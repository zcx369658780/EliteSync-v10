# APP-M5-11｜独立synthetic host九文件源码准备

ISSUED；LEVEL 2（构建/环境边界，SOURCE-ONLY）。Assignee Codex 01a0ef77-af94-75e2-8726-87c04e082018，GPT-6.1 Sol/medium。唯一D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。先读根五authority、local-workflow、dirty-worktree、runtime-slice与M5-10 plan/work-review。本任务明确允许Git全仓branch/HEAD及porcelain状态前后各一次以保存现有状态；不读其它diff/index内容、不处理dirty文件。各旧任务预算不复用。

目标：落实M5-10首个九文件切片，只准备独立debug host模板与纯标准库合同校验器；当前contract/Gradle必须失败关闭保持RUNTIME_NOT_READY，不实现启动器、材料复制/下载或实际构建。不要虚构缺失receipt、依赖闭包或READY状态。

仅允许新增以下9文件，相对根apps/android_synthetic_demo/：
1 build-contract.json
2 settings.gradle.kts
3 build.gradle.kts
4 app/build.gradle.kts
5 app/src/main/AndroidManifest.xml
6 app/src/main/java/com/elitesync/syntheticdemo/MainActivity.kt
7 app/src/main/java/com/elitesync/syntheticdemo/BootstrapEndpointPolicy.kt
8 app/src/main/res/values/styles.xml
9 tools/validate_contract.py
及本目录summary.md。源码根或任何目标已存在/链接/路径逃逸则停，不覆盖、不清理。只创建这些文件所需目录；不得添加README、wrapper、properties、测试文件、缓存或其它交付。没有修改任何已有文件的授权。

允许新增前读取/固定哈希的来源：apps/android/build.gradle.kts、apps/android/app/build.gradle.kts；apps/android/app/src/main/java/com/elitesync/BootstrapEndpointPolicy.kt（SHA256 E25174137CC6ECEA990B3EFF09752C545A8E724AF052582C7CE0665A881E9FBB），MainActivity.kt；apps/flutter_elitesync_module/lib/main.dart、lib/main_demo.dart及lib/app/router/app_route_names.dart（只核对Home常量，勿扩读路由闭包）。不复制原manifest/资源/工程；不读真实properties或任何缓存/SDK目录；图谱定位本任务无需调用，准确路径已给定。

实现规格：
- JSON schemaVersion=1，applicationId/namespace固定com.elitesync.syntheticdemo，mode=debug，syntheticDemo为JSON boolean true，target=lib/main.dart，唯一Dart define ELITESYNC_SYNTHETIC_DEMO=true。工具路径沿M5-10常量；staging目录精确host/module/gradle-user-home/gradle-project-cache/pub-cache/user-home/temp/repo/receipts，不给用户任意绝对输出入口。artifact和未闭合输入/隔离门明确NOT_READY/UNRESOLVED；无AAR假hash、GAV或预置已验证receipt。声明receipt所需字段与将来逐项核验要求，但v1不得接受任何READY输入为运行授权。
- settings/root/app模板只属于新根，不include原host/module生成式runner，不读local.properties/gradle.properties、不读取环境/用户home、不注册Exec/flutter/wrapper任务；不提供mavenLocal、远端repo或shared AAR fallback。AGP8.11.1/Kotlin2.2.20只静态声明未知可解析，SDK36/min26/target35/Java17。精确receipt与输入/隔离未闭合时必须在settings的pluginManagement最前设置明确拒绝守卫，阻止插件解析；此版可无条件拒绝所有Gradle调用并说明SOURCE_SCAFFOLD_NOT_READY。不得制造执行该模板会解析插件的误导路径。后续真正receipt/变体/任务图闭合另立任务，本切片不宣称已实现安全构建图。
- app仅独立debug ID/namespace，host boolean synthetic=true、API/WS为policy固定loopback，非debug变体禁用模板；不消费flutter_release:1.0或未校验GAV。未定依赖只描述准确待receipt接口，不填可解析共享依赖。host源码需FlutterActivity的正式包/接口，但当前依赖NOT_READY，不宣称可编译。
- policy仅M5-07精确源码更改package衍生，其余语义/字节保持，摘要记录来源与输出hash及变更。MainActivity启动前require DEBUG与synthetic；bootstrap channel只支持getBootstrap，使用实际policy返回固定端点、Home常量、版本和debug字段；不读Intent/JSON/文件、不提供clearBootstrap，其它方法result.notImplemented。首次/新Intent保持安全固定行为，不加外部route覆盖。源码接线先于super onCreate执行debug/标记门。
- manifest最小Flutter embedding与唯一exported launcher Activity，allowBackup=false，不共享UID/provider/存储/深链。不复制原Application、Baidu/permission/network配置。合并层显式移除INTERNET/位置/相机/录音权限声明；只用新增platform主题styles资源。merged manifest和插件副作用仍NOT_CHECKED，不能声称完全无网络。
- validate_contract.py纯Python标准库。提供可直接调用纯校验函数和__main__ CLI，后者仅可读用户明确给定本契约路径（本任务测试固定新增路径），不启动子进程、不修改文件、不访问缓存/配置/设备。解析JSON拒绝重复键（含嵌套）和非有限常量，字段/嵌套结构严格allowlist、精确类型，不把1当True、1.0当schema int；缺/假/错标记、模式、ID、target、冲突/重复define、路径逃逸、未知字段或伪造READY状态拒绝。路径约束纯词法，固定字段比较；不对未知外部路径调用resolve/read/stat，工具常量仅字符串校验。不得把合同结构有效当artifact/运行READY。有效模板只能返回CONTRACT_VALID_RUNTIME_NOT_READY；执行/receipt准入函数或CLI明确拒绝本v1的未验证产物。不用宽泛except吞错或无条件PASS。

新验证预算：
A 一次九文件静态文件清单/禁止引用检查（限定新根）、一次新文件空白检查；可批量XML/JSON语法检查。九文件应精确，summary单独。禁止全仓rg/diff检查。
B 一次Python隔离标准库测试进程，python -I -B（可一次Get-Command python仅解析现有命令路径，不扫描替代工具），硬时限60秒、stdout/stderr各32KiB并行排空；inline测试不落新增文件、不写pycache。直接调用生产validator，至少12个有不同意义case：合法模板只NOT_READY；缺标记/false/string/1；release/profile/混合模式；冲突/重复define；JSON重复键/NaN；路径..、绝对/UNC或drive逃逸；错误ID/target、unknown字段、伪造READY/receipt。case数与预期拒绝明确记录。测试负例不得访问真实路径；非0/超时/截断即停，不修复重跑、不启动其它测试。没有Gradle/Flutter/Kotlin/JVM/设备预算，不能复用M5-07编译预算。

编辑有界完成后执行上述各一次预算，失败即停保留候选；不重复新进程验证。summary记录九文件输入/输出hash、static/parser/validator回执/数量/时间/限额/耗尽预算、工作区既有状态保留、SOURCE-ONLY和未证项。只交付候选，停Work独立LEVEL2审查，不自接受/派发后继/改authority。

禁止Gradle/Flutter/ADB/安装/运行/截图/logcat、UAC、真实properties/缓存/凭据/备份/密钥/DB/SSH/生产API/旧D:\EliteSync、网络材料下载或Git提交/pull/push。独立包不授权覆盖未知数据；M5仍NOT_READY，真实账号/Conversation/G08/G11/恢复门和旧预算不变。
