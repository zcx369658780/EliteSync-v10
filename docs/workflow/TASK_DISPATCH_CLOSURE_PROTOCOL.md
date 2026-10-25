# Task Dispatch Closure Protocol｜任务下达闭环

生效日期：2026-10-25。适用于 EliteSync-v10 及 Astra 作为长期 Product Advisor / Planner / Independent Reviewer / Orchestrator / Current-state Manager 时发布的 Codex 正式任务。

**核心原则：Owner手动派发；Astra在Owner授权明确时直接完成任务发布闭环；发布不等于派发，派发不等于执行；不得自动启动Codex或扩大授权。**

## 阶段 A｜确认授权与冻结范围

开始写任务前，先核对：

1. Owner是否已明确授权本次任务发布/修改范围。授权明确则直接执行，不重复询问已回答的问题；授权含糊或涉及新的高风险/不可逆行为时才提问。
2. 原正式任务、当前`ACTIVE_STATE.md`、相关Astra裁决、当前live `main`与Root Tree、候选分支HEAD及对应Blob/Tree。
3. 本次可做与禁止事项、已消费/未消费预算、必须停止的门禁、产品Tree与受保护资产。
4. 本次是原任务续接、局部修复、测试放行还是新任务。不得借任务发布重新规划、重复已完成诊断或隐式创建后继任务。

形成一份内部冻结范围摘要：目标、输入基线、允许改动、禁止改动、验收证据、预算、成功/阻断终态。

## 阶段 B｜创建唯一正式任务单

1. 在权威仓库`zcx369658780/EliteSync-v10`的`main`创建唯一任务文件，使用描述性、不可歧义的路径；除非任务明确需要，不另建重复任务、issue、分支或人工prompt-result中转链。
2. 写入范围、输入身份、允许/禁止路径、命令/测试边界、预算、验收要求、证据/Hash要求、STOP条件、成功/阻断终态和Owner手动派发要求。
3. 取得工具返回的Blob SHA后，立即按路径读取文件正文；核对Blob、正文、任务目标、预算和禁止事项一致。**创建调用成功但没有读回核验，不算任务单发布完成。**
4. 任何创建或读回失败都明确报告失败/部分完成，不得声称任务已下达；不使用猜测的SHA或链接。

## 阶段 C｜更新状态并验证

1. 更新`docs/workflow/ACTIVE_STATE.md`，记录任务链接、准确Blob SHA、当前状态、授权边界和下一停止点；保留历史记录，不把旧快照重写成当前事实。
2. 按顺序重新读取live `main`、Root Tree、正式任务正文/Blob、`ACTIVE_STATE.md`/Blob；必要时读取候选和产品Tree，确认产品源码没有非授权变化。
3. 任务创建和状态更新可能各自推进`main`。最终回复必须使用**最后一次回读**的HEAD/Root/Blob，不能把写入前快照标为最终当前状态。
4. 对每个关键步骤保留成功回执。若任务单已创建但状态更新失败，应明确标记`TASK_CREATED_STATE_SYNC_INCOMPLETE`；若状态更新完成但回读失败，应标记`PUBLISHED_READBACK_UNVERIFIED`。说明已完成与未完成部分，不静默结束、不盲目重复写入。
5. 不因状态同步而改产品源码、清理历史refs/分支、重置预算或启动任务。

## 阶段 D｜一次性交付给 Owner

同一条最终回复必须包含：

1. 正式任务单标题、可验证GitHub链接、Blob SHA。
2. 一份**单一可复制Markdown代码框**中的启动Prompt；不加“PROMPT开始/结束”包装，不在启动Prompt内部嵌套反引号代码框。Prompt明确要求Codex先读正式任务单全文及实时状态，再执行冻结范围。
3. 最终回读的live `main` Commit、Root Tree、`ACTIVE_STATE.md` Blob和正式任务Blob。
4. 当前状态、产品Tree是否保持、关键禁止事项与停止门禁。
5. 明确说明任务只是`PUBLISHED / OWNER_MANUAL_DISPATCH_REQUIRED`，除非Owner另有明确指示，不声称Codex已派发或执行。

如果最终回复无法完整交付以上项目，先说明具体部分完成状态；不能用长篇分析替代任务链接与启动Prompt。

## 启动Prompt标准模板

给Codex的Prompt应短于正式任务单且不得放宽它：

- 指向任务实际路径与Blob SHA。
- 要求fresh读取live main、Root Tree、ACTIVE_STATE、正式任务全文和相关固定证据；SHA变化时按当前事实重核，不盲目套用历史值。
- 仅执行任务单明示范围；正式任务单是权威合同，Prompt只是启动入口。
- 重申预算、禁止事项、STOP条件、成功/阻断终态、证据发布与远端回读。
- 交付后停止等待Astra独立验收；不得自动派发后继任务、自动合并产品或越级进入下一Gate。

## 失败处理与部分完成

| 失败点 | 必须报告的状态 | 不允许的行为 |
| --- | --- | --- |
| Owner授权不明确 | `WAITING_FOR_OWNER_CLARIFICATION` | 猜测授权或先写高风险任务 |
| 正式任务创建失败 | `TASK_NOT_PUBLISHED` | 给出猜测链接/Blob |
| 任务创建成功但正文未回读 | `TASK_CREATED_READBACK_PENDING` | 声称已完整发布 |
| 状态入口更新失败 | `TASK_PUBLISHED_STATE_SYNC_INCOMPLETE` | 静默结束或反复创建重复任务 |
| 最终HEAD/Blob回读失败 | `PUBLISHED_READBACK_UNVERIFIED` | 把写入前SHA称为最终当前状态 |
| 任务已发布 | `PUBLISHED_OWNER_MANUAL_DISPATCH_REQUIRED` | 自动启动Codex或运行任何任务 |

## 项目源与长期记忆同步

当Owner要求工作流成为长期规则时：

- 更新本协议与`CURRENT_WORKFLOW.md`；在`AGENTS.md`添加简短权威指针；在`docs/memory/navigation.md`记录持久规则；更新`DOC_INDEX_CURRENT.md`及`docs/gpt-project-sources/PROJECT_SOURCE_INDEX_ELITESYNC_V10.md`。
- 项目源快照采用**新增日期化里程碑目录**或明确的增量包；不要静默覆盖历史快照。项目源ZIP必须来自已回读的固定GitHub正文，并提供文件清单、生成时间、SHA-256与可下载文件链接。
- GitHub文档、项目源附件和模型记忆不是同一个自动同步系统。项目源ZIP生成不等于ChatGPT Project Sources附件已自动替换；明确区分已更新、已打包与仍需Owner手动上传的步骤。
- 仅同步治理文档和安全的必要入口；不将LOCAL_ONLY、密钥、原始私密日志、运行环境快照或整个工作目录打包。

## 本次Owner确认

Owner于2026-10-25明确同意将A-D闭环落实到GitHub文档、项目长期记忆/导航与项目源，并生成更新ZIP。该规则为前瞻流程约定，不追溯改变已冻结任务的授权、预算或验收结果。