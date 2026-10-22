# v10.1.5 Gradle8.14本地离线引导报告

2026-10-23，Asia/Shanghai；任务签发日2026-10-22。

**PARTIAL / GRADLE814_LOCAL_BOOTSTRAP_PASS / RESOLUTION_VERIFICATION_TOOLING_BLOCKED / NO_APK / OWNER_DECISION_REQUIRED / AWAITING_ASTRA_INDEPENDENT_REVIEW / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN**。

本轮完成可信Gradle8.14完整分发的安全复制/解压、22,425文件与ZIP原字节比对、存量官方embedding再核，以及一次直接bin/gradle.bat离线启动（exit0）。没有调用Wrapper、执行项目依赖解析或APK构建，没有新下载。后续依任务S2.4停止：既有解析任务仅在临时init中动态注册。本体启动成功不等于依赖图或APK成功。

## 1. 权威与连续源码

唯一任务固定Blob **677a1f7c1709fa3d7778e4edab28bf84b293c7f1**，从签发后main固定路径全文读取，raw字节重算Git Blob一致。Astra前轮独立复审Blob **6f7f200da8595d52f9da21ee39cd56d7b1164c27**全文读取，身份一致。

| 对象 | 固定身份 |
|---|---|
| 开工live main | `ea551353ec73df01e20f88f1ca01c633590a1344` |
| 唯一连续起点/本轮文档Parent | `73b3b753225f99824081d312a25a7deb170c62d3` |
| 起点Root | `6c45db667bb7a11234a72600c41f04b9432328b6` |
| 固定诊断source | `24ddf05875d8d4abad7a6b473f882698c9885c2a` |
| Source唯一Parent | `62f0cd6d6df80f2f22855c0f75fd67ff52c753a7` |
| Source Root | `2c656957e1c229ca30f7c07b173bcb1062310d2c` |
| apps Tree | `72c617cf86d5c653dd722accde340b51d2e085eb` |
| services Tree | `1e1e20bb3500bedb1a521e5f2ddeece915d09424` |
| 前轮报告/manifest Blob | `ba2212be8342dc0e6354a70bab4a64c456e2a716` / `646840354b93dab3ed617e43aac89af469fa9fa5` |

main仍是已接受v10.1.4产品加顾问文档，不是待验诊断源码。候选分支codex/v10.1.5-gradle814-offline-bootstrap从干净73b3建立，仅新增本报告和manifest。**SOURCE_UNCHANGED**；未改ACTIVE_STATE、冻结AC、旧报告、源码/构建脚本、wrapper.properties或锁文件。

