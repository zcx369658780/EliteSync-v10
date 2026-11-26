# EliteSync V2｜M3 通信、媒体与离线可靠性集中报告

任务 `V2-M3-COMMUNICATION-MEDIA-RELIABILITY-20261126`，2026-11-26，北京时间。工程结论为 **PARTIAL**，待网页 GPT 顾问集中复审及 Owner 决策。发布状态为 `R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`。M1 正式保存和读回的限定接受、M1-R 后端历史身份 `PARTIAL` 沿用。

## 工程及证据身份

| 范围 | 固定身份 |
| --- | --- |
| 工作树及同步分支 | `D:/EliteSync/development/v2-cloud-r0-20261121`，`codex/v2-function-completion-20261121`，`git@github.com:zcx369658780/EliteSync-v10.git`。开工工作树与暂存区干净 |
| 开工及后端运行源码 | `428648fe5819ee1396105d1360e737d435a3f3be`，tree `6dae3e4cbd3a3dc6ab8d114f28ea03e77c640266`，backend tree `d8df13bd2c14ee902198ceb45e49806e9083a7e1`。既有镜像离线替换应用、路由、配置和迁移等目录，Composer 锁定依赖沿用 |
| 定向测试源码 | `0ec0a19f128fff8b8681b66b05ae5df27fd5d5c7`，tree `e908f8efbb5c0789d10692ec897ceee0511242c8`。包含历史夹具修正 |
| 本机 Flutter 缓存与断网修复 | `live_chat_page.dart` 的 Git blob 为 `8b9fda9bcc51b84e33134e94680ab59dae35720f`。本地源码及配套回归补丁 SHA-256 为 `45e97a0d8def147889e7df032299a294a189908c27c9963a6a37349b18275d94`。依据任务同步范围，保留在本地 |
| 本机 HTTP、Workerman 和 MariaDB | 独立 Docker 数据根、应用存储及空 MariaDB 卷。PHP 8.4.28，MariaDB 10.11.19，`server_id=2621126`。API 与 Workerman 应用镜像索引 digest `sha256:1752a07cda195caa19bf5696abb412bb84eaf9dd553d207a58a28366b742c6f4`，MariaDB 镜像 `sha256:5d60ca6129f939453472f4ed385c54820ec57f3aa384a8646619f9bc0e3b5eab`。仅合成库，回环服务 |
| WLAN APK | `com.elitesync.v2m3wlanqa`，`1011807 / 10.1.18-v2-m3-wlan-qa`，arm64-v8a，首包 SHA-256 `ba96963332f39c02f61efc1c201d50aeec024008234187c85781a48c180f3bf9`，修复包 `e9846b5ec818b9b0e14dfc2f9889e0f571a8e46269baaca9a54f8706bac71ade`。同包同签名。固定私网 TLS 证书 SHA-256 `75b3ffe1627fbe8a3fae0546be092c908b948c083593d5249dc49af648dcf018`。核验签名、证书、native/Dart 端点与 AOT |
| 设备 | 授权手机型号 `25060RK16C`。现装 `com.elitesync.v2stagingremote / 1011814` 开工读回 SHA-256 `37b9d370dda05f737cdd5e367d12267e3572220120edd6a27ec7710d8aec18d4`。独立 QA 首包及原位更新修复包均有各自授权，安装后回读命中各自 SHA。第一次 USB 安装受手机系统限制，Owner 就绪后重试通过。Android 模拟器 `emulator-5570` 以只读 AVD 启动，用同一 APK 的 ARM 翻译路径，修复包虚拟网络断开及离线冷启动通过 |

## 专项结果

| 出口 | 状态 | 本轮结论 |
| --- | --- | --- |
| M3-01 `M3_CONNECTION_CONSENT_REVOCATION_PASS` | **PASS**，本机隔离 | 双方同意分段、并发命令、撤权、Block、换代、账号切换与迟到响应均有定向证据 |
| M3-02 `M3_PRIVATE_MEDIA_LIFECYCLE_PASS` | **PARTIAL** | PNG/JPEG 真实 HTTP、撤权和缓存回归已验证。上传响应丢失后重传产生独立 ready 对象。手机结果见设备矩阵 |
| M3-03 `M3_OFFLINE_LEASE_24H_PASS` | **PARTIAL** | 服务端 86,400 秒、客户端过期边界和模拟器离线冷启动通过。实体附件下载途中切断仍未呈现授权文字，自然经过 24 小时 `NOT_RUN` |
| M3-04 `M3_REAL_WLAN_FAULT_MATRIX_SCOPED_PASS` | **PARTIAL** | 实体 WLAN 文字请求的发送中断、响应丢失两项通过。附件下载中断仍失败，实体离线期间换代未闭环 |
| M3-05 `M3_HISTORICAL_409_200_DISPOSITION` | **PASS** | 历史用例的同值重放断言已过时。陈旧异值继续返回 409 |
| M3-06 `M3_WEBSOCKET_AUTHORIZATION_PASS` | **PASS**，本机隔离 | 真实 Workerman 与 Flutter 迟到回调验证通过 |

