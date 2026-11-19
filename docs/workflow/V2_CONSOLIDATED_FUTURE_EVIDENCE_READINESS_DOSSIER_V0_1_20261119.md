# EliteSync V2｜未来工程差距核查与外部依赖集中证据准备包 V0.1

日期：2026-11-19（Asia/Singapore）  
仓库：`zcx369658780/EliteSync-v10`  
治理分支：`governance/home-matching-product-freeze-20261117`  
本轮读取前HEAD：`eab608d37efb4743d1124a3bb6c728d40e18cf86`（此为审阅输入基点，不冒充写入后的最终HEAD）  
状态：`ADVISOR_EVIDENCE_READINESS_DOSSIER_PREPARED / EVIDENCE_NOT_COLLECTED / ENGINEERING_NOT_AUTHORIZED / ALL_G01_G10_RUNTIME_NOT_RUN`  
**持久停止状态：`DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`。**

## 0. 用途、证据来源与权限排除

本包将此前分散的未来缺证据要求**合并为一份可追溯登记簿**，供Owner以后决定是否启动严格限定范围的工程差距核查或外部依赖评估。此文件**不是当下执行任务书、测试计划启动令、供应商采购授权或上线验收报告**。当前仅使用GitHub中可读取的治理/产品文本文档，没有读取、修改、运行或检查Owner本地APP/API/Web/数据库、设备/模拟器、APK、外部服务或原43份PNG二进制。

主要依据：
- [现行一页权威](V2_CURRENT_AUTHORITY_ONE_PAGE_20261119.md)、[ACTIVE_STATE顶端CURRENT ENTRY](ACTIVE_STATE.md)、[Owner具名接受索引](../product/ELITESYNC_V2_OWNER_ACCEPTED_SOURCE_INDEX_AND_AUDIT_SNAPSHOT_20261119.md)；
- [DESIGN-AUDIT-01](V2_STATIC_DESIGN_CONTRACT_AUDIT_20261119.md)、[DESIGN-AUDIT-02 P0证据账本](V2_STATIC_DESIGN_CONTRACT_AUDIT_02_P0_EVIDENCE_LEDGER_20261119.md)、[DESIGN-AUDIT-03异常场景](V2_STATIC_COMMENT_EXCEPTION_AUDIT_03_20261119.md)；
- [G01–G10原静态安全矩阵](../product/ELITESYNC_V2_P0_FAIL_CLOSED_SCREEN_AND_EVIDENCE_MATRIX_V0_1_20261119.md)、[未来证据登记模板](V2_G01_G10_FUTURE_EVIDENCE_INTAKE_TEMPLATE_20261119.md)、[P0三分流](../product/ELITESYNC_V2_P0_OPEN_TRIAGE_PRODUCT_EXTERNAL_ENGINEERING_V0_1_20261119.md)；
- 已合并的[评论/内容UX状态](../product/ELITESYNC_V2_BATCH_CONTENT_SINGLE_PASS_UX_STATE_DRAFT_V0_1_20261119.md)、[首页/匹配/资料/通知UX状态](../product/ELITESYNC_V2_BATCH_OTHER_DESIGN_SINGLE_PASS_STATIC_REVIEW_V0_1_20261119.md)、[概念收束简明导航](V2_CONCEPT_REVIEW_CLOSURE_AND_EVIDENCE_HANDOFF_20261119.md)。

**权威区分：**
- `OWNER_CONFIRMED`：仅来源于具名Owner独立接受文件的精确范围；不能将整个顾问报告变为合同。
- `ADVISOR_PROPOSAL`：本报告里的证据组织、顺序、核验目标、候选标准均为顾问建议，**不是Owner新批准的执行优先级**。
- `OPEN`：合同、外部依据、具体状态或能力尚缺；`UNKNOWN`：实际事实未核实，不能猜测。
- `NOT_RUN`：未真实执行目标动态QA；`PENDING_BINARY_UPLOAD`：按现行材料记录43原PNG远端备份缺口，本轮未逐份判断其实际存在性。
- 文档静态来源核对成功不等于工程`PASS`；历史固定软件基线`10.1.18-dev / 1011804`及UI-AUDIT-01原`NOT_RUN/UNKNOWN`不变。

## 1. 将未来需要的证据归为四大集合

