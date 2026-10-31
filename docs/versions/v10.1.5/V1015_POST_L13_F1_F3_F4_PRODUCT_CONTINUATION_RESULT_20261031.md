# v10.1.5 F1/F3/F4 Laravel13 后续集中结果（2026-10-31）

**DELIVERED_PARTIAL_WITH_EXPLICIT_GATES / AWAITING_ASTRA_REVIEW / V10.1.5_PARTIAL_NOT_ACCEPTED**

本轮在已接受Laravel13/PHP8.4主线中选择性接续F1/F3/F4，完成真实Windows回环API/MariaDB及已有Web管理使用点验证。APP设备、Android实际密文、WebSocket和H.264运行未完成，不能据此签署整版功能接受。AC05 OPEN、G2 false、真实Push PENDING，未启动v10.1.6。

## 对象与范围

- Task：`V1015_POST_L13_F1_F3_F4_E2E_20261031`；正式任务Blob：`9c7f4a9ad1b6e5d89e8976c39f4a4edb0e3c24dd`；冻结plan Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`。
- 开工fresh main/唯一Parent：`a71c1429a0bfaf9ed2fd379eb2944907dd057b7b`；Root：`de3ac6532788cc1cc91f8bcadcf50616f7f05b6c`。发布前fresh main仍相同；没有采用Astra Review或STOP分支作研发基线。
- 原产品apps/services：`3468a3dd97da7accfda2539a0f8d8f68931a6110` / `049a8676cc90b3b830e32a524c172720e800fa37`。
- 本候选apps/services：`2c72ceb889d95766a05c77047592f5886739d1c2` / `5033dd8e45979d3b01b904f0ea5951ed3f95d3df`。
- 两份交付文档加入前源码Root：`673d3465436aad081550e680a8637e10b62b7d31`；最终候选Commit/Root取其原生Git对象及发布回读，避免报告自包含自身Hash。
- 从`9b74ca6fef89e2507f966870c1f0d04f4fe09ba6`选择58条F1/F3/F4源码与测试；最终71条产品/测试路径。没有整树合入该未整版接受候选。完整旧Blob、选入Blob、最终Blob/mode/SHA256和本轮修订映射见Manifest。

## 真正实现与修复

F1保留现有MariaDB事务和授权锁，接入幂等回放契约、发送attempt、当前账号代际和私有媒体读取；真实丢ACK代理在上游提交后丢弃下游响应，同键重试仍返回原消息，四并发收敛为一条消息和通知。Block、MC撤销、CN关闭和第三账号均不复活消息、旧媒体URL或旧通知导航。

F3后端密码登录生成账户/设备/会话T0，refresh保持T0和15/30天期限（server_now正常推进）。Flutter私有缓存经账号/设备隔离安全存储入口；冷启锁定，普通token/profile不能恢复私密界面。补修裸Dio重试切号晚响应、在线列表15天仍显示摘要、聊天延迟200跨期限/安全写入失败仍显示、以及空白慢恢复被过早锁定。相关失败均先复现后修复，保留原始回执。内存安全存储替身、Widget与回环测试不证明Android硬件/插件落盘密文。

F4新增类别偏好、静默和测试替身token生命周期；数据库实际检查无原token列、token_hash均为64位hex。替身回执只有通用文案，不调用真实供应商；轮换、去重、拒绝/撤回/Block均受当前授权约束。真实系统通知GUI和后台投递未验证。

L13的composer.json/lock和114包vendor来源保留；未运行Composer安装/求解、镜像下载或构建。旧开发数据库固定白名单保留：新增server-owned私有实例资格绑定，只有本轮CLI/router实际核对schema/port/host/actor/server_id和精确grants后启用，业务权限判断不变。资格负例6项及正确实例实测通过；历史无关白名单/旧任务门没有重新开放。

## 实际验证与失败分类

| 项目 | 本轮证据 |
|---|---|
| PHP8.4.27 / PHPUnit12.5.42 | 受影响权限组128 tests /2593 assertions /exit0；最终窄门与F1/F3/F4子集25/159 /exit0，存在重叠，不能相加冒充独立测试数 |
| Flutter3.41.7 / Dart3.11.5 | 最终受影响软件组270项 /exit0，含Auth、缓存、消息、通知、晚响应、保存失败、慢恢复；离线锁定依赖准备，没有新供应 |
| Flutter分析 | exit1，0 error、0 warning、8 info；全部报告路径与Parent字节相同，未新增抑制。不是“分析全绿” |
| 实际API/DB | 密码登录/refresh、消息回放/冲突、真实丢ACK、四并发、第三方/Block/MC/CN/禁用/过期负例；MC并发竞争本次send404，终态后数据无新增副作用 |
| 私有图片 | 合成PNG经真实附件关联，200/SHA256及206精确Range、第三方/撤权404；未执行APP picker/upload或H.264 |
| Web | 6项真实HTTP检查：CSRF＋合成白名单管理员登录、同库最小用户状态/审计、无私聊内容、普通用户拒绝；没有新增大面板，未声称视觉浏览器验收 |
| MariaDB10.11.19 | 新独立93表/173行在真实进程停止/启动后逐表行数、全行Hash及实例身份一致；聚合`83566a12f55af53a760188ea7de7c02592981a91f7e52df39c05dc36f981ae8f`。非逻辑备份恢复证明 |
| 数据库断连 | 健康请求25秒超时，保留失败；之后受控启动恢复，健康与撤权负例通过。未将超时写成503响应 |
| 非作者复核 | 独立只读Sol/high完成有界复核；发现均有代码修复与定向测试，最后慢恢复条件已复核。不是Astra验收 |

原始回归失败包括：旧测试未建立现行互相接受关系/可信登录、旧通知缺当前权威指针，及缺失wsBaseUrl字段。补齐真实fixture/配置字段，保留业务断言、鉴权与限流。HTTP harness的server_now比较、类别单复数、路由前缀、通知输出形状、生命周期步骤等普通错误已在同任务内修正；失败、超时和重试均留在新账本。Manifest列出所有有记录的进程退出与stdout/stderr Hash。

## AC01—AC11分层

| AC | 状态 | 证据与限制 |
|---|---|---|
| AC01 | SOURCE_AND_LOCAL_PROTECTION_PASS | fresh main/native source binding; isolated DB qualification; unchanged dirty252/refs527/index/HEAD and named backup/seals; bounded scope only |
| AC02 | API_DB_PASS__APP_NOT_RUN | real Windows HTTP, dropped downstream ACK after upstream commit, same-key retry, conflict409, four concurrent requests -> one message/notice; final replay/readback; Flutter retry/widget regressions |
| AC03 | API_DB_AND_SOFTWARE_NEGATIVES_PASS__WS_DEVICE_NOT_RUN | third actor404; Block and MC/CN revocation, disabled/expired/rotated tokens, private URL denial, old notification no navigation; actual MariaDB send/revoke race serialized as404; no post-terminal side effects |
| AC04 | SYNTHETIC_PRIVATE_IMAGE_API_PASS__VIDEO_APP_NOT_RUN | actual PNG fixture attachment and exact SHA256/200/206 byte range; unauthorized and blocked404. No APP picker/upload or legitimate H264 fixture executed |
| AC05 | AFFECTED_PERMISSION_REGRESSION_PASS__AC05_OPEN | affected RTC authorization/retry tests included; no SFU/real device/AEC/acoustic or5s media-stop execution; G2 false |
| AC06 | REAL_HTTP_T0_REFRESH_PASS__TEST_INJECTION_BOUNDARIES | password login binds account/device/session/T0; refresh preserves login/deadlines but server_now advances; old access401; own family16day injection401; Flutter15/30 boundaries. Physical15/30days NOT_RUN |
| AC07 | FLUTTER_SOFTWARE_PASS__ANDROID_ENCRYPTION_NOT_PROVEN | account/device secure-store adapter, cold restart lock, owned fake-store deletion success/failure, clock anomaly, delayed200 deadline, failed secure write, offline read-only and slow resume tests; fake/platform adapter is not Android ciphertext-at-rest evidence |
| AC08 | API_DB_AND_WIDGET_PASS__SYSTEM_GUI_NOT_RUN | category/silent persistence, permission-denied token revoke, current click/old route checks; affected Activity/Safety negatives; OS permission UI and lockscreen not exercised |
| AC09 | TEST_ONLY_PROVIDER_PASS__REAL_PUSH_PROVIDER_PENDING | registered hash-only token, generation rotation, dedup, silent/denied/revoked/Block suppression; fixed generic envelope, real transport rejected. DELIVERY_NOT_VERIFIED for real provider |
| AC10 | API_MARIADB_WEB_PASS__FULL_APP_E2E_NOT_RUN | same product source: Windows API and existing Web admin synthetic state; ordinary user rejected; actual93table/173row MariaDB process restart full-row aggregate unchanged; database-down health request timed out; exact failing receipt retained |
| AC11 | CANDIDATE_PREPARED_FOR_NATIVE_PUBLICATION_AND_ASTRA_REVIEW | one non-main non-force sole-parent candidate, source mapping and sanitized receipts; bounded non-author fixes reviewed; GitHub readback and STOP recorded by delivery companions, not acceptance |


上述本机结果属于`CODEX_REPORTED_LOCAL_TEST`；源码为`SOURCE`，合成时间窗为`TEST_INJECTION`，原始资料为`LOCAL_ONLY_RAW`。没有本轮`DEVICE`成功证据。不得用历史R1 Android34/34或旧RTC有限证据冒充本候选APP运行。

F5只进行一次有界具名源清单/接受结论核查，输入及Blob见Manifest：旧语音留言`UNKNOWN`、完整地图`UNKNOWN`。既有地点/profile契约不等于原地图恢复；没有继续考古或新增业务。

## 保护、资源与回滚

本轮唯一新root、attempt-0001、独立持久账本，不使用任何旧STOP余额。旧dirty252、refs527、原HEAD/index及Laravel11.48/vendor身份核对通过；11,066文件/240,617,393字节备份的目录身份、逐文件身份/大小和160项SHA抽样通过，Manifest SHA256仍`3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`。具名历史原证/STOP封存以及前两轮本地入口任务账本Hash保持不变。这是明确范围的核查，不是全盘内容重扫或新恢复演练。

任务没有Owner数值硬次数/时长上限；没有借用旧预算。文档冻结时单调用时约47.7分钟；末次目录逻辑空间2,555,039,773字节、保守分配上界2,694,987,776字节，新DB卷163,716KiB。新增公网依赖供应、Composer安装/solver、Docker pull/build、全局操作和旧资产写入均0；活动计数见Manifest，终端账本另保存实际发布后总量。没有声称OS强制网络计量或完整恢复证明。

本轮5个自有容器最终全停，镜像/数据卷均保留；宿主代理已退出。旧默认Laravel11未切换。回滚只需不集成本候选；若未来获准集成，按本次Parent及逐路径映射恢复产品源码，数据库迁移只用于新合成库，不能在旧库执行破坏性down。重启本轮环境须新的有效任务权限，不自动复活账本。

## 完整性观察与剩余门禁

必须披露一处真实PREPARE缺口：写入本轮`incoming/source.json`前日志调用发生TypeError，直接文件编辑已完成；后续58条原生Blob校验和fsync不能倒填成事前合规。另一次shell源载荷被自动执行策略拒绝，未执行；随后使用直接文件编辑工具，无修改策略或另换shell重试。一个只读辅助定位使用了旧dirty索引，其结果排除出源码权威；最终保护Hash不变。PHP负例harness初次正例遇缓存连接错误，Laravel渲染异常但exit0，stdout判为失败；修正后6负例与正例JSON才计PASS。以上保留，未声称账本完美无缺口。

APP/AVD/Gradle执行资格未成立，APP/API/MariaDB/Web完整同源E2E为`NOT_RUN_GATE_CLOSED`；可信镜像缺pcntl，WebSocket运行`NOT_RUN`；Android实际密文/OS权限/锁屏、合法H.264素材、AC05声学与5秒停止仍待具名条件。真实Push供应商没有授权，继续`REAL_PUSH_PROVIDER_PENDING / DELIVERY_NOT_VERIFIED`。只需要集中评估这些设备/原生能力和素材门，不重做框架迁移、114包安装或已完成环境任务。

原四历史事故及`WINDOWS_E_NOTIMPL`、`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`、`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`、`RESTRICTED_IDENTITY_GATE_BLOCKED`、`OS_ENFORCEMENT_NOT_PROVEN`、`EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED`继续保留；物理15/30天、真实L11 Cookie、逻辑DB备份恢复仍NOT_RUN。

本轮只发布一个普通non-force、sole Parent精确绑定的非main候选。最终原生Commit/Root、全部73条变更path/mode/Blob和完整产品双Tree、最新main由GitHub回读固定在LOCAL_ONLY交付回执；本报告不把对象发布当运行或接受证明。完成回读后永久STOP，等待Astra独立验收；不签FUNCTION_ACCEPTED、不合main、不关闭AC05、不放行G2、不切默认入口、不清理旧资产、不启动v10.1.6。
