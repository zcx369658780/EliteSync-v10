# AUTH-182｜纯内存外部观察者与残留阻断回执

**作者候选，待 Work 独立 LEVEL 3 审查；仅 `SYNTHETIC_ONLY`。** 本任务只新增 `observer_gate.py`、`test_observer_gate.py` 与本回执。代码 SHA-256：`observer_gate.py` 为 `DF615EAEE2D9F89286994DE597C6EAAD094BBF130207BA833680BCE133A02E87`；`test_observer_gate.py` 为 `363AB4BEAE7CDB3DA876E78F3CB4CC5B43AC6B0A42FF902218ECAD8C2CFCA9C8`。既有 dirty/untracked 保留。

状态机初始化时接收一个非负整数**假绝对截止**；每次只接收预定义枚举事件与非负整数假时刻，返回不可变状态。启动、双流、清理、返回共用这一截止，不续期或重置；过期、启动未返回、清理未确认、IPC 中断、监督者失联、残留未知、截断、超限、认证失败和乱序均不可放行，迟到普通成功不能清除失败/未知。假消费者以固定虚构 **4 字节的计数**表示，不接收或返回真实字节；只有各阶段、模拟认证成功、模拟隔离就绪、模拟树清空按序且在截止内全部显式出现，才累计一次调用/4 字节，并标 `SYNTHETIC_ONLY`。

放行**之前**的失败、未知、超时、超限、截断、失联和重复/乱序请求均保持消费者 **0 次/0 字节**。已完成一次虚构放行后的重复 `RELEASE` 被记为 `DUPLICATE_RELEASE`，**不发生第二次交付**；此前已发生的计数仍为 1 次/4 字节，不能倒写成 0/0。这与 AUTH-169 的放行后实际计数保留边界一致。隔离请求本身不构成 `ISOLATION_READY` 事件，残留未知也不会被后续迟到事件自动写成清空。

本地固定来源核对 **2/2 轮**：根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、workflow 技能、本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be` 与 dirty/untracked、本任务 `task.md`，以及 AUTH-163/166/169/170/177/181 `work-review.md` 和 AUTH-181 `plan.md`。一次静态语法核对 **1/1**：两份 Python 文件 `ast.parse` 输出 `SYNTAX_OK`、退出码 0。唯一授权测试 **1/1**：`python -B -m unittest test_observer_gate.py` 首跑退出码 **0**，`Ran 14 tests`、`OK`，未复跑。

测试分别覆盖完全显式正例、启动迟返、双流过期、清理阻塞、监督者失联、IPC 中断、残留未知后的迟到成功、启动未返回、截断/超限、认证失败、认证/隔离/树清空乱序、提前放行、放行后重复请求和假时刻倒退。每个测试核对同一截止不变；未放行负例直接核对消费者 0/0，正例核对最多一次。

**未证边界**：这是纯内存事件逻辑；没有系统时钟、线程、进程、DLL、Win32/Job、真实监督者、IPC、真实认证/隔离、真实消费者或备份/DB。它不证明真实调用入口至返回的硬总墙钟、双流实际读取字节上限、进程树清空、残留隔离生效、明文防落盘或 AUTH-155 Phase B。AUTH-170 继续 `UNAVAILABLE/NOT_CHECKED`；真实恢复与账号回填仍 `NOT_READY`。未访问外网、GitHub、旧 `D:\EliteSync`、真实备份/密钥/DB、SSH/云/API、Docker/WSL/ACL/注册表或 UAC，未提交、pull 或 push；旧预算不重置。作者停 Work 独立 LEVEL 3 ACCEPT/REJECT，不自接受、不派发后继。
