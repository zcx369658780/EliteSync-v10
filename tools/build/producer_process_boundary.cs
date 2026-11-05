// Guest-only primitives. No Main, authorization, claim, VM or SDK launch entry.
// Windows semantics remain NOT_RUN until an independently authorized guest test.
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.AccessControl;
using System.Security.Principal;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;

internal sealed class ProducerChild {
    internal IntPtr Process, Thread;
}

internal interface IProducerBoundaryApi {
    void PrepareWorkspace();
    IntPtr CreateToken();
    IntPtr CreateJob();
    ProducerChild SpawnSuspended(IntPtr token);
    void Assign(IntPtr job, IntPtr process);
    void Resume(IntPtr thread);
    void TerminateAndDrainJob(IntPtr job);
    void TerminateAndWaitRoot(IntPtr process);
    void Close(IntPtr handle);
}

internal sealed class ProducerLease : IDisposable {
    IProducerBoundaryApi Api;
    internal readonly IntPtr Job, Process;
    internal ProducerLease(IProducerBoundaryApi api, IntPtr job, IntPtr process) {
        Api=api;Job=job;Process=process;
    }
    public void Dispose() {
        var api=Api;if(api==null)return;Api=null;
        var errors=new List<Exception>();
        ProducerBoundary.Attempt(errors,delegate{api.TerminateAndDrainJob(Job);});
        var process=Process;var job=Job;
        ProducerBoundary.CloseTaken(api,ref process,errors);ProducerBoundary.CloseTaken(api,ref job,errors);
        if(errors.Count>0)throw new AggregateException("Producer cleanup incomplete",errors);
    }
}

internal static class ProducerBoundary {
    internal static ProducerLease Start(IProducerBoundaryApi api) {
        if(api==null)throw new ArgumentNullException("api");
        IntPtr token=IntPtr.Zero,job=IntPtr.Zero;ProducerChild child=null;bool assigned=false;
        var errors=new List<Exception>();
        try {
            api.PrepareWorkspace();
            token=api.CreateToken();Nonzero(token);
            job=api.CreateJob();Nonzero(job);
            child=api.SpawnSuspended(token);
            if(child==null)throw new InvalidDataException("Missing suspended child");
            Nonzero(child.Process);Nonzero(child.Thread);
            api.Assign(job,child.Process);assigned=true;
            api.Resume(child.Thread);
        } catch(Exception failure) {errors.Add(failure);}
        if(errors.Count==0) {
            CloseTaken(api,ref child.Thread,errors);CloseTaken(api,ref token,errors);
            if(errors.Count==0)return new ProducerLease(api,job,child.Process);
        }
        if(assigned)Attempt(errors,delegate{api.TerminateAndDrainJob(job);});
        else if(child!=null&&OwnedHandle(child.Process))
            Attempt(errors,delegate{api.TerminateAndWaitRoot(child.Process);});
        if(child!=null){CloseTaken(api,ref child.Thread,errors);CloseTaken(api,ref child.Process,errors);}
        CloseTaken(api,ref job,errors);CloseTaken(api,ref token,errors);
        throw new AggregateException("Producer start failed; cleanup attempted once for all owned handles",errors);
    }
    internal static void Attempt(List<Exception> errors,Action action) {try{action();}catch(Exception e){errors.Add(e);}}
    internal static void FinishFactory(List<Exception> errors,Action rollback,params Action[] cleanup) {
        foreach(var action in cleanup)Attempt(errors,action);
        if(errors.Count>0) {
            Attempt(errors,rollback);
            throw new AggregateException("Native factory failed before ownership transfer",errors);
        }
    }
    internal static void CloseTaken(IProducerBoundaryApi api,ref IntPtr handle,List<Exception> errors) {
        var owned=handle;handle=IntPtr.Zero;
        if(OwnedHandle(owned))Attempt(errors,delegate{api.Close(owned);});
    }
    internal static bool OwnedHandle(IntPtr handle){return handle.ToInt64()>0;}
    static void Nonzero(IntPtr handle) {
        if(!OwnedHandle(handle))throw new InvalidDataException("Invalid owned handle");
    }
}

