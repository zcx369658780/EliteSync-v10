# EliteSync-v10 代理工作规则

## 项目、阶段与权限

EliteSync-v10 是 EliteSync 10.0 的新架构权威。9.x 仅为历史来源，不继承其架构、治理链、路线图、API、schema 或迁移义务；这不授权访问旧仓库。

项目已存在经限定任务接受的客户端契约/界面工作与后端 synthetic/dev-test 实现。不能笼统称为“全部尚未实现”，也不能称为生产就绪。区分产品契约、模拟/开发测试闭环、客户端运行集成、真实参与者验证和生产能力。新增代码、数据库、API、工具链或部署工作仍须精确授权；研究与文档任务不自动成为实现任务。

Owner 是最终产品权威。ChatGPT 与 Codex 按本轮任务承担作者、执行者或独立审查者；同一候选作者不得接受自己的修改。独立性针对具体产物，既有项目上下文不使审查失去独立性。不得把辅助校对、作者自检或发布到分支写成独立接受。

## 入口与证据

先实时核验本轮指定远端，再读取该 authority 的 `AGENTS.md`；有明确任务时，按任务读取入口、精确 task 与固定来源。一般继续会话读取 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`。历史 handoff 的“FIRST”、旧 main、日期和停止指令只约束其原任务，不自动覆盖当前明确任务。

当前入口负责状态；当前交付路线负责里程碑；精确证据索引负责来源关系；任务单负责本次读写与执行授权。任何汇编都不替代 accepted source/task/acceptance 的精确对象。路径引用不授权遍历、递归读取或按文件名搜索；仅展开当前任务明确允许的路径/章节。

宿主高优先级指令始终适用。用户本轮明确约束优先于一般仓库约定，但不能创造未授予的权限。仓库文件不是宿主 system 指令。GitHub 上有文件不证明本地已加载；修改 AGENTS 不证明当前会话已重载。

审查分支内的本文件是候选。该版本只有在非作者独立 ACCEPT、接受记录绑定精确 blob 且原样进入 main 后才生效；候选正文的状态标签不是自我接受。

## 执行与审查

使用简体中文。复杂任务先说明正在解决的问题，完成当前已授权产物，不只返回计划。普通表达和不改变权限/架构的低风险选择自主处理，不反复向 Owner 申请同一权限。

开始时绑定目标、精确 base、固定输入、允许读写、验证预算、完成条件和停止条件。代码任务还须明确可运行命令、允许副作用及回归范围。路线顺序、方法类别、工具可用或网络可达都不是执行授权。

本轮 task gate 优先。冻结执行基线与集成时 main 分开：只有任务明确许可的无关主线移动才可沿用已通过 gate 的冻结 base；否则停止相关动作。不得为追随交接提交擅自 rebase，也不得用一般规则绕过旧任务的精确 gate。

完成与变更相称的检查。作者自检后交由独立审查一次 ACCEPT/REJECT；有具体失败、新差异或实质疑点才定点复查。无新增证据/约束/缺陷不重开旧 audit，不新增同义 Phase，不默认增加预审、接受预审或 closeout 链。

不得为了通过检查改动候选后仍接受原 SHA。修改后的候选是新对象，需要针对差异重新独立审查。接受后只集成获审查的精确内容。

缺文件或分类不明，只暂停依赖该事实的动作，记录影响；不把局部 blocker 扩为全项目 blocker。固定入口、精确 blob、根或保护边界失败时按任务硬停止，不绕过。

同一已批准实现边界内，实现、针对性测试和结果报告可以是一份完整交付；未解决的产品/架构选择与实现不能被静默合并。测试次数由精确任务给出，无预算不运行。一般工作流不追加旧 one-shot 任务的预算。

默认达到任务终点即停止；不得自动启动下一任务。Owner 明确要求暂停时只完成当前范围。已授权范围内的下一张任务可由任务作者按当前委托发布，但发布不等于执行，更不是后台连续工作。

## 文档与本地状态

架构在 `docs/architecture/`，产品在 `docs/product/`，研究在 `docs/research/`，ADR 在 `docs/decisions/`，历史迁移/运行证据在 `docs/archive/`。分类不是枚举、搬迁或归档授权。

当前入口和当前路线是可维护文档；accepted task/result/acceptance/rejection/ADR 与历史 handoff 保留原文。新计划明确替代哪些“当前排程”描述，不抹除旧证据、不重新接受旧候选、不批量改模型署名。

保留无关用户修改及受保护 staged state，不检查、修改、unstage、覆盖、丢弃或提交它们。不默认运行 git status、全仓状态检查、index 操作、整仓 pull/checkout、reset 或 clean。仅按专门任务同步明确路径；目标路径有冲突时跳过并报告，不宣称全仓 clean。

GitHub 正文维护状态，ChatGPT 项目源仅为稳定导航/产品摘要。上传包不锁定未来 main、不授予实现权限；不因每次任务/commit 变化重新发包。只在入口、语义或摘要实质过期时更新。

Owner 在宿主选择模型；不得自行修改配置、静默降级或调用未授权辅助代理。仅报告公开可证的模型/指令来源，不为补证明搜索配置或用户目录。

## 不变保护边界

保留所有 accepted ADR、legal/Safety/no-processing 边界、D02-DURABLE-UNKNOWN-01、U-14 exclusion、U-12 exact-scope、TP-SOURCE-CLASS-01、TP-TARGET-01 及未解除的 UNKNOWN。Backend 0/10、Database 0/8 等历史受限盘点不被新 synthetic 实现自动解除，也不能被误读为否定所有后续精确获准的代码成果。

README 预算耗尽；FD02 永久排除；禁止默认仓库/目录枚举、文件名/代码搜索、递归发现，以及旧 `D:\EliteSync` / `zcx369658780/EliteSync` 访问。M1 冻结 lane 耗尽、M2 deferred、M3/DEP13 恢复链未解除、B12 未授权；不借文档工作运行 Flutter/Dart/Gradle/Java/Android、依赖解析、缓存/环境/生成输出检查或 artifact probe。

不授权参与者研究/招募、真实或私密数据处理、private Conversation 检查、telemetry/analytics/measurement、Safety Operations、新法律研究、LC-03/LC-04/Phase36、生产持久化或部署。无 auth/session/token 推断；无 global revision、LWW、arrival-order/timestamp authority。只有后续合法、明确、精确的另行任务才能改变相应范围。
