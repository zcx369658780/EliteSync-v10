# v10.1.5 产品主线源码修复与同源E2E资产交付

结论：**V10.1.5_MAINLINE_SOURCE_AND_E2E_HARNESS_CANDIDATE_DELIVERED_AWAITING_ASTRA_REVIEW / DELIVERED_PARTIAL_WITH_EXPLICIT_RUNTIME_GATES**。交付真实消息页面修复、3项新增Widget回归源码、可执行HTTP/DB驱动/合成夹具/证据收集与APP观察协议。真实Flutter/APP/API/DB整链 **NOT_RUN_GATE_CLOSED**；不自签产品接受。

## 权威、固定来源及保护

正式任务Blob `1db7fc7eaadcea172cc52016904836bd71a0b90d` 已fresh按路径读全文；开工main `f43d7e213589a916fc04de771b76b76951f9b3bb`，Root `d0376f1c49d04fe095cd604628b9705ed8e0e65b`，ACTIVE_STATE `5592cc36ff56965d126d410ed333d998fa6c093c`。协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`、当前工作流 `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03`、原AC矩阵 `4d3593925d3676722f59d29c324963842a217eb5` 均重新读取。

唯一研发Parent `0577f030f6e3bbecae611433daa226719a7cc4b0`，Root `4d024bb4d931a346f237614efa7940451a39678e`。前置Astra `9a2df55a6ea3846c8bec6711a6fee0f57663d34f`、Widget/MariaDB Astra `715bc340042675df86a0c791c49eb1852bb9b5ce` / `dc5a6d21e9c22f8e28b81cec7317aa740c9bd8db` 及报告/索引按固定Parent路径读取。Parent产品apps `798049a15eb33fec16acdd37d83a07af0ed181b5`（729）/services `9bba2938aa41ad3eaee501ef88bfeecdee797591`（716）。仅从具名既有源码副本读取并按fresh GitHub固定Tree逐Blob验证后复制 **1445/1445产品文件**，无缺失/字节不符；没有复制SDK、datadir或vendor。完整父Tree元数据保留，非改动路径按原Blob发布。

main唯一已接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` /services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。未接受v10.1.5候选不自动成为main。原dirty工作树只读且不作为写面；旧18、两ACL树、122原证、五根、527refs、Seed3183、旧失败/claims/账本不改、不重扫ACL。

## 确证缺陷与实际产品实现

**F1：unknown POST的key/payload可被新草稿覆盖。** Parent `live_chat_page.dart` Blob `76745e44e53b27c26f97b7365f8232892920ab07` 在同payload才复用_attempt；超时/5xx保留attempt但编辑器、发送与媒体按钮仍可操作，改字或换附件再发送会覆盖原key。原请求可能已提交，原尝试失去确认/重试入口。同页暂停逻辑还在非picker时清掉_attempt，而取消HTTP不证明服务端未提交。

现 `_post` 对未确认尝试始终使用其不可变peer/content/有序attachmentIds及clientMessageId；未确认或进行中的编辑、新发送/媒体入口锁定，仅原编号重试可继续。暂停隐藏私密UI但保留该同账号未确认尝试，恢复仍先真实联网重新验权；换号、退出、明确撤权/可信时间异常继续清掉私密数据与尝试。只有当前session/epoch下服务器确认匹配key和numeric id才清空并显示确认。

新增3项Widget源码：unknown后程序性改controller也只能重试原payload；unknown附件只重试同asset且不再上传；pending POST→pause/resume→旧结果丢弃→同key重试。原Widget测试正文完整保留，新增前后原testWidgets声明+3，负向权限断言未删。**这些测试本轮未执行，也未运行Dart类型/语法分析器**；不能以文本/源审称真实Widget通过。

**F3/F4边界核对。** 服务端登录T0/refresh与客户端账号设备namespace、凭据队列、重启锁定，以及通知偏好、TEST_ONLY设备/session与当前点击授权的已读契约对齐，未发现足以定性的新缺陷，因此不重写系统。重启后不恢复不可信read grant是明确保守策略；真实Push未接入是明确PENDING，均不编造bug求改动。实际设备加密、清理与物理时间仍未证。

## 可执行E2E资产与真实资格接线

`tools/v1015/mainline_e2e/`交付驱动、纯契约、15个场景JSON、安全空配置、APP观察模板、纯自测及README。未来另获运行许可后，驱动真实登录/刷新、发消息/同键重放/异payload409、上传PNG、数据库回读消息/附件/通知唯一性、失败asset原消息重放、Block/MC/CN/禁用撤权及旧media/notice、偏好/静默/OS拒绝契约与TEST_ONLY最小payload。实际HTTP状态/响应字节、SQL计数、PHPexit和操作预算写LOCAL_ONLY持久账本。

合成夹具只在未来已迁移且空的新MariaDB里创建10个普通虚构账号/5对独立关系；不reset已有库。每对仍调用实际LiveConsent转换。图片为确定性一像素PNG；没有假造可播放的短视频或ready状态，合法私有MP4缺失时场景保持NOT_RUN。响应丢失采用“记录并抑制应用ACK”，不冒充物理断网或真实丢包。

现有环境资格仅列旧端口，旧测试guard固定旧task/43329，不能为新运行误用旧实例。为使未来驱动可接入新空库，`LiveConsentService`保留final和全部原业务逻辑/旧allowlist，仅testing分支允许一个具名容器资格回调，必须严格返回true；正常public/index不注册。非生产 `tests/E2E/server.php`/bridge先核新Owner上下文、版本源Hash、127.0.0.1:43349/43359、私有datadir/server_id/actor及schema/PUBLIC grants，再注册每次复核的callback。没有测试HTTP种子端点、请求头绕过、业务鉴权替身或全局开放端口。

