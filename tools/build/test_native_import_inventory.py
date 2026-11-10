import hashlib
from pathlib import Path
import struct
import tempfile
import unittest

from native_import_inventory import parse_imports, candidate_modules, inspect_inventoried_pe


def fixture(*, bits=64, legacy_delay=False):
    raw = bytearray(2048)
    raw[:2] = b'MZ'
    struct.pack_into('<I', raw, 0x3c, 0x80)
    raw[0x80:0x84] = b'PE\0\0'
    opt_size = 240 if bits == 64 else 224
    struct.pack_into('<HHIIIHH', raw, 0x84, 0x8664 if bits == 64 else 0x14c,
                     1, 0, 0, 0, opt_size, 2)
    opt = 0x98
    struct.pack_into('<H', raw, opt, 0x20b if bits == 64 else 0x10b)
    image_base = 0x140000000 if bits == 64 else 0x400000
    struct.pack_into('<Q' if bits == 64 else '<I', raw, opt + (24 if bits == 64 else 28), image_base)
    struct.pack_into('<I', raw, opt + 60, 512)
    directory = opt + (112 if bits == 64 else 96)
    struct.pack_into('<I', raw, directory - 4, 16)
    struct.pack_into('<II', raw, directory + 8, 0x1000, 40)
    struct.pack_into('<II', raw, directory + 13 * 8, 0x1040, 64)
    section = opt + opt_size
    raw[section:section + 8] = b'.rdata\0\0'
    struct.pack_into('<IIII', raw, section + 8, 1536, 0x1000, 1536, 512)
    struct.pack_into('<IIIII', raw, 512, 0x1100, 0, 0, 0x1200, 0x1120)
    struct.pack_into('<IIIIIIII', raw, 576, 0 if legacy_delay else 1,
                     0x1240 + (image_base if legacy_delay else 0), 0, 0, 0, 0, 0, 0)
    raw[1024:1024 + 13] = b'KERNEL32.dll\0'
    raw[1088:1088 + 12] = b'example.dll\0'
    return raw


class ImportInventoryTests(unittest.TestCase):
    def test_import_and_delay_names_for_both_PE_formats(self):
        for bits in (32, 64):
            parsed = parse_imports(bytes(fixture(bits=bits)))
            self.assertEqual(parsed['bits'], bits)
            self.assertEqual(parsed['imports'], [
                {'kind': 'import', 'name': 'KERNEL32.dll'},
                {'kind': 'delay', 'name': 'example.dll'}])
            self.assertIs(parsed['runtime_dependency_closure_proven'], False)

    def test_legacy_delay_VA_converted_using_image_base(self):
        parsed = parse_imports(bytes(fixture(bits=32, legacy_delay=True)))
        self.assertEqual(parsed['imports'][1]['name'], 'example.dll')

    def test_header_truncation_and_unknown_format_rejected(self):
        for size in (0, 60, 128, 160, 400):
            with self.subTest(size=size), self.assertRaises(ValueError):
                parse_imports(bytes(fixture()[:size]))
        raw = fixture()
        struct.pack_into('<H', raw, 0x98, 0x999)
        with self.assertRaises(ValueError):
            parse_imports(bytes(raw))

    def test_directory_count_must_fit_optional_header(self):
        raw = fixture()
        struct.pack_into('<I', raw, 0x98 + 108, 100)
        with self.assertRaises(ValueError):
            parse_imports(bytes(raw))

    def test_missing_terminator_does_not_read_past_directory(self):
        raw = fixture()
        struct.pack_into('<I', raw, 0x98 + 112 + 8 + 4, 20)
        with self.assertRaises(ValueError):
            parse_imports(bytes(raw))

    def test_early_terminator_cannot_hide_unbacked_directory_tail(self):
        for entry, size in ((1, 81920), (13, 131072)):
            raw = fixture()
            struct.pack_into('<I', raw, 0x98 + 112 + entry * 8 + 4, size)
            with self.subTest(entry=entry), self.assertRaises(ValueError):
                parse_imports(bytes(raw))

    def test_import_directory_RVA_range_cannot_wrap(self):
        raw = fixture()
        struct.pack_into('<II', raw, 0x98 + 112 + 8, 0xfffffff0, 40)
        with self.assertRaises(ValueError):
            parse_imports(bytes(raw))

    def test_unbacked_RVA_and_overlapping_section_rejected(self):
        raw = fixture()
        struct.pack_into('<I', raw, 512 + 12, 0x2000)
        with self.assertRaises(ValueError):
            parse_imports(bytes(raw))
        raw = fixture()
        struct.pack_into('<H', raw, 0x84 + 2, 2)
        section = 0x98 + 240
        raw[section + 40:section + 80] = raw[section:section + 40]
        with self.assertRaises(ValueError):
            parse_imports(bytes(raw))

    def test_unsafe_import_name_and_reserved_delay_flags_rejected(self):
        raw = fixture()
        raw[1024:1024 + 14] = b'../unsafe.dll\0'
        with self.assertRaises(ValueError):
            parse_imports(bytes(raw))
        raw = fixture()
        struct.pack_into('<I', raw, 576, 3)
        with self.assertRaises(ValueError):
            parse_imports(bytes(raw))

    def test_candidate_lookup_reports_ambiguity_without_selecting_loader_path(self):
        parsed = parse_imports(bytes(fixture()))
        rows = [{'relative_path': 'bin/example.dll', 'sha256': 'a' * 64},
                {'relative_path': 'other/EXAMPLE.DLL', 'sha256': 'b' * 64}]
        result = candidate_modules(parsed, rows)
        self.assertEqual(result[0]['candidate_paths'], [])
        self.assertEqual(len(result[1]['candidate_paths']), 2)
        self.assertEqual(result[1]['status'], 'AMBIGUOUS_INVENTORIED_CANDIDATES')
        self.assertIs(result[1]['runtime_selected'], False)

    def test_file_inspection_rechecks_inventoried_bytes_and_identity(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / 'fixture.exe'
            raw = bytes(fixture())
            path.write_bytes(raw)
            info = path.stat()
            row = {'relative_path': path.name, 'bytes': len(raw),
                   'file_id': {'device': info.st_dev, 'inode': info.st_ino},
                   'sha256': hashlib.sha256(raw).hexdigest()}
            self.assertEqual(len(inspect_inventoried_pe(root, row)['imports']), 2)
            row['sha256'] = '0' * 64
            with self.assertRaises(ValueError):
                inspect_inventoried_pe(root, row)
            row['relative_path'] = '../fixture.exe'
            with self.assertRaises(ValueError):
                inspect_inventoried_pe(root, row)


if __name__ == '__main__':
    unittest.main()
