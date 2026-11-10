// Pure environment-policy tests; do not invoke guest Main or native APIs.
using System;
using System.Collections.Generic;

class FlutterCachePolicyTests {
    static int checks;
    static void Accept(Dictionary<string,object> env) {GradleDiagnostic.RequireNormalCacheEnvironment(env);checks++;}
    static void Reject(Dictionary<string,object> env) {
        try {GradleDiagnostic.RequireNormalCacheEnvironment(env);}
        catch(Exception) {checks++;return;}
        throw new Exception("Unsafe cache environment accepted");
    }
    static int Main() {
        try {
            Accept(new Dictionary<string,object>{{"FLUTTER_ROOT",@"C:\BuildWork\Flutter"}});
            Accept(new Dictionary<string,object>{{"flutter_root",@"C:\BuildWork\Flutter"}});
            foreach(string key in new[]{"FLUTTER_ALREADY_LOCKED","flutter_already_locked","Flutter_Already_Locked"})
                Reject(new Dictionary<string,object>{{"FLUTTER_ROOT",@"C:\BuildWork\Flutter"},{key,"true"}});
            Reject(new Dictionary<string,object>{{"FLUTTER_ROOT",@"C:\BuildWork\Flutter"},{"flutter_root",@"C:\Other"}});
            Reject(new Dictionary<string,object>{{"FLUTTER_ROOT",@"C:\Other"}});
            Reject(new Dictionary<string,object>{{"FLUTTER_ROOT",true}});
            Reject(new Dictionary<string,object>());
            Console.WriteLine(checks+" pure Windows cache environment assertions passed; no native APIs invoked.");return 0;
        }catch(Exception e){Console.WriteLine(e.ToString());return 1;}
    }
}
