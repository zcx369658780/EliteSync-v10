# EliteSync v10.1.5｜ICE 真机媒体、同 call 重连与撤权停止｜Astra 独立复核

日期：2026-10-25（Asia/Singapore）

**V10.1.5_RTC_MEDIA_AND_RECONNECT_ACCEPTED_WITH_OBSERVATIONS / SDK_CLEANUP_EXCEPTION_OPEN / AC05_OPEN / PARTIAL_NOT_ACCEPTED / PRODUCT_MAIN_NOT_INTEGRATED**

## 1. 复核范围与来源等级

Astra直接读取GitHub中的本轮实施报告、Manifest、四个RTC源码/测试文件、候选Commit元数据、候选父子关系和完整apps/services Tree摘要，并静态检查room teardown屏障、显式同call重连路径及刷新时保留UI状态的实现。Astra没有执行本地Flutter测试、没有访问手机、没有直接读取原始ADB/RTP/SDP/音频日志或APK二进制。真机媒体和RTP计数属于`CODEX_REPORTED / DEVICE_NEW_RUN / SYNTHETIC_PC_PEER_TEST_ONLY`；Owner听到合成音的反馈来自本会话。此裁决不将Codex运行结果伪称Astra直接执行。

- 最终候选交付Commit：`2204c7439cca344795a9a4cc5e9c4d3e27b30d12`。
- 唯一Parent：`80f6292a2c3726716ab82152f36428812f23058f`。
- 候选Root：`193db70bc47b31b1f98a36d62e22d00e34534405`。
- 本轮最终源码Commit：`80f6292a2c3726716ab82152f36428812f23058f`，唯一Parent `08df5042378a5887f36e9a1033ff654d993cc38a`，Root `5dbb0ae4c64bb7cce6db0e4be03625bfa678aed2`。
- 前一源码Commit：`08df5042378a5887f36e9a1033ff654d993cc38a`，Parent `dad5d8fe36874095c90e25f651775796bfeba7eb`。
- 候选apps Tree：`a0ca61faf9e1264f7ae4b638c78ebeae257ea002`；services Tree：`21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。候选apps递归Tree有1133项、services有792项；这些是候选树，不是产品main树。
- 报告Blob：`01aff46f9c69c4cd45c7ae2e5950926298913d22`；Manifest Blob：`e3da252a4fa46b5c5222c5560febe68b3f4fc5b6`。
- 冻结plan Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`；唯一长任务task Blob：`43b2396b2fba046d5c0ab00bea87293783d1c2fd`。
- 开工/交付前live main：`bee04025237ea099b2b274d06a12cfa2bab5b5e1`，Root `683d8fe2268adbeca05da0ce31224b67d042223c`。

候选相对上一次USB交付`dad5d8fe...`前进三个普通提交。最终交付Commit仅追加报告与Manifest；前两个提交改变了RTC service、RTC page及两份相关测试，后端源码未随本轮改变。Manifest报告735个tracked apps文件在隔离构建副本与实际工作树逐项SHA256匹配；这是Codex记录的构建身份检查。

## 2. ICE 根因定位与真机媒体结果

此前回环TCP路径虽能建立socket，但没有STUN响应、nominated candidate pair或RTP。当前报告记录：在Owner对本轮自有SFU单项批准后，只设置其`rtc.interfaces.includes: ["eth0"]`，没有改变node_ip、端口、loopback发布端口、凭据或其它ICE参数，也没有修改系统网络/防火墙/路由。该单变量试验后，SDK在约1.437秒连接并产生STUN响应和成功提名。首个控制脚本因IPC JSON写入未完成而exit1，原失败保留；不能把该次脚本记为PASS。

修正证据读取后，最终APK同一callId `10`有真实双向RTP计数随时间增长：音频入/出、视频入/出各记录17批、跨约64秒，入站视频`framesDecoded`从90增至1369。手机和合成PC SDK对端的轨道状态、RTP趋势与手动重连后新轨道对应。由此接受本次有限的真实设备媒体建立和同call手动重连证据；合成PC对端并非第二台真实手机，因此不将其包装成双物理设备的端到端用户体验验证，也不把每批统计求和冒称精确线缆字节计量。

## 3. 同 call 重连源码审查

最终`rtc_livekit_service.dart`使用`_roomTeardown` Future作为旧Room销毁屏障。`_leave`先撤销当前Room身份、增加generation并阻止旧事件影响新Room，随后等待`disconnect()`，无论disconnect成功与否都尝试`dispose()`，并在dispose尝试结束后释放teardown Future。新的`ensureConnected`在读取join信息前等待当前teardown，且检查generation/attempt身份，避免旧Room原生清理与新Room加入重叠。

