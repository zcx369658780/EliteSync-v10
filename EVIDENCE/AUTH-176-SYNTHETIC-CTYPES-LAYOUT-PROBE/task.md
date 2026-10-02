# AUTH-176｜纯静态 Python `ctypes` 布局探针

**2026-09-27 Work 派发；LEVEL 3，synthetic/static only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-173/174/175 只固定官方 C 声明与类型来源，尚未测量当前机器的 Python 布局。本任务在**不加载 Windows DLL、不调用 Win32、不启动人工父/后代**的条件下，构造最小 `ctypes.Structure` 候选并只读取本机类型大小/字段偏移。唯一允许新增/修改本目录的 `layout_probe.py`、`summary.md`；交付后停 Work 独立 LEVEL 3 审查。不是可调用 FFI 或现场监督器。

## 精确范围

先核对根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty，和 AUTH-173/174/175 的 `plan.md`/`work-review.md`。`layout_probe.py` 只可导入 Python 标准库 `ctypes`、`json`、`platform`、`struct`、`sys`；静态定义 `STARTUPINFOW`、`PROCESS_INFORMATION`，字段顺序严格照已接受官方声明。可选择 `DWORD=c_ulong`、`WORD=c_ushort`、`BOOL=c_int`、`HANDLE=c_void_p`、字符串/字节/结构指针等**候选映射**，但必须把选择与官方事实分层，不得在代码或回执中宣称映射已由文档直接证明。脚本只输出固定 schema 的 JSON：解释器/OS/指针大小、候选类型大小、两个结构的 `sizeof`、每个字段偏移，以及 `STATIC_LAYOUT_ONLY` 和未证清单；不得输出环境变量、用户目录、命令行或敏感路径。

只运行一次 `python -B layout_probe.py`，不运行测试套件。`summary.md` 记录脚本 SHA-256、命令退出码、脱敏 JSON 摘要、官方来源对应关系和所有未证边界。若不是 Windows 或类型大小与官方固定宽度事实冲突，输出 `UNAVAILABLE`，不修改映射重试；如果运行异常，记录精确错误类别并停。任何运行结果都不证明 Windows C ABI 对齐、调用约定、`argtypes`/`restype`、进程创建/失败清理、Job、硬总墙钟或进程树清空。

## 预算与停点

最多 2 轮固定本地来源核对、1 次脚本静态语法核对、**1/1 次**上述纯静态脚本运行、最后 1 次两交付的路径/哈希/格式核对。不访问外网、GitHub、旧 `D:\EliteSync`、本机 SDK/注册表、真实备份/密钥/DB、SSH/云/API；不加载 DLL、不用 `ctypes.windll`/`WinDLL`/`CDLL`，不调用 Win32 API，不生成/启动子进程，不触发 UAC、Docker/WSL/ACL，不提交、pull 或 push。保留既有 dirty/untracked。旧任务预算不重置，作者不自接受、不派发后继。
