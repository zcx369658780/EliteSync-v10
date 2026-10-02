# AUTH-172｜Win32 暂停创建与纳入 Job 的 ABI 来源账本

**2026-09-27 Work 派发；LEVEL 3，docs-only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。本任务只补 AUTH-171 明确的 `DOC_SEMANTICS_NOT_VERIFIED/NOT_FIXED`，为后继纯虚构实现准备可审核来源；不运行 Win32 API、人工进程或真实恢复。唯一允许新增/修改本目录 `plan.md`，交付后停 Work 独立 LEVEL 3 审查。

## 精确范围

先核对 `D:\EliteSync-v10` 根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty，随后只读 `EVIDENCE/AUTH-170-SYNTHETIC-WINDOWS-JOB-TREE-PREFLIGHT/work-review.md` 与 `EVIDENCE/AUTH-171-WINDOWS-JOB-STATIC-SAFETY-CONTRACT/{plan.md,work-review.md}`。外部来源只限 `learn.microsoft.com` 的以下命名 API/结构及其链接的官方类型定义：`CreateProcessW`、`STARTUPINFOW`、`PROCESS_INFORMATION`、`CreateJobObjectW`、`SetInformationJobObject`、`JOBOBJECT_EXTENDED_LIMIT_INFORMATION`、`AssignProcessToJobObject`、`ResumeThread`、`TerminateProcess`、`WaitForSingleObject`、`CloseHandle`。不访问 GitHub、第三方片段、论坛或本机注册表；某页不可读则对应行 `UNAVAILABLE`。

在 `plan.md` 用一张来源账本逐项记录：官方 URL、页面标题/可达状态、**实际抽取的短语义**、原型/参数与返回/失败分类、所需访问权、句柄和指针宽度/调用约定/结构字段与对齐的核对状态。只把本轮正文确已读取的字段写作 `VERIFIED_DOC_FACT`；未抽取或官方页未解释的字段明确 `NOT_FIXED`，不能凭 API 常识补全。区分官方文档语义、当前 Python/Windows ABI 适配及运行态三层，不要从页面可达推断本机可调用。只为**暂停态创建 → 恢复前分配 → 分配失败时仍暂停的直接父进程终止/等待**提供后继 FFI 的最小事实，不设计真实 CMS 命令、外部目标或 UAC。`TerminateJobObject`、后代成员枚举、同步调用硬总墙钟等未在本任务证明的事项保持独立缺口，不因为账本完成而放行 AUTH-170。

## 预算与停点

最多 2 轮本地固定来源静态核对，最多 2 轮上述微软官方页面限定读取；最后仅 1 次本 `plan.md` 的存在性、SHA-256、格式、允许路径核对。不得运行测试、Python 子进程、Job/Win32 API、ACL/注册表/Docker/WSL、UAC、CMS/解密/恢复、真实备份/密钥/DB、SSH/云/API，访问旧 `D:\EliteSync`，提交、pull 或 push。保留所有既有 dirty/untracked。作者不自接受、不派发后继；旧预算不重置。若资料不足，交 `NOT_FIXED` 而非扩展访问或尝试启动。
