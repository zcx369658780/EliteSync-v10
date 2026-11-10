// Owned temporary-filesystem regressions; never run guest Main, Job, Java or Gradle.
using System;
using System.Collections.Generic;
using System.IO;
using System.Diagnostics;
class DiskScanTests {
    class WrongMissingCode:FileNotFoundException {public WrongMissingCode(){HResult=unchecked((int)0x80070020);}}
    static int checks;
    static void Check(bool value,string name){if(!value)throw new Exception(name);checks++;}
    static int Main(string[] args){try{return Run(args);}catch(Exception e){Console.WriteLine("SCAN_TEST_FAILURE: "+e.GetType().FullName+" / "+e.Message);return 1;}}
    static int Run(string[] args){
        if(args.Length!=1||!Path.IsPathRooted(args[0])||Directory.Exists(args[0]))throw new Exception("fresh owned fixture path required");
        string root=args[0];Directory.CreateDirectory(root);
        string file=Path.Combine(root,"cached.txt");File.WriteAllText(file,"12345");
        int retries=0;
        long size=GradleDiagnostic.MeasureTree(root,path=>new DirectoryInfo(path).GetFileSystemInfos(),(a,e)=>retries++);
        Check(size==5&&retries==0,"stable measurement");
        bool removed=false;
        size=GradleDiagnostic.MeasureTree(root,path=>{
            var entries=new DirectoryInfo(path).GetFileSystemInfos();
            if(!removed){File.Delete(file);removed=true;}
            return entries;
        },(a,e)=>retries++);
        Check(size==5&&removed&&retries==0,"cached metadata survives disappearance after enumeration");
        Check(!File.Exists(file),"test actually removed the enumerated file");
        File.WriteAllText(file,"12345");int calls=0;retries=0;
        size=GradleDiagnostic.MeasureTree(root,path=>{if(++calls==1)throw new DirectoryNotFoundException();return new DirectoryInfo(path).GetFileSystemInfos();},(a,e)=>retries++);
        Check(size==5&&calls==2&&retries==1,"one missing-path race gets bounded complete rescan");
        calls=0;retries=0;
        try {GradleDiagnostic.MeasureTree(root,path=>{calls++;throw new DirectoryNotFoundException();},(a,e)=>retries++);throw new Exception("unstable scan accepted");}
        catch(Exception e){Check(e.Message=="DISK_SNAPSHOT_UNSTABLE"&&calls==3&&retries==2,"persistent instability rejected");}
        calls=0;retries=0;
        try {GradleDiagnostic.MeasureTree(root,path=>{calls++;throw new UnauthorizedAccessException();},(a,e)=>retries++);throw new Exception("access denied accepted");}
        catch(UnauthorizedAccessException){Check(calls==1&&retries==0,"access denial never retried away");}
        calls=0;retries=0;
        try {GradleDiagnostic.MeasureTree(root,path=>{calls++;throw new IOException("other IO failure");},(a,e)=>retries++);throw new Exception("unknown IO accepted");}
        catch(IOException){Check(calls==1&&retries==0,"unknown IO never retried away");}
        string child=Path.Combine(root,"child");Directory.CreateDirectory(child);File.WriteAllText(Path.Combine(child,"nested.txt"),"1234567");
        size=GradleDiagnostic.MeasureTree(root,path=>new DirectoryInfo(path).GetFileSystemInfos(),(a,e)=>retries++);
        Check(size==12,"nested directories counted");
        calls=0;retries=0;
        size=GradleDiagnostic.MeasureTree(root,path=>{if(++calls==1)throw new FileNotFoundException();return new DirectoryInfo(path).GetFileSystemInfos();},(a,e)=>retries++);
        Check(size==12&&calls==3&&retries==1,"error2 disappearance gets complete rescan");
        calls=0;retries=0;
        try{GradleDiagnostic.MeasureTree(root,path=>{calls++;throw new WrongMissingCode();},(a,e)=>retries++);throw new Exception("wrong missing HRESULT accepted");}
        catch(WrongMissingCode){Check(calls==1&&retries==0,"non2/3 missing-shaped failure is never retried away");}
        string target=Path.Combine(root,"target"),link=Path.Combine(root,"redirect");Directory.CreateDirectory(target);
        var start=new ProcessStartInfo(Path.Combine(Environment.SystemDirectory,"cmd.exe"),"/d /c mklink /J \""+link+"\" \""+target+"\""){UseShellExecute=false,CreateNoWindow=true,RedirectStandardOutput=true,RedirectStandardError=true,WorkingDirectory=root};
        using(var process=Process.Start(start)){process.StandardOutput.ReadToEnd();process.StandardError.ReadToEnd();if(!process.WaitForExit(10000)||process.ExitCode!=0)throw new Exception("owned junction fixture unavailable");}
        try{GradleDiagnostic.MeasureTree(root,path=>new DirectoryInfo(path).GetFileSystemInfos(),(a,e)=>{});throw new Exception("reparse accepted");}
        catch(Exception e){Check(e.Message=="REDIRECTED_DISK_ENTRY","real owned junction rejected");}
        try {GradleDiagnostic.MeasureTree(Path.Combine(root,"absent"),path=>new FileSystemInfo[0],(a,e)=>{});throw new Exception("missing root accepted");}
        catch(FileNotFoundException){checks++;}catch(DirectoryNotFoundException){checks++;}
        Console.WriteLine(checks+" filesystem scan regression assertions passed; owned fixture retained.");return 0;
    }
}
