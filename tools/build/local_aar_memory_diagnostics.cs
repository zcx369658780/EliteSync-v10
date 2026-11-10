// Read-only observations of a borrowed Job handle; this class never owns it.
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;

internal static class LocalAarMemoryDiagnostics {
    internal struct JobMemory {internal ulong Limit,PeakJob,PeakProcess;}
    internal struct CommitMemory {internal ulong TotalPages,LimitPages,PageSize;}

    // Capture the two independent queries separately so one failure preserves the other.
    internal static Dictionary<string,object> Capture(Func<JobMemory> job,Func<CommitMemory> commit) {
        var result=new Dictionary<string,object>{
            {"status","UNKNOWN"},{"job_status","UNKNOWN"},{"commit_status","UNKNOWN"},
            {"job_memory_limit_bytes",null},{"peak_job_memory_used_bytes",null},{"peak_process_memory_used_bytes",null},
            {"commit_total_bytes",null},{"commit_limit_bytes",null},{"page_size_bytes",null},{"commit_headroom_bytes",null},
            {"job_error",null},{"commit_error",null}};
        int known=0;
        try {
            var value=job();
            result["job_memory_limit_bytes"]=value.Limit;result["peak_job_memory_used_bytes"]=value.PeakJob;
            result["peak_process_memory_used_bytes"]=value.PeakProcess;result["job_status"]="KNOWN";known++;
        } catch(Exception error){result["job_error"]=error.GetType().Name+": "+error.Message;}
        try {
            var value=commit();
            if(value.PageSize==0 || value.TotalPages>value.LimitPages)throw new InvalidOperationException("Invalid performance page counts");
            ulong total=checked(value.TotalPages*value.PageSize),limit=checked(value.LimitPages*value.PageSize);
            result["commit_total_bytes"]=total;result["commit_limit_bytes"]=limit;result["page_size_bytes"]=value.PageSize;
            result["commit_headroom_bytes"]=limit-total;result["commit_status"]="KNOWN";known++;
        } catch(Exception error){result["commit_error"]=error.GetType().Name+": "+error.Message;}
        result["status"]=known==2?"KNOWN":known==1?"PARTIAL":"UNKNOWN";
        return result;
    }

    internal static Dictionary<string,object> Read(IntPtr borrowedJob) {
        return Capture(delegate{return ReadJob(borrowedJob);},ReadCommit);
    }
    static JobMemory ReadJob(IntPtr borrowedJob) {
        var value=new Extended();uint size=checked((uint)Marshal.SizeOf(value));
        if(IntPtr.Size!=8 || size!=144)throw new InvalidOperationException("x64 job layout required");
        if(!QueryInformationJobObject(borrowedJob,9,ref value,size,IntPtr.Zero))
            throw new Win32Exception(Marshal.GetLastWin32Error(),"QueryInformationJobObject class 9");
        return new JobMemory{Limit=value.JobMemoryLimit.ToUInt64(),PeakJob=value.PeakJobMemory.ToUInt64(),PeakProcess=value.PeakProcessMemory.ToUInt64()};
    }
    static CommitMemory ReadCommit() {
        var value=new Performance();value.Size=checked((uint)Marshal.SizeOf(value));
        if(IntPtr.Size!=8 || value.Size!=104)throw new InvalidOperationException("x64 performance layout required");
        if(!GetPerformanceInfo(ref value,value.Size))throw new Win32Exception(Marshal.GetLastWin32Error(),"GetPerformanceInfo");
        return new CommitMemory{TotalPages=value.CommitTotal.ToUInt64(),LimitPages=value.CommitLimit.ToUInt64(),PageSize=value.PageSize.ToUInt64()};
    }
    // Job limits/peaks describe committed virtual memory, not physical RAM.
    // https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-jobobject_extended_limit_information
    [StructLayout(LayoutKind.Sequential)] internal struct BasicLimits {public long ProcessTime,JobTime;public uint Flags;public UIntPtr Minimum,Maximum;public uint ActiveProcessLimit;public UIntPtr Affinity;public uint Priority,Scheduling;}
    [StructLayout(LayoutKind.Sequential)] internal struct Io {public ulong Read,Write,Other,ReadBytes,WriteBytes,OtherBytes;}
    [StructLayout(LayoutKind.Sequential)] internal struct Extended {public BasicLimits Basic;public Io Io;public UIntPtr ProcessMemoryLimit,JobMemoryLimit,PeakProcessMemory,PeakJobMemory;}
    // Commit counts are pages. CommitLimit (and thus headroom) can change with pagefile growth.
    // https://learn.microsoft.com/en-us/windows/win32/api/psapi/ns-psapi-performance_information
    [StructLayout(LayoutKind.Sequential)] internal struct Performance {
        public uint Size;
        public UIntPtr CommitTotal,CommitLimit,CommitPeak,PhysicalTotal,PhysicalAvailable,SystemCache,KernelTotal,KernelPaged,KernelNonpaged,PageSize;
        public uint HandleCount,ProcessCount,ThreadCount;
    }
    [DllImport("kernel32.dll",SetLastError=true)] [return:MarshalAs(UnmanagedType.Bool)]
    static extern bool QueryInformationJobObject(IntPtr job,int infoClass,ref Extended info,uint length,IntPtr returnedLength);
    [DllImport("psapi.dll",SetLastError=true)] [return:MarshalAs(UnmanagedType.Bool)]
    static extern bool GetPerformanceInfo(ref Performance info,uint size);
}
