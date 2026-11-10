# AUTH-173｜暂停态人工父进程的最小 ABI 原始声明

**2026-09-27 Work 派发；LEVEL 3，docs-only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-172 的有限来源账本已获 Work 限定接受，但 `CreateProcessW` 与两种必要结构的完整声明仍 `NOT_FIXED`。本任务只固定这一个缺口，为后续纯虚构 FFI 静态适配提供可核查原始资料；**不写 FFI、不运行任何 Win32 API 或人工进程**。唯一允许新增/修改本目录 `plan.md`，交付后停 Work 独立 LEVEL 3 审查。

## 精确范围

核对根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty 与 AUTH-172 `plan.md`/`work-review.md`。外部来源只限 `learn.microsoft.com` 的 `CreateProcessW`、`STARTUPINFOW`、`PROCESS_INFORMATION`、`Process Creation Flags` 页面，以及从这些页面直接链接、为解释字段类型必需的官方 Windows 类型定义。不可用或未实际抽取的部分记 `UNAVAILABLE/NOT_FIXED`；不访问 GitHub、第三方代码或本机 SDK/注册表。

在 `plan.md` 逐项列出固定 URL、页面可达状态与精确标题（如实际取得）、从官方**代码声明**逐字段抽取的顺序/类型、`CreateProcessW` 完整原型和成功/失败返回语义、`CREATE_SUSPENDED` 常量与线程初态；每项附短的原文标识和来源链接。明确区别 `VERIFIED_DOC_DECLARATION`、由类型定义支持的宽度/别名、以及 `NOT_FIXED`。不得从 C 声明推定本机 Python `ctypes` 的打包、对齐、调用约定、动态库解析、指针宽度或当前运行能力；这些仍须后继静态适配与独立审查。不得扩展到 Job 结构、进程树清理、CMS、备份或数据库。

## 预算与停点

最多 2 轮本地固定来源核对、2 轮上述微软官方页面限定读取；完成后仅 1 次 `plan.md` 的路径/存在性、SHA-256 与格式核对。不得运行测试、Python 子进程、Job/Win32 API、ACL/注册表/Docker/WSL、UAC、真实密文/密钥/DB、SSH/云/API，访问旧 `D:\EliteSync`，提交、pull 或 push。保留所有既有 dirty/untracked。作者预算与 AUTH-172 分开记录，旧预算不重置。资料不足就交 `NOT_FIXED`；不得为完成账本推断或执行。作者不自接受、不派发后继。
