# EliteSync v10.1.5｜scope / observer 定点只读根因报告（2026-10-27）

**BOUNDED_ROOTCAUSE_EVIDENCE_DELIVERED / ZERO_GRADLE / ZERO_PRODUCT_REPAIR。**

最强静态解释是：Gradle included/plugin build继承同一组init scripts，而该构造路径不复制根构建的`projectProperties`，项目自有init首部却在每个上下文严格读取该map。原G没有保存被拒绝Gradle对象/属性值，所以**机制可证，实际唯一根因仍NOT_PROVEN**。Observer的准确抛错分支可定位；失败进程实例和底层API错误码未落盘，不能认定退出竞态、PID复用或权限拒绝。没有具名缓存损坏或工具链版本冲突证据。

本任务只读既有文件/Hash/简单静态解析；Gradle、JVM、Flutter、受审工程测试、进程模拟、实时observer、设备/ADB/RTC、下载、更新/卸载、缓存删除、产品源码修复全部0。本地Python仅运行outbox只读分析助手，没有导入或运行受审runner/observer。

## 1. fresh权威与固定身份

| 对象 | 本轮fresh读取 |
|---|---|
| 正式任务Blob | `71d11e24c4d5b16d6d662f2684fc665750a7c154` |
| live main / Root | `82c19cf6a52618dff935263d296696afffec466e` / `693326ace9f9334024c331a560ac6eea30eec2c0` |
| main ACTIVE_STATE Blob | `51b1b533cb9164e08d1a99bc28bc1d848a1ed6a3`，2026-10-27前置状态覆盖后附旧时点正文 |
| fd0 Commit / 唯一Parent / Root | `fd0da9cce87c5eb84aec96dd11ea37aecd7aefff` / `da5ce628a499c97e916e780e2cf795353745c147` / `b1f6fd9de8083f017e342fe82149874a66ff815a` |
| fd0 apps / services | `e6bff4bc8e359e6afe80c02f25212ee8b6195eab` / `21eebf69bbc6397b1562d40f8cd9ebd7b246720f` |
| 实际方案一源码Commit | `50d79396195ed8b4b86c218584ab59864ad600be` |
| 已接受产品v10.1.4 apps / services | `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac` |
| fd0报告 / 索引Blob | `e6f0a1f96b5d52993dfce5f31ad9456ba4d06e80` / `38b20500d0e42218976a9f675607b7a5b259a7b1` |
| Astra fd0复核 | Blob `31c711e29bb32dad1e6d30c82dd08cd0b3526c32`，固定审查Commit `bcd20e9bf30aba97f7e35ac7278fe8bdc1c95028` |
| 完整交接 / 交接状态Blob | `079f4c22a3d2080af676cd630b445d6a627e877d` / `dba1b6c2cd3b85887cbcd296fb9f65b3869a1b5f`；交接分支HEAD `b945d2f6c4f9490a0295a2a81d14cadffb2fdfeb` |
| 冻结plan / 原G-A任务Blob | `7d3466b3be67135dc641cfee7c7faef78937ba03` / `129efb748bb5a22921e756f2f829a627ceae6880` |

Astra只接受`FD0DA9CC_BOUNDED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`，不是发布图或产品接受。交接写于该复核之前，其“待验收”时态不能覆盖后来的正式裁决。main的新维护方向也不能转为本任务立即下载/更新许可。8份远端原件经base64原字节读取并重算Git Blob与SHA256；main/fd0完整递归Tree均未截断。连续本地源码树仍在原方案一候选，未切换/reset；本报告候选只追加两份脱敏文档，以fd0为唯一Parent，保留其完整产品树。

## 2. 证据分级和读取范围

