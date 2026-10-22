# EliteSync v10.1.5｜Owner选择方案A：RTC独立阻断＋安卓真机测试方向

日期：2026-10-22（Asia/Singapore）。**OWNER_SELECTED_PLAN_A / RTC_GATE_RETAINED / ANDROID_PHONE_FEASIBLE_AS_TEST_ENDPOINT / DEVICE_AND_NETWORK_EXECUTION_NOT_YET_AUTHORIZED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

## 一、Owner本轮明确决定

在Astra报告v10.1.5 RTC专项独立复审之后，Owner询问“手机是否可以用于合成音频配置的设备？如果可以我选A”。顾问对安卓真机音频能力及当前隔离网络前提做了技术区分，故将Owner决定按**方案A**登记：

1. 保留v10.1.5原冻结AC，包括真实双端SFU媒体、同call重连、旧RTC JWT拒绝和撤权后≤5秒媒体停止；不通过降级或重新划分AC冒称v10.1.5 ACCEPTED。
2. v10.1.5仍`PARTIAL / NOT_ACCEPTED / PRODUCT_MAIN_NOT_INTEGRATED`，v10.1.4现有已接受main不变；v10.1.6不自动启动。
3. 已交付v10.1.5首轮与R1的消息、图片短视频、可信T0、受控Android计时注入/加密密文清理以及通知最小化等证据保持其原有接受限制，不因RTC环境失败而反复返工。
4. RTC的下一步先解决**独立的合成音频测试环境前置条件**。安卓实体手机是合理的技术候选，可替代发生`injectAudio`RPC阻塞的模拟器。但“手机可以用于音频测试”不表示当前已有两台合适设备、当前APK可直接安装、或四条硬门已经验证。

## 二、安卓真机音频的可行路径与限制

- **推荐：两个独立的安卓实体APP测试端**。各端经本人授权仅使用合成测试账号和测试媒体；采用另一独立设备/电脑扬声器在适当音量播放440/880Hz合成测试音，交由每部手机自己的麦克风捕获，观察APP→合法受控SFU→另一APP真实接收的媒体事实。对声学反馈和AEC独立记录；不默认录制用户自然语音或个人信息。
- 如只有一部安卓真机，可先验证麦克风采集与服务接入，但若另一端AVD媒体仍故障，不能声称“双端APP双向媒体”或替代旧5秒门禁。手机自己扬声器放出的测试音不等于Android系统提供的可重复虚拟麦克风PCM注入；真正数字PCM音轨通常需已有SDK可用能力或隔离测试代码，不能默认普通ADB可直接向真机mic注入。
- 真实手机访问当前仅localhost/loopback的Laravel/guard/SFU并非USB连接自动解决。必须定点设计一个**仅Owner批准设备可及、最小LAN或受控USB/隧道**的合法信令与ICE媒体候选路径，并复核端口、鉴权、raw SFU隔离与撤权效果。真实WebRTC可能使用UDP或ICE/TCP；不得自动修改Windows防火墙、开放公网/新UDP端口、引入新TURN或SDK、产生费用或暴露raw SFU。
- 只在有精确手机型号/系统版本/网络/测试APK ABI、设备所有权与显式权限范围后再讨论下一份Codex受控试验任务。是否使用两台真机、是否授予真实设备麦克风/调试权限以及是否临时提供局域网可达性，均**不能**由本轮条件选择A推定为无边界授权。
- 可查权威来源：Android emulator官方说明`-no-audio`禁音；LiveKit官方支持安卓移动端麦克风publish以及独立的ICE UDP/TCP端口；这些原理性依据不证明EliteSync本地配置已具备。

## 三、保持冻结与停止门

这次是**产品/验收路线选择与设备可行性判断**，不是Codex实际执行授权：未启动服务/模拟器/手机、未启用麦克风/摄像头、未更改网络端口或防火墙、未变动v10.1.5产品源码、未合main、未生成R2任务。后续Owner明确设备和最小权限后，才可签单次前置可行性验证并再决定是否进入原四条RTC补证。

先前Astra复审：`docs/versions/v10.1.5/rtc_env_gate_independent_review.md`；正式执行与证据：`RTC_ENV_GATE_EXECUTION_REPORT.md`及`rtc_env_gate_manifest.json`。历史源/审阅/备份完整保留。
