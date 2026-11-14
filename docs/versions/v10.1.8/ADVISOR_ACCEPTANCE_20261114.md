# v10.1.8 顾问验收：五项范围接受，通话项需补修

日期：2026-11-14（北京时间）。固定交付：`35a415803f0034fff15450b129a68de762b3a3bb`。任务发布基线：`fda6d3db4e5fe25167bece23e2773ad46f68e5ab`。

## 一、结论

**顾问结论：CHANGES_REQUIRED / PARTIAL。AC18-01、02、03、05、06 在约定开发范围内接受；AC18-04 保持 PARTIAL。**

本轮支持工程报告“5项PASS、通话项PARTIAL”的划分，未发现需要额外重开另外五项的阻断缺陷。唯一补修为 [R1-01：定位并补齐16→17通话音频](supplement-r1-20261114/task_order.md)，接续指令见 [prompt](supplement-r1-20261114/CODEX_START_PROMPT.txt)。版本尚未全部通过，Owner最终接受仍为PENDING，不进入v10.1.9。

这是一轮固定Git源码、任务标准、测试设计、去敏报告和身份核对。顾问未访问Owner本机、未重跑其Flutter/PHP测试、未试听原始音频或操作设备；本机运行、安装和部署等事实按Codex具名报告限定接受。没有重新分析旧拆解原证。

## 二、交付身份与核对结果

| 项目 | 固定身份及判断 |
|---|---|
| 仓库与分支 | `zcx369658780/EliteSync-v10`；`codex/v10.1.8-communication-notifications-20261113` |
| APP构建源码 | `18491f2a65717c52300897ff6ffebfdf010c91dc` |
| 后端最近产品修改 | `e22b0c95c2358672a8f81a9b6d6d0dd07f36830d` |
| 候选 | `10.1.8-dev / 1010805 / com.elitesync.v1015dev`；source Debug；arm64-v8a |
| APK | 123802554字节；SHA256 `2a65f9cf022c3d66cdb116662e3aca15f3dc9869130ca4365c14d017b70155ed`；签名及双端安装同一性沿具名本机回执 |
| 报告身份 | IMPLEMENTATION_REPORT的SHA256为`0fd3166254b87b8dec17add460810c82fcff2125242ec02d32c72d01a61362fb`，与manifest一致 |
| 最终摘要身份 | FINAL_EVIDENCE的SHA256为`2b87c77a670bc49a507c1b46c0163fb49dad58c36f7e9a8df9ae061cd8c71eb7`，与manifest一致 |
| 源码身份 | FINAL声明的32个改动组件及2个RTC服务文件，逐一计算SHA256与Git Blob并核对固定提交树，全部一致 |

APP源码到交付提交只改变文档与`.gitattributes`，无产品源码变化。后端最近产品修改到APP构建提交的后端产品源未变。1010804到1010805的产品差异为候选版本与会话详情接线，语音及RTC组件未变；此前文字/引用、图片/短视频/语音证据按具名组件范围继承，通知回流修复在1010805重新验证。

源文件的Git哈希由顾问独立核对；“实际容器字节相等”和“APP构建输入LF等价”是Codex本机报告，不能写成顾问直接读取。MainActivity在Git中本身含CRLF，本次按实际字节核对，没有先归一换行后误报差异。原任务的六项完成标准未被降低，plan变更仅更新交付状态。

## 三、逐项验收

| AC | 顾问结论 | 主要依据与范围 |
|---|---|---|
| **AC18-01** | **范围接受** | 当前真实会话、原子消息及附件持久化保持同一合同；结果未确认时保留原消息编号与载荷。消息132一次提交后丢失响应、同号重试仍为一消息一通知，普通文字/图片/短视频沿具名候选继承。 |
| **AC18-02** | **范围接受** | GET/搜索及本人发送不清入站未读；未读以本人入站is_read事实计算。前台显式ACK、首次read_at、混入无权ID拒绝、200扫描/20命中的实际cursor、同会话引用及指纹兼容均有实现和定向正反例。 |
| **AC18-03** | **范围接受：软件与双模拟器** | AAC-LC/M4A真实录制、预览、明确发送与对端播放链已具名提供。原生59900ms限时为60秒合同留出容器余量；后端校验真实格式、时长和完整解码。取消/后台/撤权、私密Range及录放与RTC互斥有对应实现和证据；人工听感及实机硬件不在本次接受内。 |
| **AC18-04** | **PARTIAL，R1-01 OPEN** | 当前SFU运行、双向视频、17→16受控音频、一次服务故障后新通话和新撤权停媒可作为有效进展；16→17仍未检出，不能判双向音频完成。 |
| **AC18-05** | **范围接受** | 消息/提案/CN/MC/审核/通话通知沿真实业务事务与稳定来源唯一约束生产，MC双purpose仅一次提醒。通知277、274、303在1010805回流聊天、本人审核和只读通话结果；当前目标、失效/他人ID、分类与静默偏好、账号隔离边界成立。真实Push仍PENDING。 |
| **AC18-06** | **交付与持久化范围接受** | 同组消息/通知/首次已读/偏好/publication重登及DB/API/WS重启读回沿具名证据；源码/报告/候选身份可对应。接受其交付真实性与保留限制，不等于接受整版通信功能。 |

