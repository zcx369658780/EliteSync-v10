// Guest-only wrapper. Policy tests must select their own Main, never this one.
class NativeRoleGuestWrapper {
    const string Self=@"C:\Probe\NativeRoleProbe.exe";
    const string ExpectedNonce="__EXPECTED_NONCE__";
    [StructLayout(LayoutKind.Sequential,Pack=1)] struct Privilege {public uint count;public long luid;public uint attributes;}
    [DllImport("advapi32.dll",SetLastError=true)] static extern bool OpenProcessToken(IntPtr process,uint access,out IntPtr token);
    [DllImport("advapi32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern bool LookupPrivilegeValue(string system,string name,out long luid);
    [DllImport("advapi32.dll",SetLastError=true)] static extern bool AdjustTokenPrivileges(IntPtr token,bool disable,ref Privilege state,uint size,IntPtr previous,IntPtr returned);
    [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr handle);
    [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern IntPtr CreateFile(string path,uint access,uint share,IntPtr security,uint creation,uint flags,IntPtr template);
    [DllImport("user32.dll",SetLastError=true)] static extern bool ExitWindowsEx(uint flags,uint reason);
    internal static bool BindingMatches(string user,string image,string[] args) {
        return user=="WDAGUtilityAccount"&&args.Length==1&&args[0]==ExpectedNonce&&
            System.Text.RegularExpressions.Regex.IsMatch(args[0],"\\A[0-9a-f]{32}\\z")&&
            String.Equals(image,Self,StringComparison.OrdinalIgnoreCase);
    }
    static bool Owned(string[] args) {return BindingMatches(Environment.UserName,Process.GetCurrentProcess().MainModule.FileName,args);}
    static void ShutdownOwnedGuest(string[] args) {
        if(!Owned(args))return;
        IntPtr token=IntPtr.Zero;
        try {
            long luid;
            if(!OpenProcessToken(Process.GetCurrentProcess().Handle,0x28,out token)||!LookupPrivilegeValue(null,"SeShutdownPrivilege",out luid))return;
            var privilege=new Privilege {count=1,luid=luid,attributes=2};
            if(AdjustTokenPrivileges(token,false,ref privilege,0,IntPtr.Zero,IntPtr.Zero)&&Marshal.GetLastWin32Error()==0)
                ExitWindowsEx(0x8|0x10,0x80040000);
        } finally {if(token!=IntPtr.Zero)CloseHandle(token);}
    }
    static void Denied(string path,uint access,bool directory) {
        IntPtr handle=CreateFile(path,access,7,IntPtr.Zero,3,directory?0x02000000u:0u,IntPtr.Zero);
        int error=Marshal.GetLastWin32Error();
        if(handle!=new IntPtr(-1)){CloseHandle(handle);throw new IOException("READONLY_PERMISSION_OPEN_SUCCEEDED");}
        if(error!=5)throw new IOException("READONLY_DENIAL_NOT_ERROR5: "+error);
    }
    static void Preflight(JavaScriptSerializer json,Dictionary<string,object> manifest,string nonce) {
        int files=0,dirs=0;
        foreach(Dictionary<string,object> row in (System.Collections.IEnumerable)manifest["inputs"])
            foreach(uint access in new uint[]{0x40000000,0x2,0x4,0x10000,0x40000,0x80000}){Denied((string)row["path"],access,false);files++;}
        foreach(string root in new[]{@"C:\Inputs\PrivateFlutter",@"C:\Inputs\AndroidSdk\build-tools\36.0.0",@"C:\Inputs\AndroidSdk\cmake\3.22.1",@"C:\Inputs\AndroidSdk\ndk\28.2.13676358",@"C:\Inputs\Jdk"})
            foreach(uint access in new uint[]{0x2,0x4,0x40}){Denied(root,access,true);dirs++;}
        bool network=System.Net.NetworkInformation.NetworkInterface.GetAllNetworkInterfaces().All(n=>n.NetworkInterfaceType==System.Net.NetworkInformation.NetworkInterfaceType.Loopback||n.OperationalStatus!=System.Net.NetworkInformation.OperationalStatus.Up);
        if(!network||files!=252||dirs!=15)throw new IOException("PREFLIGHT_MATRIX_OR_NETWORK_REJECTED");
        string canary=@"C:\ProbeOutput\preflight-"+nonce+".tmp";byte[] payload=Encoding.ASCII.GetBytes(nonce);
        OwnedCanary(canary,payload);
        var result=new{kind="native-cmake-preflight",nonce=nonce,username=Environment.UserName,file_denials=files,directory_denials=dirs,output_canary_write_read_delete=true,network_no_active_adapter=network,SDK_starts=0,G2=false};
        Publish(@"C:\ProbeOutput\guest-preflight.json",Encoding.UTF8.GetBytes(json.Serialize(result)));
    }
    internal static void OwnedCanary(string path,byte[] payload) {
        bool created=false;
        try {
            using(var file=new FileStream(path,FileMode.CreateNew,FileAccess.Write,FileShare.None)){created=true;file.Write(payload,0,payload.Length);file.Flush(true);}
            if(!File.ReadAllBytes(path).SequenceEqual(payload))throw new IOException("OUTPUT_CANARY_DRIFT");
        } finally {if(created&&File.Exists(path))File.Delete(path);}
    }
    internal static void Publish(string path,byte[] payload,Action afterFlush=null) {
        string pending=path+".pending";
        using(var file=new FileStream(pending,FileMode.CreateNew,FileAccess.Write)){
            file.Write(payload,0,payload.Length);file.Flush(true);if(afterFlush!=null)afterFlush();
        }
        File.Move(pending,path);
    }
    static int Main(string[] args) {
        if(!Owned(args))return 30;
        var json=new JavaScriptSerializer();json.MaxJsonLength=4*1024*1024;
        using(var watchdog=new Timer(delegate {
            try {Publish(@"C:\ProbeOutput\guest-watchdog.json",Encoding.UTF8.GetBytes("{\"stop\":\"GUEST_OVERALL_90S\"}"));}
            finally {try{ShutdownOwnedGuest(args);}finally{Environment.Exit(83);}}
        },null,90000,Timeout.Infinite)) {
            return Guarded(delegate {
                var manifest=json.Deserialize<Dictionary<string,object>>(File.ReadAllText(@"C:\Probe\manifest.json"));
                string digest;
                using(var file=File.OpenRead(Self))using(var hash=SHA256.Create())digest=BitConverter.ToString(hash.ComputeHash(file)).Replace("-","").ToLowerInvariant();
                if((string)manifest["nonce"]!=args[0]||(string)manifest["binary_sha256"]!=digest||
                   (string)manifest["role"]!="cmake"||!(manifest["runtime_authorized"] is bool)||!(bool)manifest["runtime_authorized"])throw new InvalidDataException("GUEST_MANIFEST_AUTHORITY_DRIFT");
                NativeRolePolicy.Validate(manifest);
                Preflight(json,manifest,args[0]);
                int code=GradleDiagnostic.RunNativeRole(args);
                if(code!=0&&!File.Exists(@"C:\ProbeOutput\result.json"))Failure(json,args[0],"CORE_EARLY_EXIT_"+code);
                return code;
            },delegate(Exception error){Failure(json,args[0],error.GetType().FullName+": "+error.Message);},delegate {
                using(var done=new ManualResetEvent(false)){watchdog.Dispose(done);done.WaitOne();}
                ShutdownOwnedGuest(args);
            });
        }
    }
    internal static int Guarded(Func<int> action,Action<Exception> failed,Action cleanup) {
        try {return action();}
        catch(Exception error){failed(error);return 32;}
        finally {cleanup();}
    }
    static void Failure(JavaScriptSerializer json,string nonce,string reason) {
        Publish(@"C:\ProbeOutput\guest-wrapper-failure.json",Encoding.UTF8.GetBytes(json.Serialize(new{kind="guest-wrapper-failure",nonce=nonce,reason=reason})));
    }
}
