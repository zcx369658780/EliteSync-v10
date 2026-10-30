"""Bounded PE import inspection only. Never loads a DLL or executable."""
import struct
from contracts import Gate, need
def pe_info(data,system_image=False):
    def read(fmt,offset):
        size=struct.calcsize(fmt);need(0<=offset<=len(data)-size,"PE_TRUNCATED")
        return struct.unpack_from(fmt,data,offset)
    need(data[:2]==b"MZ","PE_DOS_HEADER")
    pe=read("<I",0x3c)[0];need(data[pe:pe+4]==b"PE\0\0","PE_SIGNATURE")
    machine,sections=read("<HH",pe+4);need(machine==0x8664 and 0<sections<97,"PE_X64_REQUIRED")
    optional_size=read("<H",pe+20)[0];opt=pe+24
    need(optional_size>=240 and read("<H",opt)[0]==0x20b,"PE32_PLUS_REQUIRED")
    size_headers=read("<I",opt+60)[0];count=read("<I",opt+108)[0]
    table=opt+optional_size;entries=[]
    for i in range(sections):
        p=table+40*i
        virtual_size,rva,raw_size,raw=read("<IIII",p+8)
        need(raw+raw_size<=len(data),"PE_SECTION_BOUNDS")
        entries.append((rva,virtual_size,raw,raw_size))
    def offset(rva,size=1):
        if rva<size_headers:
            need(rva+size<=min(size_headers,len(data)),"PE_RVA_BOUNDS");return rva
        for start,virtual,raw,length in entries:
            delta=rva-start
            if 0<=delta and delta+size<=length:return raw+delta
        raise Gate("PE_RVA_UNMAPPED")
    def name(rva,delay=False):
        p=offset(rva);end=data.find(b"\0",p,min(len(data),p+260))
        need(end>p,"PE_IMPORT_NAME")
        try:value=data[p:end].decode("ascii").lower()
        except UnicodeError:raise Gate("PE_IMPORT_NAME")
        need((value.endswith(".dll") or (system_image and delay and value.endswith(".exe"))) and all(x.isalnum() or x in "._-" for x in value),"PE_IMPORT_PATH_REJECTED")
        return value
    imports=set();ordinary=set();delayed=set()
    for index,stride in ((1,20),(13,32)):
        if count<=index:continue
        rva,size=read("<II",opt+112+8*index)
        if not rva and not size:continue
        need(rva and stride<=size<=1048576,"PE_IMPORT_DIRECTORY")
        ended=False
        for n in range(min(size//stride,4096)):
            p=offset(rva+n*stride,stride);row=read("<"+"I"*(stride//4),p)
            if not any(row):ended=True;break
            if index==1:
                value=name(row[3]);imports.add(value);ordinary.add(value)
            else:
                need(row[0]&1==1,"PE_DELAY_IMPORT_VA_UNSUPPORTED");value=name(row[1],delay=True);imports.add(value);delayed.add(value)
        need(ended,"PE_IMPORT_TERMINATOR")
    return dict(machine="x64",imports=sorted(imports),ordinary_imports=sorted(ordinary),delay_imports=sorted(delayed))
