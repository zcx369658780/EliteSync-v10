# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-15-DB-SCHEMA-METADATA-PROBE-PREFLIGHT`

Risk Level: `LEVEL 2`（未来目标数据库结构只读探针的本地预检；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。仅交付本地候选，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-14 已获 Work LEVEL 2 ACCEPT：其一次部署目录 CLI 迁移账本视图中四条目标均 `Ran`，共 57/57 已运行；原始输出未保存，实际表结构、目标数据库身份、账号/关联数据范围和备份可恢复性仍未核验。Owner 已要求未来若修改阿里云后端 DB 结构，必须先备份并校验可恢复；仅允许管理员创建的现有测试账号信息受控导出本地，禁止上传到阿里云以外其他地方。本任务只准备一份**本地、离线、只读元数据探针**，不连接服务器或真实 DB，不启动备份/导出/迁移。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能和 AUTH-10/14 接受记录。只有本任务仍为 `ISSUED` 且派发匹配才执行。

## Bounded candidate

仅允许新增三条路径：`EVIDENCE/AUTH-15-DB-SCHEMA-METADATA-PROBE-PREFLIGHT/metadata_probe.php`、`EVIDENCE/AUTH-15-DB-SCHEMA-METADATA-PROBE-PREFLIGHT/test_metadata_probe.php`、`EVIDENCE/AUTH-15-DB-SCHEMA-METADATA-PROBE-PREFLIGHT/summary.md`。使用当前 Laravel 11 的公开 Schema Builder `hasTable/getColumns/getIndexes` 只读方法，准备未来可从部署目录以 PHP stdin 执行的探针；源码必须拆出可用虚构 adapter 测试的纯投影函数。探针只检查固定 `users`、`personal_access_tokens`、`migrations` 三表是否存在，以及固定的 `users.id/phone/password/disabled/role/account_type/is_synthetic` 和 `personal_access_tokens.id/tokenable_type/tokenable_id/token/created_at/last_used_at/expires_at` 字段存在性、`users.phone` 与 `personal_access_tokens.token` 唯一索引存在性。只输出固定键的 JSON 布尔值、白名单 DB driver（mysql/pgsql/sqlite）或安全错误类别；不得输出任意表/字段名、字段值、账号行、数据库名/主机/用户、连接串、环境变量、密码、SQL、堆栈或原始异常。缺表、API/权限错误要可区分且 fail closed；不得把不存在解释成已迁移。

探针运行入口不得接收请求参数或任意表名，不得执行迁移、修改 schema、写入数据库、开启事务写入、运行 shell/网络命令或主动读取固定 Laravel bootstrap 之外的文件内容。Laravel bootstrap 可能按框架机制读取配置，此任务仅做静态代码和虚构 adapter 测试，不执行真实 bootstrap；未来远端运行须另立任务并审查。测试至少覆盖全字段/索引、缺表、缺字段/索引、未知 driver、adapter 异常、任意额外元数据不泄露；测试只用虚构对象，不连接任何 DB。

## Verification and stop

本地只读范围限项目控制文件、AUTH-10/14 接受证据、三个目标的精确迁移文件及 Laravel Schema Builder 的直接方法定义。定向虚构 adapter 测试最多 **2 次**，PHP 语法检查两份新增 PHP 文件各最多 **1 次**，`git diff --check` 最多 **1 次**；新增文件另作只读尾随空白检查。无需产品测试或构建。

不得 SSH、HTTP/API、读取 `.env`/凭据/日志/数据库行、访问设备或执行真实数据库命令；不得备份、导出、恢复或修改 DB。AUTH-14 的 SSH 预算不重置。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`；不访问旧 `D:\EliteSync`，不 pull/push GitHub。Codex 不自接受、提交、备份或派发后继；Work LEVEL 2 独立 ACCEPT/REJECT。未来远端只读元数据核验、备份/恢复演练或结构变更均需另立精确任务及相应风险门。