- **PROVEN / CODEX_REPORTED_LOCAL_ONLY**：13份具名G原证逐一匹配fd0公开索引的字节数/Hash；另读取交付后本地final-readback，仅作其自身后置回执，未虚构它已在旧索引中。scope命令的两个原始副本相同，compact JSON命令Hash `9227a175845025bf0a74d33875af39df6d23d2467dbeb18b2d083fb3ef10a02d` 与G.result一致；claim原字节Hash也与G.result绑定一致。
- **PROVEN / 静态源码事实**：实际runner `ce765a33fbae04fa0febee69ce8005dbbaec65d7a47d33f430d5c795e8861985`；实际observer `2e146c48dbf6d90aee0e0a36a54188d14cc8db39deea845fde40523ccea13a72`；settings `58ed6cf1a5ff74237dba2c0dbbd19669aeeea145c2f442462b04c20541a8f609`；owned init `364295d4d861d81ca3113d25acf6e45dd422ebce64b412ef9baf20e02d32c48d`。具体Hash/字节及定位见索引。项目/SDK关键文件按既有库存的具名pin定点核对；不是重新运行库存闭合门。
- **静态来源限制**：Gradle随包`src`本轮首次定向Hash。它位于已知8.14发行环境，receipt也为8.14；未下载官方源码或验证官方签名，未执行/反编译JVM，也未证明所有src与安装class逐字同构。下文“机制PROVEN”严格限于具名源码，不冒称实际运行对象已被记录。
- **ASTRA_DIRECT_GITHUB_STATIC**仅指既有Astra审查范围；本轮读取/Hash、历史G运行及私有原证是Codex报告。Gradle定位助手仅定向读具名源码；另一非作者报告助手仅静态读取本报告、索引及代码定位，未发现具体分级或预算门禁问题。两者未运行脚本、测试、Gradle、DLL、进程或设备；均不构成Astra独立验收。
- 本轮没有扫描/重哈希100453输入文件；只对既存47MB库存文件本身核Hash，并按文件名定点定位少数pin。26784、108及100447原来源的全量核验仍是前次报告，不重标为本轮完成。

## 3. A：scope拒绝的实证链与竞争解释

**PROVEN（原证）**：G.command与G.invocation都含且仅含一次`-PelitesyncOwnedAarInit=v10.1.5-ordinary-r1-runtime`；它位于task后，但参数数组中没有独立的`--`。cwd是既有任务的模块`.android`。Kotlin普通R1参数组装也含同样拼写，先owned init、后offline init。claim只含task/stage/库存/保留次数等字段，**claim本身没有commandHash**；命令与claim的双绑定是在G.result，不能按任务文字倒填字段。

**PROVEN（原证）**：stderr在`settings.gradle:22`解析`dev.flutter.flutter-plugin-loader:1.0.0`时报“A problem occurred evaluating initialization script”，内层文案为`OWNED_AAR_INIT_REJECTED: explicit ordinary R1 scope required`，随后`BUILD FAILED in 4s`。这是location与错误摘要，**不是完整stacktrace**。根进程在强停后退出90，不能把文字当作未受干预的exit1。stderr没有Gradle对象身份、settingsDir/currentDir、parent/identity path或失败时map实值。

**PROVEN（定点源码机制）**：

1. 模块settings第3–13行的pluginManagement声明`includeBuild`到Flutter工具Gradle工程；第22行请求settings loader插件。`FlutterAppPluginLoaderPlugin.kt`声明`Plugin<Settings>`，其`apply`负责native插件包含；发生请求解析错误不等于其apply已经执行。模块后面的`include_flutter.groovy`/`module_plugin_loader.gradle`属于另一层包含逻辑，不能把它们当成同一个Gradle对象。
2. `src/plugin-use/.../DefaultPluginManagementSpec.java:88–95` → `DefaultBuildIncluder.java:70–72,96–98` → `IncludedBuildSpec.java:79–98` → `BuildDefinition.java:105–125,135–142`：included plugin build由当前StartParameter构造，调用`newBuild()`，并显式恢复`initScripts`。
3. `StartParameterInternal.java:66–89`转入父类`prepareNewBuild`，不另复制projectProperties。`StartParameter.java:79`的新对象map初始为空；`newBuild/prepareNewBuild:245–274`复制环境项和systemPropertiesArgs，**不复制projectProperties**。相反`prepareNewInstance:220–237`显式复制该map。这是两种不同API，不可混用推理。
4. `InitScriptHandlingSettingsLoader.java:30–34`在settings加载前调用`executeScripts`；`InitScriptHandler.java:48–65`取该Gradle的`getAllInitScripts()`逐个处理。同一owned init首部第4–6行检查的是**当前**Gradle的projectProperties，失败立即throw，早于后续rootProject名称跳过逻辑。
5. `StartParameterConverter.java:40–57`允许混排task/options，并将`-P`转换器结果写入map；`ProjectPropertiesCommandLineConverter.java:18–31`定义短项P，父转换器按首个`=`分键值；已pin的`gradle.bat:77`正常转发`%*`。因此“只因-P在task后所以无效”没有源码支持。