路径检查先于context读取，拒绝网络/device与原始路径折叠，检查私有root内祖先；Python检查native reparse，PHP检查raw/canonical及链接。**未来Windows原生路径/子进程/写入闭包尚未运行资格化**；JSON字段是可信操作员一致性约束，不是Owner加密签名或恶意代码sandbox。严格输入/权限/峰值环境门仍需新授权后验证。

APP侧交付观察动作与可验证artifact/source/APK身份协议，**没有自动设备点击驱动**。API/DBdriver不能替APP模拟登录/导航/Keystore；没有真实APP证据的项明确NOT_RUN。导入观察回执只检查来源声明与artifact Hash，不独立判定截图语义；驱动始终 `e2e_pass=false`，留Astra功能裁决。当前真实WS backend是501/503占位，不能将HTTP占位或客户端Mock称已贯通WS。F2 RTC/AC05、F5旧资产没有扩范围。

## 实际检查、源审与失败保留

- **Python15项纯契约PASS，exit0**：默认inspect无写入、当前task运行0、新授权/端点/源绑定/时效/预算、重复ledger不退款、DB重复计数拒绝、T0期限、通知隐私、Mock/错源/坏artifact不能升级APP、15场景ID及NOT_RUN完整性；Popen/socket/system/startfile均由拒绝替身守门。AST/JSON语法检查完成，非真实HTTP或DB。
- **PHP14项纯资格/接线PASS，exit0**：无PDO、无Laravel vendor/bootstrap/服务；验证新环境限定、错误来源/端口/库/权限、源Hash与路径穿越，实际production final service在fake Application下验证strict true/false/truthy/异常不会fallback。5个PHP文件显式语法exit0，生产service亦在纯测试中被PHP解析加载。它不证明实际MariaDB连接或业务运行。
- 非作者Sol/high只读复核发现并修正final继承不可执行、context先读路径、pause丢key；最后定点源审无新增阻断。该审查与主实现自检均不替Astra独立验收。
- 原失败LOCAL_ONLY保留：首次纯Python在新目录创建后import缓存未刷新，0测试ModuleNotFoundError；invalidate_caches后通过。PHP路径检查走出私有open_basedir导致拒绝，缩到私有root并保留root canonical资格；纯fake Application起初不接受Laravel environment数组调用形状，修fixture后通过。未放宽open_basedir、真实网络/进程或产品负向断言。中间失败回执未删除。

不重跑已接受的23 Feature/152断言、77 Widget或42 Hook测试。真实Flutter/Dart、Laravel Feature/vendor/bootstrap、MariaDB连接/迁移/服务、API服务、Gradle/JVM/G2/claim、APK/ADB、设备/RTC/Push/现网均0。允许的PHP纯语法/无框架契约CLI与API/server执行严格分开。

## SOURCE_TO_E2E及下一次授权

`SOURCE_TO_E2E_CONTRACT_MATRIX_20261029.json`覆盖AC02/03/04/06/07/08/09/10，绑定源Blob、15个场景与证据层次；源实现/纯检查/历史有界证据/同源真实E2E/设备物理门分列，所有AC仍PARTIAL、AC05 OPEN。冻结计划和原11行矩阵原字节保持。

`FOLLOWUP_OWNER_AUTHORIZATION_SPEC_20261029.md`集中给出新root/端口/库/两服务启动上限、160HTTP/48CLI、1迁移/1seed、私有工具闭包及3批定向Flutter/8GiB/90分钟的**建议**；当前不批准、不派发。APP构建/安装需另具名激活且先有独立Gradle/G2资格，未闭合则仅API/DB软件证据，不能宣称整链APP成功。物理15/30日、Keystore/实际删除、RTC/AEC与Push独立保持门禁。

## 制品、空间与STOP

本轮唯一task `V1015_APP_API_DB_MAINLINE_E2E_20261029` / attempt-0001，新源码工作面与持久ledger。产品导入/源码每写前PREPARE flush并记录前后Hash；中断沿用原根。开工全量源码逐Git Blob校验1445/1445；新增产物logical/allocated约95MiB，终态native AllocationSize观测与metadata预留保存在LOCAL_ONLY budget-terminal，均远低于536870912 bytes。离散检查不称连续峰值证明。

候选apps Tree **03ba3602a7dc807bf963264e24f33eed01c231c8**（729 Blob）；services Tree **32229dce88cf497fea43904fea3dbb69a9410b8f**（720 Blob）。Manifest列全部变更Parent/final Blob和SHA256；未改动Parent根文件原Blob保留。GitHub最终Commit/sole Parent/Root/逐变更原字节及完整双产品Tree/main回读由terminal receipt独立记录，不在自引用文件伪造候选Commit。

DIRECT_GITHUB_OBJECT仅用于直接读取的Authority/源码/远端对象；CODEX_REPORTED_LOCAL_TEST仅本轮纯检查及明确引用的历史运行摘要；原路径/Token/日志/SQL/ledger为LOCAL_ONLY_RAW；真实整链 `NOT_RUN_GATE_CLOSED`。没有上传私有文件、凭据、原始系统日志、第三方私有patch或数据库。

旧Flutter6/6、MariaDB2/2、G/APK各1/1耗尽，旧API余额无本任务权限；旧ACL事故永久封存不退款。保持 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_READY_FOR_POPEN_FALSE / PRODUCT_MAIN_NOT_INTEGRATED / REAL_PUSH_PROVIDER_PENDING / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / RTC_AEC_NOT_CLOSED / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / V10.1.6_NOT_STARTED`。

**一次集中候选后STOP，等待Astra独立验收；不合main、不关闭AC05、不放行运行或派发后继。**
