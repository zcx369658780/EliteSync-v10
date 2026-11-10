# EliteSync v10.1.5｜Owner批准的Flutter Debug Embedding精确依赖补齐与诊断APK构建门｜Codex唯一综合任务

2026-10-22（Asia/Singapore）。
**OWNER_APPROVED_PINNED_DEBUG_DEPENDENCY_FETCH / ONE_BOUNDED_BUILD_GATE / MANUAL_CODEX_DISPATCH_PENDING / EXECUTION_NOT_STARTED / PLAN_A_RETAINED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_R2 / NO_MAIN_INTEGRATION / V10.1.6_NOT_STARTED**。

## 一、批准的唯一目标和权限

在Astra独立审查v10.1.5 ICE连接前诊断源码候选之后，Owner回复“可以我同意，请继续”，批准**仅补齐同一已安装Flutter engine缺失的官方debug Maven依赖，并完成一次可复核的诊断APK正向构建与debug隔离验收**。这是针对已知`DIAGNOSTIC_APK_BUILD_BLOCKED`的**构建依赖门**，不是新的RTC媒体连通、调参或整个v10.1.5修复轮。

Owner本次明确准许在已有本地工程环境内：
1. 先只读核实本机Flutter SDK锁定engine、Gradle报错缺项及已有缓存；如已具**完全同坐标、可信的本地原件**，优先归属只读验证并隔离复用；
2. 如精确工件仍缺，**仅访问Flutter官方Maven仓库** `https://storage.googleapis.com/download.flutter.io` 的对应确切坐标及构建报错直接指向的相同engine必要传递依赖，检索其POM/AAR等官方发布材料并有限下载到**此任务专属的受限缓存/Gradle用户目录**；固定坐标优先为`io.flutter:flutter_embedding_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`。Flutter官方模块集成文档明确把`$FLUTTER_STORAGE_BASE_URL/download.flutter.io`作为Maven源。**官方仓库根的技术可用性不等于已证这条engine版本文件真实可下载，必须现场核验**；
3. 只对既有诊断源做一次`debug`正向构建、严格身份/版本/签名/测试门核验；真正无法获得可信精确工件时停止，不补造成功。
4. 因此授权**限定外部依赖获取**，不授权其它域名镜像、全量Flutter缓存预取、任意Flutter SDK/Gradle/Kotlin/AGP插件升级、访问第三方动态脚本、公共网络部署或费用。若官方仓库受限／缺version／需要重定向到意料外的来源，请报告阻断并停，不静默切非官方镜像或改用同名不同hash的工件。可以将官方的精确URL和官方验证手段写在原证，但不可凭GitHub报告预设某个不存在的发布SHA256。

**严禁**改变产品RTC业务、CN/MC/JWT/5秒撤权、SFU/guard、UDP/LAN/TURN、Windows防火墙/UAC、Docker端口、真机安装/麦克风/ADB、真实API/DB/支付/用户、历史SQL/APK/cache及已接受main。**不运行手机或模拟器、不新建call、不触发Room.connect**。不以构建成功当作运行时ICE已通过。

## 二、固定authority和继承边界

- 仓库`zcx369658780/EliteSync-v10`，签发前live main `21aa05511ba62a411aba0d6fecedeb13b963a81e`（只是v10.1.4接受产品加顾问文档）。开工须重新核main SHA/tree，但不得重置R1/P1/诊断候选回main。
- Owner本次目标为已交付`8bee827c20c26c4ec954b774c011f09238ec59b3`上的固定源码Commit `24ddf05875d8d4abad7a6b473f882698c9885c2a`，其唯一Parent `62f0cd6d6df80f2f22855c0f75fd67ff52c753a7`；Root `2c656957e1c229ca30f7c07b173bcb1062310d2c`；完整apps `72c617cf86d5c653dd722accde340b51d2e085eb`、services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。
- Astra独立复审`docs/versions/v10.1.5/ice_preconnect_diagnostic_independent_review.md` Blob `6c736933e96e32b25e57a4318aa760049e5ed758`；原正式实施报告Blob `18ef944586765231ca7b003d50e15ad3165271de`、原manifest Blob `bae88478daa065c16b8fd5b69caf4c90240a7359`；旧失败exit1与修正历史必须保留。冻结plan、R1及所有此前源码与Astra review不可倒改。
- 已安装Flutter `3.41.7`、Dart `3.11.5`，engine **`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`**；`livekit_client 2.10.0`、`flutter_webrtc 1.6.0`、`webrtc_interface 1.5.1`。以上首先通过**当前机器真实SDK bin/internal/engine.version + pubspec.lock**再次核验，若有冲突立即`SDK_IDENTITY_MISMATCH`停止；不要为迎合本任务调整锁文件。
- 唯一确证构建阻断来自离线命令`:connectivity_plus:extractDebugAnnotations`：`io.flutter:flutter_embedding_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab` `No cached version available for offline mode`，未产诊断APK；普通R1 flag-off debug宿主+release AAR成功并非诊断成功。诊断预期`com.elitesync.v1015icediag`／`10.1.5-ice-diag-test`，精确debug AAR坐标`1.0-icediag-<digest>`，Dart＋native编译门及原有5项负例保持。
- 前轮源码测试20诊断和93相关普通回归`CODEX_REPORTED_PASS`，无需因为Maven下载重跑整个RCT产品；若本任务无源码/配置变化，可针对APK正向产物验证作最少复核。
- 历史5保护根、1332具名旧原证、493旧refs、private env等均按实际开工态保护；原Windows 153条长路径警告继续独立记载，不能假定一切未登记cache都被hash。

