# APP-M5-19｜module引入与拓扑来源候选

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。:flutter名字与projectDir的源码绑定已建立，脚本通过properties定位SDK loader与included build；插件集合、实际publication/POM与路径隔离仍未闭合。M5/隔离构建NOT_READY。本文不执行脚本，不生成可执行工程或命令。

入口D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；当前ISSUED assignee 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad。168条既有工作区状态保留。唯一新增本plan，不改源码/authority/旧证据或Git状态。

## 一次新来源预算

准确三个文件由M5-18清单定位，不枚举替代路径。一次批量、每文件一次内存读取/hash，新1/1耗尽。退出0，状态/字节/hash先完整输出，全文逐行回显，无工具截断/缺失/读取或输出失败。每文件小于16KiB，总stdout在12KiB内（正文预检不超过11000 UTF-8字节并预留状态空间）。没有读取脚本所指真实properties、插件/JSON/注册内容，没有重跑M5-18清单或其它旧来源。

模板根D:/flutter/packages/flutter_tools/templates/module/android/：

| 来源 | 字节 | SHA256 |
| --- | --- | --- |
| library_new_embedding/include_flutter.groovy.copy.tmpl | 1618 | B38E39873B391391B3CB51AC537E866FD084B16B6A0BD805EC89B5B7940815A8 |
| library_new_embedding/settings.gradle.copy.tmpl | 175 | 3EB5746A9C7A6BCD1F6FD338D7C9D95F41BFAFB2F4DFC75F3D11F0DA51322B56 |
| gradle/src/main/AndroidManifest.xml.tmpl | 119 | 69AE25951BDD7722CA2D4C604EED9ACEA639C7003304D089EB5CB4876A770804 |

## 引入脚本逐行事实

include_flutter.groovy.copy.tmpl:1–14有两条调用方式：若binding没有gradle变量，gradle=this，用gradle.buildscript.sourceFile的两级父目录absolutePath求flutterProjectRoot；否则取binding.gradle，用自身class protectionDomain.codeSource.location.toURI转换File后取两级父目录absolutePath。脚本依赖宿主对象与代码来源位置，不是任意相对字符串即可保证根绑定。注释4–6区分apply from与旧setBinding方式，不能当运行证明。

16明确include :flutter；17把其projectDir设为new File(flutterProjectRoot, ".android/Flutter")。这是现在已核定的名字/目录绑定，大小写Flutter有意义。没有从文件系统确认路径存在或链接安全，没有执行绝对路径计算。

19–24构造模块根下.android/local.properties，断言存在，以UTF-8读入Properties；错误消息建议运行flutter pub get，但脚本这里没有自行执行pub get。26–27取flutter.sdk并断言非null；没有由这些行证明SDK路径版本、可信性、非空/不可逃逸或固定为D:/flutter。28 apply from SDK路径下packages/flutter_tools/gradle/module_plugin_loader.gradle；30–32在pluginManagement里includeBuild SDK的packages/flutter_tools/gradle。

隐式副作用入口分别为include/projectDir配置、properties读取、外部loader求值和included build加载。此脚本没有直接显示插件JSON读取、插件项目include或下载规则；那些可能发生在未读loader/Gradle配置中，不能写成已核完整行为。这里未直接读取env或cache，亦不能据此宣称外部脚本/构建无env/cache访问。

settings.gradle.copy.tmpl:3 rootProject.name=android_generated；4设置binding.gradle=this，5 evaluate settingsDir/include_flutter.groovy。与上述第二分支连接。此copy settings没有:app include；M5-18 host_app_ephemeral/settings.gradle.tmpl:27明确include :app，29–31再设同rootName/binding并evaluate include脚本。因此:app存在取决于所采用settings模板与生成覆盖，不能把仅library copy settings当作含app的实际工程。

没有本组三源中的显式app projectDir；M5-18 app.tmpl的目标映射和Gradle默认目录行为尚未运行/完全核定，不能用惯例补成来源事实。rootProject.projectDir/根buildDir与插件目录也无本轮显式绑定。

## manifest与发布筛选对照

gradle/src/main/AndroidManifest.xml.tmpl:1–3仅manifest namespace与package={{androidIdentifier}}；没有uses-permission、application或tools合并指令。空模板不取消M5-18已读library/host manifest的INTERNET，不保证最终合并无权限/组件；root template manifest如何参与构建/合并、实际应用包与合并输出未证。

