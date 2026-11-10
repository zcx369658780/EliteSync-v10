"""Bounded static PE DLL-name inventory, never a Windows loader or qualifier.

Format reference: https://learn.microsoft.com/en-us/windows/win32/debug/pe-format
Reads import and delay-import descriptors only. Dynamic LoadLibrary, forwarded
exports, API-set/SxS resolution and actual loaded modules remain unproven.
"""
from pathlib import PurePosixPath
import re
import struct


MAX_PE_BYTES = 512 * 1024**2
MAX_DESCRIPTORS = 4096


def parse_imports(raw):
    if type(raw) is not bytes or not 64 <= len(raw) <= MAX_PE_BYTES:
        raise ValueError('bounded PE file bytes required')

    def unpack(fmt, offset):
        size = struct.calcsize(fmt)
        if offset < 0 or offset + size > len(raw):
            raise ValueError('PE field outside file')
        return struct.unpack_from(fmt, raw, offset)

    if raw[:2] != b'MZ':
        raise ValueError('DOS header required')
    pe, = unpack('<I', 0x3c)
    if pe < 64 or raw[pe:pe + 4] != b'PE\0\0':
        raise ValueError('PE signature required')
    machine, sections, _, _, _, opt_size, _ = unpack('<HHIIIHH', pe + 4)
    opt = pe + 24
    magic, = unpack('<H', opt)
    if magic not in (0x10b, 0x20b) or not 1 <= sections <= 96:
        raise ValueError('supported PE32/PE32+ header required')
    bits = 64 if magic == 0x20b else 32
    if machine not in ({0x8664, 0xaa64} if bits == 64 else {0x14c}):
        raise ValueError('machine and optional header disagree or are unsupported')
    directory = 112 if bits == 64 else 96
    if opt_size < directory or opt + opt_size + sections * 40 > len(raw):
        raise ValueError('truncated optional/section header')
    directory_count, = unpack('<I', opt + directory - 4)
    if directory_count > (opt_size - directory) // 8:
        raise ValueError('directory count exceeds optional header')
    header_size, = unpack('<I', opt + 60)
    if not opt + opt_size + sections * 40 <= header_size <= len(raw):
        raise ValueError('invalid file-backed header range')
    image_base, = unpack('<Q' if bits == 64 else '<I', opt + (24 if bits == 64 else 28))
    ranges = [(0, header_size, 0)]
    virtual_ranges = [(0, header_size)]
    for index in range(sections):
        section = opt + opt_size + index * 40
        virtual_size, rva, size, offset = unpack('<IIII', section + 8)
        end = rva + max(virtual_size, size)
        if end > 0x100000000 or offset + size > len(raw):
            raise ValueError('section exceeds bounded address/file range')
        if end > rva:
            if any(rva < right and left < end for left, right in virtual_ranges):
                raise ValueError('overlapping PE virtual ranges')
            virtual_ranges.append((rva, end))
        if size:
            ranges.append((rva, rva + size, offset))

    def file_offset(rva, count):
        matches = [offset + rva - left for left, right, offset in ranges
                   if left <= rva and rva + count <= right]
        if len(matches) != 1:
            raise ValueError('RVA is not uniquely file-backed')
        return matches[0]

    def dll_name(rva):
        name = bytearray()
        for index in range(256):
            value = raw[file_offset(rva + index, 1)]
            if value == 0:
                text = name.decode('ascii')
                if not re.fullmatch(r'[A-Za-z0-9_][A-Za-z0-9_.+\-]*', text) or '..' in text:
                    raise ValueError('canonical DLL basename required')
                return text
            name.append(value)
        raise ValueError('unterminated or oversized DLL name')

    imported = []
    for kind, entry, width in [('import', 1, 20), ('delay', 13, 32)]:
        if entry >= directory_count:
            continue
        table_rva, size = unpack('<II', opt + directory + entry * 8)
        if table_rva == size == 0:
            continue
        if not table_rva or size < width or size > MAX_DESCRIPTORS * width:
            raise ValueError('bounded import descriptor table required')
        # A leading terminator must not conceal a declared directory tail that
        # exceeds the file-backed range. Conservatively require one full range.
        if table_rva + size > 0x100000000:
            raise ValueError('import directory RVA range overflow')
        file_offset(table_rva, size)
        terminated = False
        for relative in range(0, size - width + 1, width):
            fields = unpack('<' + 'I' * (width // 4), file_offset(table_rva + relative, width))
            if not any(fields):
                terminated = True
                break
            if kind == 'import':
                name_rva = fields[3]
            else:
                attributes, name_rva = fields[:2]
                if attributes not in (0, 1):
                    raise ValueError('reserved delay attributes must be zero')
                if attributes == 0:
                    name_rva -= image_base
            if name_rva <= 0:
                raise ValueError('import name address required')
            imported.append({'kind': kind, 'name': dll_name(name_rva)})
        if not terminated:
            raise ValueError('descriptor terminator missing inside directory')
    return {'machine': hex(machine), 'bits': bits, 'imports': imported,
            'runtime_dependency_closure_proven': False}


def candidate_modules(parsed, role_records):
    """List basename matches inside the same declared root, not loader choices."""
    candidates = {}
    for row in role_records:
        relative = row['relative_path']
        rel = PurePosixPath(relative)
        if (rel.is_absolute() or '..' in rel.parts or '\\' in relative or ':' in relative
                or str(rel) != relative):
            raise ValueError('canonical inventoried relative path required')
        candidates.setdefault(rel.name.casefold(), []).append(relative)
    result = []
    for entry in parsed['imports']:
        paths = sorted(candidates.get(entry['name'].casefold(), []))
        status = ('NO_INVENTORIED_SAME_ROOT_CANDIDATE' if not paths else
                  'UNIQUE_INVENTORIED_CANDIDATE_NOT_LOADER_PROOF' if len(paths) == 1 else
                  'AMBIGUOUS_INVENTORIED_CANDIDATES')
        result.append({**entry, 'candidate_paths': paths, 'status': status,
                       'runtime_selected': False})
    return result


def inspect_inventoried_pe(root, row):
    # Reuse the existing handle-bound before/after content identity checks.
    from current_product_aar_handoff import _bound_file
    relative = row['relative_path']
    rel = PurePosixPath(relative)
    if (not relative or rel.is_absolute() or '..' in rel.parts or '\\' in relative
            or ':' in relative or str(rel) != relative):
        raise ValueError('canonical inventoried PE path required')
    if type(row['bytes']) is not int or not 64 <= row['bytes'] <= MAX_PE_BYTES:
        raise ValueError('bounded PE size required before reading')
    with _bound_file(root, row) as stream:
        raw = stream.read(row['bytes'] + 1)
        if len(raw) != row['bytes']:
            raise ValueError('inventoried PE size changed')
        parsed = parse_imports(raw)
    return parsed
