# APP-M5-10｜独立 synthetic debug 工程实现合同（候选）

状态：DOCS-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。结论：静态源码切片可另行派发；隔离构建执行 NOT_READY。本合同不授权建立工程、复制输入、读取缓存、解析依赖、构建、安装或运行。

仓库 D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。唯一新增本文件；保留既有dirty/untracked，无Git提交/pull/push。M5仍NOT_READY，真实账号/Conversation、G08/G11、恢复回填门及所有旧预算不变。

## 本次补齐的阻塞与准确来源

第一轮10个固定源码全部存在，批量只读内容与哈希；第二轮9个Dart/依赖输入及两份既有plan全部存在，读取内容/定点片段与哈希。两轮2/2耗尽，无目录搜索、SDK源码/未知缓存/任何properties内容读取，未运行Gradle/Flutter/adb。本任务入口authority与review读取不计源码轮数。引用旧plan只复用已接受方向，不重置其预算或把旧状态当当前状态。

- apps/android/app/build.gradle.kts:10–30实际读取真实local.properties及模块.android/local.properties，并从properties/环境找Flutter；40–84接受通用define、CI跳过及共享release产物；95–118原applicationId/默认false/正式端点。不得执行该工程或include它来生成synthetic。
- apps/android/settings.gradle.kts:28、30–38仍消费原模块repo/环境Flutter镜像；删除旧Maven探测不等于自动配置隔离。
- 模块.android/settings.gradle:5–12读取local.properties并include Flutter SDK Gradle build；30–31 evaluate未读include_flutter.groovy。模块.android/app/build.gradle:14–29使用共享runner ID并定义profile/release；34将buildDir放在模块build/host。不能改用这一共享runner包或只指定最终输出目录。
- main.dart:5–9缺失synthetic define会进入prod；main_demo.dart:20–41为mock/禁RTC/loopback:9，44–67写synthetic secure storage/profile再启动；app_bootstrap.dart:15–17会清理旧缓存。独立包隔离是避免写入/清理普通应用数据的前置门。
- MainActivity:30–44与70–99已接入M5-07策略，但默认false；synthetic仍读JSON非端点字段。独立demo host可更窄：不复用文件bootstrap、Intent route或clearBootstrap副作用。
- 原manifest:3–9有网络/位置/录音/相机权限，11–25引用原Application/资源/Baidu占位。不能整份复制；生成runner manifest:5–9含调试INTERNET，不能因此推定安全。

## 工程、输入和输出边界

拟议唯一源码根：D:\EliteSync-v10\apps\android_synthetic_demo。applicationId与namespace均com.elitesync.syntheticdemo；只有受控debug，普通apps/android及其com.elitesync构建语义不改。当前emulator-5554/user0未安装该ID只是M5-09时间点事实；未来安装前另核身份、用户及占用，遇既有包不自动清除/覆盖。

后继每次构建使用全新、无冲突且事前固定的任务工作根，例如本任务后继证据目录的work/。精确子目录：host/、module/、gradle-user-home/、gradle-project-cache/、pub-cache/、user-home/、temp/、repo/、receipts/。写入前检查绝对解析路径与链接不逃逸；存在未知内容即停，不清理、不重用。host项目目录、module/.android、module/.dart_tool、module/build及各插件构建目录、Kotlin编译缓存均须落在该工作根；仅最终repo/APK隔离不合格。原模块的.android、.dart_tool、build、普通repo/共享AAR不得复制或作为输出。

模块staging不得递归复制原工程。后继先下发精确逐文件允许清单：冻结pubspec.yaml/lock、lib中实际源码闭包和assets/config中精确资源、必要安全生成元数据；每条来源/目标/hash/用途须批准。本轮只有少量入口的读取权限，未枚举完整lib/assets或锁定插件源码，因此完整输入闭包 UNRESOLVED，不能凭本合同执行拷贝。依赖package_config必须在隔离工作根重建并固定，禁止直接复用绝对指向未知共享Pub cache的旧映射。插件缓存只接受后继逐文件授权与校验的不可变依赖材料；不复制用户配置或未知缓存目录。

## 单一意图与失败关闭

独立工程不提供通用flutterDartDefines入口。唯一意图字段syntheticDemo=true及mode=debug来自经审build-contract.json；启动器校验这两个值并生成host BuildConfig.ELITESYNC_SYNTHETIC_DEMO=true与Dart ELITESYNC_SYNTHETIC_DEMO=true。缺失、false、拼错、重复/冲突保留键、外部-P/ORG_GRADLE_PROJECT_*注入、profile/release/混合请求均在子进程启动前拒绝，不能回退prod。原main.dart的默认prod行为保留；独立构建严格要求true，不能把原默认分派视为安全门。

