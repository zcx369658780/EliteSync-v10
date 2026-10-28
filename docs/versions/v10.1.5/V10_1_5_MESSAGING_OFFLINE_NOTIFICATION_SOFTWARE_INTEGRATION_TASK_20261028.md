# EliteSync v10.1.5｜消息可靠性、离线密文生命周期与授权通知｜Owner正式综合软件研发任务

**状态：OWNER_APPROVED_V10_1_5_SOFTWARE_INTEGRATION / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / PRODUCT_CODE_CHANGE_AUTHORIZED_WITHIN_FROZEN_SCOPE / NO_NEW_PHYSICAL_OS_OR_BUILD_BUDGET / G2_NOT_AUTHORIZED / NO_PRODUCT_MAIN_INTEGRATION**

日期：2026-10-28（Asia/Singapore）。仓库：`zcx369658780/EliteSync-v10`。

## 0. Owner两项明确决定、事故封存与本任务性质

Owner在阅读Astra独立裁决后正式决定：（1）将上一轮重复ACL真实实验超限**作为历史事故永久保留、停止继续调查、完整保护原证**；（2）授权返回**v10.1.5 消息可靠性、离线与通知的软件综合开发**。本文件是一份真实功能实现任务，不是再做一个只读预检或软件规划版；Codex仅在Owner手动转交后执行，Astra独立验收，发布不等于派发或执行。

历史事件固定裁决：
- `PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / CROSS_ATTEMPT_FIXTURE_BUDGET_OVERRUN`：A/B两棵新树、6后代、父DACL变更2次/恢复2次，违反原任务唯一1/3/1/1限制；两段各自原捕获视图恢复不使超限合法，**不得退款、重置或追认**。
- 两段原证及失败记录、各自实验树、旧18件、122件历史具名原证、五保护根/527 refs、旧Seed3183件、旧APK/G claim和历史partial均继续保护；不清理、搬运、修改、补修或恢复旧fixture。
- 首次生成/传输中断确切根因、未记瞬时影响及跨尝试历史空间峰值仍`NOT_PROVEN`；**Owner接受按历史事故保留这些未知，不再为其自动派发更多调查**。这不解除OS隔离或G2门禁。
- 核心职责：以可用、已接受v10.1.4业务能力为根，真正补齐指定三项v10.1.5软件纵向链，做安全有界测试、集中一次交付。不得先要求旧18件恢复PASS、受限child成功、G2或外部Push供应商才开始源码开发；这些门仅限制其对应运行能力。

## 1. 权威输入与固定对象（开工须重新fresh核验）

- 本任务创建前live main `6ec0fa7523b3210ce05f9dcde4e9ab3c6315683c`、Root `25ce547f0960c8aeaabc4837c6bdbcf536fbf753`；均只是本单写入前快照。实际开工**重新读取**main HEAD、Root、`docs/workflow/ACTIVE_STATE.md`、本任务全文及实际Blob、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`。
- 已接受的**唯一产品基线v10.1.4**完整main apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`；保留已验收1.1–1.4全部身份/关系、CN/MC/Block、安全及私密数据边界。
- 既有冻结功能计划`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`。本轮**有限软件开发切片**是上述冻结版的消息、离线和通知功能；并非擅自删除原版RTC/AEC、真实Push、SDK/G2等剩余AC。未覆盖/无法测试项如实列`NOT_RUN/PARTIAL`。
- 最近只读对账候选 `ce3e278eae6872179153243ca3060a18f68abcfd`、唯一Parent `33213a779c993e39989100ba661e81dcdef62b2d`、Root `fbf1afba14a41817bae3a0d13de7bf619001074a`，报告Blob `96539f1c78876f26f57797453b372eb873e50b52`、索引Blob `b0fdd3c795d9cd7b0a32faf952ee5986642f8141`；只作未接受产品增量的**定点来源**，绝不可把整个ce3e/cfca/3321候选树当成已接受或直接merge。
- 最新Astra审查分支 `astra/v10.1.5-ce3e278e-interruption-reconciliation-review-20261028`，HEAD `9ac9ae0e78b0c34057fec10acbb203c45238d26e`，审查报告Blob `aed5280d831c812da2211282ae0795f7dccf0b48`，独立接受仅限本轮只读调查并明确历史超限。
- 旧完整APK预算`1/1`耗尽、旧Gradle G `1/1`耗尽，旧A gate关闭；新G2合同 Blob `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c`、此前Codex回执max1/reserved0/Popen0/claim absent仅为有条件历史余额，**此任务G2 Popen=0/claim写入=0**。