| 证据包 | 未来拟核的事实与最小材料 | 应来自何处（未来角色，不是当前已分配） | 当前状态 |
|---|---|---|---|
| **E-ENG：真实工程合同与差距** | Owner本地工作树/实际代码身份，APP/API/Web/DB各层读取与写入门禁、领域字段与版本、媒体/深链、幂等/权威回执、跨设备撤权、真实状态机；证据链接与差距项 | **未来受Owner授权**的本地工程审阅方；当前不得委派Codex | `NOT_AUTHORIZED / NOT_CHECKED` |
| **E-EXT：真实外部服务** | 身份供应商功能/合法协议/字段回传/效期/失败申诉，Push提供者/平台权限/发送与送达证据，产品可用性界限；真实金额仅在实际报价后记录 | 未来由Owner决定是否接触的服务方、合规与业务责任方 | `EXTERNAL_DEPENDENCY_OPEN`；现行文档声明实人核验/真实Push未接入 |
| **E-LEGAL：数据及第三方权利** | 适用法域、处理目的与合法依据、评论/附件/转载等第三方权利、删除申请可受理对象、必要保留及备份例外、真实隐私说明和申诉 | 未来获得合法授权的业务/法律合规负责人及实际合同/政策材料 | `LEGAL_OR_EXTERNAL_FACT_OPEN`；不得编造期限或结论 |
| **E-ASSET-QA：原件与动态体验** | 原43份PNG逐项真实路径/原件身份/SHA/远端回读；设计SVG与真机截图身份区别；系统Back、读屏、大字、减少动效、D/I/N/A/W，实际设备与账号条件 | 未来经Owner另行授权的资产保管/动态验收方；现在仅准备文字结构 | `PENDING_BINARY_UPLOAD / BINARY_NOT_CHECKED / RUNTIME_NOT_RUN` |

每一包可以包含多个Gate；**不要把十个G项直接拆成十张独立工程派单或十次Owner批准**。

## 2. G01–G10 一张合并证据交付矩阵

以下列出的材料均属于**未来应该核查的证据规范**，不是已发现文件、接口或实际API名称。证据必须分别支持合法的正常路径、拒绝/失权路径，以及回执UNKNOWN等必要否定场景。

| Gate / 用户目标 | 已接受的最低设计约束、当前安全默认 | 将来需要的核心证明与归属证据包 | 现在的状态 |
|---|---|---|---|
| **G01 真实身份 / Match参与** | Lifestyle等合法可补资料可继续；实人核验未接入时**正式报名不可用**，不能虚构核验PASS或真实候选 | `E-EXT`供应商资格、合法协议、身份回执字段/效期/撤销/申诉；`E-ENG`资格与本人报名/双方业务门禁；以后明确授权下真实拒绝与正向资格链 | `EXTERNAL_OPEN / ENGINEERING_NOT_CHECKED / QA_NOT_RUN` |
| **G02 访客 / 登录内容分域** | 访客只读明确开放的官方正文；用户作品/昵称/缩略图/评论不向访客泄露；登录态仍按受众与Block | `E-ENG`账号、受众、Block、搜索/深链/媒体链接/缓存的一致判定及真实PUBLIC_AUTHENTICATED域；`E-LEGAL`若涉及正式转载/第三方使用许可 | `ENGINEERING_NOT_CHECKED / QA_NOT_RUN` |
| **G03 历史评论/附件/回复** | 原受众∩当前作品读权；评论作者撤回、作品作者隐藏、条件性独立回复、合法中性状态及第三方删除权分开；无法核原边界则隐藏 | `E-ENG`历史受众/版本、媒体签发与撤权、评论/回复树、通知引用、缓存、权限变化与权威回执；`E-LEGAL`第三方权利/必要留存；具名NEW-PC-01/02/03、EDGE-D1/D2作目标规则 | `POLICY_AND_ENGINEERING_OPEN / QA_NOT_RUN` |
| **G04 事实来源与具名用途** | SOURCE/PURPOSE独立，当前目的许可有效可合法复用；缺许可只向必要字段请求，不捆绑其它工具 | `E-LEGAL`来源处理依据/授权范围；`E-ENG`源字段权威位置、用途与版本、撤销后的计算/外显拒绝与权威回执 | `LEGAL_AND_ENGINEERING_OPEN / QA_NOT_RUN` |
| **G05 纠错影响与派生新发布** | 只限制真正受纠错影响且待核查的派生结果，不当已验证内容向新受众发布，不全局锁定无关功能 | `E-ENG`真实依赖图、计算/核查能力、受影响结果集合、状态/版本及新发布回执；`E-EXT`仅在确有外部数据或计算服务依赖时补许可 | `DEPENDENCY_NOT_CHECKED / QA_NOT_RUN` |
| **G06 本人预览/外显快照/UNKNOWN** | 保存预览≠对外发布；匹配新版默认只给未来有权新候选；旧候选现权合法时看原版；失权隐藏；UNKNOWN先只读核真事实 | `E-ENG`本人预览、覆盖字段、发布快照的身份/版本/受众/Block/候选时间关系、写入与回读/幂等；`E-LEGAL`适用撤回/保留合同 | `ENGINEERING_NOT_CHECKED / QA_NOT_RUN` |
| **G07 撤权/删除申请/完成** | 授权撤销≠删除申请受理≠删除完成；本人作品/本人评论对象级申请入口只为首期**设计优先规划**，无真渠道不出现假受理/完成 | `E-LEGAL`适用法域、对象权利、第三方与必要保留；`E-ENG`真实受理/处理/完成的不同回执、对象/主副本/附件/备份范围、幂等与UNKNOWN核验 | `LEGAL_AND_ENGINEERING_OPEN / QA_NOT_RUN` |
| **G08 切号/Block/失权及旧缓存** | 失权内容立即从当前UI隐藏；权限未知安全占位；旧账号缓存、通知、深链与迟到回包不能代替当前授权 | `E-ENG`真实账号/会话隔离、权限/Block变更、媒体签名、预加载、旧回包、设备/缓存传播与只读核验能力；不预设零延迟强一致 | `ENGINEERING_NOT_CHECKED / QA_NOT_RUN` |
| **G09 站内消息/通知/真实Push** | 已读≠待办处理；有效业务按权威状态优先，失效通知只有合法无泄密时给中性历史；双方Messaging Consent有效前不能开启有权聊天；不得声称Push已送达 | `E-ENG`站内通知业务资格、双向许可/Block、已读与待办分离、返回位置/幂等；`E-EXT`真实Push提供者、设备权限及发送/接收依据 | `PUSH_EXTERNAL_OPEN / ENGINEERING_NOT_CHECKED / QA_NOT_RUN` |
| **G10 视觉原件/动态无障碍** | 原结构SVG不冒充43份原PNG或真机截图，静态低密度原则不等于实际QA PASS | `E-ASSET-QA`逐份原PNG身份、来源、SHA/远端固定回读；未来真机截图、读屏、大字、Back、动效替代、D/I/N/A/W实测及异常安全区记录 | `PENDING_BINARY_UPLOAD / BINARY_NOT_CHECKED / QA_NOT_RUN` |

