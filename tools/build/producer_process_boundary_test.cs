// Host-safe policy/lifecycle fixtures. Never instantiate WindowsProducerBoundary.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.Script.Serialization;

internal sealed class FakeProducerApi : IProducerBoundaryApi {
    internal readonly List<string> Calls=new List<string>();
    internal readonly HashSet<IntPtr> Open=new HashSet<IntPtr>();
    internal readonly HashSet<string> Fail=new HashSet<string>();
    internal bool InvalidProcess,InvalidThread;
    internal IntPtr InvalidValue=new IntPtr(-1);
    void Call(string name) {Calls.Add(name);if(Fail.Contains(name))throw new IOException(name);}
    IntPtr Handle(int n) {var h=new IntPtr(n);Open.Add(h);return h;}
    public void PrepareWorkspace(){Call("prepare");}
    public IntPtr CreateToken(){Call("token");return Handle(10);}
    public IntPtr CreateJob(){Call("job");return Handle(20);}
    public ProducerChild SpawnSuspended(IntPtr token){Call("spawn");return new ProducerChild{
        Process=InvalidProcess?InvalidValue:Handle(30),Thread=InvalidThread?InvalidValue:Handle(40)};}
    public void Assign(IntPtr job,IntPtr process){Call("assign");}
    public void Resume(IntPtr thread){Call("resume");}
    public void TerminateAndDrainJob(IntPtr job){Call("kill-job-"+job);}
    public void TerminateAndWaitRoot(IntPtr process){Call("kill-root-"+process);}
    public void Close(IntPtr handle) {
        if(!Open.Remove(handle))throw new Exception("duplicate/unowned close "+handle);
        Call("close-"+handle);
    }
}

