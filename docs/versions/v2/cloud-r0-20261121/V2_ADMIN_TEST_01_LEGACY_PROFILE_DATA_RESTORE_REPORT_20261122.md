# EliteSync V2｜ADMIN-TEST-01 旧个人资料恢复报告

## 2026-11-23｜1011809 实体 APP 本人验收

**PROFILE_API_AND_RESTART_9_OF_9_PASS / OWNER_APP_BASIC_PROFILE_PASS / NATAL_NOT_YET_COMPUTED**

- 已获固定 APK 与具名手机授权，在实体手机安装并启动 1011809。首轮 Android 安装返回 `INSTALL_FAILED_USER_RESTRICTED`，只读确认新包未落盘。Owner 在场后重试通过，手机内 APK SHA-256 与候选一致，四个既有包版本核对一致。
- Owner 在手机上登录后确认基础信息已完全恢复。此项为本人界面验收，服务端 9/9 沿用下节的字段读回。验收记录未采集资料值或截图。
- 本命盘使用独立输入与计算合同。23:02 只读确认当前具名账号无本命盘记录，现有离线排盘运行身份为 `AVAILABLE`，本地 Node 可用。APP 使用「我 → 三盘本命 → 三盘本命 · 手填与排盘」，由 Owner 本人确认排盘输入和提交。当前未生成，不导入旧缓存。公网 443 连通性测试 0 次，R1 及发布结论沿用。

| 脱敏回执 | SHA-256 |
| --- | --- |
| `21-p0-app-1011809-install-receipt.json` | `58e93487b37970b6a4677c6c2bc4f7271650da7b30aa80a313850f6fea0a5234` |
| `21-p0-app-1011809-install-retry-01-receipt.json` | `c1e3d9ae65d31cfff1d2c56217e023404d4a87b24d3aed1990dfcaa29f800e7d` |
| `22-p0-app-1011809-owner-handoff.json` | `0afa62f760997781e813c7ef299b15502922299f8c4c22b6113fcd4d9664703e` |
| `23-p0-owner-natal-readback-20261123-230248.json` | `1f1556469050b0093573c3df57854ef414c41b2f0719efb2a1320703db14df10` |

## 2026-11-23 22:08（北京时间）｜Owner 授权补恢复昵称

**NICKNAME_APPLY_PASS / PROFILE_API_AND_RESTART_9_OF_9_PASS / APP_PROFILE_NOT_RUN**

- 唯一账号仍为 `ADMIN-TEST-01`，目标为 `elitesync_v2_beta_staging`，`server_id=2621124`，运行源码 `7e0009df4fe69e48967c4fbc111717626c85ed80`。旧主库同一映射的 `users.name` 有效，主库没有独立 `nickname` 或 `display_name` 列。旧后端 `ProfileController` 的基础资料读写使用 `name`，V2 昵称写入 `users.name`。Owner 对该来源和空目标列授权一次补写。
- 新备份 SHA-256 `175e2b9e82b0e242b92d3f5d5dc1c2505fa7c5469b3439a606ff1b346dc200d5`。备份在无网络、无发布端口的隔离 MariaDB 恢复，重导与原逻辑备份逐字节一致，隔离容器已停止。前态快照 SHA-256 `b276825b4e87785ebad7655357455344228f5eb92df176f29a43621601b4a6fe`。Dry-run 仅 `name` 为 READY，事务内锁定已核对的映射和现有用户行，确认目标仍为空，单次提交只更新 `users.name`。
- 写入后及仅重启 `staging-app` 后，进程内资料 API 均返回 200，昵称和此前 8 个字段 9/9。两次后态快照 SHA-256 均为 `1accaceada3be0bef7abd975739f9e55d8b243b6f504efed050b20ce0c84a20d`。密码、权限、已有会话、其他账号、映射、激活审计和派生资料均核对一致。回环 `18446/up` 返回 200。公网 443 连通性测试 0 次。
- Owner 本人实体 APP 资料页验收仍待完成。1011809 安装需具名手机和固定 SHA-256 授权。R1 为 PARTIAL，封闭内测和生产为 NO_GO。

| 脱敏回执 | SHA-256 |
| --- | --- |
| `19-p0-nickname-prepare-20261123-220725.json` | `da96e23c5b14d8a41862492382aba3f8a1cf7ac5c891e924285db12907e08ffa` |
| `19-p0-nickname-apply-20261123-220747.json` | `1bd1feec89a503a2fc9c3bac44979f8a6c7dbcd4cf2df6b428e816e898c9daeb` |
| `19-p0-nickname-verify-20261123-220749.json` | `e0cb878bb8fccf2d55b9cb0092ff7853f19ffd7543790bbcdb37f7c50426b643` |
| `19-p0-nickname-restart_verify-20261123-220802.json` | `8033ead293fb30f8e306c5aa42902c1db0e7bcc2ab251282a498bcb28815ddc5` |

## 原恢复批次记录

2026-11-23（北京时间） · **APPLY_PASS / API_READBACK_PASS / PROFILE_TRANSPORT_LOCAL_PASS / APP_PROFILE_NOT_RUN**

