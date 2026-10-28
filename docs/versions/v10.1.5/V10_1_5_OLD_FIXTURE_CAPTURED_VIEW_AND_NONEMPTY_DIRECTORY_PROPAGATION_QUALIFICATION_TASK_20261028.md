# EliteSync v10.1.5｜旧18件Fixture捕获视图恢复边界与非空目录继承传播／回滚资格——Owner方向A综合任务

**状态：OWNER_APPROVED_DIRECTION_A / FORMAL_TASK_PUBLISHED_OWNER_MANUAL_DISPATCH_REQUIRED / OLD18_READ_ONLY / ONE_NEW_NONEMPTY_FIXTURE_CYCLE_MAX / ZERO_RESTRICTED_CHILD / ZERO_GRADLE / G2_BLOCKED**

日期：2026-10-28（Asia/Singapore）  
权威仓库：`zcx369658780/EliteSync-v10`。  
Owner在新会话明确选择并同意方向A；这**只**授权本任务的有界调查、任务自有新fixture的有限一次实验及证据交付。Owner保有重大不可逆、历史ACL修改、真实进程启动预算与新门禁的最终权限；Codex必须由Owner本地手动派发。GitHub发布不等于派发或执行。

## 0. 目标、区别于前轮任务的新增证据

在不再次启动受限child、不触碰旧18件fixture、不使用G2的前提下，一次性形成：
1. **18件历史fixture逐件证据／可恢复承诺分级表**：可靠的原`OWNER/GROUP/DACL` SDDL与`0x8404` control、当前`0x8004`的比较范围；明确flags7只含O/G/DACL，旧完整self-relative binary及SACL历史原件缺失；不得补造不可追溯的历史字节或以ACE相同算恢复。
2. **旧非空目录的只读影响面／引用／回滚资格判定**：识别哪些是目录、是否非空、当前后代和祖先、继承来源、重解析／硬链接、权限及潜在跨任务引用，给出可证事实与未证限制；若不能证明完全边界就明确BLOCKED。
3. **唯一任务私有的微型非空目录真实实验**：仅当下述防护门满足，在新建的可丢弃父目录及有限后代上做最多一次父目录DACL-only变更与最多一次父目录恢复，观察对后代的实际control/ACL/身份传播；明确停止、回滚和剩余不一致。不把实验成功外推旧树或G2。
4. 给Astra一份具名、可审计的下轮Owner决策建议：历史完整SD无法证明的永久限制、Captured-view语义恢复**可能**具备的客观条件、仍不可动旧18件的具体阻断，而非本轮自行改历史验收合同。

本轮不是旧cfca任务重做，不重跑N01/N02、10项mock、Application Error查询或8186 child；只复用其已归档源与原证。旧18件始终**写入、恢复、rename、delete、recreate均0**。

## 1. 权威与输入冻结（须fresh读取）

- 新任务发布前live main HEAD `14e676af766cc88c58f50cb60afc4821e5944a3b`，Root `cc2278d6443a98964b29041fb474ccf53f611f4c`，为写单前基线而非永远最新；开工前fresh重新读main及`docs/workflow/ACTIVE_STATE.md`、本任务全文和实际Blob，差异须重核。
- 唯一已接受v10.1.4产品：main完整`apps` Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`、`services` Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。研发v10.1.5仍`PARTIAL_NOT_ACCEPTED`、`AC05_OPEN`、`PRODUCT_MAIN_NOT_INTEGRATED`，v10.1.6未启动。
- 最新未接受候选、建议的**唯一候选Parent**：`cfca26beb6e3710b46f9c3559cce706c332a61b9`，sole Parent `8186cebc94661bcdc229ee5b62b31871dc784a4c`，Root `462e4e542ebb6dbc2f6e9ed721134129c5a190de`；候选完整`apps` `5af7a9d0042be19437616e969e260658b67e9353` / `services` `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。候选未被整版接受，不能合入main。
- 2026-10-28交接 `docs/workflow/ELITESYNC_V10_20261028_SESSION_HANDOFF_AND_OWNER_DECISIONS.md` Blob `6e4c96977cf7bd69fd270fe3d92f5291c901079d`；`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`。
- 前轮正式任务 Blob `19a25f1446e08ff875d1533f78b8cf2726c2d795`；cfca报告 Blob `edc910819c6614cfdd8f0db02274ebfd8f9166f3`、索引 `4c7121c33030d66908c2f1423c1fddee07098c79`；Astra独立审查 `14be1423ceb3970b46af86cdc37fe0474651df12:docs/versions/v10.1.5/CFCA26BE_EARLY_DIAG_AND_SD_RECOVERY_ASTRA_REVIEW_20261028.md` Blob `7fe6528893fd711736d2cbd80f64f286709eda86`。旧8186原始report/index及LOCAL_ONLY原证必须用固定Hash/身份核对，不从main猜未集成文件。
- 原G2一次性条件合同 Blob `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c`，目前无实际运行资格；旧完整APK与旧Gradle G均1/1耗尽，旧A gate封闭。G2截至Codex前次报告max1/reserved0/Popen0/claim absent，仅历史`CODEX_REPORTED`，绝非本任务新额度。

