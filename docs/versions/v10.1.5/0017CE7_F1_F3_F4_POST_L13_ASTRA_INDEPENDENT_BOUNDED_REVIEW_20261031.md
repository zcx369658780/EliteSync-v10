# EliteSync v10.1.5｜0017ce7 F1/F3/F4 Laravel13 后续产品接续｜Astra 独立有界验收

日期：2026-10-31（Asia/Singapore）｜验收主体：Astra / EliteSync 长期 Product Advisor 与 Independent Reviewer。

**正式裁决：`V10.1.5_F1_F3_F4_SOURCE_AND_CONTROLLED_API_DB_ACCEPTED_WITH_OBSERVATIONS / TARGETED_FLUTTER_PHP_SOFTWARE_EVIDENCE_ACCEPTED_WITH_OBSERVATIONS / APP_DEVICE_E2E_NOT_RUN / ANDROID_CIPHERTEXT_AT_REST_NOT_PROVEN / WS_NOT_RUN / H264_NOT_RUN / AC05_OPEN / G2_FALSE / REAL_PUSH_PROVIDER_PENDING / V10.1.5_FUNCTION_PARTIAL_NOT_ACCEPTED / MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。**

**接受对象是本轮可证明的F1/F3/F4源码接续、受控本地合成API/DB/Web及指定软件回归；绝不是v10.1.5整版`FUNCTION_ACCEPTED`、全APP设备贯通、生产部署、真实系统Push、音质/AEC或G2放行。** 本文独立审阅Github原生对象、代码及脱敏Result/Manifest；Windows容器/Flutter/PHP/MariaDB/私有原始回执由Codex执行并提供摘要，Astra没有操机、读取私有行或重新运行程序。

## 1. 冻结任务与完整Git交付对象

- Owner正式任务 `docs/versions/v10.1.5/V10_1_5_POST_L13_F1_F3_F4_PRODUCT_CONTINUATION_AND_E2E_LONG_TASK_20261031.md`，Blob `9c7f4a9ad1b6e5d89e8976c39f4a4edb0e3c24dd`；原冻结 `docs/versions/v10.1.5/plan.md`，Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`，AC01–11不更改。
- 唯一候选Commit `0017ce7aa6b991360b2b26b7f5785b86bce2f369`，sole Parent精确为开工main `a71c1429a0bfaf9ed2fd379eb2944907dd057b7b`，Root `778437c50759cb5f057618ee95db78af981e4c89`。GitHub原生compare `ahead1/behind0`，恰好73个文件：71项源码及测试＋1份Result＋1份Manifest；递归候选Tree共6300条、`truncated=false`。
- 候选 apps Tree `2c72ceb889d95766a05c77047592f5886739d1c2`、services Tree `5033dd8e45979d3b01b904f0ea5951ed3f95d3df`；Parent apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `049a8676cc90b3b830e32a524c172720e800fa37`。本轮审查时main仍为原Parent，未合候选产品。
- Result Blob `8cd6affe37d2ec16ae08610a316df3145f7d7542`；Manifest为 `docs/versions/v10.1.5/v1015_post_l13_f1_f3_f4_artifact_manifest_20261031.json`，以该候选按路径回读的实际Blob为准。Astra逐项核Manifest `source_mapping`的71条 path/mode/native Git Blob/bytes与候选Tree **71/71完全相同**。另外2份文档确在compare新增，产品文件并未偷换。
- 报告记录从旧未整版接受的 `9b74ca6fef89e2507f966870c1f0d04f4fe09ba6`选择58个相关源码/测试路径，辅以本任务修订，而非将该旧完整产品Tree盲合到Laravel13 main。先前已接受Laravel13锁/114包与v10.1.4既有权限基础继续继承。

## 2. 直接源码核查的关键用途边界

本轮Astra实际从固定候选直接读取并审核了重要代码路径及选定对应测试/Manifest，而非只看Codex报告：

