# AUTH-164｜本机隔离恢复可行路径与 Owner 决策包

状态：`ISSUED`；风险 LEVEL 3，**本轮仅 docs-only**。派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；唯一主要交付同目录 `plan.md`，交付后停 Work 独立 LEVEL 3 审查。不得把方案写成现场授权。

## 固定入口与来源

先核对 `D:\EliteSync-v10` 本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、dirty 工作区及当前任务。只读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能；双库交接 `handoff.md`；AUTH-49 `contract.md` 的认证失败消费者 0/0；AUTH-153 `plan.md` 尾部 Work 接受；AUTH-154 `plan.md`/`work-review.md`；AUTH-155 `plan.md`/`work-review.md`；AUTH-163 `summary.md`/`work-review.md`。不得访问旧 `D:\EliteSync`、备份/密钥目录、`.env`、Docker/WSL、注册表、服务器或业务行，不搜索其他证据补缺口。AUTH-153 独立 review 实际在其 `plan.md` 尾部，不引用不存在的 `work-review.md`。

## 唯一交付 `plan.md`

1. 将当前恢复目标拆成四个互不代替的证明：CMS 认证解密且失败消费者 0/0、本机隔离数据库目标、两库逐对象/行数恢复核对、导出时源清单与无冲突 DDL。后两项的导出时证据缺失须维持 `UNKNOWN`，不得用事后快照追认。
2. 对照至少两条**候选**路径：A 为无交换/转储的受控内存暂存及本机隔离计算环境，B 为若 A 不可证时另审的加密暂存/等价受控落盘。逐项写出受信边界、能否强制字节/墙钟/资源上限、明文可能副本、ACL/同步/网络/挂载/端口、认证失败消费者 0/0、成功后清理及失败保留回执；不假定 Windows、Docker、VM 或文件加密已满足。B 若涉及任何获准明文或加密暂存盘，其精确路径、密钥生命周期、权限/同步、容量、清理责任及残留风险须列为 Owner 具体选择，不能默认许可。
3. 明确 AUTH-155 当前目标候选 `D:\EliteSync-v10-Restore-Isolation-20260927` 仍只是路径文字，未创建、未审 ACL；AUTH-163 六个虚构场景不能提供现场 PowerShell/进程树/底层读取的硬监督。镜像摘要、可强制资源上限、无自动启动、pagefile/WER/锁页等现状均不得猜定。给每个缺口一个可单独派发的**无 UAC、无真实数据**后继静态或 synthetic 核对任务候选，明确能够证明的上限及不应运行的动作。
4. 形成一份供 Work/Owner 选择的最小决策表：要达成“隔离恢复验证”所需的敏感数据暂存方式、能接受的残留副本/清理风险与 Owner 现场输入密码的条件。若两条路径都不能满足已接受硬门，结论应为 `NOT_READY`，不能借本次 Owner 一般 SSH 授权、GitHub 不可用或 30 天保留时限降低标准。别将两个备份库的账号集合或来源优先级提前定下。
5. 给出严格下一顺序：Work LEVEL 3 审查本包 → Owner 对敏感暂存/残留风险的具体决策（若确需）→ 新有界本机预检与独立门 → Owner 现场“我在”及真实密码非回显输入 → 另行授权一次真实认证/恢复；失败不得让任何输出进入 DB。不得提出本次执行命令、解密脚本或实际恢复计划的自动派发。

最多两轮固定来源静态核对；仅新增本目录 `plan.md`，记录检查轮数、事实/推断区分及 `NOT_RUN`。不运行任何测试、构建、Docker/WSL/VM、PowerShell 现场表达式、UAC、备份/密钥/CMS、SSH/云/DB；不提交、拉取或推送。保留全部原有修改及未跟踪目录。作者停 Work LEVEL 3 ACCEPT/REJECT，不自接受或启动后继。
