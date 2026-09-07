# EliteSync v10 当前上下文与近期决定 v0.1

发布状态：`INSTRUCTION REFRESH CANDIDATE — REQUIRES INDEPENDENT ACCEPTANCE AND MAIN PROMOTION`

编写日期：2026-09-07（Asia/Singapore）。本文件整合已知产品基线、现行状态和精确来源；不是恢复的2026-08-22原始总纲，不替代完整ADR，也不是技术设计或实现计划。发布状态保留历史意义；后续是否生效必须同时查明精确候选的独立接受记录与main归属。

## 1. 当前入口和生命周期

本轮已接受的文档审查基线A：`a2438e24564a5ce93b57068ab91a78c3f70ded3a`。A包含候选 `7ff4721121525eddff71c16c1d1bd51f7b75dc69` 的两份报告及独立接受记录。报告原始PROPOSED标题不否定后续接受，但报告接受也不自动接受其中每条建议。

当前修订任务：`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_INSTRUCTION_REFRESH_AND_LOCAL_SYNC_TASK_V0_1.md`；任务提交 `f454bab732a3bb6ca3ca3d248e74c8cf2b519113`。本文件和根AGENTS是该任务的仅有两个修订目标。在审查分支读取它们不能自动获得生效地位。

本轮首先主动读取的权威仍是 `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，blob `18485c95262051e43892436fb52413132c5ee626`；原交接内部f77dac是历史接受基线。以启动prompt明确绑定的main与任务版本核验当前会话，不按任何历史“read first”重新执行旧任务。

独立新会话若接受本修订，应按上述任务发布 `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_INSTRUCTION_REFRESH_ACCEPTANCE_V0_1.md` 并推进main，才使本指令版本生效。该文件是将来规定的输出，不声称现在已经存在。候选作者不得自行填写其结论。

## 2. 产品目标与概念基础

来源是固定原基线 `0f3db3e00975d95d4145954dc69f7f55d7dee1d0` 下的 `docs/architecture/ELITESYNC_V10_PHASE_35_CURRENT_SESSION_HANDOFF_V0_1.md` §§3–4（blob `3699f51b91ea563e0e2a81d6912c87ad53d1b3df`）。下列为该记录中的已接受OD与Safety语义摘要，不是重新接受全部上游ADR。

EliteSync是在不确定条件下支持人类审慎探索关系的Relationship Decision Support System，不是AI关系裁判、自动配对裁判或以提高参与度为目标的系统。v10拥有新架构权威，9.x不提供自动继承许可。

`Match ≠ Connection ≠ Conversation ≠ Relationship`。AI只做辅助，不是事实、关系、同意、罪责或自主Safety权威。用户声明不等于客观事实，AI输出不等于已验证事实，私密Conversation不是默认训练数据。

七个概念责任上下文为Identity、Personality、Compatibility、Matching、Conversation、Relationship、Safety；这是概念责任边界，不要求实现七个服务或七个数据库。信息权威按Meaning、Provenance、Purpose、Lifecycle区分。

Privacy、Safety、User Control优先；Explainability、Reliability、Fairness、Auditability作为支撑约束。Safety证据不得进入普通Compatibility／Ranking或公开声誉、恋爱价值、信任度等评分；最小必要执行控制指令不等于Safety证据。

Block不等于Report；举报只说明有人提交关切，不证明违法或不当行为。Allegation不等于Finding；即时保护不等于罪责或惩罚；未推进不证明举报者说谎；未知不等于假、不等于安全。未来限定的Safety-only运营风险评估仍为NOT DECIDED。

## 3. 必须保留的当前边界

以下承接转型交接§§3、8及已接受报告，不是本次重新作出的法律或技术结论。

- README documentary-read budget耗尽；FD02永久排除；禁止仓库／目录枚举、文件名／代码搜索及递归发现。不得访问旧 `D:\EliteSync` 或源仓库 `zcx369658780/EliteSync`。
- 受保护无关staged state不得检查、修改、unstage、覆盖、丢弃、reset、clean、提交、引用、总结或使用。文档精简不能撤销这一保护。
- D-02 unresolved／`D02-DURABLE-UNKNOWN-01`；U-14 exclusion；U-12 exact-scope target rules；`TP-SOURCE-CLASS-01`；`TP-TARGET-01`保持。
- Backend `0/10 NOT INSPECTED / NOT AUTHORIZED`；Database `0/8 NOT INSPECTED / NOT AUTHORIZED`；deferred PUI；PUI-PREREQ-12=`0`保持。
- accepted legal／Safety／no-processing边界保持；implementation、LC-03、LC-04、Phase36未授权。不得开展参与者研究／招募、业务数据活动、private-Conversation检查、telemetry／analytics／measurement、Safety Operations、新法律研究或技术实现。

沿用既有结论：`CORE PRE-ALPHA LEGAL BOUNDARY IS SUBSTANTIALLY COMPLETE; PRODUCTION LEGAL READINESS IS DEFERRED TO MATERIAL MATURITY TRIGGERS.` 法律不重新成为当前关键路径；这不表示生产法律准备已完成。

M1一次性冻结目标lane耗尽，结果为 `False / WORKTREE-STATE NON-HIT ONLY`，证据根仍为 `D:\EliteSync-v10`；不推论全局产物不存在、构建失败、集成无效或依赖解析失败。M2保持deferred。

M3保持blocked；已接受预检是Outcome B。选定的未来方法类别仍为direct `flutter build aar --no-debug --no-profile`及既有dart-define参数；这里仅记录历史类别，不是可运行命令授权。网络、缓存／工具状态、附带写入范围和安全前置检查仍未闭合。不得忽略生成型 `.android` 状态；本轮不读取它。

`METHOD CLASS ≠ EXECUTION AUTHORITY`；`GENERATION SUCCESS ≠ DEPENDENCY-RESOLUTION SUCCESS`；`GENERATION FAILURE ≠ INVALID INTEGRATION`；`COMMAND EXIT 0 ≠ RELEASE ARTIFACT PRODUCTION PROVEN`。未来新的一次性生成后证据方法仅原则上可支持，不授权重试M1或artifact probe。

旧M3任务 `8b640576822b01ae00bb04b9b5deaa75db53365c` 已编写但Owner和原交接记录尚未执行，不得恢复；原任务不因本次文档修订自动重获执行权。本转型中禁止Flutter／Dart／Gradle／Java／Android工具、syncFlutterAar、依赖解析、前置检查、缓存／环境或生成输出检查。

## 4. 近期路线：问题、证据、完成条件、下一决定

这是已有治理依赖的整理，不新增Phase、技术方案或产品完成百分比。

| 条目 | 要回答的问题与现有证据 | 完成条件及下一决定 |
| --- | --- | --- |
| 文档索引与审查 | 有界索引和14项发现；候选7ff4721已由A独立接受 | 本交付已闭合，不因原始PROPOSED标题重复提交同一审查 |
| 当前指令修订 | 消除含糊入口、全局停工和重复治理；只改根AGENTS与本汇编 | 独立新会话ACCEPT、固定候选进入main；本地同步和实际加载另报结果，不能提前宣称全部完成 |
| 本地文档同步 | GitHub文件存在不证明本地已同步；旧报告记录本地HEAD滞后 | 按同一修订任务只同步8个精确文档，冲突保留，不碰默认index；不能声称整仓同步或完整宿主配置验证 |
| 转型后的M3任务处置 | 原交接要求旧任务重评；Outcome B仍是起点 | 指令修订接受后，从届时durable main另行重新评估并重发／替代；明确新增证据或约束与单一完成条件，不复用旧任务 |
| M3实际执行 | 当前缺少执行授权和完整边界 | 继续blocked；必须另有明确执行授权，本文不给环境或构建方案 |
| M2及其他延期项 | M2 deferred；产品／外部证据和未授权事项仍有缺口 | 仅由具体证据与独立授权触发；不自动启动LC-03、LC-04、Phase36或实现 |

没有新证据、约束变化或具体缺陷时，保留同一未决条目，不自动再发同义治理任务。进展说明关闭了哪个问题、证据如何变化、现在能作出什么决定，不用文档数量表示产品进度。

## 5. 精确来源与覆盖缺口

| 来源路径 | 固定版本／用途 |
| --- | --- |
| `AGENTS.md` | 原blob `2ac5580d7eb4da4cc3b0d09ead7518dee6f607ad`；本任务修订其表达，不改变产品权威 |
| `docs/architecture/ELITESYNC_V10_DOCUMENT_AUDIT_ACCEPTANCE_V0_1.md` | A；接受两份报告，不是本指令候选的接受记录 |
| `docs/architecture/ELITESYNC_V10_DOCUMENT_RECOVERY_INDEX_V0_1.md` | 候选7ff4721／A，blob `979f3a25a0b3685840cd957b063ab0d71b18b1e6`；路径、版本、状态索引 |
| `docs/architecture/ELITESYNC_V10_SYSTEM_DOCUMENTATION_AUDIT_AND_ROADMAP_PROPOSAL_V0_1.md` | 候选7ff4721／A，blob `36283bfb918ed515d07e4e93816a726f8616e164`；14项发现和建议 |
| `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` | 原main0f3db3／A，blob `18485c95262051e43892436fb52413132c5ee626`；转型入口和永久边界 |
| `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_PREFLIGHT_SIDE_EFFECT_CLOSURE_GOVERNANCE_REVIEW_V0_1.md` | 原main0f3db3／A，blob `a012c612532134ff7ada1c685234aae1d866e492`；保留Outcome B，不重新做Flutter研究 |

早期2026-08-22总纲路径未知；ADR-005独立审查完成事件未证实；全局AGENTS、fallback、skills、完整自动加载链与用户配置未检查。报告中的本地存在性是执行者的有限快照，不证明当前工作区内容、index或cleanliness。本次新项目源包是已知信息汇编，不是仓库全量导出，也不证明旧项目源上传情况。

## 6. 官方规范的有限采用

核验日期2026-09-07；实际模型由Owner在宿主选择。对齐指令表达不等于API迁移、配置更新、技术沙箱验证或所有代理均为Astra。

- https://developers.openai.com/api/docs/guides/latest-model — Astra相关指导用于消除含糊规则、完成授权任务和校准验证范围。
- https://learn.chatgpt.com/docs/agent-configuration/agents-md — 自动加载／覆盖是宿主机制；任务优先读取与自动加载分开陈述。
- https://learn.chatgpt.com/guides/best-practices — 目标、上下文、约束、完成条件；保持根指令短而实用。
- https://learn.chatgpt.com/docs/agent-approvals-security — 沙箱、审批和项目授权分开，不以文档文字宣称技术隔离。

以上链接仅供同主题有界核验，不授权按其示例运行status、测试、安装、网络配置或模型迁移。独立审查者的接受及本地同步结果发布前，不宣布本次指令修订生效。
