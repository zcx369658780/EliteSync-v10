# EliteSync V2｜ADMIN-TEST-01 恢复执行与管理员账号盘点

2026-11-22（中国标准时间）

**ADMIN-TEST-01 已恢复、已激活，本人 Web 管理员登录通过。APP 登录 NOT_RUN。** V2 回读共 3 个账号，其中 2 个合成测试账号、1 个管理员。本轮签名清单只包含 ADMIN-TEST-01。同一旧来源的管理员恢复映射共 1 条，其他候选映射为 0。

## Owner 决策与核验工作流

- 唯一恢复对象为 Owner 本人的测试账号 ADMIN-TEST-01。Owner 确认自己控制原号码和阿里云后端，明确授权恢复该候选。
- 现场只有一台实体手机，日常另用 Android 模拟器。双实体手机短信流程停在前置核对。模拟器注入短信不作为运营商证据。
- Owner 明确选择路径 B，使用 `owner-self-attestation`，并在受控本机以 Ed25519 私钥签署目标绑定的 Manifest。该声明的保证级别低于独立号码挑战，短信、OTP、第三方核验均为 NOT_RUN。云端私有目录保留声明、签名输入、签名结果和回执，私钥由 Owner 保管。 [单手机修正任务](../../../../tasks/V2_ADMIN_TEST_01_SINGLE_PHONE_EMULATOR_VERIFICATION_CORRECTION_20261122.md)
- 执行边界为独立 V2 Staging、现有回环管理入口和这一具名候选。旧管理员原始数据、旧备份及其他候选保留。三条其余旧管理员记录来自旧库生效名单，本轮范围只含其中唯一测试候选。 [旧管理员候选核验](V2_LEGACY_ADMIN_PRIVATE_CANDIDATE_SHORTLIST_20261122.md)

## 运行执行与验收

| 项目 | 状态 | 实测结果 |
| --- | --- | --- |
| 云端目标 | PASS | 固定源码 `7e0009df4fe69e48967c4fbc111717626c85ed80`，实际云端镜像配置 ID `sha256:5a7ee83db71cdf799c0998233e3dc0b9e3ad0958fa77227f590bd15063ac99cf`，`linux/amd64`。Compose `elitesync-v2-shared-staging-beta`，APP_ENV=staging，MariaDB 10.11.19，schema `elitesync_v2_beta_staging`，`server_id=2621124`。回环 HTTPS 18446 证书匹配，健康返回 200。 |
| 签名及白名单 | PASS | 本机 OpenSSL、云端 OpenSSL、固定源码审批合同均验签通过。私有配置备份及前后 SHA-256 已留存。有效名单新增 1、移除 0，Laravel 配置缓存重建并回验。只有 staging-app 容器重建，Worker、MariaDB 和 Nginx 容器 ID 保持一致。DevPilot、LiveKit 健康检查通过。 |
| 签名 dry-run 和 apply | PASS | dry-run 退出 0，唯一候选 ready。使用同一签名清单 apply，退出 0，得到唯一 pending 映射。新 V2 用户标识用内部代号 `V2-ADMIN-01`。回读确认新旧 ID 不同，初始角色 user，账号禁用，唯一 staged 审计。 |
| 一次性激活 | PASS | 签发一次，服务端有效期 30 分钟。Owner 设置新密码后，服务端回读 activated 审计 1 条，激活摘要和截止时间均已清空。账号为 active、admin、disabled=false。当前激活页的固定密码规则为至少 12 字符，含字母和数字。 |
| 本人 Web 管理员登录 | PASS | Owner 在本机专用 Chrome 窗口用原号码和新密码登录。服务端回读激活后管理员登录会话 1 条，`AdminAccess` 角色、启用状态和名单组合授权通过。 |
| 本人 APP 登录 | NOT_RUN | 云端激活后 APP device session 为 0。固定 1011807 的原生和 Dart API 均绑定本地回环 `https://127.0.0.1:18444/` 和旧测试 TLS 证书，云端 Staging 当前是 `18446` 和另一证书。后续需确认与 Staging 匹配的 APP 客户端及设备验证范围。 |
| 数据保护 | PASS | 当前旧归档 SHA-256 7/7，V2 归档 3/3。旧主库与辅助库的隔离恢复验证沿用原回执，逐表行数和对象清单核对一致，媒体 2/2 哈希一致。V2 只导入获批候选，无旧库全量导入。 [旧栈退役及恢复回执](V2_LEGACY_STACK_RETIREMENT_AND_BETA_CUTOVER_20261122.md) |

| 候选 | 新 V2 内部代号 | Mapping | 角色 | 账号状态 | 禁用 | Activated 审计 | Web 登录 | APP 登录 |
| --- | --- | --- | --- | --- | --- | --- | ---: | --- | --- |
| ADMIN-TEST-01 | V2-ADMIN-01 | active | admin | active | false | 1 | PASS | NOT_RUN |

## 保留的异常与后续条件

首次以本机构建镜像 ID 比较云端容器配置 ID，身份断言退出 1。按固定部署回执使用云端导入配置 ID 复验通过。激活码签发成功后，首次容器文件复制退出 1，后续经私有管道取回同一个文件，摘要与数据库匹配，签发审计仍为 1。恢复前基线保留在固定提交。 [恢复前基线](https://github.com/zcx369658780/EliteSync-v10/blob/2597c1ece01908568d8542c30d16cd055c2b9909/docs/versions/v2/cloud-r0-20261121/V2_ADMIN_TEST_01_RESTORE_AND_ADMIN_ACCOUNT_INVENTORY_REPORT_20261122.md)

后续只核验发生变化的条件。实机 APP 登录、顾问集中复验待完成，其余旧管理员仍需各自的 Owner 授权。共享私信和真实 WSS 维持关闭，R1 为 PARTIAL，封闭内测及生产为 NO_GO。

## 脱敏证据索引

原始回执由本机工程留存。以下仅记录文件名与 SHA-256。

| 文件 | SHA-256 |
| --- | --- |
| `01-signed-preflight.stdout` | `2faea4f10ac39bd41b79bee04064569d027698ea0fc62f81dd2090551caec482` |
| `02-config-dry-run.stdout` | `954a0d431c6d373dd765ce1fcfa55a55b319d80d0728c0555ae3099a25ac65d3` |
| `03-apply-and-audit.stdout` | `47c6969c9e7524cf82d02f3653337ac75e5bd8d92d68526a4766c1e2b9581aa6` |
| `05-activation-issue.stderr` | `68886d15f8f6ea5351d400dafa286feeb349b4d04ead0d3e77f38ec95f8e01ef` |
| `05b-preserve-issued-activation.stdout` | `3225af9a7be27ddda2a333415f64ba170f0bc7c5602f58b62c89651a326b085a` |
| `08-owner-activation-readback.stdout` | `dca2f034153d3a190f9331abe9723a8711dc9b128e49f4bf81d1ba9f8a323532` |
| `09-owner-web-login-readback.stdout` | `c1d15b36461d8e41b786b5119f0bc1e26e96e024cf2399a262ce4f27e8131017` |
| `10-live-account-counts.stdout` | `a26cc9bccfbb6eaba66d9a9233d0b44c4415eea1a3cf37bde5241f343a92821a` |
