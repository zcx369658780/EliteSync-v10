// Default: read-only inventory of one existing guest OS image.
// Explicit --synthetic-console: verify that image, then allocate/release a console.
// Get-AuthenticodeSignature (including catalog signatures) is hosted in-process.
// https://learn.microsoft.com/powershell/module/microsoft.powershell.security/get-authenticodesignature
using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading;
using System.Web.Script.Serialization;

class ConsoleImageInventory {
    const string Target=@"C:\Windows\System32\conhost.exe";
    const string AssemblyName="System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35";
    const string Output=@"C:\ProbeOutput\console-image.json";
    const string ConsoleBaseline="c86146188b78e484f32cc29e2331689659943b47689a85570342044f499938ac";
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool AllocConsole();
    [DllImport("kernel32.dll",SetLastError=true)] static extern bool FreeConsole();
    [DllImport("kernel32.dll")] static extern IntPtr GetConsoleWindow();
    [StructLayout(LayoutKind.Sequential)] struct Identity {
        public uint attributes,creationLow,creationHigh,accessLow,accessHigh,writeLow,writeHigh,volume,sizeHigh,sizeLow,links,indexHigh,indexLow;
    }
    [DllImport("kernel32.dll",SetLastError=true)]
    static extern bool GetFileInformationByHandle(IntPtr handle,out Identity identity);
    static Identity Info(FileStream file) {
        Identity id;
        if(!GetFileInformationByHandle(file.SafeFileHandle.DangerousGetHandle(),out id))throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
        if((id.attributes&0x410)!=0||id.links<1)throw new InvalidDataException("Nonregular or redirected OS file");
        return id;
    }
    static bool Same(Identity a,Identity b) {
        return a.volume==b.volume&&a.indexHigh==b.indexHigh&&a.indexLow==b.indexLow&&a.sizeHigh==b.sizeHigh&&a.sizeLow==b.sizeLow&&a.links==b.links&&a.writeHigh==b.writeHigh&&a.writeLow==b.writeLow;
    }
    static void Canonical(string path) {
        if(!Path.IsPathRooted(path)||Path.GetFullPath(path)!=path)throw new InvalidDataException("Noncanonical OS path");
        for(string current=path;!String.IsNullOrEmpty(current);current=Path.GetDirectoryName(current)) {
            if((File.GetAttributes(current)&FileAttributes.ReparsePoint)!=0)throw new InvalidDataException("Redirected OS path");
            if(current==Path.GetPathRoot(current))break;
        }
    }
    static string Hash(FileStream file,long cap) {
        if(file.Length<1||file.Length>cap)throw new InvalidDataException("OS file byte cap");
        file.Position=0;
        using(var sha=SHA256.Create())return BitConverter.ToString(sha.ComputeHash(file)).Replace("-","").ToLowerInvariant();
    }
    static object Property(object item,string name) {
        var property=item.GetType().GetProperty(name);
        if(property==null)throw new InvalidDataException("Missing signature property "+name);
        return property.GetValue(item,null);
    }
    static object Signature(Assembly automation,string path) {
        var type=automation.GetType("System.Management.Automation.PowerShell",true);
        object shell=type.GetMethod("Create",Type.EmptyTypes).Invoke(null,null);
        try {
            type.GetMethod("AddCommand",new[]{typeof(string)}).Invoke(shell,new object[]{"Get-AuthenticodeSignature"});
            type.GetMethod("AddParameter",new[]{typeof(string),typeof(object)}).Invoke(shell,new object[]{"LiteralPath",path});
            var invoke=type.GetMethods().Single(m=>m.Name=="Invoke"&&!m.IsGenericMethod&&m.GetParameters().Length==0);
            var rows=((IEnumerable)invoke.Invoke(shell,null)).Cast<object>().ToArray();
            if((bool)Property(shell,"HadErrors")||rows.Length!=1)throw new InvalidDataException("OS signature query failed");
            object value=Property(rows[0],"BaseObject");
            var certificate=Property(value,"SignerCertificate") as X509Certificate2;
            return new {status=Property(value,"Status").ToString(),subject=certificate==null?null:certificate.Subject,
                signature_type=Property(value,"SignatureType").ToString(),is_os_binary=(bool)Property(value,"IsOSBinary")};
        }finally{((IDisposable)shell).Dispose();}
    }
    static void Write(string path,object value) {
        byte[] bytes=new UTF8Encoding(false).GetBytes(new JavaScriptSerializer().Serialize(value));
        if(bytes.Length>16384)throw new InvalidDataException("Inventory output cap");
        using(var file=new FileStream(path,FileMode.CreateNew,FileAccess.Write)){file.Write(bytes,0,bytes.Length);file.Flush(true);}
    }
    internal static byte[] FailureBytes(string message) {
        var characters=message.ToCharArray(0,Math.Min(message.Length,8192));
        var bytes=new byte[16384];int charsUsed,bytesUsed;bool completed;
        new UTF8Encoding(false).GetEncoder().Convert(characters,0,characters.Length,bytes,0,bytes.Length,true,out charsUsed,out bytesUsed,out completed);
        Array.Resize(ref bytes,bytesUsed);return bytes;
    }
    internal static void RequireWindowsSignature(object value) {
        string subject=Property(value,"subject") as string;
        string kind=Property(value,"signature_type") as string;
        if((string)Property(value,"status")!="Valid"||!(bool)Property(value,"is_os_binary")
                ||subject==null||!subject.Split(',').Any(s=>s.Trim()=="CN=Microsoft Windows")
                ||(kind!="Catalog"&&kind!="Authenticode"))throw new InvalidDataException("Fresh Windows OS signature required before console fixture");
    }
    static int Main(string[] args) {
        try {
            bool synthetic=args.Length==1&&args[0]=="--synthetic-console";
            if(args.Length>1||(args.Length==1&&!synthetic))return 22;
            if(Environment.UserName!="WDAGUtilityAccount")return 20;
            if(Process.GetCurrentProcess().MainModule.FileName!=@"C:\Probe\ConsoleImageInventory.exe")return 21;
            Canonical(Target);
            var automation=Assembly.Load(AssemblyName);
            if(automation.FullName!=AssemblyName)throw new InvalidDataException("Unexpected existing automation assembly");
            string location=automation.Location;
            Canonical(location);
            if(!location.StartsWith(@"C:\Windows\",StringComparison.OrdinalIgnoreCase))throw new InvalidDataException("Automation assembly outside guest Windows");
            // Deny write/delete sharing while reading the image and asking Windows
            // to verify its existing embedded or catalog signature. No installation.
            using(var file=new FileStream(Target,FileMode.Open,FileAccess.Read,FileShare.Read)) {
                var before=Info(file);long bytes=file.Length;
                string sha=Hash(file,16L*1024*1024);
                object signature=Signature(automation,Target);
                object assemblySignature=Signature(automation,location);
                var after=Info(file);
                Canonical(Target);
                bool stable=Same(before,after)&&file.Length==bytes&&Hash(file,16L*1024*1024)==sha;
                if(!stable)throw new InvalidDataException("Guest OS image identity drift");
                Write(Output,new {schema=1,path=Target,bytes=bytes,sha256=sha,
                    file_id=new {volume=before.volume,index=(((ulong)before.indexHigh<<32)|before.indexLow).ToString()},
                    hard_links=before.links,file_version=FileVersionInfo.GetVersionInfo(Target).FileVersion,identity_stable=stable,
                    signature=signature,automation_assembly=new {full_name=automation.FullName,under_windows=true,signature=assemblySignature}});
                if(synthetic) {
                    if(sha!=ConsoleBaseline)throw new InvalidDataException("Guest image differs from the fixed inventoried baseline");
                    RequireWindowsSignature(signature);RequireWindowsSignature(assemblySignature);
                    if(GetConsoleWindow()!=IntPtr.Zero)throw new InvalidDataException("Synthetic fixture must start without a console");
                    if(!AllocConsole())throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error(),"Synthetic AllocConsole");
                    bool released=false;
                    try {Thread.Sleep(2000);}finally{released=FreeConsole();}
                    if(!released)throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error(),"Synthetic FreeConsole");
                    if(!Same(before,Info(file))||Hash(file,16L*1024*1024)!=ConsoleBaseline)throw new InvalidDataException("OS image drift during synthetic console");
                    Write(@"C:\ProbeOutput\console-synthetic.json",new{schema=1,allocated=true,released=true,pre_execution_identity_verified=true,
                        expected_image_sha256=ConsoleBaseline,hold_ms=2000,root_pid=Process.GetCurrentProcess().Id});
                }
            }
            return 0;
        }catch(Exception error) {
            using(var file=new FileStream(@"C:\ProbeOutput\console-image-failure.txt",FileMode.CreateNew,FileAccess.Write)) {
                byte[] bytes=FailureBytes(error.ToString());file.Write(bytes,0,bytes.Length);file.Flush(true);
            }
            return 1;
        }
    }
}
