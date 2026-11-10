"""Offline byte/metadata fixtures; no SDK, VM, compiler or process execution."""
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import cmake_version_binding as binding
from test_native_import_inventory import fixture


class CMakeVersionBindingTests(unittest.TestCase):
    def setUp(self):
        self.version = b'3.22.1-g37088a8-dirty'
        pe = fixture();pe[1400:1400 + len(self.version)] = self.version
        self.pe = bytes(pe)
        self.properties = b'Pkg.Revision = 3.22.1\nPkg.Path = cmake;3.22.1\nPkg.Desc = CMake 3.22.1\n'
        self.xml = b'''<r:repository xmlns:r="http://schemas.android.com/repository/android/common/02">
<localPackage path="cmake;3.22.1"><revision><major>3</major><minor>22</minor><micro>1</micro></revision></localPackage></r:repository>'''
        self.stdout = (b'cmake version ' + self.version + b'\n\n'
                       b'CMake suite maintained and supported by Kitware (kitware.com/cmake).\n')

    def derive(self, **changed):
        inputs = dict(pe=self.pe, properties=self.properties, package_xml=self.xml,
                      stdout=self.stdout, stderr=b'')
        return binding.derive_expectation(**{**inputs, **changed})

    def encoded(self):
        raw = json.dumps(self.derive(), sort_keys=True).encode()
        return raw, hashlib.sha256(raw).hexdigest()

    def test_full_literal_is_bound_without_runtime_or_spent_case_acceptance(self):
        result = self.derive()
        self.assertEqual(result['version_literal'], self.version.decode())
        self.assertEqual(result['expected_first_line'], 'cmake version ' + self.version.decode())
        self.assertEqual(result['package_revision'], '3.22.1')
        self.assertEqual(result['literal_offsets'], [1400])
        for key in ('execution_allowed', 'runtime_qualified', 'producer_allowed', 'G2'):
            self.assertIs(result[key], False)

    def test_exact_output_checker_remains_a_pure_byte_match(self):
        raw, digest = self.encoded()
        result = binding.check_output(raw, digest, self.pe, self.stdout, b'')
        self.assertEqual(result['status'], 'OUTPUT_BYTES_MATCH_OFFLINE_EXPECTATION')
        self.assertIs(result['runtime_qualified'], False)

    def test_abbreviation_wrong_suffix_whitespace_newline_and_extra_output_rejected(self):
        raw, digest = self.encoded()
        for output in (self.stdout.replace(self.version, b'3.22.1'),
                       self.stdout.replace(b'g37088a8', b'g1234567'),
                       b' ' + self.stdout, self.stdout.replace(b'\n', b'\r\n'),
                       self.stdout + b'extra\n', self.stdout.rstrip(b'\n'), b''):
            with self.subTest(output=output), self.assertRaises(ValueError):
                binding.check_output(raw, digest, self.pe, output, b'')
        with self.assertRaises(ValueError):
            binding.check_output(raw, digest, self.pe, self.stdout, b'warning')

    def test_metadata_version_path_description_or_duplicates_fail_closed(self):
        for prop in (self.properties.replace(b'3.22.1', b'3.22.2'),
                     self.properties + b'Pkg.Revision = 3.22.1\n',
                     self.properties.replace(b'cmake;3.22.1', b'cmake;3.22.2'),
                     self.properties.replace(b'CMake 3.22.1', b'CMake other')):
            with self.subTest(properties=prop), self.assertRaises(ValueError):
                self.derive(properties=prop)
        for xml in (self.xml.replace(b'<major>3</major>', b'<major>4</major>'),
                    self.xml.replace(b'<major>3</major>', b'<major>3</major><major>3</major>'),
                    self.xml.replace(b'cmake;3.22.1', b'cmake;3.22.2'),
                    self.xml.replace(b'</revision>', b'<preview>1</preview></revision>'),
                    b'<!DOCTYPE x [<!ENTITY e "3">]>' + self.xml):
            with self.subTest(xml=xml), self.assertRaises(ValueError):
                self.derive(package_xml=xml)

    def test_literal_requires_whole_NUL_bounded_token_and_AMD64_PE(self):
        pe = bytearray(self.pe);pe[1399] = ord('X')
        with self.assertRaises(ValueError):
            self.derive(pe=bytes(pe))
        pe = bytearray(self.pe);pe[1400 + len(self.version)] = ord('X')
        with self.assertRaises(ValueError):
            self.derive(pe=bytes(pe))
        pe = fixture(bits=32);pe[1400:1400 + len(self.version)] = self.version
        with self.assertRaises(ValueError):
            self.derive(pe=bytes(pe))
        with self.assertRaises(ValueError):
            self.derive(pe=b'not PE')

    def test_UTF16_entity_bypass_rejected_and_UTF8_BOM_supported(self):
        xml = (b'<!DOCTYPE r:repository [<!ENTITY maj "3">]>' +
               self.xml.replace(b'<major>3</major>', b'<major>&maj;</major>')).decode('ascii')
        for encoding in ('utf-16-le', 'utf-16-be'):
            with self.subTest(encoding=encoding), self.assertRaises(ValueError):
                self.derive(package_xml=xml.encode(encoding))
        result = self.derive(package_xml=b'\xef\xbb\xbf' + self.xml,
                             properties=b'\xef\xbb\xbf' + self.properties)
        self.assertEqual(result['version_literal'], self.version.decode())

    def test_pinned_expectation_or_PE_drift_and_authority_flags_are_rejected(self):
        raw, digest = self.encoded()
        with self.assertRaises(ValueError):
            binding.check_output(raw + b' ', digest, self.pe, self.stdout, b'')
        with self.assertRaises(ValueError):
            binding.check_output(raw, digest, self.pe + b'changed', self.stdout, b'')
        for key, value in [('runtime_qualified', True), ('G2', 0), ('schema', True)]:
            data = self.derive();data[key] = value;bad = json.dumps(data).encode()
            with self.subTest(key=key), self.assertRaises(ValueError):
                binding.check_output(bad, hashlib.sha256(bad).hexdigest(), self.pe, self.stdout, b'')

    def test_input_caps_and_malformed_expectation_rejected(self):
        with self.assertRaises(ValueError):
            self.derive(stdout=b'x' * 4097)
        raw = b'{"schema":1,"schema":1}'
        with self.assertRaises(ValueError):
            binding.check_output(raw, hashlib.sha256(raw).hexdigest(), self.pe, self.stdout, b'')

    def test_inventoried_files_hold_all_handles_and_reject_drift(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory);cmake = root / 'CMake';case = root / 'case'
            (cmake / 'bin').mkdir(parents=True);(case / 'output').mkdir(parents=True)
            files = {'bin/cmake.exe': self.pe, 'source.properties': self.properties, 'package.xml': self.xml}
            outputs = {'output/tool.stdout': self.stdout, 'output/tool.stderr': b''}
            def rows(parent, values):
                result = []
                for rel, raw in values.items():
                    path = parent / rel;path.write_bytes(raw);info = path.stat()
                    result.append(dict(role='fixture', relative_path=rel, path=str(path), bytes=len(raw),
                        sha256=hashlib.sha256(raw).hexdigest(), file_id={'device': info.st_dev, 'inode': info.st_ino}))
                return result
            inputs = rows(cmake, files);observed = rows(case, outputs)
            result = binding.inspect_inputs(cmake, inputs, case, observed)
            self.assertEqual(result['expectation'], self.derive())
            self.assertEqual(len(result['bound_files']), 5)
            real = binding.derive_expectation
            def derive_then_drift(**kwargs):
                result = real(**kwargs)
                (cmake / 'source.properties').write_bytes(b'changed after read')
                return result
            with patch.object(binding, 'derive_expectation', side_effect=derive_then_drift):
                with self.assertRaises(ValueError):
                    binding.inspect_inputs(cmake, inputs, case, observed)
            self.assertTrue((cmake / 'bin/cmake.exe').exists())


if __name__ == '__main__':
    unittest.main()