| 竞争解释 | 支持 | 缺口/反证与结论 |
|---|---|---|
| **H1：Flutter included/plugin build继承init但没有根-P，于附属上下文触发首部guard** | settings真实声明included插件build；Gradle上述newBuild/init传播机制；错误出现在plugin-loader解析位置 | 最强`HYPOTHESIS / STATIC_MECHANISM_SUPPORTED`。原G没有保存失败上下文/map，故唯一实际根因`NOT_PROVEN`；“缺key”还是“值不等”也未区分。 |
| **H2：根build收到的实参/map与记录不同，或根上下文属性在其他环节被改写** | Popen前数组/命令Hash证明记录身份，但没有OS/JVM实际argv或root map快照；guard只报告条件不等 | `HYPOTHESIS`，支持较弱。参数拼写、位置、转发和无独立`--`均支持正常解析；没有任何正面证据显示传参被截断或map被改写。不得仅重排参数就声称修好。 |
| **H3：另一个附属初始化上下文，而非直接Flutter included工程本身** | Gradle还有buildSrc等嵌套创建路径；相同init可能在不同Gradle对象处理 | `HYPOTHESIS`；无运行身份不能选定具体对象。`BuildStateFactory.java:106–113`虽然中间显式setProjectProperties，`:88–102`随后再次进入BuildDefinition的newBuild；不能凭中间一行断言最终buildSrc保留-P，也未扩大调查寻找所有恢复路径。 |

H1/H2/H3均不是缓存损坏或Dokka发TCP的证明。G的`selectedTasks=[]`源于配置未完成，继续`GRAPH_NOT_PROVEN / DOKKA_TASK_SELECTED=NOT_PROVEN`，不能叫“Dokka未选中”。

## 4. B：observer实际异常链、身份缺口和停止机制

**PROVEN（源码与匹配原证）**：

`Observer.sample`先用Toolhelp32进程快照读取PID/parent/name，依累计known PID集合扩展父链；第92–93行对当前快照中被纳入的行逐个调用`image_path(pid)`。`image_path:57–65`使用`OpenProcess(0x1000)`；失败直接返回None。打开成功后调用`QueryFullProcessImageNameW(...,0,...)`，失败也返回None，finally关闭句柄；成功却为空字符串也会触发后续假值判断。它没有保存API层、即时GetLastError、失败PID或对应handle的创建时间。

实际`controlled_runner.py:130`对`not p['imagePath']`抛出唯一同名marker；`:138`包装为原G.result中的完整stopReason。这一步在路径resolve、白名单和二进制Hash之前，**不是**GetProcessTimes的`ROOT_INSTANCE_UNREADABLE`分支，也不能把普通非空路径不在白名单解释成此marker。后者有不同的`UNKNOWN_OR_DRIFTED_EXTERNAL_TOOL`理由。

`:134`才写该轮process/socket/signal行并flush、增加样本计数；`:130`先抛错，所以**失败帧完整process/socket列表和具体循环项未落盘**。G.result只保留了marker及36个此前有效运行样本。根句柄的GetProcessTimes和每帧rootCreationFiletime只绑定根对象，不能当成每个child的创建时间；父PID链不是唯一实例链，也没有逐child IsProcessInJob核验。

保留原件有1个挂起根基线和36个有效运行样本，后者单调时间跨度约4.562秒；它不等于整个G的4.829秒精确覆盖。下表只按匿名PID组归纳，**不是唯一进程实例名册**：

| 匿名组 | 记录映像名 | 落盘行数 | 首末行（0为基线） |
|---|---|---:|---|
| P1 | cmd.exe | 37 | 0–36 |
| P2 | conhost.exe | 36 | 1–36 |
| P3 | java.exe | 35 | 2–36 |
| P4 | java.exe | 30 | 7–36 |
| P5 | conhost.exe | 5 | 7–11 |

这五组在已落盘行的路径均非空。无法把未落盘失败归给其中某组，更不能因某conhost较早消失就指定它是失败对象。known PID残留本身不会查询一个在当前快照完全不存在的行；快照后退出竞态或旧PID后被复用仍是不同可能性。