## 2. 独立安全代码工作面和源码继承规则

从开工fresh main的已接受**产品**树建立一个新的任务专用代码分支/隔离工作面；若可证明安全且干净，可使用独立git worktree；不得对任何已有dirty根、未知旧worktree、Git refs、历史文件、旧Seed与受保护原证运行reset/rebase/clean/prune/stash/force或默认直接写。为避免新问题，所有输出、Git临时文件、脚本、测试桩、报告和缓存均记录归属；旧两棵ACL实验树及其运行历史只读保护。遇路径身份漂移或旧任务残留，停止涉及保护资产的操作，不借新权限修改它。

**唯一研发候选Parent**应为本任务正式发布后fresh main commit，包含已接受v10.1.4产品与本次任务/状态文档。若main又前进必须重核差异，不能盲选过期SHA。不得用ce3e直接做整仓Parent，避免未接受Gradle/OS调查及其它产品增量被无意整树继承。只可从具名固定v10.1.5候选逐路径、逐hunk对照引入此软件切片的合适实现；交付时在`SOURCE_PROVENANCE`表逐项列main源Blob、未接受候选Blob、采纳/重写原因、依赖和安全测试，拒绝无证复制全部候选apps/services。

至少定点核对以下事实而非盲改：
- `apps/flutter_elitesync_module/lib/features/chat/domain/entities/chat_send_attempt.dart` 在main与近期候选同Blob `50ad478e8699f4dd5dbcc106285bc85b5fa578d8`；
- `apps/flutter_elitesync_module/lib/features/chat/domain/offline_private_retention_policy.dart` main同既有候选 `4ab8b579745d3340b1e2880fe6b760b0efe5445a`；
- `apps/flutter_elitesync_module/lib/features/notification/presentation/state/notification_privacy_contract.dart` main `94c21933d058ec9cf21ba1b8588836d370fd1f6f`；
- `services/backend-laravel/app/Services/ConversationAtomicSendService.php` main `a6196e5fdd268d7bd27c3026d21d65dc8ad1158e`、候选 `5fc6d2bc7f3d2d24f15206186dcdf7ae2c668e10`；
- `apps/flutter_elitesync_module/lib/shared/providers/session_provider.dart` main `433e598c4328b6bbadcd9d50c72dfa23f31706e3`、候选 `abb6adc38c7221080e09be495ff808fb80a99705`；
- `apps/flutter_elitesync_module/lib/core/storage/private_cache_service.dart`、`services/backend-laravel/app/Services/NotificationDeliveryService.php`在所核main精确路径不存在，候选相应Blob `6a2e30c3782db3be54efa86c5d806f89b84735d0`、`c3ebf4824e8fc0feb6a1732da5a0d44ff3936b87`。main路径404不等于该功能绝对不存在；要调查现有替代实现，不制造重复授权/存储路径。

允许在`apps/flutter_elitesync_module/`、`services/backend-laravel/`的消息/私有离线/通知相关明确消费者、测试和最小配套配置中实现必要真实代码，不更改Gradle/AGP/Kotlin/Flutter SDK工具链、G2 runner/observer、数据库历史结构和无关业务。若确需本切片新数据库迁移，仅在源码中设计带回滚与审查说明的migration，**不得对旧/生产/共享数据库实际执行**；不能为省事修改旧迁移。非目标的Settings等仅限与通知/离线用户可见行为相关的小范围接线。

## 3. F1｜消息“结果未知”恢复、幂等和撤权边界

在已获准Connection及独立Messaging Consent、Block/处罚状态仍有效的前提下，用户发送文字、既有图片/短视频后若服务器已经提交但响应丢失，客户端呈现`PENDING/UNKNOWN_CONFIRMATION`而非假成功/假失败；同一不可变`clientMessageId`＋相同payload指纹与当前授权可安全查询/重试，最终以服务端持久事实为准，至多一条逻辑消息、附件关联及对应站内通知。新key正常生成；同key不同payload、不同账号/会话/权限代际必须冲突且不可串用。

