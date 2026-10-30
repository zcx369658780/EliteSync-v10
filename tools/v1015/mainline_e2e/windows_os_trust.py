"""Named Windows embedded/catalog signature evidence; no actions on import.

Caller reserves a complete observation BEFORE calling capture_named(). No catalog
database mutation, system file writes, online retrieval, or unverified DLL loads.
All returned certificate/path/identity evidence is LOCAL_ONLY_RAW.
"""
import base64,ctypes,hashlib,ntpath
from pathlib import Path
from contracts import need,digest,canonical
from os_images import readonly_fact,norm,_api

WVT_FLAGS=0x1080
CHAIN_FLAGS=0xC0000104
CODE_SIGNING='1.3.6.1.5.5.7.3.3'
TIME_STAMPING='1.3.6.1.5.5.7.3.8'


def evaluate_signature(evidence):
    """Pure result evaluation; metadata strings cannot grant trust."""
    need(evidence.get('provider_flags')==WVT_FLAGS and evidence.get('online_retrieval') is False,'OS_TRUST_FLAGS')
    need(evidence.get('status')==0,'OS_WINVERIFYTRUST_FAILED')
    signer=evidence.get('signer',{})
    need(signer.get('provider_error')==0 and signer.get('provider_chain_error')==0,'OS_SIGNER_PROVIDER_CHAIN')
    need(signer.get('chain_api_ok') is True and signer.get('chain_error')==0 and signer.get('chain_flags')==CHAIN_FLAGS,'OS_SIGNER_CHAIN_REVOCATION')
    need(CODE_SIGNING in signer.get('eku',[]) and signer.get('eku_api_ok') is True,'OS_CODE_SIGNING_EKU')
    policies=signer.get('policies',{})
    auth=policies.get('authenticode',{})
    need(auth.get('api_ok') is True and auth.get('error')==0 and auth.get('oid')==2 and auth.get('flags')==0,'OS_AUTHENTICODE_POLICY')
    need(any((policies.get(k,{ }).get('api_ok') is True and policies[k].get('error')==0 and policies[k].get('oid')==7 and policies[k].get('flags')==flag) for k,flag in [('microsoft_application',0x20000),('microsoft_product',0)]),'OS_MICROSOFT_ROOT_POLICY')
    need(type(signer.get('verify_as_of')) is int and signer['verify_as_of']>0,'OS_TRUSTED_VERIFY_TIME_MISSING')
    need(signer.get('verify_time_from_wintrust_provider') is True,'OS_ARBITRARY_VERIFY_TIME')
    count=evidence.get('counter_signers')
    need(type(count) is int and 0<=count<=8,'OS_TIMESTAMP_COUNT')
    timestamps=evidence.get('timestamps',[])
    need(len(timestamps)==count,'OS_TIMESTAMP_EVIDENCE_MISSING')
    for stamp in timestamps:
        need(stamp.get('signer_type')==0x10 and stamp.get('provider_error')==0 and stamp.get('provider_chain_error')==0,'OS_TIMESTAMP_PROVIDER')
        need(stamp.get('chain_api_ok') is True and stamp.get('chain_error')==0 and stamp.get('chain_flags')==CHAIN_FLAGS,'OS_TIMESTAMP_CHAIN_REVOCATION')
        need(stamp.get('eku_api_ok') is True and TIME_STAMPING in stamp.get('eku',[]),'OS_TIMESTAMP_EKU')
        policy=stamp.get('policies',{}).get('timestamp',{})
        need(policy.get('api_ok') is True and policy.get('error')==0 and policy.get('oid')==3 and policy.get('flags')==0 and policy.get('registry_policy_flags')==0,'OS_TIMESTAMP_POLICY')
        need(stamp.get('verify_time_from_wintrust_provider') is True and type(stamp.get('verify_as_of')) is int and stamp['verify_as_of']>0,'OS_TIMESTAMP_VERIFY_TIME')
    return dict(state='SUPPORTED_WINDOWS_SIGNATURE_QUALIFIED',time_basis='WINTRUST_TRUSTED_TIMESTAMP' if count else 'WINTRUST_CURRENT_VALIDITY',revocation='STRICT_CACHE_ONLY')


