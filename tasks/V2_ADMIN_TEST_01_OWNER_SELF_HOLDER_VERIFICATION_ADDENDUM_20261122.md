# ADMIN-TEST-01｜Owner本人兼持有人的一次性控制权核验补充

日期：2026-11-22（中国标准时间）

## 1. Owner身份与角色澄清

Owner已明确声明：

- ADMIN-TEST-01是Owner本人使用的旧EliteSync测试账号。
- 当前阿里云V2服务端由Owner本人拥有和控制。
- Owner仍能使用原登录号码接收短信或电话。
- Owner要求继续ADMIN-TEST-01恢复。

因此，本流程不强制要求另找第三方人员担任核验人。Owner可以作为账号持有人及具名核验责任人，记录为 `verified_by=owner-self-verification`。这属于Owner本人核验，不得描述成独立第三方核验。

历史数据库、旧管理员名单及Owner声明只证明历史归属和Owner自述，不能单独冒充当前号码控制权的挑战回执。

## 2. 当前核验渠道事实

固定恢复报告确认：服务器、固定源码和当前运行配置未发现已配置的SMS/语音发送服务；是否存在外部已获批渠道为UNKNOWN。

不得假设存在短信供应商，不得自动注册服务，不得采购，不得将短信发送状态伪造为成功。

## 3. 允许的Owner本人核验方式

优先采用不新增采购的Owner自控双端方式：

1. Codex在阿里云root私有目录生成高熵一次性随机挑战，挑战仅存放在0700目录中的0600文件。
2. Owner通过受控SSH/本地安全通道查看挑战，不得将挑战写入GitHub、普通日志或聊天。
3. Owner使用ADMIN-TEST-01原号码对应的SIM，从该号码向Owner自己控制的第二接收端（第二台手机或另一条号码）发送包含挑战的短信；也可使用原号码拨打Owner控制的第二接收端，由接收端记录来电号码和挑战口令。
4. Owner在第二接收端本地核对发送号码/来电号码与候选原号码一致，并记录挑战匹配、渠道、时间和结果。
5. Owner本人以 `owner-self-verification` 身份生成核验回执。回执不保存验证码或短信正文，仅记录：
   - holder_ref
   - verified_by=owner-self-verification
   - verified_at
   - expires_at
   - controls_original_phone=true
   - old_allowlist_match=true
   - approved_duty=legacy-admin-owner
6. 原始短信/通话记录证据仅保存在Owner私有设备或root私有证据目录；可记录其私有引用，不上传GitHub。

此流程不要求第三方人类核验员，但需要第二个Owner控制的接收端，以免把“我能接收”这一自述误当成实际挑战证明。

如果Owner没有第二接收端，也没有可用且已批准的可信号码验证服务，则停止在HOLDER_PROOF_PENDING；不得用同一设备本地备注、历史白名单、旧数据库记录或单纯口头声明伪造挑战成功。

## 4. Owner签名及恢复边界

号码控制回执完成后：

1. Codex补齐Manifest的holder_proof字段。
2. 生成 `LegacyAdminApproval::message()` 的规范化签名输入及SHA-256。
3. Owner在自己的受控环境使用Owner Ed25519私钥签名。
4. Owner私钥不得交给Codex、服务器或ChatGPT。
5. 签名文件通过私有渠道放回服务器。
6. 核对V2目标 `elitesync_v2_beta_staging` / `server_id=2621124`、HTTPS origin、MariaDB身份、操作者、批准号、时间窗和唯一白名单差异。
7. 执行签名dry-run。唯一结果为ADMIN-TEST-01 ready且无冲突后，依既有Owner恢复指令和有效签名Manifest继续apply。
8. apply后初始用户必须保持disabled、role=user、account_status=disabled，随后通过一次性激活由Owner本人设置新密码并完成APP/Web登录。

若dry-run非唯一ready、目标身份改变、证明过期或签名失败，立即停止，不apply。

## 5. 数据保护及账号盘点

所有旧数据库、媒体、配置、ADMIN_PHONES来源、候选清单、证据、V2备份和审计记录必须保留，不得删除。

恢复后只读查询legacy_admin_batches、legacy_admin_mappings、legacy_admin_restore_audits及users关联，报告其他旧管理员候选是否已有V2映射。不得自动恢复其他账号。

## 6. 状态

本补充只澄清核验责任角色，不代表号码挑战已经执行，不代表持有人证明已完成，不代表Owner Manifest已签名，也不代表apply已经授权完成。

当前状态保持 `HOLDER_PROOF_PENDING`，直到取得实际挑战回执。
