# EliteSync v10.1.2｜Astra独立审阅与R1同版集中返修任务

日期：2026-10-20。审阅主体：Astra / EliteSync GPT顾问。

**V10.1.2_CHANGES_REQUIRED / NOT_ACCEPTED / B1_AND_B2_SOURCE_FINDINGS / R1_TASK_ISSUED / OWNER_MANUAL_DISPATCH_PENDING / NO_PRODUCT_MAIN_INTEGRATION / V10.1.3_NOT_STARTED**

## 1. 独立裁决

v10.1.2候选实现广泛且已有实测证据，但本次Astra直接读取GitHub源码，发现**两个未被最终测试矩阵覆盖的版本内授权/生命周期缺口**，不应宣布整版接受。它们均属于冻结AC-10.1.2-02/04/07/09/11，不是要求新增功能版、第三方供应商或全仓形式化审计。

- **B1（P1，受控接触与反枚举）：正式关系申请允许仅凭任意peer_id向无既有受控接触资格的目标建立可见PENDING_MUTUAL记录，且可撤回后换幂等键立即反复重建。** 可能构成新的陌生人骚扰/账号存在探测旁路。
- **B2（P1，旧提案生命期与当前权威）：用户明确EXIT，或PAUSED后重新opt-in进入新participation generation时，原未决提案仍可能作为可浏览/可操作的PENDING或ACCEPTED_BY_ONE提案显示、返回对方Showcase；当前写端却因旧generation拒绝，旧未决slot仍可能占住新轮次。** 用户可见事实和真正决定权限不一致。

上述是Astra依据实际源码及冻结合同作出的**直接源码发现/高置信度可构造反例**，Astra没有进入Owner Windows/MariaDB运行该新反例，没有证据指向真实用户曾被骚扰、被枚举或发生私密数据泄露。R1应以受控虚构账号、真实入口和独立MariaDB明确复现前后对照；若执行机制足以排除反例，必须提交准确实际调用与持久证据，不编造红测。

冻结计划：`docs/versions/v10.1.2/plan.md`，Blob `2ebd2ea05b3d7dae52cc3995de913eeb0fde375e`，尤其§4.1/4.2/4.4/4.5、AC-02/04/07/09/11。Owner决定：2026-10-19 PD-1019-03/04/08/09，禁止未经收件方控制的陌生人接触旁路与按编号枚举，不允许关系/身份/消息同意互相冒充。

## 2. 已独立核验的精确候选

| 对象 | GitHub身份 |
|---|---|
| 实时main（审阅时） | `251f822392903804a0bdc12bf045756101939829` |
| 冻结计划Blob | `2ebd2ea05b3d7dae52cc3995de913eeb0fde375e` |
| 任务单Blob | `4f39db8e003da0889c7d23582652c0787c22bfea` |
| 候选源码Commit | `ebade52179b6ac7b76ba2f2992d31981fa995a00` |
| 候选源码Tree | `c037f294dde9ea9b696188393f0fff47bb6fe6b8` |
| apps Tree | `9344354d0da95f0388aa922b2775b1e8d18f18b7` |
| services Tree | `a0eb88caf5ed65451b56b5363b7af667dadd6fd6` |
| 最终交付Commit | `900942426e965092d3852771c4126d77210677c4` |
| 实施报告Blob | `04e11a139d767d7173e51e0ffdad1d18261a853c` |
| artifact_manifest.json Blob | `55eb35bc8bb8e2ff9dbc5ac5fba465a837f1a24a` |
| 临时审阅Commit/Tree | `70e122ddfbaa2d89e6c46bb21fb49a8fe8ae44d4` / `b9ee92719e1ae4420e530b964321ffdbdef7c55b` |

已直接核验源码相对main的3提交后继、41个产品路径，以及41/41 manifest路径与接受候选Tree中Blob一致。交付后继只改文档，main未合产品。审阅包117份文本的完整远端哈希读回属于Codex报告；Astra读取了代表性stdout、runner、JSON、核心源码及非作者报告，不冒称本次重新逐字回读所有117件或亲自执行测试。

## 3. B1：未受控的正式关系申请

