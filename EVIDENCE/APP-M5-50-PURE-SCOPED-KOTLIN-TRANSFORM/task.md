# APP-M5-50-PURE-SCOPED-KOTLIN-TRANSFORM

ISSUED — LEVEL2 SOURCE-ONLY。明确交Codex01a0f438-113d-77e1-8b50-3099bd6ece1a local/D:\EliteSync-v10，八次启动后沿用；旧01a0f1ec/01a0f0b9停用。
M5-49独立ACCEPT/CLOSED SOURCE-ONLY KOTLIN MATERIALS、Sol/high NO_FINDINGS、A/B1/1关闭、运行0。main HEAD cf8bfaa4a03b8c9a682105617b185141904413be，203既有status保留。旧budget/历史证据限制及保护门保持。

## 唯一实现与允许写路径

只CreateNew apps/android_synthetic_demo/tools/aar_scoped_kotlin_transform.py（≤24KiB UTF8）及本目录summary.md（≤16KiB）。前者是唯一主要结果，后者只记录来源/预算/未检查与原回执；任何已存在目标首停不覆盖。不得修改现有adapter、applied模块、tests、harness、SDK、旧候选或authority。

唯一公开函数 render_scoped_flutter_plugin(source: bytes) -> bytes，只接收完整输入bytes，不接收路径、operations、anchor、replacement、身份覆盖或scope覆盖参数。只编写，不执行。固定四组M5-49完整before/after bytes与顺序：helper-member、apply-preflight、repository-consumer、tasks-consumer；不得改helper/consumer逻辑或gate。私有固定tuple/bytes字面，不能变成通用patch接口，不修改Attachment executable_patch或Invocation runtime_ready，不接入构建/loader。

精确合同：
- type(source)必须是bytes（拒绝bytearray/memoryview/bytes子类等），否则ValueError('ES_SOURCE_TYPE')。
- 完整len=42405且hashlib.sha256(source).hexdigest().upper()=1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313；尺寸/身份不符分别ValueError('ES_SOURCE_SIZE') / ValueError('ES_SOURCE_IDENTITY')。不得换源、规范化行末、解码重编码输入、修正hash或fallback。
- 在原输入先核全部四before各完整出现恰一次（包含重叠出现也算），否则ValueError('ES_ANCHOR_COUNT')；核原源LF编号行范围与完整before相等：44–46 helper、47 preflight、88–101 repo、453–456 tasks。class声明原34及apply原46/addFlutterTasks原349与M5-48完整对应声明核定；scope失败ValueError('ES_SOURCE_SCOPE')。不以粗糙大括号regex或任意token代准确scope。精确完整hash固定上下文；可按LF原字节定位行，禁止臆造未存范围。
- 四原输入byte区间须按固定顺序严格有序、不重叠，否则ValueError('ES_ANCHOR_OVERLAP')。任何检查失败raise且无部分返回/日志/文件结果。
- 全部原输入前门成功后才在局部scratch按固定顺序替换。每步在当前scratch再次核before恰一次；失败ValueError('ES_SCRATCH_ANCHOR')。插入后不得继续拿原绝对行号驱动替换。只能替换固定四项，禁止执行Kotlin或求值文字。
- 全部完成才return完整immutable bytes。八字面bytes长度依次97/2291、31/67、588/642、124/1275，四delta2194/36/54/1151，总增3435，结果len=45840；不符ValueError('ES_OUTPUT_SIZE')。四块以外（含308–348、534以后）原byte不变；不能用保存上下文拼造完整输入或丢弃未读正文。实现用bytes操作保证原非替换字节保留，不制作完整SDK输出文件。
- 仅标准库hashlib导入；允许私有有限纯bytes辅助函数。无模块顶层函数调用/算法求值（固定bytes/tuple声明除外）、无__main__/CLI、无文件/环境/进程/网络IO、无动态import/eval/exec。hash只在调用函数时计算。保持简单可审查。

输入完整正例fixture、独立人工expected输出及运行证明尚未保存，均NOT_CHECKED/DEFERRED，需要另授来源与独立oracle合同；不得在本任务生成假完整源/正例测试或以delta称变换已验证。源码候选可先编写及独立审查，不把SOURCE-ONLY接受当Static/Test执行许可。早期preflight仍PROPOSED，属性安装/LibraryExtension时序NOT_PROVEN，输出即使未来字节变换成功也不代表ready/编译或真实兼容。

## 新A/B各最多一次，运行预算0

先读authority/准确本task/M5-49 work-review。
A新最多1/1，只一次批量核以下准确本仓来源普通non-reparse含祖先/size/hash/strictUTF8及必要字面摘录，主动输出≤16KiB：
- EVIDENCE/APP-M5-49-SCOPED-KOTLIN-PATCH-MATERIALS/patch-materials.md：13818 / SHA256 B783379A7FC307B8750F73758261BEBCF739CDFA72A234B80148D96F4AD9DA49；提取八完整Kotlin字面及scope声明。
- EVIDENCE/APP-M5-48-FLUTTER-PLUGIN-SOURCE-CONTEXT/source-context.md：32531 / SHA256 7D12B382EABBF43CF29BBC65E302771CA0BA3D5B1042A296005950D0E8AA37C8；仅已存编号34/44–47/88–101/349/453–456必要原行。
A失败首停关闭，不修复重跑/换源。A成功后只编写CreateNew候选及summary；可用宿主纯文字转义写源码，不调用新函数或生成完整变换结果。完整bytes字面须保持LF/缩进/末LF，避免JS模板叠PowerShell反引号，禁止脆弱全局标签定位。
B新最多1/1，仅候选两文件size/hash/non-reparse/strictUTF8、固定完整八字面文字核定及workspace旧成员保留，主动输出≤16KiB；不Python/AST/import/compile/算法或测试、不运行新函数，不以任意短语断言代语义审查。只文字核对源字面，不eval。summary保存时B未执行，最终B原回执在回复提供，B后不得改候选补记。
首失败停止关闭本预算，不修改重跑、不追认旧budget；候选或首失败后停WorkLEVEL2及独立Sol/high只读审查，不自接受或派后继。

## 保护门

SDK读取/写复制、Python/AST/import/compile/算法/test/checker/launcher/monitor/Gradle/Flutter/JVM/ADB/依赖解析/工程生成下载/staging/构建安装启动全部0。不读SDK邻源/cache/config/env/home/真实metadata/properties，不搜索索引。保留全部dirty/untracked、五冻结源/harness、旧候选/证据/关闭budget，不commit/pull/push/reset/clean/stash，不旧D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH/未知安装启动。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false及真实性/恢复/生产门保持；UAC前须当前Work Owner明确“我在”及另核具体授权，本task无UAC权限。
