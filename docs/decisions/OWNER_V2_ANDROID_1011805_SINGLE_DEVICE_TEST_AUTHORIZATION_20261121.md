# Owner决定｜授权EliteSync V2 Android 1011805单台实体设备测试

日期：2026-11-21。状态：**`OWNER_AUTHORIZED_SINGLE_PHYSICAL_ANDROID_DEVICE / LOCAL_USB_ADB_REVERSE / APK_1011805_INSTALL_AND_APP_SCOPED_TEST / NO_CLOUD / NO_BETA`**。

## Owner明确授权

Owner在P0.2交付报告后明确回复：

“好的我确认授权，下一轮可以实机检验，设备就绪。”

此前顾问提出的授权对象是一台Owner指定的自有Android手机，以及当前独立测试包1011805。本决定记录该明确授权，后续Codex无需重复询问是否允许实机安装和测试。

## 授权范围

- 仅一台当前接入或由Owner指定的实体Android手机；用`adb devices -l`识别设备。若恰有一台实体USB设备可继续；若多台，先向Owner确认具体序列号。拒绝Android Emulator。
- 仅安装和测试固定APK：
  - package：`com.elitesync.v2functionp0`
  - version：`10.1.18-v2-function-p0 / 1011805`
  - APK SHA256：`d6064498bac327f40f2b2df9c5ed9664c819b29dfaffa916eaf6f6df7b649c05`
  - Debug签名证书SHA256：`9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`
- 仅连接本机隔离服务`https://127.0.0.1:18444/`，使用已固定TLS证书和ADB reverse`tcp:18444 -> tcp:18444`。不得访问阿里云旧站、生产域名或公网服务，不修改TLS验证。
- 允许安装、启动、操作EliteSync测试包、使用虚构合成账号、采集EliteSync本应用截图及相关logcat、记录本轮ADB映射与测试结果。
- 使用合成素材完成头像/封面测试；不读取或上传Owner私人照片、联系人、短信、其它App数据或无关通知。不得清空、卸载或覆盖已有应用数据；若同包已安装，停止并报告，不清除旧数据。
- 结束时只移除本轮创建的`tcp:18444` reverse映射；不得执行`adb reverse --remove-all`。不做设备恢复出厂、系统设置重置或其它清理。

## 不在本次授权内

- 真实KYC/实名、真实用户数据或管理员资料。
- 相机/麦克风录制、RTC/Push真实服务、联系人权限、私人媒体访问。
- 阿里云SSH/部署/生产写入/真实数据迁移/费用采购。
- 软件著作权正式申报、封闭内测招募或启动、main合并、公开发布。

## 执行与证据

Codex先运行本机Host预检，识别设备，确认单台实体设备后执行脚本Reverse和Install。脚本`OwnerAuthorizationReference`使用本决定路径或本对话Owner授权作为引用，不得再向Owner索要重复许可。设备序列号仅留本机私有日志，公开GitHub报告脱敏。

该授权仅解锁当前1011805单机测试，不改变`CORE_FUNCTIONS_PARTIAL`、`CLOSED_BETA_NO_GO`或`PRODUCTION_NO_GO`状态。
