# EliteSync v10｜Delivery Refresh 独立审查、原样集成与 R18-R1 首次基线重发｜v0.1

日期：2026-09-21。状态：`OWNER-AUTHORIZED DOCUMENT REVIEW + CONDITIONAL EXACT INTEGRATION + EXISTING R18-R1 FIRST-START REDISPATCH`。
唯一仓库：`zcx369658780/EliteSync-v10`。

## 1. 角色与边界

Owner 要求先评估外部交付优化建议、更新 GitHub 文档，并明确 R18-R1 尚未执行。本任务把文档一次独立审查与原有 correction 的安全启动放在同一执行入口，不增加新的产品设计阶段。

ChatGPT 是四文档候选作者，不能 self-accept。未参与四文档编写的 Codex 可独立 ACCEPT/REJECT；ACCEPT 后原样集成，并在同一会话按 §6 执行原有 R18-R1。Codex 此时是代码作者，不能接受自己的代码候选。文档通过不等于 R18-R1 通过。

本次新工作流仅用于未来新任务。R18-R1 保持原技术内容、六路径、最多两次真实 PHPUnit 和首次 PASS 停止；不追认 R18-F2。平台运行前移只是排程，不授权现在运行 Flutter/Android 或读取受限工具链。

## 2. 固定对象与 fresh gate

B = `608c6b04dc17022db7fcf72c34b494a0944ece03`；base tree = `002158ad8c50f18caad1ffe94cc78500bfc9aa82`。
C = 本任务所在的不可变候选 commit，由启动 prompt 给完整 SHA、tree、本任务 blob。
候选分支：`review/delivery-refresh-final-validation-runtime-first-20260921-v0-1`。

先 fresh-fetch main，要求精确等于 B；先读 B 的 `AGENTS.md`（blob `c9a8e192f7647a1613a195655fe9c22c56502ddb`），再读取 C 的本任务。先验证 C sole parent=B、branch tip=C、ahead=1/behind=0、exactly five changed paths，再读候选正文。

不把候选工作流当本轮权限。main 非 B、候选／source blob 不符、R18-R1 已另行开始或存在未知主线移动时停止相关执行，不覆盖用户工作、不假称在途 gate 已通过。

## 3. 五路径候选与文档审查来源

四个修改均位于 `docs/architecture/`；第五路径是本任务，本任务 blob 由启动 prompt 固定。

| 文件 | B 上的 blob | C 上的 blob |
|---|---|---|
| `ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` | `d75de90b3c0dafe6c5241f135936d0ae653c7e30` | `da8e89a3101246e05b884ea53f4af3456737d350` |
| `ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md` | `6f49159f1cce7a28362284191c05adbc08e768aa` | `15dc5c819d22f90a1e71bc1b788dba17c2426e40` |
| `ELITESYNC_V10_CURRENT_EVIDENCE_AND_CONTRACT_INDEX_V0_1.md` | `5b26a4e396dd8f64c18e25b16ef577df124a6725` | `7ad09b6e9fbec41eaf90394a78670238f51b0cdf` |
| `ELITESYNC_V10_DELIVERY_WORKFLOW_AND_TASK_CONTRACT_V0_1.md` | `76d98e37a3b951f233bd66a5e77ca7012a84d955` | `c68be66bd3518ab6f3a93011b046191ec4dd2c90` |

本任务精确路径：`docs/architecture/ELITESYNC_V10_DELIVERY_REFRESH_REVIEW_AND_R18_R1_DISPATCH_TASK_20260921_V0_1.md`，B 上应 absent。AGENTS 不变。不得改任何历史 task/result/acceptance/rejection/ADR/handoff。

文档审查只读上述 B/C 文件、AGENTS、本任务及下列 B 的源（全路径前缀同为 `docs/architecture/`）：

