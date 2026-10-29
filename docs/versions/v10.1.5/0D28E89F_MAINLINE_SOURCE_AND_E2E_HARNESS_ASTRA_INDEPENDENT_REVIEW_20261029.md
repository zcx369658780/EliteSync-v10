# EliteSync v10.1.5｜0d28e89f Astra独立源码与E2E资产验收｜2026-10-29

**裁决：`0D28E89F_BOUNDED_F1_SOURCE_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / E2E_HARNESS_RUNTIME_ENTRY_CHANGES_REQUIRED / V10.1.5_PARTIAL_NOT_ACCEPTED`。**

本裁决只针对Codex本次主线交付候选，不签整版`FUNCTION_ACCEPTED`，不授权真实运行或main产品集成。本次Astra直接读取GitHub对象、正式任务、候选变更源码、测试/报告、运行驱动、相关现有API源码；没有操作Owner Windows设备、Flutter、PHP服务或MariaDB。

## 1. GitHub精确来源和身份

- 正式任务：`docs/versions/v10.1.5/V10_1_5_APP_API_DB_MAINLINE_PRODUCT_INTEGRATION_AND_E2E_HARNESS_TASK_20261029.md`，Blob `1db7fc7eaadcea172cc52016904836bd71a0b90d`。
- 候选：`0d28e89f71c9a4ea15d8fd5fdb33bc7b9fdd0e6f`；**sole Parent** `0577f030f6e3bbecae611433daa226719a7cc4b0`；Root `c6898b86dd1e286967b952b2ac9cb764f4b0ff6d`。
- 候选产品：apps `03ba3602a7dc807bf963264e24f33eed01c231c8`；services `32229dce88cf497fea43904fea3dbb69a9410b8f`。通过GitHub Commit与Tree直接回读。
- 19变更文件；Manifest列出其中18个非自引用文件的final Blob，Astra按固定候选路径取得的18/18文件Blob均一致。Manifest自身`final_blob=null`为自引用例外，其实际Git Blob `05d4569f25da87d963bd946cb77994449e2867ee`。此验证不声称重新计算19项SHA256或审计所有未变产品文件。
- 当次fresh main仍 `6e23418a7b53679647d41957a028e20fca720650`，Root `d7406b05d8e036ec98bf0a1a7236e01aaee4b128`；main产品apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，只接受v10.1.4。报告分支不作为未来研发Parent。

## 2. F1真实产品源码：有界接受

对照Parent差异，`live_chat_page.dart`从“仅同payload复用attempt”改成未确认`ChatSendAttempt`不可变保留：同一个`client_message_id`、peer/content/attachmentIds；编辑、普通发送和新图片/视频入口在未确认时锁定；独立“使用原消息编号重试”仍可用；暂停取消不会被误认为服务端未提交；切号/授权代际失效仍清空私密状态。当前成功确认检查回显key及数值id。改动与任务中的两条确证风险有直接对应，不是无谓重写。

新增3项Widget测试源码，分别覆盖暂停后的原key恢复、unknown后控制器被程序性改变仍保持原payload、附件结果未知后同资产重试而不重上传。**本轮未运行Dart/analyze/test**；不以这3项源码记作Widget PASS；实际点击/UI行为仍需后续Owner明确许可。

## 3. E2E制品：范围成立、真实执行资格尚未成立

已提交`tools/v1015/mainline_e2e/`下的Python HTTP/DB驱动、纯契约检验、15场景定义、APP人工观察模板、空配置与说明；PHP test-only boot/router/fixture CLI、独立测试实例资格与现行业务权限接线；并提交AC02/03/04/06/07/08/09/10矩阵、原始字节/Blob Manifest及`FOLLOWUP_OWNER_AUTHORIZATION_SPEC`。15是**场景目录数**，不是15条自动APP E2E测试：驱动覆盖选定API/DB协议和数据库计数，实际Flutter UI/切号晚WS、Keystore、物理期限、短视频播放等留给独立APP观察/设备门。源码明确`e2e_pass=false`、`NOT_RUN_GATE_CLOSED`，没有把response ACK抑制冒充物理网络丢包。

本次Codex报告Python纯契约15项exit0、PHP纯资格14项exit0、5个PHP语法检查exit0，均为`CODEX_REPORTED_LOCAL_TEST`。Astra仅直接核对源/远端记录，没有本机重跑。历史MariaDB23/152、私有patched Flutter77/77不转写为本候选的真实API/APP运行PASS。

### 必须在下一次真实运行前同版修复的有界问题（R1-01）

`tools/v1015/mainline_e2e/run.py`的`Runner.php()`使用`php.exe -n`，只显式加载`pdo_mysql`、`openssl`；但它启动真正的Laravel并通过`tests/E2E/bridge.php`走`LiveConsentService::transition`及`DeviceSessions::issue`。后者本候选源码明确使用`mb_substr`；Laravel12运行需求包括`Mbstring`、`Fileinfo`、`DOM`、`XML`、`cURL`等扩展。PHP `-n`忽略php.ini，当前驱动没有确保这些非默认扩展已启用。**因此不能以纯PHP语法/模拟资格通过判定这个Windows CLI桥接入口可成功bootstrap/seed。** 这是源到运行合同的物质缺口，不是此前Hook/ACL历史事故，也不等于已实际观察到CLI失败。

修复限定：在当前任务已有E2E工具及必要非生产文档/纯契约测试范围，明确私有PHP二进制、所需扩展/DLL、实际加载状态和Hash/路径校验，保持`-n`的无隐式全局配置原则；为启动前的扩展闭包建立fail-closed的资格检验，且保证CLI与PHP API进程使用兼容的已核环境。不可偷偷放宽Source/DB/Owner真实运行门禁，不得据此启动PHP/Laravel/服务或创建新运行预算。该单项与任何从安全定点复查找到的直接回归合并为**一次同版有界R1**，无需另一轮纯环境治理或全部历史测试。

完成上述代码审查修正前，不签“E2E_HARNESS_RUNTIME_READY”；后续真正MariaDB/API/Widget/设备测试另需Owner批准，且本次静态复核不能代替运行实证。

## 4. 证据分层及冻结状态

- **DIRECT_GITHUB_OBJECT**：准确Parent、Root、双产品Tree、19变更、18个非自引用final Blob、受审F1源/E2E工具/报告。
- **CODEX_REPORTED_LOCAL_TEST**：15项Python、14项PHP纯资格、5个PHP lint；Astra未亲自在Owner Windows环境运行。
- **LOCAL_ONLY_RAW**：原始CLI exit/stdout、空间ledger、私有工具与源写面身份等，Astra未直接复验；CodeX总结不能自动升级其层次。
- **NOT_RUN_GATE_CLOSED**：Flutter Widget新增3项、真实Laravel/API/MariaDB、同源APK、真实设备/Push/RTC/WS、Keystore、15/30日物理经过与删除。

保持`AC01–11=10 PARTIAL/1 OPEN`（AC05 RTC），`V10.1.5_PARTIAL_NOT_ACCEPTED / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / V10.1.6_NOT_STARTED`。旧6/6 Flutter、2/2 MariaDB、旧Gradle/APK各1/1不重置，API旧余量不构成本次许可；受保护原证、旧工作树与事故台账不可动。

**下一步：** 保留0d28主线进展和Owner既有任务，不发布重复主线任务；先在同一v10.1.5综合范围解决R1-01并停止，随后Astra审修复候选。Owner若决定未来真实运行，必须对独立`FOLLOWUP_OWNER_AUTHORIZATION_SPEC`明确授权。不得自动main集成、打开G2或v10.1.6。