实现/复核服务端事务唯一性与冲突返回、持久读回、晚到的响应/旧WS事件、连接撤权/恢复、切号/退出/Block之后同key重试及旧缓存授权；不得让旧会话代际回调污染当前页面。保留既有成功发送与旧消息读取路径，不重造RTC或媒体协议，不隐藏失败。禁止把网络超时解释成业务NO_MATCH或自动重放被撤权的消息。

主要依赖`ConversationAtomicSendService.php`、chat send attempt/remote datasource/room state、网络interceptor/session provider和旧消息/附件索引；只有发现真实逻辑缺陷才修正，既有正确路径保留。输出正反案例：提交后丢响应、重复相同请求、同key异payload、并发请求、撤权先到/后到、换号晚响应、附件重复绑定/通知重复。

## 4. F2｜离线私有密文与15/30天合同

按账号/设备隔离本地已存的`CONVERSATION_SHARED_PRIVATE`密文，离线`READ_ONLY`：不得发送/修改远端事实、绕过已撤权访问，未授权新账号不得读旧账号缓存。最后一次**真实成功在线登录**的可信T0是生命周期源，refresh、普通重连与本地操作不续期；正常时间、回拨、重启、关机、缺失可信时间、账号变更均要安全降级；不能靠进程单调计时在重启后证明跨进程可信时长。

落实既有15/30天方向的具名可达存储/身份/凭据联动，确保当前可合理验证的边界：到期只读拒绝/清理尝试、按精确任务自有合成密文验证物理清理与失败回执、卸载/注销/切号/异常回滚不误删别人的共享或审计数据；如果设备时钟/真实登录凭据/重启经过和30天实际物理经过没有证据，必须明确`SIMULATED_CLOCK_ONLY / ELAPSED_TIME_NOT_PROVEN / PHYSICAL_DEVICE_CLEANUP_NOT_PROVEN`，不能以注入时钟当真实天数。

重点审核`private_cache_service.dart`、secure/local storage、session provider、设备会话/trusted login和retention policy、退出/隐私用户入口；保留私人安全原证及服务器必要审计，绝不调用项目旧数据恢复/物理删除作为测试。

## 5. F3｜通知偏好、拒绝、撤权与安全点击

软件层接入站内通知、类别偏好、暂停/静默、系统通知权限状态与当前服务器授权投影。用户拒绝系统权限不能阻断聊天/匹配；锁屏/外层通用正文，不默认显示peer、聊天、恋爱、出生或Safety隐私信息。

通知到达或旧通知点开时必须以**当前会话/用户/设备/对象用途授权**重新鉴权，失效消息/拉黑/撤权/退出/删除后不得从深链、缓存或旧token复活私密读取/重播请求；换号/登出清理任务自有合成`TEST_ONLY`注册/投影及旧点击资格，真实删除与token状态必须有可审计后端约束。配套检查APP、API及独立Web运营的必要通知/权限合同，不让Safety私密上下文借通知泄漏。

真实Push供应商、系统后台送达与OS通知GUI仍`REAL_PUSH_PROVIDER_PENDING / NOT_RUN`；仅允许已隔离的`TEST_ONLY`软件替身及源级合同，不接第三方SDK、云Push密钥、真实账号token，不收费用，也不把模拟投递标成真实推送。

## 6. 测试执行与环境预算（明确允许 vs 仍封闭）

Owner本次授权**实际源码开发、测试源码编写、静态分析与完全离线的纯逻辑单元/Mock检查**。Codex在可自证`cwd`、临时写入、HOME/TEMP及测试输入/输出全部封闭于新任务工作面且不会隐式访问受保护SDK/cache/工程网络/历史库时，可运行已存在的本地Python纯mock与PHP`-l`语法检查、没有外部I/O的定向独立逻辑单测；单一综合任务内对普通代码失败可修复并有界重新检查，保留所有失败回执。不授权以“单测”为名启动Laravel真实服务、MariaDB或Flutter/Gradle工具链；与隔离资格冲突则将该检查记`NOT_RUN_ENV_GATE_CLOSED`，继续其它安全源码任务。

