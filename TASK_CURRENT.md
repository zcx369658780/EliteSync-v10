# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-86-POWERSHELL-PROBE-LAUNCH-READONLY-DIAGNOSIS`

Risk Level: `LEVEL 2`（真实密钥交互前的本机入口只读定位）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`，复用现有本地执行会话；Work 独立 LEVEL 2 审查。

## Authority and fixed boundary

AUTH-85 唯一 Owner 双击显示 `PROBE_LAUNCH_EXCEPTION`、PowerShell 退出 1 与按键提示，但未显示探针固定标记。该类别是宽泛 catch，真正异常原因 `UNKNOWN`；AUTH-83/84/85 各自运行预算均已耗尽。本任务仅只读检查 PowerShell 执行策略、固定脚本文件的来源标记和调用文本，判断是否有足够证据解释 AUTH-85。不得运行任何旧探针或改变执行策略。

## One bounded result

1. 核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区及 AUTH-83～85 接受边界，保留无关未跟踪内容；只读确认固定真实私钥目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` 仍不存在。若存在立即停止，不读内容。
2. 对当前用户/系统仅执行一次 `Get-ExecutionPolicy -List` 只读查询，记录各作用域策略类别，不改变任何作用域。对 AUTH-85 固定 `owner-visible-probe.cmd` 与 `probe.ps1` 只读查看文件属性和 `Zone.Identifier` 流**是否存在**；不得读取该流内容或枚举其他文件。核对文件 SHA-256 是否仍匹配 AUTH-85 放行值。
3. 静态检查 AUTH-85 的 `.cmd` 调用文本与 `.ps1` 顶部语法、PowerShell `-Command` 包装 catch 的覆盖范围。可用 PowerShell AST 解析脚本，但不得执行脚本、`.cmd`、新窗口或模拟一次真实启动。将可支持的原因与不能排除的其他原因分开；即使发现策略限制，也不追溯断言 AUTH-83/84 的具体失败。
4. 只在 `EVIDENCE/AUTH-86-POWERSHELL-PROBE-LAUNCH-READONLY-DIAGNOSIS/summary.md` 保存脱敏分类、固定文件哈希、检查结果和后继无秘密验证建议。没有原始异常，不得写成确诊。作者停在 Work LEVEL 2 独立审查门；不提交、推送、自接受或派发后继。

禁止运行 AUTH-83/84/85、改变执行策略或注册表、使用 `-ExecutionPolicy Bypass` 作运行尝试、触碰真实/虚构密钥、写 `E:` 或真实密钥/备份目录、连接服务器/DB/云/Docker/GitHub、访问旧 `D:\EliteSync`。本任务没有窗口/SSH/密钥生成预算，也无需 Owner 操作或输入。
