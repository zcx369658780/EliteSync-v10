# v10.1.5 消息并发重放与MC撤权锁交接实测通过｜2026-11-08

**REAL_MARIADB_MESSAGE_DUPLICATE_AND_MC_REVOKE_HANDOFF_VERIFIED / BACKEND_SUBSET_PASS / SPENT_1_REMAINING_0 / AC03_PARTIAL / G2_FALSE**

Owner当前“可以请继续”与既有Local-first同类普通本机工程委派，承接冻结AC02/03的消息权限与并发缺口。本新任务`V1015_MSG_CONCURRENCY_20261108_01`预先声明独立一次、两个串行场景；此前已完成的退出撤权、构建及其他claim/STOP全部封存，未退款或复用。本轮没有引擎启动、设备/ADB、SDK/AAR/APK、外部服务或真实数据操作。

## 实现与实际输入

新增[消息并发探针](../../tools/acceptance/v1015_messaging_concurrency/README.md)，含实际HTTP kernel worker、宿主屏障/锁等待观察、失败判据及纯测试。产品授权、消息服务、APP和冻结标准未修改。源码固定`6b03aad9c3eabefa7196f5a8ee6c161d0c9e309a`、Root `ca2d531e15939eab87c171c585cbea746b2434d5`；apps树b673913a4ff0ff1a8bfc83ca98951ff1556a2f23、services树4530ae85754a2f3698d073182a47038708f2cb55不变。

复用既有只读726文件服务快照/114包vendor；新私有空库初始化93表/4个虚构账号，使用真实API登录及CN/MC授权。实际PHP8.4.27/Laravel13.39.0和持久MariaDB，不运行PHPUnit的SQLite-memory基类，不修改隔离级别或替换鉴权代码。两组内的独立worker各自经过实际HTTP kernel、Bearer middleware、路由与应用服务；另有授权历史读取200及撤权后旧键重放404控制。

## 实际并发证据

| 场景 | 独立数据库等待证据 | 实际响应与持久结果 |
|---|---|---|
| 同一client_message_id双POST | 两请求连接20、19均等待holder18，在本新库users PRIMARY的同一用户行上有精确INNODB_LOCK_WAITS记录；观察后才释放屏障 | 两者200、同消息ID1、一个首次创建/一个replay；消息/消息通知/message_sent事件均从0增至1，附件仍0；新消息键与返回ID绑定 |
| MC撤权与等待中的GET/新POST | 请求连接27、26均等待真实revoker25，同样核对精确库/表/索引/用户行；revoker实际调用MC撤权路由200并提交后，两个请求获锁继续 | GET/新POST均404、无私有正文标记或成功标识；CN仍ACTIVE、两个MC目的均REVOKED；已跟踪消息ID/hash/键、消息通知、发送事件及附件ID保持不变；旧键重放同样404 |

两组均有实际重叠和独立会话等待证据。各请求和revoker实际为REPEATABLE-READ，请求完成/提交后事务层级0，进程退出0；500、死锁、缺屏障或残留事务均不接受。DB UTC、PHP单调时间和宿主观测时钟分别留存，提交/锁交接按同库精确等待及随后获锁、持久撤权状态判定；提交后的ACK允许晚于已恢复请求。

独立观察器仅经本新DB容器既有root客户端读取INNODB元数据，凭据留在容器环境；没有赋予应用账号PROCESS权限或执行新GRANT。应用worker保持其原有限定DB用户。本次HTTP worker结果是后端kernel/MariaDB证据，手机/WS/缓存并发NOT_RUN；快照维度限于上述字段，不宣称所有字段零写入。

## 检查、资源与收尾

24项纯unittest通过；真实故障判据含错连接/错表、500、开放事务、错误隔离、重复副作用及原子STOP发布失败等。另2项私有held-ID恢复纯检查通过。既有原生PHP8.5仅作前置语法检查；实际worker已在本次合格PHP8.4执行。两项收尾P2在启动前修正：完整原子发布STOP且单一写盘/终止错误不跳过其他收尾；已claim未ready时恢复并核验本任务精确held IDs，不可恢复则CLEANUP_UNKNOWN。真实故障注入收尾未实测。非作者Codex源码及实际原证复核无新P1/P2，非外部独立验收。

既有入口一次fresh核验可用6908MiB、卷空闲355478937600字节（仅本次历史值）。合计2GiB、启动3072MiB、1800秒/共享收尾45秒、工作卷8GiB/输出2GiB采样、一次start/migrate/seed及0次DB restart保持。后端实际101.578秒，已耗1、余0，无重试。原证验证成功且controller0、cleanup_errors为空；三个新容器均停止/PID0/无OOM，WS/API/DB退出0/137/0，API137原样保留，新卷和网络留存。

155个既有容器完整State事后与事前相同且全停止，现有共享引擎保留运行；原dirty根、旧DB/SDK/AVD/备份、所有历史原证/STOP与%SystemDrive%保护。保护ledger承接19577项，仅追加本节点原证，不重扫旧SDK/AVD/Sources。当前产品图谱未索引，本轮仅按具名消息模块/测试和旧status-post屏障框架作定位，没有全仓索引或改写旧harness。

LOCAL_ONLY根名`v1015-messaging-concurrency-20261108-case01`：先读`IMPLEMENTATION_REPORT.md`、`verified-messaging-concurrency-private.json`、`backend-storage/messaging-concurrency/summary-private.json`、两组精确锁等待/前后快照、`messaging-probe-cleanup-private.json`及最终回执。配置/token、私有原始输出和SQL不上GitHub。

AC02/03继续PARTIAL：尚需Block/CN关闭/禁用等其余真实并发矩阵、旧JWT/room/media URL、跨账号迟到结果和设备缓存直接证据。整版仍10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING；媒体、离线15/30天、通知、合格RTC/AEC与同一最终候选集中验收仍未闭合。不合main/发布、不启v10.1.6。
