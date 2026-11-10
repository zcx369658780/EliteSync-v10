# AUTH-171｜Windows Job 暂停态纳入与失败清理静态合同

**2026-09-27 Work 派发；LEVEL 3，docs-only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。本任务仅为 AUTH-170 `UNAVAILABLE/NOT_CHECKED` 停点准备可独立审查的 Win32 原语与失败状态合同，不运行 Job、人工进程、AUTH-155 或任何真实恢复动作。唯一允许新增/修改本目录 `plan.md`；交付后停 Work 独立 LEVEL 3 审查。

## 固定来源与交付

先核对 `D:\EliteSync-v10` 的根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty；再只读 `EVIDENCE/AUTH-166-HARD-SUPERVISOR-REPAIR-CONTRACT/{plan.md,work-review.md}` 与 `EVIDENCE/AUTH-170-SYNTHETIC-WINDOWS-JOB-TREE-PREFLIGHT/{task.md,summary.md,work-review.md}`。外部资料仅限微软官方 Learn 的 `CreateProcessW`/`CREATE_SUSPENDED`、`CreateJobObjectW`、`SetInformationJobObject`/`JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE`、`AssignProcessToJobObject`、`ResumeThread`、`TerminateProcess`/`TerminateJobObject`、`WaitForSingleObject`、`QueryInformationJobObject` 与 Job breakaway/嵌套语义的精确页面；若页面不可读，标 `UNAVAILABLE`，不得用非官方片段替代或凭记忆声称已核对。

在 `plan.md` 中固定**只针对当前 Python 的固定人工父/后代**的待实现状态机：创建 Job 并设置不允许 breakaway 的约束 → 人工父在暂停态创建 → 在恢复前纳入 Job → 仅在纳入/身份检查成功后恢复；各 API 调用失败或返回未知时如何保持父进程未执行、终止并有界等待、关闭句柄、记录残余 `TREE_UNCERTAIN`。列出必要的权限/句柄所有权、Windows ABI 结构与常量的来源、父先退出/后代存活/分配失败/监督者故障负例、可观察的 Job 成员/后代身份及所有阶段共用墙钟预算的**候选测量方法**。不得把同步 `CreateProcessW`、`AssignProcessToJobObject` 或 `WaitForSingleObject` 的上层 timeout 冒充可强制的总墙钟；若无法提供硬上界，明确 `UNRESOLVED` 并把后继现场测试条件分开。不得写可直接运行真实命令或任意输入的脚本。

## 预算与停点

最多 2 轮本地固定来源静态核对，加 1 轮上述微软官方页面限定核对；最后只可对本 `plan.md` 做一次存在性、SHA-256、格式和允许路径检查。不得执行测试、Python 子进程、Job/API 调用、ACL/注册表/Docker/WSL、UAC、CMS/解密/恢复、真实备份/密钥/DB、SSH/云/API，访问旧 `D:\EliteSync`，提交、pull 或 push。保留所有既有 dirty/untracked。作者只交 docs-only 候选，不自接受、不派发后继；旧预算不重置。即使合同获接受，AUTH-170 能力仍 `NOT_CHECKED`，真实恢复仍 `NOT_READY`。