### 关系、消息与媒体权限

| 条件 | 读写和留痕 |
| --- | --- |
| 具备资格，Connection 或 Messaging Consent 未完整接受 | 单方不能批准自己的请求，`CN_PENDING`、仅 `CN_ACTIVE`、`MC_PENDING` 均不给私信读写。并发 Connection 请求、Connection 接受和 Messaging Consent 接受每组得到一次 200、一次 409 |
| `CN_ACTIVE + MC_ACTIVE` | 现行 `room_key` 绑定消息、成员、附件和站内通知。PNG/JPEG 字节校验通过，直接 URI 匿名 401、未绑定受众 404，授权收件人 200 与 `private, no-store` |
| 并发撤回 Messaging Consent | 一次 200、一次 409。`CN_ACTIVE` 保持，`MC_REVOKED` 生效。双方旧会话读取、发送和直接媒体读取均 404。站内通知降级到 history，清空 payload。Workerman 主动关闭旧连接 |
| 重新申请并由对方接受 | Connection ID 延续，Consent ID 和 `room_key` 换代。旧消息原键重放 404、旧引用和附件重新挂接 422。数据库的旧消息附件关联和原文件摘要一致 |
| Block | 双向候选和精确搜索移除，旧邀请、Connection、私信历史被拒绝。Block 下附件保留与拒读沿用历史实测，当前 MC 撤回和换代独立取证 |

真实 HTTP 截断 multipart 后零新增。丢失消息响应后，同键重试返回同一已提交消息，历史读回一条。丢失上传响应时，先前成功落盘的对象保留，第二次上传产生新的 ready 对象。该轮单条消息只挂接明确确认的附件，上传端缺少可恢复的幂等收据。模拟器完成 Android Photo Picker 选择、返回、发送和读回，选中的合成 PNG 由客户端重新编码为 JPEG，像素核对通过，数据库 ready 对象关联一条消息。实体手机通过 WLAN 读取受保护图片和聊天缩略图。手机端选图上传为 `NOT_RUN`。UI 以受保护的图片文件渲染缩略图与预览，未发现独立服务端缩略图产物。Flutter 先复现刷新替换后旧图片仍被解码缓存追踪，随后验证本地修复在刷新与撤权后移除旧缓存并关闭预览。旧消息和原图保留。

### 离线、故障与实时性

服务端在带可信设备登录的最新消息窗口签发 86,400 秒授权，绑定账号、对端、设备、会话与 `room_key`。常规历史读不续发。纯文字和同代文字引用可进入离线投影，媒体引用被过滤。Flutter 覆盖冷启动关闭、同进程离线、前后台、可信时间异常、过期边界、账号切换、恢复联网与旧代撤权。30 天密文保留单列，由私密缓存定向套件验证。授权策略依据 [Owner 方案 B](../../../decisions/OWNER_V2_P0_4_2_OFFLINE_HISTORY_OPTION_B_20261122.md)。

| 故障窗口 | 本机真实 HTTP／Flutter | 实体真实 WLAN |
| --- | --- | --- |
| 正常连接突然断开 | Flutter 同进程离线只读。新回归覆盖先保存刚获授权的文字，再独立加载媒体。模拟器虚拟网络断开、冷启动锁定通过 | 首包 **FAIL**。修复包将手机的真实 WLAN 在附件读请求已到达网关而未转发时切断，设备仍锁定文字。残留原因 `UNKNOWN`。另一次普通断开复测因 QA 包离开前台作废 |
| 发送中断 | 本机半截 multipart，数据库零新增。Flutter 覆盖选择保留与恢复 | **PASS** 限文字。WLAN 代理读到 8/105 字节并在转发前暂停，手机断开 WLAN，零上游请求。恢复后手机保留未确认状态，按原编号重试仅一条 |
| 履约后响应丢失 | 回环代理确认上游 200 后丢弃响应。消息同键读回，重复上传限制单列 | **PASS** 限文字。WLAN 代理取得上游 200 并转发零响应字节，再切断 WLAN。恢复可读回，原编号重试仍一条 |
| 恢复与迟到响应 | Flutter 账号变化、授权 epoch 与旧代回复测试通过。真实 HTTP 旧键及旧引用重新提交被拒绝 | 文字写入恢复通过。离线期间换代、实体附件上传故障与移动网络为 `NOT_RUN` |

