# EliteSync v10.1.5｜Flutter AAR / Dokka 文档任务依赖链｜单份静态调查任务

**状态：OWNER_APPROVED_STATIC_INVESTIGATION / READY_FOR_OWNER_MANUAL_CODEX_DISPATCH / ZERO_REAL_BUILD_BUDGET / NO_CODE_CHANGE / NO_GATE2_AUTHORIZATION**

日期：2026-10-27（Asia/Singapore）
Owner：产品方向和不可逆事项唯一最终authority
Codex：Owner手动派发后的本地只读调查执行者
Astra：后续非作者独立验收

## 0. 唯一目标与明确不做

Owner已同意在真实构建失败后，**先查 Flutter AAR 的文档生成任务为什么进入任务图**，并保留TCP发起者尚不可证实的结论。以一份综合静态调查说明：

1. 为什么外层 `:app:assembleDebug` 通过 `syncFlutterAar` 引出内层 `assembleAarRelease`？
2. `connectivity_plus:javaDocReleaseGeneration`（及相关Dokka、出版任务）可能经哪条 Gradle task dependency/finalizer/publication/configuration路径进入内层任务图？
3. 为什么 `offline_debug.init.gradle` 移除 `javadoc` classifier 的发布artifact后，原日志中仍实际出现Dokka执行？这一移除的精确作用及局限是什么？
4. 最小的**候选**软件修正有哪些、会否影响必需的AAR/POM/runtime依赖？仅给出有据可查的修订建议，不实施、不声称已消除TCP。

**这不是构建授权，也不是修改程序的授权。原单次真实构建预算耗尽1/1、剩余0；本任务不得重跑构建、`gradle tasks`、`--dry-run`、`dependencies`、`help`或其它Gradle入口。** 不派生额外微任务。

## 1. 权威输入与历史边界

开工前fresh GET/核验：`docs/workflow/ACTIVE_STATE.md`、冻结计划`docs/versions/v10.1.5/plan.md`、本任务单、`TCP_OFFLINE_BUILD_READONLY_ROOTCAUSE_REPORT_20261027.md`及`TCP_OFFLINE_BUILD_ASTRA_REVIEW_20261027.md`、之前的`IMPLEMENTATION_REPORT.md`和`artifact_manifest.json`。

参考且须fresh复核的身份：
- live main `4df2e7f0f36cc7b80258faa73e80dad682cff6c5` / Root `03b0ecfcc360e38a462539dd50690c64b663a21e`。
- 零构建诊断文档候选 `7abea213feacc52a1e43c6ed58a40c83009c74df` / Parent `cfddecc944a043b1d85361a954a692be0dd4ce23` / Root `8a7775c97f3161f2f6f54d6499deba584349f307`；其唯一新增报告Blob `72975510872fbe3251caf1b8ddbd687761165d88`。
- 实际构建源码 `12d4e284feea609935eab12c973f5fd2efbc2992`；候选 apps Tree `cea01309fa9da5f99ccc9829654c6ec279c8c343` / services Tree `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。
- Astra只读诊断独立审阅Blob `6a7dc815eadd6950d793727b1d2679026411d5bf`；冻结plan Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`。
- v10.1.4已接受产品仍为apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。

以上是历史回读身份，不推定会话中本地文件/进程状态或live main未来恒定不变。

## 2. 已确认的程序事实（不要当作根因证据）

Astra GitHub直接静态核验 `apps/android/app/build.gradle.kts`：
- `tasks.named("preBuild") { dependsOn(syncFlutterAar) }`。
- 在v10.1.5 R1普通构建路径中，`syncFlutterAar`位于Flutter模块的 `.android`，调用经过Hash核验的本地Gradle 8.14，按 `-I=<Flutter SDK>/packages/flutter_tools/gradle/aar_init_script.gradle` 与 `-I=<项目>/apps/android/scripts/offline_debug.init.gradle` 加载init，执行内层 `assembleAarRelease --offline`。
- `offline_debug.init.gradle`当前仅在项目evaluated后遍历maven-publish publications并移除 `artifact.classifier == "javadoc"` 的publication artifact，**并未按任务名禁用 `javaDocReleaseGeneration` 或Dokka，亦不证明任务图边已移除**。
- `TCP_OFFLINE_BUILD_READONLY_ROOTCAUSE_REPORT_20261027.md` 报告旧Gradle stdout中存在`:connectivity_plus:javaDocReleaseGeneration`与Dokka进度；旧LOCAL_ONLY daemon记录涉及Flutter嵌套AAR与Dokka。两份daemon文件仅有本次只读分析中新算的Hash，没有前一候选的历史pin。

上面仅支持**Dokka执行过、artifact移除措施范围有限**；不能推断“Dokka导致那条TCP连接”，不能推断具体发包或下载。根因保持 `ROOT_CAUSE_NOT_PROVEN`。

## 3. 必须只读检查的来源

按现有Manifest/LOCAL_ONLY证据索引定位及Hash校验，禁止猜测绝对路径：
- 外层`apps/android/app/build.gradle.kts`，项目`apps/android/scripts/offline_debug.init.gradle`和既存`offline_debug.py`。
- 已安装Flutter SDK对应的实际 `packages/flutter_tools/gradle/aar_init_script.gradle`；对其计算本轮只读Hash，对照旧报告中 `b6b870954405c5d52afea183bb51b3220100c234401142d8c1bf3e2410cee2c2`，不一致则报告实际身份，不下载/替换。
- **只有文件已存在时**，从既有Flutter模块`.android`、`connectivity_plus`及其它相关插件的pub cache或原任务构建副本中，读取相关Gradle/Groovy/Kotlin脚本、Dokka插件声明、`maven-publish`/publication相关配置、发布/文档任务定义。它们可能是ignored生成文件而不在GitHub，不得凭空补内容。
- 仅复用前次LOCAL_ONLY固定Hash的 `ordinary-debug-run/stdout.txt`、`stderr.txt` 和必要的原daemon文件、`process-network-private.jsonl`，严格维持先前pin与新增Hash的证据等级。
- 可只读检查**已经存在**的Gradle解析缓存元数据、日志或任务关系输出；不得为了获得任务图而调用任何Gradle/Flutter命令或刷新缓存。

