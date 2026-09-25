# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-87-CMD-ONLY-OWNER-CONSOLE-PREFLIGHT`

Risk Level: `LEVEL 2`（真实密码提示前的无秘密本机交互入口预检）

Status: `ISSUED — PHASE A ONLY`

Assignee: `Codex`，复用现有本地执行会话；Work 独立审查 Phase A 后，才可向 Owner 下达 Phase B 手动双击。

## Authority and fixed boundary

AUTH-83/84/85 的各一次运行预算已耗尽。AUTH-86 只读观察未确诊 PowerShell 脚本调用失败原因。本任务不再追溯那些失败；只验证一个**完全不调用 PowerShell**的 Windows `.cmd` 前台控制台能否显示固定标记、接受一个无秘密按键，并等待 Owner 关闭。此验证不证明 OpenSSL 密码提示、密钥生成或备份恢复。

## Phase A — candidate only, no launch

1. 核对本地 `main`、HEAD、工作区、AUTH-83～86 接受边界；保留无关未跟踪内容。只读确认固定真实私钥目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` 不存在；若存在立即停止，不读内容。
2. 只在 `EVIDENCE/AUTH-87-CMD-ONLY-OWNER-CONSOLE-PREFLIGHT/` 准备一个 Owner 可从 Explorer 双击的 `.cmd`。不得调用 PowerShell、OpenSSL、其他脚本、后台进程或网络。运行时依次显示 `AUTH87_VISIBLE_PROBE`，使用 Windows `choice` 只接收一次固定无秘密 `Y` 键，按结果显示 `AUTH87_KEY_ACCEPTED` 或固定失败类别；无论分支均显示 `AUTH87_PRESS_ANY_KEY_TO_CLOSE` 并 `pause`。不得记录输入、读取环境变量值或输出路径/原始错误。
3. 静态核对所有分支与入口文件 SHA-256；不得启动 `.cmd` 或新窗口。把候选、检查结果和 Owner Explorer 双击指引草案写入同目录 `summary.md`，停在 Work LEVEL 2 Phase A 预运行审查。不提交、推送、自接受或派发后继。

## Phase B — reserved, not yet authorized

经 Work 审查并核对固定哈希后，Owner 才可从 Explorer 手动双击经审查的 `.cmd` **一次**，在看到提示时按 `Y` 一次，再观察固定类别和按键关闭提示；不输入密码、不发截图。预算 **1/1，当前 0/1 已用且未放行**。若闪退、失败或显示意外内容，停止并报告，不重试。Codex/Work 后续只读复核精确真实私钥目标仍不存在，由 Work 作 LEVEL 2 验收。

禁止运行 AUTH-83/84/85，改变执行策略，使用 OpenSSL、生成/读取/复制/删除密钥，写 `E:` 或真实密钥/备份目录，连接服务器/DB/云/Docker/GitHub，访问旧 `D:\EliteSync`。真实密码、证书、U 盘副本、备份及恢复均须另立任务并过相应风险门。
