# AUTH-180｜Job 扩展限制嵌套结构官方声明

**2026-09-27 Work 派发；LEVEL 3，docs-only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-179 仅固定部分类型事实，`LARGE_INTEGER` 与 `IO_COUNTERS` 完整声明仍 `NOT_FIXED`。Work 预先只读确认微软 Learn 的两个**精确页面**可达：`https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-large_integer-r1` 与 `https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-io_counters`；普通 `ns-winnt-large_integer` 路径返回 404，不得用它的失败覆盖正确页面。本任务只固定两种嵌套类型的官方声明、条件与未证边界；不写 FFI、不运行 Win32/Job/进程。唯一允许新增/修改本目录 `plan.md`，交付后停 Work 独立 LEVEL 3 审查。

## 精确范围

先核对根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty，以及 AUTH-178/179 `plan.md`/`work-review.md`。外部只限上述两个精确微软 Learn 页面及其直接链接、解释结构字段类型所必需的微软官方类型定义页。记录 URL、标题、HTTP 状态，从 `Syntax` 代码块实际抽取的完整字段/union 分支/顺序、`LARGE_INTEGER` 的 32/64 位分支条件、`IO_COUNTERS` 各成员的类型和任何对齐说明。只把正文直接支持的事实标为 `VERIFIED_DOC_DECLARATION/TYPE`；未抽取、页面没有给出的对齐/填充、目标 ABI 与 Python 映射明确 `NOT_FIXED`。不得把 `LONGLONG` 独立类型或 AUTH-178 外层声明当嵌套结构完整证明。

本任务不访问 `JOBOBJECTINFOCLASS` 枚举页，不补 `AssignProcessToJobObject` 权限、嵌套/breakaway、成员身份、最后句柄所有权、硬总墙钟或真实恢复；它们继续独立未证。

## 预算与停点

最多 2 轮固定本地来源核对、2 轮上述微软官方页面限定读取，最后仅 1 次 `plan.md` 路径/存在性、SHA-256、格式核对。不得运行测试、编译器、Python FFI、Win32 API、Job/人工进程、AUTH-155、ACL/Docker/WSL/UAC、真实密文/密钥/DB、SSH/云/API，访问 GitHub、旧 `D:\EliteSync`，提交、pull 或 push。保留既有 dirty/untracked，旧预算不重置；作者不自接受、不派发后继。
