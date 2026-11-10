# EliteSync-v10｜v10.0.5 版前计划草案｜Progress 动态阶段摘要与安全下一步

> **PROPOSED / CODEX_FEASIBILITY_REVIEW_PENDING / NOT_FROZEN / IMPLEMENTATION_NOT_AUTHORIZED**  
> 日期：2026-10-14（Asia/Shanghai）。Owner明确批准进入v10.0.5的**规划阶段**。本草案只授权指定Codex做有界、只读的真实资产/实现/测试核查；正式冻结和编程需要后续独立步骤及Owner手动派发。  
> 目标：让现有 **Progress（进展）** 从静态“匹配、连接”两个入口，演进为可靠的**只读阶段状态概览与下一步导航**。优先复用既有状态提供者/投影，绝不以合成状态开放正式业务授权，也不复制已接受Home主循环。

## 1. 当前代码与已接受基线

- 本草案前真实GitHub `main=c687acc6e7978470a2c2501fb2662b2a5492c553`，Tree `9a913acfcc96f79e8db93886097148f9bb36cdf2`。v10.0.0～v10.0.4 在各自synthetic/dev-test限定范围独立验收通过、接受对象定点纳入远端主线；上一版本地隔离基线及限定回归由Codex报告READY，网页核远端对象，不声称亲自读取本地收据。
- Codex最近回报的隔离CLEAN基线是 `C:/Users/zcxve/.codex/worktrees/elitesync-main-d49c308/EliteSync-v10`（HEAD `d49c308347d2b13f9ad417367b7ae4ec618cb4bc`，Tree `602f2aa0a219d24f6fd696c04bfbde9c442dce33`）。之后GitHub仅增一次K12状态/知识文档提交，**不得把旧本地HEAD冒认为实时最新main**。原 `D:/EliteSync-v10` 脏主树、43项tracked修改/208项untracked、109项保护与其它干净基线都继续保留，禁止整仓 `pull/reset/rebase/clean/stash` 或默认带入未经接受的 LOCAL_ONLY。
- Owner已接受产品 IA `Home | Progress | Messages | Me` 和慢约会独立阶段 `Onboarding → Readiness → Match → Connection → Conversation`；`Match != Connection != Conversation != Relationship`，任何投影≠权限。MVP的Home/Progress应以清楚的当前状态、原因/不确定性和可自决下一步为主，不能追求提醒焦虑、活跃频次或黑箱兼容分。
- 现有 `apps/flutter_elitesync_module/lib/features/progress/presentation/pages/progress_page.dart` Git Blob `8dd79b804c0d82a52eff5f876918d0f4673b2ed4`：`ProgressPage` 是StatelessWidget，仅提供两个静态列表入口 `progress-match-entry`、`progress-connection-entry`，指向既有 `/progress/match` 和 `/progress/connection`；尚无实际的阶段状态消费/失效摘要。这不意味着下游Match/Connection页面不存在或需要重做。
- 已有 `features/home/presentation/providers/calm_home_projection_provider.dart` Blob `a07e0863573db74fd7705a4657cdedc3295ba91c` 与 `features/home/presentation/state/calm_home_projection.dart` Blob `b253b9f87990f9140d495ad6fa6a733b329842ac`：现成Readiness/Match/Connection/Conversation状态摘要的authoritative/synthetic/notYetEstablished/unknown词汇与nextDecision；此provider目前**只有`env.isDev && env.useSyntheticHomeProjection`才读入合成状态**，否则返回静态保守 `CalmHomeProjection.current`，不可把该投影无条件称为正式领域来源。匹配loading/error/failed/closed和noCandidate必须保持fail closed。
- 现有 `connection_presentation_provider.dart` 内源已接受的synthetic Connection state仅在Dev加显式环境标志下可用；`ConnectionPage` Blob `df83c4893f76b2b0413d64304edb5d69b165ff35`具备独立生命周期展示与开发演示；不得复制造一个Connection写控制器。
- v10.0.3 `app_router.dart` 已接受动态Guard刷新、合法路径保持及失效跳转（Blob `2eebd3f0959414f95e2a3ec61e94d73a2779d795`），新增真实路由测试 Blob `6811828ffc8c2c37f752902d7f91513d6c5dc478`，有Home→Progress→Match/Connection同挂载覆盖。v10.0.4 `Me→Readiness` 用户来源解释已接受，正式prerequisite-set/最低身份资格仍未知，**本版不重做Router、Home或Me页面**。
- BE-12七条真实私密消息路由仍opaque404，V57/H1 PAUSED/NOT_ACTIVATED、H2/D0 unsigned、`RuntimeReady=false`、`M6 CLOSED`、`S2 unsigned`、`OwnerEnvironment PENDING`均不因本版变化；完整Feature/Android/生产服务没有新增授权。

