# AUTH-175｜Windows 基础类型与 Python `ctypes` 来源账本

**docs-only 作者候选，待 Work 独立 LEVEL 3 审查。** 本轮只固定所读取官方文档明确给出的 C 类型定义和 Python 通用类型表事实，不构造 Windows FFI。AUTH-170 继续 `UNAVAILABLE/NOT_CHECKED`；AUTH-155 Phase B、A/B 暂存与真实恢复继续 `NOT_READY`。

## 来源与分类

- 微软 Learn：[Windows Data Types](https://learn.microsoft.com/en-us/windows/win32/winprog/windows-data-types)，精确页面标题 `Windows Data Types (BaseTsd.h) - Win32 apps | Microsoft Learn`，两轮读取均 HTTP 200。下表仅按本轮实际抽取的类型行标 `VERIFIED_DOC_TYPE`。
- Python 官方：[ctypes — A foreign function library for Python](https://docs.python.org/3/library/ctypes.html)，本轮页面标题 `ctypes — A foreign function library for Python — Python 3.14.7 documentation`，两轮读取均 HTTP 200。其通用 C 类型对应表可证 `ctypes` 自身的标称 C 类型，**不能直接证明 Windows typedef、当前宿主/目标进程位宽或可调用 `argtypes`/`restype`**。
- AUTH-173/174 已接受的原始结构声明提供结构指针别名拼写；它们不是本轮基础类型宽度的替代来源。

| Windows 类型 | 微软页面实际取得的短原文标识与文档结论 | Python 官方文档能直接支持的边界；未证条件 |
| --- | --- | --- |
| `DWORD` | “A 32-bit unsigned integer”；`typedef unsigned long DWORD;`。`VERIFIED_DOC_TYPE`：32 位无符号，文档范围 0–4294967295。 | Python 表列 `c_ulong` ↔ `unsigned long`，但未直接声明 `DWORD` ↔ `c_ulong` 的当前 Windows 适配；映射 `NOT_FIXED`。 |
| `HANDLE` | “A handle to an object”；`typedef PVOID HANDLE;`，同页 `PVOID` 为 `typedef void *PVOID;`。`VERIFIED_DOC_TYPE`：C 层对象句柄的 `void *` 链。 | Python 表列 `c_void_p` ↔ `void *`，但 `HANDLE` 的 Python 映射、句柄值/所有权和当前目标指针宽度 `NOT_FIXED`。 |
| `BOOL` | “A Boolean variable (should be TRUE or FALSE)”；`typedef int BOOL;`。`VERIFIED_DOC_TYPE`：C `int`，本轮不写其目标字节宽度。 | Python 表列 `c_int` ↔ `int`，`c_bool` ↔ `_Bool`；不能把 Windows `BOOL` 凭名称映成 `c_bool`，具体 FFI 映射 `NOT_FIXED`。 |
| `WORD` | “A 16-bit unsigned integer”；`typedef unsigned short WORD;`。`VERIFIED_DOC_TYPE`：16 位无符号。 | Python 表列 `c_ushort` ↔ `unsigned short`；Windows typedef 的当前 Python 映射仍 `NOT_FIXED`。 |
| `LPWSTR` / `LPCWSTR` | 分别是指向零结尾 **16-bit Unicode** 字符串的指针与指向常量字符串的指针；`typedef WCHAR *LPWSTR;`、`typedef CONST WCHAR *LPCWSTR;`。同页 `WCHAR` 为 16-bit Unicode 字符，`typedef wchar_t WCHAR;`。`VERIFIED_DOC_TYPE`。 | Python 表列 `c_wchar_p` ↔ 零结尾 `wchar_t *`，但未直接证明它满足 Windows `WCHAR` 的位宽、可写 `LPWSTR` 缓冲或 `LPCWSTR` 调用条件；映射 `NOT_FIXED`。 |
| `LPVOID` | “A pointer to any type”；`typedef void *LPVOID;`。`VERIFIED_DOC_TYPE`。 | Python 表列 `c_void_p` ↔ `void *`；具体参数/缓冲映射及目标指针宽度 `NOT_FIXED`。 |
| `LPBYTE` | “A pointer to a BYTE”；`typedef BYTE far *LPBYTE;`，同页 `BYTE` 为 8-bit、`typedef unsigned char BYTE;`。`VERIFIED_DOC_TYPE`：C 层字节指针。 | Python 表列 `c_ubyte` ↔ `unsigned char`；没有本轮文档直接固定 `far`、指针缓冲和当前 Python 调用映射，保持 `NOT_FIXED`。 |
| 结构指针别名 | AUTH-173 原始声明有 `*LPSTARTUPINFOW`；AUTH-174 原始声明有 `*PPROCESS_INFORMATION`、`*LPPROCESS_INFORMATION`。这是已接受的 `VERIFIED_DOC_DECLARATION`，不是本轮微软类型表新增定义。 | Python `ctypes` 文档虽有指针/结构设施，本轮未取得这些 Windows 结构指针别名到 Python 类型的直接官方映射；`NOT_FIXED`。 |

上述微软行可区分固定宽度整数（`DWORD`、`WORD`、`BYTE`、`WCHAR`）与指针类型（`HANDLE`/`PVOID`、字符串指针、`LPVOID`、`LPBYTE`、结构指针）。`HANDLE` 为 `PVOID` 的 C typedef 链**不等于**本轮已测得当前宿主或目标进程是 32 位还是 64 位。本轮没有运行态位宽、结构 `sizeof`/偏移/对齐或 Windows 32/64 位调用 ABI 的测量；不得把文档的类型宽度转写为当前 Python 对象布局。Python 页面版本标题只标识此次读到的文档版本，不证明本机 Python 版本。

## 剩余硬边界与回执

仍缺当前宿主/目标位宽、Python `ctypes` 的 Windows typedef 静态适配、结构布局和调用约定、`CreateProcessW` 参数缓冲/返回/失败清理、Job 机制及限制、同步调用硬总墙钟与进程树清空。没有可调用 `argtypes`/`restype` 或现场进程能力结论；AUTH-170 启动前安全停点不变。

本地固定来源核对 **2/2 轮**：第一轮核对 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、既有 dirty/untracked、根 `AGENTS.md`/`CURRENT.md`/`TASK_CURRENT.md`/`REVIEW_GATE.md` 和本任务 `task.md`；第二轮只读 workflow 技能与 AUTH-173/174 `plan.md`/`work-review.md`。微软/Python 官方限定读取 **2/2 轮**：两轮均只访问上列两个固定 URL；未读取微软页面直接链接的其他定义页，因本页已含本表所需的基础定义。唯一新增本 `plan.md`，最后仅作任务允许的一次路径、存在性、SHA-256 和格式核对。

`NOT_RUN`：测试、Python 子进程、FFI、Job/Win32 API、ACL/Docker/WSL/UAC、真实密文/密钥/DB、SSH/云/API；未访问 GitHub、第三方示例、本机 SDK/注册表、其他项目或旧 `D:\EliteSync`，未提交、pull 或 push。保留全部既有工作区内容；旧任务预算不重置。作者停 Work 独立 LEVEL 3 ACCEPT/REJECT，不自接受、不派发后继。
