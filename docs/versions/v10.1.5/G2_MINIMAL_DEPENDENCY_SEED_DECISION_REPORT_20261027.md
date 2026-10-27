# EliteSync v10.1.5｜G2 最小依赖 Seed 与 SDK 写入边界静态决策报告

执行日期：2026-10-28（Asia/Shanghai）；任务文件日期：2026-10-27。

**MINIMAL_SEED_CLOSURE_NOT_PROVEN / BLOCKED_DISK_OR_ISOLATION / G2_READY_FOR_POPEN=FALSE。**

未证明在 536,870,912 bytes 内存在完整可用的精简 Seed，也未证明它不存在。静态声明可达模型、缓存索引闭合、SDK 隐式写入与 OS 有效隔离是四个独立缺口。此次只交付决策证据，不放行 G2；`GRADLE_RESOLUTION_RUNTIME_NOT_PROVEN / INVENTORY_RUNTIME_CLOSURE_NOT_PROVEN`。

## 1. 正式授权、来源与产品身份

唯一任务 Blob `465eb13f8cb290bfab4061b03edf51629e90ca87` 已 fresh 读取并核对原字节；冻结 plan `7d3466b3be67135dc641cfee7c7faef78937ba03`、原 G2 合同 `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c` 不变。Owner 本地手动派发覆盖本次静态分析。ACTIVE_STATE 的“尚待派发”是发布时点，不能代替本会话授权或证明本地执行。

| 对象 | 本轮直接核验身份 |
|---|---|
| live main / Root（开工读取） | `599a44d99c928c8052a0a7edfb783e79fe63513c` / `3494eb3956c9529d1714c9b2c15bf982a9857b69` |
| main 已接受 v10.1.4 apps / services | `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac` |
| 来源候选 / 唯一 Parent | `68feee0443991696385337c318348ead5306e1ef` / `286eb20d1d6af2e76423cfbd3253880f47c9ae16` |
| 68fe Root / apps / services | `93fc0d1837ff807bf40fc6c4cb55e9d8bb89b847` / `5af7a9d0042be19437616e969e260658b67e9353` / `21eebf69bbc6397b1562d40f8cd9ebd7b246720f` |
| 68fe 报告 / 索引 Blob | `8b75df6af8560b846f57661dcce144d22d9f3100` / `a5c2129376299126a1d0ede52f2616b74cd0c3d2` |
| Astra 68fe 验收 Blob / 分支 HEAD | `40a772e4a86f248b04b49bfb245d8f671e3ec751` / `7a99bc408e1de7c9bca43508917061f6c001509f` |
| 6ca / 唯一源码 Parent / Root | `6ca09a66c0ef9619df7a3d7d4b089516f409954f` / `71ab58533270dd8b3a1270a3452a82b4f426e361` / `3bf735ab1c8e394844db80be35d86d2250390c82` |
| Astra 6ca 验收 Blob | `6d5ee056409de7373e635cd5e75b6aed52396bbd` |
| 286 预检报告 / 索引 Blob | `f4c80b4bbab70485188a31daf2e36d75d0f7c7ba` / `8850d02049255c6e566e2ae5e90a6eb66eb95515` |

main、68fe、6ca 递归 Root 分别 6231、6657、6650 项，均未截断。完整产品条目逐项比对：6ca 与 68fe 相同，包含 1777 份产品文件。Astra 对 68fe 仅接受 `68FEEE04_BOUNDED_BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`；6ca 仅 `SOURCE_HARDENING_ACCEPTED_WITH_OBSERVATIONS / SOURCE_LEVEL_ONLY`。不扩大裁决。

本轮使用独立 outbox 和从 68fe Root 派生的轻量文档候选；没有新 checkout、没有切换或写入旧 dirty 根。新候选唯一 Parent 固定 68fe，只新增本报告、索引及两份安全静态解析/fixture 源。最终 Commit、Root、四个新 Blob 和原字节，以及发布时 fresh main 完整产品树回读留在 LOCAL_ONLY `final-readback.json`，避免报告自引用。产品 apps/services 保持 68fe，不并入 main。

## 2. 输入和方法的证据边界

