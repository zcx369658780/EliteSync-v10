# AUTH-173｜暂停态人工父进程最小 ABI 原始声明账本

**docs-only 作者候选，待 Work 独立 LEVEL 3 审查。** 本任务只从限定微软官方页面记录暂停创建所需声明；没有实现 Python FFI、调用 Win32 API 或启动人工父进程。`CreateProcessW` 原型与 `STARTUPINFOW` 完整字段顺序在本轮记为 `VERIFIED_DOC_DECLARATION`；`PROCESS_INFORMATION` 页面可达，但其完整声明未被本轮抽取，继续 `NOT_FIXED`。`CREATE_SUSPENDED` 常量及主线程初态为本轮官方正文事实。AUTH-170 仍 `UNAVAILABLE/NOT_CHECKED`，硬总墙钟与进程树清空仍 `UNRESOLVED`，AUTH-155 Phase B、A/B 暂存与真实恢复继续 `NOT_READY`。

本轮核对的本地仓库为 `D:\EliteSync-v10`、`main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 内容保留。来源等级严格区分：**官方 C 声明**、官方类型页面能明确支持的类型/别名、当前 Python/Windows FFI 映射、当前运行能力。后三者不能由原型页面可达或源码声明自动推出。

## 官方来源与实际抽取上限

限定微软 Learn 读取 **2/2 轮**，四个页面均 HTTP 200；第一轮取得精确 `<title>` 和 `CREATE_SUSPENDED` 正文，第二轮提取 C 声明及 `CreateProcessW` 返回段。只有下表确实抽取的文本标 `VERIFIED_DOC_DECLARATION`/`VERIFIED_DOC_FACT`。

| 官方 URL、精确页面标题 | 本轮得到的原文标识与事实 | 未固定项 |
| --- | --- | --- |
| [CreateProcessW](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw)；`CreateProcessW function (processthreadsapi.h) - Win32 apps \| Microsoft Learn`，HTTP 200 | `BOOL CreateProcessW(` 至 `LPPROCESS_INFORMATION lpProcessInformation );` 的**十参数完整 C 原型**如下；页面返回段写明成功非零、失败零并可调用 `GetLastError`。另说明函数可在新进程完成初始化前返回。`VERIFIED_DOC_DECLARATION/VERIFIED_DOC_FACT`。 | C 声明不固定当前 Python 的 `ctypes` 类型、调用约定、动态库解析、缓冲可写性实现或同步调用硬时限。 |
| [STARTUPINFOW](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/ns-processthreadsapi-startupinfow)；`STARTUPINFOW (processthreadsapi.h) - Win32 apps \| Microsoft Learn`，HTTP 200 | `typedef struct _STARTUPINFOW {` 至 `} STARTUPINFOW, *LPSTARTUPINFOW;` 的**十八字段完整声明与顺序**如下。`VERIFIED_DOC_DECLARATION`。 | `DWORD`、`WORD`、`HANDLE`、指针别名在目标 ABI 的宽度/对齐未由本轮链接类型页核定；`cb` 的运行时填充值和各字段使用条件不由字段表自动成立。 |
| [PROCESS_INFORMATION](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/ns-processthreadsapi-process_information)；`PROCESS_INFORMATION (processthreadsapi.h) - Win32 apps \| Microsoft Learn`，HTTP 200 | 页面标题与可达性已取得，但两轮受限抽取均未保留完整 `typedef` 声明；**本轮没有 `VERIFIED_DOC_DECLARATION` 的字段顺序/完整类型**。AUTH-172 旧有限账本列过局部字段，只作历史指针，不升级为本轮完整声明。 | `PROCESS_INFORMATION` 的完整原始结构、句柄/ID 字段顺序与类型、别名 `LPPROCESS_INFORMATION` 的目标 ABI 映射均 `NOT_FIXED`。不得据此写可调用输出缓冲。 |
| [Process Creation Flags](https://learn.microsoft.com/en-us/windows/win32/procthread/process-creation-flags)；`Process Creation Flags (WinBase.h) - Win32 apps \| Microsoft Learn`，HTTP 200 | 正文 `CREATE_SUSPENDED 0x00000004`；新进程的**主线程**创建为暂停态，直到调用 `ResumeThread` 才运行。`VERIFIED_DOC_FACT`。 | 主线程以外的启动副作用、当前 Python 固定人工父的实际暂停/纳入结果和硬时间上界均 `NOT_CHECKED/UNRESOLVED`。 |

### `CreateProcessW` 本轮原始声明（字段顺序照官方页面）

```c
BOOL CreateProcessW(
  [in, optional]      LPCWSTR               lpApplicationName,
  [in, out, optional] LPWSTR                lpCommandLine,
  [in, optional]      LPSECURITY_ATTRIBUTES lpProcessAttributes,
  [in, optional]      LPSECURITY_ATTRIBUTES lpThreadAttributes,
  [in]                BOOL                  bInheritHandles,
  [in]                DWORD                 dwCreationFlags,
  [in, optional]      LPVOID                lpEnvironment,
  [in, optional]      LPCWSTR               lpCurrentDirectory,
  [in]                LPSTARTUPINFOW        lpStartupInfo,
  [out]               LPPROCESS_INFORMATION lpProcessInformation
);
```

上列方向注释、类型和顺序为**文档声明**。`lpCommandLine` 在 C 原型中标为 `in,out,optional`，因此后继若需要该参数必须另审可写缓冲的官方语义；本轮不生成命令行。失败返回零并不在本轮证明所有输出字段或可能创建的对象状态，残留仍 `UNKNOWN`。不会从 `BOOL` 名称推断 Python 返回映射。

### `STARTUPINFOW` 本轮原始声明（字段顺序照官方页面）

```c
typedef struct _STARTUPINFOW {
  DWORD  cb;
  LPWSTR lpReserved;
  LPWSTR lpDesktop;
  LPWSTR lpTitle;
  DWORD  dwX;
  DWORD  dwY;
  DWORD  dwXSize;
  DWORD  dwYSize;
  DWORD  dwXCountChars;
  DWORD  dwYCountChars;
  DWORD  dwFillAttribute;
  DWORD  dwFlags;
  WORD   wShowWindow;
  WORD   cbReserved2;
  LPBYTE lpReserved2;
  HANDLE hStdInput;
  HANDLE hStdOutput;
  HANDLE hStdError;
} STARTUPINFOW, *LPSTARTUPINFOW;
```

该声明可核字段**类型名和相对顺序**，但 `sizeof`、偏移、填充、实际调用约定与当前解释器/Windows 位宽尚非本任务证据。尤其不能用 Python 对象字节布局猜测 `HANDLE` 或 `LPWSTR` 大小。若后继要传给 Win32，须另取官方 Windows 类型定义及当前 Python/Windows ABI 静态适配，独立审查后才可能进入纯虚构调用；`PROCESS_INFORMATION` 的完整声明缺口仍是更早硬停点。

## 仍缺的后继门

完成这两份原始声明**不**证明暂停态人工父能安全启动：`PROCESS_INFORMATION` 完整字段、相关 Windows 类型宽度/别名、`STARTUPINFOW` ABI 对齐、`CreateProcessW` 当前进程权限、`lpCommandLine` 可写/转义、句柄继承、失败输出与清理、当前 Python FFI 调用约定及同步调用硬墙钟均 `NOT_FIXED/UNRESOLVED`。本任务不延伸到 Job 结构/限制、分配失败直接父清理、人工后代身份、CMS 或数据库。AUTH-170 的启动前安全停点继续有效，不因微软官方声明存在而转成 API 可用或现场授权。

## 本轮回执

本地固定来源核对 **2/2 轮**：第一轮核对 cwd、`AGENTS.md`/`CURRENT.md`/`TASK_CURRENT.md`/`REVIEW_GATE.md`、workflow 技能、Git HEAD/dirty 与 AUTH-173 `task.md`；第二轮只读 AUTH-172 `plan.md`/`work-review.md`。微软官方限定页面读取 **2/2 轮**，未访问 GitHub、第三方片段、本机 SDK 或注册表。唯一新增本 `plan.md`；`NOT_RUN`：测试、Python 子进程、Job/Win32 API、ACL/Docker/WSL、UAC、真实密文/密钥/DB、SSH/云/API；未访问旧 `D:\EliteSync`，未提交、pull 或 push。AUTH-172 旧预算不重置；作者停 Work 独立 LEVEL 3 ACCEPT/REJECT，不自接受、不派发后继。
