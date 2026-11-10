// Pure buffer/policy tests; never invoke guest Main or native APIs.
using System;
using System.IO;
using System.Net;
using System.Text;
using System.ComponentModel;

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
        foreach(string signal in new[]{"Downloading https://example.invalid/x","Download http://example.invalid/x"," \tDoWnLoAdInG\r\t HtTpS://example.invalid/x"}) {
            for(int split=0;split<=signal.Length;split++) {
                var scanner=new GradleDiagnostic.DownloadLogScanner();
                try{scanner.Feed(signal.Substring(0,split));scanner.Feed(signal.Substring(split));throw new InvalidDataException("split download accepted");}
                catch(Exception e){Check(e.Message=="DOWNLOAD_LOG_SIGNAL","download detected at every split");}
            }
        }
        var benign=new GradleDiagnostic.DownloadLogScanner();
        benign.Feed("Tasks to be executed: ["+new string('x',33528)+"]");
        Check(benign.BufferedCharacters==0,"long task graph does not accumulate line memory");
        benign.Feed("Downloading https://example.invalid/not-an-anchored-prefix");
        Check(benign.BufferedCharacters==0,"unanchored text retains original anchored semantics");
        benign.Feed("\n"+new string(' ',100000));
        Check(benign.BufferedCharacters==0,"long leading whitespace uses bounded state");
        try{benign.Feed("Downloading https://example.invalid/x");throw new InvalidDataException("download after long whitespace accepted");}
        catch(Exception e){Check(e.Message=="DOWNLOAD_LOG_SIGNAL","anchored signal after long whitespace still rejected");}
        var reset=new GradleDiagnostic.DownloadLogScanner();reset.Feed("Downloa\nding https://example.invalid/x\nDownloadx http://example.invalid/x\nDownloading file:/local\n");
        Check(reset.BufferedCharacters==0,"newline resets partial words and benign schemes");
        byte[] encoded=Encoding.UTF8.GetBytes("\u2003Downloading https://example.invalid/x");
        var unicode=new GradleDiagnostic.DownloadLogScanner();
        try{foreach(byte value in encoded)unicode.FeedBytes(new[]{value},1,false);throw new InvalidDataException("UTF8 split download accepted");}
        catch(Exception e){Check(e.Message=="DOWNLOAD_LOG_SIGNAL","split UTF8 whitespace preserves detection");}
        var malformed=new GradleDiagnostic.DownloadLogScanner();malformed.FeedBytes(new byte[]{0xe2},1,false);
        try{malformed.FeedBytes(new byte[0],0,true);throw new InvalidDataException("truncated UTF8 accepted");}
        catch(DecoderFallbackException){checks++;}
        foreach(int code in new[]{2,3,5}) {
            int calls=0,retries=0;
            string result=GradleDiagnostic.ReadDirectoryName(()=>{if(++calls<3)throw new Win32Exception(code);return @"C:\BuildWork\live";},(n,e)=>retries++);
            Check(result==@"C:\BuildWork\live"&&calls==3&&retries==2,"exact name query can recover after bounded native error");
            calls=0;retries=0;
            try{GradleDiagnostic.ReadDirectoryName(()=>{calls++;throw new Win32Exception(code);},(n,e)=>retries++);throw new Exception("persistent name error ignored");}
            catch(Win32Exception e){Check(e.NativeErrorCode==code&&calls==3&&retries==2,"persistent native name error fails closed");}
        }
        foreach(int code in new[]{6,50,87}) {
            int calls=0;
            try{GradleDiagnostic.ReadDirectoryName(()=>{calls++;throw new Win32Exception(code);},(n,e)=>{throw new Exception("unknown name error retried");});throw new Exception("unknown name error ignored");}
            catch(Win32Exception e){Check(e.NativeErrorCode==code&&calls==1,"unknown name error fails immediately");}
        }
        foreach(string bad in new[]{@"C:\BuildWork\..\Outside",@"C:\Other\x",@"C:\BuildWork\x:stream"}){
            try{GradleDiagnostic.CheckOwnedPath(bad);throw new InvalidDataException("outside path accepted");}catch(Exception e){Check(e.Message=="OWNED_PATH_ESCAPE","pre-write private path rejection");}
        }
        Console.WriteLine(checks+" binary table and endpoint policy assertions passed; no native APIs invoked.");return 0;
    }
}
