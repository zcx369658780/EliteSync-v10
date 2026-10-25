# EliteSync v10.1.5｜R1 同版本集中返修｜Astra 独立复核

日期：2026-10-25（Asia/Singapore）

**R1_BOUNDED_REPAIR_ACCEPTED_WITH_OBSERVATIONS / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_PRODUCT_MAIN_INTEGRATION**

## 1. 裁决范围与证据等级

Astra直接读取GitHub候选 Commit 元数据、候选 Root Tree、与源码父提交的比较结果、当前实施报告、Manifest、冻结计划、R1源/测试差异及十件脱敏审阅材料。Astra没有运行本地 Flutter/Dart 测试、没有构建/安装 APK、没有操作手机、没有读取原始 LOCAL_ONLY 日志或 `C:/Users/zcxve/.codex/.../final-readback.json`。测试、APK、UIAutomator、RTP、native日志和数据库结果属于 `CODEX_REPORTED / DEVICE_NEW_RUN / LOCAL_ONLY`；本复核独立核验远端源码和公开脱敏证据，不把Codex执行伪称为Astra亲自运行。

## 2. 实时身份与远端回读

- 本次复核时 live main：`4df2e7f0f36cc7b80258faa73e80dad682cff6c5`，Root `03b0ecfcc360e38a462539dd50690c64b663a21e`。
- R1交付候选：`d45cd08f939f6dfc6b4efe2420f4a117efc99e68`，唯一Parent `e7cbbe6030b033c5c9244c599bd42fcff312a8c6`，Root `9a2997eacbbc386f48d2a2dc259221a2319997dd`。
- R1源码Commit：`e7cbbe6030b033c5c9244c599bd42fcff312a8c6`，唯一Parent `7773b98986d9c9395841623e6ef244379fddc865`，Root `3871583648176b69a2d0ebb1053b23a07770fec5`。
- 候选 apps Tree `0581a5286300d8c39fd7ffaf3dce37af0257419e`；services Tree `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。直接比较确认它们与源码父提交的对应子树一致；R1交付候选相对源码提交只改报告与Manifest，不改变产品源码。
- 实施报告 Blob：`741ebb72c7f42cf9f0463d6b406e6485798716e3`；Manifest Blob：`36ba70056e2d46371aceb66ec8cc16935ede1156`；冻结计划 Blob仍为 `7d3466b3be67135dc641cfee7c7faef78937ba03`。
- 完整 Root Tree 递归回读为6614项且未截断。产品接受基线仍为v10.1.4：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。未把候选子树冒充产品main。
- 源码差异只有 `rtc_livekit_service.dart` 增加三行等待逻辑及其对应测试增加两个回归用例；没有改变LiveKit vendor、后端、token、consent或WebSocket Upgrade源码。

## 3. R1代码与回归裁决

R1修复的缺陷是：首个leave已将Room从服务对象分离、正在等待native清理时，重复的带callId leave因call身份不再匹配而提前返回，可能让调用方误以为清理已完成。

新逻辑在该call-scoped早退分支等待现有 `_roomTeardown`，不重复改变连接代际或触碰新Room。新增成功和dispose失败两例在原实现均产生预期RED；修复后22项RTC service测试、27项关联页面测试和两个修改Dart文件的定向分析均由Codex报告通过。失败情形也验证清理失败后不请求新join凭据。

Astra静态读取新增测试与实际差异，未发现明显的新阻断问题。该结论仅接受此项源码修复及有界回归证据，不代表Astra亲自执行测试，也不重新接受整个RTC SDK或v10.1.5。

## 4. 撤权停止时序：有界接受

R1新call的计时采用单一主机单调时钟：GO发送发生在真实撤权transition之前，bootstrap被READY屏障排除；之后以同一手机PID的新事件及日志读取回执为终点，不相减手机/服务端时钟。COMMIT没有精确时间戳，只被GO之后0至0.062秒的回执区间所约束。

公开脱敏记录显示，renderer cancel在GO后0.312秒，PeerConnection关闭、AudioRecord/AudioTrack停止和camera release在0.625秒内，disconnect/Room.dispose/leave完成在0.875秒内可见。GetTickCount64分辨率15.625ms，加两端31.25ms量化余量，得到保守上界0.90625秒。

该推理可支持本次指定的native/lifecycle端点在撤权后5秒内被观察到；它不是精确COMMIT时间测量，也不证明最后可闻波形停止、AEC、完整native handle清点、所有设备或所有平台。camera close code4/5和trackDispose-null警告仍在限定窗口中出现，必须保留。**有界native停止时序接受，不等于AC05关闭。**

## 5. 通知旧卡片：有界接受

本轮通知源代码未改变，测试在此前APK `68e9bc37c785976713a7fbe0d18f82c1dcde0d1bbfe2641e26558e71f8cb2717` 上进行，不能称为新APK的完整通知旅程。

脱敏证据支持：真实服务端撤权后，对仍可见的通知控件执行了Android可访问性 `ACTION_CLICK`；出现阻断会话反馈，通知中心未显示合成私密正文，通知/消息/会话已读事实保持不变。未声称物理触屏，也没有单独记录HTTP状态，因此不得宣称点击响应明确为403。该证据支持失效卡片未打开私密内容这一有界结果。

## 6. 构建偏差与证据限制

首次构建的内层Gradle wrapper尝试下载Gradle，任务进程将其终止；7,941,328字节partial及Hash被保留。不得将整个过程描述为全程无下载或无网络。随后Codex在任务自有ignored构建副本内改用字节核验过的本地Gradle 8.14，修正构建exit0，最终APK SHA256 `30ca72ab1e53c55ff324ee2763d84ceab7867a7c54617e5b76bcbaa83c966a12` 与安装回取Hash一致。该偏差已公开记录，作为流程观察保留；不抹除原失败，也不把修正构建冒充首次构建成功。Astra未直接读取本地partial文件，只核验其脱敏Hash记录。

十件审阅材料的Blob与SHA256清单已从GitHub读取；它们是脱敏证据摘要，不是原始设备证据。资源关闭和保护核验仍属于Codex/LOCAL_ONLY报告。SFU退出码1与数据库退出码0分别保留，不称所有子进程均成功退出。

## 7. AC-01～11当前结论

| AC | Astra裁决 |
|---|---|
| AC-01 | `SUPPORTED_BOUNDED_PROTECTION`，具名保护对象和产品子树身份有界支持，不是整盘审计 |
| AC-02 | 复用原接受证据；本轮没有重跑完整消息可靠性旅程 |
| AC-03 | 本轮native停止端点有界支持；成功媒体旧token首次重入403沿用前次独立接受身份 |
| AC-04 | 复用原接受身份；本轮未重跑完整图片/视频/Range旅程 |
| AC-05 | `PARTIAL / OPEN`；新增重复leave修复和指定native停止时序有界接受，AEC、最后可闻波形及全量native资源释放未证明 |
| AC-06 | `WAITING_ELAPSED_TIME / NOT_RUN`；真实15/30天未完成 |
| AC-07 | `WAITING_ELAPSED_TIME / NOT_RUN`；真实离线期限与物理30天清理未完成 |
| AC-08 | 有界接受实际可见失效卡片的可访问性点击结果；不宣称物理点击或HTTP 403 |
| AC-09 | 真实Push Provider仍 `PENDING / NOT_RUN` |
| AC-10 | R1定向测试、构建/安装身份有界支持；首次Gradle下载尝试作为流程偏差保留 |
| AC-11 | 候选身份、报告/Manifest、Root Tree和源码差异已独立核验；交付后停止，无产品main集成 |

## 8. 最终裁决与禁止事项

**接受R1的有界返修结果：** `V10.1.5_R1_BOUNDED_REPAIR_ACCEPTED_WITH_OBSERVATIONS`。

**整版仍为：** `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / REAL_PUSH_PROVIDER_PENDING`。

真实AEC/语音质量、最后可闻波形停止、15/30天真实经过与物理清理、真实Push、Gate2完整条件链仍未闭合。Gate2两次历史启动预算均已消费；本轮新Gate2启动、Writer和Serializer调用为0。37案例suite、条件Sandbox SDK、Producer、`libs.jar`和30项`Configuration.resolve`继续`NOT_RUN`。

不合并产品main、不启动v10.1.6、不创建后继任务、不授权Gate2、不接入真实Push/生产服务、不清理历史备份/旧refs/SQL/APK/LOCAL_ONLY证据。等待Owner明确下一步。
