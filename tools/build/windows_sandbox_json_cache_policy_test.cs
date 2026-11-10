// Pure values only. Never call observer Main, file APIs, or native APIs.
using System;
using System.Collections.Generic;

class JsonCachePolicyTests {
    static int checks;
    static void Accept(Action action){action();checks++;}
    static void Reject(Action action){try{action();}catch(Exception){checks++;return;}throw new Exception("Invalid cache policy accepted");}
    static int Main(){
        Accept(()=>GradleDiagnostic.RequireCacheFileShape(0,0x80,1,true));
        Accept(()=>GradleDiagnostic.RequireCacheFileShape(1,0x80,1,false));
        Accept(()=>GradleDiagnostic.RequireCacheFileShape(32768,0x80,1,false));
        Reject(()=>GradleDiagnostic.RequireCacheFileShape(1,0x80,1,true));
        Reject(()=>GradleDiagnostic.RequireCacheFileShape(0,0x80,1,false));
        Reject(()=>GradleDiagnostic.RequireCacheFileShape(-1,0x80,1,false));
        Reject(()=>GradleDiagnostic.RequireCacheFileShape(32769,0x80,1,false));
        Reject(()=>GradleDiagnostic.RequireCacheFileShape(1,0x400,1,false));
        Reject(()=>GradleDiagnostic.RequireCacheFileShape(1,0x10,1,false));
        Reject(()=>GradleDiagnostic.RequireCacheFileShape(1,0x80,0,false));
        Reject(()=>GradleDiagnostic.RequireCacheFileShape(1,0x80,2,false));
        var value=new Dictionary<string,object>{{"frameworkVersion","3.41.7"},{"frameworkRevision","cc0734ac716fbb8b90f3f9db8020958b1553afa7"},{"dartSdkVersion","3.11.5"}};
        string sha=new string('a',64);
        Accept(()=>GradleDiagnostic.RequireVersionMetadata(value,sha,sha));
        Reject(()=>GradleDiagnostic.RequireVersionMetadata(value,new string('b',64),sha));
        Reject(()=>GradleDiagnostic.RequireVersionMetadata(value,"",""));
        Reject(()=>GradleDiagnostic.RequireVersionMetadata(value,null,null));
        Reject(()=>GradleDiagnostic.RequireVersionMetadata(null,sha,sha));
        foreach(string key in new[]{"frameworkVersion","frameworkRevision","dartSdkVersion"}){
            var missing=new Dictionary<string,object>(value);missing.Remove(key);
            Reject(()=>GradleDiagnostic.RequireVersionMetadata(missing,sha,sha));
            foreach(object invalid in new object[]{null,true,1,"wrong"}){
                var changed=new Dictionary<string,object>(value);changed[key]=invalid;
                Reject(()=>GradleDiagnostic.RequireVersionMetadata(changed,sha,sha));
            }
        }
        Console.WriteLine(checks+" pure JSON-cache metadata/file-shape assertions passed; no file or native APIs invoked.");return 0;
    }
}
