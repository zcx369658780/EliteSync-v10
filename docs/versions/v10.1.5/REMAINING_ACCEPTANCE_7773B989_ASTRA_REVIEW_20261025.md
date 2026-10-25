# EliteSync v10.1.5｜剩余验收综合交付｜Astra 独立复核

日期：2026-10-25（Asia/Singapore）

**V10.1.5_REMAINING_ACCEPTANCE_ACCEPTED_WITH_OBSERVATIONS / AC05_OPEN / PARTIAL_NOT_ACCEPTED / GATE2_NOT_RUN / PRODUCT_MAIN_NOT_INTEGRATED**

## 1. 复核范围与证据等级

Astra直接读取GitHub候选中的最终实施报告、Manifest、RTC service、PCM cleanup/failure/Room disposal测试、音频指标与频谱widget测试、应用自有LiveKit runtime的room.dart/track.dart/local.dart及SDK内publication清理测试，并核验候选Commit、父子关系、完整apps/services Tree和冻结计划/任务身份。Astra未在本地运行Flutter测试、未构建/安装APK、未访问USB设备或读取LOCAL_ONLY原始日志、APK、SQL及音视频。运行结果均为CODEX_REPORTED；设备结果为CODEX_REPORTED / DEVICE_NEW_RUN / SYNTHETIC_ONLY，不伪称Astra直接执行。

