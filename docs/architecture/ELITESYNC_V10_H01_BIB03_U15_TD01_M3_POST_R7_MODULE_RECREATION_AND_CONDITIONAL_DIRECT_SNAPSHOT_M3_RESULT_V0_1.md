# EliteSync v10｜Post-R7 Module Recreation + Conditional Direct-Snapshot M3 Result v0.1

Status: `EXECUTED RESULT CANDIDATE — RECREATION EXIT 0 — PROTECTED STATE EQUAL — ANDROID GRADLE SENTINEL NOT GENERATED — M3 NOT RUN — AAR NOT CHECKED — NO M2`

## 1. Final classification

唯一一次 supported existing-module recreation 实际启动并退出 `0`。五个 B6-classified IDE metadata paths 均由 Flutter 创建，protected non-generated pre/post manifests 完全相等，Flutter-tools snapshot identity保持不变。

但是任务限定的四个 `.android` Gradle sentinels 在 recreation 后仍全部不存在，因此在 conditional M3 之前按硬门停止：

`B7_MODULE_DOT_ANDROID_GRADLE_BUILD_NOT_GENERATED`

M3 invocation count=`0`，exact AAR probe count=`0`，M2=`NOT_RUN`。不得把 recreation exit `0` 或五个 IDE files 已创建解释为 `.android` generation、M3 或 AAR 成功。

## 2. Authority

- fresh-fetched GitHub `main`=`1799ded1b960d30f87e0411558cfbea69b324706`，与 B7 固定 authority 精确一致。
- FIRST path=`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`。
- FIRST blob=`18485c95262051e43892436fb52413132c5ee626`，已首先完整读取并匹配。
- B7 task branch=`task/h01-bib03-u15-td01-m3-post-r7-module-recreation-b7-v0-1`。
- B7 task commit=`57653b7923f8cd6eec47653f07eb54bf39fd6f18`。
- B7 task blob=`a7ac5bab3036150a7f7c6ba194110a0cdc52989b`。
- accepted B6 result blob=`755b2073389fe0f908dfe110b7b40d416f470ac1`，已完整读取。
- accepted B4 result blob=`24693a27360cc2fbf09bbd152c022e55511dc0ce`，仅用于 generation contract，已完整读取。
- accepted B2 result blob=`071b8b5cab38c6dc9121d3e4bf36d469f0010849`，仅用于 package context 与 direct-snapshot facts，已完整读取。
- repository-wide、host-wide、alternate-module search=`NOT_RUN`。
- default index/protected staged-state inspection、default `git status`=`NOT_RUN`。

## 3. Preserved Sandbox gate

- WSB CLI=`0.8.107.0`。
- initial `wsb list --raw`：running count=`1`；唯一 ID=`0087a898-5221-41df-a33d-65045ffea69a`；PASS。
- final `wsb list --raw`：running count=`1`；仍为同一 ID；PASS。
- Sandbox create/stop/close/reset/kill=`NOT_RUN`。

为保存 stdout/stderr、manifests、阶段和一次性计数，创建了新的 task-owned host evidence root，并将其作为一个可写 evidence share 映射到固定 Sandbox：

- host=`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-M3A-ca1bcb9c89504e2ba4a5a347d16fc940\b7`
- guest=`C:\M3B7Evidence_20260910_1`

该路径位于 repository、module、SDK/cache/source 之外；未复用或修改旧 B2/B4 evidence。

## 4. Minimum substrate recheck

| gate | observed | result |
| --- | --- | --- |
| principal | `NT AUTHORITY\SYSTEM` | PASS |
| Windows PowerShell | `5.1.26100.9444` | PASS |
| process execution policy | `RemoteSigned` | PASS |
| effective execution policy | `RemoteSigned` | PASS |
| active adapter count | `0` | PASS |
| default route count | `0` | PASS |
| Dart SHA-256 | `44328B98B6BF981D8307F72EF38ACBB37B8067394916953CAA48B8B444525152` | PASS |
| Flutter-tools pubspec SHA-256 | `6E31FF00AC4441294B60F20A71DCE2777CC80EB33663E6621DAE38C2391DB0EA` | PASS |
| Flutter-tools snapshot SHA-256 | `E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808` | PASS |
| coverage package_config entry | count=`1`; root=`file:///C:/M3A/cache/pub/hosted/pub.dev/coverage-1.15.0` | PASS |
| code_builder package_config entry | count=`1`; root=`file:///C:/M3A/cache/pub/hosted/pub.dev/code_builder-4.11.1` | PASS |
| Flutter root | `C:\M3A\tools\flutter` exists/container | PASS |
| Android root | `C:\M3A\tools\android` exists/container | PASS |
| JDK root | `C:\M3A\tools\jdk` exists/container | PASS |
| Git root | `C:\M3A\tools\git` exists/container | PASS |
| Pub root | `C:\M3A\cache\pub` exists/container | PASS |
| Gradle root | `C:\M3A\cache\gradle` exists/container | PASS |
| module root | `C:\M3A\work\apps\flutter_elitesync_module` exists/container | PASS |