新运行：只读 Python XML/JSON/POM/ZIP 元数据解析、具名 Hash、纯 fixture/mock、Git 只读状态和文件空间属性读取。固定 Gradle 8.14 distribution 314 文件与旧 pin 相等；schema2 的 7 项必需输入复核通过。44 份实际配置来源、14 个 native plugin 根、84 条声明，外部配置根 19 个，另可能 action/runtime 根 25 个。Flutter SDK 3.41.7 与 tooling 来源按固定库存具名比对；未把上轮 96736 项全量复算冒充本轮结果。

缓存 sealed 集合 3183 文件全部 fresh Hash 相等，共 1,362,106,905 bytes；含 1013 个内容 GAV、1013 POM、301 Gradle Module Metadata。本地完整文件 Hash 清单、逐节点拓扑、全部 UNKNOWN 节点、variant 属性/capability、artifact 名称及私有路径保留 LOCAL_ONLY，公开索引绑定文件 Hash 和统计。没有复制 Seed、完整 modules-2 或 SDK，没有执行或加载 JAR 类。

`seed_static.py` 是有限声明可达模型，**不是 Maven effective model 或 Gradle resolver**。脚本 literal/局部属性可读声明属于 PROVEN_STATIC/INFERRED；遍历结果是观察模型，未执行脚本、版本仲裁、Gradle attribute matching、capability 冲突、parent/BOM 优先级、profile 激活、exclusion 或 classloader reuse。正则扫描 `unsupported=[]` 也不证明找全动态依赖。

## 3. 已证声明边与无法闭合的解析边

四份外部 marker POM 的直接 literal dependency 已逐项 XML 读取并绑定文件 Hash；这证明声明存在，不证明 Gradle 选择或成功加载。Flutter loader 来自 settings 的 includeBuild 候选，无需把外部 marker 缺失误报为依赖缺失。

| marker 请求 | 已读声明目标 |
|---|---|
| `dev.flutter.flutter-plugin-loader:dev.flutter.flutter-plugin-loader.gradle.plugin:1.0.0` | `included build provider candidate` |
| `com.android.library:com.android.library.gradle.plugin:8.11.1` | `com.android.tools.build:gradle:8.11.1` |
| `org.jetbrains.kotlin.android:org.jetbrains.kotlin.android.gradle.plugin:2.2.20` | `org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.20` |
| `org.jetbrains.kotlin.jvm:org.jetbrains.kotlin.jvm.gradle.plugin:1.9.20` | `org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.20` |
| `org.gradle.kotlin.kotlin-dsl:org.gradle.kotlin.kotlin-dsl.gradle.plugin:5.2.0` | `org.gradle.kotlin:gradle-kotlin-dsl-plugins:5.2.0` |

Flutter `.android/settings.gradle` 的 `includeBuild`、`local.properties` 的 SDK 根及 tooling build 中 plugin id/version 三者相符；`includedBuildLoaderExternalMarkerRequiredBySource=false`，但 `includedBuildLoaderActualGradleProviderSelection=NOT_PROVEN`。Gradle8.14 `KotlinDependencyExtensions.kt:93–98` 将 Kotlin DSL plugin 请求固定为 5.2.0。implementation JAR 的 `META-INF/gradle-plugins/*.properties` 只作 ZIP 读取，未执行插件。

14 个 native plugin 脚本含多个 AGP 版本（8.0.0、8.1.0、8.3.1、8.5.1、8.11.1、8.12.1、8.13.1）和多个 KGP 版本；不能自行统一最高版本，也不能假定父 classloader 消除了这些请求。19 根完整坐标、84 条来源/行号/Hash、4 条 literal marker 边随索引提供；大拓扑留 LOCAL_ONLY。

配置模型观察到 5908 条边，933 个请求可达节点，715 个有缓存内容。以下计数是模型诊断事件，可能重叠，**不是实际缺失依赖数或实际 selected graph**：

