# APP-M5-17｜synthetic BuildInfo 参数材料

ISSUED；LEVEL2 SOURCE-ONLY；Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，local/D:\EliteSync-v10，Sol/medium，当前5 turns。
先读根authority/local-workflow、M5-16 plan/work-review，核Git/workspace；原预算全部关闭。

精确写范围：
- apps/android_synthetic_demo/tools/aar_material_functions.py
- apps/android_synthetic_demo/tools/test_aar_material_functions.py
- EVIDENCE/APP-M5-17-SYNTHETIC-BUILDINFO-MATERIALS/summary.md（唯一主要交付）
现有源码基线hash：977F605D32255757ABF2D5446F2EB3AA179156C31EE50B24608CC7289905D511 / 1034C01C2C52298AC96FC10D18BE74EAB1DD1AC4A3A724D23E93BEE7EA26522E。不一致先停；仅小扩展，保留M5-15行为，禁止改settings/v1/host/其它证据或源码。不读SDK/cache/config/env/其它源码。

实现准确keyword-only：
synthetic_build_info_arguments(*, track_widget_creation: bool, tree_shake_icons: bool, project_cache_relative_path: str) -> tuple[str, ...]
必需显式三个参数，无默认/通用extra/projectArg/override字典。两个bool严格type is bool；拒绝0/1、str、None等。cache复用已接受canonical POSIX相对路径字符域；可提取现有recipe路径校验小helper以避免重复，保持现有recipe行为。
返回准确顺序5项tuple：
1 已接受synthetic_define_argument()
2 -Pdart-obfuscation=false
3 -Ptrack-widget-creation=<小写true/false>
4 -Ptree-shake-icons=<小写true/false>
5 --project-cache-dir=<原样词法相对路径>
注释准确引用M5-16/build_info.dart:365–385。该tuple仅收窄BuildInfo片段，无完整AAR argv、shell命令、可执行器、实际cwd/path隔离或运行证明。保留recipe runtime_ready/binding false，不新增拒绝器。生产函数纯内存标准库，不文件/env/网络/进程访问。

测试扩展：四种bool组合固定独立预期（不得调用实现回算期望）、准确single synthetic编码/false obfuscation/顺序/tuple、必需keyword-only/未知extra关键字拒绝、严格bool负例、cache type及空/绝对/drive/UNC/反斜线/冒号/空段/./../尾分隔符/未知字符负例、合法边界原样保留；原12方法保留并同次运行，以验证小helper未改变recipe。不是重用M5-15旧预算，是本任务修改后的新必要回归。
无源码执行验证前可静态编辑；第一次验证失败即停，无修复重跑。

新预算：
- 实现完成后准确两文件静态审查1次（内容/hash/空白/禁止宿主调用），仅标准文件读取，无SDK/外部工具。
- 测试进程1次：C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe
  -I -B D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_material_functions.py
  cwd D:\EliteSync-v10；60秒硬限，两路各32KiB，异步读取；超时/超限/非零立即停，不修复、不重跑。静态失败不得继续测试。
测试只准确加载同目录生产module（已有importlib/sys.modules方式），无其它项目/环境读取和子进程，不写pycache。

summary记录精确差异、最终hash、两预算实际次数/退出/输出/超时/截断、测试方法计数，不把subTest夸大；失败也保存事实停独立Work LEVEL2审查。不自接受/后继/commit/pull/push。
保持dirty/untracked；禁止SDK/Flutter/Gradle/JVM/ADB/构建/安装/复制/下载/UAC、旧D:\EliteSync、真实properties/用户配置/cache、备份/密钥/DB/SSH/API/真实数据。M5与隔离构建NOT_READY，所有真实性/恢复门保持。