## 三、一次集中执行S0–S5

### S0｜归属保护与本地先查

1. 检查当前连续任务候选仅在可识别、干净的独立工作树，HEAD为上轮交付，核实时main与既有源码Tree。不得对历史dirty根`reset/clean/stash/prune/force`，不得修改旧SQL/APK/备份、已有同名Gradle下载缓存和原证。保存保护baseline和单一新任务输出目录。
2. 核实`FLUTTER_ROOT`、`engine.version`、Gradle wrapper/插件版本及诊断build flags；精确定位上述缺失的Maven group/artifact/version，检查现有受信本地仓库中**同精确坐标**的POM/AAR及其内容真实性。不因本机存在`flutter.jar`便假定Gradle可正确解析Maven工件，也不得通过复制、改名、编造POM或人工重包改写坐标。
3. 若精确可信工件已经可在隔离Gradle目录中复用，记录源归属、证据hash即可直接走S2。若某工件身份冲突/不可证，停并分类，避免覆盖可信缓存。

### S1｜官方精确下载与供应链证明（仅需要时）

1. 官方Maven root限制为`https://storage.googleapis.com/download.flutter.io`。从已核engine版本推导标准Maven路径`io/flutter/flutter_embedding_debug/1.0.0-<exactEngine>/`；仅探测该精确版必要`.pom`／`.aar`／有发布者提供的校验sidecar，及**真正被解析错误点名且相同engine**的直接依赖。允许官方仓库在同一安全服务的必要协议请求；所有外部重定向/主机不符合预期时停止。不可把普遍的`flutter precache --android`或整个仓库镜像作为“最小依赖”。
2. 每个下载记录：完整group/artifact/version、官方源域名/内容类型/大小、下载响应与重定向、计算SHA-256、POM group/artifact/version、AAR/ZIP文件结构与必要二进制身份、是否提供官方checksums。**SHA-256自算只能证明本次字节身份，不能自行声称发布者签名/官方签章通过**；若官方checksum不存在，必须标`PUBLISHER_HASH_NOT_AVAILABLE`，以路径/HTTPS/metadata与原生验证能力作分级判断。
3. 使用**本版一次性隔离Gradle用户目录或专属只读构建依赖仓库**缓存正式下载材料，先明确现有仓库优先级与Gradle实际解析顺序，使相同engine依赖不跨版本串包。不能修改全局Flutter SDK/Pub cache、现有受信Maven缓存元数据、用户gradle.properties、远端证书/代理信任或系统安全规则。若必须修改受保护的配置、插件或引入非精确工件，立即`NEW_PERMISSION_REQUIRED`停止；不得绕过Gradle签名/校验门。
4. 有界预算：先**唯一最初阻断坐标**；若第一次可信依赖解析暴露额外缺项，仅能再补**明确同engine且为该诊断debug路径所需的官方Flutter依赖**，逐一入清单并限制目标；出现其它SDK版本、非Flutter未知依赖或超出授权域的获取需求则停止，不无限追依赖或把构建换成上线环境。

### S2｜唯一诊断debug正向构建与身份验证

1. 只有S1或S0完成**可供Gradle正确解析**的精确依赖才可启动一次原命令语义相同的`assembleDebug`（包含三项`ELITESYNC_ICE_DIAG_TEST_ONLY=true`、`ELITESYNC_V1015_LOCAL_BUILD=true`、`ELITESYNC_V1015_R1_LOCAL_BUILD=true`；`relationshipDualDeviceBuild=true`且diagnostic-only AAR debug target）。优先在隔离缓存下最终`--offline`构建以证明依赖完备；不得把移除`--offline`后的任意远程解析成功写成离线可复现PASS。日志必须具原exit、构建产物路径和签名身份。
2. 正向成功后，不安装真机，**直接从构建APK检验**：`applicationId=com.elitesync.v1015icediag`、`versionName=10.1.5-ice-diag-test`、debuggable true、native`ELITESYNC_ICE_DIAG_TEST_ONLY`标记、明确debug AAR而非旧release AAR、只含被授权的ABI、SHA256/bytes/apksigner证书及Flutter Dart入口可证；可比对普通R1包签名与包名互不覆盖。
3. 对此精确APK作必要**一次归档前负向保护证明**：release/profile不能携diagnostic flag通过配置；无local+R1、混v1014/v1012和误用ordinary package均必须fail-closed。上轮已有的5项真实build门可复用固定源码/旧回执，若确实重新执行仅做定位所需几项，不无界跑全项目。
4. 如首次正向build仍失败，区分：`OFFICIAL_ARTIFACT_NOT_FOUND`、`NETWORK_TLS_BLOCKED`、`DEPENDENCY_GRAPH_NEEDS_UNAUTHORIZED_SOURCE`、`DEBUG_AAR_COORDINATE_MISMATCH`、`OTHER_BUILD_FAILURE`。**只报告准确阻断与最小Owner下一批准**，不要连续换坐标/源/SDK或重复无信息相同构建。不得将缺产物标为通过；不得把普通R1离线包当诊断包。
5. 如果成功构建，结果仅`DIAG_APK_BUILT_AND_IDENTITY_VERIFIED`，**不等于真机ICE功能PASS**；不使用已经授权的旧手机进行安装/ICE测试，因为本任务没有再次授权设备现场阶段。

