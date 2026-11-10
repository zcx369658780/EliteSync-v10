# AUTH-15｜DB schema 元数据探针本地预检

状态：`BUILDER CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`、`main`，派发基线 HEAD `99edaec1653beb0ef387ebc45ed15ad0ec6ed992`。类型：本地 PHP 只读元数据探针候选与虚构 adapter 测试；本轮未执行 Laravel bootstrap 或连接真实 DB。

## 候选与边界

仅新增三条允许路径：

- `EVIDENCE/AUTH-15-DB-SCHEMA-METADATA-PROBE-PREFLIGHT/metadata_probe.php`
- `EVIDENCE/AUTH-15-DB-SCHEMA-METADATA-PROBE-PREFLIGHT/test_metadata_probe.php`
- `EVIDENCE/AUTH-15-DB-SCHEMA-METADATA-PROBE-PREFLIGHT/summary.md`

探针的 `auth15_project_metadata()` 是可注入虚构 adapter 的纯投影。固定探查 `users`、`personal_access_tokens`、`migrations` 是否存在；只对前两表检查任务指定的各七个字段及 `users.phone`、`personal_access_tokens.token` 的**单列唯一**索引。多列唯一索引不冒充单列唯一。返回仅含固定表/字段/索引键的布尔值、`mysql/pgsql/sqlite` 白名单 driver 和 `schema_complete`；缺表、未知 driver、adapter 异常或畸形元数据只返回安全错误类别，不返回部分元数据。缺字段或索引使 `schema_complete=false`，不被解释为迁移已落实。任意附加元数据字段、名称和值均不进入输出。

未来入口只在另行授权时从指定 Laravel 根以 PHP stdin 执行：它没有请求参数或任意表名，固定使用 Laravel Schema Builder 的 `hasTable/getColumns/getIndexes`。仅加载 Laravel 的固定 autoload/bootstrap；进程内屏蔽 bootstrap 期间的非 JSON 输出及错误显示，最终只发固定 JSON 或安全 `PROBE_ERROR`。没有 migration、schema 写入、行查询、事务写入、shell 或网络命令。框架 bootstrap 可能读取其配置，但本轮通过测试模式只运行纯投影，**未执行入口**；真实目标版本、权限和连接身份仍须未来任务核验。

## 定向回执

| 检查 | 实际结果 |
|---|---|
| `php test_metadata_probe.php` | 按预算运行 **2/2 次**，两次均退出码 0、**19 synthetic checks PASS**。覆盖完整字段/索引、缺表、缺字段、复合索引不等于单列唯一、未知 driver、adapter 异常、畸形元数据和附加值不泄露；第二次在入口输出抑制修订后运行。 |
| `php -l metadata_probe.php`、`php -l test_metadata_probe.php` | 两份文件各运行 **1/1 次**，均报告无语法错误；之后入口增补输出抑制逻辑，最终版本由第二次虚构 adapter 测试成功加载执行，未重跑已耗的 lint 预算。 |
| `git diff --check` | 运行 **1/1 次**，退出码 0、无输出；该命令不覆盖未跟踪新文件。 |
| 三个新增文件尾随空白 | 单独只读检查：探针 196 行、测试 122 行、回执 26 行，均为 **0 行**尾随空白；无 tracked 改动。 |

AUTH-14 的四条迁移 `Ran`、57/57 仅是一次 CLI 账本视图，本探针尚未证明真实表、字段、索引、目标 DB 身份、账号范围或备份可恢复性。未 SSH、HTTP/API、读取 `.env`/凭据/日志/数据库行、访问设备、备份、导出、恢复或修改 DB；未访问旧 `D:\EliteSync` 或 GitHub。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。作者不提交、备份、推送、自接受或派发后继；候选停在 Work LEVEL 2 独立 ACCEPT/REJECT。未来远端只读核验须另立精确任务。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本地固定范围探针预检。** Work 在 `99edaec1653beb0ef387ebc45ed15ad0ec6ed992` 基线上核对三条允许路径、投影函数、固定表/字段/索引白名单及失败时的安全类别。Laravel Schema Builder 的 `hasTable/getColumns/getIndexes` 和本地 MySQL/PostgreSQL index processor 与候选调用和 `unique` 布尔字段相符。Work 独立运行 `php test_metadata_probe.php`，**19 项虚构 adapter 检查 PASS**；三条候选原文件尾随空白均为 0，暂存差异检查见接受提交。未执行 Laravel bootstrap 或真实数据库访问。

`schema_complete` 在此代码中**只代表列明的固定字段和两个单列唯一索引全部存在**，不代表整张表或整库 schema 完整。未来现场任务必须按这个窄义解释，并确认任何新读操作仅返回固定布尔投影；实际连接目标、表结构其他部分、账号范围和备份能力仍 `UNKNOWN`。本接受不授权远端运行、备份、导出或改库。
