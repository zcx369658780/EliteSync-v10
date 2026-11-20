# EliteSync V2 阶段 C 综合工程报告

2026-11-20 · **工程自验 `PHASE_C_PARTIAL` · Owner 集中验收 PENDING**

阶段 C 的具名隔离验证通过。PHP 全量仍为 `FAIL`，新增 25 条旧接口兼容错误或失败。Flutter Status 与 Buddy 扩围保留原 3 条失败。真实用途合法依据待确定，对象删除真实受理入口返回 `REQUEST_CHANNEL_UNAVAILABLE`。

## 工程身份与授权

| 项目 | 已核身份 |
|---|---|
| 治理 | `governance/home-matching-product-freeze-20261117` 固定提交 `f46a444b316b76f6f4800fc583599d09a75ae627` |
| 开发工作树 | `D:\EliteSync\development\v2-phase-a-20261119` |
| origin | `git@github.com:zcx369658780/EliteSync-v10.git` |
| 开发分支 | `codex/v2-phase-c-data-rights-purpose-20261120` |
| 阶段 A 祖先 | `4e6a5be6dcb7095438fb0a815c7831b14ffb561b`，固定交付 `07b51a6de9695f5358b6bea2a59acd5be24ab6c2` |
| 阶段 B 直接基线 | `1780f6add9a439c109f527eb7f58c2f96ab8bfa5`，为 C 首次源码提交的父提交 |
| 本次 PHP 测试源码 | `a028cf7eb46bcc4967a41df8b86052920058b1f5`，树 `8a0ed4f5a7f7b339f4f35147c267bdcc09bcb937` |
| 本次 Flutter 测试源码 | `63a0784db1ed78b52778e5166954d056f4ae6779`，与最终源码的 Flutter 应用及测试树逐路径一致 |
| 实施提交 | `69be0086` 用途与对象权利服务，`b8bac994` Flutter 入口，`63a0784d` 动态盘用途及登录资料来源，`a028cf7e` 动态盘历史许可与回滚门禁 |
| 交付提交 | 在测试源码之后仅新增本报告，最终身份以分支回读为准 |

测试源码提交完成后，开发树工作区和暂存区干净。全量 PHP 使用固定树的独立归档副本，测试产生的 devlogs 留在副本中。两处保护树仅只读核对 Git 状态。

| 保护根 | 分支与 HEAD | 末次工作区和暂存区 |
|---|---|---|
| `D:\EliteSync-v10` | `main` / `4bebc8f394248e254c1368a06fbdee5d2c883301` | 43 个已跟踪修改、213 个未跟踪条目，暂存区空 |
| `D:\EliteSync-v10-product-v1015-20261101` | `codex/ui-current-state-audit-20261116` / `1d8b485bf4f314d42431bb62a293a3fef9e9c8af` | 2 个未跟踪条目，暂存区空 |

