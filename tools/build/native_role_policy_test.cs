// Pure manifest validation only. Never calls guest Main, Spawn or native APIs.
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Web.Script.Serialization;

class NativeRolePolicyTests {
    static int Main(string[] args) {
        if(args.Length!=1)return 2;
        var json=new JavaScriptSerializer();json.MaxJsonLength=4*1024*1024;
        var cases=(IEnumerable)json.DeserializeObject(File.ReadAllText(args[0]));
        int count=0;
        foreach(Dictionary<string,object> item in cases) {
            bool accepted=true;
            try {NativeRolePolicy.Validate((Dictionary<string,object>)item["manifest"]);}
            catch(InvalidDataException){accepted=false;}
            if(accepted!=(bool)item["accept"])throw new Exception("Policy case failed: "+item["name"]);
            count++;
        }
        Console.WriteLine("VALIDATION_ONLY_NO_SDK_CASES="+count);return 0;
    }
}