通知回流修复仅解除真实开发路径被旧synthetic本地门误挡，仍由当前后端详情授权，并保留当前账号、权限epoch及会话身份校验。没有将客户端门取消解释为无需后端授权。

新后端选择集可从测试源码展开为9项ChatSemantics、3项Audio、15项NotificationEvents，共27项；420断言及运行通过为Codex回执。34项Flutter与声明选择集相符。旧55项/632断言与182项Flutter按各自范围保留，存在重叠，不相加为本轮新测试数。

## 四、唯一未关闭的功能缺口

### R1-01：16→17实际通话音频未检出

call57、59和服务重启/重登后的61均未检出16→17受控音调；call57、59的17→16可检出，call59双端视频解码累计帧为532、392。16端独立语音留言录制与预览通过，只证明该留言路径及当时工具可用，不能确定RTC采集、处理、传输、播放或探针中的断点。

现有RTC代码已有按call/track关联的本地PCM幅度、出/入站RTP以及接收音频能量观测。R1先使用call57/59/61现有原证对应同窗各段；不足时才增加一组具名短窗，保留17→16为对照。随后依据最小已证实断点修复并验证双向实际媒体。不得仅凭RTP计数、连接状态、另一条留言录音或安全退出关闭本项。

历史非注入SFU超时的精确根因继续单列UNKNOWN。它不是这次16→17音频缺口的已证实原因，也不是无限等待复现的前置任务。

## 五、已经完成的RTC子证据及保留边界

- call58一次具名SFU重启后，明确结束旧通话并建立新合法call59；恢复连接、双向视频及17→16音频可按原范围保留。旧call58结束后的原生停止样本未单独保存，报告已纠正曾在新call59启动后采样的字段含义，不能将该字段当旧call58独立停采证据。
- call59的授权提交区间为`[174446.765, 174446.812]`；每端点时钟tick为0.015625秒，两端点余量合计0.03125秒。全局保守停止上界可独立复算为`174448.093 - 174446.765 + 0.03125 = 1.35925秒`，距既有5秒限值余量为3.64075秒。
- 新尾窗保守下界申报5.31275秒，每端34个AppOps样本，首次inactive后的样本均inactive。摘要未列最后样本原始端点，因此尾窗长度按Codex具名计算报告限定接受，不声称顾问已经独立复算全部尾窗；R1报告补列现有原证端点与公式即可，不为此单独重跑。
- AppOps为离散软件观测，不扩大为连续实机硬件追踪；旧call51记录不改写。当前修改未影响的恢复/撤权证据可以继承，若R1改变音频、重连或生命周期，再按实际影响补最短验证。
- 真实Push为`REAL_PUSH_PROVIDER_PENDING`，人工听感NOT_RUN，实机硬件UNVERIFIED，自然长期限沿既有范围保留。

## 六、下一步与资源

按[R1任务](supplement-r1-20261114/task_order.md)在原稳定根和本版分支继续。仅处理实际通话音频缺口及直接受影响验证；其余五项不重做全量验收。完成后更新单一补充结果、候选身份和必要去敏摘要，保存同步后停下供复核。

最近具名资源快照仍为2026-11-14 08:13:57.502238北京时间：DB/API/WS/SFU运行、Room0，双APP和双模拟器已停止，测试用户11/12、AVD与数据库保留，手机NOT_RUN。此为工程交付时快照，顾问本轮没有读取实时本机资源。

## 固定来源

- [工程实施报告](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/docs/versions/v10.1.8/IMPLEMENTATION_REPORT.md)、[交付manifest](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/docs/versions/v10.1.8/artifact_manifest.json)、[最终证据摘要](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/docs/versions/v10.1.8/FINAL_EVIDENCE_20261114.json)。
- [语音摘要](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/docs/versions/v10.1.8/VOICE_EVIDENCE_20261114.json)、[同编号重试摘要](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/docs/versions/v10.1.8/RETRY_EVIDENCE_20261114.json)、[本版计划](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/docs/versions/v10.1.8/plan.md)。
- [消息Controller](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/services/backend-laravel/app/Http/Controllers/Api/V1/MessageController.php)、[原子发送](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/services/backend-laravel/app/Services/ConversationAtomicSendService.php)、[通知服务](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/services/backend-laravel/app/Services/NotificationService.php)、[音频验证](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/services/backend-laravel/app/Services/PrivateAudioValidator.php)。
- [APP会话详情](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/apps/flutter_elitesync_module/lib/features/chat/presentation/providers/chat_providers.dart)、[原生语音](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/apps/android/app/src/main/java/com/elitesync/NativeVoiceMemo.kt)、[RTC观测与生命周期](https://github.com/zcx369658780/EliteSync-v10/blob/35a415803f0034fff15450b129a68de762b3a3bb/apps/flutter_elitesync_module/lib/features/rtc/domain/services/rtc_livekit_service.dart)。
