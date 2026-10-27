# EliteSync v10.1.5｜源码加固后受控Gradle发布图验证 G2（仅一次 dry-run）正式任务

**状态：OWNER_APPROVED_NEW_BOUNDED_G2_GRAPH_PROBE / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / MAX_ONE_REAL_GRADLE_DRY_RUN / ZERO_REAL_AAR / ZERO_APP_APK / ZERO_GATE2**

日期：2026-10-27（Asia/Singapore）
Owner：最终授权与不可逆决策Authority。
Astra：Project Lead、Planner、Independent Reviewer、Orchestrator、Current-state Manager。
Codex：只在Owner**手动派发本任务**后实施，不把GitHub任务发布等同执行。

## 0. 唯一授权、结果边界和预算永续

Owner在Astra对源码候选`6ca09a66c0ef9619df7a3d7d4b089516f409954f`作出`SOURCE_HARDENING_ACCEPTED_WITH_OBSERVATIONS / SOURCE_LEVEL_ONLY`独立验收后，明确同意下一门：**一份新的、受控真实Gradle发布图探测任务，仅一次`assembleAarRelease --dry-run`**。本任务不含AAR/POM实际任务执行，不含外层APK/设备/Gate2，不意味着v10.1.5功能接受。

**新且单独的预算 G2：最多1次真实Gradle Popen**，仅限新可信输入库存通过后，在受监控的已pin Flutter module `.android`范围执行真实Gradle8.14 `assembleAarRelease --dry-run`。调用前原子持久化**本任务专属G2.claim**，一旦保留就计数1/1，不因配置失败、Popen失败、observer故障、Gradle退出非零、监测断档或强停退款/重试/换入口。若预检失败，则G2=NOT_RUN、0/1；若Popen调用前已保留claim但未创建子进程，则预算仍1/1，不得用新目录绕过。

**新 AAR实际执行预算=0，外层APK预算=0，Gate2=0**。历史完整APK 1/1、历史G 1/1永久耗尽；历史A表面0/1，但因旧G失败且非可转移额度，**本次A=NOT_AUTHORIZED / NOT_RUN**。绝不复用或重置旧claim/ledger，不启动A、`publish`、`:app:assembleDebug`、`flutter build aar`或其它Gradle命令。静态Python/mock可按本合同有界自主修正任务私有执行器/预检，但不能增加G2运行次数或对产品源码做修复。

只可接受三类最终报告：`G2_GRAPH_BOUNDED_SUPPORTED`（Gradle配置结束exit0、完整任务图可信、必要发布任务存在、无Javadoc/Dokka被选中且网络/监测未触发强停）；`G2_GRAPH_SELECTS_DOCUMENTATION_TASK`（被实际dry-run选入Javadoc/Dokka并停止）；`G2_GRAPH_NOT_PROVEN`（任何配置失败、产图不足、输入漂移、监测故障、Gradle运行异常、无可信任务覆盖）。如计划的前置清单不通过，直接`G2_NOT_RUN_INPUT_CLOSURE_BLOCKED`。**即使G2图成功，也只证明受控配置/选图，不证明AAR/POM真实产出或无真实联网。**

## 1. 执行前 fresh authority 与准确证据身份

务必先fresh GET远端main、Root和`docs/workflow/ACTIVE_STATE.md`、本任务全文及Blob、冻结v10.1.5 plan、原G/A授权/预算、历史G失败报告、最新Astra6ca独立评审、6ca实施报告/脱敏索引和所有受影响源码。动态分支HEAD不以历史SHA替代。

