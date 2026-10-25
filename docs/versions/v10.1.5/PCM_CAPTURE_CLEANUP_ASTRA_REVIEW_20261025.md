# EliteSync v10.1.5｜PCM capture 清理竞态修复｜Astra 独立复核

日期：2026-10-25（Asia/Singapore）

**V10.1.5_PCM_CAPTURE_CLEANUP_REPAIR_ACCEPTED_WITH_OBSERVATIONS / AC05_OPEN / PARTIAL_NOT_ACCEPTED / PRODUCT_MAIN_NOT_INTEGRATED**

## 1. 复核范围与证据等级

Astra直接读取GitHub候选中的LiveKit应用自有vendor源码、两文件完整patch、来源说明、LICENSE/NOTICE、上游文件Hash清单、八例PCM清理回归、应用依赖锁、Gradle构建输入、实施报告、Manifest及候选Commit元数据，并静态检查捕获组所有权转移、取消闭包身份判断、组级幂等stop Future、track级在途清理等待与构建指纹。Astra未在本地运行Flutter测试、未构建/安装APK，也未访问手机或读取LOCAL_ONLY原始日志/二进制。测试、APK与真机结果属于CODEX_REPORTED，不是Astra直接执行。

- 候选交付Commit：`1a3a9ff9daa315fe5e688f6f0aab8e378e1db97c`。
- 唯一Parent：`1f9d1483268e957f7184625483ff6406071c1867`。
- 候选Root：`97fc729f68fe8d0b4bd1fc2f7dfb7cb0b2bad100`。
- 本轮源码Commit：`1f9d1483268e957f7184625483ff6406071c1867`，唯一Parent `2204c7439cca344795a9a4cc5e9c4d3e27b30d12`，Root `9beff929abf3939ac863cd4096ee9fb09a64a48d`。
- 候选apps Tree：`a5c6182ea9e064db4ef73e1627a6e38591c953cc`；services Tree：`21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。这是未接受候选树，不是产品main树。
- 实施报告Blob：`a2327eeb14532c711213a96290b08c53824c2895`；Manifest Blob：`74bb3b2b6a74344ddca9156a2bc08912d6701c4e`。
- 修改后local.dart Blob：`aa993c7dae22bf1adb59f5b3670f586b5032f82e`；PCM测试Blob：`a5b6c394b52eea643d86d7a3cca79bec2a0bfd3a`；upstream patch Blob：`6d69607c6507c20ea8f861501c800ce5651883e6`。
- 冻结plan Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`；唯一综合任务Blob：`43b2396b2fba046d5c0ab00bea87293783d1c2fd`。
- 复核前live main：`2d5467e8de5b5a87d086e0767b31318109e5c1cb`，Root `9fb331e395179f64380985afd27578bcb784f5e3`。

## 2. 根因与实现审查

原版SDK的AudioTrack.stopCapture遍历可变的_captureGroups Map，并在每个组的异步native stop期间等待；与此同时，最后一个renderer的cancel闭包也会移除组。两条清理路径并发修改集合，真实SDK定向回归在修复前出现ConcurrentModificationError，并暴露重复native stop与迟到旧cancel误删替换组的问题。应用层无法可靠地把SDK私有清理完全串行化，因此对当前锁定版本建立应用自有runtime副本有合理依据。

### 2.1 同步转移捕获组所有权

stopCapture先创建List.of(_captureGroups.values)快照，再同步清空_captureGroups，最后异步停止快照中的组。Map所有权变更发生在第一个await之前，不再在异步停止过程中遍历和修改同一集合。

### 2.2 旧取消闭包不能删除新组

renderer cancel仅在_captureGroups[options]仍与原group为同一对象时移除映射，因此旧组的迟到cancel不会删除同一options下后来创建的新组。组stop时同步清空renderer列表，已取消renderer不再收到迟到帧。

### 2.3 组级stop幂等，track等待在途清理

_AudioCaptureGroup.stop memoize _stopFuture，确保同一native renderer只执行一次stop；_stop等待start完成、取消StreamSubscription、停止capture并清空引用。track级_captureStopFuture合并等待已有stop和新一批group stop，避免某个组已从Map移除后，track级stopCapture丢失其仍在进行的清理。

静态逻辑与所交付测试相符，没有发现新的静态阻断问题。底层native start/stop本身抛错时的所有平台恢复仍未证明；错误继续传播，不会被伪装成成功。

## 3. 上游来源、许可与构建身份

