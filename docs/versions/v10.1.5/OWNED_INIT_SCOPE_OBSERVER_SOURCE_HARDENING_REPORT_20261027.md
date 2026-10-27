# EliteSync v10.1.5｜Owned init scope / observer 综合源码加固交付（2026-10-27）

**SOURCE_HARDENING_CANDIDATE_DELIVERED_FOR_ASTRA_REVIEW / SOURCE_LEVEL_ONLY / GRAPH_NOT_PROVEN / DOKKA_TASK_SELECTED_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED。**

本轮在ba77来源的新隔离工作树完成17个安全源码/测试/来源路径变更；最终140项选定静态/完全mock检查通过。没有实际Gradle/JVM配置、G/A/APK、设备、实时observer/socket或工具/依赖下载。当前新runner的main首步硬拒绝`NO_RUNTIME_AUTHORIZATION`；本交付不能恢复旧预算、证明真实Groovy对象行为或自动开始后继。

## 1. fresh权威、来源及独立源码身份

正式任务：`V10_1_5_OWNED_INIT_SCOPE_AND_OBSERVER_FAIL_CLOSED_SOURCE_HARDENING_TASK_20261027.md`，Blob `ddcc4e7e74b4e2aeaf1651aa20f51a0749c7f28a`，完整读取并按原字节回验。当前main ACTIVE_STATE Blob `51029081478ca2737c9b885c1e3122ac702183d6`；旧正文是历史时点，不能覆盖新授权。

| 对象 | fresh/本轮固定身份 |
|---|---|
| live main / Root | `b420db62bd6c86394333fad863bd15f2865f6fd7` / `5b50be9c0a17ce77f8759c1fd261bca08b4cb1cc` |
| main已接受v10.1.4 apps / services | `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac` |
| ba77基线Commit / 唯一Parent / Root | `ba77a3c840c36550a7ec3aa5a6475b69d874004f` / `fd0da9cce87c5eb84aec96dd11ea37aecd7aefff` / `8817729f4804d364e11c1ecb477e1e46a1cf9152` |
| 基线apps / services | `e6bff4bc8e359e6afe80c02f25212ee8b6195eab` / `21eebf69bbc6397b1562d40f8cd9ebd7b246720f` |
| ba77报告 / 索引Blob | `8c4947c5b4155ce495eae25b799b8c053a96ea94` / `5817f409b6d5a3cb5fa5540306135a201d9e396c` |
| Astra ba77复核 | Blob `7f864c7e17b81acccb24cf0655de6b3a911a66f9`，固定审查Commit `417c2c8d704996624afb70d0f703eb20f274c2f2` |
| **本轮实际源码Commit / 唯一Parent** | **`71ab58533270dd8b3a1270a3452a82b4f426e361` / `ba77a3c840c36550a7ec3aa5a6475b69d874004f`** |
| **源码Root / apps / services** | **`275cd2664444532c759d688ba4b262576ad065a4` / `5af7a9d0042be19437616e969e260658b67e9353` / `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`** |

Astra前置裁决仅`BA77_BOUNDED_READONLY_ROOTCAUSE_REVIEW_ACCEPTED_WITH_OBSERVATIONS`。本源码Commit与其后的报告追加Commit分开；最终文档候选只在本源码Commit上追加本报告和索引，不冒充新的源码/运行身份。ba77完整递归Tree6635项及main产品Tree已fresh GET，未截断。本轮不合main、不改APP业务、LiveKit vendor或后端。

## 2. A：严格根 / 可信tooling child合同

新`context_guard.gradle`作为来源可追溯的固定前缀嵌入owned init。根构建必须同时满足：

- 无parent；显式正确`-PelitesyncOwnedAarInit=v10.1.5-ordinary-r1-runtime`与项目根参数；执行init实际来源、两条显式init的路径/顺序严格匹配项目；根cwd精确为该项目模块`.android`。
- Gradle8.14、offline、唯`assembleAarRelease`根任务、`lib/main.dart`、`is-plugin=false`、普通R1两个精确base64 define、目标ABI及普通R1 buildNumber形状一致。ICE、retention、非R1或额外任务不因同一scope字符串获准。
- 路径必须绝对/规范/存在，拒绝符号链接、可识别reparse/other及real-path重定向；SDK原AAR init、LICENSE及tooling build/settings/loader三个文件Hash均匹配固定来源。

