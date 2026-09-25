# AUTH-84｜独立可见 Windows PowerShell 窗口探针

状态：**单次探针未建立有效窗口观察，待 Work LEVEL 2 独立审查**；不得重试。

## 授权与执行前核对

- `D:\EliteSync-v10` 本地 `main`，启动 HEAD `1efa5e7924a33544627cf2c66abe3a89cf3e4807`；`TASK_CURRENT.md` 为 `AUTH-84-VISIBLE-POWERSHELL-WINDOW-DIAGNOSIS`、`ISSUED — NOT STARTED`、LEVEL 2。两个无关未跟踪目录保留。
- AUTH-83 已获 Work LEVEL 3 **REJECT**：仅有唯一启动的父进程退出码 1、Owner 未看到可报告失败类别及真实私钥目标不存在，子窗口和 OpenSSL 阶段均 `UNKNOWN`；旧预算耗尽。本任务只诊断无秘密窗口入口，不运行或修改 AUTH-83。
- 固定真实私钥目标在本轮探针前只读核对为不存在，未读取真实密钥目录条目或材料。
- 唯一脚本 `probe.ps1` SHA-256 为 `4CD4A54ABDA0C6A99C618ED7732EABAEDF3B11AE05F78C504EFF758DD4FBC837`；PowerShell AST 解析 0 错误。静态检查：`Start-Process` 1 处，窗口内固定标记 `AUTH84_VISIBLE_PROBE`、保持 12 秒（上限 15 秒），无 OpenSSL、`genpkey`、`pkey`、真实密钥路径、密码来源或删除命令。父进程只解码子进程退出码的五个控制台布尔，不重定向或采集子窗口流。

## 单次运行与 Owner 观察

启动前再次核对脚本 SHA-256 精确匹配、真实私钥目标不存在，工作区仅新增本任务证据并保留两个无关未跟踪目录。固定 `probe.ps1` **启动 1/1 次**。父进程给出的有限结果为：`AUTH84_CHILD_EXIT=1`；父进程按位解码打印 `USER_INTERACTIVE=False`、`CONSOLE_HOST=True`、stdin/stdout/stderr 重定向均 `False`、`CATEGORY=FINITE_CONSOLE_BITS`；调用工具本身退出 0。

但整次调用约 **0.98 秒** 即结束，短于子分支预定的 12 秒标记显示时间。退出码 `1` 也可能是 PowerShell 启动或脚本提前失败，故上述按位解码**不能作为子窗口实际控制台布尔证明**。Owner 在 Work 会话报告“**只看到窗口闪过**”，**没有看到固定标记**。这支持短暂出现窗口的本次界面观察，但不证明标记分支运行或控制台布尔值。具体失败阶段及 AUTH-83 原因均 `UNKNOWN`。本轮不调整参数或重试，窗口预算 **1/1 已耗尽**。

## 边界

探针结果只适用于这次独立窗口，不追溯证明 AUTH-83 子进程是否可见或当时的失败原因。本任务不生成/读取/删除密钥，不写 U:、E:、真实密钥/备份目录，不连接服务器、DB、云、Docker、GitHub 或旧 `D:\EliteSync`。作者不提交、推送、自接受或派发后继。

## Work 独立审查（2026-09-25）

**LEVEL 2 REJECT 有效可见窗口与控制台类别诊断目标；ACCEPT 单次窗口闪现及提前退出的受限事实。** Work 对照任务单、脚本、候选回执及 Owner“只看到窗口闪过”的观察；独立核对本地 `main` HEAD `1efa5e7924a33544627cf2c66abe3a89cf3e4807`、脚本 SHA-256 与候选记录一致、真实私钥精确目标仍不存在。审查前候选摘要 SHA-256 为 `00CC7CE60AF56B6B62CD3B2DF31E5DE440BA24399B125A8614634E81C3E371CA`，尾随空白 0 行，`git diff --check` PASS。

父进程约 0.98 秒结束，未达到子分支预定 12 秒；故退出码 1 的按位解读不能证明任何控制台布尔值。Owner 未看到固定标记。具体子进程失败阶段、AUTH-83 原因均 `UNKNOWN`。本任务窗口预算 1/1 已耗尽，不重试；如需再诊断，须另立任务并先审查无秘密交互入口。
