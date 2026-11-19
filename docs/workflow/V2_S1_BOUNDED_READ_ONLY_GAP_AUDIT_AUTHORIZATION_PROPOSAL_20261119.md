# EliteSync V2｜S1一次性受限只读工程差距核查：Owner授权草案 V0.1

日期：2026-11-19（Asia/Singapore）  
状态：`ADVISOR_AUTHORIZATION_PROPOSAL_ONLY / OWNER_S1_AUTHORIZATION_NOT_GRANTED / CODEX_NOT_AUTHORIZED / NO_ENGINEERING_ACTIONS`  
治理分支：`governance/home-matching-product-freeze-20261117`  
编制依据：[当前一页权威](V2_CURRENT_AUTHORITY_ONE_PAGE_20261119.md)、[集中未来证据准备包](V2_CONSOLIDATED_FUTURE_EVIDENCE_READINESS_DOSSIER_V0_1_20261119.md)、[具名Owner决策索引](../product/ELITESYNC_V2_OWNER_ACCEPTED_SOURCE_INDEX_AND_AUDIT_SNAPSHOT_20261119.md)、[两批顾问静态规格](../product/ELITESYNC_V2_BATCH_OTHER_DESIGN_SINGLE_PASS_STATIC_REVIEW_V0_1_20261119.md)、[评论/删除静态规格](../product/ELITESYNC_V2_BATCH_CONTENT_SINGLE_PASS_UX_STATE_DRAFT_V0_1_20261119.md)。

**本文件不是指令或任务单。未收到Owner对S1的另行明确授权之前：不派发Codex、不读取本地工程、不运行任何测试、命令或设备、不变更工作区。**

## 1. S1目标：一次交付真实差距，而不是再分拆十次微型审计

仅在以后Owner独立授权时，对**Owner当时指定并确认的本地工作树**进行静态只读现状核查，回答三个问题：

1. 具名Owner接受的V2业务规则，在当前真实工程中分别属于`PRESENT / PARTIAL / ABSENT / UNKNOWN`哪类？
2. 证据具体对应哪个当前路径、文件/符号、实际版本、权限/数据/业务边界？缺少可追溯依据必须标`UNKNOWN`，不能因为历史报告或注释声称PASS。
3. 若要开始下一阶段，应优先取得哪些外部/法律资料、补齐哪些工程合同；哪些功能必须继续保守阻断？

**禁止在S1交付“已经实际运行通过”或“可上线/可报名”结论。** 静态`PRESENT`也只说明看到了对应结构，不等于端到端`PASS`。

## 2. 拟授权边界（仅候选，不得自行执行）

| 项目 | S1建议范围 |
|---|---|
| 受授权方 | **未来Owner明确指定**的本地Codex或其它只读审阅者；本稿不对其派单 |
| 真实工作根 | 由Owner在授权时确认唯一活动本地目录；历史项目中的路径或GitHub治理分支都不能自动当成当前代码身份 |
| 允许材料 | 被批准根目录内的源码、配置**结构/键名**、接口声明、数据库结构/迁移定义、现有测试源码及架构文档的静态阅读；只读本地Git身份/当前分支/HEAD/工作树是否脏须使用不会改变工作树的方式 |
| 只读操作 | 文件与符号定位、结构性静态比对、只读检索和必要的脱敏摘要；外部GitHub治理资料只作产品规则权威，不代替本地工程身份 |
| 严禁 | 修改/删除/生成任何本地工程文件；安装依赖、构建、执行测试或启动服务；数据库查询/迁移/写入；仿真器/真机/APK；触达真实身份核验/Push/RTC/网络端点；git checkout/fetch/pull/push/merge/reset等改变状态或远程动作；供应商联络/采购；用户或第三方敏感材料读取/外传 |
| 高风险资料 | 密钥、token、SSH私钥、真实身份材料、私聊数据、正式数据库连接串的**值**一律不读取、不复制、不记录；如无法在不触达秘密的情况下核实能力，标`UNKNOWN/SENSITIVE_ACCESS_REQUIRED` |
| 报告内容 | 单份脱敏差距报告（含证据索引和风险分组），不要求十份Gate报告、不自动生成工程Issue/任务单 |
| 未定且需Owner补充 | 当时唯一真实本地路径及允许读取层、受授权方、是否允许对非工程文档写摘要、输出位置和证据处理限制；默认一律不授权 |

这里的“未来一次性授权”**不等于**允许无界运行；必须将执行身份与工作根绑定实际Owner当时的明确决定。

## 3. 合并核查对象：五组即可覆盖十个G，不拆Gate派单

