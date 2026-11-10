# AUTH-135｜数据库结构本地静态对照

**作者候选，停 Work LEVEL 3 独立审查。** 本轮只对照 v10 本地迁移/必要模型与已接受的旧部署目录 Laravel CLI 脱敏回执；**当前目标服务器的完整数据库结构仍 `UNKNOWN`**。本地起点 `D:\EliteSync-v10`、`main` HEAD `50d5618cb32963b966d5bbfd3937de6df5582592`。唯一新增文件为本 `summary.md`；未读取旧 `D:\EliteSync` 或任何服务器、数据库及无关未跟踪内容。

## 本地代码的表级设计清单

在 `services/backend-laravel/database/migrations/` 的 **57** 个 PHP 迁移文件中，按字面 `Schema::create('常量表名', …)` 静态核对到 **42** 次调用、**42** 个唯一表名，分布在 **32** 个文件；`Schema::table` 字面调用 **60** 次，分布在 **26** 个文件（含 `down()`，不能当作 60 项不同的后续变更）。`2026_07_12_000100_create_match_round_foundation_tables.php` 同时建六表并修改既有表，证明文件数不等于表数。所列路径均相对于上述迁移目录，逐项以实际文件核对；功能分组仅为阅读方便，不是数据库权限或恢复边界。

| 分组 | `Schema::create` 表 | 来源迁移文件 |
| --- | --- | --- |
| 账号/认证 | `users` | `0001_01_01_000000_create_users_table.php` |
| 账号/认证 | `password_reset_tokens` | `0001_01_01_000000_create_users_table.php` |
| 账号/认证 | `sessions` | `0001_01_01_000000_create_users_table.php` |
| 账号/认证 | `personal_access_tokens` | `2026_03_11_144705_create_personal_access_tokens_table.php` |
| 账号/认证 | `user_astro_profiles` | `2026_03_21_200000_create_user_astro_profiles_table.php` |
| 账号/认证 | `user_profile_showcase_drafts` | `2026_06_15_120000_create_user_profile_showcase_drafts_table.php` |
| 账号/认证 | `user_profile_showcase_review_audits` | `2026_06_16_120000_create_user_profile_showcase_review_audits_table.php` |
| 账号/认证 | `user_profile_showcase_publications` | `2026_06_16_150000_create_user_profile_showcase_publications_table.php` |
| 账号/认证 | `user_profile_showcase_publication_audits` | `2026_06_16_150100_create_user_profile_showcase_publication_audits_table.php` |
| 匹配/问卷 | `questionnaire_questions` | `2026_03_11_144712_create_questionnaire_questions_table.php` |
| 匹配/问卷 | `questionnaire_answers` | `2026_03_11_144713_create_questionnaire_answers_table.php` |
| 匹配/问卷 | `questionnaire_attempts` | `2026_04_18_000070_create_questionnaire_attempts_table.php` |
| 匹配/问卷 | `dating_matches` | `2026_03_11_150859_create_dating_matches_table.php` |
| 匹配/问卷 | `mbti_attempts` | `2026_03_22_180000_create_mbti_attempts_table.php` |
| 匹配/问卷 | `dating_round_channels` | `2026_07_12_000100_create_match_round_foundation_tables.php` |
| 匹配/问卷 | `dating_rounds` | `2026_07_12_000100_create_match_round_foundation_tables.php` |
| 匹配/问卷 | `matching_runs` | `2026_07_12_000100_create_match_round_foundation_tables.php` |
| 匹配/问卷 | `matching_run_candidates` | `2026_07_12_000100_create_match_round_foundation_tables.php` |
| 匹配/问卷 | `dating_round_user_states` | `2026_07_12_000100_create_match_round_foundation_tables.php` |
| 匹配/问卷 | `matching_operation_audits` | `2026_07_12_000100_create_match_round_foundation_tables.php` |
| 会话/媒体 | `chat_messages` | `2026_03_12_020000_create_chat_messages_table.php` |
| 会话/媒体 | `conversations` | `2026_04_18_000000_create_conversations_table.php` |
| 会话/媒体 | `conversation_members` | `2026_04_18_000010_create_conversation_members_table.php` |
| 会话/媒体 | `media_assets` | `2026_04_18_000020_create_media_assets_table.php` |
| 会话/媒体 | `media_processing_jobs` | `2026_04_18_000030_create_media_processing_jobs_table.php` |
| 会话/媒体 | `message_attachments` | `2026_04_18_000040_create_message_attachments_table.php` |
| 会话/媒体 | `rtc_sessions` | `2026_04_21_000000_create_rtc_sessions_table.php` |
| 会话/媒体 | `rtc_session_events` | `2026_04_21_000010_create_rtc_session_events_table.php` |
| 会话/媒体 | `conversation_match_links` | `2026_08_03_000000_create_conversation_match_links_table.php` |
| 运营/安全 | `app_events` | `2026_03_15_140000_create_app_events_table.php` |
| 运营/安全 | `app_release_versions` | `2026_03_22_070000_create_app_release_versions_table.php` |
| 运营/安全 | `user_blocks` | `2026_04_06_120100_create_user_blocks_table.php` |
| 运营/安全 | `moderation_reports` | `2026_04_06_120200_create_moderation_reports_table.php` |
| 运营/安全 | `status_posts` | `2026_04_09_130000_create_status_posts_table.php` |
| 运营/安全 | `user_relationship_events` | `2026_04_18_000050_create_user_relationship_events_table.php` |
| 运营/安全 | `notifications` | `2026_04_18_000060_create_notifications_table.php` |
| 运营/安全 | `status_post_likes` | `2026_04_19_000110_create_status_post_likes_table.php` |
| 框架基础 | `cache` | `0001_01_01_000001_create_cache_table.php` |
| 框架基础 | `cache_locks` | `0001_01_01_000001_create_cache_table.php` |
| 框架基础 | `jobs` | `0001_01_01_000002_create_jobs_table.php` |
| 框架基础 | `job_batches` | `0001_01_01_000002_create_jobs_table.php` |
| 框架基础 | `failed_jobs` | `0001_01_01_000002_create_jobs_table.php` |