`G01–G10`仍是此前静态矩阵的编号，本包没有新建后端状态枚举、接口名称或准确数据库字段。

## 3. 证据身份与可核验等级（将来统一登记）

同一Gate可能需要多个独立证据条目，未来每条至少登记：

| 字段 | 规则 |
|---|---|
| `evidence_id` / `gate_ids` / `category` | 固定证据条目身份；可以一次覆盖多个G项；不得重复复制互相矛盾的事实 |
| `contract_ref` 与`accepted_scope` | 独立Owner具名决定路径、固定blob/提交与精确已确认范围；顾问建议必须另标`ADVISOR_PROPOSAL` |
| `source_kind` | 实际本地工作区/运行产物、外部供应商正式材料、适用法律/合同、原始二进制及对应身份；不得拿GitHub治理分支当本地源码身份 |
| `captured_at`、`actual_version`、`scope` | 真实时间、环境与代码/设备/配置身份、账号/用途/受众/Block/场景、受控去敏方法；未知就写`UNKNOWN` |
| `claim` / `negative_case` / `proof_uri` | 要证明的正向行为、拒绝/失权/UNKNOWN安全行为及**实际可回读**的证据位置；尚未采集统一标`NONE` |
| `independent_check` | 未来审查人独立重读权威回执/日志/资产哈希或合同原文；不能只抄执行者PASS声明 |
| `outcome` / `blocker` | 动态未做记`NOT_RUN`，真实无法判断记`UNKNOWN`，已运行后有证据才可判`PASS/FAIL`；外部合法依据独立记`OPEN/VERIFIED` |
| `authority_to_act` | 引用未来Owner明确授权的范围/日期/期限/环境；无授权记`NONE`；静态文档本身不是授权 |
| `sensitive_data_handling` | 只保留必要脱敏证据；不要将真实身份原件、私聊、第三方敏感资料、令牌、供应商密钥直接写入公开GitHub |

推荐的单项**空白登记卡**（此处所有状态仅为模板）：

