# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-18-ALIYUN-DB-BACKUP-RESTORE-RUNBOOK-CANDIDATE`

Risk Level: `LEVEL 2`（未来真实数据库备份/恢复演练的实施前方案；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED`

Assignee: `Codex`。仅交付 docs-only 候选，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-14/16 仅证明部署目录当次 CLI 迁移账本与固定结构投影；AUTH-17 仅证明主机 `mysqldump` 版本 `10.11.14`、候选 `/var/backups` 目录可写测试与当次约 27,151,868 KiB 可用。数据库实例身份、服务端实际版本、数据量/分类、工具兼容、备份完整性和隔离恢复目标仍 `UNKNOWN`。Owner 要求未来若修改阿里云后端数据库结构，必须先备份并校验可恢复；仅允许现有管理员创建的测试账号信息受控本地导出供恢复，不上传到阿里云以外其他地方。完整备份的实际存放与保留期限正等待 Owner 决定；本任务不得替 Owner 决定或执行。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能和 AUTH-10/14/16/17 接受记录。只有本任务仍为 `ISSUED` 且派发匹配才执行。

目标：在唯一文档中形成**可审批的有界后继任务链**，明确下一次只读核对所需的目标 DB 身份、服务端 MySQL/MariaDB 版本、估算数据量与账号/关联数据分类的脱敏输出；提出在阿里云内的受控完整备份、加密/权限/空间检查、完整性校验、隔离恢复演练、账号恢复路径、失败即停、清理/保留与最终 migration 审查顺序。说明 Laravel CLI 连接与 Web worker 同库仍未证明，`mysqldump` 存在或 `test -w` 通过不能直接授权备份。若没有获确认的保留期限、加密方式、隔离恢复目标或数据范围，列为明确前置门，不补造事实。完整备份不得默认导出本地；Owner 所说的管理员创建测试账号本地导出须先有可证明的创建者与必要关联范围，否则不导出。

文档须给每一步一个可观测 PASS/FAIL 与停止条件，并将**备份、导出、恢复、迁移**分成不同受限动作；不得写可直接执行的带真实目标/凭据的命令，不得把方案接受写成真实 DB 操作授权。指出静态 Laravel 源码和当次 CLI 元数据证据的限度；保护账号、Token、消息、媒体等真实数据，不进入 Git、bundle、普通证据或阿里云以外位置。结构变更前必须有实际备份且隔离恢复校验通过；数据是否只含管理员测试账号仍 `UNKNOWN`。

## Scope, verification and stop

唯一允许新增 `EVIDENCE/AUTH-18-ALIYUN-DB-BACKUP-RESTORE-RUNBOOK-CANDIDATE/plan.md`。本地只读范围限控制文件、AUTH-10/14/16/17 接受证据、`services/backend-laravel/config/database.php` 的**源码键名**和必要的指定迁移文件；不做全仓泛搜。无需运行测试或构建；`git diff --check` 最多 **1 次**，新文档另作只读尾随空白检查。

不得 SSH、HTTP/API、读取 `.env`/私钥/凭据/日志/数据库行、访问设备或执行真实 DB/备份/导出/恢复/迁移命令；不修改源码或 schema。AUTH-17 的 SSH 预算不重置。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`；不访问旧 `D:\EliteSync`，不 pull/push GitHub。Codex 不自接受、提交、备份或派发后继；Work LEVEL 2 独立 ACCEPT/REJECT。实际备份、隔离恢复及改库须另立精确任务和 Owner 高风险门。
