# EliteSync v10.1.5｜G2 Cache / SDK 写入隔离闭合报告（2026-10-27）

**WRITE_ISOLATION_STILL_BLOCKED / G2_INVENTORY_CLOSURE_BLOCKED / RUNTIME_NOT_PROVEN / ZERO_RUNTIME_AUTHORIZATION。**

本轮交付18族读源/写面矩阵、107份具名状态文件分类、局部独立物理副本、源级路径政策与56项完全mock检查。已静态支持“私有Gradle user-home＋独立tooling根＋选定plugin副本”的局部路由；完整依赖seed、完整SDK读集、Android SDK与隐式写入、全轮物理磁盘增量尚未闭合，不能将局部结果升级为G2运行资格。

**真实Gradle/JVM/Flutter/AGP/Kotlin/Dart、observer/Job/socket、AAR/POM、APK、设备/RTC、Gate2均0。未创建或修改G2.claim。** 没有改6ca产品源码、共享SDK/cache、系统策略或历史原证。

## 1. Fresh权威与来源身份

唯一正式任务Blob **b6519b415d827232a9dd5f9760b322ec1a7fdaaf**，全文与GitHub原字节已读取、回验。Owner本会话手动派发生效，ACTIVE_STATE中的“等待派发”是派发前时点。原G2合同Blob **796c9ad2d5d91b3d375cea6c079e9e6121e0be4c**保持冻结；本任务预算为0，不消耗其条件性额度。

| 对象 | 本轮fresh身份 |
|---|---|
| live main Commit / Root | `fdf7812d07006503b81a88020e4d7f03a6b33743` / `4a4ca4a1328f97baa3b21510aefd7e8a4a73e456` |
| main接受产品 apps / services | `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac` |
| 286动态分支HEAD / 唯一Parent | `286eb20d1d6af2e76423cfbd3253880f47c9ae16` / `6ca09a66c0ef9619df7a3d7d4b089516f409954f` |
| 286 Root / apps / services | `4177d75aec1eae6f33cd28ec45c88dce8496274a` / `5af7a9d0042be19437616e969e260658b67e9353` / `21eebf69bbc6397b1562d40f8cd9ebd7b246720f` |
| 286报告 / 索引Blob | `f4c80b4bbab70485188a31daf2e36d75d0f7c7ba` / `8850d02049255c6e566e2ae5e90a6eb66eb95515` |
| Astra 286验收 / 动态审查分支HEAD | `ce7250d9e4cfe42bd62c4607632eb84ac53bae5b` / `3fdf635ca73fdc911027761bb3888aa31b043155` |
| 6ca Commit / 唯一Parent / Root | `6ca09a66c0ef9619df7a3d7d4b089516f409954f` / `71ab58533270dd8b3a1270a3452a82b4f426e361` / `3bf735ab1c8e394844db80be35d86d2250390c82` |

Astra对286的裁决 **G2_PRECHECK_BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS** 只接受诚实的预检停止，不接受库存闭合。6ca仍仅SOURCE_LEVEL_ONLY。完整main/286递归Root分别6230/6652项且未截断；17项固定源码规范Blob与源码身份相符。原冻结plan及既有报告不改写。

本轮仅使用一个新任务LOCAL_ONLY目录，未新增完整Git工作树或切换旧工作树分支。普通候选从286新增本报告、索引和两个纯静态政策/mock源；完整apps/services维持不变。Windows checkout工作字节与规范Git Blob分别记录，未混称。

## 2. 107份既有状态的分类

本轮定点fresh读取并Hash，保留原路径/Hash/大小于LOCAL_ONLY；不重标旧库存，不删文件，不加载class或JAR。

| 状态 | 数量 | 分类与静态依据 | 本轮处理 |
|---|---:|---|---|
| `caches/8.14/fileHashes/fileHashes.bin` | 1 | VARIABLE_RUNTIME_STATE；Gradle CrossBuildFileHashCache/VirtualFileSystemServices构造可写索引 | 旧pin漂移事实保留，未来私有home生成；不当作immutable继承 |
| `caches/journal-1/file-access.bin` | 1 | VARIABLE_RUNTIME_STATE；DefaultFileAccessTimeJournal创建journal-1/file-access并put/remove | 保留旧值与Hash，未来新journal |
| `caches/8.14/groovy-dsl`额外class/metadata | 64 | DERIVED_GENERATED_STATE_NOT_INHERITED；路径/内容名支持编译衍生角色 | 不把class反推为可信源或复制来规避scope |
| `caches/jars-9`额外class/receipt | 39 | 同上；包括settings/init衍生项 | 单独列Hash，不赋予不可变依赖身份 |
| Flutter tooling `.gradle/buildOutputCleanup` lock/cache.properties | 2 | VARIABLE_RUNTIME_STATE；ExecutionBuildServices以build-scoped factory创建buildOutputCleanup cache | 新tooling副本中的该目录为空私有写面，不继承旧锁 |

