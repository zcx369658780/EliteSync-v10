# EliteSync v10｜Post-R7 Android Reset + Recreation + Conditional Direct-Snapshot M3 Result v0.1

Status: `EXECUTED RESULT CANDIDATE — ANDROID RESET/RECREATION ESTABLISHED — M3 GRADLE DEPENDENCY RESOLUTION FAILED — EXACT AAR NON-HIT — NO M2`

## 1. Final classification

本任务唯一一次精确 `.android` 删除成功，唯一一次 supported offline module recreation 实际启动并退出 `0`。Protected non-generated pre/post manifests 在 record count、每个 relative path、Length、SHA-256、manifest Length、manifest SHA-256 和 bytes 上全部相等。Recreation 生成了 `.android/settings.gradle` 与 `.android/build.gradle`，Flutter-tools snapshot identity 保持不变。

全部前门通过后，唯一 direct-snapshot M3 实际启动并退出 `1`。最窄 observed failure 为 `:flutter_webrtc` classpath 所需 `org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0` 无法解析；Gradle 对 `dl.google.com` 与 `repo.maven.apache.org` 的请求均因主机名不可解析而失败。

Final classification：

`M3 DIRECT-SNAPSHOT FAILED — GRADLE_DEPENDENCY_RESOLUTION_NOT_ESTABLISHED`

M3 启动后的唯一 exact AAR probe=`NON-HIT`。没有搜索 alternate AAR path，没有重试 deletion、recreation 或 M3，没有联网补包，没有执行 M2。

成功结论 `M3 EXACT AAR ESTABLISHED — READY FOR FRESH M2 TARGETED HOST RESOLUTION REVIEW` 未达到。

## 2. Authority

- fresh-fetched GitHub `main`=`69fa44b0bd1608a4d30eb2a164dd7c571d1dda9c`，与 B9 固定 authority 精确一致。
- FIRST path=`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`。
- FIRST blob=`18485c95262051e43892436fb52413132c5ee626`，已首先完整读取并匹配。
- B9 task branch=`task/h01-bib03-u15-td01-m3-post-r7-android-reset-recreation-b9-v0-1`。
- B9 task commit=`7e287cf0d8095d5aad300c5b34b14c8965248726`。
- B9 task blob=`faf98837ccbb0f59fcbab59032ac459360610e10`。
- accepted B8 result blob=`f5abcad13b1cc04978900bfa8e56bbc3ee654524`，已读。
- accepted B7 result blob=`14445a7b4c0928c4ffb67943aa1ac9e8ebceb130`，仅用于 protected-manifest contract 与 prior generated-state observations，已读。
- accepted B6 result blob=`755b2073389fe0f908dfe110b7b40d416f470ac1`，仅用于五个 generated IDE metadata paths，已读。
- accepted B2 result blob=`071b8b5cab38c6dc9121d3e4bf36d469f0010849`，仅用于 package context 与 direct-snapshot M3 facts，已读。
- repository-wide、host-wide、alternate-module、whole-Flutter-SDK search=`NOT_RUN`。
- default index/protected staged-state inspection、default `git status`=`NOT_RUN`。

## 3. Preserved Sandbox gate

- WSB CLI=`0.8.107.0`。
- initial `wsb list --raw`：running count=`1`；唯一 ID=`0087a898-5221-41df-a33d-65045ffea69a`；PASS。
- final `wsb list --raw`：running count=`1`；仍为同一 ID；PASS。
- Sandbox create/stop/close/reset/kill=`NOT_RUN`。
- 新建 task-owned host evidence root=`D:\EliteSync-v10-B9-evidence-20260910-01`，位于 repository、module 与 SDK/cache roots 之外。
- guest evidence share=`C:\M3B9Evidence_20260910_01`；没有复用旧 B2/B7 guest evidence state。

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

Manifest 覆盖 module 内除 accepted generated/disposable allowlist 与 `build/**` 外的每个文件。只读取 bytes、Length 与 SHA-256，不解释 product contents。

Serialization：

`relative_path<TAB>Length<TAB>SHA256`

- path normalization=`/`
- ordering=`ordinal`
- encoding=`UTF-8 no BOM`
- line ending=`LF`
- nonempty manifest final LF=`present`
- record count=`526`
- manifest Length=`69592`
- manifest SHA-256=`9B25CCCA1AFC6CE940712B0AFE5024CA996FF563CD86A198875CC6FC5C9E49A0`

## 6. Exact pre-reset state and deletion

Pre-reset exact observations：

