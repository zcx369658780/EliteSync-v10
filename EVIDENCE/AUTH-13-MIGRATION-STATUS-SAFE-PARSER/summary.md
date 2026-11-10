# AUTH-13｜本地安全迁移状态解析器

状态：`BUILDER CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`、`main`，派发基线 HEAD `48a0518e889595209885bf92cbe3a9a6e23fb3ab`。类型：本地 Python 标准库纯解析器与合成测试，不接后端或远端工作流。

## 结果与边界

仅新增三条允许路径：

- `EVIDENCE/AUTH-13-MIGRATION-STATUS-SAFE-PARSER/migration_status_parser.py`
- `EVIDENCE/AUTH-13-MIGRATION-STATUS-SAFE-PARSER/test_migration_status_parser.py`
- `EVIDENCE/AUTH-13-MIGRATION-STATUS-SAFE-PARSER/summary.md`

`parse_migration_status(raw)` 只接收调用方 bytes/string，无 CLI，不读文件、环境变量或进程，不连接网络。输入上限 128 KiB；严格 UTF-8，并拒绝 ANSI、其他控制字符、非白名单文本。解析器要求完整末尾空行、唯一标题、连续且唯一的合规迁移行；容纳可变点线/空格和 CRLF/LF，从每行右端识别 `Pending` 或 `[正整数] Ran`。任何超限、坏编码、截断/折返、重复、额外提示、未知状态或缺四目标之一，只返回 `ok=false` 与安全错误类别，不返回原文或部分状态。整份通过后，仅返回 AUTH-11 四条精确迁移名的 `Ran/Pending` 状态及 `total/ran/pending` 数量；不披露其余行名或批次。

末尾空行是依 AUTH-12 所读本地 `StatusCommand.php` 的表格前后 `newLine()` 选取的保守完整性门；输出环境或版本若不满足，解析器会拒绝，不能靠放宽白名单自动使用。任何成功也只描述一次 CLI 迁移账本视图，不证明实际表结构、备份可恢复性、Web worker 配置或真实 T0。AUTH-11 原 stdout 未保存，本任务没有恢复它；四条远端迁移状态仍 **UNKNOWN**。

## 验证回执

| 检查 | 实际结果 |
|---|---|
| `python -B -m unittest test_migration_status_parser.py` | 运行 **1/2** 次预算，退出码 0；**12 tests OK**。输入均为合成文本与四条指定名称，无远端 stdout、账号或凭据。 |
| Python `ast.parse` 两份新增源码 | 运行 **1/1** 次语法检查，退出码 0，`syntax: PASS`；未生成 pycache。 |
| `git diff --check` | 运行 **1/1** 次，退出码 0、无输出；该命令不覆盖未跟踪新文件。 |
| 三个新增文件尾随空白 | 单独只读检查：解析器 110 行、测试 109 行、回执 26 行，均为 **0 行**尾随空白；无 tracked 改动。 |

未执行 SSH、HTTP/API、DB、设备、备份、导出、恢复或迁移；未读 `.env`、凭据、日志、数据库行、实际 Token 或用户/媒体内容，未访问旧 `D:\EliteSync` 或 GitHub。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。作者不提交、备份、推送、自接受或派发后继；候选停在 Work LEVEL 2 独立 ACCEPT/REJECT。未来远端读取须另立精确任务。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本地严格解析器和合成测试。** Work 在 `48a0518e889595209885bf92cbe3a9a6e23fb3ab` 基线上核对三条允许路径、实现和负向测试。解析器只消费调用方输入，对全量文本通过白名单后才投影四个固定目标与统计；超限、坏编码、控制字符、额外行、重复、缺目标或截断均不返回部分状态或原文。Work 独立复跑 `python -B -m unittest test_migration_status_parser.py`，**12/12 PASS**；三条候选原文件尾随空白均为 0，暂存差异检查见本地接受提交。

这是合成输入证明，不是远端版本或真实输出兼容性证明。末尾空行和 ASCII 白名单可能使真实输出被拒绝；拒绝时应保持 `UNKNOWN`，不得临场放宽解析。AUTH-11 已耗尽的 SSH 预算不因此重置；后继若再次读取须另立任务，且解析成功仍只代表该次 CLI 迁移账本视图。
