// Pure buffer/policy tests; never invoke guest Main or native APIs.
using System;
using System.IO;
using System.Net;

class DiagnosticBufferTests
{
    static int checks;
    static void Check(bool value,string label) {if(!value)throw new Exception(label);checks++;}
    static void Invalid(Action action) {try{action();}catch(InvalidDataException){checks++;return;}throw new Exception("Malformed table accepted");}
    static byte[] Table(int family,bool tcp) {
        int size=tcp?(family==2?24:56):(family==2?12:28);var bytes=new byte[4+size];
        Array.Copy(BitConverter.GetBytes((uint)1),bytes,4);
        int address=4+(tcp&&family==2?4:0), port=4+(family==2?(tcp?8:4):20);
        byte[] ip=(family==2?IPAddress.Loopback:IPAddress.IPv6Loopback).GetAddressBytes();Array.Copy(ip,0,bytes,address,ip.Length);
        bytes[port]=0x30;bytes[port+1]=0x39; // 12345, network byte order.
        Array.Copy(BitConverter.GetBytes((uint)321),0,bytes,4+size-4,4);
        if(tcp)Array.Copy(BitConverter.GetBytes((uint)2),0,bytes,4+(family==2?0:48),4);
        return bytes;
    }
    static int Main() {try{return Run();}catch(Exception e){Console.WriteLine("PURE_TEST_FAILURE: "+e.GetType().FullName+" / "+e.Message);return 1;}}
    static int Run() {
        foreach(int family in new int[]{2,23})foreach(bool tcp in new bool[]{true,false}) {
            var rows=GradleDiagnostic.Parse(Table(family,tcp),family,tcp);Check(rows.Count==1,"row count");
            var row=rows[0];Check(row.pid==321 && row.family==family,"owner/family");
            Check(row.local_port==12345,"network port order");
            Check(IPAddress.IsLoopback(IPAddress.Parse(row.local)),"address decoding");
            Check(row.protocol==(tcp?"TCP":"UDP"),"protocol");
            Check(!GradleDiagnostic.UnsafeTcp(row),"loopback positive");
        }
        Invalid(()=>GradleDiagnostic.Parse(new byte[3],2,true));
        Invalid(()=>GradleDiagnostic.Parse(Table(2,true),99,true));
        var truncated=new byte[4];Array.Copy(BitConverter.GetBytes((uint)1),truncated,4);
        Invalid(()=>GradleDiagnostic.Parse(truncated,23,true));
        Array.Copy(BitConverter.GetBytes((uint)65537),truncated,4);
        Invalid(()=>GradleDiagnostic.Parse(truncated,2,false));
        foreach(string address in new string[]{"0.0.0.0","::"}) {
            var row=new Endpoint {protocol="TCP",state=2,local=address,remote="0.0.0.0"};
            Check(GradleDiagnostic.UnsafeTcp(row),"wildcard listener must stop");
        }
        var active=new Endpoint {protocol="TCP",state=5,local="127.0.0.1",remote="192.0.2.1"};
        Check(GradleDiagnostic.UnsafeTcp(active),"nonloopback remote must stop");
        active.remote="127.0.0.1";Check(!GradleDiagnostic.UnsafeTcp(active),"loopback remote allowed");
        active.remote="0.0.0.0";Check(GradleDiagnostic.UnsafeTcp(active),"unknown active remote rejected");
        GradleDiagnostic.RequireKnownExit(true);checks++;
        try{GradleDiagnostic.RequireKnownExit(false);throw new InvalidDataException("unbound exit accepted");}catch(Exception e){Check(e.Message=="EXIT_BEFORE_IDENTITY_BOUND","unbound exit refused");}
        Check(GradleDiagnostic.CheckLogChunk("Download","ing htt")=="Downloading htt","split log prefix retained");
        try{GradleDiagnostic.CheckLogChunk("Downloading htt","ps://example.invalid/x");throw new InvalidDataException("download accepted");}catch(Exception e){Check(e.Message=="DOWNLOAD_LOG_SIGNAL","split download detected");}
        Check(GradleDiagnostic.CheckLogChunk("first"," line\nrest")=="rest","complete lines consumed");
        try{GradleDiagnostic.CheckLogChunk("",new string('x',8193));throw new InvalidDataException("long line accepted");}catch(Exception e){Check(e.Message=="DIAGNOSTIC_LINE_LIMIT","oversized diagnostic rejected");}
        foreach(string bad in new[]{@"C:\BuildWork\..\Outside",@"C:\Other\x",@"C:\BuildWork\x:stream"}){
            try{GradleDiagnostic.CheckOwnedPath(bad);throw new InvalidDataException("outside path accepted");}catch(Exception e){Check(e.Message=="OWNED_PATH_ESCAPE","pre-write private path rejection");}
        }
        Console.WriteLine(checks+" binary table and endpoint policy assertions passed; no native APIs invoked.");return 0;
    }
}
