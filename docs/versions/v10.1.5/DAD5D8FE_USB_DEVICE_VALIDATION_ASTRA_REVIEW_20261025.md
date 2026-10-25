# EliteSync v10.1.5｜USB 真机续接交付｜Astra 独立复核

日期：2026-10-25（Asia/Singapore）

**V10.1.5_DEVICE_VALIDATION_ACCEPTED_WITH_OBSERVATIONS / AC05_OPEN / PARTIAL_NOT_ACCEPTED / PRODUCT_MAIN_NOT_INTEGRATED**

## 1. 裁决范围与权威身份

Astra直接读取GitHub上的最新`IMPLEMENTATION_REPORT.md`、`artifact_manifest.json`、任务单与状态入口，并独立核验候选commit关系及文档差异。Astra没有直接访问本地LOCAL_ONLY原始日志、APK二进制、SQL dump或设备；本轮USB/Android测试事实属于Codex报告并由脱敏清单提供Hash和摘要，不能标成Astra直接执行。

- 交付候选Commit：`dad5d8fe36874095c90e25f651775796bfeba7eb`。
- 唯一Parent：`c445554f01fbd8c9aef641302f3f090900703786`。
- 候选Root Tree：`b17b6059e5f2354fa53ba88bae9f146c0a28216c`。
- 实施源码仍为`c445554f01fbd8c9aef641302f3f090900703786`，唯一Parent `67f83b053096b181ff64366f3eaad0e5e44815f8`，Root `a964881253000ed86601978d136dfba5820606fc`；本次候选只更新报告和Manifest，不改变产品源码。
- 报告Blob：`26fecfc4a703201ce7ca5f64384785e0b90302c8`。
- Manifest Blob：`997f2c709e8a636ee317562bb1ab17804ad737f7`。
- 冻结计划Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`。
- 当前唯一综合任务Blob：`43b2396b2fba046d5c0ab00bea87293783d1c2fd`。
- 交付前live main：`a391398fdc6a0547ba4b4354fc300def6da9acb5`，Root `85359b9dfb80f24eb083096006ce4b3f58758884`。

GitHub compare确认候选相对`c445554f...`仅修改`IMPLEMENTATION_REPORT.md`与`artifact_manifest.json`，没有应用或服务源码改动。候选apps/services身份继续引用已局部接受的`e9ed3a1dee4c892840831b0e31f6f96669fa17d5`和`21eebf69bbc6397b1562d40f8cd9ebd7b246720f`；接受产品main仍为v10.1.4的apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`与services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。

## 2. 真机新证据裁决

Owner已授权使用USB调试连接的单台Xiaomi测试手机。交付报告记录Android 16/API 36/arm64-v8a。候选普通开发APK构建exit 0，APK SHA与安装后回取SHA一致，既有应用数据保留。该证据支持本次APK的构建/安装/字节身份，不证明正式发布签名、生产发行或整版接受。

| 场景 | Astra裁决 | 证据限制 |
|---|---|---|
| 真机文字发送 | `ACCEPTED_BOUNDED_DEVICE_TEXT` | 合成文本由当前APP UI发送，服务端确认提示、对端API读回同一message/client_message id，数据库重启后仍只有一条；控制脚本先前误点失败保留。 |
| 呼出、来电、拒绝、挂断及取消后再呼叫 | `ACCEPTED_BOUNDED_CALL_CONTROL` | UI与真实API/数据库终态相符；Room连接曾启动，但不代表媒体建立。未刻意延迟真实endCall/heartbeat，也未运行同call媒体重连。 |
| 撤权后的旧JWT/RTC拒绝 | `ACCEPTED_BOUNDED_AUTHORITY_NEGATIVE` | 撤权前validate 200，撤权后validate与首个WebSocket握手均403；当前join/聊天读写/通话详情404，数据库call ended/activeCalls=0。此JWT此前未承载媒体，不能证明旧成功通话重新入房或流动媒体停止时间。计时从撤权HTTP成功响应后开始，未测精确DB COMMIT时点。 |
| 冷启动锁定 | `ACCEPTED_BOUNDED_COLD_START_LOCK` | 实际APP重启回登录页，无旧合成联系人/消息；不等于15/30天离线读取或物理30天清理。 |
| 通知偏好与OS权限 | `ACCEPTED_BOUNDED_NOTIFICATION_PRIVACY` | 偏好真实持久化；权限撤销后PackageManager确认denied，APP重启并锁回登录，旧私密内容未显示；原denied状态恢复。原生权限弹窗的拒绝流程未运行，真实Push未运行。 |
| 数据库重启读回与退出 | `ACCEPTED_BOUNDED_PERSISTENCE_AND_CLEANUP` | 任务专属新容器的10张表规范快照重启前后相同，合成消息仍1条；任务服务与活动会话已停止。不是异库恢复演练，也不是全部93表/所有历史资产的证明。 |

