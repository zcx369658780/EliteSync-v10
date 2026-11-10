// Existing-tool compatibility and an owned synthetic Job child only. No Gradle.
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web.Script.Serialization;
using Microsoft.Win32.SafeHandles;

class RuntimeProbe
{
    const string Output = @"C:\ProbeOutput";
    const string Self = @"C:\Probe\RuntimeProbe.exe";
    static readonly JavaScriptSerializer Json = new JavaScriptSerializer();
    static StreamWriter Log;
    [StructLayout(LayoutKind.Sequential)] struct StartupInfo {
        public uint cb; public IntPtr reserved, desktop, title;
        public uint x, y, width, height, xchars, ychars, fill, flags;
        public ushort show, reservedCount; public IntPtr reservedBytes, stdin, stdout, stderr;
    }
    [StructLayout(LayoutKind.Sequential)] struct ProcessInfo { public IntPtr process, thread; public uint pid, tid; }
    [StructLayout(LayoutKind.Sequential)] struct BasicLimits {
        public long processTime, jobTime; public uint flags;
        public UIntPtr minWorkingSet, maxWorkingSet; public uint activeLimit;
        public UIntPtr affinity; public uint priority, scheduling;
    }
    [StructLayout(LayoutKind.Sequential)] struct IoCounters { public ulong readOps, writeOps, otherOps, readBytes, writeBytes, otherBytes; }
    [StructLayout(LayoutKind.Sequential)] struct ExtendedLimits {
        public BasicLimits basic; public IoCounters io;
        public UIntPtr processMemory, jobMemory, peakProcessMemory, peakJobMemory;
    }
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern IntPtr CreateJobObject(IntPtr sa, string name);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool SetInformationJobObject(IntPtr job, int infoClass, ref ExtendedLimits limits, uint length);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool AssignProcessToJobObject(IntPtr job, IntPtr process);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool IsProcessInJob(IntPtr process, IntPtr job, out bool inside);
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern bool CreateProcess(string application, StringBuilder command, IntPtr psa, IntPtr tsa, bool inherit, uint flags, IntPtr env, string cwd, ref StartupInfo startup, out ProcessInfo process);
    [DllImport("kernel32.dll", SetLastError=true)] static extern uint ResumeThread(IntPtr thread);
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern bool QueryFullProcessImageName(IntPtr process, uint flags, StringBuilder path, ref uint length);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool GetProcessTimes(IntPtr process, out long creation, out long exit, out long kernel, out long user);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool GetExitCodeProcess(IntPtr process, out uint exit);
    [DllImport("kernel32.dll", SetLastError=true)] static extern uint WaitForSingleObject(IntPtr handle, uint milliseconds);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool TerminateProcess(IntPtr process, uint code);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool CloseHandle(IntPtr handle);
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern SafeFileHandle CreateFile(string name, uint access, uint share, IntPtr sa, uint creation, uint flags, IntPtr template);

