# v10.1.16 本机自动化运行与恢复

适用环境为 Owner 本机独立开发服务和虚构数据。既有服务及隔离恢复步骤沿用[v10.1.14 服务恢复手册](../v10.1.14/LOCAL_SERVICE_RECOVERY.md)，本文补充 B2 的持久任务与专用调度。最终运行状态和备份身份见[实施报告](IMPLEMENTATION_REPORT.md)及[manifest](artifact_manifest.json)。

## 服务与持久状态

| 项目 | 本机实例或合同 |
|---|---|
| API | `v1015-current-dev-api`，本机 HTTP 端口 8021 |
| DB | `v1015-current-dev-db`，MariaDB 10.11，容器内端口 43326 |
| WebSocket | `v1015-current-dev-ws` |
| 开发库 | `elitesync_v10_1_5_dev` |
| B2 调度 | API 容器内 `php artisan app:automation:work`，只运行 Laravel 名为 `user-automation` 的事件 |
| B2 调度日志 | 容器内 `/tmp/v10116-user-automation.log` |
| 队列配置 | 本机 `queue.default=sync`，B2 使用数据库任务 ledger 与 Laravel Scheduler |
| 持久来源 | 原有业务表，新增 `automation_authorizations/tasks/effects/commands/audits` |

`app:automation:tick --limit=25` 是一次有界排期与执行。`app:automation:work --once` 通过 Laravel 的具名事件执行一次。每分钟的常驻启动器也只选择这一个事件，使用既有 withoutOverlapping 和数据库 task lease/fencing。

全局 Scheduler 中仍有账号关闭任务，B2 本机启动器按名字选择事件。管理员匹配消费者继续受原保护开关及权限管理。

## 启动与健康核对

先核实际 DB/API/WS 状态。DB 使用共享网络命名空间，重启 DB 后沿既有手册重启 API 与 WS，使二者重新接入当前 DB 网络。现有数据和配置保留。

迁移前保存私有 SQL 并核对字节数、SHA256 与导出退出码，再在已确认的开发库执行增量迁移。本版已完成迁移和 `config:clear`，新增 effect 收据的 `authorization_revision` 列已直接核实存在。

在 API 容器启动 B2 专用调度前，检查 `/proc/*/cmdline`，确认当前只有预期实例。当前镜像未提供 `ps`，可用以下只读核对。

```powershell
docker exec v1015-current-dev-api php -r '$found=[]; foreach(glob("/proc/[0-9]*/cmdline") as $p){$a=explode(chr(0),@file_get_contents($p)?:""); if(($a[1]??"")==="artisan" && ($a[2]??"")==="app:automation:work"){$found[]=(int)basename(dirname($p));}} echo json_encode($found);'
```

确认没有已有 B2 启动器后启动。

```powershell
docker exec -d v1015-current-dev-api sh -c 'exec php artisan app:automation:work >> /tmp/v10116-user-automation.log 2>&1'
docker exec v1015-current-dev-api tail -n 10 /tmp/v10116-user-automation.log
```

核对日志按分钟出现 `scheduler event finished`，随后用虚构账号读取 `/api/v1/automations`。ACTIVE 授权的 `last_checked_at` 应推进，任务有可解释结果。未开放轮次时记录 `NO_OPEN_ROUND`，已结束报名阶段记录 `ROUND_NOT_OPEN`。

该后台进程随 API 容器退出。API 容器恢复后须按上面步骤重新启动 B2 启动器，当前采用本机手动恢复方式。日志位于容器 `/tmp`，有意义的原证及时复制至本版私有目录。

## 暂停、撤销与异常恢复

用户级停止通过 APP 的“状态与自动化”执行暂停或撤销。授权命令递增 revision 并取消待执行/运行中任务，worker 在副作用前再次检查当前授权与 fence。暂停仅作用于绑定到该 scope 授权记录的 ACTIVE 参与。独立手动报名及手动 opt_in 清除绑定后的参与保留原值。到期处理按授权记录 ID 识别旧 revision 的委托绑定。当前 proposal 保留原业务处理规则。

需要停止整个本机 B2 调度时，先使用上面的只读核对定位具名 PID，再对该 PID 发送 TERM。PID 属于当次运行，使用前重新读取并核对完整命令。恢复时重新启动具名 B2 启动器。

| 状态 | 恢复行为 |
|---|---|
| RUNNING 且 lease 尚有效 | 等待当前持有者或 lease 到期 |
| RUNNING lease 已过期 | 重新 claim 为 UNKNOWN，递增 fencing token |
| UNKNOWN 且同授权 revision 存在 effect 收据 | 核对当前参与代际并终结回执，保持一次业务效果 |
| UNKNOWN 且无 effect 收据 | 记录 NO_EFFECT_CONFIRMED 后按 `[30,120]` 秒退避，最多三次执行尝试 |
| FAILED / RETRY_EXHAUSTED | 保留失败及审计，检查当前资格、授权和数据库健康。当前实现保留该授权周期失败终态 |
| SKIPPED | 条件指纹变化后自动重新核对；同一条件重复调度保持终态 |
| PAUSED / REVOKED / EXPIRED | 停止后续委托，恢复或重授由用户明确操作 |

保持 task、effect、授权 revision、fencing 和既有参与事实一致。手工把 UNKNOWN 改成成功或删除收据会破坏核对依据，恢复工作应通过既有调度和业务合同完成。

## 私有备份与隔离恢复

迁移前备份为 `pre-migration.sql`，本版完成后的备份为 `final-b2.sql`，二者及哈希回执保存在本版私有原证目录。完整 SQL、密码、token 和 APK 由 Owner 本机保管。

导出可复用现有容器内 root 凭据，在单个本机进程环境中传入客户端，保存原始二进制 stdout，再分别核对导出退出码、文件大小和 SHA256。备份应包含五张 B2 表、三列参与授权绑定及原业务表，保持同一事务一致性。

隔离恢复先创建全新具名数据库与限定测试账号，再导入选定备份。执行任何迁移或 fixture 前，用实际 SQL `SELECT DATABASE()`、driver、环境和目标名称共同核对。测试 runner 同时覆盖 `APP_DB_*` 与 `DB_*`，因为项目配置优先采用 app-scoped 变量。仅检查配置声明的数据库名不足以证明实际连接。

当前可靠性 fixture 强制 `testing`、mysql 及 `elitesync_b2_test_[a-f0-9]{12}` 命名。之前失败的隔离库和回执均保留。worker 崩溃/并发验证使用新隔离 schema，模拟进程以 SIGKILL 中断，重启后核对 ledger 和参与 revision。最终备份的独立导入恢复本版为 NOT_RUN，既有 v10.1.14 恢复演练保留其原范围。

## 本版退出状态

2026-11-15 初次交付时 DB/API/WS 与 B2 专用调度运行，SFU exited，模拟器停止且数据保留。2026-11-16 R1 开始时 Docker 引擎已停止，恢复引擎后原 DB/API/WS 保持 exited。R1 使用新建独立 DB/PHP 容器和回环 HTTP，结束后两个测试容器均停止，测试卷与原证保留。旧 SFU 在引擎启动时自动重试，随后恢复停止。R1 当前主开发 API 与后台调度部署验证为 NOT_RUN。完整状态以本版 manifest 为准。
