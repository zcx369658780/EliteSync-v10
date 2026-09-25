# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-85-OWNER-DESKTOP-CONSOLE-ENTRY-PREFLIGHT`

Risk Level: `LEVEL 2`（真实私钥交互入口的无秘密本机预检）

Status: `ISSUED — PHASE A ONLY`

Assignee: `Codex`，复用现有本地执行会话。Work 独立审查 Phase A 后，才可向 Owner 下达 Phase B 的手动双击步骤。

## Authority and fixed boundary

AUTH-83 真实私钥目标与 AUTH-84 可见窗口诊断均未达成，各自一次运行预算已耗尽。AUTH-84 中 Owner 只看到窗口闪过，未看到固定标记；原因 `UNKNOWN`。本任务仅建立一个由 Owner 从 Windows 桌面手动启动的**无密码、无密钥**控制台入口，确认它能显示固定标记、有限失败类别并停留供观察。不得调用 AUTH-83/84 脚本或推定其失败原因。

## Phase A — candidate only, no launch

1. 核对本地 `main`、HEAD、工作区、AUTH-83/84 审查边界；保留无关未跟踪内容。只读核对固定真实私钥目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` 不存在；若存在立即停止，不读内容。
2. 只在 `EVIDENCE/AUTH-85-OWNER-DESKTOP-CONSOLE-ENTRY-PREFLIGHT/` 写一个 Owner 可从 Explorer 双击的 `.cmd` 包装器及必要的无秘密 `.ps1`，使用绝对固定路径，不依赖当前目录。入口只打印 `AUTH85_VISIBLE_PROBE` 与有限类别，显示 `UserInteractive`、`ConsoleHost`、stdin/stdout/stderr 重定向布尔；异常时打印固定 `AUTH85_FAILURE=<类别>`，不打印异常原文、环境变量或路径。无论成功或失败，等待 Owner 按键后才关闭；不得自动尝试第二次、启动后台进程或记录原始流。普通用户权限即可运行。
3. 静态核对路径、命令和控制流；作脚本语法检查与虚构/静态分支检查，不启动新窗口。记录文件 SHA-256、检查结果和 Windows Explorer 双击的精确后续指引草案到同目录 `summary.md`。候选必须不含 OpenSSL、`genpkey`、`pkey`、密码/恢复密钥来源、真实私钥/备份目录写入、U 盘访问、删除命令或网络调用。保存候选后停在 Work LEVEL 2 Phase A 预运行审查；不提交、推送、自接受或派发后继。

## Phase B — reserved, not yet authorized

Work 审查 Phase A 后如放行，Owner 可从 Explorer **手动双击一次**经审查的固定 `.cmd`。Owner 只报告是否看到窗口、固定标记、有限类别及其是否保持打开；不输入密码、不发截图。该实际窗口预算 **1/1**，未获 Work 放行前为 **0 次授权**。若失败或窗口闪退，记录观察并停止，不换参数、不重试。Codex/Work 后续只读复核真实私钥精确目标仍不存在，最终由 Work LEVEL 2 验收。

禁止运行或修改 AUTH-83/84；不得生成、读取、复制或删除任何真实/虚构密钥，不得写 `E:`、真实密钥/备份目录，不连接服务器、DB、云、Docker、GitHub 或访问旧 `D:\EliteSync`。任何真实密码、证书、U 盘副本、备份或恢复步骤均须另立任务并经过对应风险门。
