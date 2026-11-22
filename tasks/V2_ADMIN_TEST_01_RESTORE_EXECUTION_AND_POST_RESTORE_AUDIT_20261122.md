# EliteSync V2｜ADMIN-TEST-01 私有号码核验、签名恢复与恢复后账号盘点任务

日期：2026-11-22（中国标准时间）

## 1. 固定基线

仓库：`zcx369658780/EliteSync-v10`

开发分支：`codex/v2-function-completion-20261121`

最新管理员候选核验报告提交：`6d9efee754b4e6ce7abdb48ee855680854d656db`

固定业务源码：`7e0009df4fe69e48967c4fbc111717626c85ed80`

目标V2数据库：`elitesync_v2_beta_staging`

目标MariaDB server_id：`2621124`

唯一已确认候选：`ADMIN-TEST-01`

Owner明确确认本次恢复对象为ADMIN-TEST-01，并确认仍能使用原登录号码接收短信或电话，要求继续恢复。Owner要求所有旧数据库、媒体、配置、管理员名单、快照、私有候选证据和恢复记录均保留，不得删除。

## 2. 本任务目标

完成以下受控流程：

1. 完成原号码当前控制权核验并形成私有回执。
2. 补齐并验证V2目标绑定的Owner签名Manifest。
3. 仅在V2私有运行配置中为ADMIN-TEST-01增加唯一一项必要的管理员白名单。
4. 执行并记录签名dry-run。
5. 若dry-run唯一结果为ADMIN-TEST-01 ready、无冲突且所有目标绑定一致，依据Owner本轮明确的“继续执行恢复”指令及有效签名Manifest执行apply。
6. 通过既有一次性激活流程由持有人设置全新V2密码。
7. 验证本人APP和Web管理员登录。
8. 只读盘点V2中所有来自旧EliteSync管理员恢复批次的候选状态，回答是否还有其他管理员测试账号已经恢复。

不得把本任务扩大为恢复其他管理员。

## 3. 首读与身份核对

先读取：

- `AGENTS.md`
- `docs/workflow/ACTIVE_STATE.md` 顶部CURRENT ENTRY
- `docs/versions/v2/cloud-r0-20261121/V2_LEGACY_ADMIN_PRIVATE_CANDIDATE_SHORTLIST_20261122.md`
- 当前V2固定源码中的：
  - `LegacyAdminManifest.php`
  - `LegacyAdminApproval.php`
  - `LegacyAdminTarget.php`
  - `LegacyAdminRestore.php`
  - `LegacyAdminRestoreCommand.php`

核对云端目标仍为 `elitesync_v2_beta_staging` / `server_id=2621124`，不得从历史记忆或示例配置推断。

## 4. 绝对数据保护要求

禁止删除或覆盖：

- 旧版EliteSync两份数据库备份及独立恢复副本。
- 原始数据库、媒体文件、Nginx/PHP/MariaDB/Redis配置归档。
- `ADMIN_PHONES` 原始来源及配置缓存封存。
- ADMIN-TEST-01候选清单、证据文件及签名草稿。
- 本次V2数据库备份、媒体备份、恢复点及既有证据。
- 1011805、1011806、旧1011807 APK及历史实机FAIL证据。

不得修改旧数据库、旧管理员名单或旧配置。

不得把手机号、验证码、旧用户ID、私有清单、签名私钥、激活码写入GitHub、普通终端日志或去敏报告。

## 5. 原号码持有人核验

Owner已确认仍能使用原号码接收短信或电话；这项确认可作为发起核验的依据，但不得伪造独立核验回执。

按以下顺序：

