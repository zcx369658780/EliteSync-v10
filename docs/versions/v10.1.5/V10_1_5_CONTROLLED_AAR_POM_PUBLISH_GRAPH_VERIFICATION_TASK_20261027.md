# EliteSync v10.1.5｜方案一后续：新可信输入库存 + 受控 Gradle 发布图 / AAR / POM 验证

状态：OWNER_APPROVED_BOUNDED_NEW_VERIFICATION / READY_FOR_MANUAL_CODEX_DISPATCH / NEW_LIMITED_1_GRAPH_PROBE_PLUS_1_AAR_EXECUTION / NO_APP_APK_BUILD / NO_GATE2

日期：2026-10-27（Asia/Singapore）
Owner：重大方向、不可逆操作的最终 authority
Codex：Owner手动派发的本地执行者
Astra：交付后集中独立验收

## 0. 授权的精确含义（必须遵守）

Owner在Astra有界接受方案一源码修复之后，已明确同意**下一阶段先建立新的可信构建输入清单，然后受控验证实际 Gradle 发布任务图和 AAR/POM 产物**。

这是**一份新、单独、有限的验证授权**，绝不是恢复或重置2026-10-26旧单次构建预算。旧 `single-offline-build-20261026.claim.json`、entry-dispatch guard、ledger和失败证据保持原样：旧1/1预算已耗尽、剩余0。

新授权的上限严格是：
- **新预算 G = 最多一次**受监控的**内层 Flutter AAR Gradle `assembleAarRelease --dry-run` 发布图探测**。它是真实Gradle启动，只是不执行任务动作，不能称为零运行。
- **新预算 A = 最多一次**受监控的**内层 Flutter AAR `assembleAarRelease` 实际执行**，只有G成功、不含意外Javadoc/Dokka任务且所有前置门禁通过时才允许启动。它不包含外层 `:app:assembleDebug`。
- 两次是**两个不同的受控Gradle入口**；即使某次因Popen失败、观察器停止、缺依赖、任务图异常或任何中断而未达到目标，也不得退款、换入口或自动重试。
- 若新库存无法完整独立核验，**G和A均为NOT_RUN，不能为了补证据而试跑**。若G失败、不能确认解析图或含需阻断的文档任务，**A=NOT_RUN**。

明确**不授权** Android APK完整构建、安装/ADB/设备测试、RTC/后端/DB、真实Push、生产服务、新费用、Gate2/Writer/Serializer、系统防火墙/网络策略/代理/VPN/执行策略改动、管理员提权、下载工具/依赖。不可用旧的Astra有界源码接受替代真实运行验收。

## 1. 实时权威与来源固定

执行前fresh GET：本任务单、`docs/workflow/ACTIVE_STATE.md`、冻结 `docs/versions/v10.1.5/plan.md`、方案一正式Astra复核 `SCHEME1_OWNED_AAR_INIT_ASTRA_REVIEW_20261027.md`、最近候选 `da5ce628a499c97e916e780e2cf795353745c147` 的 `IMPLEMENTATION_REPORT.md` / `artifact_manifest.json` /源码和既有原始LOCAL_ONLY证据索引。参考身份必须复核，不可把历史 SHA 当实时 HEAD：

- main `4df2e7f0f36cc7b80258faa73e80dad682cff6c5`。
- 方案一候选 `da5ce628a499c97e916e780e2cf795353745c147` / Parent `50d79396195ed8b4b86c218584ab59864ad600be` / Root `e140a196942c7b1aebf8bf90871e34afaec49501`。
- 实际方案一源码 `50d79396195ed8b4b86c218584ab59864ad600be` / Parent `3d0c656d59e8621ffa6a935313b5cd4c860a16b1` / Root `d3c8e2cfbe28e3a1a4e13ac217b868f5cbb7ae20`。
- 候选 apps `e6bff4bc8e359e6afe80c02f25212ee8b6195eab` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。
- 已接受产品v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 方案一报告Blob `2f2b025d274cb79bafb89bb9b0374b4575786b06`、Manifest Blob `c56644a04b88f2f02bd7369724e4d6c7aff65637`、冻结plan Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`、Astra复核Blob `1a39ba1ab5df7c69a0f6143b4734ba56b31cf134`。

只在**新任务拥有的隔离根**操作；已有保护dirty根、项目main、历史候选/refs、SDK、SQL、APK、旧日志和旧partial不可修改。历史 `7,941,328` 字节下载partial SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`、旧claim及保护索引必须首先核验并在结束后只读复查。

