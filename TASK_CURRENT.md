# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-88-OWNER-CMD-REAL-ENCRYPTED-PRIVATE-KEY`

Risk Level: `LEVEL 3`（Owner 真实密码保护私钥生成；无 DB、服务器或备份写入）

Status: `ISSUED — PHASE B RELEASED; OWNER MANUAL DOUBLE-CLICK PENDING`

Assignee: `Owner + Codex`，复用现有本地执行会话。Work 已独立 LEVEL 3 接受 Phase A 并在 Owner 确认在场、无录屏/共享且密码已准备后放行 Phase B 的唯一一次手动双击。仅 Owner 本人从 Explorer 启动且只在 OpenSSL 原生提示输入密码。Work 保留最终验收权。

## Authority and fixed boundary

Owner 已授权本地真实私钥准备，选择 RSA 3072、AES-256-CBC 加密 PKCS#8，真实密码仅本人输入并有纸质副本分开放置；两固定目录不采用云同步。AUTH-83 的一次 PowerShell 真实生成失败，AUTH-84/85 的 PowerShell 诊断未成，旧预算均耗尽。AUTH-87 只证明一次纯 CMD 无秘密窗口与按键可用。此任务以**新的**纯 CMD 入口在固定目录直接生成**一个**真实加密私钥；不创建证书、U 盘副本、数据库备份或恢复。不得把 AUTH-87 当成 OpenSSL 密码提示证明。

## Phase A — candidate only; no key operation

1. 核对本地 `main`、HEAD、工作区、AUTH-81～87 接受边界和 Owner 决定，保留无关未跟踪内容。只读核对固定私钥目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` 不存在；若存在立即停止，不读内容。重新核对密钥目录及必要父路径为规范非重解析目录，密钥目录仅当前用户、SYSTEM、Administrators 三条显式 FullControl，Owner 为当前用户，继承关闭；若不满足即停止。核对固定 `C:\Program Files\Git\usr\bin\openssl.exe` 为规范文件，记录 SHA-256 和 `version` 有限结果；不得运行密钥命令。
2. 只在 `EVIDENCE/AUTH-88-OWNER-CMD-REAL-ENCRYPTED-PRIVATE-KEY/` 准备一个供 Owner 从 Explorer 双击的 `.cmd` 候选，使用固定绝对 OpenSSL 路径，且**只调用一次** `genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -aes-256-cbc -out <固定私钥目标>`。不使用 `-pass`、环境变量、口令文件、输入/输出重定向、管道、转录、日志或 Codex PTY。脚本在调用前再次检查固定目标不存在和固定程序存在；失败即分类并停止，绝不覆盖、删除、重试、换目录/算法或降级为无密码私钥。无论结果均显示有限状态并 `pause`，窗口只由 Owner 按键关闭。不得由脚本调用 PowerShell、其他脚本、网络或 U 盘。
3. 静态核对 `.cmd` 的全部分支、单次调用及 SHA-256；保存脱敏候选与检查结果到同目录 `plan.md`。不得执行 `.cmd`、`genpkey` 或任何真实/虚构密码测试。停在 Work LEVEL 3 Phase A 预运行审查；不提交、推送、自接受或派发后继。

## Phase B — reserved; not yet authorized

Work 已在 `plan.md` 记录精确脚本哈希、目录/程序/目标与 Owner 现场条件的临运行核对，**放行一次** Owner Explorer 双击。生成命令预算 **1/1，当前 0/1 已用**。Owner 只在 OpenSSL 原生非回显提示输入并确认新密码，不向 Codex、Work、聊天、命令参数或日志提供密码。若未见预期提示、密码回显、窗口异常或失败类别，立即停，保留任何可能的目标文件，由 Work 只读检查后决定处置；不自动重试。生成后 Work 仅做固定目标存在、文件长度、首行加密 PKCS#8 标记及 ACL 的受限只读核验；实际密码解锁、公有证书配对和 U 盘副本另立任务。

禁止调用 AUTH-83/84/85/87 的脚本或重用其预算；不得读取私钥正文、复制/删除任何密钥、写 `E:` 或备份目录、连接服务器/真实 DB/云/Docker/GitHub，或访问旧 `D:\EliteSync`。真实密码不得被 Codex 终端、聊天、脚本参数、环境变量或普通证据接收。
