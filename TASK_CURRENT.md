# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-68-DB-BACKUP-CONSISTENCY-BOUNDARY-CONTRACT`

Risk Level: `LEVEL 2`（真实完整数据库备份前的一致性/范围合同；Work 独立审查，真实操作另设高风险门）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付一份 docs-only 候选合同，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-65/67 当次部署目录 Laravel CLI 连接可见 43 张基表、0 视图，其中 InnoDB 43、非 InnoDB 0、引擎 NULL 0；权限完整性、Web worker 同库、并发 DDL/写入的一致性仍 UNKNOWN。AUTH-49 要求完整备份范围和一致性先通过门。此任务结合已接受事实写出可执行前置条件与失败停点，不读取真实数据库、不进行备份、不把当前可见计数解释为全库证明。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区、任务 ID/状态/派发；读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本文件、`REVIEW_GATE.md`、本地 workflow 技能及 AUTH-20/25/49/64～67 验收。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 与 Work 独立测试生成的 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/__pycache__/`，不得移动、删除或纳入提交。状态或派发不匹配即停。
- 只允许新增 `EVIDENCE/AUTH-68-DB-BACKUP-CONSISTENCY-BOUNDARY-CONTRACT/contract.md`。不修改历史证据、控制文件、源码或配置。合同区分当前 CLI 可见元数据、真实实例身份、完整对象/数据类别、Web worker 同库、事务引擎覆盖、备份期间 DDL/写入、dump 选项/权限、密文形成时点及恢复核验；每一项写明可用事实、UNKNOWN、独立后继核验与失败停点。
- 对一致性路线提出有界可审查的候选：例如事务快照与受控写入窗口。须说明 MariaDB/InnoDB 事务快照不能独自证明权限可见性、并发 DDL 安全、外部文件/媒体范围或真实恢复。不得自行选择会改变生产写入行为的方案；需 Owner 决策处明确列出具体影响和选择。不要写出可直接运行的真实 dump/锁表/停写命令，避免文档被误当执行授权。
- 按最短顺序列出后继：只读核验权限/连接身份与业务数据类别、设计并验证一致性门、真实密码保护密钥与 U 盘恢复副本、虚构端到端容量/失败隔离、单次真实加密备份、解密校验和本机隔离真实恢复。每步都要有独立任务、预算、证据与风险门；当前文件不授权任何一步。
- 本轮仅文档检查：`git diff --check` 最多 1 次，新文件另做只读尾随空白检查。回执写清仅 docs-only、未运行的检查、Owner 待决点与不可外推结论。作者不提交、制作 bundle、推送、自接受或派发后继。

## Stop and review

不得 SSH、CloudShell、云 API、Docker、真实 DB、备份/密钥目录内容、U 盘、Owner 密码、账号/Token/消息/媒体或旧 `D:\EliteSync`；不得备份、传输、恢复、删除、DDL/DML、部署。停在 Work LEVEL 2 独立审查门。
