# EliteSync v10.1.5｜项目artifact变体选择定点纠正＋唯一离线30配置解析｜Codex综合长任务

日期：2026-10-23（Asia/Singapore）。

**ASTRA_SCOPED_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / EXECUTION_NOT_STARTED / VARIANT_SELECTION_ROOT_CAUSE_NOT_YET_CONFIRMED / CONDITIONAL_SINGLE_FORMAL_RESOLVE_0_OF_1 / NO_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**

## 0. Authority、总目标与停止条件

Astra已对上轮`9e3333151125deb9985e86324811c1737a4fa90d`交付独立审查。Owner此前要求验收后继续推进，本任务只作为**供Owner手动派发本地Codex**的下一份单一综合长任务；发布任务本身不运行Codex、不自动消耗预算。禁止因文档已签发而跳过Owner实际派发。

**唯一目标**：在固定受控Flutter3.41.7／Gradle8.14／AGP8.11.1环境下，对首个真实阻断`:flutter:debugCompileClasspath`→`:connectivity_plus:debugApiElements`的**artifact变体选择歧义**做具名、可验证的消费者／生产者属性定点分析；如果能在**任务LOCAL_ONLY临时init或诊断解析器**内证明正确、不降安全的补正，再由本任务在Owner手动派发范围内最多执行**一次**完整真实`resolvePinnedDebugInputs`（15模块×2配置=30）。遇到无法明确属性语义、超权限、负例未通过或新依赖缺项，按相应门立即STOP；不连续派多轮微任务。

**绝对禁止**：更改任何跟踪的`apps/services`源码（包括`apps/android/app/build.gradle.kts`）、正式Gradle/Flutter/AGP/Kotlin版本、SDK/依赖锁/官方二进制、全局或用户环境；不联网下载、不使用Wrapper、不自动切AAR/APK构建、安装/ADB/真机、RTC/SFU/DB/API/网络端口/防火墙/UDP/LAN/TURN、不接入Push、不合main、不R2、不删保护资产、不启动v10.1.6。试图以`--continue`、`lenient`掩盖缺项、关闭传递依赖、硬编码省略插件、转换目标为纯dependency graph或把一次artifact选择失败当14个配置已执行，均不允许。

## 1. 固定source身份、首次必须只读核验