这是现有锁定LiveKit 2.10.0缓存的应用自有副本，不是SDK升级。README记录原package archive SHA256 `9160950ff87d1946959e4911c16236ea7a3e74ac1987990b258132fd4ed0fca9`，原始local.dart上游Git Blob `3a3cea8c67d7ea5985df7e80f0791ba5664892dc`。保留297个runtime文件；UPSTREAM_FILES.sha256为每个保留文件记录原始字节Hash。报告称其中295件字节不变，仅local.dart与vendor pubspec.yaml作明确修改；ELITESYNC_PATCH.diff记录完整两文件差异。

LiveKit版权头、Apache-2.0 LICENSE与NOTICE保留；两个修改的上游文件增加EliteSync修改声明。依赖切换为应用自有path dependency `2.10.0+elitesync.1`。Gradle将应用pubspec、lock、vendor runtime和Dart defines纳入AAR摘要及输入。Manifest记录1036个tracked apps输入与隔离构建副本逐项SHA256一致，构建后复核仍匹配；这是Codex报告的身份检查。

应用自有vendor增加约297个供应商runtime文件的维护面，未来升级LiveKit时需显式重建来源Hash与patch审查；这是已记录的维护成本，不是本次阻断项。Astra核验了来源文件、Hash清单和关键改动，但没有独立重取并比较全部297个上游原始文件字节。

## 4. 测试与真机证据

按报告与Manifest，修复前原版SDK六例为1通过/5失败，exit1，24.969秒；失败包含ConcurrentModificationError、重复native stop和旧cancel丢失新组归属。修复后原六例通过，新增八例PCM边界测试通过。最终48项相关Flutter检查exit0，26.422秒，包括八项SDK捕获组/订阅/cancel/stopCapture测试和既有40项RTC service/page/spectrum检查，计数不重复相加。

新增测试执行真实RemoteAudioTrack、捕获组、订阅、取消闭包与stopCapture，仅替换MethodChannel/EventChannel的native transport，并以Completer控制start/stop竞态。覆盖stop与cancel交错、并发stop、不同采样格式、多renderer、迟到旧cancel、迟到帧与start仍在途等场景。定向Dart analyzer exit0，No issues found。

最终普通Android debug APK构建exit0，197.953秒；APK SHA256 `83f622f301803d92ccb92650b614334914db97f75ac1dffe5eb5a057257fd678`，416357439 bytes。安装后回取Hash相同，签名一致，数据保留。真机同call手动重连后音频/视频RTP计数增长，随后另一新call也建立真实媒体，支持清理后再次连接。最终进程采样日志未出现ConcurrentModificationError、Unhandled Exception、PlatformException、MediaConnectException或StateError字符串。

首次真机harness因UI_IDLE_NOT_OBTAINED exit1；finally通过真实服务API结束call1，原始失败保留。后续call2媒体与清理脚本exit0，但结束路径仍为service API，不是新一次UI挂断验证。日志结论只适用于所采集的进程窗口，不证明所有设备/平台/故障路径均无异常。Astra没有直接执行上述测试或设备旅程。

## 5. 保留观察项与整版门禁

- 修复后同一手机进程采样日志中未再次观察到ConcurrentModificationError；这是有界观察，不等于所有并发顺序的数学证明，也不是Astra重跑。
- 未进行native PCM handle全量清点；没有证明Room.dispose所有返回路径均成功，也没有验证native start/stop故障时的恢复行为。
- 本轮没有新AEC、客观音频波形停止计时、主观语音质量测试、成功媒体token的旧JWT重新入房负例或新撤权时序测试。之前已接受的真实媒体/撤权证据仅按复用证据保留。
- Gate 2的WinPS执行策略拒绝0.375秒与PowerShell 7 TypeLoadException启动失败0.390秒两次预算均已消费。本轮没有新Gate 2预算，没有Writer/Serializer调用；完整37案例suite、条件Sandbox SDK、Producer、libs.jar与30项Configuration.resolve均NOT_RUN。
- 真实Push Provider、实际经过15/30天的设备期限及物理30天清理、旧guest/HCS状态和ICE诊断旗标等既有未决项不因本次PCM修复关闭。

## 6. 独立裁决

**接受PCM capture清理竞态修复及其有界回归/真机后续连接证据：`V10.1.5_PCM_CAPTURE_CLEANUP_REPAIR_ACCEPTED_WITH_OBSERVATIONS`。** 未发现阻止该局部修复进入后续整版候选的静态问题；应用自有vendor来源、许可说明、依赖锁与构建输入有记录且可追溯。

这不是v10.1.5整版接受，不是产品main集成授权，也不证明AEC、全平台native失败恢复或全部SDK资源释放已闭合。整版保持`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / REAL_PUSH_PROVIDER_PENDING`。

当前候选`1a3a9ff9daa315fe5e688f6f0aab8e378e1db97c`未合并main。接受产品仍v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。继续沿用唯一v10.1.5长任务；不创建微任务、不自动合并main、不启动v10.1.6。