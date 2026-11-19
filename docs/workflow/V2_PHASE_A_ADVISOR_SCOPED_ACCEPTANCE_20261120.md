# EliteSync V2｜阶段A A1–A4集中工程交付：网页顾问限定验收（2026-11-20）

状态：`PHASE_A_SCOPED_ACCEPTED_WITH_RESERVATIONS / OWNER_FINAL_ACCEPTANCE_PENDING / PHASE_B_NOT_AUTHORIZED / MAIN_MERGE_RELEASE_NOT_AUTHORIZED / A6_MEETING_DEFERRED`  
治理分支：`governance/home-matching-product-freeze-20261117`  
Owner授权：[路线图采纳及阶段A工程启动](../decisions/OWNER_V2_ROADMAP_ACCEPTANCE_AND_PHASE_A_ENGINEERING_KICKOFF_20261119.md)  
任务单：[阶段A合并安全工程](../versions/v2/V2_PHASE_A_SECURITY_BASELINE_CONSOLIDATED_EXECUTION_BRIEF_20261119.md)  
工程开发分支：`codex/v2-phase-a-security-baseline-20261119`（经GitHub回读当前HEAD为下列交付commit）  
工程源基线：`1d8b485bf4f314d42431bb62a293a3fef9e9c8af`  
工程产品源码：`4e6a5be6dcb7095438fb0a815c7831b14ffb561b`  
工程交付（报告与机器摘要）：`07b51a6de9695f5358b6bea2a59acd5be24ab6c2`  
本报告是**独立顾问限定验收**，不代表网页顾问在本地运行PHP/Flutter或具备Owner最终验收权限。

## 1. 本轮实际核对范围与身份

