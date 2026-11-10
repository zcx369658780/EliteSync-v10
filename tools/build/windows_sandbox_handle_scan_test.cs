// Real read-only NTFS object enumeration tests. All mutation is inside the fresh test fixture.
using System;
using System.IO;
using System.Text;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Reflection;
using System.ComponentModel;
using System.Security.AccessControl;
using System.Security.Principal;
using System.Threading;
class HandleScanTests {
    [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)] static extern IntPtr CreateFile(string p,uint a,uint share,IntPtr sa,uint create,uint flags,IntPtr template);
    [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
    static int count;
    static void Check(bool ok,string name){if(!ok)throw new Exception(name);count++;}
    static void Malformed(byte[] bytes){try{GradleDiagnostic.ParseDirectoryPage(bytes);throw new Exception("bad page accepted");}catch(InvalidDataException){count++;}}
    static byte[] Page(string name,long size,ulong id,uint attributes=0x20){
        byte[] text=Encoding.Unicode.GetBytes(name),bytes=new byte[104+text.Length];
        Array.Copy(BitConverter.GetBytes(size),0,bytes,40,8);Array.Copy(BitConverter.GetBytes(attributes),0,bytes,56,4);
        Array.Copy(BitConverter.GetBytes(text.Length),0,bytes,60,4);Array.Copy(BitConverter.GetBytes(id),0,bytes,96,8);Array.Copy(text,0,bytes,104,text.Length);return bytes;
    }
    static string Child(string root,string name){string path=Path.Combine(root,name);if(!Path.GetFullPath(path).StartsWith(root+"\\",StringComparison.Ordinal))throw new Exception("test fixture escape");return path;}
    static string Tree(string parent,string name,int size){string root=Child(parent,name);Directory.CreateDirectory(Child(root,"pending"));File.WriteAllBytes(Child(root,"pending\\data.bin"),new byte[size]);return root;}
    static void CheckFailureControls(string root) {
        // Exercise the actual production failure classifier with a live ID:
        // API error 87/2 alone must never imply zero bytes or a deleted object.
        var flags=BindingFlags.NonPublic|BindingFlags.Static;
        var identity=typeof(GradleDiagnostic).GetMethod("FileIdentity",flags);
        var fileId=typeof(GradleDiagnostic).GetMethod("FileId",flags);
        var confirm=typeof(GradleDiagnostic).GetMethod("ConfirmMissingDirectory",flags);
        IntPtr anchor=CreateFile(root,0x81,7,IntPtr.Zero,3,0x02200000,IntPtr.Zero);
        if(anchor==new IntPtr(-1))throw new Win32Exception(Marshal.GetLastWin32Error());
        try {
            object info=identity.Invoke(null,new object[]{anchor});
            ulong rootId=(ulong)fileId.Invoke(null,new[]{info});uint volume=(uint)info.GetType().GetField("volume").GetValue(info);
            GradleDiagnostic.MeasureLocalTree(root,e=>{
                foreach(int code in new[]{2,87,5,50}) {
                    try{confirm.Invoke(null,new object[]{anchor,anchor,rootId,e.id,volume,rootId,root,code});throw new Exception("live ID error swallowed");}
                    catch(TargetInvocationException error) {
                        var native=error.InnerException as Win32Exception;
                        Check(native!=null&&native.NativeErrorCode==code,"native failure remains fatal with live child ID: "+code);
                    }
                }
            },id=>{throw new Exception("live ID classified missing");});
        }finally{CloseHandle(anchor);}
    }
    static int Main(string[] args){try{return Run(args);}catch(Exception e){Console.WriteLine("HANDLE_TEST_FAILURE: "+e.GetType().FullName+" / "+e.Message+" / native="+(e is System.ComponentModel.Win32Exception?((System.ComponentModel.Win32Exception)e).NativeErrorCode.ToString():"none"));return 1;}}
    static int Run(string[] args){
        if(args.Length!=1||!Path.IsPathRooted(args[0])||Directory.Exists(args[0]))throw new Exception("fresh absolute fixture required");
        string fixture=Path.GetFullPath(args[0]);Directory.CreateDirectory(fixture);
        var rows=GradleDiagnostic.ParseDirectoryPage(Page("one.bin",17,99));
        Check(rows.Count==1&&rows[0].name=="one.bin"&&rows[0].bytes==17&&rows[0].id==99,"native page fields");
        Check(GradleDiagnostic.ParseDirectoryPage(Page(".",0,1,0x10)).Count==0,"dot omitted");
        Check(GradleDiagnostic.ParseDirectoryPage(Page("..",0,1,0x10)).Count==0,"parent dot omitted");
        Malformed(new byte[103]);Malformed(Page("x",-1,1));Malformed(Page("x",1,0));Malformed(Page("x:y",1,1));Malformed(Page("x/y",1,1));
        byte[] odd=Page("name",1,1);Array.Copy(BitConverter.GetBytes(7),0,odd,60,4);Malformed(odd);
        byte[] badNext=Page("name",1,1);Array.Copy(BitConverter.GetBytes(8),0,badNext,0,4);Malformed(badNext);
        byte[] hugeNext=Page("name",1,1);Array.Copy(BitConverter.GetBytes(UInt32.MaxValue),0,hugeNext,0,4);Malformed(hugeNext);
        byte[] hugeName=Page("name",1,1);Array.Copy(BitConverter.GetBytes(UInt32.MaxValue-1),0,hugeName,60,4);Malformed(hugeName);
        byte[] one=Page("first",5,101),two=Page("second",9,102);int next=(one.Length+7)&~7;
        var pair=new byte[next+two.Length];Array.Copy(one,pair,one.Length);Array.Copy(BitConverter.GetBytes(next),pair,4);Array.Copy(two,0,pair,next,two.Length);
        rows=GradleDiagnostic.ParseDirectoryPage(pair);Check(rows.Count==2&&rows[0].bytes==5&&rows[1].bytes==9&&rows[1].id==102,"aligned chained native records");
        try{GradleDiagnostic.ParseDirectoryPage(Page("link",0,3,0x410));throw new Exception("reparse accepted");}catch(Exception e){Check(e.Message=="REDIRECTED_DISK_ENTRY","reparse metadata denied");}
        string stable=Tree(fixture,"stable",17);int deleted=0;
        Check(GradleDiagnostic.MeasureLocalTree(stable,null,id=>deleted++)==17&&deleted==0,"real local tree size");
        CheckFailureControls(stable);
        string pages=Child(fixture,"pages");Directory.CreateDirectory(pages);
        for(int i=0;i<1800;i++)File.WriteAllBytes(Child(pages,"file-"+i.ToString("D5")+".bin"),new byte[3]);
        Check(GradleDiagnostic.MeasureLocalTree(pages,null,id=>{throw new Exception("stable multipage directory lost");})==5400,"real multiple native pages count every file");
        string rename=Tree(fixture,"rename",19);bool moved=false;deleted=0;
        long size=GradleDiagnostic.MeasureLocalTree(rename,e=>{if(!moved&&e.name=="pending"){Directory.Move(Child(rename,"pending"),Child(rename,"renamed"));moved=true;}},id=>deleted++);
        Check(size==19&&moved&&deleted==0&&Directory.Exists(Child(rename,"renamed")),"file ID follows owned directory rename");
        string removal=Tree(fixture,"delete",23);bool removed=false;deleted=0;
        size=GradleDiagnostic.MeasureLocalTree(removal,e=>{if(!removed&&e.name=="pending"){File.Delete(Child(removal,"pending\\data.bin"));Directory.Delete(Child(removal,"pending"));removed=true;}},id=>deleted++);
        Check(size==0&&removed&&deleted==1,"deleted directory ID explicitly observed");
        string pending=Tree(fixture,"delete-pending",31);bool marked=false;deleted=0;
        size=GradleDiagnostic.MeasureLocalTree(pending,null,id=>deleted++,e=>{
            if(!marked&&e.name=="pending"){File.Delete(Child(pending,"pending\\data.bin"));Directory.Delete(Child(pending,"pending"));marked=true;}
        });
        Check(size==0&&marked&&deleted==1,"handle-confirmed delete-pending child");
        string denied=Tree(fixture,"denied",37),deniedChild=Child(denied,"pending");
        var acl=Directory.GetAccessControl(deniedChild);var blocked=Directory.GetAccessControl(deniedChild);
        blocked.AddAccessRule(new FileSystemAccessRule(WindowsIdentity.GetCurrent().User,FileSystemRights.ListDirectory,AccessControlType.Deny));
        try {
            Directory.SetAccessControl(deniedChild,blocked);
            try{GradleDiagnostic.MeasureLocalTree(denied,null,id=>{throw new Exception("access denied treated as missing");});throw new Exception("ACL denial ignored");}
            catch(Win32Exception error){Check(error.NativeErrorCode==5,"real ACL denial fails closed");}
        }finally{Directory.SetAccessControl(deniedChild,acl);}
        string escape=Tree(fixture,"scope",29);bool escaped=false;
        try{GradleDiagnostic.MeasureLocalTree(escape,e=>{if(!escaped&&e.name=="pending"){Directory.Move(Child(escape,"pending"),Child(fixture,"escaped"));escaped=true;}},id=>{});throw new Exception("scope escape accepted");}
        catch(Exception e){Check(e.Message=="DIRECTORY_SCOPE_ESCAPE"&&escaped,"renamed object outside measured root rejected");}
        string links=Child(fixture,"links");Directory.CreateDirectory(links);string target=Child(links,"target"),link=Child(links,"redirect");Directory.CreateDirectory(target);
        var start=new ProcessStartInfo(Path.Combine(Environment.SystemDirectory,"cmd.exe"),"/d /c mklink /J \""+link+"\" \""+target+"\""){UseShellExecute=false,CreateNoWindow=true,RedirectStandardOutput=true,RedirectStandardError=true,WorkingDirectory=fixture};
        using(var process=Process.Start(start)){process.StandardOutput.ReadToEnd();process.StandardError.ReadToEnd();if(!process.WaitForExit(10000)||process.ExitCode!=0)throw new Exception("owned junction fixture unavailable");}
        try{GradleDiagnostic.MeasureLocalTree(links,null,id=>{});throw new Exception("junction followed");}
        catch(Exception e){Check(e.Message=="REDIRECTED_DISK_ENTRY","real junction refused by handle scan");}
        string churn=Child(fixture,"churn");Directory.CreateDirectory(churn);
        Exception writerError=null;int operations=0,gone=0;var stop=new ManualResetEvent(false);
        var writer=new Thread(()=>{
            try{while(!stop.WaitOne(0)) {
                string old=Child(churn,"pending-"+operations),fresh=Child(churn,"renamed-"+operations);
                Directory.CreateDirectory(old);File.WriteAllBytes(Child(old,"sample.bin"),new byte[47]);
                Directory.Move(old,fresh);File.Delete(Child(fresh,"sample.bin"));Directory.Delete(fresh);operations++;
            }}catch(Exception error){writerError=error;}
        });
        writer.Start();
        try{for(int i=0;i<500;i++)Check(GradleDiagnostic.MeasureLocalTree(churn,null,id=>gone++)>=0,"concurrent owned rename/delete sample");}
        finally{stop.Set();if(!writer.Join(10000))throw new Exception("owned churn writer did not exit");stop.Dispose();}
        if(writerError!=null)throw new Exception("owned churn writer failed",writerError);
        Check(operations>0,"concurrent owned writer actually ran");
        Console.WriteLine("Owned churn operations="+operations+", confirmed missing directory observations="+gone);
        Console.WriteLine(count+" handle scan regression assertions passed; owned fixtures retained.");return 0;
    }
}
