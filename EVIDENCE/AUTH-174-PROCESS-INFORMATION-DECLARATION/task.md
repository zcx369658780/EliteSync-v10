# AUTH-174｜PROCESS_INFORMATION 完整声明与类型边界

**2026-09-27 Work 派发；LEVEL 3，docs-only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-173 只取得 `CreateProcessW` 与 `STARTUPINFOW` 原始声明，`PROCESS_INFORMATION` 完整声明仍 `NOT_FIXED`。本任务只填这一个源文档缺口并标清类型边界；不写 FFI、不调用 Win32 API、不启动进程。唯一允许新增/修改本目录 `plan.md`，交付后停 Work 独立 LEVEL 3 审查。

## 精确范围

核对 `D:\EliteSync-v10` 根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty、AUTH-173 `plan.md`/`work-review.md`。外部只限微软 Learn 的 [PROCESS_INFORMATION](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/ns-processthreadsapi-process_information) 页面，以及由该页直接链接且解释 `HANDLE`、`DWORD` 与 `LPPROCESS_INFORMATION` 所必需的官方 Windows 类型定义。不得访问 GitHub、第三方示例、本机 SDK/注册表或其他项目。

在 `plan.md` 给出页面精确标题和可达状态；尽可能从官方**代码声明**完整逐字段记录顺序、类型和指针别名，并说明哪些宽度/别名由实际取得的官方类型定义支持。可以直接检查该页 HTML 中的代码块与可见正文；不要因 AUTH-173 的抽取失败而猜测。保留短原文标识及固定 URL，区别 `VERIFIED_DOC_DECLARATION`、`VERIFIED_DOC_TYPE` 和 `NOT_FIXED`。若两轮限定读取后仍拿不到完整声明，交出可复核的失败分类与 `NOT_FIXED`，不得把 AUTH-172 局部字段拼成完整声明。Python `ctypes` 布局、当前 Windows 位宽、调用约定、进程启动/清理、Job 与硬总墙钟全部保持后继缺口。

## 预算与停点

最多 2 轮本地固定来源核对、2 轮上述微软官方页面限定读取；最后仅 1 次 `plan.md` 路径、存在性、SHA-256、格式核对。不得运行测试、Python 子进程、Job/Win32 API、ACL/Docker/WSL/UAC、真实密文/密钥/DB、SSH/云/API，访问旧 `D:\EliteSync`，提交、pull 或 push。保留所有既有 dirty/untracked。旧任务预算不重置；作者不自接受、不派发后继。
