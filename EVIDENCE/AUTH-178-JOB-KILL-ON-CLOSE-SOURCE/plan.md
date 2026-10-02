# AUTH-178｜Job 关闭清理限制官方来源账本

**docs-only 作者候选，待 Work 独立 LEVEL 3 审查。** 本轮只记录微软 Learn 页面实际取得的 C 声明和正文事实，不构造 FFI，也不运行 Job、Win32 API 或人工进程。AUTH-170 仍 `UNAVAILABLE/NOT_CHECKED`；硬总墙钟、真实恢复及账号回填仍 `NOT_READY`。

## 固定页面与实际抽取

限定微软页面读取 **2/2 轮**；下表五个页面两轮均返回 HTTP 200。`VERIFIED_DOC_DECLARATION` 仅指代码块，`VERIFIED_DOC_FACT` 仅指本轮取得的页面正文/表项。

| 固定 URL | 精确 `<title>`；本轮证据 |
| --- | --- |
| [JOBOBJECT_BASIC_LIMIT_INFORMATION](https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-jobobject_basic_limit_information) | `JOBOBJECT_BASIC_LIMIT_INFORMATION (winnt.h) - Win32 apps \| Microsoft Learn`；下列九字段完整声明、`LimitFlags` 表中 `JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE 0x00002000` 行。`VERIFIED_DOC_DECLARATION/VERIFIED_DOC_FACT`。 |
| [JOBOBJECT_EXTENDED_LIMIT_INFORMATION](https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-jobobject_extended_limit_information) | `JOBOBJECT_EXTENDED_LIMIT_INFORMATION (winnt.h) - Win32 apps \| Microsoft Learn`；下列六字段完整声明。`VERIFIED_DOC_DECLARATION`。 |
| [SetInformationJobObject](https://learn.microsoft.com/en-us/windows/win32/api/jobapi2/nf-jobapi2-setinformationjobobject) | `SetInformationJobObject function (jobapi2.h) - Win32 apps \| Microsoft Learn`；四参数 C 原型、`JobObjectExtendedLimitInformation 9` 表项、`JOB_OBJECT_SET_ATTRIBUTES` 访问权、返回分类。`VERIFIED_DOC_DECLARATION/VERIFIED_DOC_FACT`。 |
| [QueryInformationJobObject](https://learn.microsoft.com/en-us/windows/win32/api/jobapi2/nf-jobapi2-queryinformationjobobject) | `QueryInformationJobObject function (jobapi2.h) - Win32 apps \| Microsoft Learn`；五参数 C 原型、同一信息类表项、`JOB_OBJECT_QUERY` 访问权、返回分类。`VERIFIED_DOC_DECLARATION/VERIFIED_DOC_FACT`。 |
| [Job Objects](https://learn.microsoft.com/en-us/windows/win32/procthread/job-objects) | `Job Objects - Win32 apps \| Microsoft Learn`；取得最后 Job 句柄关闭与该限制下关联进程终止的正文。`VERIFIED_DOC_FACT`。 |

### 结构原始声明

```c
typedef struct _JOBOBJECT_BASIC_LIMIT_INFORMATION {
  LARGE_INTEGER PerProcessUserTimeLimit;
  LARGE_INTEGER PerJobUserTimeLimit;
  DWORD         LimitFlags;
  SIZE_T        MinimumWorkingSetSize;
  SIZE_T        MaximumWorkingSetSize;
  DWORD         ActiveProcessLimit;
  ULONG_PTR     Affinity;
  DWORD         PriorityClass;
  DWORD         SchedulingClass;
} JOBOBJECT_BASIC_LIMIT_INFORMATION, *PJOBOBJECT_BASIC_LIMIT_INFORMATION;

typedef struct _JOBOBJECT_EXTENDED_LIMIT_INFORMATION {
  JOBOBJECT_BASIC_LIMIT_INFORMATION BasicLimitInformation;
  IO_COUNTERS                        IoInfo;
  SIZE_T                             ProcessMemoryLimit;
  SIZE_T                             JobMemoryLimit;
  SIZE_T                             PeakProcessMemoryUsed;
  SIZE_T                             PeakJobMemoryUsed;
} JOBOBJECT_EXTENDED_LIMIT_INFORMATION, *PJOBOBJECT_EXTENDED_LIMIT_INFORMATION;
```

`KILL_ON_JOB_CLOSE` 是 `BasicLimitInformation.LimitFlags` 的限制位：基础结构页面表项给出数值 `0x00002000`，并明确“requires use of a `JOBOBJECT_EXTENDED_LIMIT_INFORMATION` structure”，其 `BasicLimitInformation` 成员即上述基础结构。该页面的最短语义是最后 Job 句柄关闭时使关联进程终止；[Job Objects](https://learn.microsoft.com/en-us/windows/win32/procthread/job-objects) 进一步说，在该标志已指定时，关闭最后 Job 对象句柄将终止关联进程并销毁 Job 对象；嵌套 Job 时涉及子 Job 层级中的关联进程。这些都是**有条件的官方语义**，不是本机已设置标志、已关闭最后句柄或进程树已清空的证据。

### 设置与读回的官方接口边界

```c
BOOL SetInformationJobObject(
  [in] HANDLE hJob,
  [in] JOBOBJECTINFOCLASS JobObjectInformationClass,
  [in] LPVOID lpJobObjectInformation,
  [in] DWORD cbJobObjectInformationLength
);

BOOL QueryInformationJobObject(
  [in, optional] HANDLE hJob,
  [in] JOBOBJECTINFOCLASS JobObjectInformationClass,
  [out] LPVOID lpJobObjectInformation,
  [in] DWORD cbJobObjectInformationLength,
  [out, optional] LPDWORD lpReturnLength
);
```

两页的信息类表均列 `JobObjectExtendedLimitInformation`、值 **9**、对应 `JOBOBJECT_EXTENDED_LIMIT_INFORMATION` 指针。设置页要求 Job 句柄具有 `JOB_OBJECT_SET_ATTRIBUTES`，查询页要求 `JOB_OBJECT_QUERY`；本轮未取得这些访问权位的数值。两页返回段均写明成功返回非零、失败返回零，可调用 `GetLastError` 获扩展错误信息。由此可提出“设置后查询并比对 `LimitFlags`”的**后继候选核对步骤**，但本轮没有执行设置、读回或错误分支，也未固定 `GetLastError` 的具体错误码与失败副作用，不能记为已生效。

## 未固定边界与回执

`LARGE_INTEGER`、`IO_COUNTERS`、`SIZE_T`、`ULONG_PTR`、`JOBOBJECTINFOCLASS` 的完整目标 ABI 定义，以及两结构 `sizeof`、偏移、填充、Python `ctypes` 映射、调用约定、缓冲长度与句柄所有权均 `NOT_FIXED`；以上声明不得拼成可调用布局。`AssignProcessToJobObject` 的具体权限、嵌套 Job 的当前主机条件、breakaway、成员身份核对、最后句柄**实际**所有者及关闭后存活核验也未证。官方“关闭最后句柄”语义不能替代主动终止、有限等待和独立残留核查；硬总墙钟与进程树清空仍 `UNRESOLVED`。

本地固定来源核对 **2/2 轮**：第一轮核对 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、既有 dirty/untracked、根 `AGENTS.md`/`CURRENT.md`/`TASK_CURRENT.md`/`REVIEW_GATE.md` 和本任务 `task.md`；第二轮只读 workflow 技能、AUTH-171 `plan.md`/`work-review.md` 与 AUTH-175/176/177 `work-review.md`。微软页面限定读取 **2/2 轮**，仅访问上表五个固定 URL，未从页面直接链接扩展到其他资料。唯一新增本 `plan.md`；最后只作任务允许的一次路径、存在性、SHA-256 和格式核对。

`NOT_RUN`：测试、FFI、Win32 API、Job/人工进程、AUTH-155、ACL/Docker/WSL/UAC、真实密文/密钥/DB、SSH/云/API；未访问 GitHub、第三方示例、本机 SDK/注册表或旧 `D:\EliteSync`，未提交、pull 或 push。保留既有工作区内容，旧预算不重置；作者停 Work 独立 LEVEL 3 ACCEPT/REJECT，不自接受、不派发后继。
