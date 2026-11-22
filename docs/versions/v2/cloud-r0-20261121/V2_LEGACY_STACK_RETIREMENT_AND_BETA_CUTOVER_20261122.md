# EliteSync V2｜旧栈退役与阿里云 Beta 基础后端部署报告

2026-11-22（中国标准时间） · **旧栈退役 PASS，P0.4.2 云端回环基础后端 PASS，指定管理员恢复待 Owner。** 现有上海实例保留原 2 vCPU／2 GiB 套餐，新增费用 ¥0。P0.4.2 R1 仍为 PARTIAL，封闭内测与生产仍为 NO_GO。 [原实例基线及升配报价](V2_EXISTING_ALIYUN_BACKEND_DEPLOY_AND_TEST_ADMIN_RESTORE_REPORT.md)

## 旧栈退役、备份与恢复

| 项目 | 状态与证据 |
| --- | --- |
| 实例与依赖 | PASS。固定 RSA SSH 核到同一服务器。旧 Laravel 使用宿主 MariaDB `server_id=1`、回环 3306、Redis 6379 和宿主 PHP 8.4 FPM。DevPilot 使用独立 datadir、MariaDB 43330、Redis 63330、FPM socket 和 8030。LiveKit 容器使用 host 网络，声明未发现对旧 Redis 的依赖。保留宿主 Nginx 的原 `/rtc` 上游及代理参数。 |
| 旧数据库完整逻辑备份 | PASS。以一致性事务导出旧实例的两个业务 schema `elitesync`、`elitesync_restore_2_6`，含 61 张 InnoDB 表及适用的触发器、例程、事件。压缩文件 3,440,493 字节，导出前后对象及逐表行数清单一致。宿主旧 datadir 原样保留。 |
| 旧媒体与配置 | PASS。实际本地磁盘为 `storage/app`，S3／OSS bucket 在旧运行缓存中均无配置。归档 2 个媒体文件、Laravel `.env` 与缓存、Composer 锁、两处旧 Nginx 配置和激活链接、旧 PHP-FPM、MariaDB、Redis 和旧 WebSocket unit 配置。有效 `ADMIN_PHONES` 来源与旧 `users` 字段来源封存于 root 私有备份，去敏报告只记录来源。 |
| SHA-256 与独立恢复 | PASS。云端私有目录的 7 项清单在源端和恢复目标复核通过。WSL 独立 MariaDB 容器 `network=none`、无端口、`server_id=2621199`，恢复两库后逐表行数及对象清单一致。媒体 2/2 文件 SHA-256 一致，配置 tar 按数字 UID/GID 恢复后比较一致。隔离恢复容器已停止，独立卷与备份保留。 |
| 关闭入口和停止进程 | PASS。宿主旧 Laravel 路径返回 410，8088 无监听。原 Nginx 两个激活链接已归档，原配置文件仍在。新增只保留既有 LiveKit `/rtc` 路由的 Nginx 站点。旧 `elitesync-ws`、宿主 `php8.4-fpm`、`mariadb`、`redis-server` 分别实读 `inactive/disabled`，旧 3306、6379 无监听。 |
| 保护与回滚 | PASS。各步核对 DevPilot 及 LiveKit。DevPilot 8030 和 LiveKit 直接 7880 均为 HTTP 200，旧 80 上的 LiveKit `/rtc` 回执与切换前一致。原数据库目录、媒体与配置仍存在。PHP 8.3 和 FastAPI 未归入已确认旧服务，保留原状态。回滚仅在故障且获得恢复决定后，按归档记录恢复旧 Nginx 激活链接和具名旧 unit；数据库与配置需要替换时先保存当前状态，再使用已验证的独立备份。 |

旧备份根与媒体、旧数据和名单保存在私有权限下。第一轮独立配置恢复因 Redis 配置属主差异退出，按原数字 UID/GID 再次恢复后通过。Nginx 激活前的路由匹配检查首轮提前停止，随后受控切换成功。旧 WebSocket 间歇性自动重启导致批量停止保护检查停止，批量续接被执行策略拒绝。随后改为逐项核身、逐项停用并验证受保护服务，均已有各自回执。旧 Redis 的初始保护检查保留，复验按 DevPilot 真实认证响应和端口身份核对。

## 原实例容量复测

| 检查 | 实际读回 |
| --- | --- |
| 退役前 | 旧系统仍并行运行时可用内存快照约 598–643 MiB、无 swap。宿主旧 PHP 8.4 FPM cgroup 当前约 41 MiB、历史峰值约 70 MiB。旧 MariaDB 当前约 137 MiB。 |
| 退役后 | 2 vCPU，实读内存 1,613 MiB。初次可用 783 MiB，后续 10 个样本均为 801 MiB。CPU idle 区间 93–95%，负载 0.23／0.49／0.67，memory PSI some/full avg10 均 0，无 swap。40 GiB 系统盘可用约 24 GiB。 |
| 保留服务 | LiveKit 约 36.55 MiB，CPU 0.06%。DevPilot PHP cgroup 当前约 41 MiB、峰值约 44 MiB，MariaDB 当前约 87 MiB、峰值约 95 MiB，队列约 32 MiB。Docker 为 `overlay2`、cgroup v2。 |
| V2 受控负载 | 采用单 FPM 子进程和各容器 CPU／内存限制，Docker MemUsage 即时读回约为 PHP 44.61 MiB、队列 41.79 MiB、MariaDB 127.2 MiB、Nginx 5.49 MiB。26 次采样的最低可用内存 517 MiB，高于本轮 512 MiB 通过线。四容器 OOM=false，DevPilot 和 LiveKit 健康探针持续通过。备份后 10 次重采样的可用内存为 546–577 MiB，Beta／DevPilot／LiveKit 三端点 30/30 均返回 200。 |

