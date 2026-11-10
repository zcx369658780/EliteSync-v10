# AUTH-184｜Job 限制结构的纯静态 Python 候选布局

**2026-09-27 Work 派发；LEVEL 3，synthetic/static only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-178/180 只接受微软官方 Job 限制结构与嵌套声明；AUTH-179 部分类型来源和 AUTH-176 静态探针不能证明可调用 ABI。本任务仅在当前 Python 解释器中测量**候选** `ctypes` 结构大小/字段偏移，不加载 Windows DLL、不调用 Win32 或创建 Job/进程。唯一允许新增/修改本目录 `layout_probe.py`、`summary.md`，交付后停 Work 独立 LEVEL 3 审查。

## 精确范围

先核对根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty，以及 AUTH-175/176/178/179/180 的 `plan.md`/`work-review.md`（AUTH-176 只需探针与审查）。`layout_probe.py` 仅可导入标准库 `ctypes`、`json`、`platform`、`struct`、`sys`；按已接受微软声明的字段名/顺序静态定义 `LARGE_INTEGER` 两个 struct 成员及 union、`IO_COUNTERS`、`JOBOBJECT_BASIC_LIMIT_INFORMATION`、`JOBOBJECT_EXTENDED_LIMIT_INFORMATION`。`DWORD`、`LONG`、`LONGLONG`、`ULONGLONG`、`SIZE_T`、`ULONG_PTR` 的 Python 类型只作为**候选映射**逐项列明；若需要未证宏/别名，记录 `NOT_FIXED`，不猜成已验证 ABI。

脚本只输出固定 JSON schema：解释器/OS/指针大小、候选基础类型大小、四个结构的 `sizeof` 与各字段偏移、固定宽度冲突时 `UNAVAILABLE`、否则 `STATIC_LAYOUT_ONLY`，以及未证清单。不得输出环境变量、用户目录、命令行、句柄、真实进程信息或敏感路径。只运行一次 `python -B layout_probe.py`；不运行测试套件。`summary.md` 记录脚本 SHA-256、命令退出码、脱敏数值摘要、对应官方声明和未证边界。测量不能证明 C ABI 对齐/调用约定、Job 设置/读回、成员清空、硬总墙钟或 AUTH-155。

## 预算与停点

最多 2 轮固定本地来源核对、1 次静态语法核对、**1/1 次**上述探针运行，最后 1 次两交付路径/哈希/格式核对。不得加载 DLL 或使用 `ctypes.windll`/`WinDLL`/`CDLL`，不得调用 Win32、Job/人工进程、编译器、其它测试、AUTH-155、ACL/Docker/WSL/UAC、真实密文/密钥/DB、SSH/云/API，访问 GitHub、旧 `D:\EliteSync`，提交、pull 或 push。保留既有 dirty/untracked，旧预算不重置；作者不自接受、不派发后继。