### S3｜安全／隔离及必要最小回归

- 保证`rtc_ice_diagnostic.dart`原白名单、30秒采样、700/750ms读取期限、epoch stop、连接前启动、未采音、真机/SDK日志LOCAL_ONLY的约束**源码未变**。所有锁定版本、build IDs与Hash绑定。
- 只复核本版显式诊断build positive产物，不更改R1普通音频、RTC revoke、guard和Laravel。源码不变可引用上轮20/93测试的固定日志作为`REUSED_VALIDATION`（非本轮现场再跑），不虚构重测数量。若为了产物隔离必须调整R1诊断构建代码，**不在此任务自动改源码**，按`BUILD_CONFIG_FIX_NEEDS_OWNER_DECISION`明确阻断、交Owner审议。
- 任何怀疑的APK代码或依赖污染、未授权网络信息流出、Gradle依赖版本失配均FAIL_CLOSED停止。独立一次有界非作者静态审阅新依赖来源/构建日志、产物身份和普通包隔离，必须区分非作者没有真实安装的限制。

### S4｜验收材料、保护及资源停止

- **只交付两份新增文档**：`docs/versions/v10.1.5/ICE_DEBUG_EMBEDDING_DEPENDENCY_UNBLOCK_REPORT.md` 和 `docs/versions/v10.1.5/ice_debug_embedding_dependency_unblock_manifest.json`。严禁修改旧实施报告/manifest、Astra review、冻结plan、ACTIVE_STATE、业务源码和SDK lock。源码`SOURCE_UNCHANGED`，真实apps/services Git Tree必须同`24ddf05875d8d4abad7a6b473f882698c9885c2a`；报告文档单独新候选自`8bee827c20c26c4ec954b774c011f09238ec59b3`演进。
- 报告须保存官方来源选择理由、精准坐标和依赖清单、真实网络退出码、完整文件Hash/bytes和验证方式、隔离缓存、唯一正向构建命令及exit、APK包/manifest/签名/Flutter入口与debug身份、普通R1包不受污染证明、DIL分类的测试和非作者复核、旧失败保留、历史保护/禁止项确认。不公开私密代理凭据、机器路径、用户/设备个人信息或付费配置；APK与Maven下载字节保持`LOCAL_ONLY`或专属可信缓存，不将二进制上传GitHub。
- 本任务不运行设备/服务/DB/SDK/RTC/ADB；因此不得声称有“服务运行后已经停止”或物理媒体回执。只清理**本任务临时进程**、不删已下载的合法受控依赖缓存、构建产物、历史SQL/APK/原证，不触碰用户全局Java/Flutter/ADB/Docker。
- GitHub普通nonforce发布文档候选并独立回读最终Git commit/唯一Parent/Root、两文档Blob、完整apps/services Tree与固定诊断源码同源。保留v10.1.4 main当前已接受状态，主线仅顾问可作状态文档记录。不得自签`ACCEPTED`、自动合并main或授权v10.1.6。

### S5｜终态分类并等待Astra独立审查

终态只能据事实填写其一：
- `V10.1.5_DEBUG_EMBEDDING_DEPENDENCY_UNBLOCKED / DIAG_APK_BUILT_IDENTITY_VERIFIED / PHONE_RUNTIME_NOT_RUN / AC05_OPEN / AWAITING_ASTRA_REVIEW`；
- `V10.1.5_DEBUG_EMBEDDING_STILL_BLOCKED / EXACT_OFFICIAL_SOURCE_OR_GRAPH_BLOCKER / NO_APK / AC05_OPEN / OWNER_DECISION_REQUIRED`；
- `SOURCE_IDENTITY_OR_SUPPLY_CHAIN_MISMATCH / STOPPED`。
无论哪一类，**不因构建成功宣布v10.1.5产品、RTC媒体或5秒撤权已经接受**。不自动启动另一轮APK安装、媒体实验、R2、P2、main集成或v10.1.6。
