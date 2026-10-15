# v10.0.8 独立Blade管理业务候选交付

**CANDIDATE DELIVERED — AWAITING ASTRA FINAL ACCEPTANCE**。本报告提交冻结八项AC的实现与实际证据，Codex不自行ACCEPT、不合并main、不启动v10.0.9。以下开发账号全部虚构，Web与APP使用同一Laravel及独立持久MariaDB；测试证据与真实业务证据分别列示。

## 固定身份与交付口径

| 身份 | 固定值 |
|---|---|
| 正式plan | `ac57d3370a2f2f17c042987a758d86c9aa725650`；plan Blob `0856e7372d1f91fadfa3350b30f926f7af9cf809` |
| Owner D1/D2/D3 | `cacfa889128f9a3a4b443efa87f4c347a178f1d5`；PRODUCT_DECISIONS Blob `4f84f1968ee2737b842f828ad2e0cbdd5c929936` |
| 产品实施起点 | `a75b8d4061ae012937ef4823120b396f257d3aec`；Tree `89637891276cdf4280f918ccad7eb4c5030f55be` |
| 本次重新读取live main | `e1dec331d7fc4d6d42fb2fffa63e02987d52e4a0`；未向main写入 |
| 最终产品源码锚 | `1f73a80afd2e0678006ce62e019235dc5ec36374`；Tree `9f7071412a0341604563ee73a9556116b6b1bc28` |
| 最终Flutter lib / Android Tree | `d610254d1d93c0ab2c7eed839eba44e635713acf` / `7e76419254e889c95d846d91bde7674020331c75` |
| 独立候选分支 | `codex/v10.0.8-web-admin`，复用既有专用工作树；后续证据/文档提交不改变上述产品源码 |
| 最终候选commit/tree | 以包含本文、manifest和证据的分支发布提交为准；交付回报及本地 `publication-receipt.json` 记录远端实际回读值。manifest不伪填包含自身内容的递归hash |

完整模块路径见 [product-changed-paths.txt](evidence/product-changed-paths.txt)，环境与包身份见 [manifest.json](manifest.json)，安全原证的原始/发布SHA256见 [INDEX.json](evidence/INDEX.json)，重现步骤见 [RUNBOOK.md](RUNBOOK.md)。本地证据根Q为 `C:/Users/zcxve/.codex/visualizations/2026/10/14/01a13afa-b74f-7c11-b7e0-01a04335168d/v1008`。网页能直接核对仓库发布材料；未发布的Windows材料仅CODEX_REPORTED，不假设网页能访问本机。

## 源码与共享业务

后端核心为 `services/backend-laravel/app/Services/Admin/{UserGovernance,ReportOperations,QuestionOperations,ReleaseManagement,OperationAudit}.php`，Blade页面位于 `resources/views/admin/`，Web控制器位于 `app/Http/Controllers/Web/`。Web与旧Admin API复用同一动作服务、当前actor检查、expected revision、题库/用户/渠道锁和事务审计。新迁移为 `2026_10_15_080000_create_admin_operations.php` 与 `2026_10_15_081000_add_sanction_prior_state.php`。后者保存有限处罚前态及不泄露原凭据的指纹，防止restore覆盖独立禁用/隐藏/统计排除。

Matching沿用 `MatchingRoundService`、`MatchingRunService` 与实际 `ExecuteMatchingRun` queue job；题库锁、current run归属、fencing token与最终当前用户/输入版本复核覆盖freeze/finalize/reveal及失败/过期写入口。发布事务同时写入泛化 `matching_round` 站内事件，payload绑定round/run，不含peer或私信、不授予CN/MC。

APP当前Me入口接入运营状态卡，读取真实审核状态、原因及有效回答资格。问卷保留答案并安全续答；末题409/422也提示重载且阻止旧请求重复提交，503保留普通重试。版本中心按本版构建flag读取development，明确database/config/unknown来源。APP源码改动集中在Me、资格卡、问卷和About；未升级锁定依赖。Android构建脚本沿用现有模块AAR与host链。

## 冻结AC与真实结果

