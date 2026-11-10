# EliteSync-v10｜v10.0.8 版前范围草案 v0.1｜独立Web管理端真实运营闭环

2026-10-15。**V10_0_7_K08_COMPLETE / V10_0_8_SCOPING_STARTED / NOT_FROZEN / NOT_IMPLEMENTATION_AUTHORIZATION**。

本文件由Astra在Owner转交v10.0.7 K08完成回执并实读GitHub固定身份、路线图、功能台账和现有Blade/API代码后提出。**不是正式冻结plan、不新增AC、不启动任何数据库/服务/构建，也不授权Codex开始0.8实现**。正式plan只能在Codex一次集中版前反馈及少数必要Owner决定后另行冻结为`docs/versions/v10.0.8/plan.md`，届时由Owner手动派发。禁止重复规划v10.0.6/0.7或重做旧K08。

## 一、最新权威代码状态

- 唯一仓库 `zcx369658780/EliteSync-v10`。
- GitHub已实读**集成完成的main**：`a75b8d4061ae012937ef4823120b396f257d3aec` / Tree `89637891276cdf4280f918ccad7eb4c5030f55be`。当前版本技术起点建议以此为锚；此后版前纯文档提交不自动替换代码起点，正式冻结前再核实际main/Tree及专用本地HEAD。
- v10.0.7最终接受R1候选：`cf0c359b86e35c794da389a58ba0b687c3c0bd32` / Tree `11f1d086b0c9180998a3684c0df176e1d9c4d2b2`。产品集成：`18c1ddb67378518b6b2c3e912e1e3b2afd394051` / Tree `4cde05f06079a8bd4879ae34a31db7ac0c30c625`。GitHub核实三份Tree的`apps`、`services`、`question_bank`子Tree及`dating_question_bank_v_1.json` Blob相同，包括R1通知隐私修复。
- [v10.0.7 K08](../v10.0.7/integration.md)、[Astra验收](../v10.0.7/acceptance.md)及[复盘](../v10.0.7/retrospective.md)分开登记。v10.0.7继续`ACCEPT WITH OBSERVATIONS`；旧Flutter普通全量793通过/5失败、带同次fixture821通过/3失败，均exit1；三项旧展示/导航失败已在原基线复现，本轮K08未重新运行。Android/Flutter/PHP语法/构建等不因单纯创建本文件再运行。
- 依据：[Owner决定](../../PRODUCT_DECISIONS.md)、[当前路线图](../../architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)、[单份恢复台账](../../architecture/RESTORATION_CAPABILITY_MATRIX.md)、[现行工作流](../../workflow/CURRENT_WORKFLOW.md)。原dirty根、真实用户/原备份和0.6/0.7验收卷保护保持。

## 二、产品目标与已核实入口

**优先把v10.0.6创建的独立Blade管理员登录/用户禁用雏形扩为真正可操作的Web后台，沿用Laravel Web会话、共享业务服务和APP共用的持久数据库**。不另造React/Vue前端栈、第二个后端或第二套业务事实库；若现场证据证明Blade不足再提具体Owner决定。Web操作的成功须可在实际用户APP读回，不能只做统计卡、静态表格或API单侧测试。选定既有Flutter Admin页面仅作为字段/交互参考，不当作已经完成的独立Web实现。

当前v10主线具名代码已核：
- `services/backend-laravel/routes/web.php`在/admin仅有login、用户列表/搜索、POST禁用与logout；`resources/views/admin/`仅layout/login/users三页；`app/Http/Controllers/Web/AdminController.php`沿用AdminAccess/DisableUser。
- `routes/api.php`现有/admin users、verify-queue/verify、reports/reports/{id}/action、questionnaire quality-stats/prune-low-drop及/admin/matching rounds/runs/prepare/execution-requests/reveal/retry/close；`AdminMatchingController`包含state_version、Idempotency-Key、确认语义、consumer配置依赖。
- `app/Http/Controllers/Api/V1/AdminController.php::updateVerify`现仅更新verify_status；`::reportAction`中的restrict/banned/restore分支直接设置用户字段，须与v10.0.6已经接受的`DisableUser`令牌/持久session撤销和Web/API共享语义核对，不能让另一个管理入口产生禁用旁路；不能任意放宽restore的政策含义。
- `AdminController::questionQualityStats/pruneLowDropQuestions`有真实数据查询和启用状态写入；要核低drop的产品规则、关联当前157题/137启用的实际题库、干跑/确认/审计和用户问卷影响，不能对原0.7验收数据直接prune。
- `apps/flutter_elitesync_module/lib/features/admin/presentation/pages/`已有Dashboard/Matching/Moderation/Report/Users/Verification代码线索，**不是Blade页面已实装的证据**。

**版前候选管理包（未冻结）**：

