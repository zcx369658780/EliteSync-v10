# EliteSync v10.1.5 — R1 集中返修与候选交付任务单

状态：OWNER_ACCEPTED_REPAIR_DIRECTION / READY_FOR_MANUAL_CODEX_DISPATCH / PLAN_FROZEN / NO_GATE2_AUTHORIZATION / NO_PRODUCT_MAIN_INTEGRATION
日期：2026-10-25（Asia/Singapore）
Owner：最终产品方向和不可逆决策 authority
执行者：Codex，仅在 Owner 手动派发后执行
独立验收：Astra

## 0. 任务性质

这是 v10.1.5 同版本集中返修，不是 v10.1.6，不是重新执行已完成的综合任务，也不是产品 main 集成。

Owner 已接受 Astra 对候选 `7773b98986d9c9395841623e6ef244379fddc865` 的裁决：`CHANGES_REQUIRED / PARTIAL_NOT_ACCEPTED / AC05_OPEN`。目标是在冻结合同与既有授权内，修复可修复缺陷、对受影响路径重测并发布普通候选，等待 Astra 集中独立验收。

继续执行长期工作流：一份冻结计划、一份综合任务、中途无监督执行、一次集中交付和独立验收。Codex 可在授权范围内自主调查、实现、测试、修复普通失败并重测；不拆微任务、不逐步骤等待 Owner 审批。

本任务不授权产品 main 集成、Gate 2 新运行、真实 Push Provider、生产服务、额外设备、系统/全局安全策略变更或新增费用。

## 1. 开工前恢复实时状态

仓库：`zcx369658780/EliteSync-v10`

重新读取 `ACTIVE_STATE.md`、冻结 `plan.md`、原剩余验收长任务、最新 `IMPLEMENTATION_REPORT.md`、`artifact_manifest.json`、本任务单及既有 Astra 局部接受记录。重新核验 live main/Root、候选 Commit/Parent/Root、报告/Manifest Blob、源码 Commit 与 apps/services Tree。不得把历史 SHA 当作实时 HEAD，不得 reset、覆盖或强推。

