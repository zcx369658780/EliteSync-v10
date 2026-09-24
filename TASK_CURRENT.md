# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-24-ALIYUN-BACKUP-RESOURCE-CHOICE-PACKET`

Risk Level: `LEVEL 2`（备份资源与费用决策准备；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED`

Assignee: `Codex`。只交付 docs-only 候选，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 已决定：未来若确需修改阿里云后端数据库结构，先完成完整备份并验证可恢复；完整备份仅在阿里云内加密保存，自完成日起保留 30 天；优先核验私有 OSS 与受管密钥；恢复演练使用阿里云内独立隔离目标，演练副本恢复后清理。本任务只制作资源/费用决策包，不实施方案。

Work 于 2026-09-24 15:50～15:55（Asia/Shanghai）在已登录阿里云控制台只读观察：

| 页面与地域 | 当次可见事实 | 限制 |
|---|---|---|
| 轻量应用服务器详情，华东2（上海），`swasnext.console.aliyun.com/servers/cn-shanghai/678f6cf8de5f48ef8c7c2b394202be9a/monitor` | 公网 IP `101.133.161.203`，与此前授权目标一致；Owner 确认这是后端服务器页面。 | 不证明 Web worker 的 DB 目标或备份能力。 |
| OSS 控制台，`oss.console.aliyun.com` | 页面提示该账号尚未开通 OSS；开通后默认按量付费。 | 未开通；bucket、权限、生命周期和报价未核验。 |
| KMS 实例管理及密钥管理，华东2（上海） | 软件密钥管理实例列表显示“没有查询到符合条件的记录”；用户主密钥页显示“您已创建0个密钥”。 | 仅限当次页面和地域；默认密钥、权限、计费、配额未核验。 |
| ECS 实例列表，华东2（上海） | 显示“未查询到符合条件的实例”，并提示全部地域均未查询到实例。 | 不证明不存在其他类型的隔离恢复目标。 |
| RDS 实例列表，华东2（上海） | 页面持续停在加载占位画面，重载后仍无可判定列表。 | 实例数量和可用性均为 `UNKNOWN`，不得写作 0。 |

Owner 打开的 Cloud Shell 页面标明其云命令行虚拟机只有 1 小时使用期限；它默认不是上述轻量应用服务器。本任务不得在其中执行命令。以上只是当次控制台 UI 观察，不是云 API、账单、权限或生产配置核验。

## Exact candidate

唯一允许新增 `EVIDENCE/AUTH-24-ALIYUN-BACKUP-RESOURCE-CHOICE-PACKET/packet.md`。该文档须：

1. 引用上述观察与 AUTH-22/23 接受边界；分清已决定、已观察、`UNKNOWN` 和建议。
2. 提供供 Owner 选择的有界方案：继续优先评估私有 OSS、受管密钥与独立隔离恢复资源；或提出满足阿里云内加密、30 天保留及隔离恢复边界的其他候选。逐项写出所需资源、权限、解密路径、备份与演练副本清理责任、可能的持续费用类别。未经核实的金额写 `UNKNOWN`；不编造报价或声称零成本。
3. 列出真实备份前的最小只读核验门：实际 DB 目标及 CLI/Web worker 关系、数据类别与完整范围、一致性、空间/规模、目标存储及权限、加密和可解密路径、独立恢复目标与清理机制。只设计脱敏回执，不请求或展示账号、Token、消息、媒体、密钥值或业务数据行。
4. 明确需要 Owner 决定的资源/费用边界及下一张有界任务的最小范围。选择方案也不自动授权开通、购买、创建、备份、恢复、删除、部署或改库。

仅使用本地控制文件、上述 Work 观察及已接受的 AUTH-17/18/20/22/23 证据；不访问浏览器、SSH、云 API、账单、数据库或旧 `D:\EliteSync`。不得把轻量应用服务器等同于 ECS/RDS，也不得把 Cloud Shell 当作服务器 shell。

## Verification and stop

启动前核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能和上述接受记录。派发前已接受基线为 `8ab84e632fe38e9745b36b3e20b6659feb85efa2`；当前 HEAD 应为仅下达本任务的本地检查点，且其父提交须为该基线。若拓扑、任务状态、允许路径或工作区不符，停止并回报，不自行修复。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

候选仅新增上述一份 Markdown。运行 `git diff --check` 最多 1 次，并对新文档另做只读尾随空白检查；无产品测试或构建。Codex 不修改控制文件、不提交、不制作 bundle、不推送、不自接受或派发后继。完成后报告唯一差异、验证结果和未解决事项，停在 Work LEVEL 2 门。
