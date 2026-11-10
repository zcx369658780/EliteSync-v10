# AUTH-183｜假放行后的失联与残留状态修复

**2026-09-27 Work 派发；LEVEL 3，synthetic only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-182 Work LEVEL 3 REJECT：首次假放行后发生监督者失联等失败时仍报告 `SYNTHETIC_ONLY`。本任务只修该放行后分类缺口，保留 AUTH-182 原三文件不修改；仅允许新增/修改本目录 `observer_gate.py`、`test_observer_gate.py`、`summary.md`。候选可从 AUTH-182 的两个 Python 文件复制后窄改；交付后停 Work 独立 LEVEL 3 审查。

## 精确要求

先核对根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty，以及 AUTH-182 `task.md`、三份交付和 `work-review.md`，AUTH-169 `work-review.md`。保持原先唯一绝对截止、纯内存事件、放行前失败 0 次/0 字节的行为。**首次假放行后**，任何监督者失联、IPC 断开、残留未知、启动/清理未确认、认证失败、双流截断/超限、截止过期、倒退时间、重复 `RELEASE` 或乱序成功事件，都不能继续报告 `SYNTHETIC_ONLY`；按性质变成明确的 `RESIDUAL_UNKNOWN` 或 `BLOCKED`，之后保持终态，不再交付。已发生的虚构消费者计数必须保留真实值 **1 次/4 字节**，不能因后续失败重写为 0/0。事件 schema 之外的输入仍拒绝，不引入系统时钟、线程、进程或真实数据。

定向测试沿用 AUTH-182 的前置 14 场景并新增至少：放行后 `OBSERVER_LOST`、`IPC_DISCONNECTED`、`RESIDUAL_UNKNOWN`、认证失败、截止过期、时间倒退、乱序普通成功及重复放行；分别断言最终状态、原因、计数 1/4 和不可恢复。测试不得只断言调用次数，还须证明后续 `RELEASE` 不再增加字节。`summary.md` 记录原拒绝点、窄改、哈希、首跑预算和未证边界；仍只可称 `SYNTHETIC_ONLY`/纯内存行为，不证明真实硬墙钟或残留清理。

## 预算与停点

最多 2 轮固定本地来源核对、1 次静态语法核对、**1/1 次** `python -B -m unittest test_observer_gate.py` 定向运行，最后 1 次三交付路径/哈希/格式核对。不得修改 AUTH-182 原文件；不得重跑其旧预算，不运行其它测试或重试；不得加载 DLL、调用 Win32、创建 Job/人工进程，使用系统时钟、线程、`subprocess`、`os.system`，访问真实备份/密钥/DB、AUTH-155、SSH/云/API、GitHub、旧 `D:\EliteSync`、Docker/WSL/ACL/注册表或触发 UAC。保留既有 dirty/untracked，不提交、pull 或 push。作者不自接受、不派发后继。
