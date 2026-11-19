# EliteSync V2｜DESIGN-AUDIT-03：评论撤回、作者隐藏、回复树与删除申请异常场景静态审阅

日期：2026-11-19（Asia/Singapore）  
类别：`DOCUMENT_AND_PRODUCT_CONTRACT_STATIC_EXCEPTION_REVIEW`  
基准治理分支：`governance/home-matching-product-freeze-20261117`；本次首读HEAD：`5b2afd8a58856754db7e98132c905659eb8d5581`  
结果：`SCOPED_STATIC_REVIEW_COMPLETE / NO_DIRECT_ACCEPTED_PRINCIPLE_CONFLICT_FOUND / NEW_EDGE_DETAILS_OPEN / ALL_RUNTIME_NOT_RUN`  
Authority：`DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`

## 0. 限定范围与核查方法

本次只读回GitHub指定分支中的既有**具名Owner决定与顾问静态矩阵**，将“此前接受的产品方向”和“新的精确交互细节”区分。已核：
- [NEW-PC-01 评论者撤回展示](../decisions/OWNER_V2_NEW_PC01_COMMENT_AUTHOR_WITHDRAWAL_OPTION_A_DIRECTION_ACCEPTANCE_20261119.md)、[NEW-PC-02 作品作者隐藏评论展示](../decisions/OWNER_V2_NEW_PC02_AUTHOR_CONTROL_THIRD_PARTY_COMMENT_DISPLAY_DIRECTION_ACCEPTANCE_20261119.md)、[NEW-PC-03 对象级删除请求首期规划](../decisions/OWNER_V2_NEW_PC03_INITIAL_OBJECT_LEVEL_DELETION_REQUEST_ENTRY_OPTION_A_ACCEPTANCE_20261119.md)；
- [NEW-PC-01/02/03权限语义矩阵](../product/ELITESYNC_V2_CONTENT_CONTROL_AND_DELETION_SEMANTICS_MATRIX_V0_1_20261119.md)、[HIS-D1/D2](../decisions/OWNER_V2_HIS_D1_D2_HISTORICAL_ACCESS_AND_SNAPSHOTS_20261119.md)、[OBJ-D1](../decisions/OWNER_V2_OBJ_D1_POST_TAKEDOWN_THIRD_PARTY_COMMENTS_ACCEPTANCE_20261119.md)、[RET-D1/D2](../decisions/OWNER_V2_RET_D1_D2_REVOCATION_DELETION_CONCEPT_ACCEPTANCE_20261119.md)、[O06-R2/R3](../decisions/OWNER_V2_O06_R2_R3_O07_R2_ACCEPTANCE_20261119.md)、[O08](../decisions/OWNER_V2_O08_SAFE_FEEDBACK_ATTACHMENTS_DRAFTS_ACCEPTANCE_20261119.md)、[O09](../decisions/OWNER_V2_O09_CROSS_DEVICE_AUTH_UNKNOWN_ACCEPTANCE_20261119.md)、[S15-D1/S16-D2](../decisions/OWNER_V2_S15_D1_S16_D2_ACCEPTANCE_20261119.md)、[DESIGN-AUDIT-02](V2_STATIC_DESIGN_CONTRACT_AUDIT_02_P0_EVIDENCE_LEDGER_20261119.md)。

没有读取或测试APP/API/Web/DB、设备、媒体地址或供应商；以下“行为目标”不是对现行`10.1.18-dev / 1011804`的实际能力断言。**所有新动态验证`NOT_RUN`**。

## 1. 基础区分——四种独立事实

1. `CONTENT_READ_ALLOWED`（概念谓词）：当前作品读权、原评论受众、Block/账号/具名权限及有效历史记录均许可。只是本报告逻辑表达，不是新增DB字段或状态enum。
2. `COMMENT_AUTHOR_WITHDRAWN`：评论作者撤回自己评论的当前对外展示（NEW-PC-01），不删除他人独立回复/所有合法留存。
3. `POST_AUTHOR_HIDDEN`：作品作者选择不在**自己作品内**展示指定第三方评论（NEW-PC-02），不等于拥有评论者原件删除权。
4. `DELETE_REQUEST_RECEIPTED` / `DELETION_COMPLETED_IN_SCOPE`：删除请求受理与具体范围删除完成只能按真实权威证据确认（RET-D1/D2、NEW-PC-03），不能由2、3直接推出。

其中2、3的同时发生、覆盖关系、恢复、通知等精细语义尚未获Owner批准；不能以本逻辑名义创造真实服务端状态。

## 2. 12项异常场景的静态检查

标签：`BASELINE_DETERMINED`表示既有Owner规则足以确立最小安全边界；`PRODUCT_CHOICE_OPEN`表示安全默认之外仍存在需Owner取舍的新展示行为；`EVIDENCE_OPEN`表示当前不能以文档核实技术/法律事实。

