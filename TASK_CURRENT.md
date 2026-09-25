# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-66-DB-ENGINE-CONSISTENCY-PROBE-PREFLIGHT`

Risk Level: `LEVEL 2`（真实完整备份一致性前的本机只读探针预检；Work 独立审查）

Status: `ACCEPTED — CLOSED`（Work LEVEL 2；仅本机引擎元数据探针预检，见 `EVIDENCE/AUTH-66-DB-ENGINE-CONSISTENCY-PROBE-PREFLIGHT/summary.md`）

Assignee: `Codex`。只交付固定 PHP 元数据探针、纯虚构测试与脱敏回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-65 当次部署目录 CLI 连接可见 43 张基表、0 视图，但当前连接可能看不到全部对象；各表存储引擎、事务快照适用性和备份期间写入/DDL 边界仍 `UNKNOWN`。AUTH-49 要求真实完整备份的一致性方法先被核验。本任务只在本机预检一个固定聚合元数据探针，为后续另立单次只读现场任务准备；不运行真实 Laravel/DB，不给出备份一致性 PASS。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区、任务 ID/状态/派发；读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本文件、`REVIEW_GATE.md`、本地 workflow 技能及 AUTH-20/49/64/65 验收。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`；不匹配即停。
- 只允许新增 `EVIDENCE/AUTH-66-DB-ENGINE-CONSISTENCY-PROBE-PREFLIGHT/probe.php`、`test_probe.php`、`summary.md`。不得修改历史探针、产品源码、配置或控制文件。固定字面只读查询仅访问当前 Laravel 配置连接的 `information_schema.tables` 和服务器/库身份元数据，不接收请求参数、动态 SQL、对象名或任意连接名；不读取业务行。
- 聚合当前数据库中可见 `BASE TABLE` 的引擎分布：总基表数、`InnoDB` 数、明确非 `InnoDB` 数、`ENGINE IS NULL` 数；可另列视图数但不得混入基表。与 AUTH-20 同算法输出目标指纹，严格白名单、非负有界整数、分项等于总数、固定版本/家族检查，异常只返回安全错误类别。若权限可隐藏对象，即使聚合成功，`scope_completeness=UNKNOWN`；即使全部可见表为 InnoDB，`backup_consistency=UNKNOWN`，不得宣布可直接使用 `--single-transaction` 完成全库备份。
- 固定查询数与每次聚合输出上限，不枚举或输出原始表名、引擎名（除固定分组标签）、主机/库名、连接串、SQL、异常或业务行。必须说明聚合不能证明权限完整、Web worker 同库、并发 DDL/写入安全或 dump/restore 成功。若 MariaDB `information_schema` 语义不支持可靠分组，明确 `UNKNOWN` 并停止，不伪造通过。
- 纯虚构 targeted 测试最多 2 次，覆盖全 InnoDB、混合引擎、NULL 引擎、空库、视图分离、总数不一致、缺失/额外键、负数/溢出/超限、版本/driver 错误和异常脱敏；不得连接服务器或真实 DB。PHP 语法检查各文件最多 1 次；`git diff --check` 最多 1 次，新文件另查尾随空白。回执写明查询、限额、测试结果、哈希和仍未解决的一致性门。

## Stop and review

不得 SSH、CloudShell、云 API、Docker、真实 DB、备份/密钥目录内容、U 盘、Owner 密码、账号/Token/消息/媒体或旧 `D:\EliteSync`；不得执行真实探针、dump、备份、传输、恢复、删除、DDL/DML 或部署。Codex 不提交、制作 bundle、推送、自接受或派发后继。候选停在 Work LEVEL 2 独立审查门。
