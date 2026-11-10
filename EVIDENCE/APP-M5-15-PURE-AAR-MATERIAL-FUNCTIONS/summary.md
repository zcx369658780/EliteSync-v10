# APP-M5-15｜纯AAR材料函数候选

2026-09-30；SOURCE-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。
作者交付完成，未自接受。M5与隔离构建仍NOT_READY。

入口：D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；当前任务ISSUED，assignee 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad。入口164条既存工作区状态全部保留；三目标均确认预先不存在。仅新增两准确Python源码文件及本summary，无authority/settings/v1/host/SDK修改或Git写操作。

## 实现

- encode_dart_defines：严格tuple/str，逐项UTF-8→标准Base64→逗号连接，保序、重复与padding；空tuple为空字符串；孤立surrogate转ValueError，类型错误TypeError。
- synthetic_define_argument：仅准确单项ELITESYNC_SYNTHETIC_DEMO=true tuple，返回对应-Pdart-defines参数。空、额外、重复、false/冲突、错误类型拒绝。
- publication_recipe：keyword-only，显式区分publication_name与component_name；组件仅debug，artifact后缀来自publication_name。project_version_proposal先去除base_version中全部-SNAPSHOT，再按非None build_number覆盖，覆盖值不再次去除。记录为frozen/slots；runtime_ready与publication_binding_verified均false。字符域与POSIX相对路径仅作词法校验，不访问宿主。版本提案不证明实际pub.version/POM绑定。

生产函数仅标准库base64/dataclasses/re与内存字符串，无文件、环境、网络或进程访问。测试以importlib准确加载授权同目录module，并注册sys.modules以支持dataclass；不读取其它项目文件，不启动子进程。

## 一次静态检查

预算1/1耗尽；实现后一次准确两文件内存读取、内容/import检查、SHA256、行尾空白与末尾换行、禁止宿主调用词检查；退出0，空白与禁止调用检查均PASS。词检查不是完整形式化安全证明，源码仍须Work独立实审。检查后源码未修改。

| 源码 | SHA256 |
| --- | --- |
| apps/android_synthetic_demo/tools/aar_material_functions.py | 977F605D32255757ABF2D5446F2EB3AA179156C31EE50B24608CC7289905D511 |
| apps/android_synthetic_demo/tools/test_aar_material_functions.py | 1034C01C2C52298AC96FC10D18BE74EAB1DD1AC4A3A724D23E93BEE7EA26522E |

## 唯一测试回执

测试预算1/1耗尽，实际启动1次，无失败、修复或重跑。

- Executable：C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe
- 参数：-I -B D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_material_functions.py
- cwd：D:\EliteSync-v10
- 监控：60秒硬时限；stdout/stderr分别按UTF-8累计32KiB上限；异步双流读取；超时/超限即终止并停。
- 进程退出0；监控elapsed 0.1619519秒；stdout 0字节、stderr 1160字节；TIMEOUT=False、OUTPUT_LIMIT_EXCEEDED=False；工具回显未截断。
- unittest：Ran 12 tests in 0.002s，OK。12个方法包含固定独立向量、Unicode/逗号/等号、空/顺序/重复/padding、surrogate与类型、synthetic负例、publication/component分离、SNAPSHOT覆盖顺序、不可变记录、字符及路径边界和keyword-only检查。

回执方法：test_character_domains、test_encoder_type_and_surrogate、test_immutable_record、test_independent_vectors、test_keyword_only、test_non_strings、test_output_path_boundaries、test_publication_and_component_are_independent、test_synthetic_rejects_other_intent、test_synthetic_single_argument、test_valid_character_boundaries、test_version_order，全部ok。各方法的subTest不单列为独立测试数。

## 限制与停点

这只是纯编码/发布材料，不生成完整argv/POM/模板，不复制staging、不启动SDK，不开放构建准入。实际pub.version/POM绑定、发布脚本未读接线、模板坐标与输入闭包、插件/依赖、工具身份、自动配置/环境/系统网络隔离、AAR/host构建/签名/安装/首帧均NOT_CHECKED或既有UNRESOLVED，不由12个纯测试提升。

M5-14旧1/1及M5-13旧2/2预算保持关闭；本任务静态与测试预算各1/1耗尽。未读SDK/cache/真实properties、旧仓库、备份/密钥/DB/SSH/API，未做Flutter/Gradle/ADB/JVM/构建安装/下载/UAC或真实数据操作。真实账号/Conversation/G08/G11/恢复回填与现有全拒绝保持。候选与本证据停独立Work LEVEL 2审查，不创建后继、不自接受。