tooling child只能是**直接parent为上述已校验根**、没有更深parent链、currentDir精确为该固定SDK的`packages/flutter_tools/gradle`、相同init来源/次序、版本/offline一致的对象。child可不继承根-P，但其任何已存在的scope、项目根或runtime输入都不能冲突。只对这个精确对象在进入原AAR/Maven配置body之前return，避免给tooling工程施加应用发布修改；未知included/buildSrc、同名伪装、伪造脚本或错误SDK路径拒绝。没有全局删除guard、没有对空-P或所有附属工程放行，也没有更改系统Gradle属性。

**允许/拒绝矩阵（静态/政策model，非真实Gradle对象）：**

| 场景 | 源码合同/测试预期 |
|---|---|
| 显式scope且所有路径/输入/pin匹配的普通R1根 | 允许，继续原AAR body |
| 与该根直接关联且精确SDK tooling身份的child，own-P为空或一致 | 允许，仅tooling早退 |
| 根scope缺失/空/错误；child企图自带scope替代错误根 | 拒绝 |
| 同名gradle目录、独立SDK工程冒充根、未知included/buildSrc/深嵌套 | 拒绝 |
| scope/target/defines/项目根冲突；ICE/retention/非R1/额外任务 | 拒绝 |
| init来源/顺序错误、路径穿越/重定向、许可证/来源/patch缺失、SDK pin不符 | 拒绝 |

Python `authorize_context`明确标为**纯文件系统/政策镜像**，输入Gradle关系由mock声明；不执行Groovy，不证明真实Gradle parent、ScriptHandler属性或运行期对象可见性。`DefaultScriptHandler.getSourceFile`和Gradle parent机制只作定点静态来源支持，实际配置仍`RUNTIME_NOT_PROVEN`。因此不改变历史scope唯一根因的`NOT_PROVEN`。

## 3. 来源、字节、消费者和库存合同

原SDK init SHA256仍 `b6b870954405c5d52afea183bb51b3220100c234401142d8c1bf3e2410cee2c2`；BSD-3-Clause许可仍 `a3a9fd82f800a47377f7d3f60c60a5c91cae0495be8f329031e1448ce0f5dab9`。确定性推导保留原CRLF AAR body，仅原两处Javadoc请求继续移除，前置LF归属/上下文代码；sources、AAR变体、MavenPublication、POM、publish finalizer和插件AAR依赖原body保留。

| 新受控对象 | 精确SHA256 |
|---|---|
| owned init | `28c407c4fb95a7de690ff9a1455faf33bb62c28b365281dc6c2dfd20a61bb1a9` |
| context guard | `159a20ea2d7233b6e11d114cfa744a5edbdb9c230ffbf938d26fc231af380604` |
| SOURCE.json | `ff4d82097e80239fb9d9861a68731573079d4120a2026aeddc5d4615c456942f` |
| UPSTREAM.patch | `80966f8ea92f72137473911531882dd6394cc72da9ceaf0b697cedd7e5a0f240` |

`SOURCE.json`升级schema2，记录前一受控init Hash、严格上下文政策与tooling pins；`UPSTREAM.patch`完整反映衍生。三份很小的tooling源码fixture是现有已pin SDK的原始字节，许可证沿用同目录原件，**只用于测试，不是替换SDK**。局部`.gitattributes`保留原始/衍生/fixture字节，已核验staged Git bytes未改变这些硬pin。

Kotlin消费者同步新init/SOURCE/patch/guard及tooling文件pin，普通R1命令新增`-PelitesyncOwnedAarProjectRoot=<PROJECT_ROOT>`；新runner审阅副本参数同步，非普通R1的SDK init选择和ICE/retention targets保留。`ownedAarInitContract`为schema2、包含guard及tooling pins，7项必需项目输入在inventory与definitions均须精确Hash。旧schema1/旧输入库存不能授权新源，缺文件或Hash不符无共享SDK fallback。

