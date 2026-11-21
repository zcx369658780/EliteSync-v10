# EliteSync V2 P0 功能收口与候选质量报告

2026-11-21 · **本地具名链通过 · Android 独立 APK 已固定 · 实机待具名授权 · 核心功能 PARTIAL · CLOSED_BETA_CANDIDATE_NO_GO · PRODUCTION_NO_GO**

原 12 项 PHP 精选失败均在本轮同名回归通过。实际匹配运行与发布、双方决定、Connection 和正式关系的签名合成链已补测。隔离 MariaDB 上验证了现行身份门禁、Web 管理、会话续期及私有图片失权。Android 已核对构建、签名及双端端点，设备旅程仍为 NOT_RUN。 [最新治理任务](https://github.com/zcx369658780/EliteSync-v10/blob/486db93d97e1570a881d222ed7979ac9b499b3fa/docs/versions/v2/V2_FUNCTION_P0_CANDIDATE_CLOSURE_CONSOLIDATED_BRIEF_20261121.md)

## 工程、运行与 Android 身份

- 隔离根 D:/EliteSync/development/v2-cloud-r0-20261121，origin 为 zcx369658780/EliteSync-v10，分支 codex/v2-function-completion-20261121。起手为上批报告 `3b42dfe4328fc2fe520cab1fe9561830fcb8ca56`，工作树和暂存区为空。本轮源码 `36ae37206f482109e0bfc7a0f95335fc056da323`，较起点 ahead 2、behind 0，apps 树 `c75649ffb470521e581963325c57d1ccc4d581ee`，services 树 `2bf7a179c35d6270daccd5939c35dbd27d103743`。原脏 main、IP13I 未跟踪目录和旧工程资料保留。 [固定源码](https://github.com/zcx369658780/EliteSync-v10/commit/36ae37206f482109e0bfc7a0f95335fc056da323) · [上批报告](V2_FUNCTION_COMPLETION_QUALITY_REPORT_20261121.md)
- PHP 8.4.28、Laravel 13.39.0。HTTPS 服务为专用 WSL Docker 项目 elitesync-v2-function，镜像从 `726ff399fd9fc9587b3aa93dbd244f14eb48ed82` 后端归档构建，ID `sha256:c8fddd73247bd2e5c3149774b7038dcbfbd02027160699b835b1b6e14346df3a`。从该提交到最终源码的后端差异仅为烟测 PNG 样本。MariaDB 10.11.19、schema elitesync_v2_function、server ID 2621121、116 表。仅 HTTPS 回环 18444 有宿主端口，FPM 与 DB 在专用网络。PHPUnit 正向资格在无网络容器内使用 SQLite `:memory:`。测试结束三个容器退出码均为 0，两个命名卷保留。 [Compose](../../../../services/backend-laravel/docker/cloud-r0/compose.function.yaml)
- Android 包 `com.elitesync.v2functionp0`，`10.1.18-v2-function-p0 / 1011805`，arm64-v8a，209,094,024 字节。APK SHA-256 `d6064498bac327f40f2b2df9c5ed9664c819b29dfaffa916eaf6f6df7b649c05`，Android Debug 签名 v2 校验通过，签名证书 SHA-256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。APK 私存于隔离运行证据目录的 `android-p0-20261121/EliteSync-V2-function-p0-1011805.apk`。 [Android 构建定义](../../../../apps/android/app/build.gradle.kts)
- 原生 `BuildConfig.API_BASE_URL` 与 Dart `ELITESYNC_API_BASE_URL` 均固定 `https://127.0.0.1:18444/`。启用构建专属参数时，Gradle 要求覆盖回环地址的公开证书并只开 Debug 变体。两端使用独立信任根，防止跨源、代理、重定向和回退旧站。冷启动端点不一致时显示错误。WS、RTC 与原生语音通道关闭。包内 Dart arm64 库与 AAR 的 SHA-256 一致并含目标 URL。Dart HTTPS 绑定证书时实际读取访客 401，缺信任根或换源被拒。TLS 证书 SHA-256 `41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`。 [原生客户端](../../../../apps/android/app/src/main/java/com/elitesync/network/ApiClient.kt) · [Dart 启动](../../../../apps/flutter_elitesync_module/lib/main_prod.dart)

Android 采用 ARM64 Flutter release AAR → 独立 debug 宿主。复用运行库缓存，补取指定 AndroidX 2.7.0 的两份官方 POM。AAR 首轮缺缓存描述、随后 Dokka Metaspace 失败，均留原日志。最终仅在隔离构建跳过非运行期 JavaDoc 生成，并对测试包固定 Activity KTX 的同版依赖以排除重复类。AAR/宿主构建、签名和证据核对均 exit 0。实机仍为 DEVICE_OWNER_GATE。

## 功能与剩余验收

| 范围 | 本轮证据及状态 | 仍待验 |
|---|---|---|
| P0 注册、登录、资料与三盘，S01/S05/G01/G04/G08 | HTTPS 注册、资料读写、三盘已知/未知时刻、陈旧修订 409、退出后旧凭据 401。真登录的设备刷新凭据轮换成功，旧访问和刷新凭据均 401。Flutter 冷启动清理和切号隔离有具名 Widget 证据。PARTIAL | 当前 APK 的录入、低网、冷启动、切号、退出及历史。注册离线 T0 待决，三盘总态仍 COMPUTED_UNVERIFIED。 |
| P0 慢约与候选，S02–S04/S06/G01/G06 | 轮次准备、真实执行命令、发布、双方决策、同键回执、退出、过期、改代和历史证据在签名 TEST_ONLY 测试通过。MariaDB 现行正式报名 HTTP 403。PARTIAL | 真实 KYC 待接。正式流程正向证据仅来自 PHP/SQLite 内存合成环境。当前 APK 的匹配、持续参与和跨设备待验。 |
| P0 Connection、双方消息同意、私信及 Relationship，S10/S11/G08/G09 | 复用上批 Flutter HTTPS 双端文本及撤销旧链 404。新测实际生成候选 → 双方接受 → 独立 Connection → 双方确认 Relationship，消息授权仍独立。Block 后关系 ENDED、active slot 清空、旧连接 404、同键回放 409。服务端改为重验来源当前权利，资格缺失时隐藏确认/恢复。PARTIAL | 正式身份、真机双端、消息媒体和系统 Push/RTC。 |
| P0 首页、好友社区、媒体与旧链，S01/S13–S14/G02/G03/G08 | 真 multipart 上传私有封面与头像，MariaDB 核实对象与版本。错格式/超限 422、旧头像修订 409、未登记者拒绝。原好友读到字节且 no-store，后加好友可读作品但旧封面 404，Block 后旧封面、头像、作品均 404。隔离聊天仍限文本。PARTIAL | 当前 APK 渲染、选图、真实双端 Block 传播、视频及聊天附件。 |
| P0 Web 管理 | 真实 Laravel Web 表单、CSRF、有效 session、来宾与名单内非管理员拒绝、举报分流及陈旧修订拒绝、形象审核与本人发布、停用、审计和退出。MariaDB 核对落库。具名链 PASS | 更多运营配置、申诉场景和真实管理员账户。 |
| P0 Buddy、通知，S12/S15–S16/G08/G09 | 复用 Buddy 发现、申请、确认、退出、同键回执。PHP 实证消息失权后当前频道剔除，历史无正文、身份和路由，旧详情重验。PARTIAL | 当前 APK 的 Buddy 主旅程、通知待办办理、真实 Push。 |
| P1 Lifestyle、权限、用途和可达性，S07–S09/G04–G05/G07/G10 | 沿用用途隔离与删除技术拒绝合同。Flutter 具名验证返回、可达性组件、旧历史不可读、冷启动和迟到保护。PARTIAL | Android 辅助技术、设备级撤权与法定删除受理。 |

## 原 12 项 PHP 分诊

原 R0 与上批均为 46 项、120 断言、12 FAIL。R0 只补 Blade 缓存目录，复跑为 46 项、130 断言、11 FAIL。现行选集在同 PHP 8.4.28、同 SQLite 内存配置下为 46 项、401 断言、0 FAIL。下表逐项比对原 JUnit 与本轮 JUnit。

| 类 | 方法 | 原签名与原因 | 当前 |
|---|---|---|---|
| V1006AdminWebTest | `test_web_login_search_and_disable_share_the_api_action` | 200→500，归档测试树缺 Blade compiled path | PASS |
| V1006AdminWebTest | `test_active_refresh_retains_response_contract` | 200→401，旧 token 缺设备会话。现覆盖真登录刷新、同会话和旧凭据拒绝 | PASS |
| V1007LiveConsentTest | `test_match_alone_and_single_party_do_not_grant_messages` | 候选首次接受 200→409，旧夹具缺签名资格与当前答卷 | PASS |
| V1007LiveConsentTest | `test_legal_send_replay_read_and_revocation_check_current_server_state` | 同上 | PASS |
| V1007LiveConsentTest | `test_unknown_actor_disabled_peer_and_unconfigured_environment_deny` | 同上 | PASS |
| V1007LiveConsentTest | `test_latest_message_window_keeps_new_messages_and_legacy_cursor_order` | 同上 | PASS |
| V1007LiveConsentTest | `test_older_message_pages_are_nearest_chronological_and_exclusive` | 同上 | PASS |
| V1007LiveConsentTest | `test_a_second_authorized_peer_cannot_replay_a_revoked_peers_message` | 同上 | PASS |
| V1007R1NotificationPrivacyTest | `test_new_storage_minimizes_private_content_and_legal_navigation_is_derived` | 候选 200→409；补齐资格后需区分准备通知及消息计数 | PASS |
| V1007R1NotificationPrivacyTest | `test_revoked_old_notifications_do_not_expose_content_identity_or_navigation` | 候选 200→409；原测试未区分当前频道与历史最小投影 | PASS |
| V1007R1NotificationPrivacyTest | `test_blocked_disabled_and_unknown_authority_fail_closed` | 候选 200→409；原测试未区分当前和历史 | PASS |
| V1007R1NotificationPrivacyTest | `test_spoofed_legacy_pointer_cannot_borrow_other_receivers_authority` | 候选 200→409；补齐资格后复验真实详情拒绝 | PASS |

## 证据索引

原始日志位于隔离运行目录的 evidence，APK 和构建日志在 android-p0-20261121。以下为脱敏复核入口。

| 日志或 JUnit | 实际结果 | SHA-256 |
|---|---|---|
| `p0-phpunit-selected-final.xml` | exit 0，46 项 / 401 断言 | `3ce0e825bda252f0ade94b8bd37263f0c50f09e0445a8bf0617618d25940c465` |
| `p0-phpunit-adjacent-updated.xml` | exit 0，117 项 / 1,496 断言，含上一行。3 个邻接 R1 夹具补齐现行输入与签名 | `be7270a6ec3057e86b5c6d9112f294ed2bd930dcd7a2dae5ad3f74a3158562a9` |
| `p0-phpunit-avatar-final.xml` | exit 0，10 项 / 91 断言 | `b3dcdd7a488e25bc3d0c504964213263b12521abc627a7055d69ed49979b8bd6` |
| `p0-phpunit-r0-with-view-dir.xml` | R0 环境修复对照 exit 1，11 FAIL | `e7f7c3eb29c2294bc227b981268663573b128a2b80f5c9a53ed99ca50db6a4f7` |
| `p0-https-passing.log` | exit 0，80 条具名 HTTP 状态及持久化断言。保留首轮测试 PNG 无法解码 422 的记录 | `ad16cd83c84093d181effb93369d9ebdd1513c3af7888e2075e22d2b6f6bb7ac` |
| `p0-flutter-final.log` | exit 0，128 项，覆盖实际 TLS、冷启动、旧入口及失权。保留初轮 4 项测试合同对齐前的失败 | `3f9b68d50be2f55d0dee43794485d734285aea3d3c8a121385e77232a363b2af` |
| `p0-dart-reviewed.log` | exit 0，8 文件无问题 | `cccab7bfb3ea8024b9b089e7b9e8a0bcc48f501d97ccede9b644c7cfca628f3e` |
| `p0-apk-identity.log` | exit 0，包名、签名、证书、端点及 AAR 与 APK 库一致 | `8791f0d782ddd9e22793f514e104783c84eae1a1741241b80d65bafd42cedc98` |
| `p0-isolation-final.log` | 专用实例预检及停止 exit 0，两个卷保留 | `e6a368011d94e2b3bae0da5ef1a0f6454343ba7ce3bba29357800ea7ddaa3b9b` |

本轮全量 PHP/Flutter、设备安装、正式 A6、生产运行和真实供应商均 NOT_RUN。Q 全量 46 errors / 122 failures、旧排盘 25 项、R1 扩围 5 FAIL，历史 1011804 的 FAIL/UNKNOWN/NOT_RUN、F-01 READABILITY_PARTIAL 和原 43 PNG PENDING_BINARY_UPLOAD 照原记录。G0b 原文待独立审阅，云端和旧备份证据保留。 [Q 质量报告](../q-20261120/V2_Q_ENGINEERING_REPORT.md) · [R1 报告](../q-20261120/V2_Q_R1_ENGINEERING_REPORT_20261121.md)

## 软著资料与封闭内测门

- 暂用软件名「慢约会（EliteSync V2）」。准备索引包括 Flutter 路由与会话、Laravel 匹配/社交/私密媒体及迁移、Web 管理视图、Android 宿主和构建。许可核对入口为 Flutter pubspec.lock、Laravel composer.lock、三盘 notices 与 Android Gradle 依赖。正式版本名、权利主体、原创或委托权属和素材来源待 Owner 确认。 [Flutter 路由](../../../../apps/flutter_elitesync_module/lib/app/router/app_router.dart) · [API 路由](../../../../services/backend-laravel/routes/api.php) · [Web 路由](../../../../services/backend-laravel/routes/web.php)
- 操作说明与同版截图索引分为四组。账号、资料和三盘录入/历史。首页、慢约准备、候选、连接、双方同意与私信。社区发布/评论、旧封面与 Block、Buddy 发现/加入及站内通知。Web 登录、形象审核、举报与审计。手册正文与同版截图待设备验收后定稿，登记递交 NOT_RUN。
- APK 已具备提交具名测试的工件条件。封闭内测还需要 Owner 具名单台设备、测试账号、数据范围、USB 回环与测试窗口，并验收当前包的冷启动、断网恢复、注册/切号、本命、私信、媒体、Buddy、通知及失权旧链。内测参加人员、用户告知、访问限制和停止条件待另行批准。真实 KYC、Push、RTC 与删除受理待供应商或合法主体。
- 旧排盘 A/B/C 继续待决，建议以独立手填覆盖和可验证迁移作为兼容选择依据。注册 T0 建议分开裁定在线注册恢复与可信离线缓存。软著实际申请、内测、main 合并、生产发布和服务器迁移均停在既有授权边界。
