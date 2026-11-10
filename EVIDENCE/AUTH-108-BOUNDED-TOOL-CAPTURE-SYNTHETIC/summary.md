# AUTH-108｜有界双流采集虚构候选

**作者候选，待 Work LEVEL 2 独立审查。** 2026-09-26；`D:\EliteSync-v10` 本地 `main`，启动 HEAD `4c06010537e4848554a70b9b3a57cb9f7281099f`。本任务仅新增本证据目录的 `capture.py`、`test_capture.py` 与本文件；原有控制文档修改及两个无关未跟踪目录保持原状。

## 实现与边界

`capture()` 只接受调用方明确给出的绝对可执行路径和参数元组，不发现工具、不使用 shell；子进程的 stdin 关闭、环境为空，stdout/stderr 由两条线程同时读取。每条流只保留至限额加一的**计数**，任何原始字节均不写文件、日志、异常或普通返回值。整体执行时间到限，或任一流超限/读取失败时，杀死并等待子进程；返回值仅有固定类别、真实退出码（若进程已启动且可取得）、完整性标志与有界计数。若等待终止失败，返回 `TERMINATION_FAILED` 和不完整状态。终止回收另设最多 2 秒等待，不将这个回收宽限冒充正常执行时限。

固定类别包括 `INVALID_INPUT`、`SPAWN_FAILED`、`CAPTURE_INCOMPLETE`、`NONZERO_EXIT`、`STDERR_PRESENT`、`OUTPUT_LIMIT`、`TIMEOUT`、`TERMINATION_FAILED` 和 `OK`。非零退出或 stderr 非空不产生成功类别。控制字符和秘密标记原文只由虚构子进程输出，普通结果没有原文字段。采集核心不验证输出内容的文本布局；因此 `OK` 只说明这次有限子进程捕获完整、退出码为零且 stderr 为空，不表示 dump 工具能力、主机身份或备份可用。

`dump_observation_argv()` 是**不启动进程**的窄门示例，仅返回 `('--no-defaults', '--version')` 或 `('--no-defaults', '--help')`，其他模式返回空。未来任何真实调用仍须先独立锁定工具绝对路径、别名/符号链接身份与 SHA-256、环境、主机及参数预算；本示例不寻找 `mysqldump`。AUTH-107 `projector.py` 是另一纯函数，接受原始捕获字节；本核心刻意不返回原始字节，当前没有将其接入 `projector.py` 的安全通道。AUTH-107 完整测试为 `NOT_VERIFIED`，AUTH-106 虚构帮助里的 `PRESENT_IN_TEXT` 不能升级为现场支持结论。

## 验证与限制

| 检查 | 本任务用量与结果 |
| --- | --- |
| 纯虚构套件 | **1/3 轮**，`python -B test_capture.py` 退出 0，`SYNTHETIC_CHECKS_PASS=10`。覆盖小输出、stdout/stderr 同时突发、非零退出、stdout 超限、stderr 非空、控制字符、秘密标记不泄漏、超时及进程终止/未继续写标记、参数顺序和无效输入。无真实工具、shell、SSH、网络或 DB。 |
| 静态检查 | **1/2 轮**，两个 Python 文件 AST 可解析，尾随空白 0 行。 |

测试通过后仅移除了测试文件未用导入，并为关闭管道的 `OSError` 增加固定 `CAPTURE_INCOMPLETE` 返回；该后置错误分支未由运行测试覆盖。按任务单只有实际失败修复才可重试，没有消耗第二轮虚构套件。虚构子进程的杀死/等待已在当前 Windows 环境用超时样例证明一次；更多系统、子孙进程继承管道及强制终止失败路径仍 `UNKNOWN`。本核心不提供真实工具身份、环境审查、原始文本到投影器的安全交接或现场调用器。

本轮没有读取 `.env`、凭据、密钥、真实业务数据、备份或旧 `D:\EliteSync`；没有 SSH、生产 HTTP/API、Laravel CLI、真实 DB、云控制台、UAC、真实 dump、OpenSSL、Docker、备份、导出、传输、停写、DDL/DML 或删除。AUTH-101、AUTH-17、AUTH-107 已耗预算不重置，AUTH-107 Phase B 未放行。本地候选到此停在 Work LEVEL 2 独立审查门；不提交、推送、自接受或派发后继。

## Work LEVEL 2 独立审查（2026-09-26）

**ACCEPT 仅本地虚构子进程的有界采集核心。** Work 静态审查 `capture.py`、`test_capture.py`：调用方必须给绝对可执行路径与参数元组；进程不使用 shell、stdin 关闭、环境为空，两流并发读取，只返回固定类别、退出码、完整性与有界计数，不返回原始字节。超限/超时分支杀死并等待子进程，异常分支不包含原文。Work 对作者测试后新增的管道关闭失败分类所在最终版本，独立运行一次 `python -B test_capture.py`，退出 0、`SYNTHETIC_CHECKS_PASS=10`；两处原有无关未跟踪目录未动，`git diff --check` 通过。

本接受只覆盖当前 Windows 上的虚构子进程。测试没有注入管道关闭失败、终止失败或子孙进程继承管道情形；这些分支与其他系统行为仍 UNKNOWN。此核心不验证可执行文件身份、SSH 连接、真实帮助格式、DB 权限或 dump，也不向 AUTH-107 投影器安全传递原始帮助字节。因此不能据此放行 AUTH-107 Phase B 或任何现场操作；下一步如需主机只读观察，必须另立精确候选、负向验证和独立风险门。
