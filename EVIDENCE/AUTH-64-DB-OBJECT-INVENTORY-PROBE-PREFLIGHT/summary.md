# AUTH-64｜DB 对象清单元数据探针本地预检

状态：**作者候选；待 Work LEVEL 2 独立 ACCEPT/REJECT**。执行前位于 `D:\EliteSync-v10` 本地 `main`，HEAD `853c321397c1399fd40cc5d1d4e3061ae40115e1`；`TASK_CURRENT.md` 为 `AUTH-64-DB-OBJECT-INVENTORY-PROBE-PREFLIGHT`、`ISSUED — NOT STARTED`、派给 Codex、LEVEL 2。原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状。

仅新增本目录的 `probe.php`、`test_probe.php` 和本回执。已读取项目入口与 AUTH-19/20/49/63 的接受记录。探针尚未运行真实 Laravel、数据库或服务器；下述均为静态设计及纯虚构测试。

## 固定查询与输出边界

未来入口使用当前 Laravel 配置连接的 write PDO；成功路径执行以下 **8 条固定 SELECT**，失败时提前停止；每条最多返回 **1 行聚合结果**，不会返回对象名或业务表行。固定查询数不代表数据库内部扫描行数上限；单类计数上限为 **10,000**，超过时只返回 `OBJECT_LIMIT_EXCEEDED`。不接收请求参数、连接名、表名或 SQL 输入。

```sql
SELECT VERSION() AS version_text, DATABASE() AS database_name, @@hostname AS server_name
SELECT COUNT(*) AS total_count, COALESCE(SUM(table_type = 'BASE TABLE'), 0) AS base_count, COALESCE(SUM(table_type = 'VIEW'), 0) AS view_count FROM information_schema.tables WHERE table_schema = DATABASE()
SELECT COUNT(*) AS object_count FROM information_schema.columns WHERE table_schema = DATABASE()
SELECT COUNT(DISTINCT table_name, index_name) AS object_count FROM information_schema.statistics WHERE table_schema = DATABASE()
SELECT COUNT(*) AS total_count, COALESCE(SUM(constraint_type = 'PRIMARY KEY'), 0) AS primary_count, COALESCE(SUM(constraint_type = 'UNIQUE'), 0) AS unique_count, COALESCE(SUM(constraint_type = 'FOREIGN KEY'), 0) AS foreign_count, COALESCE(SUM(constraint_type = 'CHECK'), 0) AS check_count FROM information_schema.table_constraints WHERE table_schema = DATABASE()
SELECT COUNT(*) AS object_count FROM information_schema.triggers WHERE trigger_schema = DATABASE()
SELECT COUNT(*) AS object_count FROM information_schema.routines WHERE routine_schema = DATABASE()
SELECT COUNT(*) AS object_count FROM information_schema.events WHERE event_schema = DATABASE()
```

纯投影严格检查固定行键、MySQL/MariaDB 版本、非负整数、表/视图及约束分项与总数一致性，拒绝畸形、额外字段、未知类型与超限。成功 JSON 只含 `ok`、探针版本、DB 家族与规范化版本、`SHA-256(server_name + NUL + database_name)` 目标指纹、11 项整数计数，以及 `completeness=UNKNOWN`、`completeness_reason=PRIVILEGE_VISIBILITY_UNVERIFIED`。指纹算法与 AUTH-20 相同；本次未比较真实目标。这里的计数仅是当前连接**可见对象**的投影：`information_schema` 可能按权限隐藏对象，因而即使计数为 0，也不能认定该类对象不存在。查询或权限异常、非 MySQL driver、畸形投影、超限均只返回固定错误类别，无部分计数；异常内容不进入输出。不输出原始服务器/库/对象/账户名、连接串、SQL、业务行或原始元数据。不生成结构摘要。

## 本机验证与文件身份

| 检查 | 本次结果 / 预算 |
|---|---|
| `php test_probe.php` | **1/2 次**，退出码 0，**35 项纯虚构检查 PASS**。覆盖表与视图区分、AUTH-20 指纹稳定性、空库、计数上限、非 MySQL、查询/权限异常脱敏、缺失/额外字段、负数/溢出/畸形值、未知关系/约束类型和不一致投影。 |
| `php -l probe.php` | **1/1 次**，无语法错误。 |
| `php -l test_probe.php` | **1/1 次**，无语法错误。 |
| `git diff --check` | **1/1 次**，退出码 0、无输出；它不覆盖未跟踪新文件。三份新文件另做只读尾随空白检查，各 0 行。 |

SHA-256：`probe.php` = `ED8CB1CC5B3D3C4795595BE3F7E4B3B93589DBE7AAB4D66CDAB1323BB674FD4F`；`test_probe.php` = `6E95200EAE936C26FA46549ED75CA2EBAD3C8DBC4453AF08CE44230CA447B922`。本回执的最终 SHA-256 在写入后单独记录，不能自引用。

## 后继边界与停点

真实现场运行必须由**另一张**精确任务单授权：固定已审查脚本 SHA、部署目录与单次 SSH 预算；限定 CLI 使用的 Laravel 配置连接、元数据 SELECT 权限、严格单行 JSON 解析和错误停点。当前没有权限完整性证明，所有对象类别的完整性均为 `UNKNOWN`；真实完整对象/数据类别、业务行、库写入状态与备份一致性、CLI 与 Web worker 同库、实际 DB 身份、完整 dump 大小、备份/密钥/恢复能力仍 `UNKNOWN`。AUTH-20 的 43 条 `information_schema.tables` 不可解释为 43 张基表。

本轮未 SSH、CloudShell、云 API、Docker、真实 DB、备份/密钥目录内容、U 盘、Owner 密码、账号/Token/消息/媒体、旧 `D:\EliteSync`，也未运行真实探针、备份、传输、解密、恢复、删除或改库。不提交、不制作 bundle、不推送、不自接受或派发后继；停在 **Work LEVEL 2 独立审查门**。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT — 仅接受本地固定只读对象元数据探针预检。** Work 核对派发 HEAD `853c321397c1399fd40cc5d1d4e3061ae40115e1`、三个允许的新文件、八条固定聚合 SELECT、白名单投影及异常脱敏；独立复跑纯虚构测试 **35/35 PASS（总预算 2/2）**。作者报告两份 PHP 语法检查各 1/1 PASS、`git diff --check` 1/1 PASS；Work 对三个未跟踪文件另查尾随空白均为 0 行。审查前 SHA-256：`probe.php` 为 `ED8CB1CC5B3D3C4795595BE3F7E4B3B93589DBE7AAB4D66CDAB1323BB674FD4F`，`test_probe.php` 为 `6E95200EAE936C26FA46549ED75CA2EBAD3C8DBC4453AF08CE44230CA447B922`，本文件为 `821163F45BB9317779D1FB27030F16A3BE6A988F02D344B51127472AC955343E`。

此接受不授权现场运行。`information_schema` 可能只显示当前连接有权限看到的对象；查询成功和 0 计数也不能证明全库无对象。真实目标身份、完整数据类别、CLI 与 Web worker 同库、写入一致性、完整备份体量及可恢复性仍 `UNKNOWN`。现场只读观察须另立任务、锁定脚本 SHA 与单次 SSH 预算。