| 来源 | 精确文件 | Blob |
|---|---|---|
| 前计划接受 | `ELITESYNC_V10_PLANNING_OPTIMIZATION_INDEPENDENT_REVIEW_V0_1.md` | `4d7164e157cd9c0e1274af51661bd0857de05f91` |
| evaluator 修复接受 | `ELITESYNC_V10_IP_13I_R17_R2_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_EVALUATOR_REPAIR_ACCEPTANCE_V0_1.md` | `acfedada11c3c6e76b83f9674142168245db9c0f` |
| mapping 接受 | `ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_ACCEPTANCE_V0_1.md` | `2b1f23520912517f0e3ae6735208253fbfa37b4f` |
| R18 拒绝 | `ELITESYNC_V10_IP_13I_R18_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md` | `26bcbaf64953159c0ea53c5e9be78e817e2192c9` |
| 原 correction task | `ELITESYNC_V10_NEXT_IP_13I_R18_R1_PRODUCT_CONNECTION_APPLICATION_BINDING_ORDER_CORRECTION_TASK_V0_1.md` | `b28397028f8795149886b7c8ecb9ddb51a691b86` |
| 客户端证据层 | `ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md` | `4c00def5a94a117c8d9812996baf193de4a4aeb1`，仅 §§1–3、7–10 |

外部报告全文不要求再读或入库；当前候选记录其摘要和 hash。它不是执行源。仅为文档审查不运行项目命令；可用纯文本比较、Git object/hash 和本地算术核验估算（不访问其他数据）。

## 4. 独立审查标准

一次实质 ACCEPT/REJECT：核对当前状态非过期 R17 暂停、前计划确已接受、R18 没被追认、R18-R1 仅 Owner 报告未开始、15-domain 与 MVP/Phase2/Later 未变。

检查未来 FINAL_CANDIDATE_VALIDATION 必须有最终被测代码／测试／配置标识；新缺陷只能在既定预算内修正重验；不覆盖任何已发布 one-shot／first-pass；没有非作者接受豁免。

检查 40+20+20+8+7+5=100；7 工作块合计 20–40 有效工程日；1 日6小时是人为模型单位，容量／实际工时未被观测；日期只是 4/8/16 周算例，不是报告实测值／承诺／统计区间。

检查平台证明前移不解除工具链 gate、不声称存在可安装包；synthetic state driver 与真实 writer 分开；旧 9.x 不在当前预算且仍禁止访问；敏感数据、法律、安全、生产、UNKNOWN、本地保护未放宽。

不重跑 R17/R18，不重新接受已接受 mapping，不为了格式重复创建 review-of-review。阻塞修改必须由新候选完成；reviewer 不修改候选后接受旧 SHA。

## 5. 接受后的精确集成

唯一 verdict 路径：`docs/architecture/ELITESYNC_V10_DELIVERY_REFRESH_INDEPENDENT_REVIEW_20260921_V0_1.md`，初始 B 应 absent。

REJECT：在独立 review 分支仅发布 verdict 并 STOP；不移动 main、不启动 R18-R1。

ACCEPT：重新核验 main=B，在 B tree 上原样放入四个候选 doc blobs、本任务 blob、reviewer 自己的 verdict，恰好六路径；创建 I，sole parent=B。只 fast-forward 更新 main；失败即停，不 force。回读验证 I parent/tree、六路径范围、四文档与 task 原样。正文候选标签不改写，由 verdict 绑定其生效。

本地原 `D:\EliteSync-v10` 不默认 pull/reset/clean/stash/全仓 status/default index，不覆盖任何无关修改。文档审查可用远端 Git objects，不强制额外建立同步目录。

## 6. 明确首次基线重发：不是在途特例

仅在 §5 ACCEPT 且 I 已被远端独立核验后生效。Owner 已报告原 R18-R1 未执行：此处只替换其“启动 prompt 给出的 task-publication authority”为精确 I，candidate sole parent 也为 I；不修改历史任务正文或领域／测试规则。新 source tree 的技术文件仍与 B 相同，这必须由 I 的纯文档差异和下面的固定 source gate 共同证明。

按顺序：fresh-fetch main=I → 读 I 的未改 AGENTS → 读原 R18-R1 task（仍 blob `b28397028f8795149886b7c8ecb9ddb51a691b86`）→ 核验原 task 全部固定 inputs → 从 I 创建新的 correction worktree/branch → 执行原 task。