| ID | 异常场景 | 已接受边界/保守安全默认 | 仍需选择或证明的部分 | 分类 |
|---|---|---|---|---|
| EX-01 | 评论作者撤回**父评论**，其下仍有其他用户的合法回复 | 父评论正文/自身受控媒体不得继续对外展示；他人回复原始记录**不自动删除**；不能借回复泄露父评论已收窄内容 | 回复能否在权限合法且不泄密时保留展示；树结构使用中性占位还是折叠 | `PRODUCT_CHOICE_OPEN / EVIDENCE_OPEN` |
| EX-02 | 作品作者隐藏别人一条评论，下有第三方回复 | 作者不能删他人评论/回复原件；对已隐藏内容不得用引用、缩略图或原链绕过展示管理方向 | 对本作品读者是整支折叠还是仅隐藏目标评论；独立回复如何保持上下文 | `PRODUCT_CHOICE_OPEN` |
| EX-03 | 评论已被作品作者隐藏，之后评论者又主动撤回 | 两种权利主体独立；不能因某一操作倒转另一方的有效撤回/隐藏；不得声称删除已完成 | 恢复时冲突优先级和状态可见范围的精确合约 | `BASELINE_DETERMINED / DETAIL_OPEN` |
| EX-04 | 作品作者取消隐藏，但评论者先前已经撤回 | 已确认评论者撤回不得由他人操作强制重新外显；当前作品/原评论受众仍受HIS-D1限制 | 是否允许评论者自己另作独立重新发布决定、历史恢复路径 | `BASELINE_DETERMINED / PRODUCT_CHOICE_OPEN` |
| EX-05 | 评论/回复只对旧好友开放，作品从SELF/FRIENDS扩大到PUBLIC_AUTHENTICATED | 当前作品读权与评论原受众/其它限制取交集；不应自动把旧评论、媒体或回复扩给新读者 | 历史受众记录是否实际可恢复、媒体/引用的真实隔离机制 | `BASELINE_DETERMINED / EVIDENCE_OPEN` |
| EX-06 | 旧通知、直链或评论引用命中已撤回/隐藏的评论 | 旧通知不授予新阅读权；受保护正文/缩略图/媒体/身份不能绕过现权；旧操作不可复活 | 在原通知仍合法可读时应显示哪种中性状态、是否显示“由谁隐藏” | `PRODUCT_CHOICE_OPEN / EVIDENCE_OPEN` |
| EX-07 | Block/切号/当前权限未知时查看或管理历史评论 | O09要求当前账号与权限重验；已确认失权隐藏，UNKNOWN安全占位，不信旧缓存或迟到回包 | 真实多端缓存/媒体撤权传播及故障复现 | `BASELINE_DETERMINED / EVIDENCE_OPEN` |
| EX-08 | 评论者撤回展示后又申请删除本人评论数据 | 撤回≠申请删除≠受理≠完成；没有真实渠道不可伪造单号/处理进度 | 请求包含哪些副本、附件、法定例外及实际回执 | `BASELINE_DETERMINED / EXTERNAL_AND_ENGINEERING_OPEN` |
| EX-09 | 作品作者删除本人作品请求与第三方评论者独立权利同时出现 | 作者不能代第三方永久删除原件；作品撤下导致失权阅读必须关闭；真实删除完成按指定范围核实 | 评论者独立材料保留/申诉/导出如何合法分流 | `BASELINE_DETERMINED / EXTERNAL_AND_ENGINEERING_OPEN` |
| EX-10 | 评论被投诉/涉及Safety证据，随后作者隐藏或评论者撤回 | 展示控制不等于清除合法必要安全证据，负面档案也不得因此对普通用户公开 | 真实复核主体、必要保存依据/时限、告知与申诉流程 | `BASELINE_DETERMINED / PRODUCT_AND_LEGAL_OPEN` |
| EX-11 | 撤回/隐藏/删除请求网络超时，客户端显示UNKNOWN | 不能假成功或自动重放；当前有权只读核权威状态，无法确认保持UNKNOWN、安全返回 | 权威查询能力、请求关联/幂等、跨设备回执和真实API | `BASELINE_DETERMINED / EVIDENCE_OPEN` |
| EX-12 | 作者或评论者尝试恢复历史展示，而受众/Block/对象版本已经改变 | 旧权限不能当现权；原评论受众不可核实即隐藏；恢复不能自动扩大第三方许可 | 恢复是否提供以及如何确认、冲突/旧快照/安全复核优先级 | `PRODUCT_CHOICE_OPEN / EVIDENCE_OPEN` |

