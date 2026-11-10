# AUTH-167｜纯虚构双流原始读取上限切片

**2026-09-27 Work 派发；LEVEL 3，synthetic-only code。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。本切片只验证 AUTH-166 第 2 项的局部原始读取机制，不声称总墙钟、进程树、CMS 捕获或真实恢复已准备好。

## 允许范围与交付

先核对 `D:\EliteSync-v10` 的根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地工作流技能和 Git 工作区；固定来源仅再读 `EVIDENCE/AUTH-163-SYNTHETIC-BOUNDED-PREFLIGHT-SUPERVISOR/{supervisor.py,work-review.md}` 与 `EVIDENCE/AUTH-166-HARD-SUPERVISOR-REPAIR-CONTRACT/{plan.md,work-review.md}`。唯一允许新增/修改本目录的 `raw_reader.py`、`test_raw_reader.py`、`summary.md`。不可修改旧 AUTH-163、后端或治理文件。

实现一个仅供虚构字节的**两流独立并发**读取实验。每流显式使用无高层缓冲的 OS 读取入口，每次请求长度不得超过 `min(剩余额度+1, 固定块上限)`；记录请求、完成和累计实际返回字节以及有界峰值保留量。`L+1` 只作超限见证，不返回内容；任一流超限、读取错误、无法证明完整关闭或线程清理时 fail-closed。对每流 `L=0`、恰好 `L`、`L+1`、两流并发超限、对端关闭与读取异常设虚构测试。测试只用内存/本机匿名管道和固定虚构字节；不得启动外部子进程或接受任意命令、文件路径、密钥、密文。只输出状态与有限计数，不输出/记录正文。

在 `summary.md` 如实区分**OS 读取入口请求/返回长度**、Python/运行时内部副本、内核管道和生产者内存；若无法验证无预取或峰值保留，记 `UNRESOLVED`，不得用一组通过的测试声称硬上限。对清理失败保留失败状态和未证边界，不自动重试。交付唯一主要结果为三文件候选及定向测试回执，停 Work LEVEL 3 独立审查。

## 预算与禁令

最多 **1 次**定向测试首跑；若首跑失败，允许修复后 **1 次**定向复跑，仍失败即停。可在测试前做一次不执行代码的静态检查；使用 `python -B` 与禁写字节码，测试不得留下 `__pycache__` 或额外文件。仅允许本目录三文件写入，保留其他 dirty/untracked。不得运行 AUTH-155、CMS/解密/恢复、真实备份/密钥/DB、ACL/注册表/Docker/WSL/VM、UAC、SSH/云/API，访问旧 `D:\EliteSync`，提交、pull 或 push。作者不自接受、不启动后继；旧预算不重置。