def evaluate_file(value):
    fact=value['file'];need(value.get('identity_stable') is True,'OS_SIGNATURE_FILE_CHANGED')
    need(fact.get('readonly_handle') is True and not fact.get('reparse') and norm(fact['path'])==norm(fact['canonical_path']),'OS_SIGNATURE_ALIAS')
    need(value.get('source_class')=='WINDOWS_SYSTEM_IMAGE' and norm(ntpath.dirname(fact['path']))==norm(value['system_root']['path']),'OS_SIGNATURE_SYSTEM_PATH')
    need(value['system_root'].get('from_system_directory_api') is True and fact['volume']==value['system_root']['volume'],'OS_SIGNATURE_SYSTEM_IDENTITY')
    embedded=value.get('embedded',{})
    try:
        result=evaluate_signature(embedded)
        return dict(result,method='EMBEDDED_AUTHENTICODE')
    except Exception:pass
    for catalog in value.get('catalogs',[]):
        try:
            need(catalog.get('member_identity')=={k:fact[k] for k in ['sha256','file_id','volume','bytes']},'OS_CATALOG_MEMBER_IDENTITY')
            need(catalog.get('hash_algorithm')=='SHA256' and len(bytes.fromhex(catalog['member_hash']))==32 and catalog.get('member_tag')==catalog['member_hash'].upper(),'OS_CATALOG_MEMBER_HASH')
            need(catalog.get('calculated_hash_matches_query') is True and catalog.get('catalog_identity_stable') is True and catalog.get('member_identity_stable') is True,'OS_CATALOG_FILE_SWAP')
            need(catalog.get('wintrust_member_hash')==catalog['member_hash'] and catalog.get('wintrust_member_tag')==catalog['member_tag'],'OS_CATALOG_WRONG_MEMBER')
            need(catalog['file'].get('readonly_handle') is True and not catalog['file'].get('reparse') and norm(catalog['file']['path'])==norm(catalog['file']['canonical_path']),'OS_CATALOG_PATH')
            need(norm(catalog['file']['path']).startswith(norm(value['system_root']['path'])+'/catroot/') and catalog['file']['volume']==fact['volume'],'OS_CATALOG_LOCATION')
            result=evaluate_signature(catalog['signature'])
            return dict(result,method='CATALOG_MEMBER_AUTHENTICODE',catalog_sha256=catalog['file']['sha256'])
        except Exception:continue
    need(False,'OS_EMBEDDED_AND_CATALOG_NOT_QUALIFIED')


