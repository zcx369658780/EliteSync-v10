# APP-M5-17｜synthetic BuildInfo材料候选

2026-09-30；SOURCE-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。候选完成，停独立审查，未自接受。M5/隔离构建仍NOT_READY。

入口D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；当前ISSUED assignee 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad。166条既有工作区状态保留。本summary预先不存在；两源码基线哈希分别匹配task的977F605D32255757ABF2D5446F2EB3AA179156C31EE50B24608CC7289905D511与1034C01C2C52298AC96FC10D18BE74EAB1DD1AC4A3A724D23E93BEE7EA26522E，匹配后才编辑。

## 准确差异

仅扩展apps/android_synthetic_demo/tools/aar_material_functions.py与test_aar_material_functions.py，并新增本summary。新增keyword-only synthetic_build_info_arguments：三个显式必需参数、严格bool与canonical POSIX相对cache字符串；返回准确五字段tuple，顺序为固定synthetic define、false obfuscation、track-widget-creation、tree-shake-icons、project-cache-dir。bool使用小写true/false。源码注释引用M5-16/build_info.dart:365–385。

抽取_relative_path供recipe和新函数复用，保留原字符域与词法校验行为。原编码、publication/component分离、版本提案以及runtime_ready/publication_binding_verified false不变。无extra/projectArg/override接口。tuple只为BuildInfo片段；相对cache原样字符串不证明实际cwd、路径隔离或工具执行。

## 静态与最终哈希

实现后准确两文件静态检查1次，退出0；内容/import检查、哈希、行尾空白/末尾换行及禁止宿主调用词检查通过。生产仍只导入base64/dataclasses/re；测试仍仅dataclasses/importlib/sys/unittest。词检查不是完整形式化证明，候选须独立源码审查。检查后无源码修改。

| 文件 | 最终SHA256 |
| --- | --- |
| apps/android_synthetic_demo/tools/aar_material_functions.py | 29B34937F4CF09222234EEC9D101D387DB1859FB5182E863E623A33F947AA537 |
| apps/android_synthetic_demo/tools/test_aar_material_functions.py | 773526B50411949AD64E4180FDC7F28A60F4F5B8E5C54C7320B7A723DACF1C58 |

静态新预算1/1耗尽，非M5-15旧检查重跑。

## 一次测试回执

准确进程C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe；参数-I -B D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_material_functions.py；cwd D:\EliteSync-v10。监控硬60秒、异步读取stdout/stderr，各UTF-8累计32KiB上限，超时/超限/非零即停。

实际启动1次、退出0、监控耗时0.1579221秒；stdout0字节/stderr1635字节；TIMEOUT=False、OUTPUT_LIMIT_EXCEEDED=False，工具输出未截断。unittest Ran 17 tests in 0.002s，OK；无失败、修复或重跑。测试预算1/1耗尽。

原12方法保留并同次全部通过；新增5方法：test_build_info_fixed_combinations、test_build_info_strict_bools、test_build_info_signature、test_build_info_cache_rejections、test_build_info_cache_preserved。覆盖四bool组合固定预期、准确编码/顺序/五项tuple、必需keyword-only/未知参数拒绝、严格bool、cache类型/路径负例及合法边界原样保留。不将subTest计为独立测试数。测试只准确加载授权同目录module，-B不写pycache。

## 保持边界

未读取SDK/cache/config/env或其它源码；未改settings/v1/host/authority/既有证据，未访问旧仓库、真实properties、备份/密钥/DB/SSH/API/真实数据，无Git写动作。无Flutter/Gradle/JVM/ADB/构建安装/复制下载/UAC。

完整AAR argv、模板/输入/依赖、实际publication/POM绑定、工具身份、自动配置/环境/OS网络隔离、构建/签名/安装/首帧仍未证；17个纯测试不建立这些事实。M5/隔离构建NOT_READY，真实账号/Conversation/G08/G11/恢复门及全部旧预算保持。仅交候选与本证据，停Work独立LEVEL 2审查，不自接受、不创建后继。
