# AUTH-178｜Job 关闭清理限制的官方来源账本

**2026-09-27 Work 派发；LEVEL 3，docs-only。** Assignee：现有 Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-177 只证明纯内存恢复前失败关闭，真实 Job 仍 `UNAVAILABLE/NOT_CHECKED`。本任务只固定 Windows Job 的 `KILL_ON_JOB_CLOSE` 限制及设置/读回所需的官方声明事实；不写 FFI、不运行 Win32 API、不创建 Job 或人工进程。唯一允许新增/修改本目录 `plan.md`，交付后停 Work 独立 LEVEL 3 审查。

## 精确范围

先核对根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty，以及 AUTH-171 `plan.md`/`work-review.md`、AUTH-175/176/177 `work-review.md`。外部只限微软 Learn 的 `JOBOBJECT_BASIC_LIMIT_INFORMATION`、`JOBOBJECT_EXTENDED_LIMIT_INFORMATION`、`SetInformationJobObject`、`QueryInformationJobObject`、`Job Objects` 官方页面及从这些页面直接链接的限制标志/信息类官方定义；不访问 GitHub、第三方示例或本机 SDK/注册表。

在 `plan.md` 逐项记录固定 URL、实际取得的页面标题/HTTP 状态、从正文或代码声明**实际抽取**的结构字段顺序与类型、`LimitFlags` 与 `JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE` 的关系、`JobObjectExtendedLimitInformation` 信息类来源、设置/查询返回与失败类别、需要的 Job 访问权和最后句柄关闭语义。未抽取或官方未说明的项一律 `NOT_FIXED`；仅能逐字支持的最短事实标 `VERIFIED_DOC_FACT/DECLARATION`。分清官方 API 语义、Python/Windows ABI、本机运行证据，不得由页面可达性推断限制已设置或后代已清空。若结构完整声明或常量数值不可得，记录缺口，不拼凑可调用布局。`AssignProcessToJobObject` 的具体权限、嵌套 Job、成员核对、硬总墙钟另列为未证，不在本任务补作结论。

## 预算与停点

最多 2 轮固定本地来源核对、2 轮限定微软官方页面读取，最后仅 1 次 `plan.md` 路径/存在性、SHA-256、格式核对。不得运行测试、FFI、Win32 API、Job/人工进程、AUTH-155、ACL/Docker/WSL/UAC、真实密文/密钥/DB、SSH/云/API，访问旧 `D:\EliteSync`，提交、pull 或 push。保留全部既有 dirty/untracked，旧预算不重置。作者不自接受、不派发后继。
