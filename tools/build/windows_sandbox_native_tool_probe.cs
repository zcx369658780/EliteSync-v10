// Existing-tool compatibility supervisor; no Flutter producer, Gradle or APK execution.
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

class GradleDiagnostic
{
    const string Self=@"C:\Probe\NativeToolProbe.exe", Output=@"C:\ProbeOutput";
    static readonly JavaScriptSerializer Json=new JavaScriptSerializer();
    static StreamWriter Sink;
    static bool RootCreateAttempted;
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
    class Bound { public IntPtr handle; public uint pid; public long birth; public string image; public bool exited; }
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
    [StructLayout(LayoutKind.Sequential)] struct Security {public int length;public IntPtr descriptor;[MarshalAs(UnmanagedType.Bool)]public bool inherit;}
    [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern IntPtr CreateFile(string path,uint access,uint share,ref Security security,uint creation,uint flags,IntPtr template);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool GetExitCodeProcess(IntPtr process,out uint code);
    static Dictionary<string,string> Images=new Dictionary<string,string>(StringComparer.OrdinalIgnoreCase);
    static Child Spawn(Dictionary<string,object> m) {
        var security=new Security {length=Marshal.SizeOf(typeof(Security)),inherit=true};
        IntPtr stdout=IntPtr.Zero,stderr=IntPtr.Zero,stdin=IntPtr.Zero,env=IntPtr.Zero; Child child;
        try {
            stdout=CreateFile(Output+@"\tool.stdout",0x40000000,3,ref security,1,0x80,IntPtr.Zero);
            stderr=CreateFile(Output+@"\tool.stderr",0x40000000,3,ref security,1,0x80,IntPtr.Zero);
            stdin=CreateFile("NUL",0x80000000,3,ref security,3,0x80,IntPtr.Zero);
            Require(stdout!=new IntPtr(-1)&&stderr!=new IntPtr(-1)&&stdin!=new IntPtr(-1),"diagnostic stdio");
            var vars=(Dictionary<string,object>)m["environment"];
            string block=String.Join("\0",vars.OrderBy(k=>k.Key,StringComparer.OrdinalIgnoreCase).Select(k=>k.Key+"="+(string)k.Value))+"\0\0";
            env=Marshal.StringToHGlobalUni(block);
            var startup=new Startup {cb=(uint)Marshal.SizeOf(typeof(Startup)),flags=0x100,stdout=stdout,stderr=stderr,stdin=stdin};
            Require(CreateProcess((string)m["executable"],new StringBuilder((string)m["command_line"]),IntPtr.Zero,IntPtr.Zero,true,0x08000404,env,(string)m["cwd"],ref startup,out child),"CreateProcess suspended diagnostic");
            return child;
        } finally {foreach(var h in new[]{stdout,stderr,stdin})if(h!=IntPtr.Zero&&h!=new IntPtr(-1))CloseHandle(h);if(env!=IntPtr.Zero)Marshal.FreeHGlobal(env);}
    }
    static long Birth(IntPtr handle) { long birth,exit,kernel,user; Require(GetProcessTimes(handle,out birth,out exit,out kernel,out user),"GetProcessTimes"); return birth; }
    static uint[] Members(IntPtr job) {
        IntPtr data=Marshal.AllocHGlobal(8+64*8);
        try {
            uint length; Require(QueryInformationJobObject(job,3,data,520,out length),"Job PID list");
            uint assigned=(uint)Marshal.ReadInt32(data), count=(uint)Marshal.ReadInt32(data,4);
            if(count>64 || assigned!=count) throw new SafetyStop("UNEXPECTED_OR_INCOMPLETE_JOB_MEMBERS");
            var ids=new uint[count];
            for(int i=0;i<count;i++) { long id=Marshal.ReadInt64(data,8+i*8); if(id<=0 || id>UInt32.MaxValue) throw new SafetyStop("INVALID_JOB_PID"); ids[i]=(uint)id; }
            if(ids.Distinct().Count()!=ids.Length) throw new SafetyStop("DUPLICATE_JOB_PID");
            return ids;
        } finally { Marshal.FreeHGlobal(data); }
    }
    internal static void RequireKnownExit(bool known) {if(!known)throw new SafetyStop("EXIT_BEFORE_IDENTITY_BOUND");}
    static void CheckBound(IntPtr job,Bound bound) {
        uint wait=WaitForSingleObject(bound.handle,0);
        if(wait==0){RequireKnownExit(bound.image!=null);bound.exited=true;return;}
        if(wait!=258||bound.exited)throw new SafetyStop("MEMBER_WAIT_OR_REUSE");
        bool inside;Require(IsProcessInJob(bound.handle,job,out inside),"IsProcessInJob");
        if(!inside||Birth(bound.handle)!=bound.birth)throw new SafetyStop("MEMBER_INSTANCE_DRIFT");
        var image=new StringBuilder(2048);uint length=2048;
        Require(QueryFullProcessImageName(bound.handle,0,image,ref length),"QueryFullProcessImageName");
        string actual=image.ToString(),pin;
        Log(new {operation="process_image_check",pid=bound.pid,birth=bound.birth,observed_image=actual});
        if(!Images.TryGetValue(actual,out pin))throw new SafetyStop("UNKNOWN_PROCESS_IMAGE");
        if(bound.image==null){Canonical(actual);if(Hash(actual)!=pin)throw new SafetyStop("EXECUTABLE_IDENTITY_DRIFT");bound.image=actual;}
        else if(!String.Equals(actual,bound.image,StringComparison.OrdinalIgnoreCase))throw new SafetyStop("IMAGE_PATH_DRIFT");
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
    static void Sample(IntPtr job,Dictionary<uint,Bound> known) {
        uint[] ids=Members(job);
        foreach(uint pid in ids) {
            if(!known.ContainsKey(pid)) {
                IntPtr h=OpenProcess(0x100000|0x1000,false,pid);Require(h!=IntPtr.Zero,"OpenProcess member");
                try {known.Add(pid,new Bound {handle=h,pid=pid,birth=Birth(h)});}catch{CloseHandle(h);throw;}
            }
            CheckBound(job,known[pid]);
        }
        foreach(var b in known.Values){CheckBound(job,b);if(!b.exited&&!ids.Contains(b.pid))throw new SafetyStop("LIVE_MEMBER_MISSING_FROM_JOB");}
        var rows=new List<Endpoint>();
        foreach(int family in new[]{2,23})foreach(bool tcp in new[]{true,false})rows.AddRange(Table(family,tcp).Where(r=>known.ContainsKey(r.pid)&&!known[r.pid].exited));
        foreach(var b in known.Values)CheckBound(job,b);
        Log(new {utc=DateTime.UtcNow.ToString("o"),members=known.Values.Select(b=>new{pid=b.pid,birth=b.birth,image=b.image,exited=b.exited}).ToArray(),endpoints=rows,udp_destination="UNKNOWN",sampling_non_atomic=true});
        if(rows.Any(UnsafeTcp))throw new SafetyStop("NON_LOOPBACK_TCP");
    }
    internal static void CheckOwnedPath(string path) {
        string root=@"C:\BuildWork\";
        if(!path.StartsWith(root,StringComparison.Ordinal)||path.IndexOf(':',2)>=0||Path.GetFullPath(path)!=path)throw new SafetyStop("OWNED_PATH_ESCAPE");
        string parent=Path.GetDirectoryName(path);
        while(!String.IsNullOrEmpty(parent)&&!Directory.Exists(parent))parent=Path.GetDirectoryName(parent);
        if(!String.IsNullOrEmpty(parent))Canonical(parent);
    }
    static void Canonical(string path) {
        if(!Path.IsPathRooted(path)||!String.Equals(Path.GetFullPath(path),path,StringComparison.OrdinalIgnoreCase))throw new SafetyStop("NONCANONICAL_PATH");
        for(string p=path;!String.IsNullOrEmpty(p);p=Path.GetDirectoryName(p)) {
            if((File.GetAttributes(p)&FileAttributes.ReparsePoint)!=0)throw new SafetyStop("REDIRECTED_PATH");
            if(p==Path.GetPathRoot(p))break;
        }
    }
    static IEnumerable<Dictionary<string,object>> Rows(object rows) {return ((System.Collections.IEnumerable)rows).Cast<object>().Select(r=>(Dictionary<string,object>)r);}
    static int PrepareInputs(Dictionary<string,object> m) {
        string work=@"C:\BuildWork";if(Directory.Exists(work)||File.Exists(work))throw new SafetyStop("WORK_ROOT_EXISTS");
        if(new DriveInfo("C").AvailableFreeSpace<8L*1024*1024*1024)throw new SafetyStop("INSUFFICIENT_GUEST_SPACE");
        Directory.CreateDirectory(work);int count=0;
        foreach(var row in Rows(m["inputs"])) {
            string path=(string)row["path"];Canonical(path);
            if(Hash(path)!=(string)row["sha256"])throw new SafetyStop("INPUT_HASH_DRIFT");
            if(row.ContainsKey("destination")) {
                string dest=(string)row["destination"];
                CheckOwnedPath(dest);
                Directory.CreateDirectory(Path.GetDirectoryName(dest));File.Copy(path,dest,false);Canonical(dest);
                if(Hash(dest)!=(string)row["sha256"])throw new SafetyStop("COPY_DRIFT");
            }
            if(++count%200==0)Log(new {operation="input_verified",count=count});
        }
        foreach(string directory in (System.Collections.IEnumerable)m["private_directories"]){CheckOwnedPath(directory);Directory.CreateDirectory(directory);Canonical(directory);}
        return count;
    }
    static void SourcePins(Dictionary<string,object> m) {
        foreach(var row in Rows(m["inputs"]).Where(r=>r.ContainsKey("destination")))
            if(Hash((string)row["destination"])!=(string)row["sha256"])throw new SafetyStop("WORK_SOURCE_DRIFT");
    }
    [StructLayout(LayoutKind.Sequential)] struct FileIdentityNative {
        public uint attributes,creationLow,creationHigh,accessLow,accessHigh,writeLow,writeHigh,volume,sizeHigh,sizeLow,links,indexHigh,indexLow;
    }
    [StructLayout(LayoutKind.Sequential)] struct FileIdDescriptor {public uint size;public int type;public long id,reserved;}
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool GetFileInformationByHandle(IntPtr file,out FileIdentityNative info);
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool GetFileInformationByHandleEx(IntPtr file,int kind,IntPtr data,uint size);
    [DllImport("kernel32.dll",SetLastError=true)] static extern IntPtr OpenFileById(IntPtr volume,ref FileIdDescriptor id,uint access,uint share,IntPtr security,uint flags);
    [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern uint GetFinalPathNameByHandle(IntPtr file,StringBuilder name,uint size,uint flags);
    internal class DiskEntry {public string name;public ulong id;public long bytes;public uint attributes;}
    internal static List<DiskEntry> ParseDirectoryPage(byte[] data) {
        var result=new List<DiskEntry>();int offset=0;
        while(true) {
            if(offset<0||offset>data.Length-104)throw new InvalidDataException("Directory header truncated");
            uint next=BitConverter.ToUInt32(data,offset),length=BitConverter.ToUInt32(data,offset+60);
            if(length==0||length%2!=0||length>data.Length-offset-104)throw new InvalidDataException("Directory name truncated");
            if(next!=0&&(next%8!=0||next<104+length||next>data.Length-offset-104))throw new InvalidDataException("Directory row offset invalid");
            string name=Encoding.Unicode.GetString(data,offset+104,(int)length);
            if(name!="."&&name!="..") {
                uint attributes=BitConverter.ToUInt32(data,offset+56);ulong id=BitConverter.ToUInt64(data,offset+96);long size=BitConverter.ToInt64(data,offset+40);
                if(name.IndexOfAny(new[]{'\\','/',':','\0'})>=0||size<0||id==0)throw new InvalidDataException("Directory entry identity invalid");
                if((attributes&0x400)!=0)throw new SafetyStop("REDIRECTED_DISK_ENTRY");
                result.Add(new DiskEntry{name=name,id=id,bytes=size,attributes=attributes});
            }
            if(next==0)return result;offset=checked(offset+(int)next);
        }
    }
    static FileIdentityNative FileIdentity(IntPtr handle) {
        FileIdentityNative info;Require(GetFileInformationByHandle(handle,out info),"directory handle identity");return info;
    }
    static ulong FileId(FileIdentityNative info){return ((ulong)info.indexHigh<<32)|info.indexLow;}
    static bool DeletePending(IntPtr handle) {
        IntPtr data=Marshal.AllocHGlobal(24);
        try{Require(GetFileInformationByHandleEx(handle,1,data,24),"directory delete-pending state");return Marshal.ReadByte(data,20)!=0;}
        finally{Marshal.FreeHGlobal(data);}
    }
    internal static string ReadDirectoryName(Func<string> read,Action<int,Win32Exception> retry) {
        for(int attempt=1;;attempt++) {
            try{return read();}
            catch(Win32Exception error) {
                int code=error.NativeErrorCode;
                if((code!=2&&code!=3&&code!=5)||attempt==3)throw;
                retry(attempt,error);Thread.Sleep(10);
            }
        }
    }
    static bool ScopedDirectory(IntPtr handle,uint volume,ulong expected,string root,bool isRoot) {
        var info=FileIdentity(handle);
        if(info.volume!=volume||FileId(info)!=expected)throw new SafetyStop("DIRECTORY_OBJECT_ID_DRIFT");
        if((info.attributes&0x400)!=0)throw new SafetyStop("REDIRECTED_DISK_ENTRY");
        if((info.attributes&0x10)==0)throw new SafetyStop("DIRECTORY_OBJECT_TYPE_DRIFT");
        if(DeletePending(handle)){if(isRoot)throw new SafetyStop("OWNED_ROOT_DELETE_PENDING");return false;}
        string path;
        try {
            path=ReadDirectoryName(delegate {
                var text=new StringBuilder(32768);uint n=GetFinalPathNameByHandle(handle,text,32768,0);
                if(n==0){int error=Marshal.GetLastWin32Error();throw new Win32Exception(error,"directory final handle name; native="+error+"; id="+expected.ToString("x16"));}
                if(n>=32768)throw new SafetyStop("DIRECTORY_NAME_OVERFLOW");
                return text.ToString();
            },delegate(int attempt,Win32Exception error) {
                DiskDirectoryNameRetries++;
                if(Sink!=null)Log(new{operation="disk_directory_name_retry",file_id=expected,error=error.NativeErrorCode,attempt=attempt});
            });
        }catch(Win32Exception) {
            if(!isRoot&&DeletePending(handle))return false;
            throw;
        }
        if(path.StartsWith(@"\\?\",StringComparison.Ordinal))path=path.Substring(4);
        bool same=String.Equals(path,root,StringComparison.OrdinalIgnoreCase);
        if(isRoot?!same:!(same||path.StartsWith(root+"\\",StringComparison.OrdinalIgnoreCase))) {
            // Deletion can occur between the first pending-state query and the
            // name query (NTFS may then report its internal deleted-object path).
            if(!isRoot&&DeletePending(handle))return false;
            throw new SafetyStop("DIRECTORY_SCOPE_ESCAPE");
        }
        return true;
    }
    static List<DiskEntry> DirectoryRows(IntPtr handle) {
        IntPtr page=Marshal.AllocHGlobal(65536);var rows=new List<DiskEntry>();
        try {
            bool first=true;
            while(true) {
                bool ok=GetFileInformationByHandleEx(handle,first?11:10,page,65536);int error=ok?0:Marshal.GetLastWin32Error();first=false;
                if(!ok){if(error==18)return rows;throw new Win32Exception(error,"enumerate owned directory handle");}
                var bytes=new byte[65536];Marshal.Copy(page,bytes,0,bytes.Length);rows.AddRange(ParseDirectoryPage(bytes));
                if(rows.Count>262144)throw new SafetyStop("DIRECTORY_ENTRY_COUNT_LIMIT");
            }
        }finally{Marshal.FreeHGlobal(page);}
    }
    static IntPtr OpenDirectoryId(IntPtr anchor,ulong id) {
        var descriptor=new FileIdDescriptor{size=24,type=0,id=unchecked((long)id)};
        return OpenFileById(anchor,ref descriptor,0x81,7,IntPtr.Zero,0x02200000);
    }
    static IntPtr OpenChildDirectoryId(IntPtr anchor,ulong id,out int error) {
        for(int attempt=1;;attempt++) {
            IntPtr child=OpenDirectoryId(anchor,id);error=child==new IntPtr(-1)?Marshal.GetLastWin32Error():0;
            if(child!=new IntPtr(-1)||error!=5||attempt==3)return child;
            // NTFS can deny an ID while its last delete-pending handle closes.
            // Retry the exact read-only request, never classify error 5 as gone.
            DiskDirectoryOpenRetries++;
            if(Sink!=null)Log(new{operation="disk_directory_open_retry",file_id=id,error=error,attempt=attempt});
            Thread.Sleep(10);
        }
    }
    // A retired NTFS ID can return error 87, as well as 2. Neither is sufficient
    // evidence of deletion: retain the parent handle and confirm the ID is absent.
    // A still-live ID, an unknown error, or a failed root/API control stays fatal.
    static void ConfirmMissingDirectory(IntPtr anchor,IntPtr parent,ulong parentId,ulong id,uint volume,ulong rootId,string root,int error) {
        if(error!=2&&error!=87)throw new Win32Exception(error,"open owned child directory by ID");
        ScopedDirectory(anchor,volume,rootId,root,true);
        IntPtr control=OpenDirectoryId(anchor,rootId);Require(control!=new IntPtr(-1),"open live root ID control");
        try{ScopedDirectory(control,volume,rootId,root,true);}finally{CloseHandle(control);}
        if(ScopedDirectory(parent,volume,parentId,root,parentId==rootId)) {
            if(DirectoryRows(parent).Any(row=>row.id==id))throw new Win32Exception(error,"failed directory ID still present in parent");
            ScopedDirectory(parent,volume,parentId,root,parentId==rootId);
        }
        ScopedDirectory(anchor,volume,rootId,root,true);
    }
    static long MeasureDirectory(IntPtr anchor,IntPtr current,ulong id,uint volume,ulong rootId,string root,int depth,HashSet<ulong> seen,Action<DiskEntry> beforeOpen,Action<ulong> deleted,Action<DiskEntry> afterOpen) {
        if(depth>128)throw new SafetyStop("DIRECTORY_DEPTH_LIMIT");
        if(!ScopedDirectory(current,volume,id,root,id==rootId)){deleted(id);return 0;}
        List<DiskEntry> rows;
        try{rows=DirectoryRows(current);}
        catch(Win32Exception) {
            if(!ScopedDirectory(current,volume,id,root,id==rootId)){deleted(id);return 0;}
            throw;
        }
        long total=0;
        if(!ScopedDirectory(current,volume,id,root,id==rootId)){deleted(id);return 0;}
        foreach(var entry in rows) {
            if((entry.attributes&0x10)==0){total=checked(total+entry.bytes);continue;}
            if(!seen.Add(entry.id))continue;
            if(seen.Count>65536)throw new SafetyStop("DIRECTORY_ID_COUNT_LIMIT");
            if(beforeOpen!=null)beforeOpen(entry);
            int error;IntPtr child=OpenChildDirectoryId(anchor,entry.id,out error);
            if(child==new IntPtr(-1)) {
                ConfirmMissingDirectory(anchor,current,id,entry.id,volume,rootId,root,error);
                deleted(entry.id);continue;
            }
            try {
                if(afterOpen!=null)afterOpen(entry);
                total=checked(total+MeasureDirectory(anchor,child,entry.id,volume,rootId,root,depth+1,seen,beforeOpen,deleted,afterOpen));
            }finally{CloseHandle(child);}
        }
        ScopedDirectory(current,volume,id,root,id==rootId);return total;
    }
    internal static long MeasureLocalTree(string root,Action<DiskEntry> beforeOpen,Action<ulong> deleted,Action<DiskEntry> afterOpen=null) {
        Canonical(root);
        if(Path.GetPathRoot(root)==root||new DriveInfo(Path.GetPathRoot(root)).DriveFormat!="NTFS")throw new SafetyStop("OWNED_LOCAL_NTFS_REQUIRED");
        if(Marshal.SizeOf(typeof(FileIdentityNative))!=52||Marshal.SizeOf(typeof(FileIdDescriptor))!=24)throw new SafetyStop("DIRECTORY_NATIVE_LAYOUT");
        var security=new Security{length=Marshal.SizeOf(typeof(Security)),inherit=false};
        IntPtr anchor=CreateFile(root,0x81,7,ref security,3,0x02200000,IntPtr.Zero);
        Require(anchor!=new IntPtr(-1),"open owned directory anchor");
        try {
            var origin=FileIdentity(anchor);ulong rootId=FileId(origin);
            ScopedDirectory(anchor,origin.volume,rootId,root,true);
            var seen=new HashSet<ulong>();seen.Add(rootId);
            long total=MeasureDirectory(anchor,anchor,rootId,origin.volume,rootId,root,0,seen,beforeOpen,deleted,afterOpen);
            ScopedDirectory(anchor,origin.volume,rootId,root,true);return total;
        }finally{CloseHandle(anchor);}
    }
    static int DiskScanRetries,DiskScansCompleted,DiskDeletedDirectoryIds,DiskDirectoryOpenRetries,DiskDirectoryNameRetries;
    // DirectoryInfo enumeration pre-populates FileInfo metadata; do not stat vanished files again.
    // Each completed walk is a non-atomic observation, not an OS-enforced quota.
    internal static long MeasureTree(string root,Func<string,FileSystemInfo[]> enumerate,Action<int,IOException> retry) {
        Canonical(root);
        for(int attempt=1;attempt<=3;attempt++) {
            try {
                long total=0;var pending=new Stack<string>();pending.Push(root);
                while(pending.Count>0) {
                    string directory=pending.Pop();Canonical(directory);
                    foreach(var entry in enumerate(directory)) {
                        FileAttributes attributes=entry.Attributes;
                        if((attributes&FileAttributes.ReparsePoint)!=0)throw new SafetyStop("REDIRECTED_DISK_ENTRY");
                        if((attributes&FileAttributes.Directory)!=0)pending.Push(entry.FullName);
                        else {
                            var file=entry as FileInfo;
                            if(file==null)throw new SafetyStop("UNKNOWN_DISK_ENTRY_TYPE");
                            total=checked(total+file.Length);
                        }
                    }
                }
                return total;
            }catch(IOException error) {
                int code=error.HResult&0xffff;
                if(!((error is FileNotFoundException||error is DirectoryNotFoundException)&&(code==2||code==3)))throw;
                // Never turn an absent owned root or persistent failure into a zero-byte success.
                Canonical(root);
                if(attempt==3)throw new SafetyStop("DISK_SNAPSHOT_UNSTABLE");
                retry(attempt,error);Thread.Sleep(10);
            }
        }
        throw new SafetyStop("DISK_SNAPSHOT_UNSTABLE");
    }
    static long Size(string root) {
        long total;
        if(root==@"C:\BuildWork")total=MeasureLocalTree(root,null,delegate(ulong id){DiskDeletedDirectoryIds++;Log(new{operation="disk_directory_id_gone",root=root,file_id=id});});
        else total=MeasureTree(root,path=>new DirectoryInfo(path).GetFileSystemInfos(),delegate(int attempt,IOException error) {
            DiskScanRetries++;Log(new{operation="disk_scan_retry",root=root,attempt=attempt,hresult=error.HResult});
        });
        DiskScansCompleted++;return total;
    }
    // Inspect every character without retaining an arbitrarily long task-graph
    // line. Only an unfinished anchored download prefix is buffered (<=11 chars).
    internal sealed class DownloadLogScanner {
        int phase;string token=""; // leading whitespace / word / space / scheme / other
        readonly Decoder decoder=new UTF8Encoding(false,true).GetDecoder();
        readonly char[] characters=new char[65537];
        internal int BufferedCharacters {get{return token.Length;}}
        internal void Feed(string text) {
            foreach(char value in text) {
                if(value=='\n'){phase=0;token="";continue;}
                if(phase==4)continue;
                if(phase==0){if(Char.IsWhiteSpace(value))continue;phase=1;}
                if(phase==1) {
                    if(Char.IsWhiteSpace(value)&&(token.Equals("Download",StringComparison.OrdinalIgnoreCase)||token.Equals("Downloading",StringComparison.OrdinalIgnoreCase))){phase=2;token="";continue;}
                    string next=token+value;
                    if("Downloading".StartsWith(next,StringComparison.OrdinalIgnoreCase))token=next;
                    else{phase=4;token="";}
                    continue;
                }
                if(phase==2){if(Char.IsWhiteSpace(value))continue;phase=3;}
                string scheme=token+value;
                if(scheme.Equals("http://",StringComparison.OrdinalIgnoreCase)||scheme.Equals("https://",StringComparison.OrdinalIgnoreCase))throw new SafetyStop("DOWNLOAD_LOG_SIGNAL");
                if("http://".StartsWith(scheme,StringComparison.OrdinalIgnoreCase)||"https://".StartsWith(scheme,StringComparison.OrdinalIgnoreCase))token=scheme;
                else{phase=4;token="";}
            }
        }
        internal void FeedBytes(byte[] bytes,int count,bool final) {
            if(count<0||count>65536||count>bytes.Length)throw new InvalidDataException("Diagnostic log chunk size");
            int length=decoder.GetChars(bytes,0,count,characters,0,final);
            Feed(new string(characters,0,length));
        }
    }
    static Dictionary<string,long> LogOffsets=new Dictionary<string,long>();
    static Dictionary<string,DownloadLogScanner> LogScanners=new Dictionary<string,DownloadLogScanner>();
    static void BoundDiskAndDownloads(bool final=false) {
        if(Size(@"C:\BuildWork")>4L*1024*1024*1024||Size(Output)>512L*1024*1024)throw new SafetyStop("OWNED_DISK_BUDGET");
        foreach(string name in new[]{"tool.stdout","tool.stderr"}){
            string path=Output+"\\"+name;if(!File.Exists(path))continue;
            long offset=LogOffsets.ContainsKey(name)?LogOffsets[name]:0;
            using(var f=new FileStream(path,FileMode.Open,FileAccess.Read,FileShare.ReadWrite)) {
                if(f.Length<offset)throw new SafetyStop("DIAGNOSTIC_LOG_TRUNCATED");
                if(f.Length-offset>16*1024*1024)throw new SafetyStop("DIAGNOSTIC_BACKLOG_LIMIT");
                f.Position=offset;byte[] bytes=new byte[65536];int read;
                if(!LogScanners.ContainsKey(name))LogScanners[name]=new DownloadLogScanner();
                while((read=f.Read(bytes,0,bytes.Length))>0){
                    LogScanners[name].FeedBytes(bytes,read,false);LogOffsets[name]=f.Position;
                }
                if(final)LogScanners[name].FeedBytes(new byte[0],0,true);
            }
        }
    }
    static object Supervise(Dictionary<string,object> m) {
        IntPtr job=IntPtr.Zero;Child root=new Child();var known=new Dictionary<uint,Bound>();int samples=0;string stop=null;uint? exit=null;bool empty=false,exited=false;Timer watchdog=null;int watchdogStop=0;long heartbeat=0;var time=Stopwatch.StartNew();
        try {
            job=CreateJobObject(IntPtr.Zero,null);Require(job!=IntPtr.Zero,"CreateJobObject");var limits=new Extended();limits.basic.flags=0x2000;
            Require(Marshal.SizeOf(limits)==144,"x64 job layout");Require(SetInformationJobObject(job,9,ref limits,144),"kill-on-close");
            Before("root_create_attempt");RootCreateAttempted=true;root=Spawn(m);
            Require(AssignProcessToJobObject(job,root.process),"assign suspended root");known.Add(root.pid,new Bound{pid=root.pid,handle=root.process,birth=Birth(root.process)});Sample(job,known);samples++;
            time.Restart();Interlocked.Exchange(ref heartbeat,0);
            watchdog=new Timer(delegate {
                long elapsed=time.ElapsedMilliseconds;
                if(elapsed>=90000||elapsed-Interlocked.Read(ref heartbeat)>15000){
                    Interlocked.CompareExchange(ref watchdogStop,elapsed>=90000?1:2,0);
                    TerminateJobObject(job,81);
                }
            },null,250,250);
            Require(ResumeThread(root.thread)!=UInt32.MaxValue,"resume owned diagnostic");long diskAt=-1000,hashAt=-3000;
            while(true) {
                Sample(job,known);samples++;
                if(Interlocked.CompareExchange(ref watchdogStop,0,0)!=0)throw new SafetyStop("INDEPENDENT_WATCHDOG_STOP");
                if(time.ElapsedMilliseconds>90000)throw new SafetyStop("HARD_TIMEOUT");
                if(time.ElapsedMilliseconds-diskAt>=1000){BoundDiskAndDownloads();diskAt=time.ElapsedMilliseconds;}
                if(time.ElapsedMilliseconds-hashAt>=3000){SourcePins(m);hashAt=time.ElapsedMilliseconds;}
                if(WaitForSingleObject(root.process,0)==0){uint code;Require(GetExitCodeProcess(root.process,out code),"root exit code");exit=code;break;}
                Interlocked.Exchange(ref heartbeat,time.ElapsedMilliseconds);Thread.Sleep(100);
            }
            SourcePins(m);BoundDiskAndDownloads(true);
        }catch(Exception problem){stop=problem.GetType().FullName+": "+problem.Message;Log(new{operation="safety_stop",reason=stop,hresult=problem.HResult});}
        finally {
            if(watchdog!=null){using(var done=new ManualResetEvent(false)){watchdog.Dispose(done);done.WaitOne();}}
            if(watchdogStop!=0)stop=(stop??"")+"; WATCHDOG_"+(watchdogStop==1?"HARD_TIMEOUT":"OBSERVER_HEARTBEAT");
            try {
                if(job!=IntPtr.Zero){Require(TerminateJobObject(job,79),"terminate only owned job");var wait=Stopwatch.StartNew();while(Members(job).Length!=0&&wait.ElapsedMilliseconds<10000)Thread.Sleep(20);empty=Members(job).Length==0;}
            }catch(Exception cleanup){stop=(stop??"")+"; CLEANUP: "+cleanup.Message;empty=false;}
            finally {
                if(job!=IntPtr.Zero)CloseHandle(job);
                exited=true;foreach(var b in known.Values)if(WaitForSingleObject(b.handle,5000)!=0)exited=false;
                if(root.process!=IntPtr.Zero&&!known.ContainsKey(root.pid)){if(WaitForSingleObject(root.process,0)!=0)TerminateProcess(root.process,80);if(WaitForSingleObject(root.process,5000)!=0)exited=false;CloseHandle(root.process);}
                foreach(var b in known.Values)CloseHandle(b.handle);if(root.thread!=IntPtr.Zero)CloseHandle(root.thread);
            }
        }
        return new {root_pid=root.pid,root_exit=exit,stop_reason=stop,successful_samples=samples,bound_members=known.Count,job_final_empty=empty,all_bound_handles_exited=exited,sampling_non_atomic=true,udp_destination="UNKNOWN",disk_limit_sampled=true,transient_disk_overshoot_possible=true,disk_scan_retries=DiskScanRetries,disk_scans_completed=DiskScansCompleted,disk_deleted_directory_ids=DiskDeletedDirectoryIds,disk_directory_open_retries=DiskDirectoryOpenRetries,disk_directory_name_retries=DiskDirectoryNameRetries,watchdog_stop=watchdogStop};
    }
    static int Main(string[] args) {
        Json.MaxJsonLength=64*1024*1024;
        if(Environment.UserName!="WDAGUtilityAccount"||args.Length!=1||!System.Text.RegularExpressions.Regex.IsMatch(args[0],"\\A[0-9a-f]{32}\\z"))return 20;
        if(!String.Equals(Process.GetCurrentProcess().MainModule.FileName,Self,StringComparison.OrdinalIgnoreCase))return 21;
        var m=Json.Deserialize<Dictionary<string,object>>(File.ReadAllText(@"C:\Probe\manifest.json"));
        if((string)m["nonce"]!=args[0]||Hash(Self)!=(string)m["binary_sha256"])return 22;
        if((string)m["mode"]!="dart-version"||(string)m["executable"]!=@"C:\Inputs\DartSdk\bin\dart.exe"||(string)m["command_line"]!=@"C:\Inputs\DartSdk\bin\dart.exe --version"||(string)m["cwd"]!=@"C:\BuildWork\Home")return 23;
        foreach(var row in Rows(m["images"]))Images.Add((string)row["path"],(string)row["sha256"]);
        object proof=null;string failure=null;int inputs=0;
        using(Sink=new StreamWriter(new FileStream(Output+@"\samples.jsonl",FileMode.CreateNew,FileAccess.Write),new UTF8Encoding(false))) {
            try {inputs=PrepareInputs(m);SourcePins(m);proof=Supervise(m);}catch(Exception error){failure=error.GetType().FullName+": "+error.Message;Log(new{operation="bootstrap_failure",failure=failure});}
            Write("result",new{schema=1,kind="native-tool-probe",nonce=args[0],binary_sha256=Hash(Self),mode=m["mode"],clr_version=Environment.Version.ToString(),kernel_file_version=FileVersionInfo.GetVersionInfo(Path.Combine(Environment.SystemDirectory,"kernel32.dll")).FileVersion,input_files=inputs,proof=proof,failure=failure,native_tool_root_attempts=RootCreateAttempted?1:0,gradle_root_attempts=0,apk_builds=0,G2=false,tool_images_pinned=true});
        }
        Process.Start(new ProcessStartInfo(Path.Combine(Environment.SystemDirectory,"shutdown.exe"),"/s /t 3"){UseShellExecute=false,CreateNoWindow=true});return failure==null?0:1;
    }
}
