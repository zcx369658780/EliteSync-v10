# EliteSync V2 功能闭环与软著、封闭内测候选质量报告

2026-11-21 · **本地隔离具名链通过 · 核心功能整体 PARTIAL · 封闭内测候选未达标 · PRODUCTION_NO_GO**

本轮在 PHP 8.4 / MariaDB 10.11 上补通了两端 Flutter 文本私信及撤销，验证了独立 Web 后台的用户停用、形象审核、举报分流和审计，以及 Buddy 从草稿到发现、申请、确认和退出的接口与数据库链。正式慢约与关系闭环、当前版本 Android 整机回归、更多媒体及设备级失权证据仍缺。 [Owner 决定](https://github.com/zcx369658780/EliteSync-v10/blob/536dad49bbe6c7534ff2a3ecb313c8b6a29fc842/docs/decisions/OWNER_V2_FUNCTION_COMPLETENESS_BEFORE_SOFTWARE_COPYRIGHT_AND_CLOSED_BETA_20261121.md) · [集中任务书](https://github.com/zcx369658780/EliteSync-v10/blob/536dad49bbe6c7534ff2a3ecb313c8b6a29fc842/docs/versions/v2/V2_FUNCTION_COMPLETION_TO_SOFTCOPYRIGHT_AND_CLOSED_BETA_CONSOLIDATED_BRIEF_20261121.md)

## 工程及运行身份

- 隔离工作树 `D:/EliteSync/development/v2-cloud-r0-20261121`，origin `zcx369658780/EliteSync-v10`，分支 `codex/v2-function-completion-20261121`。起手 HEAD `2763127e6a0eb7e72f08577c4410e7c49c059083`，暂存区空，工作树有五份本任务续作。固定源码 `63a2bbf24c4dff9b892ef94ba99dd34d0888f226`，`apps` 树 `fe1bd34dca8e61553c8e236755365bb7dfcd07bc`，`services` 树 `99dc8145670a18cd2a0f37cc8c86e11098a3912c`。治理 HEAD `536dad49bbe6c7534ff2a3ecb313c8b6a29fc842` 与 origin 治理分支一致，工程承接 R1 `585a8c21aeab103daac166338f881ef343c8af99` 和 R0 `9baa82aa0cdf947dcc4996d2a584c92e4f4535f1`。旧脏 `main`、旧工作树和原证保留。 [固定源码](https://github.com/zcx369658780/EliteSync-v10/commit/63a2bbf24c4dff9b892ef94ba99dd34d0888f226)
- 专用 WSL Docker 项目 `elitesync-v2-function`。后端镜像构建自 `2763127e`，本轮固定源码后端运行文件与该镜像来源一致，后续后端目录变化限于烟测脚本。PHP 8.4.28、Laravel 13.39.0、MariaDB 10.11.19，预检 `elitesync_v2_function`、server ID `2621121`、116 表，先前重启核实 92 条迁移。Nginx HTTPS 仅 `127.0.0.1:18444`，FPM 与 DB 无宿主端口，数据网络为内部网络。APP 联测使用 Windows Flutter 测试宿主、合成账号和受信本地 TLS 证书。收尾核实三个测试容器退出码均为 0，两个测试卷保留。 [隔离配置](../../../../services/backend-laravel/docker/cloud-r0/compose.function.yaml) · [R0 运行证据](V2_CLOUD_R0_ENGINEERING_REPORT_20261121.md)

## 功能和差距

`DONE` 限本行具名链。S01–S16、G01–G10 只增加下表所列实际覆盖，未提及的细项沿用 Q/R1 的历史状态。 [Q 矩阵](../q-20261120/V2_Q_ENGINEERING_REPORT.md) · [R1 报告](../q-20261120/V2_Q_R1_ENGINEERING_REPORT_20261121.md)

| 优先级与入口 | 状态 | APP、API、Web、数据库证据及下一验收 |
|---|---|---|
| P0 注册、登录、退出与资料；S05、G01、G08 | PARTIAL | 合成注册、登录、在线 session verify、本人资料保存和重读通过 HTTPS，捏造已认证字段无效，退出后旧凭据 401，Web 停用后旧会话 401。仍需在当前 APK 验证真实页面注册、切号、资料和冷启动。 |
| P0 我的 → 独立手填三盘；S05、G04 | PARTIAL | `POST/GET /profile/natal` 已知时刻得到八字、紫微、西占结果，总状态 `COMPUTED_UNVERIFIED`。未知时刻保留空值，西占 `UNKNOWN`。覆盖版本冲突 409、账号隔离、MariaDB 读回，沿用 R0 缺依赖时 503 与恢复证据。Flutter 覆盖页面入口及会话失效；当前 APK 完整录入与历史结果验收待做。 |
| P0 慢约匹配、持续参与、候选与正式 Relationship；S02–S04、S06、G01、G06、G09 | BLOCKED / PARTIAL | 无真实身份的手动报名 HTTP 403，旧候选和资格重验沿用 A/R1 的具名回归。正式认证、正式自动参与、有效发布轮次、匹配后关系端到端 `NOT_RUN`。隔离 Connection 从已建立的合法虚构好友上下文起步。 |
| P0 Connection → 双方消息同意 → 双端文本及撤销；S10、S11、G08、G09 | DONE（本地具名文本链） | 两个 Flutter 账户使用实际路由、页面和 API 客户端，经真实 HTTPS 完成请求、接受、发信、收信和撤销。收件方 GET 返回发件方回执同一 `message_id`；旧深链服务端 404 且界面无正文。API 另证仅好友或仅 Connection 不可发送、过期修订 409、跨账号 404、同键重放、撤销和 Block 后不可读写。MariaDB 单独重启后保留加密消息及唯一请求键、读取与发送两项授权已撤销。 |
| P0 首页、好友社区和旧评论受众；S01、S13–S14、G02–G03 | PARTIAL | Home/Progress Widget 继续校验当前资格。HTTPS 验证好友作品、评论及首页读取，后加好友可读当前作品但旧评论 404，Block 后作品与评论 404。当前版本真实 APP 发布、图片/视频及缓存跨设备，访客授权正文仍待验。 |
| P0 Buddy 管理及发现；S15–S16 | DONE（隔离 API/DB 链） / PARTIAL（APP） | Widget 覆盖入口、翻页拒绝和迟到。HTTPS 验证草稿不可被第三方读取、发现需主动开启、发布卡最小暴露、申请与确认，同键单行落库。退出后发现 403，旧活动保留终态且隐藏主题。当前 Android 发布与参加链待验。 |
| P0 站内通知、待办、旧深链；S12、G08–G09 | PARTIAL | 授权时有最小消息导航，撤销与 Block 后历史通知无可导航载荷。当前版本通知页到深链的设备级传播、待办办理与真实 Push 待验。 |
| P0 独立 Web 管理后台 | DONE（具名 Web 链） / PARTIAL（全后台） | 真实 Web 路由、HTML 表单、CSRF、会话和同一 MariaDB。来宾/名单内非管理员拒绝，合成管理员登录、审核形象、查看举报并分流、停用账号、查看审计、退出失权均覆盖，旧版本动作 409。审核不直接发布，用户本人确认才生成公开快照。MariaDB 核对审核、发布、停用、举报与审计。全配置、更多审核策略和真实管理员身份未验。 |
| P1 权限说明、Lifestyle、数据用途和删除；S07–S09、G04–G05、G07 | PARTIAL / BLOCKED_EXTERNAL | 沿用已固定 A–D/Q 的 UNKNOWN 禁自动重发、用途隔离、纠错、删除入口及技术拒绝合同。真实受理渠道、历史和附件范围、完整离线/弱网业务回归仍缺。 |
| P1 主要 UI、启动、导航、辅助技术；S01、S05、S07、S09、G10 | PARTIAL / NOT_RUN | Connection 回前台重新取得权限，无当前资格时隐藏旧操作。Q 旧机证据仅适用原包。当前 APK、Android 宿主与 Flutter API 同源绑定、冷启动/切号、2× 文字/辅助技术、真实双设备消息及媒体均待具名验收。 |

## 主要改动和证据

- 服务端新增仅供隔离合成测试的 Connection 对授权。固定本机 HTTPS、专用 staging 配置和 MariaDB 实例身份，要求双方为同批次、启用状态的虚构账户，由服务端命令登记四小时有效的配对及撤销。保留双方同意、Block、版本以及同键去重。正式匹配、真实身份和正式 Relationship 的权限独立，本地配对只支持文本，附件被拒，WS/RTC 不启用。生产环境、旧 R0 库、非回环来源设置、关开关均不能建立该授权。 [源码与迁移](https://github.com/zcx369658780/EliteSync-v10/commit/9feaa10a7581de814344bf203397cd9ca268cb4d)
- Flutter 在刷新隐式对象时重读当前提案，切换对象和前后台时取消请求并清除旧投影。恢复前台重新向服务端取权；无权时关闭消息入口并给出不可用提示。通知以当前关系读权计算最小投影。 [页面](../../../../apps/flutter_elitesync_module/lib/features/connection/presentation/pages/live_connection_page.dart) · [两端联测](../../../../apps/flutter_elitesync_module/test/features/connection/live_connection_https_integration_test.dart) · [HTTPS/Web 烟测](../../../../services/backend-laravel/docker/cloud-r0/function-smoke.py)

原始日志及 JUnit 位于本机 `v2-cloud-r0-local-runtime-20261121/evidence`。下列是脱敏索引。

| 证据 | 实际结果 | 本机日志及 SHA-256 |
|---|---|---|
| Dart 静态分析 | exit 0，4 文件无问题 | `function-dart-delivery.log` `80443cd6b98fc2558d9998a386f4887a31dba9c78b665ebc1ead7295dda723c8` |
| Flutter 定向与相邻 | 本次 Connection/Home-Progress 39 项 exit 0；此前同一产品源码含 Buddy 和三盘会话保护 125 项 PASS，会话回归另 37 项 PASS。计数有重叠 | `function-widget-delivery.log` `7b60d8188780de1814c3e6b9e0e4b80392a1a7e514ca89585bdb6bdd8ffb6541`；`function-flutter-accepted.log` `2c9152c72564b6eed8282f3a2871243a220849da396254c1798c991d0c09e4ec`；`function-livechat-regression.log` `4cb8635087d612f368b5068362e132a72d991e5e0dc1511b8b2d9df37675edbc` |
| Flutter 真实路由 + HTTPS + MariaDB | exit 0，1 项。同 ID 读回、撤销后旧深链 HTTP 404。会话注入真实合成 API 凭据，存储为测试内存，websocket 关闭。此前单独 MariaDB 重启读回有独立记录 | `function-flutter-live-delivery.log` `e0a0201b60814640b2321a5e0a0a7533e6464375c752a4988729d70df6680f88`；`function-app-db-accepted.log` `684bd7ec3eae03eb5009f4c2188fbe92112a1c15f6c59f98ec07abc1830b16c6` |
| HTTPS API / 实际 Web 表单 / DB 查询 | exit 0，126 条具名 HTTP 状态验对，并通过持久化断言。专用环境、停服和卷保留预检 exit 0 | `function-smoke-expanded-delivery.log` `67c91b93cd76f2ee6ebd4b8d218e00a2e5b21cc6743b82c59417364d727327a7`；`function-isolation-delivery.log` `8f58a4a5415c2e07d5908aa3dfc23b4d78702b155bfd046fa7b5b2f8275d5401` |
| Fixture 运行边界 | 生产环境、旧 R0 库、非回环与禁用开关各次期望拒绝，控制台 exit 1 | `function-scope-gates.log` `2d56c5d1d677321cf8fd429b74b1894d6fef989f7f9fc829b2756c1c23055dce` |
| PHP 挑选回归对照 | FAIL。当前版与 R0 基准各 46 项、120 断言、12 FAIL，逐项失败名及断言签名一致。旧 Web 登录/续期出现 500/401，旧 Connection/通知夹具建立候选出现 409。当前真实 Web 烟测通过对应独立场景，PHP 回归失败仍开放 | `function-phpunit.xml` `a0d98da28928a67990af47d2cac9ac4a616f6c5c081f767611458515cc3267c9`；`function-phpunit-baseline.xml` `f2c99836a5e019ae16df11a17110da87b8b6aeed3ea25695fcf97906ff2ba491` |

全量 PHP/Flutter 本轮 `NOT_RUN`。历史 Q PHP 全量 46 errors / 122 failures（含旧排盘 25 FAIL）、R1 未关闭的 Flutter 扩围 5 项、1011804 历史 FAIL/UNKNOWN/NOT_RUN、F-01 `READABILITY_PARTIAL` 与原 43 PNG `PENDING_BINARY_UPLOAD` 均沿原记录。调试前置失败的 Flutter 日志、首次 DB 查询 exit 2 和跨 WSL 路径不可用的脚本启动 exit 2 均留存，后续通过结果对应上表具名日志。G0b 原文留本地，网页顾问独立原文审阅仍待；既有云端和备份证据可追溯。 [Q 实机原记录](../q-20261120/V2_Q_PHONE_TEST_REPORT_20261120.md) · [R0 工程回执](V2_CLOUD_R0_ENGINEERING_REPORT_20261121.md)

## 软著材料与内测准入

- 软著目前有固定工程源码、页面及管理功能目录、集成证据和第三方依赖清点入口。可从 `pubspec.lock`、`composer.lock` 与三盘 notices 追溯版本及许可资料。候选定版后仍需对齐软件名称/版本与安装包、编制操作手册和对应截图、确定源码材料范围，并请 Owner 确认权利主体、原创/委托权属及素材来源。登记申报、签名和缴费 `NOT_RUN`。 [Flutter 依赖](../../../../apps/flutter_elitesync_module/pubspec.lock) · [后端依赖](../../../../services/backend-laravel/composer.lock) · [排盘许可资料](../../../../services/backend-laravel/resources/natal/notices)
- 封闭内测还缺 P0 核心待验项的当前 APK、受控后端绑定和具名 Android 验收，重点是冷启动、切号、三盘、媒体/旧深链、离线恢复和受众撤销。还需说明参加人员、设备、账号、数据、告知、外部能力可用范围与停止条件。实名 KYC、真实 Push/RTC、真实用户或管理员资料及真实删除受理尚无本轮证据。正式封闭内测、正式 A6、main 合并及发布均 `NOT_RUN`。
- Owner 集中裁决仍为旧排盘 A/B/C 兼容路径，以及注册可信离线 T0 的 P1 合同；按当前合同保留独立手填和正式准入拒绝。今后若安排候选机验，需具名设备与环境授权。云迁移继续按 Owner 的功能优先顺序后置。