def _types():
    from ctypes import wintypes as w
    class GUID(ctypes.Structure):_fields_=[('a',w.DWORD),('b',w.WORD),('c',w.WORD),('d',ctypes.c_ubyte*8)]
    class File(ctypes.Structure):_fields_=[('size',w.DWORD),('path',w.LPCWSTR),('handle',w.HANDLE),('subject',ctypes.c_void_p)]
    class Catalog(ctypes.Structure):_fields_=[('size',w.DWORD),('version',w.DWORD),('path',w.LPCWSTR),('tag',w.LPCWSTR),('member',w.LPCWSTR),('handle',w.HANDLE),('hash',ctypes.POINTER(ctypes.c_ubyte)),('length',w.DWORD),('context',ctypes.c_void_p),('admin',w.HANDLE)]
    class Trust(ctypes.Structure):_fields_=[('size',w.DWORD),('callback',ctypes.c_void_p),('sip',ctypes.c_void_p),('ui',w.DWORD),('revoke',w.DWORD),('choice',w.DWORD),('target',ctypes.c_void_p),('action',w.DWORD),('state',w.HANDLE),('url',w.LPWSTR),('flags',w.DWORD),('context',w.DWORD),('settings',ctypes.c_void_p)]
    class Cert(ctypes.Structure):_fields_=[('encoding',w.DWORD),('encoded',ctypes.POINTER(ctypes.c_ubyte)),('length',w.DWORD),('info',ctypes.c_void_p),('store',w.HANDLE)]
    class ProviderCert(ctypes.Structure):_fields_=[('size',w.DWORD),('cert',ctypes.POINTER(Cert))]
    class Status(ctypes.Structure):_fields_=[('error',w.DWORD),('info',w.DWORD)]
    class Element(ctypes.Structure):_fields_=[('size',w.DWORD),('cert',ctypes.POINTER(Cert)),('trust',Status),('revocation',ctypes.c_void_p),('issuance',ctypes.c_void_p),('application',ctypes.c_void_p),('extended',w.LPCWSTR)]
    class Simple(ctypes.Structure):_fields_=[('size',w.DWORD),('trust',Status),('count',w.DWORD),('elements',ctypes.POINTER(ctypes.POINTER(Element))),('list',ctypes.c_void_p),('hasfresh',w.BOOL),('freshness',w.DWORD)]
    class Chain(ctypes.Structure):_fields_=[('size',w.DWORD),('trust',Status),('count',w.DWORD),('chains',ctypes.POINTER(ctypes.POINTER(Simple))),('lowcount',w.DWORD),('low',ctypes.c_void_p),('hasfresh',w.BOOL),('freshness',w.DWORD)]
    class Signer(ctypes.Structure):pass
    Signer._fields_=[('size',w.DWORD),('time',w.FILETIME),('count',w.DWORD),('certs',ctypes.POINTER(ProviderCert)),('type',w.DWORD),('info',ctypes.c_void_p),('error',w.DWORD),('counters',w.DWORD),('counter_array',ctypes.POINTER(Signer)),('chain',ctypes.POINTER(Chain))]
    class Usage(ctypes.Structure):_fields_=[('count',w.DWORD),('oids',ctypes.POINTER(ctypes.c_char_p))]
    class Match(ctypes.Structure):_fields_=[('type',w.DWORD),('usage',Usage)]
    class ChainPara(ctypes.Structure):_fields_=[('size',w.DWORD),('requested',Match),('issuance',Match),('timeout',w.DWORD),('checkfresh',w.BOOL),('freshness',w.DWORD),('resync',ctypes.c_void_p),('strong',ctypes.c_void_p),('strongflags',w.DWORD)]
    class PolicyPara(ctypes.Structure):_fields_=[('size',w.DWORD),('flags',w.DWORD),('extra',ctypes.c_void_p)]
    class PolicyStatus(ctypes.Structure):_fields_=[('size',w.DWORD),('error',w.DWORD),('chain',ctypes.c_long),('element',ctypes.c_long),('extra',ctypes.c_void_p)]
    class TsExtra(ctypes.Structure):_fields_=[('size',w.DWORD),('registry',w.DWORD),('commercial',w.BOOL)]
    class CatalogInfo(ctypes.Structure):_fields_=[('size',w.DWORD),('path',w.WCHAR*260)]
    return locals()


def _libraries(t):
    w=t['w'];win=ctypes.WinDLL('wintrust.dll',winmode=0x800,use_last_error=True);crypt=ctypes.WinDLL('crypt32.dll',winmode=0x800,use_last_error=True)
    win.WinVerifyTrust.argtypes=[w.HWND,ctypes.POINTER(t['GUID']),ctypes.POINTER(t['Trust'])];win.WinVerifyTrust.restype=ctypes.c_int32
    win.WTHelperProvDataFromStateData.argtypes=[w.HANDLE];win.WTHelperProvDataFromStateData.restype=ctypes.c_void_p
    win.WTHelperGetProvSignerFromChain.argtypes=[ctypes.c_void_p,w.DWORD,w.BOOL,w.DWORD];win.WTHelperGetProvSignerFromChain.restype=ctypes.POINTER(t['Signer'])
    crypt.CertGetEnhancedKeyUsage.argtypes=[ctypes.POINTER(t['Cert']),w.DWORD,ctypes.c_void_p,ctypes.POINTER(w.DWORD)]
    crypt.CertGetCertificateChain.argtypes=[w.HANDLE,ctypes.POINTER(t['Cert']),ctypes.POINTER(w.FILETIME),w.HANDLE,ctypes.POINTER(t['ChainPara']),w.DWORD,ctypes.c_void_p,ctypes.POINTER(ctypes.POINTER(t['Chain']))]
    crypt.CertVerifyCertificateChainPolicy.argtypes=[ctypes.c_void_p,ctypes.POINTER(t['Chain']),ctypes.POINTER(t['PolicyPara']),ctypes.POINTER(t['PolicyStatus'])]
    crypt.CertFreeCertificateChain.argtypes=[ctypes.POINTER(t['Chain'])]
    win.CryptCATAdminAcquireContext2.argtypes=[ctypes.POINTER(w.HANDLE),ctypes.POINTER(t['GUID']),w.LPCWSTR,ctypes.c_void_p,w.DWORD];win.CryptCATAdminAcquireContext2.restype=w.BOOL
    win.CryptCATAdminCalcHashFromFileHandle2.argtypes=[w.HANDLE,w.HANDLE,ctypes.POINTER(w.DWORD),ctypes.POINTER(ctypes.c_ubyte),w.DWORD];win.CryptCATAdminCalcHashFromFileHandle2.restype=w.BOOL
    win.CryptCATAdminEnumCatalogFromHash.argtypes=[w.HANDLE,ctypes.POINTER(ctypes.c_ubyte),w.DWORD,w.DWORD,ctypes.POINTER(w.HANDLE)];win.CryptCATAdminEnumCatalogFromHash.restype=w.HANDLE
    win.CryptCATCatalogInfoFromContext.argtypes=[w.HANDLE,ctypes.POINTER(t['CatalogInfo']),w.DWORD];win.CryptCATCatalogInfoFromContext.restype=w.BOOL
    win.CryptCATAdminReleaseCatalogContext.argtypes=[w.HANDLE,w.HANDLE,w.DWORD]
    win.CryptCATAdminReleaseContext.argtypes=[w.HANDLE,w.DWORD]
    return win,crypt


