# EliteSync v10｜v0.8-R1 候选重封装与 CURRENT_CONTEXT 编码修复 v0.1

Status: `TASK ONLY — GITHUB REPACK ONLY — NO LOCAL EXECUTION / SANDBOX / PUB / M3`
日期：2026-09-09（Asia/Singapore）。默认主执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol、Medium；不修改模型配置、不默认调用辅助代理。ChatGPT负责规划与独立验收。

## 1. 原因与唯一目标

v0.8-R1 候选 `d45ae29ce49e8317f37b06e8479ea6d5ce992914` 的结果报告本身完整、UTF-8 可读，blob 为 `99b98bfc81e4dfe431d9b6919b35a2383204c8d4`。但同一候选中的 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` blob `2033ac90e13e3bd9f6707f0f4936af99729fc687` 在页首、§1、§4、§5出现明显 mojibake/编码破坏，不能作为有效 CURRENT_CONTEXT 接受进入 main。

本任务仅重新封装 GitHub 候选：**原样复用已发布的 v0.8-R1 结果报告 blob，不重写其正文；从干净 main 的 CURRENT_CONTEXT blob `5ef59aa9e6ad12b03ad34ab335b461fa68bbe5c9` 出发，用有效 UTF-8 更新页首、§1、§4、§5来表达同一 v0.8-R1 事实，并逐字保留§2、§3、§6、§7。**

不读取或执行 D: 本地证据，不启动 PowerShell、Sandbox、Flutter、pub、M3、M2，不重跑 host 4+6，不修改 AGENTS、产品源码或项目源。`d45ae29...` 保留为被独立审查拒绝整体接受的历史候选；不要修改或强推它。

## 2. 固定 GitHub 入口

仓库：`zcx369658780/EliteSync-v10`。开始实时读取 main，必须恰为：
`16225ef1db6063dacadd3bfc8b033b325c11d5df`（A）。

FIRST 主动读取 A 中：
`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，要求 blob `18485c95262051e43892436fb52413132c5ee626`。

随后读取启动 prompt 固定的本任务 commit/blob，核验唯一父 A、相对 A 仅新增本任务文件。main/task/blob 失配停止依赖操作，不自行换基线。

其他 GitHub 输入仅限：
- A 中 `AGENTS.md` blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`，只确认规则。
- A 中 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` blob `5ef59aa9e6ad12b03ad34ab335b461fa68bbe5c9`，作为唯一干净上下文基底。
- 任务 commit `d7d384b6616cbccd5a27a8ba2de649f07c624fea` 及任务文件 blob `58cbfef2a382ae7aeeb78f17e1819fb0761ac251`，用于确认 v0.8-R1 运行合同。
- 被拒整体接受的候选 commit `d45ae29ce49e8317f37b06e8479ea6d5ce992914`。
- 该候选的结果报告精确路径与 blob `99b98bfc81e4dfe431d9b6919b35a2383204c8d4`；可读正文以生成上下文摘要，但结果报告正文必须原样复用。
- 该候选的损坏 CURRENT_CONTEXT blob `2033ac90e13e3bd9f6707f0f4936af99729fc687` 只用于确认“损坏对象身份”；**不得把其中乱码文本转码、解码、修补后作为新正文来源。**
- A 的 tree-repair 提交消息可读，用于准确说明 `16225ef...` 的权威来源。

不读取 README/FD02/旧仓库，不仓库枚举、搜索或跟进未授权引用。

## 3. 结果报告必须字节等同

新候选中的：
`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_8_R1.md`

必须与 `d45ae29...` 中该文件的 blob 完全相同：
`99b98bfc81e4dfe431d9b6919b35a2383204c8d4`。

不改标题、Status、标点、空白或换行；不要“顺手纠正文风”。如连接器无法直接复用 blob，可读取 UTF-8 正文后原样创建，并发布前核验最终 blob 必须仍为上述 SHA；不匹配则停止，不发布候选。

