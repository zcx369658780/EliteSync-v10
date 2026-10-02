# APP-M5-09｜当前模拟器用户的拟议synthetic包占用

ISSUED；LEVEL 2。Codex 01a0ef77-af94-75e2-8726-87c04e082018，Sol/medium。固定D:\EliteSync-v10 main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。先读根authority、local-workflow、M5-08 task/summary/work-review。唯一交付本目录summary.md；不修改源码、authority、其它证据。保留全部dirty/untracked。

目的：M5-08 pm path的非0回执仍UNKNOWN，不重跑/改写；通过当前用户的准确包列表获得不同占用证据。仅拟议com.elitesync.syntheticdemo，不查其它包，不将拟议ID当已接受产物。

固定adb C:\Users\zcxve\AppData\Local\Android\Sdk\platform-tools\adb.exe，SHA256 7035CF5EC7F99F7B5662A9F5395F9DCCFC3B6FE42583D0B9550124A0C3496606，先只读核对。所有命令-H localhost -P 5037 -s emulator-5554，不另枚举设备/用户/包。
新预算每命令1次、20秒硬时限、stdout/stderr各16KiB上限并行排空，失败/超时/截断/输出异常即停，无重跑：
1. shell getprop ro.kernel.qemu，必须单行1；确认仍为模拟器。
2. shell am get-current-user，必须单个非负十进制整数，记为U，不假设user0。
3. shell cmd package list packages --user U com.elitesync.syntheticdemo，U用参数列表传入，禁止shell拼接。只允许非空行格式package:有效Android包ID；逐行精确等于package:com.elitesync.syntheticdemo才记INSTALLED，退出0无精确匹配记NOT_INSTALLED_FOR_CURRENT_USER。不输出任何其它包名称，仅非精确匹配计数；stderr非空、非0、异常格式或重复准确项则UNKNOWN并停。

本查询只建立当前用户的占用事实，不证明其它用户、设备、未来安装安全。不使用-u/-f，不取APK路径或应用数据，不执行pm path或旧未执行命令。空输出只有退出0且无异常才构成当前用户未安装事实。模拟器/当前用户变化在未来安装前须复核。

禁止安装/卸载/clear/启动/截图/logcat/pull/push/reverse/forward、Gradle/Flutter、properties/凭据、网络API/生产DB/真实备份/密钥/SSH/旧D:\EliteSync/UAC/物理设备；不查全包列表，不创建后继、不自接受或Git提交。交付记录固定工具哈希、三命令参数/退出/时间/限额/预算、模拟器和U及精确包状态，原始额外包名不落盘。停独立Work审查。M5仍NOT_READY，各旧预算耗尽不重置。
