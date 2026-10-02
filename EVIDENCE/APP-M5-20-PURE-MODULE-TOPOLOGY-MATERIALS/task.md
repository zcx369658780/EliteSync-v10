# APP-M5-20｜纯 module 拓扑材料

ISSUED；LEVEL2 SOURCE-ONLY；Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，local/D:\EliteSync-v10，Sol/medium，当前8 turns。
先核根authority/local-workflow、M5-19 plan/work-review及M5-17 summary。M5-19 DOCS-ONLY ACCEPT，1/1关闭；全部旧预算保持耗尽。

精确写范围：
apps/android_synthetic_demo/tools/aar_material_functions.py
apps/android_synthetic_demo/tools/test_aar_material_functions.py
EVIDENCE/APP-M5-20-PURE-MODULE-TOPOLOGY-MATERIALS/summary.md（主要交付）
现有两源码基线分别29B34937F4CF09222234EEC9D101D387DB1859FB5182E863E623A33F947AA537 / 773526B50411949AD64E4180FDC7F28A60F4F5B8E5C54C7320B7A723DACF1C58，不一致停，不覆盖其它内容。不读SDK/cache/env/其它源码，不改settings/v1/host/旧证据。

新增keyword-only module_topology_materials(*, module_relative_root: str, include_app: bool) -> frozen/slots immutable record。
- 两参数显式必需；root严格str，复用已审canonical POSIX词法相对路径helper；include_app严格type is bool，拒绝0/1/str/None。
- root_name="android_generated"。
- project_names为include_app false时(":flutter",)，true时(":app",":flutter")；顺序表示所选模板静态include顺序，不宣称实际Gradle项目图。
- flutter_project_relative_dir=root+"/.android/Flutter"，精确保留大小写。
- app_project_relative_dir=None：已证来源无显式app绑定，此字段始终未知，不生成惯例目录。
- publication_module_name=":flutter"。
- excluded_plugin_candidate_names=(":app",":flutter")：只表示M5-16 modulePlugins过滤排除，不是从发布排除（:flutter仍是发布模块），也不是完整插件allowlist。
- loader_binding_verified=False，runtime_ready=False。record只材料，不执行准入器，不开放通用project/plugin/override/SDK路径输入。
- include_app只表示ephemeral vs library-copy settings的设计选择，不是SDK脚本按bool分支；root相对路径仅词法，None/False不证明隔离或实际项目图。
注释引用M5-19 include:16–17、settings:3–5及M5-18 ephemeral:27–31、M5-16:169–171。生产函数纯内存标准库，无文件/env/网络/进程访问。不生成Groovy/settings/完整argv/工程。

测试：两个合法root×两include_app固定独立预期（不调用实现回算），精确Flutter大小写/names顺序/None/排除集合/false标记/frozen；root类型及全部既有路径域非法边界；bool严格；位置/缺参数/未知plugin/project/override关键字拒绝。原17方法保留同次必要回归。
小扩展避免重复路径校验；不改已接受编码/recipe/BuildInfo行为。

新一次性验证：
1 实现后一次准确两文件静态（内容/import/hash/空白/禁止宿主调用检查），失败即停不测试。
2 一次固定Python测试进程：
C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe
-I -B D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_material_functions.py
cwd D:\EliteSync-v10，60秒硬限、异步两流各32KiB；超时/超限/非零即停，不修复/重跑。仅准确两文件加载，无其它项目/env读取或子进程，不写pycache。验证前可静态编辑；验证后不修源码。

summary记录准确差异/hash/预算次数/退出/测试方法数/双流量/超限超时截断和未解门，失败也交事实停Work独立LEVEL2审查。不自接受/后继/commit/pull/push。
保留dirty/untracked；无SDK/Flutter/Gradle/JVM/ADB/构建/安装/复制/下载/UAC，禁旧D:\EliteSync、用户配置/真实properties/cache、备份/密钥/DB/SSH/API/真实数据。M5/隔离构建NOT_READY，真实账号/Conversation/恢复门不变。