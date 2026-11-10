# AUTH-183｜假放行后失败状态修复回执

**作者候选，待 Work 独立 LEVEL 3 审查；仅纯内存 `SYNTHETIC_ONLY` 行为。** AUTH-182 Work LEVEL 3 REJECT 的精确缺陷是：首次放行后，旧 reducer 除第二次 `RELEASE` 外，对监督者失联、IPC 中断、残留未知及其他失败直接原样返回 `SYNTHETIC_ONLY`。本任务保留 AUTH-182 原三文件不改，只在本目录新增 `observer_gate.py`、`test_observer_gate.py` 与本回执。

代码 SHA-256：`observer_gate.py` 为 `27D5F8E31A14CF68C0479EA73F81C4BE621885BED3416146A7D4A1893F72C6E7`；`test_observer_gate.py` 为 `9243FB6F790E77301971650985E70CC9D6AC024E6E8AC5B52A1404C1C2B731A3`。相对旧候选，唯一控制流窄改是对**已完成首次虚构放行**的状态重新分类：假时刻倒退和重复/乱序事件为 `BLOCKED`；超过原绝对截止、启动/清理未确认、监督者/IPC 失联或残留未知为 `RESIDUAL_UNKNOWN`；认证失败、双流截断/超限为 `BLOCKED`。这些状态随后终止，不接受迟到成功或再放行。原截止不重置，已发生的假消费者 **1 次/4 字节**始终保留；第二次交付增量为 **0 次/0 字节**，不把历史计数倒写为零。

本地固定来源核对 **2/2 轮**：第一轮核对根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本任务 `task.md`、AUTH-182 `work-review.md`、`D:\EliteSync-v10` 的 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be` 及既有 dirty/untracked；第二轮只读 workflow 技能、AUTH-182 `task.md`/三份交付及 AUTH-169 `work-review.md`。两份新 Python 文件一次 `ast.parse` 语法核对 **1/1**：`SYNTAX_OK`、退出码 0。

唯一新预算定向运行 **1/1**：`python -B -m unittest test_observer_gate.py` 首跑退出码 **0**，`Ran 21 tests`、`OK`，未复跑。前置 14 场景沿用；新增负例直接覆盖放行后 `OBSERVER_LOST`、`IPC_DISCONNECTED`、`RESIDUAL_UNKNOWN`、启动/清理未确认、认证失败、截断/超限、原截止过期、假时间倒退、乱序普通成功、重复放行及 schema 外输入。每个放行后状态负例核对最终状态与原因、原截止、历史 1/4，且再送 `RELEASE` 不增加字节；放行前失败仍为 0/0。

**未证边界**：上述只是 enum 事件和非负整数假时刻的内存 reducer；没有系统时钟、线程、进程、DLL、Win32/Job、真实 IPC、CMS/DB 消费者、备份或明文。它不证明真实硬总墙钟、进程树清空、残留隔离或真实认证失败消费者 0/0。AUTH-170 继续 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B、真实恢复与账号回填仍 `NOT_READY`。未访问 GitHub、旧 `D:\EliteSync`、真实备份/密钥/DB、SSH/云/API、Docker/WSL/ACL/注册表或 UAC；未提交、pull 或 push。旧 AUTH-182 预算不重置，全部既有 dirty/untracked 保留。作者停 Work 独立 LEVEL 3 ACCEPT/REJECT，不自接受、不派发后继。
