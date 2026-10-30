import struct,unittest
from contracts import Gate
from test_php_runtime import inert_pe
from pe_symbols import inspect_symbols,split_forwarder
from native_closure import build


def importer():
    raw=bytearray(inert_pe(['host.dll']))
    struct.pack_into('<I',raw,512,0x1180);struct.pack_into('<I',raw,512+16,0x1190)
    struct.pack_into('<QQ',raw,896,0x11c0,0);raw[960:967]=b'\0\0Work\0'
    return bytes(raw)


def exporting(name='Work',forwarder=None):
    raw=bytearray(inert_pe());opt=0x98;struct.pack_into('<I',raw,opt+56,0x2000);struct.pack_into('<II',raw,opt+112,0x1000,0x200)
    struct.pack_into('<IIHH7I',raw,512,0,0,0,0,0,1,1,1,0x1080,0x1090,0x10a0)
    struct.pack_into('<I',raw,640,0x10c0 if forwarder else 0x1300);struct.pack_into('<I',raw,656,0x10b0);struct.pack_into('<H',raw,672,0)
    text=name.encode()+b'\0';raw[688:688+len(text)]=text
    if forwarder:
        text=forwarder.encode()+b'\0';raw[704:704+len(text)]=text
    return bytes(raw)


class RequiredPeSymbols(unittest.TestCase):
    def test_actual_import_name_table(self):self.assertEqual(['Work'],inspect_symbols(importer())['imports']['host.dll'])
    def test_actual_export_name_and_ordinal(self):
        symbols=inspect_symbols(exporting())['exports'];self.assertEqual(symbols['Work'],symbols['#1'])
    def test_actual_forwarder_table(self):self.assertEqual('other.Real',inspect_symbols(exporting(forwarder='other.Real'))['exports']['Work']['forwarder'])
    def test_static_symbol_closure_is_not_a_process(self):
        result=build({'php.exe':importer()},{},None,lambda name,why:exporting(),lambda:None)
        self.assertFalse(result['php_loaded']);self.assertTrue(result['static_only']);self.assertEqual(1,len(result['required_symbol_proofs']))
    def test_missing_required_export_rejected(self):
        with self.assertRaisesRegex(Gate,'REQUIRED_EXPORT_MISSING'):build({'php.exe':importer()},{},None,lambda n,w:exporting('Other'),lambda:None)
    def test_forwarder_cycle_rejected(self):
        def load(name,why):return exporting(forwarder='other.Work' if name=='host.dll' else 'host.Work')
        with self.assertRaisesRegex(Gate,'FORWARDER_CYCLE'):build({'php.exe':importer()},{},None,load,lambda:None)
    def test_unqualified_extra_vc_forwarder_rejected(self):
        with self.assertRaisesRegex(Gate,'EXTRA_VC'):build({'php.exe':importer()},{},None,lambda n,w:exporting(forwarder='vcruntime150.Work'),lambda:None)
    def test_forwarder_path_rejected(self):
        with self.assertRaises(Gate):split_forwarder('../private.Work')

    def test_required_export_outside_image_rejected(self):
        raw=bytearray(exporting());struct.pack_into('<I',raw,640,0x99999999)
        with self.assertRaisesRegex(Gate,'EXPORT_RVA_INVALID'):build({'php.exe':importer()},{},None,lambda n,w:bytes(raw),lambda:None)
    def test_valid_bss_export_not_mistaken_for_unmapped_file_bytes(self):
        raw=bytearray(exporting());section=0x98+240;struct.pack_into('<I',raw,section+8,0x1000);struct.pack_into('<I',raw,640,0x1f00)
        result=build({'php.exe':importer()},{},None,lambda n,w:bytes(raw),lambda:None)
        self.assertEqual(0x1f00,result['required_symbol_proofs'][0]['endpoint']['rva'])
