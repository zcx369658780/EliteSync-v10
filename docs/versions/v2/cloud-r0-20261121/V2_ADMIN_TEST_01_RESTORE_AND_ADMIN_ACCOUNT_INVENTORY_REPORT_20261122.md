# EliteSync V2｜ADMIN-TEST-01 恢复执行与管理员账号盘点

2026-11-22（中国标准时间）

**当前状态：HOLDER_PROOF_PENDING。ADMIN-TEST-01 尚未恢复。** V2 当前旧管理员恢复来源的批次、映射和激活审计均为 0。下列盘点为恢复前基线。

## 执行结果

| 项目 | 状态 | 核验结果 |
| --- | --- | --- |
| 固定任务与候选来源 | PASS | 任务提交 `15ce1eb421f2ce3d4beda58a1fe3a96b8191363b`，任务 blob `02944742d33037b87eb69f2840b07b36a97ed839`。服务器复核 4 份私有文件为 root 所有、权限 0600，接收目录及草稿目录为 0700。候选、旧主库 `elitesync` 的同源证据及草稿目标绑定一致。 |
| 原号码控制 | HOLDER_PROOF_PENDING | 指定私有接收范围内持有人回执 0、签名材料 0。固定源码、旧服务运行配置文件、V2 配置文件及运行容器中均未找到可用短信／语音核验渠道的证据。外部已获批渠道是否存在为 UNKNOWN。一次性挑战和私有回执生成均为 NOT_RUN。 |
| V2 运行与数据库身份 | PASS | 实际运行的是固定源码 `7e0009df4fe69e48967c4fbc111717626c85ed80`、`linux/amd64`，云端导入镜像配置 ID 为 `sha256:5a7ee83db71cdf799c0998233e3dc0b9e3ad0958fa77227f590bd15063ac99cf`。Compose 项目 `elitesync-v2-shared-staging-beta`，APP_ENV=staging，实例身份、MariaDB 10.11.19、内部 DB 主机、schema `elitesync_v2_beta_staging`、`server_id=2621124`、3306、会话登录及授权账号、同一读写 PDO 和安全数据库会话已回验。HTTPS 回环 18446 使用指定证书验证，健康返回 200。 |
| 私有白名单与候选冲突 | PASS（只读核对）／NOT_RUN（变更） | 当前有效条目 0，候选未列入。拟议差异仅增加该候选一项，移除 0。具名查询的同登录标识、同来源旧标识映射、拟议批次各为 0。白名单变更和配置缓存重建未执行。若后续写入，先备份 V2 私有配置并记 SHA-256，回滚只移除本次新增项。 |
| Owner Manifest | PENDING／NOT_RUN（验签） | 原草稿的唯一候选、最小字段范围、旧证据和目标绑定已核对。当前缺具名持有人回执、批准号、操作者、签发及失效时间、Owner 公钥绑定和独立签名。运行环境支持 Ed25519 验签，正式签名输入等待回执。 |
| 签名 dry-run、apply | NOT_RUN | 待有效的 holder proof、签名、恢复运行时绑定及唯一白名单差异。 |
| 一次性激活、本人 APP 登录、本人 Web 管理员登录 | NOT_RUN | 待签名 dry-run 唯一候选 ready、apply 和一次性激活。 |
| 恢复前账号盘点 | PASS | 只读查询旧来源 `elitesync-legacy-web` 的 `legacy_admin_batches`、`legacy_admin_mappings`、`legacy_admin_restore_audits` 及 `users` 关联。批次 0、映射 0、激活审计 0。ADMIN-TEST-01 无 V2 用户或映射，其他候选同来源映射 0，pending／active／rolled_back 各为 0。恢复后盘点 NOT_RUN。 |
| 数据保护 | PASS（归档校验） | 旧数据库、媒体、配置与原名单来源的云端归档 SHA-256 7/7 通过。V2 数据及媒体恢复归档 SHA-256 3/3 通过。独立恢复结果沿用旧栈和 V2 切换回执。云端操作限只读检查，私有证据和备份原件均保留。 |

## 顾问复核与接续

由具名核验人或可信服务通过已批准的私有渠道完成原号码验证，提交带有效期的私有回执引用。根据回执填充签名字段，用固定源码 `LegacyAdminApproval::message()` 生成规范化签名输入并计算 SHA-256。Owner 在其受控环境完成 Ed25519 detached 签名，经私有渠道交付签名结果。验签、专用目标和白名单回验就绪后，执行实际签名 dry-run。唯一候选 ready 且无冲突时，再按任务单执行同一清单的 apply、激活和本人登录。

首个审计脚本以本机构建镜像 ID 比较云端容器配置 ID，身份断言退出码 1，标准错误为空，尚未进入该脚本的业务查询。依据固定部署报告改用已核对的云端导入配置 ID 后，只读复验退出码 0。两个回执均留存。私有接收点核对脚本另有一条既有 Python 正则转义 SyntaxWarning，退出码 0，返回结构化核验结果。

R1 仍为 PARTIAL，封闭内测与生产仍为 NO_GO。共享私信、WSS 和公网管理入口的开启为 NOT_RUN。

## 脱敏证据索引

证据文件保存在本地工程留存目录，以下记录原始输出文件的 SHA-256。私有回执内容及运行配置留在受控环境。

| 证据 | 退出码 | SHA-256 |
| --- | ---: | --- |
| `01-private-target.stdout` | 0 | `5591d85549676253fe59bb6de96f40be4f9fd57b7856b70cc9c284d5eb17c0dd` |
| `02-live-audit.stdout` | 1 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `02b-live-audit.stdout` | 0 | `ea3ad7436ad4f12df3004e83338ef973a90a3b8d43233d6394a32ad24ec44c7b` |
| `03-named-conflict.stdout` | 0 | `4db50b1a9ca18dba7e880a7833419551f9c9dcd20bd18999bd5732b370a52e68` |

[固定任务单](../../../../tasks/V2_ADMIN_TEST_01_RESTORE_EXECUTION_AND_POST_RESTORE_AUDIT_20261122.md) · [候选来源核验](V2_LEGACY_ADMIN_PRIVATE_CANDIDATE_SHORTLIST_20261122.md) · [旧栈和 V2 归档恢复回执](V2_LEGACY_STACK_RETIREMENT_AND_BETA_CUTOVER_20261122.md)