host禁用非debug变体并只允许准确assembleDebug任务；任务图检查必须拒绝release/profile、多工程及不在闭包内的任务。Gradle静态模板与启动前校验都必须实现，不能依赖任务名称字符串单独证明图谱。本合同未验证AGP变体API实现，首切片仅模板，图谱行为须新预算验证。

## AAR入口及产物身份

选择Flutter模块AAR路线，不选择共享runner，也不绕过现有main.dart分派。候选参数列表为固定D:\flutter\bin\flutter.bat、build、aar、--debug、--no-profile、--no-release、--no-pub、--dart-define=ELITESYNC_SYNTHETIC_DEMO=true，cwd只能是新module staging。APP-M5-03已记录AAR target固定lib/main.dart；不能虚构可选main_demo target。当前CLI选项支持、Flutter实际Gradle调用/自动生成步骤及输出GAV未在本任务验证，上述参数是待SDK兼容性核对的实现合同，不是当前GO命令。

关键运行前门：Flutter可能在同一次build aar中生成.android并立即调用Gradle。必须先通过另行授权的准确SDK源码/生成模板核对，证明如何在调用Gradle前置换或校验受控.android配置、禁用wrapper下载、固定Gradle分发及用户home、控制自动properties/工具设置；不能依赖调用结束后的检查。若没有可验证的截断/分步入口或受控生成方案，该Flutter命令不得启动，保留NOT_READY；不能临时调用wrapper或修改全局SDK来试错。

新module/.android中的local.properties仅可由已审工具常量生成flutter.sdk=D:/flutter、sdk.dir=固定Android SDK，不复制任何真实properties；生成式settings/include_flutter/plugin构建文件须逐文件受审。原真实properties不读取。该受控文件读取与“绝不读取真实properties”不矛盾，但它不能解除Gradle自动加载其它配置的门。

独立最终GAV拟定com.elitesync.syntheticdemo:flutter_debug:<input-id>，repo仅工作根repo/，不使用flutter_release:1.0。input-id为规范化receipt输入清单的SHA-256，包含完整Dart/assets清单、lock、SDK/engine/工具身份、target=lib/main.dart、debug和define；GAV命名本身不证明内容。Flutter实际输出先隔离在module/build/host/outputs/repo，逐项固定AAR/POM及所有伴随依赖hash。若Flutter不支持该GAV，需经审单独重发布：只复制准确新生成AAR字节，显式重写/核对POM坐标与依赖闭包，不凭移动目录假定合法Maven发布，不改AAR内部内容。原始GAV与最终GAV及字节映射均入receipt；未核定真实输出结构/POM则停。host只解析独立repo中的准确GAV，并以解析回执核对实际AAR SHA-256；缺失receipt、哈希变化、shared AAR、CI跳过、缓存命中不明均拒绝。

## 工具、自动配置与缓存隔离

固定非敏感工具位置：D:\flutter；C:\Users\zcxve\AppData\Local\Android\Sdk；C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot；Gradle8.14分发C:\Users\zcxve\.gradle\wrapper\dists\gradle-8.14-all\5vwl8burbouivoo2kromnbp2p\gradle-8.14。本轮仅引用记录，无存在/版本/engine/Android组件可用性新检查，当前UNKNOWN。AGP8.11.1/Kotlin2.2.20只是原源码声明，不证明能离线解析或与工具兼容。

后继启动器使用环境白名单，从空映射构建子进程环境，明确Java/Android/Flutter及TEMP/TMP、PUB_CACHE、GRADLE_USER_HOME、受控HOME/USERPROFILE/APPDATA/LOCALAPPDATA；仅增加Windows进程启动确需的固定系统路径字段，不传父环境凭据/代理/CI/FLUTTER_STORAGE_BASE_URL/PUB_HOSTED_URL/GRADLE_OPTS/JAVA_OPTS/JAVA_TOOL_OPTIONS/_JAVA_OPTIONS/JDK_JAVA_OPTIONS/ORG_GRADLE_PROJECT_*。确需工具设置须逐项批准。子进程-Java user.home固定到隔离user-home，不能读取个人.android/debug.keystore或Flutter用户配置；debug签名密钥只在隔离根生成并另核hash，不用真实签名材料。

Gradle明确--gradle-user-home、--project-cache-dir、--no-daemon、--no-build-cache、--no-configuration-cache、--offline，直接固定分发入口而非wrapper；JAVA_HOME固定，不自动JDK下载。用户home空且受控，无init.gradle/init.d/gradle.properties；项目及父目录自动加载的gradle.properties/settings、Gradle分发init.d、SDK/Flutter工具可能加载的用户配置均须另立准确入口检查。不能认为-g只隔离全部自动配置；分发init脚本本任务未读，UNKNOWN。独立工作根若落在仓库父目录中，仍须验证实际Gradle自动配置范围；无法证明则采用经审独立根或中止，不能读取真实properties“确认一下”。