## 2. 工作A1：逐件只读恢复语义与来源矩阵

对旧18项只读检查，严格限于8186具名micro-fixture及原已归档相关证据，不扫描D盘或跨项目；对每件记录匿名ID、旧证来源Blob/Hash/采集时间与flags、原O/G/DACL SDDL和control、当前flags7视图、原/现ACE顺序、owner/group、DACL revision、Volume/FileId/link/reparse、路径规范化及父链身份、对象内容Hash、当前继承状态和可核对的引用证据。完整原值/SID/绝对path保留LOCAL_ONLY，GitHub只放脱敏摘要、Hash和判定。

按**四层**分开判读：
- `HISTORICAL_OGD_CONTROL_EVIDENCED`：仅证明旧时确有被捕获的O/G/DACL及control字段，非完整SD。
- `CURRENT_FLAGS7_VIEW_VERIFIED`：只证明现在读取的flags7 O/G/DACL视图与身份；与过去有差异时明确标出。
- `CAPTURED_VIEW_RESTORATION_CANDIDATE_NOT_EXECUTED`：在未来具名Owner另授权、完整影响/回滚资格成立时，可提议回到旧已捕获字段值；**本任务不能写旧对象**。
- `HISTORICAL_FULL_SD_BINARY_OR_SACL_UNPROVABLE`：原完整binary/SACL未捕获，不能由新读出或重新序列化回溯证明历史原字节一致；SACL未被读取不等于SACL不存在。

`SE_DACL_AUTO_INHERITED(0x0400)`是security descriptor control，不是ACE继承标志；仅ACE/owner/group/content匹配不足以证明原状。不得改变旧验收/失败定义，把“可比较”写成“已恢复”，或将旧18项0/18更改为PASS。

## 3. 工作A2：非空目录、引用与可回滚资格只读门

基于旧18项目标及具名父链，不运行会改变ACL的旧树探针：判断每个目录是否非空、有多少当前可见直接子项与安全可界定的有限后代、继承DACL/ACE及保护位来源、与其它任务或工作树的链接/引用关系，以及父目录`DELETE_CHILD`、rename/delete、hardlink/reparse等潜在影响（**只读静态／允许的元数据API**）。只读enumeration必须显式限制在旧micro-fixture根，遇访问拒绝、异常深度、不确定链接/不可完全证明的引用则标`UNKNOWN`，不转成`NO_REFERENCES`。不得做任何实际父目录delete/rename权限探针。

分别给出`RESTORATION_SCOPE_PROVABLE`、`CHILD_PROPAGATION_UNPROVEN`、`ROLLBACK_NOT_GUARANTEED`、`REFERENCES_NOT_EXCLUDED`等逐项判定；单对象影子/备份若不具备准确来源，不能表示真实旧树已具原态快照。

## 4. 工作A3：仅一个新的非空目录fixture、一次ACL变更与一次恢复

这是Owner方向A批准下的**保守实验上限**，只为新对象传播资格，不是新restricted child/旧18恢复预算。允许创建**一个全新任务私有、可丢弃且非空的父目录**，包含最多3个任务私有后代（建议1文件＋1子目录＋其下1文件），总不超过4个新对象；实验前后允许读取其元数据。真实OS ACL写操作至多：**父目录一次明确DACL-only变更＋父目录一次明确恢复**；不得独立修改后代ACL、换API多轮尝试或在失败后用另一个fixture再试。可进行不启动工程程序的Python静态/mock/本地Win32读取与此唯一实验所需API；不使用受限/对照child。

任何ACL写操作前必须具名证明：所有对象都新建在本任务独有目录且不是protected/worktree/Seed/SDK子树；volume/FileId、link、reparse/祖先及所有后代枚举安全；初始flags7 binary/SDDL/control/O/G/DACL和各对象内容/文件身份已持久化且flush；真实拟调用的mask与来源/回滚操作已冻结；所需权限仅限任务自有对象、不提权、不借共享父目录DELETE_CHILD；若恢复失败只能保留失败证据且不影响任务外资产。任一前置失败，写入0并记`NEW_NONEMPTY_FIXTURE_PREFLIGHT_BLOCKED`。

