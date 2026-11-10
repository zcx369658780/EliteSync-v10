# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Fresh Owner Sandbox Session + Exact Transport/Tool Re-establishment Result v0.1

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — REESTABLISHMENT_INPUT_NOT_PROVEN — NO B — NO M3 — NO AAR PROBE — NO M2`

日期：2026-09-10（Asia/Shanghai）。

## 1. 最终结论

`OWNER ACTIVATION = PRESENT FOR ONE FRESH SANDBOX CREATION UNDER THIS TASK`

fresh initial `wsb list --raw` 为 0 个 running Sandbox，因此按 Owner 授权创建恰好一个 fresh Windows Sandbox，并唯一绑定：

`0087a898-5221-41df-a33d-65045ffea69a`

新 ID 不等于已消失的旧 ID `68ece109-c661-420c-9899-02b1e9518036`。task-owned evidence transport、SYSTEM guest、Windows PowerShell 5.1、process/effective RemoteSigned、Security machine PATH、active adapter=0、default route=0 均已建立。Flutter SDK 已从任务文档明确引用的宿主 `D:/flutter` 以只读 share 进入 guest，并在新 guest-local 路径完成复制和关键身份复核。

但任务允许读取的精确历史对象没有提供 Android SDK、JDK、Git、Pub cache、Gradle cache、fixed module copy 的宿主 source exact path 与已接受 source identity。执行者没有猜测或搜索宿主路径，停止所有依赖步骤。

最终分类：

`REESTABLISHMENT_INPUT_NOT_PROVEN`

因此不得声称 A 成功，也未达到：

`POST-R7 OWNER SANDBOX SESSION + EXACT TRANSPORT/TOOL RE-ESTABLISHMENT ESTABLISHED — READY FOR FRESH REVIEW BEFORE R7 CONTINUATION TASK`

## 2. GitHub authority

- fresh-fetched `origin/main`=`16e78e668db360a2313db068aa19e7c5ec59800d`，匹配任务预期。
- FIRST path blob=`18485c95262051e43892436fb52413132c5ee626`，匹配并先完整读取。
- task commit=`70eae25ab371d625a72e622f9974a7ce115c81a8`。
- task sole parent=`16e78e668db360a2313db068aa19e7c5ec59800d`。
- task blob=`1ef9205dc33ec25ca944f66045db0d76ec0f0511`；task 只新增固定任务文件。
- 未运行默认 `git status`，未读取或修改 default index/protected staged state。

## 3. WSB 创建与最终状态

- `wsb --version`：exit=0，输出=`0.8.107.0`。
- initial `wsb list --raw`：exit=0，raw=`{"WindowsSandboxEnvironments":[]}`。
- 创建预算：attempt=`1/1`；config=`<Configuration><Networking>Disable</Networking></Configuration>`。
- `wsb start --raw`：exit=0，返回 ID=`0087a898-5221-41df-a33d-65045ffea69a`。
- post-start list：exit=0，仅有该 ID，唯一绑定通过。
- final list：exit=0，仍仅有该 ID。
- 未创建第二个 Sandbox；未 stop/close/reset/kill。

## 4. Task-owned transport 与 guest substrate

- nonce=`ca1bcb9c89504e2ba4a5a347d16fc940`。
- host transport=`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-ca1bcb9c89504e2ba4a5a347d16fc940`。
- guest transport=`C:/M3A/transport`。
- 新 writable share exit=0；未复用旧 R4/R7 share 或 guest path。
- controller run-as=`NT AUTHORITY\\SYSTEM`；`whoami` exit=0。
- Windows PowerShell=`5.1.26100.9444`。
- process execution policy=`RemoteSigned`；effective policy=`RemoteSigned`。
- Security machine PATH=`C:/Windows/system32;C:/Windows;C:/Windows/System32/Wbem;C:/Windows/System32/WindowsPowerShell/v1.0/`。
- `powershell.exe`=`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`。
- active adapter count=`0`；default route count=`0`。
- controller SHA-256=`188EA9F46CB4C2FD2DD2D474BB9DA862307062B42B74746961135AFB2A6C16EC`。
- helper SHA-256=`1004BCFEF16A2A5D5A79C184D293C940F9348185C240847610AB11192B4CB499`。

## 5. 九类 fixed inputs

| 对象 | host source / historical basis | guest destination / identity | 状态 |
| --- | --- | --- | --- |
| Flutter SDK | `D:/flutter`；R7 task 明确保留该宿主 source，R6 result 绑定 snapshot SHA 与 Dart 3.11.5 | `C:/M3A/tools/flutter`；read-only WSB share 后 guest-local `Copy-Item -Recurse` | `ESTABLISHED` |
| Android SDK | 允许对象未给 host source path/identity | 未建立 | `REESTABLISHMENT_INPUT_NOT_PROVEN` |
| JDK | 允许对象未给 host source path/identity | 未建立 | `REESTABLISHMENT_INPUT_NOT_PROVEN` |
| Git | 允许对象未给 host source path/identity | 未建立 | `REESTABLISHMENT_INPUT_NOT_PROVEN` |
| Pub cache | 允许对象未给 host source path/identity | 未建立；未枚举 package | `REESTABLISHMENT_INPUT_NOT_PROVEN` |
| Gradle cache | 允许对象未给 host source path/identity | 未建立；未运行 resolution | `REESTABLISHMENT_INPUT_NOT_PROVEN` |
| fixed module copy | 允许对象未给 host source path/identity | 未建立；未运行 pub/build，未检查 `.android` | `REESTABLISHMENT_INPUT_NOT_PROVEN` |
| controller/helper | task-owned transport | `C:/M3A/transport/M3A-Controller.ps1` / `M3A-Helper.ps1` | `ESTABLISHED` |
| evidence manifest | task-owned transport | `C:/M3A/transport/evidence-manifest.tsv` | `ESTABLISHED` |

Flutter bounded identity：

- bundled Dart=`C:/M3A/tools/flutter/bin/cache/dart-sdk/bin/dart.exe`，Length=5277696，SHA-256=`44328B98B6BF981D8307F72EF38ACBB37B8067394916953CAA48B8B444525152`。
- Dart identity exit=0：`Dart SDK version: 3.11.5 (stable) (Wed Apr 15 00:36:32 2026 -0700) on windows_x64`。
- Flutter-tools pubspec=`C:/M3A/tools/flutter/packages/flutter_tools/pubspec.yaml`，Length=2946，SHA-256=`6E31FF00AC4441294B60F20A71DCE2777CC80EB33663E6621DAE38C2391DB0EA`；未解析 coverage/code_builder。
- snapshot=`C:/M3A/tools/flutter/bin/cache/flutter_tools.snapshot`，Length=43747920，SHA-256=`E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`。
- 三个宿主关键文件的写后 Length/SHA 与写前一致；宿主 Flutter share 为 read-only。

## 6. 可审计命令摘要

| 序号 | 命令类别 | CLI exit | guest exit | 结果 |
| --- | --- | ---: | ---: | --- |
| 1 | exact main fetch | 0 | N/A | main 匹配 |
| 2 | FIRST blob verify/read | 0 | N/A | blob 匹配 |
| 3 | exact task ref fetch/read | 0 | N/A | task/parent/path/blob 匹配 |
| 4 | `wsb --version` | 0 | N/A | 0.8.107.0 |
| 5 | initial `wsb list --raw` | 0 | N/A | 0 running |
| 6 | `wsb --help` / `wsb start --help` / share/exec help | 0 | N/A | 仅本地语法读取 |
| 7 | `wsb start --raw --config <Networking Disable>` | 0 | N/A | 唯一创建 1/1 |
| 8 | post-start `wsb list --raw` | 0 | N/A | 新 ID 唯一 |
| 9 | task-owned writable transport share | 0 | N/A | 新 transport 建立 |
| 10 | substrate controller，run-as System | 0 | 0 | 身份/策略/PATH/网络门通过 |
| 11 | 宿主 `D:/flutter` 三个精确文件身份与 Dart version | 0 | N/A | source identity 通过 |
| 12 | `D:/flutter` read-only share | 0 | N/A | source transport 建立 |
| 13 | guest-local Flutter materialization，run-as System | 0 | 0 | copy/hash/version 通过 |
| 14 | 宿主 Flutter 三文件 post-hash | 0 | N/A | 与 pre-hash 一致 |
| 15 | final `wsb list --raw` | 0 | N/A | 新 ID 保留 |

任务要求的 GitHub authority fetch 是唯一外部远端访问。Sandbox 以 Networking Disable 创建；guest 只做本地系统状态、文件复制、哈希和 identity 命令，未观察到未授权网络尝试。

## 7. Evidence manifest

- manifest host path=`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-ca1bcb9c89504e2ba4a5a347d16fc940/evidence-manifest.tsv`。
- manifest guest path=`C:/M3A/transport/evidence-manifest.tsv`。
- Length=`837`。
- SHA-256=`A41FD0A5EA1598688AD50CD398EAF190EE42204B29105AE688D1C7281405AB88`。
- manifest 列出 9 个 payload 文件的精确相对路径、Length 与 SHA-256；manifest 本身不自包含。

## 8. 明确未执行与写入边界

- Flutter-tools Dart pub=`NOT_RUN`。
- `flutter pub get`=`NOT_RUN`。
- coverage/code_builder cache diagnostic=`NOT_CHECKED`。
- Flutter build/direct snapshot M3=`NOT_RUN`。
- AAR probe=`NOT_CHECKED`，probe=0。
- M2=`NOT_RUN`。
- product implementation=`NOT_RUN`。
- host SDK/cache write count=`0`（任务范围；read-only share，三个 Flutter 关键文件 pre/post hash 相同）。
- repository index/staged inspection=`NOT_PERFORMED`。
- CURRENT_CONTEXT=`NOT_MODIFIED`。

本结果仅等待 fresh 独立审查。执行者不自我接受、不更新 main、不执行 B。
