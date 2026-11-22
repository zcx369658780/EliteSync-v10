# EliteSync V2｜复用阿里云后端部署与测试管理员恢复报告

2026-11-22（中国标准时间） · **现机只读核查完成，部署停在容量、回滚与 HTTPS 门槛。** 上海现机承载旧站、LiveKit 和隔离的 v10.1.0 DevPilot，尚未运行固定 P0.4.2 V2 镜像。保留两套现有后端及原始数据。方案仅评估原实例升配。P0.4.2 R1 仍为 PARTIAL，封闭内测和生产均为 NO_GO。

## A｜现有服务器实时只读核查

15:14 起通过现有 SSH 信任记录，固定 RSA 主机密钥和现有授权身份，三次定向只读命令退出 0。实例元数据通过 IMDSv2 回读。公网地址、内部实例完整标识、路径清单和主机防火墙原件保留在本机私有证据目录。

| 项目 | 状态与实测 |
| --- | --- |
| 实例与规格 | PASS。与既有可信 SSH 端点一致。华东 2（上海）可用区 G，Ubuntu 24.04.2 LTS、x86_64，实例元数据规格 `ecs.e-c1m1.large`，宿主 2 vCPU。历史可信端点别名为 Ubuntu-zlxh。15:37 控制台已核对原公网地址与可信 SSH 一致，实例 ID 尾号 `02be9a`，通用型 BGP，2 vCPU／2 GiB／40 GiB，运行中，到期 2027-03-17 23:59:59。 |
| CPU、内存和磁盘 | PASS（取样）。内存 1,613 MiB、available 644 MiB、无 swap。40 GiB 系统盘约用 14 GiB、可用 24 GiB。5 秒 `vmstat` 的 4 个区间样本 CPU idle 50–94%、I/O wait 0–2%。`iostat` 后两个短窗口系统盘利用率 0%，采样时 CPU PSI avg10 为 7.47%，内存 PSI avg10 为 0.12%。长期余量 UNKNOWN。 |
| Docker | PASS。Docker 29.1.3、Compose 2.37.1、`overlay2`，仅 LiveKit 容器运行，host 网络。未见 V2 Compose 项目、命名卷或固定镜像。本地镜像归档的 OCI manifest 和 config 身份已分别留档，便于传统镜像存储的加载回读。 |
| 旧 Laravel 与配套 | PASS。旧站源目录 `/opt/elitesync/services/backend-laravel`，Composer lock 中 Laravel 11.48.0，宿主 PHP 8.4.18，MariaDB 10.11.14 和 Redis 7.0.15。Nginx 1.24.0。旧站回环 80 及原回环探针 8088 的 `/up` 均返回 200，两者共用 Laravel 根目录和宿主 PHP 8.4 FPM。旧 MariaDB 本地 socket 回读 `server_id=1`、3306，Redis 6379 回环。 |
| 独立后端与隔离 | PASS（进程与存储路径）。部署根为 `/opt/elitesync-v10.1.0-devpilot`。正在运行的发布目录对应 `997af1e58e89`；独立 PHP-FPM socket、队列、WebSocket、RTC 和 Redis 均 active。Nginx 回环 8030 `/up` 为 HTTP 200，专用 MariaDB 10.11.14 在回环 43330、独立 socket 与 datadir，Redis 在 63330。该库也使用 `server_id=1`，因此新 V2 必须指定另一 server ID。独立后端的 storage 链接解析到另一发布目录，和旧站存储 inode 不同，两者共用宿主系统盘。 |
| 端口和访问范围 | PASS（宿主层）。监听包含非回环 TCP 22、80、LiveKit 7880/7881 和指定接口 UDP 7882。MariaDB、Redis、DevPilot 8030 和旧探针 8088 仅绑定回环。未见宿主 443 监听。UFW inactive，记录了 nftables/iptables 的 Docker 转发表。阿里云实例防火墙中 TCP 80/443 已对所有 IPv4 启用，另有既存 SSH 和 RTC 规则。宿主监听与云防火墙分别核查。 |
| HTTPS/TLS | FAIL（复用入口资格）。已启用 Nginx 站点及 DevPilot 配置中未找到可直接复用的 HTTPS listener。找到的一张 Let's Encrypt 证书已于 2026-08-16 过期，近期 `certbot.service` 为 failed。实例域名页显示原域名及 www 记录。仍需核准 V2 的有效证书、入口与管理来源，或先以批准的 SSH 转发接入回环验收。 |
| 备份和回滚 | UNKNOWN（恢复资格）。`/opt/backups` 符合只读统计口径的归档、摘要和 manifest 共 83 件，合计 382,577,591 字节，最近 mtime 2026-10-18。文件存在不能证明两套活库、配置和媒体可恢复。控制台实例快照为 0。本轮未生成备份、未导入旧数据、未恢复快照。 |

