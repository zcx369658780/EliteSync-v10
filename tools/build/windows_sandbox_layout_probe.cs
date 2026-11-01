// Bootstrap one filesystem-only Java probe inside the guest. No Gradle.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Web.Script.Serialization;
using Microsoft.Win32.SafeHandles;

class LayoutBootstrap
{
    const string Self=@"C:\Probe\LayoutBootstrap.exe", Output=@"C:\ProbeOutput";
    static readonly JavaScriptSerializer Json=new JavaScriptSerializer();
    [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)]
    static extern SafeFileHandle CreateFile(string path,uint access,uint share,IntPtr security,uint creation,uint flags,IntPtr template);
    static string Sha(string path) {using(var f=File.OpenRead(path))using(var sha=SHA256.Create())return BitConverter.ToString(sha.ComputeHash(f)).Replace("-","").ToLowerInvariant();}
    static int Main(string[] args)
    {
        if(Environment.UserName!="WDAGUtilityAccount"||args.Length!=1||!System.Text.RegularExpressions.Regex.IsMatch(args[0],"\\A[0-9a-f]{32}\\z"))return 20;
        if(!String.Equals(Process.GetCurrentProcess().MainModule.FileName,Self,StringComparison.OrdinalIgnoreCase))return 21;
        var manifest=Json.Deserialize<Dictionary<string,object>>(File.ReadAllText(@"C:\Probe\manifest.json"));
        if((string)manifest["nonce"]!=args[0]||(string)manifest["binary_sha256"]!=Sha(Self))return 22;
        string failure=null;int? hresult=null;int? javaExit=null;var checks=new List<object>();
        using(var log=new StreamWriter(new FileStream(Output+@"\bootstrap.jsonl",FileMode.CreateNew,FileAccess.Write),new UTF8Encoding(false))) {
            try {
                foreach(var pair in (Dictionary<string,object>)manifest["guest_pins"])
                    if(Sha(pair.Key)!=(string)pair.Value)throw new InvalidOperationException("Guest program/tool anchor drift");
                foreach(string path in (System.Collections.IEnumerable)manifest["readonly_files"]) {
                    foreach(uint access in new uint[]{0x40000000,0x40000,0x80000}) {
                        log.WriteLine(Json.Serialize(new {operation="readonly_file",path=path,access=access}));log.Flush();((FileStream)log.BaseStream).Flush(true);
                        using(var handle=CreateFile(path,access,7,IntPtr.Zero,3,0,IntPtr.Zero)) {
                            int error=handle.IsInvalid?Marshal.GetLastWin32Error():0;
                            checks.Add(new {path=path,access=access,directory=false,succeeded=!handle.IsInvalid,native_error=error});
                            if(!handle.IsInvalid||error!=5)throw new InvalidOperationException("Readonly input file not denied: "+error);
                        }
                    }
                }
                foreach(string path in (System.Collections.IEnumerable)manifest["readonly_roots"]) {
                    log.WriteLine(Json.Serialize(new {operation="readonly_parent_delete_child",path=path}));log.Flush();((FileStream)log.BaseStream).Flush(true);
                    using(var handle=CreateFile(path,0x40,7,IntPtr.Zero,3,0x02000000,IntPtr.Zero)) {
                        int error=handle.IsInvalid?Marshal.GetLastWin32Error():0;
                        checks.Add(new {path=path,access=0x40,directory=true,succeeded=!handle.IsInvalid,native_error=error});
                        if(!handle.IsInvalid||error!=5)throw new InvalidOperationException("Readonly parent access not denied: "+error);
                    }
                }
                var info=new ProcessStartInfo(@"C:\Inputs\Jdk\bin\java.exe","-cp C:\\Probe SandboxLayoutProbe "+args[0]) {
                    UseShellExecute=false,CreateNoWindow=true,RedirectStandardOutput=true,RedirectStandardError=true,WorkingDirectory=Output};
                foreach(string key in new string[]{"JAVA_TOOL_OPTIONS","_JAVA_OPTIONS","JDK_JAVA_OPTIONS","CLASSPATH"})info.EnvironmentVariables.Remove(key);
                using(var process=Process.Start(info)) {
                    var stdout=process.StandardOutput.ReadToEndAsync();var stderr=process.StandardError.ReadToEndAsync();
                    if(!process.WaitForExit(300000)){process.Kill();process.WaitForExit(5000);throw new TimeoutException("Filesystem Java probe");}
                    if(!System.Threading.Tasks.Task.WaitAll(new System.Threading.Tasks.Task[]{stdout,stderr},5000))throw new TimeoutException("Java diagnostics");
                    File.WriteAllText(Output+@"\java.stdout",stdout.Result);File.WriteAllText(Output+@"\java.stderr",stderr.Result);
                    javaExit=process.ExitCode;if(javaExit!=0)throw new InvalidOperationException("Filesystem Java probe failed");
                }
            }catch(Exception error){failure=error.GetType().FullName+": "+error.Message;hresult=error.HResult;}
            var result=new {schema=1,kind="readonly-input-layout",nonce=args[0],username=Environment.UserName,binary_sha256=Sha(Self),
                readonly_checks=checks,java_exit=javaExit,failure=failure,failure_hresult=hresult,
                clr_version=Environment.Version.ToString(),kernel_file_version=FileVersionInfo.GetVersionInfo(Path.Combine(Environment.SystemDirectory,"kernel32.dll")).FileVersion,
                gradle_starts=0,apk_builds=0,G2=false};
            using(var file=new FileStream(Output+@"\result.pending",FileMode.CreateNew,FileAccess.Write)) {
                byte[] bytes=Encoding.UTF8.GetBytes(Json.Serialize(result));file.Write(bytes,0,bytes.Length);file.Flush(true);
            }
            File.Move(Output+@"\result.pending",Output+@"\result.json");
        }
        Process.Start(new ProcessStartInfo(Path.Combine(Environment.SystemDirectory,"shutdown.exe"),"/s /t 3"){UseShellExecute=false,CreateNoWindow=true});
        return failure==null?0:1;
    }
}
