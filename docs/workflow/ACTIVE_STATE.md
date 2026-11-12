# 当前入口｜2026-11-12 实机音频路由与前后台恢复

当前 **OWNER_PHYSICAL_SPEAKER_AND_BACKGROUND_SLICE_PASSED**。Owner继续实机验收后，已补通话页扬声器/系统听筒或耳机切换。APP源码 `ba5a5c26c6036086639f156573e826af2b872b34`，后端25bc01f7。134项定向检查、4文件analyze及非作者变更复核完成，发现的页面/共享旧Room归属P2已修。完整播放/自动路由重放/订阅异常可见恢复P2保留。

离线47.496801秒/退出0，APK 154560362字节，SHA256 `cc1be2f69ecf96486628fb31584c7fc3e89b4ea26e843998ac277f1e2017fa14`。手机A与5580/B已保留数据安装同包并核base.apk，5582/A AVD暂停保留cdb。唯一[实施报告](../versions/v10.1.5/IMPLEMENTATION_REPORT.md)与[manifest](../versions/v10.1.5/artifact_manifest.json)记录代码树和各候选实际范围。

ba call41听筒原生选择及Owner人声清晰通过，暂停采集时输出偏好往返切换未启用mic/camera。自动重订阅的不同SID观察未取得，后置mic查询时该call已ended，原界限保留。ba call42新call默认扬声器、手机Home停止观察上界0.453秒、返回保持关、明确正常UI开麦后立即观测原生mic active，Owner再次确认两边清晰。正常挂断42 ended/Room0、双端采集关闭。cdb call40相应实机恢复通过原身份保留。

本轮两次媒体authority monitor超时均fail-closed，根因/阶段UNKNOWN。当前自有SFU已设 `on-failure:3`，一次空房间进程退出的自动恢复、同网关SHA及无效token403已验证，真实超时注入与负载恢复矩阵未运行。B曾在2GiB guest被LMKD结束，现4GiB，A AVD暂停。B自动息屏原证保留，工具采用30分钟唤醒时间并核后置UI。手机设置沿Owner当前状态。

四服务运行，手机/B已正常结束通话，专用5038继续USB排除，手机5039与精确四端口反向映射保留，5037沿原边界。仍 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**。蓝牙/插拔、长时及复杂中断/AEC、完整权限并发、自然期限及硬件存储等范围见报告。原主库dirty/index、无关目录及旧STOP/已耗记录保护，私有原证/凭据/SQL/APK/截图/许可证仅本地。

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
