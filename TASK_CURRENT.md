# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-13-MIGRATION-STATUS-SAFE-PARSER`

Risk Level: `LEVEL 2`（真实数据库元数据输出的离线解析工具；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED`

Assignee: `Codex`。仅交付本地候选，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-11 的一次 SSH 返回 `OUTPUT_UNSAFE_OR_UNPARSEABLE`，四条迁移状态仍 `UNKNOWN`；AUTH-12 本地解析预检合同已获 Work LEVEL 2 ACCEPT，见 `EVIDENCE/AUTH-12-MIGRATION-STATUS-PARSER-PREFLIGHT/spec.md`。本任务只实现和验证一个**不联网**的严格解析器，以供未来另行授权的只读迁移状态观察使用；不得把 AUTH-11 旧 stdout 恢复或推断出来。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能和 AUTH-11/12 接受记录。只有本任务仍为 `ISSUED` 且派发匹配才执行。

## Bounded implementation

仅允许新增三条路径：`EVIDENCE/AUTH-13-MIGRATION-STATUS-SAFE-PARSER/migration_status_parser.py`、`EVIDENCE/AUTH-13-MIGRATION-STATUS-SAFE-PARSER/test_migration_status_parser.py`、`EVIDENCE/AUTH-13-MIGRATION-STATUS-SAFE-PARSER/summary.md`。使用 Python 标准库；解析器只接受调用方提供的 bytes/string，不连接网络、不启动进程、不读文件或环境变量。只处理本地 AUTH-12 合同规定的完整输出：UTF-8、无 ANSI/未知控制字符、可变点线和空白、唯一标题、每行唯一合规迁移名、右端精确 `Pending` 或 `[正整数] Ran`。目标固定为 AUTH-11 的四条精确迁移名；只有整份输出安全且四条都存在时，才返回四条状态及总数/已运行/待运行数。超限、截断、重复、额外提示、缺目标、歧义、行折返或未知状态一律只返回安全错误类别，不返回任何部分状态或原始输入。设置 **128 KiB** 输入上限。函数接口和输出约定写在 docstring，不需要 CLI。

用虚构/合成文本测试变动点线与空白、批次、四目标完整通过，以及 ANSI/控制序列、重复、缺目标、恶意附加行、坏 UTF-8、超限、未知状态、折返/截断的拒绝；测试不得包含真实远端输出、账号或凭据。不要将解析器接入后端或自动 SSH 工作流；成功解析也只能表示 CLI 迁移账本视图，不能证明表结构、备份或 Web worker 配置。

## Verification and stop

只读范围限项目控制文件、AUTH-11/12 接受证据、上述四个本地 migration 文件和必要的 Python 运行时版本；不做全仓泛搜。定向 `python -m unittest` 对唯一新测试文件最多 **2 次**；Python 语法检查最多 **1 次**；`git diff --check` 最多 **1 次**，新增文件另作只读尾随空白检查。失败时不扩大范围或调用服务器。

不得 SSH、HTTP/API、读取 `.env`/凭据/日志/数据库行、访问设备或执行任何真实数据库命令；不得备份、导出、恢复或修改 DB。AUTH-11 的 SSH 预算不重置。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`；不访问旧 `D:\EliteSync`，不 pull/push GitHub。Codex 不自接受、提交、备份或派发后继；Work LEVEL 2 独立 ACCEPT/REJECT。未来远端读取另立精确任务。
