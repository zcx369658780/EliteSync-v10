# EliteSync V2｜阶段B工程执行：现有Codex项目会话启动Prompt

日期：2026-11-20（Asia/Singapore）  
状态：`OWNER_PHASE_A_SCOPED_FINAL_ACCEPTED / PHASE_B_ENGINEERING_AUTHORIZED / CODEX_HANDOFF_READY / NOT_YET_EXECUTED_BY_WEB`  
治理仓库：`zcx369658780/EliteSync-v10`；分支：`governance/home-matching-product-freeze-20261117`  
含具名Owner授权和完整任务书的**固定治理提交**：`ce79430a013ab46b7dcb00aab73af5e4c8ae7b57`。该提交在本Prompt创建前完成；后续可使用最终远端治理HEAD检索此文件。

**Owner应将下方正文发至原有EliteSync本地Codex项目会话；本文件不是网页GPT已自动运行本地工程的证据。**

---

# EliteSync V2｜Owner阶段A终验接受 + 阶段B正式启动

Owner明确回复：“我同意正式接受阶段A在限定自动化范围内的工程交付，请继续阶段B”。所以**无需再请Owner批准B启动**：A的限定范围工程成果已经Owner最终接受，B1–B4工程开发与隔离自动化测试已经授权；C/D尚未启动。

## 权威首读

请通过GitHub只读连接器按固定治理commit `ce79430a013ab46b7dcb00aab73af5e4c8ae7b57` 读取以下文件，避免用旧本地AGENTS或历史OWNER_REVIEW_PENDING快照覆盖新授权：

1. `docs/decisions/OWNER_V2_PHASE_A_FINAL_SCOPED_ACCEPTANCE_AND_PHASE_B_ENGINEERING_AUTHORIZATION_20261120.md` — 本次正式Owner决策/边界。
2. `docs/versions/v2/V2_PHASE_B_HOME_CONTENT_AUDIENCE_CONSOLIDATED_EXECUTION_BRIEF_20261120.md` — **本阶段完整合并工程任务合同和验收标准**。
3. `docs/product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md` — A→B→C→D已接受总体路线图。
4. `docs/workflow/V2_PHASE_A_ADVISOR_SCOPED_ACCEPTANCE_20261120.md` — A遗留范围/证据分级与环境限制。
5. `docs/product/ELITESYNC_V2_OWNER_ACCEPTED_SOURCE_INDEX_AND_AUDIT_SNAPSHOT_20261119.md` — 按需跟读O01/O02/O11、SELF、CMT-T1、HIS-D1、NEW-PC-01/02、EDGE-D1/D2、S03/S04/S15/S16等已接受决定。不得把顾问详细UX稿当新增Owner批准。

固定源格式：`https://github.com/zcx369658780/EliteSync-v10/blob/ce79430a013ab46b7dcb00aab73af5e4c8ae7b57/<path>`。**不要为了获取治理文档把本地工程checkout/fetch/pull到治理分支**。

## 0. 先确认实际工程基线，保护已验收阶段A

阶段A已确认固定工程产品源码`4e6a5be6dcb7095438fb0a815c7831b14ffb561b`，工程交付`07b51a6de9695f5358b6bea2a59acd5be24ab6c2`，分支`codex/v2-phase-a-security-baseline-20261119`。阶段A交付时Codex报告工程根`D:\EliteSync\development\v2-phase-a-20261119`。以上**均为固定历史证据，必须重新核对本地实际工作树身份**。

在现有EliteSync Codex会话只读确认可追溯A1–A4的安全基线、git根/remote/branch/HEAD/index/dirty以及旧工作树未提交数据。优先**从A的合法已确认交付**建立独立`codex/v2-phase-b-...`分支/安全工作树；绝不可从旧S1源码分支重新开工而丢掉A，也不可修改`D:\EliteSync-v10`老main工作树、S1审阅根或覆盖未跟踪数据。身份有冲突或安全隔离不明就只报告阻断，**不为了赶进度reset/stash/clean/force操作**。

## 1. 一次性B1–B4合并执行，不拆Owner小门禁

**B1｜首页双内容域与安全精选**：访客只读具名有权的`PUBLIC_EDITORIAL`官方正文；当前登录用户在精选/好友内按`PUBLIC_AUTHENTICATED / FRIENDS`及账号/Block/权限看原作品。编辑推荐只定位合法原作品，不能当访客正式转载；无真实有效官方来源就用安全空态。精选可解释时间/具名标签优先，不以停留时长、隐私数据或AI总分排名。

