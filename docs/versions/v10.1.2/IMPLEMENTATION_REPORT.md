# EliteSync v10.1.2 实施交付报告

日期：2026-10-20。唯一冻结计划与综合任务由 Owner 手动派发；本报告只交付受控本地开发候选。

**V10.1.2_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE / NOT_YET_ACCEPTED / REAL_IDENTITY_PROVIDER_PENDING / V10.1.3_NOT_STARTED**

## 1. 固定对象与证据边界

| 对象 | 身份 |
|---|---|
| 开工、源码提交前与发布前 live main | `251f822392903804a0bdc12bf045756101939829` |
| main Tree | `39ac45c5440fef1b4318b9b7dfc0ce6781fdfdd5` |
| 冻结 plan Blob | `2ebd2ea05b3d7dae52cc3995de913eeb0fde375e` |
| 冻结 task_order Blob | `4f39db8e003da0889c7d23582652c0787c22bfea` |
| 最终产品源码 Commit | `ebade52179b6ac7b76ba2f2992d31981fa995a00` |
| 最终产品源码 Tree | `c037f294dde9ea9b696188393f0fff47bb6fe6b8` |
| apps | `9344354d0da95f0388aa922b2775b1e8d18f18b7` |
| services | `a0eb88caf5ed65451b56b5363b7af667dadd6fd6` |
| 产品候选分支 | `codex/v10.1.2-slow-dating-relationship` |
| 独立临时审阅分支 | `review/temporary-evidence-v10.1.2-20261020` |
| 最终审阅 Commit / Tree | `70e122ddfbaa2d89e6c46bb21fb49a8fe8ae44d4` / `b9ee92719e1ae4420e530b964321ffdbdef7c55b` |

[逐路径源码 Blob/SHA256、APK 和资源清单](artifact_manifest.json)固定41个产品改变路径；后续报告和入口文档提交不改变 apps/services。源码由 `917dbd8a` 主实现、`224ab490` 准备入口修正及 `ebade521` 到期授权修正构成，原提交/原失败均保留。未整体合并 v10.1.0 未接受分支。