本轮仅验证该**源合同和小型fixture**，没有建立或声称已经验证新的完整工具/缓存构建库存。100453项旧库存没有重新扫描或被更名复用。未来实际Gradle之前仍需独立的新输入库存和新运行授权。

## 4. B：失败前诊断与强停

Observer的native绑定推迟至真实构造，导入模块不再导入ctypes。当前测试注入纯Python API/type适配器；没有加载Windows DLL或读取实时进程/socket。

- OpenProcess/QueryFullProcessImageNameW/GetProcessTimes失败后，在后续clock/API/CloseHandle前立即捕获`use_last_error=True`对应的ctypes错误；不可可靠取得时写`API_ERROR_UNKNOWN`，不编造数值。Query失败后仍尽力取可取得的创建时间，保留最初错误。
- 分开snapshotSeen、imagePathQueried、API failure stage/error、query时点与snapshot时点、PID/父链、根身份及可取得的child创建时间；直接image_path查询不虚称有快照。失败时保留有界映像名、path片段/完整path Hash与长度，仅进入LOCAL_ONLY事件。创建时间未知/变化、根实例变化、可疑PID复用均继续强停；初始采样父链不冒充完整归属证明。
- 故障诊断payload限制16KiB（写出另含有界Hash封装），诊断sink验证必要字段、写入长度、Hash与flush；失败帧先于抛错尽力写出。写入失败、短写、字段缺失或大小超限均停止，不退为成功样本。当前不会补回旧G不存在的失败帧/API错误码。
- 新runner构造前必须显式注入callable诊断sink，先于任何ctypes导入和首次sample；Job kill-on-close、停止后等空、失败句柄保留、先claim后Popen、零样本拒绝及A的完整G/同输入门禁保留供源码审阅。非loopback TCP、下载、未知工具、观察器故障和输入漂移仍强停。UDP仍只是目的地未知endpoint，不能证明发包或绝对离线。
- 原G runner/测试/claim/ledger完全未改。新`controlled_runner_hardened.py`是安全可审阅衍生源，main及历史参考入口第一步硬拒绝`NO_RUNTIME_AUTHORIZATION`，当前没有可自动启动的G/A入口。未来采用这些机制仍需具名的新授权/新预算，不能把旧TASK常量或新目录当作额度。

非作者静态复核发现“首次sample无持久sink”及“CloseHandle失败提前清空Job句柄”两项，已在本轮修正并补mock回归；最终未发现剩余可证实静态阻断。审阅者没有运行代码/测试/Gradle/DLL/设备，结论不替代Astra独立验收。

## 5. RED/GREEN、执行主体与NOT_RUN

最终命令为本地Python `-X utf8 -B verify_final_tests.py`，执行主体Codex；审计hook禁止受审process/socket/ctypes DLL及其它受审工程启动。fixture在任务拥有临时目录；不复跑产品全库。

| 选定模块 | 最终项数 | 主体与证据等级 |
|---|---:|---|
| test_owned_aar_init | 37 | 字节/来源/path/静态消费检查，SDK fixture非Gradle |
| test_owned_aar_context | 23 | 政策model正反例+文本合同，非真实Groovy |
| test_offline_debug | 44 | 静态与完全mock生命周期/网络分类 |
| test_windows_build_observer | 15 | 完全mock WinAPI/错误时序/身份/诊断 |
| test_controlled_runner_hardened | 21 | 完全mock sink/预算/Job/强停/无重试 |
| **合计** | **140** | **exit0、失败0、error0、skip0；最终受禁API审计事件0** |

最终stdout SHA256 `227e9539add9179041e4b533a2e0993491a9980228d3116cf55323eae7cd522c`，stderr `28dc8821bccf703bcdeae22ede7baf7d6456ccbc6f17bc278f0de75a718dac9b`；实际tests和源Hash见索引。Python AST及staged diff检查通过；Kotlin/Groovy未编译/配置。

