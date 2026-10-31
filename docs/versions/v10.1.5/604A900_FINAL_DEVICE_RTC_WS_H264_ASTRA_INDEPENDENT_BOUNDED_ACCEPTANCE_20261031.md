# EliteSync v10.1.5｜604a900 最终设备/RTC/WS/H.264｜Astra独立有界验收

日期：2026-10-31（Asia/Singapore）。

**裁决：`V10.1.5_FINAL_DEVICE_RTC_WS_HARDENING_SOFTWARE_AND_BROWSER_SCOPE_ACCEPTED_WITH_OBSERVATIONS / APP_DEVICE_NOT_RUN / WS_REAL_RUNTIME_NOT_RUN / H264_API_GATE_CLOSED / AC05_OPEN / G2_FALSE / REAL_PUSH_PROVIDER_PENDING / V10.1.5_FUNCTION_PARTIAL_NOT_ACCEPTED / MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。**

接受范围：b441已接受源码的选择性接续、WS客户端生命周期/入口配置加固、服务端默认监听和消息最小化修正、指定Flutter/PHP软件测试、PREPARE故障负例、新独立MariaDB资格/迁移/seed，以及真实浏览器最小Web正反例。**不接受**真实Workerman、APP设备、Android密文/系统通知、H.264 API资产链、RTC/AEC/≤5秒停媒或v10.1.5整版。

Astra直接核验GitHub原生对象、94项Manifest映射、Result/Manifest Blob及选定源码/测试。Windows、Flutter/PHP、MariaDB、浏览器和本地执行器运行由Codex报告；Astra没有操机、重跑本地测试或读取私有数据库/凭据/LOCAL_ONLY日志。

## 1. Git交付身份

- Candidate：`604a900aed786c9bc53e44d3eaf7e1aa73ad4b2c`；sole Parent：`ea682562c148166dcf502a048c7e47a4e136fb8f`；Root：`fe8b89d9b717f37a2022a10c7f7d03dc3da1b0be`。
- compare ahead1/behind0，96项变更；递归Tree 6,321项，`truncated=false`。
- apps Tree：`2526e6ec86b4e054a2d712aab41f5cd6dd5a38a8`；services Tree：`7634b4755a41f08641e00948f684c06efb12d8fe`。
- Manifest 94项源码/测试映射：81项为b441已接受精确Blob，3项为b441源码加本轮WS修正，10项为本任务配置/测试/PHP夹具。Astra逐项核对path/mode/Blob/size，**94/94匹配**；另两份交付文档Blob与Tree匹配。96项compare路径恰为94项映射+2份交付文档，无未映射文件。
- Result Blob：`2b2c097d0ebe315906108650d646fcb61362fb03`；Manifest Blob：`d4d12bfa8f7656e629996b4096e7a1b91007588a`。
- Task Blob：`e9dee55a80ae274456edb8da109206e5d05183c6`；冻结plan Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`。
- b441接受来源Commit/Root：`b441d1808bb366dbffebbecc03180b7bedd197f7` / `11b73b2d3bca69d5212dc11fb7a4f109ca126c35`；Astra Review Commit/Blob：`923d248385c46d7bcecc1b29dced6f307b1dcb87` / `fe1d22b21fddfd7ec5a0bf427faddd7d219be0df`。均只是来源/审查，不是本轮研发Parent。
- main仍为Parent `ea682562c148166dcf502a048c7e47a4e136fb8f`；候选未合main。

## 2. WS源码修复：有界接受

Astra直接读取`ChatSocketDataSource`、`chat_providers.dart`、`LiveChatPage`、`chat_socket_endpoint.dart`、`main_dev.dart`、`main_prod.dart`、`ChatWebsocketServerCommand`、`ChatWebsocketAuthorizationService`及新增测试。

