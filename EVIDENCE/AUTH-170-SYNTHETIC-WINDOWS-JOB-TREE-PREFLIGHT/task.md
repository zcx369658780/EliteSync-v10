# AUTH-170｜Windows Job 进程树纯虚构能力预检

**2026-09-27 Work 派发；LEVEL 3，synthetic-only。** Assignee：Codex 会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。本切片只为 AUTH-166 的 Windows Job 候选收集局部虚构能力证据，不运行 AUTH-155 或接触真实数据。唯一允许新增/修改本目录的 `job_probe.py`、`test_job_probe.py`、`summary.md`。

先核对 `D:\EliteSync-v10` 根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能和 Git dirty 状态；固定来源只读 `EVIDENCE/AUTH-163-SYNTHETIC-BOUNDED-PREFLIGHT-SUPERVISOR/work-review.md`、`EVIDENCE/AUTH-166-HARD-SUPERVISOR-REPAIR-CONTRACT/{plan.md,work-review.md}`。若系统或工具不支持安全的固定虚构预检，明确 `UNAVAILABLE`，不要临时改用服务、UAC 或外部工具。

只使用当前 Python 可执行文件和内部固定人工脚本，`shell=False`，无网络/文件路径/任意命令输入。优先验证：受控人工父进程在**暂停态**创建、在执行前纳入本进程拥有的 Job、禁止 breakaway、Job 关闭/终止后父与人工后代是否均不存活；纳入失败时不得先恢复子进程，须有界地终止仍暂停的直接子进程并返回失败。负例至少包括人工后代存活、父进程先退和纳入失败模拟；每个启动与清理的固定上限、残留不确定状态及回执必须预先设定。任何可能触发 UAC、服务自动启动、外部命令或无法有界清理的路径在触发前停止并记 `UNAVAILABLE`。不得从 Job API 文档或父进程退出推断完整进程树清空；如不能证明后代身份/存活，记录 `TREE_UNCERTAIN`，不伪报 PASS。

最多 1 次定向测试首跑；只有首跑失败才可修复并最多复跑 1 次。测试前可做一次不执行代码的静态检查；`python -B` 且禁写字节码，本目录不得留 `__pycache__` 或额外文件。作者如实标记真实进程树、总墙钟、双流、CMS 与 DB 门仍未证。交付后停 Work LEVEL 3 独立审查，不自接受、不派发后继。不得运行 AUTH-155、ACL/注册表/Docker/WSL、UAC、CMS/解密/恢复、真实备份/密钥/DB、SSH/云/API，访问旧 `D:\EliteSync`，提交、pull 或 push。保留全部既有工作区内容；旧预算不重置。