页面的显式`_reconnectMedia()`先fresh-fetch当前call，拒绝terminal/unknown状态，再执行`_leaveMediaOnce`，然后重新调用`ensureConnected`取得新的join授权；不会复用旧页面缓存或旧Room凭据。旧Room的轨道事件通过Room identity检查，不污染新Room。刷新过程中保留已有内容与滚动位置，实际错误和身份改变的关闭分支仍保持。非作者复核报告的四个RED→GREEN场景和40项相关Flutter检查属于Codex报告；源码静态检查未发现新的阻断问题。

## 4. 撤权后媒体停止上界

报告记录在仅限任务自有隔离库、精确合成账号与真实`LiveConsentService::transition`的测试中，call10撤权后同call手机产生新`leave_complete`，对端断开。保守计时从真实transition调用前开始，直到收到手机清理完成日志，**上界0.790秒**；COMMIT处于该区间内，但没有独立打点，所以不能声称精确的COMMIT后0.790秒。

该上界不仅依赖best-effort的`leave_complete`：报告还列出同一APP PID中新观察到的两次`peerConnectionClosed`、`AudioRecord stop done`、`AudioTrack stop done`及`camera release`，均在该上界内出现。接受这组证据支持“此次测试中的native peer/audio/camera停止事件在5秒内可见”。但`Room.dispose()`整体返回成功未独立证明，最后可闻波形停止也未测量；该撤权路径为TEST_ONLY服务层夹具，不是本次HTTP/UI撤权全路径。成功媒体token的旧JWT重新握手负例本轮未运行，之前接受的旧token负例只作复用证据。

## 5. 仍然开放的SDK清理异常与AEC

最终手机PID的日志仍出现一次`ConcurrentModificationError`，发生在SDK remote PCM capture清理期间。该异常未通过共享SDK修改、忽略日志或重跑掩盖；当前报告仍保留它。虽然本轮真实双向RTP、同call重连和native teardown事件均已观察到，异常仍需后续解释或修复，并验证不会泄漏renderer/capture资源或破坏后续通话。因此本次**不接受“RTC清理完全无异常”或SDK稳定性整体通过**。

Owner反馈同call10合成音在结束后停止，是有界听感记录；停止秒数未测，不能将其当成AEC、真实双人语音可懂度或最后声波停止的证明。物理AEC/语音质量仍`NOT_RUN / NOT_PROVEN`。麦克风/摄像头muted/unmuted远端轨道证据来自此前call4/旧APK，最终APK本轮未重新执行该toggle；后台自动恢复也未证明。

## 6. AC-10.1.5状态与未完成门禁

- `AC-10.1.5-05`：升级为`PARTIAL_MEDIA_NOW_SUPPORTED / AC05_OPEN`。有界真实双向RTP、入站视频解码、同call手动重连、撤权后native停止事件上界有证据支持；SDK清理异常、AEC/语音质量、成功媒体token旧JWT重新入房、物理双手机体验仍未全部闭合。
- `AC-10.1.5-10`：本轮最终普通开发APK构建成功、安装后回取Hash一致，40项相关Flutter检查exit0；后端旧测试与此前设备场景按报告区分为复用，不重复计数。
- `AC-10.1.5-06/07`：真实经过15/30天的设备期限、离线时序和物理30天清理仍未运行；旧受控注入不能替代真实经过时间。
- `AC-10.1.5-08/09`：原生通知权限拒绝有前轮证据；真实Push Provider/SDK/Key/送达仍pending，旧通知无可读卡片的点击路径未运行。
- Gate 2：原WinPS执行策略拒绝0.375秒与PowerShell 7 `TypeLoadException`启动失败0.390秒两次预算仍已消费。本轮没有新Gate 2预算、没有运行Writer/Serializer、没有重跑D0-A。完整37案例suite、条件Sandbox SDK、Producer、`libs.jar`与30项`Configuration.resolve()`均`NOT_RUN`。

## 7. 独立裁决

**接受本轮有限的ICE真机媒体建立、同call手动重连、撤权后native停止事件和对应源码/测试修复：`V10.1.5_RTC_MEDIA_AND_RECONNECT_ACCEPTED_WITH_OBSERVATIONS`。** 此为有界接受，不代表所有RTC/SDK/AEC合同闭合。

整版继续：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / SDK_CLEANUP_EXCEPTION_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / HOST_APK_BUILT_INSTALLED_BYTE_VERIFIED / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / REAL_PUSH_PROVIDER_PENDING`。

本轮候选未合并产品main；接受产品仍v10.1.4，apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。不创建微任务，不自动启动v10.1.6。继续沿用唯一v10.1.5长任务，在同一授权范围内处理SDK清理异常、剩余RTC质量/权限边界及与Gate 2无依赖的工作，随后集中交付复核。