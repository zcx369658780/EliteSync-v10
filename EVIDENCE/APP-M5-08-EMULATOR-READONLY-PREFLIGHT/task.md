# APP-M5-08｜已启动模拟器只读预检

ISSUED；LEVEL 2（设备/环境边界）。Assignee：Codex 01a0ef77-af94-75e2-8726-87c04e082018，GPT-6.1 Sol/medium。唯一仓库D:\EliteSync-v10；main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。先核对根authority、local-workflow、runtime-slice与M5-07 work-review，保留所有dirty/untracked。Owner已启动Android Studio模拟器并允许后续调试使用；本任务仅只读预检。

允许读取：上述authority、本task；固定adb.exe存在/哈希；命令所列模拟器属性及三个精确包的安装路径元数据。唯一新交付本目录summary.md。不得修改源码、authority、配置或其他证据。不要访问旧D:\EliteSync、真实备份/密钥/DB/SSH/API或用户应用文件。

固定工具 C:\Users\zcxve\AppData\Local\Android\Sdk\platform-tools\adb.exe。不搜索替代工具。命令必须显式-H localhost -P 5037，局限本机ADB server，不沿用未知远端ADB端点。工具缺失/哈希失败则停。禁止tcpip/connect/disconnect、kill-server、物理设备操作或重启设备。devices可能启动本机普通权限ADB服务；若要求UAC则停，不触发提升。

新预算：adb devices一次（非-l，避免不必要物理设备详情），20秒硬时限；只保留emulator-*的状态，物理项只报告忽略数量。只有唯一emulator-*且state=device才继续；多个、离线、无设备或输出异常即停，不猜目标、不重新枚举。

以该serial绑定后，每命令一次、20秒硬时限，顺序执行，失败/超时/截断即停：
1. shell getprop ro.kernel.qemu，必须精确1，否则停。
2. shell getprop ro.build.version.sdk，必须单个十进制整数，否则停。
3. shell pm path com.elitesync.syntheticdemo。
4. shell pm path com.elitesync。
5. shell pm path com.elitesync.flutter_elitesync_module.host。

最后三项仅查精确包占用，不枚举全包、不读取APK/应用数据。空stdout且退出0记NOT_INSTALLED；一个或多个package:路径行记INSTALLED，但summary只记状态和路径条数，不记路径。其它输出/非0记UNKNOWN并停。com.elitesync.syntheticdemo仅为拟议独立调试包的占用查询，尚未接受为产物身份；其它两个是当前源码中的准确包ID。包未装不证明未来安装/启动安全。

每路stdout/stderr上限16KiB，并行排空捕获；硬超时终止该本地子进程，预算消耗，不重跑。只记录模拟器serial、qemu/API、包状态、退出码、时间/超时/截断及adb哈希；不保留物理serial或用户文件。禁止install/uninstall/clear/launch/am start、截图、logcat、pull/push/reverse/forward、Gradle/Flutter构建、真实网络/数据操作。每次命令独立预算，旧预算不重置。

交付summary并停Work独立LEVEL 2 ACCEPT/REJECT；作者不得自接受/创建后继/提交Git。设备身份预检不建立APK、host/AAR/入口/数据隔离或真实账号证明，M5仍NOT_READY。