```text
evidence_id: TO_ASSIGN_LATER
gate_ids: Gxx
category: E-ENG / E-EXT / E-LEGAL / E-ASSET-QA
contract_ref / accepted_scope: LINK_OR_UNKNOWN
claim: NOT_YET_CHECKED
negative_case: NOT_YET_CHECKED
source_kind / actual_version / environment: UNKNOWN
captured_at / proof_uri / hash: NONE
authority_to_act: NONE
runtime_outcome: NOT_RUN
external_legal_outcome: OPEN
independent_check: NOT_RUN
blocker: EVIDENCE_NOT_COLLECTED
```

**强制分开**“文件存在/静态文本一致”“真实运行行为”“供应商合同成立”“法律适用与用户权利”四类结论：一种通过不会让另一种自动通过。

## 4. 建议的未来分批核查顺序（无当前授权、非派单）

### 阶段 S0：保持本次仅静态准备

- 以本包、既有Owner索引和G01–G10矩阵作为可读证据需求；可以继续清理**顾问文档内**的重复描述，不移动/删除历史Owner材料。
- 不读取/操作真实本地工程、不联系供应商、不收集私密个人资料、不运行设备、不提交工程任务。

### 阶段 S1：**如果未来Owner单独允许有限只读工程差距核查**

- 权限必须明确：受授权方、被允许的本地代码根/分支、可读的层（APP/API/Web/DB schema等）、只读边界、是否允许运行任何程序（缺省为不允许）、可保存哪些去敏结果、完成与回报方式。
- 未来只读核查应首先记录**真实本地工程身份**与当前代码中有/无/未知的能力；按E-ENG整理“产品合同目标 vs 已见实现 vs 缺口”，**不得**把静态顾问稿自动转成实现指令。
- 即使只读审计获授权，也**不自动**许可模拟器、设备、数据库写入、服务部署、供应商连接、APK构建、main合并、发布。

### 阶段 S2：**如果未来Owner单独批准外部/合法依据核实**

- 身份核验/Push供应商选择、报价、协议、字段与真实回执、适用法域与第三方权利/留存应由相应合法主体先提供真实文件。未经Owner新授权不联系或购买。
- 外部材料若被审阅，必须与工程/产品结论分开记录；商用可行不代表安全集成或个人资料处理已合法实现。

### 阶段 S3：**如果未来Owner另行批准设备/运行时QA**

- 在身份与真实前置条件可用、对象/数据来源合法、环境与权限约束已确认后，按G01–G10场景检查真实正常与拒绝路径；所有测试须记录实际版本、可复核结果、FAIL/UNKNOWN与未运行范围。
- 当前不得调用设备、模拟器或网络供应商，也不得用受控假服务的PASS冒充真实供应商可用。

### 阶段 S4：**只有后续新的单独Owner批准才可能开发/集成/正式A6/发布**

- 工程修复、APP/UI高保真实施、数据库更改、真实供应商接入、A6正式会议、main合并/发布属于**不同**授权维度，不能从S1/S2/S3或本包默认推出。
- `NEW-PC-04`旧候选主动分享新版、`NEW-PC-05`正式官方转载首期范围仍是**顾问建议延期**，不是Owner已正式批准“永久不做”。

## 5. 当前阻断与最小完成判定

**文档准备完成的条件**：十个G项均具有Owner规则出处、所需证据类别、未来可能的证据来源、安全缺省和当前未运行状态；有一个统一的身份/结果登记模板；清楚区分未来四种授权。这些条件满足只意味着`DOCUMENT_READINESS_PREPARED`。

**不能据此关闭的事项**：
- `G01–G10 RUNTIME_NOT_RUN`全保留；
- 实人身份核验与真实Push按现行文档仍未接入，正式真实Match报名保持不可用；
- 43份原PNG按现行材料`PENDING_BINARY_UPLOAD`，本轮未做二进制逐份存在性/SHA核验；
- F-01原历史`OWNER_REVIEW_PENDING`的可读性风险仍`READABILITY_PARTIAL`；
- 旧`10.1.18-dev / 1011804`和UI-AUDIT-01历史`NOT_RUN/UNKNOWN`不改判；
- 实际法域、数据保留、第三方删除权、授权表/快照/媒体与幂等等均`OPEN`。

### 统一结论

`FUTURE_EVIDENCE_REQUIREMENTS_CONSOLIDATED / DOCUMENT_ONLY / ZERO_NEW_RUNTIME_OR_EXTERNAL_EVIDENCE / DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`

**本包只是未来Owner可能授权差距核查时的准备材料。没有实际核查、工程派单、采购、代码变更、A6会议、设备测试、main合并或发布。**
