# APP-M5-23｜受控 module 配置渲染器合同

ISSUED；LEVEL2 DOCS-ONLY（生成链设计）；Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，local/D:\EliteSync-v10，Sol/medium，实际11 turns。
先核根authority/local-workflow、M5-22 summary/work-review。M5-22 SOURCE-ONLY独立ACCEPT，静态/测试各1/1关闭，所有旧预算保持。
唯一新增本目录plan.md。此任务把已核模板/拓扑/插件纯材料收敛成下一可实现渲染器的精确合同，不再新增恒定拒绝器或材料record；不实际实现/执行renderer。

新只读预算两轮：
1 一次批量准确本地证据文档：EVIDENCE/APP-M5-10-ISOLATED-SYNTHETIC-BUILD-CONTRACT/plan.md、APP-M5-18-MODULE-TEMPLATE-SOURCE-CONTRACT/plan.md、APP-M5-19-MODULE-INCLUDE-SOURCE-CLOSURE/plan.md、APP-M5-21-MODULE-PLUGIN-LOADER-SOURCE/plan.md。只本地已保存来源，不读SDK。
2 一次准确两本地源码：apps/android_synthetic_demo/tools/aar_material_functions.py、test_aar_material_functions.py，各一次hash及定点接口/fixture核对。两轮各一次，不搜索/索引/扩读；可在同次内存中组织摘录，stdout每轮最多16KiB，hash/状态先输出，超限明确未回显而非重跑。读取失败停，记录UNRESOLVED；没有算法/测试/构建预算。
根authority入口读取不消耗上述专业两轮预算，不重复运行旧验证。

plan需交付可直接发源码任务的确定规格：
- 目标新增render_module_bundle.py与test_render_module_bundle.py，接口render_module_bundle(...) -> tuple[tuple[str,bytes],...]；只内存UTF-8正文，不落地工程/模板、不调用SDK renderer/loader/读取properties/metadata/env。
- 固定四目标相对bundle-root路径（不是实际现有工程）：
module/.android/settings.gradle
module/.android/build.gradle
module/.android/Flutter/build.gradle
module/.android/Flutter/src/main/AndroidManifest.xml
不生成wrapper/app/真实插件代码。AAR构建图选仅:flutter与人工批准插件，M5-22校验复用；未知插件的实际源/构建仍NOT_CHECKED，不把未输出插件文件误称依赖闭包完成。
- 明确bundle-root、settingsDir、rootProjectDir、Flutter projectDir、flutter.source的各相对路径基准；不能直接把bundle-root材料路径插入Gradle projectDir造成基准错误。每项目build output与最终repo和host各分离，明确仅拟议渲染规则，非已经落地隔离。
- 明确所有输入/schema/default：独立synthetic group/namespace、module ID、SDK/仓库相对材料目录、AGP/Kotlin/SDK版本及其它必要字段。哪些有已核模板来源，哪些自有受控设计，哪些具体值未验证必须显式给出。不要把本机默认或版本兼容写成事实。引号/换行/插值/路径逃逸/重复/重叠输入拒绝规则，字符域与固定fixture。
- 给完整四文件拟议正文/确定行序、换行和UTF-8编码，列明插件include目录/输出目录、debug variant、publication接线使用边界和仓库声明。准确区分:Flutter目录与:flutter名称。不由拼文本文法声称Gradle/AGP生效。
- 选择自有受控配置，SDK入口/被动态apply/includedBuild的后续副作用必须明确未闭合；不得借省略loaders宣称Flutter实际插件/registrant/完整输入已经处理。既有settings/v1全拒绝保持，四正文不能替换现有host或直接启动。manifest权限/组件模板事实与拟议取舍分开，不能从移除标记或网络源推导实际无网络。
- 人工两插件完整正例字节预期与准确目标映射、无app/任意extra输入；负例输入注入/签名schema/路径基准或输出冲突/缺必要材料。未来标准库目标测试1次+静态1次建议预算，不本任务执行。
- 若四正文仍依赖未核必要语义，逐项指出实际最小阻塞与准确下一source定位，不能靠占位省略冒充完整合同。评估是否可在明确定义的合成设计域内先实现SOURCE-ONLY，不放行构建。
- 唯一plan引用来源行/hash与新两轮耗用；候选停独立Work LEVEL2审查，不自接受/后继。

禁止源码/authority/旧证据变更、SDK/cache/config/env/home/真实properties/json/插件代码或目录读取，禁算法/测试/工具/Gradle/Flutter/JVM/ADB/构建/安装/复制/下载/目标生成/UAC/Git写、旧D:\EliteSync、真实数据/备份/密钥/DB/SSH/API。保留dirty/untracked；M5/隔离构建NOT_READY、loader/runtime false、真实账号/Conversation/恢复门不变。