**静态审计结论**：既有具名Owner原则对EX-01..12的最小“不泄密、不冒充删除、保留独立权利、UNKNOWN不重放”已给出一致边界，**在检查的文档范围内未发现直接规则冲突**。但这不能被解释为上述12种场景已有完整可实施UI合同，更不能称已运行通过。

## 3. 值得Owner新增审阅的两个精确交互取舍（均未获批准）

### EDGE-D1｜父评论被撤回/隐藏后，独立回复如何展示

- **A（推荐：条件性保留）**：父评论不再合法对外展示时，仅在父评论上下文不会泄密、当前作品与回复本身原受众均合法、该回复仍有效且可独立阅读的前提下，使用**不暴露作者、内容或原因的中性结构占位**保持可读的独立回复；一旦无法验证安全上下文，则保守折叠/隐藏关联回复在该作品中的展示，但不因此删除回复原始数据。
- **B（严格整体折叠）**：父评论撤回/隐藏后，整条依附讨论树均在作品中不可见，即使个别回复仍有独立合法读权；不物理删除其它作者的回复及合法独立记录。
- **取舍**：A保护第三方合法表达与对话连贯性，需更多历史受众/引用/上下文证据；B较简单且更保守，但可能不必要地隐藏独立合法回复。B不能被理解成其它用户的回复数据也被撤回/删除。
- **推荐先审A的概念原则**，但不假定存在可显示中性占位的合法条件；任何危险或未知情况都先隐藏。

### EDGE-D2｜作品作者隐藏评论后，评论者如何获知/申诉

- **A（推荐：合法最小状态+不强制Push）**：仅当评论者仍有权访问与自身评论相关的必要业务上下文且不会泄漏作者/Block/举报者身份或私密关系，允许其在自己的评论历史查看**不含隐藏原因的中性状态**以及确有实际渠道时的申请复核说明；不保证主动推送或系统已具备申诉入口。
- **B（静默处理）**：作品作者隐藏后不主动或被动展示该动作状态；评论者仅在原显示位置不可读时看普通安全返回，必要投诉通过其它真实合法渠道。该方案简单，但评论者可能无法区分故障、失权或作者管理行为。
- **取舍**：A透明度较高但要严格限制隐私推断与避免假渠道；B简单但难以解释行为变化。**目前先保持ADVISOR_PROPOSAL**，不因NEW-PC-02方向性接受而自动生成新通知或申诉机制。

## 4. 其他无需现在单独请求Owner重复决定的项

- EX-03/04的“谁都不能代表他人撤回/恢复原始权限”属于NEW-PC-01/02与HIS的既有原则，尚未获批的是**恢复产品能力本身**；
- EX-05/07/11可保持原安全缺省及`EVIDENCE_OPEN`，现阶段不要求Owner决定实际缓存或幂等技术；
- EX-08/09/10涉及真实合法保留、受理/完成API、Safety必要证据，需外部合法依据及后来Owner授权的工程检查；
- EX-06/12的中性展示样式、复核路径、恢复界面可以随EDGE-D1/D2之后的详细设计再审，而不能直接标为已批准。

## 5. 未来证据清单（不是工程任务）

本次仅从产品合同推导**将来需要**的证据类别：评论作者与作品作者各自身份/对象权限、旧评论/回复原受众、当前作品/Block、关联回复/引用与媒体URL、隐藏/撤回的权威结果与冲突顺序、原通知合法摘要、删除受理/完成与合法必要保留、跨账号与幂等/UNKNOWN、第三方安全记录权限。确切字段、服务端/数据库身份、真实设备与错误恢复仍`UNKNOWN / NOT_RUN`，没有运行或委派。

与原[DESIGN-AUDIT-02](V2_STATIC_DESIGN_CONTRACT_AUDIT_02_P0_EVIDENCE_LEDGER_20261119.md) G03、G07、G08、G09及[S15作品受众](../decisions/OWNER_V2_S15_D1_S16_D2_ACCEPTANCE_20261119.md)相关；但本次12项只构成新增**静态设计场景覆盖**，不等于G01–G10已通过，也不是全部风险枚举。

## 6. 审计结果与下一步

本轮仅`SCOPED_STATIC_REVIEW_COMPLETE / EDGE_D1_D2_OWNER_REVIEW_PENDING / IMPLEMENTATION_GATE_NOT_READY`。

**建议Owner下一次只审`EDGE-D1`**，因为父评论撤回/隐藏后的第三方回复如何展示影响内容权利与隐私交集；EDGE-D2仍独立待审，不打包自动接受。无论选择A/B，文案、真实状态字段、审核后台、回执、合法保留及实现仍OPEN。

停止边界：`DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`；旧候选`10.1.18-dev / 1011804`的UI-AUDIT-01历史`UNKNOWN/NOT_RUN`、真实核验与Push未接入及43 PNG原图备份PENDING不改判。
