# EliteSync V2｜Owner正式接受阶段A限定交付并授权阶段B工程

日期：2026-11-20（Asia/Singapore）  
治理分支：`governance/home-matching-product-freeze-20261117`  
状态：`OWNER_PHASE_A_SCOPED_FINAL_ACCEPTED / PHASE_B_ENGINEERING_AUTHORIZED / PHASE_B_EXECUTION_HANDOFF_PENDING / PHASE_C_D_NOT_STARTED / A6_MEETING_DEFERRED / NO_MAIN_MERGE_OR_RELEASE`

## 1. Owner明确决定

网页GPT顾问基于[阶段A A1–A4限定验收](../workflow/V2_PHASE_A_ADVISOR_SCOPED_ACCEPTANCE_20261120.md)单次提请Owner确认“是否最终接受阶段A的限定验收，以及是否授权启动阶段B工程实施”。Owner明确回复：

> 我同意**正式接受阶段A在限定自动化范围内的工程交付，请继续阶段B**

据此本次**独立确定两个结论**：

1. **`PHASE_A_OWNER_SCOPED_FINAL_ACCEPTED`**：接受阶段A A1–A4在**报告与自动化覆盖范围内**的工程交付，采纳此前网页顾问`ACCEPTED_WITH_RESERVATIONS`。不是PHP8.4、MariaDB真实驱动/并发/迁移、设备/跨端、真实KYC/Push及生产合规PASS，也不是main合并或发布。
2. **`PHASE_B_ENGINEERING_AUTHORIZED`**：明确允许现有EliteSync本地Codex项目会话按已采纳的四阶段路线图启动**阶段B：首页与内容权限产品化**（B1–B4），进行有边界的Flutter/Laravel/必要安全schema与迁移定义开发及隔离自动化测试，Codex自治拆版本与自验，阶段结束集中交付一包报告给Owner与顾问审阅。

阶段A已结案于**限定工程交付范围**，不应因为环境缺证据而倒改已通过的自动化判定；全部未验证环境和权限必须继续在后续总体验收前明确保留。**阶段C/D未启动**，不能用本次B授权直接实现具名用途/对象级删除完整流程、关系旅程全量改造或正式UI。

## 2. 工程身份与安全起点

阶段A已核的产品源码`4e6a5be6dcb7095438fb0a815c7831b14ffb561b`，含报告/证据的固定交付`07b51a6de9695f5358b6bea2a59acd5be24ab6c2`，开发分支`codex/v2-phase-a-security-baseline-20261119`。Codex报告实际阶段A开发根`D:\EliteSync\development\v2-phase-a-20261119`；报告并未证明Owner本地未来B工程根实时身份。阶段B应**以确认含A1–A4安全修复的最新合法源码为基线**，优先在安全的新分支/隔离工作树上开发；不得回到旧S1`1d8b...`而丢失A修复，也不能把GitHub治理HEAD当工程HEAD。

特别保护`D:\EliteSync-v10`旧main工作树历史43项未暂存/213未跟踪，以及独立S1审阅工作树的现有未跟踪资料。**Codex须先只读确认安全起点与dirty/index状态**；如无法唯一追踪到A成果或存在覆盖风险，停止危险操作并报告Owner，不盲目checkout/reset/stash/clean、复制或合并旧脏main。

## 3. 阶段B被允许的边界

阶段B以[既有路线图B节](../product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md)与具名Owner内容/评论决定为合同：