Flutter-tools offline pub rerun=`NOT_RUN`。

## 5. Protected pre-state manifest

Manifest set包含当前 module 内除以下 allowlist 与 `build/**` 以外的每个文件：五个 B6 IDE paths、`.android/**`、`.ios/**`、`.dart_tool/**`、`.flutter-plugins-dependencies`、`pubspec.lock`。没有读取 product contents 的技术语义；只读取 bytes、Length 和 SHA-256。

Serialization：

`relative_path<TAB>Length<TAB>SHA256`

- path normalization=`/`
- ordering=`ordinal`
- encoding=`UTF-8 no BOM`
- line ending=`LF`
- nonempty manifest final LF=`present`

Pre manifest：

- record count=`526`
- Length=`69592`
- SHA-256=`9B25CCCA1AFC6CE940712B0AFE5024CA996FF563CD86A198875CC6FC5C9E49A0`

## 6. Pre-recreation generated-state observations

只检查任务列出的 exact paths；没有 broad enumerate `.android` 或 `.ios`。

| path | pre exists |
| --- | --- |
| `.idea/libraries/Dart_SDK.xml` | false |
| `.idea/modules.xml` | false |
| `.idea/workspace.xml` | false |
| `flutter_elitesync_module_android.iml` | false |
| `flutter_elitesync_module.iml` | false |
| `.android/settings.gradle` | false |
| `.android/settings.gradle.kts` | false |
| `.android/build.gradle` | false |
| `.android/build.gradle.kts` | false |
| `.ios` | true |
| `.dart_tool` | true |
| `.flutter-plugins-dependencies` | true |
| `pubspec.lock` | true |

## 7. Exact recreation invocation and result

- invocation count=`1`
- process started=`true`
- executable=`C:\M3A\tools\flutter\bin\cache\dart-sdk\bin\dart.exe`
- complete args=`--packages="C:\M3A\tools\flutter\packages\flutter_tools\.dart_tool\package_config.json" "C:\M3A\tools\flutter\bin\cache\flutter_tools.snapshot" --no-version-check create --template=module --offline .`
- cwd=`C:\M3A\work\apps\flutter_elitesync_module`
- `--overwrite`=`NOT_USED`
- recreation `--no-pub`=`NOT_USED`
- `flutter.bat` / `shared.bat`=`NOT_RUN`
- start UTC=`2026-09-10T08:55:06.5938329Z`
- end UTC=`2026-09-10T08:55:09.6136882Z`
- duration=`3019.855 ms`
- exit=`0`

Process environment roots：

- `FLUTTER_ROOT=C:\M3A\tools\flutter`
- `PUB_CACHE=C:\M3A\cache\pub`
- `ANDROID_HOME=C:\M3A\tools\android`
- `ANDROID_SDK_ROOT=C:\M3A\tools\android`
- `JAVA_HOME=C:\M3A\tools\jdk`
- `GRADLE_USER_HOME=C:\M3A\cache\gradle`
- PATH=`C:\M3A\tools\jdk\bin;C:\M3A\tools\git\cmd;C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0`

Captured stdout：

```text
Recreating project ....
  .idea\libraries\Dart_SDK.xml (created)
  .idea\modules.xml (created)
  .idea\workspace.xml (created)
  flutter_elitesync_module.iml (created)
  flutter_elitesync_module_android.iml (created)
Resolving dependencies...
Downloading packages...
Got dependencies.
Wrote 5 files.

All done!
Your module code is in lib\main.dart.
```

- stdout Length=`349`；SHA-256=`C0C3F6792C085BD2A7A3691D1D2F78C4AAC58B3D9917489588008A22804AD9EA`
- stderr Length=`0`；SHA-256=`E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855`
- genuine URL/socket/DNS/connection failure diagnostic=`NONE OBSERVED`
- classification=`RECREATION EXIT 0 / NO GENUINE NETWORK FAILURE`

`Downloading packages...` 是 offline pub 的正常状态行；没有 URL、SocketException、socket error、failed host lookup、DNS、connection 或其他 genuine network failure evidence，不能据此分类为 network attempt。没有联网补包或 retry。

## 8. Protected post-state comparison

Post manifest 使用与 pre 完全相同的 set、serialization、ordering、encoding 和 exclusions：

- record count=`526`
- Length=`69592`
- SHA-256=`9B25CCCA1AFC6CE940712B0AFE5024CA996FF563CD86A198875CC6FC5C9E49A0`
- pre/post byte-for-byte equality=`true`
- every relative path / Length / SHA-256 equality=`PASS`
- protected path appeared/disappeared/changed=`NONE`

因此 `B7_PROTECTED_NON_GENERATED_STATE_CHANGED` 未触发。

