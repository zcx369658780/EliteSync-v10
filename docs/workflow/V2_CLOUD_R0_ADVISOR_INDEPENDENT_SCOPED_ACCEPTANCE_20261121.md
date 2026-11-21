# EliteSync V2-CLOUD-R0｜独立顾问集中限定验收

日期：2026-11-21（Asia/Singapore）  
结论：**V2_CLOUD_R0_ADVISOR_SCOPED_ACCEPTED_WITH_RESERVATIONS / LOCAL_STAGING_SCOPED_PASS / CLOUD_IDENTITY_BLOCKED / LEGACY_ADMIN_REAL_RECOVERY_NOT_RUN / PHONE_CLOUD_NOT_RUN / PRODUCTION_NO_GO / OWNER_NEXT_GATES_PENDING**。

## 1. 独立核实的固定身份与证据等级

- 固定R0工程报告：[V2_CLOUD_R0_ENGINEERING_REPORT_20261121.md](https://github.com/zcx369658780/EliteSync-v10/blob/e431e0c9fca2be95fd1481d6afdcbaefac9cb6c0/docs/versions/v2/cloud-r0-20261121/V2_CLOUD_R0_ENGINEERING_REPORT_20261121.md)。最终交付commit `e431e0c9fca2be95fd1481d6afdcbaefac9cb6c0`，开发分支`codex/v2-cloud-r0-gradual-staging-20261121`远端回读指向该SHA；源码提交`4c255a0915ecc792b083f94798c40216ec870f07`。
- GitHub独立compare：从R1 `585a8c21aeab103daac166338f881ef343c8af99`到R0 ahead2/behind0，merge-base为R1；从R0源码到R0最终ahead1/behind0，后置提交仅`local-smoke.py`与中文工程报告。与先前清理文档分支`716e74d...`比较是共同从R1分叉，清理报告未并入R0工程树不代表产品源码丢失，也不得趁机合main。
- 顾问确实读取报告与Dockerfile、Compose、Nginx/FPM、app-entrypoint、db-preflight、local-smoke合成脚本及`LiveConsentService::enabled()`、`AdminAccess::allows()`等固定GitHub源码；这是`ADVISOR_SOURCE_SPOTCHECK`。WSL容器/daemon、测试日志、私有SQLite/MariaDB、证书、备份真实字节与手机均无法由网页顾问直接重跑或访问；运行结果仅`CODEX_REPORTED_LOCAL_E2E`。本地证据SHA256是审阅入口而非顾问独立校验本体。

## 2. G0–G3验收矩阵

| 门 | 判定 | 支撑及边界 |
|---|---|---|
| G0阿里云真实实例与旧业务 | **BLOCKED** | 只到控制台登录门槛；当前轻量应用服务器实例的真实归属、区域、容量、账单、运行服务、旧DB/卷与可信SSH身份全部UNKNOWN。无SSH和云写入。 |
| G1 Linux PHP8.4/MariaDB/三盘Staging | **LOCAL_SCOPED_PASS_WITH_OBSERVATIONS / CLOUD_NOT_RUN** | Compose隔离项目/卷、内部DB网络和回环TLS；PHP8.4.28+Laravel13.39、MariaDB10.11.19、Python/Node/iztro/DE440s身份由Codex报告；91迁移/115表、末项回滚重迁、分别重启持久化、worker队列、HTTPS本命已知/未知/503/权限、合成Lifestyle/Buddy/媒体Block有据。原始日志未独立执行；生产性能、DB并发全量、云灾备、漏洞扫描、动态跨时重建均未运行。 |
| G2旧管理员备份及最小恢复 | **SYNTHETIC_SCOPED_PASS / REAL_DATA_BLOCKED** | 五月三份gzip与sidecar的哈希配对、另一组两份GPG字节已被Codex报告核对；不能证明同一备份、来源实例、有效管理员、合法来源、完成解密/恢复。合成新ID/密码、禁止旧token、联系方式冲突和`AdminAccess`角色+启用+受控名单负例通过。真实读取与迁移、MFA/管理页面实际设备均NOT_RUN。 |
| G3 Android经云端HTTPS | **NOT_RUN / DEVICE_PENDING** | 当前只建立本地回环TLS，尚无云实例/受限域名/独立签名包。Flutter与Android原生BuildConfig仍有独立端点/历史回退风险，不得把旧Windows USB实机成功记云端结果。 |
| 生产/public | **NO_GO** | 真实KYC/Push/RTC、法律受理、正式A6、全量旧PHP、25项旧排盘、T0 P1、真实管理员授权与设备均未闭合。 |

## 3. 源码抽查的保留意见

- `services/backend-laravel/docker/cloud-r0/Dockerfile`已由PHP8.5改为digest固定的PHP8.4基础镜像，Composer平台检测、Python哈希锁、Node npm lock存在，DE440s以只读bind挂入；Debian依赖动态解算、未来跨时逐字节重建与漏洞扫描仍OPEN。
- `compose.yaml`将 MariaDB、worker/FPM置于内部网络且未暴露3306，HTTPS仅`127.0.0.1`绑定，当前合理用于**本地隔离测试**，直接上传并不构成云端手机可达的TLS Staging。Nginx `server_name localhost`、测试证书与受限访问必须在云部署前重新设计及验证；Nginx同时加入data内部网，能到DB，云端应评估进一步分网最小化。
- `db-preflight.php`核APP_ENV、连接URL/host/schema/user、MariaDB10.11和固定server_id；空库用法会拒绝非空库。生产样式及未知数据库不得绕过；部署前重复核当前实例与volumes、避免用迁移/清理越过保护。
- `LiveConsentService::enabled()`首先要求`config('restoration.enabled')`且环境必须`local/testing`；仅指定受信本地DB签名或已注册私有实例资格才开放。当前`APP_ENV=staging`被拒绝，**Connection 404符合门禁，不能称已完成双向关系正链。** 不得通过客户端Header、全局`APP_ENV=local`、改名为测试库、HTTP开关或放宽生产读权绕过。仅可另设计经过服务端私有实例身份证明、合成主体和功能可撤销的Staging专属资格，并以安全正反例与明确Owner批准验证。
- `AdminAccess::allows`要求账号未禁用、admin角色、配置允许名单同时满足。真实管理账号绝不只凭旧库角色标识恢复；需独立来源和数据主体授权，重新发行新凭据。测试脚本的虚构管理员不应成为公开/正式管理账号。

## 4. 下一阶段建议/Owner待决门

优先：**Owner在受控浏览器完成阿里云轻量应用服务器登录及只读实例身份核验**；身份未核不允许SSH、云写入或导入真实资料。G0可和其它不涉及云写/真实个人信息的本地工程准备并行。

- G0：准确实例及费用/服务绑定；当前可协助制定只读清单，不能凭2026-09旧IP跳过可信host-key。
- G1：拿到G0旧业务/容量/回滚与预算证据后，向Owner集中申请具名Staging写入，不预先占用旧生产端口、DB/卷或采购资源。
- G2：同一来源真实管理员最小数据门，须列明源备份身份、法定/运营主体、实际账户候选与最小字段（仅私有渠道），不强求恢复旧密码、Token/MFA/私信；继续允许隔离合成管理员。
- G3：仅当云端受限HTTPS与双端API URL固定、合成Connection→MC→消息正链具名通过且设备获准，才启动手机；否则分别标NOT_RUN。
- 旧排盘A/B/C、注册T0两项Owner产品选择**仍未选定**，不得从本次“恢复阿里云”默认为允许旧算盘或注册生成离线留存。

**本验收仅顾问限定接受，不是Owner生产GO；没有真实云资源写入、数据处理或权限扩大签字。**