该报告接受层面的实际事实保持：旧008 host ordinary native 4/4 与 batch 6/6证据被只读绑定且未重跑；dispatch=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`；guest草稿/冻结 SHA=`578F97570EED07274A2E783730F5130126A5D12C8A03FA3F4B0E9A41C1889D39`；固定对象526文件、defines=EMPTY；WSB静态合同通过；一次Sandbox启动后自有记录代码因把PowerShell布尔字面量写成`true`而非`$true`，未保存原Process PID/创建时间/exit；之后未建立guest.started/guest结果，Sandbox具体启动层保持UNKNOWN；guest/复制/Git/Java/pub/M3均未运行，AAR=NOT_CHECKED，M2 deferred。

## 4. 从干净 CURRENT_CONTEXT 更新，不碰保留章节

必须从 A 的 UTF-8 `CURRENT_CONTEXT` blob `5ef59aa9...` 开始编辑，而不是从 `2033ac90...` 修码。

只允许更新：
- 页首发布状态和更新日期摘要；
- §1 当前入口和生命周期；
- §4 结果里程碑表中 M3/M2 行及与本轮状态直接相关的说明；
- §5 精确来源与覆盖缺口。

必须逐字保留 A 中：
- §2 产品目标与概念基础；
- §3 必须保留的当前边界；
- §6 官方规范的有限采用；
- §7 Owner交付与一次验收约定。

新 CURRENT_CONTEXT 应使用正常简体中文 UTF-8，并准确记录：
1. 当前接受基线是 tree-repair main `16225ef1db6063dacadd3bfc8b033b325c11d5df`；007事实已恢复并是有效权威内容。
2. v0.8 原任务因错误 main tree 固定入口停止、无GitHub候选；其host 4+6本地证据后来被v0.8-R1只读绑定。
3. v0.8-R1 任务 `d7d384...` 已由Owner直接批准并执行；本轮没有重跑host 4+6。
4. v0.8-R1 已绑定dispatch修复、物化526文件、defines=EMPTY、完成runner/WSB静态合同；但一次Sandbox启动后的自有记录代码出错，未建立可归属的启动/guest证据，因此分类为 `M3 PRECONDITION BLOCKED — SANDBOX STARTUP NOT ESTABLISHED`。
5. 不能把该分类写成Windows Sandbox不可用或guest启动失败；launcher精确exit UNKNOWN。
6. guest策略/隔离/冒烟、八项复制、真实Git/Java、pub/M3均NOT_RUN，AAR=NOT_CHECKED/probe=0，M2仍deferred。
7. `d45ae29...` 的结果报告可接受；同候选的损坏 CURRENT_CONTEXT 不接受，当前重封装任务只修GitHub文档层，不改变本地执行事实。
8. 下一最小技术缺口仅是Sandbox启动编排/采证修正：新任务应先原子保存返回Process身份再等待nonce，不重跑host 4+6，不重开dispatch/复制/策略研究。

§5中新增/更新来源应至少列：tree-repair main、v0.7 task/result、v0.8-R1 task、v0.8-R1结果（本候选同提交）；可说明损坏 `2033ac90...` 是被拒的文档对象，但不要把其乱码正文当来源。

## 5. UTF-8 和保留性硬门

发布前必须：
- 以 UTF-8 解码新 CURRENT_CONTEXT 成功；
- 目视/程序检查页首、§1、§4、§5不存在明显 mojibake 字符序列；
- 从 A 分别抽取§2、§3、§6、§7，与新文件对应章节逐字节/逐字符一致；
- 结果报告 blob精确为 `99b98bfc...`；
- CURRENT_CONTEXT 不得等于损坏 blob `2033ac90...`；
- 不因为修复编码而重排或润色保留章节。

任何保留章节差异、结果blob变化或新乱码 => STOP BEFORE CANDIDATE PUBLISH。

## 6. 唯一候选拓扑

候选分支：`review/m3-v0-8-r1-candidate-repack-v0-1`。

发布一个 commit，唯一父为本任务 commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_8_R1.md`，blob必须 `99b98bfc81e4dfe431d9b6919b35a2383204c8d4`。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`，以 A 的 `5ef59aa9...` 为基底并满足§4–5。

subject：`docs: repack v0.8-R1 result with clean UTF-8 context`。

发布后只核验一次：候选commit、sole parent、ahead/behind、恰好两路径、结果blob、新CURRENT_CONTEXT blob、§2/§3/§6/§7保留检查。执行者不自我接受、不更新main、不另发Sandbox任务，不更新AGENTS或ChatGPT项目源。完成后停止。
