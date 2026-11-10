# EliteSync-v10｜v10.0.2 正式冻结计划｜Debug/Test Flutter 只读资格诊断预览

> **FROZEN_PLAN / AWAITING_OWNER_MANUAL_DISPATCH / IMPLEMENTATION_NOT_STARTED**  
> 2026-10-13（Asia/Shanghai）。Astra 依据 Owner 已启动的 v10.0.2 规划、Codex `V10.0.2 PLAN REVIEW — READY_WITH_FINDINGS` 的只读现场报告确定本版。  
> **唯一新增能力**：使用 v10.0.1 已接受的真实 PHP 合成资格评估→当次 JSON→已有 Dart 严格 parser，进一步实现一个**独立、默认关闭、仅 Debug/Test 构建可显示**的只读 Flutter 诊断 Widget 和可复核 widget 测试链。**不进入 Progress、普通用户导航或真实聊天。**  
> **发布/签发约定**：本冻结计划的身份以 GitHub 发布提交的 SHA 和本文件 Git Blob 为准，不在正文虚构自身提交；Owner 必须将固定链接与**明确执行授权**手动交给 Codex 后才允许开发。冻结后的目标、范围、合同和 AC 不随执行结果改写。旧 [版前草案](PLAN_PROPOSAL_V0_1.md) 留作历史来源而非执行依据。

## 1. 权威、基线和证据级别