两份mutable文件变化、103份额外生成项及两份cleanup文件，**不证明缓存损坏、下载、版本冲突、恶意写入或特定进程/时间**。角色分类有源级支持，精确写入主体/历史因果仍NOT_PROVEN。不能把旧运行状态“更新Hash”后称原库存未漂移；未知缓存类别在政策model中拒绝。

旧96736项fresh哈希、272个package与74个平台plugin引用及2465份历史module复制仅按286原证复用，未声称本轮再次全量重算。此次新增核验集中于具名107项、固定工具来源和实际复制的输入。

## 3. Gradle 8.14本地源码/文档结论

本机已有完整8.14 distribution的全部314份已pin bin/lib/init输入，与原固定运行distribution逐文件Hash一致；据此定位该distribution中的本地src/docs并记录22份具名源码/文档Hash。**这是本地同distribution来源锚点，未新增验证上游签名或下载源码。** 所有源码/文档只读，不运行版本、查询、编译或dry-run命令。

源码索引S1～S22在证据索引中列相对路径、字节数和SHA256：

- **S11 `dependency_caching.html:5811–5856`，S8 `DefaultArtifactCaches.java:56–97`、S9只读coordinator：** `GRADLE_RO_DEP_CACHE`是包含`modules-2`的父目录，仅为依赖metadata/artifact的只读查找层；miss进入私有可写层，离线缺依赖必须失败。文档要求先复制seed、以只读权限提供，明确不应把已有活动安装cache直接当seed。它不隔离Groovy/Kotlin脚本编译、transforms、journal、daemon/native或项目缓存。
- **S8：** seed目录不存在或缺`modules-2`时，Gradle原生实现是warning并停用该层，随后仍有可写fallback。因而本政策model额外拒绝无效layout、读写重叠、直接历史活动cache、依赖闭合未知或只读保护未知；不能把原生软回退当作安全通过。文档图中的变量名不作为写入distribution的许可；可写层由源码的cache-builder根决定。
- **S1 `StartParameter.java:220–273`、S2 `BuildDefinition.java:135–141`、S3 `BuildScopeCacheDir.java:33–47`：** `newInstance()`复制projectCacheDir，`newBuild()`不复制；当前included-build构造走`newBuild()`，另拷init等参数。因此根`--project-cache-dir`不能自动覆盖tooling included build。未显式projectCacheDir时，通常回到**各自根目录的.gradle**；undefined-build有用户home例外。S22确认StartParameterInternal仍委托super的prepareNewBuild，未补回projectCacheDir。对未追完的buildSrc/其它动态构建仍UNKNOWN，不以“所有child都会继承”放行。
- **S6 `ExecutionBuildServices.java:121–128`：** cleanup cache来自build-scoped factory，故仅改Gradle user-home不足以迁走tooling的cleanup锁/状态。
- **S15 `module_plugin_loader.gradle:17–33`：** plugin projectDir来自真实插件路径，普通module loader将其buildDirectory移到module私有`plugins_build_output`，配置时可能mkdir。该重定向不证明每个plugin都不会自行写projectDir或其它目录。
- **S16 `FlutterPlugin.kt:71–81,284`、S17 `FlutterPluginUtils.kt:592–625`：** config读取engine stamp/realm并调用forceNdkDownload布置native build/CMake staging。它不证明本次会下载，也不证明已有NDK令SDK写入绝对不可能；`--offline`与JDK autodownload关闭不能替代Android SDK manager写入分析。

## 4. 读源/写面矩阵及最小方案

下表是完整18族摘要；索引对每行还给出逻辑作用、来源pin/原报告锚点、私有写根、估计大小、检测方式、回滚保留和缺失验证。真实路径仅LOCAL_ONLY。所有“私有”表示本轮物理骨架/计划路由，**不表示插件已被OS强制限制**。

