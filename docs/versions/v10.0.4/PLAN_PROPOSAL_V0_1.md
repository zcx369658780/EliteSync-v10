# EliteSync-v10｜v10.0.4 版前计划草案｜Me Readiness 具名条件解释与安全恢复引导

> **PROPOSED / CODEX_FEASIBILITY_REVIEW_ONLY / NOT_FROZEN / IMPLEMENTATION_NOT_AUTHORIZED**  
> 日期：2026-10-13（Asia/Shanghai）。Owner 已明确同意**进入 v10.0.4 版本规划**。本页是供指定本地 Codex 做**有界只读可行性核查**的版前草案；不是正式冻结计划、产品资格政策决定或执行授权。  
> **推荐目标**：让现有用户可访问的 `Me → Readiness` 从一个总体状态/兼容跳转页，走向“目前哪些准备条件已被适当来源确认、哪些尚未确定、为什么、用户可安全前往何处”的**真实只读解释/恢复体验**。不把已接受的 synthetic Runtime Readiness 评估当成正式用户资格，不替 Owner 填写尚未确定的必需清单。

## 1. 代码、产品和版本事实

- **草案前的 GitHub main**：`a4f441a761e1c9ae47ab0aae8c32a5109466cb50`，Tree `5fa3f9528f1e37d1d4af1c6d589bac41c321f497`。此前 v10.0.0～v10.0.3 四版 `ACCEPTED/CLOSED WITH OBSERVATIONS`（各自 synthetic/dev-test 范围），已接受必要代码均按白名单定点纳入远端 main。v10.0.3 新增的是**真正复现并修复的** GoRouter 动态 Guard/路径保持缺陷，不能作为下一版重新设计或回归的理由。
- **Codex 最近报告的本地安全基线**：`C:/Users/zcxve/.codex/worktrees/elitesync-main-64a098f/EliteSync-v10`，clean，HEAD `64a098f88543efa44b499d04cb91d4c7c4290238`，Tree `6d472934ceee64eb2fea01c4f14d55518df8fa3b`；此后远端只发布了一份四路径的状态/知识文档提交 `a4f441a761e1c9ae47ab0aae8c32a5109466cb50`，而非修改已接受 Router 源。Codex 后续须核最新远端源码，不要凭本草案把可用旧隔离树误写为实时最新 HEAD。**原 `D:/EliteSync-v10` dirty main** 与43项 tracked修改、208项 untracked、109项具名保护继续保留，不允许 `pull/reset/rebase/clean/stash` 或整包迁移。
- **产品权威**：[已接受 APP 功能设计](../../gpt-project-sources/06_新版本APP功能设计正文_已接受.md) 的 Domain 8 规定 named Readiness checklist、条件必需/可选、用途、阻塞解释、可纠正/恢复、到期/失效透明；Domain 12 要求渐进设置与 resume。 [Owner 接受记录](../../gpt-project-sources/07_新版本APP功能设计Owner接受记录.md) 明确 `Home | Progress | Messages | Me`、`Match != Connection != Conversation != Relationship`、独立同意。**正式必需成员/launch eligibility/最低身份保证级别等仍未决定**，不能由开发者预设。
- **现有 Me 用户页**：`apps/flutter_elitesync_module/lib/features/me/presentation/pages/me_purpose_pages.dart`（Git Blob `614d412f417d7ce2e6385ac5324c4fd79660b788`）的 `ReadinessPurposePage` 当前读取 `navigationGuardProvider.readinessState`，展示总体状态、受限文案及“验证状态”“问卷”两个兼容入口；无正式具名 prerequisite-set 数据消费。现有 `MeLandingPage`（Blob `619987bc7da198c1586c9bf03848ee951211235c`）已把五种用途独立入口明确展示，**不得重复构建新 Me/Readiness 顶层入口或重新打开 APP-T04**。
- **现有客户端 Guard**：`apps/flutter_elitesync_module/lib/shared/providers/navigation_guard_provider.dart` Blob `f15eb57367349664dbc057424bae66bf5287473b`，现行 Ready 仅在明确 Dev synthetic flag 下建立；非 Dev authenticated 仍可为 `UNKNOWN`。现有 `Home`/GoRouter 的 Readiness 跳转和失效保护已按前版接受，**绝不能为了清单展示修改 Guard 语义、Match unlock 或 Router**。
- **后端已接受而不可滥用的资产**：`RuntimeReadinessDerivedEvaluator` Git Blob `1d5918d890d5eb753032b24540a4a133107c811f`；[领域 evaluator 接受](../../architecture/ELITESYNC_V10_BACKEND_RUNTIME_READINESS_DERIVED_EVALUATOR_IMPLEMENTATION_ACCEPTANCE_V0_1.md)仅建立精确 prerequisite-set/依赖向量和 fail-closed 派生规则；[BA-02 技术设计接受](../../architecture/ELITESYNC_V10_BACKEND_RUNTIME_READINESS_AUTHORITY_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md)要求 Eligibility / Checklist / Verification / Effective Readiness / Presentation 分域。
- **已有 synthetic HTTP vertical slice**：[IP-13I-R7 接受](../../architecture/ELITESYNC_V10_IP_13I_R7_RUNTIME_READINESS_HTTP_ENTRY_IMPLEMENTATION_ACCEPTANCE_V0_1.md)仅对 `POST /api/v2/runtime-readiness/evaluations` 的 bounded synthetic/dev-test 验证成立。成功响应**仅五字段**：`readiness_classification`、`reason_categories`、`materialized_projection_usable`、`condition`、`synthetic_dev_test_only`；**没有供真实用户逐项展示的 prerequisite details**。其 READY 也不是可信生产来源/正式用户 auth/资格。不得将 HTTP 200、存储 materialized、演示 fixture 或前端完成按钮升级为 `READY` 权威。
- **另一个同名词的非产品接口**：`GET /api/v2/app/readiness` 的 `AppReadinessController` 表示应用基础设施就绪检查（DB/queue/monitoring等），**不是用户 Match Readiness**，不许误接。
- **历史已接受来源**：[APP-T04 接受](../../architecture/ELITESYNC_V10_APP_T04_ME_PURPOSE_SURFACES_READINESS_ONBOARDING_GUARD_FOUNDATION_ACCEPTANCE_V0_1.md)只接受Me purpose/Guard fail-closed基础，Flutter执行测试当时仍 NOT_ESTABLISHED；[APP-INT-02 synthetic Readiness/Match接受](../../architecture/ELITESYNC_V10_APP_INT_02_SYNTHETIC_READINESS_MATCH_STATE_INTEGRATION_ACCEPTANCE_V0_1.md)只限明确 Dev 演示与只读 Match，不证明真实 readiness。已有具体测试需Codex定点核查并排除重复。
- **仍冻结**：BE-12七条真实私密消息路由 opaque404、V57/H1/H2/D0未激活、`NOT_READY`、`RuntimeReady=false`、`M6 CLOSED`、`S2 unsigned`、`OwnerEnvironment PENDING`；不解冻正式平台、实际用户数据/认证与生产环境。

