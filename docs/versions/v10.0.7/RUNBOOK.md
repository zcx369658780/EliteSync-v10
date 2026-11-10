# v10.0.7 本地运行与复现

源码/包/数据身份先读[执行报告](EXECUTION_REPORT.md)、[manifest](manifest.json)、[测试原结果](TEST_RESULTS.md)。产品源码锚 `7f8da6954db8ef994f91e586c8a4f91fa0bc0a4f`；后续报告提交不改变构建源码。

## 保留现场

专用树：`C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`。E：`C:/Users/zcxve/.codex/visualizations/2026/10/14/01a13afa-b74f-7c11-b7e0-01a04335168d/v1007`。

结束时PHP/front、容器`elitesync-v1007-db`及AVD`elitesync_v1007_api36`停止；volume`elitesync-v1007-db-data`及E/secrets私配保留。私配和本地环境文件不得复制到GitHub、终端输出或命令行参数；不得触碰原3306或0.6的43316库/验收卷。原dirty根不作为运行树。

当前库有意保存终态：Bob3禁用、token0；Alice/Bob CN1 ACTIVE rev2，但两种MC REVOKED rev3；Charlie CN2 DECLINED、Dave CN3 WITHDRAWN；Status1 soft-deleted。重启后旧Bob登录或旧消息404/401/403是预期拒绝，不能为了“复现”直接改回ACTIVE/重seed。先看原正例截图/HTTP/DB时序；未来获准重演需具名新fixture，保留本次证据库。

## 获准继续本地回看时的最小启动

下列是复现说明，不是自动重启/后继版本授权。

1. 核对容器label `elitesync.version=v10.0.7`、volume挂载及仅127.0.0.1:43317，确认8000/8001空闲。正常`docker start elitesync-v1007-db`，不seed，不导入备份。本容器没有Docker Health字段，以PDO SELECT/实际业务JSON确认就绪，不能盲轮询不存在的Health。
2. 在专用树执行 `pwsh -NoProfile -File docs/versions/v10.0.7/start-local.ps1 -EvidenceDirectory <本次新的本地证据目录>`。脚本检查端口占用和容器label，启动PHP8001/front8000并保存owned-processes.json。不得覆盖旧runtime目录或杀端口占有者。
3. 使用已有Android SDK启动**具名**AVD `elitesync_v1007_api36`，端口5582；先确认 `adb -s emulator-5582 emu avd name`。执行 `adb -s emulator-5582 reverse tcp:8000 tcp:8000`。所有ADB带明确serial，不wipe别的AVD。
4. 安装E/packages-final/app-debug.apk，核manifest SHA。启动 `adb -s emulator-5582 shell am start -W -n com.elitesync/.MainActivity`，先观察真实空登录/页面；不用monkey后盲点。仅使用E/secrets中虚构账户。正常Alice可回看资料、MBTI及剩余匹配，Bob应被拒绝；生产URL/证书/全局明文配置不修改。
5. Matching consumer为backend目录 `C:/tools/php85/php.exe artisan app:matching:execute-pending --once`；只有明确准备的本版pending run才执行。媒体本版同步处理ready，消息采用HTTP定期拉取，不宣称WebSocket或RTC worker。已完成run不得强制重写，重复consumer应No pending。

APP导航：我的→Private Identity→兼容资料编辑；Readiness→兼容问卷；进展→匹配→连接与消息同意；消息→当前有权会话；我的→动态广场/可选MBTI/本地真实八字/站内通知/本地设置。首页/进展旧只读summary仍有未接通的readiness projection，明确UNKNOWN，不作为服务端授权；local匹配入口直接读取真实API。真实权限由服务端当前状态决定。

## 构建

复用锁定Flutter3.41.7/Dart3.11.5、JDK17、Gradle8.14/AGP8.11.1/Kotlin2.2.20、Android36/36.1。无需更新这些版本。专用既有Gradle home见manifest包构建收据及本地E；其中代理私配不打印。

`pwsh -NoProfile -File docs/versions/v10.0.7/build-local.ps1 -GradleHome <既有专用Gradle-home绝对路径>`

脚本在Android assembleDebug前从当前Flutter源生成release AAR，define `ELITESYNC_V1007_LOCAL_BUILD=true`；仅该包开启local恢复页面。正常默认包仍fail-closed。build07之后严格顺序安装并留hash，无源码变化的报告提交不重复全套构建。

APK源路径 `apps/android/app/build/outputs/apk/debug/app-debug.apk`；AAR源路径 `apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`。物理包副本在E/packages-final，未发布二进制。

## 测试与证据

`evidence/index.json`是已发布安全原证的逐文件SHA索引。未选原始流及工具脚本保留E/RAW_INDEX.json；secrets不列入公开index。原stdout/stderr/exit同时核验，runner的exit0不等于child成功。部分Windows JSON为CP936，原字节保持，用正确编码解码；测试stdout多为UTF8。

全量Flutter6失败、全范围analyze3 info仍存在；详见TEST_RESULTS，不因包构建通过称全套测试通过。可针对当前差异使用V1007*及鉴权/上传/问卷provider有效回归；SQLite不能替代APP/MariaDB正反例。

## 停止

读取**本次**owned-processes.json，并重新核验进程命令、实际listener PID和端口后停止自有PHP/front；不能只按旧PID杀进程。核对v10.0.7容器label后正常stop，**不删volume**；核对serial对应具名AVD后emu kill，不删除AVD数据。退出Blade管理会话，保留私配、原失败及物理包。不clean/reset/stash原dirty根、不清理无关LOCAL_ONLY/EVIDENCE，不自动合并main或启动0.8。