直接源码：
- `services/backend-laravel/app/Http/Controllers/Api/V1/SlowDatingController.php` 方法 `requestRelationship`：仅验证 `peer_id` 为正整数及幂等键。
- `services/backend-laravel/app/Services/FormalRelationshipService.php` 方法 `request`：只以 `JourneyStore::users([$actor,$peer])` 核账号可用/Block，再检查同pair是否有非终态行，就插入 `PENDING_MUTUAL` 与审计。没有收件方许可、先前合法连接/好友/受控邀请来源、请求开关或冷却限制。
- `services/backend-laravel/routes/api.php`：新版 `POST /api/v1/formal-relationships` 在auth+account.active组内，没有该入口的专门频率/场景门。
- `FormalRelationshipService::listing`：所有命中user_a/user_b的申请均会返回给目标。原作者可 `withdraw` 置终态，再更换幂等键立即对同一目标创建新记录。

静态可构造结果：拥有正常凭据的A仅猜测或知道另一个活跃账号B的数值ID，就可以提交申请；不存在目标返回404、活跃目标可能返回200、禁用目标返回403，存在账号探测区别；交互无需Match、CN、MC、好友或接收方邀请。双确认/双实人认证虽然保护ACTIVE与深字段，但**不能替代对PENDING接触入口的防骚扰控制**。本项不要求强制先参加恋爱匹配：可沿用现有合法好友/Connection/接收方签发邀请等受控来源，确保双方若本来线下相识也有明确、可验证的合法入口；不能把原始user ID当接触能力。

需要的R1正负证明：有合法受控接触来源的正式关系请求成功，仍不能自动激活；陌生人无来源、关闭或撤销接收许可、被拒/反复重发、Block、禁用/注销、错误actor/自请求、枚举连续ID不得建立待确认关系或增加审计/通知骚扰；错误返回不暴露被探测账号存在性。限制请求频率及冷却可**复用已有受控Social请求合同**，不得引入新的目录或陌生人自由文本。正常取消/拒绝不是违规，不能新增Safety Finding。测试须记录源权限、HTTP、formal_relationships与journey_audits/通知实际变化，不能仅测最终ACTIVE未发生。

## 4. B2：退出/换代际后的未决提案仍像当前授权

直接源码：
- `SlowDatingService::participate`：`pause`或`exit`只更新matching_participations.state/revision；`opt_in`在非ACTIVE时增加generation。没有清退或显式处理尚存的未决提案和slot。
- `SlowDatingService::projectLocked`：判断pairAllowed、账号状态、expires_at与proposal.state是否为PENDING/ACCEPTED_BY_ONE/MUTUALLY_ACCEPTED，但**没有在投影未决提案时核验两人的当前participation.state/generation**。
- `SlowDatingService::decision`：对accept/decline强制旧generation与当前ACTIVE一致，因而旧提案写入会409；与上面的可读/可操作投影不一致。
- `SlowDatingService::reveal`：若旧未决slot仍存在，未到期无法释放，会409阻止新揭晓。
- Flutter `slow_dating_journey_page.dart`：`exit`按钮只发participation动作，仍按proposal.state决定是否渲染候选和accept/decline/withdraw按钮；没有当前代际不一致提示/失效态。
- 新测试 `V1012JourneyTest::test_peer_cannot_complete_an_old_proposal_after_acceptor_pauses_and_reenrolls` 已证明旧代际accept被409，但**没有assert GET /journey、/matches/current、/match-rounds/current与APP不再把该旧提案呈现为有效可接受候选**。

确定性静态反例：A/B在gen1的有效未决提案，B明确EXIT（或暂停再opt-in至gen2），原PENDING/ACCEPTED_BY_ONE没有被转为历史失效、slot没有清理；只要expires_at未到，A通过GET /journey依然可取B当前Showcase并看到决策控件；进一步决策又409。这个矛盾不能通过“写端已拒绝”视为AC-02/04完全通过。即使选择保留暂停期间待决提案，恢复新代际必须有明确、双方一致、不会静默继承的策略。

R1应锁定以下结果而由Codex选择最小安全实现：
1. 对明确EXIT的当前未决提案，按照已冻结的独立withdraw/terminal语义停止新授权投影和新增同意，历史状态/审计不丢；不得伪造对方拒绝或增加Safety记录。
2. PAUSED可保留冻结计划允许的本人明确withdraw操作，但再次opt-in新generation后，不得默默把旧generation作为可接受当前候选；旧slot的处理必须是显式、可理解且不会阻断新轮次的合法机制（必要时要求先由本人明确withdraw，而不是偷偷替双方下决定）。
3. `proposal/current`、历史round投影、Flutter状态以及Match衍生新CN资格采用一致的当前生命周期/代际边界；既有双方合法形成的CN/MC独立权利不因此自动销毁。
4. MariaDB中至少复现一次EXIT→等待/回读、PAUSE→新generation→旧proposal的HTTP/DB实际对照，并测用户锁等待后退出先COMMIT、旧读请求继续时不返回无权新私密内容；未到期旧槽与新轮次、合法正例均核实。不能用500、死锁或测试异常算拒绝。

