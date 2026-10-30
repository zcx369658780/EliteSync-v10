"""Supported running-schema lookup from an already loaded, pinned KernelBase.

GetModuleHandle/GetProcAddress only: no LoadLibrary or unqualified image load.
The lookup is not a file/signature/export check and never grants native PASS.
"""
import ctypes,os,re
from pathlib import Path
from contracts import need,digest,canonical
from os_images import _api,readonly_fact,norm,validate_os_source


def validate_query(candidate,value):
    need(value.get('hresult')==0 and value.get('available') is True,'API_SET_SUPPORTED_QUERY_FAILED')
    need(re.fullmatch(r'[a-z0-9_.-]+[.]dll',value.get('host','')) is not None and '..' not in value['host'],'API_SET_QUERY_HOST_PATH')
    need(value.get('actual_name_length')==len(value['host'])+1 and 0<value.get('actual_name_length',0)<=value.get('buffer_capacity',0)<=32767,'API_SET_QUERY_LENGTH')
    need(value['host']==candidate,'API_SET_RAW_AND_RUNNING_SCHEMA_DISAGREE')
    need(value.get('provider_module')=='kernelbase.dll' and value.get('provider_owner_matches') is True,'API_SET_QUERY_PROVIDER_IDENTITY')
    return candidate


class BoundQuery:
    def __init__(self,system,policy):
        self.k,_,w=_api();self.handle=None;self.w=w;self.receipts=[]
        path=Path(system['path'])/'kernelbase.dll';fact=readonly_fact(path);validate_os_source(fact,policy,system)
        self.handle=self.k.CreateFileW(str(path),0x80000000,1,None,3,0x00200000,None)
        need(self.handle!=ctypes.c_void_p(-1).value,'API_SET_QUERY_PROVIDER_HOLD')
        try:
            need(readonly_fact(path)==fact,'API_SET_QUERY_PROVIDER_CHANGED')
            k=self.k;k.GetModuleHandleW.argtypes=[w.LPCWSTR];k.GetModuleHandleW.restype=w.HMODULE
            k.GetModuleFileNameW.argtypes=[w.HMODULE,w.LPWSTR,w.DWORD];k.GetModuleFileNameW.restype=w.DWORD
            k.GetProcAddress.argtypes=[w.HMODULE,ctypes.c_char_p];k.GetProcAddress.restype=ctypes.c_void_p
            k.GetModuleHandleExW.argtypes=[w.DWORD,ctypes.c_void_p,ctypes.POINTER(w.HMODULE)];k.GetModuleHandleExW.restype=w.BOOL
            module=k.GetModuleHandleW(str(path));need(module,'API_SET_QUERY_PROVIDER_NOT_ALREADY_LOADED')
            text=ctypes.create_unicode_buffer(32768);need(k.GetModuleFileNameW(module,text,len(text))>0 and norm(text.value)==norm(str(path)),'API_SET_QUERY_PROVIDER_PATH')
            query=k.GetProcAddress(module,b'GetApiSetModuleBaseName');available=k.GetProcAddress(module,b'IsApiSetImplemented')
            need(query and available,'API_SET_QUERY_API_NOT_AVAILABLE')
            for address in [query,available]:
                owner=w.HMODULE();need(k.GetModuleHandleExW(6,address,ctypes.byref(owner)) and owner.value==module,'API_SET_QUERY_UNEXPECTED_PROVIDER')
            self.query=ctypes.WINFUNCTYPE(ctypes.c_int32,ctypes.c_char_p,w.UINT,w.LPWSTR,ctypes.POINTER(w.UINT))(query)
            self.implemented=ctypes.WINFUNCTYPE(w.BOOL,ctypes.c_char_p)(available)
            need(bool(self.implemented(b'api-ms-win-core-apiquery-l2-1-1')),'API_SET_QUERY_CONTRACT_UNAVAILABLE')
            self.path=path;self.fact=fact;self.receipt=dict(provider_module='kernelbase.dll',provider_owner_matches=True,provider_file=fact,current_control_pid=os.getpid(),module_already_loaded=True,new_module_load=False)
        except BaseException:
            self.close();raise
    def host(self,contract):
        key=contract.encode('ascii');text=ctypes.create_unicode_buffer(260);size=self.w.UINT()
        status=int(self.query(key,len(text),text,ctypes.byref(size)))
        result=dict(self.receipt,contract=contract,hresult=status,status_hex=hex(status&0xffffffff),host=text.value.lower(),actual_name_length=int(size.value),buffer_capacity=len(text),query_interface_implemented=True,lookup_succeeded=status==0,available=status==0)
        self.receipts.append(result)
        return result
    def close(self):
        if self.handle is not None:
            self.k.CloseHandle(self.handle);self.handle=None
    def __enter__(self):return self
    def __exit__(self,*exc):
        try:need(readonly_fact(self.path)==self.fact,'API_SET_QUERY_PROVIDER_CHANGED')
        finally:self.close()