## 2. 独立构建输入库存：强制前置、先于任何Gradle

从方案一已回读的源码及已知R1成功环境中已有工具/缓存，**独立**核验：
1. Gradle 8.14的实际二进制、distribution和版本receipt身份；JDK、Android SDK、Flutter SDK、Pub/Gradle缓存的具名文件Hash。原缓存存在不代表新的依赖图已闭合。
2. 新 `apps/android/app/build.gradle.kts`、`apps/android/scripts/owned_aar_init.py`、`owned_flutter_aar_init/{aar_runtime.init.gradle,SOURCE.json,UPSTREAM.patch,FLUTTER_LICENSE}`、其余 `REQUIRED_PROJECT_INPUTS`、原SDK `aar_init_script.gradle`及许可、Flutter module `.android`生成输入、真实插件元数据引用路径及相关声明。源Hash不符、软链接/reparse、越界路径、漏项目/依赖定义必须fail-closed。
3. 新manifest须包含由 `owned_aar_init.inventory_contract()` 确定的 `ownedAarInitContract`，以及六个 `REQUIRED_PROJECT_INPUTS` 在 `inventory`与`definitions`的精确字节Hash。不能只复制旧库存 `3eafdc458ee7a0dd06b3a5e47fb1d26396aa30faac950732e82fd20c26f1c0c6` 后更名就称新库存完成。
4. 对 `pub cache` 实际引用路径与受控库存副本可能不一致的事实必须单独解决：若真实任务从库存之外的插件/工具路径读取输入而不能固定、验证或隔离，则 `INPUT_CLOSURE_NOT_PROVEN` 且停止，不得以“没有新依赖”推定有效。
5. 新可信库存应为**本任务唯一受控快照**，有完整路径scope、Hash、新源码/缓存映射及出处；将受限路径明细保留LOCAL_ONLY，只发布脱敏Hash索引。不在构建前改写共享SDK/缓存，不下载/联网补缺；如果无法在既有字节条件下闭合则报告阻断，不执行Gradle。

先运行必要的纯本地Python Hash/静态/隔离检查，确认已有方案一37项/44项测试可按本任务源码直接复验；不得把这些当Gradle图测试。独立只读校验完成后才有资格使用新的G预算。若发现实施缺陷超出本验证范围，停止交Owner；**本任务不授予修复产品源码或随意升级依赖**。

## 3. 受监控的Gradle启动安全边界

必须通过**新任务专属**、独立的只读清单预检与持久化预算claim进行防重入。分别为G和A在启动其Gradle Popen**之前**原子保留一次授权（如exclusive `open('x')`）；保留所有成功/失败/未使用预算回执。独立旧claim绝不更改、删除、重置或复用。

命令配置必须取自 `app/build.gradle.kts` 原普通R1内层AAR的**真实参数合同**，不是凭记忆构造一个较简单的不同任务。直接调用已Hash验证的本地Gradle 8.14及该同一Gradle user home，显式：
- 项目工作目录为本任务隔离根的Flutter模块 `.android`；
- `-I` 加载经过pin的项目自有 `aar_runtime.init.gradle`，随后继续保留项目 `offline_debug.init.gradle`，并传项目自有scope参数；
- `-Pflutter-root`、`-Poutput-dir`、`-Pis-plugin=false`、`-PbuildNumber`、`-Ptarget=lib/main.dart`、`-Pdart-defines`、`-Ptarget-platform` 与原R1普通模式对应；
- `assembleAarRelease --offline --console=plain --no-daemon --max-workers=2`、当前既有必要`--gradle-user-home`与禁用JVM自动下载参数，避免任何Wrapper及下载fallback；
- 仅探测G在这些**同一配置**后追加 `--dry-run`；真实A不追加。明确记录两次参数差异与源Hash。