冻结计划 Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`。已接受产品仍为 v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。候选树不得冒充产品 main。

## 2. 第一优先级：AC-10.1.5-05 RTC 清理、撤权与时序

### 2.1 PCM/Room 清理错误路径

复核并按需修复 renderer cancel、capture start/stop 交错、重复清理、track dispose、Room.dispose 并发等待和错误传播、disconnect 失败后继续必要清理，以及清理失败后禁止伪报成功或直接开始下一次连接。

保留应用自有 LiveKit 2.10.0 runtime 的来源、LICENSE、NOTICE、上游 Hash 清单与最小 patch。不得吞异常、降低断言或屏蔽测试。仅对本次改变路径执行定向回归及必要关联测试和 Dart 分析；保留原始 RED、退出码和日志 Hash，不无谓重跑无关旅程。

### 2.2 撤权后媒体停止时限

当前保守观察上界是 10.125 秒，不能宣称新的 5 秒 PASS。调查服务端撤权实际提交时点、客户端清理启动、PeerConnection 关闭、AudioRecord/AudioTrack 停止、camera release、Room.dispose 与 leave 完成时点。

优先使用同一单调时钟；跨时钟关联必须有可核验的误差界。不得把 HTTP 调用开始、进程启动、服务端返回或未经同步的日志差值当作精确提交时点。只在现有授权手机、合成 PC 对端和受控测试服务可用时做最小验证，不扩展设备、不收集私人音视频、不下载工具或改系统设置。

只有时序与测量边界充分支持撤权后 5 秒内停止，才可 PASS；否则保留 `NOT_PROVEN`，报告缺失观测点。

### 2.3 成功媒体 token 与 AEC

复核 call5 是否绑定于撤权前真正建立媒体的成功会话、SDK 实际使用的旧 token、撤权后首次重新入房请求和真实 WebSocket Upgrade 拒绝。区分新入房请求被拒与既有媒体停止；证据身份完整且源码未变时可复用。

明确区分音频配置请求、实际处理模式、合成信号与真实语音质量。现有 `hardwareProcessingRequested=false`、`engineWasAlreadyInitialized=true`、`effectiveMode=unverified` 不构成 AEC 通过。只有现有授权设备和条件可用时才做有界观察；否则保留 `NOT_PROVEN`。不得采集/上传私人语音或用单次主观听感冒充完整声学实验。

## 3. 第二优先级：AC-10.1.5-08 通知旧卡片点击

当前卡片在第二次权威快照前已消失，旧卡片实际点击为 `NOT_RUN`。在合成账号/消息上建立真实通知并确认卡片身份；经真实服务端路径撤权；在不绕过授权检查的前提下，验证仍可见的失效通知点击行为。确认旧路由不展示已撤权私密内容，且消息、通知、会话已读状态无不当变化。

若卡片及时消失而无法点击，保留 `NOT_RUN` 并说明缺口。不得伪造 UI 点击、削弱权限检查或修改系统安全设置。复用未受影响的通知文案、偏好和系统权限证据。

## 4. 时间、Gate 2 与其他 AC

- 真实经过 15/30 天与物理 30 天清理继续 `WAITING_ELAPSED_TIME / NOT_RUN`，除非自然时间已过且有新证据。受控时钟/单测不能冒充真实经过时间；不得改系统时钟或压缩时间伪造 PASS。
- Gate 2 无新运行授权。WinPS 策略拒绝 0.375 秒、PS7/.NET TypeLoadException 启动失败 0.390 秒两次预算已消费；D0-A 历史 15 次 Serialize、约 0.688 秒不得重跑。不得启动 Gate 2、调用 Writer/Serializer、使用 Bypass、修改策略、复制 Framework DLL 到 Core、替换 Serializer 或尝试未授权入口。37 案例 suite、条件 Sandbox SDK、Producer、`libs.jar`、30 项 `Configuration.resolve` 保持 `NOT_RUN`。
- 真实 Push Provider、供应商 SDK/密钥/费用、生产服务、公网部署和真实用户均未获新授权，不得接入或采购；真实 Push 继续 `PENDING / NOT_RUN`。
- 逐项对照冻结 AC-01～11。复用未受影响且身份完整的接受证据；区分本轮新运行、历史复用、静态源码证据、Codex 报告和 LOCAL_ONLY 原证。核心软件缺陷不得被归类成外部门禁。

## 5. 执行与保护

仅使用既有授权本地代码树、开发工具、原授权 Android 测试机、合成账号/媒体和现有受控测试服务。不读取或上传私人图库、短信、通讯录、私人音视频、凭据、SQL 原件或 LOCAL_ONLY 原始设备证据。

不清理历史备份、旧 refs、旧候选、审阅分支、SQL、APK、旧 dirty 根或 LOCAL_ONLY 证据。结束后核验本任务进程、测试通话、令牌、服务、端口和 ADB reverse；默认保留 APK 安装。失败脚本与退出码如实保留；只读补充核验不得被写成重测通过。

## 6. 集中交付与停止

集中更新同一份 `IMPLEMENTATION_REPORT.md` 和一个 `artifact_manifest.json`，必要时更新当前状态入口；不得改冻结计划或覆盖历史章节/原始失败。

交付应绑定实时 main/Root、源码与候选 Commit/Parent/Root、apps/services Tree、报告/Manifest Blob、变更文件 Hash、测试命令与退出码、stdout/stderr Hash、APK build/install Hash（若 APK 改变）、AC-01～11 状态、证据来源分类、资源恢复和保护对象核验。

call3、call4、call5 分别记录，不拼接为虚假的整体 PASS。明确记录撤权计时定义与误差界；AEC、旧通知卡片点击、真实 elapsed-time、Push 和 Gate 2 的未完成状态。仅做有界非作者复核，不得声称审阅者执行了本地测试或设备操作。

发布普通 non-force 候选并完成远端 Commit/Parent/Root/Blob/原字节回读。候选交付后停止，等待 Astra 集中独立验收。

最终仍为 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`，除非冻结合同有充分证据且 Astra 独立改变裁决。禁止自动合并产品 main、启动 v10.1.6、创建微任务、启动未授权 Gate 2、接入真实 Push/生产服务、产生未经授权费用或清理历史证据。

## 7. 派发方式

本文件只是一份待 Owner 手动派发的正式返修任务单。创建任务单或同步状态不等于向 Codex 派发。Owner 手动将任务单完整交给 Codex 后才开始执行。Codex 在授权范围内自主完成返修，不逐步请求普通修改审批；Astra 在新候选交付后集中独立验收。
