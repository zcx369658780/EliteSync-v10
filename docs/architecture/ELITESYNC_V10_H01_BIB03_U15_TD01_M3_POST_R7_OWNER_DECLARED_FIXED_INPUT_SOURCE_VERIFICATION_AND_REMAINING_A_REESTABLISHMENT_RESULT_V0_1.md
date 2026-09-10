# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Owner-Declared Fixed-Input Source Verification + Remaining A Re-establishment Result v0.1

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — JDK_SOURCE_IDENTITY_NOT_PROVEN — NO MATERIALIZATION — NO B — NO M3 — NO AAR PROBE — NO M2`

日期：2026-09-10（Asia/Shanghai）。

## 1. 最终结论

GitHub authority、FIRST、A3 task、A2 result、唯一 A1 Sandbox 与 A1 substrate preservation 均通过。

随后 host source verifier 按 Owner 声明路径开始 bounded verification。唯一一次 host `java -version` 已实际运行，但 Windows PowerShell 5.1 在 `$ErrorActionPreference='Stop'` 下将 Java 写入 stderr 的正常版本输出提升为 `NativeCommandError`，导致 recorder 在写出 JSON 前终止。

已捕获首行：

`openjdk version "17.0.18" 2026-01-20`

同一 `java.exe` 的只读文件 metadata/hash 后续证明：Company=`Eclipse Adoptium`、Product=`OpenJDK Platform 17.0.18`、File/ProductVersion=`17.0.18.0`、SHA-256=`5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`。这些证据仍不能独立证明任务要求的完整 build identity `Temurin/OpenJDK 17.0.18+8`。

由于 host `java -version` 预算为 exactly once，执行者未重跑。最终分类：

`JDK_SOURCE_IDENTITY_NOT_PROVEN`

未进入其余 source verification、任何 share/materialization 或 B。

## 2. Authority

- 附件授权文本 Length=11478，SHA-256=`E923DB1E23AE55E972D4574DFCBBC8AC55391F1501F52195ED1283763276B23B`。
- fresh-fetched `origin/main`=`e2a4cbb6bc4747f4c867a3ff7a6c74708e6259e6`。
- FIRST blob=`18485c95262051e43892436fb52413132c5ee626`，匹配并先完整读取。
- A3 task commit=`1ff8a74959c6c6d49f6a25ba1a3bb4fed75c2dc9`。
- A3 task sole parent=`e2a4cbb6bc4747f4c867a3ff7a6c74708e6259e6`。
- A3 task blob=`271e1ea9a772452db7ca2d1fc084b4e5982174d0`；只新增固定任务文件。
- A2 result blob=`bf9126e06c329c62151f3360dc01db8c754a21d5` 已读取。
- 未运行默认 `git status`，未读取或修改 default index/protected staged state。

## 3. Owner 六路径声明

| class | Owner literal host source |
| --- | --- |
| Android SDK | `C:/Users/zcxve/AppData/Local/Android/Sdk` |
| JDK | `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot` |
| Git | `C:/Program Files/Git` |
| Pub cache | `C:/Users/zcxve/AppData/Local/Pub/Cache` |
| Gradle cache | `D:/GradleHome` |
| fixed module | `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input-r6-r1/apps/flutter_elitesync_module` |

未从 PATH、registry、environment、Program Files/Users/drive enumeration 或历史 guest path 推导替代项。

## 4. A1 Sandbox 与 substrate preservation

- `wsb --version`：exit=0，输出=`0.8.107.0`。
- initial `wsb list --raw`：exit=0，仅有 `0087a898-5221-41df-a33d-65045ffea69a`。
- final `wsb list --raw`：exit=0，仍仅有同一 ID。
- 未创建新 Sandbox；未 stop/close/reset/kill。
- A3 preservation controller：WSB CLI exit=0、guest ExitCode=0、run-as `NT AUTHORITY\\SYSTEM`。
- Windows PowerShell=`5.1.26100.9444`；process/effective=`RemoteSigned`。
- Security machine PATH 与系统 PowerShell 路径匹配。
- active adapter count=`0`；default route count=`0`。
- A1 manifest SHA-256=`A41FD0A5EA1598688AD50CD398EAF190EE42204B29105AE688D1C7281405AB88`。
- Flutter root=`C:/M3A/tools/flutter`，未重做 materialization。
- Dart SHA-256=`44328B98B6BF981D8307F72EF38ACBB37B8067394916953CAA48B8B444525152`。
- Flutter-tools pubspec SHA-256=`6E31FF00AC4441294B60F20A71DCE2777CC80EB33663E6621DAE38C2391DB0EA`。
- snapshot SHA-256=`E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`。

## 5. Host source verification 状态

| class | 实际验证 | 状态 |
| --- | --- | --- |
| Android SDK | verifier 在 Java 前执行 root/两个固定对象检查，但 recorder 尚未写出结果即终止；未重跑 | `CHECKS_EXECUTED_BUT_NOT_RECORDED / IDENTITY_NOT_PROVEN` |
| JDK | root/java exists；Length=50344；SHA=`5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`；唯一 `java -version` 已运行但完整 stderr 未捕获 | `JDK_SOURCE_IDENTITY_NOT_PROVEN` |
| Git | 未到达 | `NOT_RUN` |
| Pub cache | 未到达 | `NOT_RUN` |
| Gradle cache | 未到达 | `NOT_RUN` |
| fixed module | 未到达；未执行 current-view | `NOT_RUN` |

JDK 的 metadata 为：FileVersion=`17.0.18.0`、ProductVersion=`17.0.18.0`、Company=`Eclipse Adoptium`、ProductName=`OpenJDK Platform 17.0.18`。Owner 路径名中的 `.8-hotspot` 不被提升为已验证 build identity。

host verifier script Length=7248，SHA-256=`12B6F6EF208909B603FB474A97253D947B7F518A0088C2AD65A7CEEE4316AF81`；process exit=1；预定 `a3-host-verification.json`=`NOT_CREATED`。

## 6. Materialization 与 guest recheck

- 六类 read-only share=`NOT_RUN`。
- Android/JDK/Git/Pub/Gradle/module guest-local copy=`NOT_RUN`。
- guest JDK/Git/module/Android identity recheck=`NOT_RUN`。
- host source write count=`0`。
- Sandbox Flutter source/pubspec/snapshot/package context modification=`NOT_PERFORMED`。

## 7. A3 evidence

- host transport=`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-ca1bcb9c89504e2ba4a5a347d16fc940`。
- guest transport=`C:/M3A/transport`。
- preservation script SHA-256=`2F8344DF6C8C4E257A8EC0852ABDC36870A64005419C0133C2C0C63EDA6FB5D2`。
- preservation result SHA-256=`05C41AC84F8D3A78E6E8CBA53547E3BC5C35CA426BE8A477AC9633993FC1ECF9`。
- A3 manifest=`a3-evidence-manifest.tsv`，Length=590，SHA-256=`4CCCA461892BB6633AA33C859AAB910BB53AC7AD1137D0C0E8C9503627CB763B`。
- manifest 列出 6 个 A3 payload 文件的精确相对路径、Length 与 SHA-256；manifest 本身不自包含。

## 8. 明确 NOT_RUN / NOT_CHECKED

- second `java -version`=`NOT_RUN`。
- Git `--version`=`NOT_RUN`。
- module current-view=`NOT_RUN`。
- source materialization=`NOT_RUN`。
- Flutter-tools Dart pub=`NOT_RUN`。
- `flutter pub get` / module Dart pub=`NOT_RUN`。
- coverage/code_builder diagnosis=`NOT_CHECKED`。
- Flutter M3/direct snapshot M3=`NOT_RUN`。
- AAR probe=`NOT_CHECKED`，probe=0。
- M2=`NOT_RUN`。
- Gradle resolution=`NOT_RUN`。
- network download/fill=`NOT_RUN`。
- product implementation=`NOT_RUN`。
- CURRENT_CONTEXT=`NOT_MODIFIED`。

本结果只等待 fresh 独立 review。执行者不自我接受、不更新 main、不执行 B。
