# ADMIN-TEST-01｜Owner双设备短信挑战与签名恢复执行补充

日期：2026-11-22（中国标准时间）

## 1. Owner最新确认

Owner明确说明：

- ADMIN-TEST-01是Owner本人使用的测试账号。
- 原号码仍由Owner本人使用。
- 日常测试手机也是Owner本人控制的设备。
- Owner同意继续执行本次唯一候选的号码控制核验及恢复流程。
- 不需要第三方核验人。

因此核验责任标识使用 `owner-self-verification`。不得把本流程描述成独立第三方核验。

## 2. 固定边界

唯一候选：`ADMIN-TEST-01`

V2目标：`elitesync_v2_beta_staging`

MariaDB server_id：`2621124`

固定业务源码：`7e0009df4fe69e48967c4fbc111717626c85ed80`

沿用：
- `tasks/V2_ADMIN_TEST_01_RESTORE_EXECUTION_AND_POST_RESTORE_AUDIT_20261122.md`
- `tasks/V2_ADMIN_TEST_01_OWNER_SELF_HOLDER_VERIFICATION_ADDENDUM_20261122.md`

所有旧数据库、媒体、配置、ADMIN_PHONES来源、旧栈归档、V2备份、候选清单、恢复记录和原始证据必须保留，不得删除、覆盖或清理。

## 3. 双设备一次性短信挑战

当前服务器没有已配置的SMS/语音发送服务，不得虚构短信发送能力，不得采购或注册短信供应商。

采用Owner自控双设备方式，验证目标是证明Owner当前可以在原号码对应设备上接收短信。方向必须正确：

1. Codex在阿里云root私有目录生成至少128-bit随机、单次使用、10分钟有效的一次性challenge。
2. challenge文件放在root所有、目录0700、文件0600的全新子目录；不覆盖旧证据。
3. Codex仅向Owner报告私有challenge文件的绝对路径，不在普通终端、GitHub、网页GPT或普通聊天中输出challenge正文。
4. Owner通过受控SSH读取challenge。
5. Owner在自己控制的第二台日常测试手机上，使用系统原生SMS应用，从第二设备的SIM向ADMIN-TEST-01原号码发送challenge。
6. Owner在原号码对应的手机上实际收到该短信，核对发送设备/号码与预期第二设备一致，并确认正文challenge完全匹配。
7. Owner将原号码手机收到短信的截图或等效系统证据保存到Owner本地私有目录。证据不得进入GitHub或普通日志；如需复制到服务器，只能使用受控私有通道，保存为root私有文件。
8. Owner通过受控私有交互确认已在原号码手机收到正确challenge。Codex核对时间窗、challenge引用及一次性状态，并将challenge标记为已消费。
9. 生成holder receipt，字段至少包括：
   - `holder_ref`：私有证据引用
   - `verified_by=owner-self-verification`
   - `verified_at`：UTC秒格式
   - `expires_at`：UTC秒格式，最长不超过核验后7天
   - `controls_original_phone=true`
   - `old_allowlist_match=true`
   - `approved_duty=legacy-admin-owner`
10. 回执只记录challenge引用/哈希、渠道`owner-controlled-secondary-device-sms-to-original-phone`、核验时间、结果和私有证据路径；不得保存或输出短信正文、完整号码或任何验证码。

此流程证明Owner在核验时可接收发送至原号码的短信，属于Owner本人自证，不是第三方独立证明。不得将其表述成电信运营商身份认证或第三方KYC。

若短信未到达、发送方无法识别、挑战不匹配、超过10分钟、证据缺失或私有路径权限不符合要求，立即保持`HOLDER_PROOF_PENDING`，不得伪造回执。

## 4. Owner签名输入

挑战回执通过后：

1. 补齐ADMIN-TEST-01 Manifest的holder_proof。
2. 只允许该候选，不加入其他管理员。
3. 生成当前固定源码`LegacyAdminApproval::message()`要求的规范化签名输入。
4. 输出签名输入SHA-256及私有绝对路径，不输出手机号、旧用户ID或Manifest正文。
5. Owner在自己受控环境使用Owner Ed25519私钥签名。
6. 私钥绝不交给Codex、服务器或ChatGPT。
7. 签名文件通过私有安全通道放回服务器。

签名必须绑定：
- 当前V2目标`elitesync_v2_beta_staging`
- `server_id=2621124`
- 当前HTTPS origin及APP_URL
- MariaDB 10.11实际身份、CURRENT_USER及读写PDO
- 批准号、操作者
- 最小字段范围
- 签发和失效时间
- holder proof及旧管理员名单匹配证据

Owner签名有效期不超过7天，holder proof必须在签名时及执行时有效。

## 5. 最小白名单和dry-run

Owner已授权仅为ADMIN-TEST-01准备本次恢复所需的唯一白名单差异。

执行前：
- 备份V2私有运行配置，目录0700、文件0600。
- 记录SHA-256。
- 确认目标Compose项目、容器、APP_ENV=staging及数据库身份。
- 只增加ADMIN-TEST-01对应条目，不删除或改动其他条目。
- 不修改旧版ADMIN_PHONES。
- 不将号码写入GitHub。
- 重建Laravel config cache并回读有效配置。

随后完成Owner签名验签和目标绑定核验，再执行：
`php artisan admin:legacy-restore <private-manifest> --action=dry-run`

唯一允许结果为`ADMIN-TEST-01 ready`。如出现任何冲突、allowlist_missing、目标绑定变化、签名或时间窗错误，停止，不apply。

## 6. Apply与激活

Owner已明确要求继续恢复；当且仅当签名Manifest有效、holder proof有效、目标身份一致、唯一白名单差异正确、dry-run唯一ready时，按既有任务单执行同一Manifest的apply。

apply后初始用户必须保持：
- role=user
- disabled=true
- account_status=disabled

随后按既有CLI签发30分钟一次性激活码到全新root私有文件。通过私有渠道交给Owner。Owner本人设置全新密码，Codex不得查看、接收或记录密码。

验证：
- 激活码一次性使用后失效。
- 用户role=admin、disabled=false、account_status=active。
- Owner本人完成APP登录。
- Owner本人完成Web管理员登录。
- 管理员路由及admin.phone组合授权通过。

若apply成功但激活失败，账号保持禁用，不得删除用户或映射；如需撤权，使用现有签名rollback并保留审计。

## 7. 恢复后账号盘点

只读查询：
- `legacy_admin_batches`
- `legacy_admin_mappings`
- `legacy_admin_restore_audits`
- `users`

报告所有来自旧EliteSync来源的候选代号、mapping state、角色、账号状态、disabled、activated审计、APP登录和Web登录状态。

不得查询或输出无关真实管理员的手机号、姓名或凭据。不得自动恢复其他候选。

若除ADMIN-TEST-01外没有其他mapping，明确报告当前没有其他旧管理员测试账号已恢复。

## 8. 数据保留与交付

不删除任何旧备份、旧数据库、媒体、配置、候选清单、challenge回执、签名输入、签名结果、激活审计或V2备份。

提交去敏报告：
`V2_ADMIN_TEST_01_RESTORE_AND_ADMIN_ACCOUNT_INVENTORY_REPORT_20261122.md`

报告区分PASS、FAIL、UNKNOWN、NOT_RUN、OWNER_ACTION_REQUIRED；不包含号码、验证码、Manifest、签名、激活码、私钥或密码。

同步原非main开发分支，等待网页GPT集中验收。

不开放共享私信/WSS，不开放公网管理入口，不合main，不宣布封闭内测GO或生产GO。
