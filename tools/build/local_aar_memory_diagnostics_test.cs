using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Web.Script.Serialization;

internal static class LocalAarMemoryDiagnosticsTest {
    static void Check(bool ok,string message){if(!ok)throw new Exception(message);}
    static LocalAarMemoryDiagnostics.JobMemory Job(){return new LocalAarMemoryDiagnostics.JobMemory{Limit=4294967296,PeakJob=3000000000,PeakProcess=2000000000};}
    static LocalAarMemoryDiagnostics.CommitMemory Commit(){return new LocalAarMemoryDiagnostics.CommitMemory{TotalPages=3,LimitPages=10,PageSize=4096};}
    static void Main() {
        var sample=LocalAarMemoryDiagnostics.Capture(Job,Commit);
        Check((string)sample["status"]=="KNOWN","known");
        Check((ulong)sample["job_memory_limit_bytes"]==4294967296UL && (ulong)sample["peak_job_memory_used_bytes"]==3000000000UL && (ulong)sample["peak_process_memory_used_bytes"]==2000000000UL,"job units");
        Check((ulong)sample["commit_total_bytes"]==12288 && (ulong)sample["commit_limit_bytes"]==40960 && (ulong)sample["commit_headroom_bytes"]==28672,"page units");
        sample=LocalAarMemoryDiagnostics.Capture(delegate{throw new IOException("fixture job query");},Commit);
        Check((string)sample["status"]=="PARTIAL" && (string)sample["job_status"]=="UNKNOWN" && sample["job_memory_limit_bytes"]==null && (ulong)sample["commit_total_bytes"]==12288 && ((string)sample["job_error"]).Contains("fixture job query"),"job partial");
        sample=LocalAarMemoryDiagnostics.Capture(Job,delegate{throw new IOException("fixture performance query");});
        Check((string)sample["status"]=="PARTIAL" && (string)sample["commit_status"]=="UNKNOWN" && sample["commit_total_bytes"]==null && (ulong)sample["peak_job_memory_used_bytes"]==3000000000UL,"commit partial");
        sample=LocalAarMemoryDiagnostics.Capture(delegate{throw new IOException("job");},delegate{throw new IOException("commit");});
        Check((string)sample["status"]=="UNKNOWN" && sample["job_error"]!=null && sample["commit_error"]!=null,"both unknown");
        sample=LocalAarMemoryDiagnostics.Capture(Job,delegate{return new LocalAarMemoryDiagnostics.CommitMemory{TotalPages=UInt64.MaxValue,LimitPages=UInt64.MaxValue,PageSize=4096};});
        Check((string)sample["commit_status"]=="UNKNOWN" && sample["commit_total_bytes"]==null,"overflow unknown");
        sample=LocalAarMemoryDiagnostics.Capture(Job,delegate{return new LocalAarMemoryDiagnostics.CommitMemory{TotalPages=11,LimitPages=10,PageSize=4096};});
        Check((string)sample["commit_status"]=="UNKNOWN" && sample["commit_headroom_bytes"]==null,"invalid page counts unknown");
        sample=LocalAarMemoryDiagnostics.Capture(Job,delegate{return new LocalAarMemoryDiagnostics.CommitMemory{TotalPages=10,LimitPages=10,PageSize=4096};});
        Check((ulong)sample["commit_headroom_bytes"]==0,"zero headroom");
        var writer=new StringWriter();IntPtr borrowed=new IntPtr(99);int calls=0;
        var last=LocalAarSupervisor.MemoryHeartbeat(writer,borrowed,123,true,delegate(IntPtr handle){Check(handle==borrowed,"borrowed handle");calls++;return LocalAarMemoryDiagnostics.Capture(Job,Commit);});
        var row=new JavaScriptSerializer().Deserialize<Dictionary<string,object>>(writer.ToString());
        Check(calls==1 && (bool)row["root_exit_observed"] && Convert.ToInt64(row["elapsed_ms"])==123 && row.ContainsKey("memory") && (string)last["status"]=="KNOWN","final heartbeat");
        Check(Marshal.SizeOf(typeof(LocalAarMemoryDiagnostics.Extended))==144 && Marshal.SizeOf(typeof(LocalAarMemoryDiagnostics.Performance))==104,"native x64 layout");
        Console.WriteLine("PASS 11 pure memory cases");
    }
}
