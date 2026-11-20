# EliteSync V2 阶段 D 综合工程报告

2026-11-20 · **工程自验 `PHASE_D_PARTIAL` · Owner 集中验收 PENDING**

连续旅程、站内待办和既有页面的具名自动化通过。内部候选为 **PARTIAL**，生产资格为 **NO_GO**。阶段 C 的 25 条兼容错误或失败单列，阶段 D 在本次 PHP 全量和 Flutter 扩围对照中新增失败为零。

## 工程身份

| 项目 | 已核实内容 |
|---|---|
| 固定治理提交 | `7cc6f6dbba3c813238a57c6f81b319af4687c243` |
| 工程根与 origin | `D:\EliteSync\development\v2-phase-a-20261119` · `git@github.com:zcx369658780/EliteSync-v10.git` |
| 开发分支 | `codex/v2-phase-d-journey-notification-20261120`，在干净的阶段 C 工作树上创建 |
| 阶段 C 直接基线 | `15b45a0068c65615dd600b314037965e31244584`，继承阶段 B `1780f6add9a439c109f527eb7f58c2f96ab8bfa5` 与阶段 A 安全成果 |
| D0 提交 | `399f34c5f3245758a433ecbbb562f8f228c97c0c` |
| D 最终测试源码 | `cdfd8f2753147ac3eaacd24af30d69a7efb3d07e`，树 `6decbef6e2cc7b42c3b697d6eb76b6612272044d` |
| D 交付身份 | 最终源码之后仅添加本报告，固定交付 SHA 以该分支回读为准 |
| 工作区和暂存区 | 开工前均空；固定源码测试后均空 |

