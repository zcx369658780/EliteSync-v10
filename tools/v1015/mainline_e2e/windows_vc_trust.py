"""Windows Authenticode/chain policy evidence. No observation on import.

No display name, issuer, thumbprint, serial or signature-algorithm allowlist.
Cache-only revocation is REQUIRED; unavailable cache is a closed gate, not PASS.
Certificate originals returned by capture() are LOCAL_ONLY.
"""
import base64
import ctypes
import hashlib
import os
from pathlib import Path
from contracts import need, digest, canonical
from os_images import system_root_fact, readonly_fact, norm, _api
from pe_dependencies import pe_info

CODE_SIGNING = '1.3.6.1.5.5.7.3.3'
CHAIN_FLAGS = 0xC0000104  # revocation chain-exclude-root, cache-only + no root auto-update
WVT_FLAGS = 0x1080  # cache-only URL retrieval + revocation chain-exclude-root
CENTRAL_NAME = 'vcruntime140.dll'
# Microsoft SDK wincrypt.h: application-signing root only; no test roots or ignore flags.
MICROSOFT_APPLICATION_ROOT = 0x00020000


def evaluate_trust(value):
    need(value.get('schema') == 1 and value.get('identity_stable') is True,
         'CENTRAL_TRUST_FILE_BINDING')
    wvt=value.get('winverifytrust', {}); chain=value.get('chain', {})
    need(wvt.get('provider_flags') == WVT_FLAGS and chain.get('flags') == CHAIN_FLAGS,
         'CENTRAL_REVOCATION_POLICY_CHANGED')
    need(wvt.get('status') == 0, 'CENTRAL_AUTHENTICODE_TRUST_FAILED')
    need(chain.get('api_ok') is True and chain.get('error_status') == 0,
         'CENTRAL_CHAIN_ERROR_OR_REVOCATION_UNKNOWN')
    need(CODE_SIGNING in value.get('leaf_eku', []) and value.get('leaf_eku_api_ok') is True,
         'CENTRAL_CODE_SIGNING_EKU_REQUIRED')
    for key, oid, flags in [('authenticode', 2, 0), ('microsoft_root', 7, MICROSOFT_APPLICATION_ROOT)]:
        policy=value.get('policies', {}).get(key, {})
        need(policy.get('api_ok') is True and policy.get('error') == 0
             and policy.get('flags') == flags and policy.get('policy_oid') == oid, 'CENTRAL_CHAIN_POLICY_' + key.upper())
    need(chain.get('certificate_count', 0) >= 2 and value.get('online_retrieval') is False,
         'CENTRAL_CHAIN_EVIDENCE_INCOMPLETE')
    return dict(state='CENTRAL_VC_EVIDENCE_QUALIFIED', revocation='CACHE_VALIDATED_NO_ONLINE_QUERY',
                publisher_basis='WINDOWS_MICROSOFT_ROOT_AND_AUTHENTICODE_POLICY',
                php_abi='NOT_PROVEN_UNTIL_CONTROLLED_LOAD')


def file_version(path):
    from ctypes import wintypes as w
    v=ctypes.WinDLL('version.dll', winmode=0x800, use_last_error=True)
    v.GetFileVersionInfoSizeW.argtypes=[w.LPCWSTR,ctypes.POINTER(w.DWORD)];v.GetFileVersionInfoSizeW.restype=w.DWORD
    ignored=w.DWORD();size=v.GetFileVersionInfoSizeW(str(path),ctypes.byref(ignored));need(size>0,'VC_VERSION_SIZE')
    buf=ctypes.create_string_buffer(size);v.GetFileVersionInfoW.argtypes=[w.LPCWSTR,w.DWORD,w.DWORD,ctypes.c_void_p]
    need(v.GetFileVersionInfoW(str(path),0,size,buf),'VC_VERSION_READ')
    ptr=ctypes.c_void_p();length=w.UINT();v.VerQueryValueW.argtypes=[ctypes.c_void_p,w.LPCWSTR,ctypes.POINTER(ctypes.c_void_p),ctypes.POINTER(w.UINT)]
    need(v.VerQueryValueW(buf,'\\',ctypes.byref(ptr),ctypes.byref(length)) and length.value>=52,'VC_VERSION_QUERY')
    data=ctypes.cast(ptr,ctypes.POINTER(w.DWORD*13)).contents;need(data[0]==0xfeef04bd,'VC_VERSION_SIGNATURE')
    return '.'.join(str(x) for x in (data[2]>>16,data[2]&65535,data[3]>>16,data[3]&65535))


