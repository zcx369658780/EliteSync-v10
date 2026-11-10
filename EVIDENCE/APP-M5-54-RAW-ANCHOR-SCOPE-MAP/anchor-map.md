# APP-M5-54 原始锚与声明地图

CANDIDATE — 待 Work 独立 LEVEL2 与独立 Sol/high 审查；不自接受。
2026-10-01；Codex 01a0f438-113d-77e1-8b50-3099bd6ece1a。
仓库 D:\EliteSync-v10；main；HEAD cf8bfaa4a03b8c9a682105617b185141904413be。

唯一来源为本仓已接受 M5-52 fixture；准确身份、普通 non-reparse（含祖先）、strict UTF8、全源行末及七个原始跨度见下方同次 A 完整 JSON。行号为 1-based；Start/End 为原始 bytes 的 0-based half-open 区间，Bytes=End-Start。按原 byte LF 边界定位，CR 留在该行末，没有 strip、normalize 或重编码原 fixture。

每项 Raw 是完整 JSON 字符串转义数据。解码该字符串后以 UTF8 编码即对应原跨度 bytes；文字中的 \r\n 明确保留原始行末。这是数据表示，不执行或求值源码。WholeFileOverlapCount 枚举所有可能 byte 起点，包含重叠出现；四 before 都为 1，固定顺序不重叠（相邻区间允许相接）。

scope 仅指原行上下文：class 在 34；helper 44–46 包含 apply 46 的声明边界；preflight 47 与 repository 88–101 位于 apply 声明之后、addFlutterTasks 349 之前；tasks 453–456 位于 addFlutterTasks 声明之后。没有 AST、括号解析、编译或运行证明，不新增完整材料或实际变换结论。

## 同次 A 原始回执

chunk_id=229533；exit_code=0；wall_time_seconds=0.8583105；original_token_count=595。
输出在打印前主动核 UTF8 ≤4KiB；无源码全文或 Base64。以下保留 A.output 完整 JSON：

```json
{"Phase":"A","Result":"PASS","Source":"EVIDENCE/APP-M5-52-RAW-NEWLINE-SOURCE-FIXTURE/flutter_plugin_original.bin","Bytes":42405,"SHA256":"1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313","OrdinaryNonReparseAncestors":true,"StrictUTF8":true,"BOM":false,"CRLF":821,"BareLF":0,"BareCR":0,"FinalByte":10,"Spans":[{"ID":"helper-member-before","Lines":[44,46],"Start":1793,"End":1893,"Bytes":100,"CRLF":3,"WholeFileOverlapCount":1,"Raw":"    private var pluginHandler: PluginHandler? = null\r\n\r\n    override fun apply(project: Project) {\r\n"},{"ID":"preflight-before","Lines":[47,47],"Start":1893,"End":1925,"Bytes":32,"CRLF":1,"WholeFileOverlapCount":1,"Raw":"        this.project = project\r\n"},{"ID":"repository-consumer-before","Lines":[88,101],"Start":3530,"End":4132,"Bytes":602,"CRLF":14,"WholeFileOverlapCount":1,"Raw":"        val hostedRepository: String =\r\n            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)\r\n                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST\r\n        val repository: String? =\r\n            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {\r\n                project.property(PROP_LOCAL_ENGINE_REPO) as String?\r\n            } else {\r\n                \"$hostedRepository/${engineRealm}download.flutter.io\"\r\n            }\r\n        rootProject.allprojects {\r\n            repositories.maven {\r\n                url = uri(repository!!)\r\n            }\r\n        }\r\n"},{"ID":"tasks-consumer-before","Lines":[453,456],"Start":22417,"End":22545,"Bytes":128,"CRLF":4,"WholeFileOverlapCount":1,"Raw":"            return\r\n        }\r\n        // Flutter host module project (Add-to-app).\r\n        val hostAppProjectName: String? =\r\n"},{"ID":"class","Lines":[34,34],"Start":1327,"End":1368,"Bytes":41,"CRLF":1,"WholeFileOverlapCount":1,"Raw":"class FlutterPlugin : Plugin<Project> {\r\n"},{"ID":"apply","Lines":[46,46],"Start":1849,"End":1893,"Bytes":44,"CRLF":1,"WholeFileOverlapCount":1,"Raw":"    override fun apply(project: Project) {\r\n"},{"ID":"addFlutterTasks","Lines":[349,349],"Start":16485,"End":16550,"Bytes":65,"CRLF":1,"WholeFileOverlapCount":1,"Raw":"    private fun addFlutterTasks(projectToAddTasksTo: Project) {\r\n"}],"FourAnchorsOrderedNonOverlapping":true,"ReadAllBytes":1,"SDKReadWriteCopy":0,"Execution":0,"Budget":"A1/1 closed; B0/1 at save"}
```

## 预算与停止门

A 新 1/1 成功关闭，仅一次准确 fixture ReadAllBytes。保存时 B 新 0/1，后续只核本文件身份、七个完整转义跨度与 A 一致、范围/计数/预算及 207 个旧工作区成员；最终 B 回执仅在回复提供，B 后不补写候选。仅本 anchor-map.md CreateNew 一次，未新增 summary/script。M5-53 失败和旧 A/B 预算关闭保持，不追认原错误回执已被 Work 独立恢复。

SDK 读取/写入/复制，以及 Python/AST/import/compile、函数/变换算法/tests/checker/launcher/monitor、Gradle/Flutter/JVM/ADB、依赖解析/下载/工程生成/staging/构建安装启动均为 0。未读 M5-49/M5-50/_EDITS，未解析 fences、映射 after、计算完整八材料/delta/输出尺寸、生成变换后源码或 expected。独立 expected 不得由候选函数或 _EDITS 回算；局部 after 材料、CRLF 合同、实现修订、oracle、稳定 Static/Test 脚本与运行预算须分别另授。

保留六冻结文件、原 fixture、所有 dirty/untracked、旧候选/证据/关闭预算；无 Git mutation，无旧 D:\EliteSync、真实数据/备份/密钥/生产 DB/API/SSH、SDK/cache/config/env/home/真实 metadata/properties/邻源/搜索索引/未知安装启动或 UAC。成员保留不证明全部 dirty bytes 完整。

M5-50 历史 SOURCE-ONLY 接受及完整输入适用性阻塞保持；此地图不证明函数通过或失败。早期 preflight PROPOSED，属性与 LibraryExtension 时序 NOT_PROVEN；M5/隔离构建 NOT_READY、settings/v1 全拒绝、loader/runtime false、真实性/恢复/生产门及历史 transport 限制保持。UAC 仍需当前 Work Owner 明确“我在”并另核授权。

首失败停，不补读、修正重跑、自接受或派后继；交付停 Work LEVEL2 与独立 Sol/high。若再同类编排失败，由 Work 停止派发并只读交接，作者不自行新建会话或转移预算。
