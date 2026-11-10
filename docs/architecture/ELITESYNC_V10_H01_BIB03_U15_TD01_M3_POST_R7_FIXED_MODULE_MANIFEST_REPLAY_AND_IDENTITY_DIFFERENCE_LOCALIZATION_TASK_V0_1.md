# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Fixed Module Manifest Replay + Identity Difference Localization Task v0.1

Status: `PUBLISHED TASK SHEET — MODULE IDENTITY DIFFERENCE ONLY — NO MATERIALIZATION — NO B — NO M3 — NO AAR PROBE — NO M2`

日期：2026-09-10（Asia/Singapore）。

## 1. Authority 与目标

当前 accepted main 必须为：

`510a4b388375fcefdf1623b5cb9c7cce3c201186`

A4 已接受的唯一结论：A4 verifier 对 Owner-declared fixed module 得到 files=527、directories=301、bytes=3234145、reparse=0，但 manifest=`FD599405E7BB490B223CE63EA5E69967231873DB049260EF07DEF7337AD31EE7`，与历史 expected `6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB` 不同；这尚不足以证明 module 内容漂移，因为历史 R6-R1 只固定“relative path + SHA-256”而未完整固定序列化细节。

本任务唯一目标：对同一个 Owner-declared source 做只读 manifest replay，区分：

- `SERIALIZATION_IMPLEMENTATION_DIFFERENCE`
- `ACTUAL_FILE_IDENTITY_DIFFERENCE`
- `IDENTITY_DIFFERENCE_NOT_LOCALIZED`

不允许 materialization，不允许进入 B/M3/M2。

## 2. FIRST 与精确只读输入

1. fresh-fetch main；若不等于 `510a4b388375fcefdf1623b5cb9c7cce3c201186`，STOP `MAIN AUTHORITY CHANGED`。
2. FIRST 读取固定 blob `18485c95262051e43892436fb52413132c5ee626`。
3. 读取本任务。
4. 只读读取：A4 result blob=`8a0cfabfabe18172e7ca32b8b5d8731232465692`；R6-R1 result blob=`b47be1a5c33c7499e14678a0dc842e6d8dc5cf09`；R6-R1 task commit=`370089838888af2f477736f961a25adc112137b4`，仅用于 manifest 合同。

不得仓库/目录搜索，不访问 default index/protected staged state。

## 3. 唯一授权 source

只允许访问：

`D:\EliteSync-M3-readiness-v02\attempts\M3-ISO-V02-008\input-r6-r1\apps\flutter_elitesync_module`

该 source 只读。不得访问 `D:\EliteSync-v10\apps\flutter_elitesync_module` 作为替代比较源。

先复核：527 files / 301 dirs / 3234145 bytes / reparse=0。任一不符，STOP `FIXED_MODULE_STRUCTURAL_IDENTITY_DRIFT`。

## 4. Manifest replay

对这个单一 source 允许一次 bounded recursive enumeration，仅用于生成相对路径与每个文件 SHA-256。不得读取文件内容作技术分析；哈希读取仅用于 identity。

至少计算并记录以下明确序列化变体，所有变体均按 ordinal relative path 排序：

A. `relative_path<TAB>lowercase_file_sha256`，LF，UTF-8 no BOM，最终每行 LF。
B. 与 A 相同，但 uppercase file SHA-256。
C. 与 A 相同，但 CRLF。
D. `relative_path<TAB>length<TAB>uppercase_file_sha256`，LF，UTF-8 no BOM。
E. A 但路径分隔符分别规范为 `/` 与 `\`，若原实现已固定其中一种则分别记录。

目标 expected manifest：

`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`

A4 observed manifest：

`FD599405E7BB490B223CE63EA5E69967231873DB049260EF07DEF7337AD31EE7`

若任一受控序列化变体精确命中 expected，则分类：

`FIXED_MODULE IDENTITY ESTABLISHED — SERIALIZATION_IMPLEMENTATION_DIFFERENCE`

并记录命中的规范；不得继续寻找文件差异。

## 5. 若无变体命中

只有所有受控变体都未命中时，允许生成 current per-file identity TSV：`relative_path<TAB>length<TAB>sha256`。

只允许把它与历史 evidence 中**已经存在且精确已知路径**的 frozen manifest/current-view 对象比较；不得搜索历史目录。若没有精确已知 historical per-file manifest path，则不得猜，分类：

`IDENTITY_DIFFERENCE_NOT_LOCALIZED — HISTORICAL_PER_FILE_MANIFEST_NOT_AUTHORIZED`

若有精确 authorized historical per-file manifest，则只输出：差异文件数量、首个至多 10 个 relative paths、每项 historical/current length+SHA；不得输出文件内容。

若存在任何 per-file difference，分类：

`ACTUAL_FILE_IDENTITY_DIFFERENCE`

## 6. Sandbox 与下游

fresh `wsb list --raw` 只用于确认 preserved Sandbox `0087a898-5221-41df-a33d-65045ffea69a` 是否仍唯一运行；不得 exec、share、materialize、stop/close/reset/kill。Sandbox 不可用不阻塞本 host-only manifest replay，但必须记录状态，不得创建新 Sandbox。

明确禁止：Flutter/Dart pub、coverage/code_builder、Gradle resolution、M3、AAR probe、M2、网络、host source 写入、产品实现。

## 7. 结果与停止

创建：

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_MODULE_MANIFEST_REPLAY_AND_IDENTITY_DIFFERENCE_LOCALIZATION_RESULT_V0_1.md`

只新增该 result，candidate sole parent 必须为本 task commit。记录每个 replay variant SHA、是否命中 expected/A4-observed、最终分类、所有 NOT_RUN 项，然后 STOP。不得 self-accept，不得 update main，不得执行 materialization 或 B。