# AUTH-180｜Job 嵌套结构官方声明账本

**docs-only 作者候选，待 Work 独立 LEVEL 3 审查。** 本轮只从任务固定的两个微软 Learn 页面抽取 `LARGE_INTEGER` 与 `IO_COUNTERS` 的 C 声明，补 AUTH-179 的嵌套**声明**缺口；没有构造 FFI，也没有运行 Win32、Job 或人工进程。AUTH-170 仍 `UNAVAILABLE/NOT_CHECKED`，真实恢复与账号回填仍 `NOT_READY`。

## 固定页面与原始声明

两个页面在限定读取 **2/2 轮**均返回 HTTP 200；各有一个可抽取的 `Syntax` 代码块。

| 固定 URL | 精确 `<title>`；本轮取得的范围 |
| --- | --- |
| [LARGE_INTEGER](https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-large_integer-r1) | `LARGE_INTEGER - Win32 apps \| Microsoft Learn`；完整 union 声明如下，`VERIFIED_DOC_DECLARATION`。正文还称 `QuadPart` 为“a signed 64-bit integer”，并说明 `LARGE_INTEGER` 实际是 union；这两句为 `VERIFIED_DOC_TYPE`。 |
| [IO_COUNTERS](https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-io_counters) | `IO_COUNTERS (winnt.h) - Win32 apps \| Microsoft Learn`；完整六字段结构声明如下，`VERIFIED_DOC_DECLARATION`。 |

```c
typedef union _LARGE_INTEGER {
  struct {
    DWORD LowPart;
    LONG  HighPart;
  } DUMMYSTRUCTNAME;
  struct {
    DWORD LowPart;
    LONG  HighPart;
  } u;
  LONGLONG QuadPart;
} LARGE_INTEGER;
```

两个内部 `struct` 分支各按 `LowPart: DWORD`、`HighPart: LONG` 的顺序；另有 `LONGLONG QuadPart`。这是**union 的成员分支**，不是 `_WIN64`/32 位预处理分支。本轮页面 HTML 未抽取到 `#if`/`#ifdef`/`#else`/`#endif` 条件声明；页面未给出 32/64 位目标下不同的完整 C 定义，也未在本轮材料中给出宏 `DUMMYSTRUCTNAME` 的展开条件。因此**不**将某个分支删去或重写成单一 Python 结构，也不推断 union 在目标 ABI 的 `sizeof`、成员偏移或对齐。

```c
typedef struct _IO_COUNTERS {
  ULONGLONG ReadOperationCount;
  ULONGLONG WriteOperationCount;
  ULONGLONG OtherOperationCount;
  ULONGLONG ReadTransferCount;
  ULONGLONG WriteTransferCount;
  ULONGLONG OtherTransferCount;
} IO_COUNTERS;
```

这六项的**类型名、数量和相对顺序**由该页面声明直接支持。页面没有在本轮可核文本中给出六项的字节偏移、整体大小、填充或目标对齐规则；`ULONGLONG` 的独立 typedef 及目标 ABI 宽度亦未从允许的两个页面取得，不凭名称补定。`LARGE_INTEGER` 两个半部的 `DWORD`/`LONG` 独立目标 ABI 映射、`LONGLONG` 的底层目标布局同样不是本轮声明所证明。

## 外层结构与未证门

AUTH-178 已接受的 `JOBOBJECT_BASIC_LIMIT_INFORMATION` 声明在前两字段使用 `LARGE_INTEGER`，`JOBOBJECT_EXTENDED_LIMIT_INFORMATION` 在 `IoInfo` 使用 `IO_COUNTERS`。本轮只为这些字段补上**嵌套声明**，没有固定外层两结构的实际 `sizeof`、嵌套偏移、填充/对齐、目标 32/64 位 ABI 或 Python `ctypes` 表示；不能据此形成 `SetInformationJobObject` 可调用缓冲。`JOBOBJECTINFOCLASS` 枚举仍未固定；`AssignProcessToJobObject` 权限、嵌套/breakaway、成员身份、最后句柄所有权、真实清理和硬总墙钟保持独立 `NOT_FIXED/UNRESOLVED`。

本地固定来源核对 **2/2 轮**：第一轮核对 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、既有 dirty/untracked、根 `AGENTS.md`/`CURRENT.md`/`TASK_CURRENT.md`/`REVIEW_GATE.md` 和本任务 `task.md`；第二轮只读 workflow 技能及 AUTH-178/179 `plan.md`/`work-review.md`。微软页面限定读取 **2/2 轮**，只访问上表两个精确 URL，未访问错误的普通 `ns-winnt-large_integer` 路径或其他资料。唯一新增本 `plan.md`；最后仅作任务允许的一次路径、存在性、SHA-256 和格式核对。

`NOT_RUN`：测试、编译器、Python FFI、Win32 API、Job/人工进程、AUTH-155、ACL/Docker/WSL/UAC、真实密文/密钥/DB、SSH/云/API；未访问 GitHub、本机 SDK/注册表、其他项目或旧 `D:\EliteSync`，未提交、pull 或 push。保留既有工作区内容，旧预算不重置；作者停 Work 独立 LEVEL 3 ACCEPT/REJECT，不自接受、不派发后继。
