# EliteSync v10 指令精简、独立接受与本地文档同步任务 v0.1

Status: `BOUNDED DOCUMENT REVISION CONTRACT — CANDIDATE AUTHORING THEN INDEPENDENT REVIEW — NO M3 AUTHORITY`

日期：2026-09-07（Asia/Singapore）。Owner已在本轮明确授权必要的GitHub文档更新、项目源打包与后续本地文档更新。本任务在任何指令改写前发布。它把修订、独立复核及通过后的同步放在一个有限合同中，不要求逐个措辞再立任务。

## 1. 基线与入口

仓库：`zcx369658780/EliteSync-v10`。本任务基线main：

`a2438e24564a5ce93b57068ab91a78c3f70ded3a`

该提交包含已接受的两份文档报告及 `docs/architecture/ELITESYNC_V10_DOCUMENT_AUDIT_ACCEPTANCE_V0_1.md`。接受的报告候选为 `7ff4721121525eddff71c16c1d1bd51f7b75dc69`，两个blob分别为 `979f3a25a0b3685840cd957b063ab0d71b18b1e6`、`36283bfb918ed515d07e4e93816a726f8616e164`。

审查／执行会话先实时读取main，要求上述A基线；第一份主动读取的项目治理文档仍为 `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，在A读取，要求blob `18485c95262051e43892436fb52413132c5ee626`。随后读取上述接受记录、本任务及启动prompt绑定的修订候选。原交接的f77dac与原审查任务的0f3db3是历史阶段基线，不把它们误用为此次main要求。

本任务commit/blob及候选commit/两个blob由发布后的prompt绑定，不能用浮动分支代替。任务提交唯一父为A，只新增本任务；修订候选唯一父为任务提交，只改§2两个目标。入口、哈希、父子关系或main不匹配时，停止依赖它的后续读取／写入；不换基线、不rebase、不猜新任务。

## 2. 唯一修订范围

| 路径 | 基线 | 允许变更 |
| --- | --- | --- |
| `AGENTS.md` | blob `2ac5580d7eb4da4cc3b0d09ead7518dee6f607ad` | 保留产品权威、阶段、职责、目录分类和保护；澄清入口、局部停止、验证与结束条件；用简体中文表达；不改模型配置 |
| `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` | 在A精确查询缺失 | 新增一个当前上下文汇编：已知产品基线、现行约束、近期问题／证据／完成条件、精确来源；不伪装成恢复的早期总纲，不新建Phase |

历史handoff、ADR、旧M3任务／review、两个已接受报告全部不改名、不搬迁、不删除、不改原始状态。无需创建缺失的7个AGENTS.override／子目录AGENTS，也不添加ROADMAP、PLANS、skills、全局AGENTS或配置文件。

## 3. 精确只读输入

除§1、§2及本任务外，只允许按已绑定提交读取下列文件：

- `docs/architecture/ELITESYNC_V10_DOCUMENT_RECOVERY_INDEX_V0_1.md`，A，blob `979f3a25a0b3685840cd957b063ab0d71b18b1e6`。
- `docs/architecture/ELITESYNC_V10_SYSTEM_DOCUMENTATION_AUDIT_AND_ROADMAP_PROPOSAL_V0_1.md`，A，blob `36283bfb918ed515d07e4e93816a726f8616e164`。
- `docs/architecture/ELITESYNC_V10_PHASE_35_CURRENT_SESSION_HANDOFF_V0_1.md`，A，blob `3699f51b91ea563e0e2a81d6912c87ad53d1b3df`；只在核对产品／Safety语义需要时读取相关章节，不执行历史startup。
- 原交接已绑定的预检review，A：`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_PREFLIGHT_SIDE_EFFECT_CLOSURE_GOVERNANCE_REVIEW_V0_1.md`，blob `a012c612532134ff7ada1c685234aae1d866e492`；仅按需核对状态，不进行工具链研究。

官方依据限4个主题：`https://developers.openai.com/api/docs/guides/latest-model`、`https://learn.chatgpt.com/docs/agent-configuration/agents-md`、`https://learn.chatgpt.com/guides/best-practices`、`https://learn.chatgpt.com/docs/agent-approvals-security`，允许同主题官方重定向。需要时核验实际Astra章节，不把默认旧型号页签或API迁移示例当作本地改配授权。记录日期、URL和适用范围；无必要不重复整套研究。

