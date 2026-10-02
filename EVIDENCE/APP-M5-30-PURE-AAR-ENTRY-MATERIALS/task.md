# APP-M5-30｜受控AAR入口纯内存修订材料

ISSUED；LEVEL2 SOURCE-ONLY；Codex 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，local/D:\EliteSync-v10，Sol/medium，派发前20次启动，沿用。
M5-29独立ACCEPT/CLOSED DOCS-ONLY，唯一接受合同EVIDENCE/APP-M5-29-AAR-ADAPTATION-CONTRACT-CONSISTENCY-REPAIR/plan.md，SHA256 B7477C177E1CB1860959BD4136E6B1A1B33A5D9F2B75E75BDB4F6FC442A95382。旧2/2关闭；M5-28 REJECT保留，所有旧预算不重置。

只允许新增或修改：
- apps/android_synthetic_demo/tools/aar_entry_materials.py
- apps/android_synthetic_demo/tools/test_aar_entry_materials.py
- 本目录summary.md
三个目标派发前不存在。一个主要结果为本纯材料实现，summary仅证据回执。不得改旧材料/renderer/authority/SDK/旧证据。

## 最小实现

准确实现keyword-only adapt_module_debug_entry(*, materials, config)，返回M5-29 frozen EntryMaterials/六PatchOperation/两Attachment/InvocationContract/四InstallationGroup和LiteralString或RootProjectDirFilePath recipes。只标准库dataclasses/hashlib/re/typing及必要future annotations；不导入其它项目模块或SDK/Gradle。所有容器tuple，不返回dict/list引用；所有source片段UTF8 LF字节、顺序/hash/锚/类型/固定项目与路径/11键/64hex/六property键域准确依M5-29，无默认、自由覆盖、继承或任意path。

验证原材料hash及唯一锚在返回包前完成；每operation.input_fragment_sha256指最初原片段，未来顺序scratch操作只检查当时锚唯一，不把已修改scratch重新要求等于原hash。INSERT_BEFORE.after不含before锚；所有REPLACE.after完整准确，helpers插入后init-all仍exact一次；plugin-deps校验但不修改。完整apply未持有，两Attachment.executable_patch=false，不能将其应用或输出完整SDK文件。本实现只返回typed操作描述和recipe，不直接应用/写文件/安装。

source常量来自接受合同codeblock；不把M5-28输出域带回。input_id任意64小写ASCIIhex；Invocation/input四个buildNumber/四个安装LiteralString都绑定同一ID。logical output-dir仅publication；File.path recipe固定ROOT_PROJECT_DIR+('..','..','publication')、FILE_PATH、LOCAL_EXTRA及准确阶段，不在Python解析实际路径。mode检查源片段必须完整且与已接受presence/null矩阵一致；生产函数不假装检查真实Project/AGP对象。

TYPE与CONTRACT错误固定，不回显输入/路径，exact顶层与嵌套类型检查先于解包/方法调用；拒绝bool/string/tuple/dict/bytes子类、自定义对象、重复键/错序/extra/缺失、不一致ID、原材料不匹配/改动/已适配、path逃逸/额外project/app/flavor/release/多任务/带前缀task、repo策略绕过。frozen可保持输出确定性与输入变更脱离，不以constant record替代完整patch operations。

## 新预算：三个一次性轮次，各0/1，失败即停

