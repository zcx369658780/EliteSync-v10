# EliteSync v10｜Post-R7 Remaining A Materialization + Guest Identity Recheck Result v0.1

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — POST-R7 OWNER SANDBOX SESSION + EXACT TRANSPORT/TOOL RE-ESTABLISHMENT ESTABLISHED — READY FOR FRESH REVIEW BEFORE R7 CONTINUATION TASK — NO B — NO M3 — NO AAR PROBE — NO M2`

日期：2026-09-10（Asia/Shanghai）。

## 1. 最终结论

GitHub authority、FIRST、A7 task、A4/A6 result、唯一 preserved Sandbox、A1 substrate preservation 与全部六个 host drift gate 均通过。

六个固定 host sources 随后仅以 read-only share 暴露给 preserved Sandbox，并全部复制到 preferred guest-local writable destinations。六项 materialization 均成功，failed/mismatch/extras 均为 `0/0/0`。guest Android/JDK/Git/module/Pub/Gradle 必要 identity recheck 全部通过；guest Java/Git version 各恰好执行一次。

唯一成功结论严格为：

`POST-R7 OWNER SANDBOX SESSION + EXACT TRANSPORT/TOOL RE-ESTABLISHMENT ESTABLISHED — READY FOR FRESH REVIEW BEFORE R7 CONTINUATION TASK`

该结论仍不授权 B、Flutter-tools pub、M3、AAR probe 或 M2。

## 2. Authority

- fresh-fetched GitHub `main`=`a3c69b8e21cb7ddf458b15dfe20e100f00965449`。
- FIRST blob=`18485c95262051e43892436fb52413132c5ee626`，匹配并先完整读取。
- A7 task commit=`00abec0c987428f67342715065d70cbfca10a7f4`。
- A7 task sole parent=`a3c69b8e21cb7ddf458b15dfe20e100f00965449`。
- A7 task blob=`d01e643681c64c2980b13e55ef14f4191d018e9e`。
- A4 result blob=`8a0cfabfabe18172e7ca32b8b5d8731232465692`。
- A6 result blob=`e7c1a0173e5e5934bf598c7e7bb8f9e74ac3da56`。
- 未执行 repository-wide/directory-wide search；未访问 default index/protected staged state；未运行默认 `git status`。

## 3. Preserved Sandbox 与 A1 substrate

- `wsb --version` exit=`0`，version=`0.8.107.0`。
- initial `wsb list --raw` exit=`0`，running count=`1`，ID=`0087a898-5221-41df-a33d-65045ffea69a`。
- final `wsb list --raw` exit=`0`，仍只有同一 ID。
- Sandbox create/stop/close/reset/kill=`NOT_RUN`。
- run-as=`NT AUTHORITY\SYSTEM`。
- Windows PowerShell=`5.1.26100.9444`。
- process/effective execution policy=`RemoteSigned`。
- machine PATH=`C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\`。
- system PowerShell=`C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`。
- active adapter count=`0`；default route count=`0`。
- A1 evidence manifest SHA-256=`A41FD0A5EA1598688AD50CD398EAF190EE42204B29105AE688D1C7281405AB88`。
- existing Flutter Dart SHA=`44328B98B6BF981D8307F72EF38ACBB37B8067394916953CAA48B8B444525152`。
- existing Flutter-tools pubspec SHA=`6E31FF00AC4441294B60F20A71DCE2777CC80EB33663E6621DAE38C2391DB0EA`。
- existing Flutter-tools snapshot SHA=`E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`。
- Flutter materialization=`NOT_REDONE`；现有 Flutter source/pubspec/snapshot/package context=`NOT_MODIFIED`。

## 4. Host drift gate

| source | bounded gate | result |
| --- | --- | --- |
| Android | `platform-tools\adb.exe` SHA=`7035CF5EC7F99F7B5662A9F5395F9DCCFC3B6FE42583D0B9550124A0C3496606`；`cmdline-tools\latest\bin\sdkmanager.bat` SHA=`11D021F90186F7FCC0B2D97623348C9C857109636B29D70FA1B804A4D603F5E7` | PASS |
| JDK | `bin\java.exe` SHA=`5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`；host `java -version`=`NOT_RUN` | PASS |
| Git | `cmd\git.exe` SHA=`DA240FE9BC24895B3E04150A4990B8A6FF329ECABCD8F19684C2CC310DA5EF3F`；host `git --version`=`NOT_RUN` | PASS |
| Pub | exact root exists；package-specific inspection=`NOT_RUN` | PASS |
| Gradle | exact root exists；resolution=`NOT_RUN` | PASS |
| fixed module | accepted helper SHA=`6ECA7C8ADF8AF51CD2CAE08E736595F4BA4C9324F891AF80DE604A1A3DC6311D`；527/301/3234145/0；TSV Length=69676，SHA=`4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E` | PASS |

host module current-view generation count=`1`。第一次 aggregation wrapper 在 helper 已成功生成 TSV/stats 后读取未定义 `$LASTEXITCODE` 而退出；最小修正后的 wrapper 仅复用既有 TSV/stats 完成其他固定检查，没有再次枚举 module，也没有运行任何 host version command。

六个 host source root 的 final LastWriteTimeUtc 均与 materialization 前一致。所有 host shares 均为 read-only，host source write count=`0`。

## 5. Read-only shares

| source | exact host path | guest-visible source | allow-write | exit |
| --- | --- | --- | --- | ---: |
| Android | `C:\Users\zcxve\AppData\Local\Android\Sdk` | `C:\M3A\source\a7\android` | false | 0 |
| JDK | `C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot` | `C:\M3A\source\a7\jdk` | false | 0 |
| Git | `C:\Program Files\Git` | `C:\M3A\source\a7\git` | false | 0 |
| Pub | `C:\Users\zcxve\AppData\Local\Pub\Cache` | `C:\M3A\source\a7\pub` | false | 0 |
| Gradle | `D:\GradleHome` | `C:\M3A\source\a7\gradle` | false | 0 |
| module | `D:\EliteSync-M3-readiness-v02\attempts\M3-ISO-V02-008\input-r6-r1\apps\flutter_elitesync_module` | `C:\M3A\source\a7\module` | false | 0 |

share requested/attempted/succeeded=`6/6/6`。WSB CLI 无本任务使用的 unshare 动作；六个 read-only mappings 保留在 preserved Sandbox 中，不授予 guest 写回 host source 的能力。

## 6. Guest-local materialization

所有 preferred destination 在复制前均不存在。统一方法：

`robocopy /E /COPY:DAT /DCOPY:DAT /R:0 /W:0 /XJ /NFL /NDL /NP /NJH`

| source | guest-local destination | robocopy exit | dirs copied | files copied | bytes summary | failed/mismatch/extras |
| --- | --- | ---: | ---: | ---: | --- | --- |
| Android | `C:\M3A\tools\android` | 1 | 16125 | 103648 | 9.089 g | 0/0/0 |
| JDK | `C:\M3A\tools\jdk` | 1 | 88 | 492 | 302.59 m | 0/0/0 |
| Git | `C:\M3A\tools\git` | 1 | 830 | 9311 | 400.26 m | 0/0/0 |
| Pub | `C:\M3A\cache\pub` | 1 | 18650 | 82432 | 1.553 g | 0/0/0 |
| Gradle | `C:\M3A\cache\gradle` | 1 | 60095 | 125547 | 9.988 g | 0/0/0 |
| module | `C:\M3A\work\apps\flutter_elitesync_module` | 1 | 302 | 527 | 3.08 m | 0/0/0 |

Robocopy exit=`1` 表示已复制且无 copy failure；六个 destination 均 exists/container。module 的 robocopy directory total 包含复制根，canonical helper 统计仍为 301 descendant directories。

## 7. Guest identity rechecks

### Android

- guest `C:\M3A\tools\android\platform-tools\adb.exe` SHA=`7035CF5EC7F99F7B5662A9F5395F9DCCFC3B6FE42583D0B9550124A0C3496606`，匹配 host fixed identity。
- guest `C:\M3A\tools\android\cmdline-tools\latest\bin\sdkmanager.bat` SHA=`11D021F90186F7FCC0B2D97623348C9C857109636B29D70FA1B804A4D603F5E7`，匹配 host fixed identity。

### JDK

- guest `java.exe` SHA=`5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`。
- guest `java -version` invocation count=`1`；native capture exit=`0`；stdout 为空。
- native stderr 证明 `openjdk version "17.0.18"` 与 `OpenJDK Runtime Environment Temurin-17.0.18+8 (build 17.0.18+8)`。
- result=`PASS — TEMURIN / OPENJDK 17.0.18+8`。

### Git

- guest `git.exe` SHA=`DA240FE9BC24895B3E04150A4990B8A6FF329ECABCD8F19684C2CC310DA5EF3F`。
- guest `git --version` invocation count=`1`；native capture exit=`0`；stdout=`git version 2.53.0.windows.1`；stderr 为空。
- result=`PASS`。

### Fixed module

- helper SHA=`6ECA7C8ADF8AF51CD2CAE08E736595F4BA4C9324F891AF80DE604A1A3DC6311D`。
- files=`527`；directories=`301`；total_bytes=`3234145`；reparse=`0`。
- TSV Length=`69676`；SHA-256=`4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`。
- historical-current-view identity=`EXACT MATCH / PASS`。

### Pub and Gradle

- guest Pub root `C:\M3A\cache\pub` exists/container，materialization completed。
- coverage/code_builder package-specific inspection=`NOT_RUN`。
- guest Gradle root `C:\M3A\cache\gradle` exists/container，materialization completed。
- Gradle dependency resolution=`NOT_RUN`。

## 8. Explicit NOT_RUN / NOT_CHECKED

- Flutter-tools Dart pub=`NOT_RUN`。
- `flutter pub get` / module Dart pub=`NOT_RUN`。
- coverage diagnosis=`NOT_CHECKED`。
- code_builder diagnosis=`NOT_CHECKED`。
- Gradle dependency resolution=`NOT_RUN`。
- Flutter M3/direct flutter_tools.snapshot M3=`NOT_RUN`。
- AAR probe=`NOT_CHECKED`，probe=`0`。
- M2=`NOT_RUN`。
- B=`NOT_RUN`。
- network/download/install/fill=`NOT_RUN`。
- product implementation=`NOT_RUN`。
- CURRENT_CONTEXT=`NOT_MODIFIED`。

## 9. Evidence

Task-owned evidence root：

`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-M3A-ca1bcb9c89504e2ba4a5a347d16fc940\a7`

| artifact | Length | SHA-256 |
| --- | ---: | --- |
| `M3A-A7-HostDrift.ps1` | 4461 | `C906ADBCEA30B4D4468A228E2DDE5834A0BC47348A85A656380955155FE2EABA` |
| `a7-host-drift.json` | 6268 | `BF33A8ADE07A9D8A9A5AE5F60FD870BE63D3AF5B09A84072C0D50C1C0087EF46` |
| `a7-host-module-current.tsv` | 69676 | `4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E` |
| `a7-host-module-stats.json` | 346 | `413AEF44521990DFEE6A3BFF6D8962F8E34B8596D575BDC60BC6BD4831906B92` |
| `M3A-A7-Share.ps1` | 1806 | `E7E3E772EB3DBD389400EC6CBCD70A4CE145EB0BA9991E724B3ACA2E807AE8BC` |
| `a7-share-results.json` | 2594 | `5C5787A5DC5FE837772C688AD7C7CA211CC833D5F4571BEB4207815A8561CF2F` |
| `M3A-A7-GuestMaterialize.ps1` | 7796 | `4B67C20281D6DA53BABC144F850472E931C7045E5E5CF2B7FFD17CEE6A7A401C` |
| `a7-guest-result.json` | 13663 | `ED3389DE88F30FB363ECFAE4567DA5F2F858E82D6DC6D5822F42CE40E02BD352` |
| `a7-guest-module-current.tsv` | 69676 | `4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E` |
| `a7-guest-module-stats.json` | 290 | `352A5A50142D1A2E2035E525CB10EF8E09A7E6C41E5E80D140FD75765AC0648F` |
| `current-view-r6r4r2.ps1` | 2031 | `6ECA7C8ADF8AF51CD2CAE08E736595F4BA4C9324F891AF80DE604A1A3DC6311D` |

本候选只记录 A7 成功结果，等待 fresh 独立 ACCEPT/REJECT。执行者不自我接受、不更新 `main`、不执行 B。
