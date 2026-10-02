# APP-M5-20｜纯module拓扑材料候选

2026-09-30；SOURCE-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。候选交付，未自接受；M5/隔离构建NOT_READY。

入口D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；当前ISSUED assignee 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad。169条既有工作区状态保留。两源码基线匹配task的29B34937F4CF09222234EEC9D101D387DB1859FB5182E863E623A33F947AA537 / 773526B50411949AD64E4180FDC7F28A60F4F5B8E5C54C7320B7A723DACF1C58；本summary预先不存在。

## 准确差异

仅扩展准确两Python文件并新增本summary。新增frozen/slots ModuleTopologyMaterials与keyword-only module_topology_materials；root复用_relative_path、include_app严格bool且参数必需。固定root_name android_generated；名称tuple依模板选择为(:flutter,)或(:app,:flutter)；flutter目录为词法root/.android/Flutter；app目录始终None；publication_module_name=:flutter。

excluded_plugin_candidate_names准确为(:app,:flutter)，仅表示modulePlugins过滤，不从发布排除:flutter，也不是完整插件allowlist。loader_binding_verified与runtime_ready为false。注释引用M5-19 include/settings、M5-18 ephemeral及M5-16筛选来源；不接收通用plugin/project/override/SDK路径输入，不生成Groovy/settings/完整argv或工程。旧编码/recipe/BuildInfo行为未改。

## 一次静态与最终hash

实现后一次准确两文件内容/import/hash/空白/禁止宿主调用检查，退出0，WHITESPACE_PASS=True、FORBIDDEN_CALLS_ABSENT=True。生产imports仍base64/dataclasses/re，测试仍dataclasses/importlib/sys/unittest。检查后未修改源码。词检查不是形式化宿主访问证明，独立Work仍须实审源码。

| 文件 | SHA256 |
| --- | --- |
| apps/android_synthetic_demo/tools/aar_material_functions.py | 7DEA9ABAA81E7B423B3312C8FE8B531C24EEE6F35A40981302786034406CA732 |
| apps/android_synthetic_demo/tools/test_aar_material_functions.py | E37E24484435C6A79D42A9791F80F43BACCED46029146E514FBF5861D03F1C82 |

静态新预算1/1耗尽；验证前只作静态编辑，首次验证后无修复。

## 一次测试回执

Executable C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe；参数-I -B D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_material_functions.py；cwd D:\EliteSync-v10。监控60秒硬限、异步双流，各UTF-8累计32KiB；超时/超限/非零即停。

实际启动1次，退出0，elapsed 0.1525929秒；stdout0/stderr2064字节；TIMEOUT=False、OUTPUT_LIMIT_EXCEEDED=False，工具回显无截断。unittest Ran 22 tests in 0.002s，OK；测试新预算1/1耗尽，无失败、修复或重跑。

原17方法同次全部通过。新增test_topology_fixed_choices、test_topology_immutable、test_topology_root_boundaries、test_topology_signature、test_topology_strict_bool，共5方法；覆盖两合法root×两模板选择的固定预期、名称顺序/Flutter大小写/None/排除集合/false标记、不可变slots及tuple、路径/类型/严格bool/必需keyword-only与未知关键字拒绝。22为方法数，不把subTest算独立测试数。只准确加载同目录生产module，-B不写pycache。

## 保留未解门

相对root只词法材料，不证明实际cwd/路径隔离；include_app是设计选择，不是SDK脚本bool分支；app目录未知与loader false不证明实际项目图。插件集合/目录、模板覆盖、publication/GAV/POM/任务图、完整输入依赖、工具身份、自动配置/父环境/系统网络隔离、AAR/host构建/签名/安装/首帧均未证，不由22个纯测试升级。

未读SDK/cache/env或其它源码，未改settings/v1/host/authority/旧证据，无Flutter/Gradle/JVM/ADB/构建安装/复制下载/UAC/真实数据/旧仓库/用户配置/真实properties/备份密钥/DB/SSH/API/Git写动作。M5/隔离构建NOT_READY；真实账号/Conversation/G08/G11/恢复保护门与所有旧预算保持关闭。候选及本证据停独立Work LEVEL2审查，不自接受、不创建后继。
