# EliteSync v10｜TASK_CURRENT

Task ID: `APP-INT-07-RECOVERY-REVALIDATION-CONTRACT`

Risk Level: `LEVEL 2`（对话与消息恢复的权限/隐私边界；须由 Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。Work 已按 Owner 2026-09-23 的条件恢复方向下达本任务；本任务只形成设计候选，不授权实现、接受或后继任务。

## Objective / Why now

把“重启后允许在重新核验有效性后恢复对话、消息等信息”转成可审查、可测试、fail-closed 的恢复核验合同。APP-INT-06 只证明现有 synthetic/demo 重启后状态重新 seed；不能以当前本地 provider、既有 debug APK、缓存行或旧同意推断真实恢复权限。

## Sources to reconcile

- `PRODUCT_DECISIONS.md` 中 Owner 的条件恢复决定，以及 `EVIDENCE/APP-INT-06-RECOVERY-BASELINE/summary.md` 的设备/测试基线。
- `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md` §2–6：当前 participant/context/revision/freshness 绑定的 `CN_ACTIVE` 与独立 `MC_ACTIVE` 两输入 live gate；read/send 分离、send 时重查、重启/并发/撤销 fail-closed。
- `docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md` D-01～03、D-07～10：无授权历史只读、数据权利、保留与私密用途边界。
- 现有 Flutter Connection/Conversation contract、presentation provider、Home 投影；只用于标记当前 synthetic/dev 与目标 authoritative 能力差距。

## Deliverable / allowed paths

只可新增 `EVIDENCE/APP-INT-07-RECOVERY-REVALIDATION-CONTRACT/contract.md`，作为唯一主要结果。必要时可在同目录新增一份不含敏感数据的短执行回执。任务源文件只读；不得修改 `lib/`、test、backend、DB、依赖、环境、旧接受文档或 `PRODUCT_DECISIONS.md`。保留无关未跟踪目录。

合同须以精简表格或状态图明确：恢复前的锁定状态；需重新核验的身份/参与者、Connection aggregate/context、`CN_ACTIVE`、独立 `MC_ACTIVE`、purpose/audience、revision/currentness/freshness；何时允许 live read、何时允许 live send、何时仅可显示非私密占位。区分对话索引、消息正文、草稿、未读数与发送权限，不把缓存存在等同可见或可发。列出 fresh-valid、loading/unavailable、offline、stale、revoked、paused/closed、context mismatch、新 aggregate、冲突/乱序、send 期间失效的负向矩阵与下一步测试建议。

逐项列明“已由接受合同决定”“由本任务建议但尚未接受”“仍需 Owner/法律/后端 authority 决定”的内容。若发现恢复所需的本地保存范围、保留期限、离线历史查看、真实身份/服务端来源等没有既有 authority，只列为开放问题和可选方案，不自定政策。给出后续最小实现切片顺序及每片验收门；不得把设计候选写成已可运行的恢复机制。

## Verification budget / stop conditions

只做本地文档与源码静态核对；不运行 Flutter/Gradle、模拟器、PHP、HTTP、DB、网络或真实数据操作。检查新增路径、引用来源与文档内部一致性；不访问旧 `D:\EliteSync` 或刷新/推送 GitHub。若源合同存在实质冲突或需要新的 Owner 决策才能写出安全合同，明确冲突与决策点，停止该部分，不填补空白。交付候选与来源/检查回执后停在 Work LEVEL 2 独立审查门；Codex 不自行 ACCEPT、commit、备份或派发后继。