只保存派生摘要、文件Hash与脱敏路径。绝对路径、账号、设备标识、原始socket IP/端口、JWT/凭据、完整个人目录与原始日志始终LOCAL_ONLY。

## 4. 调查步骤：建立可审查的任务依赖图（静态，非运行）

A. 从外层`preBuild`追踪`syncFlutterAar`和Flutter `aar_init_script.gradle` 的task registration/task dependency/finalizedBy/publication逻辑，用源码文件/行号+Hash画出一条或多条候选路径。

B. 对`connectivity_plus`相关任务重点调查：
- `javaDocReleaseGeneration`实际由哪个插件和哪一版本注册，属 `dependsOn`、`finalizedBy`、publication artifact build dependency还是其它路径？
- `flutterAar`发布是否必须经 `publish`/POM，`javaDocReleaseGeneration`是否真正属于必要产物？
- 能否只读识别 `javaDocReleaseGeneration` 的外部文档链接解析配置？不能通过任务名字推断网络行为。
- 若缺少生成的task graph或插件来源，明确指出 `EDGE_NOT_PROVEN` / `TASK_ORIGIN_NOT_PROVEN`，不可编造Gradle内部依赖边。

C. 将静态链条与旧stdout的`:connectivity_plus:javaDocReleaseGeneration`、Dokka输出、Flutter AAR任务及daemon源码/插件行对应，但**不要使用没有共同时间基准的日志来精确对应TCP事件**。将“Dokka被运行”与“Dokka发起TCP”分成两个不同待证命题。

D. 形成最多两个**可选的最小补丁思路**，评估可能影响：runtime AAR、POM、Flutter插件依赖、Gradle task graph、缓存身份、重复构建安全策略。不要改代码/disable任务/排除依赖；需要Owner授权才能实施。特别不得通过跳过必要AAR/POM或关监控换取APK。

E. 输出明确的结论等级：`STATIC_DEPENDENCY_PATH_SUPPORTED`、`EDGE_NOT_PROVEN`、`DOC_TASK_EXECUTION_REUSED_LOG`、`DOKKA_TCP_CAUSALITY_NOT_PROVEN`、`ROOT_CAUSE_NOT_PROVEN`。若缺少Plugin DSL/插件Jar/生成目录或task graph，把缺口写清而非以行业通用规律补齐。

## 5. 保护与禁止门禁

- 零构建、零Gradle/Wrapper/Flutter/AAR/Kotlin运行，不调用`--dry-run`/`tasks`/`dependencies`/`help`/test；不启动网络观察器、ETW、抓包或管理员工具。
- 不启动Android、ADB、Docker、服务、RTC或生产；不运行Gate2、Writer、Serializer；不修改执行/网络/防火墙策略、环境变量或共享工具。
- 不修改任何产品源码、构建脚本、Dokka配置、pub cache、Gradle cache或旧任务树，不生成/删除现有输出，不清理历史refs、SQL、APK和7,941,328字节partial。
- 既有真实构建预算1/1已消耗，剩余0。旧claim/ledger必须保留，不能通过工作目录、命令或试运行重置授权。
- 无真实Push、生产服务、费用、产品main合并、v10.1.6启动。
- 不在公开报告中贴私人日志原文、具体IP/端口或私有路径。

## 6. 一次性交付与停止

交付**一份独立、脱敏且有据可查的静态诊断报告**，建议 `docs/versions/v10.1.5/AAR_DOKKA_STATIC_DEPENDENCY_REVIEW_20261027.md`，外加如有必要的极简Hash索引。无需改写旧`IMPLEMENTATION_REPORT.md`、Manifest、冻结plan或历史报告。报告至少包含：
- 实时main/Root、候选/Parent/Root、源头身份和源码Hash；
- 静态任务图候选链（节点/边、源码位置、证据类别和未证实之处）；
- `offline_debug.init.gradle`移除发布artifact的确切作用及局限；
- 既有日志支持的已执行任务与新增LOCAL_ONLY仅当前Hash的证据等级；
- Dokka/TCP因果关系是否仍为NOT_PROVEN；
- 最多两个最小后续方案及依赖Owner再次授权的工作；
- 零本地构建/Gradle/设备/Gate2/新观察器动作的回执边界；
- 保护文件、历史根和refs有界核验与LOCAL_ONLY原证保持；
- 不同证据等级区分 `ASTRA_DIRECT_GITHUB`、`CODEX_REPORTED_LOCAL_READ_ONLY`、`LOCAL_ONLY_RAW`。

在原连续候选基础上仅普通non-force发布文档候选，回读Commit/唯一Parent/Root、文件Blob/原字节与apps/services完整Tree，停止等待Astra集中独立验收。不得自行创建后继任务或声称构建/产品验收通过。

最终继续：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / SINGLE_REAL_BUILD_BUDGET_EXHAUSTED_1_OF_1 / GATE2_NOT_AUTHORIZED`。