- 唯一仓库`zcx369658780/EliteSync-v10`；开始先重新获取live main/Root/apps/services，不凭任务编制SHA永远不变。当前main仍是**v10.1.4接受产品**（apps`3468a3dd97da7accfda2539a0f8d8f68931a6110`；services`0cb1f9d19659291a462488b3686fd0a07a6698ac`），不是v10.1.5源合并权。
- 后继唯一候选起点`9e3333151125deb9985e86324811c1737a4fa90d`，Root `34b72d5916edc2e928f28187c760a05eb64e83c6`，sole Parent `d45c0fae755fb97e1df9cbdc875965725a88d969`。待验apps Tree`785822ca072943c5bfefa3ccc37ede01c2af5164`，services Tree`1e1e20bb3500bedb1a521e5f2ddeece915d09424`；本轮仍须逐项不变。接受的诊断构建source`1522466faf798b719ccff281de7584f043946437`，build.gradle.kts Git Blob`bdb8e241d3e0defd1793c90b5f730c2facd7433d`只读。
- 本轮Astra独立复审`docs/versions/v10.1.5/ice_variant_selection_first_blocker_independent_review.md` Blob **`808f8cda0ded459811384c9c63db9a4fe0b8b935`**；原交付报告`ICE_ENV_RECEIPT_CORRECTION_AND_SINGLE_RESOLVE_REPORT.md` Blob`1b39ce901faa27826143ca151b370ff91e75987c`，Manifest`ice_env_receipt_correction_and_single_resolve_manifest.json` Blob`e83f2f6992530dfa63a37fbd32fda6467b4d46a4`。先按固定Blob读这些证据，旧失败和未跑配置身份都保留。
- 既有环境回执50键全保留、安全fixture38项PASS、旧HOST及25项fixture PASS均作为已审前证复用，不重新执行。实际Gradle消费的sealed env Hash按既有LOCAL_ONLY回执`78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`；`ANDROID_PREFS_ROOT`不可出现，`ANDROID_USER_HOME`保持既有批准归属。首次正式解析结果：1/1 exit1、118.183s，`:flutter:debugCompileClasspath` BEGIN1、OK0、29项NOT_RUN；首个`:connectivity_plus`的`debugApiElements`有8种可选artifact type，**没有观察到缺失GAV**，旧API/Gradle运行日志仍LOCAL_ONLY。
- 工具冻结：Gradle8.14、Flutter3.41.7、Dart3.11.5、engine`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、AGP8.11.1、Kotlin2.2.20、JDK17.0.18.8。可信Gradle bin SHA256`af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`。不能为了修variant错将前述工具升级或替换为未知官方下载。

## 2. D0｜具名保护和只读定位（正式解析0次）

1. 只读核旧LOCAL_ONLY首失败原始stderr **102148B／SHA256 `78894d70ca6600fde5a94f9f2f375411a82d487e57d521fdf69b659382e09ec2`**、stdout **2620B／SHA256 `3c2daa4368a821a9f779c0736dbe6ffc969f3696fe1728dccda8bd75ef617bea`**、原init和Gradle脚本source及前轮固定测试helper、解析器入口、target属性。先提取**原有日志已包含**的consumer attrs/producer attrs、各artifact类型及14个插件的统一症状；不假装本轮新运行或补造未打印异常类。可通过固定本地Gradle8.14/AGP8.11.1及插件metadata做**具名只读源码/配置检查**，不无界搜机器、也不通过试改SDK定位。
2. 按具名范围保护上轮289350份登记文件（前一轮初始hash＋终检delta/9项复核；不是声称终检全量hash）、502个old refs、五历史root和153既有长路径warning，以及未授权`.zip.part`、原dirty、私有SQL/APK/env、旧调试日志/daemon/失败。优先复用已证明干净的`LOCAL_ONLY`离线隔离工程与Gradle home；**不要为修一个init artifact属性再次复制整个7.3GB SDK/依赖副本或回滚原树**。确实无法确认运行隔离安全则`PRECONDITION_BLOCKED`。
3. 明确编译与运行两个configuration的**真实目的**：`:flutter:debugCompileClasspath`的消费者class artifact需求与`debugRuntimeClasspath`的runtime artifact需求不得合并。分清Gradle依赖**图variant**选择和**secondary artifact**选择。首日志暗示consumer未明确请求`artifactType`，但不预先认定任何值（`jar`、`android-classes-jar`等）就是唯一正确的修复。参考Gradle官方概念文档 https://docs.gradle.org/current/userguide/artifact_resolution.html ，但此文档当前版本可能不同于Gradle8.14，实际合同仍需本机已冻结版本和插件证据核定。

## 3. D1｜任务局部有界诊断与静态/fixture门

1. 在全新**任务自有LOCAL_ONLY**脚本/临时Gradle init副本提出**至多一个经证据支持的最小方案**：给原consumer的artifact-selection选择提供明确正确的属性/ArtifactView，仅限目标诊断解析脚本；不能以`resolutionResult`只得依赖图而跳过要求的真实文件解析，也不能在非法配置下人为取首个候选。若无法从已冻结AGP producer/Gradle consumer确定准确匹配规则，直接`VARIANT_CAUSE_OR_FIX_NOT_PROVEN_STOP`，不用Gradle试错枚举。
2. 在运行预算外，可用**最多一次**隔离的小型、完全离线Gradle8.14属性匹配fixture（仅fixture-owned最小合成producer/consumer；不装APP插件、不解析本产品依赖）验证：多候选时旧语义歧义可复现；正确属性下唯一适当artifact；compile与runtime分别保留各自意义；任意错误artifact type/不同AGP属性/缺失GAV时**不得静默放行**，且`lenient=false`、transitive保持、无保留旧授权复活。允许纯脚本静态负例替代需要新环境权限的fixture，但不能把纯static称真实Gradle验证。
3. 对**实际后继30配置解析器**的固定入口作差异审阅：仅一份LOCAL_ONLY init/runner可变，原50键sealed env、cwd/argv、taskRoot、工具输入、仓库exact GAV allowlist、15×2遍历顺序和首异常停止不变；不修改跟踪build脚本、独立LocalProject源码，也不启用外网。一次非作者定点复核必须在正式预算前确认修复不会把旧问题改成伪PASS。诊断门不成立即停，不为了让30项解析开始而删除保护。
4. 若已打印consumer属性无法据实选定`artifactType`，应交付`VARIANT_FIX_NOT_PROVEN`和需要的一个最小诊断建议，**不要再放行正式解析**。本任务并未允许任意数量的Gradle生产配置试跑、Android插件修改或多种方案搜索。

## 4. D2｜仅一次正式30配置离线解析

仅D0/D1全部PASS才可调用**一次**可信本地Gradle8.14 bin，固定`resolvePinnedDebugInputs --offline --no-daemon --console=plain --max-workers=2 -Ptarget-platform=android-x64,android-arm64`及先前三诊断flags/四iceDiag属性与既有受控专用init。无Wrapper、`--refresh-dependencies`、新下载/SDK补包，不能改plugins/dependency graph或重试。

必须观察`Configuration.resolve()`对实际15模块×`debugCompileClasspath`和`debugRuntimeClasspath`的运行：逐项`BEGIN`、`OK`与首阻断项目/配置、stdout/stderr真实exit、执行时间、已核合法artifact选择等。**30/30 OK才称正式解析PASS**。第一个缺失GAV、插件/SDK错误或新的variant歧义立刻STOP；余项真实标NOT_RUN，不重复跑一轮来处理下一错误。

无论是否通过，`flutter AAR`、`syncFlutterAar`、`assembleDebug`、APK构建/安装、实际RTCPeer/Room/媒体/设备和后续v10.1.6均为0；本版冻结AC05四硬门继续OPEN。

## 5. D3｜保护、单次非作者复核、最终交付

- 一次有界非作者复核固定脚本准确属性、合法/拒绝负例、D2计数/失败和无产品字节漂移；不能用非作者主观PASS代替Astra独立验收。历史保护工作只看触及对象、已具名快照与新派生范围；真实运行Gradle本任务可能产生缓存/daemon/lock输出，应分类计数，不宣称零写入；原始stderr、SDK、路径、完整env、原SQL/APK等仅LOCAL_ONLY。不得大规模扫描无关历史/用文档数量衡量质量。
- 在连续候选`9e3333151125deb9985e86324811c1737a4fa90d`后新建一条无污染后继分支，Git只**新增**：
  - `docs/versions/v10.1.5/ICE_VARIANT_SELECTION_SCOPED_FIX_AND_SINGLE_RESOLVE_REPORT.md`
  - `docs/versions/v10.1.5/ice_variant_selection_scoped_fix_and_single_resolve_manifest.json`
- 不改`ACTIVE_STATE.md`、旧冻结计划/拒绝/报告、旧review分支或受保护私有证据。普通non-force提交/发布，远端回读sole parent/Root/2个新Blob/完整apps与services Tree及原文字节后STOP。Astra独立审阅后再决定是否发布下一份任务。绝不自签产品`ACCEPTED`或把候选合main。

合法终态按证据选择一个：
`VARIANT_FIX_NOT_PROVEN / FORMAL_RESOLVE_NOT_RUN / NO_APK`；
`VARIANT_FIXTURE_OR_PROTECTION_BLOCKED / FORMAL_RESOLVE_NOT_RUN / NO_APK`；
`VARIANT_FIX_BOUNDED / OFFLINE_RESOLUTION_FIRST_BLOCKER / NO_APK`；
`VARIANT_FIX_BOUNDED / OFFLINE_30_CONFIG_RESOLUTION_PASS / NO_APK`。

统一附加：**`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_PRODUCT_MAIN_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`**。

本任务发布即停在Owner手动派发门；执行完毕停在Codex交付，不自行连续运行后继。