class ProducerBoundaryTests {
    static int Checks;
    static void Assert(bool ok,string message){Checks++;if(!ok)throw new Exception(message);}
    static Exception Throws(Action action) {
        try{action();}catch(Exception e){Checks++;return e;}throw new Exception("Expected failure");
    }
    static void Lifecycle() {
        var api=new FakeProducerApi();var lease=ProducerBoundary.Start(api);
        Assert(String.Join(",",api.Calls)=="prepare,token,job,spawn,assign,resume,close-40,close-10","suspend/assign/resume order and transient handles");
        Assert(api.Open.SetEquals(new[]{new IntPtr(20),new IntPtr(30)}),"lease holds only its job/root");
        lease.Dispose();int count=api.Calls.Count;lease.Dispose();
        Assert(api.Open.Count==0&&api.Calls.Count==count,"dispose closes once");
        Assert(api.Calls.IndexOf("kill-job-20")<api.Calls.IndexOf("close-30"),"drain before process handle release");
    }
    static void FailurePaths() {
        foreach(string failure in new[]{"prepare","token","job","spawn","assign","resume","close-40","close-10"}) {
            var api=new FakeProducerApi();api.Fail.Add(failure);
            Throws(delegate{ProducerBoundary.Start(api);});
            Assert(api.Open.Count==0,"all owned handles attempted after "+failure);
            Assert(api.Calls.Count(x=>x=="resume")==(failure=="resume"||failure.StartsWith("close-")?1:0),"no premature resume after "+failure);
            if(failure=="assign")Assert(api.Calls.Contains("kill-root-30")&&!api.Calls.Contains("kill-job-20"),"unassigned root cleanup");
            if(failure=="resume"||failure.StartsWith("close-"))Assert(api.Calls.Contains("kill-job-20"),"assigned child cleanup "+failure);
            Assert(!api.Calls.Any(x=>x.StartsWith("close-")&&api.Calls.Count(y=>y==x)>1),"no close retries after "+failure);
        }
        var both=new FakeProducerApi();both.Fail.UnionWith(new[]{"resume","kill-job-20","close-40"});
        var error=Throws(delegate{ProducerBoundary.Start(both);});
        Assert(error is AggregateException,"preserve primary and cleanup failures");
        Assert(((AggregateException)error).Flatten().InnerExceptions.Count>=3,"all failure causes retained");
        Assert(both.Open.Count==0,"cleanup continues after close failure");
        var drain=new FakeProducerApi();var lease=ProducerBoundary.Start(drain);drain.Fail.Add("kill-job-20");
        Throws(delegate{lease.Dispose();});Assert(drain.Open.Count==0,"drain failure releases only owned handles");
        foreach(int sentinel in new[]{0,-1,-2})foreach(bool process in new[]{true,false}) {
            var invalid=new FakeProducerApi{InvalidProcess=process,InvalidThread=!process,InvalidValue=new IntPtr(sentinel)};
            Throws(delegate{ProducerBoundary.Start(invalid);});
            Assert(!invalid.Calls.Any(c=>c.EndsWith("--1")||c.EndsWith("--2")||c.EndsWith("-0")),"invalid/pseudo-handle is never terminated or closed");
            Assert(!invalid.Calls.Contains("resume")&&invalid.Open.Count==0,"invalid child stops before resume and closes only positive owned handles");
        }
    }
    static Dictionary<string,string> Env(){return new Dictionary<string,string>{{"PATH","C:/Inputs/Jdk/bin;C:/Windows/System32"}};}
    static void FactoryOwnership() {
        var calls=new List<string>();var errors=new List<Exception>();
        ProducerBoundary.FinishFactory(errors,delegate{calls.Add("rollback");},
            delegate{calls.Add("one");},delegate{calls.Add("two");});
        Assert(String.Join(",",calls)=="one,two","successful factory transfers after transient cleanup");
        calls.Clear();errors.Clear();
        Throws(delegate{ProducerBoundary.FinishFactory(errors,delegate{calls.Add("kill-and-close-local-child");},
            delegate{calls.Add("close-one");throw new IOException("close-one");},
            delegate{calls.Add("close-two");});});
        Assert(String.Join(",",calls)=="close-one,close-two,kill-and-close-local-child","factory failure retains child ownership and cleans every temporary handle");
        errors=new List<Exception>{new IOException("native operation")};calls.Clear();
        var all=Throws(delegate{ProducerBoundary.FinishFactory(errors,delegate{calls.Add("rollback");throw new IOException("rollback");},
            delegate{calls.Add("cleanup");throw new IOException("cleanup");});});
        Assert(((AggregateException)all).Flatten().InnerExceptions.Count==3,"native, cleanup and rollback errors retained");
        Assert(String.Join(",",calls)=="cleanup,rollback","rollback after cleanup even on primary native failure");
    }
    static void Validation() {
        const string nonce="0123456789abcdef0123456789abcdef",cmd="C:/Inputs/Jdk/bin/java.exe -version",cwd=@"C:\BuildWork\Project\apps\flutter_elitesync_module\.android";
        WindowsProducerBoundary.Validate(nonce,cmd,cwd,Env());Checks++;
        Assert(WindowsProducerBoundary.RestrictionSid(nonce)!=WindowsProducerBoundary.RestrictionSid(nonce.Substring(0,31)+"0"),"all 128 nonce bits bind restriction SID");
        foreach(var value in new[]{"",nonce+"\n",nonce.ToUpperInvariant(),"not-a-nonce"})
            Throws(delegate{WindowsProducerBoundary.Validate(value,cmd,cwd,Env());});
        foreach(var value in new[]{"cmd.exe /c anything",cmd+"\0",cmd+"\r\n",new string('a',30001)})
            Throws(delegate{WindowsProducerBoundary.Validate(nonce,value,cwd,Env());});
        Throws(delegate{WindowsProducerBoundary.Validate(nonce,cmd,@"D:\EliteSync-v10",Env());});
        foreach(var value in new[]{new Dictionary<string,string>(),
            new Dictionary<string,string>{{"PATH","x"},{"Path","y"}},
            new Dictionary<string,string>{{"FLUTTER_ALREADY_LOCKED","true"}},
            new Dictionary<string,string>{{"X","a\0b"}},
            new Dictionary<string,string>{{"X",new string('x',40000)}}})
            Throws(delegate{WindowsProducerBoundary.Validate(nonce,cmd,cwd,value);});
        var aggregate=Enumerable.Range(0,5).ToDictionary(i=>"X"+i,i=>new string('x',8192));
        Throws(delegate{WindowsProducerBoundary.Validate(nonce,cmd,cwd,aggregate);});
    }
    static void ValidateBoundRequest(string path) {
        var bytes=File.ReadAllBytes(path);Assert(bytes.Length<=1024*1024,"bounded binding file");
        var serializer=new JavaScriptSerializer{MaxJsonLength=1024*1024};
        var data=serializer.Deserialize<Dictionary<string,object>>(System.Text.Encoding.UTF8.GetString(bytes));
        Assert((string)data["kind"]=="producer-boundary-source-binding"&&data["nonce"]==null&&data["authorization"]==null&&
            data["runtime_authorized"] is bool&&!(bool)data["runtime_authorized"]&&
            data["claim_created"] is bool&&!(bool)data["claim_created"],"source binding does not carry runtime permission");
        var request=(Dictionary<string,object>)data["launch_request"];
        var env=((Dictionary<string,object>)request["environment"]).ToDictionary(p=>p.Key,p=>(string)p.Value);
        WindowsProducerBoundary.Validate("0123456789abcdef0123456789abcdef",(string)request["command_line"],(string)request["cwd"],env);
        Checks++; // Fixed nonce above is a validation fixture, never a run nonce.
    }
    static int Main(string[] args) {
        try{
            Lifecycle();FailurePaths();FactoryOwnership();Validation();
            if(args.Length>1)throw new InvalidDataException("At most one source binding fixture");
            if(args.Length==1)ValidateBoundRequest(args[0]);
            Console.WriteLine("PASS "+Checks+" host-safe boundary assertions; Windows token/ACL/Job/SDK runtime NOT_RUN");return 0;}
        catch(Exception error){Console.Error.WriteLine(error);return 1;}
    }
}
