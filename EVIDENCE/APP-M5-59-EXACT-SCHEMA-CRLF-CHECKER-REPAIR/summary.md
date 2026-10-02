# APP-M5-59 SOURCE-ONLY candidate

Status: CANDIDATE — pending independent Work LEVEL2 and GPT-6.1 Sol/high.
Main: cf8bfaa4a03b8c9a682105617b185141904413be.
只新建本目录 Check-CrlfContract.ps1 与本 summary；旧候选/证据保持。

## 本轮 A 原回执
A command raw cmd: 3362 characters; exit 0; reads 4.
此为未包装 cmd 长度；不与 native 包装长度混用。
A1/1 closed；保存时 B0/1。原输出含末 CRLF ≤2KiB。
本 A 只读取、解码和文档 JSON 数据确认，不执行旧/新检查器或其函数。

```json
{"Phase":"A","Result":"PASS","Sources":[{"Path":"EVIDENCE/APP-M5-58-COMPACT-CRLF-CHECKER-SOURCE/Check-CrlfContract.ps1","Bytes":13604,"SHA256":"A5FF5D6859E2B9F4EC308D72FD6326E341BDA96EA8A5CCDD9EDFA53CD3824366"},{"Path":"EVIDENCE/APP-M5-55-LOCAL-CRLF-MATERIALS-CONTRACT/crlf-contract.md","Bytes":14300,"SHA256":"214F7D4232DE8A8A71CF71353968466ECFD2E55B74D85792A7026BD8B3E2A051"},{"Path":"EVIDENCE/APP-M5-54-RAW-ANCHOR-SCOPE-MAP/anchor-map.md","Bytes":5879,"SHA256":"CC1DA4B0484DC29E5BA2DE0DC4765337629394D327D8775869883533E9CE4774"},{"Path":"EVIDENCE/APP-M5-49-SCOPED-KOTLIN-PATCH-MATERIALS/patch-materials.md","Bytes":13818,"SHA256":"B783379A7FC307B8750F73758261BEBCF739CDFA72A234B80148D96F4AD9DA49"}],"MapSourceType":"path string","MapIdentityLocation":"root Bytes/SHA256/CRLF/BOM/BareLF/BareCR/FinalByte","Counts":{"ContractLiterals":8,"ContractAnchors":4,"ContractDeclarations":3,"MapSpans":7},"DeclarationIds":["class","apply","addFlutterTasks"],"ContractBudget":"A1/1 closed; B0/1 at save","MapBudget":"A1/1 closed; B0/1 at save","Reads":4,"ABudget":"1/1 closed","BBudget":"0/1 at save","Execution":0}
```

## 作者 source-only 实质核定
按 M5-59 Required 对已核身份的旧源码作新文件最窄修订：
1. map.Source 单独核准确 fixture 路径 string；Bytes/SHA256/CRLF/BOM/
   BareLF/BareCR/FinalByte 从 map 根核 accepted 身份与行末事实，
   再逐项关联合同 OriginalFixtureBytes/OriginalFixtureSHA256/
   OriginalCRLF/OriginalBOM/OriginalBareLF/OriginalBareCR/OriginalFinalByte。
2. 三声明 expected Id 固定 class/apply/addFlutterTasks，
   不由候选合同推导。按 Id 比对全部 flat 字段并单独逐字/UTF8 bytes 核
   完整 Raw；核固定 Lines/range/Bytes/CRLF/WholeFileOverlapCount。
   完整 Raw 的准确引用来自 hash-fixed accepted map，不读取 fixture。
3. Spans 不要求或读取 ScopeReference。合同四条固定 scope 字符串
   分别与三声明完整数据、四锚固定 Lines/Start/End/Bytes/CRLF 及
   class→helper、helper 包含 apply 并 End=apply.End、
   preflight 接 apply.End、preflight/repo 在 addFlutterTasks 前、
   tasks 在 addFlutterTasks 后的关系共同核定。
   此为 exact original line context only，不是 AST/括号或运行 scope 证明。

保留其余设计：固定三文档根/路径/size/hash/普通文件及祖先 non-reparse/
strictUTF8；显式 Anchors/Literals/Spans 独立唯一 Id 与 preflight 映射；
八准确 kotlin fence 全开闭 delimiter/末 LF、局部无 CR、
LF→CRLF 及完整 Raw/UTF8 bytes/五项计数；四 replacement delta、
总3502/拟45907关联合同 stored 字段；准确保存预算
A1/1 closed; B0/1 at save。无通用递归、预算 regex、动态求值、
子进程、网络、环境读取、SDK 或文件写入。
最多64具名聚合 checks，成功与失败输出在打印前核 UTF8 含末CRLF
≤4KiB；首失败固定 tag，不输出 partial 成功表/Raw/exception。
内部未知异常 INTERNAL_EXCEPTION；固定最小失败回执亦有常量大小界限。

## 验证层级和停止门
上述核定为完整源码文字审阅及 task 对照，不是 parser/AST 或实际运行。
本轮 parser/点源/脚本/checker/函数/Python/import/compile/算法/tests/
launcher-monitor/Gradle/Flutter/JVM/ADB/构建安装启动全0。
语法、字段级运行适用性、完整字面执行结果及运行输出限额均 NOT_CHECKED。
本源码只有候选身份；先独立 Sol/high 与主 Work LEVEL2，
静态或一次准确冻结 checker 运行另授，不自行接受或派后继。
B 仅两候选完整文字身份/UTF8/size/hash与213旧成员，不补读四来源；
最终原B只回复提供，B后不补写。

M5-58 REJECT/CLOSED SOURCE-ONLY、M5-55/56/57旧失败及全部关闭预算保持，
不追认旧M5-55 B。保留三原文档、六冻结/rawfixture/dirty/untracked/
旧候选和历史证据。SDK/fixture/M5-50内容读取0；无Git修改、UAC、
真实数据/备份/密钥/生产动作。M5-50历史SOURCE-ONLY及完整输入适用性
BLOCKED_NOT_CHECKED、历史transport限制、早期preflight PROPOSED、
属性与LibraryExtension时序NOT_PROVEN、M5及隔离构建NOT_READY/
settings-v1拒绝/loader-runtime false/真实性恢复生产门保持。
独立expected不得调用函数或从_EDITS回算；源修订/expected/
稳定Static-Test与运行预算各另授。