依赖材料必须通过另行受限清单准备：AGP/Kotlin/Flutter embedding/engine及所有插件的准确版本/hash/POM，隔离Gradle/Pub缓存或本地repo，禁止mavenLocal、用户repo、共享产物引用和自动下载。--offline只约束Gradle依赖解析，不能阻止配置脚本/Exec任意网络；--no-pub只跳过Pub求解，不隔离Flutter缓存/生成Gradle或插件构建。所有嵌套子进程须受同一环境/工作根/网络禁止措施约束；SDK首次下载、engine/NDK组件缺失、插件依赖不齐即NOT_READY，不自动补齐、不复跑。实际操作系统访问/网络封闭机制尚未固定；不能以文档环境白名单宣称已隔离。

## 独立host最小实现与数据/网络门

新增host不用原Application、Baidu、Retrofit、地图资源或原manifest。MainActivity使用FlutterActivity；启动前require DEBUG与host synthetic；bootstrap channel只返回固定policy端点、固定Home初始路由及版本，不读取外部Intent/JSON，不提供原应用文件清理；其它方法明确拒绝。复用M5-07纯policy的准确源码与hash，改package到独立namespace的单文件衍生必须明确记录，不复制整个java目录。

应用allowBackup=false，不配置sharedUserId，不引入普通包provider authority/共享storage/exported数据组件；launcher是唯一必要exported Activity，不带原深链。独立ID使私有目录、SharedPreferences及secure-storage/Keystore作用域具有分离基础；插件具体实现及合并manifest必须在新门核对，不能仅从ID推断所有跨包/外部媒体隔离。demo会实际写token/profile并清理该包缓存，绝不在普通包测试；不读取或迁移普通包数据。

初始UI演示合同以无网络、无位置/相机/录音权限为目标，manifest不声明这些权限且合并层明确移除依赖所加权限；不得复制原network_security_config。调试Flutter可能需要INTERNET用于VM service，若需要hot reload必须另审具体网络/权限和新预算；当前最小首帧任务不自动要求hot reload。移除INTERNET仅作为产物检查之一，不证明已运行无网络，也不能保证所有native插件无初始化副作用。pubspec有url_launcher、image_picker、video_player、permission_handler、livekit等，mock标记并不消除插件注册与其它调用风险；插件原生注册闭包、合并manifest/provider与行为须新审，未核定不能安装。

## 准确首个源码切片（建议另立ISSUED，不在本轮实现）

只新增以下9文件于apps/android_synthetic_demo/，不得改原工程：
1. build-contract.json：固定schema、独立ID、debug、true、工具路径、staging相对目录、输入清单/receipt结构；artifact暂标NOT_READY。
2. settings.gradle.kts：独立rootProject/include(:app)，不include原host/.android，repo仅待校验隔离材料；缺receipt就失败，不设远端fallback。
3. build.gradle.kts：固定AGP8.11.1/Kotlin2.2.20声明及禁止其它任务/工具链下载的接口。
4. app/build.gradle.kts：独立ID、SDK36/min26/target35、Java17、debug-only及host true；精确receipt GAV消费，不调用普通syncFlutterAar；不存在已审AAR即失败。
5. app/src/main/AndroidManifest.xml：最小Flutter embedding、无原权限/深链、allowBackup=false，合并权限移除声明。
6. app/src/main/java/com/elitesync/syntheticdemo/MainActivity.kt：上述固定bootstrap行为与fail-closed debug门。
7. app/src/main/java/com/elitesync/syntheticdemo/BootstrapEndpointPolicy.kt：仅由已读M5-07 policy准确衍生，不引入原host源集。
8. app/src/main/res/values/styles.xml：新增最小原生平台主题，不复制未读原资源。
9. tools/validate_contract.py：纯标准库校验schema/固定模式/参数/路径约束与receipt拒绝；本切片不执行子进程、不生成/复制staging、不读用户properties/cache。

来源复用清单只含：M5-07 policy字节与接线思路、main.dart分派/原Dart源码冻结需求、原Gradle已读SDK/插件版本声明；main_demo/app_bootstrap/存储实现作为后续模块输入而非改写来源；manifest及styles新写。完整模块输入清单、isolated AAR launcher、SDK生成适配、依赖准备器、合并manifest验证器另立，不假装本9文件已能构建。

建议首切片预算：单次源码写入、一次静态文件/禁止引用/空白核对、一次纯标准库validator人工负例（缺标记、release/profile/混合、冲突键、路径逃逸、未知receipt均拒绝），不运行Gradle/Flutter/ADB。候选LEVEL2独立审查，接受后才另立运行任务。