全程沿用已固定的Windows任务进程树网络监测、安全停止、快照和日志Hash机制。**不要通过原`offline_debug.py --single-attempt-authorized`旧入口重跑**：那是 `:app:assembleDebug` 且旧预算已耗尽。新执行器只可由本任务专属脚本与清单构成，执行器源码本身若需新增，须仅写入本任务拥有的局部脚本/隔离目录并接受静态隔离审计。

- 强停：任何非loopback TCP、已明确识别的下载日志、观察器读取失败/无法识别根实例、缺失/漂移输入、未知外部工具自动启动、任务根越界立即fail-closed，并停止**仅本任务拥有的进程树**；不得修改系统网络策略。
- UDP endpoint仅作目的不可见的本地观察，不声称已发包或完全无网络。若沿用先前有界单次观察策略允许仅UDP信号不阻断，必须在本任务授权参数中显式声明且保留每条观察；**任何UDP不能覆盖TCP/下载/观察器故障强停**。这不证明UDP未实际发包、绝对离线或安全无风险。
- 不能仅依赖PID积累集合就宣称捕获归属100%准确；现有监测的进程实例与非原子采样局限仍要单列。若监测失效，立即停止，不得直接改用无监测Gradle以拿到产物。
- 不得为了完成任务放宽TCP强停止、加不经核验的远端白名单或丢弃失败证据。
- 受控进程/Gradle即使因缓存变动而异常，也不能为了补全结果再启动另一个相同命令。

## 4. G阶段：最多一次真实Gradle发布图 `--dry-run`

必须先由Python/静态独立预检通过、确认新库存真实闭合且本任务授权claim可原子锁定，才能调用一次真实Gradle `assembleAarRelease --dry-run`。

G阶段验收分三种：
- `GRAPH_BOUNDED_SUPPORTED`：Gradle实际配置/任务选择退出0、同一参数合同、全部必需Flutter和plugin AAR任务与publication/metadata任务可识别，报告其选中状态，并对 `:connectivity_plus:javaDocReleaseGeneration` 及其它文档Javadoc/Dokka任务的**选中情况**作明确只读判断；task被注册不等于被选中或执行。
- `GRAPH_STILL_SELECTS_DOC_TASK`：若dry-run选择了该文档生成/Jar任务，保留证据并停止，**不得再执行A阶段**；这说明方案一的源级修正尚不能闭合期望的发布图。
- `GRAPH_NOT_PROVEN`：配置失败、监测强停止、输出不足、预检失败、必要runtime/plugin任务丢失或任务图不完整。停止，不执行A。

G阶段的 `--dry-run` **不会执行普通任务动作**，所以不能证明实际AAR/POM构建或Dokka运行期网络无异常，也不等于未加载项目配置插件。不能声称dry-run无任何网络。

## 5. A阶段：只有G合格时，最多一次受控AAR发布执行

**仅G阶段真实运行成功、具有完整可审核任务图证据、期望Javadoc/Dokka任务未被选中、未出现网络强停止及其它阻断时**，启动最多一次直接内层Gradle `assembleAarRelease`，重用同一受控输入身份。

A阶段真正执行/验证而非只打印名称：
- 需要的 `flutter_release` 与插件AAR对应变体、产物数量/版本/路径及SHA256、对应POM和Gradle Module Metadata如按原发布合同应存在的文件；
- 不破坏 Flutter plugin依赖坐标、组装变体、来源和runtime属性；读回POM/meta字段与依赖集合，以原已接受R1对应产物身份及源码声明作一致性比对，不能因缺少旧POM基线而编造精确相等；
- 删除Javadoc请求并非禁止sources：保留必要sources与runtime AAR；若任何依赖路径丢失，标记 `AAR_POM_RUNTIME_NOT_PROVEN`，不得写PASS；
- 是否实际执行Dokka：仅由G的selected tasks与A阶段真实stdout、任务结果证据判断。不能从日志中缺少Dokka文本就宣称“Dokka绝对不运行”，也不能把没有非loopback TCP的**有限样本**等同绝对无联网；
- 任何强停止/无法得到全部必需产物/Hash/依赖模型缺口，都保持 `AAR_POM_RUNTIME_NOT_PROVEN` 并停止，不启动外层APK。
- 如输出存在但未执行所有任务（缓存UP-TO-DATE），需要准确标记为缓存命中/引用，不把历史产物重标为本次真实新构建。可通过任务拥有输出独立性、文件Hash和执行日志区分。