- 最终候选Commit：`7773b98986d9c9395841623e6ef244379fddc865`。
- 唯一Parent：`a25e7c1012bce3f2a2d7048f284f17ebd8a0915c`；候选Root：`fcef280b0f07bb047f8f57b3c5490e8beee7d29d`。
- 源码Commit：`a25e7c1012bce3f2a2d7048f284f17ebd8a0915c`；唯一Parent：`1a3a9ff9daa315fe5e688f6f0aab8e378e1db97c`；源码Root：`21243e8f60dccae5106d9d04bd739ef587d05646`。
- 候选apps Tree：`db3a2936ee37bf9610053fb8fd67b360fc377a94`（递归1,510项，未截断）；services Tree：`21eebf69bbc6397b1562d40f8cd9ebd7b246720f`（递归792项，未截断）。这是未接受候选树，不是产品main树。
- 报告Blob：`8c7184384be6c8f8fef76b9c27df9385131de304`；Manifest Blob：`bb8f5023f102b38268ed78e1821a7aa02362cb36`。
- 关键Blob：RTC service `ba497a929a9903eb269aae81ddf31a5c102af07c`；PCM cleanup tests `63139d34f53450f943b024806d506d9b1d3143e5`；PCM failure tests `dfb60ac1d59cf573215760487487232924466537`；Room disposal tests `9fd94eda52ca77831881a6632359f23709157706`；vendor room `03a8afdfb37fad70ec6dc09bc96b30a8155d8ce7`；vendor local `591eb355d45dde0a46ca0c6c8ded8d1b8149c750`；vendor track `25fb811bd84c25be08dab15077e003952f7e124a`；vendor publication cleanup test `42e56970e90feab14e6ed624e4db0b98ed31a479`。
- 冻结计划Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`；本次综合长任务Blob：`fec31d6318524a40b9ff8f0dab49b60aa7fa3490`；原综合task_order（含F/G）Blob：`43b2396b2fba046d5c0ab00bea87293783d1c2fd`。
- 任务开始时live main：`36593e0b5082602f2060fae94d7e88894a1193f4` / Root `84751dbee1ebe9c89021084d1a7691560b3ab007`。这是历史起点，不冒充本次写入后的main。

候选相对源码起点`1a3a9ff9...`前进两个普通提交；源码提交修改RTC service、频谱指标/widget、应用依赖锁、LiveKit vendor runtime与相关测试，最终候选仅追加实施报告和Manifest。后端services Tree未改变。

## 2. PCM capture与Room清理修复

静态审查确认：capture group先取快照并在await前清空共享Map；旧renderer cancel仅在仍拥有对应group时才移除Map条目；group stop使用共享Future；track级stop等待先前清理并记住native stop错误；track dispose在调用基类dispose前等待capture清理并传播失败。disposing/disposed或已有持久stop错误时拒绝新增renderer。

Room使用memoized dispose Future，使并发/重复调用共享同一完成或失败结果。清理步骤逐项尝试并保存失败；publication/track链中的PCM错误不会仅因通用Disposable best-effort处理而被误报为Room成功。RTC service结束时等待renderer cancel、Room disconnect和Room dispose，记录完成/失败；清理失败不伪装为leave成功，也不直接启动下一次join。

Codex报告修复后最终67项相关Flutter检查exit0（6.078秒），另17项ICE guard检查exit0（3.438秒），Dart analyzer exit0，0 errors/0 warnings，19条既有上游style info未变化。67项包括PCM、native stop failure、Room disposal、publication和关联RTC/UI/spectrum。Astra直接检查源码与测试实现，未发现新的静态阻断问题；未在本地重跑测试。受控native transport/Engine边界测试不等于所有平台native故障恢复或所有handle全量清点。

## 3. 真机证据：逐场景接受，不拼接失败旅程

最终开发APK为`com.elitesync.v1015r1dev`，versionCode `1010511`，versionName `10.1.5-r1-dev`。Codex报告构建与安装回取SHA256均为`68e9bc37c785976713a7fbe0d18f82c1dcde0d1bbfe2641e26558e71f8cb2717`，签名一致、数据保留。设备为Owner授权的Xiaomi Android 16/API 36/arm64-v8a手机；序列号与原始证据保持LOCAL_ONLY。

| 场景 | Astra裁决 | 限制 |
|---|---|---|
| call3麦克风/摄像头启停与前后台 | `ACCEPTED_BOUNDED_CONTROL_EVIDENCE` | 合成PC对端观察到off/on及后台muted、恢复后unmuted；整段脚本因重连按钮仅露12px而exit1，finally通过真实API结束。整段不记PASS，也不与其他call拼接。 |
| call4同call手动重连与真实UI挂断 | `ACCEPTED_BOUNDED_DEVICE_MEDIA_AND_UI_HANGUP` | 脚本exit0；同call重新读取join并建立新轨道，约24秒四方向RTP增长，入站视频解码94→574。实际UI挂断后出现新的renderer cancel、disconnect、Room dispose及leave完成事件。对端为合成PC SDK，不是双物理手机体验。 |
| call5清理后再次连接 | `ACCEPTED_BOUNDED_FOLLOWUP_MEDIA` | 新call真实双向RTP增长、视频解码89→169；证明此前清理后可建立新媒体，不证明所有平台无泄漏。 |
| 成功媒体token撤权后首次重新入房 | `ACCEPTED_BOUNDED_OLD_TOKEN_REENTRY_REJECTION` | call5使用实际成功媒体会话、仍未过期的同一token；撤权后仅一次真实guarded WebSocket Upgrade尝试返回403，没有mint新token。证明新请求被拒，不等于旧媒体已在5秒内停止。 |
| 撤权后的媒体停止时间 | `NO_NEW_5_SECOND_PASS` | 本轮host保守观察上界10.125秒，包含约9.750秒进程启动/服务调用；native/server跨时钟仅作佐证。此前已接受的0.790秒上界仅作为旧身份复用。 |
| 有限合成信号 | `LIMITED_SYNTHETIC_SIGNAL_OBSERVATION_ONLY` | 本地20份、远端19份440/880Hz与幅值派生指标，不保存PCM。硬件处理请求为false、引擎已初始化、有效AEC模式未验证；无AEC on/off对照、声学标定、真实双人语音可懂度或最后可闻波形计时。 |

限定日志窗口中未见`ConcurrentModificationError`、`Unhandled Exception`、`PlatformException`、`MediaConnectException`或`StateError`字符串；同时仍观察到camera close code 4/5和track dispose时track null警告。该窗口支持局部稳定性改善，不证明所有设备/平台无异常，也不等同native PCM handle全量普查。

## 4. AC-10.1.5-01～11边界

- AC01：受控保护清单、fresh authority与独立空库有界支持，不是整盘审计。
- AC02：消息可靠性沿用此前已接受证据；本轮新合成消息写入/重启读回有界支持，不是全量文字重试旅程。
- AC03：本轮成功媒体token首次撤权后WebSocket Upgrade 403有界接受；新媒体停止<=5秒未证明。
- AC04：图片/视频/Range/撤权证据按原APK身份复用；本轮未重跑最终APK完整picker/player旅程。
- AC05：`PARTIAL_AC05_OPEN_TARGETED_CLEANUP_AND_DEVICE_SUPPORTED`。PCM/Room清理、同call重连、真实UI挂断及token重入拒绝获得支持，但AEC、客观波形、所有native资源路径与5秒停止合同未闭合。
- AC06：真实T0/refresh边界按原身份复用；实际经过15/30天未运行。
- AC07：冷启动锁定有新设备证据；物理离线15～30天及实际经过30天清理未运行，保持`WAITING_ELAPSED_TIME`。
- AC08：通知通用文案和撤权后当前权威卡片移除有界支持；实际旧卡片点击未运行，OS权限/偏好有旧接受证据。
- AC09：`REAL_PUSH_PROVIDER_PENDING`；无真实供应商、凭据或外部送达。
- AC10：67项相关Flutter检查、17项ICE guard、Dart分析、APK身份和12表重启快照有界支持；后端检查复用，Gate 2链未运行。
- AC11：报告/Manifest、脱敏审阅包与远端身份回读已集中交付；本次Astra裁决不代表整版接受。

## 5. Gate 2、保护资产与未关闭项

WinPS执行策略拒绝0.375秒与PowerShell 7 TypeLoadException启动失败0.390秒两次历史预算均已消费。本轮新Gate 2预算/启动/Writer/Serializer调用均为0。完整37案例suite、条件Sandbox SDK、Producer、libs.jar与30项Configuration.resolve仍`NOT_RUN`。本任务只授权只读分析，不授权新的Gate 2运行预算。

真实Push Provider未授权；实际经过15/30天的离线期限与物理30天清理仍`WAITING_ELAPSED_TIME`。旧guest/HCS状态与ICE诊断旗标仍未知/未证明。AEC、客观波形停止时间、真实语音质量、native PCM handle全量清点、所有平台故障恢复仍未闭合。

## 6. 独立裁决

**接受本轮剩余验收任务中有证据支持的PCM/Room清理修复、受影响回归、call4真实UI挂断与同call重连、call5清理后新媒体连接，以及成功媒体token撤权后首次重新入房403：`V10.1.5_REMAINING_ACCEPTANCE_ACCEPTED_WITH_OBSERVATIONS`。** call3整体失败、10.125秒撤权观察、AEC和期限测试均按上述限制保留，不提升为PASS。

整版仍为`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / REAL_PUSH_PROVIDER_PENDING`。候选未合并产品main；已接受产品仍v10.1.4，apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。

本次复核不自动创建下一任务、不放行Gate 2、不合并main、不启动v10.1.6。后续任务须由Owner明确要求并按A-D发布闭环执行。