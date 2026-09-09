# EliteSync v10｜Guest PowerShell PATH 修复、Offline Pub 续行与条件式 M3 结果 v0.8-R6-R4-R3

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — OFFLINE_PUB_FLUTTER_TOOL_NETWORK_ATTEMPT_BLOCKED — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`
日期：2026-09-09（Asia/Shanghai）。

## 1. 结论

远端authority、controller parser/static gate、fresh Owner Sandbox句柄、guest RemoteSigned/Security/禁网、固定cwd/tools存在性及PowerShell PATH四门全部通过。系统PowerShell只在本任务controller及子进程PATH中临时前置，未修改Machine/User PATH、注册表、组策略、profile或持久环境变量。

唯一新的`flutter pub get --offline`实际启动，276980ms后exit=69。首个诊断为Flutter工具执行`fetch --tags`时访问`https://github.com/flutter/flutter.git/`，在活动网卡0、默认路由0的guest中因`Could not resolve host: github.com`失败；随后报告无法取得`https://pub.dev`的package collection。未联网补包、未重试。

最终分类：`M3 PRECONDITION BLOCKED — OFFLINE_PUB_FLUTTER_TOOL_NETWORK_ATTEMPT_BLOCKED`。

这证明本次offline pub入口仍发生网络访问尝试并被隔离阻断；不证明应开放网络，也不把失败泛化为cache不足。M3=`NOT_RUN`，AAR=`NOT_CHECKED`、probe=0，M2=`NOT_RUN`。

## 2. GitHub远端authority

- main=`93a5466b57a99dcc10a369cd005bbe7953ce38a4`；FIRST blob=`18485c95262051e43892436fb52413132c5ee626`并先读取。
- task commit=`0724df842d1e85fd405daa16e94550e63d9d5040`，blob=`a70359494cf72bc7da29fcd95ac8ace91f206cae`；sole parent精确为main，ahead=1、behind=0且只新增固定task文件。
- main中R6-R4-R2 result blob=`03720d5499fca33f837abedd79871c740a0906bf`，CURRENT_CONTEXT blob=`10595ef7ae958da0324b60b4650933067ac2e065`。
- 附件6904 bytes，SHA-256=`6D2F6399E2885E62945040192DD28FB98E9C49365DC3FD7C3D9F89829F2355ED`。

未读取default index/working tree，未运行`git status`。

## 3. Controller、Sandbox与fresh preflight

B=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r4/r6r4r3-continuation`，E=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r6-r4-r3`；开始时均不存在。旧证据只读。

controller通过Windows PowerShell 5.1 parser/static gate；使用允许的1/1次定点纠正消除静态门字符串误报，最终Length=12495、SHA-256=`E9887CCDBE32094B5C048833DEDB877F02648093DD66A7D0438EBA84C5C91C7F`，禁止`throw'`/`throw"`及裸布尔代码均0。nonce=`M3-ISO-V02-008-R6R4R3-8b57aa248bef4e2d9de732e2bbb94487`。

WSB CLI=`0.8.107.0`；initial list唯一running ID=`68ece109-c661-420c-9899-02b1e9518036`。首次`wsb exec`因本机不接受`-i`与分离命令参数，在CLI解析阶段exit=1；guest未启动，pub/M3预算未消耗。随后依照该公开错误给出的`--id`、`--command`语法，以同一ID、run-as System执行实际controller，CLI exit=0、guest ExitCode=51。

controller PID=2920，进程路径=`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`；Process/effective均RemoteSigned。Security module=`Microsoft.PowerShell.Security`，Path=`C:/Windows/system32/WindowsPowerShell/v1.0/Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1`。活动网卡0、默认路由0。module cwd/`pubspec.yaml`、Flutter、Android、JDK、Git、Pub及Gradle两项固定路径均存在。

未重跑helper、host/guest current-view、observable、module copy、ordinary/batch、Git或Java；未新share或新建Sandbox。

## 4. 系统PowerShell与进程级PATH门

exact path=`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`；FileVersion=`10.0.26100.8875 (WinBuild.160101.0800)`，Length=454656，SHA-256=`7600FFE12DA441FE89D035B13801E8E91D064BC544A27B19A5CF49F6AB8B18F5`。

原始PATH=`C:/Windows/system32;C:/Windows;C:/Windows/System32/Wbem;C:/Windows/System32/WindowsPowerShell/v1.0/;C:/Windows/system32/config/systemprofile/AppData/Local/Microsoft/WindowsApps`。

临时PATH按序前置`C:/Windows/System32/WindowsPowerShell/v1.0`、`C:/Windows/System32`、`C:/M3R4/t/f/bin`、`C:/M3R4/t/g/cmd`、`C:/M3R4/t/j/bin`，再追加原始PATH。

`Get-Command powershell.exe`精确命中系统路径；`where.exe powershell.exe` exit0；`cmd.exe /d /s /c "where powershell.exe"` exit0；PATH名子PowerShell exit0，四门PASS。随后仅在controller/子进程设置固定JAVA_HOME、Android、Pub、Gradle及task-owned HOME/USERPROFILE/TEMP/TMP。

## 5. 唯一offline pub、M3与AAR

args=`pub get --offline`；actual executable=`C:/Windows/System32/cmd.exe`；最终Arguments=`/d /s /c ""C:\M3R4\t\f\bin\flutter.bat" pub get --offline"`；cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`。process_started=true，start=`2026-09-09T12:03:12.4308364Z`，end=`2026-09-09T12:07:49.4110156Z`，timed_out=false，exit=69。

stderr首个诊断：

```text
Command exited with code 128: fetch --tags
Standard error: fatal: unable to access 'https://github.com/flutter/flutter.git/': Could not resolve host: github.com

Got socket error trying to find package collection at https://pub.dev.

Failed to update packages.
```

classification/stdout/stderr/exit/timing先完整落盘，随后controller正常exit 51；没有后续异常遮蔽。pub=1/1；M3未启动，AAR未检查、probe=0；没有下载、联网补包或重试。

## 6. Evidence与Owner Sandbox

B完整复制到E。payload manifest size=1687、SHA-256=`B70DEA984734B2E3F04FAFCB19A90766F1BB3DD422FDC698011FECBC7DED0EF1`。最终B/E均19 files、2 dirs、101639 bytes，current-view TSV size=1885、SHA-256均=`581ABD94387E9C110FFCA3DC23A722EECFD04EAAE72F62458C67C4D7D9C2D2AE`。

final list仍仅有Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`。未stop/close/reset/kill；Owner Sandbox继续由Owner控制。未执行M2，未修改AGENTS或ChatGPT项目源。

本候选只等待fresh独立ACCEPT/REJECT；执行者不自我接受、不更新main、不启动后续任务。