| UNKNOWN / 保守处理类别 | 配置模型计数 |
|---|---:|
| `GRADLE_VARIANT_SELECTION_NOT_EMULATED` | 135 |
| `COMPONENT_CONTENT_NOT_CACHED` | 218 |
| `MULTI_VERSION_WINNER_NOT_PROVEN` | 160 |
| `EXCLUSIONS_NOT_APPLIED_TO_ENVELOPE` | 207 |
| `OPTIONAL_EDGE_INCLUDED_CONSERVATIVELY` | 149 |
| `MAVEN_PROFILE_ACTIVATION_UNKNOWN` | 81 |
| `EFFECTIVE_PARENT_MODEL_NOT_GRADLE_RESOLVED` | 145 |
| `PARENT_OVERRIDE_EFFECTIVE_VERSION_UNKNOWN` | 108 |
| `BOM_UNRESOLVED` | 2 |
| `DEPENDENCY_VERSION_UNRESOLVED` | 56 |
| `CLASSIFIER_SELECTION_REQUIRED` | 12 |

`COMPONENT_CONTENT_NOT_CACHED=218` 可能来自非选中 variant、旧版本或父支持节点，不能据此宣称实际构建缺依赖。两项 `BOM_UNRESOLVED` 是有限模型在父 property override 下清空未证版本的结果，不是缓存真的缺 BOM 的证明。parent 支持节点独立遍历，其预展开依赖不再误称子节点 effective 边。rich version 保留所有声明固定候选且仍 UNKNOWN；重复不一致 `.module` 拒绝，避免静默覆盖。

完整性结论：已证的是根声明、上述直接 literal 边、对应文件现有字节和固定源码行为；最小闭包、最终版本/variant、artifact 必需性与离线命中均 NOT_PROVEN。已有缓存未出现 Hash 漂移，没有证据把这些模型未知项归因为缓存损坏或工具链不兼容。

## 4. 缓存格式与只读层的实际范围

固定 Gradle8.14 源码：`ModuleMetadataStore.java:52` 等以 repository/component key 读取 descriptor；`AbstractModuleMetadataCache`、module versions/artifact(s) cache、`CachingModuleComponentRepository` 将解析缓存与内容文件分开。`DependencyManagementBuildTreeScopeServices.java:194–210,234–289` 构造只读/可写 two-stage 依赖缓存，`TwoStageByUrlCachedExternalResourceIndex` 负责 URL 资源索引。它们不能覆盖所有编译、transform、included build、SDK 或用户状态写入。

现有 metadata-2.107 共 3,682,071 bytes：1031 份 descriptor 和 3 份全局索引（module-artifact 206,568；module-metadata 111,976；resource-at-url 881,745 bytes）。三份索引 Hash 在公开索引。内容目录可见 POM/JAR/module，**不等于新根离线可命中**；repository identity、序列化索引和路径迁移尚未闭合。本轮未重建二进制索引，不能用复制 files-2.1 或重新命名目录取代证明。未见某其它索引也不单独证明损坏，它是否必要取决于真实解析路径。

## 5. 精确内容容量与非保证的峰值方案

| 内容集合 | 逻辑 bytes | 结论 |
|---|---:|---|
| core-only 场景 | 315,205,052 | 排除了 native plugin buildscript 请求；不是完整 G2 Seed |
| 配置声明模型可达缓存内容 + 全现有 dependency metadata | 880,792,638 | 2505 文件；不是最小量、完整闭包或严格上界 |
| 再加入可能 action/runtime 声明 | 951,221,175 | 2815 文件；不是 selected task 需求或严格上界 |
| 全 sealed modules-2 比较全集 | 1,362,106,905 | 3183 文件；超 512MiB；不是实际必须复制量 |

无条件运行必需字节下界只能保留 **0**（未证明实际解析如何命中 descriptor）；4 个 marker POM 共 4068 bytes 是已读证据，不是严格运行下界。真正完整闭包的容量上界 **UNKNOWN**；全 sealed 集合仅是已有内容全集的上界，未必涵盖动态新请求。即使选择 ≤512MiB 的 core-only 内容，也不能证明其完整性。不能从 880,792,638 bytes 宣称已证明任何正确 Seed 都超 cap。