- observation在首次异步profile/token/upgrade前注册session-change订阅；identity包含账号、状态、access token、relationship authority epoch。logout/切号/token轮换/epoch变化主动stop，取消frame和identity订阅、重连Timer、identity monitor，关闭HTTP upgrade client及已连接socket。
- 每次连接有generation；超时/切号后迟到返回的socket会被关闭。每次重试重新取当前token，最多初次连接加5次重连。profile/token/upgrade/等待重连期间均可取消。
- LiveChatPage在session/epoch变化、后台、拒绝和dispose时cancel旧订阅；恢复前台先做当前HTTP验证再订阅。旧done回调不能清除新handle，旧事件不能触发新账号读取。
- dev/prod bootstrap接入WS地址；只接受与API同host的WS authority，拒绝凭据、query、fragment、自定义path和TLS降级；HTTPS只用WSS，明文WS仅限dev loopback/模拟器宿主桥。未资格化公网HTTP不推断Bearer WS目的地。
- Workerman默认bind从`0.0.0.0`改为`127.0.0.1`；消息轮询只发送`conversation_changed`及ID，不再通过WS推送正文/发送方/接收方/时间；正文由当前授权HTTP读取。服务端仍按当前token、设备session、online deadline、账号状态和MC/CN/Block重新授权。
- 软件测试覆盖无帧切号主动关闭、epoch/logout、token换代、upgrade中切号、迟到socket、有限重连、旧页面事件、后台恢复及dev/prod endpoint安全正反例。

**重要边界：** 47项Flutter测试使用mock socket/软件夹具；10项PHP测试使用SQLite内存库。它们支持客户端生命周期和服务端授权软件逻辑，不能证明Workerman真实握手、网络断线重连或服务器周期重授权已运行。

## 3. 本轮执行证据（Codex本机回执）

| 项目 | 结果 | 限定 |
|---|---|---|
| Flutter定向 | 5文件/47 tests/exit0 | 软件测试，不是设备 |
| Flutter分析 | 首轮exit1/3 info保留；修正后exit0/No issues | 无suppress/删断言 |
| PHP | PHP8.4.27/PHPUnit12.5.42，10 tests/58 assertions/exit0 | SQLite内存库 |
| PREPARE | 9负例通过 | logger TypeError、实际flush、实际fsync × write/revise/process；未准备副作用0 |
| MariaDB新实例 | 初始0表，迁移后93表；2虚构用户/1管理员 | 新库资格、单次迁移/seed；本轮DB重启0 |
| 最小API | health 200、缺鉴权profile 401 | 不是旧120项API全量重跑 |
| 浏览器 | 真实IAB单批8项正反例通过 | 登录、CSRF管理员、同库虚构用户、审计、退出、旧session拒绝、普通用户拒绝 |
| 非作者复核 | Sol/high只读审查六个WS源码、三个Dart回归及PHP夹具，无具体P1/P2 | 未执行测试，不是Astra终验 |

Manifest有68项process receipts，68/68具备prepare_seq；两项非零退出均保留：offline pub setup exit69（后改用已有缓存并保持offline/enforce-lockfile）和初次Flutter分析exit1（修正后最终exit0）。失败历史未删除。

Astra直接读了公开`executor_fail_closed_test.py`：9个故障负例只作用于标记的.fixture测试journal，分别覆盖logger/flush/fsync对write/revise/process的阻断；Codex报告9/9通过，目标副作用0。旧PREPARE缺口未追溯补写。

## 4. 未运行门与限制

- **G2 false**；本轮Gradle/ADB/install=0，无本轮APK/package/signature/hash。Android实际flutter_secure_storage密文、冷启动、删除/失败路径、OS通知权限/锁屏和APP→API→DB均未运行。Fake SecureStorage测试不等于Android原生密文证明。
- 已接受PHP镜像缺pcntl/pcntl_fork，无获准替代途径；Workerman未启动。真实WS握手、Bearer、服务器poll/re-authorization、真实断线重连均`WS_REAL_RUNTIME_NOT_RUN`。
- b441旧合成H264素材有效，但旧API因缺可信ffprobe返回422、未建READY。本轮限定可信输入仍未发现合格ffprobe；仅两个PHP verifier fail-closed负例通过。未运行真实H264上传、READY、Range、附件读回或Android播放器，分类`VIDEO_API_VERIFIER_GATE_CLOSED`。
- **AC05 OPEN**：没有当前合格双端、麦克风/摄像头、SFU/guard和同步时钟；没有新AEC on/off或revoke COMMIT至最后有效媒体≤5秒测量。历史10.125秒不满足5秒目标。
- 真实Push供应商/SDK/凭据/费用未授权，保持PENDING；物理15/30天、逻辑数据库恢复未运行。