- **消息：** `ConversationAtomicSendService`在真实事务内先按顺序锁住两方User，再重验当前Sanctum token与既有消息idempotency replay；新写之前仍经`authorizeSend`，同键不同fingerprint走CONFLICT、权限失效走UNAVAILABLE。 `MessageController`的请求校验/响应、`MessagingReplayContract`的纯判断与Flutter `live_chat_page`的不可变attempt和跨session guard有可核来源。没有看到在此审查面内允许失效同意重新发送的新增直接通路；未宣称全WebSocket或所有设备失败时序已实测。
- **可信时间/离线：** `DeviceSessions`服务端用成功密码登录的`trusted_login_at`、当前device/session及有限onlineDeadline；refresh仅轮换令牌而不刷新原T0。`TrustedLoginTimeContract`拒绝未来或无效锚。`PrivateCacheService`只在收到绑定user/device/session/T0/服务器当前时间的login receipt后解锁；跨账号/旧代际晚写由generation guard阻断、清理对象优先写Manifest、30天测试密文删后读回并在失败时fail-closed；Flutter `session_provider`冷重启锁定，`AuthLocalDataSource`对旧明文私有keys进行按键清理。`LocalStorageService`通过`CacheKeys.isPrivate`将包括旧`lastKnownProfile`在内的具名私有值路由至安全存储，而非普通SharedPreferences。以上说明源码设计及软件测试覆盖，不证明Android硬件/插件真实密文落盘或实体物理30日。
- **通知：** `NotificationDeliveryService`仅local/testing环境允许test_only设备登记和尝试，存token_hash而非raw token；当前device-session、撤权、账号、偏好、通知presentation等在单次DB事务内核查，外发固定通用envelope。`NotificationPreferencesController`的authenticated route和Flutter通知设置为非生产Provider预留，不产生任何真实供应商投递成功。
- **WebSocket：** `ChatWebsocketAuthorizationService`的token与关系当前鉴权以及`ChatWebsocketServerCommand`定期reauthorize在源码可读，但缺实际可运行pcntl/可信启动，**WS端到端NOT_RUN**。不能把静态鉴权等同已验证WS连接/断线/恢复。
- **既有来源修正：** Flutter注册DTO中`realnameVerified: true`是Parent原有代码，后端注册明确将`realname_verified`落为false；本轮不把此旧客户端字段误签为真实实人认证。没有由本候选产生已实人核验的权限。

所查具体实现包括关键鉴权、中间件、消息幂等、设备会话、私有缓存、Auth DataSource、通知服务、Flutter重连/晚响应与多处Widget回归；71/71 Git对象身份核验不等于71文件逐行动态证明。

## 3. Codex本机运行证据的限定接受

| 范围 | 可接受的本轮受控证据 | 严禁提升为 |
|---|---|---|
| PHP/权限回归 | `128 tests/2593 assertions/exit0`；另`25/159/exit0`是重叠子集，不与128相加 | 整APP用户旅程或所有业务全量回归 |
| Flutter软件 | 本轮受影响`270 tests/exit0`，涉及跨账号晚响应、缓存有效期、失败写入、慢恢复、消息/通知等 | Android实际安装、原生密文或设备可用性 |
| 静态分析 | `flutter analyze exit1`，0 error/0 warning，8 info；报告称这8项均为Parent既有路径且未新增 suppress | `analyze PASS/exit0` |
| 合成HTTP/API/MariaDB | 真实Windows loopback登录/refresh、丢ACK后同键重放、不同payload冲突409、4并发1消息1通知、CN/MC/Block/禁用及越权负例 | Flutter APP操作、外网或真实用户/历史DB |
| 媒体 | 合成PNG关联、私有200/206 Range及越权/撤权404 | H264/APP picker/player、RTC音质 |
| 独立Web既有使用点 | 6项真实HTTP CSRF/合成管理员、最小用户状态与审计、普通用户拒绝，不暴露私聊 | 真实浏览器视觉操作/公开Web上线 |
| MariaDB持续性 | 新独立合成93表/173行，DB真实进程重启后逐表计数/全行Hash一致，聚合SHA256 `83566a12f55af53a760188ea7de7c02592981a91f7e52df39c05dc36f981ae8f` | 从备份重建、旧库恢复、长时间可靠性 |
| 保护和STOP | Codex报告旧dirty252/refs527/原Laravel11及11,066件备份保留，5个任务容器全停；不能直接从公开源码重算本地PRIVATE账本 | Astra现场逐个运行/全盘保护审计 |

Manifest包含106项具名process_receipts及19项显式历史失败进程回执，具备对应`prepare_seq`字段；这证明公开数据结构完整，**但不能倒推出原始LOCAL_ONLY每条在执行前都成功PREPARE**，详见第4节。

## 4. 必须保留的真实缺口与观察

