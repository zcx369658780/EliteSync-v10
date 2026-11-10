# APP-M5-58 SOURCE-ONLY candidate

Status: CANDIDATE — pending independent Work LEVEL2 and GPT-6.1 Sol/high.
Main: cf8bfaa4a03b8c9a682105617b185141904413be.
唯一源码: Check-CrlfContract.ps1；本报告不修改旧合同或旧证据。

## 本轮 A 原回执
A command: 2756 characters; exit 0; reads 3; output includes final CRLF.
A1/1 closed; B0/1 at save.
本轮 A 只核来源身份、四 schema 数量和两根 Phase/Result/Budget；
没有执行完整字面、范围、scope 或算术检查器。

```json
{"Phase":"A","Result":"PASS","Sources":[{"Path":"EVIDENCE/APP-M5-55-LOCAL-CRLF-MATERIALS-CONTRACT/crlf-contract.md","Bytes":14300,"SHA256":"214F7D4232DE8A8A71CF71353968466ECFD2E55B74D85792A7026BD8B3E2A051"},{"Path":"EVIDENCE/APP-M5-54-RAW-ANCHOR-SCOPE-MAP/anchor-map.md","Bytes":5879,"SHA256":"CC1DA4B0484DC29E5BA2DE0DC4765337629394D327D8775869883533E9CE4774"},{"Path":"EVIDENCE/APP-M5-49-SCOPED-KOTLIN-PATCH-MATERIALS/patch-materials.md","Bytes":13818,"SHA256":"B783379A7FC307B8750F73758261BEBCF739CDFA72A234B80148D96F4AD9DA49"}],"Counts":{"ContractDeclarations":3,"ContractAnchors":4,"MapSpans":7,"ContractLiterals":8},"ContractPhase":"A","ContractResult":"PASS","ContractBudget":"A1/1 closed; B0/1 at save","MapPhase":"A","MapResult":"PASS","MapBudget":"A1/1 closed; B0/1 at save","Reads":3,"ABudget":"1/1 closed","BBudget":"0/1 at save","Execution":0}
```

## 源码设计与未验证层级
固定根与三准确路径/长度/SHA-256；先普通文件及祖先 non-reparse，
再各一次读取、身份和 strict UTF8。明确阶段 FailureTag；
未知内部异常使用 INTERNAL_EXCEPTION，不输出 exception 或 Raw。
JSON/kotlin fence 使用完整 delimiter 与唯一前门，保留局部末 LF；
三份文件中的数据仅作文字/JSON解析，不执行字符串。
Anchors、Literals 和 Spans 分别按 Id 索引，显式将
preflight-before 关联 apply-preflight-before，不再从 Raw 节点要求 Start。
八局部 LF→CRLF 字面、UTF8 bytes 与五项计数分别核对；
四锚有序非重叠/原始范围/行/scope引用、三声明完整字段，
四 delta 与合同储存总 delta/拟尺寸均有具名核定。
成功具名表最多 64 项，完整 JSON 含末 CRLF ≤4KiB，超限停止；
失败只固定标签、Reads 和预算，不输出部分成功表或来源正文。
不写文件、不子进程、网络、SDK、fixture 或变换候选调用。

本轮仅交付源码；语法/parser/AST/点源/import/脚本函数及 checker 执行、
完整字面行为、字段级 schema 适用性和实际限额路径均 NOT_CHECKED。
源码内具体字段、Id 及 delimiter 关联须由独立审查实质核定；
A 的数量/预算回执不证明这些字段级关联正确。
本轮所有上述运行预算 0，不作可执行 PASS 或兼容性结论。

## 预算与保护
本任务 A1/1 已关闭；保存时 B0/1，最终 B 原回执只在回复提供。
B 不补读三来源，不改两候选。M5-55/56/57 旧预算关闭，
M5-55 REJECT 不追认旧 B。六冻结、原 fixture、旧合同、
dirty/untracked、候选和历史证据保持。
M5-50 SOURCE-ONLY/完整输入适用性 BLOCKED_NOT_CHECKED 保持；
早期 preflight PROPOSED，属性与 LibraryExtension 时序 NOT_PROVEN；
M5/隔离构建 NOT_READY/settings-v1拒绝/loader-runtime false 保持。
SDK/fixture/M5-50内容读取、测试/构建/安装/UAC/真实数据/生产动作0。
源码静态检查与一次运行、源修订、独立 expected 均须后继另授。