不存在新的引用追踪预算。除本任务自产提交的父／树标识／变更清单、已声明refs和精确文件blob外，不查提交历史、不列目录、不查全仓文件。

## 4. 修订者职责与终点

当前ChatGPT可依Owner直接更新授权，在发布本任务后编写两个修订目标；这不是自我接受权限。

任务分支：`task/gpt6-astra-instruction-refresh-local-sync-v0-1`。
修订分支：`review/gpt6-astra-instruction-refresh-local-sync-v0-1`。
候选subject：`docs: clarify agent workflow and consolidate current context`。

使用GitHub Git Database，以任务tree为base只更新两个目标；一个候选提交、唯一父为本任务；不接触本地index、不枚举tree、不覆盖已有冲突分支。核验两个blob与唯一两路径diff，提供prompt和文档包后停止。不得把修订候选直接推入main，也不得预先填写独立审查结论。

## 5. 新Codex会话的独立复核与接受权限

Owner在实际Codex会话选择GPT-6 Astra。此任务不读取／修改配置、不启动其他模型；使用单个主审查会话，辅助代理不是必要步骤。无法证明实际model ID时如实说明；不能通过提示词宣称模型已切换。

新会话不得参与改写本候选再接受自己改写的结果。按§1验证后，检查：

1. 两路径范围、旧AGENTS保护语义完整、没有实现或隐含网络／缓存权限。
2. 历史startup与当前授权分离；局部缺口只暂停依赖决定；硬基线门仍停。
3. 目标／输入／约束／完成条件清楚；必要验证后不无故重复；不存在同义治理任务自动循环。
4. 当前上下文只汇编已知证据；未知总纲与ADR审查缺口保留；不把文档进度当产品完成率。
5. 原交接全部边界及独立审查要求保留，官方规范不被表述为技术隔离或完整宿主配置证明。

一次内容／引用／范围／拓扑核对即可；不跑项目测试、文档构建、链接爬虫或工具链。明确返回 `ACCEPT` 或 `REJECT`。

REJECT：报告具体问题和证据，保持main与本地文件不变；不自行修改候选，不另发任务。

ACCEPT：Owner通过本合同授权以下有限后续动作，不再询问一次“是否可以同步”：

- 唯一新增接受记录：`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_INSTRUCTION_REFRESH_ACCEPTANCE_V0_1.md`。
- 记录exact候选commit／两个blob、检查结果、独立角色及范围。声明本次仓库指令修订关口关闭；本地同步／实际加载状态分别报告；全局配置未审查；M3仍blocked。
- 以候选为唯一父创建一个仅新增该记录的提交R；不得编辑两个被审查目标。发布到新分支 `review/gpt6-astra-instruction-refresh-acceptance-v0-1`。
- 立即重读main要求仍为A；非强制快进main至R，不merge、rebase、cherry-pick或force。若平台保护阻止直接推进，报告明确障碍，不更改保护规则或绕过审批。
- 推进后回读main及两个目标blob，确认成功后才允许§6本地同步。

本任务赋予的是对另一个作者候选的文档接受与有限发布，不是无限Owner权威。报告接受不等于执行M3，也不自动发布下一项M3任务。

## 6. 精确本地文档同步：不checkout、不触碰默认index

目标根仅 `D:\EliteSync-v10`。允许根／HEAD／当前分支元数据读取，HEAD无需等于远端A或R。不要git pull、merge、checkout、switch、reset、stash、clean、clone或创建worktree。不要git status、读写默认index、未跟踪扫描、宽范围diff、git add或本地commit。

