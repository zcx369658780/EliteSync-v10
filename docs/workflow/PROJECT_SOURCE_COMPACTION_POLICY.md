# Project Sources瘦身与按需读取规则

生效：2026-11-01。适用于ChatGPT Project Sources及本仓库的长期同步。

2026-11-12按 [AGENTS](../../AGENTS.md)、[CURRENT_WORKFLOW](CURRENT_WORKFLOW.md)和Owner最新继续及工作流迁移指令收尾。当前工程入口见 [ACTIVE_STATE](ACTIVE_STATE.md)。

## 1. 权威分层

1. 工程身份从实际本地根、remote、当前授权分支、HEAD、工作区/index核实；当前进度由本地`docs/workflow/ACTIVE_STATE.md`顶部有效入口及具名源码/运行证据承载。运行资源须区分历史快照和当前实查。
2. Owner决定目标与权限，顾问提供计划和路线，Codex承担工程执行与工程验收。AGENTS和CURRENT_WORKFLOW承载现行规则，Session Handoff提供恢复导航。
3. GitHub记录已同步提交，main按需要核对。开发分支、验收分支、固定材料快照、Project附件和账户Memory分别保留身份与同步状态。项目源较旧时，以实际工程及最新Owner决定核验后补齐摘要，保护本地最新进度。
4. 冻结plan、Owner决定、历史正式任务、Astra验收和Codex运行回执各自保留原始身份；摘要不得覆盖原件。`CODEX_REPORTED`、`LOCAL_ONLY`、`NOT_RUN`、`UNKNOWN`、`PENDING`继续保留实际含义，工程检查、外部独立复核、Owner接受和发布分别记录。

## 2. Project Sources保留内容

只保留有长期复用价值的短索引、注明身份和日期的当前状态快照、稳定治理边界、Owner决定/路线摘要、必要设计参考、研究摘要、交接规则和历史导航。大型研究、旧handoff、旧状态、旧任务及可公开证据保留具名原路径或历史提交；完整私有运行原证由Owner本机保管。

Project Sources是按需参考库，不是每次会话的阅读清单。不得把完整ACTIVE_STATE、TASK_CURRENT、CURRENT、全量日志或整仓清单复制进Project Sources。相同正文不得用多个文件名重复装入。

## 3. 新会话首读与按需补读

先核实际本地Git身份和工作区/index，再读该工程`AGENTS.md`、`ACTIVE_STATE.md`顶部有效入口与`CURRENT_WORKFLOW.md`。依据当前目标按需补读一份最新具名交接及必要材料，随后推进已授权工作。GitHub按需核对，避免按Project Sources索引顺序全量读取。

只有目标明确后才补读：
- Owner明确引用的任务或专项合同，保留其适用范围和身份。
- 产品/技术决策：直接相关的Owner决定、原始合同、源码、测试和验收证据。
- 历史追溯：通过archive map定位具名原件，不递归加载所有历史。

证据复用须保留Tree/Blob、适用范围和失效条件；仅在源码、环境、合同或风险边界相关变化时增量重验。

## 4. Session Handoff与任务Prompt

Session Handoff使用 [SESSION_HANDOFF_TEMPLATE](SESSION_HANDOFF_TEMPLATE.md)六字段结构，目标300–600字，通常不超过1000字；记录实际本地身份、本轮变化、必要验证、未完成项、下一目标、必要路径/提交、Owner决定与适用停止条件。最新有效交接按目标读取，旧handoff保留历史身份。

启动Prompt给出实际本地根、当前授权分支、保存提交、当前目标和最小读取路径。普通工程沿Owner有效授权连续执行，顾问计划按需参考。[TASK_DISPATCH_CLOSURE_PROTOCOL](TASK_DISPATCH_CLOSURE_PROTOCOL.md)保留旧手动派发与A–D协议的历史原文。Owner保留事项、一次性额度、明确停止条件和独立审查要求仍按当前适用授权执行。

## 5. 历史封存与安全

保留历史事实、原始失败、冻结标准、验收判定及旧STOP/已耗记录。过期入口标注为历史；历史PENDING/NOT_RUN/授权状态仍是形成时的事实。资产管理遵循Owner具体决定，保护独有成果与必要私有资料，常规同步使用当前授权分支。

私密SQL、真实个人数据、密钥、设备原始日志、LOCAL_ONLY APK/数据库和未脱敏运行证据不得进入公开GitHub或Project Sources。

## 6. ZIP与附件同步

有意义节点更新ACTIVE_STATE单一当前入口和本次受影响规则，正常提交同步当前授权分支；失败记PENDING_SYNC。无新变化时沿用有效具名证据。完整替换包、全量哈希、独立镜像或多份CURRENT记录按实际交付需求安排。

Owner要求替换Project附件时，按指定范围制作日期化完整替换包，包含唯一文件集合、README/索引和必要SHA256 manifest。GitHub提交、ZIP生成、Owner手动替换Project附件和账户Memory更新分别报告各自实际状态。本轮仅完成规则文档迁移和当前状态记录。

项目源维护在Owner已授权目标内执行，普通文档同步沿用长期工程授权。产品源码、构建、设备、生产/真实数据、外部服务、费用、提权、main集成与发布等动作逐项受当前任务范围和Owner保留权限约束。