def signature_chain(path, handle):
    """One supported API path; no online retrieval, fallback, or ignored policy errors."""
    from ctypes import wintypes as w
    class GUID(ctypes.Structure):_fields_=[('a',w.DWORD),('b',w.WORD),('c',w.WORD),('d',ctypes.c_ubyte*8)]
    class File(ctypes.Structure):_fields_=[('size',w.DWORD),('path',w.LPCWSTR),('handle',w.HANDLE),('subject',ctypes.c_void_p)]
    class Trust(ctypes.Structure):_fields_=[('size',w.DWORD),('callback',ctypes.c_void_p),('sip',ctypes.c_void_p),('ui',w.DWORD),('revoke',w.DWORD),('choice',w.DWORD),('file',ctypes.POINTER(File)),('action',w.DWORD),('state',w.HANDLE),('url',w.LPWSTR),('flags',w.DWORD),('context',w.DWORD),('settings',ctypes.c_void_p)]
    class CertContext(ctypes.Structure):_fields_=[('encoding',w.DWORD),('encoded',ctypes.POINTER(ctypes.c_ubyte)),('length',w.DWORD),('info',ctypes.c_void_p),('store',w.HANDLE)]
    class ProviderCert(ctypes.Structure):_fields_=[('size',w.DWORD),('cert',ctypes.POINTER(CertContext))]
    class Signer(ctypes.Structure):_fields_=[('size',w.DWORD),('time',w.FILETIME),('count',w.DWORD),('certs',ctypes.POINTER(ProviderCert))]
    class Usage(ctypes.Structure):_fields_=[('count',w.DWORD),('oids',ctypes.POINTER(ctypes.c_char_p))]
    class Match(ctypes.Structure):_fields_=[('type',w.DWORD),('usage',Usage)]
    class ChainPara(ctypes.Structure):_fields_=[('size',w.DWORD),('requested',Match),('issuance',Match),('timeout',w.DWORD),('checkfresh',w.BOOL),('freshness',w.DWORD),('resync',ctypes.c_void_p),('strong',ctypes.c_void_p),('strongflags',w.DWORD)]
    class Status(ctypes.Structure):_fields_=[('error',w.DWORD),('info',w.DWORD)]
    class Element(ctypes.Structure):_fields_=[('size',w.DWORD),('cert',ctypes.POINTER(CertContext)),('trust',Status),('revocation',ctypes.c_void_p),('issuance',ctypes.c_void_p),('application',ctypes.c_void_p),('extended',w.LPCWSTR)]
    class Simple(ctypes.Structure):_fields_=[('size',w.DWORD),('trust',Status),('count',w.DWORD),('elements',ctypes.POINTER(ctypes.POINTER(Element))),('list',ctypes.c_void_p),('hasfresh',w.BOOL),('freshness',w.DWORD)]
    class Chain(ctypes.Structure):_fields_=[('size',w.DWORD),('trust',Status),('count',w.DWORD),('chains',ctypes.POINTER(ctypes.POINTER(Simple))),('lowcount',w.DWORD),('low',ctypes.c_void_p),('hasfresh',w.BOOL),('freshness',w.DWORD)]
    class PolicyPara(ctypes.Structure):_fields_=[('size',w.DWORD),('flags',w.DWORD),('extra',ctypes.c_void_p)]
    class PolicyStatus(ctypes.Structure):_fields_=[('size',w.DWORD),('error',w.DWORD),('chain',ctypes.c_long),('element',ctypes.c_long),('extra',ctypes.c_void_p)]
    win=ctypes.WinDLL('wintrust.dll',winmode=0x800,use_last_error=True);crypt=ctypes.WinDLL('crypt32.dll',winmode=0x800,use_last_error=True)
    win.WinVerifyTrust.argtypes=[w.HWND,ctypes.POINTER(GUID),ctypes.POINTER(Trust)];win.WinVerifyTrust.restype=ctypes.c_int32
    win.WTHelperProvDataFromStateData.argtypes=[w.HANDLE];win.WTHelperProvDataFromStateData.restype=ctypes.c_void_p
    win.WTHelperGetProvSignerFromChain.argtypes=[ctypes.c_void_p,w.DWORD,w.BOOL,w.DWORD];win.WTHelperGetProvSignerFromChain.restype=ctypes.POINTER(Signer)
    crypt.CertGetEnhancedKeyUsage.argtypes=[ctypes.POINTER(CertContext),w.DWORD,ctypes.c_void_p,ctypes.POINTER(w.DWORD)]
    crypt.CertGetCertificateChain.argtypes=[w.HANDLE,ctypes.POINTER(CertContext),ctypes.POINTER(w.FILETIME),w.HANDLE,ctypes.POINTER(ChainPara),w.DWORD,ctypes.c_void_p,ctypes.POINTER(ctypes.POINTER(Chain))]
    crypt.CertVerifyCertificateChainPolicy.argtypes=[ctypes.c_void_p,ctypes.POINTER(Chain),ctypes.POINTER(PolicyPara),ctypes.POINTER(PolicyStatus)]
    crypt.CertFreeCertificateChain.argtypes=[ctypes.POINTER(Chain)]
    g=GUID(0xaac56b,0xcd44,0x11d0,(ctypes.c_ubyte*8)(0x8c,0xc2,0,0xc0,0x4f,0xc2,0x95,0xee));f=File(ctypes.sizeof(File),str(path),handle,None)
    t=Trust();t.size=ctypes.sizeof(t);t.ui=2;t.revoke=1;t.choice=1;t.file=ctypes.pointer(f);t.action=1;t.flags=WVT_FLAGS
    result=dict(schema=1,online_retrieval=False,winverifytrust=dict(provider_flags=WVT_FLAGS),chain=dict(flags=CHAIN_FLAGS,api_ok=False),policies={},leaf_eku=[],leaf_eku_api_ok=False,certificates=[])
    chain=ctypes.POINTER(Chain)()
    try:
        code=win.WinVerifyTrust(ctypes.c_void_p(-1),ctypes.byref(g),ctypes.byref(t));result['winverifytrust']['status']=code&0xffffffff
        provider=win.WTHelperProvDataFromStateData(t.state);need(provider,'VC_TRUST_PROVIDER_DATA_MISSING')
        signer=win.WTHelperGetProvSignerFromChain(provider,0,False,0);need(signer and 0<signer.contents.count<=32,'VC_SIGNER_CHAIN_MISSING')
        leaf=signer.contents.certs[0].cert;need(bool(leaf),'VC_SIGNER_CERT_MISSING')
        n=w.DWORD();eku_ok=bool(crypt.CertGetEnhancedKeyUsage(leaf,0,None,ctypes.byref(n)))
        if eku_ok and 0<n.value<=65536:
            buf=ctypes.create_string_buffer(n.value);eku_ok=bool(crypt.CertGetEnhancedKeyUsage(leaf,0,buf,ctypes.byref(n)))
            if eku_ok:
                usage=ctypes.cast(buf,ctypes.POINTER(Usage)).contents;need(usage.count<=64,'VC_EKU_COUNT');result['leaf_eku']=[usage.oids[i].decode('ascii') for i in range(usage.count)]
        result['leaf_eku_api_ok']=eku_ok
        oids=(ctypes.c_char_p*1)(CODE_SIGNING.encode());params=ChainPara();params.size=ctypes.sizeof(params);params.requested=Match(0,Usage(1,oids))
        ok=bool(crypt.CertGetCertificateChain(None,leaf,None,leaf.contents.store,ctypes.byref(params),CHAIN_FLAGS,None,ctypes.byref(chain)))
        result['chain']['api_ok']=ok
        if ok:
            need(chain and 0<chain.contents.count<=8,'VC_CHAIN_CONTEXT_BOUNDS');cc=chain.contents;result['chain'].update(error_status=int(cc.trust.error),info_status=int(cc.trust.info),simple_chain_count=int(cc.count),has_revocation_freshness=bool(cc.hasfresh),revocation_freshness_seconds=int(cc.freshness))
            for j in range(cc.count):
                simple=cc.chains[j].contents;need(0<simple.count<=32,'VC_CERTIFICATE_CHAIN_BOUNDS')
                for i in range(simple.count):
                    el=simple.elements[i].contents;c=el.cert.contents;need(0<c.length<=1048576,'VC_CERTIFICATE_SIZE');der=ctypes.string_at(c.encoded,c.length)
                    result['certificates'].append(dict(simple_chain=j,element=i,sha256=hashlib.sha256(der).hexdigest(),der_base64=base64.b64encode(der).decode(),trust_error=int(el.trust.error),trust_info=int(el.trust.info),revocation_info_present=bool(el.revocation)))
            result['chain']['certificate_count']=len(result['certificates'])
            for name,oid,flags in [('authenticode',2,0),('microsoft_root',7,MICROSOFT_APPLICATION_ROOT),('microsoft_product_root',7,0)]:
                pp=PolicyPara(ctypes.sizeof(PolicyPara),flags,None);ps=PolicyStatus();ps.size=ctypes.sizeof(ps)
                policy_ok=bool(crypt.CertVerifyCertificateChainPolicy(ctypes.c_void_p(oid),chain,ctypes.byref(pp),ctypes.byref(ps)))
                result['policies'][name]=dict(api_ok=policy_ok,error=int(ps.error),chain_index=int(ps.chain),element_index=int(ps.element),flags=flags,policy_oid=oid)
    except BaseException as e:
        result['capture_error']=type(e).__name__+': '+str(e)
    finally:
        if chain:crypt.CertFreeCertificateChain(chain)
        t.action=2;win.WinVerifyTrust(ctypes.c_void_p(-1),ctypes.byref(g),ctypes.byref(t))
    return result