| AC | 实际操作、持久结果与可核证据 |
|---|---|
| AC-08-01 | 独立Blade登录/退出、role-only/名单-only/普通/disabled拒绝；真实浏览器已有会话在降权、禁用、空名单时均403，截图 `web-{demoted,disabled,empty-allowlist}-old-session.png`。`session-rotation-real.json`核真实HTTP登录session与CSRF轮换、退出后不能访问；`web-real-csrf-version-concurrency.json`核伪造CSRF419、stale409、自身403、同revision并发结果[200,409]。同库 `admin_operation_audits`记录actor/目标/理由/版本及有限前后态；详情访问亦审计。 |
| AC-08-02 | 最终第五次构建已安装的Alice(ID2)在Me正常显示approved/40题后，经真实Blade禁用。`web-final-alice-disabled.png`及 `app-final-disabled-session.png`显示共享禁用和APP清会话提示；旧token401、refresh401、新登录403，Bob(ID3)资格API200且真实APP正常。禁用前有2个token及一条明确标注为非浏览器的持久session删除fixture；禁用后同ID均0，`after-final-disable.stdout`与 `persisted-session-before-disable.stdout`可核。账号disabled、account_status disabled、moderation banned、match eligibility false，旧MC保持失效。 |
| AC-08-03 | 同Alice实际Blade pending→rejected→approved及理由，APP刷新读回；`web-alice-pending.png`、`web-alice-rejected.png`、`app-fifth-me.png`。pending/rejected不进新候选，approved仍须有效问卷/状态等其余资格。`d1-history-consent-preserved.json`对照旧Match/CN/MC均保持，零候选真实consumer与最终发布检查不放过未配对pending用户。审核不是实名认证。 |
| AC-08-04 | Alice真实APP举报Bob公开动态，report1；Blade查看/处理remove_post，APP刷新后隐藏。report对Bob执行ban及指定sanction恢复，旧token/refresh不复活。Alice restrict时公开发布403、双向新消息404、合法历史读200；restore原MC仍撤销，重新双方同意才生成generation2。末次Alice禁用后Bob私信/图片404，通知API仍有泛化事件与计数，但message payload无导航/敏感身份；真实APP仅显示泛化提示和“仅标记已读”，操作后API read_at更新、未读3→2。见 `http-alice-post-restricted.json`、`http-bob-send-to-restricted.json`、`http-alice-restricted-read.json`、`http-restore-old-read-denied.json`、`final-disabled-peer-{message,media,notices}.json`及 `app-final-bob-private-{notice,read}.png`。 |
| AC-08-05 | 真实Blade准备/执行请求→database queue→consumer完成→发布/关闭，详见下表。同库5个round、7个run包含真实pair、零候选、worker停止pending、lease过期及新attempt恢复、题库变更拒绝。发布事务的round/run事件在Alice真实APP打开并标记已读，`final-notice-{api,read}.json`及 `app-final-notice-{list,opened}.png`；未读1→0。APP目标页继续显示明确标注的历史Match及独立连接/消息同意；最后零候选轮次不制造新Match或权限。关闭后round-current返回no_round；Alice禁用后Bob current match拒绝，历史DB行仍保留，不能把历史UI冒称当前轮次新配对。 |
| AC-08-06 | 真实Blade质量统计→q1影响预览/dry-run→version2→3停用、bank revision1；历史answers/attempt/Match/CN/draft不改，`question-history-preservation.json`。Alice有效回答20→19/20，APP明确需补；原draft未包含停用q1，实际安全续答并提交20项，39/20恢复eligible；恢复q1后40有效。恢复为题version4、bank revision2，真实freeze竞争造成旧run input_changed、零半写Match，新attempt成功。最后题stale/503分支另有5项定向测试，未冒称真实APP走过该stale分支。 |
| AC-08-07 | Blade开发channel release1创建/编辑/激活/停用/再激活，最终revision6，0.08.04/80400，hash绑定第五包，`web-fifth-release-metadata.png`。APP停用时明确config fallback且不下载；重新激活和联合重启后实际APP显示development/database/0.08.04与当前更新说明，`app-joint-release-database.png`。仅版本元数据；本版没有验证URL上的APK托管/下载，没有商店或生产发布。 |
| AC-08-08 | 最终源码AAR/debug APK构建exit0，安装exit0并从设备拉回APK同hash。仅重启核归属的PHP/front/worker、0.8 MariaDB同一volume及APP，不重seed。`joint-before.stdout`、`joint-after.stdout`与 `joint-snapshot-comparison.json`逐字段比较全部true，包含审核/处罚/举报/动态/题库/答案attempt hash/round/run/Match/CN/MC/release/audit及有限凭据计数。重启后Web同ID与Bob实际APP读回；Alice旧token401、媒体404保持。最终专用服务、容器与AVD停止，volume、媒体及私配保留。 |

