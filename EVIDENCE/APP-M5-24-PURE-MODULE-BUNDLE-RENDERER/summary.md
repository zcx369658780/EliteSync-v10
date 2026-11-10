# APP-M5-24｜四正文纯内存renderer候选

2026-09-30；SOURCE-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。作者交付完成，停独立审查，不自接受。M5/隔离构建NOT_READY。

入口D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；当前ISSUED assignee 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，173条既有状态保留。M5-23 plan hash匹配82D150AB94166034660832017B722575B7F0D97AD113165D77D905AB49A1A60B；已有材料模块匹配DAB75C66F4064E57635BB859900507CC8C3BCC46792A073322BBDF96560E7672；三个新增目标预先不存在。

## 精确差异

仅新增render_module_bundle.py、test_render_module_bundle.py与本summary。keyword-only render_module_bundle返回四个(str,bytes)有序对；exact config与固定身份/材料路径/版本/严格int、必需NDK三数字段与64小写hex ID；approved收窄三虚构name/path，复用已接受synthetic_plugin_materials全声明校验，native按metadata顺序、dev保留。对所有固定与approved根按段检查相等/祖先冲突。

按完整M5-23合同生成settings、root build、Flutter build与manifest正文：settingsDir/rootProjectDir相对材料定位、Flutter目录大小写与flutter.source基准、各输出/最终publication分离、SDK included build与local Maven声明、仅模块debug设计与显式权限remove。只在内存生成UTF-8/LF bytes，无BOM、恰一末LF，不落地四个bundle目标；不生成app/wrapper/plugin代码、POM/完整argv/启动器。生产仅普通导入re与已有材料纯函数，不自行文件加载、读取配置/env/SDK或启动进程。

## 一次静态批量检查

准确读取两个新增源码与材料模块一次，计算hash；以Python标准库AST静态解析新增两文件，未导入或运行renderer/材料算法。检查imports白名单、禁止宿主调用、准确keyword-only必需参数、四常量目标、空白/末换行与材料hash门，退出0。静态新预算1/1耗尽，验证后源码未修改。

| 源码 | SHA256 |
| --- | --- |
| render_module_bundle.py | 94ECF3FADA48499AA110D4E50C9057F6E04EE778454B8CE0CDE6A0198430228C |
| test_render_module_bundle.py | 42721EF6D8D8E99722F639A411024FBCBC3AB4782CD769A43C78608EBB3C3DB0 |
| aar_material_functions.py（只读、未改） | DAB75C66F4064E57635BB859900507CC8C3BCC46792A073322BBDF96560E7672 |

静态命令为固定Python -I -B -c的AST检查代码；工具墙钟0.3635504秒，完整短回执无工具截断，内容远低于32KiB。限制：静态检查由命令工具合并回显，未单独计量stdout/stderr，也未使用测试的双流主动上限监控；实际未出现错误或超量，但不宣称该静态调用具备双流超限终止证明。不得为补该证明重跑静态预算。AST词/调用检查不是形式化安全证明，Work仍须独立实审源码。

## 唯一测试进程回执

Executable C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe；参数-I -B D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_render_module_bundle.py；cwd D:\EliteSync-v10。脚本准确用importlib依次加载材料模块和renderer，在exec_module前按准确名字注册sys.modules；测试模块由unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])明确加载。没有discover/sys.path扫描或旧31方法回归，旧测试文件未运行。

测试监控硬60秒、异步双流，各UTF-8累计32KiB上限，超限/超时/非零即停。实际启动1次、退出0、elapsed 0.2148204秒；stdout0/stderr1355字节；TIMEOUT=False、OUTPUT_LIMIT_EXCEEDED=False，工具回显完整。Ran 13 tests in 0.003s，OK。测试新预算1/1耗尽，无失败、修复或重跑。

13方法：approved_fixture_and_conflicts、complete_independent_bytes、config_schema_and_types、dependency_and_size_errors、empty_native_full_expectation、fixed_fields_and_injections、input_detachment_and_false_gamma、metadata_schema_and_flags、ndk_id_errors、order_and_approved_order_independence、paths_and_no_app、signature_and_private_errors、valid_variable_fields（均test_前缀）。subTest不计独立方法数。

完整四正文独立硬编码固定字节，基线、空native、false gamma/true dev、metadata重排/approved重排、合法ID与NDK替换、输入修改脱离及路径基准通过；配置/schema/type/int不接bool、固定域/注入/缺键/extra、approved冲突与unknown、metadata依赖/循环/native依赖false/128冲突与129数量门等负例通过。未调用renderer回算期望，未用Gradle/Groovy解析验证实际生效。

## 未解门与停止状态

四正文为自有SOURCE-ONLY设计，不是官方等价或可执行工程。SDK includedBuild/Flutter插件动态副作用与注册、真实插件源码/variants/任务图、local repo冲突和依赖材料、真实GAV/POM绑定、manifest合并/权限、完整Dart/assets/输入与工具身份、配置/环境/系统网络/路径隔离、构建签名安装首帧均未证。省略loader不证明真实闭包，权限remove不证明实际无网络。settings/v1全拒绝及已有loader/runtime false保持。

无SDK/config/cache/env/home/真实properties/metadata/json/plugin/旧仓库/真实数据/备份密钥/DB/SSH/API读取；无bundle目标写入/复制下载/Flutter/Gradle/JVM/ADB/构建安装启动/UAC/Git写。只有授权Python静态AST与一次人工测试执行。两新预算各1/1关闭，旧预算不重置。停Work独立LEVEL2 ACCEPT/REJECT，静态双流证明限制明确留审，不自接受、不创建后继；M5/隔离构建NOT_READY，全部真实性/恢复门保持。