若G完成但本次任务不具备能安全证明输出的条件，A直接 `NOT_RUN`；不得为了填表而启动。

## 6. 运行终态、保护和交付

无论G/A是否成功，都必须确认任务独有Gradle进程及子孙关闭、其作用域端口终态与任务拥有的临时目录状态；保留原日志/网络观察、退出码、stdout/stderr和证据Hash，不运行`gradle --stop`作用于非任务Gradle，不杀Owner系统全局进程。

对具名历史保护范围做首尾只读核验：旧R1首次下载partial `7,941,328`字节和原SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`、旧构建日志、原claim/ledger、旧SQL/APK/refs、5历史根及LOCAL_ONLY。此前26784项具名保护清单/524旧refs为参考核验范围，不得冒称整盘审计。共享SDK/缓存只对声明不可变输入作前后Hash核对，预先允许的task-owned生成输出单独列名，不得称全盘零写。

集中交付同一v10.1.5的一份综合 `AAR_POM_CONTROLLED_VERIFICATION_REPORT_20261027.md` 和证据索引/受控候选说明。若新增本任务专属的最小验证脚本或项目文档，只发布安全源与脱敏派生摘要；所有敏感完整路径/IP/PID/socket信息、旧APK、SQL、原始回执等留在LOCAL_ONLY。发布普通non-force候选，回读Commit/唯一Parent/Root、apps/services完整Tree、文件Blob/原字节。历史`IMPLEMENTATION_REPORT.md` / Manifest/plan仍作为immutable prior source，不因本验证任务静默回写或清除旧失败；若需新的验收索引仅普通追加独立文档。Astra独立验收以新候选+本任务原始运行证据身份为准。

必须单列：
- `INVENTORY_CLOSURE`: VERIFIED / BLOCKED；
- G预算：MAX1，实际启动/剩余/完整命令与Hash、dry-run任务选择、stopReason；
- A预算：MAX1，G门禁与实际启动/剩余/产物Hash/POM依赖及meta证据；
- `DOKKA_TASK_SELECTED`：TRUE/FALSE/NOT_PROVEN；`DOKKA_TCP_CAUSALITY`：仍NOT_PROVEN，除非未来有真正归因新证据，本任务不能用关联推断；
- `APP_APK_BUILD`：NOT_RUN，不能因AAR成功写APP APK PASS；
- `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`不改，真实Push/AEC/期限清理等未关闭项仍旧开放；
- 证据等级：`CODEX_REPORTED_LOCAL_EXECUTION`、`DIRECT_GITHUB_READBACK`、`LOCAL_ONLY_RAW` 与非作者审阅事实分开。

不自动建下一任务，不授权第三次Gradle启动、外层完整APK构建、Gate2/Writer/Serializer、新费用、真实Push、设备/RTC或生产服务；不合并产品main、不启动v10.1.6。候选完成后停止等待Astra集中独立验收。

## 7. STOP状态

**执行任务单不等于自动启动Codex。** 必须由Owner在既有本地 Work→Codex 工作流中手动派发。

原 `BUILD_BUDGET_EXHAUSTED_1_OF_1` 永远保持事实。新G与A为另一项受控验证授权，不为旧APK构建续命。直到真实AAR验证完成，保持 `PUBLISH_GRAPH_NOT_EXECUTED / AAR_POM_RUNTIME_NOT_PROVEN`；直到全APP另获批准并实跑，保持 `ACTUAL_BUILD_NOT_COMPLETED`。原TCP事件的 `ROOT_CAUSE_NOT_PROVEN` 和 `EDGE_NOT_PROVEN` 不被倒改。
