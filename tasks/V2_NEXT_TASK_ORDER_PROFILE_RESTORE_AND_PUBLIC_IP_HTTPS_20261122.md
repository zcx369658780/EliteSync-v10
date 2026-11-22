# EliteSync V2｜下一轮任务顺序：本人资料恢复 + 公网IP受限HTTPS

日期：2026-11-22（中国标准时间）

## 固定基线

- 仓库：`zcx369658780/EliteSync-v10`
- 开发分支：`codex/v2-function-completion-20261121`
- 本任务创建前HEAD：`c77bd6b31cd52107309ba5c71264d89c8b6a8dc1`
- 云端业务源码：`7e0009df4fe69e48967c4fbc111717626c85ed80`
- V2目标库：`elitesync_v2_beta_staging`
- MariaDB `server_id=2621124`
- 唯一已恢复Owner账号：`ADMIN-TEST-01` / `V2-ADMIN-01`

## 本轮任务

### P0：恢复ADMIN-TEST-01本人旧个人资料

先完整执行：
`tasks/V2_ADMIN_TEST_01_LEGACY_PROFILE_DATA_RESTORE_20261122.md`

这是当前最优先任务，因为Owner已经在真实APP登录后发现原个人资料缺失。

只恢复唯一账号的无歧义个人资料字段；使用既有legacy mapping绑定旧来源；先备份、字段映射、dry-run，再按任务单实际apply。不得批量迁移其他用户，不得覆盖新密码、管理员权限或V2身份。冲突字段保留并报告。旧数据库和全部备份永久保留。

### P1：将域名方案调整为公网IP HTTPS

执行：
`tasks/V2_PUBLIC_IP_RESTRICTED_HTTPS_AND_REMOTE_STAGING_20261122.md`

域名注册/备案暂不可用，不再等待域名。评估Let's Encrypt公开可信IP SAN短期证书、自动续期及IP字面量Nginx/Android/Flutter适配。

可先做只读核查、ACME staging验证方案、本地配置与客户端适配。云端正式443监听必须在精确Owner来源、证书可信链、自动续期和回滚条件满足后才开启。不得自签名、关闭TLS验证、用HTTP传递凭据或开放全网匿名访问。

## 执行节奏

1. 先读两份任务单和当前工程规则，核对真实本地工作树，不覆盖脏文件。
2. 优先完成P0资料恢复。P0 apply后先由Owner本人检查APP资料；如字段有语义/来源冲突，只停冲突字段，不猜。
3. P1可并行完成本地IP模式代码准备、Certbot版本核对及只读云端检查；不要因P1等待Owner来源而阻塞P0。
4. P0/P1分别报告，分开提交，不把资料恢复PASS等同公网HTTPS PASS。
5. 不合main、不安装新APK（除非另有明确授权）、不启用WSS、不宣布封闭内测GO或生产GO。

## 全局保护

旧数据库、旧媒体、旧配置、旧APP_KEY归档、V2备份、恢复Manifest、审计、历史APK及全部失败证据必须保留。真实个人资料、手机号、生日、出生地点、经纬度、密码哈希、密钥、token、证书私钥、真实公网IP及数据库导出不得进入GitHub。

若任务单与本地实际源码/数据库schema不符，以当前固定云端源码和只读实况为准，记录差异并fail closed；不得根据文档猜字段或猜来源。