- GitHub 仓库 `zcx369658780/EliteSync-v10`。**代码父基线精确固定为 `be070a771114052b2f6e7796636cd1a186502988`**，即 v10.0.2 版前草案/导航发布提交，也是已接受两版代码完成**远端 main 定点整合**之后的提交。冻结计划文档所在的更新提交与代码父基线不同，Codex 不得把后续文档 main 当源码父提交；建立隔离候选时核对父提交及所需对象精确 Git Blob。
- [远端整合回执](../v10.0.1/integration.md) 记录 14 项固定对象进入 GitHub main。v10.0.0、v10.0.1 的 acceptance 均为 `ACCEPTED/CLOSED WITH OBSERVATIONS`（synthetic/dev-test），但它们的历史候选整条提交链**没有整体 merge**。整合后 main 的 PHP/Flutter **POST_INTEGRATION_RUNTIME_NOT_RUN**，不得把旧候选的 PASS 冒充新基线 PASS。
- 2026-10-13 Codex 版前实测（**作者本机回报，非网页独立操作 D:/ 磁盘**）：`D:/EliteSync-v10` `main` HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`，index SHA256 `2be660029a2e2c2578f5193bc050dee35be3e71ce941460a42331babf577e716`，staged 0 / tracked 修改43 / untracked normal208。本地缓存 `origin/main` 仍为旧 `696834...`，不能当实时远端事实；Codex 已通过定点 Git 对象读取核对最新远端 `be070a...`。
- 远端14项整合对象，Codex 本地定向核查：6项 `app/EliteSync` 源/fixture 在原 dirty root 属 **untracked 同字节**；1项已跟踪 Product Connection 测试仍为增强前 blob `f3e0d983...`，远端接受后为 `5e59626a5ed640482cc786862f5e1e9c01511262`；另7项在原根不存在，但已存在远端 main。这些是**本地对照记录**，不是整合后 main 运行实测；本版不必将其再次纳入或拷贝。
- 已有 [QualificationDiagnostic Dart DTO/parser](../../../../apps/flutter_elitesync_module/lib/features/qualification_diagnostics/domain/qualification_diagnostic.dart)（当前 Git Blob `1d5a4cc16040d73432a0548f4cb57b85fc5bef58`）严格验证 schema、expected context/scenario 集合、重复键、四个 false 权限字段，返回不可变只读 diagnostics。已有 [v10.0.1 exporter](../../../../services/backend-laravel/tests/Unit/EliteSync/ConversationQualification/export_diagnostic_fixture.php) 与 [同次编排工具](tools/../.keep) 的实际路径需使用 `docs/versions/v10.0.1/tools/validate_diagnostics.py`；`tools/../.keep` 非实际文件，**不得**据此创造依赖。执行时以本条明确的既存路径为准。（此处正文不能将归档 URL 推断为真实本地镜像。）
- 确认的 Flutter 产品入口 `AppShell → ProgressShellPage → ProgressPage`、`Home | Progress | Messages | Me`、已有 synthetic Relationship/聊天 UI 均属于其他独立成果。本版 **不修改/加入任何这些页面的正式用户入口**；`LocalOnlyVisualFixturePage` 也是其他视觉用途，不在本版挂接。
- `Match != Connection != Conversation != Relationship`；`PROJECTION != PERMISSION`；BE-12 真实私密消息七条路由保持默认 opaque 404。v10.0.1 `CONTRACT_EVALUATED` 仅代表虚构合同检查，不代表来源信任、正式资格或在线消息权限。

## 2. 正式范围 A｜隔离候选与来源保护

1. Owner 手动派发后，先定点核对 `be070a...` 代码父基线的已接受14项 Git 对象和现存 PHP exporter/Dart parser。建立**独立隔离 worktree + 单父 `codex/v10-0-2-...` 分支**，精确从 `be070a...` 出发，不合并其它候选或将原本地 `main` 整树更新。
2. 不触碰原 `D:/EliteSync-v10` main HEAD、默认 index、dirty/staged/untracked、其他 worktree/EVIDENCE；严禁 `git pull/rebase/reset/clean/stash`、全仓 add、旧拒绝候选 cherry-pick。源自旧 root 的 App/Flutter 独立 UI 资产只在**明确必要且属于本版合同**时白名单定点复用；默认所有现有远端已接受对象直接继承，不拷入同名本地 untracked。
3. 在开始编辑前保存必要 protected source/test 的准确 path、候选 Git blob、原根定向保护身份。结束时保留原始前后记录，分别陈述 `GITHUB_MAIN_CODE_BASE`、`ISOLATED_CANDIDATE`、`LOCAL_ROOT_UNSYNCED`；不把本版候选代码存在等同于已并入 GitHub main。

## 3. 正式范围 B｜独立 Debug/Test 只读诊断预览

**仅允许新增两个 Flutter 源/测试文件：**
- `apps/flutter_elitesync_module/lib/features/qualification_diagnostics/presentation/widgets/qualification_diagnostic_preview.dart`
- `apps/flutter_elitesync_module/test/features/qualification_diagnostics/qualification_diagnostic_preview_test.dart`

复用现有 Dart `QualificationDiagnostic.parse()`，不修改其 schema/语义。可复用现有 `AppCard`、`AppTag` 及 Flutter 公共基础 Widget；若此复用引入未经授权的 App 路由/权限耦合则改为安全的 Flutter 原生基础布局，不修改设计系统或被保护资产。

### 3.1 展示门和纯只读输入

- Widget **默认关闭**。只有 **`kDebugMode == true` 且 test harness 显式开启**时才能呈现诊断。Profile/Release 始终无诊断 UI，即使调用者传入 enable=true；默认关闭、显式关闭或非 Debug 构建不得解析/持有用于渲染的有效旧诊断或触发任何业务副作用。
- 不新增正式路由、导航标签或入口。不纳入普通 `Progress`、`Messages` 或 `Me`；无进入链接、动作/发送按钮、聊天跳转、权限按钮、数据写入、网络或本地持久化。仅由独立 widget-test harness 明确注入 source JSON、expected context、expected scenario IDs。
- Widget 的状态源必须是**每次提供的当前输入**。有效 JSON 用原 Dart strict parser 转成只读 projection；缺失、非法、跨 context/未知场景或滥用授权位时必须 fail closed；在有效→无效或 revoke/stale 等输入变更时，下一次 rebuild 必须撤销/替换旧“合同检查完成”展示，不缓存旧绿色诊断或通过理由推测权限。
- 要明确展示 `Synthetic dev-test / 仅测试诊断`、`source trust UNKNOWN`、`formal qualification NOT ESTABLISHED` 和始终可见的“不授予消息读取/发送权限”；`CONTRACT_EVALUATED` 只能写“合同检查完成（不代表正式资格）”，`REJECTED` 为“合同拒绝”，`UNAVAILABLE` 为“输入/来源不可用”。Reason codes 可以在受限诊断中按原样只读展示，不根据 reason 推断真实生命周期或生成行动建议；不得使用“聊天已激活/可发送”等误导文案。
- 对极窄屏幕、长 reason、Flutter `MediaQuery.textScaler` 放大应合理换行/滚动，避免 RenderFlex overflow 和隐藏免责声明。显示内容只使用虚构 scenario/context；严禁实时账号或私密消息读发。

### 3.2 严格禁止的依赖

新 Widget、测试与编排不得连接/修改/导入：
- `chat_providers.dart`、`ProductConversationAccessAdapter.resolve()`、`ChatRemoteDataSource`、真实消息 callback/permission tokens、`ApiClient`、生产 HTTP、真实账号或安全/运营接口；
- `ProgressPage`、`ProgressShellPage`、`AppShell`、全局 app router、`LocalOnlyVisualFixturePage`、现有 synthetic Relationship 或聊天主循环；
- 现有 PHP `ConversationUsePointQualifier` / `LocalTestConversationLifecycle` 的业务状态或授权语义、BE-12 middleware/route、Dart strict parser 的既定 schema，及正式环境/依赖配置。

如当前依赖实际要求修改上述文件才能实现 B，停止超范围操作并报告 `BLOCKED_SCOPE_DECISION`，不通过改变冻结计划或把预览变为真实功能绕过。

## 4. 正式范围 C｜同次动态数据、负向 Widget 测试与交付

**允许额外新增**一个 `docs/versions/v10.0.2/tools/validate_preview.py` 验证编排脚本、版本 `docs/versions/v10.0.2/` 下必要的执行报告、manifest、脱敏原始日志/生成 JSON/测试收据。其它产品代码文件不在本版白名单。测试所需非生产隔离环境配置必须有明确目的、准确对象并限在本版 evidence/tools 目录，不能覆盖项目全局或生产配置。

- 使用本版既定 `be070a...` 基线的**实际 PHP exporter** 调用既有 lifecycle/qualifier，**在同一次验证编排中**输出新的 synthetic JSON；记录原始文件字节数、SHA-256、PHP 退出码、stdout/stderr、真实来源/scene oracle。不能读取之前签入的静态 fixture 当本次生成。
- 使用现有 Dart parser 测试加新 Widget 测试，测试层读取**刚生成的同一 JSON 文件**；记录双方输入原始字节的 SHA-256 相同。Widget 内容应由实际 parser/projection 渲染；不能靠独立手造同值 DTO 或写死画面冒充跨层消费。
- Widget tests 必须覆盖：`CONTRACT_EVALUATED` 但始终“无消息权限”、`REJECTED`、`UNAVAILABLE`、pending consent、pause/close、revoke、stale/revision mismatch、cross context；缺失/篡改/额外键/错误类型/伪 permission=true 的 fail-closed；尤其有效输入→无效输入后旧状态立即消失、无诊断残留；默认关闭、显式关闭和 debug-mode 强制门；窄屏/长reason/文字放大无 layout overflow、警示不被遮蔽。
- 如果 Widget 测试环境无法模拟 Profile/Release 编译，应以源码静态门 `kDebugMode` 与 debug 测试可执行负向证明的组合明确证据层级，**不能把非 Debug 构建未执行说成 runtime PASS**。若要求真正非 Debug 构建测试却缺工具资格，应记录 `NOT_RUN`，但不能从中发明正式 Android 资格。
- BE-12 原 middleware/route 保持已接受 Blob；适用的静态身份/原有 pure middleware 测试可定点复用，不将其冒充完整 Laravel Feature route 运行。PHP、Flutter 直接相关有限验证按实际依赖执行，不机械复制既有294/301套件。保留首次失败、实际修复、最终重测与 stdout/stderr，不为绿灯弱化原测试。禁下载升级 SDK/依赖、启动真实服务、测试设备、账号及生产数据。
- 交付**固定、可读、独立候选 GitHub commit/tree**，包含新增 Widget 与测试、验证工具、必要脱敏 raw、manifest/source+fixture/旧接受文件身份证据、代码保护记录。Astra 必须能在网页从固定 ref 直接读取核心源码/测试/真实输入证据；单凭作者口头 PASS 或本地路径不够。候选**不自动合并到 main**。

## 5. 冻结验收标准 AC-01 ～ AC-07

| AC | 不可事后降低的 PASS 条件 |
|---|---|
| **AC-01 安全基线** | 隔离候选**唯一父**为 `be070a771114052b2f6e7796636cd1a186502988`；14项已整合对象继承/按需保持准确身份；原 dirty main HEAD/index/相关保护集合前后不受修改；候选及纳入 source blob可追溯。 |
| **AC-02 只读 Widget** | 已实际实现并通过 Flutter widget tests 观察 synthetic/UNKNOWN/formal-not-established/零聊天权限提示与三种合法 outcome；默认关闭、不接普通导航或聊天路径、无消息读写或授权 callback。 |
| **AC-03 失效即时替换** | 同一 Widget 从合法合同诊断切到非法/缺失/context错/撤销/stale/source异常，重新渲染立即失败关闭、旧“合同检查完成”内容消失；恶意权限位/额外字段绝不转为可用状态。 |
| **AC-04 同次真实数据链** | 真实既有 PHP 领域函数→当次新生成 JSON→既有严格 Dart parser→Widget test harness 实际渲染完整证据链；PHP 输出与 Dart/Widget 输入原始 SHA-256 一致；静态 mock 或复述旧版本通过不能替代。 |
| **AC-05 实际有限回归/视觉约束** | 所需 Flutter parser+Widget tests 和直接必要的 PHP/exporter 验证实际 exit0，保存 raw streams、输入身份、断言/场景索引、失败修复链；至少一种窄屏/长reason/放大文字测试无 overflow，固定权限免责声明可读。未跑的构建/设备/正式运行明确 NOT_RUN，绝不伪称 PASS。 |
| **AC-06 安全保护与独立证据** | 候选没有修改 BE-12 路由/消息合同、Progress/Chat/授权代码或正式工具链；V57等仍暂停；固定 GitHub candidate 源码/测试/有限 manifest/原始日志能由 Astra 独立读取，保护程度如实注明网页与本机验证边界。 |
| **AC-07 集中验收/双状态** | Codex 交付准确 candidate/tree、测试/失败、保留缺口；Astra 按此冻结计划独立决定 PASS/PARTIAL/FAIL/返修并记录版本复盘；`Acceptance Status` 与 `Integration Status` 分别登记，候选不自动并主线、不启动 v10.0.3。 |

本计划中涉及 Widget 显示的全部内容都**仅开发/测试可见**，不构成对正常用户 UI 的 Owner 产品改变决策；若将来需要公开展示，必须另立有 Owner 批准范围的后续版。若依赖被排除的源或测试不可得，本版保留原 AC 并据证据分类阻塞或部分完成，不在实施时追改计划。

## 6. 权限、执行与复盘

- 此次冻结计划**本身**不授权修改代码或运行程序。Owner 手动发送本计划的固定 GitHub 链接和明确“执行 v10.0.2 冻结版”指令后，Codex 才可在隔离候选上实现本文 A+B+C；普通故障可自主诊断修复并重测，不需 Astra 中途微审。
- 除本版白名单外的不可逆/生产/数据/合同变更必须暂停该操作并报告；不全仓清理、无额外强制多模型 review、无 Work/Dot 实时监督。工作量初估 **1～2 个工程工作日**（Codex 版前估计，非硬性预算或交付时限）。
- 本版不修改或启动旧 V57/H1/H2/D0，保留 `NOT_READY`、`RuntimeReady=false`、`M6 CLOSED`、`S2 unsigned`、`OwnerEnvironment PENDING`；真实消息404持续。
- 固定计划不重写。Codex 完成后仅一次性集中交付受限候选与原始证据；Astra 对照本版固定 AC 独立验收、复盘与登记。没有自动 v10.0.3、自动 merge/部署/正式平台放行。

**最终标记：`V10.0.2 FROZEN_PLAN — DEBUG_TEST_ONLY_READONLY_DIAGNOSTIC_WIDGET — AWAITING_OWNER_MANUAL_DISPATCH`**