管理员降权/disabled/空名单验证只调整本版虚构管理员fixture/同一进程配置；不是生产角色政策修改，也不是通过产品restore恢复旧凭据。持久session删除fixture明确不是Alice真实Web管理员登录。HTTP补证不冒充浏览器；Widget/SQLite测试不冒充MariaDB。

## 实际consumer与数据库身份

下表固定值可与 `final-business-snapshot.stdout`、Web页面和审计交叉核对。全部round最终closed；首个已发布Match1仍存在。

| cadence / round_key | run_key / 结果 |
|---|---|
| 08-baseline / `6370d69b-d715-48f1-a5d5-82daa55424f4` | `e85aa167-f60b-41a4-9517-c4c403d3b5ac`，真实consumer candidate2/pair1，发布后关闭；APP见虚构Bob历史结果，未自动授予CN/MC |
| 08-recovery / `ef144a3a-fc77-4fe7-924c-b0527a2e8c83` | `d8f38c55-c0e5-4544-8023-38158b07eebe`真实领取后退出、lease_expired；Web retry fence旧run，attempt2 `be972351-bc35-4372-9934-8a4d0d20edea`由恢复worker实际完成，pair0，发布关闭 |
| 08-zero / `e3df5fc0-f840-4395-8fc6-8962796a1518` | `1be2c158-4f60-42c9-a915-4f27b51d44b7`，两人pending时candidate0/pair0，no_candidate发布关闭 |
| 08-bank-race / `b7787b1b-850c-442d-a875-f9c13749ceef` | `eeabc9d4-d8ca-4e43-b944-34e575a3b3fb` freeze后输入改变，failed/input_changed、无Match半写；attempt2 `596729b1-af32-4b68-83df-c6e64f87b853`真实worker成功、发布关闭 |
| 08-final-notice / `5829c486-ea91-4c98-ac16-a4003d274822` | `1896c78f-3656-444a-b0b3-b149d272e7cc`真实consumer succeeded/pair0，发布写Alice通知3、Bob通知4，实际APP读回及已读，最终version5 closed |

原轮次后不再重复既有pair，所以后几轮pair0不冒新配对。题库竞争中29ms仅点击派发；派发至成功页面状态约1912.6ms、consumer持锁12秒，真实重叠约1.7秒，见校正时间回执。另一次MariaDB题库锁使审核等待约2.816秒。并发/故障harness exit0表示其**预期拒绝得到证明**，不把failed业务run改记succeeded。

同库主要表为 users、admin_sanctions、admin_operation_audits、admin_versions、moderation_reports、status_posts、dating_rounds、matching_runs、dating_matches、questionnaire_questions/answers/attempts/drafts、product_connections、messaging_consents、notifications、app_release_versions、sessions与personal_access_tokens。种子Alice/Bob最初各20答案与前2份attempt是具名历史fixture；Alice后续20项由真实APP操作提交，不能把seed冒充APP回答。新旧答卷的停用前后原hash比较与最终整体hash分别登记，不拿追加后的整体hash冒旧记录不变。

## 测试、失败与构建

