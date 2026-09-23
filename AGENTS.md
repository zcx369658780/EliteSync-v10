# EliteSync-v10 本地工作约定

## 入口与角色

本地仓库是实时项目状态来源。新会话先读 `CURRENT.md`，再按需读 `PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md` 和对应源码/证据。历史架构文档仍是来源记录，不能因新入口而改写其接受结论。当前本地 main 与远端若不同，应分别标明；不自动 pull、reset、覆盖工作区或把未合入候选写成已接受。

GPT Work 负责产品规划、任务发布、轻量或高风险审查、状态和文档维护、跨端协调。Codex 负责在 `TASK_CURRENT.md` 或 Owner 明确任务范围内实现、测试、构建与保存本地证据。Owner 保留产品方向、敏感数据、安全/隐私、不可逆数据库和生产发布等重大决策。等级与停止条件见 `REVIEW_GATE.md`；已发布旧任务的精确预算和禁止项继续有效，不由新工作流追认或重置。

LEVEL 0 可自检接受；LEVEL 1 经 Work 轻量审查；LEVEL 2 需独立 Work 审查；LEVEL 3 需 Owner 或明确的 Work 高风险门，其中生产、真实数据和不可逆操作仍须具体授权。默认不以 GitHub 作为日常任务总线；备份、里程碑和发布时才同步，且每次同步须有明确范围。网络或 GitHub 账号问题不阻断已授权的纯本地开发。

## 证据与执行

区分产品决策、任务授权、候选、接受、进入本地 main、运行证明、真实用户与生产就绪。一个任务保留一个主要结果，测试与构建回执引用它即可。没有实际 build、签名和部署证据不得称 APK/release ready；仅有 skeleton、contract、mock 不得称 production backend ready。文档迁移不改变产品代码或权限。

保留无关的 staged、modified、untracked 文件；不为同步而 reset、clean、stash 或覆盖。缺少固定来源或路径冲突时只暂停受影响动作。旧 `D:\EliteSync` 仓库仍不得默认访问；真实/私密数据、生产 API/DB/部署、Safety Operations 等仍需独立明确授权。

历史 accepted ADR、legal/Safety/no-processing、UNKNOWN、README 已耗预算、FD02 排除以及未解除的工具链限制继续有效。Synthetic/dev 演示不建立真实身份、Connection 或 Conversation authority。产品/架构语义不得借 LEVEL 0/1 降级；新任务若触及 auth、writer、consent、数据模型、隐私或发布链，按高风险等级处理。
