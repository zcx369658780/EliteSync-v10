# EliteSync V2｜RC-D Owner 产品决策集中审阅材料

2026-11-27，北京时间。任务 `V2-RC-D-OWNER-PRODUCT-DECISIONS-20261127`。**出口 `RC_D_OWNER_DECISION_DOSSIER_READY`，全部新增产品选择为 `OWNER_PENDING`。** 发布状态 `R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`。

- **FACT** 表示固定源码、历史运行记录或已经具名接受的 Owner 原则。历史顾问材料中的提案仍按提案引用。
- **PROPOSAL** 表示本报告供选择的方案或后续验收条件，成本为相对量级。**ADVISOR_RECOMMENDATION** 引用已找到的网页顾问意见并注明时间与适用范围。本轮顾问集中审阅待 Owner 转交。
- **OWNER_PENDING** 表示 Owner 尚需确认的范围或选择。真实取证、供应商采购、实施和发布须按各自边界授权。

**FACT（基线）**。活动工程 `D:/EliteSync/development/v2-cloud-r0-20261121`，分支 `codex/v2-function-completion-20261121`，origin `git@github.com:zcx369658780/EliteSync-v10.git`。开工本地与远端交付 `f7f06a856606a2192204371c03c3b59598a51660`、tree `75d303437e0abc547cc4565a13113a246ffe40bf` 一致，工作树和暂存区干净。产品源码 `03d6740e9cbe36255129ef848d66d4a54dea2327`、tree `78333979365d8e2787827eb6c2f3aaf1b6fed93d`。另一个 `D:/EliteSync-v10` main 为 `4bebc8f394248e254c1368a06fbdee5d2c883301`，43 项未暂存、213 项未跟踪、暂存区空。本轮只读源码与回执，动态运行 `NOT_RUN`，M4-R 统一 QA 候选及证据沿原记录。 [RC-F 固定报告](https://github.com/zcx369658780/EliteSync-v10/blob/f7f06a856606a2192204371c03c3b59598a51660/docs/versions/v2/cloud-r0-20261121/V2_RC_F_ROADMAP_FUNCTION_CLOSURE_REPORT.md) · [M4-R 固定报告](https://github.com/zcx369658780/EliteSync-v10/blob/440ac56217659b32b040d58b3cd1748761f6039a/docs/versions/v2/cloud-r0-20261121/V2_M4_R_INTEGRATION_CLOSURE_REPORT_20261127.md)

## RC-D01｜NEW-PC-04 既有匹配候选的主动新版分享

**FACT（原提案与 Owner 原则）**。2026-11-19 网页 GPT 顾问在集中分诊把这项选择列作“向已形成的既有 Match 候选主动发布形象新版”。原提案有两个方向。一是首期沿用 O05-X A，二是未来逐个既有候选由本人明确选择，并满足当前双方合法业务条件与发布回执。背景是资料预览、对外发布和候选原快照分离后，有人可能希望主动补充新版。顾问材料未规定接收方必须再次确认。Owner 已确认 O05-X A，新匹配形象只给未来新形成且当前有权的候选。S11-D2 另确认发布前解释版本差异、场景、受众和影响范围，由本人明确确认。两项已认可原则均保留。 [原分诊 §3](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_REMAINING_TRUE_OWNER_PRODUCT_DECISIONS_TRIAGE_V0_1_20261119.md#L54-L58) · [Owner O04/O05](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_O04_O05_DATA_REUSE_AVATAR_PUBLICATION_20261119.md) · [Owner S11-D2](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_S09_D1_S11_D2_ACCEPTANCE_20261119.md)

**FACT（源码）**。候选揭晓时一次性绑定当时合法发布记录、审核提交、发布版本和访问代际。本人主昵称与头像编辑更新仍用默认值的本人预览。独立场景覆盖和对外发布分别处理。候选投影仅给出展示 ID、简介、兴趣、Lifestyle 标签和发布版本。原提交必须匹配，联系人在揭晓时缺独立原读权的旧候选不会事后补绑定。读取要求提案仍有效、当前发布与代际有效且原受众和当前权限均通过。Block、失权、撤回或受众收窄可让旧投影不再可读。已具备独立好友、消息读权或正式关系共享权限的账号，可能从独立 Showcase 路径读取当前获准版本，候选投影仍按原绑定处理。历史保留时长及单独新版分享、撤回和收件人确认均未实现或未冻结。 [候选捕获及读权](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Services/ProfileShowcase/CandidateShowcaseSnapshot.php) · [独立 Showcase 读权](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Services/ProfileShowcase/ShowcaseWorkflow.php#L337-L412) · [A2 证据](https://github.com/zcx369658780/EliteSync-v10/blob/f7f06a856606a2192204371c03c3b59598a51660/docs/versions/v2/phase-a-20261119/PHASE_A_ENGINEERING_REPORT.md)

| PROPOSAL | 产品收益 | 风险与工程成本 |
| --- | --- | --- |
| A · 首期维持原绑定 | 既有候选的预期稳定，无额外通知和共享步骤。 | 已形成的合法候选无法通过候选入口获知补充版本。工程成本低。 |
| B · 发件人逐人确认，合格收件人可直接查看 | 本人能主动提供指定新版，无需对方再操作。独立呈现分享版本和原候选版本。 | 需明确接收方可拒看或静音、生命周期与分享滥用限制。工程成本中，需版本化分享授权、受众复核、撤回及只读回执。 |
| C · 发出邀请，收件人确认后查看 | 双方都能决定是否接触新内容，接受前只见最小提示。 | 多一步，需处理拒绝、过期、双方并发、重复通知。工程成本高，增加邀请状态、回执和失权清理。此方向为 RC-D 新备选。 |

**ADVISOR_RECOMMENDATION**。历史网页顾问建议首期 A。理由是既有默认已明确，主动分享将新增候选生命周期、许可、撤销和版本合同。本轮顾问复审待回。 [原建议](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_REMAINING_TRUE_OWNER_PRODUCT_DECISIONS_TRIAGE_V0_1_20261119.md#L54-L58)

**OWNER_PENDING**。首期选 A、B 或 C。若选 B/C，明确可选候选状态、接收方是否再次确认、允许字段和最长有效条件、收件人拒看与新分享撤回方式、旧快照仍可读的条件及历史保留依据。应单独决定独立关系已失效后的显示。暂以现有最小候选字段为评估基线。真实姓名、联系方式、出生时地和坐标、命盘、私聊、核验凭证、第三方照片须各有权限依据。

**PROPOSAL（决策后验收）**。选 A 可用旧候选对新发布不变、旧快照失权隐藏、未来有权新候选见新版收口。选 B/C 才设计本人预览差异、逐人选择、独立分享记录及撤回和缓存失效。验收涵盖未批准或未接受的版本、迟到确认、Block、撤回、到期、切号、旧通知和深链，以及只读核对回包丢失。候选绑定、报名、Connection、Messaging Consent、Conversation 和正式关系各按原合同。

## RC-D02｜NEW-PC-05 官方内容与访客内容

**FACT（原提案与 Owner 原则）**。原问题是“正式官方转载是否属于 V2 首期功能”。当时 A 先做官方原创专题和站内受控编辑推荐，B 把有独立具名授权的正式转载纳入首期。O11-D1/D2/D3 与 S16-D2 已接受官方与用户分域、站内推荐只链接当前有权的原作品、公开复制/改编/引用须另获具体素材、用途、目标受众和有效版本的许可，以及可解释排序。访客只读获准的官方正文。用户站内公开、作者同意或管理员推荐均不会把好友动态、用户缩略图、评论、附件、互动及第三方素材授权给访客。官方编辑责任主体、审核、撤销时效、许可合同和首期转载范围仍开放。 [原分诊 §3](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_REMAINING_TRUE_OWNER_PRODUCT_DECISIONS_TRIAGE_V0_1_20261119.md#L60-L64) · [Owner O11](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_O11_EDITORIAL_REPOST_SORT_CONCEPT_ACCEPTANCE_20261119.md) · [Owner S15-D1/S16-D2](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_S15_D1_S16_D2_ACCEPTANCE_20261119.md)

**FACT（源码）**。公开 `GET /api/v1/home/editorial/{article?}` 仅投影内部配置中 `PUBLIC_EDITORIAL`、`guest_read_approved=true`、具备合法格式 ID 及非空标题、正文、来源引用的条目。响应字段为 ID、标题、正文和 `Cache-Control: no-store`。未知或未获准详情返回 404。源码正文默认空，配置条件和合成正例只证明软件过滤合同。该读路由没有官方发布审批、署名、媒体许可登记或撤稿管理入口。登录频道从原作品读取并按当前账号、原作品的当前受众和 Block 复核，推荐标记不能授权访问。 [访客 HTTP](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Http/Controllers/Api/V1/HomeController.php#L11-L31) · [默认配置](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/config/home_content.php) · [登录频道](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Http/Controllers/Api/V1/StatusPostController.php#L228-L276) · [阶段 B 合成用例](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/tests/Feature/V2PhaseBContentTest.php#L97-L128)

| PROPOSAL | 产品收益 | 风险与工程成本 |
| --- | --- | --- |
| A · 首期官方原创正文与站内推荐 | 访客可读明确批准的原创内容，登录用户保留原作品发现。 | 需指定发布者、审核者、稿源与下架负责人。真实正文获批前保持空。工程成本低至中。 |
| B · 首期加具名授权正式转载 | 优秀用户内容可进入公开专题，支持约定署名与正式来源。 | 第三方权利、复制/改编/引用范围、跨渠道传播与撤回边界更复杂。工程成本高，需独立转载版本、许可和审计。 |

**ADVISOR_RECOMMENDATION**。历史网页顾问建议 A，因正式转载需要编辑角色、第三方许可、撤回及版权处置合同。该建议保留为顾问意见。 [O11 顾问稿](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_O11_EDITORIAL_RECOMMENDATION_REPOST_GOVERNANCE_V0_1_20261119.md) · [原推荐](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_REMAINING_TRUE_OWNER_PRODUCT_DECISIONS_TRIAGE_V0_1_20261119.md#L60-L64)

**OWNER_PENDING**。确认首期 A/B、实际发布主体和审批角色、允许访客读到的正文和素材类型。若选 B，逐项确定复制、转载、引用、改编、署名/匿名、媒体许可、原作品撤下或改受众与独立转载撤回的关系，以及争议投诉和紧急下架责任。图片、插画、字体和第三方媒体需记录权利人、许可范围、版本、署名和期限。有未核准项的正文仍保持空配置。

**PROPOSAL（决策后验收）**。用获准稿件版本、许可和发布者证明正向名单。检查匿名列表、详情、搜索、深链和媒体缓存，验证禁读内容、过期/撤回、下架和清缓存；旧副本的保留、访问及第三方不可回收范围需单独实证。B 额外验证原作品与转载独立授权，失权不会暴露第三方内容。

## RC-D03｜D0 旧排盘接口处置

**FACT（历史与当前）**。阶段 C 分离账号事实和排盘，D0 增加拒绝说明与本人手填入口。网页 GPT 的 Q 阶段固定备选仍为待决。本单采用 RC-D03 编号，**历史 Q 的 B（退役）对应本单 C，历史 Q 的 C（兼容桥）对应本单 B**。请按选项名称确认。 [Q 固定备选](https://github.com/zcx369658780/EliteSync-v10/blob/c3499b0d599698287a73fd295aaf5892a74d12c1/docs/product/V2_Q_LEGACY_ASTRO_COMPATIBILITY_OWNER_DECISION_OPTIONS_20261120.md) · [阶段 D D0 报告](https://github.com/zcx369658780/EliteSync-v10/blob/f7f06a856606a2192204371c03c3b59598a51660/docs/versions/v2/phase-d-20261120/PHASE_D_ENGINEERING_REPORT.md#L30-L43)

| FACT · 接口或调用面 | 当前合同 |
| --- | --- |
| 旧 `POST /api/v1/profile/astro` | 已通过正常路由鉴权的请求进入处理器后，返回 409 `LEGAL_BASIS_UNVERIFIED` 和独立工具指引，私有 no-store；处理器无旧数据写入、重算或默认正午。 |
| `GET/POST /api/v1/profile/natal` 与历史 | 本人独立工具读取/保存。提交具名本次输入、设置及 expected revision，校验民用时刻、精度、时区、坐标/来源等。以输入签名及代际保护结果，运行错误保留输入并阻止迟到旧结果写入。历史归档另有本人权限。M4-R 固定候选具名 v1/v1 保存和读回。 |
| 旧 `GET /api/v1/profile/astro`、`/summary`、`/chart` | 三路映射同一 `show`。只投影本人已存私有本命的镜像，签名变化时结果标过时。仅有旧衍生行时返回 HTTP 200、`exists=false`、`profile=null`、`LEGAL_BASIS_UNVERIFIED`；无本命且无旧行时为 `NO_PRIVATE_CALCULATION`。这些兼容读入口和独立高级工具的 `/pair`、`/transit`、`/return` 请求不属于 D0 旧 POST 的退役范围。 |
| 当前 Flutter 与旧 Android | Flutter 本命页 POST/GET natal，并用历史路由读归档。旧星盘画像仍 GET summary/chart，404 时才回落 GET astro，依据未核实时给出手填指引并停止自动重试。Android 宿主以 FlutterActivity 为入口。已查旧固定宿主提交及当前树有 Retrofit GET/POST 和 AppRepository 包装声明，未找到宿主页面调用该 POST 的可证调用点。旧 APK 的实际安装面、活跃请求和升级覆盖 UNKNOWN。 |
| 旧失败 | 阶段 D 和 RC-F 核对的 C 阶段兼容差异仍 25 条。AstroCanonicalApiTest 14 failures，涉及旧写入、旧展示及缓存重算；ProfileBasicRecomputeTest 5 failures；V1007BaziProvenanceTest 3 failures、2 errors；AuthPasswordApiTest 1 failure。基本资料与登录只读写私有账号事实，禁止从旧衍生盘反填。 |

[路由](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/routes/api.php#L247-L289) · [旧读写控制器](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Http/Controllers/Api/V1/AstroProfileController.php#L17-L42) · [本命保存](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Http/Controllers/Api/V1/NatalProfileController.php) · [私有镜像与签名](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Services/NatalProfileView.php) · [Flutter 兼容读取](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/apps/flutter_elitesync_module/lib/features/profile/presentation/providers/astro_profile_provider.dart) · [Flutter 正式提交](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/apps/flutter_elitesync_module/lib/features/profile/presentation/pages/natal_restoration_page.dart#L665-L704) · [历史 Android Retrofit](https://github.com/zcx369658780/EliteSync-v10/blob/2b5065bd2ef406c992656484014759987b8a2f7f/apps/android/app/src/main/java/com/elitesync/network/ApiService.kt#L58-L62) · [阶段 C 逐例账](https://github.com/zcx369658780/EliteSync-v10/blob/f7f06a856606a2192204371c03c3b59598a51660/docs/versions/v2/phase-c-20261120/PHASE_C_ENGINEERING_REPORT.md#L86-L100)

| PROPOSAL · 本单编号 | 产品收益 | 一致性、兼容性和工程成本 |
| --- | --- | --- |
| A · 保留 409，继续新接口 | 给旧调用稳定拒绝和升级路径，当前 App 可继续独立手填。 | 不恢复旧客户端写入。历史只读按当前合同，签名和旧行保留。需确认最低可升级版本及文案。成本低。 |
| B · 旧客户端受限适配 | 合法与版本证据成立时，减少指定旧客户端中断。 | 旧字段映射与精度/来源有差异。需可核客户端身份、本人明确本次用途及合法依据，以新接口为唯一写权威。拒绝缺输入、误匹配和过期授权，保留新签名核验，不恢复静默双写、旧缓存重算、默认正午或历史反填。成本高且持续维护。 |
| C · 有弃用周期，迁移后退役旧写入 | 降低接口维护和隐式复用风险，保留独立工具与另行确认的读取接口。 | 需确认旧装机面、升级路径、截止条件和回滚。旧写入到退役点前继续 409；完成迁移后才调整路由语义。成本中，旧用户影响待证。 |

**ADVISOR_RECOMMENDATION**。Q 网页顾问建议 A 的有界升级过渡。在旧装机分布和来源合法性未知时，以明确拒绝和替代入口维持数据一致性。本轮顾问复审待回。 [Q 顾问建议 §2](https://github.com/zcx369658780/EliteSync-v10/blob/c3499b0d599698287a73fd295aaf5892a74d12c1/docs/product/V2_Q_LEGACY_ASTRO_COMPATIBILITY_OWNER_DECISION_OPTIONS_20261120.md)

**OWNER_PENDING**。选本单 A/B/C 的具名策略。明确旧写入保留/退出条件、旧镜像和合法历史的读范围、支持的客户端版本及迁移证据门槛。选 B 需确认允许输入字段、合法依据、可核验的客户端识别、范围和终止条件。选 C 需确认弃用窗口、告知、回滚及终止前最低迁移覆盖。实际旧用户数据访问另行授权。

**PROPOSAL（决策后验收）**。用具名客户端验证旧 POST、新工具和旧镜像的实际请求，检查未授权始终安全拒绝、旧版拒绝后能到独立工具、资料保存/登录无自动重算、签名不混用、旧合法历史未被覆盖。B 另验字段不全、撤回、同请求重放和旧写入冲突。C 另验最低版本覆盖、过渡文案、切换和回滚。原 25 条失败继续保留历史身份，按 Owner 新合同逐例给出处置及替代证据。

## RC-D04｜对象级数据权利与真实受理

**FACT（具名决定）**。NEW-PC-03 A 只接受首期优先规划本人作品和本人评论的对象级删除申请入口。RET-D1/D2 将撤权、真实受理和指定范围完成分开，并按对象、用途、权利主体、第三方与必要例外处理。OBJ-D1 禁止作品作者替第三方评论者承诺删除，历史内容可见性依原受众与当前权利交集。NEW-PC-01/02 已把评论者撤回本人展示与作品作者隐藏第三方评论区分开。 [Owner NEW-PC-03 A](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_NEW_PC03_INITIAL_OBJECT_LEVEL_DELETION_REQUEST_ENTRY_OPTION_A_ACCEPTANCE_20261119.md) · [Owner RET-D1/D2](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_RET_D1_D2_REVOCATION_DELETION_CONCEPT_ACCEPTANCE_20261119.md) · [Owner OBJ-D1](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_OBJ_D1_POST_TAKEDOWN_THIRD_PARTY_COMMENTS_ACCEPTANCE_20261119.md) · [Owner 评论撤回](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_NEW_PC01_COMMENT_AUTHOR_WITHDRAWAL_OPTION_A_DIRECTION_ACCEPTANCE_20261119.md) · [Owner 作者隐藏](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_NEW_PC02_AUTHOR_CONTROL_THIRD_PARTY_COMMENT_DISPLAY_DIRECTION_ACCEPTANCE_20261119.md)

**FACT（软件能力）**。C1/C2 对城市复用与私有本命复用检查具名用途、来源/许可版本、到期和撤回。源事实纠错使有关草稿或派生结果重审，手填与无关用途独立。C3/C4 的 `/data-rights/objects` 仅列本人 work/comment 的标识和创建时间，特定对象端点核所有者及版本（作品受众 revision 加 present/withdrawn，评论 revision）。提交需显式确认及 UUID 请求键。相同键与相同对象版本幂等，冲突拒绝，回包未知时按原键 GET 查询。非 TEST_ONLY 返回 `REQUEST_CHANNEL_UNAVAILABLE`，提交被拒。合成状态仅 `REQUESTED_TEST_ONLY` → `ACCEPTED_TEST_ONLY` → `PROCESSING_TEST_ONLY`，内置处理器只允合成控制台推进，`completion_available=false`。无撤销申请、人工受理或真实完成接口。本人评论失去作品读权时仍可按本人对象核验，目录不提供原作品正文。 [权利 API](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Http/Controllers/Api/V1/DataRightsController.php) · [对象请求服务](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Services/ObjectDataRequestService.php) · [具名用途](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Services/DataPurposeService.php) · [C1–C4 固定证据](https://github.com/zcx369658780/EliteSync-v10/blob/f7f06a856606a2192204371c03c3b59598a51660/docs/versions/v2/phase-c-20261120/PHASE_C_ENGINEERING_REPORT.md#L31-L38)

| 对象/动作 | FACT · 当前边界 | PROPOSAL · 实际受理需要决定的合同 |
| --- | --- | --- |
| 本人作品 | 可收窄受众或撤下。删除请求单独，作品作者无权替评论者处置原文。 | 明确作品正文、本人封面、索引与缓存的副本范围。由人工处理作者与共用附件、第三方权利冲突。 |
| 本人评论 | 可撤回展示；作者隐藏仅改变展示。两者与删除请求独立。 | 明确父评论、回复、引用的呈现和保留边界。无权者继续禁读。第三方回复的独立处理须人工核对。 |
| 附件、媒体、派生数据 | 对象 API 无这些类型。用途撤回可阻止特定派生继续使用或外显。 | 核对权属、同资产多引用、原件/缩略图、受众、依赖与删除范围。处理备份回灌和恢复后的再删除。 |
| 撤回申请与审核 | 现行可撤回用途或本人评论展示，无撤回删除申请状态。 | 可评估处理前明确撤回。已进入不可逆阶段、身份冲突、第三方、必要留存、争议或法务例外转人工。撤回申请后既有权限继续按权威状态读取。 |
| 反馈与审计 | TEST_ONLY 回执不出现在真实链。 | 区分提交未确认、已受理、处理中、需补充、拒绝、撤回、范围完成及部分保留。用户只见本人对象、可解释原因和实际范围。审计考虑请求 ID、范围版本、操作者角色、时间、依据与证据摘要，避免在审计副本复制原文。 |

| PROPOSAL | 产品收益 | 风险与工程成本 |
| --- | --- | --- |
| A · 先保留真实渠道不可用状态 | 准确显示 APP 当前能力，继续提供已有合规的展示控制。 | 适用义务仍需查证，若存在可用合法渠道应准确指引。工程成本低，法律与运营责任待定。 |
| B · 核实真实人工受理后提供指引 | 可以具名记录范围、例外和进度，便于处理少量复杂请求。 | 需证明实际值守、身份核对、反馈、留存和申诉能力。工程成本中，运营负担持续。 |
| C · APP 内首期受理本人作品与评论 | 用户能在对象上下文直接发起、只读查询或在允许时撤回。 | 需受理和履行后台、人工复核、版本审计、对象与副本数据图、失败和安全回滚。工程及运营成本高。 |

**ADVISOR_RECOMMENDATION**。原网页顾问建议优先规划作品和评论对象入口并只展示实证状态。Owner 已接受该规划方向，实际渠道方案 A/B/C 仍待定。 [NEW-PC-03 顾问设计](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_NEW_PC03_INITIAL_DELETION_REQUEST_ENTRY_SCOPE_CONCEPT_REVIEW_V0_1_20261119.md) · [Owner 方向与未决项](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_NEW_PC03_INITIAL_OBJECT_LEVEL_DELETION_REQUEST_ENTRY_OPTION_A_ACCEPTANCE_20261119.md)

**OWNER_PENDING**。确认真实受理的责任人与渠道、各对象首期范围、请求撤回截止和人工/申诉规则。请专业法律审查确认适用法域、本人身份与第三方权利、备份及法定/安全例外、处理时限、拒绝或限制反馈、保留期限、恢复后处置及最小审计字段。具体期限和法律结论为 `UNKNOWN`。

**PROPOSAL（决策后验收）**。先验渠道确实有运营处理能力，再以合成数据验证身份、对象/版本、重复/冲突、UNKNOWN 只读回执、人工权限、撤回、拒绝、完成范围、独立留存、备份恢复及旧缓存撤权。实际完成应有明确对象及范围证据，合法保留和第三方副本应有可解释状态。任何真实对象处理另行授权。

## RC-D05｜E1、E2、E3 外部要求

### E1｜真实身份核验

**FACT（来源与状态）**。路线图的 E1 是正式实人核验及正式资格链。现有 `verify_status` 是运营审核，`pending` 和 `rejected` 在满足更高优先级账号条件时均使匹配准备不合格并显示各自运营原因。 `approved` 只通过运营这一项，仍受真实身份、账号、匹配输入、问卷、Lifestyle、报名等各自条件制约。后端可记录运营审核理由和 revision，申请可按预期版本重交，但该流程回执的 `realname_verified=false`。普通账号缺真实核验时正式准入 fail-closed，当前正向能力仅来自具名 TEST_ONLY。现有制裁/举报申诉 API 属于独立流程，真实身份失败、复核及供应商申诉尚无验收。 [路线图 E1](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md) · [运营申请](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Http/Controllers/Api/V1/OperatingApplicationController.php) · [运营审核](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Services/Admin/UserGovernance.php#L37-L58) · [正式门禁](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Services/TrustedIdentityService.php#L100-L119) · [资格业务影响](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Services/ProfileReadinessService.php#L16-L79)

| PROPOSAL | 产品收益 | 风险与成本 |
| --- | --- | --- |
| E1-A · 维持正式核验不可用 | 既有独立社交流程可继续准备，用户能看到准确的服务状态。 | 正式参与被阻塞。新增工程成本低。 |
| E1-B · 满足前置后另立具名试点 | 可证实正式准入、失效、复核与失败状态。 | 要求供应商资质、合同、费用、数据流和人工申诉。工程与运营成本高。 |

**ADVISOR_RECOMMENDATION**。路线图顾问建议先整理供应商资质、回执、失败/撤销和申诉要求，未具备真实证据时保留正式门禁，不用 TEST_ONLY 替代。 [路线图外部要求](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md)

**OWNER_PENDING**。是否批准后续选型准备、谁承担实际审核与失败申诉、启用的业务门、最小必要字段和访问主体。现实前置包括服务商法律名称与资质、数据字段及传输/存放区域、平台和供应商的保存期限各自可核实、凭证撤销和失效传播、费用、退出及迁移、删除或归还证明。字段可先从账号关联标识、核验状态与有效期评估，证件、面部及联系方式的必要性和持有方由适用依据决定。失败、身份不能确定、待补核与申诉结果应有不同业务反馈。选择或授权采购、传输真实数据、接入和运行分开。

**PROPOSAL（决策后验收）**。具名服务、凭证来源和时效回读，账户绑定错误拒绝，pending/失败/过期/撤销不能取得正式资格；approved 仍须其他业务门通过。验正式成功、撤回、失效传播、重复/延迟回执及人工申诉，可用已有独立功能进入安全退出路径。

### E2｜真实 Push

**FACT（来源与状态）**。O06 确认合法单条详情打开才标读，已读与待办独立。站内通知和点击后的当前权利在 M4-R/RC-F 有具名证据。系统 Push 是额外设备投递。源码返回 `REAL_PUSH_PROVIDER_PENDING`，注册限定 `local/testing` 与 `test_only`。设备记录绑定当前账号和设备会话，存 Token 哈希、代际及撤销时间；退出指定设备或退出全部可撤销对应记录。合成发送前重读静默、类别、设备会话、期限和当前业务内容，按通知、设备与代际去重。现有合成信封仅用通知 ID、固定标题与提示，`TEST_ONLY/SUPPRESSED` 说明模拟资格。真实供应商受理、平台到达及展示、失败/重试一律 `NOT_RUN`。 [Owner O06/O07](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_O06_O07_NOTIFICATION_READ_DERIVED_REVIEW_20261119.md) · [投递服务](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Services/NotificationDeliveryService.php) · [最小信封](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Domain/NotificationDeliveryContract.php) · [设备退出](https://github.com/zcx369658780/EliteSync-v10/blob/03d6740e9cbe36255129ef848d66d4a54dea2327/services/backend-laravel/app/Services/Accounts/DeviceSessions.php#L130-L164) · [RC-F 站内复核](https://github.com/zcx369658780/EliteSync-v10/blob/f7f06a856606a2192204371c03c3b59598a51660/docs/versions/v2/cloud-r0-20261121/V2_RC_F_ROADMAP_FUNCTION_CLOSURE_REPORT.md)

| PROPOSAL | 产品收益 | 风险与成本 |
| --- | --- | --- |
| E2-A · 首期使用站内通知 | 保留待办与安全回流，新增外部数据处理最少。 | 用户在应用外无法收到提示。新增成本低。 |
| E2-B · 条件满足后另立最小正文 Push | 给用户设备级提示并可独立关闭，站内仍是权威事实。 | 涉及锁屏隐私、账号切换、Token 轮替和在途通知。工程成本中至高，有供应商与值守成本。 |

**ADVISOR_RECOMMENDATION**。路线图顾问建议系统 Push 关闭，待提供者、平台权限、最小内容、退订、真实成功/失败回执具备后再独立开启。 [路线图 E2](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md)

**OWNER_PENDING**。是否仅站内或预备具名 Push，首期哪些类别、默认选项、锁屏展示和紧急例外；OS 权限与 APP 内选择怎样撤回，退出和账号切换后的旧设备处理方式。真实提供者的技术覆盖、费用、Token 保存/轮换/吊销、数据区域与退出机制待核实。请选择是否采用合成信封的通用文字作为未来起点。实际标读和业务确认均保留各自用户动作。

**PROPOSAL（决策后验收）**。明确区分供应商接受、设备实际收到和用户打开三个证据。覆盖 OS 拒绝、APP 静默、Token 更新/失效、设备注销和账号切换后的旧地址、权限过期后在途/深链安全、临时错误的有界重试、永久错误的停止与去重。撤销后可控渠道停止，设备已显示或不可控缓存按实证说明。锁屏、日志和供应商载荷不得泄露业务正文。

### E3｜法律、数据与第三方资产

**FACT（来源与状态）**。原路线图 E3 要求核法域、具名处理依据、个人数据和第三方素材。O04/O05、DATA-D1/D2、RET/HIS/OBJ 提供产品约束，真实用途、来源与法定期限仍 `UNKNOWN`。F-01 `READABILITY_PARTIAL` 涉及四批逐屏原稿中历史待审文本与标题上的 Owner 具名接受增量并存。已有静态索引缓解，状态继续保留。另行跟踪的 43 份原 PNG 在 GitHub 仍为 `PENDING_BINARY_UPLOAD`，历史清单的 36 项或重绘 SVG 不能替代原二进制身份、权属或公开许可证据。 [路线图 E3](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md) · [Owner DATA-D1/D2](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/decisions/OWNER_V2_DATA_D1_D2_PURPOSE_REUSE_CORRECTION_PUBLICATION_ACCEPTANCE_20261119.md) · [F-01 静态审计](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/workflow/V2_F01_HISTORICAL_SNAPSHOT_READABILITY_AUDIT_03_20261119.md) · [阶段 D 资产记录](https://github.com/zcx369658780/EliteSync-v10/blob/f7f06a856606a2192204371c03c3b59598a51660/docs/versions/v2/phase-d-20261120/PHASE_D_ENGINEERING_REPORT.md#L124)

| PROPOSAL | 产品收益 | 风险与成本 |
| --- | --- | --- |
| E3-A · 先取证，保持受影响动作关闭 | 准确保留权利和缺口，避免带未核验来源的公开与处理。 | 真实受理、历史资料复用和材料发布继续等待。新增工程成本低。 |
| E3-B · 对具名对象与素材逐批形成发布前提 | 有明确依据的一批可进入单独验收，证据容易追溯。 | 需专业法务、权利人和运行团队核实。工程及持续审核成本中至高。每批仍需 Owner 具名裁决。 |

**ADVISOR_RECOMMENDATION**。历史顾问建议以具名依据、具体对象及可核原件来解锁；受影响功能按实际证据判断，原图和动态验证各自保留。 [来源索引及资产边界](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_OWNER_ACCEPTED_SOURCE_INDEX_AND_AUDIT_SNAPSHOT_20261119.md) · [外部与法律建议](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_REMAINING_TRUE_OWNER_PRODUCT_DECISIONS_TRIAGE_V0_1_20261119.md#L66-L73)

**OWNER_PENDING**。确认目标服务地区、运营/处理主体、专业法律审查责任人和拟优先复核的对象或素材。要求查明适用法域与跨境情形、账号/匹配/出生资料/行为数据各具名用途、历史迁移来源、许可版本与撤回、第三方评论/媒体/字体/插画权利、存储副本与备份恢复、依法或安全必要例外及保存期限。F-01 责任人需核具名接受与旧文并存的检索风险。43 PNG 需权利人、原始字节 SHA-256、来源、用途、允许上传/公开范围及授权后读回，公示和授权分别判断。

**PROPOSAL（决策后验收）**。法律意见和责任人记录到具体数据类别、用途、对象、期限和例外。以资产 ID、版本、许可来源与范围形成清单。合成验证撤权、版权下架、对象请求、备份恢复后的访问限制及审计证据。F-01 后续须有版本化索引和抽查才能变更状态。43 PNG 只对具名获准原件作二进制及 GitHub 可见性回读，历史资产状态按实证更新。

## Owner 与顾问审阅回执

请按选项名称登记 D01、D02、D03、D04，以及 E1/E2/E3 的单项决定。每项记录所选范围、前置证据、责任人和有效条件。必要的实施、对外联系、共享环境、发布和正式 UI-S 授权另行记录。报告归档后停止，RC-E 尚未启动。
