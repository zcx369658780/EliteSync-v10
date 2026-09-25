# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-64-DB-OBJECT-INVENTORY-PROBE-PREFLIGHT`

Risk Level: `LEVEL 2`（真实数据库完整范围前的只读元数据探针预检；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付本机 PHP 固定元数据探针、纯虚构 targeted 测试和脱敏说明，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-49 的真实备份前门仍缺真实 DB 身份和完整对象范围。AUTH-20 只在当次部署目录 CLI 连接上报告 43 个 `information_schema.tables` 条目和大小估算，不能区分表/视图，不能说明触发器、例程、事件、约束或 Web worker 同库。AUTH-63 只解决本机虚构解密身份门。此任务只在本机预检未来一次只读元数据探针，不运行真实 Laravel/DB；为后续另立的严格单次 SSH 任务准备可审查代码，不把预检当现场事实。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10` 的本地 `main`、HEAD、工作区以及本任务 ID/状态/派发；读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本文件、`REVIEW_GATE.md`、项目本地 workflow 技能、AUTH-19/20/49/63 验收。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。状态或派发不匹配立即停止。
- 只允许新增 `EVIDENCE/AUTH-64-DB-OBJECT-INVENTORY-PROBE-PREFLIGHT/probe.php`、`test_probe.php`、`summary.md`。不改历史证据、产品源码、配置或控制文件。探针为固定字面量、只读 `information_schema`/服务器元数据查询，无请求参数、动态 SQL、任意表名、业务表行、DDL/DML、dump 或迁移。
- 明确区分 `BASE TABLE` 与 `VIEW`；固定统计当前数据库的表、视图、列、索引、主键/唯一/外键约束、触发器、例程和事件。缺失权限、查询异常、非 MySQL/MariaDB、畸形或不完整投影必须 fail closed 为脱敏错误类别，不把 0 当“没有对象”。若某类无法在当前连接下可靠读取，标记 `UNKNOWN` 并说明原因，不伪造完整范围 PASS。
- 使用当前 Laravel 配置连接且明确只读 SELECT；固定查询数与每次结果上限，避免无限对象枚举或输出。纯函数/adapter 可注入虚构结果进行测试。输出仅固定白名单 JSON：探针版本、DB 家族/规范化版本、与 AUTH-20 可比较的目标指纹、各类非负整数计数、可选确定性结构摘要以及安全错误类别。不得输出原始主机名、库名、对象名、账户、连接串、SQL、异常、业务行或原始元数据。指纹和计数不证明 Web worker 同库或完整备份能力。
- 纯虚构 targeted 测试最多 2 次；至少覆盖表/视图区分、稳定指纹与结构摘要（若实现）、空库、对象上限、权限/查询失败、缺字段/多字段、负数/溢出/畸形值、异常脱敏和额外键拒绝。PHP 语法检查各文件最多 1 次；`git diff --check` 最多 1 次，新文件另做只读尾随空白检查。测试不得启动真实 Laravel、连接 DB 或服务器。
- 回执列出精确探针查询及限额、测试次数/结果、文件 SHA-256、未来现场运行需要另立的权限和 SSH 边界、仍为 UNKNOWN 的完整对象/数据类别/一致性与 Web worker 同库。不得保存任何真实配置、凭据或业务数据。

## Stop and review

不得 SSH、CloudShell、云 API、Docker、真实 DB、备份/密钥目录内容、U 盘、Owner 密码、账号/Token/消息/媒体或旧 `D:\EliteSync`；不得运行真实探针、备份、传输、解密、恢复、删除或改库。Codex 不提交、制作 bundle、推送、自接受或派发后继。即使本机预检 PASS，真实库完整范围、备份一致性、密钥与恢复仍未证明；停在 Work LEVEL 2 独立审查门。
