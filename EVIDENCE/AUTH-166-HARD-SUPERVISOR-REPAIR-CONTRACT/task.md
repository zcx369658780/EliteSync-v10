# AUTH-166｜虚构监督器硬边界修复合同

**2026-09-27 Work 派发；LEVEL 3，docs-only。** Assignee：已完成只读交接的 Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。唯一交付为本目录新 `plan.md`；交付后停 Work 独立 LEVEL 3 审查。此任务不修复或运行 AUTH-163 代码，也不放行 AUTH-155 Phase B。

## 固定来源与目标

先核对 `D:\EliteSync-v10` 本地 `main`、HEAD、dirty 工作区及根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地工作流技能；再只读 `EVIDENCE/AUTH-163-SYNTHETIC-BOUNDED-PREFLIGHT-SUPERVISOR/{supervisor.py,test_supervisor.py,summary.md,work-review.md}`、`EVIDENCE/AUTH-164-ISOLATED-RESTORE-FEASIBILITY-DECISION-PACK/{plan.md,work-review.md}`、`EVIDENCE/AUTH-165-RESTORE-TARGET-ACL-EXPECTED-CONTRACT/work-review.md`。不存在的固定来源标 `UNAVAILABLE`，不扩展到真实备份、密钥或其他服务器资料。

在 `plan.md` 中逐项给出 AUTH-163 三处 REJECT 缺口的可验证修复合同：从调用入口到启动、读取、终止和返回的**总墙钟**；stdout/stderr 在底层实际读取与内存保留层面的每流硬字节上限（含超限见证字节、双流并发、异常）；Windows 进程树在正常、超时、超限、启动竞态及清理失败时的生存判据。每项写明拟用的本机原语或明确 `UNRESOLVED`、失败状态、最小虚构负例、测量方法、可证范围与剩余不可证范围。不得只把旧 `read()` 计数、直接子进程退出或上层 timeout 重新命名为硬保证。进程启动可能触发 UAC/服务/外部依赖的情况须列为停点。AUTH-49 的认证失败消费者 0 次/0 字节、明文防落盘、隔离引擎限额仍是独立门，不能由本合同推出。

## 允许路径、预算和停点

唯一允许新增/修改：`EVIDENCE/AUTH-166-HARD-SUPERVISOR-REPAIR-CONTRACT/plan.md`。最多 **2 轮**固定来源本地静态核对；最后只可对本 `plan.md` 做 1 次存在性、SHA-256、格式和允许路径核对。不得执行测试、虚构子进程、AUTH-155 命令、ACL/注册表/Docker/WSL/VM、UAC、CMS/解密/恢复/数据库、SSH/云/API；不得读取原 CMS 密文或私钥/密码，访问旧 `D:\EliteSync`，提交、pull 或 push。保留所有原有修改和未跟踪内容。若不能建立某项硬保证，结论明确 `UNRESOLVED`，不要临时引入新运行预算或将候选称为现场监督器。作者不自接受、不派发后继。
