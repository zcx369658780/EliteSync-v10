# EliteSync v10.1.5｜RTC 取消连接与迟到回调竞态｜Astra 独立复核

日期：2026-10-25（Asia/Singapore）

**V10.1.5_RTC_CANCELLATION_RACE_FIX_ACCEPTED_WITH_OBSERVATIONS / AC05_OPEN / CANDIDATE_NOT_MAIN_INTEGRATED**

## 1. 复核范围与证据等级

Astra直接读取GitHub候选源码、RTC与ICE诊断测试、集中报告和artifact manifest，并独立检查关键异步所有权逻辑及测试场景。Astra未在本地执行Flutter测试、未构建/安装当前APK、未连接真实SFU或物理音频设备。本轮测试计数与本地进程结果属于`CODEX_REPORTED / LOCAL_ONLY`，不是Astra直接执行观察。

- 当前main（复核前）：`9b574425d59f00903192ca7a6db450bf6c3af688`；Root `f9c4bb7b35e86282cf4a61fdaedc8638b36d334f`。
- 源码Commit：`67f83b053096b181ff64366f3eaad0e5e44815f8`；唯一Parent `079ea1097788c533a57f5909e1e2348e0cf9e724`；Root `444d558e0ba6912501c3ef94a03b11625d4e89ca`。
- 最终候选Commit：`c445554f01fbd8c9aef641302f3f090900703786`；唯一Parent `67f83b053096b181ff64366f3eaad0e5e44815f8`；Root `a964881253000ed86601978d136dfba5820606fc`。
- 候选apps Tree：`e9ed3a1dee4c892840831b0e31f6f96669fa17d5`；services Tree：`21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。这两棵Tree属于未接受候选，不是main产品Tree。
- 报告Blob：`521b1d5e7851a40e98361887b8fe8117a51c5305`；Manifest Blob：`90a0da0c305016be742d8a131356b368fab10121`。
- RTC服务Blob：`1abe844a83eb6f48e0718ac361778df73127ca00`；RTC服务测试Blob：`e23a875d0a04044c4c0227868b0f46f8e86b5a14`；ICE诊断测试Blob：`6a125584204890209f60716b8264c9f7710d92f6`。
- 冻结plan Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`；当前长任务Blob：`d737c3a813d81ada7a9ca9a60aa310e9e14e0960`。

## 2. 静态实现复核

### 2.1 取消中的凭据请求不能干扰下一次连接

旧的单一`_connecting`布尔状态已改为唯一`_connectionAttempt`对象身份。`ensureConnected`在启动时创建attempt并记录请求时的generation；`leave`会立即撤销所属attempt与pending call，而内部换Room可通过`preserveAttempt`保留当前attempt。旧凭据Future迟到成功/失败后，generation与attempt身份检查阻止旧请求清除或覆盖新attempt状态。旧异常路径只有在仍拥有同一个attempt时才设置failure并清理。

静态检查未发现迟到旧请求仍能通过catch/finally覆盖新attempt的明显路径。新增测试覆盖相同callId与不同callId，以及迟到的不可用结果/错误；测试通过属于Codex报告。

### 2.2 诊断分支迟到endCall不能关闭同call重试

诊断模式`endCall`的finally在调用`leave`前核对当前`_connectionAttempt`仍是发起该结束请求的attempt。已取消的旧诊断调用不会因迟到成功或失败而关闭新建的同call Room。测试分别覆盖迟到成功和迟到异常。

### 2.3 旧heartbeat不能影响新连接

`_sendHeartbeat`捕获开始时的connection generation与Room身份，并以`disposed`、generation、Room identity和callId组成`current()`谓词。heartbeat成功、错误处理及finally的`_heartbeatInFlight`清理均先验证该请求仍属于当前连接。迟到旧heartbeat的terminal响应或异常不能触发新连接的leave，也不能清理新连接的in-flight状态。

测试覆盖旧heartbeat的terminal与error两种迟到结果，且同call retry场景被明确构造。此处结论为源码静态逻辑成立，配合Codex报告的定向单测支持；不是实际网络heartbeat或SFU媒体证明。

## 3. 测试与静态分析结果

按正式报告/Manifest中的`CODEX_REPORTED / NEW_RUN / UNIT_ONLY_NO_DEVICE_SFU`记录：

| 检查 | 报告结果 | Astra解释 |
|---|---|---|
| RTC与路由普通测试 | 95通过，exit 0 | 定向软件回归支持通过；本地原始stdout尚未由Astra直接读取。 |
| ICE诊断编译开关测试 | 11通过，exit 0 | 包含4项与普通测试重叠的基础案例，不能与95简单相加为106个独立案例。 |
| 三个Dart文件分析 | `No issues found`，exit 0 | 报告绑定了对应源码Hash。 |
| Red/Green回归 | 凭据取消、迟到end、旧heartbeat均先出现预期RED，再经修复GREEN | 支持测试能检测相应竞态；仍属Codex报告的运行证据。 |

源码与测试在GitHub候选中的Blob已独立核验。Manifest记录执行工作树SHA与Git规范化内容的差异仅为行尾规范化。当前候选尚未重新构建/安装APK。

## 4. 未关闭的v10.1.5功能门禁

**AC-10.1.5-05仍为`PARTIAL_CORE_OPEN`，整版仍`PARTIAL / AC05_OPEN`。** 以下证据未被本次单测覆盖：

- 双APP真实SFU流动音视频；
- 同call真实重连及旧RTC JWT首次重新入房拒绝；
- 撤权后流动媒体在5秒内停止；
- 物理设备AEC/音频质量；
- 当前候选源码构建并安装新APK后的真实旅程。

Gate 2的Writer/Serializer定点正负例仍`NOT_RUN`，原两次启动阻断和已消费预算保持；完整37案例suite、条件式Sandbox SDK、Producer、`libs.jar`与30项`Configuration.resolve()`均`NOT_RUN`。本次RTC竞态修复不解决或重置这些门禁。

## 5. 独立裁决

**接受范围限定的RTC取消/迟到回调竞态修复：`V10.1.5_RTC_CANCELLATION_RACE_FIX_ACCEPTED_WITH_OBSERVATIONS`。** 此裁决仅接受候选中的源码逻辑与定向单测证据，不是整版功能接受，不是APK/SFU/物理设备接受，不是产品main集成授权。

候选仍未合并main；接受产品仍v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。v10.1.5保持`PARTIAL_NOT_ACCEPTED`，AC05保持`OPEN`，v10.1.6未启动。

本次不创建微任务或下一版本任务。Codex应继续当前已授权v10.1.5综合长任务，在同一任务范围内推进与Gate 2无依赖的工作，并在整版集中交付后由Astra验收。