**原始失败保留，不把“最终0事件”冒充全轮从无尝试：** 初始scope合同3项RED exit1；scope根任务约束和直接image查询标志也先RED后改。B初始RED及中间GREEN1/GREEN2退出1、非作者修正RED和映像身份字段RED都保留。最早Windows ctypes导入触发kernel32的`ctypes.dlopen`请求，被审计hook在该请求执行前拒绝并使测试失败；随后改为完整lazy native和mock适配，最终审计为0。未顺着失败去放行真实DLL或真实运行。一次outbox辅助patch定位失败亦保留在工具记录，不归为Gradle或缓存故障。

各轮完整stdout/stderr、退出记录、工作源与中间证据留在LOCAL_ONLY，公开仅标签/字节/Hash。fixture/静态测试不能证明真实操作系统句柄释放、API错误返回、Groovy对象关系、选中任务图、Dokka行为或AAR/POM产物。

继续`GRAPH_NOT_PROVEN / DOKKA_TASK_SELECTED_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / OBSERVER_FAILING_INSTANCE_NOT_PROVEN / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN`。缓存损坏及工具链版本冲突仍`NOT_PROVEN`；没有升级、下载、删除或卸载理由在本轮被执行。

## 6. 源码变更、保护、容量和停止

以下均为源码Commit `71ab58533270dd8b3a1270a3452a82b4f426e361` 中的规范Git字节，工作副本Hash另列索引。其后的文档追加Commit不改变完整apps/services Tree。

| 授权变更路径 | mode | Git Blob | Git内容SHA256 |
|---|---|---|---|
| `apps/android/app/build.gradle.kts` | 100644 | `ec58832c88aa41d8ce005c9fe8b036ccf5bf3c3c` | `a23e9002d04dd182b6e99456bd369bb943063aec3361ad1804fd34dc63a5680f` |
| `apps/android/scripts/controlled_runner_hardened.py` | 100644 | `0d8da8a44268c12e7593b13aa8c5b41337a3f2df` | `7cc0a4ab2291b79b73326b72abab6cf0158ed00081c97223294c55d0af26cffb` |
| `apps/android/scripts/owned_aar_init.py` | 100644 | `c2b59d849a1388f88d889973c66e03c2a6e07c00` | `742de359859622bdbddebb5abb3edb6b6bf578cff03ecb890d485df5e33336d1` |
| `apps/android/scripts/owned_flutter_aar_init/.gitattributes` | 100644 | `586a92c15b368b698e17af617f6e01eb54516406` | `fb351120d33219a16da303ab68f8f4ac78a64fb14a0ca63d022085bdf5baf55c` |
| `apps/android/scripts/owned_flutter_aar_init/SOURCE.json` | 100644 | `6ccd167b2408ac406c723cae4394b528d59707ee` | `ff4d82097e80239fb9d9861a68731573079d4120a2026aeddc5d4615c456942f` |
| `apps/android/scripts/owned_flutter_aar_init/UPSTREAM.patch` | 100644 | `2a19fc61745ab35cdf527d026973bc4ac50cb220` | `80966f8ea92f72137473911531882dd6394cc72da9ceaf0b697cedd7e5a0f240` |
| `apps/android/scripts/owned_flutter_aar_init/aar_runtime.init.gradle` | 100644 | `42e7d45840559fa0444f305d23203b78e7658787` | `28c407c4fb95a7de690ff9a1455faf33bb62c28b365281dc6c2dfd20a61bb1a9` |
| `apps/android/scripts/owned_flutter_aar_init/context_guard.gradle` | 100644 | `65835140b9b6fb1f824ab47537848bf6bec64b01` | `159a20ea2d7233b6e11d114cfa744a5edbdb9c230ffbf938d26fc231af380604` |
| `apps/android/scripts/owned_flutter_aar_init/tooling_fixtures/README.md` | 100644 | `62ecdbea91e4ce7043a0422c6bf030c7ed2c2be7` | `2f3dd1ac078b0b6962cfbceef8be29240b460ee883903ad8bd0cb61b0017fede` |
| `apps/android/scripts/owned_flutter_aar_init/tooling_fixtures/build.gradle.kts` | 100644 | `cd869002163ac72761e4f54f1bbc152f9de8fbcb` | `8d83640366f1f78c9db70f771d0c6e4a9c0d9e4858aa6eee30891e86fed323b1` |
| `apps/android/scripts/owned_flutter_aar_init/tooling_fixtures/settings.gradle.kts` | 100644 | `4a18f6886531b85c58531124fb49043df068e798` | `106ea06cbc2bf28234443b8a74e7ec4e32a817b4d279d122a650c073daad4d37` |
| `apps/android/scripts/owned_flutter_aar_init/tooling_fixtures/src/main/kotlin/FlutterAppPluginLoaderPlugin.kt` | 100644 | `463770e272a570f70d204e3a71dea66dc68ef579` | `8f0cff54afa2bc47a463f8bdec32ee2163c365d980e8f461a8941f02ace96be1` |
| `apps/android/scripts/test_controlled_runner_hardened.py` | 100644 | `c1e79efaed9b1d148c3fbfda0c080d5a59e6c31c` | `085abfeb77687f6a8c5c3d32411ec0c5bb76e090443a287a620a70338fb8d42a` |
| `apps/android/scripts/test_owned_aar_context.py` | 100644 | `877a70c831d81227d942308594a5243910c63af9` | `741b5b14032aaefa0bc5340126b3add7be6df9a59258cb9a40b5a653e4296ab1` |
| `apps/android/scripts/test_owned_aar_init.py` | 100644 | `21296268bc77adb3866e7eb586b52d1523789a43` | `1e37eada136c65d92b612b8b63315846c8dba3112711b0ecac2d93de4ef9238a` |
| `apps/android/scripts/test_windows_build_observer.py` | 100644 | `0d2f40af021a3116940b5296d40c1c4d638e7473` | `5b17a98326c01e34e08b468aa06ea4b75abc133b896d95f773eac404b2e43cc4` |
| `apps/android/scripts/windows_build_observer.py` | 100644 | `e3be0bc3ce7189faf0bc58ec12782a913c7efe06` | `f81b91215d35ea388fc9b4d996c6b6637d1857990c2a72e42f49d522dd08b1b3` |