分组计数为账号/认证 **9**、匹配/问卷 **11**、会话/媒体 **9**、运营/安全 **8**、框架基础 **5**，合计 **42**。`services/backend-laravel/config/database.php` 指定迁移账本表名 `migrations`；它由 Laravel 迁移机制管理，**不在上述 42 次 `Schema::create` 内**。因此“42 个本地显式建表名 + 1 个配置中的账本名 = 43”只是静态算术，绝不证明与 AUTH-65 的 43 张可见基表集合相等。

其余迁移对已有表执行 `Schema::table`，可改变列、索引或约束；模型可有独立表映射（例如 `AppNotificationItem` 显式映射 `notifications`），模型类数不能反推表数。对迁移目录的受限文本检查未命中 `DB::statement`、`DB::unprepared`、`Schema::rename` 或显式 `CREATE TABLE/VIEW/TRIGGER/PROCEDURE/EVENT`；`Schema::dropIfExists` 命中的是回滚分支，不能当新表。此方法覆盖该目录中的字面调用，但未运行 Laravel、未解析条件分支或框架内部建表，也未证明仓库其他位置不存在运行时/raw SQL；更不证明这些迁移已在当前目标应用或 DB 实际执行。没有读取业务行或对真实表、列、索引做集合比较。

## 旧部署目录的已接受聚合，仅限各次 CLI 可见范围

| 回执 / 观察时点 | 当次被 Work 接受的最小事实 | 不能推出 |
| --- | --- | --- |
| AUTH-14 / 2026-09-24 | 部署目录 Laravel CLI 的 `migrate:status` 严格解析：57 行、57 `Ran`、0 待运行；四个固定目标迁移均 `Ran`。 | 不能证明 migration 内容与当前本地 57 文件字节相同、实际表/列完整、Web worker 同库或当前迁移状态。 |
| AUTH-16 / 2026-09-24 | 当次 CLI 连接的 MySQL 驱动下，固定三表、14 个指定字段、两个单列唯一索引的存在性均为真；其中 `schema_complete` 只对这些固定检查项。 | 不能证明整表/整库 schema、逐项约束、目标实例身份或真实业务范围。 |
| AUTH-20 / 2026-09-24 | 当次 CLI 连接报告 MariaDB 10.11.14、一个仅供同算法后续比较的目标指纹、`information_schema.tables` 43 条，以及 `data_length+index_length` 估算 7,176,192 bytes。 | 指纹不证明实例身份；43 条不提供对象名或权限完整性，估算不是 dump 大小。 |
| AUTH-65 / 2026-09-25 | 当次 CLI 连接可见 **43 基表、0 视图、532 列、196 索引、43 主键、29 唯一约束、66 外键、39 CHECK**；触发器、例程、事件各可见 0。目标指纹与 AUTH-20 同算法比较相同。 | 计数相同不等于表/列/索引集合相同；0 也可能由权限隐藏，不能证明权威全集或业务数据范围。 |
| AUTH-67 / 2026-09-25 | 当次 CLI 连接可见的 43 基表均报 InnoDB；明确非 InnoDB 0、引擎 NULL 0、视图 0；版本/目标指纹与 AUTH-65 比较相同。 | 不能证明事务快照足以覆盖全部真实对象、并发写入/DDL 一致性或可恢复性。 |

