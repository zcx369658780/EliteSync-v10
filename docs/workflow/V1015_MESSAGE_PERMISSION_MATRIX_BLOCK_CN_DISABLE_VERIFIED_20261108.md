# v10.1.5 Block、CN关闭与peer禁用真实并发通过｜2026-11-08

**REAL_MARIADB_BLOCK_CN_CLOSE_PEER_DISABLE_HANDOFF_VERIFIED / BACKEND_SUBSET_PASS / SPENT_1_REMAINING_0 / AC03_PARTIAL / G2_FALSE**

Owner明确回复“批准修正候选运行一次”，为已保存的设备ID修正候选另授一次。新任务`V1015_MSG_CONCURRENCY_20261108_03`，只验证Block、CN关闭、管理员禁用peer三组后端场景；[前次首登录422停止](V1015_MESSAGE_PERMISSION_MATRIX_LOGIN_STOP_CANDIDATE_20261108.md)的输入、claim、STOP及已耗1余0保持，不退款、不复用。前次422的字段响应未捕获；本次成功不改写其唯一原因UNKNOWN。

## 实际输入与串行场景

批准候选SHA256 `d34e64f9a5b6f5185c62527fa295e63d92639c1346c959efe342814b4911adfd`。功能修正仅为设备ID长前缀；新一次必要的任务/容器/DB/网络隔离身份适配另有hash回执。公开探针代码固定ac867637，实际输入提交`84b3be96286652df612e16f5a3b4d67908ca9799`；APP/授权/消息服务未改，apps树b673913a4ff0ff1a8bfc83ca98951ff1556a2f23、services树4530ae85754a2f3698d073182a47038708f2cb55保持。复用726文件只读服务快照/114包vendor，没有重复物化源码或依赖。

真实PHP8.4.27/Laravel13.39.0 HTTP kernel、Bearer middleware、应用服务及持久MariaDB，新空库93表/单事务4个虚构账号及三pair friendship。四账号实际API登录和三组CN/MC授权均通过。三组严格串行，每组先真实发送一条消息、读取历史200作阳性控制，再使独立GET/新POST确实等待holder的精确users PRIMARY行；独立INNODB_LOCK_WAITS观察后，holder才调用真实权限变更路由并提交：

| 场景 | 实际独立等待连接→holder及主键 | 提交后的实际结果 |
|---|---|---|
| Block a/b | 31、32→30，users PRIMARY行1 | 真实Block路由200；pair block从0变1；等待GET/POST均404；旧键重放404 |
| CN关闭 third/admin | 42、41→40，users PRIMARY行3 | 真实CN close路由200；等待GET/POST均404；旧键重放404 |
| 管理员禁用peer third（a/third） | 51、52→50，users PRIMARY行1 | 真实admin disable路由200；等待GET/POST均404；旧键重放404；peer旧Bearer直接401 |

三组CN均ACTIVE→CLOSED、两目的MC均ACTIVE→REVOKED，revision均2→3。六个等待请求、三个旧键重放和禁用旧Bearer均无私有正文标记、id/client_message_id/idempotent_replay成功字段均null，实际kernel/RR/事务闭合通过；等待请求实际获锁。每组已跟踪消息ID、存储密文hash、client key、消息通知、message_sent事件和附件ID，在变更、重放之后均保持。禁用组仅peer3 disabled：目标令牌ID5/6与活动会话撤销，actor1令牌ID1/2及其会话保持；旧Bearer401之后捕获状态仍不变。

提交顺序以同库精确锁等待、交接和持久状态为据，不要求提交后ACK早于已恢复请求。观察器仅用本新DB既有root客户端SELECT INNODB元数据，无新增GRANT或隔离级别修改；应用worker仍用限定DB用户。三组证明在途peer失权后的消息GET/POST，未覆盖actor自身已禁用、所有conversation/detail/mutation路径、APP/WS/cache并发或所有字段零写入。

## 检查、收尾与范围

此前32项公开纯检查、2项held-ID纯检查、3项候选输入纯检查按相同代码/hash沿用，未计为本次新测；本次新增核验候选身份适配和6个准备Python文件语法。非作者Codex对新输入及三组实际原证复核无P1/P2，不是外部独立验收。原生PHP8.5旧语法预检不替代本次PHP8.4实际worker；真实故障注入收尾未测。

合计2GiB、启动3072MiB、1800秒/共享45秒收尾、工作卷8GiB/输出2GiB采样、一次start/migrate/seed及DB restart0、离线保持。完整fresh核验只由既有入口执行一次：可用8939MiB、卷空闲354897092608字节仅为本次历史值。后端实际157.109秒，**已耗1、余0，无重试**；controller0、verified=true、cleanup_errors空。三个新容器均停止/PID0/无OOM，WS/API/DB退出0/137/0，API137不归因；新卷/网络保留。

161个既有容器完整State前后一致且均停止，共享引擎保持运行；本轮无新引擎启动、手机/ADB/SDK/AAR/APK/安装、云端、外部服务、真实数据、费用、Push或RTC操作。原dirty根255项状态/index及%SystemDrive%保护；ledger承接19952项，仅追加本节点与上一最终回执，不重扫旧SDK/AVD/Sources。LOCAL_ONLY根名`v1015-messaging-permission-matrix-20261108-case02`：先读`IMPLEMENTATION_REPORT.md`、`verified-messaging-concurrency-private.json`、三组等待/提交/前后快照、`non-author-actual-matrix-review-private.json`及最终回执。私有配置、token、原始日志和SQL不上GitHub。

前次双同键POST及MC撤权实际通过证据继续保留，不写成本次重测。AC03仍PARTIAL：尚需其他路径/主体与时序矩阵、旧JWT/room/media URL、跨账号迟到结果和设备缓存直接证据；媒体、离线15/30天、OS通知/Push token、合格双端RTC/AEC及同一最终APK→API→MariaDB→Web→重启读回集中验收未闭合。整版仍**10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**。不合main/发布、不启v10.1.6，不自动建立后继动态额度。