| 实际执行 | 结果与限制 |
|---|---|
| `php-regression-sixth` | 146 tests /1457 assertions，exit0；2项vendor deprecations仍保留。包含本版全部V1008测试及受影响旧Admin、消息隐私、媒体、题库/准备资格、matching和版本合同，不是后端全套通过声明 |
| `flutter-related-final02` | 41项通过，exit0；这次之后仅移除冗余cast和补test if花括号 |
| `flutter-related-final03` | 实际命令范围30项通过，exit0；范围与上一次不同，不累计成71项，不称全量Flutter通过 |
| `analyze-final03` | 全范围 `flutter analyze --no-pub`，No issues found，exit0；覆盖产品lib及test。本版未另外重复单独lib analyze |
| `build-fifth` | 最终源码release AAR及debug host，exit0；syncFlutterAar执行并输出Built repo，host其余多数任务up-to-date。增量构建合法复用缓存；与第四包hash相同，不冒“每个任务重编译” |
| `install-fifth`及设备回读 | install-r exit0；设备base.apk SHA256与最终APK一致，versionName0.08.04、versionCode80400 |

最终包仅LOCAL_ONLY：Q `/packages-fifth/v1008-debug.apk` SHA256 `f2e025c9e9f3d4ace1183467d8f753ed5b7ffd395cf0793d323abdc3ef15b11d`；`v1008-release.aar` SHA256 `a22561393b09f6e57e1ef913fa174b1fbe6120b91d073ad3ec05c778308a27c9`。第四包与全部前次构建保留。去掉cast不改变生成代码，重新构建/安装后字节hash相同；后续仅文档/证据，不再修改客户端。

原始失败不删除：core first/second/third exit2→fourth0；PHP regression first2、second1、third0、fourth0、fifth1、sixth0；Matching Web未过期lease原500修为409；readiness fixture缺当前approved/active状态与合法option对象造成4失败，修fixture后保留断言并通过；运营卡自动retry延迟错误态修为手动刷新；About测试视口/生命周期两次失败后10项通过；发布actor-lock fixture重复key修updateOrInsert；末题409/422重载漏洞修复后5项通过；analyze-final02为warning+info/exit2，final03无问题。`flutter-related-02` durable draft加载失败后03通过。具体标签与原exit保存在evidence。

另有snapshot imports错误exit255、先使用不存在的 `/api/v1/me` 得404、关闭理由超64字符被真实表单拒绝，以及root `-uall`检查产生长路径警告；这些失败/误用不作为权限通过。随后修import重取、改正确 `/profile/basic` 区分Alice401/Bob200、以合法短理由关闭、以相同normal口径对比保护锚。原流仍在Q；公开材料中core-first SQL错误的密码hash已脱敏，INDEX分别保留原始/发布hash，未改本地原件。

旧0.7全量Flutter普通793/5、带fixture821/3均exit1，沿用其固定归因与原始记录。本版没有重跑全量Flutter、没有将历史3失败写成PASS。定向变更合同已重测，不因这些旧失败重开历史验收。

## 资源、保护与保留缺口

最终仅本版owned PHP/front/worker已停止，`elitesync-v1008-db` Exited(0)、`elitesync-v1008-db-data`保留；emulator-5582已停止。0.6/0.7库与卷、原3306、历史SQL/VHDX未访问或重seed。Q/media与secrets保留本机，发布材料不含账号密码、token、cookie、私配或物理包。重启与停止日志exit0及精确volume记录已封存。

原dirty根HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`、index、normal status、既有43具名文件hash与Q旧保护锚一致；不是本轮重新制造before，更不是105/109项全历史验证。无blind pull/reset/stash/clean/prune，无关LOCAL_ONLY/EVIDENCE保留。

NOT_RUN：生产与真实账号、完整后端/Flutter全套、包下载托管、完整题库编辑器/物理删除、真实历史数据恢复、真实第三方服务和商店发布。RTC、完整紫微/西占、Buddy/Social、其它媒体、地图、系统Push及历史数据/附件恢复仍在单份台账，必须完整内测前具名安排或Owner决定；没有完成或删掉这些欠账。旧本地通知明文存储观察仍保留，本版不清洗历史证据。

下一门仅为Astra对固定候选的独立终验与集中返修意见；不得把候选交付等同接受或K08。
