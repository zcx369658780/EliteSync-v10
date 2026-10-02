# AUTH-177｜纯虚构恢复前失败关闭状态机

**2026-09-27 Work 派发；LEVEL 3，synthetic only。** Assignee：现有 Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-171 已接受暂停态纳入 Job 的顺序候选，AUTH-176 仅测得静态 `ctypes` 候选布局；本任务只用**内存中的假 Win32 适配器**验证恢复前失败关闭的控制流，不加载 DLL、不调用 Win32、不启动进程。唯一允许新增/修改本目录 `pre_resume.py`、`test_pre_resume.py`、`summary.md`。作者交付后停 Work 独立 LEVEL 3 审查。

## 目标与允许行为

先核对根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md` 相关决定、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty，以及 AUTH-171 `plan.md`/`work-review.md`、AUTH-174/175/176 `work-review.md`。实现一个不含平台调用的最小函数，接收由测试提供的假适配器和固定人工身份标识。仅模拟 `create_job → configure_limits → create_parent_suspended → assign_parent → verify_membership → resume_parent` 的顺序；任一步的失败、异常或未知必须停止后续正向调用。`resume_parent` 仅在前五步全部明确成功时恰好调用一次。

人工父已被假接口表示为“创建”后、恢复前任一步失败时，必须先记录 `NO_RESUME`，再通过假接口请求终止**该精确直接父**并做有限等待，区分 `TERMINATED_CONFIRMED`、`WAIT_TIMEOUT`、`TERMINATE_FAILED`、`HANDLE_UNKNOWN`；任何未知或清理失败都输出 `RESIDUAL_UNKNOWN`，不得输出 `TREE_CLEARED`。父创建前失败不得尝试终止不存在的父。所有结果只包含枚举状态与假调用顺序，不包含任意进程 ID、句柄或真实命令。假适配器不得隐藏调用、隐式创建对象或将返回非空视为已核成员身份。

定向测试至少覆盖：创建 Job 失败、设置限制失败、暂停创建失败/返回句柄未知、分配失败且终止等待成功、分配失败且等待超时、成员身份核对未知、全部前置成功时仅一次假恢复；至少一个假接口抛异常的负例。检查每个前置失败后 `resume_parent` 计数为 0、清理调用顺序与最终状态。成功分支只能命名 `SYNTHETIC_PRE_RESUME_PASSED`，不能声明本机 Job、进程树或硬总墙钟能力。

## 预算与停点

最多 2 轮固定本地来源核对、1 次静态语法核对、**1/1 次** `python -B -m unittest test_pre_resume.py` 定向运行，最后 1 次三交付路径/哈希/格式核对。不得加载 DLL 或使用 `ctypes.windll`/`WinDLL`/`CDLL`，不得调用 Win32、`subprocess`、`os.system`、PowerShell 子进程或创建人工父/后代；不得读取真实备份/密钥/DB、运行 AUTH-155、访问 SSH/云/API、GitHub、旧 `D:\EliteSync`、Docker/WSL/ACL/注册表或触发 UAC。保留所有既有 dirty/untracked，不提交、pull 或 push。旧任务预算不重置。此任务不放行 AUTH-170、真实 CMS 或数据库消费者；作者不自接受、不派发后继。
