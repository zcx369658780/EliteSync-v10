# EliteSync v10.1.5｜b441d180 POST-0017｜Astra独立有界验收

日期：2026-10-31（Asia/Singapore）。

**裁决：`V10.1.5_POST_0017_SOFTWARE_AND_CONTROLLED_API_DB_WEB_ACCEPTED_WITH_OBSERVATIONS / APP_DEVICE_NOT_RUN / ANDROID_CIPHERTEXT_NOT_PROVEN / OS_NOTIFICATION_GUI_NOT_RUN / WS_NOT_RUN_WITH_CLIENT_LIFECYCLE_OBSERVATION / H264_API_PIPELINE_BLOCKED / AC05_OPEN / G2_FALSE / REAL_PUSH_PROVIDER_PENDING / V10.1.5_FUNCTION_PARTIAL_NOT_ACCEPTED / MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。**

接受范围：0017已接受软件源码的精确接续、Dart分析修复、新任务PREPARE fail-closed测试、受控真实API/独立MariaDB/Web HTTP及指定软件回归。**不代表**真实APP设备贯通、Android实际密文/OS通知、WebSocket运行、完整视频链、RTC/AEC、G2放行或v10.1.5整版接受。

Astra直接核验GitHub原生对象、84项源映射、Result/Manifest及选定源码/测试。Windows容器、PHP/Flutter/MariaDB执行和LOCAL_ONLY日志由Codex提供脱敏摘要；Astra未直接操机、重跑测试或读取私密SQL/日志。

## 1. Git对象与交付完整性

- Candidate：`b441d1808bb366dbffebbecc03180b7bedd197f7`；sole Parent：`be272c1f6855eb28aa4b483083ab4072783bdf30`；Root：`11b73b2d3bca69d5212dc11fb7a4f109ca126c35`。
- compare：ahead1/behind0；86项变更；递归Tree 6,310项，`truncated=false`。
- apps Tree：`92c7caea1ed2d22b3998e79c120d4b31c9572bdf`；services Tree：`ca42f315edb27a8993b3591f51991185d1ed3026`。
- 86项由84项源码/测试与2份交付文档构成。Manifest source_mapping的84项path/mode/Git Blob/bytes与候选Tree **84/84一致**；Result/Manifest文档Blob也与Tree一致。
- 84项来源：71项为Astra已接受0017精确Blob；5项为Dart分析修复；8项为本任务合成E2E/资格/执行器harness。未盲合旧候选整棵Tree。
- Result Blob：`3587cebce51083cda837f036a241c8d30c3cf92d`；Manifest Blob：`f8df511f0f99ca223ccda0ee17ae3fb4589b8fd1`。
- Task Blob：`ffe21d60ea46630f01cb09fe1821dccd5a115a89`；冻结plan Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`；0017 Astra Review Commit/Blob：`b5e2c9754aa2710d2d40eea22ba8d9a6b2960d4e` / `5679481e0b7ffd5259fae0efdbfe0c8b8fb54e10`。
- main仍为Parent `be272c1f6855eb28aa4b483083ab4072783bdf30`，产品候选未合main。

## 2. 源码与harness审查

- 71项已接受源码Blob与0017输入完全一致，继承F1/F3/F4有界接受，不将旧测试冒充本轮新运行。
- 5项Dart修正涉及RTC邀请/状态页面条件大括号、社区分页null-aware cursor、Buddy测试结构、测试闭包未使用参数。对照Parent差异，未发现权限扩大或测试断言放宽。
- 公开`executor_fail_closed_test.py`覆盖logger TypeError、实际event flush、实际event fsync三种故障，每种对write/revise/process执行，9个负例。Codex报告9/9通过，未准备的写入/revise/process为0。故障注入仅作用于具名`.fixture`测试数据journal，不向权威账本注入模拟I/O错误。
- 执行器本体为LOCAL_ONLY；Astra只能直接审公开测试源码和脱敏Manifest，不能独立读取私有执行器及原始账本。故该项分类为`PUBLIC_TEST_SOURCE_REVIEW + CODEX_REPORTED_LOCAL_RUNTIME`。
- 上一任务`incoming/source.json`的历史PREPARE缺口未追溯补写、未倒签；旧账本永久STOP保持原样。
- 新PHP harness的`qualify.php`限定精确TASK_ID/local/MySQL/host/port/schema/user/server_id/grants；`scenario.php`、`qualification_negative.php`、`hold_pair.php`为CLI+TASK_ID门禁且限定synthetic-c31账号；非公开HTTP后门。`web_http.py`只走127.0.0.1既有Web入口。