## 2. 建议的唯一产品切片（Codex核查后再冻结）

**Progress主页面**展示简短的、可随现有provider实时变化的 **Readiness、Match、Connection** 只读状态与“查看现有页面”导航。仅在现有证据确实支持时可用已有Conversation的只读摘要；不要强行加入消息/关系阶段，不能把Home的`authoritativeNextDecision`本身当权限token。维持`Home | Progress | Messages | Me`及原两个静态入口/route key/下游页面。

### A. 来源资格与复用核查

1. 用当前实际main和已有clean本地基线，核真实 `ProgressPage`、`calmHomeProjectionProvider`、`MatchRoundProjectionProvider`、`ConnectionPresentationProvider`、`navigationGuardProvider` 与此前APP-INT-05、v10.0.3已有测试。若其它正式接受文件已实现等价Progress动态stage列表，则不重复。
2. 区分 `ALREADY_ACCEPTED_AND_TESTED`、`PRESENT_UNTESTED`、`IMPLEMENTED_NOT_ACCEPTED`、`LOCAL_ONLY_UNVERIFIED`、`MISSING`、`PAUSED_OR_PROTECTED`、`UNKNOWN`。原脏root存在局部Flutter/Progress差异时只按最邻近具名对象判断是否必要，不整包导入。
3. 优先重用**同一权威标签和状态枚举映射**而非新建总分、生命周期或第二套聚合source；需要新私有只读helper可放Progress同文件，任何新增共享业务authority/provider/网络接口须报告阻碍，不默扩范围。

### B. Progress受限用户体验

- 非Dev或演示标志关闭：保守显示“状态/来源尚未建立或未知”，说明可以查看现有Match/Connection页，但**不声称当前有提案、连接已成立或具有消息许可**。UNKNOWN≠无资格/无兴趣/对象不合适。
- 已明确开启的Dev synthetic：仅显示与已有真实投影一致、醒目标为Synthetic的Readiness/Match/Connection阶段状态与来源限制；阶段展示**不是发起匹配、建立连接或发送消息**。状态可能loading/error/noRound/failed/closed时不能沿用旧success/CTA，必须按现有业务分类保守降级。Connection paused/closed时不显示“已连接”及对话可用暗示。
- 动态变化：同次挂载下新旧状态更新应立即改变可读摘要，用户返回Progress时看到当前快照；现有Route Guard对`/progress/match`的Readiness检查继续生效，无关状态变动不能重置路径。
- 保留已有Match、Connection入口和文案的基础含义，页面只提供**查看/解释/导航**，不写业务状态、不可由Progress按钮越过已有Guard、不得提前导向私密Conversation/RTC或Phase2 Relationship。屏幕狭窄与放大文字仍能正常阅读。

### C. 版前可行性与范围最小化