### 15:28 续接核验

沿用原可信 SSH 定向复测，仍只有 LiveKit 容器、无 V2 Compose 项目，三个回环 `/up` 均为 200，未见 443 监听。实测可用内存约 637 MiB、无 swap，系统盘可用约 24 GiB。旧备份目录找到 23 份 `.sql.gz`，就其中最新可与同名 sidecar 绑定的一份进行原始字节 SHA-256 复核，2026-08-20、305,971 字节，结果 PASS。该证据只覆盖该归档与 sidecar 的字节一致性，两套旧环境的实际恢复资格仍为 UNKNOWN。15:28 时控制台仍为登录页，15:37 已登录并完成下述控制面核查。

## B｜原实例升配和回滚门

现机同时承担旧站及 DevPilot。可用内存 644 MiB，已签收的 4 个 FPM 子进程配置上界合计 1 GiB，另需 MariaDB、队列、运行库和三盘脚本。回环隔离仍会共享内存、I/O 和磁盘，当前资源不足以支持安全同驻。**部署停止在镜像上传前。**

| 决策项 | 当前状态 |
| --- | --- |
| 控制台核身与套餐 | PASS。上海通用型 BGP 原档为 ¥45/月。升配页按配置显示套餐，未展示内部 SKU 编码。以下金额为 15:37 结算前实时显示，正式应付金额以结算前再次核对为准。 |
| 云防火墙与快照 | PASS（只读盘点）。9 条现有入站规则已启用，443 已放行，实例快照为 0。启用任何新的公网监听仍须按 Owner 范围处理。 |
| 预选升配 | 原实例 2 vCPU／4 GiB／50 GiB 为满足本轮预案的最低档，标价 ¥70/月，页面合计 ¥43.26。升配后先复测两套旧环境、LiveKit 和实际资源余量，再决定 V2 启动。 |
| 停机 | 该实例页面提示，结算后立即升级并重启，预计中断 5–10 分钟。维护窗口需另加原服务逐项验证时间，实际时长只有执行后才能核实。 |
| 回滚与恢复 | 升配不支持降配。提升规格无法作为回滚点。先验证两套数据库、两套媒体与关键配置的各自备份，保留 hash、恢复目标与测试回执。确认系统盘快照范围、完成状态与可恢复性。如升配后旧业务异常，暂停新 V2 投入，优先恢复旧服务，必要时按独立批准的恢复点执行。原盘快照回滚会停机，并覆盖快照之后的写入，执行前应保存新增写入及当前故障证据，保留可独立恢复的配对备份。 |

| 控制台可选同族 BGP 档位 | 页面月标价 | 本次合计 |
| --- | ---: | ---: |
| 2 vCPU／4 GiB／50 GiB | ¥70 | ¥43.26 |
| 4 vCPU／8 GiB／70 GiB | ¥220 | ¥302.79 |
| 4 vCPU／16 GiB／80 GiB | ¥300 | ¥441.21 |