**容量判定**：2 vCPU／2 GiB 支持本轮回环、低并发的合成负载。最低值距离 512 MiB 通过线仅 5 MiB；实际多设备并发、持续高峰和长期稳定性为 NOT_RUN。先维持原规格。若用途扩大或持续低于余量线，再评估原实例 2 vCPU／4 GiB 档，由 Owner 按当时结算金额和维护窗口批准。

## P0.4.2 实际云端部署

| 项目 | 状态与实际结果 |
| --- | --- |
| 源码与镜像 | 固定源码 `7e0009df4fe69e48967c4fbc111717626c85ed80`，tree `80b7237fcd0c7d569a7026d4a73d1e0c34ef86b9`。本机 image/index ID `sha256:679875fc201c17a9c8140c30523a1c03c0c0d8d9e57340783d4e27fbcb2c060e`。固定 amd64 Docker 归档 SHA-256 `b19e42a3d5a54546a0734087323b509ae0723d587cf9af1851b3ca4e2ba7a6b2`，SSH 传输后云端复核吻合。云端 `docker load` 实读 config ID `sha256:5a7ee83db71cdf799c0998233e3dc0b9e3ad0958fa77227f590bd15063ac99cf`、`linux/amd64` 和同一 OCI revision。 |
| Compose 与端口 | `elitesync-v2-shared-staging-beta`，配置含内部 data 网及独立 DB／媒体卷，APP_KEY 与 DB 账户独立。云端运行 FPM `952e91bf58e3`、Worker `a59fe9637ea8`、MariaDB `dd787d366373`、Nginx `3d1595fde643`。只发布回环 `127.0.0.1:18446`。Workerman profile 关闭，共享 Connection 和 WebSocket 保持关闭。 |
| MariaDB 迁移 | PASS。独立实例标识 `aliyun-beta-20261122-160321`，库 `elitesync_v2_beta_staging`，用户 `elitesync_v2_beta_app`，`server_id=2621124`，MariaDB 10.11.19。空库预检 0 表，固定源码 94 个迁移完成，最终 119 表。 |
| HTTPS 及业务 | PASS。回环 TLS 按专用证书与 IP SAN 验证，Laravel `/up` 返回 200。合成 HTTPS 业务交换 **18/18** 通过，含登录退出、资料写入和持久读回、三盘计算、跨账号隔离、私有 PNG 上传及读取、非授权读取拒绝和共享 Connection 拒绝。三盘产品回执状态为 `COMPUTED_UNVERIFIED`，紫微和西占为 `CALCULATED`。 |
| 队列和重启 | PASS。DB Queue Worker 消费 1 个合成媒体作业，`failed_jobs=0`。重启 FPM、Worker 和边缘后，HTTPS 健康、资料和媒体重新读回，退出后的 token 被拒。 |
| 新 V2 备份与恢复 | PASS。冻结回环业务进程后备份，3 个文件 SHA-256 校验通过。独立 WSL 库 `network=none`、`server_id=2621198`，恢复 119 张表并重导 SQL，与云端源逐字节一致，2 个合成媒体文件哈希一致。云端应用重启后 HTTPS／DevPilot／LiveKit 健康通过。隔离恢复容器已停止，留存恢复卷。首轮备份脚本使用标准输入，执行提前结束且未产出归档，改为固定脚本文件启动后通过，原证据保留。 |

固定辅助镜像和历法内核一并传输并核对 SHA-256。实际运行使用私有 Compose 限资源叠加，分别限制 FPM、Worker、MariaDB 和 Nginx 内存为 320、110、224、48 MiB。候选仍运行在回环，容器重启策略为当前试运行的 `no`。现有域名和网络对外配置未扩展。

## 管理员来源与剩余门槛

Owner 已确认旧账号来源位于原服务器。旧站数据库与当时有效名单来源已保存，并完成独立恢复。恢复只等 Owner 指定少量候选，目前没有具名私有候选清单或原号码持有人验证证明。候选查表、LegacyAdminRestore dry-run、签名 apply、一次性激活码与持有人 APP／Web 本人登录均为 **NOT_RUN**。管理员账号的身份和字段冲突须用相应私有清单核对。 [既有目标绑定](../../../../services/backend-laravel/app/Services/Accounts/LegacyAdminTarget.php) · [Owner 签名门](../../../../services/backend-laravel/app/Services/Accounts/LegacyAdminApproval.php)

**NOT_RUN** 还包括付费升配、V2 公网 HTTPS、共享私信及真正 WSS、长时峰值并发和生产发布。新 V2 库只存在本次两名合成普通用户。没有把旧数据导入云端 V2 业务库。

证据根为本机私有 `v2-legacy-retirement-20261122-160321-796`。主要回执为 `03-backup.stdout`、`04b-isolated-restore.stdout`、`09–12b` 的逐项停用结果、`13-capacity.stdout`、`14-transfer.stdout`、`15-candidate.stdout`、`16b-beta-backup.stdout`、`17b-beta-restore.stdout`、`18-final-cloud-readback.stdout` 及两版本备份 SHA-256。早期失败与原始日志均可按该目录回查。