本轮 cap 始终 536,870,912 bytes，复制依赖 Seed **0 bytes**。仅提出下一轮待 Owner 批准的 **2GiB 静态 snapshot + OS 隔离资格**选项：1,362,106,905 全现有 sealed 字节 + 8,277,854 既有小骨架 + 536,870,912 私有写预留 + 67,108,864 分配/metadata 规划余量 = **1,974,364,535 bytes**；相对 2,147,483,648 尚余 **173,119,113 bytes**。写预留和余量均不是已证最大值，2GiB 不保证运行足够或闭合。

回滚可保留旧输入完全不动、停用新 Seed，因此不必新建第二份完整备份。如果还要求两份新 Seed 共存，则规划峰值 **3,336,471,440 bytes**，2GiB 不足，需单独批准。本轮没有扩大 cap、没有复制这些内容，也未申请真实 G2。观察时系统卷可用约 505.7GB 只用于空间背景，不等于授权容量。

## 6. SDK、native plugin 剩余写面

| 关键路径 | 静态可核验事实 | 当前分类与剩余门 |
|---|---|---|
| Flutter 配置 → NDK/CMake | `FlutterPlugin.kt:284` 调用 forceNdkDownload；`FlutterPluginUtils.kt:593–606` 在已有 cmake.path 时早退，否则指向 SDK 的空 CMakeLists | 条件/声明 CLOSED_BY_PINNED_SOURCE；是否触发 SDK Manager、下载或 stamp/metadata 写入 UNRESOLVED |
| CMake staging | `FlutterPluginUtils.kt:610–634` 设置相对 build 的 `.cxx` | 路径公式 CLOSED_BY_PINNED_SOURCE；最终 canonical 目标、插件自设 CMake 与 AGP 副作用 CLOSURE_REQUIRES_RUNTIME_OBSERVATION |
| 已安装工具 | NDK28.2.13676358、CMake3.22.1、API36、build-tools36.0.0 的四份 source.properties 与旧 pin 相符 | 只证明 metadata 在场，不证明完整安装、AGP 不写 SDK、许可检查或工具版本兼容 |
| Flutter tooling included build | 固定 build/settings、tooling 源 Hash；6ca schema2 七项一致 | 源入口已证；`.gradle`、buildOutputCleanup、Kotlin/transform/编译输出必须私有；完整配置读集 UNRESOLVED |
| Flutter SDK bin/cache、Dart | 当前 SDK 属性/来源具名可读；小 SDK 模板仅 partial | stamp、版本、engine/artifact、Dart cache 读集与配置期启动可能性 UNRESOLVED；三个 tooling pin 不证明完整 SDK 闭合 |
| 14 native plugin | `module_plugin_loader.gradle:24–30` 将普通 build 输出导向 plugins_build_output；部分 JNI 引用 `../java` / `../src/CMakeLists.txt` | 默认输出路由源级已证；完整插件包读取、自定义写入、动态 classpath 与 CMake 额外输出 UNRESOLVED |
| generateLockfiles | `FlutterPlugin.kt:333–342` 的 wrapper exec 位于 doLast | action 存在 PROVEN_STATIC；目标图是否选择 NOT_PROVEN，未执行 |
| HOME/AppData/temp/Android/Pub 用户态 | 既有私有环境映射只是提案 | ANDROID_USER_HOME、PUB_CACHE、TEMP/TMP、HOME/USERPROFILE 及 native/AGP 自选输出必须逐个限定；实际有效路径 UNRESOLVED |

存在安装元数据、`--offline` 和关闭 JDK autodownload 均不足以封闭 SDK Manager/native 写面。脚本出现 JitPack 或 wrapper URL 是声明，不能提升为本次 TCP 或下载证据；Dokka 实际选择及 TCP 因果仍未证明。

## 7. OS 隔离方案仅为可行性分析

只读读取三份 ACL descriptor，真实 SID/owner/路径保持 LOCAL_ONLY；没有改 ACL、有效访问实验、写探针、restricted token 或进程运行。Python 路径与 Hash 策略不是操作系统隔离；同一可写账户的普通只读属性或自设 DACL 不能当然阻止 owner/WRITE_DAC/父目录 delete/rename/privilege 路径，Job kill 也不限制文件写入。