def _chain_result(signer,t,crypt,is_timestamp=False):
    w=t['w'];need(signer and 0<signer.contents.count<=32,'OS_SIGNER_CERT_BOUNDS');s=signer.contents;leaf=s.certs[0].cert;need(bool(leaf),'OS_SIGNER_CERT_MISSING')
    result=dict(provider_error=int(s.error),provider_chain_error=int(s.chain.contents.trust.error) if s.chain else None,signer_type=int(s.type),verify_as_of=(int(s.time.dwHighDateTime)<<32)|int(s.time.dwLowDateTime),verify_time_from_wintrust_provider=True,chain_flags=CHAIN_FLAGS,eku=[],eku_api_ok=False,chain_api_ok=False,policies={},certificates=[])
    length=w.DWORD();ok=bool(crypt.CertGetEnhancedKeyUsage(leaf,0,None,ctypes.byref(length)))
    if ok and 0<length.value<=65536:
        buf=ctypes.create_string_buffer(length.value);ok=bool(crypt.CertGetEnhancedKeyUsage(leaf,0,buf,ctypes.byref(length)))
        if ok:
            usage=ctypes.cast(buf,ctypes.POINTER(t['Usage'])).contents;need(usage.count<=64,'OS_EKU_BOUNDS');result['eku']=[usage.oids[i].decode('ascii') for i in range(usage.count)]
    result['eku_api_ok']=ok
    oid=(TIME_STAMPING if is_timestamp else CODE_SIGNING).encode();oids=(ctypes.c_char_p*1)(oid);para=t['ChainPara']();para.size=ctypes.sizeof(para);para.requested=t['Match'](0,t['Usage'](1,oids));chain=ctypes.POINTER(t['Chain'])()
    try:
        # The time comes ONLY from a successful WinTrust verification state,
        # never from file metadata or a caller-supplied clock/string.
        ok=bool(crypt.CertGetCertificateChain(None,leaf,ctypes.byref(s.time),leaf.contents.store,ctypes.byref(para),CHAIN_FLAGS,None,ctypes.byref(chain)));result['chain_api_ok']=ok
        if not ok:return result
        cc=chain.contents;result.update(chain_error=int(cc.trust.error),chain_info=int(cc.trust.info),revocation_freshness_present=bool(cc.hasfresh),revocation_freshness_seconds=int(cc.freshness))
        need(0<cc.count<=8,'OS_CHAIN_BOUNDS')
        for j in range(cc.count):
            simple=cc.chains[j].contents;need(0<simple.count<=32,'OS_CHAIN_CERT_BOUNDS')
            for i in range(simple.count):
                el=simple.elements[i].contents;c=el.cert.contents;need(0<c.length<=1048576,'OS_CERT_SIZE');der=ctypes.string_at(c.encoded,c.length)
                result['certificates'].append(dict(chain=j,element=i,sha256=digest(der),der_base64=base64.b64encode(der).decode(),trust_error=int(el.trust.error),revocation_info_present=bool(el.revocation)))
        policies=[('timestamp',3,0)] if is_timestamp else [('authenticode',2,0),('microsoft_application',7,0x20000),('microsoft_product',7,0)]
        for name,oid,flags in policies:
            extra=t['TsExtra'](ctypes.sizeof(t['TsExtra']),0,False) if is_timestamp else None
            pp=t['PolicyPara'](ctypes.sizeof(t['PolicyPara']),flags,ctypes.addressof(extra) if extra else None);ps=t['PolicyStatus']();ps.size=ctypes.sizeof(ps)
            good=bool(crypt.CertVerifyCertificateChainPolicy(ctypes.c_void_p(oid),chain,ctypes.byref(pp),ctypes.byref(ps)))
            result['policies'][name]=dict(api_ok=good,error=int(ps.error),oid=oid,flags=flags,chain_index=int(ps.chain),element_index=int(ps.element),registry_policy_flags=0)
        return result
    finally:
        if chain:crypt.CertFreeCertificateChain(chain)