def capture(expected):
    """Single complete named observation. Caller reserves/flushes budget FIRST."""
    need(os.name=='nt','WINDOWS_REQUIRED');system=system_root_fact();path=Path(system['path'])/CENTRAL_NAME
    k,_,_= _api();hold=k.CreateFileW(str(path),0x80000000,1,None,3,0x00200000,None)
    need(hold!=ctypes.c_void_p(-1).value,'VC_READONLY_HOLD')
    try:
        before=readonly_fact(path)
        need(before['links']==1 and not before['reparse'] and before['volume']==system['volume'],'VC_FILE_ALIAS_OR_LINK')
        for key in ('sha256','file_id','volume','bytes'):need(before[key]==expected[key],'VC_FIXED_FILE_CHANGED_'+key)
        data=path.read_bytes();need(digest(data)==before['sha256'],'VC_HANDLE_PATH_HASH_MISMATCH')
        pe=pe_info(data);version=file_version(path);need(version==expected['file_version'],'VC_FIXED_VERSION_CHANGED')
        trust=signature_chain(path,hold);after=readonly_fact(path);trust['identity_stable']=before==after
        result=dict(schema=1,source_class='MICROSOFT_CENTRAL_V14_RUNTIME',module=CENTRAL_NAME,system_root=system,file=dict(before,architecture=pe['machine'],file_version=version),imports=pe['imports'],trust=trust)
        try:result['qualification']=evaluate_trust(trust)
        except Exception as e:result['qualification']=dict(state='CENTRAL_VC_NOT_QUALIFIED',reason=str(e))
        result['trust_evidence_sha256']=digest(canonical(trust));return result
    finally:k.CloseHandle(hold)
