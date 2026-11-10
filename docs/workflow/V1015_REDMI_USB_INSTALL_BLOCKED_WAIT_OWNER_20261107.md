# v10.1.5 Redmi USB安装受限，按Owner要求等待｜2026-11-07

**PHYSICAL_USB_PHONE_QUALIFIED / INSTALL_FAILED_USER_RESTRICTED / WAIT_OWNER_AFTER_MEAL / RUNTIME_HOT_RELOAD_NOT_RUN / G2_FALSE**

Owner指定自己的唯一手机Redmi K80 Ultra继续源码Debug调试，并明确安装若被手机点击/确认卡住，就停下等待吃完饭。该手机按个人数据设备处理，未假定为可清空的专用测试机。

只读核对一台已授权ADB设备：市场名REDMI K80 Ultra、型号25060RK16C、ARM64/API36、主用户0；`adb -d get-serialno`与选定设备一致，确认USB传输。Windows `get-devpath`返回unknown，未当作USB证据。精确查询`com.elitesync.v1015dev`在安装前不存在；未读取其他APP、个人界面、账号、文件或广域设备日志。设备序列号和原始ADB输出仅LOCAL_ONLY，不上GitHub；FD02产品功能排除继续保留。

同一已验源码Debug APK SHA256 `974ef00c5803c87acee457d6010648f4b1fb0868fecc966e61e3ad363017a4dc`，仅对绑定USB设备的用户0尝试新包安装1次。没有`-r`覆盖、`-g`自动授予权限、降级、卸载、清空或修改手机安全/USB设置。约16.509秒返回exit1：`INSTALL_FAILED_USER_RESTRICTED: Install canceled by user`。该字符串不证明Owner手动取消，手机确认/安全策略的具体原因UNKNOWN。

**收到受限结果后立即停止，未重试、未轮询设备、未继续任何手机命令。** 本节点共13条ADB命令（12条连接/资格元数据与精确包查询，1条安装）；APP启动、登录、attach和热重载NOT_RUN。按Owner要求等待饭后回来；不要求Owner现在操作手机，也不自动启动第二次安装。

本地原证根名`v1015-redmi-source-debug-usb-20261107-case01`，入口`wait-owner-checkpoint-private.json`、`install-outcome-private.json`、`qualified-device-target-private.json`及最终本地/Git回执。设备数据/原始日志不上GitHub；旧17500项保护ledger承接并仅追加本节点原证，不重扫旧SDK/AVD/Sources。

源码Debug APK构建与核验结果保持，case05已耗1余0、无SDK重编；case01–04旧STOP、原AAR/host预算、旧SDK/Pub、DB、备份、worktrees、原dirty根及无关`%SystemDrive%/`不动。本轮无后端/DB、云、VM、媒体或真实Push运行，旧VM teardown UNKNOWN。

仍**10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING**。仅安装受限，不能升级为手机运行、热重载或G2验收；不合main、不发布、不启v10.1.6。