## 2. 建议唯一产品增量（尚待 Codex 判断可行性）

**方向**：以现有 `Me → Readiness` 页面为唯一产品展示入口，加入**真实的只读说明/安全恢复切片**，清楚区分“来源确认的具名条件”与“整体条件集合本身未知”，而非单一完成百分比或黑箱总分。明确条件是否存在、是否必需、各项结果、来源/新鲜性和可纠正入口的展示资格必须由实际已有 source contract 支撑；**不得在代码里擅自签发 Match 所需成员**。

### A. 版前资产/来源资格核查

1. Codex 在已存在 clean 隔离基线中定点检查 `ReadinessPurposePage`、`MeLandingPage`、`NavigationGuard`、Verification/Questionnaire compat destinations、APP-T04/APP-INT-02 的已接受语义及相应 Flutter 测试。识别旧根同一 UI 相关 LOCAL_ONLY 有哪些具名差异、是否真实必要；**默认不搬入**。
2. 核实 `RuntimeReadinessDerivedEvaluator`、synthetic HTTP五字段响应、current Flutter 是否已有可复用的 privacy-minimal condition/reason 解释投影或 developer fixture。严格标记 `ACCEPTED`、`IMPLEMENTED_NOT_ACCEPTED`、`LOCAL_ONLY_UNVERIFIED`、`NOT_IMPLEMENTED`、`PROTECTED/PAUSED`、`UNKNOWN`；不能把仅 backend domain evidence 直接作为前端权限。
3. 给出**一个**经过真实代码确认的最小 UI 消费切片与文件白名单。若现有 payload 根本不能逐项确认成员，则不得伪造“必填年龄已完成”“身份核验通过”等；应把清单成员设为 `UNESTABLISHED/UNKNOWN`，或只做基于已有独立事实的状态说明/安全恢复，**不装作真正 checklist 已经完整实现**。

