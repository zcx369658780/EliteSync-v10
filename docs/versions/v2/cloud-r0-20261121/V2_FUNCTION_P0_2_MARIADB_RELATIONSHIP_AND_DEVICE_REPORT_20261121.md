# EliteSync V2 P0.2 MariaDB 关系闭环与单设备准备报告

2026-11-21 · **MARIADB_TEST_ONLY_RELATIONSHIP_E2E_PASS / ANDROID_HOST_PREFLIGHT_PASS / DEVICE_OWNER_GATE / CORE_FUNCTIONS_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO**

本轮在本机专用 MariaDB 上验证了报名、实际匹配计算、候选发布、双方选择、独立 Connection、消息同意、正式关系双方确认及撤权。Android 1011805 APK 和主机回环预检通过，实际设备操作均为 NOT_RUN。软著操作手册正文已起草。 [固定治理任务](https://github.com/zcx369658780/EliteSync-v10/blob/43c5997a0b0c4ea963297ee4419140fa6b4cc850/docs/versions/v2/V2_FUNCTION_P0_2_MARIADB_RELATIONSHIP_AND_ANDROID_DEVICE_CLOSURE_BRIEF_20261121.md) · [手册准备稿](ELITESYNC_V2_OPERATION_MANUAL_DRAFT_20261121.md)

## 工程与隔离身份

- 实际工程根 D:/EliteSync/development/v2-cloud-r0-20261121，origin 为 zcx369658780/EliteSync-v10，分支 codex/v2-function-completion-20261121。起点 `6e3f52522033da04bc84d0c291d11d13f2dff36d`，工作树和暂存区原为空。固定源码和脚本 `362abd618a1f670e313b365b60b5dfe1f6ab71b8`，较起点 ahead 2、behind 0。Android/Flutter 树 `c75649ffb470521e581963325c57d1ccc4d581ee` 与 1011805 源码一致。旧脏 main、IP13I 及原证留存。 [固定源码](https://github.com/zcx369658780/EliteSync-v10/commit/362abd618a1f670e313b365b60b5dfe1f6ab71b8) · [上批工程报告](V2_FUNCTION_P0_CANDIDATE_CLOSURE_REPORT_20261121.md)
- 后端镜像由 `2a528919702289b4e0c39d86a5bb52d6067fc745` 的 Git 归档构建，镜像 ID `sha256:4e55a606161eca08bacf568462395470a71bf60e551bfd01b64922885d26377e`。PHP 8.4.28、Laravel 13.39.0、MariaDB 10.11.19，专用 WSL Docker 项目 elitesync-v2-function、内部数据网络、116 表。FPM 与 DB 无宿主端口，HTTPS 仅回环 18444。测试结束三个容器退出码均为 0，两专用卷保留。 [Compose](../../../../services/backend-laravel/docker/cloud-r0/compose.function.yaml)

## MariaDB TEST_ONLY 资格

测试适配器要求 staging、固定本机功能标识、HTTPS 回环地址和默认关闭的专用开关同时满足。连接配置须为 MariaDB、r0-db:3306、elitesync_function_app，禁用 DB URL 与 socket 替代。运行时另查 schema、认证数据库账号、server ID 2621121 和 MariaDB 10.11。实际连到同名库、同名数据库账号但 server ID 为 2621122 的独立空探针容器时，CLI 签发拒绝。

指定批次的启用合成账户方可获资格。签发将 issuer、dataset、当前数据库标识、账号、nonce、revision 和有效期作为 HMAC 数据，最长 60 分钟，防止重放，过期或停用立即失权。本机测试密钥只读挂载，签发及撤销均走 CLI 和审计；无 HTTP 签发入口。真实身份标志和 `formal_participation_available=false` 保持，SQLite 内存签名路径独立，上一批好友场景的合成 Connection 授权仍独立。 [签名与资格](../../../../services/backend-laravel/app/Services/MariaDbFixtureIdentity.php) · [CLI](../../../../services/backend-laravel/app/Console/Commands/MariaDbFixtureIdentityCommand.php) · [资格路由](../../../../services/backend-laravel/app/Services/TrustedIdentityService.php)

## 具名结果

| 范围 | MariaDB HTTPS / 数据库实测 | 状态 |
|---|---|---|
| 匹配与候选 | 合成问卷准备、HTTPS 匹配输入和 Lifestyle 完成、报名、运营 API 准备轮次并请求执行、实际消费者生成 1 组候选、确认发布。发布前候选隐藏；两方各自接受，旧修订和同键异请求 409，受权只读回执 APPLIED。退出/重入产生新代，旧决策拒绝。 | PASS，TEST_ONLY |
| Connection、正式关系及私信 | Match 本身不建立关系，Connection 与正式关系均由双方分别确认。无独立消息同意时读取 404，取得同意后同一文本 ID 可由双方读回。正式关系来源为已生效的 Connection revision 2。 | PASS，TEST_ONLY |
| 撤权、Block 与历史 | 撤销后旧连接、旧消息 404，关系进入 SUSPENDED_REVERIFY。重签仅提供新资格，恢复需双方重新确认。Block 后关系 ENDED、关系槽位 0，旧连接、消息和对方资料 404，越权关系操作 404，旧通知仅历史投影。旧候选历史保留双方事实并隐藏内容。 | PASS，TEST_ONLY |
| 拒绝与过期 | 普通账号、错批次、禁用者、超 TTL、重复 nonce、错误环境/标志/库/主机/账号/端口/回环/真实服务器 ID 均拒绝签发。单方无签名时报名 403。篡改签名与自然到期凭据失权。另以已发布的具名合成提案模拟到期，旧接受返回 409，历史为 EXPIRED，未代替任何一方作决定。已签发后停用的账号旧会话 403。 | PASS，具名负例 |
| 独立重启 | 仅重启 MariaDB，FPM 与入口容器启动时间不变。92 条迁移、关系终态及来源版本、消息、历史通知、Block、撤销审计与到期拒绝重启后可核。受信 HTTPS 恢复返回访客 401。 | PASS |
| 真实身份与正式运行 | 真实 KYC、生产环境、真实用户关系、真实 Push、RTC、法定删除受理保持外部阻断。 | BLOCKED_EXTERNAL / NOT_RUN |

主要流程 85 条 HTTP 状态和 23 次 CLI 回执，补充提案到期与账号停用 33 条 HTTP 状态和 5 次 CLI 回执。操作者的测试题与账号资料由专用脚本置备，用户端业务调用均经过 HTTPS。现行 PHP 容器定向回归 127 项、1,587 断言、0 失败，含上一批精选 46 项及其原 12 项。此前全量 Q PHP 46 errors / 122 failures、旧排盘 25 项、R1 Flutter 扩围 5 项及 1011804 原 FAIL/UNKNOWN/NOT_RUN 保留。本轮 PHP/Flutter 全量、当前 Android 整机、正式 A6 均 NOT_RUN，F-01 READABILITY_PARTIAL、原 43 PNG PENDING_BINARY_UPLOAD 延续。 [HTTPS 脚本](../../../../services/backend-laravel/docker/cloud-r0/function-relationship-smoke.py) · [原 12 项账](V2_FUNCTION_P0_CANDIDATE_CLOSURE_REPORT_20261121.md)

## Android 1011805 单机准备

- 独立 APK 为 `com.elitesync.v2functionp0 / 10.1.18-v2-function-p0 / 1011805`，arm64-v8a，209,094,024 字节。复算 APK SHA-256 `d6064498bac327f40f2b2df9c5ed9664c819b29dfaffa916eaf6f6df7b649c05`。Debug v2 签名证书 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。既有原生与 Dart 同一回环端点 `https://127.0.0.1:18444/` 以及 TLS 证书 `41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96` 与 APK 身份相符，主机以固定证书拿到访客 401。ADB 1.0.41 / platform-tools 37.0.0 的本机帮助确认 reverse 与 no-rebind 能力。首次主机工具选错证书解析重载的日志保留，最终预检 exit 0。 [设备准备脚本](../../../../tools/android/v2-function-1011805-device.ps1)
- 脚本默认仅检查主机。实际手机序列号、Owner 授权引用和 USB 测试窗口待确认。具名阶段先验证测试包未安装或单独确定保留策略，再对该设备建立 `tcp:18444 → tcp:18444`，仅安装核验过的固定 APK。反向转发、安装和设备读取、截图、logcat 均 NOT_RUN。授权结束仅收回本次建立的映射。
- 具名验收顺序为冷启动、登录/退出与切号、三盘已知/未知输入、慢约候选/拒绝、消息同意与私信、社区图片、Buddy、通知旧链、Block 与断网恢复。每步记录合成账号的 UI、HTTP 状态、数据库版本和旧入口失权。同版截图按手册 A01–A12 与 W01–W04 采集。

## 证据索引

原始日志及 JUnit 私存于隔离运行目录的 evidence，APK 和原签名、编译端点回执继续保存在 android-p0-20261121。

| 文件 | 结果 | SHA-256 |
|---|---|---|
| `p02-runtime-start.log` | 专用环境和 DB 预检 | `72f8a41bc4e4a53f34755db84d3e2c876b08787d3b0edbc578c2875ef76b3099` |
| `p02-https-relationship-first.log` | 正反链 exit 0 | `690f4e8d4c02bf0a689e1c8b43b7d2802a0766e04572c20bf542dc12096397ab` |
| `p02-proposal-expiry.log` | 到期及停用 exit 0 | `378d486e9649cbc0f0534a19b6364e8b16f6f6fa7c6528993a3de28d5aea8e4b` |
| `p02-wrong-db-server-final.log` | 错误 server ID 的 CLI 预期 exit 1，探针 exit 0 | `07f3a1359ab903cd5d63d764d7aa2131423387bf4946048b90d79744273dc4fd` |
| `p02-mariadb-restart.log` | 仅 MariaDB 重启、持久及 HTTPS 恢复 exit 0 | `1fa9886845c2de89714bf2d283386acb361b835878267e38b7b58d4d38935136` |
| `p02-persistence-final.log` | 最终读回脚本 exit 0 | `2fc7e75d8129eade48dfb8f602fc51dcc2a1c1dcd0184e41d515a4ebab3340db` |
| `p02-phpunit-scoped.xml` | 127 项 / 1,587 断言，exit 0 | `4983f16bc34c9491b3f718e739f269eaae96346b1f33fd88408cf45665279607` |
| `p02-android-host-pass.log` | APK、签名、主机 TLS、ADB 本机能力核实 exit 0 | `f6f8685c393cc6f68ef27f3c7527ffad8c1ea144826dd900c69d3d24303f9654` |

## 软著准备与 Owner 门

已完成手册正文初稿及功能、源码、依赖许可、素材、权属和截图清单。正式软件名、权利主体、职务或委托材料及第三方授权由 Owner 确认。同版真机截图需实际授权后采集。旧排盘 A/B/C 与注册可信离线 T0 继续待决。封闭内测仍缺同版实机证据、受控参加范围、用户告知与 Owner 准入决定。登记递交、PC 清理、云迁移、真实管理员恢复、main 合并、内测与发布均未启动。