最小可审查方案需独立 Seed 与私有 writable home/project/tooling/module/plugin 输出，源目录不可回写；对每层 canonical ancestor、file-id/link count/reparse、父目录删除重命名权限、有效 token 权限及时间窗口变化实施 OS 层约束。只读依赖层无法替代 included build 或 SDK 隔离。未知输出必须拒绝；不能用 writable fallback、hardlink/junction/symlink 指回保护根。当前未实施或验证这些 OS 约束，状态 UNRESOLVED。

## 8. 新检查、原失败与资源保护

25 项定向 fixture/mock，exit0，0 failures/errors/skips，测试审计禁止 subprocess/socket/DLL 事件 0。覆盖 marker/parent/BOM 缺口、variant/classifier、transitive/conflict、rich version、重复 metadata、未知 profile、索引缺口、RO fallback、Hash/redirect、逻辑/峰值 cap 拒绝。初版22项绿灯遗漏三种逻辑缺陷，非作者只读审查指出后修正为25项；v1/v2 模型、旧源码和运行回执全部保留，旧绿灯不算最终验证。非作者只读复核未执行测试或本地设备操作，不替代 Astra。

没有新运行历史56/140广谱套件。intake、reviewed analysis、source SDK、25项测试、交付前保护脚本均 exit0；分析脚本 exit0只表示解析完成，结论仍 BLOCKED。命令/真实退出码/stdout/stderr Hash 见索引。最后摘要只将 loader 两字段加上源级限定，未改变模型边或容量；未为标签变更重复全库分析。

空间查询曾尝试只读 fsutil file layout，exit1、Error5 Access denied；保留工具输出转录，未提权或绕过该权限。之后使用普通 FILE_READ_ATTRIBUTES / FILE_STANDARD_INFO 查询任务拥有的文件/目录 AllocationSize：这是实际只读文件属性 API，**不能笼统称所有 native API 调用为0**；不涉及真实 observer/Job、进程句柄或网络。

| 本轮测量阶段 | logical bytes | allocated bytes |
|---|---:|---:|
| intake 后首次 before | 4,671,302 | 4,706,304 |
| 分析阶段 | 23,004,418 | 23,141,224 |
| 报告生成前 delivery | 27,290,418 | 27,443,448 |

新 outbox 创建前没有本轮文件；before 是 intake 后首个测量，不伪称开工零时刻全卷采样。逐文件/目录分配量覆盖任务自有内容，排除后续 receipt、MFT/journal 等全卷元数据；卷 free 含外部并发，不能把全卷差额归给本任务。报告及远端回读后的最终测量留 LOCAL_ONLY final receipt。未新增工作树或大副本，当前远低于 cap。

交付前重新核验84份具名保护原件、五根 HEAD/branch/index/status、527个本地既有 refs；源286仍干净，44配置来源、14源码锚点、3183缓存与314 Gradle文件、四份SDK metadata相等。本轮不冒称全盘或历史26784/108/100453项目复算。任务新文件均单 link、无 reparse；ACL 原件只读。旧 partial 7,941,328 bytes / SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`、APK claim `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、G claim `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316` 保持。

本轮没有 Gradle/JVM/Java/Flutter/Dart/AGP/Kotlin 执行、G2 Popen、observer/Job/network 实验、AAR/APK、ADB/RTC、Gate2、下载/升级/缓存删除或共享SDK/系统策略修改。没有创建任务拥有的通话、令牌、服务或端口，也未做全局设备/网络扫描来补写“实测0”。旧 APK/G 预算均1/1耗尽、旧A门禁关闭；G2 本地只读 claim absent，reservedStarts=0/Popen=0/max=1，本任务运行预算0；Gate2未授权。最终再核对并留 receipt，不改 claim/ledger。

## 9. Owner 下一步最小决策建议与停止

**原512MiB下不具备放行依据。** 阻断并非已证“物理磁盘不足”，而是精简闭包未证、索引迁移未证、SDK隐式写面未封闭及OS有效隔离未验证。建议如继续，只考虑另行批准 **≤2GiB 的具名独立 Seed snapshot 与OS隔离资格工作，仍零Gradle**：先封闭repository/metadata映射，验证只读源和私有写面；任何超空间、未知写面或有效只读失败即停，不启动G2。本轮没有创建此后继任务或申请其执行。