仅恢复 `ADMIN-TEST-01` 的 8 个无歧义资料字段。事务提交后及 V2 应用容器重启后，资料 API 均返回 200，8 个字段逐项一致。昵称语义待核，保留 V2 原值。Owner 本人在 APP 资料页的显示验收待完成。

## 固定基线与来源

- 治理任务基线 `3bf5769494feca893e2ea0369f836926d572c5e0`，云端业务源码 `7e0009df4fe69e48967c4fbc111717626c85ed80`，业务 Git tree `80b7237fcd0c7d569a7026d4a73d1e0c34ef86b9`。
- 目标为 `elitesync-v2-shared-staging-beta` 的 `elitesync_v2_beta_staging`，MariaDB `server_id=2621124`。现有 `legacy_admin_mappings` 唯一 active 行、签名批次指纹和既有恢复审计共同绑定旧账号及当前 V2 管理员。
- 旧主库 1 条精确身份匹配，辅助旧库 0 条精确身份匹配。同账号 Astro 原始输入通过旧 `user_id` 关联。本轮依据唯一身份匹配选择源行。
- 目标库备份已在独立、无网络且未发布端口的 MariaDB 恢复，重导逐字节一致。首次前态查询遇到 `platform_admin_sessions` 无 `id`，保留失败回执。按实际 `session_hash` 核对后取得备份恢复及前态快照回执。

## 字段矩阵

| 源 | V2 目标 | 格式和语义 | Dry-run | Apply / API |
| --- | --- | --- | --- | --- |
| `users.name` | `users.name` | `varchar(255)`，旧显示名是否等于用户昵称待证 | SEMANTIC_UNKNOWN | 保留当前值 |
| `users.birthday` | `users.birthday` | Gregorian `date`，日期精确匹配 | READY | PASS |
| `users.gender` | `users.gender` | `varchar(8)`，按目标枚举校验 | READY | PASS |
| `users.city` | `users.city` | `varchar(64)`，当前城市 | READY | PASS |
| `users.relationship_goal` | `users.relationship_goal` | `varchar(32)`，按目标枚举校验 | READY | PASS |
| `user_astro_profiles.birth_time` | `users.private_birth_time` | `varchar(5)`，旧 API 要求的 HH:mm 原始输入 | READY | PASS |
| `users.private_birth_place` | `users.private_birth_place` | `varchar(255)`，出生地点 | READY | PASS |
| `users.private_birth_lat` | `users.private_birth_lat` | 成对读取，原精度 `decimal(10,7)`，纬度范围校验 | READY | PASS |
| `users.private_birth_lng` | `users.private_birth_lng` | 成对读取，原精度 `decimal(10,7)`，经度范围校验 | READY | PASS |

Dry-run 共 8 个 READY、1 个 SEMANTIC_UNKNOWN、0 个目标值冲突。写入在唯一现有用户的行锁内复验身份、目标前态及 8 列白名单，只提交一次。源字段指纹、规则、执行时间和回执留于 root 私有审计文件。

## 核验及未完成项

| 核验项 | 结果 |
| --- | --- |
| 唯一目标用户、管理员权限、密码及受保护列 | PASS，事务前后核对 |
| 已有 Web 与 APP 会话 | PASS，会话身份、有效性和保护列一致，正常访问时间戳不纳入对比 |
| 恢复映射、旧恢复审计、其他用户 | PASS，前后行内容一致，其他旧来源映射 0 |
| 旧派生资料、历史计算及缓存 | PASS，目标派生资料前后核对一致 |
| `GET /api/v1/profile/basic` | PASS，Laravel 进程内以目标用户授权，200，8/8 |
| 仅重启 `staging-app` 后读回 | PASS，API 200，8/8，保护项一致 |
| Owner 本人 APP 资料页 | NOT_RUN，既有实体手机未连接。1011808 的既有本人登录证据单独保留 |

云端进程内 HTTP 响应的格式核对确认经纬度均为十进制 JSON 字符串。原 Flutter DTO 强转 `num?`，合成同形回执在修复前复现两项失败。Flutter 资料摘要、编辑页和会话资料回退现统一解析数字或十进制字符串，保留零值、字段别名与边界校验。资料 DTO、资料编辑及入口定向 27 项通过。扩围结果为 43 通过、6 失败，独立 `671d400d` 对照工作树复现同名 6 项，保留原日志。修复进入本轮经核对的新候选，1011808 原包保留。

备份整件 SHA-256 `76068738899d7bfd81b0da28ef1345af3822cccb549306a62d3b193c8808eb77`。前态整件 SHA-256 `f86f1f7a6d88c7539c120b564f16dca713059748432e869d0e99b81f636ae49a`。核验及重启后的同一后态整件 SHA-256 `6113a6657bfdd29915c144bd27c4a2d53712ae89b805aefb8e3ed59f2d00fa54`。

R1 PARTIAL。封闭内测与生产 NO_GO。网页 GPT 集中复验待 Owner 转交。 [P0 脱敏证据索引](V2_ADMIN_TEST_01_LEGACY_PROFILE_DATA_RESTORE_EVIDENCE_INDEX_20261122.md)