这些结论仅接受报告中有界的设备场景及其交付证据，不将复用的旧单测计数重复算成本轮真机执行。

## 3. AC-10.1.5状态与必须保留的阻断

- `AC-10.1.5-01`：受控基线/保护证据有界支持；不扩大为对整盘所有历史SQL/APK的逐字节审计。
- `AC-10.1.5-02`：本轮真机文字发送/持久读回支持；请求已提交但响应丢失的真实设备故障注入及全量双APP旅程仍部分复用旧证。
- `AC-10.1.5-03`：本轮撤权拒绝支持；完整GUI切号/注销、旧通知点击及WS撤权时序矩阵仍部分未完成。
- `AC-10.1.5-04`：本轮真机未重做图片/视频；此前受控私有媒体/Range/撤权证据可复用，但不得标成新设备执行。
- `AC-10.1.5-05`：`PARTIAL_CORE_OPEN`。手机和合成PC SDK对端的ICE未建立，`MediaConnectException`，无nominated pair/RTP；双向媒体、同call媒体重连、流动媒体≤5秒停止、真实麦克风/摄像头媒体启停与物理AEC均`NOT_RUN / NOT_PROVEN`。精确ICE根因未解决。
- `AC-10.1.5-06`：15/30天与T0边界复用既有受控证据；本轮不是实际经过15/30天的设备实验。
- `AC-10.1.5-07`：本轮冷启动锁定有界支持；真实物理30天到期清理未重新执行，不能以旧注入替代实物期限证明。
- `AC-10.1.5-08`：本轮通知偏好、OS权限撤销与私密内容隐藏有界支持；原生授权弹窗拒绝、完整Safety/旧通知GUI矩阵未全部执行。
- `AC-10.1.5-09`：真实Push Provider/SDK/Key/费用和远端送达仍`PENDING / NOT_RUN`；本轮设备通知权限不是远端Push成功。
- `AC-10.1.5-10`：当前候选普通APK构建/安装/回取字节一致，有限真实API/DB旅程通过；媒体链仍开放。
- `AC-10.1.5-11`：报告/Manifest与脱敏审阅包交付完成，等待Astra本次独立裁决；非作者review不是整版接受。

Gate 2的WinPS执行策略拒绝0.375秒与PowerShell 7/.NET 10 `TypeLoadException` 0.390秒两次启动预算均保持已消费；本次未重试，未运行Writer/Serializer，也未建立新预算。完整37案例suite、条件Sandbox SDK、Producer、`libs.jar`与30项`Configuration.resolve()`均`NOT_RUN`。不得将这些环境阻断标成Writer运行失败或PASS。

## 4. 非作者审查与证据等级

Manifest记录非作者复核为`SUPPORTED_BOUNDED_EVIDENCE_REVIEW`、无未关闭静态发现。其审查范围为报告/Manifest、6份公开材料、允许的结果摘要和3份harness源码；未执行脚本、设备、DB、API、服务或测试，未读取APK/SQL/原始设备日志/凭据/私人媒体。该结论支持报告一致性和脱敏检查，不等同运行复测。

Astra直接观察到的是GitHub源码、报告、Manifest、候选父子关系和文件差异；本地命令/设备状态、APK字节、数据库快照及进程退出属于`CODEX_REPORTED / LOCAL_ONLY`，Manifest提供摘要和Hash但不代表Astra读取了原始文件。报告已保留原始失败与限制，包括构建期间Kotlin增量缓存回退、通知撤权harness首次失败、ICE未建立及旧Gate 2预算。

## 5. 独立裁决

**接受此次USB真机交付中明确列出的有界场景与证据一致性：`V10.1.5_DEVICE_VALIDATION_ACCEPTED_WITH_OBSERVATIONS`。不接受v10.1.5整版。**

整版状态继续：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / HOST_APK_BUILT_INSTALLED_BYTE_VERIFIED / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / REAL_PUSH_PROVIDER_PENDING`。

候选`dad5d8fe36874095c90e25f651775796bfeba7eb`不是main产品集成。Astra不自动合并main、不启动v10.1.6，也不创建微任务。继续沿用唯一综合长任务，在同一任务范围推进与ICE/Writer门无依赖的功能；下一次集中交付时再整体审查。真实SFU媒体与Gate 2相关链仍是核心开放项，必须如实保持。

## 6. 保留的产品Tree与下一步

- 已接受产品：v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 当前v10.1.5候选源码：`c445554f01fbd8c9aef641302f3f090900703786`，Root `a964881253000ed86601978d136dfba5820606fc`；候选apps `e9ed3a1dee4c892840831b0e31f6f96669fa17d5` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。
- 冻结计划不变，Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；唯一综合任务单不变，当前Blob `43b2396b2fba046d5c0ab00bea87293783d1c2fd`。

本次复核不授权新的Gate 2预算、修改系统安全策略、真实Push/生产服务或额外设备操作。