# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-32-DOCKER-MOUNTS-PARSER-STATIC-REPAIR`

Risk Level: `LEVEL 2`（隔离声明解析逻辑的纯本地修正与负向测试；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED`

Assignee: `Codex`。只交付纯本地候选与测试回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-30 的一次虚构恢复演练在隔离声明检查失败；AUTH-31 定点诊断确认网络无连接、端口和宿主 Binds 为空、三个 tmpfs 目标匹配，但 `Mounts` 解析在 PowerShell 严格模式下失败，数量/类型仍未知。Work 独立证明 `if` 表达式空数组分支可能赋值 `$null` 并令 `.Count` 抛错。两张任务运行预算均已耗尽。本任务**只修复和测试一个纯函数解析器**，不运行 Docker 或恢复演练，不改写旧证据。

## Exact candidate

只允许新增 `EVIDENCE/AUTH-32-DOCKER-MOUNTS-PARSER-STATIC-REPAIR/parse_mounts.ps1`、`test_parse_mounts.ps1` 和 `summary.md`。纯函数仅接收调用方提供的虚构 `Mounts` 值，返回固定 `count`（非负整数或 UNKNOWN）、`all_tmpfs`、`destinations_allowed`、`parse_ok` 四项；空/null 要可安全给出 count 0，不访问 `$null.Count`。只允许三个固定目标 `/var/lib/mysql`、`/run/mysqld`、`/tmp`；任意 `bind`/`volume`、额外目标、缺失 Type/Destination、非数组/对象或异常均 fail-closed。不得把 count 0 单独解释为隔离 PASS；真实任务仍必须结合 HostConfig.Tmpfs、Binds、端口、网络和 ID/名称。

测试用完全虚构值覆盖：null、空数组、三个合法 tmpfs、单个合法 tmpfs、bind、volume、额外目标、缺字段、畸形类型，以及严格模式下的 `.Count` 安全。预期必须包括明确负向拒绝。只运行固定测试脚本最多 **1 次**；若测试失败，保留最早失败，不修改后重跑。测试不调用 Docker、WSL、SSH、云或数据库。

文档说明这仅解决解析器的本地可测试语义，不证明 AUTH-30/31 当次 Docker `Mounts` 实际是什么，也不证明网络隔离或恢复能力。下一步如需容器诊断或虚构恢复，须另立任务及新预算。

## Verification and stop

启动前读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-30/31 失败记录；核对 `main`、HEAD、工作区。派发前检查点为 `d050792c90092b6f8b4549528dd8b28e7f652f83`；当前 HEAD 应为仅下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。不符即停。

`git diff --check` 最多 1 次，新文件另作只读尾随空白检查。不得访问旧 `D:\EliteSync`、浏览器、Docker、SSH、云 API、真实 DB、备份目录、凭据、密钥或业务数据；不备份/传输/恢复/删除/改库。Codex 不修改控制文件、不提交、不制作 bundle、不推送、不自接受或派发后继。
