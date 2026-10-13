# EliteSync-v10｜v10.0.2 版前计划草案｜主线基线衔接与可验证的非生产 Flutter 只读消费

> **PROPOSED / CODEX_FEASIBILITY_REVIEW_ONLY / NOT_FROZEN / IMPLEMENTATION_NOT_AUTHORIZED**  
> 日期：2026-10-13（Asia/Shanghai）。Owner 已明确授权整合两个已接受候选后启动下一版本**规划**。本页只授权 Owner 手动交给 Codex 进行**有界只读核查与执行计划反馈**，不授权直接实现、运行测试、合并主线或正式发布。  
> 候选版本 `v10.0.2` 是内部工程增量，不是完整 MVP、正式 Android 发布、真实账号/聊天功能或生产资格。

## 1. 基线与证据身份

- 正式当前流程：[CURRENT_WORKFLOW](../../workflow/CURRENT_WORKFLOW.md)，[动态目录](../../../DOC_INDEX_CURRENT.md)，[当前状态](../../../CURRENT_STATE.md)，[版本登记](../README.md)。
- Owner 授权的上两版**远端 main 白名单定点集成**已完成：[集成回执](../v10.0.1/integration.md)。集成代码基础提交为 `c4a49b2027b99ded84b73b739636b595adfaf0fe`。14 个完整路径的 Git Blob 与 v10.0.1 已接受候选相同：11 项源码/测试/fixture，另3项有限验证工具与source-intake。v10.0.0 接受测试 Blob `5e59626a5ed640482cc786862f5e1e9c01511262` 已在此远端 main。
- 历史验收：v10.0.0 [acceptance](../v10.0.0/acceptance.md) 与 v10.0.1 [acceptance](../v10.0.1/acceptance.md) 均 `ACCEPTED/CLOSED WITH OBSERVATIONS`（仅相应 synthetic/dev-test）；v10.0.1 被实际证明的是 **PHP领域函数→当次新生成JSON→Dart只读DTO/parser**，不是 Flutter APP 可见页面，更不是 online messages。
- **Integration 精度**：两版仅**选定代码/测试/复现材料**进入 GitHub main，历史候选 commit/tree 原样保留；整合后 main **POST_INTEGRATION_RUNTIME_NOT_RUN**。用户的实际 `D:/EliteSync-v10` 本地 `main` 曾固定在 `4bebc8f...`，并有43 tracked 修改、大量 untracked；GitHub 不能直接读取和修改这些本机成果。不得把“GitHub 已集成”推成“本地主树已安全同步”。
- 权威边界：`Match != Connection != Conversation != Relationship`，`PROJECTION != PERMISSION`。BE-12 七条实际私密消息路由默认404保持；`ConversationUsePointQualifier` 仍 contract-only/source trust UNKNOWN/formal qualification NOT_ESTABLISHED，合成数据不成真实用户资格。V57/H1/H2/D0、`NOT_READY`、`RuntimeReady=false`、`M6 CLOSED` 等保护状态不变。

## 2. 建议核心目标（待 Codex 版前校验）

将已经固定、可复现的 synthetic 资格诊断链**下沉为一个可测试的 Flutter 只读消费/可视化切片**，让工程有比 v10.0.1 DTO 单测更实际的客户端增量。优先使用已接受的 Dart parser/projection 和既有 UI 元件，但**不能进入真实聊天授权/写者路径**。

### 候选工作包 A｜新远端基线和本地源的安全对齐

1. 在 `D:/EliteSync-v10` 只读核实最新 `origin/main`、本地源码 HEAD/dirty/index/untracked/重要历史工作树，与 GitHub 定点集成回执的**准确14项文件身份**是否冲突。尤其检查新增 `app/EliteSync` 具名源码是否已在本地 untracked、是否与远端刚整合的 Git Blob 相同；不可默认 pull 或直接切换工作树。
2. 提出**安全隔离候选**：推荐以 `c4a49b2027b99ded84b73b739636b595adfaf0fe`（或从当前最新 main 只追加规划文档的后续提交）为代码父基线，在单独工作树/分支上实施；本地的高价值 dirty UI 资产仅在真实消费需要时按白名单、准确哈希定点纳入，绝不先整仓清理/改索引再规划。
3. 如果远端集成代码与本地 LOCAL_ONLY 源仅是“同名同内容”，不重复 materialize/提交。若同名不同内容，分清 `ACCEPTED`、`IMPLEMENTED_NOT_ACCEPTED`、`LOCAL_ONLY_UNVERIFIED`、`PAUSED_OR_PROTECTED`，由 Codex 给出准确选取策略；避免旧 rejected 祖先混入。
4. 原始脏工作树与默认 index 不改变；**在本版计划确定前不得主动把原本地 main fast-forward/pull/rebase 至 GitHub main**。用户明确授权的远端集成不等于全树本地覆盖授权。

