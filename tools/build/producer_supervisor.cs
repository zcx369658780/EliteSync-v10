// One guest entry point. The host supplies a frozen contract and one-shot claim.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web.Script.Serialization;

internal static class ProducerSupervisor {
    const string Probe=@"C:\Probe", Work=@"C:\BuildWork", Output=@"C:\ProbeOutput";
    static readonly JavaScriptSerializer Json=new JavaScriptSerializer{MaxJsonLength=64*1024*1024};
    static string Hash(byte[] raw){using(var hash=SHA256.Create())return BitConverter.ToString(hash.ComputeHash(raw)).Replace("-","").ToLowerInvariant();}
    static Dictionary<string,object> Object(object value){return (Dictionary<string,object>)value;}
    static Dictionary<string,object> Read(string name){return Json.Deserialize<Dictionary<string,object>>(File.ReadAllText(Path.Combine(Probe,name)));}
    static void Publish(string name,object value) {
        string path=Path.Combine(Output,name);
        using(var file=new FileStream(path+".pending",FileMode.CreateNew,FileAccess.Write)) {
            var bytes=Encoding.UTF8.GetBytes(Json.Serialize(value));file.Write(bytes,0,bytes.Length);file.Flush(true);
        }
        File.Move(path+".pending",path);
    }
    internal static uint Wait(Func<bool> exited,Func<uint> code,Func<long> elapsed,long deadline,
                              Action heartbeat,Action<int> pause) {
        while(true) {
            if(elapsed()>=deadline)throw new TimeoutException("Producer guest deadline");
            if(exited())return code();
            heartbeat();pause(500);
        }
    }
    internal static void ValidateAuthority(Dictionary<string,object> contract,Dictionary<string,object> grant,
        Dictionary<string,object> claim,string contractSha,string grantSha,string nonce,string binarySha) {
        if((string)contract["nonce"]!=nonce||(string)contract["binary_sha256"]!=binarySha||
           (string)contract["kind"]!="current-product-aar-producer"||
           !(grant["authorized"] is bool)||!(bool)grant["authorized"]||
           (string)grant["contract_sha256"]!=contractSha||!Equals(grant["max_attempts"],1)||
           (string)claim["contract_sha256"]!=contractSha||!Equals(claim["attempt"],1)||
           (string)claim["grant_sha256"]!=grantSha)
            throw new InvalidDataException("One-shot producer authority does not match");
    }
    static string Child(string root,string relative) {
        string path=Path.GetFullPath(Path.Combine(root,relative.Replace('/',Path.DirectorySeparatorChar)));
        if(!path.StartsWith(root+Path.DirectorySeparatorChar,StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("Input escapes declared tree");
        return path;
    }
    static int Materialize(string inventory,string expectedSha,string source,string target) {
        byte[] bytes=File.ReadAllBytes(Path.Combine(Probe,inventory));
        if(Hash(bytes)!=expectedSha)throw new InvalidDataException("Prepared inventory changed");
        var rows=(System.Collections.IEnumerable)Object(Json.DeserializeObject(Encoding.UTF8.GetString(bytes)))["files"];
        Directory.CreateDirectory(target);int count=0;
        foreach(object item in rows) {
            var row=Object(item);string relative=(string)row["relative_path"];
            string input=Child(source,relative),output=Child(target,relative);
            Directory.CreateDirectory(Path.GetDirectoryName(output));
            using(var src=new FileStream(input,FileMode.Open,FileAccess.Read,FileShare.Read))
            using(var dst=new FileStream(output,FileMode.CreateNew,FileAccess.Write))
            using(var digest=SHA256.Create()) {
                long copied=0,expected=Convert.ToInt64(row["bytes"]);byte[] buffer=new byte[1024*1024];int size;
                while((size=src.Read(buffer,0,buffer.Length))>0) {
                    copied+=size;if(copied>expected)throw new InvalidDataException("Prepared input grew");
                    digest.TransformBlock(buffer,0,size,buffer,0);dst.Write(buffer,0,size);
                }
                digest.TransformFinalBlock(new byte[0],0,0);
                if(copied!=expected||BitConverter.ToString(digest.Hash).Replace("-","").ToLowerInvariant()!=(string)row["sha256"])
                    throw new InvalidDataException("Prepared input bytes differ: "+relative);
            }
            count++;
        }
        return count;
    }
    static int ExportRepository() {
        string root=Work+@"\AarOutput\outputs\repo";
        var pending=new Stack<string>();pending.Push(root);long total=0;int count=0,entries=0;bool aar=false,pom=false;
        while(pending.Count>0) {
            string current=pending.Pop();
            if((File.GetAttributes(current)&FileAttributes.ReparsePoint)!=0)throw new IOException("Redirected output directory");
            foreach(string path in Directory.EnumerateFileSystemEntries(current)) {
                if(++entries>50000)throw new IOException("Output entry bound");
                var attributes=File.GetAttributes(path);
                if((attributes&FileAttributes.ReparsePoint)!=0)throw new IOException("Redirected output");
                if((attributes&FileAttributes.Directory)!=0){pending.Push(path);continue;}
                if(++count>10000)throw new IOException("Output file bound");
                total+=new FileInfo(path).Length;if(total>2L*1024*1024*1024)throw new IOException("Output exceeds 2 GiB export bound");
                aar|=path.EndsWith(".aar");pom|=path.EndsWith(".pom");
                string destination=Child(Output+@"\repository",path.Substring(root.Length+1));
                Directory.CreateDirectory(Path.GetDirectoryName(destination));File.Copy(path,destination,false);
            }
        }
        if(!aar||!pom)throw new InvalidDataException("Real AAR/POM output missing");
        return count;
    }
    static int Main(string[] args) {
        if(Environment.UserName!="WDAGUtilityAccount"||args.Length!=1||
           !String.Equals(Process.GetCurrentProcess().MainModule.FileName,Probe+@"\ProducerSupervisor.exe",StringComparison.OrdinalIgnoreCase))return 30;
        var clock=Stopwatch.StartNew();bool started=false;Timer watchdog=null;WindowsProducerBoundary api=null;
        try {
            var contractRaw=File.ReadAllBytes(Probe+@"\run-contract.json");
            var contract=Object(Json.DeserializeObject(Encoding.UTF8.GetString(contractRaw)));
            var grant=Read("owner-grant.json");var claim=Read("launch.claim.json");
            string grantSha=Hash(File.ReadAllBytes(Probe+@"\owner-grant.json"));
            ValidateAuthority(contract,grant,claim,Hash(contractRaw),grantSha,args[0],Hash(File.ReadAllBytes(Probe+@"\ProducerSupervisor.exe")));
            long deadline=Convert.ToInt64(contract["guest_seconds"])*1000;
            watchdog=new Timer(delegate{
                try{Publish("watchdog.json",new{nonce=args[0],reason="guest_deadline"});}
                finally{Environment.Exit(83);}
            },null,checked((int)Math.Max(1,deadline-clock.ElapsedMilliseconds)),Timeout.Infinite);
            if(Directory.Exists(Work))throw new IOException("Fresh guest BuildWork required");
            Directory.CreateDirectory(Work+@"\Control");
            int flutter=Materialize("flutter-inventory.json",(string)contract["flutter_inventory_sha256"],@"C:\Inputs\PreparedFlutter",Work+@"\Flutter");
            int project=Materialize("project-inventory.json",(string)contract["project_inventory_sha256"],@"C:\Inputs\PreparedProject",Work+@"\Project");
            byte[] entryRaw=File.ReadAllBytes(Probe+@"\producer-entry.json");
            if(Hash(entryRaw)!=(string)contract["producer_entry_sha256"])throw new InvalidDataException("Producer entry changed");
            var entry=Object(Json.DeserializeObject(Encoding.UTF8.GetString(entryRaw)));
            foreach(var overlay in Object(entry["overlays"]))File.WriteAllText(Child(Work+@"\Flutter",overlay.Key),(string)overlay.Value,new UTF8Encoding(false));
            Directory.CreateDirectory(Work+@"\GradleHome");
            File.WriteAllText(Work+@"\GradleHome\gradle.properties",(string)entry["gradle_properties"],new UTF8Encoding(false));
            File.Copy(Probe+@"\producer-output.init.gradle",Work+@"\Control\producer-output.init.gradle");
            foreach(string directory in new[]{"Home","tmp","PubCache","state\\project-cache","AarOutput"})Directory.CreateDirectory(Work+"\\"+directory);
            var request=Object(contract["launch_request"]);
            var env=Object(request["environment"]).ToDictionary(p=>p.Key,p=>(string)p.Value);
            api=new WindowsProducerBoundary(args[0],(string)request["command_line"],(string)request["cwd"],env);
            uint exit;
            using(var lease=ProducerBoundary.Start(api)) {
                started=true;
                using(var heartbeat=new StreamWriter(Output+@"\heartbeat.jsonl",false,new UTF8Encoding(false))) {
                    exit=Wait(()=>api.HasExited(lease.Process),()=>api.ExitCode(lease.Process),()=>clock.ElapsedMilliseconds,deadline,
                        delegate{heartbeat.WriteLine(Json.Serialize(new{elapsed_ms=clock.ElapsedMilliseconds}));heartbeat.Flush();},Thread.Sleep);
                }
            }
            if(exit!=0)throw new InvalidOperationException("AAR producer exited "+exit);
            int outputs=ExportRepository();
            if(clock.ElapsedMilliseconds>=deadline)throw new TimeoutException("Producer deadline includes output export");
            Publish("result.json",new{nonce=args[0],status="AAR_PRODUCER_EXIT0_OUTPUT_EXPORTED",root_exit=exit,
                copied_flutter_files=flutter,copied_project_files=project,exported_files=outputs,elapsed_ms=clock.ElapsedMilliseconds,
                sdk_started=started,G2=false,host_handoff_verified=false});
            return 0;
        } catch(Exception error) {
            Publish("failure.json",new{nonce=args[0],reason=error.ToString(),root_create_attempted=api!=null&&api.RootCreateAttempted,
                sdk_start_observed=started,elapsed_ms=clock.ElapsedMilliseconds,G2=false});return 32;
        } finally {if(watchdog!=null)watchdog.Dispose();}
    }
}