1. 检查已有批准的SMS/语音验证渠道是否可用。
2. 若已有渠道可用且无需新增采购，生成一次性挑战；验证码只通过该私有渠道发送，不能输出到日志或GitHub。
3. 持有人在本地受控交互中完成验证，不得要求其把验证码发送给ChatGPT或普通日志。
4. 由具名核验人或已有可信验证服务记录核验结果。
5. 在root私有目录保存回执，目录0700、文件0600；回执只记录引用、核验人代号、核验时间、有效期及结果，不重复保存验证码。
6. 若没有可用的已批准验证渠道，或发送会产生未经批准的费用，不得假装验证成功；保持HOLDER_PROOF_PENDING并报告最小阻断。

既有Owner的“能接收”确认不能被改写成“已经完成OTP验证”。

## 6. V2白名单最小变更

当前V2有效 `app.admin_phones` 为空，候选会被 `allowlist_missing` 阻断。

Owner本轮明确要求继续执行ADMIN-TEST-01恢复，因此授权的配置范围仅限：

- 在V2专用私有运行配置中增加ADMIN-TEST-01对应的唯一登录标识。
- 不删除、不重排、不改动其他条目。
- 不修改旧版ADMIN_PHONES。
- 不将号码或配置值写入GitHub。
- 先私有备份V2配置并记录SHA-256。
- 只在确认目标容器、目标Compose项目、目标APP_ENV=staging后修改。
- 重建Laravel config cache并回读组合权限。
- 记录精确before/after差异的脱敏证明。
- 回滚时只移除本次新增项，不恢复覆盖其他后续合法配置。

若发现目标V2配置已含其他未授权管理员号码或实际配置与候选草稿不一致，停止并报告，不擅自清理。

## 7. Owner签名Manifest

使用现有私有草稿：

`/opt/backups/elitesync-legacy-retire-20261122-160321/admin-shortlist-20261122-164700/owner-confirmed-20261122T092742Z/manifest-signing-draft.json`

不要覆盖原草稿。生成新版本并保存到同级新的私有子目录。

Manifest必须满足当前源码合同：

- batch、source_system、snapshot、target、approval、operator。
- candidates仅包含ADMIN-TEST-01。
- legacy_user_id、phone、status=enabled、role=admin。
- holder_proof包含：
  - holder_ref
  - old_allowlist_ref
  - verified_by
  - verified_at
  - expires_at
  - controls_original_phone=true
  - old_allowlist_match=true
  - approved_duty
- authorization包含：
  - fields，优先最小字段 `legacy_user_id, phone, role, status`
  - issued_at
  - expires_at
  - target_binding
- signature：由Owner私钥生成的Ed25519 detached signature。

严格遵守：

- Owner私钥不得交给Codex、服务器或ChatGPT。
- Codex只准备规范化签名消息和SHA-256/签名输入文件。
- Owner在其受控本地环境签名，再把签名结果通过私有安全渠道放入服务器。
- 不得伪造Owner签名，不得把公钥当作私钥。
- 运行时 `LEGACY_ADMIN_TARGET`、`LEGACY_ADMIN_APPROVAL`、`LEGACY_ADMIN_OPERATOR`、`LEGACY_ADMIN_OWNER_PUBLIC_KEY` 等绑定必须与Manifest一致。
- `APP_ENV=staging`、HTTPS origin与APP_URL一致、secure session、MariaDB连接、schema、username、CURRENT_USER、server_id及MariaDB 10.11版本必须逐项回验。
- Owner签名有效期不超过7天，holder proof不得过期。

若签名私钥操作需要Owner手动执行，输出明确的本地签名步骤和私有输入路径，不得要求Owner上传私钥。

## 8. Dry-run与实际恢复

签名、持有人回执、目标绑定、白名单配置全部就绪后：

1. 先执行当前源码的 `php artisan admin:legacy-restore <private-manifest> --action=dry-run`。
2. 确认唯一输出为 `ADMIN-TEST-01 ready`。
3. 确认没有 `allowlist_missing`、`login_identifier_conflict`、`legacy_id_already_mapped` 或目标绑定异常。
4. 保存脱敏回执。
5. 由于Owner已明确要求继续执行恢复，且Manifest由Owner正式签名，dry-run满足全部条件后可执行同一Manifest的 `--action=apply`。
6. apply应创建新V2用户ID，初始保持disabled、role=user、account_status=disabled，不直接启用管理员权限。
7. 核对旧账号ID与新V2用户ID不同，mapping唯一，audit记录完整。

