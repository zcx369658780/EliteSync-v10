# 当前入口｜2026-11-12 已有功能实机验收与顾问资料收口

Owner已明确继续，当前 **EXISTING_FEATURE_DEVICE_ACCEPTANCE_IN_PROGRESS**。工作限于已有功能实机测试、实际问题修复与顾问验收资料整理，具体见[Owner决定](../decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。整APP功能说明、各UI截图、所有现有按钮逻辑与UI切换层级纳入[验收目录](../versions/v10.1.5/acceptance/README.md)。

当前APP源码 `5e023b0632bc32ed4811818963b023b841e13dba`，后端25bc01f7，APK SHA256 `d60d8bc7c1aba006c5ed8d6a2a2344cfec6941c580ac06a3eaedbc7bf75761a1`，154567981字节。手机A和5580/B实读安装同包，5582/A暂停保留cdb。120项定向检查、受影响analyze及非作者审查通过。唯一[实施报告](../versions/v10.1.5/IMPLEMENTATION_REPORT.md)和[manifest](../versions/v10.1.5/artifact_manifest.json)已更新。

call44错误状态注入后的正常UI恢复、暂停保持及明确开麦后Owner“很清晰”反馈已记录，通话已ended。VM对象句柄变化不能单独证明新音轨，新TrackSubscribed实际事件证据UNKNOWN，原推论已限定。路由故障注入与蓝牙NOT_RUN。通话已有通过场景沿原候选证据收口，当前转向账号/资料、消息媒体、通知离线与现有页面流程及截图采集。

2026-11-12恢复实读手机和B连接、同包、无活动call、Room0，四自有服务运行。专用5038保持USB排除、手机5039、5037沿原边界。仍 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**，未验范围逐项记录。原主库dirty/index、无关目录、旧STOP和已耗记录继续保护，私有截图/APK/日志/SQL/凭据/许可证仅本地。

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