### 候选工作包 B｜Flutter 受控 synthetic 只读诊断显示/消费（需核实产品/代码落点）

1. 先检查当前 v10 APP 的 `Home | Progress | Messages | Me` 已接受 IA 与现有 Flutter `Progress`、Chat gating、common UI states；确定一个**不侵入正常用户流程**且可以独立测量的诊断呈现落点。首选**仅开发/测试模式可进入的独立受限只读预览 widget/screen**；是否放进 `Progress` 普通页面须在冻结前明确获得 Owner 的产品选择，不由工具默认决定。
2. 消费现有 `apps/flutter_elitesync_module/lib/features/qualification_diagnostics/domain/qualification_diagnostic.dart` 的实际 `QualificationDiagnostic.parse(...)` 输出，不重新写 JSON/parser/资格语义。诊断允许展示的含义仅有 `CONTRACT_EVALUATED`（合同检查完成、**不证明正式资格**）、`REJECTED`、`UNAVAILABLE`，并以清楚稳定的文案区分源可信UNKNOWN、正式 qualification 未成立和 synthetic 测试标签。
3. **不能**将 `contractEvaluated` 映射为有效 Connection、聊天可用、`CV_ACTIVE`、live read/send、权限 token 或真实关系建议。**不得**导入/绑定 `chat_providers`、`ProductConversationAccessAdapter.resolve()`、`ChatRemoteDataSource`、真实 messages路由、生产HTTP、永久缓存或 Message callbacks。
4. 无权限/stale/revoke/cross-context/JSON 不合法时展示 fail-closed 的“无可靠诊断/不可用于实际许可”，不能在失效后展示先前的“合同通过”作为当前状态，更不能从 outcome/reason 推断 source authority。
5. 如现有 Flutter UI 消费链的实际实现需要 SDK/设备/授权或特殊 Product 决定，请说明原因，**在冻结前**建议只做独立 widget test harness 或提出**一个**同等价值的可执行替代切片，不能为了造 UI 扩宽正式聊天许可。

### 候选工作包 C｜真实非生产测试与身份交付

- 建议验证 **PHP synthetic 真实 evaluator→新 JSON→Dart parser→只读 widget/render/state** 在同一测试编排内的消费者行为（且不静态重建假 JSON），允许 Flutter widget tests/synthetic tests 与必要 PHP regression；不要求正式 Android assemble/install/设备，也不机械拷贝上两版的全部测试套件。某些环境条件不能满足时必须如实写 `NOT_RUN/BLOCKED`。
- 确保 test oracle 不单靠自身生成输出核对自身：应有合理独立的场景预期、失效/拒绝/无权限 UI 断言，明确日志/fixture SHA 和工具真实 exit，保留错误与修复证据。
- 对最小改动保留原文件白名单、候选 commit/tree、源/测试/fixture manifest；在 GitHub 独立候选分支安全发布代码与必要脱敏 raw，以便 Astra 固定读取终验。测试通过不等于正式平台/生产授权，也不自动 merge GitHub main。

## 3. 计划草案的验收建议（不是冻结门）

| 候选 AC | 所需真实证据 |
|---|---|
| P-AC01 | 最新远端主线中14项对象与本地相关文件已识别，隔离候选基线及定点纳入清单明确，原本地 dirty HEAD/index/未提交资产不受破坏 |
| P-AC02 | 真实 Dart 诊断 DTO 进入纯只读 Flutter widget/展示态，synthetic/UNKNOWN/zero permission 有可观察的界面语义，不暴露 chat permission 或真实读写 callbacks |
| P-AC03 | 与原 PHP 领域函数产生的同次合成诊断字节形成可复核消费链；至少覆盖合同满足但不授权、拒绝、UNAVAILABLE、stale/revoke/cross-context/篡改失效 |
| P-AC04 | 适用的 Widget/Dart/PHP targeted tests 真实运行，保留双流、退出码、失败-修复链与固定最终身份；不以旧历史 PASS 代替当前候选 |
| P-AC05 | GitHub 固定提交可供独立读取新增代码、重要原证及 limited manifest，并将上版验收、远端 integration、本地尚未对齐分列 |
| P-AC06 | 独立 Astra 终验与版本复盘完成；只标记实际验证的 synthetic/UI 限定范围，BE-12 404、旧暂停与正式资格不得提升 |