## 5. AC01–AC11裁决

| AC | Astra分类 |
|---|---|
| AC01 | SOURCE_VERIFIED / CODEX_REPORTED_LOCAL_RUNTIME；新库资格及具名旧资产保护有界支持，非全盘审计 |
| AC02 | SOFTWARE_REGRESSION_PASS / REAL_WS_AND_APP_NOT_RUN |
| AC03 | SOFTWARE_AUTHORIZATION_PASS / TEST_INJECTION / WS_REAL_RUNTIME_NOT_RUN |
| AC04 | VIDEO_API_VERIFIER_GATE_CLOSED / PLAYER_NOT_RUN |
| AC05 | **OPEN / NOT_RUN_GATE_CLOSED** |
| AC06 | ACCEPTED_SOURCE_RETAINED / SOFTWARE_RETENTION_REGRESSION；物理15/30天未运行 |
| AC07 | DART_SOFTWARE_SUPPORTED / ANDROID_NOT_PROVEN |
| AC08 | ACCEPTED_NOTIFICATION_SOURCE_RETAINED / OS_NOT_RUN |
| AC09 | TEST_ONLY_SOURCE_RETAINED / REAL_PUSH_PROVIDER_PENDING |
| AC10 | NEW_WEB_BROWSER_MINIMAL_PASS / APP_DEVICE_E2E_NOT_RUN |
| AC11 | SOURCE_MAPPING_AND_BOUNDED_REVIEW_COMPLETE |

## 6. 保护、资源与最终决定

- Owner报告总用时61.3分钟；Manifest冻结时约53.1分钟，硬窗口90分钟。任务工作面含日志/元数据保守上界3,334,164,480 bytes（约3.11GiB），低于8GiB。containerd SizeRw/SizeRootFs为null，未假定为0，也未声称OS全局VHDX配额已证。
- 6个任务容器均停止/PID=0，代理停止、浏览器页关闭；其中两个API容器exit137、其余四个exit0。新DB未重启，逻辑恢复未执行。
- 旧Laravel11.48默认根、dirty252/refs527、原HEAD/index、11,066文件/240,617,393字节备份元数据和160项SHA样本按具名范围核验；备份Manifest SHA256 `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`。没有旧资产写入/旧库访问/默认入口切换/删除；这是限定范围核验，不是全盘审计或恢复证明。
- 一次历史网络元数据定位曾返回旧合成密钥字段；Codex报告未使用、未公开并停止进一步凭据型查询。该观察保留，不在此复述任何密钥。
- **Astra接受本轮WS软件生命周期/入口加固、指定Flutter/PHP回归、PREPARE负例、新独立库资格和真实浏览器最小Web流程，状态`V10.1.5_FINAL_DEVICE_RTC_WS_SOFTWARE_AND_BROWSER_BOUNDED_ACCEPTED_WITH_OBSERVATIONS`。** 设备、真实WS、H.264 API链、AC05及Push未通过/未运行项保持原状态。
- 整版仍`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_FALSE / REAL_PUSH_PROVIDER_PENDING`。Review仅作独立审查记录，不是产品合并许可或未来研发Parent。候选永久STOP；不合main、不放行G2/AC05、不切旧Laravel11默认入口、不删除备份、不启动v10.1.6、不自动派发后继任务。

**结论：`ACCEPTED_WITH_OBSERVATIONS_IN_BOUNDED_WS_SOFTWARE_AND_BROWSER_SCOPE / FULL_V10.1.5_NOT_ACCEPTED`。**