def verify_target(path,handle,t,win,crypt,catalog=None,admin=None,member_hash=None):
    w=t['w'];g=t['GUID'](0xaac56b,0xcd44,0x11d0,(ctypes.c_ubyte*8)(0x8c,0xc2,0,0xc0,0x4f,0xc2,0x95,0xee))
    if catalog:
        raw=(ctypes.c_ubyte*len(member_hash)).from_buffer_copy(member_hash)
        target=t['Catalog'](ctypes.sizeof(t['Catalog']),0,str(catalog),member_hash.hex().upper(),str(path),handle,raw,len(member_hash),None,admin);choice=2
    else:target=t['File'](ctypes.sizeof(t['File']),str(path),handle,None);choice=1
    trust=t['Trust']();trust.size=ctypes.sizeof(trust);trust.ui=2;trust.revoke=1;trust.choice=choice;trust.target=ctypes.addressof(target);trust.action=1;trust.flags=WVT_FLAGS
    result=dict(provider_flags=WVT_FLAGS,online_retrieval=False,choice=choice,timestamps=[])
    try:
        result['status']=win.WinVerifyTrust(ctypes.c_void_p(-1),ctypes.byref(g),ctypes.byref(trust))&0xffffffff
        if result['status']!=0:return result
        data=win.WTHelperProvDataFromStateData(trust.state);need(data,'OS_WVT_PROVIDER_DATA')
        signer=win.WTHelperGetProvSignerFromChain(data,0,False,0);need(signer,'OS_WVT_SIGNER')
        result['signer']=_chain_result(signer,t,crypt)
        count=int(signer.contents.counters);need(0<=count<=8,'OS_COUNTER_SIGNER_BOUNDS');result['counter_signers']=count
        for i in range(count):
            counter=win.WTHelperGetProvSignerFromChain(data,0,True,i);need(counter,'OS_WVT_COUNTER_SIGNER')
            result['timestamps'].append(_chain_result(counter,t,crypt,True))
    except Exception as exc:result['capture_error']=type(exc).__name__+': '+str(exc)
    finally:
        trust.action=2;result['state_close_status']=win.WinVerifyTrust(ctypes.c_void_p(-1),ctypes.byref(g),ctypes.byref(trust))&0xffffffff
    return result


