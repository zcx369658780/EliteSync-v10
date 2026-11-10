# AUTH-66｜DB 存储引擎与备份一致性元数据探针本机预检

状态：**作者候选，待 Work LEVEL 2 独立 ACCEPT/REJECT**。执行前核对 `D:\EliteSync-v10` 本地 `main`、HEAD `b8d1b420091ffbd3486a5f0521e2c7b53510506b`；`TASK_CURRENT.md` 为 `AUTH-66-DB-ENGINE-CONSISTENCY-PROBE-PREFLIGHT`、`ISSUED — NOT STARTED`、派给 Codex、LEVEL 2。无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。本候选仅新增同目录 `probe.php`、`test_probe.php` 与本回执。

## 固定查询与输出

未来入口沿用当前 Laravel 配置连接的 write PDO，成功时运行**两条固定 SELECT**，失败提前停止；各最多返回**一行聚合结果**。第一条仅取 `VERSION()`、`DATABASE()`、`@@hostname`，原值只用于版本规范化及 `SHA-256(server_name + NUL + database_name)` 目标指纹，与 AUTH-20 算法一致。第二条仅访问当前库的 `information_schema.tables`，以固定条件聚合关系总数、`BASE TABLE`、`VIEW`，以及基表中的 `InnoDB`、明确非 `InnoDB`、`ENGINE IS NULL` 数。`UPPER(engine)` 将引擎名比较标准化；没有动态 SQL、请求参数、任意连接名、对象名枚举或业务行读取。它是固定条件聚合，不输出原始引擎名。

输出只含固定 `ok`、探针版本、MySQL/MariaDB 家族及规范化版本、目标指纹、五项非负整数计数，以及恒为 `UNKNOWN` 的 `scope_completeness` 和 `backup_consistency`。所有整数上限 **10,000**（含），视图与基表不得混计；关系总数须等于基表加视图，基表总数须等于三类引擎分项。版本、driver、字段键、整数格式和身份元数据严格检查。超限只返回 `COUNT_LIMIT_EXCEEDED`，畸形投影只返回 `INVALID_METADATA`，连接或查询异常只返回 `QUERY_OR_ADAPTER_ERROR`，引导失败只返回 `PROBE_ERROR`；不回显 SQL、异常、连接串、主机/库名或业务数据。固定查询数及每条一行输出限制不构成数据库内部扫描行数上限。

MariaDB `information_schema.tables` 的 `TABLE_TYPE` / `ENGINE` 条件聚合是本次待现场核验的元数据语义。若未来目标的语义、权限或投影无法可靠归类，结果应为 `UNKNOWN` 并停止，不能把条件聚合当作备份一致性通过。即使当前连接可见表全为 InnoDB，权限仍可能隐藏对象；聚合无法证明权限完整、CLI 与 Web worker 同库、并发 DDL/写入安全、事务快照覆盖所有数据，或 dump/restore 成功。不能据此宣布可直接以 `--single-transaction` 完成全库备份。

## 本机验证与文件身份

| 检查 | 作者结果 / 任务预算 |
|---|---|
| `php test_probe.php` | **1/2 次**，退出 0，**34/34 纯虚构检查 PASS**；覆盖全 InnoDB、混合、NULL、空库、视图区分、分项不一致、缺失/额外字段、负数/溢出/超限、错误版本/driver 和异常脱敏。没有运行真实探针。 |
| `php -l probe.php` | **1/1 次**，退出 0，无语法错误。 |
| `php -l test_probe.php` | **1/1 次**，退出 0，无语法错误。 |
| `git diff --check` | **1/1 次**，退出 0、无输出；不覆盖未跟踪新文件。 |
| 三个新文件尾随空白 | 另作只读检查，各 **0 行**。 |

SHA-256：`probe.php` = `5E0BCB9C4AE7EA2A90A23E12759BFE7804C090B5BA0E0B7E9B96D5844DA2DB9D`；`test_probe.php` = `56DB2EEF941DE9890678A2A9688DAB2EDB5BDDFDDEDF90331391F1F593718EA0`。本回执自身的最终哈希另作只读计算，避免自引用。

## 停点

本轮未 SSH、CloudShell、云 API、Docker、真实 Laravel/DB、备份/密钥目录、U 盘、密码、真实账号/Token/消息/媒体或旧 `D:\EliteSync`；未执行真实探针、dump、备份、传输、恢复、删除、DDL/DML 或部署。现场只读观察需另立有界任务并独立审查固定脚本哈希与连接/输出边界；真实 DB 身份、完整范围、备份一致性和恢复能力仍 `UNKNOWN`。不提交、不制作 bundle、不推送、不自接受或派发后继；停在 **Work LEVEL 2 独立审查门**。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT — 仅接受本机固定元数据探针预检。** Work 核对派发 HEAD `b8d1b420091ffbd3486a5f0521e2c7b53510506b`、三个允许的新文件、两条固定只读聚合 SELECT、白名单投影与脱敏错误；独立复跑纯虚构检查 **34/34 PASS（总预算 2/2）**。作者报告两份 PHP 语法检查各 1/1 PASS、`git diff --check` 1/1 PASS；Work 另查三个未跟踪文件尾随空白均为 0 行。审查前 SHA-256：`probe.php` 为 `5E0BCB9C4AE7EA2A90A23E12759BFE7804C090B5BA0E0B7E9B96D5844DA2DB9D`，`test_probe.php` 为 `56DB2EEF941DE9890678A2A9688DAB2EDB5BDDFDDEDF90331391F1F593718EA0`，本文件为 `1C06CF1D4EDA1E42D1055657A414661A2FA47E4D68FB43481DF251BBDE15D87A`。

本接受不授权现场运行。可见基表的引擎分布不能证明完整库范围、权限完整性或备份期间写入/DDL 一致性；`scope_completeness` 与 `backup_consistency` 仍为 `UNKNOWN`。后继现场读取须单独锁定文件哈希、SSH 预算和严格输出解析；真实备份、恢复和改库均未获授权。
