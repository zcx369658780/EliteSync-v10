# AUTH-168｜A/B 暂存失败状态与放行合同

**2026-09-27 Work 派发；LEVEL 3，docs-only。** Owner 已明确允许继续**设计** A 严格内存与 B 受控加密暂存两条方案；这不是 B 真实落盘或 CMS 解密授权。Assignee：Codex 会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。唯一交付本目录新 `plan.md`，交付后停 Work LEVEL 3 独立审查。

## 固定来源和结果

先核对 `D:\EliteSync-v10` 根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md` 对 A/B 的新决定、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地工作流技能与 Git dirty 状态。再只读 `EVIDENCE/AUTH-49-AUTHENTICATED-LOCAL-BACKUP-RESTORE-CONTRACT/contract.md`、`EVIDENCE/AUTH-153-LOCAL-ISOLATED-RESTORE-PREFLIGHT/plan.md`、`EVIDENCE/AUTH-164-ISOLATED-RESTORE-FEASIBILITY-DECISION-PACK/{plan.md,work-review.md}`、`EVIDENCE/AUTH-165-RESTORE-TARGET-ACL-EXPECTED-CONTRACT/work-review.md`、`EVIDENCE/AUTH-166-HARD-SUPERVISOR-REPAIR-CONTRACT/work-review.md`、`EVIDENCE/AUTH-167-SYNTHETIC-RAW-DUAL-STREAM-READER/work-review.md`。缺失则记 `UNAVAILABLE`，不搜索真实数据位置。

`plan.md` 为 A/B 各自给出从加密输入身份核对、Owner 非回显输入、认证前封存、认证失败、完整成功、唯一 DB 消费者放行、导入失败、清理/残留的**状态转换表**。每次转换注明允许接触主体、可能存在的明文/密文副本、何时消费者必须 0 次/0 字节、放行后失败应记录的实际消费量、超限/超时/中断/清理不明的失败隔离。A 要列 Windows pagefile/WER/休眠/运行时副本/锁页失败的证据需求；B 要列受控介质与精确路径、加密层、暂存密钥生灭、ACL/同步/残留/容量和 Owner 日后须具体选择的项。共同门与仅 A、仅 B 的门分开，逐条指出可用**纯虚构**负例验证什么、不能证明什么。不得重复把 AUTH-167 单块计数说成峰值证明，也不得设计认证前解密 stdout 直通 DB。

把 A/B 当前结论均保持 `NOT_READY`，明确 B 具体介质、位置、密钥生命周期和残留风险未获 Owner 选择。不得在文档中写可直接执行真实数据的命令或默认准许任何明文落盘。原 CMS 密文不覆盖、不删除；导出时独立比较源与无冲突 DDL 仍 `UNKNOWN`。

## 预算与停点

唯一允许新增/修改 `EVIDENCE/AUTH-168-DUAL-STAGING-FAILURE-STATE-CONTRACT/plan.md`。最多 **2 轮**固定来源静态核对；最后只可做 1 次交付存在性、SHA-256、格式与允许路径核对。不得运行测试、子进程、ACL/注册表/Docker/WSL、UAC、CMS/解密/恢复、真实备份/密钥/DB、SSH/云/API，访问旧 `D:\EliteSync`，提交、pull 或 push。保留原有全部工作区内容；作者不自接受、不派发后继，旧预算不重置。
