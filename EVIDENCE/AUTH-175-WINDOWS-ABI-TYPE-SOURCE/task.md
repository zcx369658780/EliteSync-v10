# AUTH-175｜Windows 基础类型与目标 ABI 来源账本

**2026-09-27 Work 派发；LEVEL 3，docs-only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-173/174 固定了暂停创建所需的 C 原始声明，但 `DWORD`、`HANDLE`、指针/别名宽度仍没有完整来源。本任务只固定后继静态 Python 适配所需的官方类型事实；不写 FFI、不运行任何 Win32 API 或人工进程。唯一允许新增/修改本目录 `plan.md`，交付后停 Work 独立 LEVEL 3 审查。

## 精确范围

核对根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty，以及 AUTH-173/174 `plan.md`/`work-review.md`。外部资料只限微软 Learn 的 [Windows Data Types](https://learn.microsoft.com/en-us/windows/win32/winprog/windows-data-types)、由该页直接链接的必要官方基础类型定义，和 Python 官方 [ctypes 文档](https://docs.python.org/3/library/ctypes.html)；不访问 GitHub、第三方示例、本机 SDK/注册表。

在 `plan.md` 按 `DWORD`、`HANDLE`、`BOOL`、`WORD`、`LPWSTR`/`LPCWSTR`、`LPVOID`、`LPBYTE`、结构指针别名逐项给出**实际读取的**原文短标识、固定 URL、页面可达状态、文档类型定义/宽度结论及未证条件。特别区分 Windows C 类型语义、32/64 位 ABI 条件、Python `ctypes` 类型映射和当前宿主/目标进程位宽；只把官方正文明确支持的结论记为 `VERIFIED_DOC_TYPE`。若 Python 文档没有直接证明某个 Windows 类型的具体映射，保留 `NOT_FIXED`，不得凭常识写成可调用 `argtypes`/`restype`。本机运行态、结构 `sizeof`/偏移/对齐、Job 机制、失败清理和硬总墙钟仍是独立后继门。

## 预算与停点

最多 2 轮本地固定来源核对、2 轮上述官方页面限定读取；最后仅 1 次 `plan.md` 路径、存在性、SHA-256、格式核对。不得运行测试、Python 子进程、Job/Win32 API、ACL/Docker/WSL/UAC、真实密文/密钥/DB、SSH/云/API，访问旧 `D:\EliteSync`，提交、pull 或 push。保留既有 dirty/untracked。旧任务预算不重置；作者不自接受、不派发后继。