| 可能解释 | 现有证据及分级 |
|---|---|
| 快照列出后正常退出，OpenProcess/Query时已不可读 | 非原子采样顺序支持可能性；无失败handle/退出码/创建时间，`HYPOTHESIS / NOT_PROVEN`。 |
| 访问拒绝、受保护进程或权限机制 | 有OpenProcess/Query失败合并为None的分支；没有GetLastError/权限回执，均`NOT_PROVEN`，不申请提权来验证。 |
| PID复用、累计归属集合误纳入 | 现有known以PID累计且没有child创建时间，机制上存在歧义；落盘记录没有证明实际发生复用，`NOT_PROVEN`。 |
| Windows API/缓冲或实现缺陷 | API层和错误码丢失可证；具体API故障/实现bug是否导致本次不可读`NOT_PROVEN`。 |
| 普通路径重定向/白名单不匹配 | 非空路径规范化位于当前marker之后，不能直接解释此异常；Windows查询阶段的路径相关失败仍因原码缺失而未知。 |

**PROVEN（既有停止回执；非本轮实时观察）**：runner `:74`启用Job kill-on-close，`:140`有reason即abort，`:146–147`检查并有界wait_empty；G.result记录exit90、finalJobActiveProcesses=0、eligibleForA=false。A gate检查exit/stop/图完整性及同输入凭据。保守停止是正确行为：无法验证某个被纳入对象的路径时不能宣称它是已批准工具或忽略其潜在网络证据。Job约束终止范围不等于采样归属100%正确。

原件累计110条UDP endpoint和46条TCP记录（有限样本内非loopback TCP行0）；这些不是唯一连接或发包次数。UDP无目的地，不证明发包；既有36样本也不证明绝对离线。保留`DOKKA_TCP_CAUSALITY_NOT_PROVEN / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN`，不重写旧TCP事件。

## 5. C：缓存损坏与工具链兼容

**CACHE_CORRUPTION_NOT_PROVEN / TOOLCHAIN_VERSION_CONFLICT_NOT_PROVEN。** 原stderr直接落在项目自有guard条件，并无ZipException、checksum/corrupt、UnsupportedClassVersionError、NoSuchMethodError或ClassNotFoundException等本轮目标错误信号。缺少这些文本不是缓存健康证明，也没有检查全缓存CRC。

只读的Gradle build-receipt为8.14、commit `34c560e3be961658a6fbcd7170ec2443a228b109`，匹配启动输出；JDK release为Temurin17.0.18+8；settings声明AGP8.11.1、Kotlin2.2.20；现有Flutter receipt为3.41.7 / Dart3.11.5。版本存在和相互一致的声明不等于已实测兼容全部插件。仅在内存读取一个JAR的receipt成员，没有解压写盘/执行Jar或全面验包；不把这个局部读取泛化为整套工具链通过。

因此当前没有证据支持删除缓存、全量重新下载、盲升级Gradle/Flutter/JDK或卸载旧版。旧版本对其他项目的依赖本轮未调查，继续`OLD_VERSION_DEPENDENCY_ABSENCE_NOT_PROVEN`。

## 6. D：最小建议、授权类别、空间和回滚（全部未执行）