## 3. 本轮运行证据（均为CODEX_REPORTED_LOCAL_RUNTIME）

| 验证面 | 结果 | 接受边界 |
|---|---|---|
| Flutter analyzer | exit0 / No issues found | 本轮静态分析 |
| Flutter定向软件 | 默认Dart 63项exit0 + Buddy专用Dart profile 5项exit0，共68项 | Buddy define不是Gradle/G2或APK资格 |
| PHP | PHP8.4.27 / PHPUnit12.5.42，32 tests / 240 assertions / exit0 | 受影响服务端测试，不是全项目回归 |
| API/DB | 120项HTTP检查：actors26、messages23、media/notifications37、revocation16、concurrent MC18 | 真实loopback+新独立合成MariaDB |
| 消息幂等 | 丢ACK后同client_message_id回放、冲突409、4并发收敛一条消息/通知 | API/DB真实合成链，不是APP操作 |
| MariaDB锁交错 | REPEATABLE-READ；真实持锁与HTTP请求重叠，connection过滤wait计数[0,2]；send200、revoke200、replay404 | 本轮事务锁交错，不等于WS |
| PNG | multipart真实上传→READY→附件→私有200/206；第三账号/撤权后404 | API层图片链 |
| H264 | 合成1秒160×120、10fps、10帧完整解码；SHA256 `a220520c0fbf9aa620cf6a718966f7743ed580b1b8d0d5ced4eb55b23ca23ec9` | 素材有效；API缺可信ffprobe返回422、未创建资产/READY，视频产品链阻断 |
| 通知 | 偏好持久化、静默/类别抑制、test_only token登记/轮换/撤销、旧通知当前授权 | 测试替身；真实Push PENDING |
| Web HTTP | 8项HTTP/CSRF：管理员最小运营状态、无私聊正文、logout后拒绝、普通用户拒绝 | 浏览器自动化OS error3，视觉UI NOT_RUN |
| MariaDB重启 | 新库93表/163行；真实进程停止/PID0后启动，逐表行数及全行哈希一致；aggregate SHA256 `01d7b0e5a0b7d9ec23b36f0c152367381ecd1b3d175856fb41aa2e16fabf2cc2` | 真实进程重启；SQL副本已保存/读回，逻辑恢复未执行 |
| 资源停止 | 4个任务容器全停；旧镜像/卷未删除；默认入口未切换 | Codex回执，非Astra现场操作 |

Manifest记录110项process receipts，全部具备prepare_seq；7项非零退出均保留原回执。初始DB readiness、离线pub get、修复前analyzer、首轮HTTP actor/T0及首轮Buddy profile等失败未被删除；报告记载后续更正运行。

## 4. 未运行门禁与源码观察

### APP / Android / G2

G2仍false；本轮Gradle/ADB/install操作0，APK身份/hash均null。Android实际flutter_secure_storage密文、冷启动设备行为、测试密文删除、系统通知权限对话框/锁屏均NOT_RUN或NOT_PROVEN。68项Dart测试不能替代真实APP。

### WebSocket

Astra直接读取`ChatSocketDataSource`、`chat_providers`、`LiveChatPage`、`ChatWebsocketServerCommand`、`ChatWebsocketAuthorizationService`及socket contract test：

1. 客户端每个frame派发前检查sessionIdentity，身份变化后的旧frame会被丢弃；但已连接后身份变化时，`_runConnectionLoop`没有监听身份变化并主动关闭`activeSocket`，`LiveChatPage`的session listener也没有显式`_socket?.cancel()`。若旧token未同时服务端撤销，旧授权连接可能持续到服务端重鉴权/过期关闭。此为源码生命周期观察，不是本轮已证实的数据泄露。
2. 新增`AppEnv.wsBaseUrl`字段，但`main_dev.dart`和`main_prod.dart`未从环境/host bootstrap赋值；当前连接依赖`buildChatSocketUri`回退到API host/默认端口，独立WS地址未完成贯通。
3. PHP镜像缺pcntl/pcntl_fork，无获准等价途径；Workerman未启动，真实WS握手、重连、切号关闭、撤权后连接关闭均NOT_RUN。