## 5. 已完成成果与观察保留，不能重做归零

仍保留并接受作为**候选执行方证据**：
- 41/41产品Blob身份已Astra独立远端核验。
- scoped后端71 tests / 713 assertions，退出码0（2 Deprecations及2 PHPUnit Deprecations保留）；补充11/150不与71合计。
- scoped Flutter 39 tests，退出码0；APK `com.elitesync.v1012dev` / `10.1.2-dev` / `1010201`，双ABI，Codex报告安装/pull SHA256同为 `5728683b4f3cf45b8e6de9bcba1952d8f19c8e43c6f143bcfcc81b8f8da91b39`。
- 受控MariaDB正式关系独占200/409、提案revision200/409、168h到期、CN/MC正反、6组字段撤权、14表受控重启持久、四字段实际读取、Web与获准AVD证据；均标明`CODEX_REPORTED / LOCAL_ONLY`。
- TEST_ONLY身份隔离，没有真实身份供应商、真实用户关系激活、手机/RTC媒体、系统网络授权。
- 初始失败、修复、原历史v10.1.1误清开发库/恢复及v10.1.0 PARTIAL不归零。v10.1.1功能和集成接受保持有效。
- R1不得重跑无关算法oracle、完整RTC媒体、所有Flutter/后端历史测试或再次构建APP（除非apps源码改变）；原获准模拟器授权和开发环境边界不得擅自扩大。

另一个证据注意点（不单独构成P1）：本版公开并发 `scripts/races.py` 使用全局`INNODB_LOCK_WAITS`数量而非精确reader与writer connection ID配对，报告称真实锁等待，但现有副本不足以独立排除无关等待者。R1补受影响入口的定向并发回归时应记录准确reader/writer连接身份、明确锁等待与撤权COMMIT顺序及新请求HTTP/副作用；无需对原所有6组再做全量实验。

## 6. 单次R1集中返修执行授权边界

此文签发后状态为`R1_TASK_ISSUED / OWNER_MANUAL_DISPATCH_PENDING`。**必须由Owner把本文件完整交给本地Codex，才获本次同版修复执行授权。不要自动派发或启动v10.1.3。**

允许在v10.1.2原受控开发授权内：
1. 保护已发布源码 `ebade521...`、交付报告 `90094242...`、审阅原HEAD `70e122dd...`、原dirty根、既有备份/测试卷和所有失败原件。
2. 直接对上述B1/B2现有服务/Controller、与之直接相关的Flutter入口和必要测试做一次集中修复，补最小可复核真实MariaDB/HTTP/APP正反证据；正常工程错误自行诊断修复。不改冻结plan与其它已接受产品合同。
3. 如修改apps则用最后固定源码重建v10.1.2开发APK并在本版获准AVD实际readback，不能用原APK证明新Flutter源码；只改services时可保留旧APK身份＋新后端源码的准确组合。
4. 普通`non-force`推送独立R1候选及单份原 `docs/versions/v10.1.2/IMPLEMENTATION_REPORT.md` 的追加R1章节。原始stdout/stderr、保留失败、锁等待/边界回执可仅在新或既有单一独立审阅分支提交**最小脱敏**副本，原私密配置/SQL/APK/设备日志等仍LOCAL_ONLY。
5. 后端测试禁止触达旧开发库或任何恢复卷；继续沿用有效APP_DB_CONNECTION/SQLite防误清门。范围内本版新库使用之前先核准确属/恢复点，最后只停止R1专属资源并保留卷。
6. 由非作者进行一次有界代码/反例复核，最终提交源码Commit/Tree/apps/services、报告及证据Blob、差异、测试真实exit和所有NOT_RUN；不要自行ACCEPTED，不合main，不清理分支，不启动下一版。

如果发现实际受控关系请求是有意允许陌生人直接发起，也不能仅靠命名说明安全；必须在不增加陌生人可骚扰渠道、不允许user ID枚举和不改变双向确认合同的前提下提供可审计的合法受控接触依据。若需新的Owner不可逆产品决定，只暂停该子项并报告。

**正常出口：V10.1.2_R1_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE / NOT_YET_ACCEPTED / V10.1.3_NOT_STARTED**。Astra在Owner返回本次唯一R1候选后再独立终验。本文件不是集成main/生产发布/供应商采购许可。
