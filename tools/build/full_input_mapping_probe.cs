// Mapping-only fixture. No SDK or child process is started. Never run on host.
using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net.NetworkInformation;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web.Script.Serialization;
using Microsoft.Win32.SafeHandles;

class FullInputMappingProbe
{
    const string Self = @"C:\Probe\MappingProbe.exe", Output = @"C:\ProbeOutput";
    const uint EWX_POWEROFF = 0x8, EWX_FORCEIFHUNG = 0x10;
    static readonly JavaScriptSerializer Json = new JavaScriptSerializer { MaxJsonLength = 4 * 1024 * 1024 };
    [StructLayout(LayoutKind.Sequential)] struct FileInfo {
        public uint attributes; public System.Runtime.InteropServices.ComTypes.FILETIME created, accessed, modified;
        public uint volume, sizeHigh, sizeLow, links, indexHigh, indexLow;
    }
    [StructLayout(LayoutKind.Sequential, Pack=1)] struct Privilege { public uint count; public long luid; public uint attributes; }
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    static extern SafeFileHandle CreateFile(string path, uint access, uint share, IntPtr security, uint creation, uint flags, IntPtr template);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool GetFileInformationByHandle(SafeFileHandle handle, out FileInfo info);
    [DllImport("advapi32.dll", SetLastError=true)] static extern bool OpenProcessToken(IntPtr process, uint access, out IntPtr token);
    [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern bool LookupPrivilegeValue(string system, string name, out long luid);
    [DllImport("advapi32.dll", SetLastError=true)] static extern bool AdjustTokenPrivileges(IntPtr token, bool disable, ref Privilege state, uint size, IntPtr previous, IntPtr returned);
    [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr handle);
    [DllImport("user32.dll", SetLastError=true)] static extern bool ExitWindowsEx(uint flags, uint reason);

    static bool Same(FileInfo a, FileInfo b) {
        return a.volume==b.volume && a.indexHigh==b.indexHigh && a.indexLow==b.indexLow &&
            a.sizeHigh==b.sizeHigh && a.sizeLow==b.sizeLow && a.links==b.links && a.attributes==b.attributes &&
            a.modified.dwHighDateTime==b.modified.dwHighDateTime && a.modified.dwLowDateTime==b.modified.dwLowDateTime;
    }
    static string Hash(string path) {
        using(var stream=File.OpenRead(path)) using(var sha=SHA256.Create())
            return BitConverter.ToString(sha.ComputeHash(stream)).Replace("-", "").ToLowerInvariant();
    }
    static void ShutdownGuest() {
        // Main reaches this method only after the WDAG/self/nonce guards.
        if(Environment.UserName!="WDAGUtilityAccount" || !String.Equals(Process.GetCurrentProcess().MainModule.FileName,Self,StringComparison.OrdinalIgnoreCase)) return;
        IntPtr token=IntPtr.Zero;
        try {
            long luid;
            if(!OpenProcessToken(Process.GetCurrentProcess().Handle,0x28,out token) || !LookupPrivilegeValue(null,"SeShutdownPrivilege",out luid)) return;
            var privilege=new Privilege {count=1,luid=luid,attributes=2};
            if(AdjustTokenPrivileges(token,false,ref privilege,0,IntPtr.Zero,IntPtr.Zero) && Marshal.GetLastWin32Error()==0)
                ExitWindowsEx(EWX_POWEROFF | EWX_FORCEIFHUNG,0x80040000);
        } finally { if(token!=IntPtr.Zero) CloseHandle(token); }
    }
    static object ReadAnchor(Dictionary<string,object> row) {
        string path=(string)row["guest_file"];
        long expected=Convert.ToInt64(row["bytes"]), total=0;
        if(expected<0 || expected>262144) throw new InvalidOperationException("anchor bound");
        if((File.GetAttributes(path)&FileAttributes.ReparsePoint)!=0) throw new InvalidOperationException("anchor reparse");
        using(var input=new FileStream(path,FileMode.Open,FileAccess.Read,FileShare.Read)) {
            FileInfo before,after;
            if(!GetFileInformationByHandle(input.SafeFileHandle,out before) || before.links!=1 || (before.attributes&0x410)!=0)
                throw new InvalidOperationException("anchor shape");
            if((((long)before.sizeHigh<<32)|before.sizeLow)!=expected) throw new InvalidOperationException("anchor size");
            using(var sha=SHA256.Create()) {
                byte[] buffer=new byte[65536]; int count;
                while((count=input.Read(buffer,0,buffer.Length))>0) {
                    total+=count; if(total>expected) throw new InvalidOperationException("anchor grew");
                    sha.TransformBlock(buffer,0,count,buffer,0);
                }
                sha.TransformFinalBlock(new byte[0],0,0);
                string digest=BitConverter.ToString(sha.Hash).Replace("-", "").ToLowerInvariant();
                if(total!=expected || digest!=(string)row["sha256"] || !GetFileInformationByHandle(input.SafeFileHandle,out after) || !Same(before,after))
                    throw new InvalidOperationException("anchor identity/content drift");
                return new {role=row["role"],path=path,bytes=total,sha256=digest,identity_stable=true};
            }
        }
    }
    static object Denial(string role,string path,uint access,bool directory) {
        using(var handle=CreateFile(path,access,7,IntPtr.Zero,3,directory?0x02000000u:0u,IntPtr.Zero)) {
            int error=handle.IsInvalid?Marshal.GetLastWin32Error():0;
            return new {role=role,path=path,access=access,directory=directory,succeeded=!handle.IsInvalid,native_error=error};
        }
    }
    static int Run(string[] args) {
        if(Environment.UserName!="WDAGUtilityAccount" || args.Length!=1 || !System.Text.RegularExpressions.Regex.IsMatch(args[0],"\\A[0-9a-f]{32}\\z")) return 20;
        if(!String.Equals(Process.GetCurrentProcess().MainModule.FileName,Self,StringComparison.OrdinalIgnoreCase)) return 21;
        var manifest=Json.Deserialize<Dictionary<string,object>>(File.ReadAllText(@"C:\Probe\manifest.json"));
        if((string)manifest["nonce"]!=args[0] || (string)manifest["binary_sha256"]!=Hash(Self) ||
            (string)manifest["scope"]!="v1015-full-input-mapping-qualification-20261104" ||
            !(bool)manifest["mapping_fixture_only"] || (bool)manifest["sdk_execution_allowed"]) return 22;
        var reads=new List<object>(); var denials=new List<object>(); var writes=new List<object>();
        string failure=null; bool networkQuiet=false;
        {
            try {
                foreach(object value in (IEnumerable)manifest["mappings"]) {
                    var row=(Dictionary<string,object>)value;
                    reads.Add(ReadAnchor(row));
                    if((bool)row["readonly"]) {
                        string role=(string)row["role"], path=(string)row["guest_file"];
                        foreach(uint access in new uint[]{0x40000000,0x2,0x4,0x10000,0x40000,0x80000}) denials.Add(Denial(role,path,access,false));
                        foreach(uint access in new uint[]{0x2,0x4,0x40}) denials.Add(Denial(role,(string)row["guest"],access,true));
                    }
                }
                foreach(object value in denials) {
                    var d=Json.Deserialize<Dictionary<string,object>>(Json.Serialize(value));
                    if((bool)d["succeeded"] || Convert.ToInt32(d["native_error"])!=5) throw new InvalidOperationException("readonly access not denied with error 5");
                }
                foreach(object value in (IEnumerable)manifest["mappings"]) {
                    var row=(Dictionary<string,object>)value;
                    if((bool)row["readonly"]) continue;
                    string path=Path.Combine((string)row["guest"],".elitesync-mapping-"+args[0]+".tmp");
                    byte[] bytes=Encoding.UTF8.GetBytes("owned-mapping-fixture:"+args[0]);
                    using(var output=new FileStream(path,FileMode.CreateNew,FileAccess.Write,FileShare.None)) {output.Write(bytes,0,bytes.Length);output.Flush(true);}
                    if(Convert.ToBase64String(File.ReadAllBytes(path))!=Convert.ToBase64String(bytes)) throw new InvalidOperationException("private canary read");
                    File.Delete(path); if(File.Exists(path)) throw new InvalidOperationException("private canary cleanup");
                    writes.Add(new {role=row["role"],path=path,write_read_delete_ok=true});
                }
                networkQuiet=true;
                foreach(var adapter in NetworkInterface.GetAllNetworkInterfaces())
                    if(adapter.NetworkInterfaceType!=NetworkInterfaceType.Loopback && adapter.OperationalStatus==OperationalStatus.Up) networkQuiet=false;
                if(!networkQuiet) throw new InvalidOperationException("active nonloopback adapter");
            } catch(Exception error) {failure=error.GetType().FullName+": "+error.Message;}
            var result=new {schema=1,scope=manifest["scope"],nonce=args[0],username=Environment.UserName,
                binary_sha256=Hash(Self),pid=Process.GetCurrentProcess().Id,creation_utc=Process.GetCurrentProcess().StartTime.ToUniversalTime().ToString("o"),
                reads=reads,readonly_checks=denials,private_writes=writes,network_no_active_adapter=networkQuiet,failure=failure,
                kernel_file_version=FileVersionInfo.GetVersionInfo(Path.Combine(Environment.SystemDirectory,"kernel32.dll")).FileVersion,
                clr_version=Environment.Version.ToString(),sdk_starts=0,gradle_starts=0,apk_builds=0,G2=false};
            using(var output=new FileStream(Output+@"\result.pending",FileMode.CreateNew,FileAccess.Write)) {
                byte[] bytes=Encoding.UTF8.GetBytes(Json.Serialize(result));output.Write(bytes,0,bytes.Length);output.Flush(true);
            }
            File.Move(Output+@"\result.pending",Output+@"\result.json");
        }
        return failure==null?0:1;
    }
    static int Main(string[] args) {
        if(Environment.UserName!="WDAGUtilityAccount" || !String.Equals(Process.GetCurrentProcess().MainModule.FileName,Self,StringComparison.OrdinalIgnoreCase)) return 20;
        using(var timer=new Timer(delegate { ShutdownGuest(); },null,90000,Timeout.Infinite)) {
            try { return Run(args); }
            catch { return 23; }
            finally { ShutdownGuest(); }
        }
    }
}