| path | pre state |
| --- | --- |
| `.android` | exists / directory |
| `.android/settings.gradle` | absent |
| `.android/settings.gradle.kts` | absent |
| `.android/build.gradle` | absent |
| `.android/build.gradle.kts` | absent |
| `.ios` | present |
| `.dart_tool` | present |
| `.flutter-plugins-dependencies` | present |
| `pubspec.lock` | present |
| `.idea/libraries/Dart_SDK.xml` | present |
| `.idea/modules.xml` | present |
| `.idea/workspace.xml` | present |
| `flutter_elitesync_module_android.iml` | present |
| `flutter_elitesync_module.iml` | present |

唯一 deletion：

- exact literal target=`C:\M3A\work\apps\flutter_elitesync_module\.android`
- equivalent invocation=`Remove-Item -LiteralPath 'C:\M3A\work\apps\flutter_elitesync_module\.android' -Recurse -Force`
- deletion count=`1`
- attempted=`true`
- post-delete root exists=`false`
- result=`PASS`
- retry=`NOT_RUN`

没有删除或修改 `.ios`、`.dart_tool`、IDE metadata、lockfile、product file、SDK/cache root 或 host source。

## 7. Exact recreation invocation and result

- invocation count=`1`
- process started=`true`
- executable=`C:\M3A\tools\flutter\bin\cache\dart-sdk\bin\dart.exe`
- complete args=`--packages="C:\M3A\tools\flutter\packages\flutter_tools\.dart_tool\package_config.json" "C:\M3A\tools\flutter\bin\cache\flutter_tools.snapshot" --no-version-check create --template=module --offline .`
- cwd=`C:\M3A\work\apps\flutter_elitesync_module`
- start UTC=`2026-09-10T10:28:57.1870497Z`
- end UTC=`2026-09-10T10:29:00.1826348Z`
- duration=`2995.585 ms`
- exit=`0`
- stdout Length=`156`; SHA-256=`6DF1123A04F7D74245824FF7D24958A5061E009C4AC78292B2D67015FFF5A8F8`
- stderr Length=`0`; SHA-256=`E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855`
- genuine URL/socket/DNS/connection failure diagnostic=`NONE OBSERVED`
- retry=`NOT_RUN`

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
Resolving dependencies...
Downloading packages...
Got dependencies.
Wrote 0 files.

All done!
Your module code is in lib\main.dart.
```

`Downloading packages...` 是 `--offline` pub 的状态行；没有 genuine network failure evidence，也没有联网补包。

## 8. Protected post-state comparison

Post manifest 使用与 pre 完全相同的 set、serialization、ordering、encoding 与 exclusions：

- record count=`526`
- manifest Length=`69592`
- manifest SHA-256=`9B25CCCA1AFC6CE940712B0AFE5024CA996FF563CD86A198875CC6FC5C9E49A0`
- pre/post byte-for-byte equality=`true`
- every relative path / Length / SHA-256 equality=`PASS`
- protected path appeared/disappeared/changed=`NONE`

因此 `B9_PROTECTED_NON_GENERATED_STATE_CHANGED` 未触发。

## 9. Generated-state and Android Gradle gate

| path | post state |
| --- | --- |
| `.android/settings.gradle` | present |
| `.android/settings.gradle.kts` | absent |
| `.android/build.gradle` | present |
| `.android/build.gradle.kts` | absent |
| `.ios` | present |
| `.dart_tool` | present |
| `.flutter-plugins-dependencies` | present |
| `pubspec.lock` | present |
| `.idea/libraries/Dart_SDK.xml` | present |
| `.idea/modules.xml` | present |
| `.idea/workspace.xml` | present |
| `flutter_elitesync_module_android.iml` | present |
| `flutter_elitesync_module.iml` | present |

Android Gradle sentinel gate=`PASS`。Flutter-tools snapshot post-recreation SHA-256=`E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`，与固定 identity 精确相等；snapshot regenerate/rebuild=`NOT_RUN`。

## 10. Unique direct-snapshot M3

- invocation count=`1`
- process started=`true`
- executable=`C:\M3A\tools\flutter\bin\cache\dart-sdk\bin\dart.exe`
- complete args=`--packages="C:\M3A\tools\flutter\packages\flutter_tools\.dart_tool\package_config.json" "C:\M3A\tools\flutter\bin\cache\flutter_tools.snapshot" --no-version-check build aar --no-debug --no-profile --no-pub`
- cwd=`C:\M3A\work\apps\flutter_elitesync_module`
- environment roots与 recreation 相同
- start UTC=`2026-09-10T10:29:00.9472028Z`
- end UTC=`2026-09-10T10:30:14.0520121Z`
- duration=`73104.809 ms`
- exit=`1`
- stdout Length=`74`; SHA-256=`C3DFB9E3927026744FA0BE211308B8A6E7DF5EB9EF82FA963E7C43A1BBF35FA6`
- stderr Length=`1664`; SHA-256=`B529FB7A570D3F582106AA0526B1E7737261CE8A36DEC06D46CAABD48C81FE3E`
- retry=`NOT_RUN`

Observed stdout：

```text
Running Gradle task 'assembleAarRelease'...                        72.8s
```

Observed narrow failure：

```text
A problem occurred configuring project ':flutter_webrtc'.
> Could not resolve all artifacts for configuration 'classpath'.
  > Could not resolve org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0.