M5-16发布脚本非plugin分支会排除root.name==gradle，再查直接subproject名字flutter；本轮settings明确android_generated、include脚本明确:flutter，提供源码接线匹配。它没有核实最终root settings覆盖、loader是否加入其它同名/额外项目、library插件评估成功或任务存在。

发布modulePlugins集合是所有直接子项目中非flutter/app者。:app（如由ephemeral settings引入）被排除；:flutter作为模块。未知loader实际插件名字、projectDir、native平台筛选与其它子项目仍缺来源，不能把发布脚本筛选等同严格插件allowlist。本轮引用精确module_plugin_loader.gradle路径只是来源定位，不授予读取；真实JSON/插件内容同样未读。

M5-18 library模板group/namespace={{androidIdentifier}}、project.version=1.0保留；新projectDir绑定不能证明pub.artifactId默认flutter、pub.name与component名相同、project版本到pub.version/POM的实际绑定。M5-15版本提案及publication/component分离继续适用；runtime_ready/publication_binding_verified false不得升级。

## 下一实质纯拓扑材料切片

建议准确扩展已有两文件：apps/android_synthetic_demo/tools/aar_material_functions.py与test_aar_material_functions.py。新增keyword-only module_topology_materials(*, module_relative_root: str, include_app: bool) -> frozen immutable record。

输入root仅canonical POSIX相对词法路径，复用已接受字符域；include_app严格bool且必需。输出root_name=android_generated；有序project_names为(:flutter,)或(:app,:flutter)；flutter_project_relative_dir为原样module_relative_root + "/.android/Flutter"；app_project_relative_dir=None，因为本轮没有显式app目录绑定来源。另给publication_module_name=:flutter、excluded_publication_names=(:app,:flutter)，以及loader_binding_verified=False、runtime_ready=False。这些是可审查的拓扑记录而非完整settings/执行器。

include_app=true代表自有选择ephemeral settings的收窄意图，false代表library copy settings；不是脚本会按这个bool自行分支。未证app目录不能用None变相接受运行，接口文档必须说明它只是命名材料。独立受控工程以后可以另行指定app目录，但需明确是新设计，不由本来源默认推定。

固定允许名称仅:flutter与可选:app；本切片不接受任意plugin/project列表、override字典、外部SDK/loader路径或绑定Gradle对象，不拼Groovy执行字符串。拒绝未知关键字、错误类型与路径域外输入。不能将自有“不接收插件输入”冒充SDK原生禁止插件；SDK实际上应用loader，只是其行为当前未读齐。record的未知标记不是又一执行准入器，接口不提供executionReady或启动功能。

冲突规则：名称和:flutter目录后缀由函数常量产生，不能由caller改写成app/同名插件；module_relative_root必须无绝对/drive/UNC/空段/./../反斜线/冒号/尾分隔符/注入字符，返回不resolve/stat。相对材料不证明真实cwd、reparse或隔离。此函数会产生随root和include_app变化的拓扑及明确来源映射，不只是固定identity字符串。

正例固定两个root与两种include_app组合，核定大小写Flutter、名称顺序、excluded集合与None、frozen不可变。负例0/1/str/None作为bool；root非str/空/非法路径/Unicode/引号/换行/Groovy插值；位置参数/缺参数/未知plugin或override关键字；明确禁止将未知app目录断言为已绑定。原17方法同次回归以保持已接受编码/recipe/BuildInfo行为。建议新预算一次两文件实现、一次纯标准库目标测试、一次两文件静态检查，具体硬时限/双流上限由Work新task固定；本任务不实现/运行测试、不创建后继。

## 剩余门与停止状态

未读SDK loader实现、实际插件JSON/注册与所有Dart/assets/native输入，settings覆盖/模板转换的完整语义、app/root/plugin目录、实际publish任务图/GAV/POM/依赖闭包、工具身份、配置/环境/系统网络隔离均未闭合。不能从路径/hash/静态include证明可以生成或构建。复杂受控settings替换、SDK loader替换及完整生成器须另审。

本次无Groovy/Dart/模板/算法/测试/工具执行，无复制/下载/目标生成/构建/ADB/安装/UAC；未访问其它SDK/cache/config/env/home/真实properties/JSON/注册、旧仓库、备份/密钥/DB/SSH/API/真实数据或Git写动作。新1/1关闭，所有旧预算保持。唯一plan停独立Work LEVEL2审查，不自接受或后继；M5/隔离构建NOT_READY，真实账号/Conversation/G08/G11/恢复保护门不变。