- 发布任务前main `b420db62bd6c86394333fad863bd15f2865f6fd7` / Root `5b50be9c0a17ce77f8759c1fd261bca08b4cb1cc`；**已接受v10.1.4** apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 本次仅核验的**未接受源码候选** `6ca09a66c0ef9619df7a3d7d4b089516f409954f` / Parent（源码commit）`71ab58533270dd8b3a1270a3452a82b4f426e361` / Root `3bf735ab1c8e394844db80be35d86d2250390c82` / 完整 apps `5af7a9d0042be19437616e969e260658b67e9353` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。真实源码commit唯一Parent `ba77a3c840c36550a7ec3aa5a6475b69d874004f`、Root `275cd2664444532c759d688ba4b262576ad065a4`。
- 6ca原实施报告Blob `ed802bb3a72d6e52e3fd926d4905b456e16bfd65`，证据索引Blob `8d5a379a351960b3cb391fd2fd074908872719ab`。Astra独立审查归档于 `astra/v10.1.5-6ca09a66-source-hardening-review-20261027:docs/versions/v10.1.5/6CA09A66_SOURCE_HARDENING_ASTRA_REVIEW_20261027.md`，Blob `6d5ee056409de7373e635cd5e75b6aed52396bbd`，审查分支head截至本单准备时 `b7215a6fd80918fff725b54f327cfa096d2a6ef1`。
- 方案一源级接受只适用于静态；旧G失败候选 `fd0da9cce87c5eb84aec96dd11ea37aecd7aefff`、旧G报告Blob `e6f0a1f96b5d52993dfce5f31ad9456ba4d06e80`、旧G索引Blob `38b20500d0e42218976a9f675607b7a5b259a7b1`。ba77根因报告Blob `8c4947c5b4155ce495eae25b799b8c053a96ea94`。旧失败`OWNED_AAR_INIT_REJECTED`与`PROCESS_INSTANCE_PATH_UNREADABLE`无已证唯一归因。
- 冻结`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；旧受控G/A任务Blob `129efb748bb5a22921e756f2f829a627ceae6880`；前轮源码加固正式任务Blob `ddcc4e7e74b4e2aeaf1651aa20f51a0749c7f28a`。
- 重点pin的owned init源码SHA256 `28c407c4fb95a7de690ff9a1455faf33bb62c28b365281dc6c2dfd20a61bb1a9`，guard `159a20ea2d7233b6e11d114cfa744a5edbdb9c230ffbf938d26fc231af380604`，schema2 SOURCE `ff4d82097e80239fb9d9861a68731573079d4120a2026aeddc5d4615c456942f`，UPSTREAM.patch `80966f8ea92f72137473911531882dd6394cc72da9ceaf0b697cedd7e5a0f240`；Gradle8.14、原Pin Flutter3.41.7、JDK17/AGP8.11.1等**需新鲜核对**，不可从版本标签替代字节身份。

## 2. G2之前必须建立新可信输入库存；失败则不启动

在**任务独有隔离工作树、独立输出目录**沿用6ca源码；绝不在保护dirty根直接重写。新库存不仅替换旧文件名，而要由新`owned_aar_init.inventory_contract()` schema2独立生成/核验，覆盖7项`REQUIRED_PROJECT_INPUTS`、`definitions`与`inventory`两侧真实SHA、guard/TOOLING_PINS、Kotlin消费者新的`-PelitesyncOwnedAarProjectRoot`、SOURCE/LICENSE/UPSTREAM、Flutter tooling included脚本、真实插件依赖引用、Flutter module生成的`.android/settings.gradle`及其解析路径、Gradle distribution/JDK/Android SDK/pub/缓存与真实执行工具的出处。对存在的path进行绝对/规范/重定向检查。

保留旧100453项目输入库存及历史证据为immutable；可以按pin继承**已Hash验证且字节未变的输入**，只定点增量审计变更17源码和它们的真实消费图；不能仅复制旧库存然后重新标记为已验证。每个运行期可能读取的工具/插件输入必须有**真实位置→可信库存位置**的证明；如果pub cache插件/Gradle缓存/Flutter SDK实际消费位置不能闭合，立即`INPUT_CLOSURE_NOT_PROVEN`停止。不为闭合而下载、联网解依赖、改共享SDK/Cache，或者用纯文本静态检查冒充闭合。需要本次拥有的小型input manifest/receipt、来源pin、Hash、文件类型/硬链接/重定向检查及LOCAL_ONLY细节。

**前置STOP：** 新inventory无法完整验证、真实Gradle命令和source合同漂移、root/init任务参数无法保持、现有runner/observer尚不能安全承载新G2授权、预算/监测无法原子持久化、磁盘空间不足或影响保护范围，则G2=NOT_RUN。不能以一次dry-run去探索尚未闭合的输入，也不允许靠旧G的“曾经验证库存”直接继续。

## 3. 新任务专有G-only入口与fail-closed监测

最新`apps/android/scripts/controlled_runner_hardened.py`默认`main()`与历史参考入口都会抛`NO_RUNTIME_AUTHORIZATION`。**严禁在正式tracked runner上直接删锁、调用旧`offline_debug.py --single-attempt-authorized`或通过历史`TASK=129ef...`开旧G/A**。本任务允许在**仅G2专有的新局部脚本副本/单独调度器**上增添最小的显式授权入口，限制只调用已固定`assembleAarRelease --dry-run`；所有输入、observer/runner源码、委派关系与真实命令Hash先由另一简单只读预检确认。调度器需把当前**正式任务Blob、本次G2 stage、固定6ca源码commit/Root、schema2库存Hash、G-only runner和observer源码Hash、精确命令/cwd/环境策略Hash**全部绑定到原子`G2.claim`和后置receipt；使用独占创建(`open('x')`等)在任何Gradle Popen之前锁定，绝不清除旧claims。未来运行权不能被移动到A或任何别的task。

在安全preflight阶段可以对**新任务私有调度器/观察器接口**做必要静态和完全mock验证/普通修正，不消耗Gradle预算；新6ca产品源码保持只读固定，不能顺带改`context_guard.gradle`、`aar_runtime.init.gradle`、app Kotlin或共享SDK。若原候选guard本身有真实配置错误，**记录G2失败而不重试/热修重新启动**。只有Owner新的修复授权才可能另做源码修复。

必须保证既有Windows Job kill-on-close / 根句柄创建时间 / 所属唯一进程实例归属（并清晰标记sampling非原子限制）、根与子进程身份、下载日志信号、全进程树网络观察、输入漂移与stop时终止**仅本任务Job**。Observer的首次真实sample前必须已经绑定强制LOCAL_ONLY可flush诊断sink；OpenProcess/QueryFullProcessImageNameW/GetProcessTimes失败、镜像路径不可读或子进程identity未知、PID复用疑点、diag写入失败、未知外部工具或越界、观测器API不能取样、任意非loopback TCP endpoint、任何明确下载信号都立即强停，任务计数不退款。UDP endpoint只能说明本地端点，不能宣称已发包或绝对没流量；如延续既有`UDP_OBSERVE_ONLY_DESTINATION_UNKNOWN`政策，必须原始行逐条保留、不能豁免TCP/监测故障。禁止改防火墙/代理/VPN/执行策略、提权、关闭/规避监测来获得成功，禁止真实外部费用及未知网络下载。

任务独立容量约束：避免复制整个Flutter SDK、Pub/Gradle缓存和旧100453清单数据到多份本地；优先现有可信只读输入+**单个有界任务输出隔离**。将**新增任务自有非缓存物理文件**的预算先按不超过512MiB规划，另记录真实Gradle临时写盘/用户home与可回收量；若必须写共享protected输入或无法预估/隔离新增写入，则fail-closed、G2=NOT_RUN，不能随意删除旧工具/缓存腾空间。禁止硬链接可能写入的受保护文件、`git clean/reset/stash/prune/force`与清理历史备份。新引擎产物/暂存不等于可删除历史证据。

## 4. 唯一真实Gradle G2命令：只可选图，不执行AAR任务

在通过上述所有preflight且原子占用G2.claim后，通过本任务G-only受控Job启动**一次**真实Gradle8.14二进制（不是Wrapper、`flutter build aar`或外层APP）：

- 工作目录：**本任务可信隔离根**的Flutter module `.android`，不能用另一个便捷root伪装。
- 按6ca普通R1真实Kotlin命令构造同一参数合同：先`-I=<pinned project-owned aar_runtime.init.gradle>`，接`-I=<pinned offline_debug.init.gradle>`；`-Pflutter-root`、`-Poutput-dir`、`-Pis-plugin=false`、`-PbuildNumber=1.0-v1015r1-<12hex>`（按受控源码计算）、`-Ptarget=lib/main.dart`、精确`-Pdart-defines`、`-Ptarget-platform=android-x64,android-arm64`、`-PelitesyncOwnedAarInit=v10.1.5-ordinary-r1-runtime`、`-PelitesyncOwnedAarProjectRoot=<exact canonical project root>`、`--offline --console=plain --no-daemon --max-workers=2`、已pin`--gradle-user-home`及JDK autodownload关闭；后加`--dry-run`。
- 唯一任务名称`assembleAarRelease`；不增加第二个task；含Javadoc/Dokka时仍只是图验证，并不能运行这些task actions。Gradle配置及插件初始化**本身可以执行逻辑/尝试网络**，所以`--dry-run`不是安全或绝对离线证明；必须始终监测，必要时强停。
- 命令`-P`/init脚本及位置、输出目录/用户home与Kotlin正常R1入口的任何真实差异都必须清楚标注与闭合；不允许因为guard失败而删guard、调整到非等效命令或切另一个Gradle版本。**若安全监测自身不满足约束，宁可不运行G2。**
- 总运行硬上限1200秒，若无任务完成信号、输入漂移或新网络观察强停则终止本Job；终止后确认只此Job及后代退出、output-dir写入范围，保留log和失败原件。

## 5. G2验收准则和证据区分

只有同时满足：`Gradle实际启动且exit=0`、完成配置与完整`--dry-run`选择输出、任务图覆盖`:flutter`和每个实际需要的Android plugin AAR/metadata/POM/sources/publish任务、该合同的task选择逻辑可靠、运行全程监测有效且stopReason=NULL、输入前后Hash不漂移、所有子Job清空，才可报告`G2_GRAPH_BOUNDED_SUPPORTED`。一个插件被列为required但未出图要标`GRAPH_NOT_PROVEN`，不能根据"BUILD SUCCESSFUL"直接PASS。

必须分别标明每个目标task是`REGISTERED`、`SELECTED_IN_DRY_RUN`还是`ACTUALLY_EXECUTED`。在真正完整图上明确搜索`*:javaDocReleaseGeneration`、`*:javadoc*`、`*:dokka*`及JavadocJar；若任何文档生成任务**被选入**，报`G2_GRAPH_SELECTS_DOCUMENTATION_TASK`，不得宣称方案一已解决图问题。配置在`settings.gradle/plugin-loader`失败、observer API/Job失败、网络或下载触发、未达到可信图条件，则`G2_GRAPH_NOT_PROVEN`。当`selectedTasks=[]`且Gradle配置失败，只能`DOKKA_TASK_SELECTED=NOT_PROVEN`，不能写FALSE。

**即使G2成功：** `AAR_POM_RUNTIME_NOT_PROVEN / ACTUAL_BUILD_NOT_COMPLETED / REAL_PUSH_PROVIDER_PENDING / AC05_OPEN / V10.1.5_PARTIAL_NOT_ACCEPTED`。既有历史TCP事件的`ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN`不清零；新网络观察也不自动证明历史Dokka归因。无实际AAR/POM、Module Metadata或APK Hash时不能捏造产物。

## 6. 单次集中交付、保护与STOP

把本任务原始真实G2`claim`、私密命令/进程树/socket/PID/API诊断、原始stdout/stderr/Runner代码和敏感host路径等保持`LOCAL_ONLY_RAW`；GitHub仅发布经过审查的**脱敏Markdown综合报告、最小SHA256证据索引和必要的安全源/静态测试**。报告至少包含：

1. 新可信库存闭合状态、schema2合同与新旧差异、Gradle/JDK/Flutter/SDK工具和各plugin输入实际映射；未闭合就`G2_NOT_RUN_INPUT_CLOSURE_BLOCKED`。
2. G2授权`MAX1`及唯一claim是否已原子创建、`reservedStarts`、Popen实际发生与否、完整真实命令Hash、root/userhome/cwd身份、Gradle退出及stopReason、观察样本数、强停/API失败、Job最终清空回执、所有input/输出SHA。
3. Dry-run真实selected任务逐行的脱敏可核验摘要；Flutter及插件publication/metadata/POM/sources/文档类任务逐类`REGISTERED/SELECTED/EXECUTED`与缺失；对于任何失败精准保留失败阶段与已知/未知。
4. 旧partial仍7,941,328 bytes/SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`、旧APK claim SHA256 `07820a04f5f7bb5fccea83a5372340af33b224269bc6f89b476b637230140f8c8`、旧G claim SHA256 `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`、A claim不存在等具名历史原证**按可触达范围首尾只读校验**；老26784保护集合、108附证、525历史refs和旧100453库存没逐项重算不能冒称本轮又全量通过。
5. 任务拥有工作树、实际空间增量、可追踪GitHub候选Commit/唯一Parent/Root、完整apps/services Tree、报告/索引Blob原字节远端回读；main接受产品树不变。原源码`6ca`及其Astra验收原证永久保留，绝不合main。
6. `CODEX_REPORTED_LOCAL_EXECUTION`、`DIRECT_GITHUB_READBACK`、`LOCAL_ONLY_RAW`与`ASTRA_DIRECT_GITHUB_STATIC`各自来源分层；不得以Codex自查取代未来Astra独立验收。

只在普通non-force审阅候选归档，不推送私密日志、旧SQL/APK、token或本机原生网络数据；不修改历史候选refs、不清理旧Gradle缓存/旧软件、不重写原预算。任务内不另发后继真实AAR任务，即使G2成功也要**STOP等待Astra独立验收及Owner单独新预算决定**。不自动启动v10.1.6或产品main集成。
