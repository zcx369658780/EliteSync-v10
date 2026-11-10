# AUTH-169｜A/B 共同放行门纯虚构状态演练

**2026-09-27 Work 派发；LEVEL 3，synthetic-only。** Assignee：Codex 会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。只验证 AUTH-168 A/B 共同状态不变量，绝不接触真实 CMS、私钥、备份或 DB。唯一允许新增/修改本目录 `release_gate.py`、`test_release_gate.py`、`summary.md`。

先核对 `D:\EliteSync-v10` 根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能和 Git dirty 状态；固定来源只读 `EVIDENCE/AUTH-49-AUTHENTICATED-LOCAL-BACKUP-RESTORE-CONTRACT/contract.md`、`EVIDENCE/AUTH-168-DUAL-STAGING-FAILURE-STATE-CONTRACT/{plan.md,work-review.md}`。仅当文件缺失时记 `UNAVAILABLE`，不得扩展读取真实数据。

用固定虚构标记构造 A 与 B 两条纯内存状态路径；B 只模拟“加密暂存已封存”的**状态**，不实现加密、不创建文件。假消费者只计调用次数和虚构字节数。必须测试：CMS 有部分输出但认证非零、截断/篡改/错钥、容量超限、超时/中断、清理失败、对象身份替换、重复放行、正常认证后唯一放行，以及**放行后导入失败时保留实际消费量**。认证完成、捕获完整、输入/对象身份一致及暂存安全缺一不可；放行前任何失败均 0 次/0 字节，禁止补放行或自动重试。明确清理不明不等于已清理。代码只能接受内部固定场景名，不收外部命令、路径、正文、密钥或真实数据；回执只含状态和有限计数，绝不含虚构正文。两路测试须能发现假消费者被过早调用，而不是仅断言实现返回的一个常量。

最多 1 次定向测试首跑；若失败，允许修复后最多 1 次定向复跑，仍失败即停。测试前可做一次不执行代码的静态检查，使用禁写字节码 `python -B`，本目录不得留 `__pycache__` 或额外文件。结果如实区分合成状态演练与 AUTH-49 真实认证、AUTH-166 监督、AUTH-167 峰值内存、B 真实加密/路径/密钥及 DB 隔离，后者继续 `NOT_PROVEN`。交付后停 Work LEVEL 3 独立审查，不自接受、不派发后继。不得运行子进程、ACL/注册表/Docker/WSL、UAC、CMS/解密/恢复、真实备份/密钥/DB、SSH/云/API，访问旧 `D:\EliteSync`，提交、pull 或 push。保留所有原有工作区内容，旧预算不重置。
