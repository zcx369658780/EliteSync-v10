# EliteSync v10｜Direct `flutter_tools.snapshot` 条件式 M3 与精确 AAR 结果 v0.8-R6-R4-R6

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — DIRECT_FLUTTER_TOOLS_SNAPSHOT_NETWORK_ATTEMPT — AAR EXACT NON-HIT — NO M2`
日期：2026-09-09（Asia/Shanghai）。

## 1. 结论

远端authority、controller静态门、fresh Owner Sandbox/隔离、固定路径、最小PowerShell门、Dart identity、snapshot及Flutter-tools package_config身份绑定全部通过。

唯一M3通过Flutter SDK内置Dart直接加载既有`flutter_tools.snapshot`，没有调用`flutter.bat`或其他Flutter wrapper，但仍尝试从`https://pub.dev`查找`coverage`，exit=69。唯一精确AAR probe=1、NON-HIT。

最终分类：`M3 PRECONDITION BLOCKED — DIRECT_FLUTTER_TOOLS_SNAPSHOT_NETWORK_ATTEMPT`。

该结果证明网络尝试并非仅来自`flutter.bat/shared.bat` bootstrap；direct snapshot命令路径本身仍触发pub.dev访问。不得据此开放网络、修改SDK、补包、重试或执行M2。

## 2. Authority与范围

- main=`35667044e94c51f3f100d03a8da81cb83202691f`；FIRST blob=`18485c95262051e43892436fb52413132c5ee626`并先读取。
- task=`698bfd8fbe7b4cd01963f3886eed30792ba4bee0`，blob=`fa26ae075bf5adbde77236201620086816dca6db`；sole parent为main，ahead=1、behind=0且只新增固定task。
- main中R6-R4-R5 result blob=`2450f706cd1ac7602f632f1e85b4019d6a9963ef`；CURRENT_CONTEXT blob=`3e4f0591a3f84fd166b68eb6f27dce7d709ee6d8`。
- 附件6572 bytes，SHA-256=`EF7C1591CCCB102F5D654B1ED2872B4299F9464D06DE3FF4BBF5DB9211C27553`。

B=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r4/r6r4r6-direct-snapshot`，E=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r6-r4-r6`；起始均不存在。旧证据只读，未访问default index/working tree或受保护staged state。

## 3. Controller、Sandbox与身份

controller parser/static PASS，纠正0/1，Length=9163，SHA-256=`913753BF9292C531FD4C602FBF11E9B153822B85EDE95398500C2746A8EDC739`。nonce=`M3-ISO-V02-008-R6R4R6-d67603ab33984e07bb44e425537e1933`。

WSB CLI=`0.8.107.0`；唯一Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`。controller run-as System，CLI exit=0、guest ExitCode=0、PID=2864。Process/effective RemoteSigned、Security系统Path、活动网卡0、默认路由0全部PASS；全部固定路径存在。最小`Get-Command powershell.exe`精确命中系统PowerShell。

Dart exact executable=`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`，版本=`Dart SDK 3.11.5 stable windows_x64`，版本命令exit=0。

snapshot=`C:/M3R4/t/f/bin/cache/flutter_tools.snapshot`，Length=43747920，SHA-256=`E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`。

Flutter-tools package_config=`C:/M3R4/t/f/packages/flutter_tools/.dart_tool/package_config.json`，Length=21503，SHA-256=`354D6C66AB147E9DD5C65ADD67A34252739723FBF9084A6541F099CC0D584BB7`。

未执行flutter.bat、doctor、precache、update-packages、pub、upgrade或version check；未生成新snapshot，未重跑已接受链。

## 4. 唯一direct-snapshot M3与AAR

executable received=`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`；Dart identity已由同一exact executable确认。M3进程退出过快，`actual_executable`捕获为null，保持null而不推断。

args顺序：`--packages=C:/M3R4/t/f/packages/flutter_tools/.dart_tool/package_config.json C:/M3R4/t/f/bin/cache/flutter_tools.snapshot --no-version-check build aar --no-debug --no-profile --no-pub`。

cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`；defines=EMPTY。process_started=true，start=`2026-09-09T13:56:18.4346252Z`，end=`2026-09-09T14:00:54.5933595Z`，duration=276159ms，timed_out=false，exit=69，stdout空。首个stderr诊断：

```text
Got socket error trying to find package coverage at https://pub.dev.

Failed to update packages.
```

因此分类`DIRECT_FLUTTER_TOOLS_SNAPSHOT_NETWORK_ATTEMPT`。未联网、补包或重试。

M3已启动，所以执行唯一AAR probe：`C:/M3R6R4R2/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`。结果NON-HIT，probe=1，size/hash=null；未搜索替代路径。

## 5. Evidence与Sandbox

B完整复制至E。payload manifest size=1746、SHA-256=`F02232F8161BB14B5530DBD6A35DB986664FECA9EF3DF8B67FBA1070068C9702`。最终B/E均20 files、2 dirs、20507 bytes，current-view TSV size=1944、SHA-256均=`03B9515032DED27FC737437663BBB501D7E3800A138DDC759AB9B0DB5953790B`，一致。

final list仍仅有Owner Sandbox `68ece109-c661-420c-9899-02b1e9518036`。未新share/Sandbox，未stop/close/reset/kill；Owner Sandbox继续由Owner控制。未修改Flutter SDK、cache、原仓库或持久环境；未执行M2。

本候选仅等待fresh独立ACCEPT/REJECT；执行者不自我接受、不更新main、不启动后续任务。