本机真实运行、持久库、构建安装和 UI 观察均为 **CODEX_REPORTED**，不冒称 Astra 已读取 Windows 或独立重跑。[临时脱敏审阅包](https://github.com/zcx369658780/EliteSync-v10/tree/70e122ddfbaa2d89e6c46bb21fb49a8fe8ae44d4/docs/_temporary_review/v10.1.2-20261020)可以直接审阅；其117个文本文件包含脚本、最小原始流、屏障、派生摘要及原件/副本哈希。响应正文/实际凭据、SQL、APK、截图/XML、设备日志及私密配置均 LOCAL_ONLY。派生摘要不冒原始字节。

## 2. 实际实现及边界

### 2.1 准备、轮次和提案

复用现有 ProfileReadiness、问卷、Showcase、DatingRound/Run/Match 与真实 consumer。新增本人意图草稿、显式报名、暂停/退出/恢复代际；冻结候选时记录 participation_generation，Reveal 与双方决定再次核验。Showcase 是候选展示输入，不增设为本版额外强制报名门槛；运营 `approved` 明确不代表实人认证。

提案绑定 UUID、round/run/match、双方与报名代际、revision、服务器 UTC 揭晓/到期时间、双决策及 actor 幂等键。`journey.proposal_hours=168` 是本版开发默认，channel cadence 来自既有配置；未硬编码全站每周一次。一个用户一个未决槽由主键与协调用户锁守护。

持久状态为 `PENDING / ACCEPTED_BY_ONE / MUTUALLY_ACCEPTED / DECLINED / WITHDRAWN / EXPIRED`，各人决定另存。`ACCEPTED_BY_ME` 是按当前 actor 投影，不混成第三个用户事实。未决到期持久化 EXPIRED；已双选历史决定保留，但到期后清空 Showcase/解释并撤去**新 Match 衍生 CN 资格**。既有合法独立 CN/MC 不因 Match 到期而销毁；终结 CN 后的新生命周期必须重新具备当前有效来源。

旧 v1 Match confirm/like 写旁路统一 410；current/explanation 读取新授权投影。旧 history 暂返回安全空投影，数据库历史未删。这是兼容观察，不宣称恢复了历史浏览体验。v2 canonical synthetic evaluation 未转成真实用户写库入口。

### 2.2 独立 CN、MC 与正式关系

Match 双选只提供发起独立 CN 的资格。CN 双向同意、MC 双向同意、普通消息/附件/WS/RTC 授权继续分层。好友、请求接受、正式关系均不自动升级这些权限。既有合法 CN/MC 独立继续；Block 撤销联系及恋爱专属分享，解除 Block 不恢复。

新增独立 formal_relationships 聚合，状态为 `PENDING_MUTUAL / ACTIVE / PAUSED / SUSPENDED_REVERIFY / ENDED / DECLINED / WITHDRAWN`；没有行代表尚未声明。请求不替任何一方确认；激活必须同一 Identity、当前 revision、双方明确确认、两份非空有效服务端凭据。每人一个 ACTIVE 槽由 User 有序锁和数据库主键守护；这是受控开发默认，不宣称永久社会政策。

暂停/结束不要求对方同意或当下核验有效，不生成 Safety Finding，不销毁独立合法消息。暂停/认证失效清除双方确认；resume 先回到 PENDING_MUTUAL，再由双方逐次 confirm，不能自动 ACTIVE。结束/拒绝/撤回是终态，新申请产生新 UUID。认证绑定具体 credential ID；撤销后先补发新 credential 也不能暗恢复旧分享。

### 2.3 TEST_ONLY 身份适配

无真实供应商。签发仅在控制台、本版 local/mysql/loopback43323/指定库，或 testing/内存 SQLite，并要求独立开关、至少32字节私密密钥、`is_synthetic` 与 development_identity_subjects 登记。不存在 HTTP 或管理员签发入口。issuer/dataset/subject/nonce/revision/期限绑定 HMAC；nonce 重放、签名篡改、跨账号/切环境/客户端 verified 与旧自报关系不能激活。

未登记真实账号显示 PROVIDER_NOT_CONFIGURED / NOT_VERIFIED；APP 对替身显示 TEST_ONLY，绝不称真实身份认证成功。专用合成夹具中的“Real”标签只表示门禁负例，仍是虚构测试账号，不是导入真人。

### 2.4 字段合同与当前授权读

| 字段 | 持久值来源 | peer 受众条件 |
|---|---|---|
| birthday | users.birthday | 本人该字段 RELATIONSHIP_SHARED + 当前有效正式关系共享门 |
| interests | users.public_personality | 同上，按字段独立选择 |
| resume | users.relationship_resume，nullable，最多1000字符 | 同上；未提供/清空则遗漏，不造履历 |
| zodiac | users.public_zodiac_sign | 同上；不暴露原星盘输入 |

默认 SELF。共享门要求 ACTIVE、双向确认、双方绑定凭据当前有效、未 Block/禁用及当前账号权限；普通好友或 Match 本身不够。证件、精确生辰时地、原问卷/私聊、举报处罚及审计均不在该投影。新 `/privacy/resume` 是本人编辑；保存履历不改变受众。

JourneyStore 统一有序 User 锁、锁后 token/device session 再核验。事务外定位仅作为 hint，锁后重取并复核参与者；授权依赖采用当前锁定读取，不降低 RR 隔离级别。SocialPolicy、关系/身份/受众和幂等重放重新投影，不把先前响应缓存当权限。私密 API 使用 `private,no-store`。已下载的客户端像素不能承诺远程抹除。

### 2.5 APP 与 Web

Home 显示真实旅程摘要；Progress 组织 Match/Connection/Relationship；Me 的准备入口读取真实旅程，仍保留 Home | Progress | Messages | Me 四 Tab。新增旅程、正式关系与字段分享页面，可保存本人履历/草稿，执行各自明确动作；旧 synthetic/unknown 不能代替服务端事实。账号/授权 epoch 改变会清除草稿/peer 投影并丢弃旧响应。

Web 复用已有登录/RBAC/CSRF 和轮次操作，统一 default channel，提供轮次准备、排队、失败/重试、Reveal/关闭及最小只读审计；无代双方确认或实人认证按钮。候选 Showcase 完成真实 draft→submit review→本人 publication API；测试中的 approved 前置明确为 SYNTHETIC_REVIEWED_FIXTURE，**未实现或验证完整真实管理员 Showcase 审核流程**。

## 3. 迁移、独立库与持久性

新增迁移：

1. `2026_10_20_160000_create_slow_dating_relationship_tables.php`：participations、proposals/slots、development_identity_subjects、identity_assertions、formal_relationships/slots、journey_commands/audits；users.relationship_resume；matching_run_candidates.participation_generation。
2. `160001_bind_formal_relationship_credentials.php`：formal_relationships.credential_a/b，绑定双方具体凭据。
3. `160002_align_match_cadence_capacity.php`：dating_matches.week_tag 扩为120，匹配原 cadence_key 容量；回滚遇长值会拒绝截断。

唯一持久开发库 `elitesync_v10_1_2_dev`，MariaDB10.11，容器 `elitesync-v1012-journey-db`、新卷 `elitesync-v1012-journey-data-20261020`，仅 loopback43323。迁移前实核 local / effective selector mysql / 空库 / 无 URL/socket / 新归属容器卷，实际隔离级别 **REPEATABLE-READ**。普通 PHPUnit 继承 TestCase 的 RefreshDatabase 前置护栏，强制 testing/sqlite/:memory:；实际 APP_DB_CONNECTION=mysql 优先于 DB_CONNECTION=sqlite 的 probe 在任何迁移前被拒绝。

没有对旧库执行 migrate:fresh/db:wipe/seed。媒体兼容 adapter 名 `v1011_relationship` 仍在使用，但 root 解析到**本版专用树**的 storage/app/v1011-relationship-private，没有读写旧工作树媒体目录。

受控 DB/API/WS 重启前后14张关键表的行数与全值 hash 完全相等；重启后 HTTP/字段受众/实际 WS 再读成功。报名、提案、双选、关系与分享没有靠内存伪装持久化。最终新增四字段专项后另存完整恢复点，旧备份保留：

| LOCAL_ONLY 恢复点 | bytes | SHA256 |
|---|---:|---|
| before-restart | 391114 | `2f92ac80a078c392afe193fd511bf24478685e67e2495189f59f5cfcb43fae3c` |
| first-final | 446735 | `12306b0d1425536c22b6a4fae680159cc7b2a52ec3ba9372be8e6f06d0148bdb` |
| final-after-four-fields | 453438 | `70490c108ce90e3be7c0f31d617c7a30aa8f35a79f07c724da643a8b2c5c4f8b` |

## 4. AC-10.1.2-01～12 自测矩阵

PASS 只表示下述冻结开发范围的 Codex 自测结果；不是 Astra ACCEPTED，也不是生产或真实身份能力。统计不把单元、Widget、HTTP 与 DB 次数相加。

| AC | 自测结果 | 实际证明及证据标签 |
|---|---|---|
| 01 | PASS | main/冻结 Blob/接受产品基线接续；新库初始空配置；`db-selector-fail-closed`；四保护树最终逐字节一致。 |
| 02 | PASS | 真实20题/运营资格与实人区分；A/B 明确报名、暂停与恢复代际；Incomplete422/Disabled403；APP 保存草稿、暂停/再报名及重登代际3读回。`prepare*`、`app-*-api-readback`、`app-final-A-persistent-draft`。 |
| 03 | PASS | Web真实登录/CSRF→prepare/排队→既有 consumer→Reveal；APP/API waiting/无候选与错误分开；浏览器关闭、故意失败、retry与零候选揭晓。`web-round*`、`web-round-failed`、`web-no-candidate`、`matching-failure-observed`（实际FAIL）及 retry DONE。 |
| 04 | PASS | 隐藏未揭晓；真实双选、旧revision/错误actor/重放与旧v1写口拒绝；单未决槽、换代际与Reveal复验；两实际等待者只一个200另409。168h服务器期限使用明确进程内合成时钟验证，并验证持久EXPIRED不复活；`proposal-result`、`edges-result`、`expiry-mariadb-result`、Feature。 |
| 05 | PASS | APP实际解释类别/来源/限制，候选只取 canonical self_intro；私密后续draft不流入已发布投影；互选后消息仍404。`showcase-real-api-receipts`、`mutual-http-receipts`及 Feature。 |
| 06 | PASS | 独立CN/MC双同意后文字及合成PNG上传/发送/同bytes读回，实际WS连接；撤MC后5秒内WS关闭、旧JWT重连拒绝，消息/附件/content404，RTC发起403/旧join404。到期后原MC仍有效，关闭后不能借旧Match重建。`media-consent-result`、`expiry-mariadb-result`。RTC媒体本轮NOT_RUN。 |
| 07 | PASS（TEST_ONLY） | A/B 双有效签名凭据与双确认ACTIVE；缺一方、过期/撤销后补发、伪造/重放/跨号/非dev环境/旧事件拒绝；真实账号不可激活。`relationship-http-receipts`、`edges-result`及 V1012JourneyTest。真实provider NOT_RUN。 |
| 08 | PASS | pause→PENDING_MUTUAL→双方再次confirm→ACTIVE；任一end、旧Identity/revision409，新生命周期独立；并发同人两关系仅一ACTIVE、另一409。CN/MC不随普通关系退出销毁；`relationship-lifecycle-receipts`、`exclusive-result`、APP暂停与恢复API读回。 |
| 09 | PASS | 四字段实际单项选择都读回精确合成持久值，其余3项遗漏；SELF全遗漏，null resume遗漏；陌生人404。六组RR撤权及APP履历保存/单项收回再读；`supplement/four-fields-result`、`race-*`、`app-audience-revoked-readback`。 |
| 10 | PASS（获准AVD） | 实际 Home/Progress/Me→旅程/正式关系/分享；草稿/履历、暂停/恢复、切至Incomplete不残留A状态；未完成与未核验单列。APP离线显示Connection error且清除旧投影，API恢复后重读；挂起刷新期间退出后旧响应不复活；最终源码构建/安装/pull、A重登草稿读回。`app-offline-final`、`app-late2-response-result`、APK清单。物理手机NOT_RUN。 |
| 11 | PASS | Web轮次/失败/只读审计与普通角色拒绝；14表重启持久；Block404/disabled403/旧session401；虚构注销DELETION_PENDING、关系ENDED、资料拒绝、无新增举报；未物理erasure。71项范围回归与RR证据见下。 |
| 12 | PASS（候选交付） | 固定源码/41路径、三迁移、APK/签名/hash、真实分层回执、原失败/exit、非作者复核、公开脱敏副本和停止资源；普通non-force候选及独立GitHub回读作为交付门。Astra验收仍PENDING。 |

## 5. 真实并发、媒体和 APP 证据的证明范围

六组 RR 先以写方持有有序 User 锁，再让**真实 HTTP profile-peers 请求**进入，读取本版 MariaDB INNODB_LOCK_WAITS，保存 reader_pending=true/至少1个实际等待、writer-locked与committed屏障；之后提交撤权才放行响应。结果：受众SELF、关系pause、credential撤销且先补发后读均无深字段；Block404、disabled403、session401 SESSION_REVOKED。拒绝没有用500/死锁/进程异常冒充。初次Block脚本缺commit marker的失败另保留。

独占关系与并发提案专项均观察至少两个等待者；前者一个ACTIVE/200另409，后者一个200/ACCEPTED_BY_ONE另409。SQLite仅用于快速回归，未替代上述 MariaDB证明。

最后到期专项使用新的已登记虚构对与**实际产品服务**：无CN到期后新request404且零insert；已有CN/MC的live_send仍true；关闭CN后凭旧Identity/current revision再request404且总共仅1条CN。`hasContext()`保留终态CN用于历史/关闭响应；新生命周期已有独立来源门，新增测试首跑即通过，没有伪造红测。

APP晚响应专项只读持有本版合成用户锁，发起刷新后通过实际UI退出，再释放旧请求；登录页没有被旧结果复活。首版自动脚本误点对话框标题，未完成退出，exit1；第二版精确控件选择后exit0。它与后端RR专项分别陈述，不拿UI观察冒数据库锁等待证明。

媒体是实际授权与WebSocket撤权验证；RTC只验证权限入口。没有本轮RTC媒体房间、音视频、真人听感或手机测试，继承此前接受证据不声称新APK重测。同call历史证据及原UDP窗口全部保留，不续期。

## 6. 测试、退出码和原失败

| 最终检查 | 实际结果 |
|---|---|
| scoped PHPUnit：V1012JourneyTest、V1011 Social/Account/R1/Revocation/Notice、MatchingFoundation、ProfileReadinessTruth | `feature-expiry-final-regression`：71 tests / 713 assertions，exit0；仍有2 Deprecations + 2 PHPUnit Deprecations。 |
| 集中审查后补充回归 | `feature-review-regressions`：11 tests /150 assertions，exit0；不与上一行加总。 |
| Flutter新页及受影响Home/Progress | `frontend-final-tests-04`：39 tests，exit0。新页面自身9项包含账号/授权变化、晚响应及失败peer重读清空。 |
| scoped Flutter analyze | `frontend-final-analyze-04` 与 readiness route final analyze：exit0。 |
| 改变PHP文件lint | `php-lint-02.json`：28文件exit0。初版11个路径定位错误另保留。 |
| 真实受控专项 | RR六组、exclusive、proposal、精确edge、expiry02、四字段HTTP、APP晚响应02及重启均保存实际流/exit与结构断言；不计算虚构总通过率。 |
| 最终离线Android构建/安装 | `apk-ebade521-build` 与 `apk-ebade521-install`：exit0。UP-TO-DATE任务合法复用相同客户端输入，不宣称清空重编了全部依赖。 |

核心后端命令为 `php vendor/phpunit/phpunit/phpunit --filter 'V1012JourneyTest|V1011SocialTest|V1011AccountSecurityTest|V1011R1AuthorizationTest|V1011RevocationTest|V1011NoticeRevocationTest|MatchingFoundationServiceTest|ProfileReadinessTruthApiTest' --colors=never`，有效配置始终testing/sqlite/:memory:。真实专项通过独立guard脚本操作指定新库，不走RefreshDatabase。

原失败按形成顺序保存，以下不是清零后的“首跑成功”：

| 标签 / exit | 原失败与处置 |
|---|---|
| feature-v1012-01 /1 | 预期409实际422；修正合同断言，02为7tests104assertions/0。 |
| feature-regression-01/2、02/1、03/2 | view cache目录、readiness/旧privacy投影断言及SESSION_REVOKED夹具问题；04为66/638/0，后续最终71/713/0。未删安全断言。 |
| frontend-analyze-final、frontend-final-check-02 /1 | Home braces lint；03及最终analyze/0。 |
| frontend-final-tests-02、03 /1 | 提示文本查找、Home provider及旧页面预期；最终39/0。名称含failed peer reread的测试本身通过，不是隐藏失败。 |
| apk-preliminary-build、02、03、04 /1 | development gate、独立SDK位置、Flutter生成.android缺Gradle工程；仅修本树ignored配置/生成文件，05及最终构建/0，未升级全局SDK。 |
| http-prepare-01、http-prepare-resume /1 | 缺实际必要20题导致422；脚本admin路由误用POST得到405；后续补正确合成题及使用实际入口，finish/0。 |
| mariadb-edge-cases /1 | cadence超出旧week_tag16，真实SQL1406；迁移扩120后02/03成功，最终明确仅409算拒绝。原02宽泛403/409脚本另保留，不代替03。 |
| rr-authority-races-01 /1 | Block脚本无commit marker；修正实际controller输入字段后02/0。 |
| expiry-mariadb-01 /1 | 最后一条夹具查询误用不存在requester_id列；02改pair_key断言后/0；不是产品授权拒绝。 |
| app-resume-partner-01 /1 | 取用脚本缺label参数；02使用真实actions/confirm合同/0。APP resume先重启双确认，不能误当单方恢复ACTIVE。 |
| app-late-response-01 /1 | UI脚本误点“退出”标题未确认退出；02精确控件后/0。重登脚本早期连续点击/密码输入未正确完成，观察原件保留；最终分步UI确认成功，不视为服务端数据丢失。 |
| matching-failure-observed /0 | stdout为FAIL，是有意制造不可用合成题的真实失败轮次；恢复题、浏览器retry、consumer DONE，后续零候选Reveal。exit0不代表该原作业成功。 |
| expiry-terminal-cn-before-fix /0 | 1test29assertions；其标签不是复现失败。hasContext的终态新建门原本已正确，修复针对match/projection到期。 |
| source-diff-check / EXIT_UNKNOWN | 原流保留CRLF/trailing whitespace；独立exit文件未保存，不补造；规范本版文件LF后diff-check通过。php-lint.json逐文件包含实际退出码。 |
| github-source-review-readback /1 | 未认证GitHub REST返回403 rate limit；转用已连接GitHub只读元数据工具，固定SHA raw字节回读02/0，未关闭TLS或改全局路由。 |

`runs.json`保留审阅包生成时每条命令的真实exit/UTC/脱敏argv，完整本地记录继续LOCAL_ONLY。其它早期运行原件、历史算法失败、v10.1.1事故/恢复原证一律不重写。没有声称已消除deprecation；首次lint/格式命令的可证明层级分别如上。

## 7. APK 身份与最终组合

| 项目 | 实值 |
|---|---|
| 文件 | EliteSync-v10.1.2-dev-ebade521.apk（LOCAL_ONLY） |
| applicationId | com.elitesync.v1012dev |
| versionName / versionCode | 10.1.2-dev / 1010201 |
| ABI | x86_64 + arm64-v8a |
| bytes | 411524159 |
| APK SHA256 / AVD安装pull SHA256 | `5728683b4f3cf45b8e6de9bcba1952d8f19c8e43c6f143bcfcc81b8f8da91b39`，两者相同 |
| 签名证书SHA256 | `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`，开发签名 |
| 构建源码 | ebade521，apps9344354d，servicesa0eb88ca（完整值见§1） |
| 后端组合 | 同一最终源码 + 独立elitesync_v10_1_2_dev；API8015 / WS8016，仅loopback |

冻结最终源码后执行离线 `assembleDebug -PflutterDartDefines=ELITESYNC_V1012_LOCAL_BUILD=true -PrelationshipDualDeviceBuild=true --offline --console=plain`，安装到获准既有AVD，检查badging/签名、pm path并pull比对。客户端树自224ab490未变，因此新构建与其APK同hash；后端到期修复已绑定ebade521，不把旧后端混用。最终安装后重登A读取草稿/代际成功。专属applicationId未覆盖v10.1.1 APK；物理手机未操作。

## 8. 非作者集中复核

[非作者复核原意记录](https://github.com/zcx369658780/EliteSync-v10/blob/70e122ddfbaa2d89e6c46bb21fb49a8fe8ae44d4/docs/_temporary_review/v10.1.2-20261020/non-author-review.md)：独立GPT-6.1 Sol/high助手只读源码、迁移、锁序与保存证据，未独立重跑。此前发现的报名代际/Reveal、凭据失效后补发、canonical简介、锁后session与幂等重新投影、到期授权问题已版内修复；最终限定范围无新增具体阻断。复核不构成ACCEPTANCE。

脱敏包另经非作者内容检查：最初105项与新增4个guard stream均无实际秘密/个人路径/设备ID；manifest原件bytes说明修正；随后四字段补证独立列supplement及manifest，不覆盖首次收尾。四字段补证脚本的 `cache_private_no_store` 名称最初宽于实际仅检查 no-store 的断言；已另对保存的14条真实HTTP header逐条核验 private 与 no-store 两项均存在，记录输入原件SHA及结论于制品清单 `cache_header_postcheck`，没有重跑请求或抹改原脚本/结果。所有公开副本还经实际本地私密值、JWT和个人路径匹配扫描。安全扫描与哈希都不替代Astra功能验收。

## 9. 发布、回读与资源终态

临时审阅分支普通non-force发布，原审阅提交3702c51保留、补充70e122dd是正常子提交；不把临时证据commit合进产品候选。本报告及制品清单只含必要脱敏长期信息。最终候选同样普通non-force发布，不移动main。

独立回读分两层：通过已连接GitHub的GET核对Commit/Tree/apps/services/main，通过固定SHA raw逐文件比对Git blob SHA1、SHA256及bytes。初次审阅源41文件+109审阅文件共150项已完全一致；最终补充8项也已逐文件一致，原109项在正常子树中保留；候选报告/入口文档再作同等回读，最终回执保持LOCAL_ONLY并随集中交付指向固定远端提交。该回读证明远端对象，不证明Astra已验收。未经认证REST限流原失败保留，没有规避仓库权限或工具拒绝。

本版全部服务收尾：API/WS停止、独立DB容器停止、volume/三份恢复点保留、获准AVD停止、仅本版ADB reverse8015移除；8015/8016/43323/5554最终均无监听。补四字段时只短暂恢复同版DB/API，已再次备份/停止，没有恢复WS/AVD。27个历史容器均未运行。四处受保护工作树HEAD/status/index输出及index文件SHA与开工逐字节相同；没有reset/clean/stash/prune或清理旧资产。当前专用树的runtime storage/framework继续LOCAL_ONLY未跟踪，没有为“干净”删除原证。最终资源证据为 `supplement/resource-final-after-four-fields.json`。

## 10. NOT_RUN 与保留观察

- 真实身份供应商/证件采集、真实账号实人完成或正式关系激活：NOT_RUN / PROVIDER_PENDING。
- 物理手机USB安装/操作、麦克风/相机、RTC音视频媒体与人耳听感：NOT_RUN；旧单次授权不续期。
- UDP、DNAT、系统防火墙、UAC、阿里云试点、公网/证书/备案、第三方身份/Push/支付/AI外传与费用：NOT_RUN。
- 历史真实库迁移/覆盖、物理erasure、共享记录/审计/备份销毁：NOT_RUN；本版虚构注销只到DELETION_PENDING撤权流程。
- 全部无关算法oracle、历史RTC长测、全仓考古/新竞品研究、全局SDK升级：NOT_RUN。只执行既有匹配consumer与本版直接相关测试。
- main合并、原候选/审阅分支/备份清理、正式运营发布、v10.1.3启动：NOT_RUN。

v10.1.0整体及AC-10.1-08的PARTIAL、v10.1.1接受/集成观察和DB事故原证保留。尚无生产接入、真实匹配效果、完整真实Showcase审核流程或独立Astra接受结论。交付后停止，下一门仅为Astra独立验收。
