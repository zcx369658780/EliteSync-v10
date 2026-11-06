// Local build controller. Repository files stay in place for Python verification;
// the legacy .NET filesystem API never walks or exports the Maven repository.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Web.Script.Serialization;

internal static class LocalAarSupervisor {
    static readonly JavaScriptSerializer Json=new JavaScriptSerializer{MaxJsonLength=64*1024*1024};
    static readonly string Control=Path.GetDirectoryName(Process.GetCurrentProcess().MainModule.FileName);
    static readonly string Output=Path.GetFullPath(Path.Combine(Control,"..","output"));
    static string Hash(byte[] raw){using(var h=SHA256.Create())return BitConverter.ToString(h.ComputeHash(raw)).Replace("-","").ToLowerInvariant();}
    static Dictionary<string,object> Read(string file){return Json.Deserialize<Dictionary<string,object>>(File.ReadAllText(Path.Combine(Control,file)));}
    static void Publish(string name,object value) {
        string path=Path.Combine(Output,name);
        using(var file=new FileStream(path+".pending",FileMode.CreateNew,FileAccess.Write)) {
            byte[] bytes=Encoding.UTF8.GetBytes(Json.Serialize(value));file.Write(bytes,0,bytes.Length);file.Flush(true);
        }
        File.Move(path+".pending",path);
    }
    internal static void Authority(Dictionary<string,object> c,Dictionary<string,object> g,Dictionary<string,object> claim,
                                   string contractSha,string grantSha,string nonce,string binarySha) {
        if((string)c["kind"]!="current-product-local-aar-producer"||(string)c["nonce"]!=nonce||
           (string)c["binary_sha256"]!=binarySha||!Equals(g["authorized"],true)||!Equals(g["max_attempts"],1)||
           (string)g["contract_sha256"]!=contractSha||(string)claim["contract_sha256"]!=contractSha||
           (string)claim["grant_sha256"]!=grantSha||!Equals(claim["attempt"],1))
            throw new InvalidDataException("Independent local AAR authority does not match");
    }
    internal static Dictionary<string,object> MemoryHeartbeat(TextWriter writer,IntPtr job,long elapsed,bool rootExited,
                                                             Func<IntPtr,Dictionary<string,object>> capture=null) {
        var memory=(capture??LocalAarMemoryDiagnostics.Read)(job);
        // These are observations at this timestamp, never a precise failure-instant diagnosis.
        memory["sample_elapsed_ms"]=elapsed;memory["root_exit_observed"]=rootExited;
        writer.WriteLine(Json.Serialize(new{elapsed_ms=elapsed,root_exit_observed=rootExited,memory=memory}));writer.Flush();
        return memory;
    }
    static int Main(string[] args) {
        if(args.Length!=1)return 30;
        var clock=Stopwatch.StartNew();WindowsProducerBoundary api=null;Timer watchdog=null;
        bool started=false;Dictionary<string,object> memoryLast=null;
        try {
            byte[] raw=File.ReadAllBytes(Path.Combine(Control,"run-contract.json"));
            var contract=Json.Deserialize<Dictionary<string,object>>(Encoding.UTF8.GetString(raw));
            var grant=Read("owner-grant.json");var claim=Read("launch.claim.json");
            Authority(contract,grant,claim,Hash(raw),Hash(File.ReadAllBytes(Path.Combine(Control,"owner-grant.json"))),
                      args[0],Hash(File.ReadAllBytes(Process.GetCurrentProcess().MainModule.FileName)));
            long limit=Convert.ToInt64(contract["sdk_seconds"])*1000;
            watchdog=new Timer(delegate {
                try{Publish("watchdog.json",new{nonce=args[0],reason="local_sdk_deadline",memory_last=memoryLast});}
                finally{Environment.Exit(83);}
            },null,checked((int)Math.Max(1,limit-clock.ElapsedMilliseconds)),Timeout.Infinite);
            var request=(Dictionary<string,object>)contract["launch_request"];
            var env=((Dictionary<string,object>)request["environment"]).ToDictionary(p=>p.Key,p=>(string)p.Value);
            api=new WindowsProducerBoundary(args[0],(string)request["command_line"],(string)request["cwd"],env);
            uint exit;
            using(var lease=ProducerBoundary.Start(api)) {
                started=true;
                using(var heartbeat=new StreamWriter(Path.Combine(Output,"heartbeat.jsonl"),false,new UTF8Encoding(false))) {
                    while(true) {
                        if(clock.ElapsedMilliseconds>=limit)throw new TimeoutException("Local SDK deadline");
                        if(File.Exists(Path.Combine(Output,"host-stop.json")))throw new IOException("Host requested owned build stop");
                        if(api.HasExited(lease.Process)){
                            memoryLast=MemoryHeartbeat(heartbeat,lease.Job,clock.ElapsedMilliseconds,true);
                            exit=api.ExitCode(lease.Process);break;
                        }
                        memoryLast=MemoryHeartbeat(heartbeat,lease.Job,clock.ElapsedMilliseconds,false);Thread.Sleep(500);
                    }
                }
            }
            if(exit!=0)throw new InvalidOperationException("Local AAR producer exited "+exit);
            if(clock.ElapsedMilliseconds>=limit)throw new TimeoutException("Local result deadline");
            Publish("result.json",new{nonce=args[0],status="LOCAL_AAR_ROOT_EXIT0_REPOSITORY_UNVERIFIED",root_exit=exit,
                elapsed_ms=clock.ElapsedMilliseconds,repository=(string)contract["repository"],sdk_started=started,memory_last=memoryLast,G2=false});
            return 0;
        } catch(Exception error) {
            Publish("failure.json",new{nonce=args[0],reason=error.ToString(),root_create_attempted=api!=null&&api.RootCreateAttempted,
                sdk_start_observed=started,elapsed_ms=clock.ElapsedMilliseconds,memory_last=memoryLast,G2=false});return 32;
        } finally {if(watchdog!=null)watchdog.Dispose();}
    }
}
