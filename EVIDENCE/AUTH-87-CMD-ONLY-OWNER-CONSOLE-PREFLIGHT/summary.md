# AUTH-87｜纯 CMD 桌面控制台入口 Phase A 候选

状态：**仅静态候选，待 Work LEVEL 2 预运行审查**。本轮没有启动 `.cmd` 或任何新窗口。

## 当前授权与边界

- `D:\EliteSync-v10` 本地 `main`，启动 HEAD `adfdf8cd258494fc66f26e73a2748838301285e4`；`TASK_CURRENT.md` 为 `AUTH-87-CMD-ONLY-OWNER-CONSOLE-PREFLIGHT`、`ISSUED — PHASE A ONLY`、LEVEL 2。两个无关未跟踪目录保留。
- AUTH-83/84/85 的各一次运行预算均已耗尽且对应目标未达成；AUTH-86 只读结论不确诊 PowerShell 失败原因。本任务仅准备完全不调用 PowerShell 的无秘密控制台入口，不追溯旧失败。
- 固定真实私钥目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` 只读核对为**不存在**，未读取真实密钥目录内容。系统固定 `C:\Windows\System32\choice.exe` 当次存在。

## 唯一候选与静态核对

唯一入口是同目录 `owner-cmd-probe.cmd`，SHA-256 为 `31B53742CA04B3A0757588F49373FE58D51620735099B9B0463D8E32C92AB94A`。它先显示 `AUTH87_VISIBLE_PROBE`，再以前台固定 `choice.exe /C Y` 接收一次无秘密 `Y` 键。返回类别为 `AUTH87_KEY_ACCEPTED`，或 `AUTH87_FAILURE=CHOICE_UNAVAILABLE` / `AUTH87_FAILURE=CHOICE_NOT_ACCEPTED`。三条结果路径均汇合到 `AUTH87_PRESS_ANY_KEY_TO_CLOSE` 与 `pause`，由 Owner 按键后关闭；不写输入或结果文件。

纯文本静态检查：第一行为 `@echo off`，标记为第一条输出；固定 `choice.exe` 调用 **1 处**，`pause` **1 处**；所有 `goto` 目标均存在，成功、程序缺失和选择失败路径均通向同一停留段。未发现 PowerShell、OpenSSL、其他脚本、后台启动、网络/删除命令、密码或恢复密钥来源、真实密钥/备份路径、U 盘路径或环境变量展开。未运行 `.cmd`、`choice` 或任何模拟启动，故以上仅为静态结构结论，不能证明实际窗口可见或按键路径。

## Work 审查后的 Owner 指引草案（本轮不执行）

1. 仅在 Work 独立审查候选并核对上述 SHA-256、明确放行 Phase B 后，Owner 从 Windows Explorer 打开 `D:\EliteSync-v10\EVIDENCE\AUTH-87-CMD-ONLY-OWNER-CONSOLE-PREFLIGHT\`，手动双击 **一次** `owner-cmd-probe.cmd`。不从 Codex 终端启动，不输入密码，不接受未预期的提权提示。
2. 若看到 `AUTH87_VISIBLE_PROBE` 和 `AUTH87_PRESS_Y_ONCE`，只按 `Y` 一次；观察 `AUTH87_KEY_ACCEPTED` 或固定失败类别，再看到 `AUTH87_PRESS_ANY_KEY_TO_CLOSE` 后按任意键关闭。只向 Work 报告是否见到这些标记及窗口是否保持，不发送截图或原始输出。
3. 若窗口闪退、出现意外内容或选择失败，停止并报告，不再次双击、不换参数。随后由 Codex/Work 只读复核真实私钥目标仍不存在。

Phase B 实际双击预算 **0/1，尚未放行**。本任务不调用 AUTH-83/84/85，不改变执行策略，不触碰真实/虚构密钥、E:、真实备份目录、服务器、DB、云、Docker、GitHub 或旧 `D:\EliteSync`。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 2 预运行审查门。

## Work Phase A 独立预运行审查（2026-09-25）

**LEVEL 2 ACCEPT Phase A 候选，放行 Phase B 的一次 Owner 双击。** Work 逐行审查唯一 `.cmd`：只打印固定标记、调用固定 `choice.exe` 一次，按 `errorlevel` 映射结果，所有分支汇入同一 `pause`；没有 PowerShell、OpenSSL、文件写入或秘密操作。独立复核入口 SHA-256 与上方值一致，真实私钥精确目标仍不存在，本地 HEAD 为 `adfdf8cd258494fc66f26e73a2748838301285e4`。审查前候选摘要 SHA-256 为 `25B969A672F9B88A20E4BD43BFA04C6B8CAFD61DB0C368F2A8E9AD098FCD39FB`。

Phase B 仅放行 Owner 按上述指引从 Explorer **手动双击一次**固定入口、按一次无秘密 `Y` 并回报固定类别；不得输入密码、重复启动或扩展到真实密钥。

## Work Phase B 独立审查（2026-09-25）

**LEVEL 2 ACCEPT 一次纯 CMD 前台控制台可见与无秘密按键路径。** Owner 回报成功标记出现，窗口显示按任意键提示，并在按键之后才退出。结合经审查的固定 `.cmd`，这支持本次 `AUTH87_VISIBLE_PROBE`、`AUTH87_KEY_ACCEPTED`、`AUTH87_PRESS_ANY_KEY_TO_CLOSE` 的正常路径；没有录制窗口原始流，细节以 Owner 观察为限。Work 独立核对本地 HEAD `ea739777344bc6b49621af5820ac858bca39f5b3`、入口 SHA-256 仍与放行值一致、真实私钥精确目标仍不存在。

Owner 双击预算 **1/1 已耗尽**，不重试。这仅证明无秘密 CMD 控制台入口和按键路径；不证明 OpenSSL 原生密码提示、真实密钥或恢复能力。真实生成须另立 LEVEL 3 有界任务并先做脚本预运行审查。