```

Gradle 随后记录两个 exact resource resolution failures：

- `https://dl.google.com/dl/android/maven2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.1.0/kotlin-gradle-plugin-2.1.0.pom`
- `https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.1.0/kotlin-gradle-plugin-2.1.0.pom`

两者均以“不知道这样的主机”失败。随后 `BUILD FAILED in 1m 12s`，`Gradle task assembleAarRelease failed with exit code 1.`。这证明本次 isolated M3 的 Gradle dependency resolution 未建立；不授权网络、补包、重试或单独 Gradle resolution。

Flutter-tools snapshot final SHA-256=`E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`，保持不变。

## 11. Exact AAR probe

- probe count=`1`，且只在 M3 process 实际启动后执行。
- exact path=`C:\M3A\work\apps\flutter_elitesync_module\build\host\outputs\repo\com\elitesync\flutter_elitesync_module\flutter_release\1.0\flutter_release-1.0.aar`
- result=`NON-HIT`
- Length/SHA-256=`NOT_APPLICABLE`
- alternate-path search=`NOT_RUN`

该 NON-HIT 只绑定上述 exact path 和本次唯一 M3，不证明 AAR 全局不存在。

## 12. Evidence

Task-owned evidence root：

`D:\EliteSync-v10-B9-evidence-20260910-01`

| artifact | Length | SHA-256 |
| --- | ---: | --- |
| `M3A-B9-GuestExecution.ps1` | 17449 | `DE8D8AAE0A6D03699494FBF1B0AFE31EAA5A2B6DD6344E8921449E96EB6071C3` |
| `b9-guest-result.json` | 6769 | `75A4EEFE6B9558BFB7C0E5C98AA18337C251D236773338A8390F68EDA39E9A7F` |
| `b9-protected-pre.tsv` | 69592 | `9B25CCCA1AFC6CE940712B0AFE5024CA996FF563CD86A198875CC6FC5C9E49A0` |
| `b9-protected-post.tsv` | 69592 | `9B25CCCA1AFC6CE940712B0AFE5024CA996FF563CD86A198875CC6FC5C9E49A0` |
| `b9-recreation.stdout.txt` | 156 | `6DF1123A04F7D74245824FF7D24958A5061E009C4AC78292B2D67015FFF5A8F8` |
| `b9-recreation.stderr.txt` | 0 | `E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855` |
| `b9-m3.stdout.txt` | 74 | `C3DFB9E3927026744FA0BE211308B8A6E7DF5EB9EF82FA963E7C43A1BBF35FA6` |
| `b9-m3.stderr.txt` | 1664 | `B529FB7A570D3F582106AA0526B1E7737261CE8A36DEC06D46CAABD48C81FE3E` |

## 13. Explicit NOT_RUN / NOT_CHECKED

- additional Flutter-tools pub=`NOT_RUN`
- additional module pub outside recreation built-in offline pub=`NOT_RUN`
- `.android` deletion retry / second deletion=`NOT_RUN`
- recreation retry / second recreation=`NOT_RUN`
- `--overwrite`=`NOT_USED`
- recreation with `--no-pub`=`NOT_RUN`
- any `--platforms` option=`NOT_USED`
- manual `.android` repair=`NOT_RUN`
- manual template copy=`NOT_RUN`
- `gradlew init`=`NOT_RUN`
- separate Gradle dependency resolution=`NOT_RUN`
- network/package fill/download/install=`NOT_RUN`
- M3 retry / second M3=`NOT_RUN`
- alternate AAR path search=`NOT_RUN`
- M2=`NOT_RUN`
- product implementation=`NOT_RUN`
- host SDK/cache/source modification=`NOT_RUN`
- Sandbox create/stop/close/reset/kill=`NOT_RUN`
- default `git status` / default index/protected staged-state inspection=`NOT_RUN`
- self-accept / acceptance commit / `main` update=`NOT_RUN`
- `CURRENT_CONTEXT`=`NOT_MODIFIED`

本候选只记录 B9 的唯一 bounded execution 与 first terminal blocker，等待 fresh 独立 ACCEPT/REJECT。执行者不自我接受、不更新 `main`、不执行 M2。
