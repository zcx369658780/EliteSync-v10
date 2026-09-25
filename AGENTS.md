# EliteSync-v10 本地工作约定

## Codex 新任务入口

启动项目任务时，先确认工作目录为 `D:\EliteSync-v10`，读取本地 Git 分支、HEAD 与工作区状态；以本地文件、代码和证据判断当前状态，不以旧聊天或远端可达性作为启动门。先读 [CURRENT.md](CURRENT.md)，再按任务需要读 [PRODUCT_DECISIONS.md](PRODUCT_DECISIONS.md)、[TASK_CURRENT.md](TASK_CURRENT.md) 和 [REVIEW_GATE.md](REVIEW_GATE.md)。执行已下达任务时使用 [elitesync-local-workflow](.agents/skills/elitesync-local-workflow/SKILL.md)。

Codex 从 `TASK_CURRENT.md` 核对 Task ID、状态、风险级别、允许路径、验证预算与停点。只有状态为 `ISSUED`、明确交给 Codex 且当前派发与任务一致时才执行；预备、暂停、待审、已接受的任务不得自行启动。Codex 只交付候选和证据，停在相应验收门；任务发布、独立验收及后继任务由 Work 负责，Owner 权限不转移。保留无关工作区内容；不自行推送或提交 Git。

## 入口与角色

本地仓库是实时项目状态来源。新会话先读 `CURRENT.md`，再按需读 `PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md` 和对应源码/证据。历史架构文档仍是来源记录，不能因新入口而改写其接受结论。当前本地 main 与远端若不同，应分别标明；不自动 pull、reset、覆盖工作区或把未合入候选写成已接受。

GPT Work 负责产品规划、任务发布、轻量或高风险审查、状态和文档维护、跨端协调。Codex 负责在 `TASK_CURRENT.md` 或 Owner 明确任务范围内实现、测试、构建与保存本地证据。Owner 保留产品方向、敏感数据、安全/隐私、不可逆数据库和生产发布等重大决策。等级与停止条件见 `REVIEW_GATE.md`；已发布旧任务的精确预算和禁止项继续有效，不由新工作流追认或重置。

LEVEL 0 可自检接受；LEVEL 1 经 Work 轻量审查；LEVEL 2 需独立 Work 审查；LEVEL 3 需 Owner 或明确的 Work 高风险门，其中生产、真实数据和不可逆操作仍须具体授权。默认不以 GitHub 作为日常任务总线；备份、里程碑和发布时才同步，且每次同步须有明确范围。网络或 GitHub 账号问题不阻断已授权的纯本地开发。

## 本地任务循环与交接

Work 从 `CURRENT.md` 恢复状态，在 `TASK_CURRENT.md` 下达一个 bounded task；Codex 按任务实现、验证并保存 `EVIDENCE/<task-id>/`；Work 对照差异与证据作 ACCEPT/REJECT，接受后更新本地状态和 Git 检查点。没有待 Owner 决策项、未解决高风险门或任务停点时，Owner 已授权 Work 在验收后**自动下达下一张任务单**，不必逐轮询问；下达不等于执行，不放宽 LEVEL 2/3 门或旧任务预算。

当前 GPT 项目的 Work 会话对话记录超过 30 条，或上下文已长到影响可靠继续执行时，必须停止当前目标并交接。交接前先在本地项目文档保存本会话的任务进度、重点决策、未解决门和下一步，再给 Owner 一份可独立使用的交接 prompt；由 Owner 手动交接 GPT 项目的 Work 会话。交接本身不新建任务、不放行待审动作，也不重置任何一次性预算。

执行本项目任务时，先核对并选择最新的 Codex 执行会话；若已有完成交接的新会话，选择最新交接会话。只要所选会话未出错、对话记录未超过 30 条且上下文仍适合继续，就沿用该会话，不得为连续任务重复创建新会话。最新 Codex 会话超过 30 条对话记录或上下文已过长时，立即停止向其派发或继续执行，由 Work 指导交接；出现错误时也由 Work 判断是否需要交接。已明确要求停用的旧会话不得因其仍是最新会话而复用。Codex 会话交接不改变任务的独立预算、状态和 Work 验收门。

如当前所需项目文档只在 GitHub 端、且本地无法恢复，Owner 已授权 Work 让 Codex 协助做有范围的恢复。先记录缺失文档、可能的本地/缓存/备份来源和目标路径；恢复物须核对来源与内容，作为候选审查后才写入本地 authority。不得因恢复授权自动推送、覆盖本地已接受内容，或把远端可用性变成普通开发前置条件。

Work 可在上述强制阈值前自行选择交接时点。发生交接时，旧会话完成本地进度与决策记录后，只给 Owner 一份可独立使用的**交接 prompt**，不在同次交接额外下达任务单；prompt 指向本地 `CURRENT.md`、接受结论、未解决门与下一步。新会话完成交接并核对本地状态后，若没有 Owner 决策项或高风险停点，自动下达下一张任务单。若交接时已有有效任务单，只继续/审查该任务，不重复创建。

本地 Git 用于可回退检查点。代码备份另存于独立存储位置的完整 Git bundle，并校验 bundle 与定期演练恢复；控制面和必要证据随备份纳入。独立存储位置尚未指定时，记录为备份待办，不把同盘 Git 历史宣称为独立备份。远端同步仅在明确范围的备份、里程碑或协作任务中进行。

Owner 当前不保证随时在电脑旁。任何后续任务若可能触发 Windows UAC，Work/Codex 必须在触发前停下；仅在 Owner 于**当前 Work 会话**明确输入“我在”后，才可按该任务已通过的具体风险门继续现场步骤。旧会话或旧任务的到场确认不沿用。“我在”只确认到场，不替代具体任务授权、运行前复核或一次性预算；无回复时继续无需 UAC 的本地工作。

## 证据与执行

区分产品决策、任务授权、候选、接受、进入本地 main、运行证明、真实用户与生产就绪。一个任务保留一个主要结果，测试与构建回执引用它即可。没有实际 build、签名和部署证据不得称 APK/release ready；仅有 skeleton、contract、mock 不得称 production backend ready。文档迁移不改变产品代码或权限。

保留无关的 staged、modified、untracked 文件；不为同步而 reset、clean、stash 或覆盖。缺少固定来源或路径冲突时只暂停受影响动作。旧 `D:\EliteSync` 仓库仍不得默认访问；真实/私密数据、生产 API/DB/部署、Safety Operations 等仍需独立明确授权。

历史 accepted ADR、legal/Safety/no-processing、UNKNOWN、README 已耗预算、FD02 排除以及未解除的工具链限制继续有效。Synthetic/dev 演示不建立真实身份、Connection 或 Conversation authority。产品/架构语义不得借 LEVEL 0/1 降级；新任务若触及 auth、writer、consent、数据模型、隐私或发布链，按高风险等级处理。