| 台账 | 可观察候选业务链 |
|---|---|
| B01 用户管理 | Web管理员查询/筛选用户及状态、必要禁用/会话撤销；后台操作→同ID DB→APP拒绝/保持，管理员名单＋role＋CSRF；敏感字段最小化 |
| B02 资格/验证审核 | Web待审列表、状态/审核决策→真实DB→APP所依赖的verify/资格/展示状态变化；非法角色、伪造、并发、未配置拒绝。具体status政策须以现有实现核实，不捏造身份认证要求 |
| B03 举报/内容处理 | 用户APP具名开发举报→Web列表/详情/处理→DB/audit→APP block/可见性/禁用体现；现API直接设置disabled/restore的安全差异须收口；不得任意查看私信正文、泄露举报者私密信息或恢复已撤销权限 |
| B04 匹配运营 | Web创建/执行请求→明确受控consumer实际领取、失败重试、reveal/close、幂等与state_version→MariaDB真实MatchingRun/round→用户APP Match显示/拒绝；不能只写pending任务、误称Web后台已自动运行consumer |
| B05 问卷运营 | Web统计及具名预览→dry-run→带确认的题目启停操作/审计→DB有效题/答卷影响→APP题目与资格读取；不重写原题库或在已接受的0.7库上做破坏性测试 |
| B06 必要版本/通知/设置 | 仅当源码/原功能清单证实后台确有管理需要时，纳入真正可操作的管理入口；不得承诺尚不存在的Push/外部通知供应商或空按钮 |

允许同一版本跨Blade/Laravel共享服务/数据库迁移/真实APP必要展示/集成测试修复；不默认限制改一个文件或新建第二套管理数据库。独立Web认证必须是浏览器session＋有效CSRF与服务端双重管理鉴权，不能把APP Bearer token/管理员菜单隐藏当权限。

## 三、必须明确保留的用户侧待恢复功能

v10.0.7已接通真实问卷→Matching→双方CN/MC→文本/本地图片和八字/MBTI/动态/站内通知，但完整软件**仍缺**RTC两端音视频、完整紫微/西占（准确性与Kerykeion/Swiss许可）、Buddy/Social真实业务、其他已实现原版媒体能力、地图/系统Push/SMS、历史真实数据与附件恢复。原版已实现且选定基线的功能不能因为Web管理版优先就默默丢弃或推迟到内测以后。

Codex此次只在需要时按[台账](../../architecture/RESTORATION_CAPABILITY_MATRIX.md)具名分析上述能力的实现来源、独立第三方依赖和与当前Web后台的耦合程度；给出**0.8中能和管理包合理共用的用户恢复子链**及剩余具名包排序。不要为RTC自动购买/启动SFU或第二端、开启被许可门禁blocked的占星依赖、用seed排盘声称准确、擅建新Buddy真实运营政策。若Owner取舍未定，单列具体决定，其他Web模块可继续规划。

## 四、版前集中调查任务（完成一次即可）

在K08专用基线中，Codex只读核实上述路由/Controller/Service/表/APP当前真实调用链及确定来源的旧管理资产，形成一份含：
1. B01～B06每项的现有Web页面/接口、Laravel业务服务、表/迁移、可复用测试及**实际运行状态（本轮均未实测0.8）**；划分可复用、需补、依赖、真正需Owner政策取舍，不将API存在冒充Web可用。
2. 特别定点审查verify_status的APP业务意义、reportAction封禁/恢复绕过共享DisableUser的风险、matching运营消费者启动策略、问卷题目变更时已提交答卷/attempt兼容与留证。
3. 一份推荐的**0.8可冻结功能组合**，以管理员实际浏览器操作→Laravel共享服务→受控DB→同一开发用户APP结果为基本验收单位，并给出相应候选AC（不是当前冻结标准）。若规模过大，提供一份有源码依赖依据的优先组合及明确后续落点，不拆成每页面独立版本、不新增连续考古/环境治理版。
4. 建议复用现有Android AAR/APK、Laravel loopback/Web session、Matching consumer、本地MariaDB10.11/AVD构建底座；为0.8**另立隔离开发库、测试账号、媒体区/卷**，不得改写或重seed0.6/0.7验收环境。专门提出必要Web浏览器会话/CSRF、安全截图与DB/APP双侧证据。
5. 现行Owner原则、旧通知明文开发记录、权限撤销、隐私/举报者信息最小化、角色白名单空列表拒绝、生产fail closed以及非开发端许可门禁继续成立。对真实外部服务、付费、系统安装、原始SQL/VHDX或生产权限需求必须具体单项列决策，不能一并申请全局提权。
6. 准确给出实际`main`和产品tree、哪些旧Flutter3项fail/两个fixture fail可能被0.8影响、如何做必要差异回归而非无差别重测历史；时间/工程量若无实测则标估算。

**本阶段授权只读具名源码与已发布安全GitHub证据，及已允许的本地具名源码定位；不授权创建/启动0.8开发数据库、改代码、构建安装、禁用真实用户或修改历史/生产系统**。不因本草案恢复Work/dot实时监督、自动轮询、单一提交或每版新worktree。难以获取的本地原证标CODEX_REPORTED/UNKNOWN。

## 五、下一步与执行边界

本版前调查完成后提交**一份**固定GitHub `FEASIBILITY_RECOMMENDATION.md`并集中回报`V10.0.8 FEASIBILITY_READY / NOT_FROZEN / NOT_IMPLEMENTED`。Astra按证据确定正式`plan.md`和AC，必要时只请Owner对少数真实风险作决定。**正式plan发布及Owner手动派发前，不开始v10.0.8产品实现；不自动进入v10.0.9、历史数据或生产。**

终点：**V10.0.8 PREPLAN READY — CODEX FEASIBILITY PENDING — NO IMPLEMENTATION DISPATCH**。
