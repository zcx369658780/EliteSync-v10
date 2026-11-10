# AUTH-182｜纯内存外部观察者与残留阻断负例

**2026-09-27 Work 派发；LEVEL 3，synthetic only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-181 已接受 A/B 共用的安全下一切片：只在内存中模拟跨阶段同一绝对截止、监督者失联及残留未知时的消费者拒绝。唯一允许新增/修改本目录 `observer_gate.py`、`test_observer_gate.py`、`summary.md`；不运行 OS 进程、Win32、真实 CMS/DB 消费者或备份。作者完成后停 Work 独立 LEVEL 3 审查。

## 精确行为

先核对根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty，以及 AUTH-163/166/169/170/177/181 的 `work-review.md` 和 AUTH-181 `plan.md`。实现一个纯事件/假时钟 reducer：外部观察者在第一个阶段之前给出唯一绝对截止值；启动、双流、清理、返回阶段只能使用该同一个截止，不能重置或延长。输入仅为预定义枚举事件和非负整数假时刻；禁止 `time.sleep`、系统时钟、线程、子进程、网络和任意真实字节输入。越过截止、启动未返回、清理未确认、IPC 断开、监督者失联、重复或乱序事件均进入明确的不可放行失败/未知态；`RESIDUAL_UNKNOWN` 不能被后续迟到的普通成功事件自动清除。

假消费者只有在**全部**显式模拟认证成功、隔离就绪、进程树清空且未过同一截止后，才可被恰好放行一次；这是 `SYNTHETIC_ONLY` 正例，不可称真实认证、清空或硬时间保证。所有失败、未知、超时、截断、超限、失联场景的假消费者调用计数与交付字节必须为 **0/0**；返回只包含状态枚举、假时间与计数，不含凭据、进程 ID、句柄或真实数据。不得从“已发隔离请求”推断 `QUARANTINED` 已生效，未确认仍 `RESIDUAL_UNKNOWN`。

定向负例至少覆盖：启动调用在截止后才返回、双流阶段过期、清理阻塞、监督者失联、IPC 中断、残留未知后迟到成功、重复放行、乱序认证/隔离/清空；另设一个完全显式成功正例。测试检查每例唯一截止未重置、失败态不可恢复、0/0 与正例至多一次放行。`summary.md` 记录路径/哈希、测试首跑、预算和未证边界；不得把纯内存结果升级为 AUTH-170 Job 能力或 AUTH-155 Phase B。

## 预算与停点

最多 2 轮固定本地来源核对、1 次静态语法核对、**1/1 次** `python -B -m unittest test_observer_gate.py` 定向运行，最后 1 次三交付路径/哈希/格式核对。不得运行其它测试或重试；不得加载 DLL、调用 Win32、创建 Job/人工进程、使用线程/系统时钟/`subprocess`/`os.system`，不得访问真实备份/密钥/DB、AUTH-155、SSH/云/API、GitHub、旧 `D:\EliteSync`、Docker/WSL/ACL/注册表或触发 UAC。保留既有 dirty/untracked，不提交、pull 或 push。旧预算不重置；作者不自接受、不派发后继。