- 草案暂建议可修改 `apps/flutter_elitesync_module/lib/features/progress/presentation/pages/progress_page.dart`，新增一个Progress真实路由/状态消费者widget测试；Codex必须核实际可复用接口、确切新增测试目录及所需固定Git Blob，在正式冻结前收敛为唯一完整白名单。
- 测试推荐真实 `appRouterProvider + MaterialApp.router + AppShell`，虚构Guard/Match/Connection fixtures且明确Dev synthetic开关；实际断言Home和Progress相应stage的文本/权威标签一致，入口到Match/Connection以及Guard失效路径正确，loading/error/closed/unknown或演示开关关闭后旧成功清除。
- 对`apiClient/dio/secureStorage/Match remote/telemetry`、本地写入及HTTP设置可执行的**拒绝哨兵+实际零调用计数**；禁RTC watcher与不必要的warmup。单靠`localhost:9`并非无网络证明。若无法隔离远端调用，止于有界报告，不能为了测试关闭原保护。
- 测试限新Progress文件及直接必要的已接受Home/Router/Connection用例与窄`dart analyze`，不机械重复PHP294、Flutter42+13全部回归或Android完整平台构建；退出码和**stdout内容共同检查**（v10.0.4的R1经验），不能因为analyze exit0就写“No issues”。

## 3. 排除事项

正式Readiness的required/optional成员与最低身份保证/准入政策尚未建立，不能补写。不能修改Router/Guard、Home投影领域定义、Match/Connection/Conversation授权、任何后端route/写入、生产数据、Profile/问卷/Verification源；不改变已接受的首页优先动作或APP-INT-05独立消息同意。
不做真实账号、设备/Android安装、下载/升级SDK、联网调用、UAC、生产DB/API/SSH、敏感日志发布、后台提醒/OS推送、Safety或v10.0.6新版本。候选未独立验收前不能合入main；原脏root及所有未吸收LOCAL_ONLY仍保护。

## 4. 候选AC草稿（**尚未冻结**）

| P-AC | Codex应验证的实际门 |
|---|---|
| P-AC01 | 固定最新父SHA/Tree、既有Progress/Home/Match/Connection资产与实际测试边界，明确未重复APP-INT-05/v10.0.3，保护原dirty与前一clean基线 |
| P-AC02 | Progress页面真实展示来源明确的阶段只读摘要，保留既有Match/Connection入口，不增加顶层页/业务写操作 |
| P-AC03 | default/nonDev或UNKNOWN fail closed；Dev Synthetic醒目，Match loading/error/closed、Connection pause/close后旧阶段成功不残留；不制造消息/关系授权 |
| P-AC04 | 真实AppShell/Router同次挂载状态消费、导航、Readiness Guard拒绝路径与返回，窄屏/字体可用；实际哨兵0外部调用/写入 |
| P-AC05 | 最终限定Flutter测试/窄分析stdout与exit码一致，失败与修复原证保存，固定GitHub候选/少量manifest可独立核查 |
| P-AC06 | Astra独立验收/复盘；GitHub定点集成、本地隔离新基线、集成后限域回归独立登记；不自动下一版 |

若真实现有的Home投影不足以安全在Progress显示相应来源，Codex须明确唯一可行的降级切片或唯一真正缺口，不能擅造业务source或为版本号重复写静态卡片。

## 5. Codex本轮只读评审回报

请只进行**有界只读**代码/测试/权威事实核验，回答：①main与clean本地基线具体差异、原dirty树保护；②已接受可复用的状态摘要与现有Progress缺口真实证明；③最小产品切片、准确两到若干文件白名单、预期关键场景、真实Widget隔离可行性；④是否有非本版权限/Owner产品政策决定；⑤将P-AC01~06简化成可真实验证的冻结门。粗略工期可以给区间但不是验收依据。未知写UNKNOWN，不运行Flutter或PHP测试，不做源码写入/提交/分支移动。

反馈以 `V10.0.5 PLAN REVIEW — READY / READY_WITH_FINDINGS / BLOCKED — IMPLEMENTATION_NOT_AUTHORIZED` 开头，由Owner交Astra决定是否冻结`v10.0.5/plan.md`。本草案不授权开发，不派生v10.0.6。

**`V10.0.5 PROPOSED — PROGRESS_STAGE_SUMMARY_AND_SAFE_NEXT_NAVIGATION — AWAITING_CODEX_FEASIBILITY_REVIEW`**