Codex交付：[PHASE_A_ENGINEERING_REPORT.md](https://github.com/zcx369658780/EliteSync-v10/blob/07b51a6de9695f5358b6bea2a59acd5be24ab6c2/docs/versions/v2/phase-a-20261119/PHASE_A_ENGINEERING_REPORT.md) 与 [evidence_summary.json](https://github.com/zcx369658780/EliteSync-v10/blob/07b51a6de9695f5358b6bea2a59acd5be24ab6c2/docs/versions/v2/phase-a-20261119/evidence_summary.json)；后者包含测试命令/退出码、版本、源文件SHA256及本地原始日志SHA256。

- 独立确认GitHub远端工程分支当前指向`07b51a6d...`，源基线→产品源码为`ahead 2/behind 0`，共**32个工程文件变更**；产品源码→报告交付为`ahead 1/behind 0`，仅增加**报告、JSON证据摘要与ACTIVE_STATE文本**。GitHub工程产品源码与报告身份未混用。
- 直接在固定产品源码`4e6a5be6...`回读涉及A1–A4的PHP、Dart、迁移定义与定向测试源码，并与阶段A任务单逐项对照。此为远端**源码和测试设计抽样**，非对所有变更及全部运行行为的独立验证。
- Codex报告本地开发根`D:\EliteSync\development\v2-phase-a-20261119`，分支、HEAD、原脏main与旧S1工作树未受损、索引干净。**网页顾问未能独立接触本地Windows文件系统**，因此这些本地现场事实标`CODEX_REPORTED`，不能称外部独立证实全部零写入。
- GitHub本次没有原始PHP/Flutter运行日志及临时图片，仅有`exit_code=0`和日志SHA256的**Codex生成摘要**。日志路径`D:\EliteSync\development\v2-phase-a-evidence-20261119`为本地保留；不能从摘要本身独立复算110项PHP和140项Flutter的执行过程。

## 2. A1–A4范围内独立源码确认与裁决

| 合同/AC | 本次从实际固定源码确认的事实 | 裁定边界 |
|---|---|---|
| **A1 身份/正式Match阻断** | `TrustedIdentityService::participationAllowed`要求`testing + SQLite :memory: + 无DB URL + 合法签名合成凭据`；`requireParticipation`进入报名/自动参加及候选/正式关系相关入口，`ProfileReadinessService`另校验。旧`DevRunMatchingCommand::handle`立即失败，不再执行旧直接写路径。定向`V2PhaseASecurityTest`含伪造/生产环境/失效凭据、旧CLI拒绝与Lifecycle案例。 | `ACCEPT_IN_NAMED_TEST_SCOPE`；真实提供者仍`PENDING`，不得称真实KYC/正式报名可用；TEST_ONLY成功与正式资格隔离。 |
| **A2 原候选绑定历史合法形象** | 新`CandidateShowcaseSnapshot`在提案揭晓时绑定原批准发布、版本和原受众，只保留有限发布字段；`SlowDatingService::projectLocked`读取绑定快照。旧候选无绑定不回填当前发布，访问要求当前发布/权限/Block/版本access_epoch仍有效；撤回及收窄受众推进epoch。`V2CandidateSnapshotTest`含新旧发布、撤回、Block、过期、非参与者与历史缺绑定。 | `ACCEPT_IN_NAMED_TEST_SCOPE`；历史读权是否实际满足所有MariaDB并发、跨端媒体传播及合法保留条件仍`NOT_RUN/OPEN`。联系人独立可读权和候选匹配权不能混为一谈。 |
| **A3 UNKNOWN先查权威** | 新`LifestyleDiscoveryService::commandResult`按当前用户、原请求键、规范化hash/版本返回`APPLIED/NOT_APPLIED/CONFLICT`；Dart `LifestyleController.load`恢复pending后调用`reconcile`而非自动`retry`。查询未知/切号不自动发高影响写入，只有显式重试时再查并以原键尝试；定向PHP与Dart测试覆盖丢回包、未知、冲突和换号。 | `ACCEPT_IN_NAMED_TEST_SCOPE`；持久化成功、分布式超时/故障、真实MySQL/MariaDB锁顺序和设备恢复均须未来专项实际验证。 |
| **A4 原受众与失权保护** | 新迁移`original_viewer_ids`为可空JSON；`PostAudience::commentViewersLocked`在新评论提交时捕获有限原读者；评论读取使用原读者∩当前作品权限/作者与Block，旧NULL不重显。列表与计数过滤无权对象；`V2CommentAudienceTest`证实旧NULL不可读、新增好友不继承旧评论、失去作品读权被拒；账号隔离/私有缓存测试有代码。 | `ACCEPT_IN_NAMED_TEST_SCOPE`；这只是最小保护，**不意味着已完成B阶段的分主体撤回/隐藏、父回复树、评论媒体与PUBLIC域**。 |

对测试源码中的“正确断言存在”与“真实执行通过”分别记录：本顾问能确认主要反例断言确实写入远端源码，**未直接执行它们**。

## 3. 自动化测试证据与未验证环境

| 维度 | 当前证据级别 |
|---|---|
| PHP 11个具名测试文件 | Codex报告：**110项/1,429断言，0失败/错误，exit 0**；`evidence_summary.json`记录真实命令、版本与日志SHA；**原始日志本地保留未独立回读** |
| Flutter定向Widget/单元与传输缓存 | Codex报告：**140项、0失败、exit 0**；JSON记录命令/日志SHA；**未重新运行或回读原始日志** |
| Dart八个指定受影响文件分析 | Codex报告：**0问题、exit 0**；只支持指定文件，不等于所有Flutter源码全量分析 |
| PHP/Laravel/Flutter/Dart实际环境 | 报告：**PHP 8.5.3 / Laravel 13.39.0 / Flutter 3.41.7 / Dart 3.11.5 / SQLite :memory:**；所有这些运行版本为Codex报告，顾问没有本地独立执行 |
| **PHP版本兼容性** | 根清单声明`PHP ~8.4.0`，实际测试在PHP **8.5.3**：**PHP 8.4运行兼容性`NOT_RUN`**。不得把PHP8.5的通过直接推断为声明环境通过 |
| **数据库行为** | 新迁移up/down及相关锁/HTTP在**SQLite内存**受控测试通过（Codex报告）；**MariaDB真实驱动/并发/索引/迁移与回滚`NOT_RUN`** |
| 设备与真实业务环境 | 真机/模拟器、跨设备传播、真实KYC/Push/RTC供应商、正式Match、全部G01–G10新动态`NOT_RUN/PARTIAL_BY_SCOPE`；旧工程`FAIL/UNKNOWN`不重判 |

**范围声明**：此处接受的是`PASS_IN_NAMED_AUTOMATED_SCOPE`作为有报告+机器摘要+定向源码佐证的**Codex工程自验结果**；不是“网页顾问复跑110/140项均PASS”。未提供全部原始日志不是对Codex报告的否定，但限制了独立运行证据的等级。

## 4. 保留风险、阶段边界及后续处置

以下集中归三类，**不要求为每个Gate开新的小审批门禁**：

1. **环境/可迁移性阻断**：PHP目标版本`~8.4.0`尚未在PHP8.4运行；MariaDB并发与实际迁移、权限受众JSON、历史快照epoch与回滚均仅在SQLite内存证明。要将阶段A宣称为真实部署候选，必须以后获得Owner相应测试/环境权限并取得可回读的真实环境证据；在此之前不建议main合并或发布。
2. **法域/真实服务/设备阻断**：真实身份、Push、RTC供应商/合同、个人信息与第三方保留、跨端失权时效、设备/模拟器及生产配置均无本批真实证据，不能开放真实报名、真Push或作上线验收。
3. **后续B/C/D业务合同仍OPEN**：完整访客/登录双内容域、用户作品默认受众、评论者撤回/作品作者隐藏/回复树、具名用途与数据删除受理、通知及高保真UI继续按已获Owner路线图分期。本阶段A4小幅补原受众不等于提前完成B；NEW-PC-04/05没有新增授权。

**G项精确口径**：按Codex报告，`G01/G02/G03/G06/G08`只有与阶段A相关的特定自动化子场景`PARTIAL`；`G04/G05/G07/G09/G10`未运行本轮对应完整专项。原43份PNG`PENDING_BINARY_UPLOAD`、F-01`READABILITY_PARTIAL`及旧`10.1.18-dev/1011804` UI-AUDIT-01`UNKNOWN/NOT_RUN`均保持。

## 5. 最终阶段A顾问判断

- `PHASE_A_AUTOMATED_SCOPE_ACCEPTED_WITH_RESERVATIONS`：A1–A4的主要工程目标在指定源码/测试设计及Codex报告的定向自动化范围内具备可采纳证据，**不要求再为已有四项分别审批**。
- `OWNER_FINAL_ACCEPTANCE_PENDING`：顾问不代替Owner终验；不自动执行原未授权的PHP8.4/MariaDB/设备/真实服务验证，不把未知改PASS。
- `PHASE_B_NOT_AUTHORIZED / A6_MEETING_DEFERRED / MAIN_MERGE_RELEASE_NOT_AUTHORIZED`：阶段B可进入Owner集中决定是否授权实施；此文档不是阶段B任务单。
- `S1_CLOSED_AT_REPORT`仍作为上一个独立静态审计历史结果；阶段A正常开发与隔离测试是后续另一份Owner授权的成果，身份和历史不得混淆。

建议Owner可以接受**阶段A限定工程完成**并转入阶段B的有界实施准备，同时把PHP8.4+MariaDB兼容性作为下一次综合工程验证包的明确前置证据，而不是反复把A1–A4拆回微任务。是否授权阶段B、真实测试环境及其它外部事项，保留Owner后续明确选择。