未来 G2 前仍须：完整可信读源/写面库存与schema2七项、tooling与插件Hash；Seed索引/仓库身份闭合；SDK/NDK/CMake隐式写入隔离；OS有效权限/ancestor/link/TOCTOU资格；专属 runner/observer 的进程身份与强停资格；fresh预算和原子claim绑定。提出清单不等于已验证或自动获准运行。

持续 `DOKKA_TASK_SELECTED_NOT_PROVEN / GRAPH_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`；AEC、真实elapsed-time、物理清理和Push等历史缺口不关闭。**普通候选发布并回读后 STOP，等待 Astra 独立验收；不自动 G2/A/APK/Gate2、不合 main、不启动 v10.1.6。**

证据等级：GitHub对象原字节 DIRECT_GITHUB_READBACK；本轮文件分析与mock回执 CODEX_REPORTED_LOCAL_EXECUTION、原件 LOCAL_ONLY_RAW；前置Astra裁决 ASTRA_DIRECT_GITHUB_STATIC。任何辅助审查均不替代新候选独立验收。

## 附录：固定源码锚点与配置来源 Hash

以下为安全的上游相对路径/插件标签；真实机器路径不公开。行号事实见第4、6节。

| 固定源码 | SHA256 |
|---|---|
| gradle/src/dependency-management/org/gradle/api/internal/artifacts/ivyservice/modulecache/ModuleMetadataStore.java | `7cb8cf634278840ff62d68fbfde14668a81cd123a7009a2c012f7e3974c668da` |
| gradle/src/dependency-management/org/gradle/api/internal/artifacts/ivyservice/modulecache/AbstractModuleMetadataCache.java | `94b949572e1ef560f5174a7c94cf2872401d4f3da7b228f2ac4e062081238483` |
| gradle/src/dependency-management/org/gradle/api/internal/artifacts/ivyservice/modulecache/dynamicversions/DefaultModuleVersionsCache.java | `df46df51a11576aca9e942930459d8395fd604c3d495d75fa0246bd7c55307c7` |
| gradle/src/dependency-management/org/gradle/api/internal/artifacts/ivyservice/modulecache/artifacts/DefaultModuleArtifactsCache.java | `d338141a4169631d3412b2396c0e4b512bcfbe000bb7378c321aa4586ab2acfb` |
| gradle/src/dependency-management/org/gradle/api/internal/artifacts/ivyservice/modulecache/artifacts/DefaultModuleArtifactCache.java | `690d7968e3ce2ed92705d7c19eb50a4b5a7dd8be21a5f561a73e0c69508b8a43` |
| gradle/src/dependency-management/org/gradle/api/internal/artifacts/DependencyManagementBuildTreeScopeServices.java | `d4d3337fbb25b282f9ff7369dd4b752c109d2f83c78ccdf69c8d7e52463a3362` |
| gradle/src/dependency-management/org/gradle/internal/resource/cached/TwoStageByUrlCachedExternalResourceIndex.java | `ac72eb61f21d7911e28205f71a8a372fe186c95cff141ff62a2d43031172fa96` |
| gradle/src/dependency-management/org/gradle/api/internal/artifacts/ivyservice/ivyresolve/CachingModuleComponentRepository.java | `25e10dbd285614ac1117a1722efc2bfa919f0c9b6d8eafb06cf47559df0591fb` |
| gradle/src/dependency-management/org/gradle/api/internal/artifacts/repositories/metadata/DefaultGradleModuleMetadataSource.java | `0bcfd711180f08bbeb157ac6d2c6119cdca823adbbf0a04a20789608a540942d` |
| flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt | `1eeb49a1e17859b150e8ed5109c9af0932fafacb06810d2a02bc688a69387313` |
| flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPluginUtils.kt | `e0eb454157e67127b7677d697e924eb6b0556c8a4e51405045bc5e7f77798fd0` |
| flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt | `cdb7c4e296c353dcbebd409157759cc552dd1a041603f79f9ed81618c8b44ea5` |
| flutter/packages/flutter_tools/gradle/module_plugin_loader.gradle | `169b243692655ef740aab29795e4c4202a7b43b9a5e53ef713da307211145913` |
| flutter/packages/flutter_tools/gradle/src/main/kotlin/tasks/FlutterTask.kt | `018145e27f13790bf089f8430355e15c5852ca7eac5d0d39ce1deb5858729dbf` |