如果dry-run不是唯一ready，立即停止apply并报告。

## 9. 激活与本人登录

apply成功后：

1. 使用同一有效签名Manifest执行既有 `--action=issue --candidate=ADMIN-TEST-01 --out=<new-private-file>`。
2. 激活码仅写入新建的root私有文件，目录0700、文件0600，禁止输出到终端/GitHub。
3. 通过私有渠道交付给持有人。
4. 持有人在V2 HTTPS受控入口完成激活并设置全新密码。
5. 验证一次性激活码失效、用户状态active、role=admin、disabled=0。
6. 本人完成V2 APP登录。
7. 本人完成Web管理员登录。
8. 验证管理员入口及后端admin.phone组合授权。
9. 不迁移旧密码、Token、Session、MFA。

不得由Codex代替持有人设置或获知新密码。

## 10. 恢复后管理员测试账号盘点

用户明确要求：恢复后通过检测账号名列表查看其他管理员测试账号是否也恢复。

必须使用只读查询，不修改任何账号。

权威来源是：

- `legacy_admin_batches`
- `legacy_admin_mappings`
- `legacy_admin_restore_audits`
- 与 `users` 表的关联

不要只用 `users.account_type='test'` 判断。当前源码在非local staging目标创建的恢复用户会使用account_type=normal；恢复来源与状态应以mapping和audit为准。

输出去敏账号状态表，仅显示：

- candidate代号
- 新V2用户ID（可只显示末尾或内部代号）
- mapping state
- users.role
- account_status
- disabled
- 是否有activated审计
- 是否已完成APP登录
- 是否已完成Web管理员登录

同时查询该旧来源所有恢复mapping，判断除ADMIN-TEST-01外是否存在其他候选：

- 若没有其他mapping，明确报告“当前V2恢复批次中没有其他旧管理员测试账号已恢复”。
- 若有其他候选，逐个标记pending/active/rolled_back，不输出手机号。
- 不得把未获Owner批准的其他旧管理员自动加入Manifest或恢复。
- 不得扫描、输出无关真实管理员个人信息。

## 11. 失败与回滚

任何步骤失败：

- 不删除任何备份。
- 不删除旧数据。
- 不删除V2恢复mapping或audit。
- 不重建/覆盖旧数据库。
- 不重试生成新账号，直到冲突原因核清。
- 保留所有日志及SHA-256。
- 对已新增的V2白名单项，若需要回滚，仅移除本次新增项。
- 若账号已apply但激活失败，保持禁用状态。
- 若账号已激活且需要撤权，必须走既有签名rollback流程，撤销设备Session和管理员Session；不得物理删除用户或mapping。

## 12. 最终交付

生成去敏中文报告：

`V2_ADMIN_TEST_01_RESTORE_AND_ADMIN_ACCOUNT_INVENTORY_REPORT_20261122.md`

记录：

- Holder proof状态及私有回执引用。
- Manifest签名验证结果，不包含签名秘密。
- V2目标绑定结果。
- 白名单唯一差异及回滚路径。
- Dry-run和apply回执。
- 新V2用户ID的去敏表示。
- 激活结果。
- APP/Web登录结果。
- 恢复后全部旧管理员恢复mapping的账号代号列表。
- 其他候选是否已恢复。
- 所有PASS、FAIL、UNKNOWN、NOT_RUN。
- 所有备份保留确认。

只同步去敏报告和证据索引到原非main开发分支。

不提交私有清单、手机号、验证码、Manifest、签名、激活码、私钥、数据库导出或配置。

本任务不开放共享私信/WSS，不开放公网管理入口，不合main，不宣布封闭内测GO或生产GO。
