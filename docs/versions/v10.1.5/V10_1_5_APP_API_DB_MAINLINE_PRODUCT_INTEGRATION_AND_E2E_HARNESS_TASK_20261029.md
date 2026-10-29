# EliteSync v10.1.5｜回归产品主线：APP—API—MariaDB业务贯通源码收口与同源E2E场景实现｜Owner正式综合研发任务

**状态：OWNER_APPROVED_RETURN_TO_MAINLINE_PRODUCT_DEVELOPMENT / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / REAL_PRODUCT_AND_E2E_HARNESS_SOURCE_IMPLEMENTATION_ALLOWED / REAL_APP_DB_BUILD_DEVICE_EXECUTION_NOT_YET_AUTHORIZED / NO_PRODUCT_MAIN_INTEGRATION**

日期：2026-10-29（Asia/Singapore）。Authority仓库：`zcx369658780/EliteSync-v10`。

## 0. Owner决定、真实目标与必须避免的循环

Owner在Astra完成`0577f030` Hook SHA-256权威勘误有界验收后明确决定：“可以，既然错误已经解决，让我们回到开发主线上来。”这授权**回到v10.1.5实际产品研发**，而不是再以新一轮纯Hash、旧ACL、环境考古、任务管理重组代替产品工作。

**本任务唯一主要产品目标：** 在固定最新`0577`未接受产品候选基础上，围绕F1消息、F3可信T0/私有加密离线、F4通知权限与当前重新鉴权，真正梳理并**实施**APP→Laravel API→MariaDB业务贯通所需的**最小源码修正、可执行E2E测试/合成fixture/调用脚本**及必要客户端错误/安全状态表现；把冻结AC02/03/04/06/07/08/09/10中可以在当前源码工作面推进的部分推进到**可由下一次专门授权的真实同源版本运行**的状态。已经在上轮通过的23项MariaDB Feature/152断言和11文件77个Flutter Widget/unit Mock不做无意义重复，不发纯规划候选或单独环境再发现任务。

**权力边界必须显式区分**：Owner同意“回主线”不等于重新授权耗尽的Flutter6/6、MariaDB2/2、旧Gradle G1/1、旧APK1/1或G2的执行，不等于批准新APK/真机/网络/RTC/AEC/真实Push/操作系统安全调整。这些后续必须有精确新Owner授权、私有环境及预算。**本轮可以写真实产品源码、E2E harness和合成测试源码；不能用未授权的真实服务执行来取得E2E PASS。** 如果发现软件缺陷，在本任务内修复，不把普通小修拆成微任务。若某条线路确实需要物理设备或服务才有事实，提前准备可用脚本和负例并报告`NOT_RUN_GATE_CLOSED`，继续其它允许的实际开发工作。

## 1. Fresh Authority、冻结唯一Parent与已接受产品身份