Owner 对阶段 C 的限定接受仍带原保留项。阶段 D 的实现、隔离测试与非 main 工程备份依据这次具名授权。 [Owner 决定](https://github.com/zcx369658780/EliteSync-v10/blob/7cc6f6dbba3c813238a57c6f81b319af4687c243/docs/decisions/OWNER_V2_PHASE_C_FINAL_SCOPED_ACCEPTANCE_AND_PHASE_D_ENGINEERING_AUTHORIZATION_20261120.md) · [合并任务书](https://github.com/zcx369658780/EliteSync-v10/blob/7cc6f6dbba3c813238a57c6f81b319af4687c243/docs/versions/v2/V2_PHASE_D_JOURNEY_NOTIFICATION_EXPERIENCE_CONSOLIDATED_EXECUTION_BRIEF_20261120.md) · [启动 Prompt](https://github.com/zcx369658780/EliteSync-v10/blob/7cc6f6dbba3c813238a57c6f81b319af4687c243/docs/workflow/V2_PHASE_D_CODEX_EXISTING_SESSION_KICKOFF_PROMPT_20261120.md)

| 保护工作树 | 分支 / HEAD | 开工与交付核对 |
|---|---|---|
| `D:\EliteSync-v10` | `main` / `4bebc8f394248e254c1368a06fbdee5d2c883301` | 43 个已跟踪修改、213 个未跟踪条目，暂存区空 |
| `D:\EliteSync-v10-product-v1015-20261101` | `codex/ui-current-state-audit-20261116` / `1d8b485bf4f314d42431bb62a293a3fef9e9c8af` | 2 个未跟踪条目，暂存区空 |
| `D:\EliteSync\development\v2-governance-handoff-20261120` | `codex/v2-governance-handoff-sync-20261120` / `c73074bebc8ea55086b4ce2b537dade174bb9ed0` | 1 个未跟踪交接文件，暂存区空。原文工作副本 SHA256 `557d81c9ae91b7f1e0bb5a2a6d7a7046ff82d679f0ec4745e0392a81b04514a7` |

未跟踪条目使用 Git 的普通状态口径，含折叠目录。三处保护树只读核对。

## D0 旧排盘兼容

App 的星盘关系参考及画像入口区分 `LEGAL_BASIS_UNVERIFIED` 和空记录，提供本人本命手填路径。合法依据拒绝停止自动重读，保留页面显式刷新及现有 `/profile/natal` 输入。涉及 `astro_profile_provider.dart`、`AstroOverviewPage`、`AstroProfilePage` 和 `AstroProfileStateView`。Widget 验证旧拒绝提示和进入手填工具的导航，`V1010NatalApiTest` 验证独立私有保存及读回。

旧 `POST /profile/astro` 继续返回 409，`ProfileController::saveBasic` 继续独立保存账号事实，`AuthController` 继续从私有账号字段读取。完整兼容或旧核心接口退役仍需 Owner 决定。**D0 为 PARTIAL**。

| 阶段 C 新增兼容账 | 本次仍存 | 实际合同与处置 |
|---|---|---|
| `AstroCanonicalApiTest` | 14 failures | 旧星盘 POST 和旧摘要、图表缓存曾依赖自动计算。当前 App 走本命手填入口；仍需要旧客户端 API 产品处置。 |
| `ProfileBasicRecomputeTest` | 5 failures | 历史用例预期基本资料触发重算。保留私有资料保存和独立排盘入口。 |
| `V1007BaziProvenanceTest` | 3 failures、2 errors | 旧合同期待间接输入、自动计算或默认正午。当前用途未知时继续阻断，独立手填测试单列。 |
| `AuthPasswordApiTest` | 1 failure | 历史合同期待空出生地从旧盘回填。登录只用账号私有字段，沿用阶段 C 的来源边界。 |

25 个失败项逐例名称见阶段 C 报告。D 的 JUnit 用例身份和错误类型与该表全部相同。[阶段 C 逐项对照](../phase-c-20261120/PHASE_C_ENGINEERING_REPORT.md)

## D1–D4 验收矩阵

| 范围 | 实现与权限合同 | 已运行证据与自验 |
|---|---|---|
| **D1 连续关系旅程** | `LifestyleController` 核对问卷版本、本次修订及所选答案的保存修订。欢迎可以跳过，缺回执保留草稿与原键。重读后定位第一个未答场景。提案依据 `accept_available` 显示接受按钮。提案、连接、双方消息许可、会话和正式关系沿用各自服务，合法既有连接独立于旧提案期限。 | PHP `V10115LifestyleDiscoveryTest`、`V1017MatchingJourneyTest`、`V1012JourneyTest` 与 Flutter Lifestyle、Slow Dating、Connection 和进展页 Widget。首次、跳过、重入、逐步保存、失权、迟到响应、旧候选及独立同意的具名断言通过。真实身份正向链 `NOT_RUN`。 |
| **D1 提案命令与回执** | `SlowDatingService::decisionResult` 按当前本人身份、提案、动作、版本、原键查询最小回执。无回执时重新查到期、Block、参与代际和当前资格。接受、拒绝和撤回有明确确认。丢响应时先 GET，确认 `NOT_APPLIED` 且用户同意后才同键重试。 | PHP 覆盖 `APPLIED`、`NOT_APPLIED`、`UNKNOWN`、`CONFLICT`、过期及他人 404。Flutter 模拟丢响应并断言重试前确实查询、确认、原键及版本一致。现有连接和消息许可继续使用其生命周期版本，失败清空旧操作投影，重新读取当前状态。 |
| **D2 通知、待办与历史** | `NotificationService` 及 `NotificationController` 提供 `current/todo/history`。标读保留首次时间，独立于是否需要回应。匹配待办从既有轮次/运行源键定位本人提案，联系请求和提案的截止期来自业务记录。连接与消息许可复核事件、当前生命周期和收件资格；业务本身无截止期时显示待处理。历史只保留本人通知标识、通用文案与已读位。缺可证源键的旧记录按历史处理。 | PHP `NotificationApiTest`、`V1011NoticeRevocationTest`、`V1017MatchingJourneyTest` 与通知 Widget 具名通过。覆盖已读仍待办、未读已过期、办理后历史、Block、错号、旧链接、媒体与互动通知撤权。 |
| **D2 权限回流与外部投递** | 客户端打开前重读通知。提案待办传递本提案定位，进程页重读后拒绝替换提案。返回后重查原频道。读回包丢失时查询本人当前已读状态。合成传输按问卷与排序主体锁顺序取当前事实。 | Widget 验证系统 Back 回原待办以及新提案替换旧定位时的拒绝。真实 Push 仍 `REAL_PUSH_PROVIDER_PENDING`，真实传输 `NOT_RUN`。 |
| **D3 既有 UI 与可访问性** | Lifestyle 维持一题一屏，保存状态进入无障碍实时区域。通知频道使用可聚焦的选择控件，移除无实际作用的“稍后处理”，保留明确的标读与打开业务按钮。当前通知截止期按本机时区解释，卡片允许大字换行。既有 `SectionReveal` 对减少动效和辅助导航优先直接呈现。 | Lifestyle Widget 验证 2× 字体、选中语义、键盘访问和减少动效。通知 Widget 验证 2× 布局与系统 Back。读屏软件、真实键盘焦点顺序、完整 UI 审计、正式 A6 均 `NOT_RUN`。 |
| **D4 条件性联测** | Laravel HTTP 内核与 SQLite 内存真实执行业务写入和重读。Flutter 使用 Widget、传输和缓存测试，涉及 HTTP 数据的 Widget 使用虚构响应。D 无新增迁移定义，现有迁移在测试库初始化。 | 具名 A+B+C+D 测试及 D 变体通过。真实 APP→设备→API→DB 跨环境链 `NOT_RUN`。完整证据及历史失败见下表。内部候选 `PARTIAL`，生产 `NO_GO`。 |

源码独立复核聚焦待办权限、历史最小化、生命周期绑定、只读回执和锁序。已处理的轮次通知进入历史，撤回回执检查共用失效条件并保留暂停后的合法撤回，联系请求先锁双方再核当前行。最终源码的具名复核无开放 P1/P2/P3 意见。MariaDB 实际竞争行为仍缺验证。

## 测试环境、命令与日志

Windows，PHP 8.5.3、PHPUnit 12.5.42、Laravel 13.39.0、SQLite 3.49.2，Flutter 3.41.7、Dart 3.11.5。PHP 的 `Tests\TestCase` 在迁移前校验 `testing`、SQLite `:memory:` 和空 DB URL。全量在固定 D 源码的 `git archive` 独立副本中执行，仅复制既有本地 vendor。归档副本无项目 `.env` 和配置缓存。Flutter 单元与 Widget 测试在主机测试运行器执行。

| 检查 | 结果 |
|---|---|
| PHP A+B+C+D 具名 | `PASS` · 175 项 / 2,265 断言 · exit 0 |
| Flutter A+B+C+D 具名 | `PASS` · 383 项 · exit 0 |
| Flutter 恢复构建条件 | `PASS` · 31 项 · exit 0，覆盖实际 `ELITESYNC_V1017_LOCAL_BUILD` 分支下 Lifestyle 与进展页逻辑 |
| Dart 改动文件分析 | `PASS` · 22 个文件，0 问题 · exit 0 |
| PHP Unit + Feature 全量 | `FAIL` · 1,498 项 / 26,154 断言，83 errors、131 failures、1 deprecation、4 skipped、3 risky · exit 2。断言数取控制台。 |
| Flutter Buddy/Status 扩围 | `FAIL` · 65 项通过、3 项失败 · exit 1，三条身份与 C 完全相同 |
| Flutter 全仓 | `NOT_RUN` |

具名 PHP 执行阶段 C 同一组 19 个文件加 `V1010NatalApiTest.php`。Flutter 具名执行 C 阶段原有 17 个路径加通知目录、进展页、连接页、星盘入口及独立本命会话保护测试。测试输入、参数和日志均留存。

```text
php -d extension=gd vendor/phpunit/phpunit/phpunit --colors=never --log-junit <证据根>/d-named.xml <20 个具名测试文件>
php -d memory_limit=512M -d extension=gd vendor/phpunit/phpunit/phpunit --colors=never --log-junit <证据根>/d-full.xml
flutter test --no-pub --reporter expanded <22 个具名测试路径>
flutter analyze --no-pub <22 个改动 Dart 文件>
flutter test --no-pub --dart-define=ELITESYNC_V1017_LOCAL_BUILD=true --reporter expanded test/features/lifestyle_discovery test/features/user_automation/b3_journey_overview_test.dart
flutter test --no-pub --concurrency=1 --reporter expanded test/features/buddy_v1013 test/features/status
```

私有证据根为 `D:\EliteSync\development\v2-phase-d-evidence-20261120`。具名和分析命令的完整参数在 `d-php-named-command.txt`、`d-flutter-named-command.txt`、`d-dart-command.txt`。本地日志、归档和 SQLite 测试副产品未进入 Git。

| 文件 | SHA256 |
|---|---|
| `d-named.log` | `5d666e966bc7a70cbd6186523e13a25bb4d005ffd8ed6e5174712b2a627c3a00` |
| `d-named.xml` | `7c660ca40e61aed2d848b55ea7913c0f9d65f86048c28f9dabaddf7f61ebfd74` |
| `d-full.log` | `a71173fcfcb2dd7cd3757263e44e41abc7da0a2be8175d949c09c2f85fee9ee1` |
| `d-full.xml` | `81946f2adc849539810028fc7b2208232ece2d4e65b141fc3de60caa72f0930d` |
| `d-flutter-named.log` | `4c66fb02b58a6963b2b1ae8bf0bc7ec095d80bc644c769c92d20aa853f3e5435` |
| `d-flutter-v1017.log` | `130a78391d118ece343afd17bbca08e33c75c2c779c0268d004213db8deabb11` |
| `d-flutter-expanded.log` | `4c43907da4e9c2e6fa060c20e50170adfb3ea62e810951c74a6b0b0c1bc67ab0` |
| `d-dart.log` | `44271e65ec1de7c9bcd3f684df26b9cc674dbdee54a75715236a3119b6034766` |
| `d-backend-source.tar` | `bfee0b2db442a4c376f4e3cc94294b98f9dd8ccc10efdbc70879f32882f22c2e` |
| C 基线 `c-verified-full.xml` | `1c84cc26f381473505f8a60aed0888720fabd1f7cfdb42efd4204ce3879c52e6` |
| C 基线 `c-final-flutter-expanded.log` | `7fe847d6cda31bba7402bf095ecbd75670a5f4aef1b34e7d88bde66631c2d8a6` |

PHP 用 JUnit 的类名、方法名和错误类型对照 B、C、D。阶段 B 的 189 项（81 errors、108 failures）和阶段 C 新增的 25 项全部保留。D 新增失败 0，移除失败 0。Flutter 扩围保留 `v1013_root_entry_test.dart` 中的 `SessionNotifier.build` 编译错误和 `v1019_buddy_pages_test.dart` 的两条 Widget 失败（分页 403 后清除旧发现卡片、丢回包后的创建草稿与原命令）。两组全量或扩围结论继续为 `FAIL`。

## S01–S16 与 G01–G10

S 编号沿用历史 `UI-AUDIT-01` 屏幕清单。此处记录本阶段的具名自动化，设备复查全部 `NOT_RUN`。

| S | 页面 | D 阶段证据 |
|---|---|---|
| S01 | 首页与冷启动 | `PARTIAL`，Home 具名 Widget 与频道权限通过；真实冷启动 `NOT_RUN`。 |
| S02 | 匹配首屏 | `PARTIAL`，进展页读取、权限未知和现有合法会话分离通过。 |
| S03 | 每周慢约准备与参与 | `PARTIAL`，具名 PHP/Widget 覆盖授权拒绝、确认、过期及同键回执。 |
| S04 | 匹配历史 | `PARTIAL`，原候选绑定、当前权限重读、已终结提案不出现操作。 |
| S05 | 我的首屏 | `NOT_RUN`，本次未运行整屏。 |
| S06 | 持续参与与自动化 | `PARTIAL`，A+B+C+D PHP 组保存/拒绝及进展入口。 |
| S07 | 权限与说明 | `NOT_RUN`，本次未重跑该整屏；对象级删除另见 G07。 |
| S08 | Lifestyle 完成摘要 | `PARTIAL`，五场景完成、重入与摘要测试。 |
| S09 | Lifestyle 改选题页 | `PARTIAL`，2× 文字、键盘、选中语义、返回、减少动效与不完整回执停留。 |
| S10 | 会话列表 | `PARTIAL`，会话资格及旧账号保留列表缓存回归。 |
| S11 | 会话详情 | `PARTIAL`，当前会话条件、私有缓存和迟到响应测试；真实跨端交流 `NOT_RUN`。 |
| S12 | 站内通知 | `PARTIAL`，当前、待办、历史、截止期、难以确认回包、系统 Back 和 2× 字体覆盖。 |
| S13 | 好友社区 | `PARTIAL`，当前作品受众、Block、评论通知和媒体读权回归。 |
| S14 | 社区发布 | `PARTIAL`，默认受众、扩大影响确认、拒绝与失权回归。 |
| S15 | Buddy 主页与管理 | `PARTIAL`，具名 Buddy Widget 与 API 通过，扩围旧失败保留。 |
| S16 | Buddy 发现与筛选 | `PARTIAL`，具名发现 API 回归；扩围分页 403 Widget 保留 `FAIL`。 |

历史截图清单 `UI-AUDIT-01`，候选 `10.1.18-dev / 1011804`，原报告 APP 源码 `1afa6940c37bc1b40aa3d05ea46fb47002f6455c`。本次只读 36 条历史清单，Git blob `f32bd04607b024a7f44cd2fd67f45f05d7da8581`，当前本地清单 SHA256 `3e08fdb838e8edc4fc414ca764ce47a424ba85618eea385f904c5a691e7a29ee`。另行跟踪的 43 份原 PNG 为 `PENDING_BINARY_UPLOAD`，F-01 为 `READABILITY_PARTIAL`。[历史清单](../../../workflow/ui-current-state-audit-20261116/SCREENSHOT_MANIFEST.json)

| G | D 本轮具名结果 | 仍未闭合 |
|---|---|---|
| G01 | `PARTIAL` · 签名 TEST_ONLY、真实身份未配置时拒绝、候选回应资格 | 真 KYC `NOT_RUN` |
| G02 | `PARTIAL` · 首页双域、作品受众、Block、媒体与预览回归 | 访客实际正文仍空，真实素材授权 `UNKNOWN` |
| G03 | `PARTIAL` · 历史评论原受众、撤回/隐藏与引用拒绝回归 | 全量历史数据迁移和真实跨端 `NOT_RUN` |
| G04 | `PARTIAL` · 独立用途、期满、撤销及主页外显拒绝回归 | 真实用途依据 `UNKNOWN` |
| G05 | `PARTIAL` · 更正后相关草稿与动态盘来源重新核验 | 旧数据权属及外部核验 `UNKNOWN` |
| G06 | `PARTIAL` · 原候选绑定、历史权限、UNKNOWN 与展示资格回归 | 真实跨端状态传播 `NOT_RUN` |
| G07 | `PARTIAL` · 本人对象匹配，拒绝假受理和完成，合成请求回归 | 真实受理 `REQUEST_CHANNEL_UNAVAILABLE`，法域与备份范围 `UNKNOWN` |
| G08 | `PARTIAL` · 切号、迟到回包、通知/待办、Block、旧定位和返回 | 跨设备权限时效 `NOT_RUN` |
| G09 | `PARTIAL` · 隔离的关系正向片段、拒绝、过期、最小站内投影 | 真实 KYC/Push/RTC 和设备链 `NOT_RUN` |
| G10 | `PARTIAL` · 具名页面大字、语义、焦点、Back、减少动效 | 实机辅助技术、正式 A6、原图回读与发布 `NOT_RUN` |

## 保留与交付停点

PHP `~8.4.0`、MariaDB 驱动/迁移回滚/锁并发、真机和模拟器、真实数据及生产数据库验证均 `NOT_RUN`。实际对象删除受理与法务处理依据继续开放。原 1011804 与 UI-AUDIT-01 的 `FAIL/UNKNOWN/NOT_RUN` 沿用历史报告。旧排盘兼容保留待 Owner 裁决。

`PHASE_D_PARTIAL / OWNER_FINAL_PENDING / INTERNAL_CANDIDATE_PARTIAL / PRODUCTION_NO_GO / A6_MEETING_DEFERRED / RELEASE_NOT_AUTHORIZED`