该观察不推翻API/DB权限负例，但WS端到端接受前须修复/测试；不据静态源码宣称WS PASS。

### 视频与AC05

H264素材可解码，但API因可信ffprobe缺失返回422且未建资产；Android picker/player未运行。AC04仅接受PNG API路径，视频链阻断。AC05仍OPEN：仅核对一份具名历史Review，保留call4/call5有限接受及旧token403；没有新合格双端、AEC on/off客观控制、同步revoke COMMIT与≤5秒媒体终止、native完整清理路径。真实Push PENDING；物理15/30天、真实L11 Cookie、逻辑数据库恢复仍NOT_RUN。

## 5. AC01–AC11裁决

| AC | Astra本轮分类 |
|---|---|
| AC01 | `DIRECT_GITHUB_OBJECT_AND_BOUNDED_PROTECTION_SUPPORTED`；具名资产保护及新独立库资格有界支持，非全盘审计 |
| AC02 | `NEW_API_DB_IDEMPOTENCY_RUNTIME_SUPPORTED / APP_DEVICE_NOT_RUN` |
| AC03 | `CURRENT_AUTHZ_AND_REAL_RR_OVERLAP_SUPPORTED / WS_DEVICE_NOT_RUN`；保留socket切号主动关闭观察 |
| AC04 | `REAL_PNG_UPLOAD_API_SUPPORTED / VALID_H264_FIXTURE / VIDEO_API_AND_ANDROID_PIPELINE_BLOCKED` |
| AC05 | **`OPEN`**；无新AEC、双端声学或5秒停媒证明 |
| AC06 | `REAL_HTTP_T0_REFRESH_SUPPORTED_WITH_TEST_INJECTION / PHYSICAL_TIME_NOT_RUN` |
| AC07 | `DART_PRIVATE_CACHE_LOGIC_SUPPORTED / ANDROID_CIPHERTEXT_NOT_PROVEN` |
| AC08 | `API_AND_WIDGET_NOTIFICATION_PRIVACY_SUPPORTED / OS_PERMISSION_GUI_NOT_RUN` |
| AC09 | `TEST_ONLY_PROVIDER_SUPPORTED / REAL_PUSH_PROVIDER_PENDING` |
| AC10 | `API_DB_WEB_HTTP_AND_MARIADB_RESTART_SUPPORTED / APP_UI_AND_BROWSER_UI_NOT_RUN` |
| AC11 | `CANDIDATE_DELIVERY_AND_GIT_OBJECTS_VERIFIED / ASTRA_BOUNDED_REVIEW_COMPLETE`；非整版接受 |

## 6. 保护资产与最终决定

Manifest记录旧Laravel11.48、dirty252、refs527、原HEAD/index、11,066文件/240,617,393字节备份元数据检查及160项SHA抽样通过；备份Manifest SHA256仍`3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`。旧0017账本SHA256 `c9cee51fe7aa8ddddc4dd34e92196442bc3c60416d59e1ae0665cdec7087a678`且永久STOP。无旧资产写入、无默认入口切换；这是具名范围保护核验，不是全盘审计或备份恢复证明。

**Astra接受本轮有证据的软件源码接续、PREPARE故障测试、指定Flutter/PHP软件回归、真实合成API/DB/Web HTTP及MariaDB进程重启结果，状态`V10.1.5_POST_0017_BOUNDED_ACCEPTED_WITH_OBSERVATIONS`。** 设备、Android、WS、视频、AC05及G2未通过部分继续保留；整版仍`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_FALSE / REAL_PUSH_PROVIDER_PENDING`。

Review文件只作独立审阅记录，不是产品合并许可或未来研发Parent。本轮审阅归档后STOP：不合main、不放行G2、不关闭AC05、不切旧默认环境、不启动v10.1.6、不自动派发下一任务。下一次如Owner授权，可针对WS切号主动关闭/地址配置、Android设备、ffprobe/视频链和AC05具名条件集中规划，不重做Laravel13迁移或本轮已通过的API/DB工作。

**结论：`ACCEPTED_WITH_OBSERVATIONS_IN_BOUNDED_SOFTWARE_AND_API_DB_WEB_SCOPE / FULL_V10.1.5_NOT_ACCEPTED`。**