三档均显示峰值带宽 200 Mbps、无固定流量包及 1 个固定 IPv4。页面保留在 4 GiB 报价，未点确认、未创建订单。完成备份与恢复核验后，由 Owner 确认档位、最终应付金额和维护时窗。升配完成后复核实例、内存、盘、Docker、旧 PHP/MariaDB/Redis/RTC、三条已有服务入口及主机回环。旧服务健康和余量通过后再部署。 [阿里云升配与重启说明](https://help.aliyun.com/zh/simple-application-server/user-guide/upgrade-a-simple-application-server) · [快照使用条件](https://help.aliyun.com/zh/simple-application-server/user-guide/manage-snapshots)

## C｜固定镜像归档及 V2 目标冻结

| 对象 | 身份与状态 |
| --- | --- |
| GitHub | `zcx369658780/EliteSync-v10`，开发分支 `codex/v2-function-completion-20261121`。前置报告 `23e5c2b0bb9a1b82d08512c1e95c715d238db225`。固定业务源码 `7e0009df4fe69e48967c4fbc111717626c85ed80`，tree `80b7237fcd0c7d569a7026d4a73d1e0c34ef86b9`。 |
| 本机 docker save | PASS。专用 WSL 引擎 `/var/lib/docker-r0`，仅导出固定 `linux/amd64` 平台。文件 `p042-staging-linux-amd64-docker-save.tar`，301,962,752 字节，SHA-256 `b19e42a3d5a54546a0734087323b509ae0723d587cf9af1851b3ca4e2ba7a6b2`。36 个镜像层、平台 manifest、config 哈希及 OCI revision 已对照。沿用原本地测试结果，未重复运行。 |
| 镜像标识 | 本机 image/index ID `sha256:679875fc201c17a9c8140c30523a1c03c0c0d8d9e57340783d4e27fbcb2c060e`；归档 amd64 manifest `sha256:6bce0c32e49a3ac2800644fb42eac616742b88e9a0beffb159fe6045e42a9f10`；镜像 config `sha256:5a7ee83db71cdf799c0998233e3dc0b9e3ad0958fa77227f590bd15063ac99cf`。云端归档 SHA、镜像 ID、Compose 容器和卷均 NOT_RUN。 |

通过容量和恢复门后，用原可信 SSH 将归档送入新独立私有目录，云端先比对归档 SHA 再 `docker load`。传统 Docker 镜像存储的 `.Id` 可能显示 config digest；将其与归档内已验证的 manifest、平台和 revision 一起核对。不要将该差异解释为已经获得 Registry 镜像 digest。

以原 [Staging Compose](../../../../services/backend-laravel/docker/shared-staging/compose.yaml) 为基础，仅为新实例绑定单独的项目、账户、网络、卷、密钥和媒体。旧预部署默认账号 `elitesync_staging_app` 和 schema 前缀不满足 `LegacyAdminTarget`，续接时已补齐 Compose 和目标预检参数，Beta 项目、库名、应用及 MariaDB 用户和 `CURRENT_USER()` 一并核对：

- 待云端确认唯一性后采用独立 `elitesync-v2-shared-staging-beta` 项目、`elitesync_v2_beta_staging` 与 `elitesync_v2_beta_app`，独立 `server_id` 和实例标识。同一应用环境绑定 `APP_ENV=staging`、debug 关闭、HTTPS、Secure Cookie、MariaDB 10.11、数据库 session。先验证空库和连接身份，再迁移。
- 新库仅内部网络可达。FPM、MariaDB、Worker 均无公网发布端口。单独的 APP_KEY 与媒体卷，使用 DB cache、queue、session。Workerman 服务定义随配置保留，profile 不启动，`MATCHING_FOUNDATION_WEBSOCKET_ENABLED=false`、`V1007_LOCAL_RESTORATION=false`，共享私信关闭。
- 优先只启用新回环 TLS 进行基础验收。后续远端供测试人使用时，先确认合法域名、TLS 续期、管理和激活路由来源限制。若必须变动 DNS、防火墙或公网监听，提供具体差异，由 Owner 批准后执行。旧 HTTP/Nginx、LiveKit 及旧 WebSocket 不改动。

本地只渲染原配置和 Beta 配置，并为预检使用合成 Docker/SQL 回执，6/6 通过，涵盖原默认配置、Beta 目标、错用户名、开启 Workerman、旧 server ID 和非空库。没有启动容器、迁移库或重复本地预部署演练。

## D｜云端基础验收清单

本轮以下均为 **NOT_RUN**。部署获准后分别回填实际容器、镜像、SQL 身份、HTTP 状态、实测数及原始证据：

1. 空库身份、迁移与可信 HTTPS `/up`。
2. 合成账号登录与退出，用户资料持久化读回。
3. 八字、紫微、西占计算及读回。
4. 私有媒体上传、授权读取、异账号拒绝。
5. DB Queue Worker 实际消费。
6. 数据库和媒体成对备份，独立恢复目标与错误目标拒绝。
7. 定向重启新服务并复核 HTTPS、数据和旧服务健康。

## E｜原管理员来源与恢复边界

只读观察到旧站 `.env` 受控声明有 4 个条目且存在 Laravel 配置缓存，DevPilot 声明有 1 个条目且未见 Laravel 配置缓存。本次仅统计声明，运行时有效名单 UNKNOWN，未记录号码。来源应由 Owner 指明。候选代号、旧用户记录的角色／启用状态、控制原号证明及 Owner 签名目前均 UNKNOWN，候选 SQL 和恢复 dry-run 为 NOT_RUN。

请在私有渠道提供具名测试候选对应的代号、旧来源、核验责任人及原号码控制证明。以获批最小字段只查这几人的旧主体 ID、原登录标识、旧角色、启用状态和受控名单命中。不得为待核候选推定授权。旧密码哈希、Token、Session、MFA 均排除。

管理员恢复目标读取实际 `LEGACY_ADMIN_*` 绑定，核 HTTPS origin、目标代号、MariaDB connection/host/schema/version/server ID/port/grant account 及目标 allowlist。远程目标的现有实现要求 Owner 提供独立签名，核冲突、幂等和最小字段后才 apply。签发一次性激活码、本人设新密码、APP 本人登录、授予管理权限的人员本人 Web 登录均须分别记录。若需撤销，执行工具的 rollback，撤销新凭据及会话、移出私有 allowlist，并保留审计。 [恢复目标检查](../../../../services/backend-laravel/app/Services/Accounts/LegacyAdminTarget.php) · [签名核验](../../../../services/backend-laravel/app/Services/Accounts/LegacyAdminApproval.php)

## 结论与证据

**PASS**：可信 SSH 只读盘点、控制台实例及报价核查、旧系统与独立 DevPilot 区分、现有三个 HTTP 回环健康、本机固定镜像归档与身份验证。**FAIL**：当前容量资格、可复用的受信 HTTPS。**UNKNOWN**：旧备份可恢复性、内部 SKU 编码、实际中断时长、候选和持有人证明。**NOT_RUN**：原实例升配及升配后验证、镜像上传与加载、云端部署、云端业务验收、管理员候选查表／恢复和本人登录。零新增费用，旧服务、网络和数据无工程写入。

本机私有证据目录末级为 `v2-existing-aliyun-readonly-20261122-151416-712`。原始 SSH 命令、退出码、归档收据和控制面证据在该目录。15:28 续接的 SSH、静态检查和 SHA-256 在 `resume-20261122-152816-767` 子目录。15:37 控制台的只读报价及防火墙回执保存于 `console-20261122-1537`。Git 分支只同步去敏报告及部署配置。 [前置本地预部署报告](V2_BETA_PREP_SHARED_STAGING_PREDEPLOY_REPORT_20261122.md)