| 族 | 读源/证据级别 | 计划私有写面 | 尚未闭合 |
|---|---|---|---|
| Gradle distribution | 固定8.14，314份Hash | 不可写；直接二进制 | 不允许Wrapper/global-init注入 |
| dependency seed | modules-2限定只读能力，PROVEN_STATIC | 独立readonly-seed | 完整seed超cap；精简闭合/只读enforcement未知 |
| writable dependency cache | second-level，PROVEN_STATIC | home/caches/modules-2 | offline缺依赖不能下载补齐 |
| fileHashes/checksums/journal | 可变索引，PROVEN_STATIC | 私有home/caches | 不继承旧mutable pin |
| Groovy/jars/Kotlin DSL/transforms | 衍生编译态，局部静态 | 私有home/caches | 未枚举的新输出拒绝 |
| daemon/native/locks | REASONABLE_RISK | home、tmp、profile | no-daemon仍可能single-use daemon；默认写入未知 |
| root project cache | PROVEN_STATIC | module/.android/.gradle | 显式project-cache仅根构建 |
| tooling included .gradle/cleanup | PROVEN_STATIC默认路径 | 物理私有tooling根/.gradle | 没有额外共享目录redirect |
| tooling build/Kotlin输出 | REASONABLE_RISK | 私有tooling根/build | 编译器自定义路径未知 |
| module settings/build/.cxx/Maven | 局部PROVEN_STATIC | 私有module与output-dir | 完整runtime source未物化 |
| native plugin输入 | 14个选定包独立副本 | plugins/各自目录 | 不等于74个平台全部输入 |
| native plugin输出 | loader局部PROVEN_STATIC | module/plugins_build_output | plugin自定义projectDir/外部写入未知 |
| Flutter SDK | tooling/license/stamps已pin | 私有Flutter外形骨架 | 完整bin/artifact/Dart读集未证 |
| Android SDK | 现有只读候选 | UNRESOLVED | manager/NDK/metadata写入未关闭 |
| JDK | 固定17读取候选 | profile、tmp | 实际user.home/java.io.tmpdir未采样 |
| Pub | 历史源+选定plugin副本 | pub-writable | 全部package URI和潜在工具写入未闭合 |
| 环境profile/temp/Android user | REASONABLE_RISK | profile、tmp、android-user | 默认fallback/第三方工具实际环境未知 |
| 未知输出/链接/身份 | UNKNOWN_REJECT | DENY | 未实现OS写拦截/竞态证明 |

**已构造的局部方案：**

1. 新私有Gradle home为空骨架，不复制旧journal、scripts、daemon、native、transforms或103份衍生状态；readonly-seed/modules-2也只是**空占位，不是可用完整cache**。
2. 复制已seal的Flutter tooling源子树、LICENSE和两份engine stamp；tooling内新建空`.gradle`及build目录。默认included-build写面因此落在新的物理根中，而非借根project-cache选项掩盖共享SDK写入。
3. 14个实际native plugin包按具名旧库存作独立文件复制，避免用硬链接/目录重定向复用可写源码。LiveKit vendor的历史source tree与6ca canonical Tree相等后才作显式映射，不对任意未知plugin放行。
4. 仅复制少量module生成模板及七项owned输入和offline init；schema2七项definitions/inventory与新私有项目/SDK副本再次匹配。owned init/guard/source/license/patch/tooling pins通过，未修改守卫。
5. **1098对源/目标Hash一致，目标link count=1，源/目标volume/file identity不同**；目录祖先lstat未见symlink/reparse。它证明检查时副本独立，不能证明未来路径竞争、mount/drive alias或运行时不会越界。原源始终只读访问。

将来命令提案保留两个固定init、ordinary R1、单assembleAarRelease、offline/dry-run及旧monitor强停合同；只是将project/Flutter/home改为新骨架，并明确列出新增root-project-cache与Java user.home提案差异。命令与环境提案Hash已记录，但模块源码不完整，buildNumber尚未按完整新源重算、seed为空、环境不完整，**不可执行**。本轮没有launcher/Popen入口，未变更正式runner的NO_RUNTIME_AUTHORIZATION。

## 5. 容量、失败与不能闭合的路径

| 测量/方案 | 结果与限制 |
|---|---|
| 现有modules-2完整sealed集合 | 3183份，本轮stat大小合计 **1,362,106,905 bytes**，高于536,870,912；未重新全Hash或复制 |
| tooling源子树 | 旧sealed逻辑量364,731 bytes，实际副本逐Hash核验 |
| 新骨架最终逻辑文件长度 | **8,277,854 bytes**，1098份具名独立副本；0全SDK/0全Gradle-cache复制 |
| 物理磁盘观察 | 恢复准备阶段卷free-space下降 **11,603,968 bytes**，包括并发宿主活动，不等于独占文件allocated bytes |
| 首轮部分准备 | 5,200,449逻辑bytes；首轮失败前free-space值未持久化，**全轮精确物理增量NOT_PROVEN** |
| cap裁决 | 已知逻辑量很小，但不伪称已证明全轮allocated增量；完整seed方案为BLOCKED_DISK_OR_ISOLATION |

一次普通准备失败：初版脚本遗漏“LiveKit metadata指向286工作面、库存副本位于历史project根”的映射，抛StopIteration、exit1；部分任务自有副本保留。保留v1源、stdout/stderr和退出码后，限定为该vendor的canonical Tree相等证明，再恢复同一骨架，只验证已有文件Hash/独立身份，不覆盖历史输入，不另建预算。v2准备exit0、骨架独立审计exit0。该失败不是Gradle错误或缓存损坏，也没有触发真实运行。另一次脱敏启发式因把布尔字段名targetFileIdsIndependent误当成file-id实值而退出1，工具原记录和LOCAL_ONLY说明保留；改为匹配精确敏感键后复核，不把它写成真实泄露或Gradle失败。

