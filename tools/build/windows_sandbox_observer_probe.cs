// Synthetic two-process Job and owner-PID socket sampling only. No build tools.
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web.Script.Serialization;

class Endpoint
{
    public uint pid, state; public int family, local_port, remote_port;
    public string protocol, local, remote;
}

class ObserverProbe
{
    const string Self=@"C:\Probe\ObserverProbe.exe", Output=@"C:\ProbeOutput";
    static readonly JavaScriptSerializer Json=new JavaScriptSerializer();
    static StreamWriter Sink;
    [StructLayout(LayoutKind.Sequential)] struct Startup {
        public uint cb; public IntPtr reserved,desktop,title; public uint x,y,w,h,xc,yc,fill,flags;
        public ushort show,reservedCount; public IntPtr reservedBytes,stdin,stdout,stderr;
    }
    [StructLayout(LayoutKind.Sequential)] struct Child { public IntPtr process,thread; public uint pid,tid; }
    [StructLayout(LayoutKind.Sequential)] struct Limits {
        public long processTime,jobTime; public uint flags; public UIntPtr min,max;
        public uint active; public UIntPtr affinity; public uint priority,scheduling;
    }
    [StructLayout(LayoutKind.Sequential)] struct Io { public ulong r,w,o,rb,wb,ob; }
    [StructLayout(LayoutKind.Sequential)] struct Extended { public Limits basic; public Io io; public UIntPtr pm,jm,pp,pj; }
    class Bound { public IntPtr handle; public uint pid; public long birth; public string image; }
    class SafetyStop:Exception { public SafetyStop(string reason):base(reason) {} }
    [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern IntPtr CreateJobObject(IntPtr sa,string name);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool SetInformationJobObject(IntPtr job,int kind,ref Extended info,uint length);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool QueryInformationJobObject(IntPtr job,int kind,IntPtr data,uint size,out uint written);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool AssignProcessToJobObject(IntPtr job,IntPtr process);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool IsProcessInJob(IntPtr process,IntPtr job,out bool inside);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool TerminateJobObject(IntPtr job,uint code);
    [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern bool CreateProcess(string app,StringBuilder command,IntPtr psa,IntPtr tsa,bool inherit,uint flags,IntPtr env,string cwd,ref Startup startup,out Child process);
    [DllImport("kernel32.dll",SetLastError=true)] static extern uint ResumeThread(IntPtr thread);
    [DllImport("kernel32.dll",SetLastError=true)] static extern IntPtr OpenProcess(uint access,bool inherit,uint pid);
    [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern bool QueryFullProcessImageName(IntPtr process,uint flags,StringBuilder image,ref uint length);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool GetProcessTimes(IntPtr process,out long birth,out long exit,out long kernel,out long user);
    [DllImport("kernel32.dll",SetLastError=true)] static extern uint WaitForSingleObject(IntPtr handle,uint milliseconds);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool TerminateProcess(IntPtr process,uint code);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool CloseHandle(IntPtr handle);
    [DllImport("iphlpapi.dll")] static extern uint GetExtendedTcpTable(IntPtr data,ref uint size,bool ordered,uint family,uint kind,uint reserved);
    [DllImport("iphlpapi.dll")] static extern uint GetExtendedUdpTable(IntPtr data,ref uint size,bool ordered,uint family,uint kind,uint reserved);

    static void Require(bool result,string operation) { if(!result) { int code=Marshal.GetLastWin32Error(); throw new Win32Exception(code,operation); } }
    static string Hash(string path) { using(var file=File.OpenRead(path)) using(var sha=SHA256.Create()) return BitConverter.ToString(sha.ComputeHash(file)).Replace("-","").ToLowerInvariant(); }
    static void Log(object row) { Sink.WriteLine(Json.Serialize(row)); Sink.Flush(); ((FileStream)Sink.BaseStream).Flush(true); }
    static void Before(string operation) { Log(new { utc=DateTime.UtcNow.ToString("o"),operation=operation }); }
    static void Write(string name,object value) {
        using(var file=new FileStream(Output+"\\"+name+".pending",FileMode.CreateNew,FileAccess.Write)) {
            byte[] data=Encoding.UTF8.GetBytes(Json.Serialize(value)); file.Write(data,0,data.Length); file.Flush(true);
        }
        File.Move(Output+"\\"+name+".pending",Output+"\\"+name+".json");
    }
    static Dictionary<string,object> Read(string name) { return Json.Deserialize<Dictionary<string,object>>(File.ReadAllText(Output+"\\"+name+".json")); }
    static void Await(string name) {
        var time=Stopwatch.StartNew(); while(!File.Exists(Output+"\\"+name+".json") && time.ElapsedMilliseconds<5000) Thread.Sleep(20);
        if(!File.Exists(Output+"\\"+name+".json")) throw new TimeoutException(name);
    }
    static Child Spawn(string nonce,string role) {
        var startup=new Startup(); startup.cb=(uint)Marshal.SizeOf(startup); Child child;
        Require(CreateProcess(Self,new StringBuilder("\""+Self+"\" "+nonce+" "+role),IntPtr.Zero,IntPtr.Zero,false,0x08000004,IntPtr.Zero,Output,ref startup,out child),"CreateProcess suspended");
        return child;
    }
    static long Birth(IntPtr handle) { long birth,exit,kernel,user; Require(GetProcessTimes(handle,out birth,out exit,out kernel,out user),"GetProcessTimes"); return birth; }
    static uint[] Members(IntPtr job) {
        IntPtr data=Marshal.AllocHGlobal(8+16*8);
        try {
            uint length; Require(QueryInformationJobObject(job,3,data,136,out length),"Job PID list");
            uint assigned=(uint)Marshal.ReadInt32(data), count=(uint)Marshal.ReadInt32(data,4);
            if(count>2 || assigned!=count) throw new SafetyStop("UNEXPECTED_OR_INCOMPLETE_JOB_MEMBERS");
            var ids=new uint[count];
            for(int i=0;i<count;i++) { long id=Marshal.ReadInt64(data,8+i*8); if(id<=0 || id>UInt32.MaxValue) throw new SafetyStop("INVALID_JOB_PID"); ids[i]=(uint)id; }
            if(ids.Distinct().Count()!=ids.Length) throw new SafetyStop("DUPLICATE_JOB_PID");
            return ids;
        } finally { Marshal.FreeHGlobal(data); }
    }
    static void CheckBound(IntPtr job,Bound bound) {
        if(WaitForSingleObject(bound.handle,0)!=258) throw new SafetyStop("MEMBER_NOT_LIVE");
        bool inside; Require(IsProcessInJob(bound.handle,job,out inside),"IsProcessInJob");
        if(!inside || Birth(bound.handle)!=bound.birth) throw new SafetyStop("MEMBER_INSTANCE_DRIFT");
        var image=new StringBuilder(1024); uint length=1024;
        Require(QueryFullProcessImageName(bound.handle,0,image,ref length),"QueryFullProcessImageName");
        Log(new {utc=DateTime.UtcNow.ToString("o"),operation="process_image_check",pid=bound.pid,birth=bound.birth,
            observed_image=image.ToString(),expected_image=Self});
        if(!String.Equals(image.ToString(),Self,StringComparison.OrdinalIgnoreCase)) throw new SafetyStop("UNKNOWN_PROCESS_IMAGE");
        bound.image=image.ToString();
    }

    internal static List<Endpoint> Parse(byte[] table,int family,bool tcp) {
        if((family!=2 && family!=23) || table.Length<4) throw new InvalidDataException("table header");
        int stride=tcp ? (family==2 ? 24:56):(family==2 ? 12:28);
        uint count=BitConverter.ToUInt32(table,0);
        if(count>65536 || 4L+(long)count*stride>table.Length) throw new InvalidDataException("table rows");
        var rows=new List<Endpoint>();
        for(int i=0;i<count;i++) {
            int offset=4+i*stride, local=offset+(tcp && family==2 ? 4:0);
            int addressBytes=family==2 ? 4:16, lp=offset+(family==2 ? (tcp?8:4):20);
            int rp=offset+(family==2 ? 16:44), remote=offset+(family==2 ? 12:24);
            var localBytes=new byte[addressBytes]; Array.Copy(table,local,localBytes,0,addressBytes);
            var row=new Endpoint {family=family,protocol=tcp?"TCP":"UDP",local=new IPAddress(localBytes).ToString(),
                local_port=(table[lp]<<8)|table[lp+1],pid=BitConverter.ToUInt32(table,offset+stride-4)};
            if(tcp) {
                var remoteBytes=new byte[addressBytes]; Array.Copy(table,remote,remoteBytes,0,addressBytes);
                row.remote=new IPAddress(remoteBytes).ToString(); row.remote_port=(table[rp]<<8)|table[rp+1];
                row.state=BitConverter.ToUInt32(table,offset+(family==2?0:48));
            }
            rows.Add(row);
        }
        return rows;
    }
    internal static bool UnsafeTcp(Endpoint row) {
        if(row.protocol!="TCP") return false; // UDP destinations remain unknown.
        if(!IPAddress.IsLoopback(IPAddress.Parse(row.local))) return true;
        if(row.state==2) return false; // Listening rows have no meaningful remote endpoint.
        return !IPAddress.IsLoopback(IPAddress.Parse(row.remote));
    }
    static List<Endpoint> Table(int family,bool tcp) {
        // https://learn.microsoft.com/windows/win32/api/iphlpapi/nf-iphlpapi-getextendedtcptable
        // https://learn.microsoft.com/windows/win32/api/iphlpapi/nf-iphlpapi-getextendedudptable
        uint size=0, code=tcp?GetExtendedTcpTable(IntPtr.Zero,ref size,false,(uint)family,5,0):GetExtendedUdpTable(IntPtr.Zero,ref size,false,(uint)family,1,0);
        if(code!=0 && code!=122) throw new Win32Exception((int)code,"network table sizing");
        for(int attempt=0;attempt<3;attempt++) {
            if(size<4 || size>8*1024*1024) throw new SafetyStop("NETWORK_TABLE_SIZE_INVALID");
            uint capacity=size; IntPtr memory=Marshal.AllocHGlobal((int)capacity);
            try {
                code=tcp?GetExtendedTcpTable(memory,ref size,false,(uint)family,5,0):GetExtendedUdpTable(memory,ref size,false,(uint)family,1,0);
                if(code==122) continue;
                if(code!=0) throw new Win32Exception((int)code,"network table read");
                if(size>capacity) throw new SafetyStop("NETWORK_TABLE_SIZE_DRIFT");
                byte[] bytes=new byte[size]; Marshal.Copy(memory,bytes,0,(int)size);
                return Parse(bytes,family,tcp);
            } finally { Marshal.FreeHGlobal(memory); }
        }
        throw new SafetyStop("NETWORK_TABLE_UNSTABLE");
    }
    static List<Endpoint> Sample(IntPtr job,Dictionary<uint,Bound> known,long leafBirth,uint leafPid,bool allowPendingLeaf=false) {
        Before("sample_begin"); uint[] ids=Members(job);
        if(ids.Length<known.Count) throw new SafetyStop("JOB_MEMBER_DISAPPEARED");
        foreach(uint pid in ids) {
            if(!known.ContainsKey(pid)) {
                if((pid!=leafPid || leafBirth<=0) && !(allowPendingLeaf && leafPid==0 && known.Count==1)) throw new SafetyStop("UNKNOWN_JOB_MEMBER");
                IntPtr handle=OpenProcess(0x100000|0x1000,false,pid); Require(handle!=IntPtr.Zero,"OpenProcess member");
                try {var bound=new Bound {handle=handle,pid=pid,birth=leafPid==0?Birth(handle):leafBirth};known.Add(pid,bound);}
                catch {CloseHandle(handle);throw;}
            }
            CheckBound(job,known[pid]);
        }
        var rows=new List<Endpoint>();
        foreach(int family in new int[]{2,23}) foreach(bool tcp in new bool[]{true,false})
            rows.AddRange(Table(family,tcp).Where(row=>known.ContainsKey(row.pid)));
        // Recheck identities after the endpoint snapshots, retaining non-atomic limits.
        foreach(var bound in known.Values) CheckBound(job,bound);
        Log(new {utc=DateTime.UtcNow.ToString("o"),members=known.Values.Select(b=>new {pid=b.pid,birth=b.birth,image=b.image}).ToArray(),endpoints=rows,udp_destination="UNKNOWN",sampling_non_atomic=true});
        if(rows.Any(UnsafeTcp)) throw new SafetyStop("NON_LOOPBACK_TCP");
        return rows;
    }
    static void WaitObserved(string name,IntPtr job,Dictionary<uint,Bound> known,long birth,uint pid,ref int samples,bool pending=false) {
        var timer=Stopwatch.StartNew();
        while(!File.Exists(Output+"\\"+name+".json") && timer.ElapsedMilliseconds<5000) {
            ChildFailure();
            Sample(job,known,birth,pid,pending);samples++;Thread.Sleep(30);
        }
        ChildFailure();
        if(!File.Exists(Output+"\\"+name+".json"))throw new TimeoutException(name);
    }
    static void ChildFailure() {
        foreach(string role in new string[]{"worker","leaf"})
            if(File.Exists(Output+"\\"+role+"-failure.json"))throw new SafetyStop("OWNED_CHILD_FAILED: "+Read(role+"-failure")["failure"]);
    }
    static void Leaf(string nonce) {
        var tcp4=new TcpListener(IPAddress.Loopback,0); var tcp6=new TcpListener(IPAddress.IPv6Loopback,0);
        var udp4=new Socket(AddressFamily.InterNetwork,SocketType.Dgram,ProtocolType.Udp);
        var udp6=new Socket(AddressFamily.InterNetworkV6,SocketType.Dgram,ProtocolType.Udp);
        TcpListener bad=null;
        try {
            tcp6.Server.DualMode=false; udp6.DualMode=false; tcp4.Start(); tcp6.Start();
            udp4.Bind(new IPEndPoint(IPAddress.Loopback,0)); udp6.Bind(new IPEndPoint(IPAddress.IPv6Loopback,0));
            var process=Process.GetCurrentProcess();
            Write("leaf-ready",new {nonce=nonce,pid=process.Id,birth=process.StartTime.ToUniversalTime().ToFileTimeUtc(),
                ports=new int[]{((IPEndPoint)tcp4.LocalEndpoint).Port,((IPEndPoint)tcp6.LocalEndpoint).Port,
                                ((IPEndPoint)udp4.LocalEndPoint).Port,((IPEndPoint)udp6.LocalEndPoint).Port}});
            Await("violate"); if((string)Read("violate")["nonce"]!=nonce) return;
            // No outbound connection: deliberately bind a guest-only wildcard listener.
            bad=new TcpListener(IPAddress.Any,0); bad.Start(); Write("violation-ready",new {nonce=nonce,port=((IPEndPoint)bad.LocalEndpoint).Port});
            Thread.Sleep(30000);
        } finally {tcp4.Stop();tcp6.Stop();udp4.Dispose();udp6.Dispose();if(bad!=null)bad.Stop();}
    }
    static void Worker(string nonce) {
        Child leaf=Spawn(nonce,"leaf");
        try {
            Write("leaf-created",new {nonce=nonce,pid=leaf.pid,birth=Birth(leaf.process),suspended=true});
            Await("resume-leaf"); if((string)Read("resume-leaf")["nonce"]!=nonce) return;
            Require(ResumeThread(leaf.thread)!=UInt32.MaxValue,"resume inherited Job leaf"); Thread.Sleep(30000);
        } finally {if(WaitForSingleObject(leaf.process,0)!=0)TerminateProcess(leaf.process,72);CloseHandle(leaf.process);CloseHandle(leaf.thread);}
    }
    static object Supervise(string nonce) {
        IntPtr job=IntPtr.Zero; Child root=new Child(); var known=new Dictionary<uint,Bound>(); int samples=0;
        try {
            Before("create_owned_job"); job=CreateJobObject(IntPtr.Zero,null); Require(job!=IntPtr.Zero,"CreateJobObject");
            var limits=new Extended(); limits.basic.flags=0x2000;
            Require(Marshal.SizeOf(limits)==144,"x64 job layout"); Require(SetInformationJobObject(job,9,ref limits,144),"kill-on-close");
            root=Spawn(nonce,"worker"); Require(AssignProcessToJobObject(job,root.process),"assign suspended root");
            known.Add(root.pid,new Bound {pid=root.pid,handle=root.process,birth=Birth(root.process)});
            Sample(job,known,0,0);samples++;Require(ResumeThread(root.thread)!=UInt32.MaxValue,"resume root");
            WaitObserved("leaf-created",job,known,0,0,ref samples,true);var created=Read("leaf-created");
            if((string)created["nonce"]!=nonce || !(created["suspended"] is bool) || !(bool)created["suspended"]) throw new SafetyStop("LEAF_FRAME_INVALID");
            uint leafPid=Convert.ToUInt32(created["pid"]); long leafBirth=Convert.ToInt64(created["birth"]);
            Sample(job,known,leafBirth,leafPid);samples++; if(known.Count!=2)throw new SafetyStop("DESCENDANT_NOT_BOUND");
            if(!known.ContainsKey(leafPid) || known[leafPid].birth!=leafBirth)throw new SafetyStop("SUSPENDED_FRAME_IDENTITY_DRIFT");
            Write("resume-leaf",new {nonce=nonce});WaitObserved("leaf-ready",job,known,leafBirth,leafPid,ref samples);var ready=Read("leaf-ready");
            if((string)ready["nonce"]!=nonce || Convert.ToUInt32(ready["pid"])!=leafPid || Convert.ToInt64(ready["birth"])!=leafBirth)throw new SafetyStop("READY_IDENTITY_DRIFT");
            int[] ports=((System.Collections.IEnumerable)ready["ports"]).Cast<object>().Select(Convert.ToInt32).ToArray();
            if(ports.Length!=4 || ports.Any(p=>p<1 || p>65535))throw new SafetyStop("PORT_FRAME_INVALID");
            for(int pass=0;pass<3;pass++) {
                var rows=Sample(job,known,leafBirth,leafPid);samples++;
                var specs=new[]{new {f=2,t="TCP",p=ports[0]},new {f=23,t="TCP",p=ports[1]},new {f=2,t="UDP",p=ports[2]},new {f=23,t="UDP",p=ports[3]}};
                if(specs.Any(s=>!rows.Any(r=>r.pid==leafPid && r.family==s.f && r.protocol==s.t && r.local_port==s.p)))throw new SafetyStop("OWNED_ENDPOINT_NOT_OBSERVED");
                Thread.Sleep(30);
            }
            Write("violate",new {nonce=nonce});bool stopped=false;
            try {WaitObserved("violation-ready",job,known,leafBirth,leafPid,ref samples);Sample(job,known,leafBirth,leafPid);samples++;}catch(SafetyStop stop){if(stop.Message!="NON_LOOPBACK_TCP")throw;stopped=true;}
            if(!stopped)throw new SafetyStop("EXPECTED_NEGATIVE_NOT_DETECTED");
            Before("terminate_only_owned_job");Require(TerminateJobObject(job,73),"TerminateJobObject");
            foreach(var bound in known.Values)Require(WaitForSingleObject(bound.handle,5000)==0,"owned member exited");
            var emptyWait=Stopwatch.StartNew();while(Members(job).Length!=0 && emptyWait.ElapsedMilliseconds<5000)Thread.Sleep(20);
            if(Members(job).Length!=0)throw new SafetyStop("JOB_NOT_EMPTY");
            return new {bound_members=2,positive_endpoint_kinds=4,positive_samples=3,successful_samples=samples,
                descendants_bound_before_resume=true,negative_reason="NON_LOOPBACK_TCP",owned_job_stopped=true,
                all_bound_handles_exited=true,job_final_empty=true,tcp_udp_v4_v6_api_observed=true,
                udp_destination="UNKNOWN",sampling_non_atomic=true,full_builder_qualified=false};
        } finally {
            if(job!=IntPtr.Zero) {TerminateJobObject(job,74);CloseHandle(job);}
            if(root.process!=IntPtr.Zero && !known.ContainsKey(root.pid)) {TerminateProcess(root.process,75);WaitForSingleObject(root.process,5000);CloseHandle(root.process);}
            foreach(var bound in known.Values) {WaitForSingleObject(bound.handle,5000);CloseHandle(bound.handle);}
            if(root.thread!=IntPtr.Zero)CloseHandle(root.thread);
        }
    }
    static int Main(string[] args) {
        if(Environment.UserName!="WDAGUtilityAccount" || args.Length<1 || args.Length>2 ||
            !System.Text.RegularExpressions.Regex.IsMatch(args[0],"\\A[0-9a-f]{32}\\z"))return 20;
        if(!String.Equals(Process.GetCurrentProcess().MainModule.FileName,Self,StringComparison.OrdinalIgnoreCase))return 21;
        var manifest=Json.Deserialize<Dictionary<string,object>>(File.ReadAllText(@"C:\Probe\manifest.json"));
        if((string)manifest["nonce"]!=args[0] || Hash(Self)!=(string)manifest["binary_sha256"])return 22;
        if(args.Length==2) {
            if(args[1]!="worker" && args[1]!="leaf")return 23;
            try {if(args[1]=="worker")Worker(args[0]);else Leaf(args[0]);return 0;}
            catch(Exception childError) {Write(args[1]+"-failure",new {nonce=args[0],failure=childError.GetType().FullName+": "+childError.Message,hresult=childError.HResult});return 1;}
        }
        object proof=null; string failure=null; int? error=null;
        using(Sink=new StreamWriter(new FileStream(Output+@"\samples.jsonl",FileMode.CreateNew,FileAccess.Write),new UTF8Encoding(false))) {
            try {proof=Supervise(args[0]);}catch(Exception problem){failure=problem.GetType().FullName+": "+problem.Message;error=problem.HResult;}
            Before("write_result_and_request_guest_shutdown");
            Write("result",new {schema=1,kind="owned-tree-and-network-observer",nonce=args[0],username=Environment.UserName,
                binary_sha256=Hash(Self),proof=proof,failure=failure,failure_hresult=error,gradle_starts=0,apk_builds=0,G2=false});
        }
        Process.Start(new ProcessStartInfo(Path.Combine(Environment.SystemDirectory,"shutdown.exe"),"/s /t 3"){UseShellExecute=false,CreateNoWindow=true});
        return failure==null?0:1;
    }
}
