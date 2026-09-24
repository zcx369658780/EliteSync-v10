# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-10-LOGIN-EVENT-PERSISTENCE-DB-BACKUP-DESIGN`

Risk Level: `LEVEL 2`（认证事件持久化及未来真实数据库备份/恢复设计；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED`

Assignee: `Codex`。仅交付 docs-only 设计与备份门候选，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-08 合同与 AUTH-09 隔离纯判定已获 Work 独立接受，但真实服务端成功交互登录事件、顺序、账户/设备绑定、持久化、15/30 天执行均未建立。Owner 最新明确授权：**若后续确需修改阿里云后端数据库结构，先备份数据库；允许将现有管理员创建的测试账号信息导出到本地用于结构变更后的恢复；不得上传到阿里云以外的其他地方。** 这是未来有界数据库任务的前置许可与约束，不表示已备份、不证明服务器只含测试账号，也不授权本任务执行备份、导出、迁移或恢复。敏感导出不得进入 Git、Git bundle、日志或普通证据。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能、AUTH-08/09 证据和 AUTH-07 静态来源图。只有本任务仍为 `ISSUED` 且派发匹配才执行。

目标：仅依据当前本地 Laravel `users`、`personal_access_tokens` 迁移、`User` 模型、`AuthController::login/refresh` 与数据库配置**源码键名**，评估可信 `T0` 是否需要新增持久化、可选的最小 schema 边界及为何 Token `created_at`/当前 `users` 字段不能直接成为受信登录事件。提出可审查的事件表/字段、唯一性与顺序、账户删除/撤权关联、refresh 不重锚、回退与旧数据兼容的**候选**，不得把本地迁移当部署 DB 事实。为未来真实改库列出顺序门：只读核对实际 DB 引擎/目标/表和迁移状态、确认数据范围、执行受限完整备份并校验可恢复性、保护本地导出、再评审精确 migration 和回退/账号恢复；失败即停，不以 Git bundle 替代数据库备份。对导出范围仅记录 Owner 所说的管理员创建测试账号，实际行内容/数量仍 UNKNOWN，不得假定其他表无关联数据。

## Scope and verification

唯一允许新增 `EVIDENCE/AUTH-10-LOGIN-EVENT-PERSISTENCE-DB-BACKUP-DESIGN/plan.md`。只读范围限上述精确源码/迁移、AUTH-07/08/09、CACHE-05 和必要的相邻本地认证 Feature 测试；可使用图谱和精确路径/符号搜索，不做全仓泛搜。文档分别标记已接受产品边界、本地静态事实、候选 schema、远端 UNKNOWN 和未来受限操作门。无需运行测试或构建；只运行一次 `git diff --check`，新文档另作尾随空白检查。

本任务**不连接服务器、不读真实数据库或 `.env`/凭据、不备份或导出账号、不修改 schema/代码/数据**；不使用 SSH、HTTP/API、设备或真实数据，不读取实际 Token、日志、用户/媒体内容。不访问旧 `D:\EliteSync`，不 pull/push GitHub。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。Codex 不自接受、不提交、不备份、不推送、不派发后继。Work LEVEL 2 独立 ACCEPT/REJECT；真实服务器/DB 任务须另立精确路径、对象、命令、预算与停止条件，并在任何结构变更前完成获授权备份与恢复校验。
