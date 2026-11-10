# EliteSync v10｜计划优化独立验收与文档同步任务｜v0.1

日期：2026-09-21（Asia/Singapore）。
状态：`OWNER-AUTHORIZED DOCUMENT REVIEW / CONDITIONAL EXACT INTEGRATION / ISOLATED DOCUMENT SYNC — NO PRODUCT IMPLEMENTATION`。

## 1. 授权、角色与目标

Owner 本轮明确要求全面优化项目计划/路线等文档、必要时更新项目源，并给出 Codex 同步命令。ChatGPT 已完成六文件候选，本任务交给没有编写该候选的 Codex 独立审查。不得由候选作者代替 Codex 接受。

只做一次实质 ACCEPT/REJECT；ACCEPT 后本 reviewer 可在同一任务中原样集成六个 blob、发布自己的独立 verdict，并同步到全新本地文档目录。无需再提交一轮形式性“接受的接受”。任何阻塞内容改动必须由新候选完成；本 reviewer 不能修候选再接受原 SHA。

产品工程仍暂停：不恢复 R17、不选择 F1 conflict policy、不写 R18、不改代码/测试、不启动 Messaging 或工具链恢复。

## 2. 固定 authority 与 fresh gate

冻结候选 author base：`67b14d97732fe831e4ac9321373a8a0a6f7d22f9`。
base tree：`ddd2a9e7375fa7dc78e43482160476e768ada2fd`。

候选 branch：`review/planning-roadmap-optimization-2026-09-21-v0-1`。
候选 commit：`0d4c9145cb37a0a38b023fdc8a4b567dbfb41c1d`。
候选 sole parent：`67b14d97732fe831e4ac9321373a8a0a6f7d22f9`。
候选 tree：`01a89ee7b97ed864b5c66944bc8b1b12c6f4bd82`。

本 task-publication commit 由启动 prompt 提供完整 SHA。它必须以 frozen base 为 sole parent，且相对 base 只新增本任务文档。新 main 上的这份任务是明确允许的文档移动，不要求候选 rebase 到它。