1. 一次实施来源准备：准确读取M5-29 plan（hash如上）及M5-27目录m526-original-receipt.txt（FE1A9CF5D3DDAF259A5412346B77DF43CFB05295B31BBF8FB3767C2423F2E062）、round-2-original-receipt.txt（8B4657648F3BE8CA1A36E4DFCCED2CFAEA0FAFE18C6BB2B4DCEBD5EFB6B1FE44）、round-1-original-receipt.txt（9FD10B2C9B46D2578F7BFD32E266248A4C45CEC74140A39A1ED734E5DC1EA8E6）。各一次普通非reparse/≤256KiB、总≤1MiB/hash门，唯一JSON output/SECTION/源行一致性，归一规则依合同。只已存证据，不SDK实际来源，不执行原命令；输出UTF8主动累计≤32KiB，状态/hash先，未回显明确标限额；任何来源/hash/解析/缺行/链接/大小失败即停，不补读。将四准确原材料作为测试内嵌字面bytes；后续运行测试不得读这些证据。
2. 一次新静态检查：准确两新增源各一次读内存、hash，AST静态解析，不import/调用生产算法。核imports/宿主副作用/准确keyword-only参数/输出types/无自由source读取、测试精确加载/独立expected字节来源、scope与预算。标准库文本/hash/AST允许，硬60秒，双流各UTF8≤32KiB，失败/超时/超量即停，不修复重跑、不启动测试。成功后源码冻结；新改动须另报不能悄悄重开预算。
3. 一次人工材料测试进程：准确已使用Python C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe，参数 -I -B D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_entry_materials.py，cwd D:\EliteSync-v10。硬60秒、异步双流各UTF8累计≤32KiB，超时/超量/非零即终止并停，不修复重跑。只此文件，不discover/扫描/sys.path搜源/运行旧测试。使用importlib精确绝对加载唯一生产源，在exec_module前准确注册sys.modules；unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])明确加载。只能读取测试自己与准确生产源进行加载，标准库正常导入；fixture内嵌，不读证据/SDK/config/env/metadata/其它项目。不接受0 tests为PASS。

静态与测试都先核固定Python executable存在普通非reparse，不搜索替代工具/安装依赖；无SDK/Gradle/Flutter/JVM/设备/构建预算。三个新轮各1次；在轮前修改草稿可自行判断，轮失败或冻结后不得修复/补跑。单次回执保留hash、数量、stdout/stderr字节、walltime、退出码/超时超量与耗用。无输出或失败如实NOT_VERIFIED。

## 必要人工测试证明

P1=64a、P2=64b完整独立预期：逐字六operations的before/after/order/原片段hash、两Attachment及executable_patch=false、整个Invocation字段、logical properties与全部installation recipes；期望不得调用生产函数回算或从生产模块常量复制。原输入/期望source字节独立内嵌，可按合同明确手工分段拼接，禁止宽泛token包含断言替代完整预期。

在测试自身纯内存scratch依固定operations应用六操作（测试局部检查器，不新增生产API），用独立手工字节预期核完整repo-block/tasks-full/init-full结果，证明产生新library debug接线、repo条件包裹和init guard/helpers且所有剩余原bytes保留；不得编译或执行片段。直接比较三个完整结果，不能由生产返回的after字节组成expected。两例完整operation bytes相同但Invocation/ID绑定不同；四project等值recipe、File.path未求值、input修改不影响旧返回、冻结/确定性、再适配或材料变异拒绝。

负例按M5-29完整域：顶层/嵌套类型子类及bool/null/custom对象、id版本/hash/byte/order/缺/extra/已适配/锚材料篡改、11键与六property键缺/extra/重排/重复、64hex大小写长度/非ASCII、P2某buildNumber仍a、project/app/后代/误mode/null/false/作用域或ID冲突、路径/token/自由recipe/env/executable/extra任务/repo策略绕过。runtime mode矩阵只静态核源材料中明确presence后取值，不用Python tests称真实Gradle行为已执行。

## 停点

唯一summary含三轮实际预算和同次回执、两最终source hash、精确测试方法/数量、独立完整正例与负例覆盖、未跑项和限制。仅SOURCE-ONLY pure-memory，不生成bundle文件/SDKpatch/启动器，不对Gradle/Groovy/Kotlin/AGP/metadata/registrant/真实材料/POM/OS隔离作完成声明。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false与真实账号/Conversation/恢复/UAC门保持。

保留全部dirty/untracked；不commit/pull/push、旧D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH，不SDK/config/cache/env/home/真实properties/metadata/engine/plugin材料读取，不源码追读/目录索引搜索、下载复制、Gradle/Flutter/JVM/ADB/构建/安装/启动/UAC。上述准确Python静态及人工测试是唯一新执行授权。完成/失败后停Work独立LEVEL2，不自接受/派后继，旧预算全部关闭。