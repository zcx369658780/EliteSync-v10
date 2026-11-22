# P0.4.2 R1｜Builder 修复与独立 L3 回执

2026-11-22，北京时间。`R1_PARTIAL`，候选 `1011807` 的构建门关闭。封闭内测与生产均为 `NO_GO`，最终状态由 Owner 裁定。

本轮开工时，工作树位于 `D:/EliteSync-v10/build/p042-v2-worktree`，分支 `codex/v2-function-completion-20261121`，暂存区与工作区干净。本地 `465cc5507d8f1aca6de66e3778c55ca4ade65150`、GitHub 分支 `32b6065943104f5cc094d59542d878258abf9e6d` 实时核对同为 tree `5d0bd96fc269a549ff6b9a4b787a6a10e20e77a4`。

原始证据留在 `D:/EliteSync/development/v2-cloud-r0-local-runtime-20261121/p042-r1-local-20261122`。其 `RUNTIME_RECEIPT.md`、`13-widget-cases.json`、`22-php84-regression.log`、`27-mariadb-completion.log` 记录了上一轮 65/69 Flutter（62/66 Widget）、56/57 PHP 8.4、8/9 专用 MariaDB 和 4/4 真实 WebSocket。本机回执确认原专用发行版 `EliteSync-V2-Cloud-R0-20261121`，专用库 `elitesync_v2_function`、MariaDB 10.11.19、`server_id=2621121`、`REPEATABLE-READ` 和卷 `elitesync-v2-function_r0-dbdata`。本会话仍为网络禁用，独立回环返回 `10013`，WSL 枚举返回 `E_ACCESSDENIED`，桌面会话读取返回 `-32000`。本会话无法独立回读专用库运行身份。

## 修复范围与逐项证据

| 原失败 | 本轮变更 | 本轮结果 |
| --- | --- | --- |
| 保留列表刷新的两项 Widget 测试在第 245 行观察到请求数 1 | 保留列表和聊天页在恢复事件中同步使共享授权失效，全部生命周期观察者结束后，通过微任务开始重新读取。原前台、会话、epoch 守卫继续执行。 | Dart 定向分析通过。最短套件启动后，`flutter_tester` 连接 `127.0.0.1` 返回 `10057`，业务断言执行数 0。修复后其余四套待执行。 |
| 换代历史测试找不到 `fictional message 2` | 先断言旧历史页使用游标 `5`，再滚动反向惰性列表使旧消息实际进入视口，然后按原测试检查换代后旧历史及离线副本。 | Dart 定向分析通过，目标 Widget 待执行。 |
| 24 小时文字离线测试读取空 `TextField.controller` | 断言实际 `EditableText` 的控制器为空；继续检查只读和发送、草稿操作不可用。 | Dart 定向分析通过，目标 Widget 待执行。 |
| 双方向并发中，A Block B 的同键重放及 B Block A 的读取先后发生 500 | Block、直接消息授权、读写和共享用户权限检查采用逐个主键查询，按用户 ID 升序加锁。锁后继续检查会话、Block、CN/MC、代际及重放权限。 | 六份改动 PHP 源码语法通过。专用 MariaDB 同源并发与真实 Workerman 定向复验为 `NOT_RUN`。 |

MariaDB 原始 `25-r1-app-raw.log` 与 `29-r1-app-final-raw.log` 均为 `SQLSTATE[40001] / 1213`，受害栈在 `DenyUnverifiedMessagingLiveAccess` 首个 `users` 锁定查询。Block 路径按双用户、封锁行、关系撤权的顺序进入；直接读取和同键重放先经同一中间件锁双用户，再检查凭据及会话授权，内部路径再取用户与相应凭据、消息或重放记录。旧批量 SQL 都指定了返回顺序。原日志缺少 InnoDB 对手事务的持锁与等待边，因此实际锁环仍未知。此次变更固定具名入口的物理请求顺序。批量会话列表、Workerman 外层及部分授权服务仍有批量锁，按原边界保留并列入复验。若再次出现 `1213`，应在原专用引擎立即采集脱敏的 InnoDB 两条事务持锁和等待记录。

PHP 8.5.3／SQLite 内存库辅助检查中，消息、WebSocket 授权、同 CN 的 MC 换代隔离和隐私幂等共 19 项、164 断言通过。扩围 58 项、616 断言中 51 项通过。六项附件或媒体读取失败均为 Symfony `File must be readable.` 导致的 500，第七项为历史 `409/200`。Windows PHP 的 `is_readable` 对可由 `require` 加载的 vendor 文件也返回 false，因此使用 scratch 配置和显式 autoload 执行，数据库仍强制 SQLite 内存库。上述结果不能替代 PHP 8.4 或专用 MariaDB 验收。

## 独立 GPT L3 与 409/200

非作者 GPT L3 复核 Flutter 的失效时序、原断言、后端锁后重验、代际隔离和复验边界。结论为静态范围可接受、运行验收待补，未发现 P0/P1 源码问题。双向并发零 `1213` 或 500、以及同源 WebSocket 握手、撤权关闭、重连和新代窗口均须通过后再判断构建门。

`V1011SocialTest.php:75` 重复提交同一组隐私字段及旧 revision `0`，期待 `409`。既有 `PrivacyController::save` 在字段完全相同时走无修改的幂等路径，返回 `200` 和当前 revision。`V10111AccountSupportTest.php:94` 把等值重放 `200` 和异值陈旧写入 `409` 均列为显式断言，其用例本轮通过。旧用例在冲突断言停止，后续 preview/unfriend 断言未执行。历史与新增回执保留。需 Owner 决定是否单独修订这一条旧测试，范围为等值重放 `200`、异值陈旧写入 `409`，随后继续原权限断言，生产合同保持现行定义。

## 本机续验与 APK 门

1. 在原本机 Codex 重新核对同源工作树、回环与专用引擎身份。先用 `D:/flutter/bin/flutter.bat --no-version-check test --no-pub --machine test/features/chat/presentation/pages/live_chat_retained_list_cache_test.dart` 达到实际 2/2，再按 `13-widget-cases.json` 的五套范围复验。
2. 对最新源码的 PHP 8.4、原专用 MariaDB 及真实 Workerman 重新取证。用具名合成夹具覆盖两方向 Block 同时读取、同键重放，记录全部 HTTP 指标和新增 `1213` 计数。Block 提交后读取和重放须拒绝，换代只返回新代消息，旧行完整保留。
3. 构建门全通过后产生 ARM64 release AAR 和独立 debug APK。固定 APK 路径、包名 `com.elitesync.v2functionp042r1`、版本码 `1011807`、签名证书指纹、文件 SHA-256、原生与 Dart 实际端点、TLS 身份和 AAR/APK 的 `libapp.so`。以此为交付终点，实体安装等待 Owner 对这个 APK 和 `25060RK16C` 的单独授权。

本轮未访问实体设备、改动 1011805/1011806 及其数据、操作专用数据库卷、启动构建或覆盖原始证据。1011806 A09 FAIL、PHP 409/200 FAIL 和历次 1213 与 500 证据保留。
