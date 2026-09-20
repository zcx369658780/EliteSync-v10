# EliteSync v10｜交付工作流与任务契约｜v0.1

日期：2026-09-21（Asia/Singapore）。
状态：`PROPOSED — REQUIRES INDEPENDENT ACCEPTANCE — NOT A LIVE EXECUTION TASK`。

## 1. 目标与优先级

把一个真实交付闭环做完整，减少没有新增证据的治理往返；保留作者/审查独立、精确来源、最小权限和本地修改保护。

优先级：宿主指令 > Owner 本轮明确授权/约束 > 本轮精确 task 与 accepted 约束 > 已生效仓库工作流 > 当前计划 > 历史建议。高优先级也不能被解释为不存在的合法/生产/数据授权。

本工作流只在独立接受后适用于后续任务编写。它不修改已冻结任务的读写范围、命令次数、one-shot gate 或停止条件，不复活旧任务。

## 2. 最少文件与一次独立验收

一个任务通常只需：task、候选交付（代码/测试/一份结果）、独立 verdict。需要交接才写 handoff；没有新信息不增设 readiness review、review-of-review 或 closeout gate。

角色：任务作者绑定 Owner 已授权范围；候选作者实施并自检；非候选作者独立审查；接受后的集成者原样集成。任务作者可以审查他人候选；候选作者不能自受。作者自检不是独立审查。

审查只能 ACCEPT 或 REJECT 精确对象，可记录非阻塞观察。阻塞修正需新 candidate SHA；不可审查时修改候选后仍声称同一对象通过。独立 reviewer 可在同一次明确任务内完成 ACCEPT、精确集成与同步，无需再找第三位对同一 verdict 作形式验收。

## 3. 任务必填字段

以下是模板，不是本轮运行授权。

```text
TASK_ID / TITLE / ROLE
OWNER_AUTHORIZATION_AND_GOAL
NEW_EVIDENCE_OR_CONCRETE_DEFECT
FROZEN_EXECUTION_BASE (exact commit)
TASK_PATH_AND_FIXED_OBJECTS (path / ref / blob / allowed sections)
READ_SET (explicit paths; include retained corrected sources)
WRITE_SET (explicit paths and create/modify/delete operation)
CONTRACT_DECISIONS_ALREADY_ACCEPTED / DECISIONS_NOT_YET_ALLOWED
INPUT_OUTPUT_AND_FAILURE_BOUNDARIES
ALLOWED_COMMANDS_AND_SIDE_EFFECTS / ATTEMPT_BUDGET
TARGET_TESTS_AND_SHARED_BOUNDARY_REGRESSIONS
FRESH_BASE_AND_IN_FLIGHT_MOVEMENT_POLICY
PASS_CRITERIA / STOP_CONDITIONS
PUBLICATION_RECEIPT / INDEPENDENT_REVIEW_REQUIREMENT
INTEGRATION_AND_OPTIONAL_LOCAL_SYNC_AUTHORITY
```

文档任务明写 runtime commands = NONE；实现任务不能只写“运行必要测试”。精确 path/ref/blob 不用“最新版”“相关文件”“如有需要自行查找”代替。缺少 source definition 时 task author 补齐清单，而不是让执行者默认扩大读取。

## 4. 修正稿与来源闭包

task 的 contract source 必须覆盖 key sets、词表、跨字段矩阵、默认/nullable 字段、identity/canonicalization、终态/失效、隐私/非权威字段。每个定义有实际来源，不能只引用一份局部 correction。

有 supersession 时列清：原文件固定 commit/blob、保留章节、替代章节、accepted correction 与 acceptance。原稿整体 REJECTED 不妨碍 accepted correction 明确恢复的部分作为来源；但不得把原候选整份升级为 accepted。

只有来源链稳定且确有消费成本时才做一次独立接受的自包含 consolidation；不能为每层接口重复合并或改写语义。本次先以精确 index 修复可发现性，不生成新的 Product Connection 技术契约。

## 5. fresh-base 与在途主线移动

task 必须分别写明：初始执行 gate、冻结 execution base、预期 sole parent、候选范围，以及 review/integration 时的 main。

默认初始 gate 失败即停。若后续 task 明确准许在途例外，必须满足执行者已在 main 移动前通过初始 gate，并给出回执。reviewer 对候选相对 frozen base 查拓扑，对 main 相对 frozen base 的变化另外查验。

仅 task 明列的无关 handoff/review-receipt 文档移动，且固定输入 blob、写路径和规则均未改变，才可原样评审并向新 main 集成。任何未知移动、AGENTS/任务约束/消费源变化、路径碰撞或代码变化均停止集成并定点确认，不自动重基。

R17 的 `b0196202...` 例外是已记录的具体历史特例；本条不扩大它或使其候选接受。新任务各自给出完整 SHA。