使用新隔离根 `D:\EliteSync-v10-ip13i-r18-r1-post-delivery-refresh-v0-1`，新分支 `fix/ip-13i-r18-r1-binding-order-post-delivery-refresh-v0-1`。任一已存在／不安全即停止本地创建，不清理，不重置旧 worktree。不得把 rejected R18 当祖先，只按原任务重建指定五个 code/test blobs。

这不是给旧 task 增加测试预算。原最多两次真实 PHPUnit、首次 PASS 后不得再改代码／测试、offline Composer 一次且禁止网络／scripts/plugins、六路径写集合全部不变。新工作流对该任务明确不适用。实现候选仍需 ChatGPT 或其他非作者独立验收，Codex 不集成自己的代码。

若在文档审查期间发现原 R18-R1 已实际开始，停止本段，不擅自 rebase／搬运或丢弃其修改。未知 main 移动也停止，不仅检查“是文档”就自动扩大例外。

## 7. 原任务中缩写路径的精确展开

这是原 R18-R1 §§5–6 已授权对象的路径展开，不扩大源内容。D/=`services/backend-laravel/app/Domain/`，T/=`services/backend-laravel/tests/Unit/`，这些前缀必须按此展开使用。

| 固定 ref | 路径 | Blob |
|---|---|---|
| rejected R18 `64dd8f8dccbbb3582656f98a70b1e36c6449fe0b` | `D/InMemoryLogicalPersistenceRepositoryContract.php` | `6178bc7290a9e542a39155756c9dd9e43d9eb0b2` |
| 同上 | `D/SqliteInMemoryLogicalPersistenceAdapter.php` | `678881a6c5868170270f4a400351966dd2e69a95` |
| 同上 | `T/ProductConnectionPersistenceFamilyTest.php` | `e4e6b946e5bace72da0bf36db6fd49caa328d00f` |
| 同上 | `D/ProductConnectionPersistenceApplicationAdapter.php` | `824f6950a0358d13675fb6cc79ce6c9eeaf45434` |
| 同上 | `T/ProductConnectionPersistenceApplicationAdapterTest.php` | `b1680ef749a7e30b7d696988809360c86ee51171` |
| I（值须等于 B） | `T/ProductConnectionStateTransitionEvaluatorTest.php` | `c68f82adf44af65ca80e51d7fc73bf1522b81980` |
| I（同上） | `T/CanonicalMatchPersistenceFamilyTest.php` | `aaa5c90f038db7ab3fb92c927c067f7fabe2d423` |
| I（同上） | `T/CanonicalMatchPersistenceApplicationAdapterTest.php` | `c8298f5e786a47d118b56f47cef6baab7f543b60` |
| I（同上） | `T/InMemoryLogicalPersistenceRepositoryContractTest.php` | `f5ed7cef27459faa2f799040f2166fd8e2d15b1f` |
| I（同上） | `T/SqliteInMemoryLogicalPersistenceAdapterTest.php` | `5a7c697174710f6b189a6b86681d83d7b4d72d6a` |
| I（同上） | `T/PersistenceBoundaryApplicationInterfaceIntegrationContractTest.php` | `78ac776ecb3f48a9614ad94be3349464af6aa4a5` |

原 source/code/config 其他明确路径、blob 及内容范围仍由原 task 控制；tooling 前缀为 `services/backend-laravel/`。不得为了继承读取旧仓库、README、FD02、无关代码／缓存／用户目录或私密数据。

## 8. 回执与停止

文档回执列 B、C、五路径 blobs、ACCEPT/REJECT、verdict blob、I/sole parent/tree、远端核验；无候选内容修改。它是文档 review，不是外部报告所有历史事实的重审。

通过后按 §6 完成原 correction：原 task blob、新执行基线 I、implementation candidate/parent/tree、六 code/result paths、三个保留 Phase-A blobs、修正 adapter/test/result blobs、实际测试与工具回执、首次 PASS 停止。结果文档内说明基线由本 dispatch 重发，未称为旧在途恢复。

代码候选发布后 STOP，不自受／合入、不创建新产品 task、不启动平台、HTTP、IP-13F、Messaging/Conversation、真实数据或生产工作。若实现阻塞，保留已接受文档和实际本地工作，分别报告，不回滚文档来伪装完成。
