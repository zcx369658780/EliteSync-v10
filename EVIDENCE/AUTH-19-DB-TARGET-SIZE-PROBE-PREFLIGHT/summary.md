# AUTH-19｜目标与规模元数据探针本地预检

状态：`BUILDER CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`、`main`，派发基线 HEAD `33989c928e66f5fd1683ab06811f41fd0037459e`。类型：本地 PHP 固定只读元数据探针候选与虚构 adapter 测试；本轮未启动真实 Laravel 入口或连接 DB。

## 候选与输出边界

仅新增三条允许路径：`target_probe.php`、`test_target_probe.php` 和本 `summary.md`，均位于 `EVIDENCE/AUTH-19-DB-TARGET-SIZE-PROBE-PREFLIGHT/`。探针提供可由虚构 adapter 注入的纯投影 `auth19_project_target()`。未来入口只在另行授权后从指定 Laravel 根以 PHP stdin 运行；没有请求输入、任意表名或连接名，不更换连接。

入口使用当前 Laravel DB connection 的固定字面 `SELECT`，且在同一次查询中获取 `VERSION()`、`DATABASE()`、`@@hostname` 以及 `information_schema.tables` 中 `table_schema = DATABASE()` 的 `COUNT(*)` 与 `COALESCE(SUM(data_length + index_length), 0)`。`selectOne(..., [], false)` 只在当前配置连接上使用 write PDO 执行这条只读 SELECT，以避免读副本造成不同目标；没有数据修改、业务表行查询、表名列表、账号数量、备份或迁移。`information_schema.tables` 的计数是该视图中当前库的条目数，可能包括视图；估算字节数不是 dump 大小。

纯投影要求 driver 恰为 `mysql`，严格接受固定五个元数据键，规范化输出 MySQL/MariaDB 家族及数字版本、非负整数表数/估算字节数、`SHA-256(server_name + NUL + database_name)` 指纹。只输出固定 JSON 键；原始 hostname、库名、用户名、连接串、SQL、异常及附加元数据均不输出。未知/畸形版本、空或控制字符标识、负数/非整数字节数、过大整数、额外键及异常均返回安全错误类别，不返回部分结果。指纹只是重复核对线索，不证明 Web worker 同库或生产身份。入口 bootstrap 可能按 Laravel 机制读取配置；本轮测试模式只运行纯投影，未执行该入口。

## 定向验证与事实界限

| 检查 | 实际结果 |
|---|---|
| `php test_target_probe.php` | **1/2 次**，退出码 0，**22 synthetic checks PASS**。覆盖 MySQL/MariaDB 版本、稳定指纹、非负统计、零值、未知 driver、畸形/负数/溢出/额外元数据、adapter 异常及原始库名/服务器名不泄露。全部使用虚构值。 |
| 两份 PHP 文件 `php -l` | 各 **1/1 次**，均无语法错误。 |
| `git diff --check` | **1/1 次**，退出码 0、无输出；该命令不覆盖未跟踪新文件。 |
| 三个新增文件尾随空白 | 单独只读检查，三者均为 **0 行**；无 tracked 改动。 |

AUTH-14/16/17 的接受事实分别限于当次 CLI 迁移账本、固定结构投影和主机工具/候选空间；AUTH-18 仅是 docs-only 后继方案。本候选未核验目标实例身份、Web worker 连接、服务端版本、真实数据量、账号分类、备份位置/保留期限或可恢复性。Owner 对完整备份存放及期限仍待决定。

本轮未 SSH、HTTP/API、读取 `.env`/私钥/凭据/日志/数据库行、访问设备或执行真实 DB、备份、导出、恢复、迁移命令。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。作者不提交、备份、推送、自接受或派发后继；停在 **Work LEVEL 2 独立 ACCEPT/REJECT**。未来远端运行须另立精确任务、锁定脚本哈希并严格解析受限输出。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本地固定目标/规模探针预检。** Work 在 `33989c928e66f5fd1683ab06811f41fd0037459e` 基线上核对三条允许路径、固定 SQL、纯投影白名单及失败时的安全类别。Laravel `Connection::selectOne()` 第三参数为 `useReadPdo`，候选显式传 `false` 仍只执行字面 SELECT；这避免读副本但不证明 Web worker 使用同一连接。Work 独立运行 `php test_target_probe.php`，**22 项虚构 adapter 检查 PASS**；三条候选原文件尾随空白为 0，暂存差异检查见接受提交。未执行真实 Laravel bootstrap 或 DB 查询。

`information_schema.tables` 的大小合计是估算，不是完整 dump 大小；目标指纹只由当次服务器名与库名计算，不证明生产身份或与 Web worker 同库。远端 MySQL/MariaDB 版本、实际目标、数据量、账号分类和备份可恢复性仍 `UNKNOWN`。本接受不授权现场运行、备份、导出或改库。