## 6. 作者验证预算

文档工作只作内容、来源、范围、拓扑及引用一致性检查。不得顺带启动项目测试、依赖解析、服务或数据库。

在未来明确实现任务中，低风险离线 synthetic unit tests 可采用最多三次命令尝试（初次一次 + 最多两次修正后复验）。task 必须预先点名命令、测试路径、可变动代码、允许副作用；失败仅在相同授权范围内修正。有不确定副作用、缺依赖或环境问题立即停止，不把预算变为安装/网络许可。

预算上限不是必须用满；无内容变化/新失败不重跑。单次 test command 失败也计一次；基础设施失败不能通过改变工具链或测试约束偷偷重试。旧 one-shot 的剩余次数不因本工作流增加。

修改共享 validator/storage 时，点名新增 family 目标测试和受影响的既有 family 回归。不能只因新增用例通过就声称 reference/SQLite parity 或所有历史行为保持。未获准的全套测试保持未运行。

## 7. 证据组合与反例

候选需证明关键边界，不只报告 happy path 数量。相关时至少覆盖：输入置换、equal-conflict 与 higher revision 的组合、incomparable namespace、缺 dependency、真实 cross-field mismatch、终态保留、generic overlay 与 domain invalidation 分离、exact payload readback、UNKNOWN/REJECTED 不可用。

这些是验证问题，不预先决定领域政策。特别是 R17-F1：不得在未批准语义前增加 conflict 优先级、丢弃旧证据、排序输入改变 evaluator 行为，或把合法语义冲突变成 structural error。

静态推演、作者报告、运行测试、远端 committed scope 和本地 cleanliness 分开记录。GitHub metadata 不能证明未运行某命令或本地 untracked=0；未看到的执行证据写 NOT OBSERVED。

## 8. 独立审查与原样集成

reviewer 先读生效 AGENTS 和明确 task，再核验 authority、candidate parent/tree、精确 changed paths、固定 blobs 和所需正文。无新矛盾不重做所有既有审计。

ACCEPT 后 fresh-fetch main，确认仅 task 准许的移动；使用获接受的 immutable blobs 构建集成树，保留当前 main 的其他内容。记录 old main、candidate、integration commit/tree、逐路径 blob 和 verdict。不要复制作者文本时改换行、措辞或 SHA。

只允许 fast-forward remote update，禁止 force。push 竞争失败时停止/重新核验，不能覆盖新 main。候选分支保留，不要求 rebase；未获审查对象不得混入同一集成。

REJECT 则发布一份有具体来源和影响的 verdict；不集成候选、不启动后继。非阻塞发现不无限扩展读写。

## 9. 本地同步保护

同步是独立于 remote integration 的动作。task 必须给出本地根、允许文档清单、来源 commit/blob、旧值/冲突检查和写入方式；没有该授权只报告远端结果。

默认保护当前工作区：不 pull、全仓 checkout、reset、clean、stash、全仓 status 或默认 index 操作；不枚举 unrelated staged/untracked/modified 内容。对获准文档若有本地修改、冲突、无法确认旧内容、符号链接/目录歧义，跳过并报告，不覆盖。

可优先把精确文件同步到 task 指定的新独立文档目录，按 blob 验证，不声称整个仓库 HEAD 已同步。要同步现有 root，须另有明确目标路径条件；不得通过移动本地 branch/HEAD 假装代码也已到新 main。

工具不支持安全原样发布时，返回固定文件、hash 和未完成动作；不降级为破坏性命令。远端已接受与本地同步部分完成可以分别报告，不为本地冲突重开已通过的实质 review。

## 10. 状态维护与发布回执

回执最少包含：base、candidate/sole parent/tree、逐路径 blob、实际 diff 范围、验证实际结果、作者与 reviewer 角色、远端指向、本地观察范围、剩余 blocker、STOP。

交付接受/拒绝后只更新 CURRENT_CONTEXT 对应条目和精确来源指针；路线 milestone 有变化才更新路线。历史 result/acceptance/rejection/ADR/handoff 不随进度改写。

项目源包保持导航摘要；不自动从包中读取所有链接，不把包中的证据快照 SHA 当固定未来 authority。更新包是迁移旧入口，不是无限权限或对候选的接受。

## 11. 强制停止边界

本工作流不授权 R17 修复、R18、任何实现、HTTP、Messaging、工具链恢复、auth/session/token 设计、网络/acquisition、生产、真实/私密数据、research/recruitment、telemetry/analytics/measurement、Safety Operations、新法律研究或旧仓库访问。

README、FD02、受保护 staged state、accepted ADR/UNKNOWN/U-12/U-14/TP 边界不变。Owner 可批准未来精确任务；task author 不以本通用模板自行扩大授权。
