# EliteSync V2-Q｜集成质量与产品决策收口：独立顾问集中限定验收

日期：2026-11-20（Asia/Singapore）  
**顾问结论：`V2_Q_ADVISOR_SCOPED_ACCEPTED_WITH_RESERVATIONS` / `EXPANDED_INTERNAL_CANDIDATE_PARTIAL` / `PRODUCTION_NO_GO` / `OWNER_FINAL_PENDING`**。  
不构成Owner最终接受，不授权旧星盘产品策略/T0新法律解释、真实设备、正式A6、供应商、生产/共享DB、main合并或对外发布。

## 1. 固定工程身份和证据分层

- 前一阶段D交付：`40ba853a3e9fed9062e8527b22c0b8ca9471e9ce`；Q最终测试源码：`5e457fb0fd21c5978864f146d78120cc9a7d025b`；Q最终交付：`b35f6d0aa43a80e648143a30fbb17a91c2bf922a`，分支`codex/v2-q-integration-quality-20261120`在本次读取时指向交付SHA。
- GitHub独立compare：D→Q前进5提交、落后0、merge-base等于D；Q源码→交付仅前进1提交，新增[Q工程报告](https://github.com/zcx369658780/EliteSync-v10/blob/b35f6d0aa43a80e648143a30fbb17a91c2bf922a/docs/versions/v2/q-20261120/V2_Q_ENGINEERING_REPORT.md)，没有后置源码改动。
- [Q固定综合报告](https://github.com/zcx369658780/EliteSync-v10/blob/b35f6d0aa43a80e648143a30fbb17a91c2bf922a/docs/versions/v2/q-20261120/V2_Q_ENGINEERING_REPORT.md)已实际阅读全文；其214条历史失败清单已在报告文本独立计数核对：**B189条+C25条=214条**；在相同D辅助环境下36条恢复PASS，随后Q环境下另10条PASS，仍FAIL168。不能把报告脚注等同于独立JUnit运行。
- `CODEX_REPORTED`：Windows实际工程root、origin、branch、dirty/index，三棵保护树、PHP/Flutter执行命令退出码、本地日志与SHA256及真实开发环境隔离；网页GPT不能直接核验Windows磁盘和原始JUnit日志。GitHub固定差异、关键Laravel/Flutter代码、若干原始测试断言是`ADVISOR_SOURCE_SPOTCHECK`。

## 2. 全量与具名的数学核对

| 证据节点 | PHP用例 | errors | failures | errors+failures | 结论 |
|---|---:|---:|---:|---:|---|
| D原工程报告 | 1498 | 83 | 131 | 214 | FAIL |
| 相同D源码补齐归档环境 | 1498 | 48 | 130 | 178 | FAIL |
| Q固定源码在同类辅助归档 | 1500 | 46 | 122 | 168 | FAIL |

- **环境恢复36**：D原归档缺Git题库和Blade编译目录，Q按相同源码、补齐题库/运行目录重跑后，35 errors+1 failure不再复现，非生产源码修复。
- **测试夹具/断言恢复10**：Q修正真正设备会话测试凭据、消息通知计数的前置基线、会话列表SQLite完整schema、迁移回滚的依赖顺序等，2 errors+8 failures不再复现。顾问直接见到修改的`AuthPasswordApiTest.php`、`V1015MessagingTest.php`、`ConversationListPeerFilterTest.php`、`MatchingFoundationServiceTest.php`及相关反例断言，但未重新计算私有JUnit。
- 新增两项PHP通过用例（报告：1500 vs D1498），新增失败0为**CODEX_REPORTED差异对照**。仍未解决的168条不是“可归档为全部已知无害”的证明。
- PHP具名：`CODEX_REPORTED PASS` 190项/2402断言；Flutter具名396项、Buddy/Status扩围77项、v1013构建条件5项、v1017构建条件31项、Dart改动26文件0问题均为`CODEX_REPORTED PASS`。Flutter全仓、PHP8.4、MariaDB、真实设备均NOT_RUN。构建条件Widget PASS不等于APK/设备PASS。

## 3. Q0–Q4独立抽查和限定判断

| 部分 | 顾问判断 | 验证情况 |
|---|---|---|
| Q0基线/历史明细 | **SCOPED_PASS FOR AUDITABILITY** | D→Q真实Git祖先和源代码→报告锁定，214条附录表存在且B/C数量可独立计算；测试命令及私有日志SHA属Codex报告。 |
| Q1旧星盘25项 | **PARTIAL / OWNER_CHOICE_PENDING** | 报告明确继续25 FAIL，当前旧`POST /profile/astro`无合法用途返回409；D已提供当前APP独立本命手填入口。A有界升级、B正式退役、C合法有界兼容桥均未获Owner选定；不得暗自开旧跨用途计算或改断言宣称零失败。 |
| Q2 Flutter3条扩围 | **SCOPED_PASS** | `v1013_root_entry_test.dart`同步`SessionNotifier.build`和v1013构建路径测试；`buddy_discovery_page.dart`已知403提示映射；`buddy_page.dart`保留不可变原命令，先GET`/buddy/activities/create-result`核对仅NOT_APPLIED才重发，APPLIED/UNKNOWN/CONFLICT/403不作新写；`v1019_buddy_pages_test.dart`覆盖老内容失权、迟到回包、账号切换、同键重试正反例。Laravel `BuddyService::createResult`读当前身份和actor/key的命令kind，响应仅状态，`BuddyController`加no-store，`V1013BuddyCommunityTest`覆盖匿名、他人、伪actor、同键查询、非create键冲突和无新增活动。无真实MariaDB多连接竞态或进程被杀后草稿恢复证据。 |
| Q2 PHP高风险旧失败 | **PARTIAL** | 具名密码改密、真实令牌夹具、原消息单次通知/撤权、旧候选无权投影与依赖迁移正反例有源码断言；全量仍168 FAIL，真实RTC/媒体、匹配旧合同、工具依赖不可以转为PASS。 |
| Q3环境/回归 | **SCOPED_PASS FOR ISOLATED PATHS / OVERALL NOT_RUN** | PHP8.5.3+SQLite `:memory:`与Flutter虚构Widget路径可审；PHP声明`~8.4.0`但8.4未运行，MariaDB真实索引/锁/回滚、设备和真实跨端传播NOT_RUN。 |
| Q4准入账 | **SCOPED_PASS FOR DOCUMENTED LEDGER / RELEASE NO_GO** | 三层资格明确，S05/S07本轮未跑整屏，G/S均保留PARTIAL/NOT_RUN；实人身份、真Push/RTC、法律用途/删除真实受理、`public_editorial=[]`、原43PNG和F-01未闭合，不产生发布许可。 |

## 4. 新发现/主要阻断：注册T0合同冲突为具名P1

可直接核实的两条互斥规范事实：

1. 旧冻结`docs/versions/v10.1.5/task_order.md`的B4明确提出：**真实成功在线login才生成可信T0；注册、refresh、APP重启及资料更新不能偷换T0**。现行`V1015TrustedLoginTest::test_registration_does_not_create_a_successful_login_or_offline_receipt`断言register响应`session_retention=null`并且`device_sessions.trusted_login_at=null`。
2. Q最终`AuthController::register()`仍调用`DeviceSessions::issue($user, 'Mobile', true, device_id)`；`DeviceSessions::issue`为`successfulLogin=true`写入`trusted_login_at`，`retentionReceipt`可返回15/30天时点与设备绑定的可信留存回执；因此当前源码**注册被当作成功在线登录建立T0**。GitHub已看到Q最后一个源码提交将诊断候选的`issue(... deviceId: ...)`恢复成`issue(... true, ...)`，与报告“保留阶段D行为”一致。

这不是测试框架随意报错，也不能从较新`v10.1.15`阶段整体接受推断已独立推翻旧“注册不生成T0”具体合同。当前`V1015TrustedLoginTest`具名专项9项/1失败为Codex报告；源码明确支持此冲突。离线实际私有内容是否可见仍依Flutter持久化、当前设备绑定/密钥和真机条件，**设备端未验证，不能据此断言已经发生数据泄露**。

**顾问风险等级：P1产品与安全合同待Owner裁决**。推荐在真实离线资格合规证明前，区分“注册后允许当前在线会话恢复”和“生成受保护私有离线30天留存T0”两件事；首选不凭注册单独授予离线私有内容资格。该建议不是Owner已选。若Owner要求注册同时生成可信T0，须具名定义充分认证条件、服务端/设备证据、15/30天边界及全量相关测试如何更新，不能直接删旧负例。绝不允许在当前Q阶段借顾问验收自动修改涉及Owner原批准权利的核心注册行为。

## 5. 结论和Owner下一步

**结论：`V2_Q_ADVISOR_SCOPED_ACCEPTED_WITH_RESERVATIONS`**。Q的具名隔离源码/测试设计、Flutter3旧失败的修复机制及历史214逐条证据账可限定接受；但原始JUnit与Windows执行属于Codex报告，扩大内部候选仍PARTIAL，发布/生产仍NO_GO。

Owner的两个**独立产品决定仍待选择**：
- 旧排盘兼容主策略A/B/C（建议A有界升级，维持无许可409/独立手填；明确客户端版本和实际影响后再考虑B/C）。
- 注册后在线恢复是否可生成`trusted_login_at`，以及是否可因此授予15/30天可信离线私有留存回执（建议先作两层区分并安全保守）。如未决定，此P1继续OPEN且不放行真实离线内容。

**仍阻断扩大内测与生产准入**：PHP全量46 errors/122 failures、旧星盘25条、可信注册T0、PHP8.4/MariaDB、设备、真实KYC/Push/RTC、法域/删除受理、资源及正式A6。旧历史FAIL/UNKNOWN/NOT_RUN不倒改。无需重做A–D已接受具名验收；下一工作应由Owner先确认关键产品合同，再授权各自有界工程及真实环境验证。

本文件是**顾问验收**而非Owner终验或新工程/供应商/设备/main/发布授权。