为防止不经Owner认可的运行预算，本轮明示：
- `GRADLE/G2/JVM/AGP/FLUTTER_DART_CLI_BUILD_OR_TEST / AAR/POM/APK / ADB/RTC / LIVE_PUSH = 0`；包括`flutter test`、`dart test`、`pub get`、`flutter build`，不得借默认工具隐式写共享SDK/插件或cache。
- `REAL_DB/API_SERVER/HTTP_E2E = 0`，不创建/改动真实MariaDB数据库、3306事故库、历史SQL、现有staging/production或公网。可将新测试写成未来隔离DB/APP环境可执行的脚本与fixtures，实际端到端`NOT_RUN`；不允许用SQLite mock自称MariaDB实测。
- `NEW_RESTRICTED_CHILD / WINDOWS_ACL_CHANGE / TOKEN_PROBE / OS_PERMISSION_MATRIX / G2_POPEN / G2_CLAIM = 0`；不写系统设置、共享ACL、网络策略、预算claim。不要触发新的真实构建消耗或改旧账本。
- 新任务独立新增**非缓存**工作产物、源码副本、文档及测试日志的logical和allocated预算分别≤**256MiB（268,435,456 bytes）**；不得复制1.36GB旧Seed、整个Flutter/Android SDK或复制造成多份大cache；若实际新代码工作面需要更多空间，则停并报告，不申请默许续额。相关任务自有workspace/目录创建需避免写旧保护源，Git安全工作树操作只限本新任务。
- 不执行生产、真实用户、费用/供应商、D盘历史目录清理。历史原证/两次ACL实验树保持不动。必要的历史签名/权限/动态运行缺口列出，不用新测试绕旧门。

如需要正式Android设备、真实数据库持久化旅程、Flutter CLI或APK构建以实现完整验收，则保留精确`NOT_RUN`及其局部阻断，**不因此取消其它获准的源码实现与测试设计**。Codex可完成所有可安全实施的业务源码、纯逻辑测试与独立非作者静态复核后集中交付，不得为了绿色擅改验收AC、换运行环境或拆成一串自动后继任务。

## 7. 证据、验收、交付与硬停止

使用**从fresh main创建的唯一软件候选branch**（sole Parent为开工时fresh main，或main并发纯文档前进后具名重核的安全后继），遵循main已接受产品继承原则；未接受候选仅为按路径来源，不以它作为base并批量导入。交付一次集中`docs/versions/v10.1.5/SOFTWARE_INTEGRATION_IMPLEMENTATION_REPORT_20261028.md`及`docs/versions/v10.1.5/software_integration_artifact_manifest_20261028.json`，包含产品源码差异/输入/输出、测试程序与实际运行/NOT_RUN矩阵、Git路径mode/Blob身份、完整apps/services Tree、权限正反例、被选择的候选源码来源、受控环境和保护记录、局部已证与长期缺口；如需非作者静态review，可在本长任务内部一次完成，不强制强模型循环。

要求从UI/客户端动作→API/持久状态预期→重读/撤权的完整`TEST_CASES`编写和实现连接，不以独立mock两端“都PASS”宣称端到端。服务端绝不可相信客户端的关系/认证/Safety真值。原已接受业务保留，bug修复限本切片；每个无法真实执行的场景`NOT_RUN`，不能凭源码类比改`AC05_OPEN`。

本任务成功终态：`V10.1.5_MESSAGING_OFFLINE_NOTIFICATION_SOFTWARE_CANDIDATE_DELIVERED / STATIC_OR_PURE_UNIT_EVIDENCE_ONLY / AWAITING_ASTRA_INDEPENDENT_REVIEW`。若有未能安全实施的关键缺口，`DELIVERED_PARTIAL_WITH_EXPLICIT_BLOCKERS`同样是合法集中交付。Astra独立验收后再由Owner决定真实DB/Flutter/Android/OS或G2下一门；本轮不授权产品`main`集成、不自动派发v10.1.6或建立后继任务。

无论结果持续保留：`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / CROSS_ATTEMPT_TOTAL_BUDGET_NOT_PROVEN / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTORATION_BLOCKED_WITH_ORIGINAL_EVIDENCE / CHILD_INIT_ROOT_CAUSE_NOT_PROVEN / CHILD_ACCESS_MATRIX_NOT_RUN_14_OF_14 / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / INPUT_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / AAR_POM_RUNTIME_NOT_PROVEN / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。

**最终STOP**：发布一份非force完整软件候选与固定GitHub报告/索引；按路径回读Commit、唯一Parent、Root、完整apps/services与报告/manifest Blob，原始敏感日志/凭据/私密SDDL/数据库保持LOCAL_ONLY；STOP等Astra独立验收，不合main、不运行新G2/Gradle/系统安全/真实设备，不因生成中断重置任何执行预算。
