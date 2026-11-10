using System;
using System.Collections.Generic;
using System.IO;

class ProducerSupervisorTests {
    static int Checks;
    static void Assert(bool value,string message){Checks++;if(!value)throw new Exception(message);}
    static void Reject(Action action){try{action();}catch(InvalidDataException){Checks++;return;}throw new Exception("Expected authority rejection");}
    static void WaitTests() {
        int polls=0,beats=0;long elapsed=0;
        uint code=ProducerSupervisor.Wait(()=>++polls==2,()=>7,()=>elapsed,2000,()=>beats++,ms=>elapsed+=ms);
        Assert(code==7&&beats==1&&elapsed==500,"poll carries actual root exit without resetting deadline");
        polls=0;
        try{ProducerSupervisor.Wait(()=>{polls++;return true;},()=>0,()=>3000,2000,()=>{},ms=>{});throw new Exception("timeout missing");}
        catch(TimeoutException){Assert(polls==0,"deadline includes preparation before root polling");}
        elapsed=0;beats=0;
        try{ProducerSupervisor.Wait(()=>false,()=>0,()=>elapsed,1000,()=>beats++,ms=>elapsed+=ms);throw new Exception("timeout missing");}
        catch(TimeoutException){Assert(elapsed==1000&&beats==2,"bounded heartbeat wait terminates");}
    }
    static void AuthorityTests() {
        var c=new Dictionary<string,object>{{"nonce","nonce"},{"binary_sha256","binary"},{"kind","current-product-aar-producer"}};
        var g=new Dictionary<string,object>{{"authorized",true},{"contract_sha256","contract"},{"max_attempts",1}};
        var a=new Dictionary<string,object>{{"contract_sha256","contract"},{"attempt",1},{"grant_sha256","grant"}};
        Action valid=()=>ProducerSupervisor.ValidateAuthority(c,g,a,"contract","grant","nonce","binary");
        valid();Checks++;
        g["authorized"]=false;Reject(valid);g["authorized"]=true;
        g["max_attempts"]=true;Reject(valid);g["max_attempts"]=1;
        a["attempt"]=true;Reject(valid);a["attempt"]=2;Reject(valid);a["attempt"]=1;
        a["grant_sha256"]="other";Reject(valid);a["grant_sha256"]="grant";
        Reject(()=>ProducerSupervisor.ValidateAuthority(c,g,a,"other","grant","nonce","binary"));
        Reject(()=>ProducerSupervisor.ValidateAuthority(c,g,a,"contract","grant","other","binary"));
        Reject(()=>ProducerSupervisor.ValidateAuthority(c,g,a,"contract","grant","nonce","other"));
    }
    static int Main(string[] args) {
        try {
            WaitTests();AuthorityTests();
            if(ProducerBoundaryTests.Run(args)!=0)return 1;
            Console.WriteLine("PASS "+Checks+" supervisor deadline/authority assertions; no VM or SDK");return 0;
        }catch(Exception error){Console.Error.WriteLine(error);return 1;}
    }
}
