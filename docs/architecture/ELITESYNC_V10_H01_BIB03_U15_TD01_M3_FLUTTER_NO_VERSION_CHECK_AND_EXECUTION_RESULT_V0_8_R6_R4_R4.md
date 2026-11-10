# EliteSync v10｜Flutter `--no-version-check` 离线续行与条件式 M3 结果 v0.8-R6-R4-R4

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — OFFLINE_PUB_NETWORK_ATTEMPT_PERSISTS_AFTER_NO_VERSION_CHECK — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`
日期：2026-09-09（Asia/Shanghai）。

## 1. 结论

远端authority、controller静态门、fresh Owner Sandbox句柄、RemoteSigned/Security/禁网、固定路径和最小PowerShell解析门全部通过。唯一`flutter.bat --no-version-check pub get --offline`实际启动并exit=69。

R3的`git fetch --tags`与`github.com`诊断本轮未再出现；首个真实诊断变为：`Got socket error trying to find package code_builder at https://pub.dev.`。依任务固定分类：

`M3 PRECONDITION BLOCKED — OFFLINE_PUB_NETWORK_ATTEMPT_PERSISTS_AFTER_NO_VERSION_CHECK`

该证据仅证明关闭Flutter版本检查后，pub仍尝试访问pub.dev并被guest隔离阻断；它没有明确证明本地cache缺少`code_builder`的具体版本，不分类为exact cache miss，不授权联网或补包。M3=`NOT_RUN`，AAR=`NOT_CHECKED`、probe=0，M2=`NOT_RUN`。

## 2. 远端authority与固定输入

- main=`9a415997405314fc6e047f47f238cfd6f8de1ef4`；FIRST blob=`18485c95262051e43892436fb52413132c5ee626`并先读取。
- task commit=`42e58ac4dfd5aab0a9b6851dc788e187b27ba5a9`，blob=`6a8adfd5b89cea94c3e1fd08bfe2a7d733aa29b6`；sole parent为main，ahead=1、behind=0且只新增固定task文件。
- main中R6-R4-R3 result blob=`3a856692e3a2eeb7c7068c28debef20f0c88b319`，CURRENT_CONTEXT blob=`2c0e9353b7ccfde07c0787247a113805a3f9a440`。
- 本机task ref/object不作为门；未读取default index/working tree，未运行`git status`。

B=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r4/r6r4r4-no-version-check`，E=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r6-r4-r4`；开始时均不存在，旧证据保持只读。

## 3. Controller、Sandbox与最小preflight

controller通过Windows PowerShell 5.1 parser/static gate，纠正0/1，Length=9555，SHA-256=`73F93D84F1450C4353FB91EFB8721402C95D5DC150F17A36EAEEB2384BA82084`。nonce=`M3-ISO-V02-008-R6R4R4-9d435a22ea97477f897715cac76f149b`。

WSB CLI=`0.8.107.0`；initial list唯一running Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`。controller run-as System，CLI exit=0、guest ExitCode=41、guest PID=8968。

Process/effective policy均RemoteSigned；Security module=`Microsoft.PowerShell.Security`，系统Path=`C:/Windows/system32/WindowsPowerShell/v1.0/Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1`；活动网卡=0，默认路由=0。

module cwd、pubspec、Flutter、Android、JDK、Git、Pub、Gradle home及系统PowerShell精确路径全部存在。未重跑helper fixture、SRC/B3 current-view、observable、module copy/current-view、ordinary/batch smoke、Git、Java或R3完整PowerShell四门；未新share或新建Sandbox。

## 4. 临时PATH与最小门

原始PATH：

`C:/Windows/system32;C:/Windows;C:/Windows/System32/Wbem;C:/Windows/System32/WindowsPowerShell/v1.0/;C:/Windows/system32/config/systemprofile/AppData/Local/Microsoft/WindowsApps`

仅在controller/子进程前置：系统PowerShell、System32、R4 Flutter、Git、JDK目录，再追加原PATH。唯一最小门`Get-Command powershell.exe`精确解析到`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`，PASS。没有重跑where/cmd-where/child-powershell。

JAVA_HOME、ANDROID_HOME、ANDROID_SDK_ROOT、PUB_CACHE和GRADLE_USER_HOME仅在controller/子进程设置为固定R4路径；HOME/USERPROFILE=`C:/M3R6R4R4/home`，TEMP/TMP=`C:/M3R6R4R4/tmp`。未修改持久环境。

## 5. 唯一pub、M3与AAR

收到args=`[--no-version-check,pub,get,--offline]`；actual executable=`C:/Windows/System32/cmd.exe`；最终Arguments=`/d /s /v:off /c ""C:\M3R4\t\f\bin\flutter.bat" "--no-version-check" "pub" "get" "--offline""`；cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`。

process_started=true，start UTC=`2026-09-09T12:41:39.6269164Z`，end UTC=`2026-09-09T12:46:15.4115371Z`，duration=275785ms，timed_out=false，exit=69。stdout为空；stderr为：

```text
Got socket error trying to find package code_builder at https://pub.dev.

Failed to update packages.
```

诊断、stdout/stderr、exit和timing先完整落盘，controller随后正常exit 41。pub=1/1，未联网补包、未重试。因为pub非零，M3未启动，精确AAR未检查、probe=0。

## 6. Evidence与Owner Sandbox

B完整复制至E。payload manifest格式=`relative_path<TAB>length<TAB>SHA256`，size=1456、SHA-256=`EB4AA94553203DE33D7433DC7D0A36E79A674EA76E5DD093F494533F7D7ABDAC`。最终B/E均17 files、2 dirs、18557 bytes，current-view TSV size=1654、SHA-256均=`B8068CD8864FF3C14FFF3B332833522A6A8E164C32C963F735596F9D39D1998E`，一致。

final `wsb list --raw`仍只有Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`。未stop/close/reset/kill，Owner Sandbox继续由Owner控制。未执行M2，未修改AGENTS或ChatGPT项目源。

本候选仅等待fresh独立ACCEPT/REJECT；执行者不自我接受、不更新main、不启动后续任务。