# EliteSync V2 阶段 B 集中工程报告

2026-11-20（北京时间）。**B1–B4 具名隔离自动化范围 PASS，待顾问集中复核和 Owner 终验。** PHP 全量套件仍有基线失败，真实环境证据另列。

## 工程身份与授权

- 治理固定提交 `af7982de084023126409b1511e97e564f3ffe51e`。Owner 已终验阶段 A 的具名范围并授权阶段 B。适用依据为阶段 B 任务书、V2 集中路线图、阶段 A 顾问限定验收，以及 O01/O02、CMT-T1、HIS-D1、NEW-PC-01/02、EDGE-D1/D2 的具名规则。[Owner 授权](https://github.com/zcx369658780/EliteSync-v10/blob/af7982de084023126409b1511e97e564f3ffe51e/docs/decisions/OWNER_V2_PHASE_A_FINAL_SCOPED_ACCEPTANCE_AND_PHASE_B_ENGINEERING_AUTHORIZATION_20261120.md) · [任务书](https://github.com/zcx369658780/EliteSync-v10/blob/af7982de084023126409b1511e97e564f3ffe51e/docs/versions/v2/V2_PHASE_B_HOME_CONTENT_AUDIENCE_CONSOLIDATED_EXECUTION_BRIEF_20261120.md)
- 当前开发根 `D:\EliteSync\development\v2-phase-a-20261119` 复用既有依赖与源码，开发分支 `codex/v2-phase-b-home-content-audience-20261120`，origin 为 `git@github.com:zcx369658780/EliteSync-v10.git`。阶段 B 从 `950472d0` 派生，包含 A 产品源码 `4e6a5be6` 和交付 `07b51a6d`。阶段 B 产品源码 `f20f25ac8d0b70d9806295c62c0c3dd3e722a946`，含最后一项测试夹具修正的验收提交 `789764f9`。定向测试结束后产品工作区及暂存区为空。
- 两棵保护树的分支、HEAD 和工作区计数与起手核对一致。`D:\EliteSync-v10` 为 `main / 4bebc8f3`，43 个已跟踪修改、213 个未跟踪条目。`D:\EliteSync-v10-product-v1015-20261101` 为 `codex/ui-current-state-audit-20261116 / 1d8b485b`，2 个未跟踪条目。未跟踪数为普通 Git 状态口径，两处暂存区均为空。

## B1–B4 工程与权限证据

| 组 | 实现和具名结果 |
|---|---|
| B1 首页双域 | **PASS**。访客入口仅投影带显式访客批准与来源记录的官方标题和正文，运行配置当前为空。测试用匿名合成正文验证正例，并验证未批准专题和访客访问用户作品的拒绝。登录后精选列公开作品及仍可读的编辑推荐原作品，好友频道列当前好友作品。推荐通过原作品权限复核，按作品顺序读取。现有四个一级入口保留。 |
| B2 作品与评论 | **PASS**。默认 `FRIENDS + FRIENDS_ONLY`，`SELF` 强制关闭评论。SELF→FRIENDS 预览区分隐式 OFF、显式 OFF 与未知来源，以确认和版本校验提交。公开正文扩大受众后，历史评论与封面继续各自核权。发布按账号保存不含草稿的请求键，遇到不确定结果先权威查询。Widget 实测恢复请求键仅发 GET，未发生自动 POST。 |
| B3 评论分权 | **PASS**。评论者撤回与作品作者隐藏使用不同数据字段和操作权限，保留原文和独立回复。本人对已知评论 ID 的撤回独立核验账号、本人归属和版本，回执只含 ID、状态及版本，失去作品读权后仍可行使本人撤回。回复自身、父上下文和原受众均需通过核验，父评论隐藏后只保留经服务器验证可独立展示的固定回复文案，其余分支隐藏。评论者仅在合法上下文看到中性状态。评论提交不确定时先查询，确认未应用后由用户显式以原键重试。 |
| B4 当前权限 | **PASS（具名自动化）**。列表、详情、搜索、收藏、通知定位、媒体字节、引用与深链按当前账号、Block 和对应受众核验。旧评论原受众 NULL 隐藏，缺原读者记录的旧封面仅作者可读。新封面绑定原好友读者，共用媒体须至少有一条独立有效授权。旧通知点击重读通知与目标。Flutter 在前台与路由返回时重新取数。定向测试复核切号、权限代际变更、迟到回包和私有缓存。评论附件与任意引用入口依需保守拒绝。 |

阶段 A 回归覆盖签名 TEST_ONLY 身份隔离、原候选发布绑定、Lifestyle UNKNOWN 先查、历史评论原受众和旧缓存保护。阶段 B 的新正反例还覆盖作者和第三方先后操作、历史好友失权、后加入好友和晚注册账号、当前点赞撤销后的旧通知、重复点赞、分页丢弃受限项及真正文件字节授权。

非作者后端复核确认旧封面、回复撤回、共用媒体及关闭评论后的回复能力四条发现已闭合。后续发现的评论分页并发窗口采用重新读取提示，已有点赞重复请求仅返回当前状态。前者的 MariaDB 并发时序仍为 NOT_RUN，最终两处修改由主代理复查。

## 迁移与回滚

三份迁移新增作品策略及来源、受众版本和封面原读者快照，评论的原受众类型、父 ID 与分主体展示状态，以及发布原请求回执。旧行不回填权限。PHPUnit 在 SQLite 内存库实际验证迁移和有存量行的 down 路径。回滚将 B 公开作品及有封面的好友作品收紧到 SELF，并保留评论原文，将 B 中已撤回、已隐藏或带父引用的记录置为隐藏，清空 B 公开评论的快照。回滚将移除 B 阶段独立展示状态及请求回执，数据与状态保留范围须据此判断。MariaDB 实际迁移、回滚和更大受众规模下的表现为 NOT_RUN。

## 测试与基线差异

| 实际执行 | 结果 |
|---|---|
| PHP 具名阶段 A+B 回归 | **PASS，149 项 / 1,936 断言，exit 0** |
| Flutter 具名阶段 A+B 回归 | **PASS，226 项，exit 0** |
| 本次 17 个 Dart 文件静态分析 | **PASS，0 问题，exit 0** |
| PHP 全量 Unit + Feature 和阶段 A 固定源对照 | **FAIL（历史）**。阶段 A 基线 1,477 项、81 errors / 109 failures。B 交付 1,487 项、81 errors / 108 failures。按测试类、用例及失败类型逐项对照，零新增失败或错误，恢复 1 项旧评论状态用例 |
| Flutter Status 与 Buddy 扩围 | **FAIL（历史）**。顺序执行 65 项通过、3 条失败，分别为 1 条旧入口测试编译错误和 2 条旧 Buddy Widget 失败，均在固定阶段 A 源复现。修复了阶段 B 使用的社区分页测试夹具。 |

PHP 8.5.3、Laravel 13.39.0、PHPUnit 12.5.42、SQLite 3.49.2 内存数据库，测试入口会先验证有效数据库配置。Laravel 用真实应用 HTTP 内核，无监听服务器。媒体测试使用本地临时磁盘和虚构文件。Flutter 3.41.7、Dart 3.11.5 在本机运行单元、传输及 Widget 测试。

- PHP 具名组由 `php -d extension=gd vendor/phpunit/phpunit/phpunit --colors=never --log-junit <结果文件> <测试文件>` 执行。输入为阶段 A 摘要中的 11 个 PHP 文件，再加入 `V2PhaseBContentTest`、`V10114StatusVideoTest`、`StatusPostApiTest`、`V1013BuddyCommunityTest`、`V1011NoticeRevocationTest`、`NotificationApiTest`。全量两组在各自固定源码副本内采用同命令，去掉文件筛选并加入 `-d memory_limit=512M`。首轮 128 MiB 停在内存上限的记录已保存。[阶段 A 命令摘要](https://github.com/zcx369658780/EliteSync-v10/blob/07b51a6de9695f5358b6bea2a59acd5be24ab6c2/docs/versions/v2/phase-a-20261119/evidence_summary.json)
- Flutter 用 `flutter test --no-pub --reporter expanded` 运行阶段 A 摘要中的定向集，再加入 `test/features/status`、`test/features/home`、`test/features/buddy_v1013/buddy_pages_test.dart`。另用 `flutter test --no-pub --concurrency=1 --reporter expanded test/features/buddy_v1013 test/features/status` 扩围，并执行 `flutter analyze --no-pub <17 个变更 Dart 文件>`。
- 私有原始日志在 `D:\EliteSync\development\v2-phase-b-evidence-20261120`。核心文件 SHA256 如下。

| 日志 | SHA256 |
|---|---|
| `php-delivery-named.log` | `fe36775b913bc0d4c088f7f0ebc886371a5ee79683a8955cdfc327e7418b5252` |
| `php-delivery-named.xml` | `878f55372dee2b7da4a75f86e06413a055967099666587618afc2240bf39cc0e` |
| `php-baseline.xml` | `dd7a742fd7280e17e7285700e3dcaf404dc8df118993de0181912e42ac7718d1` |
| `php-delivery-full.xml` | `ce5f18535a588982d4fc74ffefe9b9e05218852394424026f2362206954aafdb` |
| `flutter-reviewed-targeted.log` | `e25ef0e62f2265988720f29f7d71f3c89a9f1b352dec1f826cdbdc8d765f94e5` |
| `flutter-expanded-serial.log` | `f62ee8a0dc5d796addfb98ae5f06a5fa35976d494a40dde3bed67dfa2ac1016a` |
| `dart-reviewed-final.log` | `1f74c19997e6dc474cc7eef8f9ccb6d5fd7b9122caf3df76cb81b5596a9226b2` |

## 保留状态

- G02/G03/G08 继续按具名测试子项记 PARTIAL。G01/G06 沿用阶段 A 的局部状态，G04/G05/G07/G09/G10 专项仍 NOT_RUN。旧 1011804 的 FAIL/UNKNOWN/NOT_RUN、F-01 READABILITY_PARTIAL 和原 43 PNG PENDING_BINARY_UPLOAD 沿用原记录。
- PHP 8.4、MariaDB 并发与真实迁移、真机与跨设备撤权传播、真实 KYC/Push/RTC 以及生产环境均 NOT_RUN。真实官方专题授权和第三方媒体授权仍待具名证据，访客实内容为空。真实申诉、对象级删除和跨用途治理仍在后续范围。
- 阶段 B 停在集中验收点。C/D 未启动，正式 A6 为 DEFERRED。main 合并和生产发布仍待相应授权。