internal sealed class WindowsProducerBoundary : IProducerBoundaryApi {
    const string Work=@"C:\BuildWork", Self=@"C:\Probe\ProducerSupervisor.exe";
    readonly string Nonce, Command, Cwd, EnvironmentBlock;
    readonly SecurityIdentifier RestrictedSid;
    internal WindowsProducerBoundary(string nonce, string command, string cwd, IDictionary<string,string> environment) {
        if(Environment.UserName!="WDAGUtilityAccount"||
           !String.Equals(Process.GetCurrentProcess().MainModule.FileName,Self,StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Guest supervisor identity required");
        Validate(nonce,command,cwd,environment);
        Nonce=nonce;Command=command;Cwd=cwd;
        RestrictedSid=new SecurityIdentifier(RestrictionSid(nonce));
        EnvironmentBlock=String.Join("\0",environment.OrderBy(p=>p.Key,StringComparer.OrdinalIgnoreCase)
            .Select(p=>p.Key+"="+p.Value))+"\0\0";
    }
    internal static string RestrictionSid(string nonce) {
        if(nonce==null||!Regex.IsMatch(nonce,"\\A[0-9a-f]{32}\\z"))throw new InvalidDataException("Exact nonce required");
        return "S-1-5-21-"+String.Join("-",Enumerable.Range(0,4).Select(i=>Convert.ToUInt32(nonce.Substring(i*8,8),16)))+"-1015";
    }
    internal static void Validate(string nonce,string command,string cwd,IDictionary<string,string> environment) {
        if(nonce==null||!Regex.IsMatch(nonce,"\\A[0-9a-f]{32}\\z")||command==null||command.Length>30000||
           command.IndexOfAny(new[]{'\0','\r','\n'})>=0||
           !command.StartsWith("C:/Inputs/Jdk/bin/java.exe ",StringComparison.Ordinal))
            throw new InvalidDataException("Bound Java command required");
        if(cwd!=@"C:\BuildWork\Project\apps\flutter_elitesync_module\.android")
            throw new InvalidDataException("Exact producer working directory required");
        if(environment==null||environment.Count==0||environment.Count>64)
            throw new InvalidDataException("Explicit bounded environment required");
        var names=new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        long length=1;
        foreach(var p in environment) {
            if(String.IsNullOrEmpty(p.Key)||p.Key.Length>128||p.Value==null||p.Value.Length>8192||p.Key.IndexOf('=')>=0||
               (p.Key+p.Value).IndexOfAny(new[]{'\0','\r','\n'})>=0||!names.Add(p.Key)||
               p.Key.Equals("FLUTTER_ALREADY_LOCKED",StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("Invalid explicit environment");
            length+=p.Key.Length+p.Value.Length+2;
        }
        if(length>32760)throw new InvalidDataException("Explicit environment block bound exceeded");
    }
    static void Check(bool ok,string operation) {if(!ok)throw new Win32Exception(Marshal.GetLastWin32Error(),operation);}
    static void Canonical(string path) {
        if(Path.GetFullPath(path)!=path)throw new IOException("Noncanonical guest path");
        for(var current=new DirectoryInfo(path);current!=null;current=current.Parent)
            if(!current.Exists||(current.Attributes&FileAttributes.ReparsePoint)!=0)
                throw new IOException("Missing or redirected guest directory");
    }
    public void PrepareWorkspace() {
        Canonical(Work);Canonical(Cwd);
        // Only the future owned guest workspace receives this SID and low label.
        // No source mapping, Windows directory or host path is modified.
        var acl=Directory.GetAccessControl(Work);
        acl.SetAccessRuleProtection(true,true);
        acl.AddAccessRule(new FileSystemAccessRule(RestrictedSid,FileSystemRights.Modify|FileSystemRights.Synchronize,
            InheritanceFlags.ContainerInherit|InheritanceFlags.ObjectInherit,PropagationFlags.None,AccessControlType.Allow));
        Directory.SetAccessControl(Work,acl);
        IntPtr descriptor=IntPtr.Zero;
        try {
            Check(ConvertStringSecurityDescriptorToSecurityDescriptor("S:(ML;OICI;NW;;;LW)",1,out descriptor,IntPtr.Zero),"low workspace descriptor");
            bool present,defaulted;IntPtr sacl;
            Check(GetSecurityDescriptorSacl(descriptor,out present,out sacl,out defaulted)&&present,"low workspace SACL");
            uint code=SetNamedSecurityInfo(Work,1,0x10,IntPtr.Zero,IntPtr.Zero,IntPtr.Zero,sacl);
            if(code!=0)throw new Win32Exception((int)code,"label only owned workspace");
        } finally {if(descriptor!=IntPtr.Zero)LocalFree(descriptor);}
    }
    public IntPtr CreateToken() {
        IntPtr original=IntPtr.Zero,restricted=IntPtr.Zero;
        var sidBytes=new byte[RestrictedSid.BinaryLength];RestrictedSid.GetBinaryForm(sidBytes,0);
        IntPtr sid=Marshal.AllocHGlobal(sidBytes.Length),low=IntPtr.Zero;
        var errors=new List<Exception>();
        try {
            Marshal.Copy(sidBytes,0,sid,sidBytes.Length);
            Check(OpenProcessToken(GetCurrentProcess(),0x0001|0x0002|0x0008|0x0080,out original),"open own token");
            var restriction=new[]{new SidAndAttributes{Sid=sid,Attributes=0}};
            // DISABLE_MAX_PRIVILEGE | WRITE_RESTRICTED. Only explicit owned ACL
            // grants satisfy the second write access check. MIC adds NO_WRITE_UP.
            Check(CreateRestrictedToken(original,0x1|0x8,0,IntPtr.Zero,0,IntPtr.Zero,1,restriction,out restricted),"restricted write token");
            Check(ConvertStringSidToSid("S-1-16-4096",out low),"low token SID");
            var label=new SidAndAttributes{Sid=low,Attributes=0x20};
            Check(SetTokenInformation(restricted,25,ref label,(uint)(Marshal.SizeOf(typeof(SidAndAttributes))+GetLengthSid(low))),"low token label");
        } catch(Exception error) {errors.Add(error);}
        ProducerBoundary.FinishFactory(errors,delegate{if(restricted!=IntPtr.Zero)Close(restricted);},
            delegate{if(original!=IntPtr.Zero)Close(original);},
            delegate{if(low!=IntPtr.Zero&&LocalFree(low)!=IntPtr.Zero)throw new Win32Exception("free low SID");},
            delegate{Marshal.FreeHGlobal(sid);});
        return restricted;
    }
    public IntPtr CreateJob() {
        IntPtr job=CreateJobObject(IntPtr.Zero,null);
        Check(job!=IntPtr.Zero,"create owned job");
        try {
            var limits=new Extended();limits.Basic.Flags=0x2000|0x8|0x200;
            limits.Basic.ActiveProcessLimit=64;limits.JobMemoryLimit=new UIntPtr(4UL*1024*1024*1024);
            Check(Marshal.SizeOf(limits)==144,"x64 job layout");
            Check(SetInformationJobObject(job,9,ref limits,144),"job kill-on-close, process and memory limits");
            return job;
        } catch {Close(job);throw;}
    }
    public ProducerChild SpawnSuspended(IntPtr token) {
        string logs=Work+@"\Control";Canonical(logs);
        IntPtr stdout=IntPtr.Zero,stderr=IntPtr.Zero,stdin=IntPtr.Zero,attributes=IntPtr.Zero,
            handles=IntPtr.Zero,env=IntPtr.Zero;
        bool initialized=false;
        bool created=false;ProcessInformation child=new ProcessInformation();var errors=new List<Exception>();
        try {
            var sa=new SecurityAttributes{Length=Marshal.SizeOf(typeof(SecurityAttributes)),Inherit=true};
            stdout=CreateFile(logs+@"\stdout-"+Nonce+".log",0x40000000,1,ref sa,1,0,IntPtr.Zero);ValidFile(stdout);
            stderr=CreateFile(logs+@"\stderr-"+Nonce+".log",0x40000000,1,ref sa,1,0,IntPtr.Zero);ValidFile(stderr);
            stdin=CreateFile("NUL",0x80000000,1|2,ref sa,3,0,IntPtr.Zero);ValidFile(stdin);
            IntPtr size=IntPtr.Zero;InitializeProcThreadAttributeList(IntPtr.Zero,1,0,ref size);
            if(size==IntPtr.Zero)throw new Win32Exception("attribute size unavailable");
            attributes=Marshal.AllocHGlobal(size);Check(InitializeProcThreadAttributeList(attributes,1,0,ref size),"initialize explicit inherited handles");initialized=true;
            handles=Marshal.AllocHGlobal(3*IntPtr.Size);
            Marshal.WriteIntPtr(handles,0,stdin);Marshal.WriteIntPtr(handles,IntPtr.Size,stdout);Marshal.WriteIntPtr(handles,2*IntPtr.Size,stderr);
            Check(UpdateProcThreadAttribute(attributes,0,new IntPtr(0x20002),handles,new IntPtr(3*IntPtr.Size),IntPtr.Zero,IntPtr.Zero),"three inherited handles only");
            var startup=new StartupEx();startup.Startup.Size=(uint)Marshal.SizeOf(typeof(StartupEx));
            startup.Startup.Flags=0x100;startup.Startup.Stdin=stdin;startup.Startup.Stdout=stdout;startup.Startup.Stderr=stderr;startup.Attributes=attributes;
            env=Marshal.StringToHGlobalUni(EnvironmentBlock);
            Check(CreateProcessAsUser(token,@"C:\Inputs\Jdk\bin\java.exe",new StringBuilder(Command),IntPtr.Zero,IntPtr.Zero,true,
                0x08000000|0x80000|0x400|0x4,env,Cwd,ref startup,out child),"restricted suspended Java root");
            created=true;
        } catch(Exception error) {errors.Add(error);}
        ProducerBoundary.FinishFactory(errors,delegate {
            if(!created)return;
            // Still suspended and not assigned to a Job: the factory retains
            // ownership until every temporary resource is cleaned successfully.
            var rollback=new List<Exception>();
            ProducerBoundary.Attempt(rollback,delegate{TerminateAndWaitRoot(child.Process);});
            ProducerBoundary.CloseTaken(this,ref child.Thread,rollback);
            ProducerBoundary.CloseTaken(this,ref child.Process,rollback);
            if(rollback.Count>0)throw new AggregateException("Untransferred child cleanup failed",rollback);
        },delegate{if(initialized)DeleteProcThreadAttributeList(attributes);},
          delegate{if(attributes!=IntPtr.Zero)Marshal.FreeHGlobal(attributes);},
          delegate{if(handles!=IntPtr.Zero)Marshal.FreeHGlobal(handles);},
          delegate{if(env!=IntPtr.Zero)Marshal.FreeHGlobal(env);},
          delegate{CloseTemporary(stdin);},delegate{CloseTemporary(stdout);},delegate{CloseTemporary(stderr);});
        return new ProducerChild{Process=child.Process,Thread=child.Thread};
    }
    void CloseTemporary(IntPtr h){if(h!=IntPtr.Zero&&h!=new IntPtr(-1))Close(h);}
    static void ValidFile(IntPtr h) {Check(h!=IntPtr.Zero&&h!=new IntPtr(-1),"new private log or readonly stdin handle");}
    public void Assign(IntPtr job,IntPtr process) {Check(AssignProcessToJobObject(job,process),"assign suspended root before resume");}
    public void Resume(IntPtr thread) {if(ResumeThread(thread)!=1)throw new Win32Exception("resume requires exactly one suspension");}
    public void TerminateAndWaitRoot(IntPtr process) {
        Check(TerminateProcess(process,79),"terminate only unassigned owned root");
        if(WaitForSingleObject(process,5000)!=0)throw new IOException("Owned root exit not observed");
    }
    public void TerminateAndDrainJob(IntPtr job) {
        Check(TerminateJobObject(job,79),"terminate only owned job");
        var clock=Stopwatch.StartNew();
        while(true) {
            Accounting accounting;uint returned;
            Check(QueryInformationJobObject(job,1,out accounting,(uint)Marshal.SizeOf(typeof(Accounting)),out returned),"owned job active count");
            if(accounting.ActiveProcesses==0)return;
            if(clock.ElapsedMilliseconds>=5000)throw new IOException("Owned job did not drain");Thread.Sleep(20);
        }
    }
    public void Close(IntPtr handle) {Check(CloseHandle(handle),"close owned handle");}
    [StructLayout(LayoutKind.Sequential)] struct SidAndAttributes {public IntPtr Sid;public uint Attributes;}
    [StructLayout(LayoutKind.Sequential)] struct SecurityAttributes {public int Length;public IntPtr Descriptor;[MarshalAs(UnmanagedType.Bool)]public bool Inherit;}
    [StructLayout(LayoutKind.Sequential)] struct Startup {public uint Size;public IntPtr Reserved,Desktop,Title;public uint X,Y,XSize,YSize,XChars,YChars,Fill,Flags;public ushort Show,Reserved2;public IntPtr ReservedBytes,Stdin,Stdout,Stderr;}
    [StructLayout(LayoutKind.Sequential)] struct StartupEx {public Startup Startup;public IntPtr Attributes;}
    [StructLayout(LayoutKind.Sequential)] struct ProcessInformation {public IntPtr Process,Thread;public uint Pid,Tid;}
    [StructLayout(LayoutKind.Sequential)] struct BasicLimits {public long ProcessTime,JobTime;public uint Flags;public UIntPtr Minimum,Maximum;public uint ActiveProcessLimit;public UIntPtr Affinity;public uint Priority,Scheduling;}
    [StructLayout(LayoutKind.Sequential)] struct Io {public ulong Read,Write,Other,ReadBytes,WriteBytes,OtherBytes;}
    [StructLayout(LayoutKind.Sequential)] struct Extended {public BasicLimits Basic;public Io Io;public UIntPtr ProcessMemoryLimit,JobMemoryLimit,PeakProcessMemory,PeakJobMemory;}
    [StructLayout(LayoutKind.Sequential)] struct Accounting {public long User,Kernel,PeriodUser,PeriodKernel;public uint Faults,TotalProcesses,ActiveProcesses,Terminated;}
    [DllImport("kernel32.dll")] static extern IntPtr GetCurrentProcess();
    [DllImport("advapi32.dll",SetLastError=true)] static extern bool OpenProcessToken(IntPtr process,uint access,out IntPtr token);
    [DllImport("advapi32.dll",SetLastError=true)] static extern bool CreateRestrictedToken(IntPtr existing,uint flags,uint disable,IntPtr disabled,uint deletes,IntPtr privileges,uint count,[In] SidAndAttributes[] sids,out IntPtr token);
    [DllImport("advapi32.dll",SetLastError=true)] static extern bool SetTokenInformation(IntPtr token,int kind,ref SidAndAttributes value,uint bytes);
    [DllImport("advapi32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern bool ConvertStringSidToSid(string sid,out IntPtr pointer);
    [DllImport("advapi32.dll")] static extern uint GetLengthSid(IntPtr sid);
    [DllImport("advapi32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern bool ConvertStringSecurityDescriptorToSecurityDescriptor(string sddl,uint revision,out IntPtr descriptor,IntPtr size);
    [DllImport("advapi32.dll",SetLastError=true)] static extern bool GetSecurityDescriptorSacl(IntPtr descriptor,out bool present,out IntPtr sacl,out bool defaulted);
    [DllImport("advapi32.dll",CharSet=CharSet.Unicode)] static extern uint SetNamedSecurityInfo(string name,uint kind,uint info,IntPtr owner,IntPtr group,IntPtr dacl,IntPtr sacl);
    [DllImport("advapi32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern bool CreateProcessAsUser(IntPtr token,string app,StringBuilder command,IntPtr pa,IntPtr ta,bool inherit,uint flags,IntPtr env,string cwd,ref StartupEx startup,out ProcessInformation child);
    [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern IntPtr CreateFile(string path,uint access,uint share,ref SecurityAttributes sa,uint creation,uint flags,IntPtr template);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool InitializeProcThreadAttributeList(IntPtr list,int count,int flags,ref IntPtr size);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool UpdateProcThreadAttribute(IntPtr list,uint flags,IntPtr key,IntPtr value,IntPtr size,IntPtr previous,IntPtr returned);
    [DllImport("kernel32.dll")] static extern void DeleteProcThreadAttributeList(IntPtr list);
    [DllImport("kernel32.dll")] static extern IntPtr LocalFree(IntPtr pointer);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool CloseHandle(IntPtr handle);
    [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern IntPtr CreateJobObject(IntPtr attributes,string name);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool SetInformationJobObject(IntPtr job,int kind,ref Extended value,uint bytes);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool AssignProcessToJobObject(IntPtr job,IntPtr process);
    [DllImport("kernel32.dll",SetLastError=true)] static extern uint ResumeThread(IntPtr thread);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool TerminateJobObject(IntPtr job,uint code);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool TerminateProcess(IntPtr process,uint code);
    [DllImport("kernel32.dll",SetLastError=true)] static extern uint WaitForSingleObject(IntPtr handle,uint milliseconds);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool QueryInformationJobObject(IntPtr job,int kind,out Accounting value,uint bytes,out uint returned);
}