| S1审阅组 | 关注的G门禁 | 将来静态要核对的源码事实 | 证据不足时的默认 |
|---|---|---|---|
| **R1 真实身份/关系状态** | G01、G09关系许可部分 | 实人核验接入状态/占位、真实报名资格、Lifestyle状态、Match→Connection→双方Consent→Conversation/Relationship是否独立、权威回执契约 | 真实供应商未核则Match正式报名保持禁用，不宣称真实端到端可用 |
| **R2 内容/媒体/评论受众** | G02、G03、G08相关部分 | 访客与登录域、SELF/FRIENDS/PUBLIC_AUTHENTICATED、旧评论原受众、第三方回复、媒体/深链与Block门禁及撤权 | 无法证明合法交集则不展示历史受控内容，不扩大受众 |
| **R3 来源/用途/派生/发布版本** | G04、G05、G06 | 来源字段所有者、具名用途许可/撤销记录、派生结果依赖/失效状态、本人预览与外发快照版本、旧候选生命周期 | 不跨用途默用；待核查派生不按已验证新发布；旧候选不自动升级 |
| **R4 删除/安全恢复/跨账号** | G07、G08、G09的UNKNOWN部分 | 对象级申请/真实受理与删除完成回执是否分离、跨账号缓存/迟到回包、权威只读查询、请求幂等/冲突 | 不假报删除受理/完成；失权隐藏；UNKNOWN不自动重放 |
| **R5 通知与资产结构** | G09、G10静态部分 | 通知已读/待办状态、内容/消息权限结构；现有视觉原始文件路径/版本记录（**不校验未授权原二进制、不运行设备**） | 不假称真实Push送达；原43 PNG仍PENDING，动态QA仍NOT_RUN |

**R1–R5是合并阅读顺序而不是五次Owner审批或五个Codex子任务。** G01–G10所有实际运行时QA继续`NOT_RUN`，R5对G10仅做结构性静态记录，无法取得的原件身份留作另行资产核验。

## 4. 静态结果和证据的统一记录样式

将来一个只读报告覆盖全部组，每项至少：

```text
audit_scope: S1_READ_ONLY
owner_authorization: NONE_UNTIL_EXPLICIT_OWNER_APPROVAL
local_root / branch / HEAD / worktree_identity: NOT_CHECKED
contract_ref: concrete Owner accepted document and narrow scope
review_group / gate_ids: Rn / Gxx
component / file / symbol: UNKNOWN_UNTIL_READ
static_state: PRESENT | PARTIAL | ABSENT | UNKNOWN
evidence_path / line_range: NOT_COLLECTED
what_is_not_proven: RUNTIME_NOT_RUN | EXTERNAL_OPEN | LEGAL_OPEN
security_default: exact existing fail-closed rule
gap / priority_suggestion: ADVISOR_ANALYSIS_ONLY
next_required_authorization: OWNER_TO_DECIDE
```

- `PRESENT`：实际找到指向特定规则的静态结构，并记录准确文件/符号/版本；不是PASS。
- `PARTIAL`：已有相关实现，但至少一个产品/权限/异常分支缺失或未能证明。
- `ABSENT`：已按获准范围充分检查未发现对应结构；对未获准阅读的层不得宣称全系统ABSENT。
- `UNKNOWN`：身份、权限、文件或静态证据不足；宁可标UNKNOWN，不因文档声称或旧基线猜测。
- 只读核查不得把`NOT_RUN`升级为`PASS`或虚构供应商的真实回执；安全/隐私敏感数据仅留去敏摘要，不上传公开GitHub。

## 5. 一次性交付验收标准（未来S1有授权之后才适用）

未来S1若真实获批，按**一份主报告**收束：
- 真实工作树身份和只读范围清晰且不更改文件；
- R1–R5覆盖的G01–G10能追溯具名Owner规则与实际代码证据；未检查的对象明确`UNKNOWN/NOT_CHECKED`；
- 对每个差距分别指出是`PRODUCT_DETAIL_OPEN`、`EXTERNAL_OR_LEGAL_OPEN`还是`ENGINEERING_GAP`；高风险缺口保留对应安全阻断；
- 独立列出无法在静态阶段证明的动态性能、跨设备、媒体、真实供应商、删除与备份清理；
- 不输出工程修改、实现承诺、通过声明或版本候选；提交一份**后续可供Owner决定的综合摘要**。

如果真实本地根不明确、权限/来源变动、发现密钥或敏感信息、疑似越权工程动作，则**立即停止或绕开该材料并记UNKNOWN**，不得为了覆盖率扩大授权。

## 6. 后续授权选择：只提出一次，不拆成大量新门禁

供Owner以后明确选择的唯一区别为：

- **S1-A（建议）**：允许指定本地审阅者在确认的唯一项目根下进行上述受限**只读源码与合同差距审计**，仍不执行代码/测试/设备/供应商操作，交付一份脱敏静态差距总报告；实际授权须写明受授权者和工程根目录。
- **S1-B**：继续只由网页GPT核GitHub治理/产品静态文档，不开放本地代码只读审阅；此时工程差距仍不得变成PRESENT/ABSENT。

本文件当前仅为`S1_A_B_OWNER_REVIEW_DRAFT`，**不是Owner选择了A**。用户的“好的，请继续”仅授权顾问继续推进到当前阶段的**文档准备**，不能替代Owner明确批准Codex。外部供应商核实、A6会议、动态QA、开发/发布仍各自`NOT_AUTHORIZED`，即使未来S1-A获批也不能自动解锁。

## 7. 当前持续保持的状态

`DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED / S1_NOT_AUTHORIZED`。实人身份核验与真实Push仍按现行记录为未接入；F-01`READABILITY_PARTIAL`；G01–G10全部新增动态`NOT_RUN`；原43 PNG远端`PENDING_BINARY_UPLOAD`（本次未逐份核验）；旧`10.1.18-dev / 1011804`、UI-AUDIT-01的`NOT_RUN/UNKNOWN`不变。

本文件只为**一次性未来Owner授权**准备范围与交付口径，不对本地Codex发送任何执行任务。
