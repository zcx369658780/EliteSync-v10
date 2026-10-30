import struct,unittest
from contracts import Gate
from api_set_schema import parse_schema,resolve,archive_then_parse
from test_php_runtime import inert_pe


def inert_schema():
    pe=bytearray(inert_pe());table=0x98+240;pe[table:table+8]=b'.apiset\0'
    raw=bytearray(1536);struct.pack_into('<7I',raw,0,6,1536,0,1,28,0,0)
    name='api-ms-inert-l1-1-0'.encode('utf-16-le');host='inert.dll'.encode('utf-16-le')
    raw[100:100+len(name)]=name;raw[200:200+len(host)]=host
    struct.pack_into('<6I',raw,28,0,100,len(name),len(name),52,1)
    struct.pack_into('<5I',raw,52,0,0,0,200,len(host));pe[512:2048]=raw
    return bytes(pe)


class ApiSetParser(unittest.TestCase):
    def test_actual_bounded_schema_parser(self):self.assertEqual('inert.dll',resolve(parse_schema(inert_schema()),'api-ms-inert-l1-1-0.dll','php.exe'))
    def test_unsupported_version_rejected(self):
        raw=bytearray(inert_schema());struct.pack_into('<I',raw,512,7)
        with self.assertRaises(Gate):parse_schema(raw)
    def test_out_of_bounds_string_rejected(self):
        raw=bytearray(inert_schema());struct.pack_into('<I',raw,512+28+4,999999)
        with self.assertRaises(Gate):resolve(parse_schema(raw),'api-ms-inert-l1-1-0.dll','php.exe')
    def test_host_path_rejected(self):
        raw=bytearray(inert_schema());host='../bad.dll'.encode('utf-16-le');raw[712:712+len(host)]=host;struct.pack_into('<I',raw,512+52+16,len(host))
        with self.assertRaises(Gate):resolve(parse_schema(raw),'api-ms-inert-l1-1-0.dll','php.exe')
    def test_empty_host_is_not_permission_to_skip(self):
        with self.assertRaises(Gate):resolve({'api-ms-inert':[dict(alias='',host='')]},'api-ms-inert.dll','php.exe')
    def test_ambiguous_host_rejected(self):
        with self.assertRaises(Gate):resolve({'api-ms-inert':[dict(alias='',host='one.dll'),dict(alias='',host='two.dll')]},'api-ms-inert.dll','php.exe')
    def test_importer_alias_must_be_exact(self):
        schema={'api-ms-inert':[dict(alias='',host='one.dll'),dict(alias='php.exe',host='two.dll')]}
        self.assertEqual('two.dll',resolve(schema,'api-ms-inert.dll','php.exe'))
        self.assertEqual('one.dll',resolve(schema,'api-ms-inert.dll','other.exe'))

    def test_unrelated_kernel_host_not_required_or_allowed_as_dll(self):
        schema={'api-ms-good':[dict(alias='',host='good.dll')],'api-ms-kernel':[dict(alias='',host='kernel.sys')]}
        self.assertEqual('good.dll',resolve(schema,'api-ms-good.dll','php.exe'))
        with self.assertRaises(Gate):resolve(schema,'api-ms-kernel.dll','php.exe')
    def test_raw_input_persisted_before_parser_failure(self):
        from contracts import digest
        from unittest.mock import patch
        seen=[];raw=b'INVALID_SCHEMA_INPUT'
        with patch('windows_os_trust.evaluate_file',return_value={}):
            with self.assertRaises(Gate):archive_then_parse(raw,dict(file=dict(sha256=digest(raw))),seen.append)
        self.assertEqual([raw],seen)
    def test_persistence_failure_prevents_parsing(self):
        from contracts import digest
        from unittest.mock import patch
        raw=b'INERT'
        with patch('api_set_schema.parse_schema',side_effect=AssertionError('NO_PARSE')):
            with self.assertRaisesRegex(OSError,'PERSIST_FAILED'):
                archive_then_parse(raw,dict(file=dict(sha256=digest(raw))),lambda b: (_ for _ in ()).throw(OSError('PERSIST_FAILED')))

    def test_missing_archive_cannot_be_replaced_by_a_pass_label(self):
        from current_native_task import validate_api_set_closure
        from pathlib import Path
        with self.assertRaisesRegex(Gate,'ARCHIVE_REQUIRED'):
            validate_api_set_closure(Path('C:/INERT'),dict(state='OS_CATALOG_AND_MINIMUM_IMPORT_PROVEN'),dict(ordinary_edges=[]))

    def test_source_path_cannot_escape_raw_namespace(self):
        from current_native_task import validate_api_set_closure
        from pathlib import Path
        with self.assertRaisesRegex(Gate,'ARCHIVE_PATH'):
            validate_api_set_closure(Path('C:/INERT'),dict(api_set_schema=dict(archived_relative_path='../schema.bin')),dict(ordinary_edges=[]))

    def revision_schema(self,published=2,hashed=True):
        raw=bytearray(inert_schema());name=('api-ms-inert-l1-1-'+str(published)).encode('utf-16-le')
        raw[612:612+len(name)]=name
        struct.pack_into('<I',raw,512+28+8,len(name))
        struct.pack_into('<I',raw,512+28+12,len('api-ms-inert-l1-1'.encode('utf-16-le')) if hashed else len(name))
        return bytes(raw)
    def test_signed_hashed_prefix_maps_older_revision_without_host_guess(self):
        schema=parse_schema(self.revision_schema())
        self.assertEqual('inert.dll',resolve(schema,'api-ms-inert-l1-1-0.dll','php.exe'))
        self.assertEqual('api-ms-inert-l1-1-2',schema.selected_entries['api-ms-inert-l1-1-0']['published'])
    def test_newer_request_not_silently_aliased(self):
        with self.assertRaises(Gate):resolve(parse_schema(self.revision_schema()),'api-ms-inert-l1-1-3.dll','php.exe')
    def test_other_major_family_not_aliased(self):
        with self.assertRaises(Gate):resolve(parse_schema(self.revision_schema()),'api-ms-inert-l2-1-0.dll','php.exe')
    def test_compatibility_requires_explicit_signed_hashed_prefix(self):
        with self.assertRaises(Gate):resolve(parse_schema(self.revision_schema(hashed=False)),'api-ms-inert-l1-1-0.dll','php.exe')