def capture_named(path,system):
    """One member of a pre-reserved named observation; read-only API calls only."""
    path=Path(path);need(norm(str(path.parent))==norm(system['path']),'OS_NAMED_DIRECT_SYSTEM_PATH')
    need(path.name.lower()!='vcruntime140.dll','CENTRAL_TRUST_MUST_BE_REUSED')
    t=_types();win,crypt=_libraries(t);k,_,w=_api();handle=k.CreateFileW(str(path),0x80000000,1,None,3,0x00200000,None)
    need(handle!=ctypes.c_void_p(-1).value,'OS_MEMBER_READONLY_HOLD')
    result=dict(schema=1,source_class='WINDOWS_SYSTEM_IMAGE',system_root=system,catalogs=[])
    try:
        before=readonly_fact(path);need(before['volume']==system['volume'],'OS_FILE_VOLUME')
        result=dict(schema=1,source_class='WINDOWS_SYSTEM_IMAGE',system_root=system,file=before,embedded=verify_target(path,handle,t,win,crypt),catalogs=[])
        try:evaluate_signature(result['embedded']);embedded_ok=True
        except Exception:embedded_ok=False
        if not embedded_ok:
            admin=w.HANDLE();need(win.CryptCATAdminAcquireContext2(ctypes.byref(admin),None,'SHA256',None,0),'OS_CATALOG_ADMIN_SHA256')
            try:
                k.SetFilePointerEx.argtypes=[w.HANDLE,ctypes.c_longlong,ctypes.POINTER(ctypes.c_longlong),w.DWORD]
                need(k.SetFilePointerEx(handle,0,None,0),'OS_MEMBER_HASH_REWIND')
                size=w.DWORD();ctypes.set_last_error(0)
                size_ok=bool(win.CryptCATAdminCalcHashFromFileHandle2(admin,handle,ctypes.byref(size),None,0));size_error=ctypes.get_last_error()
                result['catalog_hash_size_query']=dict(api_ok=size_ok,error=size_error,bytes=int(size.value))
                need(size.value==32 and (size_ok or size_error==122),'OS_CATALOG_HASH_SIZE')
                hashed=(ctypes.c_ubyte*size.value)();need(k.SetFilePointerEx(handle,0,None,0),'OS_MEMBER_HASH_REWIND');need(win.CryptCATAdminCalcHashFromFileHandle2(admin,handle,ctypes.byref(size),hashed,0),'OS_CATALOG_MEMBER_HASH_QUERY');member_hash=bytes(hashed)
                previous=w.HANDLE();count=0
                while True:
                    cat=win.CryptCATAdminEnumCatalogFromHash(admin,hashed,size,0,ctypes.byref(previous) if previous.value else None)
                    previous=w.HANDLE(cat) # Official SDK/sample: own only the returned live context.
                    if not cat:
                        result['catalog_enumeration_end_error']=ctypes.get_last_error();break
                    count+=1;need(count<=8,'OS_CATALOG_CANDIDATE_BOUND')
                    ci=t['CatalogInfo']();ci.size=ctypes.sizeof(ci);need(win.CryptCATCatalogInfoFromContext(cat,ctypes.byref(ci),0),'OS_CATALOG_INFO')
                    cp=Path(ci.path);need(cp.suffix.lower()=='.cat' and norm(str(cp)).startswith(norm(system['path'])+'/catroot/'),'OS_CATALOG_RETURNED_PATH')
                    ch=k.CreateFileW(str(cp),0x80000000,1,None,3,0x00200000,None);need(ch!=ctypes.c_void_p(-1).value,'OS_CATALOG_READONLY_HOLD')
                    try:
                        cf=readonly_fact(cp);sig=verify_target(path,handle,t,win,crypt,cp,admin,member_hash)
                        result['catalogs'].append(dict(file=cf,catalog_identity_stable=cf==readonly_fact(cp),member_identity_stable=before==readonly_fact(path),member_identity={key:before[key] for key in ['sha256','file_id','volume','bytes']},hash_algorithm='SHA256',member_hash=member_hash.hex(),member_tag=member_hash.hex().upper(),calculated_hash_matches_query=True,wintrust_member_hash=member_hash.hex(),wintrust_member_tag=member_hash.hex().upper(),signature=sig))
                    finally:k.CloseHandle(ch)
                    try:evaluate_signature(sig);break
                    except Exception:continue
            finally:
                if previous.value:win.CryptCATAdminReleaseCatalogContext(admin,previous,0)
                win.CryptCATAdminReleaseContext(admin,0)
        result['identity_stable']=before==readonly_fact(path)
        try:result['qualification']=evaluate_file(result)
        except Exception as exc:result['qualification']=dict(state='OS_SIGNATURE_NOT_QUALIFIED',reason=str(exc))
        result['evidence_sha256']=digest(canonical({k:v for k,v in result.items() if k!='evidence_sha256'}))
        return result
    except Exception as exc:
        result['capture_error']=type(exc).__name__+': '+str(exc)
        result['qualification']=dict(state='OS_SIGNATURE_NOT_QUALIFIED',reason=result['capture_error'])
        return result
    finally:k.CloseHandle(handle)
