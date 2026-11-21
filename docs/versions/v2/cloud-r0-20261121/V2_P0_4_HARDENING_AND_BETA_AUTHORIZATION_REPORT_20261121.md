# EliteSync V2｜P0.4 收口与 Beta 管理员恢复加固

2026-11-21（中国标准时间） · **本机功能与合成恢复具名验证通过／P0.4 实机待验／真实数据与共享 HTTPS 待批准／封闭内测 NO_GO**

实际工程为 `v2-cloud-r0-20261121` 隔离工作树，origin 为 `zcx369658780/EliteSync-v10`，分支 `codex/v2-function-completion-20261121`。起点 `0fd75198db3067782241b6777054050ac2af6918`，本轮源码 `00ca46f6b020afa25ce472509c2fd3227f74c461`。治理固定 `aeb6661b5d4a5585c4d31f27fe12f15037b980a0`。上一轮本地合成与实机证据沿用原判定。 [治理任务书](https://github.com/zcx369658780/EliteSync-v10/blob/aeb6661b5d4a5585c4d31f27fe12f15037b980a0/docs/versions/v2/V2_P0_4_AND_BETA_ADMIN_RECOVERY_HARDENING_CONSOLIDATED_TASK_20261121.md) · [顾问限定验收](https://github.com/zcx369658780/EliteSync-v10/blob/aeb6661b5d4a5585c4d31f27fe12f15037b980a0/docs/workflow/V2_BETA_PREP_LEGACY_ADMIN_AND_SHARED_HTTPS_ADVISOR_REVIEW_20261121.md)

## P0.4 验收

| 范围 | 实际结果 | 待补 |
|---|---|---|
| 消息 UNKNOWN 并发 | 每次显式核对发出独立、带 no-cache 的当前会话 GET，与历史和轮询在途状态分开，单次核对占用同一操作。只有本次 GET 成功且会话、对象 epoch 和原请求均匹配才处理。找到同 sender、原消息 ID 的结果就确认并清理草稿；未在最新窗口读到时，才允许显式复用原不可变 key，由服务端去重。读取失败显示「重新核对服务器」，没有 POST；切号、授权变化和后台取消旧操作。具名 Widget 验证轮询重叠、快速重复点击、读取 503、已提交后的读回、切号、Block 与后台。 | 设备上真实无线网络、历史分页与前后台组合仍需新包实测。 |
| Block、旧入口和缓存 | Widget 验证会话页确认/取消、响应丢失后的只读核对、发送与媒体控件失权。专用 MariaDB HTTPS 验证 A→B、同向重复和 B→A，实际落库两条方向记录。双方已收藏的旧消息路由与原 key 写请求均 404，旧通知为 history 且无私密载荷。 | 新包手机端 Block、切号/冷启动后的本机缓存和 A12 实测 NOT_RUN。 |
| 媒体与历史受众 | 经 HTTPS 上传合成 PNG、发布 SELF 和 FRIENDS 封面并读取实际源字节，私有响应 no-store。原好友可读 FRIENDS；SELF 对好友 404；新增好友可读作品正文，旧封面 404；Block 后旧封面、头像、作品均 404。损坏 PNG 422，旧头像 revision 409。 | 系统 Photo Picker、设备缩略图清除、A10 媒体截图仍需新包实测。 |
| URI | 1011806 构建清单确认 Android 现有对外声明只包含地图回调。独立候选关闭 Flutter 平台 URI 自动转发，宿主不从外部启动参数接收初始页面；内部通知和对象入口继续服务端重验。跨账号旧会话入口 404，Block 后旧通知最小化。 | 设备外部 intent 分发、冷/热启动和不同会话的实际结果 NOT_RUN。 |
| 写途中响应丢失 | 本机固定 TLS 故障驱动在服务端返回成功头后关闭连接，人工客户端丢弃业务响应体，随后走新 GET 核对原状态。消息命中原 client ID，Buddy 回执由 NOT_APPLIED→APPLIED，Block 查询命中原对象。同键对照后库内只有 1 条消息、1 个 Buddy 活动和各方向 1 条 Block。 | 这是服务端提交后丢响应的故障注入。设备断网、写入前/提交前主动切断、真实弱网窗口 NOT_RUN。 |
| 关系文案 | 延续已验收的「正式关系已建立」和 TEST_ONLY 标志。相关旅程页面测试随回归通过。 | 真机截图仍待 1011806。 |

Flutter 定向 **72 项通过**，涉及改动的 Dart 文件分析无问题。PHP 扩围 **61 项中 60 通过，1 项失败**，合计 777 断言。失败为 `V1011SocialTest::test_privacy_posts_and_revocation_do_not_disclose_deep_fields` 第 75 行，历史断言期待 409，实得 200；在上批镜像单独执行同一未修改测试可复现。本轮媒体原受众的另行具名证据见上表。旧全量 Q PHP、旧盘和 Flutter 既有失败继续按原账。 [当前消息页源码](../../../../apps/flutter_elitesync_module/lib/features/chat/presentation/pages/live_chat_page.dart)

### Android 候选 1011806

ARM64 Flutter AAR 和 APK 均以既有离线依赖构建。宿主与 AAR 中 `libapp.so` 字节一致；DEX 与 Dart 二进制均含 `https://127.0.0.1:18444/`，证书指纹固定。候选包名与 1011805 不同，原 APK SHA-256 重算一致。APK 原件留本机，新包安装、启动、截图和设备操作均为 NOT_RUN。

| 字段 | 实测身份 |
|---|---|
| APK | `EliteSync-V2-function-p04-1011806.apk`，209,094,076 字节 |
| Package / 版本 | `com.elitesync.v2functionp04` · `10.1.18-v2-function-p04 / 1011806` · arm64-v8a |
| APK SHA-256 | `3c855b8f796e7b79124d35ae2c605c3cf36574e89d569cb47d687d1f4ff4c130` |
| APK v2 签名证书 SHA-256 | `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09` |
| Flutter AAR SHA-256 | `b81774a1730c0835161ee443625493c93c006543192c7b4beffe83afb36466aa` |
| 端点 TLS 证书 SHA-256 | `41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96` |

## 管理员恢复工具与正反验证

- **目标身份。** `LegacyAdminTarget` 在查询候选或写入前核验 staging、私有 target、HTTPS origin 与 APP_URL、debug、Secure Cookie，以及数据库 session 的 driver、连接名和表。两个层级比对 Laravel 声明配置和实际连接配置，检查专用 MariaDB 驱动、host、username、port、schema；禁用 URL、socket、别名和读写分离/读 PDO 重绑。由同一个写 PDO 读取 `DATABASE()`、`@@server_id`、`@@port`、完整 `VERSION()`、`CURRENT_USER()` 及 `USER()`，逐项精确匹配；Beta 专用库和账号使用独立命名，已知旧/R0/本机 server ID 从真实 Beta 目标排除。实际专用 MariaDB 测试了 username、port、会话别名、授权账户、完整版本、server ID、URL、socket、运行时重绑九个拒绝例，返回去敏错误。 [目标核验](../../../../services/backend-laravel/app/Services/Accounts/LegacyAdminTarget.php)
- **Owner 签名与持有人。** 真实目标必须提交一份 Ed25519 签名的私有清单。服务从独立部署配置取得可信 Owner 公钥及指定 operator，核验完整目标绑定、来源快照、字段白名单、候选与角色、批准号、有效时间和唯一批次。逐人必须有原号码控制、旧私有 admin 名单命中、启用状态、职责、核验人和核验时段的签名证明引用。缺失、不符或过期就停止。证明引用由具名人员实际核验，软件核验签名和规则。签发的一次性激活码有效期以 30 分钟、Owner 截止与持有人证明截止三者最早为准。数据库唯一索引消费批准号一次；相同内容重跑幂等，批准号用于另一批被拒。已过期的原签名仍可对原批撤销。 [签名核验](../../../../services/backend-laravel/app/Services/Accounts/LegacyAdminApproval.php)
- **实际执行。** 本机合成模式继续仅接受指定虚构号码段。用一次性虚构签名密钥完成两名虚构管理员的 dry-run、apply、双 ID/手机号、issue、激活、APP 登录 API、Web 后台、allowlist 反例、撤权、回滚与持久审计。缺签名、伪造签名、篡改快照、错目标/操作者、缺/过期持有人证明及批准号重放均有负例。旧 Web 组与新增恢复测试共 **12 项、123 断言通过**。临时 FPM/HTTPS 执行器已正常停止。原本机专用 MariaDB 和功能服务及旧数据卷继续保留，真实候选 **0**，真实恢复 NOT_RUN。
- **运维撤权。** CLI 回滚撤销角色、账号、激活码、访问/刷新、设备和两类 Web 会话，保留源到目标映射与审计。运行负责人逐人维护私有 `ADMIN_PHONES`，记录操作者、变更前后名单版本、候选代号、启用时点和撤权回执；重载/缓存生效与跨请求失权需在选定共享环境实证。基础 admin 角色覆盖范围偏宽，交 Owner 按职责裁定；匹配运营资格沿独立门禁，恢复时不视为已批准。旧凭据与真实 KYC 均维持原门禁。

## 一次性真实管理员数据授权包（待 Owner 确认）

本包公开部分仅保留字段和随机候选代号。实际名单、证明、签名附件和账号映射放在 Owner 指定的私有目录。当前具名范围、签名公钥、操作者、目标写入库与核准窗口均待定。

| 需填项 | 精确范围与验收 |
|---|---|
| 来源与保全 | A 首选现时旧 MariaDB 的一致性只读快照或可验证最小字段导出，填实例与旧 schema、快照 ID、时间和保管人。B 仅在 A 不可用时选择具名五月 gzip manifest，先从独立渠道核原件摘要和恢复条件。分开列明任何解压/解密动作与获批边界；独立 GPG 组维持未选。两来源待证，真实行读取及解密 NOT_RUN。 |
| 逐人私有证明 | 填指定人数和随机代号。保管人核查旧主体、active/enabled、旧 admin 与旧允许名单命中；由本人证明现时控制原手机号，记录确认人、UTC 核验时点与到期、证据引用及获准职责。号码失控、状态不合格或来源无法证明时，候选为 BLOCKED，内测硬门继续挂起。 |
| 最小字段 | 许可读取旧 ID、原手机号、旧角色状态和名单是否命中。显示名仅在必要且签名明确允许时读取。在 V2 只写原标识、获准角色/状态、可选显示名、新 ID、映射与安全审计。排除旧密码/哈希、Token、session、MFA、API key、业务资料、三盘、媒体和认证材料。 |
| 目标与执行人 | 填具名实例、镜像 digest、schema、Laravel connection、SQL hostname/username/port、`CURRENT_USER()`、server ID、完整版本、HTTPS origin/TLS、session DB 和恢复演练回执。记录数据保管、提取、迁移、独立复核及回滚负责人，附受限入口、留存时限、费用上限和通知渠道。 |
| 一次签名与停止条件 | Owner 先批准上述具名最小读取边界。取证后，由指定复核人与 Owner 核最终清单，在离线环境以受控 Ed25519 私钥签名，公钥走独立可信配置。签名消息为固定域前缀加解析后的递归规范 JSON，排除签名字段，覆盖包括证明引用的清单全部字段。目标不符、号码冲突、缺失证明、失权或未授权费用立即止步。停止或误授时撤该批码、角色、账号及会话，移除私有 allowlist，保留回执。 [规范化实现](../../../../services/backend-laravel/app/Services/Accounts/LegacyAdminApproval.php) |
| 通过标准 | 所有指定人亲自在外地用原手机号和 V2 新密码登录 APP，获准管理人员本人验证 Web 后台，缺角色/名单、禁用、退出和撤权负例通过。只有 Owner 确认两硬门完成并批准测试范围，才可进入封闭内测。 |

## 共享 HTTPS 容量与费用

| 方案 | 可行性及成本 |
|---|---|
| A · 现有上海旧机 | 历史 2 vCPU、2 GiB、根盘可用约 24 GiB、可用内存 627–628 MiB、无 swap，同时运行旧 Laravel/MariaDB/Redis/LiveKit。旧站仍按历史保护范围运行。零新增实例费依赖容量足够、无升配且已包含网络；备份、带宽/流量、域名及运维成本另核。本轮仍 `CAPACITY_NOT_APPROVED`。 [CLOUD-R0 原证](V2_CLOUD_R0_ENGINEERING_REPORT_20261121.md) |
| B · 独立上海轻量/ECS | 建议起点 2 vCPU、4 GiB、50–60 GiB SSD 及独立网络。阿里云开发者社区公开参考为轻量通用型 2 核 4 GiB、50 GiB、200 Mbps 峰值的 70 元/月刊例、379 元/年活动。它是公开参考，具体上海库存、账号活动资格、续费与税费待具名选配页。阿里云官方支持套餐内网络，旧有固定流量套餐内地超额 0.8 元/GB，轻量内置快照有数量限制且免费。ECS 需另列系统盘、EIP/公网、快照和 VPN 并按计费周期计算。已查官方购买入口和计算器，未返回该账号的上海结算价。本轮云端支出 0 元。 [轻量公开参考](https://developer.aliyun.com/article/1784154) · [阿里云官方计费项](https://help.aliyun.com/zh/simple-application-server/product-overview/billable-items) · [官方价格计算器](https://www.aliyun.com/price/product) |

容量核准方案在取得具名只读权限后，先采旧业务覆盖一个日峰值和备份窗口的 CPU、内存、OOM、磁盘 I/O、连接/LiveKit 并发及 80/443/8088 等监听。建议门槛为 CPU p95 ≤70%，预留内存 ≥ 实测 V2 峰值预算 ×1.25，无新增 OOM/持续 swap，磁盘留 ≥20% 且能保留可恢复备份，旧站 p95 相对基准增长 ≤10% 且无错误率上升/通话抖动。具名负载之前保持旧机否决。独立资源预算必须列新购、续费、带宽/流量、快照、域名证书与受控网络，Owner 确认总上限后另行批准写入。

两方案都需独立 V2 FPM、worker、MariaDB 服务身份/schema、数据库与媒体卷，以及功能隔离网络。用受信 TLS 和固定地址，按具名 VPN 或访问源限制 APP；Web 管理/激活入口额外限制，数据库、Redis、FPM 不发布公网。Android Dart/原生共享同一环境地址并复核无旧站回退。先以合成账号验证远程连通、备份与恢复、三盘/队列、持续负载和切换回滚。1011806 为本机回环候选，未来共享地址需重新固定签名 APK 并申请具名设备授权。

## 内测剩余门槛与证据索引

共享 HTTPS 部署/远程联测、所有指定旧账号的真实恢复及本人异地登录、1011806 真机媒体/外部 URI/失权与弱网补验均待执行。A10/A12 同版手机截图与本轮 W01–W04 截图待采，原 1011805 截图与 A05 哈希仍沿原索引。旧排盘 A/B/C、注册可信离线 T0、真实 KYC/Push/RTC/法定删除、软著正式申报与历史失败维持原状态。Owner 真实数据、设备安装、云写入及费用审批均未消费。

| 本地回执 | SHA-256 |
|---|---|
| `p04-hardening-flutter.log` | `2fb88eaeac1e1557a918012fbd32ce31b0ffbf83fb1e3734cefba26520c74854` |
| `p04-hardening-dart-analysis.log` | `f069bcdde7e26a8943b01489a8662e0f226f8cfcb002c5c3e8a799df6d6f63c6` |
| `p04-hardening-api-fault.log` | `896d7eb37fc37f6478f214bbaae06df67b87d91b29cbc8ea2e840a25f60d1e24` |
| `p04-hardening-admin-phpunit.log` | `9964aac91a67153d75c609f3361c87846ce3347204625e4ee2caff2a673a63b3` |
| `p04-hardening-phpunit.log` | `c370f6460f821f4cb4655011fb3ad20e31b5ee67613cf6be2ae43eb4ebe2eaa2` |
| `p04-hardening-php-baseline-failure.log` | `d01178775450be6ae6615e82827fd99404eb75034bea921fc19c7db81fec7267` |
| `p04-hardening-staging.log` | `bd9edd69c49910e9d2c5956cbc894fad61d7f94a1d987858b44b58d034860871` |
| `p04-hardening-signed-e2e.log` | `6f52bb755232fab21220283be6bf934709ee784006e863aa7c8c238a66f12ddf` |