1. Codex由Owner**手动**完整派发后，fresh读取live main/Root、`docs/workflow/ACTIVE_STATE.md`、本正式任务全文及实际Git Blob、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob`0f62532a71fb9753811fafa9e03819a46422f4bf`、`docs/workflow/CURRENT_WORKFLOW.md`、冻结`docs/versions/v10.1.5/plan.md` Blob **`7d3466b3be67135dc641cfee7c7faef78937ba03`**、以及`docs/versions/v10.1.5/ac01_11_gap_matrix_20261029.json` Blob **`4d3593925d3676722f59d29c324963842a217eb5`**。本任务发布前main `7b33f685df3704a384a3cf1f34c3f810e741aeac` / Root `fc5ef9921d954ac4cd0ffc75cf698efe5a1318ed`只作签发前锚，开工以fresh实时值为准。
2. 本轮**唯一真实研发候选Parent**=`0577f030f6e3bbecae611433daa226719a7cc4b0`，Root=`4d024bb4d931a346f237614efa7940451a39678e`；完整apps Tree=`798049a15eb33fec16acdd37d83a07af0ed181b5`（729 Blob），services Tree=`9bba2938aa41ad3eaee501ef88bfeecdee797591`（716 Blob）。不得把Astra独立审查分支作为Parent、不得从main错误重做v10.1.5增量、不得向main自行merge。
3. 最新Astra `0577`裁决文件`astra/v10.1.5-0577f030-hook-hash-erratum-review-20261029:docs/versions/v10.1.5/0577F030_HOOK_HASH_ERRATUM_LOCK_ASTRA_INDEPENDENT_REVIEW_20261029.md` Blob **`9a2df55a6ea3846c8bec6711a6fee0f57663d34f`**，review HEAD `e5c06b1e08d1088f172e1e902608cbfbed5e3574`；前轮Flutter独立审查Blob `715bc340042675df86a0c791c49eb1852bb9b5ce`、服务端MariaDB独立审查Blob`dc5a6d21e9c22f8e28b81cec7317aa740c9bd8db`、报告原文及其索引均必须按路径取源，避免把Codex本地回执当Astra在Windows直接重跑。
4. main**唯一已接受正式产品v10.1.4** apps Tree=`3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree=`0cb1f9d19659291a462488b3686fd0a07a6698ac`；产品v10.1.5仍`PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_PRODUCT_MAIN_INTEGRATION`。冻结F1=消息、F2=RTC、F3=离线、F4=通知、F5=具名旧资产；`AC05_OPEN`对应RTC保护及有界质量，不能被“F3离线用例”误关。
5. 对照关键真实源码而不重造：`services/backend-laravel/app/Services/ConversationAtomicSendService.php` Blob`40abdfdaaa6f17fdc850183d519ae60eb348c16a`，`NotificationDeliveryService.php` Blob`3b9835bfed135d2a990f3e4a0d85077d47cc7cf9`，`apps/flutter_elitesync_module/lib/features/chat/presentation/pages/live_chat_page.dart` Blob`76745e44e53b27c26f97b7365f8232892920ab07`，`lib/core/storage/private_cache_service.dart` Blob`ea23fcf79a2a20f26377620575eba94356194f25`，`lib/features/notification/presentation/pages/notification_center_page.dart` Blob`df95b10eefdda5bcdedfa3d03fe5ee7d2c704da7`，`services/backend-laravel/routes/api.php` Blob`fcb4d81338b6ec4b908ba16d1e729d76f98ca101`。其他真实文件须从固定Git树确认，路径/Blob仅是入口，不代表已判存在缺陷。

## 2. 单一源码工作面与真实产品开发任务

建立**一棵新task-owned、无硬链接/reparse穿透的安全独立源码工作面**，由固定`0577`Commit/Root/apps/services按GitHub可核源重建，仅写它与本任务特定合成夹具。不得在旧dirty目录reset/clean/rebase/stash/force、更新旧Git refs、覆写历史SQLite/MariaDB/SDK/LOCAL_ONLY或使用旧受保护数据作合成fixture。新增全部工作产物logical和allocated各≤**512MiB（536870912 bytes）**，在写前创建持久task ledger、固定task_id/attempt/文件Hash/操作PREPARE并flush，任意中断必须沿用同根/账本，不得借重建任务再次消费旧预算。禁止复制既有3GB Flutter SDK或MariaDB datadir到此512MiB任务根。

**A. F1消息与媒体实际源码实现：**
- 从真实Flutter网络层、`live_chat_page`、会话服务及Laravel `ConversationAtomicSendService`/capability/route沿完整同一条`send→unknown result→same clientMessageId replay→server identity readback→UI confirmed`路径逐字段核数据模型、状态、token、session epoch、idempotency fingerprint（receiver/content/有序附件）、API错误域与响应结构。只有**确证且能安全说明的字段/竞态/页面错误**才修真正产品代码，不重复大规模重写、不能因未运行就凭猜测“修Bug”。
- 实现一份**可在未来具名独立环境直接执行**的E2E/HTTP场景驱动器（测试工具/fixture，不是模拟APP已经真实贯通）：合成两个有权账户，单逻辑id同键同payload的成功/响应丢失/重发、异payload409、附件同一identity、超时/重连和旧WS变更信号；对DB回读消息/附件/通知计数和Flutter显示的`pending/unknown/confirmed/denied`实际可观察结果留证。
- 反例至少含Block、CN关闭、MC撤权、禁用/失效token、切号后晚回包、旧room/media URL及图片/短视频ready→failed/撤权后的200/206/403/404预期。每个场景明确**需要真实APP、API或DB中的哪一项**，不能通过mock输出冒充E2E实际结果。
- 图片/短视频仅使用未来task-owned合成小附件与冻结私有媒体链，不下载真实敏感媒体、无须转码整个历史库。没有真实media server时可以交付明确尚未运行的可执行用例源码及权限负例协议，不能报200/206“已通过”。

**B. F3离线与账户安全真实代码：**
- 审计真实登录T0的服务端来源、Flutter`PrivateCacheService`命名空间与权限、`SecureStorageService`、profile/session保存及队列顺序，检查从首次成功登录→刷新→重启锁定→断网只读→重联当前服务端权限→切号/退出/可信时钟异常→30天应清/失败的**真实调用路径是否存在缺线**；修确证的客户端/后端接口或失败表现，保留原fail-closed与在线鉴权。
- 实现一套面向**未来获Owner批准的同源APP/设备**合成检查脚本/观察记录定义，标明实际加密密文路径、设备Keystore、重启行为、已属本版对象的删除收据和单调计时/物理15/30天需要真实时间。任何纯合成15/30天转换不得提升为`ELAPSED_TIME_VERIFIED`或`PHYSICAL_PURGE_COMPLETED`，也不得清理历史缓存/原证。

**C. F4通知最小披露与权限链：**
- 从后端`NotificationDeliveryService`、偏好/设备/session API与客户端通知列表/偏好页的真实字段和点击行为出发，确保合法会话、偏好、TEST_ONLY token hash归属、注销、旧通知点击前后再鉴权与异步切号没有跨层不一致。若发现受影响产品缺陷，在同任务内修；保持`REAL_PUSH_PROVIDER_PENDING`、不上传真实token，不接供应商网络/SDK。
- 在同一E2E场景资产中形成既可对当前后端/客户端分别运行又能绑定**相同源码版本**的测试索引，覆盖类别/静默、拒绝OS权限不会影响核心访问、撤权/换号后当前资源404或拒绝导航，以及外部锁屏payload不含姓名、正文、Safety私密数据。

**D. 冻结AC05 RTC与其它门的处理：**
- AC05 RTC/AEC、流动媒体撤权后最后可闻≤5秒、真实双端通话/音质**仍然OPEN**；历史不同apps Tree的call4/5与旧token403不能冒充此候选通过。若源接口有与本综合软件安全修正直接相关的回归，允许写安全测试源码/保留独立观察；不得借本任务运行RTC/设备/UDP/网络、扩音麦/摄像头权限、做新G2/Gradle/APK。
- 旧F5语音留言/地图具名来源不足者依旧`UNKNOWN/OUT_OF_SCOPE`；不扩成新增产品功能。

## 3. 可用测试与新运行硬门

**本轮允许**：在一份私有源码工作面实施真实Flutter/Laravel业务源码和跨端测试工具/合成fixture；仅可用可信已有Python/PHP进行不需Laravel vendor/DB/Flutter SDK/网络/外部进程的纯契约断言、JSON/AST/语法检查，单操作的原始exit/hash/失败必须保留，普通安全源码修复在同一任务集中完成。不必重复已经接受的23 Feature/152断言、77 Widget、42纯Hook锁测试。

**本轮没有额外授权**：真正Flutter/Dart工具链启动（前任务6/6已耗尽）、MariaDB独立服务或迁移（前任务2/2已耗尽）、PHP回环API（历史1/2余量不构成权限）、当前App APK编译/安装、Gradle/G2（旧G/APK1/1耗尽、G2未授权）、Android/ADB/设备、RTC/摄像麦克风/UDP/音质、真实Push/第三方费用、系统ACL/UAC/权限或既有服务。工具包的`Hook hash`已纠正，但`SOURCE_BYTES_NOT_VERIFIED_THIS_TASK / PATCH_INPUT_NOT_QUALIFIED / PREPARE_NOT_RUN / EXECUTE_NOT_RUN`，不得把当前非生产入口直接执行以取得业务通过。

若端到端链真实运行确实需要新的**可隔离E2E运行预算**，作为集中交付中的`FOLLOWUP_OWNER_AUTHORIZATION_SPEC`明确列：唯一新库/固定端口、服务启动最多次数、工具/SDK可写目录、设备与APK来源、网络、合成身份、保护首尾检查、时间/空间上限与实际STOP。**不能把提议写成已经获得权限**，也不能仅因授权不够就停在另一份环境规划文档；继续提交本轮可实现的产品代码和脚本。若源码已达标不需改生产，明确证据支持后以真实E2E harness/fixture交付，不虚构问题。

## 4. 一次集中交付、真实验收终点与STOP

唯一研发候选以`0577f030f6e3bbecae611433daa226719a7cc4b0`作为sole Parent提交普通non-force候选，**不合main**。本任务正式交付必须包含：
- 与真正问题直接相关的APP/Laravel实现和合成测试/脚本变更（若经核没有新的产品缺陷，必须说明证据；但仍交付**可运行而尚未运行的同源E2E harness**，不能仅交调查文档）；
- 一份冻结v10.1.5 AC02/03/04/06/07/08/09/10对照的`SOURCE_TO_E2E_CONTRACT_MATRIX`，区分源实现完备、纯逻辑PASS、历史MariaDB或Widget有界PASS、同源真实E2E`NOT_RUN`、真机/RTC/Push/物理期限仍`OPEN`；
- 实际文件/路径/Blob来源和端到端JSON清单，所有命令、真实失败、安全预算、含运行门禁的`NO_FALSE_E2E_PASS`回执，以及下一次最小明确Owner许可建议（不得自动开后继）。
- 建议统一报告 `docs/versions/v10.1.5/APP_API_DB_MAINLINE_IMPLEMENTATION_AND_E2E_HARNESS_REPORT_20261029.md`、索引 `docs/versions/v10.1.5/app_api_db_e2e_harness_artifact_manifest_20261029.json`，不得覆盖前轮历史报告/冻结AC。
- 安全数据/隐私原始日志、本地绝对路径/Token、系统ACL/SDK cache、真实媒体/DB不上传GitHub。若单项触及保护资产/越权限，STOP该项并保留原证；其它合法源码工作继续。

结尾必须GitHub按路径回读Commit/sole Parent/Root、全部变更`path/mode/Blob`及完整apps/services Tree，fresh核main仍只接受v10.1.4产品，Codex**不自签ACCEPTED、不自动集成main、不开v10.1.6**。成功交付上限`V10.1.5_MAINLINE_SOURCE_AND_E2E_HARNESS_CANDIDATE_DELIVERED_AWAITING_ASTRA_REVIEW`，环境阻断`DELIVERED_PARTIAL_WITH_EXPLICIT_RUNTIME_GATES`；二者均保持`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_READY_FOR_POPEN_FALSE / PRODUCT_MAIN_NOT_INTEGRATED / REAL_PUSH_PROVIDER_PENDING / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / RTC_AEC_NOT_CLOSED / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`。**STOP等待Astra独立验收，不发下一微任务、不释放G2或旧预算。**
