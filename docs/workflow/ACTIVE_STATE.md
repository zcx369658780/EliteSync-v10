# 当前入口｜2026-11-12 已有功能实机验收与顾问资料收口

当前 **EXISTING_FEATURE_DEVICE_ACCEPTANCE_IN_PROGRESS**。Owner决定限于已有功能实机测试、实际缺陷修复及顾问资料整理，范围见[决定](../decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。当前转向消息媒体及其余现有页面，[验收目录](../versions/v10.1.5/acceptance/README.md)维护功能、UI截图、全部现有控件与导航、实际结果。

当前APP源码 `e5aa6a29a76711b0e4bdb01613e269759d1ffe8e`，后端 `6549f02880968f99ae3f45439d15a37c1b3d5251`。APK 154568851字节，SHA256 `398d9e1a30a92b39e6a8f95c8218a3ea1a528e7baedb924636f5f8705f6a7608`，离线32.4737954秒/退出0/v2签名。手机A和5580/B实际同包、登录聊天保留，5582/A暂停保留cdb。唯一实施报告和manifest已更新。

本轮版本中心dev误解析为0导致强制旧版下载已修，9项54断言及手机同包通过。昵称独立保存/重入/恢复及通知偏好持久化/恢复通过。通知中心2秒闪烁根因共享provider被后台来电扫描周期刷新，已分离读取、禁用UI失败自动retry，页面退出释放后重进单次读取。45项定向及受影响analyze通过，识别的生命周期P2已修并复核。8216手机正常滚动/未读50→49，e5最终手机受控失败停住/服务恢复后等待/明确重试恢复通过，Owner确认“正常，不再闪烁，按钮可用”。临时代理已停，手机API直连已恢复。

旧5e call44清晰反馈等沿原候选保留，VM对象句柄不足以证明新音轨，限定说明保留。仍 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**。自然时间/硬件故障/蓝牙等按实际条件列明。原主库dirty/index、无关目录、旧STOP及已耗记录受保护，截图/APK/日志/SQL/凭据/许可证仅本地。

以下为历史交付快照。



---
## 历史609交付快照

Owner要求完成软件侧后停下通知。当前 **V10.1.5_CANDIDATE_DELIVERED / AWAITING_OWNER_DEVICE_ACCEPTANCE**，本轮自动化工程停止。长期普通工程授权保留，下一次实机动作按Owner协助安排。

- APP源码 `60930170e3a437da0b77e877c55ed4dd1a92f9ca`，后端 `25bc01f7d6ce848f5fe964bbc544e9be87325a0e`。唯一[实施报告](../versions/v10.1.5/IMPLEMENTATION_REPORT.md)和[manifest](../versions/v10.1.5/artifact_manifest.json)固定Commit/Root/apps/services、检查及限定证据。
- 最终arm64 Debug APK为154546416字节，SHA256 `d8af0c896ceeb43d2251c89d1080eced593392d5127b0276c95db7ba88b89b67`。私有根 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev` 下delivery保存固定命名包。两端base.apk已核同hash。
- 最终同包完成未知POST109跨冷启与原编号重试、图片111/视频110持久化和播放、通知权限拒绝时文字112正常双向链、旧通知168实际点击重验、call22当前/旧JWT与媒体URL撤权。commit后双端原生停媒保守上界4.874250秒，尾窗15次双端采样未见反弹。四服务重启前后指定持久事实相同，双APP文字图片视频及独立Web读回通过。
- 真实认证HTTP kernel/MariaDB受控时钟16项通过，独立原生存储probe的7次wrapper故障及新进程冷启重试通过。自然30天、硬件Keystore/物理故障、实机音质/AEC仍待验证。609附件明确重试观察UNKNOWN，5af相同逻辑的实际重试证据保留。完整权限/并发和页面覆盖边界详见报告。
- 停下时两APP正常force-stop，5580实际B/user2、5582实际A/user1的AVD/登录/数据保留，模拟器保持运行。四个自有DB/API/WS/SFU服务运行，房间0，采集停止，开发库4虚构用户/112消息/13媒体、MC generation13。专用ADB5038保持USB排除。

冻结结论保持 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**。Owner实机协助与最终产品接受待完成。原主库dirty/index、无关目录、历史STOP和已耗预算受保护。私有原证、凭据、SQL、APK、截图及许可证本机保存。11月11日交接和停止回执继续保留历史身份。

最终Git本地/远端HEAD、资源实读及手动恢复信息见私有 `final-local-github-receipt-20261112-private.json` 和 `HANDOFF_PROMPT_20261112.txt`。稳定构建目录与现有工具继续沿用。