## 9. Post-recreation generated-state and Android gate

| path | post exists | change/classification |
| --- | --- | --- |
| `.idea/libraries/Dart_SDK.xml` | true | allowed creation |
| `.idea/modules.xml` | true | allowed creation |
| `.idea/workspace.xml` | true | allowed creation |
| `flutter_elitesync_module_android.iml` | true | allowed creation |
| `flutter_elitesync_module.iml` | true | allowed creation |
| `.android/settings.gradle` | false | required sentinel absent |
| `.android/settings.gradle.kts` | false | required sentinel absent |
| `.android/build.gradle` | false | required sentinel absent |
| `.android/build.gradle.kts` | false | required sentinel absent |
| `.ios` | true | present before and after |
| `.dart_tool` | true | present before and after |
| `.flutter-plugins-dependencies` | true | present before and after |
| `pubspec.lock` | true | present before and after |

Android Gradle sentinel established=`false`。四个 exact sentinels 全部 absent，触发：

`B7_MODULE_DOT_ANDROID_GRADLE_BUILD_NOT_GENERATED`

没有 broad enumerate `.android`／`.ios`，没有搜索其他 settings/build 文件或 alternate module path。

Flutter-tools snapshot post-recreation SHA-256：

`E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`

Result=`PASS / UNCHANGED`；snapshot regenerate/rebuild=`NOT_RUN`。

## 10. Conditional M3 and exact AAR probe

Android Gradle sentinel gate未通过，因此：

- direct-snapshot M3 invocation count=`0`
- M3 process started=`false`
- M3 executable/args/cwd/environment/timing/stdout/stderr/exit=`NOT_APPLICABLE`
- M3 retry=`NOT_RUN`
- exact AAR probe count=`0`
- exact AAR probe result=`NOT_CHECKED`
- exact AAR Length/SHA-256=`NOT_APPLICABLE`
- alternate AAR path search=`NOT_RUN`
- M2=`NOT_RUN`

## 11. Evidence

Task-owned evidence root：

`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-M3A-ca1bcb9c89504e2ba4a5a347d16fc940\b7`

| artifact | Length | SHA-256 |
| --- | ---: | --- |
| `M3A-B7-GuestExecution.ps1` | 21638 | `8AF8F420E789031A59774FF0C2B30571742F482C62445A6ABBC84DDF52BFE296` |
| `b7-guest-result.json` | 8293 | `53B1DA4D8203133B1F74B237B836B075CB52FBEC0AA6E288AA5B42BD4AF0FC1A` |
| `b7-budget.json` | 171 | `6B0E1D90C41853C924692B8CE26FDC5CCD0624EAB4C0B1B5890A56583167F02F` |
| `b7-phase.txt` | 37 | `3E4E6F3A95DC380198A0C2A14320BF08EE848449BA739B211C5DB66E0227E303` |
| `b7-protected-pre.tsv` | 69592 | `9B25CCCA1AFC6CE940712B0AFE5024CA996FF563CD86A198875CC6FC5C9E49A0` |
| `b7-protected-post.tsv` | 69592 | `9B25CCCA1AFC6CE940712B0AFE5024CA996FF563CD86A198875CC6FC5C9E49A0` |
| `b7-recreation.stdout.txt` | 349 | `C0C3F6792C085BD2A7A3691D1D2F78C4AAC58B3D9917489588008A22804AD9EA` |
| `b7-recreation.stderr.txt` | 0 | `E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855` |

Recorder final phase=`STOPPED_ANDROID_GRADLE_NOT_GENERATED`；guest recorder exit=`25`。该 exit 是 bounded hard-stop code，不是 recreation process exit；recreation process exit=`0`。

## 12. Explicit NOT_RUN / NOT_CHECKED

- another Flutter-tools pub=`NOT_RUN`
- another module pub / separate Dart pub=`NOT_RUN`
- recreation retry or second recreation=`NOT_RUN`
- `--overwrite`=`NOT_USED`
- recreation with `--no-pub`=`NOT_RUN`
- manual `.android` repair=`NOT_RUN`
- manual template copy=`NOT_RUN`
- `gradlew init`=`NOT_RUN`
- separate Gradle dependency resolution=`NOT_RUN`
- network/package fill/download/install=`NOT_RUN`
- conditional direct-snapshot M3=`NOT_RUN`
- exact AAR probe=`NOT_CHECKED`
- alternate AAR path search=`NOT_RUN`
- M2=`NOT_RUN`
- product implementation=`NOT_RUN`
- host SDK/cache/source modification=`NOT_RUN`
- default `git status` / default index inspection=`NOT_RUN`
- self-accept / acceptance commit / `main` update=`NOT_RUN`
- `CURRENT_CONTEXT`=`NOT_MODIFIED`

本候选只记录 B7 的 first terminal blocker，等待 fresh 独立 ACCEPT/REJECT。执行者不自我接受、不更新 `main`、不执行 M2。