本轮新工作树文件约138.94MiB，outbox在写交付前约0.47MiB，合计低于512MiB任务cap。这里只统计新拥有目录文件大小，不是磁盘物理allocated bytes或共享Git object store总量；没有复制巨大SDK/cache。SQL/APK、私密路径、PID/IP/socket和旧原证保持LOCAL_ONLY。

定向首尾核验54个去重关键原件/脚本/局部SDK/选定SQL/APK指纹一致，5个历史根元数据一致；525个原refs不变，只新增本任务独立候选ref。没有把原26784份/108份/100453项说成本轮再次全量核验。原7,941,328字节partial SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`、旧APK claim `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、G claim `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`不变，A claim不存在。

预算保持：**OLD_APP_APK=EXHAUSTED_1_OF_1 / G=EXHAUSTED_1_OF_1 / A=0_OF_1_GATE_CLOSED / GATE2_NOT_AUTHORIZED**。没有新Gradle/JVM/Flutter/AAR/APK/ADB/RTC/实时observer/网络实验、DB/生产、Writer/Serializer、工具下载/升级、缓存删除或系统安全配置改变。合法Git authority/候选传输和Python宿主测试是本任务允许动作，不等于依赖下载或工程运行。

本轮raw为`LOCAL_ONLY_RAW`，源码与派生结果为`CODEX_REPORTED_LOCAL_EXECUTION / STATIC_MECHANISM_SUPPORTED`，前置Astra记录为`ASTRA_DIRECT_GITHUB_STATIC`；静态支持不提升成实际运行。继续**V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED**；AEC、最后可闻波形、native handle、真实15/30天/物理清理及Push等开放项不关闭。

普通非force候选发布后回读最终Commit/唯一Parent/Root、全部17源Blob及两新增文档原字节、完整apps/services Tree和main接受树。完成后STOP等待Astra独立验收；不自行接受、不启动后继修复/Gradle、不合main、不清理历史。