| 实际配置来源标签 | bytes | SHA256 |
|---|---:|---|
| module/settings.gradle | 926 | `58ed6cf1a5ff74237dba2c0dbbd19669aeeea145c2f442462b04c20541a8f609` |
| module/build.gradle | 361 | `5a611dadb1c89e576bd50d964efeb52b0ac9883fb4773e594bf75c37979ab760` |
| module/gradle.properties | 140 | `1888df8f168eb770ca0f540b7bf84091e6b31b0d5ac55e4de518590b8f7ed8e5` |
| module/Flutter/build.gradle | 1320 | `d01309040bd46eab30baad16ec9fe1c198304a920da80842b8f68d763acb1251` |
| module/app/build.gradle | 1162 | `880e8f96916520df0854aeca56e63650ac58c344d5f9eb8144875e11911d1fc7` |
| tooling/settings.gradle.kts | 172 | `106ea06cbc2bf28234443b8a74e7ec4e32a817b4d279d122a650c073daad4d37` |
| tooling/build.gradle.kts | 2798 | `8d83640366f1f78c9db70f771d0c6e4a9c0d9e4858aa6eee30891e86fed323b1` |
| plugin/connectivity_plus/android/build.gradle | 862 | `e43e962b5f4e8975bcac35073840136ccd4a1a7a790e6f340f5863d2e110623b` |
| plugin/connectivity_plus/android/settings.gradle | 34 | `51de563de119e5e42b7bc33f696a8acdfd3c235b193fee5d01fdea09d6191258` |
| plugin/connectivity_plus/android/gradle.properties | 84 | `f4c746b640de7c7f401199e50e1d4b7be1ead892f17d9fc4a96aa13f81c20196` |
| plugin/device_info_plus/android/build.gradle | 1100 | `21a89e2e96af054d9fc95d9da5af2f8d779cf2704115c8342c51645dc2f23295` |
| plugin/device_info_plus/android/settings.gradle | 33 | `26e94e4f9e41a9c22f0e4b5fad6483f901cc5cb343de0c4a8c99bc671b98166c` |
| plugin/device_info_plus/android/gradle.properties | 29 | `034fd3f15ac7a699cf7393150e318cd3e0afb51826b0decc69a548db53fa1116` |
| plugin/flutter_plugin_android_lifecycle/android/build.gradle.kts | 1628 | `dd6b424f03f08a6d91799199e89b67a95011b7122edcdc90a920acbf06be9b0f` |
| plugin/flutter_plugin_android_lifecycle/android/settings.gradle.kts | 54 | `5e1f38acf596f1b1040f969b0bc2f51ea2ff9994ee6c2de4dd4d7f23df2a842f` |
| plugin/flutter_secure_storage/android/build.gradle | 932 | `fd69c260d8c1af9ed6baa65928d32ba396fff05c3071cab02b29ab81cd4ce535` |
| plugin/flutter_secure_storage/android/settings.gradle | 44 | `b5fb1df0485dcc39fb62a5d323d02af51a27ba387ba7d297fcbb12594a271e14` |
| plugin/flutter_secure_storage/android/gradle.properties | 29 | `034fd3f15ac7a699cf7393150e318cd3e0afb51826b0decc69a548db53fa1116` |
| plugin/flutter_webrtc/android/build.gradle | 2458 | `88e98751759e607c3b9e00c62732bc8e28223e837ca8d75b08e887eb1a4c63f8` |
| plugin/flutter_webrtc/android/settings.gradle | 28 | `9105117799f36567266c8daae357444ccb10452fd1fb7bfa79e621d1cb3115d9` |
| plugin/flutter_webrtc/android/gradle.properties | 166 | `20c411ebbe5162992d16d170656ee19a9ffe0571e6c4d4c5a5314bb06da0a672` |
| plugin/image_picker_android/android/build.gradle.kts | 2140 | `7bdf38d4b24d0f469d9704c3eb318cda2f66d108064ea040ce9816e5b6ce9859` |
| plugin/image_picker_android/android/settings.gradle.kts | 42 | `66438c10cc93f35ab471d6bb88c4c3889f12b2cb8eef8c8a7f2e4c5a8b638aee` |
| plugin/image_picker_android/android/gradle.properties | 64 | `622a3c6053f7d1429ef926700e2859ddcf2da8e58581de4621b5b601074508ba` |
| plugin/jni/android/build.gradle | 1967 | `d69d3d6ddca300453c7a222451a268bd157cc93b2de4fc385d60b94656c6e008` |
| plugin/jni/android/settings.gradle | 25 | `d91b05de12e9bb05305cc346abc1125ca09c0817da14f3951a2ba6e941ea1356` |
| plugin/jni_flutter/android/build.gradle | 796 | `de116770599698bb122e0b19be9bbd1ffe80291ef500660288d03eeae0d4d194` |
| plugin/jni_flutter/android/settings.gradle | 33 | `394f5957375b4cec4a82294b3f69afa1fc1b34da3853d87fc08c712759aa673c` |
| plugin/livekit_client/android/build.gradle | 2896 | `4dcd64394c34a8be868753e5053e2aea6d76d64e278467fbd2c5b2eef2bd1a7c` |
| plugin/livekit_client/android/settings.gradle | 29 | `0200e2431f97cfc02a9a9ba469fe6a322a57d2aefe960e6a3353f59e432d7b5a` |
| plugin/livekit_client/android/gradle.properties | 54 | `284d2e2db67de29a1fb4a05228dbdaa797a46c1c8caca5d7d43955f803ea644c` |
| plugin/package_info_plus/android/build.gradle | 1056 | `10beba354a1777db5e436060e98fa1b7732f41eae1a436cad7c1faae5115b482` |
| plugin/package_info_plus/android/settings.gradle | 39 | `131f7a5eca63e71fd6f6b4f8107039a0dbcc3f88ceb26639375be38c8d0a879b` |
| plugin/package_info_plus/android/gradle.properties | 29 | `034fd3f15ac7a699cf7393150e318cd3e0afb51826b0decc69a548db53fa1116` |
| plugin/permission_handler_android/android/build.gradle | 723 | `a7eb30be9254f9b4be2ab15d7ec4377432bf2906c65ea81ba2eb0bbda87ef967` |
| plugin/permission_handler_android/android/settings.gradle | 40 | `498e62f65c668b5686d078f4be72cf9f1ee833dc20554cb40f25c7724ac581a9` |
| plugin/shared_preferences_android/android/build.gradle.kts | 2469 | `da70c2c309867579219fcf6e9d5ed206a66e261792906271903900dc49693e78` |
| plugin/shared_preferences_android/android/settings.gradle.kts | 48 | `e32bb28ef85cb9620d9397d0e152ae062fdc9f9149b2e06396525996e919339d` |
| plugin/shared_preferences_android/android/gradle.properties | 51 | `d9dee78fe96651a3552d9084b0e9fa91b8a8889af91f9a39cb7a7becc1cfd547` |
| plugin/url_launcher_android/android/build.gradle.kts | 2120 | `7c14db00b9b95ba783d9cc0c939467211a78695c2eee3a1360d134b3fe660c47` |
| plugin/url_launcher_android/android/settings.gradle.kts | 42 | `48899388be4a4df328b6cfc308b756829bb09f9d286bbb5ec3957b8f85654a32` |
| plugin/video_player_android/android/build.gradle.kts | 2868 | `b488058f52b34df7aaa074c3c2ceb1f1c43d265af837d89877f25247e37d885e` |
| plugin/video_player_android/android/settings.gradle.kts | 42 | `1df579c8b33c4ba967d52f389cf2f48bd3ad948e0f07943a8d9e21d898c28407` |
| gradle/KotlinDependencyExtensions.kt | 4141 | `0a3e5e82931049989b42f835d591167ca866592e0458136d204520c5af8eb095` |
