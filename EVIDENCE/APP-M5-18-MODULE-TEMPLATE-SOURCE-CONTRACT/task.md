# APP-M5-18｜module 模板来源合同

ISSUED；LEVEL2 DOCS-ONLY；Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，local/D:\EliteSync-v10，Sol/medium，实际6 turns。先核根authority/local-workflow与M5-17 review、M5-13两份保存source-receipt。M5-17源码ACCEPT，静态/测试各1/1关闭，所有旧预算不重置。
唯一新增本目录plan.md，不修改源码/authority/旧证据。

准确定位依据：旧同次project.dart:865、869、896、900的module/android四逻辑名；template.dart:29–35以flutterRoot/packages/flutter_tools/templates/name连接，均已保存回执。新预算仅官方模板源码，不读生成出的真实properties或cache/config。

新只读预算共两轮：
1. 一次批量目录结构清单，仅以下四根：
D:\flutter\packages\flutter_tools\templates\module\android\host_app_common
D:\flutter\packages\flutter_tools\templates\module\android\host_app_ephemeral
D:\flutter\packages\flutter_tools\templates\module\android\library_new_embedding
D:\flutter\packages\flutter_tools\templates\module\android\gradle
只枚举这四目录内相对路径、普通文件长度/类型，不读取内容；递归遇reparse不进入，记录停该分支。合计上限100项，stdout8KiB，超限或缺目录记未覆盖，不搜索替代路径/父目录/其它SDK位置。失败即停不重试。
2. 从第一轮实际清单选最多8个准确普通模板文件，各一次内存读取/hash；限build.gradle.tmpl/build.gradle.kts.tmpl、settings.gradle.tmpl/settings.gradle.kts.tmpl、gradle.properties.tmpl、AndroidManifest.xml.tmpl（路径必须存在于清单，不能猜补；名称大小写按实际文件）。每文件16KiB上限，总正文24KiB；状态/hash先输出，工具预算覆盖小输出，不截断重跑。其它文件只记录清单存在，不读内容。若允许名称没有覆盖必要事实则UNRESOLVED，禁止扩大。

plan要求：
- 模板路径/hash与逐文件实际语义定位；区分source目录映射、生成目标目录、占位变量与真实值，不执行渲染。
- default group/artifact/project name/version、root/module buildDir、settings子项目/插件引入、SDK/Gradle配置、manifest来源等仅按可读模板事实；与M5-16发布接线/M5-15版本proposal对照。没有明确pub.version/POM绑定仍UNRESOLVED，不借默认约定假称已证。
- 未读模板/源码/注册/依赖闭包/自动配置和环境隔离缺口；存在不证明能生成/构建。
- 唯一下一有事实增量软件切片，给准确路径、接口、正负例与必要新预算；优先以明确模板事实生成可审的纯内存材料，不能只叠拒绝器。复杂生成/隔离方案须另审，不能从本plan放行。
- 两轮实际次数/状态/退出/输出/覆盖、缺失和sourcehash；失败也保留唯一plan事实停独立Work审查。

不能执行模板/算法/测试/工具、复制或生成目标文件、构建/ADB/安装/下载，不读其它SDK/cache/config/env/home/真实properties/备份/密钥/DB/SSH/API/旧D:\EliteSync，不UAC/Git写。保留dirty/untracked。唯一plan交付停LEVEL2独立审查，不自接受或后继；M5/隔离构建NOT_READY，真实账号/Conversation/恢复边界保持。