| 优先级/建议 | 精确候选范围及安全条件 | 所需后续授权类别 | 增量磁盘及回滚 |
|---|---|---|---|
| **P1 scope上下文修复候选** | 项目自有`aar_runtime.init.gradle`、来源/补丁/Hash合同、Kotlin消费pin及相关Python纯静态/完全mock检查。保留root必须显式scope、未知上下文拒绝；可研究仅对精确pin的Flutter tooling included-root采用受控分支，或定义可审核的跨上下文传递契约。不得全局删除guard、缺-P即放行或给所有nested build无条件白名单。sources/AAR/POM/runtime要求仍保留。 | 单独具名源码修复任务；mock/静态预算。该方向不是当前已实施补丁，也不保证选图通过。 | 仅文本/fixture拟定上限1MiB、mock证据1–10MiB为规划cap，非未来实测值。回滚至fd0/方案一源码及原pin，恢复合同所有关联Hash；不reset dirty根、不改共享SDK。 |
| **P1 observer先补可诊断性** | 未来新的任务自有runner副本及必要observer接口：失败前落盘API阶段、即时GetLastError、快照/查询时点、PID/父链与可取得的创建时间；句柄取证与身份核验失败仍强停。故障帧即使日志写失败也不得继续。 | 仅具名诊断源码修复+完全mock的API/日志失败回归；不授权真实进程模拟或构建。 | 文本加有界原证拟定1–10MiB cap，原故障原件只读。回滚新副本到原runner Hash；保留所有新失败记录，不覆盖旧执行器/claim。 |
| **P2 修复后的运行验证** | 先重新固定受影响输入及root/child上下文证据，再由新任务申请新的受控图验证额度；不是重跑旧G，A仍不能从旧余额自动启动。 | Owner对新Gradle预算的明确授权和新持久claim；新受控运行任务。 | 完整新隔离快照的额外空间本轮未做全量核算，`NOT_PROVEN`；后续先按具名输入元数据估算并冻结硬盘cap，不能承诺只有文本大小。保留原输入/日志；回滚为停止新Job、保留回执。 |
| **条件维护：仅具名损坏时重建/可信下载** | 当前不建议执行。未来有具体损坏条目/Hash/CRC等证据时，仅替换新任务自有且非历史原证/非共享依赖的目标；确认来源、版本、签名/Hash、费用零新增及路径。原protected缓存输入/partial不当普通可删除缓存。 | Owner既有维护方向下，由Astra落实具名范围、版本、磁盘cap及回滚的维护任务；维护不产生构建预算。 | 至少保留原件+新下载+新解压/回滚空间，具体MiB/GiB需目标后定，当前`NOT_PROVEN`。隔离新目录，旧共享版本和证据不动；不得用清ledger或换目录恢复预算。 |
| **条件升级/旧版清理** | 当前没有实际版本冲突，不选新版本号。先隔离验证兼容和回滚，再核所有项目引用及旧版无依赖；本轮未做跨项目扫描，不给可清理清单。 | 按既有方向落实的具体升级/清理任务；提权、安全策略或不可逆跨项目影响另需具名授权。 | 下载/解压峰值、双版本共存及可回收量均`NOT_PROVEN`，不能虚报可腾出容量；未完成新版本/依赖/回滚门前保留旧版。 |

本轮对两具名根只读查询的卷可用空间约为477.2GiB（证据卷）及1019.1GiB（既有隔离副本卷）；它们是该时点的可用空间元数据，不是可回收容量。未计算旧工具全盘占用，也不据此开放删除。**单一最小下一步建议**：等待Astra审查本报告，再决定是否派发一份“scope上下文合同＋observer异常前记录”的零Gradle、纯mock/静态源码修复任务。当前不创建该任务、不开始实现或新验证。

## 7. 保护、证据索引与终态

本轮定向首尾核验：43份关键原件/局部源码/选定SQL/APK指纹、14份本次读取的既有G原件、5根Git HEAD/branch/index/status元数据，以及525开工refs一致。六份SQL/APK只做流式Hash，不输出内容。原partial仍7,941,328字节，SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`；旧APK claim `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、G claim `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`不变，A claim仍不存在。

这不是26784份历史文件、108份旧附加原证或全部dirty文件原字节的重新普查。已有保护seal继续保留；本轮未写产品树、历史日志、SDK/缓存、refs或dirty根。一个只读助手因Gradle源文件module路径定位错误退出1，已保留说明并修正outbox定位，不是缓存损坏或构建失败；没有运行受审代码。

公开索引仅含脱敏标签、代码定位、Hash、字节数、分级结论与运行预算0；完整路径、PID/父链、socket原始行、用户标识、SQL/APK和原日志保持LOCAL_ONLY。fd0旧报告/索引、实施报告/Manifest及plan均不回写。本候选最终Commit/唯一Parent/Root、完整双产品Tree和新增文档原字节以发布回读为准。

继续：**V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / GRAPH_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN / DOKKA_TASK_SELECTED_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / GATE2_NOT_AUTHORIZED / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED**。

旧APK=1/1耗尽；G=1/1耗尽；A=0/1且gate=false；本任务新运行预算全部0。AEC、最后可闻波形、native handle、真实15/30天与物理30天清理不因本报告关闭。发布普通文档候选并完成回读后STOP，等待Astra独立验收，不自动使用后续维护方向或创建后继任务。
