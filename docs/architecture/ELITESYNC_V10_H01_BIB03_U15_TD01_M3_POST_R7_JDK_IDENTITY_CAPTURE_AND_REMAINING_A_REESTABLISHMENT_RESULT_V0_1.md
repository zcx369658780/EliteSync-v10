# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 JDK Identity Capture + Remaining A Re-establishment Result v0.1

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — FIXED_MODULE_SOURCE_IDENTITY_MISMATCH — ALL-SIX HOST SOURCES NOT ESTABLISHED — NO MATERIALIZATION — NO B — NO M3 — NO AAR PROBE — NO M2`

日期：2026-09-10（Asia/Shanghai）。

## 1. 最终结论

A4 的 GitHub main、FIRST、task、accepted A3 result、唯一 preserved Sandbox、A1 substrate preservation 与新的 JDK identity capture 均通过。JDK 捕获预算恰好消耗一次；完整 native stderr 证明 `Temurin/OpenJDK 17.0.18+8`。

随后继续六个 Owner-declared host sources 的 bounded verification。Android 固定对象、JDK、Git、Pub cache root 与 Gradle cache root/固定对象通过，但 fixed module 的 current-view manifest SHA-256 为：

`FD599405E7BB490B223CE63EA5E69967231873DB049260EF07DEF7337AD31EE7`

任务固定权威要求：

`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`

二者不一致。虽然 files=`527`、directories=`301`、total_bytes=`3234145`、reparse=`0` 均匹配，完整 manifest identity 仍不匹配。最终分类：

`FIXED_MODULE_SOURCE_IDENTITY_MISMATCH`

因此 all-six host sources 未建立；未建立任何新 share，未 materialize 任一来源，未执行 guest source identity recheck，也未进入 B/M3/AAR/M2。

## 2. Authority

- fresh-fetched GitHub `main`=`d36170669bd25d33d5e336ba7e34d2cadb15b69d`。
- FIRST path=`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`。
- FIRST blob=`18485c95262051e43892436fb52413132c5ee626`，匹配并先完整读取。
- A4 task commit=`0161e1cd370635e2f2e0d72ee1bf3dd390248d0d`。
- A4 task sole parent=`d36170669bd25d33d5e336ba7e34d2cadb15b69d`。
- A4 task blob=`ee55d4c6680e1ab048d1fb12b37526b2705a2f34`。
- accepted A3 result commit/tree authority=`d36170669bd25d33d5e336ba7e34d2cadb15b69d`；result blob=`967997075b1f4ea1338dfad0c2143fccce8a14c4`。
- 未运行默认 `git status`，未读取或修改 default index/protected staged state。

## 3. Preserved Sandbox 与 A1 substrate

- `wsb --version`：exit=0，输出=`0.8.107.0`。
- initial `wsb list --raw`：exit=0，仅有 `0087a898-5221-41df-a33d-65045ffea69a`。
- final `wsb list --raw`：exit=0，仍仅有同一 ID。
- 未创建、stop、close、reset 或 kill Sandbox。
- guest execution：exit=0，run-as `NT AUTHORITY\SYSTEM`。
- Windows PowerShell=`5.1.26100.9444`。
- process/effective execution policy=`RemoteSigned`。
- machine PATH=`C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\`。
- system PowerShell=`C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`。
- active adapter count=`0`；default route count=`0`。
- A1 evidence manifest SHA-256=`A41FD0A5EA1598688AD50CD398EAF190EE42204B29105AE688D1C7281405AB88`。
- Flutter root=`C:\M3A\tools\flutter`，materialization=`NOT_REDONE`。
- Dart SHA-256=`44328B98B6BF981D8307F72EF38ACBB37B8067394916953CAA48B8B444525152`。
- flutter_tools pubspec SHA-256=`6E31FF00AC4441294B60F20A71DCE2777CC80EB33663E6621DAE38C2391DB0EA`。
- flutter_tools snapshot SHA-256=`E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`。

## 4. A4 exactly-once JDK capture

- exact executable=`C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\java.exe`。
- pre-invocation Length=`50344`，SHA-256=`5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`；无 identity drift。
- capture method=`System.Diagnostics.Process`；`UseShellExecute=false`；stdout/stderr 均独立 redirected。
- arguments=`-version`；invocation count=`1`；exit=`0`。
- native stdout 为空。
- native stderr 完整包含：`openjdk version "17.0.18"`、`OpenJDK Runtime Environment Temurin-17.0.18+8 (build 17.0.18+8)`、`OpenJDK 64-Bit Server VM Temurin-17.0.18+8 (build 17.0.18+8, mixed mode, sharing)`。
- conclusion=`JDK SOURCE IDENTITY PASS — TEMURIN / OPENJDK 17.0.18+8`。
- 未使用目录名中的 `.8-hotspot` 代替 process output 证明；未发生 `NativeCommandError`。

## 5. Six-source host verification

| class | bounded evidence | result |
| --- | --- | --- |
| Android SDK | root exists；`platform-tools\adb.exe` SHA=`7035CF5EC7F99F7B5662A9F5395F9DCCFC3B6FE42583D0B9550124A0C3496606`；`cmdline-tools\latest\bin\sdkmanager.bat` SHA=`11D021F90186F7FCC0B2D97623348C9C857109636B29D70FA1B804A4D603F5E7` | `PASS` |
| JDK | root/java exists；java SHA matches；exactly-once captured output proves Temurin/OpenJDK `17.0.18+8` | `PASS` |
| Git | `cmd\git.exe` Length=`46480`，SHA=`DA240FE9BC24895B3E04150A4990B8A6FF329ECABCD8F19684C2CC310DA5EF3F`；native capture exit=0，stdout=`git version 2.53.0.windows.1` | `PASS` |
| Pub cache | declared root exists/container | `PASS` |
| Gradle cache | declared root exists；`caches\8.14`、`caches\9.0.0`、`wrapper\dists\gradle-8.14-all`、`wrapper\dists\gradle-9.0.0-bin` 均存在 | `PASS` |
| fixed module | files=527；directories=301；bytes=3234145；reparse=0；current manifest SHA=`FD599405E7BB490B223CE63EA5E69967231873DB049260EF07DEF7337AD31EE7`，不等于 expected `6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB` | `FIXED_MODULE_SOURCE_IDENTITY_MISMATCH` |

只访问 Owner 明确声明的六个 host source 与任务点名的固定相对对象；未搜索 PATH、registry、environment、drives、Program Files、Users、repository 或替代位置。verifier 为 read-only，host write count=`0`；六个 source root 的 pre/post LastWriteTimeUtc 均未变化。

## 6. Materialization 与 downstream

- 新 read-only host share=`NOT_ESTABLISHED`；share command count=`0`。
- Android/JDK/Git/Pub/Gradle/module guest-local materialization=`NOT_RUN`。
- guest JDK/Git/module/Android/cache-root recheck=`NOT_RUN`。
- Flutter-tools Dart pub=`NOT_RUN`。
- `flutter pub get` / module Dart pub=`NOT_RUN`。
- coverage/code_builder diagnosis=`NOT_CHECKED`。
- Flutter M3/direct snapshot M3=`NOT_RUN`。
- AAR probe=`NOT_CHECKED`，probe=`0`。
- M2=`NOT_RUN`。
- Gradle dependency resolution=`NOT_RUN`。
- network/download/dependency fill=`NOT_RUN`。
- product implementation=`NOT_RUN`。
- Sandbox Flutter source/pubspec/snapshot/package context modification=`NOT_PERFORMED`。
- CURRENT_CONTEXT=`NOT_MODIFIED`。

## 7. Evidence

Task-owned evidence root:

`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-M3A-ca1bcb9c89504e2ba4a5a347d16fc940`

| artifact | Length | SHA-256 |
| --- | ---: | --- |
| `M3A-A4-JdkCapture.ps1` | 2060 | `1075B0DBDA8F3522DC8D678A276F03AF264109CD237D18630298BE22BCC5B10A` |
| `a4-jdk-capture.json` | 840 | `B5B90853C67D414865546F72E108E02320C8AFF965ED30DD13A0BCEDC6101876` |
| `M3A-A4-HostVerify.ps1` | 7483 | `13CBE1C01DD26D08BFBF5696902DEB4F146176A020FFF6CAE06D346A0AD19842` |
| `a4-host-verification.json` | 7582 | `D2ADEA84A994F73EDC96A4D6DCDCBE37F0704AC8B78F356076FCF83EA4E9D698` |
| refreshed `a3-preservation.json` | 2678 | `7990D48B7519571488740A3B9E9940A50C89074473A9EB4B252B20B6B805CC26` |

本候选只记录 A4 的 terminal blocker，等待 fresh 独立 ACCEPT/REJECT。执行者不自我接受、不更新 `main`、不执行 B。