以上是各次已接受的**部署目录 CLI 当前配置和其账号权限所能看见的**聚合，并非本轮现场复查。原始输出未在本轮获取；跨时点指纹/计数相合也未核定服务器硬件或云实例身份。AUTH-104 Work LEVEL 2 仅接受对象全集/权限预检的**静态设计**：权威全集、拟备份账号逐项权限、Web/CLI 同库、一致性和恢复边界仍 `UNKNOWN`。

## 三层证据矩阵

| 命题 | 本地源码可推断 | 旧部署聚合可证 | 当前目标实例仍需证明 |
| --- | --- | --- | --- |
| 表及迁移 | 当前 v10 文件中 42 个字面建表名、57 个迁移文件，另有账本配置与后续改表调用。 | AUTH-14 当次 CLI 账本 57/57 `Ran`；AUTH-65 当次权限可见 43 基表。 | 当前部署文件字节、账本与**实际表名集合**逐项相等，以及是否存在额外/缺失对象：`UNKNOWN`。 |
| 列、索引、外键与数据行 | 迁移定义的是设计，模型只给应用读取映射线索。 | AUTH-16 固定 14 字段/2 唯一索引；AUTH-65 给可见聚合计数。 | 当前实际列/索引/外键**集合**、业务行及数据类别、引用完整性：`UNKNOWN`。 |
| 视图、触发器、例程、事件 | 该迁移目录未见显式 raw SQL 创建调用，不等于全系统不使用。 | AUTH-65 对这些类别当次各报可见 0（视图 0）。 | 权威目录来源、权限是否隐藏对象、各定义与备份账号逐项读取权：`UNKNOWN`。 |
| Web worker / CLI / 备份连接 | 本地配置代码可描述连接机制，不能给实例现时值。 | 既有回执全是部署目录 CLI 连接；AUTH-20/65/67 指纹只供同算法比较。 | 三种执行上下文是否指向同一权威 DB、目标云实例是否为 Owner 所选：`UNKNOWN`。 |
| 引擎、写入与一致性 | 本地迁移可见部分约束设计，不表示运行时写入窗口。 | AUTH-67 当次可见 43/43 InnoDB。 | 隐藏对象/非事务依赖、并发 DDL/写入、完整快照与恢复校验：`UNKNOWN`。 |
| DB 外部文件 | 本地媒体表名不证明文件已包含在 DB。 | 聚合只覆盖 DB 元数据，没有服务器文件清单。 | Owner 本次备份目标**仅 DB 内数据和对象**；外部图片/视频不纳入，依赖缺口及整站恢复能力 `UNKNOWN`。 |

要证明**当前服务器**结构，后继必须先在新任务中固定 Owner 目标实例技术身份、独立 host-key/端口信任门、CLI 与 Web/备份连接同库、权威目录来源和最小只读元数据/权限比较范围；再按 LEVEL 3 审查并取得具体现场授权。本文件没有可运行现场命令，也不申请预算。AUTH-121/122/123 本机读取各 1/1、AUTH-128 页面 1/1 和既有 SSH 预算均不重置；本轮现场预算 **0**。首次真实备份未开始，不能把数据库备份称为整站恢复。

作者最多两轮本地静态检查，交文件 SHA-256、实际范围与差异后停 Work LEVEL 3；不提交、推送、自接受或派发后继。

## Work LEVEL 3 独立审查（2026-09-26）

**ACCEPT 仅本地表级设计清单与旧部署聚合的分层对照；当前服务器完整 schema 仍 `UNKNOWN`。** Work 对照作者交付前 SHA-256 `CBC3C20FE69C55ABF38D512E61ADA1042A2C77E705322E91679667829A848DC1`、唯一新增文件及差异，独立从迁移目录核得 57 个文件、42 次字面 `Schema::create`、42 个唯一表名，并逐项比较本文件 42 行表名，无遗漏/额外项；复核 `config/database.php` 中账本名及 AUTH-14/16/20/65/67 的受限回执。作者报告两轮本地静态检查，Work 未访问旧仓库或现场数据库。

本地 42 个显式表名加配置中的迁移账本名，不能由数量相等推得旧部署端 43 个可见基表的**集合**相等。旧回执仅证明各次部署目录 CLI 与其账号权限可见的聚合；现时目标实例、Web worker/CLI/备份账号同库、权威对象全集、逐项权限、数据行和一致性仍未证明。该接受不授权 SSH、命令助手、DB、dump、传输或恢复，既有一次预算不重置。要回答 Owner 所问的当前服务器结构，仍须另经目标身份与连接信任门、受限权威元数据读取及 LEVEL 3 现场授权。
