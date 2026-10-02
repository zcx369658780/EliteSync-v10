# APP-M5-10｜隔离synthetic调试工程实现合同

ISSUED；LEVEL 2（构建/环境边界，docs-only）。Assignee Codex 01a0ef77-af94-75e2-8726-87c04e082018，GPT-6.1 Sol/medium。唯一仓库D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；保留dirty/untracked。先核对根五authority/local-workflow与M5-07/08/09 review及本任务；这些入口读取不消耗下面源码两轮预算。唯一新增交付本目录plan.md；不改源码/配置/authority、不建目录或复制工程、不运行工具。

目标是把已接受M5-05的标记/AAR/端点合同，补为**不读取真实properties且不复用普通产物/应用数据**的可实施源码任务。不要重复旧设计；给精确文件清单、参数、闭合门、必要新预算和首个软件切片。优先在v10下新增独立synthetic debug工程，不让原工程Gradle配置读取本机properties，不改变普通构建语义。不得选择另一个未证明的共享runner包以绕过独立ID。

源码只读预算2轮，单轮可批量以下准确文件；不搜索目录、不索引工具链、不读任何properties内容或凭据。
第一轮：apps/android/build.gradle.kts、apps/android/settings.gradle.kts、apps/android/app/build.gradle.kts、apps/android/app/src/main/AndroidManifest.xml、MainActivity.kt、BootstrapEndpointPolicy.kt（后两项位于apps/android/app/src/main/java/com/elitesync/）；apps/flutter_elitesync_module/.android/settings.gradle、.android/build.gradle、.android/app/build.gradle、.android/app/src/main/AndroidManifest.xml。某指定文件不存在记录MISSING，不替代搜索。
第二轮：apps/flutter_elitesync_module/lib/main.dart、lib/main_demo.dart、lib/main_prod.dart、lib/app/bootstrap/app_bootstrap.dart、lib/app/config/app_env.dart、lib/core/storage/secure_storage_service.dart、lib/core/storage/local_storage_service.dart、pubspec.yaml、pubspec.lock，以及EVIDENCE/APP-M5-03-SYNTHETIC-HOST-ENTRY-CONTRACT/plan.md与APP-M5-05-SYNTHETIC-HOST-GUARD-DESIGN/plan.md。允许在这些文件内部定点重读/哈希，但总源码轮次不超过2。

合同必须明确：
- 独立applicationId com.elitesync.syntheticdemo（仅后继源码采用，当前未建立产物），普通com.elitesync不受改动；当前用户0未安装只作时间点事实，安装前另核。
- 只有debug synthetic；明确host/Dart单一来源，release/profile/混合或缺失冲突标记失败关闭，不静默进入prod。
- AAR单独输出/GAV与实际字节哈希及冻结Dart输入/标记回执；CI或已有共享flutter_release:1.0不能视作匹配。固定哪种AAR构建入口及其生成式中间目录，不能只隔离最终输出。
- 不复制真实local.properties、.android/local.properties、gradle.properties、init脚本、用户凭据或任何未知缓存配置；SDK/Flutter/JDK用明确非敏感路径提供。Gradle用户home、项目properties/自动配置、环境变量和依赖缓存怎样隔离；--offline和--no-pub各自不构成全部隔离证明。依赖不齐时记录NOT_READY，不提自动下载补齐。
- 应用私有数据/secure storage/shared prefs在新包隔离，端点与其它网络调用不得凭loopback字符串推断无网络；标明最小必要权限及需检查合并manifest的门。不能把移除INTERNET当已运行证明。
- 针对最小工程给准确新增源码/配置文件及来源复用清单，禁止递归复制整个原工程。区分可以静态实现的首个切片和后续有新预算的依赖解析、编译、签名/产物验真、安装与demo调试。

固定工具路径仅引用已知记录，不存在则UNKNOWN，不扫描：D:\flutter；C:\Users\zcxve\AppData\Local\Android\Sdk；JDK C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot；Gradle8.14分发C:\Users\zcxve\.gradle\wrapper\dists\gradle-8.14-all\5vwl8burbouivoo2kromnbp2p\gradle-8.14。版本/依赖可用性未证时准确标记。

禁止Gradle/Flutter/adb、构建/安装/运行、UAC、网络API/SSH/DB/真实备份密钥、旧D:\EliteSync或Git动作。仅交付plan及源文件哈希/行定位、2/2预算，停独立Work LEVEL 2审查；无自接受或后继。M5仍NOT_READY，不改真实账号/Conversation/恢复门与旧预算。