### B. 用户可理解的 Readiness 只读解释与恢复

1. 在原 Me Readiness 页面保留现有整体 fail-closed 状态与两个兼容入口；可新增可独立测试的**说明投影/清单区域**，仅在确切已建立 prerequisite-set 时显示具名、真实来源支撑的成员。成员必需/可选/状态/用途/失效/重试或纠正路径只能从具名**受保护使用范围**的可信合同取得，不能由当前登录态/问卷填写数量/HTTP success 推断。
2. 如果 prerequisite-set 权威尚未建立（当前已证事实），普通用户必须得到明确“**具体必需条件尚未确定/来源未确认，不能由此判断已满足匹配资格**”的可理解状态；同时仍可访问现有验证状态、问卷等**非授权**恢复路径。不能把未知等同失败、空列表等同所有条件完成、`UNKNOWN` 等同 `NOT_READY`。
3. 仅在开发/测试 synthetic 受控 fixture 中允许展示具名成员及状态，但必须有醒目的 Synthetic 标签、清楚表示非真实本人/正式资格，并与普通用户状态彻底隔离；不得将其作为实际 Match/Connection/Conversation unlock 或默认持久缓存。
4. 用户页面要分清 `Eligibility`、`Checklist Completion`、`Verification`、`Effective Readiness` 和 `Presentation`；若已有来源只能支持一个分类，不把它包装成其余分类。保留已有解释、用户选择、隐私/用途边界，尤其不得把编辑个人资料或完成问卷直接变成 Match opt-in。
5. **不是新通路版本**：不准新建真实服务/数据库接口、实际 Auth/session、生产 Readiness writer、真实受保护来源或读取私密用户资料。后台既有 synthetic HTTP 不自动连入非 Dev Flutter；如要跨语言实测必须在独立 fixture/harness 中限定 synthetic，不能靠默认启用真实网络达到“端到端”。

### C. 直接相关的 Flutter/领域有限测试

- 在真实 `ReadinessPurposePage` / Me 已接受路由语境中验证：无来源/default non-Dev → 未确认；Dev synthetic 有醒目标签；可信/不可信/过期/失效/前后输入变更 → 安全降级且旧 Ready/列表/下一步文案不残留；点击已有兼容入口不会赋权。若必需集合尚未建立，应专门测试**没有对该集合做硬编码假设**。
- 如源本身仅有整体 `readiness_classification + reason_categories`，测试只验证其允许的有限文案，不凭推断 invented member labels；真实 Domain evaluator 与 UI 不同层的测试成绩分别记录。
- 允许使用本地已有 Flutter package graph/SDK 和合成 fixtures；针对性 Flutter widget/provider tests 和必要的最小 PHP 合同检查需实际 `exit0`、失败-修复回执、安全 stdout/stderr 与准确源码/fixture Git 身份。**不机械重跑旧 v10.0.0～0.3 回归配额**；不做真实 API、UAC、Android build/install/设备、SDK升级、业务DB或公网连接。
- 如果当前已经接受的前端代码足够覆盖同目标，不能只为新增版本而重写现有功能；请 Codex 给出一个相邻的真实 MVP 解释/恢复缺口或一个合理的可做产品切片，而不是重新叠加测试治理或资格诊断。

## 3. 拟排除的政策与工程越权

- **禁止指定正式 required/optional 清单、年龄或地区准入、身份保证级别、第三方验证方法、真正 Match/Conversation 授权、Relationship暗示或黑箱总分**。这些是仍未决的产品/政策事实，属于 Owner 未来另行明确的决定。
- 不修改 `RuntimeReadinessDerivedEvaluator`、既有已接受的 R5/R7 domain/HTTP状态词汇/数据权限、生产路由、Guard、Home/Progress、Connection/Conversation、v10.0.3 Router 修复、正式私密内容存储。
- 不打开 BE-12、V57/H1/H2/D0、Safety Operations、真实日志/账号/审查数据、生产API、部署、正式Android M5/M6。
- 本版不以“清单页面已经显示卡片”代替“真实条件成员有权威来源”；没有来源时必须透明告知当前缺口。

