# EliteSync V2｜Beta 准备、旧管理员身份延续与共享 HTTPS 报告

2026-11-21（中国标准时间） · **本地合成恢复 PASS／真实管理员恢复 BLOCKED_OWNER_DATA_GATE／共享 HTTPS BLOCKED_CAPACITY_AND_OWNER_GATE／封闭内测与生产 NO_GO**

所有 Owner 指定且经本人核验的旧管理员都须完成原登录标识恢复、新凭据激活及异地登录。这是封闭内测准入硬门。当前没有取得真实账号候选、获批快照或云写入授权。 [Owner 决定](https://github.com/zcx369658780/EliteSync-v10/blob/a77ebe606048be884d4682f27f77527b8d6fe5c1/docs/decisions/OWNER_V2_LEGACY_ADMIN_ACCOUNT_RECOVERY_REQUIRED_FOR_CLOSED_BETA_20261121.md) · [固定任务书](https://github.com/zcx369658780/EliteSync-v10/blob/a77ebe606048be884d4682f27f77527b8d6fe5c1/docs/versions/v2/V2_BETA_PREP_SHARED_BACKEND_AND_LEGACY_ADMIN_RECOVERY_CONSOLIDATED_TASK_20261121.md)

## 工程与当前权限合同

实际工程为隔离目录 `v2-cloud-r0-20261121`、origin `zcx369658780/EliteSync-v10`、分支 `codex/v2-function-completion-20261121`。起点 `651f3dea30cb6744d6a3863e5d9f7a921ca7ae43`，工作树和暂存区为空。使用 PHP 8.4.28、固定 MariaDB 10.11.19、原专用 `elitesync_v2_function` 库和 server ID 2621121。恢复演练入口单独绑定本机 HTTPS 18445，原 18444 用于缺 allowlist 的反例。新增 FPM 与边缘容器已停止。原功能容器和两卷保留，数据库运行正常。 [P0.3 工程基线](https://github.com/zcx369658780/EliteSync-v10/commit/651f3dea30cb6744d6a3863e5d9f7a921ca7ae43)

| 现行合同 | 源码核对与恢复处理 |
|---|---|
| APP 登录 | `users.phone` 唯一。现有 API 按手机号查用户并检查 V2 密码，拒绝禁用账号，由 DeviceSessions/Sanctum 签发新访问/刷新令牌。恢复分配新 ID，原手机号须以本人确认且符合格式的原标识入库。 |
| 管理员 | `AdminAccess::allows()` 同时检查用户存在、未禁用、`role=admin`、手机号精确命中服务端私有 `ADMIN_PHONES`。常规 Web 与管理员 API 使用该控制，匹配运营等另有专门门禁。现有 admin 角色的管理面较宽，仅应对确需管理员的具名人开放。 |
| Web | 独立 `/admin/login` 校验手机号、密码和 AdminAccess，限速 10 次/分钟，成功轮换 Web session ID 并记录管理员会话。后台使用 CSRF、当前账户与 allowlist 校验。退出撤销会话并轮换 CSRF。 |
| 真实身份 | 恢复时 `verify_status=pending`、`realname_verified=false`，保持身份、安全与 V2 测试资格各自独立。 |

源码核对与原行为回归入口见 [AdminAccess](../../../../services/backend-laravel/app/Services/Accounts/AdminAccess.php)、[Web 登录](../../../../services/backend-laravel/app/Http/Controllers/Web/AdminController.php)、[APP 登录](../../../../services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php) 和 [原 Web 测试](../../../../services/backend-laravel/tests/Feature/V1006AdminWebTest.php)。

## 恢复工具与合成演练

CLI 为 `php artisan admin:legacy-restore <受控清单文件>`。默认只读 dry-run，仅打印候选代号和状态。清单须给出固定批次、旧系统代号、快照代号、目标、Owner 批准回执号、操作者及逐个获准候选。每人输入字段限旧主体 ID、原手机号、旧状态、批准角色、可选必要显示名及不可逆公开代号。手机号冲突、跨快照已映射的旧 ID、名单未入目标配置或同批异内容均停止。正式动作在数据库事务中运行，批次、旧主体、手机号及 V2 映射受唯一约束。 [固定恢复源码](https://github.com/zcx369658780/EliteSync-v10/commit/d1c653194c1f5cd11be444e75648ae8176325301)

| 操作 | 结果和边界 |
|---|---|
| `--action=apply` | 核对目标别名、配置批准号、HTTPS origin、MariaDB 实际库名/主机/server ID/版本及会话库。创建禁用普通身份和私有映射。重复执行返回已有状态。 |
| `--action=issue --candidate=<代号> --out=<私有文件>` | CLI 签发 30 分钟随机码，仅在独占新建的私有 Linux 文件交付，凭据的 SHA-256 入库。重签作废前码。手机号在签发及激活时重验原绑定和私有 allowlist。 |
| 持有人在受限 HTTPS 激活页输入一次性码和新密码 | 激活页只受理已有 CLI 签发的凭据，采用 POST、CSRF、限速及不缓存。新密码写入、激活码消耗、赋予获准角色及审计同事务。随后持有人用原手机号和新密码单独走现有 APP 或 Web 登录。 |
| `--action=rollback` | 禁用并降为普通角色，撤销该批激活码、Sanctum 和设备会话、数据库 Web 会话及管理员会话，保留映射和审计。回滚可重跑，已回滚批次不能再次启用。运行负责人同步从私有 `ADMIN_PHONES` 移除本批条目。回滚以 CLI 为准，保留审计迁移表。 |

审计在受控库记录批次、来源、旧到新映射、字段名、动作、操作者代号和时点。可恢复账号仅由批准清单输入。旧密码或哈希、Token、session、MFA、API key、邮箱及其它业务资料不在本工具输入合同内。激活码文件用于一次性私下交付，到期或使用后依获批保留期限处置。 [CLI 源码](../../../../services/backend-laravel/app/Console/Commands/LegacyAdminRestoreCommand.php) · [迁移定义](../../../../services/backend-laravel/database/migrations/2026_11_21_190000_create_legacy_admin_restore_tables.php)

| 定向验证 | 实际结果 |
|---|---|
| 专用 MariaDB / 固定证书 HTTPS | 两名虚构管理员。默认 dry-run 前后无映射或审计写入，重复 apply 保留两个新 ID 和原手机号。重签旧码及已用码 422，独占输出冲突退出 1，无 CSRF 激活 419。两人以新密码走 APP 登录 API 200，并在实际 Web 会话查看用户、形象审核、举报和审计，均为 200。前置 Web cookie 无权限，旧密码 422、虚构旧 token 401、虚构旧 Web cookie 转回登录。 |
| 权限与回滚 | 同一个 V2 bearer 在缺 allowlist 的原本机入口返回 403。回滚并重复执行后，被恢复账号无可用访问/刷新令牌、设备会话及 Web 管理会话。旧 bearer/refresh 均 401，新密码登录 403，已有 Web 会话被送回登录。审计保留 9 个事件，两个合成账号以禁用非管理员状态保留。 |
| 速率限制与定向回归 | 实际 HTTPS 激活第 6 次、Web 登录第 11 次均触发 429。PHP 8.4 定向 10 项、100 断言通过，含 TTL 到期、错目标/审批、非法字段、现有手机号冲突、重复来源、普通账号无管理权、既有账号在回滚后保留及 Web CSRF/退出。 |
| 失败与验证限制 | 首轮 PHP 测试辅助代码直接传入了未经解析排序的清单，签发因批次指纹不一致停止。测试改用同一正式清单解析器后复测通过。合成演练覆盖 APP 登录 API 与实际 Web HTTP 表单，实体手机上的激活/登录和真实持有人异地登录均 NOT_RUN。 |

## 旧账号来源与可恢复性

G0 已限定接受旧站、旧库归属和备份目录元数据。G0b 决策报告为本地证据，顾问独立审阅仍待。使用原证评估，本轮 SSH、读取真实管理员、解压或解密、历史 SQL 演练、云端写入均 NOT_RUN。 [CLOUD-R0 原报告](V2_CLOUD_R0_ENGINEERING_REPORT_20261121.md)

| 来源 | 可用于何处和待证条件 |
|---|---|
| A · 现时旧 MariaDB 10.11.14 | 优先。旧 Laravel 缓存确认指向主机回环库，schema 和历史 manifest 有关联。登录标识的持有人、旧角色和旧私有管理员名单、当前启用状态均未核。Owner 指定候选和时间窗后，由具名数据保管人建立一致、可核来源标记的最小字段只读提取。实际读取时重验实例、schema 和授权主体边界。 |
| B · 2026-05-08 三份 gzip | 仅作回退。三份本地 gzip 已与各自 sidecar 实算吻合，也与远端声明摘要、长度、schema、端口关联。远端原始字节未重算、格式兼容与实际恢复未证。先做授权范围内的原始字节验签。若可恢复，再由受控来源载体仅提取获批行。历史记录还需重新核现在的持有人和有效权限。如果无法在批准范围内提取最小字段，维持 BLOCKED，不导入全库。 |
| C · 独立的历史 GPG 密文组 | 与五月 gzip 分开。仅有密文字节摘要，缺独立 sidecar 与可核解密条件。暂不作为恢复输入。 |

## 一次性 Owner 数据与环境授权包

当前为 **PENDING**。公开报告不记真实候选姓名、号码或旧/新 ID。以下未定项由 Owner 与数据保管人在私有审批表一次填定并确认，工具的批准号须能追溯该表。

| 需 Owner 一次确认 | 请求边界 |
|---|---|
| 来源与截止时间 | 优先 A，填写 G0 已验证实例、旧 schema、具名一致性提取/快照回执、截止时间与读取时间窗。若选 B，明确一份 manifest ID、远/本端 SHA-256 复核和提取方式。密文解密若确有必要，须在此包另列文件、保管人、权限范围和处理环境。 |
| 候选与持有人 | 私表填写明确人数、随机代号、旧主体引用、当前旧管理员名单命中、未禁用及本人控制原号码的核验结果、APP 与 Web 权限用途。当前人数与身份均 UNKNOWN。任一无证据候选标 `BLOCKED_REVIEW`，不能以重复注册或照搬旧角色代替。 |
| 允许字段和操作 | 读旧 ID、手机号、启用状态、旧角色及名单是否命中，显示名仅必要时另列。写 V2 原手机号、经批准角色、必要显示名、新 ID 及恢复审计，先以最小只读提取和 dry-run 核冲突。无生日、地理位置、认证资料、关系、聊天、媒体、旧凭据、MFA 或其他用户业务。 |
| 目标、责任人和费用 | 填固定 V2 Beta 实例 ID、域名与镜像 digest、目标库/schema/内部主机/server ID、私有配置版本、备份回执、允许来源、数据保管人、CLI 执行人、证据复核人、回滚责任人、同事联系渠道、测试和数据留存时间窗、含税总费用上限。当前生产旧库不在目标范围。 |
| 回滚与通过口径 | 写入前备份目标 V2 并验证可恢复性。错误来源、冲突、失权、账号本人无法验证或任一压力指标越线时停止。撤销这批激活码、账号权限、allowlist 和新会话，按需要撤掉新 HTTPS 入口。保留审计，通知具名持有人。所有指定人完成本人远程登录才可申请内测。 |

## 共享 V2 HTTPS 方案与成本

先评估现有上海 `Ubuntu-zlxh`。历史只读观察为 2 vCPU/2 GiB/40 GiB ESSD，两次可用内存约 627–628 MiB、无 swap、根盘空余约 24 GiB。旧 Laravel、主机 MariaDB、Redis、LiveKit 同驻。按历史 FPM 的 4 workers × 256 MiB 配置上界，单 FPM 就可能大于取样空闲内存，尚要计入 Node/Python、worker、独立 MariaDB 和旧业务波动。8088 回环入口与旧 Laravel 共用，暂不符合隔离目标。当前同驻为 `CAPACITY_NOT_APPROVED`。 [G0 现场元数据](V2_CLOUD_R0_ENGINEERING_REPORT_20261121.md#g0阿里云核身)

| 候选 | 可行性与预算范围 |
|---|---|
| 现有上海实例，优先评估 | 需另外获准的新一轮只读容量验证，覆盖旧站高峰、LiveKit、CPU/内存/OOM、磁盘 I/O、备份峰值及端口。再用合成负载验证明确的 V2 资源上限与旧业务退化阈值。同规格复用的新增实例费在条件满足时为零，域名/TLS、网络、快照或容量扩展费用仍待账单确认。 |
| 已有其它隔离资源，或独立上海 Staging | 若旧机容量不足，报价起点为 2 vCPU、4 GiB、40–60 GiB SSD，按独立 PHP8.4/MariaDB10.11、三盘计算、队列和留存实测修正。轻量实例核套餐、带宽、流量、快照和续费。ECS 另核系统盘、公网 IP/VPN、备份及停机留存。实际含税费用 UNKNOWN，待在本包确认期限和总上限。 |
| 暂无合格共享资源 | 继续本地合成工程。异地登录与内测继续阻断。本次新增云支出为零。 |

部署时为 V2 设置独立进程及 worker、专用 MariaDB/schema/账号/卷、独立媒体卷和内部容器网络。隔离 APP_KEY、会话 cookie、`ADMIN_PHONES` 及恢复配置。边缘入口使用受信 TLS、具名 VPN 或来源限制，APP API 给经批准设备可达，Web 管理和激活入口另限管理来源。数据库、Redis、FPM 不发布公网端口。保留旧业务端口、站点、数据库、Redis 和 LiveKit 原始身份。合成环境先核三盘依赖、迁移/回滚、并行负载、备份恢复与错误目标拒绝。部署或负载不符合时只停新入口和新进程，保留新卷和证据供调查。

## 同事异地验收与剩余条件

- 先固定共享域名、TLS 证书、后端镜像与 APK 版本，核 Android 原生与 Dart 端点一致并排除旧站回退。用合成账号在具名网络上通过 HTTPS 验证，涵盖三盘和消息等业务。在分发前锁定包名、签名、versionCode、SHA-256 和目标设备范围。
- 真实恢复获批后，逐个持有人从外地访问受限激活入口，以新凭据设置密码，用原手机号亲自在 APP 登录。获批管理员再独立登录 Web，验证用户、审核、举报、审计等具名场景，以及未列名单、缺角色、禁用、退出、旧会话与撤权反例。用户和操作者分别具名，报告只存代号、去敏状态和证据哈希。全体指定候选均成功才可提交 Owner 准入审阅。
- P0.4 本地已补会话页拉黑确认、UNKNOWN 时只读核对、撤权后的发送/媒体控件限制，以及正式关系 ACTIVE 文案。消息响应丢失时，点原编号重试先重读当前会话。读到同一消息即确认，未在最新窗口读到时可以在重验权限后按原键显式重试。Flutter 定向 67 项通过，涉及改动文件的静态分析通过。首轮测试发现控件 Finder 类型和同键重试失配，已修正并复测。A05 原图 SHA 已重算与索引匹配，原文件名沿用旧采集顺序。 [P0.4 本轮代码](https://github.com/zcx369658780/EliteSync-v10/commit/1ae36d248974c32ea1ef0beb0d964c2bc01b6132)
- P0.4 实机媒体、历史受众与外部旧 URI、跨进程/网络故障矩阵、全量回归和新 APK 均待补。1011805 仍是原机证据版本。真实 KYC/Push/RTC/删除受理、旧排盘 A/B/C、注册可信离线 T0、软著登记选图与权属及既有历史失败继续按原记录。共享 HTTPS、全部具名管理员恢复、本人登录和 Owner 的测试范围/停止机制共同决定封闭内测是否可申请。

## 本地证据

以下为私有运行目录去敏回执的 SHA-256。运行叠加镜像 ID 为 `sha256:041cda5414ccd0b51433da04ee38d1e8003c0a7d50fd9f2763b861bdd6caac39`，属于本机现有基镜像上的定向验证。部署候选仓库镜像 digest 尚未固定。

| 回执 | SHA-256 |
|---|---|
| `beta-prep-staging.log` | `ac01a520d0743807a0458ac0dd544c9de3bb31104729703782743b3bab3a11c6` |
| `beta-prep-rehearsal.log` | `437af0f249efc89af5fe1c44c2a01a4d07371cf4b5ebbcf1450ec5bd90082599` |
| `beta-prep-phpunit.log` | `0e3567ce447e76b3cbfcc4b5cd2faa3549c66edc1678d67cf3acb62098fd3266` |
| `beta-prep-throttle.log` | `89e715095813bae2e11227a17453a2669496eb55b40e94a50184a386fad090ea` |
| `beta-prep-p04-flutter.log` | `171df98ffd131725f108abaebae24aff019cc252302a1e7b227d235d9be81f85` |
| `beta-prep-p04-analysis.log` | `dfd7ccf0b428d0e3af69561a17e1b1d677f74024512095c57e7607e61420e662` |
