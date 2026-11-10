# EliteSync v10｜Direct Dart Offline 诊断、条件式 M3 与精确 AAR 结果 v0.8-R6-R4-R5

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — M3_NO_PUB_NETWORK_ATTEMPT — AAR EXACT NON-HIT — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`
日期：2026-09-09（Asia/Shanghai）。

## 1. 结论

远端authority、controller静态门、fresh Owner Sandbox/隔离、固定路径、最小PowerShell门、Dart exact executable及direct Dart offline pub全部通过。`dart.exe pub get --offline`仅运行约2.044秒并exit=0。

随后唯一M3实际启动：`flutter.bat --no-version-check build aar --no-debug --no-profile --no-pub`。尽管带`--no-pub`，Flutter仍尝试从`https://pub.dev`查找`coverage`，约276.089秒后exit=69。唯一精确AAR路径NON-HIT。

最终分类：`M3 PRECONDITION BLOCKED — M3_NO_PUB_NETWORK_ATTEMPT`。

该结果证明direct Dart offline依赖解析可在既有cache完成，但不证明Flutter M3入口完全遵守`--no-pub`或已具备离线构建闭包；不授权联网、补包、重试或M2。

## 2. Authority与固定边界

- main=`fd447ca5cf3c8e7407a3a65bee144b6257a317c5`；FIRST blob=`18485c95262051e43892436fb52413132c5ee626`并先读取。
- task=`a1441caaa81134f53aaea00ae256e86fbd61b110`，blob=`874ce5ddc87989e1f073fd5bbb3bfc4051d7cba2`；sole parent为main，ahead=1、behind=0且只新增固定task文件。
- main中R6-R4-R4 result blob=`f2d1024e316e096385bf1645af74788bd1554ce4`，CURRENT_CONTEXT blob=`e611420974d5bbcab20de9b0c4aaa59226133ba1`。
- 附件6914 bytes，SHA-256=`7F8B1D99CE426C5232F4085B64E3ACDA97554255152EC34C184DE06A35CA7803`。

B=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r4/r6r4r5-direct-dart`，E=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r6-r4-r5`；起始均不存在。旧证据只读；未访问default index/working tree。

## 3. Controller、Sandbox与preflight

controller Windows PowerShell 5.1 parser/static PASS，纠正0/1，Length=10831、SHA-256=`1B2A9630A8F446C1DEE68AABC995E5E042FDF38DA7B89F743FEE438A5AD8449B`。nonce=`M3-ISO-V02-008-R6R4R5-6fbdb40ea74043a998f9b2a21605a3d3`。

WSB CLI=`0.8.107.0`；唯一Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`。controller run-as System，CLI exit=0、guest ExitCode=0、PID=8180。

Process/effective RemoteSigned、Security系统Path、活动网卡0、默认路由0全部PASS。module cwd、pubspec、Flutter、Dart、Android、JDK、Git、Pub、Gradle及PowerShell精确路径全部存在。最小`Get-Command powershell.exe`精确命中系统PowerShell；临时PATH和task环境仅作用于controller/子进程。

未重跑helper、current-view、observable、module copy、smoke、Git、Java、R3 PowerShell四门或Flutter pub；未新share或Sandbox。

## 4. code_builder有界诊断与Dart版本

pub前`pubspec.lock`存在；固定`Select-String '^  code_builder:$' -Context 0,8`未命中，因此lock version/source保持null，不输出其他package。

对`C:/M3R4/p/hosted/pub.dev`唯一有界过滤只返回`code_builder-4.11.1`。这仅证明该匹配目录存在，不证明依赖图完整。

Dart exact path=`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`；`--version` exit=0：`Dart SDK version: 3.11.5 (stable) (Wed Apr 15 00:36:32 2026 -0700) on "windows_x64"`。

## 5. Direct Dart pub、M3与AAR

Direct Dart：executable=`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`，args=`pub get --offline`，cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`。process_started=true，start=`2026-09-09T13:16:02.0932859Z`，end=`2026-09-09T13:16:04.1370435Z`，duration=2044ms，timed_out=false，exit=0，stderr空。stdout含`Resolving dependencies...`、`Downloading packages...`、`Got dependencies!`及12项较新版本提示；在`--offline`语义下没有观察到URL/socket/DNS诊断。正常pub生成物仅写task-owned module copy。

M3：actual executable=`C:/Windows/System32/cmd.exe`；最终Arguments=`/d /s /v:off /c ""C:\M3R4\t\f\bin\flutter.bat" "--no-version-check" "build" "aar" "--no-debug" "--no-profile" "--no-pub""`；同一cwd。process_started=true，start=`2026-09-09T13:16:04.1637496Z`，end=`2026-09-09T13:20:40.2530390Z`，duration=276089ms，timed_out=false，exit=69。stdout空；首个stderr诊断：

```text
Got socket error trying to find package coverage at https://pub.dev.

Failed to update packages.
```

M3=FAILED。精确AAR=`C:/M3R6R4R2/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`；probe=1、NON-HIT，size/hash=null。未搜索替代路径，未重试。

## 6. Evidence与Owner Sandbox

B完整复制至E。payload manifest size=2034、SHA-256=`52D5508B1BA9C2FC18A14647FF52556300089E25D2554695AFFD41130A9E40B9`。最终B/E均23 files、2 dirs、23609 bytes，current-view TSV size=2232、SHA-256均=`0AA32F007F9F9104BC6976328291EA087F09D6066FF2327FE621A4EAEED185BD`，一致。

final list仍仅有Owner Sandbox `68ece109-c661-420c-9899-02b1e9518036`。未stop/close/reset/kill；Owner Sandbox继续由Owner控制。未执行M2，未修改AGENTS或ChatGPT项目源。

本候选仅等待fresh独立ACCEPT/REJECT；执行者不自我接受、不更新main、不启动后续任务。