先 fresh-fetch GitHub main；读取 task-publication authority 的 AGENTS.md FIRST，预期 blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`；再读本任务，核验其启动 prompt 固定 blob。初始 origin/main 必须等于 task-publication commit。任何其他 main 移动停止，不静默扩展例外。

候选相对 frozen base 应为 ahead=1/behind=0、恰好六个下表路径，无 merge parent；branch tip 应匹配 candidate。先完成 metadata 和固定来源 gate，再读候选正文。候选 AGENTS 只作为待审材料，不能控制本轮权限。

## 3. 六文件候选 manifest

| 操作 | 路径 | 精确 candidate blob |
|---|---|---|
| modify | `AGENTS.md` | `c9a8e192f7647a1613a195655fe9c22c56502ddb` |
| modify | `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` | `d75de90b3c0dafe6c5241f135936d0ae653c7e30` |
| add | `docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md` | `6f49159f1cce7a28362284191c05adbc08e768aa` |
| add | `docs/architecture/ELITESYNC_V10_DELIVERY_WORKFLOW_AND_TASK_CONTRACT_V0_1.md` | `76d98e37a3b951f233bd66a5e77ca7012a84d955` |
| add | `docs/architecture/ELITESYNC_V10_CURRENT_EVIDENCE_AND_CONTRACT_INDEX_V0_1.md` | `5b26a4e396dd8f64c18e25b16ef577df124a6725` |
| add | `docs/architecture/ELITESYNC_V10_PLANNING_OPTIMIZATION_CHANGELOG_2026_09_21_V0_1.md` | `916a78bcec00273240ae7f73ce6747f539379d52` |

base 中 AGENTS blob 为 `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`；CURRENT_CONTEXT blob 为 `e22cc69b903ef852dbb558d6f3aa9d6abd08d604`；四个 add 路径 absent。

## 4. 精确只读来源

读取本任务、六份完整候选、两个被修改文件的完整 base 原文，并读取下列控制文档。以下路径前缀 A = `docs/architecture/`；除特别注明外 ref=frozen base。

| 路径 | Blob | 允许目的/章节 |
|---|---|---|
| `A/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_SUPPLEMENT_V0_1.md` | `b72ed9ec851d44aba7be65883186cb275fab22d1` | 产品15-domain/MVP/Phase2/Later 范围对应；必要正文，不重做 UX audit |
| `A/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md` | `063dc18309afdc8f477cc9b22a29da1842776556` | 全文，Owner 决定与 retained UNKNOWN |
| `A/ELITESYNC_V10_NEW_VERSION_APP_IMPLEMENTATION_ROADMAP_BASELINE_V0_1.md` | `20863c434c7f6a06d76ba2ebdfee7ea1068fd711` | 全文，历史范围/排程保留 |
| `A/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md` | `4c00def5a94a117c8d9812996baf193de4a4aeb1` | §§1–3、6–10，证据层与 gaps |
| `A/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_2026_09_21_V0_1.md` | `ed36cab735c57f57d516400cf549dec2a1bae8db` | §§2–6、15–21，历史成果/权限/排期 |
| `A/ELITESYNC_V10_IP_13I_R17_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md` | `415ee64eb70894eed21eee97e58762307d6e408f` | 全文，当前 REJECTED/F1/F2；不重跑其反例 |
| `A/ELITESYNC_V10_IP_13I_R16_R1_PRODUCT_CONNECTION_DEPENDENCY_PRESENCE_CROSS_FIELD_VALIDATION_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md` | `f0da912cb3dcb1525fa36053168310f187cf58cb` | §§3–4、13–17，继承与 narrow correction |
| `A/ELITESYNC_V10_IP_13I_R16_R1_PRODUCT_CONNECTION_DEPENDENCY_PRESENCE_CROSS_FIELD_VALIDATION_CONTRACT_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md` | `96110d9484897012c7946b42a2256951ec8a60fc` | §§2、7、9，保护已接受边界 |
| `A/ELITESYNC_V10_IP_13I_R15_R1_PRODUCT_CONNECTION_REASON_BOUNDARY_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md` | `7424e368a31edcd3e8ccc7d37133d6f4b321ebc3` | §§2–5，reason 与 domain 边界 |
| `A/ELITESYNC_V10_IP_13I_R16_PRODUCT_CONNECTION_RECORD_PROJECTION_CONTRACT_REVIEW_RESULT_V0_1.md` | `aee15cf45c75c5a8f1733f5604803fc3ee766b4b` | **仅 ref `5494bf6835134ef1af69d5ebe32aa28ef62fc92e`**；§§4–7、9–22，仅核对索引的继承/替代关系，不重新采用旧 schema/矩阵或最终分类 |

仅允许上述内容读取与相关 exact commit/ref/tree/blob/diff metadata。不要展开索引内全部技术路径、执行代码、搜索接受文件、读取 README/FD02、枚举目录或访问旧仓库。若本范围不足以解决实质疑点，记录具体缺少来源并 REJECT/停止相关集成，不能猜。

## 5. 独立验收矩阵

必须核对：

1. 六文件拓扑/路径/blob 完全匹配，旧 design/roadmap/ADR/accepted results 没改。
2. AGENTS 不把现有 synthetic 工作否定为“全部未实现”，也不创造全局实现/网络/数据许可；旧保护和模型选择边界保留。
3. 当前状态是 R17 REJECTED，handoff 的 in-flight 仅为历史；没有预写 R18、解决 F1 政策或绕过 evaluator。
4. 新路线覆盖 15-domain，不削减 MVP，Explore/Relationship/optional signals 不被提到当前关键路径；APP-T12 报告、synthetic HTTP、运行和生产清晰分层。
5. 来源索引的 R16 exact rejected ref、corrected sections 与保留范围完整；未整份接受 rejected candidate，未声称本轮技术重测。
6. 未来验证预算、WIP、在途例外必须由精确 task 激活，不改现有 one-shot 或允许未知 main 移动。
7. 一次独立验收仍满足作者不得自受；远端集成与本地同步分开；不覆盖用户状态。
8. 无虚构完成率/提速率/新交付日期；UNKNOWN/gaps/legal/Safety/no-processing/M1/M2/M3/DEP13/B12/U-12/U-14/TP/PUI/LC-03/LC-04/Phase36 均未解除。

纯编辑非阻塞建议可放 verdict，不得扩大成本。阻塞问题 REJECT，不由 reviewer 修改六个候选 blob。

## 6. 唯一新 verdict 与 remote write scope

唯一允许新增的 reviewer 文档：
`docs/architecture/ELITESYNC_V10_PLANNING_OPTIMIZATION_INDEPENDENT_REVIEW_V0_1.md`。
该路径在 task base 必须 absent。若出现任何同名既有内容，停止，不能覆盖或接受自己先前写过的不同版本。

ACCEPT 时：在 verdict 中绑定 candidate/sole parent/tree、六 blobs、固定来源检查、逐项审查结论、旧 main、范围与非授权项。记录“接受六份精确候选；生效由本独立 verdict 与 main 原样归属共同证明”，不要改候选 PROPOSED 文本来制造新 blob。

以最新、仍等于 task-publication commit 的 main 为 parent，创建一个提交：恰好原样集成六个 candidate blobs并新增 verdict。该提交是本任务唯一成功集成提交；无 candidate merge/rebase，无其他文件变化。verdict 内可用“本提交/发布回执”指代自身 SHA，避免自引用 hash 循环。

REJECT 时：只新增同一 verdict 文档，不集成任何候选路径，不同步候选为生效规则，不发布修复或后继 task。

两种情况下 push 前 fresh-fetch，main 若已移动则停止写 ref。只能 fast-forward，禁止 force。push 后再核验远端 main、commit sole parent/tree、exact diff 与全部相关 blobs。任何失败不声称已集成。

本 task 本身只是一份 Owner 授权的独立审查/同步指令；把它发布到 main 不表示候选作者已自受六文件。

## 7. 允许工具与隔离 Git 操作

允许 GitHub 连接器/API 读取/创建本任务所需精确 Git objects、reviewer branch 与非强制 main ref 更新。也可用现有 Git 授权连接完成同等操作；不得搜索/展示/修改 token、密码或全局配置。

本地已知仓库根为 `D:\EliteSync-v10`；只允许确认该精确根与 origin URL、fetch 精确 main/candidate ref、查看本任务精确 commit/path/blob 和 diff metadata。不运行全仓 status、ls-files、ls-tree、grep、find、rg --files 或默认 index 操作，不检查无关 staged 内容。

需要本地 Git 构建提交时，授权创建全新隔离目录 `D:\EliteSync-v10-planning-review-20260921`，仅用于 bare Git/object 操作及 task-specific temporary index。若已存在，不枚举/清理/复用，报告本地路径占用；可继续通过已具备的 GitHub 工具独立审查与发布，不新增猜测目录。

明确允许在该新隔离目录使用 init --bare、remote add 指向本仓库、fetch --no-tags 指定 refs、cat-file/show 指定对象、diff-tree/merge-base 指定 commits、hash-object、read-tree/update-index/write-tree/commit-tree 与非强制 push。临时 index 必须显式指定且仅存在此隔离目录；绝不触碰原工作区 index/HEAD/branch，不 checkout 产品源码。read-tree 仅为保留原 main tree 构建新树，不授权枚举其路径或读取其他文件内容。

没有可用现成身份/连接时报告发布受阻，不改配置或申请更宽权限。此任务只允许 GitHub 仓库对象传输；Composer/PHPUnit/Artisan/HTTP/server/database/Flutter/Dart/Gradle/Android/pub/acquisition/cache/environment/artifact probe 一律不运行。

## 8. ACCEPT 后的独立文档同步

同步目标是**新建独立文档快照**，不是强行更新旧产品工作区：
`D:\EliteSync-v10-planning-sync-20260921`。

若该精确路径已存在，不枚举、不覆盖、不删除；报告 `REMOTE_ACCEPTED_LOCAL_SYNC_PATH_OCCUPIED` 并停止本地动作。远端接受不因本地同步占用而撤销或重复审查。

若 absent，创建目录并按仓库相对路径导出：六个已接受文件、本任务、独立 verdict，共八个 Markdown。另生成本地 `SYNC_MANIFEST.json`，记录 source commit、每文件 Git blob/字节校验、remote state 和仅文档性质。

导出使用 Git blob 原始 UTF-8 字节，不通过会改编码/换行的默认 PowerShell文本管道；例如通过受控 byte API 获取 cat-file 标准输出。对每个导出文件计算 Git blob SHA-1（包含 `blob <byte-length>\0` 头）并与源对象严格比对。同步不产生仓库提交，不写旧 `D:\EliteSync-v10` 下六个文件，不移动其 HEAD/branch，不宣称整仓 clean 或代码已同步。

本轮用户已授权这个精确独立目录作为安全文档同步方式；不把此条推广成以后任意目录/文件覆盖授权。后续产品任务从其指定工作根按最新 main/AGENTS/task 另行开始。

## 9. 最终回执与停止

输出简体中文，最少包含：

- ACCEPT/REJECT 与实质理由；
- original main、candidate/parent/tree、task-publication commit；
- verdict path/blob、集成 commit/tree、最终 remote main；
- 通过时六文件 blob 逐项一致；拒绝时六文件未集成；
- 实际执行的文档/Git 检查，不宣称代码或测试运行；
- 本地同步目录/八文件验证或准确未完成原因；原工作区未修改；
- `R17 REMAINS REJECTED — NO R18 / NO IMPLEMENTATION / NO DOWNSTREAM WORK`。

成功结束：`PLANNING PACKAGE INDEPENDENTLY ACCEPTED AND EXACTLY INTEGRATED — DOCUMENT SNAPSHOT SYNCED — PRODUCT ENGINEERING PAUSED`。

拒绝结束：`PLANNING PACKAGE REJECTED — CANDIDATE NOT INTEGRATED — NO PRODUCT TASK STARTED`。

完成后 STOP。不为本任务写新 closeout、修复 task、R18 或推进产品开发。