版本文件及lock确认Flutter3.41.7、Dart3.11.5、engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`，LiveKit2.10.0、flutter_webrtc1.6.0、webrtc_interface1.5.1；项目声明Gradle8.14、AGP8.11.1、Kotlin插件2.2.20保持原样。

## 2. S0可信输入和四闸门

全部新工具副本、解压目录、私有Gradle home及原证均在本轮新LOCAL_ONLY目录。旧原件只读，不覆盖原解压目录或全局缓存。

| 输入 | bytes | SHA256 | 本轮处理 |
|---|---|---|---|
| 可信完整Gradle8.14 ZIP | 224116304 | `efe9a3d147d948d7528a9887fa35abcf24ca1a43ad06439996490f77569b02d1` | 与任务固定hash和原缓存一致；复制后再核 |
| 新解压bin/gradle.bat | 与ZIP内原件比对 | `af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab` | 真实GradleMain入口，非Wrapper |
| 同engine官方embedding POM | 2542 | `437cf27a8aa1829c07f81f43e0468a5fa05cef7dc21451cabd51b7a6914341ff` | 只复制既有原件，未抓取 |
| 同engine官方embedding JAR | 1541793 | `f6cb78578df77875f18f4d6c3bd29066288109935007e59d83e53ec85a8ce745` | 只复制既有原件，未抓取 |
| 旧未授权zip.part | 38302288 | `f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e` | 原位保留、前后hash一致；不复制/解压/执行/使用 |

完整ZIP共27,264条目。解压前检查绝对路径、越界根、父目录跳转、盘符、反斜杠、异常符号链接、大小写碰撞；均无阻断，ZIP CRC通过。完整安全解压到新目录，22,425个文件逐一与ZIP原字节SHA256及bytes匹配。全部文件映射LOCAL_ONLY保存。Gradle8.14启动JAR及GradleMain.class存在，分发init.d没有可执行init脚本。信任依据是Owner固定hash与既有原件一致，不冒称本轮在线发布者签名验证。

| 事件 | 实际时间（2026-10-23，+08:00） | 结果 |
|---|---|---|
| COPY_COMPLETED | 07:10:54.635 | 完整ZIP复制/解压和两份embedding复制结束 |
| HASH_VERIFIED | 07:16:20.688 | 22425文件、ZIP CRC、两工件验证通过 |
| GRADLE_BIN_READY | 07:16:20.689 | 入口hash、启动类及分发身份通过 |
| SAFE_OFFLINE_START_ALLOWED | 07:16:20.689 | 仅允许独立version，不进入项目钩子 |
| S1 START | 07:16:30.095 | 第一次且唯一一次Gradle启动 |
| S1 END | 07:16:30.639 | exit0 |
| S2/S3 STOP RECORDED | 07:17:10.260 | 解析/构建均未执行 |

只读登记初稿曾误含未登记重复解压缓存，已停止该元数据进程（exit1），按已登记对象和明确输入完成正式基线；原过程见baseline-scope-refinement.json。其间没有Gradle启动，不是重置执行预算。静态工作副本原字节断言曾因既有CRLF/LF差异失败，之后按规范Git字节匹配固定Blob；未改源码，说明保留。

## 3. S1唯一离线本体启动

真实入口是新目录内已核完整分发的bin/gradle.bat，未调用gradlew.bat或Wrapper jar。会话局部JAVA_HOME绑定原有JDK17；清除子进程继承的Java/Gradle注入选项并禁用自动JDK下载。采用空私有GRADLE_USER_HOME、无init、无项目构建文件的中性cwd，不改全局环境、代理或信任设置。

```text
<verified-gradle-8.14>/bin/gradle.bat --version --offline --no-daemon --console=plain
```

实际exit0，启动1次，约0.544秒。完整stdout/stderr/exit、真实执行路径、进程和hash保存LOCAL_ONLY。stdout摘录（不公开机器绝对路径行）：

```text
Gradle 8.14
Build time: 2025-04-25 09:29:08 UTC
Revision: 34c560e3be961658a6fbcd7170ec2443a228b109
Kotlin: 2.0.21
Groovy: 3.0.24
Launcher JVM: 17.0.18 (Eclipse Adoptium 17.0.18+8)
OS: Windows 11 10.0 amd64
```

Kotlin2.0.21是Gradle内嵌版本，不是项目Kotlin插件2.2.20被更换。没有Downloading输出、项目配置或仓库解析事件。离线启动证据是可信直接入口、空home/无init、中性cwd、版本模式及日志；未作全机抓包，不扩大为全部宿主网络或项目依赖图PASS。进程正常退出，没有停止共享Java/Gradle/ADB/Docker。

## 4. S2工具门阻断，S3不执行

正式任务S2.4明文要求：

> 若真实预检没有合法解析任务、只有动态定义或需要修改build源码，则以RESOLUTION_VERIFICATION_TOOLING_BLOCKED停止并交Owner，不擅自脚本修产品。

旧临时init中，projectsEvaluated内动态注册resolvePinnedDebugInputs是唯一已知定义；tracked项目配置/源码精确查询无同名定义。脚本SHA256为 `b77ccde95034ec94237e127d65eafb77263a2292a1672854d839cb05225be709`。本轮未将其装入新home，未创建/改写新任务或settings。依任务明文在S2执行前停止，解析预算0/1。

**RESOLUTION_VERIFICATION_TOOLING_BLOCKED / DEPENDENCY_RESOLUTION_NOT_RUN / NO_NEW_MISSING_COORDINATE_OBSERVED**。动态任务技术上可以有效；这是本轮授权工具条件未满足，不是Gradle机制缺陷。没有真实missing错误，不编造缺坐标或官方工件不可用结论，也没有依赖完整性PASS。

另有后续静态限制：固定build.gradle.kts Blob `5a08d63f5f95155ca1f346f9809683f6f35ac7e0`中，preBuild依赖syncFlutterAar（L151–152），该Exec构造内层gradlew.bat并调用（L121/124），诊断AAR输出仍采用产品工作树build路径（L107–108/120）。顶层换成直接Gradle bin不能排除此内层Wrapper路径。本轮禁止Wrapper且不准改构建源码、输出路径或切目标凑PASS，所以未执行该链。

S3 assembleDebug为NOT_RUN，预算0/1，不是build失败exit1。没有诊断APK；预期packageId、versionName、debug标志、AAR/入口、ABI、权限、签名和hash均ARTIFACT_NOT_VERIFIED。旧普通R1包不替代诊断APK。

## 5. 工件与测试分层

本轮再次解析已有POM：精确io.flutter:flutter_embedding_debug及固定engine版本，packaging=jar。JAR本地再核CRC通过、436条目和FlutterEngine.class存在。不是AAR，未伪造POM或重包flutter.jar。前轮官方源为storage.googleapis.com/download.flutter.io，本轮仅复用同hash原件；SHA256 sidecar前轮404、发布者签名未验证的限制保留，没有新网络校验。

| 子项 | 本轮等级 |
|---|---|
| 可信ZIP/完整解压/四闸门 | LOCAL_ACTUAL_VERIFIED，S0 prepare exit0 |
| Gradle8.14 --version | LOCAL_ACTUAL_EXIT0，唯一一次 |
| 同engine POM/JAR | LOCAL_REVALIDATED，同bytes/hash/metadata，CRC通过 |
| 依赖图/传递依赖来源 | NOT_RUN |
| 诊断debug APK及正向隔离身份 | NOT_BUILT / NOT_VERIFIED |
| 原20诊断测试、93普通回归、5项真实构建负例 | REUSED_VALIDATION，本轮未重跑 |
| 原普通R1控制APK | 旧原证hash未变，未覆盖/构建/安装，不是诊断包 |
| 真机/AVD/ADB、APP/RTC/Room.connect | NOT_RUN，0次 |
| DB/API/Laravel/guard/SFU/网络/防火墙 | 未操作/未启动 |

原R1、诊断、依赖补齐的所有失败和未授权part保留。本轮无新依赖下载、Wrapper调用、SDK升级、engine变化、源码/锁修改；CN/MC/JWT及5秒撤权合同、诊断无音频/白名单不变，AC05仍OPEN。

## 6. S4一次非作者复核与保护终检

一次非作者GPT-6.1 Sol/high静态复核，核对实际bin hash/路径、四闸门、S1日志/exit、S2.4与动态定义事实、内层Wrapper路径、embedding/part和保护回执范围。未发现高置信事实或解释错误，确认停止点。审阅者只抽核指定文件和回执，没有重hash全部22425分发文件或保护资产，未执行Gradle/网络/设备；不冒称独立完整实物验收或Astra ACCEPTED。

保护终检：1483份具名历史原证及显式输入bytes/SHA256全部一致；3193条工具链/env/lock/cache登记记录一致，其中3184全局Maven文件的hash和集合一致；五保护根HEAD/branch/index/status一致，首根仍153条历史长路径warning；495原refs未移。旧part原位同hash、不复制/使用；原可信ZIP、SDK/engine、private env、锁文件和已登记SQL/APK/备份原证受保护。未登记缓存仅只读，不宣称全盘逐字节覆盖，也不声称DB卷逐块证明。

新可信解压与合法产物保留LOCAL_ONLY；未清理任何历史资产，未reset/clean/stash/prune/force。只停止过本轮只读登记初稿进程；唯一S1启动正常结束。未启动设备或产品服务，不虚构运行后停服回执。

## 7. S5集中交付与下一门

只新增本报告和manifest，从73b3直接演进，普通nonforce发布候选。最终commit/唯一Parent/Root、两docs Blob原字节及完整apps/services映射与固定source同源，按独立REST/raw回读核验。最终自哈希不写入自身文档，固定身份见LOCAL_ONLY delivery-remote-readback.json及最终用户链接。不改main或ACTIVE_STATE，不集成产品。

剩余最小Owner/Astra决定是构建工具授权衔接：是否明确允许复用/修正临时解析验证器；如何在不调用内层Wrapper、产物不越出本轮目录的条件下执行诊断构建壳。若需调整构建脚本须另行明确授权。本轮不写替代任务、不覆盖Exec、不跳过同步/换目标，也不为未观测的缺项申请下载；无需据此改变RTC规划、网络、SDK或设备权限。

**GRADLE814_LOCAL_BOOTSTRAP_PASS / RESOLUTION_VERIFICATION_TOOLING_BLOCKED / NO_APK / OWNER_DECISION_REQUIRED / AWAITING_ASTRA_INDEPENDENT_REVIEW / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_AUTO_R2 / NO_P2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

已停止本轮新增执行，等待Astra独立复审，不自动继续解析、构建重试或手机安装。
