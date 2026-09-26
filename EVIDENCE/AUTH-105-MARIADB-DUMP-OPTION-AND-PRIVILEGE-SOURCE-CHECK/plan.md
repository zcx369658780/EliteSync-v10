# AUTH-105｜MariaDB dump 选项与权限官方来源静态核对

**作者候选，待 Work LEVEL 2 独立审查。** 2026-09-25；`D:\EliteSync-v10`、`main`、HEAD `bacb48fa8d49ab6f2a33fcc7c16b980fe2d1fc10`。`TASK_CURRENT.md` 为 `ISSUED — OFFICIAL-DOCS AND LOCAL STATIC CANDIDATE ONLY`；只写本新证据目录。检查前 `CURRENT.md`、`TASK_CURRENT.md` 已修改，两个既有无关未跟踪目录保留。本轮没有服务器或 DB 访问。

## 来源与版本限度

仅公开读取 MariaDB 官方文档的 Markdown 页面，访问日 **2026-09-25**：

- [MariaDB Server: mariadb-dump](https://mariadb.com/docs/server/clients-and-utilities/backup-restore-and-import-clients/mariadb-dump.md)（下称 D）：Usage、Options 中各精确选项小节。此为**当前在线文档**，部分选项有起始版本注记，整页不是固定的 10.11.14 快照。文档写明工具先前名为 `mysqldump`，11.0 起其同名链接被弃用并从 MariaDB Docker Official Image 移除；不据此推断目标主机今天的路径或二进制身份。
- [MariaDB Server: GRANT](https://mariadb.com/docs/server/reference/sql-statements/account-management-sql-statements/grant.md)（下称 G）：Database Privileges 和 Table Privileges 对 `SELECT`、`SHOW VIEW`、`TRIGGER`、`LOCK TABLES`、`EVENT` 的说明；`SHOW CREATE ROUTINE` 标为 **11.3.0 起**，不能用来填补 10.11 的权限证明。

本地已接受证据边界：AUTH-17 **当次**目标主机 `mysqldump --version` 报 `10.11.14`，不证明现时工具/选项；AUTH-20/65/67 只见部署 CLI 当前权限下的聚合元数据；AUTH-68/102～104 是范围、身份与权限静态门，尚未证明整库对象、备份账号或 Web 同库。AUTH-49 要求真实备份在服务器侧形成获批认证密文后才进入网络、失败产物不可用，并经本机隔离恢复。AUTH-101 的虚构 CMS 往返不证明真实服务器加密链。

## 不可直接运行的参数模板

本模板只有待裁决字段，**不是 shell 命令或运行授权**：

| 字段 | 候选选择 | 必须后继锁定的内容 |
| --- | --- | --- |
| 工具 | `mariadb-dump` 语义；现场实际可执行文件可能名为 `mysqldump`。 | 精确文件身份/哈希、`--version` 与该文件的 `--help` 选项集；当前均 UNKNOWN。 |
| 目标 | 仅一个经确认的数据库；候选使用 `--databases` 且只给一个获批库，不加表名。 | 真实实例/库、账号、连接路径、全量对象边界和输出中的 `CREATE DATABASE`/`USE` 恢复影响。没有明文目标值写入本文件。 |
| 内容 | 评估显式 `--routines`、`--events`、`--triggers`；不得含 `--no-data`、`--no-create-info` 或 `--skip-triggers`。 | 权威对象全集、是否存在视图/例程/事件/触发器、10.11 工具实际行为、逐项权限和恢复结果。 |
| 一致性 | 仅在全部纳入表适用、DDL 边界获批时考虑 `--single-transaction` 与 `--quick`；不同时使用显式 `--lock-tables`。 | 全对象引擎与跨系统数据、写入/DDL 责任、快照建立和结束时点、Owner 对生产影响的决定。 |
| 输出 | 原始 dump 只允许由受审查流程在服务器进程内**直接交给获批的认证加密消费者**，随后仅密文进入网络；本文不给出管道、文件路径、密码参数或可复制执行命令。 | 服务器侧算法/证书与身份、分段/失败隔离、退出码传播、密文完整性、临时副本和本机隔离恢复。 |

不选择 `--all-databases`、`--force`、`--result-file`、`--log-error`、`--flush-logs`、复制坐标/全局锁选项，亦不以命令行密码参数传秘密。任何认证方式必须另经保护门；不得因 D 提到密码提示或 option file 就把真实秘密放在参数、环境、文件、日志或普通证据中。

## 选项、权限与失败语义矩阵

| 项 | 官方文档要点与精确来源 | 10.11 / 当前现场结论 |
| --- | --- | --- |
| 单库范围 | D「Usage」：指定 `db_name` 且不列单独表，或使用 `--databases db_name`，文档称导出整个指定数据库；`--databases` 会写 `CREATE DATABASE`/`USE`。 | 语法有官方依据；**完整对象和数据类别仍 UNKNOWN**，不由“entire”字样代替权限/范围验证。 |
| 表数据和结构 | D「`--no-data`」「`--no-create-info`」分别不写行数据/建表语句，因此候选排除。G「Table Privileges」说 `SELECT` 允许读表数据，可能按列授予。 | 拟备份账号对**每个权威基表的全部所需列**是否足够，UNKNOWN；不能只看 `SHOW GRANTS` 文本。 |
| 触发器 | D「`--triggers`」默认启用，可由 `--skip-triggers` 禁用。G「Table Privileges」将 `TRIGGER` 与 `SHOW CREATE TRIGGER` 关联。 | 对权威触发器全集和账号定义读取能力须实测；可见 0 不证明没有，UNKNOWN。 |
| 存储例程 | D「`--routines`」须显式包含过程/函数，**明确写需 `mysql.proc` 的 SELECT**，且重建不保留原创建/修改时间戳。G 的 `SHOW CREATE ROUTINE` 是 11.3 起，不能用于 10.11。 | 10.11 具体授权、例程全集及恢复元数据保真要求 UNKNOWN；不能为方便直接扩大系统库权限。 |
| 事件 | D「`--events`」显式包含事件。G 将 `EVENT` 描述为创建/删除/修改事件的权限，但 D 未在该选项小节明确列出 dump 所需权限。 | 候选账号需要何种读取权、权威事件全集、恢复权限均 **UNKNOWN**；不把 G 的描述猜成 dump PASS。 |
| 视图 | D 开头称视图不随一般导出自动重建，但同页「`--force`」例子讨论无效视图定义；未给出本方案可直接锁定的视图参数与 10.11 语义。G 将 `SHOW VIEW` 关联到 `SHOW CREATE VIEW`。 | **文档表述不足/待澄清**；若权威全集有视图，先用 10.11 官方/工具帮助和纯虚构恢复验证，不能声称候选已完整。 |
| `--single-transaction` | D 同名小节：启动事务；仅 InnoDB 等事务表可获一致快照；非事务引擎不保证；导出期间 `ALTER/CREATE/DROP/RENAME/TRUNCATE TABLE` 可能使结果错误或失败；与 `--lock-tables` 互斥，自动关闭后者；建议与 `--quick` 配合。 | AUTH-67 的 43 张**可见** InnoDB 不等于全对象；DDL/外部数据与实际快照方案 UNKNOWN。 |
| 默认 `--opt` / 锁表 | D「`--opt`」默认开启，含 `--lock-tables`、`--quick` 等；D「`--single-transaction`」会关掉 `--lock-tables`。G 说显式锁表需 `LOCK TABLES` 且表上有 `SELECT`。 | 必须在 10.11 实际 `--help` 中核对默认/选项顺序，避免意外锁表；账号是否需锁表权限取决于最终方案，UNKNOWN。 |
| 外部数据引擎 | D「`--no-data-med`」称对若干管理外部数据的引擎**默认不导出行**，需显式关闭该选项才可考虑行数据。 | AUTH-67 只覆盖可见表；是否有隐藏/外部引擎及如何备份其外部内容均 UNKNOWN。 |
| 错误/输出 | D「`--force`」会在 SQL 错误后继续，且可能把无效视图定义作为注释写入；候选排除。D「`--result-file`」即使导出错误也会创建并覆盖目标；候选排除。D「`--log-error`」将警告/错误追加文件；候选排除。D 未给本任务可锁定的数字退出码表。 | 非零、超时、流中断、下游加密失败一律停并隔离部分产物；**精确数字退出码 UNKNOWN**，不得仅因输出文件存在或工具退出 0 声称完整。 |

## 后继门与回执

最小下一步是**另发只读工具/账号预检任务**：先固定服务器身份、精确工具文件与版本、只读 `--help` 选项集和 MariaDB 10.11 适用文档；再固定权威对象全集与拟备份账号，在获授权受控进程内只读核对逐项权限。任务须明确允许的单次调用/连接/查询次数、超时、输出上限、严格脱敏白名单与错误类别，任何不匹配即停；不得复用 AUTH-17 或其他已耗预算。权限确认后还须独立的纯虚构全链演练验证结构、视图/例程/事件/触发器、失败即停、服务器侧认证密文、部分产物隔离及恢复。真实库现场 dump 仍需固定身份/范围、一致性、加密传输和本机隔离恢复准备，另获 Owner LEVEL 3 单次明确授权。

| 结论层级 | 当前结果 |
| --- | --- |
| 官方文档通用选项语义 | PASS，仅上表有明确来源的文字；当前页并非固定 10.11.14 快照。 |
| 10.11.14 目标主机现时工具身份、支持选项、默认值 | UNKNOWN；AUTH-17 只是旧一次版本字符串。 |
| 拟备份账号权限、权威全库对象、Web/CLI 同库 | UNKNOWN。 |
| 真实 dump、认证加密传输、完整性、隔离恢复 | NOT RUN / UNKNOWN。 |

本轮只访问上述公开 MariaDB 官方文档和本地授权文件；没有读取 `.env`、凭据、密钥、业务行或真实备份。未连接阿里云服务器、真实 DB、云 API，也未运行 SSH、生产 HTTP、Laravel CLI、Docker、OpenSSL、UAC、dump、备份、导出、传输、恢复、部署、停写、DDL/DML 或删除。仅新增本计划，不提交、推送、自接受或派发后继，停在 Work LEVEL 2 门。

## Work LEVEL 2 独立审查（2026-09-26）

**ACCEPT 仅官方资料静态核对与不可运行参数候选。** Work 独立重读 MariaDB 官方 `mariadb-dump` 与 `GRANT` Markdown 页面，核对 `--single-transaction` 对事务表/DDL 的限制、与 `--lock-tables` 的互斥，`--routines` 的 `mysql.proc` SELECT 说明、`--no-data-med` 默认行为，以及 `SHOW CREATE ROUTINE` 自 11.3.0 起的版本注记。候选对视图的官方说明不足处保持 UNKNOWN，没有把当前在线文档当作固定 10.11.14 快照，也没有把 AUTH-17 的旧工具版本观察当作当前服务器能力。

本文未提供可执行命令，未锁定账号、权限、对象全集或一致性时窗；因此不授权 dump、服务器连接、加密流或传输。`--databases`、例程/事件/触发器和权限矩阵仍需目标主机工具帮助、最终版本及纯虚构恢复验证后才能形成运行候选。Work 检查本任务只新增 plan.md；既有两个无关未跟踪目录保留，`git diff --check` 通过。真实备份依然需要各独立门与 Owner LEVEL 3 单次授权。
