# Project Sources瘦身与按需读取规则

生效：2026-11-01。适用于ChatGPT Project Sources及本仓库的长期同步。

## 1. 权威分层

1. 工程实时状态只认live GitHub main与`docs/workflow/ACTIVE_STATE.md`最新CURRENT ENTRY。
2. Session Handoff是导航摘要，不是状态数据库、任务合同或授权来源。
3. 冻结plan、Owner决定、正式任务、Astra验收和Codex运行回执各自保留原始身份；摘要不得覆盖原件。
4. `CODEX_REPORTED`、`LOCAL_ONLY`、`NOT_RUN`、`PENDING`不得改写成Astra直接核验或PASS。

## 2. Project Sources保留内容

只保留有长期复用价值的短索引、当前状态快照、稳定治理边界、Owner决定/路线摘要、必要设计参考、研究摘要、交接规则和历史导航。大型研究、旧handoff、旧状态、旧任务、完整验收与运行证据留在GitHub原路径。

Project Sources是按需参考库，不是每次会话的阅读清单。不得把完整ACTIVE_STATE、TASK_CURRENT、CURRENT、全量日志或整仓清单复制进Project Sources。相同正文不得用多个文件名重复装入。

## 3. 新会话首读与按需补读

首读仅三项：`AGENTS.md`全文 → `ACTIVE_STATE.md`最新CURRENT ENTRY → 最新具名Session Handoff。到此停止，不按Project Sources索引顺序全量读取。

只有目标明确后才补读：
- 正式任务：任务全文及其引用的当前冻结plan/专项合同。
- 产品/技术决策：直接相关的Owner决定、原始合同、源码、测试和验收证据。
- 历史追溯：通过archive map定位具名原件，不递归加载所有历史。

证据复用须保留Tree/Blob、适用范围和失效条件；仅在源码、环境、合同或风险边界相关变化时增量重验。

## 4. Session Handoff与任务Prompt

Session Handoff使用`SESSION_HANDOFF_TEMPLATE.md`六字段结构，目标300–600字，通常不超过1000字；只写本轮状态差异、下一目标、必要文件路径/Blob、Owner决定和STOP。旧handoff不删除，但不作为首读材料。

任务单采用八字段最小结构；启动Prompt只指向正式任务路径/Blob并给出fresh读取、范围、预算和STOP要求，不复制任务正文。具体规则见`TASK_DISPATCH_CLOSURE_PROTOCOL.md`。

## 5. 历史封存与安全

历史文件不删除、不重命名、不force-push、不覆盖原始证据。过期入口通过日期化索引标注为历史，不再首读；历史PENDING/NOT_RUN/授权状态仍是其形成时的事实。

私密SQL、真实个人数据、密钥、设备原始日志、LOCAL_ONLY APK/数据库和未脱敏运行证据不得进入公开GitHub或Project Sources。

## 6. ZIP与附件同步

每版生成日期化完整替换ZIP，包含唯一文件集合、README/索引和SHA256 manifest。不得叠加旧附件。ZIP生成、GitHub镜像、Owner手动替换Project附件和账户Memory更新是四件不同的事，分别报告，不声称自动同步。

Codex仅在Owner手动派发的文档同步任务范围内操作；项目源治理本身不授权产品代码、运行库、构建、Gradle、ADB、设备、系统策略、供应商或费用操作。
