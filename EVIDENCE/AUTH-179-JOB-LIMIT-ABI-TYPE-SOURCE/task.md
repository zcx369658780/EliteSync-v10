# AUTH-179｜Job 限制结构依赖类型的官方来源账本

**2026-09-27 Work 派发；LEVEL 3，docs-only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-178 已固定两份 Job 限制结构的官方 C 声明，但其依赖类型的目标 ABI 未固定。本任务只抽取 `LARGE_INTEGER`、`IO_COUNTERS`、`SIZE_T`、`ULONG_PTR`、`JOBOBJECTINFOCLASS` 及结构中用到的基础整数类型的官方声明/宽度条件，为后继静态布局比对提供来源；不写 FFI、不运行 Win32、不创建 Job/进程。唯一允许新增/修改本目录 `plan.md`，交付后停 Work 独立 LEVEL 3 审查。

## 精确范围

先核对根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty，以及 AUTH-175、AUTH-178 的 `plan.md`/`work-review.md`。外部来源仅限 `learn.microsoft.com` 的 AUTH-178 两结构页及其直接链接的上述类型/官方 Windows Data Types 页面；`JOBOBJECTINFOCLASS` 仅可读取微软官方枚举页。可用微软页面的 `Syntax` 代码块、正文及官方类型表；不可用时保留 `UNAVAILABLE/NOT_FIXED`。不得访问 GitHub、第三方代码、本机 SDK/注册表或其他项目。

在 `plan.md` 逐项列 URL、精确页面标题/HTTP 状态、实际抽取的完整声明或短类型定义、32/64 位条件、是否影响结构字段宽度/对齐；仅正文直接支持的项标 `VERIFIED_DOC_DECLARATION/TYPE`。不要把 C typedef 直接映成 Python `ctypes`，不要从类型名称推断 `sizeof`、字段偏移、调用约定或当前主机兼容性。若微软文档没有给出结构嵌套布局所需的某项，明确 `NOT_FIXED`。本任务不补 `AssignProcessToJobObject` 权限、嵌套/breakaway、最后句柄所有权、成员核对或硬总墙钟。

## 预算与停点

最多 2 轮固定本地来源核对、2 轮限定微软官方页面读取，最后仅 1 次 `plan.md` 路径/存在性、SHA-256、格式核对。不得运行测试、编译器、Python FFI、Win32 API、Job/人工进程、AUTH-155、ACL/Docker/WSL/UAC、真实密文/密钥/DB、SSH/云/API，访问旧 `D:\EliteSync`，提交、pull 或 push。保留既有 dirty/untracked，旧预算不重置；作者不自接受、不派发后继。