- **B1 首页双内容域**：访客仅明确获准的`PUBLIC_EDITORIAL`官方正文；登录后精选/好友按`PUBLIC_AUTHENTICATED`与`FRIENDS`及Block读取，编辑推荐指向仍有权的原作品，不默许官方正式转载。
- **B2 作品与评论策略**：新作品默认`FRIENDS + FRIENDS_ONLY`，SELF仅本人读且默认OFF；SELF→FRIENDS遵守CMT-T1对显式OFF、隐式默认OFF、UNKNOWN的区别；扩大受众前安全摘要并确认，不能带旧评论/附件一并升权。
- **B3 历史评论与独立权利**：继续沿用阶段A原受众∩当前作品读权保护；本人评论撤回展示和作品作者隐藏第三方评论展示分主体、分语义，不自动物理删除。合法独立回复仅在原受众/上下文能核实且不泄密时保留，否则安全隐藏。评论者中性状态只在仍有权且不泄密时可见，不虚构申诉或推送。
- **B4 全通道权限一致**：列表、详情、搜索/推荐、通知指针、缩略图、媒体URL、引用、深链、Block、账户切换、缓存都必须守当前权限与历史原受众交集。未知/旧版受众按fail-closed，不开放非法受众。

允许Codex为实现上述范围修改APP/API/必要数据库**schema与迁移定义**和自动化测试，在确认隔离、无真实用户数据的本地测试环境运行PHP/Flutter单元、Widget及有界集成测试。文档/脱敏工程分支可按Local-first既有规则安全备份GitHub**非main分支**。由Codex自治任务子拆与自验，Owner只在阶段完成或出现真正不可逆/跨权利新事项时集中决策。

## 4. 明确保留、绝不自动开放的权限

- **不授予**正式官方转载用户素材作为访客可读内容的许可采集/发布，也不将`NEW-PC-05`顾问建议延期写成Owner永久排除；若缺具名素材/版本/受众授权和合法权利，不实际转载。
- 阶段B**不**实现阶段C的对象级删除申请真实受理/完成、跨用途授权和派生重算；普通作品撤下或评论展示撤回绝不冒称真正数据删除。
- **不**联系/采购/集成真实身份KYC、Push、RTC供应商，不访问生产/共享数据库或真实用户身份、聊天、安全案卷；不执行不可逆真实资料清理或历史批量回填。
- **不**操作真机/模拟器、生产/公开环境、APK发布，不合main、不创建正式发布候选，不召开A6正式UI会议。隔离测试必须先确认真实环境身份、安全DB配置与无真实资料；不明确即保持`NOT_RUN`。
- 任何新增实质用户权利、跨用途、对第三方永久删除或真实外传等，仍需Owner明确独立批准；已有Owner概念合同不重复审批，但顾问详细UI草案不能自动当Owner逐字批准。

## 5. 阶段B交付、阶段A保留与停止点

阶段B以**一份综合工程证据包**交付：明确基线/实际root/分支/提交、B1–B4源码与安全迁移、对应具名Owner接受规则、真实执行的正反/UNKNOWN/失权/历史权限案例、PHP/Flutter测试环境与命令结果、原始日志身份、仍OPEN的外部/法律/媒体/设备问题、回滚风险以及`PASS/PARTIAL/FAIL/UNKNOWN/NOT_RUN`结论。顾问集中复核，Owner最终验收后另决定是否进入C；不拆为每个G一次审批。

阶段A保留项继续`OPEN/NOT_RUN`：**项目PHP`~8.4.0`而A测试PHP8.5.3**；MariaDB真实驱动、并发、迁移/回滚；真机/跨端；真实KYC/Push；历史原43PNG`PENDING_BINARY_UPLOAD`；F-01`READABILITY_PARTIAL`；旧1011804/UI-AUDIT-01旧`FAIL/UNKNOWN/NOT_RUN`。建议阶段B在**确已具安全隔离PHP8.4或MariaDB测试环境**时顺带补证，并分别记录，不能使用生产库补证，也不以缺环境为由重新否决已接受的A限定成果。

状态：`OWNER_PHASE_A_SCOPED_FINAL_ACCEPTED / PHASE_B_ENGINEERING_AUTHORIZED / PHASE_B_HANDOFF_PENDING / PHASE_C_D_NOT_STARTED / A6_MEETING_DEFERRED / MAIN_MERGE_RELEASE_NOT_AUTHORIZED`。网页GPT不能直接声称已在Windows启动Codex或完成阶段B工程。
