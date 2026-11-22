# EliteSync V2｜旧管理员测试账号候选核验

2026-11-22（中国标准时间）

| 核验项 | ADMIN-TEST-01 |
| --- | --- |
| 旧记录命中 | **PASS，唯一候选。** 已验证的 `elitesync` 恢复副本中，生效管理员名单命中的四条管理员记录仅一条标记为测试账号。该候选的旧主键与原登录标识均与更早的管理员备份中唯一合格测试账号精确一致。 |
| 旧角色 | **PASS。** 两份独立留存来源均为 `role=admin`。 |
| 旧账号状态 | **PASS（备份时点）。** 主源字段为 `account_status=active`、`disabled=0`、`moderation_status=normal`、`account_type=test`。历史来源也表明未禁用。结合旧应用的角色、账号状态与名单判据，候选建议映射为恢复清单所需的 `status=enabled`、`role=admin`。 |
| 旧 ADMIN_PHONES | **PASS。** 候选精确命中退役前留存的 Laravel 生效配置缓存，且备份中的声明与缓存集合一致。候选也命中更早备份所保留的声明。 |
| 两库重复与冲突 | **存在旧标识冲突。** `elitesync_restore_2_6` 的 `users` 表没有角色和账户状态列。该库中有同旧主键但登录标识不同、同登录标识但主键不同的记录，精确成对匹配为 0。候选以 `elitesync` 主源和其中同源的历史管理员备份为准。 |
| 持有人证明 | **HOLDER_PROOF_PENDING。** Owner 已确认本候选，所提供的登录标识与候选精确一致。仍待独立核验人出具当前原号码控制回执。 |
| V2 数据库冲突 | **只读通过。** 目标为 `elitesync_v2_beta_staging`，`server_id=2621124`。同登录标识用户、同来源旧 ID 映射均为 0。目标有效白名单为空，候选目前会被 `allowlist_missing` 阻断。提议的白名单差异和实际数据库绑定已保存在私有证据。 |
| Owner 签名与工具预览 | **MISSING／NOT_RUN。** 恢复绑定、批准号、操作者及 Owner 签名公钥尚未配置，无已签候选清单。此非本地目标的 dry-run 要求有效 Owner 签名。 |

**ADMIN-TEST-01** 已获 Owner 确认为本次具名对象。私有签名草稿绑定该候选和已核对的 V2 目标。下一步由具名核验人验证原号码控制并制作私有回执，再确认操作者、批准号、Owner 公钥、有效期及候选白名单差异，完成独立签名。具备这些条件后执行 dry-run，核对冲突结论，再裁定授权写入。已签批次的撤权和回滚沿用既有 `LegacyAdminRestore`。 [清单字段](../../../../services/backend-laravel/app/Services/Accounts/LegacyAdminManifest.php) · [签名要求](../../../../services/backend-laravel/app/Services/Accounts/LegacyAdminApproval.php)