手机在 `wlan0` 上直接访问候选绑定的私网 TLS 入口，网关单列手机 WLAN 记录。USB 只用于操作和读回，ADB reverse 列表为空。结束前核实 WLAN 开关及原路由已恢复，现装 Staging 1011814 哈希保持一致。

真实 Workerman 使用现行令牌握手 101。轮换后旧令牌与错账号拒绝，撤权后原连接关闭。新代首次消息建立 Conversation 后可握手，帧仅携带消息变化 ID，与当前 HTTP 读回一致。无 Conversation 的空新代使用 HTTP 获取当前窗口。手机和模拟器候选用 HTTPS 轮询，Workerman 在本机隔离服务单独取证。客户端另有 19 项实时生命周期回归，涵盖重连、超时迟到、账号切换和授权失效。共享 WSS、真实 Push 与生产 RTC 为 `NOT_RUN`。

### 历史 409／200 裁决及运行清单

历史失败点是 `V1011SocialTest::test_privacy_posts_and_revocation_do_not_disclose_deep_fields` 的同值重复提交。现行 `PrivacyController::save` 在锁内比较字段。同值重复返回 200 且 revision 为 1，异值且预期版本过期返回 409。PHP 8.4／专用 MariaDB／真实 HTTP 核对两种返回、生日字段隐藏以及解除好友后的帖子 404。保留旧测试失败与原始回执。[v10.1.11 合同](../../v10.1.11/IMPLEMENTATION_REPORT.md)

| 定向检查 | 结果 |
| --- | --- |
| 首轮 Flutter | **PASS 110/110** |
| 首轮 PHP 8.5.3／SQLite | **37 PASS、5 FAIL**，674 断言。旧分页数据缺当前代际两项、匿名媒体断言两项、隐私旧断言一项 |
| 修正后 PHP 8.5.3／SQLite | **PASS 58/58**，877 断言。补当前代际、合法拥有者和拒读、同值与异值对照 |
| Flutter 扩围 | 首次修正后 **PASS 127/127**。设备断网缺口新增 RED 回归，修复后重跑相关四套 **PASS 94/94**，范围有重叠。旧长窗口与媒体夹具三项、旧公网明文 WS 断言一项、图片缓存及媒体传输回归各一项，RED 留档。另有私密缓存 **30/30**、Socket 生命周期 **19/19**。Dart 静态分析通过 |
| MariaDB／真实 HTTP、Workerman | **9 组**观察与断言通过，92 个 HTTP 响应，500 为零。其中一次上传响应丢失暴露重传重复对象。空新代握手与 WebSocket 接收方向的初次夹具失败保留 |
| 历史附件与 WebSocket 专项 | 附件 **8/8** 及 Workerman **4/4 + 1/1**，沿用原回执 |

旧代授权、设备测试和代码身份保留在本机证据目录 `v2-m3-local-20261126`。联测回执 `m3-http-d9ca44ac.json` 记录方法、路由、状态与故障收据。手机复测见 `phone-wlan-retest.private.log` 及网关故障窗口回执。模拟器首次确认离线只读和冷启动锁定，后续换代试验未取得离线前置状态，未执行该次撤权。Android 构建日志、候选、私网信息和合成操作原件留在本机。[前轮媒体与前后台证据](V2_P0_4_2_R1_FOREGROUND_AND_MEDIA_CLOSURE_20261122.md) · [前轮工程复验](V2_P0_4_2_R1_LOCAL_CLOSURE_20261122.md)

## 发布门槛

本机合成证据不产生真实用户认证结论。共享 Staging、真实供应商、公开注册、共享私信、WSS、生产 RTC 与 main 均未变更。P1 历史公网 443 限定来源失败、根因 `UNKNOWN` 继续保留，独立 Chrome、真实手机移动网络和双实体专项仍待验证。M3 报告准备供顾问复审，Owner 保留内测及生产准入权。

## 2026-11-27 续作回执

续作从固定报告提交 `c6ebd5460a5991ecbd5072cf5dee79b9a39cba16` 开始，上方 11 月 26 日结果保留。代码与依赖本轮变更的测试在当前本地工作树，跟踪文件补丁 SHA-256 为 `434551d054a4d65c7c3a5af77c383a6cc62ee5806131663921f96306ea885a3e`，隔离库的新增迁移文件 SHA-256 为 `5b30a2094e87df0d084e3e47cb4b26f339ed78c077ab427fbf2790ad57d45642`。