**B2｜作品/评论默认与扩大受众确认**：普通新作品**FRIENDS + FRIENDS_ONLY**，当前好友可评论，陌生人默认不能评论；SELF仅作者读且默认OFF；SELF→FRIENDS区分系统隐式OFF、作者显式OFF和旧来源UNKNOWN，推荐但不自动扩权；发布前摘要与扩大受众明确确认。FRIENDS→PUBLIC_AUTHENTICATED只扩大作品正文合法读权，**不能自动提升旧评论、回复、附件/媒体、引用、缩略图或评论策略**。所有合法控制在服务端强制，不能仅靠前端按钮。

**B3｜历史评论与不同权利主体**：保留阶段A评论原读者集合与当前作品读权交集。实现评论作者撤回自己评论展示和作品作者在自己作品隐藏第三方评论展示的**独立语义与可审计权限**，不可都冒称已物理删除。父评论撤回/隐藏后第三方独立回复须验证回复自身原受众、现行权限与不会泄露父内容/身份/原因，安全时可中性结构保留，否则折叠/隐藏分支但不得因此删除回复原件。评论者中性状态仅在本人仍有权且不泄密时提供；不存在真实复核机制不可虚构申诉、工单、时限、结果或Push。

**B4｜从API到媒体/通知/搜索/深链一致**：列表、详情、搜索摘要、推荐定位、通知历史、媒体签名URL、图片缩略图、Block/账号切换/迟到回包与缓存都不得绕开作品读权和历史评论原受众。已失权隐藏、不可核验安全占位。阶段A历史NULL原受众不回填推断、更不能用作品公开给原第三方评论自动扩权。

详细验收项以完整B任务书为准，可由Codex自治按依赖拆分并自验；已接受原则内的小状态/文案无需逐项Owner批准。不可逆数据、真实法律/第三方新权利、未获准正式转载或明确跨域产品取舍仍由Owner决策。

## 2. 实施权限、隔离测试和阶段A遗留

允许在**确认安全隔离**的阶段B工程分支修改Flutter、Laravel API/Web权限/内容、必要schema和迁移定义，增加自动化单元、Widget、隔离HTTP/DB测试并完成局部回归；可以按Local-first既有规则备份非main脱敏提交。

**绝对禁止**：访问/迁移生产或共享DB、真实用户数据与凭据；真实KYC/Push/RTC供应商连接、采购或对外发布；真机/模拟器、正式A6 UI会议、main合并/Release；不做C的对象级删除请求实际受理/完成、跨用途授权/派生计算全套，也不自动跳入D的全旅程/最终视觉验收。

保留A的环境缺口：`PHP ~8.4.0`声明而A实测PHP8.5.3，PHP8.4兼容仍未证明；MariaDB真实并发、迁移与JSON受众查询只在SQLite内存有旧测试。**若当前具备明确无真实用户数据的隔离PHP8.4/MariaDB，可在B的合并测试中一并定向补证；否则记录NOT_RUN，不能借生产库补齐。**

A1正式身份无真实服务时fail-closed、A2旧候选快照绑定、A3 UNKNOWN先查、A4原评论受众保护必须同步回归。所有测试都记录实际环境/命令/版本/退出码、正反例、失败/未知、证据哈希，不能用测试设计/模拟器或test_only值宣称G01–G10整体PASS。

## 3. 唯一交付/停止

在阶段B完成后，请在**同一现有Codex会话**只交付**一份中文综合工程报告**，包含：

- 实际基线和安全独立开发工作树、提交及代码/迁移diff，确认A1–A4保护没有回退；
- B1–B4每组具名Owner合同、实现源码/权限/媒体/历史兼容/UNKNOWN证据；
- 已运行PHP/Flutter及实际安全隔离DB的命令、数量、正反结果、FAIL/UNKNOWN/NOT_RUN、原始日志SHA与本地私有存放位置；
- 访客/好友/新好友/旧受众/Block/失权/媒体链接/评论作者撤回/作品作者隐藏/父回复等一张覆盖矩阵；
- 原有PHP8.4、MariaDB、KYC/Push、法律/留存、设备/PNG缺口与风险；
- `PHASE_B_PASS/PARTIAL/FAIL/UNKNOWN`自验建议。

交付后**停止自动转入阶段C或D**。Owner集中审阅后决定下一步；本次不做main合并、生产发布、正式A6。若存在需要Owner实质新权利决定或不可逆真实数据操作的事项，只暂停超范围点，不废弃已授权的独立安全软件工作。

Authority：`OWNER_PHASE_A_FINAL_SCOPED_ACCEPTED / PHASE_B_ENGINEERING_AUTHORIZED / PHASE_C_D_NOT_STARTED / A6_MEETING_DEFERRED / RELEASE_NOT_AUTHORIZED`。

---

此Prompt是网页GPT在治理分支创建、供Owner转交既有本地Codex会话的启动文字。创建它并不代表网页GPT已亲自启动Windows开发或运行阶段B动态测试。