仅在§5完成后，对以下8个字面目标授予**本次任务相关工作区文档**的定点内容读取／比较与安全写入权限，这是相对旧只读任务的明确扩展，不延伸到任何无关或受保护文件：

1. `AGENTS.md`
2. `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_DOCUMENT_AUDIT_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_DOCUMENT_RECOVERY_INDEX_V0_1.md`
5. `docs/architecture/ELITESYNC_V10_SYSTEM_DOCUMENTATION_AUDIT_AND_ROADMAP_PROPOSAL_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_INSTRUCTION_REFRESH_AND_LOCAL_SYNC_TASK_V0_1.md`
7. `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_INSTRUCTION_REFRESH_ACCEPTANCE_V0_1.md`
8. `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`

权威内容只从最终固定R取得。先检查字面路径及祖先不是symlink／junction／reparse point；发现即跳过该路径，不跟随。父目录缺失时只可创建上述字面路径必需的docs／architecture目录，不列目录。

文件不存在：以exclusive-create语义写入。文件存在且与R原文一致：不写。AGENTS存在且仅与旧blob `2ac5580d7eb4da4cc3b0d09ead7518dee6f607ad` 的正文一致：允许更新为R版本。比较允许仅规范CRLF/LF，但不能忽略其他内容差异。其余存在且不同的文件一律保留，报告目标冲突，不读／输出差异正文，不stash、不覆盖、不改名备份；继续其余独立可同步目标。

对已允许更新的AGENTS，写前再次比较已授权字节，变化则取消；采用工具支持的最小安全替换方式，不能覆盖未知版本。写入后核验本次写入文件的Git blob／SHA-256。禁止运行仓库脚本和安装工具，允许标准文本与哈希处理能力。

工作区文档同步不是本地Git历史同步。不得宣称HEAD=origin/main、整仓clean或index内容已验证。默认index和任何无关受保护暂存状态始终不检查、不修改、不提交。若宿主已经明示某个目标属于受保护对象，跳过它，不读取内容。

AGENTS更新不证明本轮已自动重载；完成后请Owner从该根启动新的Astra会话。下一会话可报告宿主已公开的指令来源，但不得搜索未授权全局配置。同步冲突可形成局部未完成，不回滚远端已接受文档，也不阻断其余合规同步。

## 7. 保持原边界与结束输出

README预算耗尽；FD02永久排除；不枚举仓库或目录，不运行rg --files、find、fd、git ls-files、git ls-tree、git grep、globs、代码／文件名搜索；不访问旧D:\EliteSync或zcx369658780/EliteSync。受保护无关staged state不得检查、修改、unstage、覆盖、reset、clean、提交、引用、总结或使用。

保持D-02／D02-DURABLE-UNKNOWN-01、U-14排除、U-12精确目标、TP-SOURCE-CLASS-01、TP-TARGET-01、Backend 0/10、Database 0/8、deferred PUI、PUI-PREREQ-12=0、legal／Safety／no-processing；implementation、LC-03、LC-04、Phase36未授权。沿用既有pre-alpha法律完成及生产成熟度触发表述，不开展新法律研究、参与者／业务数据／private-Conversation／telemetry／Safety Operations工作。

M1冻结lane耗尽、False / WORKTREE-STATE NON-HIT ONLY；M2 deferred；M3 blocked、Outcome B不变。禁止Flutter／Dart／Gradle／Java／Android工具、syncFlutterAar、构建前置检查、依赖解析、缓存／环境检查、.android或生成输出检查、artifact probe和M1重试。旧M3提交8b640576822b01ae00bb04b9b5deaa75db53365c不得恢复。

最终只报告独立结论、候选和接受commit／blob、远端main、8个目标的同步／未变化／冲突／未核验状态及实际模型证据限制；不输出受保护内容、不另建closeout、不发下一任务、不自行上传ChatGPT项目源。达到这些条件即停止。
