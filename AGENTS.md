# EliteSync-v10 项目启动指导

生效：2026-10-14 Owner批准路线调整。此文件只保留现行项目指导；旧长篇启动历史已由[调整前AGENTS固定版本](https://github.com/zcx369658780/EliteSync-v10/blob/db1300bb19182f2de46b4ff5b1f7d9b947907b69/AGENTS.md)完整保留，不每次注入或全量重读。

## 当前目标与入口

v10.0核心只有两项：**复现可实际使用的EliteSync APP（前端、后端、数据库及选定原版主要功能恢复）＋可用的独立Web管理面板**。其它新增产品扩展及公开运营准备后置；不再以长期synthetic演示或新架构设计替代恢复。

先读[动态目录](DOC_INDEX_CURRENT.md)、[当前状态](CURRENT_STATE.md)、[现行工作流](docs/workflow/CURRENT_WORKFLOW.md)、[路线图](docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)及本版必要的[恢复台账](docs/architecture/RESTORATION_CAPABILITY_MATRIX.md)。Owner方向决定见[PRODUCT_DECISIONS](PRODUCT_DECISIONS.md)，记忆入口见[导航](docs/memory/navigation.md)。历史Sources/旧CURRENT、TASK_CURRENT和旧Work指令不覆盖现行入口；冻结版仍按其固定原计划验收。

## 执行方式

Owner保留方向/风险取舍；Astra规划、最终独立验收、复盘；Codex在手动派发的冻结版本内自主调查、实现、测试、修复。旧Work/dot不实时管理。一个功能版本可跨前端、后端、数据库、管理面板和测试，不默认限制一个源文件；只在真实范围/权限取舍处集中提问。

原版有效功能不得仅因旧MVP标Later而省略。读取具名旧资产和现有LOCAL_ONLY为恢复服务，不能无限考古、覆盖原件或擅自认可旧未验收实现。用户/管理员操作须最终贯通真实开发服务和持久化数据库；测试数据可以虚构，软件链不能只用mock代替。

具体开发环境、数据副本、构建/设备操作在正式版本一次授权；本次文档同步不启动服务、数据库、构建或v10.0.6开发。生产覆盖、敏感外传、密钥、真实费用和不可逆操作仍须具体授权。不全局删除鉴权或私信保护，不复活旧V57/H1/H2/D0任务链；必要恢复权限由新版本明确，不拿旧流程预算阻断新任务。

保持原dirty根和未提交成果，后续可安全接续专用clean基线，不强制每轮新建worktree或重验全部历史。历史冻结计划、接受/拒绝和原始失败不重写；退出码与stdout共同核验。网页不假设可读C:/D:/QMD或Basic Memory。无权限如实报告，不绕过工具限制。

## 审阅材料临时交付（2026-10-16 Owner补充）

Codex需要向Astra交付本地脚本、测试与原始退出证明时，按[短期脱敏审阅与清理协议](docs/workflow/TEMP_REVIEW_EVIDENCE_PROTOCOL.md)执行。GitHub无法读取本地未跟踪目录；允许仅将**公开安全的最小审阅副本**提交到独立临时审阅分支，Astra审阅后组织精确清理，**不合main或产品分支**。真实设备/家庭网络/凭据/语音及其它敏感证据保持LOCAL_ONLY；已推送的Git对象不能保证随分支删除而彻底消失。不改变冻结计划、Owner的系统操作权限和版本验收门。

## Owner任务下达闭环（2026-10-25）
## 默认长任务模式（Owner确认，2026-10-25）

EliteSync v10.x以一份冻结计划、一份综合长任务、一次集中候选与独立验收为默认。Codex在已授权范围内自主调查、实现、构建、测试、调试和修复普通失败；不为每个普通步骤或范围内返修重新派单/等待Owner。只有方向性决策、超范围、真实用户/生产数据、敏感外传、真实费用、系统/全局安全设置、供应商/实人操作或不可逆风险才暂停请求Owner。真实策略拒绝须记录并在既有授权内选择已批准的合法方式；不得隐瞒、伪造结果、修改策略或规避限制。A-D闭环是任务发布质量保证，不是逐步监督流程；最终由Astra集中验收。


发布任何Codex正式任务必须遵循[Task Dispatch Closure Protocol](docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md)的A-D阶段：先核对明确授权、原任务、当前状态、live main/Root、禁止事项与预算；创建唯一任务文件并读取核验Blob/正文；更新ACTIVE_STATE并重新回读main、Root、任务与状态；最终同一条回复交付任务链接、Blob SHA、状态/停止门禁和单一可复制启动Prompt代码框。

没有任务创建成功及正文读回，不得声称任务已下达；状态更新或最终回读失败必须报告部分完成，不静默结束、不盲目重复创建。Owner仍手动派发Codex；发布不代表执行，启动Prompt不扩大正式任务授权。不得自动运行Codex、创建后继任务、合并产品或越级放行下一Gate。