## 4. 版前建议 AC（**不是已冻结的验收标准**）

| 暂拟 P-AC | Codex 需要论证的可验收目标 |
|---|---|
| P-AC01 | 最新代码基线与既有 Me/Readiness/Runtime Readiness 接受资产去重，准确区分未知政策和真实可读取材料；保护两棵旧工作树 |
| P-AC02 | 一个可见的 Me Readiness 状态解释/恢复产品切片，复用现有页面，不引入新顶层入口或自动资格 |
| P-AC03 | `UNKNOWN`/必需集合未知/过期/来源不可用时 fail closed；仅确证数据才具名显示，不推断 ready/required/optional |
| P-AC04 | 至少一个真实 Flutter Widget 路由/页面测试与输入变更/异常负向断言；若跨 PHP 则同次 synthetic 字节与权限边界可验 |
| P-AC05 | 固定代码候选、最小文件白名单、重要原始（经安全处理）证据/manifest，Astra 可从 GitHub 独立读取 |
| P-AC06 | Astra 独立终验与复盘，Acceptance、GitHub安全定点集成、本地隔离基线及范围回归分开记录；不自动下一版 |

若 B 无法带来明确可用的产品改善，**不冻结一个只复制旧页面/静态假清单的版本**，须按Codex现场结果选定一个真正缺口。草案中任何示意文案不是最终确定的用户政策。

## 5. Codex 只读核查应集中报告

先读取本草案、最新 `main`、已接受产品/Readiness source/相关 APP-T04/APP-INT-02 与真实 Flutter/后端资产。之后集中回答：

1. 最新 `main`/Tree 与最近 clean 隔离 worktree `elitesync-main-64a098f` 的实际差异，原 `D:/EliteSync-v10` HEAD/index/dirty/109保护是否保持。**本轮不移动任何分支和worktree**。
2. Readiness页面与真实可获得的资料/问卷/验证状态、后端 Runtime Readiness 五字段源的准确代码路径与 Git Blob：哪些可以安全用户展示？哪些是`UNKNOWN`或仅 synthetic？是否已有实测清单组件？
3. **推荐唯一最小且有真实产品价值的 B 切片**、预计准确新改文件、需要的测试和一个明确可复现的失败/缺失场景；完全可用就说已完成，不能凭模型凭空写需求。必要 Owner 决定单列，尤其是任何正式 required policy 一律不得自行设定。
4. 估计1～3工程日仅作粗略提议，实际文件/依赖/风险评估以真实源码为准；不知道则 `UNKNOWN`。若无法安全生产某类 member data，给一个 source-correct 的降级呈现/恢复 UX；不要转为大规模新后端或旧治理审核。
5. 六项 P-AC 如何成为冻结的少量清晰行为 AC；必须列出实际可以运行的合成 Widget/路由回归及不会执行的授权/平台测试。
6. 以 `V10.0.4 PLAN REVIEW — READY / READY_WITH_FINDINGS / BLOCKED — IMPLEMENTATION_NOT_AUTHORIZED` 开头；本轮 `READONLY`、`NO TEST RUN`、`NO IMPLEMENTATION`、`NO MAIN MERGE`、`NO LIVE AUTHORITY`。

## 6. 正式流程

1. Astra 把本草案作为唯一版前材料发布 GitHub；Owner 手动转交指定本地 Codex。
2. Codex 用干净本地基线做有界**只读**核查，聚焦真实资产来源、已接受语义与可执行的最小产品增量，集中反馈。
3. Astra 审议后才可能另行冻结 `docs/versions/v10.0.4/plan.md`（固定 Commit+Blob、代码父基线、单一写入范围和实际 AC）。有 Owner 产品决策缺口时在冻结前提问，不自行编造。
4. Owner 再手动发出明确冻结版执行授权，Codex 自主实现/自修/验证集中交付；Astra 独立终验/复盘；已接受成果按 K08 安全 GitHub定点集成并手动本地基线接续。**不因本草案自动写代码、修改旧 accepted、打开真实消息或发起 v10.0.5**。

**状态：`V10.0.4 PROPOSED — READINESS_EXPLANATION_AND_SAFE_RECOVERY_FEASIBILITY — AWAITING_CODEX_READONLY_REVIEW`**
