# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-19-DB-TARGET-SIZE-PROBE-PREFLIGHT`

Risk Level: `LEVEL 2`（未来备份目标与规模元数据探针的本地预检；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。仅交付本地候选，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-18 docs-only 方案获 Work LEVEL 2 ACCEPT，第一步需要只读确认实际目标连接标识、服务端 MySQL/MariaDB 版本和数据规模；AUTH-14/16/17 仅有 CLI 迁移/固定结构、MySQL driver 和主机备份工具/空间的受限事实。Owner 对完整备份存放及保留期限尚未答复。本任务只准备**本地、离线测试的固定只读元数据探针**，不连接服务器或真实 DB、不读取任何账号行，不执行备份或恢复。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能和 AUTH-14/16/17/18 接受记录。只有本任务仍为 `ISSUED` 且派发匹配才执行。

## Bounded candidate

仅允许新增三条路径：`EVIDENCE/AUTH-19-DB-TARGET-SIZE-PROBE-PREFLIGHT/target_probe.php`、`EVIDENCE/AUTH-19-DB-TARGET-SIZE-PROBE-PREFLIGHT/test_target_probe.php`、`EVIDENCE/AUTH-19-DB-TARGET-SIZE-PROBE-PREFLIGHT/summary.md`。使用当前 Laravel bootstrap 及固定 SQL 只读元数据接口，准备未来可从部署目录以 PHP stdin 执行的探针。只允许对**当前连接**获取 DB driver、`VERSION()`、`DATABASE()`、服务器 hostname 标识和 `information_schema.tables` 中 `table_schema = DATABASE()` 的表数与 `data_length + index_length` 合计；不得查询 `users` 或任何业务表数据行、任意 schema/table 名列表、账号数量、Token、媒体或日志。SQL 必须字面固定，无请求输入、拼接条件或外部参数；不得更换连接。

脚本拆出可用虚构 adapter 测试的纯投影：只输出固定键的 JSON，包括白名单 `mysql` driver、规范化的 MySQL/MariaDB 家族与数字版本、非负的估算字节数/表数，以及由**当次服务器标识与当前库名**计算的 SHA-256 指纹；不输出原始 hostname、库名、用户名、连接串、密码、SQL、异常或任意其他元数据。指纹只是重复核对线索，不证明 Web worker 同库或生产身份；估算空间不是完整 dump 体积。未知/畸形版本、空库名、非整数字节数、负数、异常或额外元数据应 fail closed，仅输出安全错误类别。Laravel bootstrap 可能按框架机制读取配置，本任务仅测试纯投影，不执行真实入口。

虚构 adapter 测试至少覆盖 MariaDB/MySQL 版本、稳定指纹、非负统计、畸形/负数/异常、不泄露原始库名与服务器名。不得把测试用值写成真实目标事实。未来现场运行仍须单独授权、固定脚本哈希与受限输出解析。

## Verification and stop

本地只读范围限控制文件、AUTH-14/16/17/18 接受证据及 Laravel DB facade/connection 的直接方法定义；不做全仓泛搜。定向虚构测试最多 **2 次**，PHP 语法检查两份新增 PHP 文件各最多 **1 次**，`git diff --check` 最多 **1 次**；新增文件另作只读尾随空白检查。无需产品测试或构建。

不得 SSH、HTTP/API、读取 `.env`/私钥/凭据/日志/数据库行、访问设备或执行真实数据库命令；不得备份、导出、恢复或修改 DB。AUTH-17 的 SSH 预算不重置。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`；不访问旧 `D:\EliteSync`，不 pull/push GitHub。Codex 不自接受、提交、备份或派发后继；Work LEVEL 2 独立 ACCEPT/REJECT。未来远端只读核验、实际备份或改库须另立精确任务和相应 Owner 高风险门。
