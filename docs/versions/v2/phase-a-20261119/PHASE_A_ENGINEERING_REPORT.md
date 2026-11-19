# EliteSync V2 阶段 A 集中工程交付

2026-11-19（北京时间）。结论：**A1–A4 已实施，`PASS_IN_NAMED_AUTOMATED_SCOPE / OWNER_AND_ADVISOR_REVIEW_PENDING`**。本结论限于下列自动化范围，不代表真实身份准入、设备验收或 V2 全部 G01–G10 通过。完成本批次后停止；B–D 不自动启动。

## 1. 授权与工程身份

- [Owner 正式授权](https://github.com/zcx369658780/EliteSync-v10/blob/bc1124ae0696fb4decac936eead6ce240f65eb9f/docs/decisions/OWNER_V2_ROADMAP_ACCEPTANCE_AND_PHASE_A_ENGINEERING_KICKOFF_20261119.md)、[阶段 A 合并任务书](https://github.com/zcx369658780/EliteSync-v10/blob/bc1124ae0696fb4decac936eead6ce240f65eb9f/docs/versions/v2/V2_PHASE_A_SECURITY_BASELINE_CONSOLIDATED_EXECUTION_BRIEF_20261119.md)、[固定交接](https://github.com/zcx369658780/EliteSync-v10/blob/0df5b9ca70be34e028fa7ad67f355ec68fe559b7/docs/workflow/SESSION_HANDOFF_20261119_ELITESYNC_V2_S1A_TO_PHASE_A.md)已回读；治理分支最新 ACTIVE_STATE/CURRENT_WORKFLOW 的授权顶部已核对。各文件 Blob 身份见 [机器可读摘要](evidence_summary.json)。未将旧 S1 一次性审计权限延长为本轮工程权限。
- 实际开发根：`D:\EliteSync\development\v2-phase-a-20261119`；分支：`codex/v2-phase-a-security-baseline-20261119`；origin：`git@github.com:zcx369658780/EliteSync-v10.git`。
- 唯一父基线：`1d8b485bf4f314d42431bb62a293a3fef9e9c8af`。后端提交：`c6ff7e4471287674db0f1caca851ba49cca238a4`；最终产品源码：`4e6a5be6dcb7095438fb0a815c7831b14ffb561b`。报告另提交，产品文件 SHA256 绑定上述源码。
- 起手和交付前只读核对：原 `D:\EliteSync-v10` 仍为 main / `4bebc8f394248e254c1368a06fbdee5d2c883301`，43 个已跟踪修改、213 个普通 porcelain 未跟踪条目，暂存区空；未对其改码、清理或切分支。S1 根仍为原分支/原 HEAD，已跟踪修改 0，暂存区空，两个未跟踪条目为既有 `%SystemDrive%/` 和交接文档。
- 为辨别旧失败，另从同一提交建立 `D:\EliteSync\development\v2-phase-a-baseline-20261119`，只用于隔离自动化对照；未移动旧工程或历史资产。

## 2. 实现与正反例

| 范围与合同 | 实际实现 | 已运行的正向、拒绝与异常案例 |
|---|---|---|
| A1-AC1/2：正式身份门禁 | `TrustedIdentityService::participationAllowed` 在真实供应商缺位时拒绝正式参与。唯一测试特例要求 testing + SQLite `:memory:`、无 DB URL、注册的 synthetic 主体及有效签名凭据。门禁进入手动 opt_in、自动 grant/resume（旧回执返回前）、候选直接 freeze、查询/执行/揭晓链、提案 accept 及正式关系 confirm/resume。旧 `app:dev:run-matching` 在任何数据库动作前失败。 | 运营审核、realname 标志和旧自动授权回执不能产生参与；伪造签名、到期、撤销及 production 环境中的测试凭据被拒。真实轮次接受后撤销凭据，再复用旧接受请求仍被拒；旧 CLI 带 reset/release 参数零删除、零新增、零放出。 |
| A1-AC3：保留独立能力 | 不对 Lifestyle、私有资料、好友、Buddy、独立 Connection/消息许可做全局禁用。正式关系的独立联系请求不宣称已经实人核验，依赖身份的确认/恢复仍受新门禁。身份响应明确真实供应商 PENDING、正式参与不可用。 | Lifestyle 五场景、合法签名 TEST_ONLY 匹配、双方独立同意、暂停/结束、Buddy、收藏和私有照片回归通过。测试成功不表示真实 KYC 成功。 |
| A2-AC1/3：绑定原合法发布 | 揭晓事务一次性写 `candidate_showcase_bindings`，核对当时可读发布与 approved submission。只留自我介绍、兴趣/生活标签及原受众，记录发布版本、来源和 access_epoch；不复制证件、出生信息或照片。旧候选没有可信绑定时返回空材料，不从今天的发布版补录。 | 真实 save/submit/admin review/publish → 轮次执行/揭晓 → 新发布 → 旧候选 HTTP 仍读旧介绍；新候选绑定新版。缺绑定、过期、局外人、原审核失效均拒绝。 |
| A2-AC2/4、A4：每次重验 | 同时检查原受众、当前发布受众、Block、账号、提案与参与上下文。撤回或缩小发布受众推进 access_epoch。仅凭旧 Match 的普通资料/照片深链也检查绑定版本，不能升级到新发布；独立仍有效的好友授权可单独读取当前版。 | 撤回后重新发布不恢复旧绑定；Block/账号禁用/提案过期隐藏。真实私有照片当前有独立权限时可读；旧 revision、丧失独立授权后猜新版 revision、资料深链均拒绝。候选快照本身不输出媒体 URL。 |
| A3-AC1–4：UNKNOWN 先查询 | 新增受登录、账号和私有响应保护的 GET `profile/lifestyle-discovery/command-result`：按本人原请求键、规范化请求 hash 和当前版本返回 APPLIED/NOT_APPLIED/CONFLICT；查询不写入。客户端恢复 pending 只查询，查询未知不发送；确认未提交后才允许用户显式重试原键/CAS。SessionBoundPage 写异常清除可写投影，须 GET 后再决定；形象撤回异常须先刷新。 | 已成功丢回包、真实未提交、版本冲突、查询断网、冷恢复、查询期间切号、保存期间切号均覆盖；查询不会自动写。提案/报名失败后无旧可写按钮；发布撤回再次调用不会重发。只有确认保存成功才自动下一题的 Widget 回归继续通过。 |
| A4：原受众与缓存 | 新评论保存原有限读者集合，读取取原受众与当前作品/作者/Block 权限交集。历史 NULL 原受众不回填；无权详情 404，列表及分页计数不包含其编号、时间或正文。沿用现有账号代际、迟到回包及私有缓存保护。 | 老评论不可枚举；后来添加的好友不能继承旧评论；原有权读者可读，失去作品权后拒绝。切号、迟到响应、深链、媒体权限、加密缓存和附件发送定向测试通过；存储失败时禁止上传/发送。 |

尚无独立可读授权的 contacts-only 候选，在 PENDING 揭晓时不会取得快照，后续双方接受不补造历史授权，材料保持隐藏。此为保守能力限制；本次没有新增候选分享权或实现 NEW-PC-04。

## 3. 迁移与隔离环境

迁移定义：`2026_11_19_230000_phase_a_candidate_and_comment_authority.php`。新增候选绑定表、当前发布 access_epoch，以及可空的评论原读者字段；**不回填旧候选/旧评论，不执行批量清理**。up/down 仅在 SQLite 内存测试库运行并验证现有 users/match_proposals 保留。回滚会失去新权限证据，不能据此恢复旧版宽松读取；真实数据库应用与回滚均未执行。

实际环境为 PHP 8.5.3 CLI（进程参数启用 GD）、Laravel 13.39.0、Flutter 3.41.7、Dart 3.11.5。114 个已安装依赖的版本和 source reference 与本分支锁文件逐项一致，0 差异。首次依赖下载中断后，复用本机同锁文件依赖；没有更新锁文件。**根清单声明 PHP `~8.4.0`，PHP 8.4 运行验证仍 NOT_RUN**，8.5 的结果不能替代该兼容性证据。

PHPUnit 强制 testing / SQLite `:memory:`，`Tests\TestCase` 在迁移前检查有效连接配置，拒绝其它环境。接口验证使用真实 Laravel HTTP 测试内核和真实 SQL，没有监听端口、生产/共享数据库或外部供应商。私有照片写入测试专用临时盘；忽略测试生成目录。Flutter 使用单元/Widget 测试，无真机、模拟器、APK 构建或安装。

## 4. 实际验证与审查

| 验证集 | 最终结果 |
|---|---|
| PHP：V2PhaseASecurity、V2CandidateSnapshot、V2CommentAudience、V1017MatchingJourney、V10116UserStateAutomation、V10115LifestyleDiscovery、V1019SocialCommunity、ProfileShowcaseWorkflow、V1019BuddyDiscovery、ShowcaseJourneyAudience、V1012Journey | **110 项，1,429 断言，0 失败/错误，exit 0** |
| Flutter：Lifestyle、SlowDating、形象发布 controller、传输重试/迟到响应、私有缓存、媒体 URL、聊天权限及 retained-list/cache | **140 项，0 失败，exit 0** |
| 8 个受影响 Dart 文件静态分析 | **0 问题，exit 0** |
| 非作者 Codex 静态代码审查与修复复核 | 发现的旧 CLI 旁路、UNKNOWN 可再次写、评论元数据泄露三项已修复；复核无开放 P1/P2。不是网页顾问阶段验收或 Owner 终验。 |

原始同提交基线：PHP 78 项中 5 项失败，Flutter 两项缓存测试失败。修复的是测试夹具缺失的当前匹配输入、签名身份、显式撤回事实及加密草稿必须先确认的时序；没有取消失败断言、跳过测试或放松产品门禁。非作者复核认为该修正没有降低标准。基线与中途红测原件全部保留。

复现工作目录分别为本开发根下的 `services/backend-laravel` 与 `apps/flutter_elitesync_module`。PHP 命令为 `php -d extension=gd vendor/phpunit/phpunit/phpunit` 加上上表 11 个具名 Feature 文件；Flutter 为 `flutter test --no-pub` 加上本报告所列目录/文件。完整精确参数、测试结果及 SHA256 回执保存在本机 `D:\EliteSync\development\v2-phase-a-evidence-20261119`；可分享的计数、环境、源码哈希及原始结果哈希见同包 `evidence_summary.json`。原始日志和测试临时图片不上传 GitHub。

## 5. G01–G10 与保留风险

| 项 | 本次新证据状态 |
|---|---|
| G01 | PARTIAL：正式拒绝与签名 TEST_ONLY 自动化通过；真实核验接入/用户准入 NOT_RUN。 |
| G02 | PARTIAL：本批私有媒体与 Block 相关拒绝通过；完整首页双域、访客及搜索矩阵 NOT_RUN。 |
| G03 | PARTIAL：历史原受众未知隐藏、原受众交集通过；完整回复树/附件/第三方独立权利体系 NOT_RUN。 |
| G04、G05 | NOT_RUN：具名跨用途与派生纠错发布体系留 C。 |
| G06 | PARTIAL：原候选绑定、旧版重读、撤权和 UNKNOWN 刷新通过；完整 V2 发布体验未验收。 |
| G07 | NOT_RUN：对象级删除真实受理、完成回执及备份删除未实现/未运行。 |
| G08 | PARTIAL：相关切号、迟到响应、缓存及深链自动化通过；真实设备与跨设备失权实效 NOT_RUN。 |
| G09、G10 | NOT_RUN：本次未新增真实 Push/通知动态或原资产/设备视觉验收证据。 |

历史 `10.1.18-dev / 1011804` 的 FAIL、UNKNOWN、NOT_RUN 不改判；F-01 仍 `READABILITY_PARTIAL`，原 43 PNG 仍 `PENDING_BINARY_UPLOAD`。真实 KYC/Push/RTC、法域与留存依据、PHP 8.4、MariaDB 并发/真实网络、真机/模拟器及跨设备证据仍开放。

## 6. 工程建议与停止

建议 Owner 与顾问集中审阅本阶段候选：在上述保守默认和具名自动化范围内，可作为阶段 A 工程完成候选；不能据此宣称真实 Match/Relationship 准入或全面产品验收。Owner 终验与顾问阶段审阅均为 PENDING。

当前停止于本包交付。未启动 B–D、正式 A6、真实供应商、真实/共享数据库、设备、main 合并或发布；后续推进由 Owner 与顾问集中审阅后决定。工程分支备份与治理分支授权历史分开，不改写旧治理结论。
