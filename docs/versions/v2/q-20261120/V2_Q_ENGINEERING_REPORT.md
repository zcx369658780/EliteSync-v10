# EliteSync V2-Q 集成质量与产品决策工程报告

日期 2026-11-20。工程自验结论 **具名隔离合同 SCOPED_PASS，扩大内部候选 PARTIAL，生产 NO_GO**。Flutter 原扩围三项已收口。PHP 全量仍 FAIL，附录保留 D 的 214 条逐例记录，其中 C 新增的旧排盘 25 条全部保留。Owner 与顾问集中验收为 PENDING。

## Q0｜授权、源码与复跑基线

本轮从阶段 D 固定工程包切出 `codex/v2-q-integration-quality-20261120`，完整继承固定 D 源码与 A、B、C 工程。治理材料从固定 GitHub 提交只读核验。[Owner 授权](https://github.com/zcx369658780/EliteSync-v10/blob/c3499b0d599698287a73fd295aaf5892a74d12c1/docs/decisions/OWNER_V2_PHASE_D_FINAL_SCOPED_ACCEPTANCE_AND_INTEGRATION_QUALITY_AUTHORIZATION_20261120.md) · [集中任务书](https://github.com/zcx369658780/EliteSync-v10/blob/c3499b0d599698287a73fd295aaf5892a74d12c1/docs/versions/v2/V2_Q_INTEGRATION_QUALITY_AND_PRODUCT_DECISION_CONSOLIDATED_BRIEF_20261120.md) · [现有会话启动说明](https://github.com/zcx369658780/EliteSync-v10/blob/c3499b0d599698287a73fd295aaf5892a74d12c1/docs/workflow/V2_Q_CODEX_EXISTING_SESSION_KICKOFF_PROMPT_20261120.md)

| 项目 | 已核身份 |
|---|---|
| 工程根 | `D:/EliteSync/development/v2-phase-a-20261119` |
| origin | `git@github.com:zcx369658780/EliteSync-v10.git` |
| 固定 D 工程包 / D 源码 | `40ba853a3e9fed9062e8527b22c0b8ca9471e9ce` / `cdfd8f2753147ac3eaacd24af30d69a7efb3d07e` |
| 固定 Q 源码 | `5e457fb0fd21c5978864f146d78120cc9a7d025b`，此报告提交的直接父提交 |
| Q 工作区及暂存 | 起点、源码锁定时 Git 均显示干净。交付 SHA 以提交本报告后的 GitHub 分支回读为准。 |
| 原脏 main | `D:/EliteSync-v10`，`main`，`4bebc8f394248e254c1368a06fbdee5d2c883301`，43 项跟踪文件修改、213 项简表未跟踪条目，暂存 0。 |
| S1 审阅树 | `D:/EliteSync-v10-product-v1015-20261101`，`codex/ui-current-state-audit-20261116`，`1d8b485bf4f314d42431bb62a293a3fef9e9c8af`，跟踪文件修改 0、2 项简表未跟踪条目，暂存 0。 |
| 独立治理交接树 | `D:/EliteSync/development/v2-governance-handoff-20261120`，`codex/v2-governance-handoff-sync-20261120`，`c73074bebc8ea55086b4ce2b537dade174bb9ed0`，跟踪文件修改 0、1 项简表未跟踪条目，暂存 0。 |

三棵保护树均只读检查。表中未跟踪数采用 `git status --porcelain=v1 --untracked-files=normal` 的条目口径，目录可折叠。复核时根、origin、分支、HEAD 及短状态计数与起点一致。

| PHP 全量 | 用例 | 断言 | Errors | Failures | 结论 |
|---|---:|---:|---:|---:|---|
| B 历史 | 见 B 原报告 | 见 B 原报告 | 81 | 108 | FAIL |
| C/D 历史 D 回执 | 1,498 | 26,154 | 83 | 131 | FAIL，C 新增 25，D 新增 0 |
| 同一 D 工程包，辅助完整归档 | 1,498 | 26,603 | 48 | 130 | FAIL，exit 2 |
| Q 固定源码，辅助完整归档 | 1,500 | 26,684 | 46 | 122 | FAIL，exit 2。另 1 deprecation、4 skipped、2 risky。 |

历史 D 归档缺题库源码和 Blade 编译目录。重新归档同一 D 工程包时加入 Git 跟踪的 `question_bank/` 与 `dating_question_bank_v_1.json`，并创建所需空运行目录。在相同辅助条件下，22 条题库加载错误和 14 条 Blade 缓存路径错误恢复，归因由同源 JUnit 和异常签名支持。该 36 条是证据环境修复。Q 使用同样方式归档与测试，Q 修复 10 个历史测试前置或副作用断言，2 errors 和 8 failures 转 PASS，新增失败标识 0。全量新增两条通过用例，覆盖搭子回执与旧匹配最小投影。没有删去历史用例。历史 D 已接收时的 FAIL 记录保留。[D 固定交付报告](https://github.com/zcx369658780/EliteSync-v10/blob/40ba853a3e9fed9062e8527b22c0b8ca9471e9ce/docs/versions/v2/phase-d-20261120/PHASE_D_ENGINEERING_REPORT.md)

## Q1｜旧排盘和 Owner 待决项

旧排盘 C 新增 25 项在 Q 同环境全量继续 FAIL，均见附录 A。旧客户端安装面、迁移成本和实际用户影响为 UNKNOWN。任务书给出的安全行为在隔离回归中继续生效。

| 旧入口与测试组 | 当前权威行为与客户端路径 |
|---|---|
| `POST /api/v1/profile/astro`，`AstroCanonicalApiTest`、`V1007BaziProvenanceTest` | 缺具名用途与合法依据时固定 409 `LEGAL_BASIS_UNVERIFIED`，旧自动计算、正午兜底和旧缓存重算关闭。当前 App 通过“我的 → 星盘”中的“打开本命手填工具”或“三盘本命 · 手填与排盘”，使用本人本次明确录入的 `GET/POST /api/v1/profile/natal`。 |
| `GET /api/v1/profile/astro[/summary\|/chart]`，`AstroCanonicalApiTest` | `AstroProfileController::show` 只允许本人读取已存独立本命的私有投影。仅有旧衍生记录时返回依据未核实状态且 profile 为 null。Flutter 保留拒绝说明和手填路径。旧画法、缓存签名及精度警语的等价体验待裁决。 |
| `POST /api/v1/profile/basic`，`ProfileBasicRecomputeTest`、`V1007BaziProvenanceTest` | 保存本人账号事实。用途授权、数据来源和当前版本仍由独立服务检查。历史候选快照保持原发布绑定。相关依赖受事实更正影响时重审，过时派生结果不得以已验证身份新发布。 |
| `GET /api/v1/profile/basic` 和 `POST /api/v1/auth/login`，`AuthPasswordApiTest` | 读取本人确认的账号事实。缺字段保持空。旧衍生盘 `birth_place`、时间与坐标不回填到账号或用于匹配。 |
| 动态本命当前和历史读取 | 当前用途许可、快照来源及版本独立重验。撤销、过期、未知和晚到落库拒绝。真实历史来源及真实处理依据待具名核查。 |

| Owner 选项 | 用户影响 | 实施前置 |
|---|---|---|
| A 有界升级过渡，顾问建议 | 继续给旧自动入口明确的 409 和升级指引，保留当前 App 的独立手填。旧客户端原有自动入口仍受限。 | 核实旧版本覆盖、升级路径、旧接口可读范围和保留期。 |
| B 正式退役旧自动排盘合同 | 公布退役范围和最低版本，保留独立工具。旧客户端须升级。 | Owner 具名批准核心能力变更及兼容期限，迁移、发布另行授权。 |
| C 具名合法的有限兼容桥 | 证据成立时限用途、字段、来源、有效期和撤销，未获许可时继续 409。 | 确认真实依据、旧资料权威、失权传播和迁移处理能力，再定实际启用。 |

Owner 需选择 A、B 或 C，并明确只读历史、本人手填和具名用途新计算各自保留的范围。旧排盘测试与策略未决均保留。本轮隔离覆盖拒绝与替代入口，真实算法准确性及旧客户影响保持 UNKNOWN。[固定选择备选](https://github.com/zcx369658780/EliteSync-v10/blob/c3499b0d599698287a73fd295aaf5892a74d12c1/docs/product/V2_Q_LEGACY_ASTRO_COMPATIBILITY_OWNER_DECISION_OPTIONS_20261120.md)

## Q2｜三条 Flutter 回归与 PHP 核心分诊

| D 固定扩围失败 | Q 变更与验证 |
|---|---|
| `v1013_root_entry_test.dart` 无法编译，`SessionNotifier.build` 仍用旧异步签名 | 使用当前同步会话类型。默认构建验证旧专属入口未出现。显式 `ELITESYNC_V1013_LOCAL_BUILD=true` 用真实分支，正向验证首页及进展页分别打开 Buddy、好友社区，四项均保留。测试使用 App 外层 Material 容器和隔离传输，进展页先展开原有分组。默认和 v1013 专项均 PASS。 |
| `v1019_buddy_pages_test.dart` 分页 403 后提示不符合预期 | 页面原有的卡片、游标和分页按钮清除继续生效。将本地确定的许可提示精确映射，未知错误仍使用通用文案。定向覆盖 403、瞬时失败及迟到 403 后的新账号/权限状态，PASS。 |
| 同文件，创建响应丢失后草稿及原命令无法正常保留 | 本人表单在服务端列表失效时仍可只读查看，账号或权限变化清除。请求存不可变原 payload。用户点原编号重试后先查只读回执，收到 `NOT_APPLIED` 才重发同一命令。 `APPLIED` 刷新列表，`CONFLICT` 或未知保持待核，拒绝或迟到响应不触发写入。定向和扩围 PASS。 |

搭子回执使用 `GET /api/v1/buddy/activities/create-result`、现有认证与限频及服务端账号/会话锁。查询以当前账号与原 idempotency key 查现有唯一索引，成功响应只含命令状态且禁共享缓存和存储，没有活动明细、邀请凭据或账号资料。PHP 检查匿名、伪造 actor、不同账号同键、拒绝、已处理、键冲突和行数不变。原写入事务和唯一键继续处理读后写之间的竞争。Q 无产品 schema 或迁移定义变更。证据覆盖页面未退出时的同会话草稿及原命令，进程被杀后的搭子草稿恢复和数据库并发仍 NOT_RUN。[BuddyService](../../../../services/backend-laravel/app/Services/BuddyService.php) · [BuddyPage](../../../../apps/flutter_elitesync_module/lib/features/buddy_v1013/buddy_page.dart) · [定向 Widget](../../../../apps/flutter_elitesync_module/test/features/buddy_v1013/v1019_buddy_pages_test.dart)

| PHP 分诊项 | Q 结果 |
|---|---|
| 账号改密 3 个旧 401 | 测试改用同进程真实 `DeviceSessions` 测试凭据，正向修改与重新登录、错误密码和截断哈希的拒绝与不写入得到验证。另保留注销旧设备令牌的测试。生产凭据门禁保持既有规则。 |
| V1015 消息通知 5 个计数失败 | 按发消息前的总行数为基线，分别验证一次消息通知、接收人、撤下连接自身的一次合法事件及 Block、离开和重放的副作用。保留行数总量与历史密文断言，旧夹具的连接/许可通知计入基线。 |
| 会话列表断言缺表、匹配迁移回滚断言缺索引 | 会话列表回归使用完整 SQLite schema，原拒绝/无效 peer 断言保留。匹配回滚按依赖顺序包含后来的运行对索引迁移，确认旧行存续和重新迁移还原当前唯一索引。真实迁移、锁及回滚仍待验证。 |
| 旧匹配 `404 → 200` | 旧路径返回当前提案投影。追加正反隔离断言，孤立旧匹配无投影，绑定提案失权后仅历史过程事实，摘要、解释和确认动作关闭。原历史状态码断言仍 FAIL。 |
| 注册生成可信 T0 | **待决安全合同冲突**。v10.1.5 B4 要求注册不产生离线 T0。诊断候选 94eadd41 让旧测试通过，却使后来 v10.1.15 B1 的设备绑定注册回执具名用例失败。 v10.1.15 Owner 限定接受了包括在线核验恢复的注册欢迎链。交付保留 D 行为。Q 的 T0 专项原样复跑仍有旧失败，诊断候选具名套件的 1 条新失败单独留存。需 Owner 确认是否分开注册的在线恢复与可信离线缓存，再单独验证入口、重启、失权和 15/30 天边界。 |

已具名回归内未发现新增的内容越权或私有正文泄露。注册 T0 冲突涉及私有离线保留，仍列为 P1 风险待 Owner 决定。全量里其余 Match、RTC、内容/媒体及通知旧失败见附录，真实授权情况未核条目均保持 UNKNOWN 或 NOT_RUN。当前仍存在旧客户端自动排盘入口受限，部分历史核心链用例受门禁、基础设施或旧预期阻塞。[v10.1.5 B4](../../v10.1.5/task_order.md) · [v10.1.15 Owner 接受](../../v10.1.15/OWNER_ACCEPTANCE_20261115.md)

## Q3｜实际隔离测试、跨层回归与证据

PHP 为 Windows CLI 8.5.3、PHPUnit 12.5.42、Laravel 13.39.0，启用 GD。核对 Composer 114 个已装依赖的版本和源码引用，锁文件差异 0。使用由固定 Git 内容生成的私有归档与本机相同依赖副本。测试显式设置 `APP_ENV=testing`、`APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、空 `DB_URL`、array cache/session，归档副本无 `.env` 或 Laravel 配置缓存。Flutter 3.41.7 / Dart 3.11.5，现有依赖、`--no-pub`、隔离 Widget 与假传输。Flutter 运行于 `f2d979666232c04621d6a23058bd914fda2ae749`，Git diff 验证到 Q 固定源码的整个 Flutter 目录字节一致。

| 实际验证 | 结果 |
|---|---|
| PHP A–D 具名 + Q 登录改密相邻链、会话列表、消息通知 | PASS，190 项 / 2,402 断言，exit 0 |
| PHP 改密正反例 | PASS，4 项 / 20 断言，exit 0 |
| PHP 旧匹配迁移按依赖回滚 | PASS，1 项 / 9 断言，exit 0 |
| PHP 可信登录与注册专项 | FAIL，9 项 / 40 断言，1 failure，exit 1。注册 T0 合同冲突。 |
| Flutter A–D 具名 + Q 认证存储与离线策略 | PASS，396 项，exit 0 |
| Flutter Buddy/Status 原扩围 | PASS，77 项，exit 0。原 65 项、修复的两项 Widget、恢复编译的文件五项、补充回执五项。 |
| Flutter v1013 实际构建条件 | PASS，5 项，exit 0 |
| Flutter v1017 实际构建条件 | PASS，31 项，exit 0 |
| Dart 分析 | PASS，26 文件，0 问题，exit 0 |
| Flutter 全仓、PHP 8.4、MariaDB | NOT_RUN。Composer 声明 `~8.4.0`。本机常用工具路径只有可见 PHP 8.3/8.5，未确认 PHP 8.4 及可用的独立 MariaDB 实例。 |

A–D 回归包括 A1 正式参与和真实身份拒绝、A2 固定候选与 Block、A3 UNKNOWN 原编号重读，A4/B 的评论原受众和私有媒体字节，B 的双域/列表/深链，C 的用途撤销、来源更正、未知旧数据及 `REQUEST_CHANNEL_UNAVAILABLE`，D 的最小通知/待办投影、失权、提案幂等状态及分离的匹配、连接、消息同意、会话和正式关系。Flutter 覆盖切号/迟到、2× 文字、返回、减少动效与独立手填可达性。MariaDB JSON 索引、锁序、多连接并发和真实回滚，设备跨端失权及外部供应商维持 NOT_RUN。

PHP 命令在隔离 Laravel 根执行，Flutter 命令在模块根执行。原样参数、退出码及日志保存在本地私有证据根 `D:/EliteSync/development/v2-q-evidence-20261120`。

<details>
<summary>完整命令参数</summary>

```text
php -d memory_limit=512M -d extension=gd vendor/phpunit/phpunit/phpunit --colors=never --log-junit <证据根>/q-delivery-full.xml
php -d memory_limit=512M -d extension=gd vendor/phpunit/phpunit/phpunit --colors=never --log-junit <证据根>/q-delivery-named.xml tests/Feature/NotificationApiTest.php tests/Feature/ProfileShowcaseWorkflowTest.php tests/Feature/ShowcaseJourneyAudienceTest.php tests/Feature/StatusPostApiTest.php tests/Feature/V10114StatusVideoTest.php tests/Feature/V10115LifestyleDiscoveryTest.php tests/Feature/V10116UserStateAutomationTest.php tests/Feature/V1011DynamicChartApiTest.php tests/Feature/V1011NoticeRevocationTest.php tests/Feature/V1012JourneyTest.php tests/Feature/V1013BuddyCommunityTest.php tests/Feature/V1017MatchingJourneyTest.php tests/Feature/V1019BuddyDiscoveryTest.php tests/Feature/V1019SocialCommunityTest.php tests/Feature/V2CandidateSnapshotTest.php tests/Feature/V2CommentAudienceTest.php tests/Feature/V2PhaseASecurityTest.php tests/Feature/V2PhaseBContentTest.php tests/Feature/V2PhaseCDataRightsTest.php tests/Feature/V1010NatalApiTest.php tests/Unit/ConversationListPeerFilterTest.php tests/Feature/V1015MessagingTest.php tests/Feature/V10111AccountSupportTest.php
php -d memory_limit=512M -d extension=gd vendor/phpunit/phpunit/phpunit --colors=never --log-junit <证据根>/q-delivery-rollback.xml --filter test_latest_additive_migrations_roll_back_without_deleting_legacy_matches tests/Feature/MatchingFoundationServiceTest.php
php -d memory_limit=512M -d extension=gd vendor/phpunit/phpunit/phpunit --colors=never --log-junit <证据根>/q-delivery-password.xml --filter test_change_password tests/Feature/AuthPasswordApiTest.php
php -d memory_limit=512M -d extension=gd vendor/phpunit/phpunit/phpunit --colors=never --log-junit <证据根>/q-delivery-retention.xml tests/Feature/V1015TrustedLoginTest.php
flutter test --no-pub --concurrency=1 --reporter expanded test/features/lifestyle_discovery test/features/slow_dating_v1012 test/features/profile/presentation/providers/profile_showcase_draft_provider_test.dart test/core/network/retry_session_guard_test.dart test/core/network/api_transport_replay_test.dart test/core/network/v1015_late_response_test.dart test/core/storage/private_cache_service_test.dart test/core/media/media_url_resolver_test.dart test/features/chat/presentation/conversation_detail_live_test.dart test/features/chat/presentation/pages/live_conversation_private_cache_test.dart test/features/chat/presentation/pages/live_chat_retained_list_cache_test.dart test/features/status test/features/home test/features/buddy_v1013/buddy_pages_test.dart test/features/profile/phase_c_data_rights_page_test.dart test/features/profile/dynamic_chart_page_test.dart test/features/profile/v10110_tool_history_test.dart test/features/notification test/features/user_automation/b3_journey_overview_test.dart test/features/connection/live_connection_page_test.dart test/features/profile/presentation/pages/astro_profile_page_test.dart test/features/profile/natal_restoration_session_guard_test.dart test/features/auth/data/datasource/auth_local_data_source_test.dart test/features/chat/domain/offline_private_retention_policy_test.dart
flutter test --no-pub --concurrency=1 --reporter expanded test/features/buddy_v1013 test/features/status
flutter test --no-pub --concurrency=1 --reporter expanded --dart-define=ELITESYNC_V1013_LOCAL_BUILD=true test/features/buddy_v1013/v1013_root_entry_test.dart
flutter test --no-pub --concurrency=1 --reporter expanded --dart-define=ELITESYNC_V1017_LOCAL_BUILD=true test/features/lifestyle_discovery test/features/user_automation/b3_journey_overview_test.dart
flutter analyze --no-pub lib/app/router/app_router.dart lib/design_system/components/layout/section_reveal.dart lib/features/journey_integration/journey_overview_page.dart lib/features/lifestyle_discovery/lifestyle_controller.dart lib/features/lifestyle_discovery/lifestyle_page.dart lib/features/notification/data/datasource/notification_remote_data_source.dart lib/features/notification/domain/entities/notification_item_entity.dart lib/features/notification/presentation/pages/notification_center_page.dart lib/features/notification/presentation/providers/notification_provider.dart lib/features/profile/presentation/pages/astro_overview_page.dart lib/features/profile/presentation/pages/astro_profile_page.dart lib/features/profile/presentation/providers/astro_profile_provider.dart lib/features/profile/presentation/widgets/astro_profile_state.dart lib/features/relationships_v1011/session_bound_page.dart lib/features/slow_dating_v1012/journey_components.dart lib/features/slow_dating_v1012/slow_dating_journey_page.dart test/features/lifestyle_discovery/lifestyle_controller_test.dart test/features/lifestyle_discovery/lifestyle_page_test.dart test/features/notification/presentation/pages/notification_center_page_test.dart test/features/profile/presentation/pages/astro_profile_page_test.dart test/features/slow_dating_v1012/journey_pages_test.dart test/features/slow_dating_v1012/r1_journey_gates_test.dart lib/features/buddy_v1013/buddy_discovery_page.dart lib/features/buddy_v1013/buddy_page.dart test/features/buddy_v1013/v1013_root_entry_test.dart test/features/buddy_v1013/v1019_buddy_pages_test.dart
```

</details>

### 证据 SHA256

| 本地文件 | SHA256 |
|---|---|
| `v2-phase-b-evidence-20261120/php-delivery-full.xml` | `ce5f18535a588982d4fc74ffefe9b9e05218852394424026f2362206954aafdb` |
| `v2-phase-c-evidence-20261120/c-verified-full.xml` | `1c84cc26f381473505f8a60aed0888720fabd1f7cfdb42efd4204ce3879c52e6` |
| `v2-phase-d-evidence-20261120/d-full.xml` | `81946f2adc849539810028fc7b2208232ece2d4e65b141fc3de60caa72f0930d` |
| `v2-phase-d-evidence-20261120/d-full.log` | `a71173fcfcb2dd7cd3757263e44e41abc7da0a2be8175d949c09c2f85fee9ee1` |
| `v2-phase-d-evidence-20261120/d-flutter-expanded.log` | `4c43907da4e9c2e6fa060c20e50170adfb3ea62e810951c74a6b0b0c1bc67ab0` |
| `v2-q-evidence-20261120/d-supported-source.tar` | `978cc45fcdb6ed0ef17c4f8b7c531b8f14e719bb194d4e8dd074d7d099e1cbee` |
| `v2-q-evidence-20261120/d-supported-full.xml` | `e558c98921f437863af48522defb277863f3ae6cc508503438d13f7617994ad2` |
| `v2-q-evidence-20261120/d-supported-full.log` | `d92592c15803a87d054dc44edbc0d013bfebe3926d4517b518a4ca43d1957da6` |
| `v2-q-evidence-20261120/q-final-full.xml` | `b4de95ac9030403cbba688f825132590751107c1d126f6c0b2eb8cf166f74805` |
| `v2-q-evidence-20261120/q-final-named.xml` | `f21580261e210f097ccf4682dcd5331e9fc15a5ea712e82c176446db66343409` |
| `v2-q-evidence-20261120/q-final-php-exits.txt` | `dfb5fcb27abae05238f0425dedee3cda903488c37cbeccc3251b63a9e01fbaf1` |
| `v2-q-evidence-20261120/q-delivery-source.tar` | `77f58d3c07f81c61718a1b00618770e1739d501e1cef879708acbdf8440e4099` |
| `v2-q-evidence-20261120/q-delivery-full.log` | `8aa403755cd47c08dbd5bf4d86505306f692721c2f10fbd97e8775ec8bad1381` |
| `v2-q-evidence-20261120/q-delivery-full.xml` | `9a03ca927ae6a144619259a518168666fe7ef3e8e39efcb3ddb4d66e04e02717` |
| `v2-q-evidence-20261120/q-delivery-named.log` | `cddbdbf8fe0781dd0219d95766c3287aed45c05d971805fa6022d2c9253a7ea4` |
| `v2-q-evidence-20261120/q-delivery-named.xml` | `d68a541f6a188f38b7942ffd1620fff8d9c19ebb870a07c5650713a6f4c7586b` |
| `v2-q-evidence-20261120/q-delivery-rollback.log` | `c985a26f9f102fc68b2af053f860127d344d2f7f591e96ddb21bb4502e287e40` |
| `v2-q-evidence-20261120/q-delivery-rollback.xml` | `017628242d9906ff9c3b9baf1a820483ded75ab6cc93a144bdfea777b273bcdf` |
| `v2-q-evidence-20261120/q-delivery-password.log` | `702058344b6ca3d28a472dbf61d35435bf3d44a5239c7ff6262b1e8da5701468` |
| `v2-q-evidence-20261120/q-delivery-password.xml` | `566e1a0a186f9b603d61a5b7945c9c140cec44563dc3750b7cfb9eb089df516e` |
| `v2-q-evidence-20261120/q-delivery-retention.log` | `dcb911654c25278b69553672ed2abf4e861d553fe002c6d2be4f830257f144bb` |
| `v2-q-evidence-20261120/q-delivery-retention.xml` | `2e1f62a6018e543fbed065845a813e57578b3dc8ab35dd64e8f50df7d94c4dd9` |
| `v2-q-evidence-20261120/q-delivery-php-commands.txt` | `f11dddf9e407d8550b4882a7ca2ae5673ca3a85ecc3a945fc0a837772510cdfb` |
| `v2-q-evidence-20261120/q-delivery-php-exits.txt` | `005ba6a690e2e5ede5c09298d484e0944d2e3eee6b164868821769ec104deec2` |
| `v2-q-evidence-20261120/q-flutter-version.log` | `b9a8d409e38c6d7bf3c15bbb784bb044cef8374b17bfc4cc53aadf15962d67f5` |
| `v2-q-evidence-20261120/q-flutter-named.log` | `33581b3b473cdd05dd33a288f450327f1bbab95f5974eea3e992ad34a3dce383` |
| `v2-q-evidence-20261120/q-flutter-expanded.log` | `6abaae3da041340a6edcfab438b7e6f2fb66adb9fc6bd2affe4cd4f5b688f025` |
| `v2-q-evidence-20261120/q-flutter-v1013.log` | `acf3807e6d77f291b631986d6c42573af2b672a69f95717475dd69f60be203a4` |
| `v2-q-evidence-20261120/q-flutter-v1017.log` | `d5654abd8baa7f8ad5ce55b67e6c1866b2841372b4b01e3d67ba804536b3e286` |
| `v2-q-evidence-20261120/q-dart.log` | `07ad3a33e071fe3de525f1e38cc466d14641f7c01e7d2649140006a9174b8522` |
| `v2-q-evidence-20261120/q-flutter-commands.txt` | `e78fc6eb61ba6acc49d2d3caa2762f98d75fca8d08b7ffa4c707eed6b6277283` |
| `v2-q-evidence-20261120/q-flutter-exits.txt` | `9248a40a30ed4c42509ee95c34d76075c4e0773a9547dadadfd2ab9b07724619` |

## Q4｜候选与生产前置

| 层 | 判定 | 依据与剩余 |
|---|---|---|
| 具名内部软件合同 | **SCOPED_PASS** | A–D 具名隔离与 Q 重点回归通过。单独回执 T0 冲突、旧排盘和 PHP 全量仍 FAIL。 |
| 扩大内部候选及真实设备评估 | **PARTIAL / NOT_RUN** | 仅具名软件证据和部分 Widget 可用。全量 PHP、PHP 8.4、MariaDB、真机/模拟器、真实跨端及辅助技术均按下列状态保留。 |
| 对外测试、生产及正式发布 | **NO_GO** | 真实 KYC/Push/RTC、生产部署/迁移、真实设备、素材授权、个人资料法域与删除实际受理缺证或未授权。需 Owner、具名业务/法务责任人及经授权的环境验证。 |

| 场景 | 当前状态 |
|---|---|
| S01 首页与冷启动 | PARTIAL，具名首页与频道验证。真实冷启动 NOT_RUN。 |
| S02 匹配首屏 | PARTIAL，提案当前资格及独立会话读权回归。 |
| S03 每周慢约 | PARTIAL，准备、参与、拒绝、过期和同键回执。 |
| S04 匹配历史 | PARTIAL，固定候选、旧入口最小投影与失权关闭。 |
| S05 我的首屏 | NOT_RUN，整屏未跑。 |
| S06 持续参与和自动化 | PARTIAL，具名保存、拒绝及进展入口。 |
| S07 权限与说明 | NOT_RUN，整屏未跑。对象请求按 G07。 |
| S08 Lifestyle 完成摘要 | PARTIAL，场景、完成、重入与摘要。 |
| S09 Lifestyle 改选题页 | PARTIAL，2× 文字、语义、返回和减少动效。 |
| S10 会话列表 | PARTIAL，当前资格与旧列表缓存。 |
| S11 会话详情 | PARTIAL，缓存隔离、失权和迟到。真实双端 NOT_RUN。 |
| S12 站内通知 | PARTIAL，当前、待办、历史、期限和点击重验。 |
| S13 好友社区 | PARTIAL，Block、历史评论原受众、通知与媒体。 |
| S14 社区发布 | PARTIAL，默认受众、扩大确认与失权。 |
| S15 Buddy 主页与管理 | PARTIAL，创建待核、同键重读及旧构建 Widget PASS，设备未运行。 |
| S16 Buddy 发现与筛选 | PARTIAL，分页 403 清旧内容、摘要提示及迟到保护 PASS，设备未运行。 |

| 门 | 当前状态与外部责任 |
|---|---|
| G01 身份与参与 | PARTIAL，签名 TEST_ONLY 和正式拒绝。授权真实 KYC 待 Owner 及供应商证据。 |
| G02 首页与作品 | PARTIAL，具名双域及媒体权限。`public_editorial=[]`，正式访客正文授权 UNKNOWN，待 Owner 与内容权利方。 |
| G03 评论 | PARTIAL，原受众、隐藏/撤回及引用拒绝。真实迁移与跨端 NOT_RUN。 |
| G04 用途 | PARTIAL，具名独立用途、期满与撤销。真实合法依据由授权法务确认，UNKNOWN。 |
| G05 纠错 | PARTIAL，隔离重审与来源重验。历史权属和外部核验 UNKNOWN。 |
| G06 匹配快照 | PARTIAL，原候选及失权。真实跨端传播 NOT_RUN。 |
| G07 对象级删除 | PARTIAL，测试对象权限与拒绝合同。真实 `REQUEST_CHANNEL_UNAVAILABLE`，受理方、法域、备份和附件范围 UNKNOWN。 |
| G08 跨通道 | PARTIAL，切号、迟到、失权、旧通知、Block。跨设备时效 NOT_RUN。 |
| G09 关系与通知 | PARTIAL，隔离独立关系片段及最小站内投影。真实 KYC/Push/RTC、设备 NOT_RUN。 |
| G10 可达性与发布 | PARTIAL，具名大字、语义、返回、减少动效。设备辅助技术、原图回读、正式 A6、发布 NOT_RUN。 |

原 `10.1.18-dev / 1011804`、`UI-AUDIT-01` 的 FAIL、UNKNOWN、NOT_RUN 保留。`F-01 READABILITY_PARTIAL`，原 43 PNG 保留 `PENDING_BINARY_UPLOAD`。原 PNG 二进制 SHA 和正式素材权利仍需资产持有人提供，设备/A6 证据须 Owner 单独授权后核验。真实供应商、生产数据、公开测试、main 合并及正式发布均保持未执行。[历史清单](../../../workflow/ui-current-state-audit-20261116/SCREENSHOT_MANIFEST.json)

本轮在 Owner 集中验收节点停止。集中验收时有两项明确决策，旧排盘 A/B/C，以及注册在线恢复与可信离线回执的合同。工程交付保持 `PARTIAL / PRODUCTION_NO_GO`。

## 附录 A｜历史 D 逐例失败账

每行按完整类、方法和 D 错误/断言定位。状态按 JUnit 用例核对。“D 辅助”是同一 D 源码在完整隔离归档中的结果，Q 列是交付源码实测。保留 ERROR 与 FAIL 分别表示 JUnit error 与 failure。签名省略请求资料、SQL、绝对路径和日志正文。若 Q 签名与 D 不同，Q 列会附新锚点。“待核”表示只有失败位置和风险入口证据，具体根因或真实影响仍 UNKNOWN。

### C 新增 25 条 · B 未失败 · D 继承

全组仍是 `CONTRACT_CONFLICT_PENDING_OWNER`。所列 API 路径省略 `/api/v1`，共同替代入口、来源权限及真实影响按 Q1。

| 序号与起源 | 测试类与方法 | 历史 D 类型与签名 | 合同或分诊依据 | D 辅助 | Q |
|---|---|---|---|---|---|
| 001 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_astro_chart_cache_recomputes_when_birth_input_signature_changes` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L939 | 首个 POST /profile/astro 已因用途 409，后续再次 POST /profile/astro，出生输入变更后重算的旧断言未达。 | FAIL | FAIL |
| 002 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_astro_chart_cache_recomputes_when_house_system_policy_changes_to_placidus` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L814 | 首个 POST /profile/astro 已因用途 409，后续GET /profile/astro/chart，宫位策略改变后旧缓存重算的旧断言未达。 | FAIL | FAIL |
| 003 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_astro_chart_cache_rejects_legacy_not_house_truth_cache_even_with_matching_signature` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L871 | 首个 POST /profile/astro 已因用途 409，后续GET /profile/astro/chart，同签名旧缓存的宫位真值校验的旧断言未达。 | FAIL | FAIL |
| 004 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_astro_chart_cache_reuses_matching_western_natal_signature` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L770 | 首个 POST /profile/astro 已因用途 409，后续GET /profile/astro/chart，旧西盘缓存复用的旧断言未达。 | FAIL | FAIL |
| 005 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_astro_chart_endpoint_returns_chart_data_payload` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L732 | 首个 POST /profile/astro 已因用途 409，后续GET /profile/astro/chart，旧画图 payload的旧断言未达。 | FAIL | FAIL |
| 006 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_astro_chart_old_cache_without_signature_forces_recompute` | FAIL · ExpectationFailedException · 断言字符串应不同 @ L996 | GET /profile/astro/chart。旧缓存缺签名也不触发重算。 | FAIL | FAIL |
| 007 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_astro_chart_python_fallback_does_not_claim_house_truth` | FAIL · ExpectationFailedException · 实际 null 与期望不符 @ L1031 | GET /profile/astro/chart。旧 Python 降级精度标志依赖原投影，当前未取旧缓存。 | FAIL | FAIL |
| 008 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_astro_save_changes_bazi_ziwei_and_western_when_birth_place_changes` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L536 | 首个 POST /profile/astro 已因用途 409，后续再次 POST /profile/astro，地点变更触发三盘重算的旧断言未达。 | FAIL | FAIL |
| 009 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_astro_save_falls_back_when_user_birthday_missing` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L600 | POST /profile/astro。旧自动求值或事实缺失兜底遇具名用途 409。 | FAIL | FAIL |
| 010 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_astro_save_uses_server_canonical_engine_without_client_sun_sign` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L361 | POST /profile/astro。旧自动求值或事实缺失兜底遇具名用途 409。 | FAIL | FAIL |
| 011 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_astro_summary_endpoint_returns_profile_without_svg_payload` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L630 | 首个 POST /profile/astro 已因用途 409，后续GET /profile/astro/summary，旧无 SVG 摘要的旧断言未达。 | FAIL | FAIL |
| 012 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_astro_summary_prefers_current_natal_chart_signs_over_stale_legacy_summary` | FAIL · ExpectationFailedException · 实际 null 与期望不符 @ L694 | GET /profile/astro/chart、/summary。当前只镜像独立本命，缺期望星座值，旧精度兼容留待决策。 | FAIL | FAIL |
| 013 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_bazi_hidden_stems_contract_uses_lunar_php_canonical_source` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L409 | 首个 POST /profile/astro 已因用途 409，后续GET /profile/astro/summary，旧藏干的摘要读取的旧断言未达。 | FAIL | FAIL |
| 014 C | `Tests\Feature\AstroCanonicalApiTest`<br>`test_cece_p0_ziwei_payload_is_preserved_by_profile_astro_api` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L465 | 首个 POST /profile/astro 已因用途 409，后续GET /profile/astro/summary，旧紫微投影的旧断言未达。 | FAIL | FAIL |
| 015 C | `Tests\Feature\AuthPasswordApiTest`<br>`test_login_prefers_profile_birth_place_when_private_value_is_blank` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L77 | GET /profile/basic、POST /auth/login。旧出生地回填与账号来源隔离冲突。 | FAIL | FAIL · ExpectationFailedException · 断言字符串应相同 @ L78 |
| 016 C | `Tests\Feature\ProfileBasicRecomputeTest`<br>`test_save_basic_bootstraps_astro_profile_when_missing` | FAIL · ExpectationFailedException · 实际 null 与期望不符 @ L161 | POST /profile/basic。旧预期为无旧盘时自动建盘，当前保存账号事实，独立工具按其用途处理。 | FAIL | FAIL |
| 017 C | `Tests\Feature\ProfileBasicRecomputeTest`<br>`test_save_basic_changes_astro_when_birth_place_changes_with_same_birth_time` | FAIL · ExpectationFailedException · 实际 null 与期望不符 @ L229 | POST /profile/basic。旧预期为出生时刻不变仍触发地点联算，当前保存账号事实，独立工具按其用途处理。 | FAIL | FAIL |
| 018 C | `Tests\Feature\ProfileBasicRecomputeTest`<br>`test_save_basic_invalidates_stale_western_natal_chart_cache_before_detail_recompute` | FAIL · ExpectationFailedException · 实际 null 与期望不符 @ L323 | POST /profile/basic。旧预期为账号保存促使旧缓存作废并在详情重算，当前保存账号事实，独立工具按其用途处理。 | FAIL | FAIL |
| 019 C | `Tests\Feature\ProfileBasicRecomputeTest`<br>`test_save_basic_marks_western_natal_render_failure_without_fake_chart_cache` | FAIL · ExpectationFailedException · 断言数组应为空 @ L443 | POST /profile/basic。旧预期为账号保存触发渲染并记录失败，当前保存账号事实，独立工具按其用途处理。 | FAIL | FAIL |
| 020 C | `Tests\Feature\ProfileBasicRecomputeTest`<br>`test_save_basic_recomputes_existing_astro_profile_with_new_birth_place` | FAIL · ExpectationFailedException · 实际 null 与期望不符 @ L101 | POST /profile/basic。旧预期为更正地点后联算旧盘，当前保存账号事实，独立工具按其用途处理。 | FAIL | FAIL |
| 021 C | `Tests\Feature\V1007BaziProvenanceTest`<br>`test_client_cannot_supply_derived_bazi_or_provenance_notes` | FAIL · ExpectationFailedException · 期望 HTTP 422 / 实际 409 @ L78 | POST /profile/astro。旧派生字段校验预期 422，当前用途前置拒绝且不写入。 | FAIL | FAIL |
| 022 C | `Tests\Feature\V1007BaziProvenanceTest`<br>`test_invalid_time_or_unsupported_timezone_rejects_before_user_or_profile_write` | FAIL · ExpectationFailedException · 期望 HTTP 422 / 实际 409 @ L69 | POST /profile/basic、/profile/astro。旧自动入口先作权限拒绝，旧参数 422 断言保留。 | FAIL | FAIL |
| 023 C | `Tests\Feature\V1007BaziProvenanceTest`<br>`test_missing_birth_time_is_explicit_default_noon_with_low_confidence` | ERROR · ModelNotFoundException · 模型记录缺失 @ L53 | POST /profile/basic。旧预期默认正午创建或更新八字行，当前不假定缺失时刻且不联算。 | ERROR | ERROR |
| 024 C | `Tests\Feature\V1007BaziProvenanceTest`<br>`test_real_local_lunar_engine_produces_known_four_pillars_without_coordinates` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L42 | POST /profile/astro。原四柱计算请求先被用途门拒绝，真实算法证据未补。 | FAIL | FAIL |
| 025 C | `Tests\Feature\V1007BaziProvenanceTest`<br>`test_repeated_unknown_time_stays_low_confidence_until_explicit_time_replaces_provenance` | ERROR · ModelNotFoundException · 模型记录缺失 @ L108 | POST /profile/basic。旧预期默认正午创建或更新八字行，当前不假定缺失时刻且不联算。 | ERROR | ERROR |

### B 遗留 189 条 · C/D 继承

| 序号与起源 | 测试类与方法 | 历史 D 类型与签名 | 合同或分诊依据 | D 辅助 | Q |
|---|---|---|---|---|---|
| 026 B | `Tests\Feature\AdminApiTest`<br>`test_prune_low_drop_questions_supports_dry_run_and_apply` | ERROR · RuntimeException · 缺题库 JSON @ L234 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 027 B | `Tests\Feature\AdminApiTest`<br>`test_question_quality_stats_endpoint_returns_reason_breakdown` | ERROR · RuntimeException · 缺题库 JSON @ L202 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 028 B | `Tests\Feature\AdminMatchingOperationalTruthLoopIntegratedSmokeTest`<br>`test_disposable_admin_operation_truth_recovery_and_audit_loop` | FAIL · ExpectationFailedException · 期望 HTTP 202 / 实际 500 @ L45 | 数据完整性 · 匹配执行失败，执行器细因待核 | FAIL | FAIL |
| 029 B | `Tests\Feature\Api\V2\TransportEnvelopeTest`<br>`test_v1_source_slice_and_non_authority_boundaries_remain_unchanged` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L306 | 用户入口/普通兼容 · 就绪状态或接口格式，细因待核 | FAIL | FAIL |
| 030 B | `Tests\Feature\AuthPasswordApiTest`<br>`test_change_password_rejects_truncated_synthetic_hash_without_rewriting_it` | FAIL · ExpectationFailedException · 期望 HTTP 422 / 实际 401 @ L265 | 权限 · 改密夹具使用实际设备凭据 | FAIL | PASS |
| 031 B | `Tests\Feature\AuthPasswordApiTest`<br>`test_change_password_rejects_wrong_current_password` | FAIL · ExpectationFailedException · 期望 HTTP 422 / 实际 401 @ L244 | 权限 · 改密夹具使用实际设备凭据 | FAIL | PASS |
| 032 B | `Tests\Feature\AuthPasswordApiTest`<br>`test_change_password_success_and_login_with_new_password` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 401 @ L34 | 权限 · 改密夹具使用实际设备凭据 | FAIL | PASS |
| 033 B | `Tests\Feature\AuthQuestionnaireApiTest`<br>`test_register_login_questionnaire_flow` | ERROR · RuntimeException · 缺题库 JSON @ L17 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 034 B | `Tests\Feature\AuthQuestionnaireApiTest`<br>`test_submit_answers_accepts_v2_payload_fields` | ERROR · RuntimeException · 缺题库 JSON @ L128 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 035 B | `Tests\Feature\C2LocalRuntimeIntegrationTest`<br>`test_admin_request_replay_stale_retry_reveal_and_close_contract` | FAIL · ExpectationFailedException · 期望 HTTP 202 / 实际 500 @ L122 | 数据完整性 · 匹配执行失败，执行器细因待核 | FAIL | FAIL |
| 036 B | `Tests\Feature\C2LocalRuntimeIntegrationTest`<br>`test_non_admin_is_denied_and_compensation_stays_unavailable` | FAIL · ExpectationFailedException · 期望 HTTP 403 / 实际 409 @ L183 | 数据完整性/权限 · 匹配前置、执行或回滚差异，细因待核 | FAIL | FAIL |
| 037 B | `Tests\Feature\C2LocalRuntimeIntegrationTest`<br>`test_real_api_returns_every_guarded_synthetic_scenario` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L48 | 数据完整性/权限 · 匹配前置、执行或回滚差异，细因待核 | FAIL | FAIL |
| 038 B | `Tests\Feature\CleanupCalibrationInjectedCommandTest`<br>`test_cleanup_command_removes_marked_rows` | ERROR · RuntimeException · 缺题库 JSON @ L19 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 039 B | `Tests\Feature\DomainSkeletonApiTest`<br>`test_conversation_and_media_skeleton_routes_are_available` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L70 | 用户入口/普通兼容 · 就绪状态或接口格式，细因待核 | FAIL | FAIL |
| 040 B | `Tests\Feature\EvalAstroV2CommandTest`<br>`test_eval_astro_v2_report_contains_outcome_sections` | ERROR · RuntimeException · 缺题库 JSON @ L19 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 041 B | `Tests\Feature\ExampleTest`<br>`test_the_application_returns_a_successful_response` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L17 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 042 B | `Tests\Feature\ExportMatchCalibrationDatasetCommandTest`<br>`test_export_match_calibration_dataset_generates_json_and_csv` | ERROR · RuntimeException · 缺题库 JSON @ L19 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 043 B | `Tests\Feature\InjectCalibrationPositivesCommandTest`<br>`test_inject_command_writes_positive_signals` | ERROR · RuntimeException · 缺题库 JSON @ L19 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 044 B | `Tests\Feature\MatchApiTest`<br>`test_current_match_and_confirm_mutual_flow` | ERROR · RuntimeException · 缺题库 JSON @ L43 | 用户入口/旧合同 · 候选或旧匹配形态差异，逐例待核 | FAIL | FAIL · ExpectationFailedException · 实际 null 与期望不符 @ L77 |
| 045 B | `Tests\Feature\MatchApiTest`<br>`test_current_match_returns_404_when_no_match_after_questionnaire_complete` | ERROR · RuntimeException · 缺题库 JSON @ L136 | 权限/旧合同 · 当前提案信封与旧状态码之差，隔离内容检查见 Q2 | FAIL | FAIL · ExpectationFailedException · 期望 HTTP 404 / 实际 200 @ L150 |
| 046 B | `Tests\Feature\MatchApiTest`<br>`test_current_match_returns_404_when_questionnaire_incomplete` | ERROR · RuntimeException · 缺题库 JSON @ L120 | 权限/旧合同 · 当前提案信封与旧状态码之差，隔离内容检查见 Q2 | FAIL | FAIL · ExpectationFailedException · 期望 HTTP 404 / 实际 200 @ L130 |
| 047 B | `Tests\Feature\MatchApiTest`<br>`test_explanation_by_target_returns_404_when_not_matched` | ERROR · RuntimeException · 缺题库 JSON @ L258 | 用户入口/旧合同 · 候选或旧匹配形态差异，逐例待核 | FAIL | FAIL · ExpectationFailedException · 实际 null 与期望不符 @ L273 |
| 048 B | `Tests\Feature\MatchApiTest`<br>`test_explanation_by_target_returns_latest_match_payload` | ERROR · RuntimeException · 缺题库 JSON @ L156 | 用户入口/旧合同 · 候选或旧匹配形态差异，逐例待核 | FAIL | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 404 @ L220 |
| 049 B | `Tests\Feature\MatchApiTest`<br>`test_explanation_by_target_sorts_module_explanations_by_priority_desc` | ERROR · RuntimeException · 缺题库 JSON @ L278 | 用户入口/旧合同 · 候选或旧匹配形态差异，逐例待核 | FAIL | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 404 @ L338 |
| 050 B | `Tests\Feature\MatchPayloadContractTest`<br>`test_current_match_payload_contains_all_module_contracts_from_matching_engine` | ERROR · RuntimeException · 缺题库 JSON @ L156 | 用户入口/权限 · 旧关系或匹配读写合同，细因待核 | FAIL | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 403 @ L239 |
| 051 B | `Tests\Feature\MatchPayloadContractTest`<br>`test_current_match_payload_contains_contract_fields_and_module_algo_version` | ERROR · RuntimeException · 缺题库 JSON @ L44 | 用户入口/权限 · 旧关系或匹配读写合同，细因待核 | FAIL | FAIL · ExpectationFailedException · 数组断言不符 @ L101 |
| 052 B | `Tests\Feature\MatchRoundApiFoundationTest`<br>`test_current_round_canonical_state_and_field_matrix_is_server_owned_and_read_only` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L133 | 用户入口/普通兼容 · 就绪状态或接口格式，细因待核 | FAIL | FAIL |
| 053 B | `Tests\Feature\MatchingFoundationServiceTest`<br>`test_all_unmatched_reveals_no_candidate_then_closes_projection` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L36 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 054 B | `Tests\Feature\MatchingFoundationServiceTest`<br>`test_atomic_pair_failure_leaves_no_matches_or_projections_then_records_failure` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L36 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 055 B | `Tests\Feature\MatchingFoundationServiceTest`<br>`test_input_change_after_freeze_is_rejected` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L36 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 056 B | `Tests\Feature\MatchingFoundationServiceTest`<br>`test_latest_additive_migrations_roll_back_without_deleting_legacy_matches` | ERROR · QueryException · 缺旧轮次-配对唯一索引 @ L59 | 数据完整性 · 回滚夹具补前置索引依赖 | ERROR | PASS |
| 057 B | `Tests\Feature\MatchingFoundationServiceTest`<br>`test_prepare_request_claim_heartbeat_finalize_and_idempotent_replay` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L36 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 058 B | `Tests\Feature\MatchingFoundationServiceTest`<br>`test_reveal_atomically_updates_match_and_user_projections` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L36 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 059 B | `Tests\Feature\MatchingTruthSliceIntegratedSmokeTest`<br>`test_authenticated_truth_chain_and_conversation_gate_are_coherent` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L63 | 数据完整性/权限 · 匹配前置、执行或回滚差异，细因待核 | FAIL | FAIL |
| 060 B | `Tests\Feature\MbtiApiVersioningTest`<br>`test_quiz_and_submit_are_disabled_when_feature_is_off` | ERROR · RuntimeException · 缺题库 JSON @ L17 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 061 B | `Tests\Feature\MediaUploadEndpointTest`<br>`test_media_content_route_streams_public_disk_files` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 401 @ L177 | 权限/用户入口 · 旧媒体链被拒或不可用，细因待核 | FAIL | FAIL |
| 062 B | `Tests\Feature\MediaUploadEndpointTest`<br>`test_missing_ready_media_is_unavailable_without_mutation` | FAIL · ExpectationFailedException · 期望 HTTP 404 / 实际 401 @ L205 | 权限/用户入口 · 旧媒体链被拒或不可用，细因待核 | FAIL | FAIL |
| 063 B | `Tests\Feature\PairOutcomeMetricsCommandTest`<br>`test_pair_outcome_metrics_command_generates_report_with_expected_keys` | ERROR · RuntimeException · 缺题库 JSON @ L19 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 064 B | `Tests\Feature\ProfileAvatarApiTest`<br>`test_jpeg_metadata_is_removed_and_oversized_pixels_are_rejected` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 503 @ L125 | 权限/用户入口 · 旧媒体链被拒或不可用，细因待核 | FAIL | FAIL |
| 065 B | `Tests\Feature\ProfileAvatarApiTest`<br>`test_jpeg_orientation_is_applied_to_pixels_before_metadata_is_removed` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 503 @ L170 | 权限/用户入口 · 旧媒体链被拒或不可用，细因待核 | FAIL | FAIL |
| 066 B | `Tests\Feature\ProfileReadinessIntegratedSmokeTest`<br>`test_disposable_readiness_refresh_publication_separation_and_owner_isolation` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L38 | 用户入口/普通兼容 · 就绪状态或接口格式，细因待核 | FAIL | FAIL |
| 067 B | `Tests\Feature\ProfileReadinessTruthApiTest`<br>`test_profile_basic_exposes_canonical_matching_eligibility_and_missing_action` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L37 | 用户入口/普通兼容 · 就绪状态或接口格式，细因待核 | FAIL | FAIL |
| 068 B | `Tests\Feature\ProfileReadinessTruthApiTest`<br>`test_profile_basic_refreshes_to_eligible_without_publication` | FAIL · ExpectationFailedException · 实际 false 与期望不符 @ L76 | 用户入口/普通兼容 · 就绪状态或接口格式，细因待核 | FAIL | FAIL |
| 069 B | `Tests\Feature\ProfileShowcaseWorkflowTest`<br>`test_admin_role_and_current_allowlist_are_required_for_snapshot_and_photo_review` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L303 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 070 B | `Tests\Feature\ProfileShowcaseWorkflowTest`<br>`test_operating_application_note_and_actual_web_feedback_persist_without_realname_claim` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L322 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 071 B | `Tests\Feature\ProfileShowcaseWorkflowTest`<br>`test_web_feedback_resubmission_publication_replacement_and_withdrawal_preserve_snapshots` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L152 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 072 B | `Tests\Feature\QuestionnaireReadinessActionLoopIntegratedSmokeTest`<br>`test_submission_moves_only_the_owner_from_incomplete_to_fresh_eligible_truth` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L48 | 用户入口/普通兼容 · 就绪状态或接口格式，细因待核 | FAIL | FAIL |
| 073 B | `Tests\Feature\RtcApiTest`<br>`test_busy_call_returns_busy_status_when_pair_has_active_call` | ERROR · NotFoundHttpException · connection unavailable @ L49 | 权限 · 连接前置条件被拒，旧链合同待核 | ERROR | ERROR |
| 074 B | `Tests\Feature\RtcApiTest`<br>`test_create_accept_connect_and_end_voice_call_flow` | ERROR · NotFoundHttpException · connection unavailable @ L49 | 权限 · 连接前置条件被拒，旧链合同待核 | ERROR | ERROR |
| 075 B | `Tests\Feature\RtcApiTest`<br>`test_create_call_ignores_expired_active_call_when_pair_is_no_longer_busy` | ERROR · NotFoundHttpException · connection unavailable @ L49 | 权限 · 连接前置条件被拒，旧链合同待核 | ERROR | ERROR |
| 076 B | `Tests\Feature\RtcApiTest`<br>`test_create_call_ignores_expired_connecting_call_when_pair_is_no_longer_busy` | ERROR · NotFoundHttpException · connection unavailable @ L49 | 权限 · 连接前置条件被拒，旧链合同待核 | ERROR | ERROR |
| 077 B | `Tests\Feature\RtcApiTest`<br>`test_heartbeat_closes_call_when_peer_is_stale` | ERROR · NotFoundHttpException · connection unavailable @ L49 | 权限 · 连接前置条件被拒，旧链合同待核 | ERROR | ERROR |
| 078 B | `Tests\Feature\RtcApiTest`<br>`test_livekit_join_info_rejects_non_participants` | ERROR · NotFoundHttpException · connection unavailable @ L49 | 权限 · 连接前置条件被拒，旧链合同待核 | ERROR | ERROR |
| 079 B | `Tests\Feature\RtcApiTest`<br>`test_livekit_join_info_returns_signed_token_for_participants` | ERROR · NotFoundHttpException · connection unavailable @ L49 | 权限 · 连接前置条件被拒，旧链合同待核 | ERROR | ERROR |
| 080 B | `Tests\Feature\RtcApiTest`<br>`test_reject_call_updates_status_and_notifies_caller` | ERROR · NotFoundHttpException · connection unavailable @ L49 | 权限 · 连接前置条件被拒，旧链合同待核 | ERROR | ERROR |
| 081 B | `Tests\Feature\V1006AdminWebTest`<br>`test_active_refresh_retains_response_contract` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 401 @ L106 | 权限/旧合同 · 旧工具、管理或参与入口，细因待核 | FAIL | FAIL |
| 082 B | `Tests\Feature\V1006AdminWebTest`<br>`test_web_login_search_and_disable_share_the_api_action` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L39 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 083 B | `Tests\Feature\V1007LiveConsentTest`<br>`test_a_second_authorized_peer_cannot_replay_a_revoked_peers_message` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L28 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 084 B | `Tests\Feature\V1007LiveConsentTest`<br>`test_latest_message_window_keeps_new_messages_and_legacy_cursor_order` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L28 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 085 B | `Tests\Feature\V1007LiveConsentTest`<br>`test_legal_send_replay_read_and_revocation_check_current_server_state` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L28 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 086 B | `Tests\Feature\V1007LiveConsentTest`<br>`test_match_alone_and_single_party_do_not_grant_messages` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L28 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 087 B | `Tests\Feature\V1007LiveConsentTest`<br>`test_older_message_pages_are_nearest_chronological_and_exclusive` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L28 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 088 B | `Tests\Feature\V1007LiveConsentTest`<br>`test_unknown_actor_disabled_peer_and_unconfigured_environment_deny` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L28 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 089 B | `Tests\Feature\V1007MatchNotificationTest`<br>`test_first_mutual_like_notifies_both_once_and_guides_independent_consent` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 410 @ L25 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 090 B | `Tests\Feature\V1007MatchProjectionTest`<br>`test_blocked_peer_current_and_history_hide_explanation_in_both_directions` | ERROR · RuntimeException · 缺题库 JSON @ L30 | 权限/旧合同 · 当前提案信封与旧状态码之差，隔离内容检查见 Q2 | FAIL | FAIL · ExpectationFailedException · 期望 HTTP 404 / 实际 200 @ L104 |
| 091 B | `Tests\Feature\V1007MatchProjectionTest`<br>`test_current_recovers_latest_durable_match_outside_weekly_cadence` | ERROR · RuntimeException · 缺题库 JSON @ L30 | 用户入口/旧合同 · 候选或旧匹配形态差异，逐例待核 | FAIL | FAIL · ExpectationFailedException · 实际 null 与期望不符 @ L54 |
| 092 B | `Tests\Feature\V1007MatchProjectionTest`<br>`test_disabled_peer_current_and_history_hide_explanation` | ERROR · RuntimeException · 缺题库 JSON @ L30 | 权限/旧合同 · 当前提案信封与旧状态码之差，隔离内容检查见 Q2 | FAIL | FAIL · ExpectationFailedException · 期望 HTTP 404 / 实际 200 @ L93 |
| 093 B | `Tests\Feature\V1007MatchProjectionTest`<br>`test_history_projects_only_released_matches_in_local_restoration` | ERROR · RuntimeException · 缺题库 JSON @ L30 | 用户入口/旧合同 · 候选或旧匹配形态差异，逐例待核 | FAIL | FAIL · ExpectationFailedException · 实际计数或值为 0 @ L67 |
| 094 B | `Tests\Feature\V1007MatchProjectionTest`<br>`test_local_old_explanation_does_not_grant_unrestored_algorithm_authority` | ERROR · RuntimeException · 缺题库 JSON @ L30 | 用户入口/旧合同 · 候选或旧匹配形态差异，逐例待核 | ERROR | ERROR · TypeError · 数组断言收到 null @ L81 |
| 095 B | `Tests\Feature\V1007MatchingExplanationTest`<br>`test_real_engine_pair_persists_explanation_consistent_with_scoring_exclusions` | ERROR · RuntimeException · 缺题库 JSON @ L43 | 用户入口/权限 · 旧关系或匹配读写合同，细因待核 | FAIL | FAIL · ExpectationFailedException · 断言或异常详见私有 JUnit @ L60 |
| 096 B | `Tests\Feature\V1007PrivateMediaTest`<br>`test_client_alias_or_overwrite_fields_are_rejected_with_and_without_file` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/用户入口 · 旧媒体链被拒或不可用，细因待核 | FAIL | FAIL |
| 097 B | `Tests\Feature\V1007PrivateMediaTest`<br>`test_private_attachment_download_requires_current_participant_consent` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/用户入口 · 旧媒体链被拒或不可用，细因待核 | FAIL | FAIL |
| 098 B | `Tests\Feature\V1007PrivateMediaTest`<br>`test_public_disk_asset_cannot_be_injected_as_live_attachment` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/用户入口 · 旧媒体链被拒或不可用，细因待核 | FAIL | FAIL |
| 099 B | `Tests\Feature\V1007PrivateMediaTest`<br>`test_upload_fails_closed_without_private_disk_configuration` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/用户入口 · 旧媒体链被拒或不可用，细因待核 | FAIL | FAIL |
| 100 B | `Tests\Feature\V1007QuestionnairePersistenceTest`<br>`test_canonical_answer_and_attempt_are_persisted_with_current_identity` | ERROR · RuntimeException · 缺题库 JSON @ L26 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 101 B | `Tests\Feature\V1007QuestionnairePersistenceTest`<br>`test_disabled_research_question_cannot_be_answered` | ERROR · RuntimeException · 缺题库 JSON @ L26 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 102 B | `Tests\Feature\V1007QuestionnairePersistenceTest`<br>`test_draft_persists_and_readback_is_isolated_by_current_account` | ERROR · RuntimeException · 缺题库 JSON @ L26 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 103 B | `Tests\Feature\V1007QuestionnairePersistenceTest`<br>`test_invalid_draft_index_does_not_replace_saved_snapshot` | ERROR · RuntimeException · 缺题库 JSON @ L26 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 104 B | `Tests\Feature\V1007QuestionnairePersistenceTest`<br>`test_invalid_option_rejects_entire_batch_without_answer_or_attempt_writes` | ERROR · RuntimeException · 缺题库 JSON @ L26 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 105 B | `Tests\Feature\V1007QuestionnairePersistenceTest`<br>`test_local_legacy_formats_cannot_bypass_question_bank_guards` | ERROR · RuntimeException · 缺题库 JSON @ L26 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 106 B | `Tests\Feature\V1007QuestionnairePersistenceTest`<br>`test_local_legal_legacy_selected_answer_persists_canonical_bank_identity` | ERROR · RuntimeException · 缺题库 JSON @ L26 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 107 B | `Tests\Feature\V1007QuestionnairePersistenceTest`<br>`test_question_session_order_survives_partial_draft_and_ignores_client_snapshot` | ERROR · RuntimeException · 缺题库 JSON @ L26 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 108 B | `Tests\Feature\V1007QuestionnairePersistenceTest`<br>`test_questions_replace_stale_nonempty_snapshot_and_clear_incompatible_draft` | ERROR · RuntimeException · 缺题库 JSON @ L26 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 109 B | `Tests\Feature\V1007QuestionnairePersistenceTest`<br>`test_seeder_retains_unrelated_history_and_disables_research` | ERROR · RuntimeException · 缺题库 JSON @ L26 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 110 B | `Tests\Feature\V1007QuestionnairePersistenceTest`<br>`test_stale_draft_version_or_bank_does_not_override_current_snapshot` | ERROR · RuntimeException · 缺题库 JSON @ L26 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 111 B | `Tests\Feature\V1007QuestionnairePersistenceTest`<br>`test_stale_question_version_rejects_without_writes` | ERROR · RuntimeException · 缺题库 JSON @ L26 | 基础设施 · 缺题库 JSON | PASS | PASS |
| 112 B | `Tests\Feature\V1007R1NotificationPrivacyTest`<br>`test_blocked_disabled_and_unknown_authority_fail_closed` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L35 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 113 B | `Tests\Feature\V1007R1NotificationPrivacyTest`<br>`test_new_storage_minimizes_private_content_and_legal_navigation_is_derived` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L35 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 114 B | `Tests\Feature\V1007R1NotificationPrivacyTest`<br>`test_revoked_old_notifications_do_not_expose_content_identity_or_navigation` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L35 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 115 B | `Tests\Feature\V1007R1NotificationPrivacyTest`<br>`test_spoofed_legacy_pointer_cannot_borrow_other_receivers_authority` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L35 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 116 B | `Tests\Feature\V1008EligibilityConsentTest`<br>`test_approved_requires_twenty_current_enabled_answers_with_valid_option_identity` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L206 | 权限/旧合同 · 旧工具、管理或参与入口，细因待核 | FAIL | FAIL |
| 117 B | `Tests\Feature\V1008EligibilityConsentTest`<br>`test_pending_and_rejected_are_excluded_despite_twenty_valid_answers` | FAIL · ExpectationFailedException · 实际 false 与期望不符 @ L59 | 权限/旧合同 · 旧工具、管理或参与入口，细因待核 | FAIL | FAIL |
| 118 B | `Tests\Feature\V1008EligibilityConsentTest`<br>`test_question_disable_preserves_history_and_requires_supplement_for_future_matching` | FAIL · ExpectationFailedException · 实际 false 与期望不符 @ L109 | 权限/旧合同 · 旧工具、管理或参与入口，细因待核 | FAIL | FAIL |
| 119 B | `Tests\Feature\V1008EligibilityConsentTest`<br>`test_restrict_retains_history_read_but_restore_requires_new_bilateral_consent_generation` | ERROR · NotFoundHttpException · connection unavailable @ L126 | 权限 · 连接前置条件被拒，旧链合同待核 | ERROR | ERROR |
| 120 B | `Tests\Feature\V1008MatchingConcurrencyTest`<br>`test_finalize_rejects_a_running_run_that_is_no_longer_the_current_attempt` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L210 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 121 B | `Tests\Feature\V1008MatchingConcurrencyTest`<br>`test_finalize_requests_global_then_sorted_users_then_round_and_run_locks` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L210 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 122 B | `Tests\Feature\V1008MatchingConcurrencyTest`<br>`test_question_change_after_finalize_prevents_reveal_when_current_coverage_is_insufficient` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L210 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 123 B | `Tests\Feature\V1008MatchingConcurrencyTest`<br>`test_question_change_committed_after_freeze_prevents_finalize_and_retains_answers` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L210 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 124 B | `Tests\Feature\V1008MatchingConcurrencyTest`<br>`test_restrict_committed_after_finalize_prevents_reveal_without_rewriting_frozen_run` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L210 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 125 B | `Tests\Feature\V1008MatchingConcurrencyTest`<br>`test_reveal_requests_the_same_input_locks_before_publishing` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L210 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 126 B | `Tests\Feature\V1008MatchingConcurrencyTest`<br>`test_review_committed_after_freeze_prevents_finalize_without_partial_matches` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L210 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 127 B | `Tests\Feature\V1008MatchingConcurrencyTest`<br>`test_unmatched_candidate_review_change_blocks_no_candidate_publication_without_half_writes` | ERROR · HttpException · REAL_IDENTITY_PROVIDER_UNAVAILABLE_OR_REVERIFY_REQUIRED @ L210 | 权限 · 旧夹具不满足当前真实身份门禁 | ERROR | ERROR |
| 128 B | `Tests\Feature\V1008MatchingOperationsWebTest`<br>`test_web_prepare_and_execution_replay_show_pending_without_manufacturing_completion` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L87 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 129 B | `Tests\Feature\V1008ReleaseTest`<br>`test_web_create_edit_activate_and_deactivate_are_audited_and_read_by_app` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L40 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 130 B | `Tests\Feature\V1008SanctionAppealTest`<br>`test_note_validation_and_admin_read_is_escaped_minimal_and_audited` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L102 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 131 B | `Tests\Feature\V1008SessionWebTest`<br>`test_demoted_existing_web_session_loses_read_and_write_access` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L131 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 132 B | `Tests\Feature\V1008SessionWebTest`<br>`test_login_and_logout_rotate_session_and_csrf_and_old_csrf_is_rejected` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L106 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 133 B | `Tests\Feature\V1008StatusModerationTest`<br>`test_publish_retains_success_contract_and_rejects_foreign_media_without_partial_write` | FAIL · ExpectationFailedException · 表行断言不符 @ L166 | 内容权限/旧合同 · 旧 public 默认与当前 FRIENDS 合同相异 | FAIL | FAIL |
| 134 B | `Tests\Feature\V1009RtcAuthorityRetryTest`<br>`test_deadlock_budget_exhaustion_does_not_return_a_false_revocation` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 135 B | `Tests\Feature\V1009RtcAuthorityRetryTest`<br>`test_http_deadlock_retries_the_whole_request_before_success` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 136 B | `Tests\Feature\V1009RtcAuthorityRetryTest`<br>`test_http_exhausted_deadlock_returns_generic_503_even_with_debug_enabled` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 137 B | `Tests\Feature\V1009RtcAuthorityRetryTest`<br>`test_http_raw_pdo_begin_failure_returns_generic_503_without_retry` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 138 B | `Tests\Feature\V1009RtcAuthorityRetryTest`<br>`test_http_raw_pdo_error_rolls_back_partial_write_and_returns_generic_503` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 139 B | `Tests\Feature\V1009RtcAuthorityRetryTest`<br>`test_nonconcurrency_error_is_not_retried` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 140 B | `Tests\Feature\V1009RtcAuthorityRetryTest`<br>`test_outermost_authority_check_retries_deadlock_then_reads_current_call` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 141 B | `Tests\Feature\V1009RtcAuthorityTest`<br>`test_accepting_a_still_valid_invitation_grants_a_fresh_connection_deadline` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 142 B | `Tests\Feature\V1009RtcAuthorityTest`<br>`test_an_expired_invitation_cannot_be_accepted_or_revived` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 143 B | `Tests\Feature\V1009RtcAuthorityTest`<br>`test_authority_exception_propagates_with_only_safe_diagnostic_fields` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 144 B | `Tests\Feature\V1009RtcAuthorityTest`<br>`test_database_denial_records_safe_sqlstate_and_driver_code_without_sql` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 145 B | `Tests\Feature\V1009RtcAuthorityTest`<br>`test_expired_busy_attempt_does_not_invalidate_an_active_call` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 146 B | `Tests\Feature\V1009RtcAuthorityTest`<br>`test_independent_accept_and_current_revisions_guard_join_and_reconnect` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 147 B | `Tests\Feature\V1009RtcAuthorityTest`<br>`test_logging_failure_cannot_change_an_authority_denial` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 148 B | `Tests\Feature\V1009RtcAuthorityTest`<br>`test_match_alone_does_not_grant_rtc` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 149 B | `Tests\Feature\V1009RtcAuthorityTest`<br>`test_old_sweep_snapshot_cannot_overwrite_committed_current_heartbeat` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 150 B | `Tests\Feature\V1009RtcAuthorityTest`<br>`test_restrict_disabled_and_unknown_environment_fail_closed` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 151 B | `Tests\Feature\V1009RtcAuthorityTest`<br>`test_sweep_check_error_does_not_permanently_invalidate_active_call_or_publish_partial_allowlist` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 152 B | `Tests\Feature\V1009RtcAuthorityTest`<br>`test_terminal_room_epoch_is_never_reused` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L34 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 153 B | `Tests\Feature\V10110ToolHistoryTest`<br>`test_dynamic_failed_compute_retries_original_command_without_new_row_or_revision` | FAIL · ExpectationFailedException · 期望 HTTP 503 / 实际 403 @ L124 | 权限/旧合同 · 旧工具、管理或参与入口，细因待核 | FAIL | FAIL |
| 154 B | `Tests\Feature\V10110ToolHistoryTest`<br>`test_dynamic_retry_history_and_owner_delete_are_consistent` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 403 @ L85 | 权限/旧合同 · 旧工具、管理或参与入口，细因待核 | FAIL | FAIL |
| 155 B | `Tests\Feature\V10110ToolHistoryTest`<br>`test_new_history_is_bounded_and_mbti_rejects_duplicate_answers` | FAIL · ExpectationFailedException · 期望 HTTP 422 / 实际 403 @ L146 | 权限/旧合同 · 旧工具、管理或参与入口，细因待核 | FAIL | FAIL |
| 156 B | `Tests\Feature\V10111SupportFeedbackTest`<br>`test_admin_classification_status_and_public_reply_return_without_internal_material` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L60 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 157 B | `Tests\Feature\V1011AccountSecurityTest`<br>`test_web_account_audit_denies_ordinary_role_and_never_projects_receipt_or_idempotency_secrets` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L272 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 158 B | `Tests\Feature\V1011SocialTest`<br>`test_privacy_posts_and_revocation_do_not_disclose_deep_fields` | FAIL · ExpectationFailedException · 期望 HTTP 409 / 实际 200 @ L75 | 数据完整性/旧合同 · 同值旧 CAS 返回当前状态，旧 409 断言保留 | FAIL | FAIL |
| 159 B | `Tests\Feature\V1012R1BoundaryTest`<br>`test_exit_withdraws_pending_and_stale_generation_lazily_releases_both_slots` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L362 | 用户入口/权限 · 旧关系或匹配读写合同，细因待核 | FAIL | FAIL |
| 160 B | `Tests\Feature\V1012R1BoundaryTest`<br>`test_mutual_history_survives_exit_and_generation_change_without_new_cn_authority` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L362 | 用户入口/权限 · 旧关系或匹配读写合同，细因待核 | FAIL | FAIL |
| 161 B | `Tests\Feature\V1012R1BoundaryTest`<br>`test_pause_preserves_pending_allows_withdraw_and_blocks_opt_in_until_resolved` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L362 | 用户入口/权限 · 旧关系或匹配读写合同，细因待核 | FAIL | FAIL |
| 162 B | `Tests\Feature\V1014PlatformSafetyTest`<br>`test_expired_and_cancelled_events_do_not_imply_attendance_or_safety_penalty` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L549 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 163 B | `Tests\Feature\V1014PlatformSafetyTest`<br>`test_human_finding_named_appeal_review_restores_only_selected_sanction_and_no_social_rights` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 500，缺 Blade 编译路径 @ L499 | 基础设施 · 缺 Blade 编译目录 | PASS | PASS |
| 164 B | `Tests\Feature\V1015MessagingTest`<br>`test_committed_attachment_state_change_does_not_hide_same_key_result_or_conflict` | FAIL · ExpectationFailedException · 通知表期望 1 行 / 实际 5 行 @ L99 | 数据完整性 · 基于实际同意事件总数，确认消息及撤权副作用 | FAIL | PASS |
| 165 B | `Tests\Feature\V1015MessagingTest`<br>`test_committed_block_denies_even_same_key_replay_and_private_reader_without_new_side_effects` | FAIL · ExpectationFailedException · 通知表期望 1 行 / 实际 5 行 @ L50 | 数据完整性 · 基于实际同意事件总数，确认消息及撤权副作用 | FAIL | PASS |
| 166 B | `Tests\Feature\V1015MessagingTest`<br>`test_departed_member_cannot_replay_a_committed_message` | FAIL · ExpectationFailedException · 通知表期望 1 行 / 实际 5 行 @ L60 | 数据完整性 · 基于实际同意事件总数，确认消息及撤权副作用 | FAIL | PASS |
| 167 B | `Tests\Feature\V1015MessagingTest`<br>`test_hiding_keeps_authorized_history_readable_but_cn_close_does_not` | FAIL · ExpectationFailedException · 通知表期望 1 行 / 实际 6 行 @ L82 | 数据完整性 · 基于实际同意事件总数，确认消息及撤权副作用 | FAIL | PASS |
| 168 B | `Tests\Feature\V1015MessagingTest`<br>`test_replay_is_exactly_once_conflicting_payload_rejected_and_readback_retains_idempotency_identity` | FAIL · ExpectationFailedException · 通知表期望 1 行 / 实际 5 行 @ L38 | 数据完整性 · 基于实际同意事件总数，确认消息及撤权副作用 | FAIL | PASS |
| 169 B | `Tests\Feature\V1015TrustedLoginTest`<br>`test_registration_does_not_create_a_successful_login_or_offline_receipt` | FAIL · ExpectationFailedException · 断言或异常详见私有 JUnit @ L52 | 权限 · P1 注册 T0 合同冲突，Owner 待决 | FAIL | FAIL |
| 170 B | `Tests\Feature\V1018AudioTest`<br>`test_real_duration_bounds_and_forged_content_are_rejected_without_assets` | ERROR · ProcessFailedException · 子进程退出异常 @ L52 | 基础设施/兼容 · 本地计算或媒体运行前置待核 | ERROR | ERROR |
| 171 B | `Tests\Feature\V1018AudioTest`<br>`test_truncated_recording_must_decode_and_unavailable_verifier_rejects` | ERROR · ProcessFailedException · 子进程退出异常 @ L52 | 基础设施/兼容 · 本地计算或媒体运行前置待核 | ERROR | ERROR |
| 172 B | `Tests\Feature\V1018AudioTest`<br>`test_valid_audio_upload_send_replay_and_private_range_then_revoke` | ERROR · ProcessFailedException · 子进程退出异常 @ L52 | 基础设施/兼容 · 本地计算或媒体运行前置待核 | ERROR | ERROR |
| 173 B | `Tests\Feature\V1018ChatSemanticsTest`<br>`test_absent_reply_preserves_the_preexisting_fingerprint_bytes` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 174 B | `Tests\Feature\V1018ChatSemanticsTest`<br>`test_ack_is_exact_and_preserves_first_read_time_on_batch_and_single_replay` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 175 B | `Tests\Feature\V1018ChatSemanticsTest`<br>`test_cross_room_reply_is_rejected_and_reply_identity_is_part_of_replay_fingerprint` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 176 B | `Tests\Feature\V1018ChatSemanticsTest`<br>`test_history_prefetch_search_and_own_send_preserve_unpresented_inbound_rows` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 177 B | `Tests\Feature\V1018ChatSemanticsTest`<br>`test_mixed_foreign_room_or_outbound_ack_ids_reject_the_whole_batch` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 178 B | `Tests\Feature\V1018ChatSemanticsTest`<br>`test_same_room_replies_are_bounded_and_media_quotes_expose_only_type` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 179 B | `Tests\Feature\V1018ChatSemanticsTest`<br>`test_search_and_reply_replay_recheck_current_permission` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 180 B | `Tests\Feature\V1018ChatSemanticsTest`<br>`test_search_hit_limit_cursor_is_last_scanned_row_and_skips_no_hits` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 181 B | `Tests\Feature\V1018ChatSemanticsTest`<br>`test_search_scan_window_advances_over_zero_hits_and_does_not_mark_read` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L36 | 权限/旧合同 · 会话、同意或 RTC 前置，细因待核 | FAIL | FAIL |
| 182 B | `Tests\Feature\V1018NotificationEventsTest`<br>`test_business_rollback_leaves_neither_state_change_nor_notice` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L94 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 183 B | `Tests\Feature\V1018NotificationEventsTest`<br>`test_connection_lifecycle_notifies_the_other_participant_once with data set #0` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L94 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 184 B | `Tests\Feature\V1018NotificationEventsTest`<br>`test_connection_lifecycle_notifies_the_other_participant_once with data set #1` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L94 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 185 B | `Tests\Feature\V1018NotificationEventsTest`<br>`test_connection_lifecycle_notifies_the_other_participant_once with data set #2` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L94 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 186 B | `Tests\Feature\V1018NotificationEventsTest`<br>`test_dual_purpose_message_consent_emits_one_notice_per_user_action with data set #0` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L94 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 187 B | `Tests\Feature\V1018NotificationEventsTest`<br>`test_dual_purpose_message_consent_emits_one_notice_per_user_action with data set #1` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L94 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 188 B | `Tests\Feature\V1018NotificationEventsTest`<br>`test_dual_purpose_message_consent_emits_one_notice_per_user_action with data set #2` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L94 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 189 B | `Tests\Feature\V1018NotificationEventsTest`<br>`test_proposal_decisions_notify_peer_and_replay_has_no_second_event with data set #0` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L94 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 190 B | `Tests\Feature\V1018NotificationEventsTest`<br>`test_proposal_decisions_notify_peer_and_replay_has_no_second_event with data set #1` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L94 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 191 B | `Tests\Feature\V1018NotificationEventsTest`<br>`test_proposal_decisions_notify_peer_and_replay_has_no_second_event with data set #2` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L94 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 192 B | `Tests\Feature\V1018NotificationEventsTest`<br>`test_terminal_rtc_notices_and_old_invite_resolve_to_read_only_result` | FAIL · ExpectationFailedException · 期望 HTTP 200 / 实际 409 @ L94 | 权限/旧合同 · 旧通知前置或路由，细因待核 | FAIL | FAIL |
| 193 B | `Tests\Unit\ConversationListPeerFilterTest`<br>`test_list_excludes_invalid_and_denied_peers_without_recovering_identity_from_id` | ERROR · QueryException · 缺会话隐藏视图表 @ L44 | 权限 · 补齐隔离 schema，原 peer 拒绝断言通过 | ERROR | PASS |
| 194 B | `Tests\Unit\LiveKitTokenServiceTest`<br>`test_issue_join_info_rejects_when_livekit_is_disabled` | ERROR · NotFoundHttpException · connection unavailable @ L71 | 权限 · 连接前置条件被拒，旧链合同待核 | ERROR | ERROR |
| 195 B | `Tests\Unit\LiveKitTokenServiceTest`<br>`test_issue_join_info_returns_signed_payload_for_participant` | ERROR · NotFoundHttpException · connection unavailable @ L71 | 权限 · 连接前置条件被拒，旧链合同待核 | ERROR | ERROR |
| 196 B | `Tests\Unit\V1010NatalBaziCalculatorTest`<br>`test_changed_birth_date_changes_pillars_and_result_input_identity` | ERROR · RuntimeException · bazi_time_executable_not_configured @ L147 | 基础设施 · 隔离环境未配置八字时间可执行文件 | ERROR | ERROR |
| 197 B | `Tests\Unit\V1010NatalBaziCalculatorTest`<br>`test_combined_year_month_ten_gods_use_effective_day_master` | ERROR · RuntimeException · bazi_time_executable_not_configured @ L230 | 基础设施 · 隔离环境未配置八字时间可执行文件 | ERROR | ERROR |
| 198 B | `Tests\Unit\V1010NatalBaziCalculatorTest`<br>`test_confirmed_algorithm_sex_changes_direction_but_not_natal_pillars` | ERROR · RuntimeException · bazi_time_executable_not_configured @ L87 | 基础设施 · 隔离环境未配置八字时间可执行文件 | ERROR | ERROR |
| 199 B | `Tests\Unit\V1010NatalBaziCalculatorTest`<br>`test_domain_edges_and_pre_utc_birth_crossing_1960_keep_explicit_time_frames` | ERROR · RuntimeException · bazi_time_executable_not_configured @ L261 | 基础设施 · 隔离环境未配置八字时间可执行文件 | ERROR | ERROR |
| 200 B | `Tests\Unit\V1010NatalBaziCalculatorTest`<br>`test_explicit_parent_solar_context_can_cross_date_and_is_recorded` | ERROR · RuntimeException · bazi_time_executable_not_configured @ L122 | 基础设施 · 隔离环境未配置八字时间可执行文件 | ERROR | ERROR |
| 201 B | `Tests\Unit\V1010NatalBaziCalculatorTest`<br>`test_late_zi_day_boundary_is_an_explicit_profile_setting` | ERROR · RuntimeException · bazi_time_executable_not_configured @ L98 | 基础设施 · 隔离环境未配置八字时间可执行文件 | ERROR | ERROR |
| 202 B | `Tests\Unit\V1010NatalBaziCalculatorTest`<br>`test_li_chun_boundary_uses_real_instant_rather_than_local_wall_clock` | ERROR · RuntimeException · bazi_time_executable_not_configured @ L197 | 基础设施 · 隔离环境未配置八字时间可执行文件 | ERROR | ERROR |
| 203 B | `Tests\Unit\V1010NatalBaziCalculatorTest`<br>`test_parent_solar_cross_day_does_not_reclassify_instant_year_month_or_yun` | ERROR · RuntimeException · bazi_time_executable_not_configured @ L217 | 基础设施 · 隔离环境未配置八字时间可执行文件 | ERROR | ERROR |
| 204 B | `Tests\Unit\V1010NatalBaziCalculatorTest`<br>`test_real_fields_are_computed_with_explicit_rules_and_unverified_oracle` | ERROR · RuntimeException · bazi_time_executable_not_configured @ L28 | 基础设施 · 隔离环境未配置八字时间可执行文件 | ERROR | ERROR |
| 205 B | `Tests\Unit\V1010NatalBaziCalculatorTest`<br>`test_same_utc_uses_same_cst_year_month_and_yun_across_global_timezones` | ERROR · RuntimeException · bazi_time_executable_not_configured @ L178 | 基础设施 · 隔离环境未配置八字时间可执行文件 | ERROR | ERROR |
| 206 B | `Tests\Unit\V1010NatalBaziCalculatorTest`<br>`test_unknown_algorithm_sex_still_returns_pillars_but_not_direction_or_luck_cycles` | ERROR · RuntimeException · bazi_time_executable_not_configured @ L74 | 基础设施 · 隔离环境未配置八字时间可执行文件 | ERROR | ERROR |
| 207 B | `Tests\Unit\V1010NatalBaziCalculatorTest`<br>`test_yun_conversion_method_is_explicit_and_minute_method_keeps_hours` | ERROR · RuntimeException · bazi_time_executable_not_configured @ L110 | 基础设施 · 隔离环境未配置八字时间可执行文件 | ERROR | ERROR |
| 208 B | `Tests\Unit\ZiweiIztroAppVisibleReplacementTest`<br>`test_app_visible_replacement_outputs_b_iztro_14_main_star_subset` | ERROR · ErrorException · 读取缺失字段 @ L167 | 普通兼容 · 旧工具输出或缺字段，细因待核 | ERROR | ERROR |
| 209 B | `Tests\Unit\ZiweiIztroAppVisibleReplacementTest`<br>`test_app_visible_replacement_outputs_c_iztro_14_main_star_subset` | ERROR · ErrorException · 读取缺失字段 @ L167 | 普通兼容 · 旧工具输出或缺字段，细因待核 | ERROR | ERROR |
| 210 B | `Tests\Unit\ZiweiIztroLocalReplacementTest`<br>`test_local_replacement_mode_outputs_b_iztro_14_main_star_subset` | ERROR · ErrorException · 读取缺失字段 @ L245 | 普通兼容 · 旧工具输出或缺字段，细因待核 | ERROR | ERROR |
| 211 B | `Tests\Unit\ZiweiIztroLocalReplacementTest`<br>`test_local_replacement_mode_outputs_c_iztro_14_main_star_subset` | ERROR · ErrorException · 读取缺失字段 @ L245 | 普通兼容 · 旧工具输出或缺字段，细因待核 | ERROR | ERROR |
| 212 B | `Tests\Unit\ZiweiIztroRunnerClientTest`<br>`test_runner_client_executes_iztro_runner_for_sample_a` | FAIL · ExpectationFailedException · 实际 false 与期望不符 @ L51 | 基础设施/兼容 · 本地计算或媒体运行前置待核 | FAIL | FAIL |
| 213 B | `Tests\Unit\ZiweiIztroShadowAdapterTest`<br>`test_shadow_adapter_generates_a_b_c_candidates_that_match_accepted_strict_subset` | FAIL · ExpectationFailedException · 断言字符串应相同 @ L46 | 普通兼容 · 旧工具输出或缺字段，细因待核 | FAIL | FAIL |
| 214 B | `Tests\Unit\ZiweiIztroShadowAdapterTest`<br>`test_shadow_adapter_preserves_b_empty_strict_main_star_palaces` | FAIL · ExpectationFailedException · 数组对比不符 @ L81 | 普通兼容 · 旧工具输出或缺字段，细因待核 | FAIL | FAIL |