后续门按顺序另立：①固定SDK自动生成/Gradle调用语义与完整模块/插件输入清单；②受限依赖材料和工具身份只读准备；③隔离配置/任务图解析（一次，失败即停）；④AAR生成一次与byte/POM/GAV验真；⑤host assembleDebug一次、合并manifest/签名/ID/标记/AAR绑定验真；⑥同模拟器/当前用户/占用新复核，Owner授权与独立门通过后安装一次；⑦demo首帧有界运行。具体时限/输出/产物/停点须每张任务固定，不能从本合同继承执行预算。任一输入/依赖/配置来源不明即NOT_READY，不自动重试/下载或越门。首源码切片可准备，步骤③以后当前均NOT_READY。

## 两轮源哈希（本轮固定）

| 路径（仓库相对） | SHA-256 |
| --- | --- |
| apps/android/build.gradle.kts | F4DB52252E3F16CDB2EE6B783AB3330366534D236024CE69AD6924C136133461 |
| apps/android/settings.gradle.kts | 781C2CDBD80B6F0ADD4ACE7A67CD84EDC7B49071238C21399BD6B8AB131438C1 |
| apps/android/app/build.gradle.kts | 0B667C458BC45E213F36F9C0C7D25960EA9A900FD309B983890AE2A7668FBA5B |
| apps/android/app/src/main/AndroidManifest.xml | 1923E66B50EEDCB613856665735662A887C0A0A5679110E7E4560CC783767405 |
| apps/android/app/src/main/java/com/elitesync/MainActivity.kt | 96500063E7728CFB50AD196744AFFA0B6FDE0080045AA69BA0DF8EBD340CAD27 |
| apps/android/app/src/main/java/com/elitesync/BootstrapEndpointPolicy.kt | E25174137CC6ECEA990B3EFF09752C545A8E724AF052582C7CE0665A881E9FBB |
| apps/flutter_elitesync_module/.android/settings.gradle | 58ED6CF1A5FF74237DBA2C0DBBD19669AEEEA145C2F442462B04C20541A8F609 |
| apps/flutter_elitesync_module/.android/build.gradle | 5A611DADB1C89E576BD50D964EFEB52B0AC9883FB4773E594BF75C37979AB760 |
| apps/flutter_elitesync_module/.android/app/build.gradle | 880E8F96916520DF0854AECA56E63650AC58C344D5F9EB8144875E11911D1FC7 |
| apps/flutter_elitesync_module/.android/app/src/main/AndroidManifest.xml | 8F3733DE037BB59E8A4DDAE6BED39ECE45194DD0C877FD44DCAD735B754712CA |
| apps/flutter_elitesync_module/lib/main.dart | F0F4A6C112774AE0EE78D47B4FFAFD6CF20250B1CA5B6EE112AC4A4EB2BF2B54 |
| apps/flutter_elitesync_module/lib/main_demo.dart | F542C28670BB3D9C28B4D5DF43E93FBCBD144FCB266FDFB91B9B94789B422D02 |
| apps/flutter_elitesync_module/lib/main_prod.dart | AB5AD23F7E00BA195EB8FF11EB1E052739BDA53FE5B7DB33682A67F25BFA9C78 |
| apps/flutter_elitesync_module/lib/app/bootstrap/app_bootstrap.dart | 051BEC691642CDE8F94B4DB084C11AEC7C64FA478D769CF23524BBD7F7F45F7B |
| apps/flutter_elitesync_module/lib/app/config/app_env.dart | C53A449036D50FF9F51363FE73103F22544B610D2B4C83CA1C32BBCC1DCFCD32 |
| apps/flutter_elitesync_module/lib/core/storage/secure_storage_service.dart | 6896ECAD91C88A5DAD884C8A1558A931B6819ED44C203F7052B34EFFB2AB69E2 |
| apps/flutter_elitesync_module/lib/core/storage/local_storage_service.dart | 410BA0E3437A32417E4CE4ED4C81FB33B11934B38A3606024100A9AA5A283F9A |
| apps/flutter_elitesync_module/pubspec.yaml | ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC |
| apps/flutter_elitesync_module/pubspec.lock | 9D392F33B4324149B282AA62721D642D37A4BD5E1677DB403CB5A7373C385EEE |
| EVIDENCE/APP-M5-03-SYNTHETIC-HOST-ENTRY-CONTRACT/plan.md | 29FF5F4E2C8326E98D251EA0C11DC436DE0B12B38C99B84C633FAE85B60D2E95 |
| EVIDENCE/APP-M5-05-SYNTHETIC-HOST-GUARD-DESIGN/plan.md | E0C6474F94BDBA2A6C54F1E88B5188118A224A94E6DF06889EF5E78F5BC476C5 |

只交付本plan，停独立Work LEVEL2审查。不自接受、不派发后继，不把拟议路径/参数/合同说成现成可运行产物。
