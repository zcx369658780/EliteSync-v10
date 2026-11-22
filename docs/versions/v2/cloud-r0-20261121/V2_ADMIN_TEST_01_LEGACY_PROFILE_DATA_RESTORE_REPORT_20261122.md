# EliteSync V2｜ADMIN-TEST-01 旧个人资料恢复报告

2026-11-23（北京时间） · **APPLY_PASS / API_READBACK_PASS / APP_PROFILE_NOT_RUN**

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
| 已有 Web 与 APP 会话 | PASS，前后行内容一致 |
| 恢复映射、旧恢复审计、其他用户 | PASS，前后行内容一致，其他旧来源映射 0 |
| 旧派生资料、历史计算及缓存 | PASS，目标派生资料前后核对一致 |
| `GET /api/v1/profile/basic` | PASS，Laravel 进程内以目标用户授权，200，8/8 |
| 仅重启 `staging-app` 后读回 | PASS，API 200，8/8，保护项一致 |
| Owner 本人 APP 资料页 | NOT_RUN，既有实体手机未连接；既有 1011808 本人登录证据单独保留 |

备份整件 SHA-256 `76068738899d7bfd81b0da28ef1345af3822cccb549306a62d3b193c8808eb77`。前态整件 SHA-256 `f86f1f7a6d88c7539c120b564f16dca713059748432e869d0e99b81f636ae49a`。核验及重启后的同一后态整件 SHA-256 `6113a6657bfdd29915c144bd27c4a2d53712ae89b805aefb8e3ed59f2d00fa54`。

R1 PARTIAL。封闭内测与生产 NO_GO。网页 GPT 集中复验待 Owner 转交。 [P0 脱敏证据索引](V2_ADMIN_TEST_01_LEGACY_PROFILE_DATA_RESTORE_EVIDENCE_INDEX_20261122.md)
