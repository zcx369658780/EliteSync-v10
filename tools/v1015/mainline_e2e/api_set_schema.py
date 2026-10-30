"""Bounded, version-checked API-set data parser; pure bytes only.

API-set names are contracts, not DLL filenames. Unknown layouts, empty hosts,
ambiguous/default/alias mappings fail closed. This parser is not loader proof;
actual child images must independently match qualified source pins.
"""
import re,struct,ntpath
from contracts import need


def parse_schema(pe):
    def unpack(fmt,offset):
        need(0<=offset<=len(pe)-struct.calcsize(fmt),'API_SCHEMA_PE_BOUNDS')
        return struct.unpack_from(fmt,pe,offset)
    need(pe[:2]==b'MZ','API_SCHEMA_PE')
    pos=unpack('<I',0x3c)[0];need(pe[pos:pos+4]==b'PE\0\0','API_SCHEMA_PE')
    machine,count=unpack('<HH',pos+4);need(machine==0x8664 and 0<count<97,'API_SCHEMA_PE_ARCH')
    table=pos+24+unpack('<H',pos+20)[0];sections=[]
    for i in range(count):
        entry=table+40*i
        if pe[entry:entry+8].rstrip(b'\0')==b'.apiset':
            length,offset=unpack('<II',entry+16);need(offset+length<=len(pe),'API_SCHEMA_SECTION_BOUNDS');sections.append(pe[offset:offset+length])
    need(len(sections)==1,'API_SCHEMA_SECTION_REQUIRED')
    raw=sections[0]
    def read(fmt,offset):
        need(0<=offset<=len(raw)-struct.calcsize(fmt),'API_SCHEMA_BOUNDS')
        return struct.unpack_from(fmt,raw,offset)
    version,size,flags,count,entries,hash_offset,factor=read('<7I',0)
    need(version==6 and 28<=size<=len(raw) and 0<count<=10000 and entries+24*count<=size,'API_SCHEMA_VERSION_OR_BOUNDS')
    raw=raw[:size]
    def text(offset,length):
        need(length%2==0 and 0<=offset<=len(raw)-length and length<=1024,'API_SCHEMA_TEXT_BOUNDS')
        return raw[offset:offset+length].decode('utf-16-le').lower()
    result={}
    for i in range(count):
        f,no,nl,hashed,vo,vc=read('<6I',entries+24*i)
        name=text(no,nl);need(bool(name) and '\0' not in name and name not in result,'API_SCHEMA_NAME')
        need(0<vc<=32 and vo+20*vc<=size,'API_SCHEMA_VALUES')
        values=[]
        for j in range(vc):
            vf,alias_offset,alias_length,host_offset,host_length=read('<5I',vo+20*j)
            alias=text(alias_offset,alias_length);host=text(host_offset,host_length)
            # Do not reject unrelated schema entries (e.g. kernel-mode hosts).
            # No host is trusted/used until the exact ordinary contract is selected.
            need('\0' not in alias and '\0' not in host,'API_SCHEMA_TEXT_NUL')
            values.append(dict(alias=alias,host=host))
        result[name]=values
    return result


def resolve(schema,contract,importer):
    key=contract.lower().removesuffix('.dll');name=ntpath.basename(importer.lower()).removesuffix('.dll')
    values=schema.get(key);need(isinstance(values,list),'API_SCHEMA_CONTRACT_MISSING:'+key)
    aliases=[x['host'] for x in values if x['alias'].removesuffix('.dll')==name]
    hosts=aliases or [x['host'] for x in values if not x['alias']]
    need(len(set(hosts))==1 and hosts[0],'API_SCHEMA_HOST_UNRESOLVED:'+key)
    need(re.fullmatch(r'[a-z0-9_.-]+[.]dll',hosts[0]) is not None and '..' not in hosts[0],'API_SCHEMA_HOST_PATH')
    return hosts[0]


def archive_then_parse(pe,evidence,persist):
    """Mandatory raw persistence BEFORE parsing. persist must durably reserve/write.

    No system read is performed here. A parser error never destroys its exact
    input. The blob is data-only LOCAL_ONLY, never part of a runtime directory.
    """
    from contracts import digest
    need(isinstance(pe,bytes) and digest(pe)==evidence.get('file',{}).get('sha256'),'API_SCHEMA_BYTE_BINDING')
    persist(pe)
    from windows_os_trust import evaluate_file
    evaluate_file(evidence)
    return parse_schema(pe)
