# EliteSync v10｜TASK_CURRENT

Task ID: `WF-CODEX-01`

Risk Level: `LEVEL 2 — 本地执行控制面`（只改 Codex 工作约定；不改产品/数据/生产权限）

Status: `ISSUED — 等待 Codex 执行与 Work 独立验收`

## Objective / Why now

把已接受的本地 Work → Codex 循环真正接入 **新启动的 Codex 项目任务**：启动即识别仓库根、本地控制面和当前任务状态；只执行明确已下达的任务；按任务交付最小证据；停在非作者验收门。Owner 要求先完成并验收这项流程固化，再恢复产品任务 `APP-INT-06-RECOVERY-BASELINE`。

## Allowed files / components

- 可修改仓库根 `AGENTS.md`：只增加简短、可执行的 Codex 入口与委托规则，指向现有 `CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md` 与本任务技能；不要复制这些文件的事实。
- 可新增 `.agents/skills/elitesync-local-workflow/SKILL.md`：按 Codex skill 格式写短的项目执行协议。必要时可有最小 `agents/openai.yaml`，但不要生成模板、脚本或新治理档案来凑结构。
- 可写 `EVIDENCE/WF-CODEX-01/summary.md`，记录文件差异、静态检查、实际可验证范围和新任务验证所需的检查点。
- `CURRENT.md` 与 `TASK_CURRENT.md` 由 Work 管理；Codex 只读，不改。其他 `.agents/skills/`、产品源码、测试、backend、DB、依赖、全局 `C:\Users\zcxve\.codex` 配置及远端均不在写入范围。

## Required behavior / acceptance criteria

1. 根 `AGENTS.md` 作为 Codex 自动发现入口，要求新项目任务先确认 `D:\EliteSync-v10` 与本地 Git 状态，按需读取四个控制文件；项目状态以本地文件/代码/证据为准，不能以远端可达性或旧聊天作为启动门。
2. Codex 从 `TASK_CURRENT.md` 读 Task ID、状态、风险、允许路径、测试预算和停点；仅在 `ISSUED` 且任务指向 Codex 执行时行动。`预备`、`暂停`、`待审`、`已接受` 状态不得自行开启产品工作。本任务自己的执行授权是本文件和 Work 派发，不授权 APP-INT-06。
3. Codex 交付候选差异、针对性验证与 `EVIDENCE/<task-id>/` 简短结果；准确区分未运行与 PASS、作者完成与 Work 接受、synthetic 与真实/生产。Codex 不自我验收、不自动创建后继、不推送、不覆盖无关工作区。
4. Work 的任务发布、独立验收、自动后继、Git bundle 备份、GitHub 文档恢复和仅交接 prompt 的权责仍以现有 `AGENTS.md` / `REVIEW_GATE.md` 为准；新技能只说明 Codex 如何消费任务和交付，不赋予它 Work 或 Owner 权限。
5. 新增 skill 的 frontmatter、触发描述与正文能够被新 Codex 任务发现/引用，且与已有 `elitesync-runtime-slice`、`elitesync-dirty-worktree` 不冲突。项目根 `AGENTS.md` 保持简短，控制面事实不产生第二份副本。

## Required checks / evidence

运行 `git diff --check`；核对准确变更路径、skill YAML frontmatter 与所有本地文件链接。记录实际检查命令和结果。不要运行 Flutter/PHP/Gradle/Android/DB 或网络任务。官方 Codex AGENTS.md 发现规则可参考 https://learn.chatgpt.com/docs/agent-configuration/agents-md ；它说明指令链在新运行启动时构建，因此本任务作者不能用当前运行声称新规则已重新加载。完成后由 Work 另起一个**只读的新 Codex 任务**核验指令入口，再决定 ACCEPT/REJECT。

## Stop conditions / forbidden expansion / review

若发现本地入口与已有高优先级/旧任务预算冲突、skill 无法以项目范围使用、需要修改全局配置或需要扩大写入路径，停止并报告具体冲突。不要执行 APP-INT-06、任何产品 feature、真实数据、生产动作或 GitHub 同步。候选完成后停下，由 Work 独立审查；只有 WF-CODEX-01 验收通过，Work 才恢复原 APP-INT-06 任务单（上一版可从本地提交 `2574d0ee94d66164499cc8ae77ea6c850a515074:TASK_CURRENT.md` 恢复）。
