"""Pure ctypes layout/API doubles, with no actual Windows API calls."""
import ctypes,copy,struct,unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import Mock,patch
from contracts import Gate
import windows_os_trust as os_trust
from test_os_catalog_minimal import catalog_fixture,signed
from test_php_runtime import inert_pe
from pe_dependencies import pe_info
from minimal_imports import minimum_private_graph


class ApiDoubles(unittest.TestCase):
    def test_catalog_wintrust_receives_same_handle_hash_and_tag_and_closes(self):
        t=os_trust._types();calls=[];hashed=b'\x12'*32
        def verify(hwnd,guid,ptr):
            trust=ptr._obj;calls.append(trust.action)
            self.assertEqual(os_trust.WVT_FLAGS,trust.flags)
            if trust.action==1:
                self.assertEqual(2,trust.choice)
                cat=ctypes.cast(trust.target,ctypes.POINTER(t['Catalog'])).contents
                self.assertEqual(9,cat.handle);self.assertEqual(3,cat.admin)
                self.assertEqual(hashed,ctypes.string_at(cat.hash,cat.length))
                self.assertEqual(hashed.hex().upper(),cat.tag)
                return 0x800b0100
            return 0
        result=os_trust.verify_target(Path('C:/Windows/System32/normaliz.dll'),9,t,SimpleNamespace(WinVerifyTrust=verify),None,Path('C:/Windows/System32/CatRoot/INERT/c.cat'),3,hashed)
        self.assertEqual([1,2],calls);self.assertEqual(0x800b0100,result['status'])

    def capture_double(self,success):
        fixture=catalog_fixture();t=os_trust._types();w=t['w']
        kernel=SimpleNamespace(CreateFileW=Mock(side_effect=[9,10]),CloseHandle=Mock(),SetFilePointerEx=Mock(return_value=True))
        def acquire(ptr,*args):ptr._obj.value=3;return True
        def calc(admin,handle,size,buf,flags):
            self.assertEqual(9,handle);self.assertEqual(0,flags);size._obj.value=32
            if buf is not None:
                for i in range(32):buf[i]=0xcc
            return True
        def catalog_info(handle,ptr,flags):ptr._obj.path='C:/Windows/System32/CatRoot/INERT/catalog.cat';return True
        win=SimpleNamespace(CryptCATAdminAcquireContext2=acquire,CryptCATAdminCalcHashFromFileHandle2=calc,CryptCATAdminEnumCatalogFromHash=Mock(side_effect=[41,None]),CryptCATCatalogInfoFromContext=catalog_info,CryptCATAdminReleaseCatalogContext=Mock(),CryptCATAdminReleaseContext=Mock())
        sig=signed() if success else dict(status=0x800b0109)
        def facts(path):return copy.deepcopy(fixture['catalogs'][0]['file'] if str(path).endswith('.cat') else fixture['file'])
        with patch('windows_os_trust._libraries',return_value=(win,None)),patch('windows_os_trust._api',return_value=(kernel,None,w)),patch('windows_os_trust.readonly_fact',side_effect=facts),patch('windows_os_trust.verify_target',side_effect=[dict(status=0x800b0100),sig]):
            result=os_trust.capture_named(Path(fixture['file']['path']),fixture['system_root'])
        kernel.CloseHandle.assert_any_call(9);kernel.CloseHandle.assert_any_call(10)
        win.CryptCATAdminReleaseContext.assert_called_once()
        return result,win
    def test_early_catalog_success_releases_owned_context(self):
        result,win=self.capture_double(True)
        self.assertEqual('SUPPORTED_WINDOWS_SIGNATURE_QUALIFIED',result['qualification']['state'])
        win.CryptCATAdminReleaseCatalogContext.assert_called_once()
    def test_enum_exhaustion_does_not_release_consumed_context_again(self):
        result,win=self.capture_double(False)
        self.assertEqual('OS_SIGNATURE_NOT_QUALIFIED',result['qualification']['state'])
        win.CryptCATAdminReleaseCatalogContext.assert_not_called()
        self.assertEqual(2,win.CryptCATAdminEnumCatalogFromHash.call_count)


class RealInertPeSplit(unittest.TestCase):
    def make(self,target='iphlpapi.dll'):
        data=bytearray(inert_pe(['kernel32.dll']));opt=0x98
        struct.pack_into('<II',data,opt+112+8*13,0x1100,64)
        struct.pack_into('<IIIIIIII',data,768,1,0x1300,0,0,0,0,0,0)
        raw=target.encode()+b'\0';data[1280:1280+len(raw)]=raw
        return bytes(data)
    def test_actual_parser_separates_ordinary_and_delay(self):
        data=self.make();info=pe_info(data)
        self.assertEqual(['kernel32.dll'],info['ordinary_imports']);self.assertEqual(['iphlpapi.dll'],info['delay_imports'])
        graph=minimum_private_graph({'php.exe':data},['php.exe'])
        self.assertNotIn('iphlpapi.dll',graph['mandatory_os'])
    def test_optional_system_exe_does_not_weaken_private_import_rules(self):
        data=self.make('inert.exe')
        with self.assertRaises(Gate):pe_info(data)
        self.assertEqual(['inert.exe'],pe_info(data,system_image=True)['delay_imports'])
