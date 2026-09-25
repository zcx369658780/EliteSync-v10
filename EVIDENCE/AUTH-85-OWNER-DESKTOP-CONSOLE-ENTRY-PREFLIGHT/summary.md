# AUTH-85｜Owner 桌面控制台入口 Phase A 候选

状态：**仅候选，待 Work LEVEL 2 预运行审查；Phase B 未放行**。本轮没有启动 `.cmd`、PowerShell 窗口或任何探针。

## 授权与边界

- `D:\EliteSync-v10` 本地 `main`，启动 HEAD `dc6453a1b96d5daf18fa99fbc4f2c4fd48fb0f2c`；`TASK_CURRENT.md` 为 `AUTH-85-OWNER-DESKTOP-CONSOLE-ENTRY-PREFLIGHT`、`ISSUED — PHASE A ONLY`、LEVEL 2。两个无关未跟踪目录原样保留。
- AUTH-83 的真实私钥生成目标已被 Work LEVEL 3 REJECT：唯一父进程返回 1，真实私钥目标不存在，子窗口及 OpenSSL 阶段 `UNKNOWN`。AUTH-84 的可见窗口目标被 Work LEVEL 2 REJECT：Owner 只看到窗口闪过、未看到固定标记，父进程约 0.98 秒退出，控制台位解码无效。两任务预算各自耗尽，不重试或调用其脚本。
- 本次仅以 `Test-Path` 核对固定真实私钥目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` **不存在**；未读取真实密钥目录内容。

## 唯一桌面入口候选

| 文件 | SHA-256 | 作用 |
|---|---|---|
| `owner-visible-probe.cmd` | `2BEF93FA817E584E86EA7E9AF5D374EF0DDD411F9ECC7D3D97F6092A861BC206` | 由 Owner 在 Explorer 手动双击；使用固定绝对 Windows PowerShell 路径，前台同步运行固定探针；无论正常、缺文件或非零退出，显示有限类别并在 `pause` 等待按键后关闭 |
| `probe.ps1` | `4DDE4076CBAB0F4C6F81F689E5A0876A259064E1EADF1A89EA087EC7DCF39B48` | 在同一控制台输出 `AUTH85_VISIBLE_PROBE`、`UserInteractive`、`ConsoleHost` 和 stdin/stdout/stderr 重定向布尔；异常仅输出固定 `AUTH85_FAILURE=PROBE_EXCEPTION`，不输出异常原文 |

包装器无当前目录依赖，无 `Start-Process`、后台进程或流重定向；正常用户权限即可使用。`.cmd` 在 PowerShell 不存在、探针不存在、子探针异常/非零退出等静态分支均进入同一个按键停留段，不自行第二次尝试。脚本及包装器不含 OpenSSL、`genpkey`、`pkey`、密码或恢复密钥来源、真实密钥/备份目录写入、U 盘、删除或网络调用。PowerShell AST 解析为 **0 错误**；上述六个有限失败/停留分支的静态检查均为真。这是静态检查，不证明 Explorer 实际双击后的窗口、类别或停留行为。

## Work 审查后供 Owner 使用的指引草案（本轮不执行）

1. 只有 Work 明确放行 Phase B 并复核上表两个 SHA-256 后，Owner 才在 Windows Explorer 打开 `D:\EliteSync-v10\EVIDENCE\AUTH-85-OWNER-DESKTOP-CONSOLE-ENTRY-PREFLIGHT\`，手动双击 **一次** `owner-visible-probe.cmd`。不从 Codex 终端运行，也不输入密码或接受未预期的提权提示。
2. Owner 只观察窗口是否出现、是否显示 `AUTH85_VISIBLE_PROBE`、有限控制台布尔/失败类别，以及窗口是否保持至按键；可记下类别后按任意键关闭。只向 Work 报告这些分类，不发送截图、原始窗口流或任何密码。
3. 若未出现、闪退或类别异常，即停止；不再次双击、不换参数。Work/Codex 后续只读核对精确真实私钥目标仍不存在，再由 Work 作 LEVEL 2 验收。

Phase B 实际双击预算 **0/1 未消耗，且尚未授权**。本任务不生成、读取、复制或删除任何密钥，不写 E:、真实密钥/备份目录，不连接服务器、DB、云、Docker、GitHub 或旧 `D:\EliteSync`。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 2 预运行审查门。

## Work Phase A 独立预运行审查（2026-09-25）

**LEVEL 2 ACCEPT Phase A 候选并放行 Phase B 的一次 Owner 手动双击。** Work 逐行审查 `.cmd` 与 `.ps1`：固定绝对路径、同一前台控制台、无秘密探针、有限输出与失败类别、所有包装器分支最终进入 `pause`；没有授权范围外的密钥、U 盘、服务器或 DB 操作。独立核对上表两个 SHA-256 精确匹配、真实私钥目标仍不存在、本地 HEAD 为 `dc6453a1b96d5daf18fa99fbc4f2c4fd48fb0f2c`。审查前候选摘要 SHA-256 为 `C10790A816F71125C1D812A72DB30ACADD7BD22BA93B6468B20239C96617C2B9`。仅静态通过，实际双击表现仍待 Owner 回执。

Phase B 仅放行 Owner 从 Explorer 对上述固定 `.cmd` 手动双击 **一次**，无密码、无 UAC、无其他动作。若窗口闪退或显示失败类别，停止并回报，不重试。

## Work Phase B 独立审查（2026-09-25）

**LEVEL 2 REJECT 探针可运行与控制台布尔诊断目标；ACCEPT 可见失败类别的受限事实。** Owner 回报单次手动双击显示 `AUTH85_FAILURE=PROBE_LAUNCH_EXCEPTION`、`AUTH85_POWERSHELL_EXIT=1`、`AUTH85_FAILURE=POWERSHELL_NONZERO` 和 `AUTH85_PRESS_ANY_KEY_TO_CLOSE`。未回报 `AUTH85_VISIBLE_PROBE` 或五个控制台布尔；因此仅能认定包装器进入了 PowerShell 调用和有限异常/按键提示路径，不能认定探针执行或窗口确实停留到按键。`PROBE_LAUNCH_EXCEPTION` 是宽泛 catch 类别，真实异常原因 `UNKNOWN`；执行策略等仅为后续待核假设。

Work 独立复核本地 `main` HEAD `2d12ddbfe3474cab1793415452595d4de68ea2fc`、两个脚本 SHA-256 与放行值一致、真实私钥精确目标仍不存在，工作区仅保留两个既有无关未跟踪目录。AUTH-85 的 Owner 双击预算 **1/1 已耗尽**，不重试。下一步须另立只读本机诊断任务，不直接改变执行策略或尝试真实密钥。