以上是建议而非事先签发。若 B 涉及新的 Owner 用户可见产品行为或真实消息/正式数据边界，须**在冻结前**取得明确产品决策；本文件不替代该决定。

## 4. 当前保护边界和明确排除

- 本草案发布**只授权只读源码及版本事实核查**，不得自行搭建业务执行环境、运行应用测试/Android/设备、写/发布源码候选、修改原 dirty root、合并 accepted branches 或启动自动监控。
- 不解除 BE-12 七条 opaque 404；不新增真实 writer、CN/MC trusted live authority、线上 Conversation/Message/API/SSH、真实用户数据/账号、隐私缓存、部署、数据库、密钥、SDK升级、正式平台证明。
- 不启动 V57/H1/H2/D0 与旧 Work/Dot/任务队列；不得把历史 SOURCEONLY/SYNTHETIC PASS 提升成正式运行。
- 不重写接受的产品设计、解释权威、安全域、对应冻结计划、原始接受与拒绝或审查/版本复盘记录。
- 调试 UI 不进入普通产品正式入口，不通过“用户可见诊断”变相推出 AI/玄学或 Safety 判决；必要 UX 取舍必须由 Owner 审议，普通测试-only rendering 可由 Codex 反馈可行性。

## 5. 正式版本流程

1. Astra 发布草案，Owner 手动转交同一个 EliteSync-v10 本地 Codex，会话若变化需以可信回执定位。
2. Codex **只读**回答真实 Flutter 资产能否安全消费现有诊断 DTO、推荐一个最小 UI 落点（优先受控 developer-only widget，不擅自加入 Progress 导航），准确基线、文件、测试及保护策略；如需 Owner 产品决定，指出一个清晰问题。
3. Astra 对照 Codex 真实现场压缩本版为一个可执行增量，并在 Owner 解决必要方向取舍后，**另行冻结正式 `v10.0.2/plan.md`**，记录唯一范围与 AC 身份。
4. Owner 将冻结计划固定链接和明确执行授权手动派发后，Codex 范围内自主编码、诊断、回归，集中发布候选；Astra 独立验收/复盘。没有中途逐步骤审批，也不自动启动 v10.0.3。

## 6. Codex 只读核查回报要求

请在不修改任何文件或运行应用测试的前提下集中回报：

1. `cwd/Git HEAD/origin main/index/dirty` 与本次远端代码集成 `c4a49b2027b99ded84b73b739636b595adfaf0fe` 的逐对象差异。**哪些远端文件已在本地未提交成果中、哪些会有同名冲突**？给出不伤原 root 的安全候选策略。
2. 当前 Flutter Progress、已接受 UX、qualification_diagnostic Dart DTO、现有 synthetic loop 的准确模块与主要消费者；是否存在安全且可独立测试的 developer-only read-only widget 落点，避免重造已有 UI。
3. 推荐唯一最小 B 切片及文件/数据流、禁止 import 的现有授权路径、负向 widget cases、同次 PHP→Dart→widget 验证办法；需要 Owner 决策的问题单列。
4. 如果非生产预览仍不适合本版本，给一个**确有代码进展**的替代窄范围，不将本版退化为“再做全仓文档/治理审计”。
5. 建议将 P-AC01～06 精简为明确冻结标准，报告可能的技术/权限阻碍与粗略工作量，未知写 UNKNOWN。
6. 明确 `NO DEVELOPMENT / NO MAIN MERGE / NO LIVE MESSAGING ROUTE ACTIVATION`，结果首行 `V10.0.2 PLAN REVIEW — READY / READY_WITH_FINDINGS / BLOCKED`。

**状态：`V10.0.2 PLAN PROPOSAL — AWAITING CODEX FEASIBILITY REVIEW — NOT FROZEN / IMPLEMENTATION NOT AUTHORIZED`**
