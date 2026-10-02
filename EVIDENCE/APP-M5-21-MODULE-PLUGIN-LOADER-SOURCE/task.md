# APP-M5-21｜module 插件加载入口来源

ISSUED；LEVEL2 DOCS-ONLY；Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，local/D:\EliteSync-v10，Sol/medium，实际9 turns。
先核根authority/local-workflow、M5-19 plan/work-review、M5-20 summary/work-review。M5-20源码独立ACCEPT、两预算各1/1关闭，全部旧预算保持。
唯一新增本目录plan.md；不改源码/authority/旧证据。

两轮全新定点只读预算：
1 一次准确D:\flutter\packages\flutter_tools\gradle\module_plugin_loader.gradle内存读取/hash、全文回显。由M5-19 include脚本28行明确定位。最大文件32KiB、stdout16KiB；过大选完整关键语义段并明确未覆盖，总输出不可截断重跑。状态/hash先打印，失败即停。
2 只有第一轮源码明确给出被apply/import的静态源码位置时，允许一次批量最多2个被该第一轮直接引用的源文件读取/hash。必须在D:\flutter\packages\flutter_tools\gradle内，准确路径表达式能由已核源位置/字面量解析，无搜索/枚举/猜测。允许扩展名.gradle、.groovy、.kt、.kts，禁止properties/json/plugin metadata/生成文件/cache/config。每项最多32KiB，总stdout24KiB；不追第二跳，不重读第一文件。没有明确位置则第二轮NOT_USED/UNRESOLVED，不用猜路径消耗。所有失效/超限读取失败停不重试。

只读官方加载器源码，不执行apply/import/解析算法，不访问源码指向的真实模块/插件/json/properties/目录或环境。不得从import包名转换猜实际源文件位置，静态字面量路径才可作第二轮授权依据。

plan：
- 每源准确hash/行定位、入口到依赖的源码接线，实际metadata格式/必需字段/Android或native筛选、项目名与projectDir绑定、重复/冲突/缺失处理、文件/环境/缓存或外部代码入口。未读被引用源保持缺口。
- 与M5-16发布筛选/M5-20拓扑材料比对：SDK原规则与拟议synthetic严格allowlist分开；加载器能读不代表实际项目图/插件清单闭合。
- 元数据/POM/默认坐标/模板生成/自动配置/OS隔离门按事实标记；不升loader_binding_verified/runtime_ready，不构建。
- 下一有事实增量的软件切片给准确路径/接口/人工fixture/负例与建议预算。优先纯内存插件材料结构校验/拓扑合同，真实json读写及插件源码执行均不授权。不要只多一恒定拒绝器。
- 两轮实际次数/输出/退出/覆盖与未解门，唯一plan后停独立WorkLEVEL2审查，不自接受/后继。

保留dirty/untracked，无Git写；禁其它SDK源码/搜索/索引、SDK工具/算法/测试/构建/ADB/安装/复制/下载/生成目标/UAC、用户配置/cache/env/home/真实properties/json/plugin内容、旧D:\EliteSync、真实数据/备份/密钥/DB/SSH/API。M5/隔离构建NOT_READY，真实性/恢复边界保持。