在满足前门时，对父目录DACL-only变更一次并逐对象读回继承传播，再对**同一父目录**进行最多一次DACL-only恢复并逐对象核对flags7 bytes/SDDL/control/DACL/ACE/O/G/FileId及内容，收集真实Win32/NTSTATUS或明确失败域与退出/日志Hash；SACL不请求、不写、不冒证明。发现子对象意外变动、恢复不能精确回到本轮开始捕获的flags7值、引用/身份不明，立刻`NONEMPTY_PROPAGATION_OR_ROLLBACK_BLOCKED`，留存原始失败（不得为“清零”继续写后代）。此实验本身不会验证旧18件历史完整SD或原旧非空目录的引用排除。

**实验硬上限：** task-owned新增文件及证据/日志的logical与allocated各不超过`32MiB = 33,554,432 bytes`（独立新任务上限，非继承上轮64MiB）；前／关键节点／末尾记录，接近上限即STOP，不复制旧1.36GB Seed、不生成额外checkout。若Windows ACL写操作需扩大权限/系统配置，直接阻断，不绕过。

## 5. 全局禁止事项、保护与强停止

**本任务均为零：** 旧18件的SetSecurity/SetACL/owner/group/SACL/删除/移动/重建/回滚；新restricted或普通对照child、CreateRestrictedToken/CreateProcessAsUser与任何等效重试；真实14项权限矩阵；Gradle/JVM/Flutter/Dart/AGP/Kotlin、G2 Popen/claim与任何预算账本写入；AAR/POM/APK、ADB/RTC、Gate2、工程network/Job/observer、真实DB/云端/生产/Push；系统用户、全局ACL/UAC/防火墙/策略/共享SDK/cache/Seed变更；D盘历史目录清理、Git clean/reset/rebase/prune/force和原证删除。

任务内不得以`runas`、提权、禁用安全工具、改ACL以获得权限、改test assert、放宽file-scope或重建旧对象求PASS。出现未知对象路径、原件缺失、元数据不一致、权限拒绝、原写面外溢、保护资产意外变化，立即停止相关实际动作并保留失败原件。实验若有意外影响，优先安全结束对任务外的所有写入，记录受影响对象；不要自行提升权限扩大回滚范围。

保护旧Seed3183、五保护根、已知122原证、旧claims/partial、527refs、dirty/untracked、SQL/APK及历史失败日志；按现存固定清单和可触达范围首尾只读核验，未全量扫描不得声称全量已证。

## 6. 交付合同、状态与独立复核

使用现有未接受研发候选`cfca26beb6e3710b46f9c3559cce706c332a61b9`作为单一来源Parent；以普通non-force候选归档**只新增本任务的报告、脱敏证据索引及确实必要的安全mock/实验源码**，不得更改apps/services产品Tree，不合main，不覆盖原报告或改写接受文档。只读异常和失败亦为合法交付，不能为了PASS扩大实验。

交付路径建议：
- `docs/versions/v10.1.5/OLD18_CAPTURED_VIEW_AND_NONEMPTY_PROPAGATION_QUALIFICATION_REPORT_20261028.md`
- `docs/versions/v10.1.5/OLD18_CAPTURED_VIEW_AND_NONEMPTY_PROPAGATION_EVIDENCE_INDEX_20261028.json`

公开报告至少包含18行匿名恢复证据矩阵、旧非空目录/引用/传播/回滚资格结论、新fixture实验前置/实际调用次数/逐对象前后flags7与错误域的脱敏Hash、证据等级、精确预算、保护首尾、原始失败保留、Git候选Commit/sole Parent/Root/完整apps+services Tree和正式Blob原字节回读；本机真实SDDL/SID/系统路径、原ACL binary、日志、PID和个人内容保持`LOCAL_ONLY_RAW`。

允许结论：`CAPTURED_VIEW_RECOVERY_BOUNDARY_DEFINED`（证据语义清晰）、`NONEMPTY_PROPAGATION_BOUNDED_SUPPORTED_ON_NEW_FIXTURE`或`NONEMPTY_PROPAGATION_QUALIFICATION_BLOCKED`、`OLD18_READONLY_NO_RESTORATION`。无论新fixture结果，旧18项`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTORATION_BLOCKED_WITH_ORIGINAL_EVIDENCE`继续开放；`CHILD_INIT_ROOT_CAUSE_NOT_PROVEN / CHILD_ACCESS_MATRIX_NOT_RUN_14_OF_14 / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / INPUT_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / AAR_POM_RUNTIME_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`全部不关闭。

成功或阻断均提交**单一集中候选**，确保公开文件脱敏与固定Git Blob/readback；区分`ASTRA_DIRECT_GITHUB_STATIC`、`CODEX_REPORTED_LOCAL_EXECUTION`、`LOCAL_ONLY_RAW`及`NOT_RUN`。**STOP等待Astra独立验收与Owner后续决定**。不得自动派发下一任务、启动G2、修旧18、合产品main或转入v10.1.6。
