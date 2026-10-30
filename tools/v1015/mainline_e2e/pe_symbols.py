"""Bounded ordinary import symbols and export/forwarder tables. Pure bytes."""
import struct,re
from contracts import need


def inspect_symbols(data):
    def read(fmt,offset):
        need(0<=offset<=len(data)-struct.calcsize(fmt),'PE_SYMBOL_BOUNDS')
        return struct.unpack_from(fmt,data,offset)
    need(data[:2]==b'MZ','PE_SYMBOL_DOS')
    pe=read('<I',0x3c)[0];need(data[pe:pe+4]==b'PE\0\0','PE_SYMBOL_SIGNATURE')
    machine,count=read('<HH',pe+4);need(machine==0x8664 and 0<count<97,'PE_SYMBOL_ARCH')
    opt=pe+24;size=read('<H',pe+20)[0];need(size>=240 and read('<H',opt)[0]==0x20b,'PE_SYMBOL_OPTIONAL')
    headers=read('<I',opt+60)[0];image_size=read('<I',opt+56)[0];table=opt+size;sections=[];mapped=[]
    for i in range(count):
        virtual,rva,length,offset=read('<IIII',table+40*i+8)
        need(offset+length<=len(data),'PE_SYMBOL_SECTION');sections.append((rva,offset,length));mapped.append((rva,max(virtual,length)))
    def offset(rva,n=1):
        if rva<headers:need(rva+n<=min(headers,len(data)),'PE_SYMBOL_HEADER_RVA');return rva
        for start,base,length in sections:
            delta=rva-start
            if 0<=delta and delta+n<=length:return base+delta
        need(False,'PE_SYMBOL_RVA')
    def text(rva):
        start=offset(rva);end=data.find(b'\0',start,min(len(data),start+4096));need(end>start,'PE_SYMBOL_STRING')
        value=data[start:end].decode('ascii');need(all(32<x<127 for x in data[start:end]),'PE_SYMBOL_STRING_ASCII');return value
    imports={};irva,ilen=read('<II',opt+120)
    if irva or ilen:
        need(irva and 20<=ilen<=1048576,'PE_SYMBOL_IMPORT_DIRECTORY');ended=False
        for i in range(min(ilen//20,4096)):
            row=read('<5I',offset(irva+20*i,20))
            if not any(row):ended=True;break
            library=text(row[3]).lower();need(re.fullmatch(r'[a-z0-9_.-]+[.]dll',library) is not None,'PE_SYMBOL_IMPORT_NAME')
            thunk=row[0] or row[4];symbols=[];finished=False
            for j in range(65536):
                item=read('<Q',offset(thunk+8*j,8))[0]
                if item==0:finished=True;break
                if item>>63:symbols.append('#'+str(item&65535))
                else:need(item<0x100000000,'PE_SYMBOL_THUNK_RVA');symbols.append(text(item+2))
            need(finished and library not in imports,'PE_SYMBOL_IMPORT_TERMINATOR_OR_DUPLICATE');imports[library]=symbols
        need(ended,'PE_SYMBOL_DESCRIPTOR_TERMINATOR')
    exports={};er,es=read('<II',opt+112)
    if er or es:
        need(er and es>=40,'PE_SYMBOL_EXPORT_DIRECTORY')
        row=read('<IIHH7I',offset(er,40));base,nfunc,nnames,functions,names,ordinals=row[5:]
        need(0<nfunc<=100000 and nnames<=nfunc,'PE_SYMBOL_EXPORT_COUNT')
        entries={}
        for i in range(nfunc):
            rva=read('<I',offset(functions+4*i,4))[0]
            if rva:
                valid=0<rva<image_size and (rva<min(headers,len(data)) or any(start<=rva<start+length for start,length in mapped))
                entries[i]=dict(ordinal=base+i,forwarder=text(rva) if er<=rva<er+es else None,rva=rva,rva_valid=valid)
        for i,item in entries.items():exports['#'+str(base+i)]=item
        for i in range(nnames):
            name=text(read('<I',offset(names+4*i,4))[0]);index=read('<H',offset(ordinals+2*i,2))[0]
            need(index<nfunc and name not in exports,'PE_SYMBOL_EXPORT_INDEX')
            if index in entries:exports[name]=entries[index]
    return dict(imports=imports,exports=exports)


def split_forwarder(value):
    module,sep,symbol=value.rpartition('.')
    need(sep and re.fullmatch(r'[A-Za-z0-9_.-]+',module) and '..' not in module and symbol,'PE_FORWARDER_NAME')
    if symbol.startswith('#'):need(symbol[1:].isdigit(),'PE_FORWARDER_ORDINAL')
    return module.lower() if module.lower().endswith('.dll') else module.lower()+'.dll',symbol