关键未解决集合：

- 完整modules-2独立seed超cap；小于cap的精简subset尚无完整依赖/metadata/variant选择证明。不能只复制看似需要的JAR后宣布闭合，也不以空seed试跑。
- 独立seed的OS只读保护未建立；原生活动cache不直接作为只读层，不使用硬链接或目录alias规避复制容量。
- 最小tooling/stamps覆盖了已识别读取，**没有证明完整G2配置只读取这些SDK输入**；不能据此断言一定缺哪个依赖，也不能声称完整Flutter/Dart读集就绪。
- Android SDK manager/NDK/metadata及第三方plugin/编译器的隐式输出、系统profile fallback仍UNKNOWN；源码路由不是实际写入防护。
- 全轮allocated磁盘增量、运行时文件身份/竞态安全、写入enforcement未证。

可核验备选仅作为建议：从现有缓存metadata和具名依赖版本建立可独立审阅、≤cap的closed seed；若不能，则由Owner后续具名决定容量及独立只读快照范围。对SDK/Android/plugin需证明必要配置读集及私有写路由，不能以全复制或共享写入替代。**本轮不实施这些未授权扩大方案，不发布后继任务，不申请/执行真实G2。**

## 6. 静态/mock检查与证据边界

最终 **56项、exit0、0失败/0错误/0 skip、受审process/socket/DLL审计事件0**。测试为纯Python声明的Windows路径/FileFact/路由政策：symlink、junction、未知reparse、hardlink count/保护file-id alias、路径穿越、UNC/device/ADS、大小写/盘符/前缀混淆、未知输出、共享SDK/home回写、环境fallback/冲突、无效RO layout/seed、mutable pin继承、cap及无dry-run等负例均拒绝。没有创建真实链接或启动真实进程来测试它们。

公开两个源文件只含政策model和mock测试；task token相等检查**不是Owner、分支或进程认证**。环境/命令函数比较的是调用方提供的声明值，不是实际子进程采样或已认证的Gradle launcher绑定。FileFact链接/identity事实也由mock输入；漏报或竞态无法由纯函数发现。global_readiness始终readyForPopen=false、runtimeAuthorization=ZERO_THIS_TASK。

只读非作者辅助核对了Gradle来源链与政策代码，未执行测试/Gradle/native。Flutter辅助没有重新检查共享实物，其继承摘要不作为本轮新证据；相关Flutter文件由主执行者具名读取并Hash。复核不是Astra独立接受。前两轮50项mock属于中间结果；最终新增RO-seed负例后56项才绑定本交付，旧stdout/exit保留。未重跑历史140/96736等不相关集合。

## 7. 保护、预算与集中交付

具名首尾核验：79份关键原证/固定源码，另107状态文件、22份本地源码/文档和1098对实际副本；五根HEAD/branch/index/status与527个**本地既有refs**不变。源286工作树HEAD仍286且干净。本轮不新增完整checkout，不以这些定点核验冒称26784/108/100453全量重算。公开仅安全报告、最小索引与两个政策/mock源；本机路径、file id、私密日志、SQL/APK等LOCAL_ONLY。

旧partial仍 **7,941,328 bytes / b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4**；旧APK claim **07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8**、旧G claim **0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316**不变。旧APK/G均1/1耗尽，旧A门禁关闭；原G2仍0/1、claim不存在，本轮授权使用0。没有改写其ledger或创建claim。

证据分级：远端对象/原字节为DIRECT_GITHUB_READBACK；本地Hash/副本/执行回执为CODEX_REPORTED_LOCAL_EXECUTION、LOCAL_ONLY_RAW；前置Astra记录为ASTRA_DIRECT_GITHUB_STATIC。此候选未接受产品，不自授WRITE_ISOLATION_STATIC_CONTRACT_DELIVERED全局成功、INVENTORY_RUNTIME_CLOSURE_VERIFIED或G2_READY_FOR_POPEN。

候选唯一Parent固定286，完整apps/services与286/6ca一致；最终Commit/Root、四份新增Blob/原字节、完整产品Tree及fresh main产品树的发布后回读保存于本轮final-readback。报告自身不填自引用最终Commit/Blob。

继续 **V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / GRAPH_NOT_PROVEN / DOKKA_TASK_SELECTED_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED**；AEC、最后可闻波形/native handle、真实15/30天和物理清理不关闭。

**交付回读后STOP，等待Astra独立验收。不自动恢复G2，不启动A/APK/Gate2、后继任务或v10.1.6，不合main、不清理历史。**