保护树与开发树的 origin 相同。未跟踪条目按 Git 普通状态的目录折叠口径计数。[Owner 授权](https://github.com/zcx369658780/EliteSync-v10/blob/f46a444b316b76f6f4800fc583599d09a75ae627/docs/decisions/OWNER_V2_PHASE_B_FINAL_SCOPED_ACCEPTANCE_AND_PHASE_C_ENGINEERING_AUTHORIZATION_20261120.md) · [阶段 C 合并任务书](https://github.com/zcx369658780/EliteSync-v10/blob/f46a444b316b76f6f4800fc583599d09a75ae627/docs/versions/v2/V2_PHASE_C_DATA_RIGHTS_AND_PURPOSE_CONSOLIDATED_EXECUTION_BRIEF_20261120.md) · [阶段 B 固定报告](../phase-b-20261120/PHASE_B_ENGINEERING_REPORT.md)

## C1–C4 合同与证据

| 范围 | 源码与验证结果 | 自验 |
|---|---|---|
| **C1 资料来源与具名用途** · O04/O05、DATA-D1 | `DataPurposeService`、`DataRightsController` 和 `DataPurposePage` 独立记录现居城市复用与本人动态盘复用本命快照。账号来源、用途许可版本与有效期、可读受众、独立草稿或快照各有校验。资料和登录读取使用账号私有出生输入。基本资料保存停止触发旧排盘联算。独立工具保留手填。动态盘读取复用入口只取得当前已选来源版本，写入及结果落库重验许可和来源。拒绝、过期、撤销、用途不匹配以及旧许可版本均有隔离测试。 | `PARTIAL`。两个具名用途的隔离合同 `PASS`。真实合法依据 `UNKNOWN`，一般账号的跨用途复用关闭。 |
| **C2 派生和纠错** · DATA-D2、O05、HIS-D2 | `ShowcaseWorkflow` 将复用城市与源摘要、用途版本、展示草稿版本绑定。更正只使依赖该事实的草稿进入 `NEEDS_REVIEW`，阻断旧审核结果新发布。原合法发布保留其固定版本，撤销许可后从接口投影移除复用字段。手填字段继续独立可用。动态盘校验输入签名与实时来源版本，晚到的计算结果在用途撤销后无法落库。A2 原候选快照只读其绑定字段，城市与出生精确输入在该投影范围之外。 | `PASS`，限城市依赖、私有本命快照和既有候选投影的具名自动化。未具名旧数据的来源确认仍 `UNKNOWN`。 |
| **C3 本人对象级请求** · NEW-PC-03、RET-D1/D2、OBJ-D1 | `ObjectDataRequestService`、`DataRightsController` 和作品、评论、隐私设置三个 UI 入口按账号、对象类型、对象版本和请求键校验。作者撤下作品、评论者撤回展示、作品作者隐藏评论沿用各自展示语义。评论者失去作品读权后仍可定位本人评论，目录仅返回本人对象标识、时间和分页，无作品正文。同一对象唯一请求，同键异对象或版本拒绝。隔离流程具备 `REQUESTED_TEST_ONLY`、`ACCEPTED_TEST_ONLY`、`PROCESSING_TEST_ONLY`。处理器校验状态迁移，响应明确 `completion_available=false`。 | `PARTIAL`。本人作品与评论权限、请求幂等、测试状态迁移 `PASS`。真实渠道 `REQUEST_CHANNEL_UNAVAILABLE`，无实际受理或完成回执。 |
| **C4 失权与回归** · O09、HIS、A1–A4、B1–B4 | `JourneyStore` 复核会话和账号，历史动态盘详情在读取时复核许可。Flutter 保留切号及迟到响应隔离，主动进入动态用途设置时清除该用途当前结果和已选来源版本。对象请求回包不明时先按原键只读核对。仅确认 `NOT_APPLIED` 且对象版本一致后允许用户明确重试。作品 Block、历史评论原受众未知、私有媒体字节授权、通知和深链当前读权由 A+B 具名组回归。 | 具名组 `PASS`，总体验收 `PARTIAL`。跨设备撤权传播和真实设备时序 `NOT_RUN`。 |

### 迁移与状态保留

`services/backend-laravel/database/migrations/2026_11_20_120000_create_phase_c_data_rights.php` 新增私有出生时刻列，以及 `data_purpose_grants`、`showcase_city_sources`、`object_data_requests`。用途键采用用户和用途联合主键，草稿依赖采用用户和草稿版本联合主键，请求采用用户和 UUID 联合主键，并对用户、对象类型、对象键加唯一约束。动态盘许可版本保存在私有保存记录的 prepared JSON 中。许可和请求写入持有主体行锁，数据库唯一约束保护对象与命令归并。

SQLite 内存测试覆盖迁移后的读取与约束行为，以及回滚后撤下依赖许可的城市发布、清除审核历史中的复用城市、保留独立手填城市。动态盘历史只附加许可版本，读取时重新核对当前许可。发现曾复用本命的当前记录或历史时，回滚定义拒绝继续。SQLite 已验证仅剩历史记录也会阻断降级。MariaDB 的 JSON、迁移回滚和锁行为仍待专项验证。

对象删除请求测试覆盖他人访问 404、过期对象版本冲突、失去作品读权后处理本人评论、同键回读，以及作品撤下后保留第三方评论。接收与处理中仅在 `testing + SQLite :memory: + 签名合成身份` 运行。真实法域、受理方、备份、附件及第三方必要留存范围仍待认定。

## 最终源码的自动化证据

Windows 本机。PHP CLI 8.5.3、PHPUnit 12.5.42、Laravel 13.39.0、SQLite 3.49.2。测试入口固定 `testing`、SQLite `:memory:` 和空 DB URL，在迁移执行前核对有效配置。全量归档副本移入本地依赖，未载入工作树的 `.env` 或配置缓存。Flutter 3.41.7、Dart 3.11.5。本次 Flutter 使用本机测试运行器和隔离的 Widget 测试。动态盘计算引擎的定向契约用例使用测试替身，结果保持 `UNVERIFIED`。

| 验证 | 结果 |
|---|---|
| PHP 具名 A+B+C | `PASS`，167 项、2,140 断言，exit 0 |
| Flutter 具名 A+B+C | `PASS`，243 项，exit 0 |
| 本次改动的 Dart 文件 | `PASS`，12 项分析，0 问题，exit 0 |
| PHP Unit + Feature 全量 | `FAIL`，1,496 项、26,069 条断言，83 errors / 131 failures，另有 1 deprecation、4 skipped、3 risky，exit 2。断言数取控制台 |
| Flutter Status 与 Buddy 扩围 | `FAIL`，65 项通过、3 项失败，exit 1，与阶段 B 的三条失败标识一致 |
| Flutter 全仓 | `NOT_RUN` |

实际命令按各自应用根执行。具名 PHP 的输入为 B 固定 JUnit 中全部 17 个测试文件，加上 `V2PhaseCDataRightsTest.php` 和 `V1011DynamicChartApiTest.php`。后者保留来源不可用的 422 断言，同时核对缺许可及过时许可两道 409 拒绝。Flutter 保留原动态盘重试和历史断言，夹具补上用途版本并确认写入携带该版本。

```text
php -d extension=gd vendor/phpunit/phpunit/phpunit --colors=never --log-junit "<证据根>/c-verified-named.xml" <19 个具名测试文件>
php -d memory_limit=512M -d extension=gd vendor/phpunit/phpunit/phpunit --colors=never --log-junit "<证据根>/c-verified-full.xml"
flutter test --no-pub --reporter expanded test/features/lifestyle_discovery test/features/slow_dating_v1012 test/features/profile/presentation/providers/profile_showcase_draft_provider_test.dart test/core/network/retry_session_guard_test.dart test/core/network/api_transport_replay_test.dart test/core/network/v1015_late_response_test.dart test/core/storage/private_cache_service_test.dart test/core/media/media_url_resolver_test.dart test/features/chat/presentation/conversation_detail_live_test.dart test/features/chat/presentation/pages/live_conversation_private_cache_test.dart test/features/chat/presentation/pages/live_chat_retained_list_cache_test.dart test/features/status test/features/home test/features/buddy_v1013/buddy_pages_test.dart test/features/profile/phase_c_data_rights_page_test.dart test/features/profile/dynamic_chart_page_test.dart test/features/profile/v10110_tool_history_test.dart
flutter analyze --no-pub <相对阶段 B 交付改动的 12 个 Dart 文件>
flutter test --no-pub --concurrency=1 --reporter expanded test/features/buddy_v1013 test/features/status
```

证据根为 `D:\EliteSync\development\v2-phase-c-evidence-20261120`。完整参数保留在 `c-verified-php-named-command.txt`、`c-delivery-flutter-named-command.txt` 和 `c-final-dart-command.txt`。原始日志、归档与测试副本留在本机。

| 本地证据 | SHA256 |
|---|---|
| `c-verified-named.log` | `0b07f31e44a92f604744fc30cecf02ee9648ce606e1a790aded8b408a0006790` |
| `c-verified-named.xml` | `dfc48766fb156636309b32815de36ce52ac0f5fa1663000ab8253277b8004522` |
| `c-verified-full.log` | `fac5e4c30652993fb5f554d76e23a1133d88083224bdd2e1f00e13407fb17549` |
| `c-verified-full.xml` | `1c84cc26f381473505f8a60aed0888720fabd1f7cfdb42efd4204ce3879c52e6` |
| `c-delivery-flutter-named.log` | `431361937178111a8f29f2e9aecc4dd8727dace30b60a744a4a22ee44c41250c` |
| `c-final-flutter-expanded.log` | `7fe847d6cda31bba7402bf095ecbd75670a5f4aef1b34e7d88bde66631c2d8a6` |
| `c-final-dart.log` | `9999d2151ac5bb004c4403c8d520a0b02d83f06bf8b04acda9080693aa248828` |
| `c-verified-backend-source.tar` | `76e8fd43a122ced88e75663e7861f516f0205d1052fc28d3e9cfaef03d16d9ed` |
| B 基线 `php-delivery-full.xml` | `ce5f18535a588982d4fc74ffefe9b9e05218852394424026f2362206954aafdb` |
| B 基线 `flutter-expanded-serial.log` | `f62ee8a0dc5d796addfb98ae5f06a5fa35976d494a40dde3bed67dfa2ac1016a` |

## A+B 回归与全量差异

A1 身份测试资格、A2 原候选快照及当前读权、A3 Lifestyle 先查询 UNKNOWN、A4 历史评论原受众及迟到回包均在具名组通过。B1 访客官方内容和用户作品分域、B2 `FRIENDS + FRIENDS_ONLY` 与受众变更、B3 独立撤回与隐藏、B4 搜索、媒体、通知、深链和切号同样在具名组通过。访客实际官方正文仍为 `public_editorial=[]`。

PHP 以 JUnit 的类名、方法名和错误类型逐项比较。阶段 B 的 81 errors、108 failures 均保留。阶段 C 新增 2 errors、23 failures，零条移除。兼容变化发生于旧排盘写入或读取被阻断、基本资料停止触发旧联算、登录停止从旧排盘回填私有字段。既有断言保留，PHP 全量结论维持 `FAIL`。

| PHP 新增差异 | 数量 | 阶段 B 用例方法名（省略共同前缀 `test_`） |
|---|---|---|
| `AstroCanonicalApiTest` | 14 failures | `astro_chart_cache_recomputes_when_birth_input_signature_changes`、`astro_chart_cache_recomputes_when_house_system_policy_changes_to_placidus`、`astro_chart_cache_rejects_legacy_not_house_truth_cache_even_with_matching_signature`、`astro_chart_cache_reuses_matching_western_natal_signature`、`astro_chart_endpoint_returns_chart_data_payload`、`astro_chart_old_cache_without_signature_forces_recompute`、`astro_chart_python_fallback_does_not_claim_house_truth`、`astro_save_changes_bazi_ziwei_and_western_when_birth_place_changes`、`astro_save_falls_back_when_user_birthday_missing`、`astro_save_uses_server_canonical_engine_without_client_sun_sign`、`astro_summary_endpoint_returns_profile_without_svg_payload`、`astro_summary_prefers_current_natal_chart_signs_over_stale_legacy_summary`、`bazi_hidden_stems_contract_uses_lunar_php_canonical_source`、`cece_p0_ziwei_payload_is_preserved_by_profile_astro_api` |
| `ProfileBasicRecomputeTest` | 5 failures | `save_basic_bootstraps_astro_profile_when_missing`、`save_basic_changes_astro_when_birth_place_changes_with_same_birth_time`、`save_basic_invalidates_stale_western_natal_chart_cache_before_detail_recompute`、`save_basic_marks_western_natal_render_failure_without_fake_chart_cache`、`save_basic_recomputes_existing_astro_profile_with_new_birth_place` |
| `V1007BaziProvenanceTest` | 3 failures | `client_cannot_supply_derived_bazi_or_provenance_notes`、`invalid_time_or_unsupported_timezone_rejects_before_user_or_profile_write`、`real_local_lunar_engine_produces_known_four_pillars_without_coordinates` |
| `V1007BaziProvenanceTest` | 2 errors | `missing_birth_time_is_explicit_default_noon_with_low_confidence`、`repeated_unknown_time_stays_low_confidence_until_explicit_time_replaces_provenance` |
| `AuthPasswordApiTest` | 1 failure | `login_prefers_profile_birth_place_when_private_value_is_blank` |

Flutter 扩围在 B 和 C 均报告 `v1013_root_entry_test.dart` 的 `SessionNotifier.build` 签名编译错误，以及 `v1019_buddy_pages_test.dart` 的 `loaded discovery cards and cursor disappear after pagination business 403` 和 `create retains draft and immutable command after lost response` 两条 Widget 失败。

## 外部阻断与验收建议

- `UNKNOWN`。真实的资料复用和对外发布依据、旧资料来源、对象删除的法域与合法受理方、保留例外、备份和附件范围。真实对象删除渠道继续关闭。
- `NOT_RUN`。项目声明的 PHP `~8.4.0`、MariaDB 真实驱动和并发、迁移及回滚、跨设备权限传播、真机和模拟器、真实 KYC/Push/RTC、生产和共享数据库。
- G01/G02/G03/G06/G08 的 A+B 证据沿用原限定状态。G04/G05/G06/G07 增加本报告所列具名子项。旧 1011804 和 UI-AUDIT-01 的 `FAIL/UNKNOWN/NOT_RUN`、F-01 `READABILITY_PARTIAL`、43 PNG `PENDING_BINARY_UPLOAD` 按原记录保留。
- Owner 集中验收可核定旧排盘客户端的兼容处置和独立手填路径。发布前仍需确认真实用途和删除依据，并在安全隔离环境补 PHP 8.4、MariaDB 和设备证据。

`PHASE_C_PARTIAL / OWNER_FINAL_PENDING / PHASE_D_NOT_STARTED / A6_MEETING_DEFERRED / RELEASE_NOT_AUTHORIZED`
