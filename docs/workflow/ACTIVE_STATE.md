# 当前入口｜2026-11-12 手机复测与模拟器宿主音频配置修正

当前 **HOST_AUDIO_CONFIG_REPAIRED_AWAITING_OWNER_RECALL**。Owner已确认连接，手机保留数据更新同cdb并核base.apk SHA，A登录与B历史对话保留。call35双端媒体和四方向RTP有效，但Owner只在手机听到沙沙声，电脑无声、无法辨识电脑说话，双向人声验证失败。

两个保留AVD硬件录音/播放实际均关闭。此前仅凭未带no-audio启动参数标音频开启的元数据已更正。正常挂断并停止自有AVD后，已启用config两项、重启核generated hardware均true，并开启B宿主麦克风、调整语音音量8/15。两个账号/APP数据保留，A模拟器APP暂停，B与手机聊天页就绪。已请求Owner重拨，修正配置后人声/AEC仍待验证。5038继续USB排除，手机使用精确5039，5037沿原状态。

APP源码 `cdb0b46dc4613b35eba7adb0c50415a455f3063c`，后端25bc01f7。首次麦克风/相机授权前置及代次保护已完成，补修旧终态页暂停残留影响下一通入房。83项定向检查、两文件analyze及非作者变更复核通过。离线37.5032738秒/退出0，APK 154557386字节、SHA256 `85c6deddd3463d06188137aa9658879fbc054e04867178c04e710bbb27c25fc8`，双模拟器实际安装hash一致。唯一[实施报告](../versions/v10.1.5/IMPLEMENTATION_REPORT.md)和[manifest](../versions/v10.1.5/artifact_manifest.json)记录当前身份及历史候选范围。

c1 call28/29首次mic、call30首次camera与真实Home通过。最终cdb call34保留终态页后新通话双端入房、双方原生mic active，四方向RTP持续增长。Home停媒观察上界6.047秒，返回保持关闭、明确开麦恢复，正常挂断Room0/采集停。合成音诊断默认RPC期间源模拟器退出，客户端报SocketException，退出根因未定，已恢复并结束该诊断，客观输出UNKNOWN。实机声音/AEC按顶部最新复测保留待定。完整可见播放/路由/订阅故障恢复P2保留。

5580实际B、5582实际A，四自有服务沿用，精确本机映射恢复。历史609同包消息/附件/通知/MC撤权/持久重启证据及c1原生证据保留各自源码身份，cdb未重新进行全部联合旅程。仍 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**。原主库dirty/index、无关目录及旧STOP/已耗记录保护。私有原证、凭据、SQL、APK、截图及许可证本机保留。

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
