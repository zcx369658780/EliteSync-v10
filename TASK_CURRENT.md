# EliteSync v10｜TASK_CURRENT

Task ID: `APP-INT-09-RECOVERY-AUTHORITY-SOURCE-MAP`

Risk Level: `LEVEL 2`（恢复所需的身份、Connection 与 Messaging Consent 权威来源映射；须由 Work 独立审查）

Status: `ACCEPTED — OWNER DECISION AND AUTHORITY SOURCES REQUIRED BEFORE REAL RECOVERY IMPLEMENTATION`

Work verdict (2026-09-23): `ACCEPT — STATIC SOURCE MAP; REAL RECOVERY AUTHORITY NOT ESTABLISHED`，见 `EVIDENCE/APP-INT-09-RECOVERY-AUTHORITY-SOURCE-MAP/source-map.md`。本任务已结束，不得重复执行或直接接入纯判定器。下一真实恢复实现任务须先明确本地私密数据保存/离线历史方向，并建立与审查当前身份、Connection、独立 Messaging Consent 的真实权威来源；当前没有后继实现任务授权。

Assignee: `Codex`。Work 在 APP-INT-08 的纯判定器通过 LEVEL 2 独立审查后下达本任务；本任务只交付只读来源映射，不授权实现、接受或后继任务。

## Objective / Why now

APP-INT-08 只对调用方提供的 typed claims 做一致性判定，不能证明其来自真实权威源。限定清查本地仓库中**已经存在**的身份/session、Product Connection、独立 Messaging Consent、Conversation lifecycle、revision/currentness/freshness 相关接口和实现，逐字段映射到恢复核验合同，指出缺失和阻断条件。把历史接受的设计、synthetic/dev 实现、实际 backend 代码、运行证据分开，不把任何文档或 mock 当作可用生产源。

## Allowed paths / sources

只可新增 `EVIDENCE/APP-INT-09-RECOVERY-AUTHORITY-SOURCE-MAP/source-map.md` 作为唯一主要结果；必要时同目录可新增一份短静态检索回执。只读消费 `CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、APP-INT-07/08 证据、BA-04/05 接受设计、现有 Flutter `apps/flutter_elitesync_module/lib/` 与 Laravel `app/`、相关配置/测试/已接受结果。优先用可用的代码图谱定位结构；图谱不可用时用受限路径文件搜索并说明。不得修改产品源码、测试、DB、依赖、配置、旧接受文档或控制文件；保留无关 untracked 目录。

## Deliverable and acceptance criteria

1. 对 APP-INT-08 每类输入（主体/参与者、Connection aggregate/context、`CN_ACTIVE`、`MC_ACTIVE`、purpose/audience、owner/provenance、独立 lineage/revision/currentness/freshness、Conversation lifecycle、read/send 再核验）列出候选来源的精确文件/类/方法与 Git blob，标明状态为 accepted contract、代码存在、synthetic-only、实际已接线、运行已证明或 UNKNOWN。无来源时明确写 `NOT ESTABLISHED`，不可凭名称推断。
2. 画出最短静态数据流：从可能的 backend authoring/evaluator/persistence 到客户端读取、恢复核验门及 read/send 消费者。每条连接标记已存在还是缺口；不得将未接通的两层画成完整链。
3. 核对是否存在无需真实服务/数据即可在本地证明的最小下一切片，及其明确的前置来源、反例和 LEVEL 2/3 验收门。若身份或独立 consent 来源未建立，建议只能继续做无真实权限的隔离工作，并列出需要 Owner、后端或法律确定的最少决策点。
4. 回执说明限定搜索范围、实际核对的路径/哈希、未运行项。只做静态读取，不声称 API、DB、设备或生产行为已验收。

## Verification budget / stop conditions

不运行 Flutter/Gradle、模拟器、PHPUnit/Artisan、HTTP/API、DB、网络、真实数据或远端同步。不得访问旧 `D:\EliteSync`。若发现来源合同互相冲突或需触及真实 auth、私密数据、生产服务才能进一步证明，在矩阵中标记冲突/UNKNOWN 并停在受影响范围。完成后交付候选，停在 Work LEVEL 2 独立审查门；Codex 不自行 ACCEPT、commit、备份或派发后继。
