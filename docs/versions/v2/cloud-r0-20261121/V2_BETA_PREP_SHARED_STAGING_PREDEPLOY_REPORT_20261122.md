# EliteSync V2 共享 Staging 预部署报告与 Owner 决策包

2026-11-22（中国标准时间） · **本地预部署演练 PASS，远端部署待 Owner 授权，共享私信未就绪。** P0.4.2 R1 三项核心实机结果沿用网页 GPT 的限定接受，整版仍为 PARTIAL，封闭内测及生产均为 NO_GO。 [固定实机报告](V2_P0_4_2_R1_1011807_UPDATED_DEVICE_REPORT_20261122.md)

本报告附属于原 Beta 准备任务。独立 Staging 底座可以复查并按手册执行和回滚。远端开通须先固定资源、费用、镜像、网络和回滚责任人。共享私信须另行批准合成 Connection 授权并通过正向设备测试。真实管理员恢复有独立数据审批。 [原 Beta 准备任务](https://github.com/zcx369658780/EliteSync-v10/blob/a77ebe606048be884d4682f27f77527b8d6fe5c1/docs/versions/v2/V2_BETA_PREP_SHARED_BACKEND_AND_LEGACY_ADMIN_RECOVERY_CONSOLIDATED_TASK_20261121.md) · [既有综合报告](V2_BETA_PREP_LEGACY_ADMIN_AND_SHARED_HTTPS_REPORT_20261121.md) · [操作手册](../../../../services/backend-laravel/docker/shared-staging/RUNBOOK.md)

## 源码、镜像与运行证据

| 对象 | 实际核验 |
| --- | --- |
| Git | 文档起点 `868a4f6eaa674b6204469d11468b60070d7de406`，tree `35bdacbb5dfa775c3ab6a6cd6686628c58654128`。业务源码 `7e0009df4fe69e48967c4fbc111717626c85ed80`，完整 tree `80b7237fcd0c7d569a7026d4a73d1e0c34ef86b9`，后端子树 `177108a60390c83256f71928fafb6e878270ae1a`。相对原 CLOUD-R0 `4c255a0915ecc792b083f94798c40216ec870f07` 为 0/37。 |
| 构建 | 本机专用 WSL，Docker 29.1.3，根 `/var/lib/docker-r0`。固定 Git 对象导出的后端目录走原完整 Dockerfile。OCI revision 为固定源码。linux/amd64，PHP 8.4.28、Node 22.23.5、Python 3.11.2、Composer 2.9.8。 |
| 镜像身份 | 本机标记 `elitesync-v2-shared-staging:7e0009df-20261122`，引擎 image/index ID `sha256:679875fc201c17a9c8140c30523a1c03c0c0d8d9e57340783d4e27fbcb2c060e`，amd64 manifest `sha256:6bce0c32e49a3ac2800644fb42eac616742b88e9a0beffb159fe6045e42a9f10`，config `sha256:5a7ee83db71cdf799c0998233e3dc0b9e3ad0958fa77227f590bd15063ac99cf`，inspect size 301,929,975 字节。私有 Registry digest 待批准后回读。 |
| 基础镜像 | Node 22、Composer 2.9、PHP 8.4 FPM 固定为原 [Dockerfile](../../../../services/backend-laravel/docker/cloud-r0/Dockerfile) 中完整 digest。MariaDB 10.11.19 和 Nginx 1.28-alpine 固定为 [Staging Compose](../../../../services/backend-laravel/docker/shared-staging/compose.yaml) 中完整 digest。 |
| 依赖 | `composer.lock` SHA-256 `de8ad0c0593620df96a2ce02e547552d556c728703f06c00605bbbf0d95a84a3`。npm lock `fb11a11dc4ecb7c6fc342b05dc2864d5b36805da04b661c8d9cd076aef0780d2`。Python CP311 Linux 哈希锁 `f285ab3b886abec93315aaf1b4322bb2e41c5c7a033a71d3c9c2f5cbb4884c62`。全量 [OS 包版本锁](../../../../services/backend-laravel/docker/shared-staging/os-packages.tsv)、PHP 锁定包及 Python 实装清单指纹已固定并回读。Debian APT 索引仍会随仓库变化，重建以包清单哈希判定，交付以固定产物为准。 |
| 实际容器 | 本机独立 Compose `elitesync-v2-shared-staging` 的 FPM `fd5a4fea1ca4`、Worker 和 Workerman 均回读到上述镜像，完整容器 ID 和挂载见 `08-runtime-close.log`。源实例 DB `elitesync_v2_shared_staging/2621122`，恢复实例 `elitesync_v2_shared_staging_restore/2621123`，各有独立 DB 卷、媒体卷、私有凭据及 internal 网络。仅边缘端口绑定回环。 |
| 保护范围 | 脏 main 仍为 `4bebc8f3`，暂存区为 0，原 P0.4.2 `f127cc68` 与 CLOUD-R0 `9fd84d2f` 保持各自工作树。原 DB 容器在演练前后身份相同，保留 `elitesync-v2-function_r0-dbdata` 与 `server_id=2621121`，结束仍为 healthy。设备及旧 APK 未操作。两个新演练栈全部退出 0，四个新卷、镜像、配对备份及原始日志保留。 |

| 本地验证 | 实际执行与结果 | 证据 |
| --- | --- | --- |
| 固定源码镜像 | 1 个完整构建 PASS，平台与三类依赖锁回读 PASS。首次从 WSL 按 Windows 挂载路径启动返回 127，保存原日志后用字节传输重新开始。校验器首次少传容器 stdin，保留失败后复核 PASS。 | `01-full-build.log`、`02-full-build.log`、`05-image-lock-readback.log` |
| 空库迁移与 Laravel | 70 个迁移动作 DONE，SQL 表数 0 → 119。源及恢复回环 `/up` 都返回 200，TLS 1.3、IP SAN 和证书信任校验通过。两边各用独立测试证书。 | `03-start-migrate.log`、`07-backup-restore-file.log`、`08-runtime-close.log` |
| HTTPS 业务与媒体 | 38 次请求 PASS，涵盖虚构账号登录、管理员角色及私有名单、同键读回、并发提交、私有 PNG 的所有者读回和跨账号／访客拒绝。Connection 在现有 Staging 身份下保持拒绝。HTTP 计数按请求行统计，脚本另含业务断言。 | `04-business.log` |
| 三盘 | 8 次请求 PASS。固定历法内核，八字 `COMPUTED_UNVERIFIED`、紫微和西占 `CALCULATED`。核持久读回、跨账号隔离、旧 revision 冲突、未知时刻保持 `UNKNOWN`。 | `04-natal.log` |
| Queue Worker | 真实 Worker 消费 1 个合成媒体作业，资产 ready、作业 succeeded、failed_jobs=0。缓存、会话和队列实际使用 MariaDB。 | `06-queue-ws.log` |
| Workerman 与 WSS 边缘 | 1 次缺 Upgrade 返回 426；访客与有 `chat:ws` 能力但无 Connection 的合成账号，各 1 次真实 TLS Upgrade 到达 Workerman，立即关闭，边缘 502，无业务帧。代理连通和拒绝 PASS，正向 101、授权后事件与撤权换代在此部署配置均 NOT_RUN。应在开放共享入口前实现拒绝语义并定向复验。 | `06-queue-ws.log` |
| 备份、恢复与隔离 | 2 次目标拒绝 PASS（错误 server ID、非空源库）。1 次空目标恢复 PASS，SQL 逻辑转储逐字节一致，2 个媒体文件路径与哈希一致。源／恢复挂载及网络隔离 PASS。此轮验证新 APP_KEY 环境的备份字节复原，密文使用原受控 APP_KEY 的业务级解密恢复仍待独立演练。 | `07-backup-restore-file.log`、`08-runtime-close.log` |

## A–G｜一次性 Owner 审批表

**当前为待审批。** 推荐第一阶段仅批准独立 Staging 基础部署与具名合成数据验收。请把实例 ID、项目标识、域名、镜像 digest、数据库身份、部署及回滚责任人、允许来源、费用和有效窗口填入同一私有回执。Connection 机制与真实管理员操作分别明示。实际云操作在相关项获批且目标核身通过后执行。

### A · 服务器选择与容量

| 方案 | 容量与隔离 | 建议决定 |
| --- | --- | --- |
| 复用上海 `Ubuntu-zlxh` | 历史 2 vCPU／2 GiB／40 GiB，采样可用内存约 627–628 MiB，无 swap、根盘约剩 24 GiB。旧 Laravel、MariaDB、Redis、LiveKit 同驻，端口、内存、I/O、备份、高峰和回滚相互影响。当前资源与账单 UNKNOWN。 | 暂不批准同驻。若 Owner 优先复用，先另批只读高峰测量与容量判定，独立做故障隔离演练。 |
| 独立 Staging | 2 vCPU／4 GiB／40–60 GiB SSD 起步。分离实例、边缘容器、DB schema/账号/卷、媒体卷、密钥、备份空间和日志。共享宿主的现有其它资源仅在能证明同等隔离时替代。 | 推荐。先限制到具名测试人，量测并发三盘、长连接、队列及备份峰值后再定规格。 |

部署验收建议先用 2 个并发三盘、10 条具名 WSS、1 个数据库队列 Worker 做短测，复查 FPM 目前 4 子进程和每进程 256 MiB 上限。持续可用内存低于 512 MiB、OOM、异常 5xx、备份失败或磁盘达到 80% 时暂停扩量。对 Worker 积压、DB 慢查询、WS 重连／异常断线、证书到期和备份滞后建立告警；固定分服务轮转及 Workerman 文件轮转。指标为初始验收建议，当前容量测试 NOT_RUN。 [历史容量证据](V2_CLOUD_R0_ENGINEERING_REPORT_20261121.md#g0阿里云核身)

### B · 费用与期限

| 项目 | 实际含税价 | 建议分项月上限 |
| --- | --- | ---: |
| 实例及 40–60 GiB 系统盘 | UNKNOWN | ¥150 |
| 公网带宽、流量或 VPN | UNKNOWN | ¥40 |
| 域名或现有域名分摊 | UNKNOWN | ¥10 |
| TLS（优先现有或自动化免费证书） | UNKNOWN | ¥0 |
| 快照与独立备份存储 | UNKNOWN | ¥40 |
| 日志与监控 | UNKNOWN | ¥10 |

建议限 30 天，运行月上限 ¥250，含首次一次性支出的总上限 ¥300，关闭自动续费。费用项按发票口径确认，重复计算的套餐带宽和存储剔除。需填供应商、区域、SKU、流量超额、续费及保留费、含税报价的时间与账单责任人。超额或价格未核时暂停采购。本轮云支出 ¥0。

### C · 共享网络、TLS 与 Workerman

- 首选独立实例以 `staging.<批准域名>` 向批准的 VPN 或设备来源提供 HTTPS。APP API 与 WSS 使用同一 HTTPS authority。管理 Web、管理员 API 与激活路由额外限制具名管理来源，经 Laravel 的角色、私有 allowlist、会话及 CSRF 控制。公开注册、生产 RTC、邮件和测试发行入口沿用关停策略，按路由回读验证。
- 外层 HTTPS 只覆盖新入口。上游回环 HTTPS 使用独立可信 CA 或已知证书。TLS 启用标准主机名校验及自动续期，续期前 30/14/7 日预警，证书挑战与更新方式由 Owner 连同 DNS 或 VPN 方案确认。DB、FPM、Worker、Workerman 使用 Compose internal 网络，DB/FPM/WS 端口无主机发布。
- 旧 Compose 无 Workerman 与 Upgrade 代理。本轮独立 Compose 增加 `staging-ws` profile 与 Nginx 对 `/api/v1/messages/ws/{userId}?peer_id=…` 的 HTTP/1.1 Upgrade，Bearer 走请求头。默认关闭 `MATCHING_FOUNDATION_WEBSOCKET_ENABLED`。开关只控制传输。边缘不记录 Authorization、查询或业务内容的访问日志，启用前复核外层、错误日志和应用日志均满足同样脱敏要求。
- DB cache、session、queue 和单 Worker Workerman DB polling 已实测运行，首期无需 Redis。队列 Worker 与 Laravel scheduler 分开，账号关闭和用户自动化计划任务先按范围逐项决定，纳入后另验误触发与回退。增加 Redis、计划任务、外部邮件、RTC 或新公开入口均另列审批。
- 本地 502 需在远端放开 WebSocket 前明确改为可辨识拒绝并完成 token、A/B、跨代和实时撤权验收。将 WSS 探针的授权拒绝、上游不可达与正向 101 分开计量；单独的 `/up=200` 只作为 Laravel 存活指标。

### D · 数据、备份与回滚

只使用空白 Staging MariaDB 和独立媒体卷。设独特实例及库标识、私有服务账号、专属 APP_KEY；合成批次、数据保留窗口和责任人先登记。旧生产全库与旧媒体不进入 Staging。数据库与媒体成对做加密备份，恢复到另一套空实例、库和卷。推荐合成阶段每天备份，保留最近 7 份与每次变更前备份，RPO ≤24 小时、RTO ≤2 小时作为待验证目标。APP_KEY 和 TLS 秘钥单独保管，恢复权限分开审批。 [迁移、备份和回滚命令](../../../../services/backend-laravel/docker/shared-staging/RUNBOOK.md)

错误镜像、目标不符、越权、容量误差或备份不可恢复时暂停新流量。关闭新入口，停止新容器，保留新卷和审计。兼容 schema 时回退到已验收 Staging digest，变更过 schema 时从成对备份恢复到新目标后再切 Staging。首发失败关闭新入口并隔离即可。回滚责任人、执行时限、回切批准和验收指标写入 Owner 批准回执。

### E · StagingSyntheticConnectionScope 设计，待 Owner 决策

现有 `SyntheticConnectionScope` 与 `LiveConsentService` 的本地例外绑定回环 18444、`elitesync_v2_function`、`2621121` 和固定合成批次。部署保留 `V1007_LOCAL_RESTORATION=false`，客户端请求头、账户自报资格和 Workerman flag 均不能放行关系。

- 独立策略仅在 `APP_ENV=staging`、显式服务端开关、唯一实例号、约定 HTTPS origin、实时 DB schema／server_id、由运维签发的 DB 实例标记与私有密钥均吻合时可用。生产镜像使用相同代码时也须强制拒绝，禁止 `APP_ENV=production` 或任何身份检查异常时打开。以不同环境配置与恢复克隆错目标的测试锁住门禁。
- 资格由私有 CLI 指定具名 A、B 内部 ID、两方均为正常启用的合成账号与同一批准 `synthetic_batch`、工单号、开始与到期时间。数据库记录规范化成对 ID、实例号与批次，审批可加私钥签名并避免重复。CLI 通过受控运维主体或私有凭据运行。没有对外授予、续期或撤销 Web API。
- 短时默认建议 8 小时、最长 24 小时，支持提前撤销和立即封流。记录创建、撤销、时间、执行人、审批号和拒绝原因，保留审计而无令牌或消息正文。资格仅允许请求指定 A/B 的 Connection，其后仍由关系状态、双方同意、Block、当前代际与现有 token 权限判定。HTTP 与 WS 复用同一服务端策略，重新计算能力，撤销使现连接关闭，旧代不可见。禁用、错误批次／用户对、复制 DB、错误实例、过期、撤销、重放与生产模式列入验收。
- 决策请选择 `批准限域合成授权的实现和测试` 或 `继续关闭共享 Connection`。本轮交付设计，未实现、签发或远程启用。批准实现后，代码需复核并补齐真实 WSS 101、事件、撤权、重连换代及 A/B 实机路径。

### F · 旧管理员身份恢复，单独数据审批

优先来源为经核身的旧 MariaDB 具名最小字段提取，历史快照仅作可验证的备选。填写具名数据保管人、批准窗口、来源回执和指定候选。仅取旧主体 ID、原手机号、角色／是否命中旧私有名单、启用状态和确有必要的显示名；不复制密码或哈希、MFA、凭据、会话、聊天、联系方式列表及媒体。持有人确认控制原号码，Owner 单独确认启用及授权角色。目标查重和 dry-run 后，由既有 `admin:legacy-restore` 单独批准写入，生成新 V2 ID，使用私有一次性激活码签发新凭据。已授予的临时凭据、会话和角色可撤销。APP 原登录标识、新密码、Web 管理范围均由本人远程走通。真实数据读取、解密、迁移和持有人激活均 NOT_RUN。 [Owner 恢复决定](https://github.com/zcx369658780/EliteSync-v10/blob/a77ebe606048be884d4682f27f77527b8d6fe5c1/docs/decisions/OWNER_V2_LEGACY_ADMIN_ACCOUNT_RECOVERY_REQUIRED_FOR_CLOSED_BETA_20261121.md) · [现有合成恢复回执](V2_BETA_PREP_LEGACY_ADMIN_AND_SHARED_HTTPS_REPORT_20261121.md)

### G · 未来共享端点 APK

现有 Gradle function flavor、原生 `ApiClient` 与 Flutter `api_transport_policy.dart` 把候选限定在 `https://127.0.0.1:18444/` 及专用测试证书。原生普通分支还含 `slowdate.top` 回退与 `DomainDns`。后续用新的显式 Staging flavor，由同一批准 origin 生成 Gradle BuildConfig 与 Dart define；WS 从同一 authority 派生 WSS。对 HTTPS 主机名和证书链做系统信任或经批准私有 CA 校验，拒绝非同源、跨域重定向和旧站 fallback。另行批准包名、versionCode、签名、APK SHA-256 与设备名单后，沿既有 AAR → APK 构建，实读 APK manifest、DEX、AAR／APK `libapp.so` 和 TLS，负测错误证书、错误域名、缺少端点、旧站无回退。现有 1011805／1011806／1011807 及其设备证据留用；共享 APK 未构建或安装。 [Android 构建](../../../../apps/android/app/build.gradle.kts) · [原生端点](../../../../apps/android/app/src/main/java/com/elitesync/network/ApiClient.kt) · [Dart 传输](../../../../apps/flutter_elitesync_module/lib/core/network/api_transport_policy.dart)

## 状态与证据哈希

远端 SSH／镜像上传／云部署／采购／DNS、防火墙、公网 443／旧服务变更／真实管理员操作／共享正向 WSS 和双设备／真实 WLAN／共享 APK／云端容量压测及内测均为 NOT_RUN。当前云报价、续期配置、实际空闲容量和私有 Registry digest 为 UNKNOWN。本机作业、迁移和回滚预演只支持部署审批评估。

本机证据目录末级为 `v2-cloud-r0-local-runtime-20261121/v2-shared-staging-predeploy-20261122`。原始日志、TLS 核验、SQL 与媒体在本机保留，审批方可按下表查验去敏证据身份。

| 证据 | SHA-256 |
| --- | --- |
| `01-backend-source.tar` | `44ad309469aa1200f709be18d0111118f6271313c99a148b9fff7836afbbfcd3` |
| `01-full-build.log` | `faeed6ba9333b1bba9392b237711ea5bec204cf08edd9ebea6c38ac253a24067` |
| `02-full-build.log` | `56e18061893c25228a90793d9c0a7ca66682ca3d265e46815129d3b1454c9f29` |
| `03-start-migrate.log` | `83602f83540242c2e22e93364b5a132d8efc5c34237fde56c953f68e40519b3d` |
| `04-business.log` | `632255a74bcb5fad2f1e1d69e4f5c6bb843229273ab1e5cb1d5e035d0a37a142` |
| `04-natal.log` | `617fe9151d2236a8724af8ac49aed345f90fcd7e92d88cd4e36dc308598ee34f` |
| `05-image-lock-readback.log` | `6660c07bc419822a7de85744d84f5f969f26fe672600c5ad8b14f5ecd2972738` |
| `06-queue-ws.log` | `3159971329a8ad19d20122bc20e1cc8003a9f730bc39d818c99f5acd79a77772` |
| `07-backup-restore-file.log` | `54aecea1e7171ff4f8348eba32cc4b6f3eec80cbbae3654cacb10773df26073f` |
| `08-runtime-close.log` | `a480be5bb989482044fded5617b644f3878975ee25f9167502f4e0f3cff6db29` |