| 范围 | 新证据 |
| --- | --- |
| 离线授权 | 可控测试复现被遮挡会话列表超时抢先切换共享缓存模式，聊天当前代际文字写入失败。回环探针真实复现响应体中断上浮为 Dio `unknown`，内层为 Dart `HttpException`。补丁使后台列表的失败不夺取当前聊天的授权，并仅把所核实的无 HTTP 响应中断类型纳入离线读。服务端鉴权拒绝仍会关闭授权 |
| 私信图片重传 | Android 每次选择图片生成上传编号，同一次显式重试重建 multipart 时保留编号。PHP 在帐号和当前凭据检查后，以帐号和编号查回已登记资产，校验服务端计算的文件摘要。加法迁移增加唯一约束，旧客户端无编号仍沿用原合同。隔离 MariaDB `server_id=2621127`，应用镜像 `sha256:36dca749623091744991a455f2efd511c5f9ae2133738d3df7904e6a5f304c1f` |
| 定向验证 | Flutter **111/111**，PHP **21/21** 和 458 断言，Dart 静态分析通过。隔离 MariaDB 和真实 HTTP **4/4**，16 次响应，零 500。确认服务端已保存但客户端丢响应后以原编号读回同一 PNG，两次并发 JPEG 上传收敛到一个对象及一套处理任务。相同编号替换文件返回 409，跨账号复用编号各自独立，直接读取对方未授权 URI 返回 404 |
| 模拟器 | 同 APK 走实际隔离 HTTPS，网关先转发图片响应的部分字节，再切断模拟器虚拟网络。检测到 `unknown / HttpException`，同进程仅保留本代文字，隐藏图片。恢复网络后重新在线读取图片 |
| 11 月 27 日候选 | `com.elitesync.v2m3wlanqa / 1011807`，原签名，APK SHA-256 `328fa43cab68809762494b661d9904c724c61e25adf94d229870c0efa4759c8e`。本地诊断版输出授权检查布尔值和错误类型。实机原位更新及安装哈希读回通过 |

### 最终实体复测

- `328fa43c` 的实体 WLAN 中断仍复现了授权内层读取为空。诊断确认传输已识别、缓存已解锁且进入离线，原失败记录保留。独立回归随后复现登录期间清理旧缓存会让可信时间落后，从而拒绝新签发授权。最终补丁在清理前捕获单调计时锚点，并让聊天和会话列表共用连接故障识别。现行代际、时间边界、账号绑定和服务端拒绝检查继续生效。旧实体失败的各因素贡献未分离。
- `328fa43c` 在实体手机完成合成图片选择与返回。上传经真实 WLAN 到达隔离服务，HTTP 200 响应丢弃后，手机按原编号重传。文件摘要、资产唯一性、处理任务和单条消息关联一致，收件端可读回。该范围记 `M3_PRIVATE_MEDIA_LIFECYCLE_PASS`，限 PNG/JPEG 和现有端侧缩略显示。
- 可信时钟修复包经具名授权在 `25060RK16C` 同包原位安装。已装 SHA-256 `817747b534a6ddbf24a7657a342ce03e929677db5fea67d8cc213400100e6223`。第一次真实 WLAN 中断发生在受保护图片的部分响应体送达后，实机保持本代文字只读并隐藏图片，恢复后再次在线读取。第二次切断期间在隔离服务撤权并换代，手机在获知撤权之前仍按授权显示本代文字，恢复后仅显示新代。旧图片 URI 返回 404，原文件摘要、消息和附件关联保留。
- 本轮与 11 月 26 日的发送中断和响应丢失实机回执合并使用，记 `M3_REAL_WLAN_FAULT_MATRIX_SCOPED_PASS`，范围为手机与模拟器在隔离服务上的已记录窗口。发送故障回执对应 11 月 26 日的候选，附件中断及换代回执对应时钟修复包。实体移动网络和同一最终 APK 重跑全部文字发送故障均为 `NOT_RUN`。
- 修复后 Flutter 定向 **158/158**，Dart 静态分析通过。本机最终跟踪代码补丁 SHA-256 `dbc2c3506db20ecee251e20bef4174b8c2b68c710a6f8c85396db4f613f32aaa`，新增传输分类文件 SHA-256 `e3d52253c6f325e438113397b438258448cc76c83ffb5fd6ddec49c1bc898386`，新增迁移身份见上。设备测试结束后原 WLAN 路由恢复，ADB reverse 为空，原 Staging 1011814 的已装哈希一致。

**M3 整体仍为 `PARTIAL`。** 方案 B 在实机获得短时离线、撤权与重连闭环，服务端和自动化的 86,400 秒边界均有证据。实体设备自然经过 24 小时的到期拒绝仍为 `NOT_RUN`，因此 `M3_OFFLINE_LEASE_24H_PASS` 仍待验。整体发布门槛保持 `R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`。