1. **PREPARE事前记录缺口**：Codex承认本次task-owned `incoming/source.json`一次直接编辑前logger发生TypeError，随后58条Git Blob校验和fsync只能证明最后对象完整，**不能追认为该具体写操作已事前PREPARE**。归类为`RECORDED_PREPARE_PROCEDURAL_GAP / NOT_RETROACTIVELY_CLOSED`；相关写面限于任务自有输入，结果哈希和旧资产边界检查未发现已证产品/原证污染。该瑕疵不被重写为PASS，也不凭它否定别的独立真实运行回执。下一次独立授权的任务必须从执行入口修正日志失败前的fail-closed行为，不使用旧STOP预算追补。
2. **执行策略与来源观察**：一次shell源载荷被自动策略拒绝，报告未改变策略；随后通过具名直接文件编辑，不能冒称原shell已成功。一个只读辅助曾使用旧dirty索引，其结果已排除权威。本轮没有因此写旧目录；保留原事故标签。
3. **Flutter analyzer**：`exit1 / 0 errors / 0 warnings / 8 info`，保留非零退出码；是否清理info按未来直接相关工作而非当前必须重做全部功能。
4. **运行缺口是真正的缺口而非FAIL**：APP/AVD/Gradle资格未成立，故`SAME_SOURCE_APP_API_DB_E2E`不能计PASS；Android系统加密原生plugin实际密文、OS权限GUI/锁屏、WebSocket缺pcntl、合格H264素材、物理15/30天、真实L11 Cookie与DB逻辑备份恢复都NOT_RUN或NOT_PROVEN。
5. **冻结安全门不变**：AC05 RTC/AEC/5秒媒体停止仍OPEN；G2 false；真实Push provider PENDING；v10.1.6未启动。旧`WINDOWS_E_NOTIMPL`、交叉尝试预算不合规、fixture修复未证、限制身份、OS全局enforcement和早期只读回执缺口均保留。

## 5. AC01–AC11独立分类

| AC | 本次Astra裁决 |
|---|---|
| AC01 | `SOURCE_AND_BOUNDED_LOCAL_PROTECTION_SUPPORTED`；非全盘审计，PREPARE gap保留 |
| AC02 | `API_DB_IDEMPOTENCY_AND_FLUTTER_SOFTWARE_SUPPORTED / APP_NOT_RUN` |
| AC03 | `CURRENT_AUTHZ_NEGATIVES_SUPPORTED / WS_DEVICE_NOT_RUN` |
| AC04 | `SYNTHETIC_PRIVATE_IMAGE_200_206_SUPPORTED / VIDEO_APP_NOT_RUN` |
| AC05 | **`OPEN`**，本轮RTC受影响权限回归不关闭AEC/5秒合同 |
| AC06 | `REAL_L13_HTTP_T0_REFRESH_SUPPORTED / PHYSICAL_ELAPSED_TIME_NOT_RUN` |
| AC07 | `FLUTTER_CACHE_LOGIC_SUPPORTED / ANDROID_CIPHERTEXT_NOT_PROVEN` |
| AC08 | `API_WIDGET_NOTIFICATION_PRIVACY_SUPPORTED / OS_GUI_NOT_RUN` |
| AC09 | `TEST_ONLY_PROVIDER_ISOLATION_SUPPORTED / REAL_PUSH_PENDING` |
| AC10 | `SAME_SOURCE_API_MARIADB_WEB_SUPPORTED / FULL_APP_E2E_NOT_RUN` |
| AC11 | `CANDIDATE_OBJECTS_AND_DELIVERY_SUPPORTED / FUNCTION_ACCEPTANCE_NOT_GRANTED` |

## 6. 决议与明确停止

**Astra独立接受该单份候选中可证明的软件源码/合成环境实际API-DB-Web和指定回归结果，状态`V10.1.5_F1_F3_F4_BOUNDED_ACCEPTED_WITH_OBSERVATIONS`。** 未发现本轮定点审查内新确定的高置信服务端权限/缓存/幂等P1/P2足以否决这些有限结果；此结论不是对未知Android/WS/RTC运行能力的无条件背书。

整版仍为`V10.1.5_PARTIAL_NOT_ACCEPTED / 10_PARTIAL_1_OPEN / AC05_OPEN / G2_FALSE / REAL_PUSH_PROVIDER_PENDING / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。本审查分支与文件**只作独立审阅记录，非未来研发sole Parent、非main产品合并许可**。现在不自动下发下一任务、不重开预算、不切换Laravel11旧默认目录、不删除备份、不合main、不放行G2/AC05。后续可由Owner明确授权的合并软件功能测试/设备贯通任务集中收口APP密文、WS、H264及RTC具名门禁；不得为了设备/供应商缺口重做已接受的L13迁移及本轮PHP/Flutter软件成果。

**结论：`ACCEPTED_WITH_OBSERVATIONS_IN_BOUNDED_F1_F3_F4_SCOPE / FULL_V10.1.5_NOT_ACCEPTED`。**
