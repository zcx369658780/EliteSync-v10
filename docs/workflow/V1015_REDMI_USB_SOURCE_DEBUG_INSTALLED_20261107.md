# v10.1.5 Redmi USB源码Debug APK已安装并核对原字节｜2026-11-07

**SOURCE_DEBUG_APK_INSTALLED_EXACT_BYTES_VERIFIED / APP_LAUNCH_ATTACH_HOT_RELOAD_NOT_RUN / G2_FALSE**

Owner饭后明确“可以我在了，请继续安装”，中断后再次“请继续”。接续范围`v1015-redmi-source-debug-usb-20261107-case02`保留case01安装受限原文与STOP/等待记录，不修改旧claim或复用旧安装尝试。启动前确认无遗留安装客户端。

重新只读确认物理USB仍指向同一Redmi K80 Ultra、主用户0，开发包尚未安装。核对原ADB二进制和固定APK哈希后，仅一次`install --user 0 -t`，约7.868秒返回exit0/Success；没有覆盖参数、自动授予权限、降级、卸载、清空或修改手机安全/USB设置。此继续依据Owner本人返回后的明确指令，不是后台自动重试。

手机实际安装`com.elitesync.v1015dev /10.1.5-dev /1010501 /debuggable`。定向查询该开发包的base.apk并在设备上计算SHA256，与已验交付**974ef00c5803c87acee457d6010648f4b1fb0868fecc966e61e3ad363017a4dc**完全一致；因此承接原APK的ARM64、Android Debug签名、JIT kernel和官方Debug引擎代码链核验。不是仅凭安装返回Success认定产物身份。

本次8条ADB命令：4条连接/用户/目标包状态核对、1次安装、3条目标包路径/哈希/元数据核验。没有读取个人文件、其他APP、广域日志或手机界面；设备序列号、原始包路径/输出仅LOCAL_ONLY。

**本次安装目标已完成；Codex未发APP启动命令，运行、attach和热重载仍NOT_RUN。** 不把安装通过当设备功能或G2通过。下一工程步骤是接通源码调试服务和热重载；不因本次安装放宽真实账号/数据、后端/外部服务、媒体/Push或发布边界。FD02产品排除保留。

原证根名`v1015-redmi-source-debug-usb-20261107-case02`，先读`verified-installed-source-debug-private.json`、`install-outcome-private.json`及最终本地/Git回执。此前case01受限安装失败不改写；源码构建case05完成1/0、旧SDK构建/STOP/数据库/原dirty根/无关`%SystemDrive%/`保持。无SDK重编、后端/DB、VM、云、媒体或真实Push操作；旧VM teardown UNKNOWN。旧17541项保护ledger承接，仅追加本节点原证。

仍**10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING**。不合main、不发布、不启v10.1.6；APK、设备原始日志、凭据和私密原证不上GitHub。