    static string Hash(string path) {
        using(var stream=File.OpenRead(path)) using(var sha=SHA256.Create())
            return BitConverter.ToString(sha.ComputeHash(stream)).Replace("-", "").ToLowerInvariant();
    }
    static void Before(string operation) {
        Log.WriteLine(Json.Serialize(new { utc=DateTime.UtcNow.ToString("o"), operation=operation }));
        Log.Flush(); ((FileStream)Log.BaseStream).Flush(true);
    }
    static void Require(bool result, string operation) {
        if(!result) { int error=Marshal.GetLastWin32Error(); throw new Win32Exception(error, operation); }
    }
    static void DenyAccess(string path) {
        foreach(uint access in new uint[] { 0x40000000, 0x40000, 0x80000 }) {
            Before("readonly_handle_"+path+"_"+access);
            using(var handle=CreateFile(path,access,7,IntPtr.Zero,3,0,IntPtr.Zero)) {
                int error=handle.IsInvalid ? Marshal.GetLastWin32Error() : 0;
                if(!handle.IsInvalid || error!=5) throw new InvalidOperationException("Readonly tool anchor not denied: "+error);
            }
        }
    }
    static object Tool(string name, string executable, string arguments, string expectedVersion) {
        Before("existing_tool_"+name);
        var info=new ProcessStartInfo(executable,arguments) { UseShellExecute=false, CreateNoWindow=true,
            RedirectStandardOutput=true, RedirectStandardError=true, WorkingDirectory=Output };
        foreach(string key in new string[] { "JAVA_TOOL_OPTIONS", "_JAVA_OPTIONS", "JDK_JAVA_OPTIONS", "CLASSPATH", "PYTHONPATH", "PYTHONHOME" }) info.EnvironmentVariables.Remove(key);
        using(var process=Process.Start(info)) {
            var stdout=process.StandardOutput.ReadToEndAsync(); var stderr=process.StandardError.ReadToEndAsync();
            if(!process.WaitForExit(10000)) { process.Kill(); process.WaitForExit(5000); throw new TimeoutException(name); }
            if(!System.Threading.Tasks.Task.WaitAll(new System.Threading.Tasks.Task[] { stdout,stderr },5000)) throw new TimeoutException(name+" output");
            string text=stdout.Result+stderr.Result;
            if(text.Length>32768 || process.ExitCode!=0 || !text.Contains(expectedVersion)) throw new InvalidOperationException(name+" compatibility failed");
            File.WriteAllText(Path.Combine(Output,name+".stdout"),stdout.Result);
            File.WriteAllText(Path.Combine(Output,name+".stderr"),stderr.Result);
            return new { exit=process.ExitCode, pid=process.Id, creation_utc=process.StartTime.ToUniversalTime().ToString("o"), version=expectedVersion };
        }
    }
    static object Job(string nonce) {
        // https://learn.microsoft.com/windows/win32/api/jobapi2/nf-jobapi2-assignprocesstojobobject
        // https://learn.microsoft.com/windows/win32/api/jobapi2/nf-jobapi2-setinformationjobobject
        IntPtr job=IntPtr.Zero; ProcessInfo child=new ProcessInfo();
        try {
            Before("create_owned_unnamed_job"); job=CreateJobObject(IntPtr.Zero,null); Require(job!=IntPtr.Zero,"CreateJobObject");
            var limits=new ExtendedLimits(); limits.basic.flags=0x2000;
            Require(Marshal.SizeOf(limits)==144,"extended limits x64 layout");
            Require(SetInformationJobObject(job,9,ref limits,(uint)Marshal.SizeOf(limits)),"kill_on_close");
            var startup=new StartupInfo(); startup.cb=(uint)Marshal.SizeOf(startup);
            Before("create_own_suspended_child");
            Require(CreateProcess(Self,new StringBuilder("\""+Self+"\" "+nonce+" worker"),IntPtr.Zero,IntPtr.Zero,false,0x08000004,IntPtr.Zero,Output,ref startup,out child),"CreateProcess suspended");
            Before("bind_child_before_resume"); Require(AssignProcessToJobObject(job,child.process),"AssignProcessToJobObject");
            bool inside; Require(IsProcessInJob(child.process,job,out inside) && inside,"IsProcessInJob");
            var path=new StringBuilder(1024); uint length=1024;
            Require(QueryFullProcessImageName(child.process,0,path,ref length),"QueryFullProcessImageName");
            if(!String.Equals(path.ToString(),Self,StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Unexpected child image");
            long birth,exit,kernel,user; Require(GetProcessTimes(child.process,out birth,out exit,out kernel,out user),"GetProcessTimes");
            Before("resume_bound_child"); Require(ResumeThread(child.thread)!=UInt32.MaxValue,"ResumeThread");
            var deadline=Stopwatch.StartNew();
            while(!File.Exists(Output+@"\worker-ready.json") && deadline.ElapsedMilliseconds<5000) Thread.Sleep(25);
            var ready=Json.Deserialize<Dictionary<string,object>>(File.ReadAllText(Output+@"\worker-ready.json"));
            if((string)ready["nonce"]!=nonce || Convert.ToUInt32(ready["pid"])!=child.pid || Convert.ToInt64(ready["birth"])!=birth) throw new InvalidOperationException("Child startup identity mismatch");
            uint code; Require(GetExitCodeProcess(child.process,out code) && code==259,"child must be live before close");
            Before("close_owned_job_kill_child"); Require(CloseHandle(job),"CloseHandle job"); job=IntPtr.Zero;
            Require(WaitForSingleObject(child.process,5000)==0,"child exit after job close");
            Require(GetExitCodeProcess(child.process,out code) && code!=259,"child exit code");
            return new { pid=child.pid, birth=birth, image=path.ToString(), assigned_before_resume=true, startup_frame=true,
                kill_on_close_observed=true, exit_code=code, full_build_observer_qualified=false };
        } finally {
            if(job!=IntPtr.Zero) CloseHandle(job);
            if(child.process!=IntPtr.Zero) {
                if(WaitForSingleObject(child.process,5000)!=0) { TerminateProcess(child.process,71); WaitForSingleObject(child.process,5000); }
                CloseHandle(child.process);
            }
            if(child.thread!=IntPtr.Zero) CloseHandle(child.thread);
        }
    }
    static int Main(string[] args) {
        if(Environment.UserName!="WDAGUtilityAccount" || args.Length<1 || args.Length>2 ||
            !System.Text.RegularExpressions.Regex.IsMatch(args[0],"\\A[0-9a-f]{32}\\z")) return 20;
        if(!String.Equals(Process.GetCurrentProcess().MainModule.FileName,Self,StringComparison.OrdinalIgnoreCase)) return 21;
        var manifest=Json.Deserialize<Dictionary<string,object>>(File.ReadAllText(@"C:\Probe\manifest.json"));
        if((string)manifest["nonce"]!=args[0] || (string)manifest["binary_sha256"]!=Hash(Self)) return 22;
        if(args.Length==2) {
            if(args[1]!="worker") return 23;
            var self=Process.GetCurrentProcess();
            File.WriteAllText(Output+@"\worker-ready.pending",Json.Serialize(new { nonce=args[0],pid=self.Id,birth=self.StartTime.ToUniversalTime().ToFileTimeUtc() }));
            File.Move(Output+@"\worker-ready.pending",Output+@"\worker-ready.json");
            Thread.Sleep(30000); return 0;
        }
        string failure=null; int? hresult=null; object java=null,python=null,job=null; bool readonlyAnchors=false;
        using(Log=new StreamWriter(new FileStream(Output+@"\operations.jsonl",FileMode.CreateNew,FileAccess.Write),new UTF8Encoding(false))) {
            try {
                foreach(var pair in (Dictionary<string,object>)manifest["guest_inputs"])
                    if(Hash(pair.Key)!=(string)pair.Value) throw new InvalidOperationException("Tool anchor drift");
                DenyAccess(@"C:\Tools\Jdk\release"); DenyAccess(@"C:\Tools\Python\Lib\os.py");
                readonlyAnchors=true;
                java=Tool("java",@"C:\Tools\Jdk\bin\java.exe","-version","17.0.18");
                python=Tool("python",@"C:\Tools\Python\python.exe","-I -S -c \"import sys,ctypes; print(sys.version); print(ctypes.sizeof(ctypes.c_void_p))\"","3.11.");
                job=Job(args[0]);
            } catch(Exception error) { failure=error.GetType().FullName+": "+error.Message; hresult=error.HResult; }
            Before("write_result_and_request_guest_shutdown");
            string result=Json.Serialize(new { schema=1,kind="existing-tools-and-owned-job",nonce=args[0],username=Environment.UserName,
                binary_sha256=Hash(Self),readonly_tool_anchors=readonlyAnchors,java=java,python=python,job=job,failure=failure,failure_hresult=hresult,
                gradle_starts=0,apk_builds=0,G2=false });
            using(var file=new FileStream(Output+@"\result.pending",FileMode.CreateNew,FileAccess.Write)) {
                byte[] bytes=Encoding.UTF8.GetBytes(result); file.Write(bytes,0,bytes.Length); file.Flush(true);
            }
            File.Move(Output+@"\result.pending",Output+@"\result.json");
        }
        Process.Start(new ProcessStartInfo(Path.Combine(Environment.SystemDirectory,"shutdown.exe"),"/s /t 3") { UseShellExecute=false,CreateNoWindow=true });
        return failure==null ? 0 : 1;
    }
}
