# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-25-LOCAL-ENCRYPTED-DB-BACKUP-PREFLIGHT`

Risk Level: `LEVEL 2`（真实数据库的本地加密备份设计；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。仅交付 docs-only 候选，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 于 2026-09-24 改定：因 OSS 是付费服务，完整数据库备份保存到 Owner 的电脑或本地磁盘。此前“完整备份仅在阿里云内保存”及 OSS/KMS 优先路线不再是当前目标；加密、自完成日起保留 30 天、真实改库前先完成备份并验证可恢复仍有效。Owner 尚未修改“阿里云内独立隔离目标做恢复演练，演练副本恢复后清理”方向；其费用与资源需单独决定。当前没有真实备份、传输、恢复或删除。本任务只设计本地加密备份的实施前门和有界后继任务，不实施备份。

## Exact candidate

唯一允许新增 `EVIDENCE/AUTH-25-LOCAL-ENCRYPTED-DB-BACKUP-PREFLIGHT/plan.md`。该文档须：

1. 明确旧 AUTH-18/22/24 是其各自时点的历史方案与观察，不修改旧接受记录；列出这次 Owner 决定覆盖的存放/OSS/KMS 方向与继续有效的加密、30 天、可恢复和隔离演练要求。
2. 给出从阿里云服务器到 Owner 本地磁盘的候选数据流，要求传输前或传输中加密、传输与静态存储防止明文泄露；区分服务器临时文件、网络流、本地密文、密钥与恢复副本。不得将完整备份放入 Git、Git bundle、普通证据、聊天或任何第三方云服务。不得假定当前已具备可用的 DB 凭据、解密密钥或目标目录。
3. 列出真实操作前必须核验的项目和最小脱敏回执：精确 DB 实例身份及 CLI/Web worker 同库、数据类别和完整范围、一致性/工具兼容、备份体量与两端空间、Owner 本地目标的物理磁盘和访问边界、加密/密钥保管及失钥恢复、传输中断与校验、30 天清理和失败告警、独立恢复目标与费用。每一项未知即保留 `UNKNOWN`，不得推导生产就绪。
4. 提出严格分开的后继任务链：只读预检、Owner 确认精确本地目标及密钥/恢复安排、一次受限加密备份、密文完整性及解密校验、隔离恢复演练、30 天到期清理。说明每步的 STOP 与权限门；任何实际传输、备份、恢复、删除或改库都需要精确独立任务。指出阿里云内隔离恢复演练仍可能有付费资源，须在执行前向 Owner 提出具体费用/替代方案决定。
5. 只给方案和决策点，不提供可直接执行的真实数据库 dump/解密/删除命令或包含秘密的路径、参数、数据。若建议测试，只使用虚构数据且不在本任务运行。

仅使用本地 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、AUTH-17/18/20/22/23/24 已接受证据和本任务；不访问浏览器、SSH、云 API、数据库、账单、Owner 本地备份目录或旧 `D:\EliteSync`。不得读取 `.env`、凭据、私钥内容、账号/Token/消息/媒体或业务数据行。

## Verification and stop

启动前核对本地 `main`、HEAD、工作区及本地工作流技能。派发前已接受基线为 `c3e312298e0987b88e41ad9b40e46efdc418424c`；当前 HEAD 应为仅记录 Owner 决定并下达本任务的本地检查点，其父提交须为该基线。若拓扑、任务状态、允许路径或工作区不符，停止并回报，不自行修复。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

候选仅新增上述一份 Markdown。`git diff --check` 最多 1 次，新文档另作只读尾随空白检查；无产品测试或构建。Codex 不修改控制文件、不提交、不制作 bundle、不推送、不自接受或派发后继。完成后报告唯一差异、验证结果和未解决事项，停在 Work LEVEL 2 门。
