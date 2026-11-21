# EliteSync V2-CLOUD-R0 综合工程报告

2026-11-21（中国标准时间）

**本地隔离 Staging 已完成定向验证。阿里云目标仍待核身，真实管理员恢复和 Android 云端实测未执行。生产维持 `NO_GO`。**

| 分项 | 现场结论 | 范围 |
|---|---|---|
| G0 实例与旧服务 | `BLOCKED` | 阿里云控制台登录门槛。当前实例、旧服务和备份归属待证 |
| G1 V2 Staging | `PARTIAL` | 独立本地 Linux 构建、迁移和定向集成通过。云端 Staging `NOT_RUN` |
| G2 管理员 | `PARTIAL` | 两组备份完成不透明字节核验，合成映射与授权演练通过。真实资料门待裁定 |
| G3 Android 云端实测 | `NOT_RUN / DEVICE_PENDING` | 待合格云端 HTTPS、具名设备及独立 APK |

## 权限与工程身份

- 治理固定提交 `e486e5d4724f63dabab2b146c7e438fc91d7a9ed`，与治理分支远端 HEAD 回读一致。执行依据为 Owner 授权、集中任务书、ACTIVE_STATE 顶部与本轮启动说明。 [固定治理提交](https://github.com/zcx369658780/EliteSync-v10/tree/e486e5d4724f63dabab2b146c7e438fc91d7a9ed)
- 工程基线 R1 `585a8c21aeab103daac166338f881ef343c8af99`。隔离树以 `V2_CLOUD_R0_WORKTREE` 代称，目录名 `v2-cloud-r0-20261121`，分支 `codex/v2-cloud-r0-gradual-staging-20261121`，origin 为 `zcx369658780/EliteSync-v10`。镜像从 `4c255a0915ecc792b083f94798c40216ec870f07` 的后端 Git 归档构建，OCI revision 已标注该提交。交付包含本地合成回归脚本以及本报告。Flutter、Laravel 产品逻辑和原迁移定义保留原 R1 版本。 [运行时源码](https://github.com/zcx369658780/EliteSync-v10/tree/4c255a0915ecc792b083f94798c40216ec870f07/services/backend-laravel/docker/cloud-r0)
- PC 清理已关闭，旧 13 项继续保留。原脏 main、旧工作树、旧 APK 和私有证据均保持原状。实际操作仅涉及本任务隔离工作树、专属本地容器及本地证据目录。

## G0｜阿里云核身

历史线索指向上海轻量应用服务器。通过阿里云控制台该产品入口进入后，页面要求登录。现时账号、地域与产品类型绑定、实例 ID、公网绑定、资源容量与费用均为 `UNKNOWN`。站点、API、数据库、卷、容器挂载及备份关系均未取得现场证据。SSH 当前端口及可信主机指纹没有独立来源，SSH `NOT_RUN`。现阶段旧系统、站点、反向代理、生产数据库、容器网络、卷、备份及现有入口均列为保护对象。

## G1｜本地镜像、隔离与实测

专属 WSL Ubuntu 24.04.5、Docker 29.1.3、Compose 2.40.3，以独立空容器与卷启动。Compose 项目 `elitesync-v2-cloud-r0`，专属 MariaDB 和媒体卷，数据网为 internal，数据库与 FPM 均无主机发布端口。Nginx 仅绑定主机回环 HTTPS。用本机信任的测试证书验证名称和 TLS。密钥文件、数据库和媒体字节留在隔离环境。四个本地容器在交付前均已停止并回读为 `exited 0`，两卷保留。

| 组件 | 实测身份 |
|---|---|
| PHP-FPM 和 worker | PHP 8.4.28、Laravel 13.39.0、Linux amd64、UID 33。两者本地镜像 ID `sha256:579663375d8dfacd1178b43b31ee42b2f1d1605034ab3cfe9b3bfca8ef26d578` |
| MariaDB | 10.11.19，schema `elitesync_v2_r0`，预检 server ID `2621111`。固定镜像 `sha256:5d60ca6129f939453472f4ed385c54820ec57f3aa384a8646619f9bc0e3b5eab` |
| Nginx | 固定镜像 `sha256:0dcc88822d45581e65ae329f8be769762bf628d3b2bb7d2a077d4aa5c98b30e3` |
| 三盘依赖 | Python 3.11.2、Node 22.23.5、iztro 2.5.8。DE440s 32,726,016 字节，容器只读，SHA-256 `c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2` |

构建采用固定基础镜像 digest 与 Composer、Python 哈希锁、npm 锁，平台依赖检查通过。OS、PHP、Python、npm 版本清单保留。Debian 软件包由构建时的仓库解析，跨时间逐字节复建和独立漏洞扫描均为 `NOT_RUN`。应用镜像 ID 为本地证据，云镜像仓库 digest 待实际交付。

| 核验 | 真实结果 |
|---|---|
| 数据库配置与迁移 | Laravel 实际使用 `staging`、debug 关闭、`mariadb`、空 `DB_URL`。缓存、会话、队列使用隔离数据库，Secure Cookie 有效配置为 true。预检 0 表后应用 91 个迁移、115 表。最新一项回滚至 112 表后重迁至 115 表。再次要求空库时预检拒绝，退出码 1 |
| HTTPS 三盘与权限 | 已知时刻 POST 200，计算结果含八字、紫微、西盘，紫微和西盘为 `CALCULATED`，保留 `COMPUTED_UNVERIFIED` 与紫微 `UNVERIFIED`。所有者 GET 持久读回一致，另一账号 `exists=false`，无登录 401，旧版本写 409。未知时刻 POST 200，归一时间为空，西盘 `UNKNOWN` |
| 缺依赖与重启 | 仅在本地 FPM 注入不可用 Node 路径，POST 503 `natal_calculation_unavailable`，GET 为 `FAILED` 且无结果。恢复配置后先读原状态，再按当前版本重算至第 2 版。单独重启 MariaDB、再单独重启 FPM，HTTPS 健康返回 200，两个 MariaDB 结果均保留。worker 以同 UID 和镜像独立计算三盘 |
| 真实队列 | 已有 `ProcessMediaAssetJob` 经数据库队列被 worker 消费，新增 1 条成功审计，队列余额 0，失败作业 0 |
| 登录与正式门禁 | 虚构主体 HTTPS 登录与会话核验 200，退出后旧凭证 401。正式手动报名 403。真实 KYC、Push、RTC 均 `NOT_RUN` |
| Lifestyle 与 Buddy | 两个不同请求键同版本并发，一个 200、一个 409，写入和回执各 1。原结果查询、跨账号隔离及冲突复核通过。Buddy 先查 `NOT_APPLIED`，创建后查 `APPLIED`，同键同内容重试返回原 ID，改内容 409 |
| 媒体与 Block | 现有私有照片上传和所有者读回 200，响应 `no-store`。另一账号 404，未登录 401。好友动态原受众读 200，其它账号和 Block 后原旧链接均 404。首轮旧 PNG 样例上传返回 422，改为生成的有效 PNG 后复测通过，原始失败日志保留 |
| Connection 与消息 | 合成好友关系已存在时，当前 Staging 的 Connection 请求仍返回 404。R1 `LiveConsentService::enabled()` 只允许现有受信本地环境。保留此门禁。双向 Connection、消息同意、发送消息的完整正向链尚未通过，通知和跨进程缓存全量回归 `NOT_RUN` |

性能证据限于短时合成样例，已知时刻正例约 1 秒。长时 FPM/worker 超时故障、全量历史套件、发布容量和云端灾备演练 `NOT_RUN`。受控回滚和单服务重启只覆盖本地合成库。历史手机三盘 503 根因仍为 `UNKNOWN`。

## G2｜备份来源和合成账号

| 来源 | 本轮仅元数据核验 | 恢复资格 |
|---|---|---|
| 2026-05-08 旧阿里云备份组 | 3 个 gzip 字节 SHA-256 与附带 sidecar 对应值一致，保留原 manifest | 来源实例、schema、管理员范围、合法可读性与恢复链待证。历史 9.0-C GPG 中止保持 |
| 另一独立历史备份组 | 检查 2 个 GPG 密文文件，计算各自 SHA-256，邻近目录未找到对应校验 sidecar | 密文来源、完整性基线、解密条件和归属待证。解密与恢复 `NOT_RUN` |

全合成演练验证旧主体引用映射至数据库生成的新 V2 user ID，联系方式冲突由唯一键拒绝。只以新凭据进入 V2，虚构旧密码无法匹配新哈希，虚构旧 token 被拒绝。实际管理员 API 在启用、admin 角色和显式允许名单三条件成立时返回 200，分别缺角色、缺名单时 403，禁用账号无法登录且在合成名单检查中仍被拒绝。撤销角色后，同一有效会话访问管理接口变为 403，随后退出令牌变为 401。真实账号、旧密码哈希、会话、MFA、密钥与业务记录没有进入该演练。

真实恢复建议逐主体审批。记录旧主体引用、当前验证过的最小联系人标识、批准角色和新 V2 ID 映射。操作者在独立新库中核冲突、现时启用状态、名单和权限范围，重新签发凭据并单独确认 MFA 或设备认证。若发生误授权，撤销角色及允许名单、使新会话失效，保留受控审计。实际管理页面与真实管理员重签、MFA 验证均 `NOT_RUN`。

## G3｜Android 回归资格

本轮未生成云端 APK、未接触手机。已查现行构建配置，Flutter 支持 `ELITESYNC_API_BASE_URL`，但 Android 主工程还有原生 `BuildConfig.API_BASE_URL` 和宿主注入，默认可回落到既有站点。取得具名 Staging HTTPS 后，须让 Flutter 与原生两条客户端路径均绑定该环境，再锁定独立包名、签名摘要、版本、代码提交和 APK SHA-256，验证无既有站点回退。之后只用具名手机和虚构账号走任务书旅程，采集去敏 HTTP 与实机证据。旧回环手机记录保留原判定。

## Owner 集中决策包

1. **先完成云核身。** 请 Owner 在受控会话打开上海轻量应用服务器的当前实例详情，提供可核对的账号归属、地域、产品类型、脱敏实例 ID、公网绑定、服务状态、容量及计费影响。若同意继续 SSH 只读盘点，请通过独立可信通道绑定该实例的当前地址、端口、host key 和只读操作者权限。保留密码、验证码和私钥在原授权通道。
2. **确认云隔离写入边界。** G0 取得旧站点、数据库、网络挂载及可恢复备份的证据后，集中确认具名隔离目标、资源额度和零额外费用或明确上限、访问主体、受限 TLS 入口、隔离数据库和卷、部署镜像身份及回滚责任人。初始成功口径为独立环境实际健康、空库预检和迁移通过。若失败，先撤掉本轮访问入口并停止本轮容器，保留专属新卷和日志供调查。
3. **独立批准真实管理员数据门。** 指定一份已证明来源的备份、合法数据持有人、逐个已核属主、允许读取的最小字段、操作者和具名隔离库。审批前保持 `BLOCKED_OWNER_DATA_GATE`。同时明确冲突处理、重签交付与撤权责任人。
4. **裁定 Connection 的 Staging 正向资格并确认设备。** 请评审是否在后续任务中为受限 Staging 定义新的可审计、服务端绑定资格，以验证 Connection→消息同意→消息链。当前保持 R1 门禁。云端 HTTPS 达标后，确认唯一测试手机、允许来源、测试账号和设备操作范围。

旧盘 A/B/C、注册可信离线 T0 仍 `OWNER_CHOICE_PENDING`。R1 既有全量 46 errors / 122 failures、25 项旧盘合同、历史 FAIL / UNKNOWN / NOT_RUN 保留原记录。阶段停在 Owner/GPT 集中复核，生产与 main 维持 `NO_GO`。

## 证据校验

本机运行证据以 `V2_CLOUD_R0_LOCAL_EVIDENCE` 代称。以下 SHA-256 为本机回执文件哈希。备份原文件、凭证、真实身份材料和截图不随 GitHub 提交。

| 回执 | SHA-256 |
|---|---|
| 镜像构建 | `650ebbbea13c7432e117900d70b93b640a298bb234d7ac3b5c7ac36877b8d27d` |
| 运行身份、队列与重启 | `f06b0f0ab0201400f984cacb0a570621f03a68bbece66f9e0a48fd61ffbf722f` |
| 三盘 HTTPS 正例 | `c4606cf1a8f76a6794879eec90031302a966cd991133bbe54ba776dd4698d779` |
| 三盘 503 与恢复 | `fa41f1762382df10e2c02e76747381d5856d0f7e4be2a4c805ddf7029a6f6a05` |
| worker 计算和空库预检反例 | `79f2eb159269dae87950bea044c3088088aa81aa38f8c766ebb95b4fde261997` |
| 业务及合成管理员 | `cade4770f975141b51b95ad7413cc93df63788db2ae671cd56c4b387162e8b6d` |
| 首轮 PNG 422 | `06cba7d9759c23e4e3ff1a7e4a53de60ff9680105ff7315e9c634873e3b318f6` |
| 备份字节核验 | `6fc8c899fa3a9521025fca92505c12c61017f5ea342b050328dc6b28fd01d645` |

复核入口为固定源码下的 `services/backend-laravel/docker/cloud-r0`。初次迁移应在通过 `php /opt/elitesync-r0/db-preflight.php --empty` 后，同一独立容器中执行。合成测试脚本仅针对本次专属本地项目和具名测试证书，业务写入使用虚构账号。
