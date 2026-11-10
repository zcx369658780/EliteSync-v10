# AUTH-174｜`PROCESS_INFORMATION` 官方声明与类型边界

**docs-only 作者候选，待 Work 独立 LEVEL 3 审查。** 本轮从任务限定的微软 Learn 页面取得 `PROCESS_INFORMATION` 完整 C 声明，补上 AUTH-173 的原始声明缺口；没有固定目标 Python/Windows ABI，也没有调用 Win32 API 或启动进程。AUTH-170 保持 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B、A/B 暂存和真实恢复保持 `NOT_READY`。

## 固定来源与声明

- 固定 URL：[PROCESS_INFORMATION structure (processthreadsapi.h)](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/ns-processthreadsapi-process_information)。本轮页面精确 `<title>` 为 `PROCESS_INFORMATION (processthreadsapi.h) - Win32 apps | Microsoft Learn`，两轮限定读取均返回 HTTP 200。
- 第一轮从页面可见的 **Syntax** 段取得 `typedef struct _PROCESS_INFORMATION {` 至 `} PROCESS_INFORMATION, *PPROCESS_INFORMATION, *LPPROCESS_INFORMATION;`；第二轮直接提取页面 HTML 的 `<pre><code>`，核对了同一段完整声明。分类：`VERIFIED_DOC_DECLARATION`。

```c
typedef struct _PROCESS_INFORMATION {
  HANDLE hProcess;
  HANDLE hThread;
  DWORD  dwProcessId;
  DWORD  dwThreadId;
} PROCESS_INFORMATION, *PPROCESS_INFORMATION, *LPPROCESS_INFORMATION;
```

上段固定的仅是**官方 C 声明中的四字段类型名、顺序与结构指针别名**：第 1、2 字段为 `HANDLE`，第 3、4 字段为 `DWORD`；`PPROCESS_INFORMATION` 与 `LPPROCESS_INFORMATION` 均在同一声明中写作指向 `PROCESS_INFORMATION` 的指针。该声明本身支持这些拼写和 C 层别名，不能据此推出当前 Python `ctypes` 的可调用输出缓冲。

## 类型边界及未固定项

本轮从该页面实际取得的材料没有 `HANDLE`、`DWORD` 的独立官方类型定义；在第二轮抽取的页面直接链接中也未取得可核对的类型定义页。因此这两个类型的目标宽度、指针表示及 `DWORD` 底层类型**没有**本轮的 `VERIFIED_DOC_TYPE` 证据，保持 `NOT_FIXED`。页面中的 `*PPROCESS_INFORMATION` 与 `*LPPROCESS_INFORMATION` 仅按原始 C 声明标为 `VERIFIED_DOC_DECLARATION`，不升级为目标 ABI 映射。

结构 `sizeof`、四字段偏移/对齐、目标 Windows 位宽、当前 Python `ctypes` 布局与调用约定、句柄生命周期在当前调用路径的实现、进程启动和失败清理、Job 纳入、同步调用硬总墙钟及进程树清空仍为后继缺口 `NOT_FIXED/UNRESOLVED`。本任务没有生成、测试或批准可调用 FFI；AUTH-173 的其他声明与旧预算不因本轮结论重置。

## 作者回执与停点

本地固定来源核对 **2/2 轮**：第一轮确认 `D:\EliteSync-v10`、本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、既有 dirty/untracked，以及根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、workflow 技能和本任务 `task.md`；第二轮只读 `TASK_CURRENT.md` 当前段及 AUTH-173 `plan.md`/`work-review.md`。微软 Learn 限定读取 **2/2 轮**，只访问上列固定官方 URL；第二轮未取得可核对的直接链接类型定义。唯一新增本 `plan.md`，其路径、存在性、SHA-256 和格式另作任务允许的最后一次核对。

`NOT_RUN`：测试、Python 子进程、Job/Win32 API、ACL/Docker/WSL/UAC、真实密文/密钥/DB、SSH/云/API；未访问 GitHub、第三方示例、本机 SDK/注册表、其他项目或旧 `D:\EliteSync`；未提交、pull 或 push。保留全部既有工作区内容。作者在 Work 独立 LEVEL 3 ACCEPT/REJECT 门前停止，不自接受、不派发后继。
