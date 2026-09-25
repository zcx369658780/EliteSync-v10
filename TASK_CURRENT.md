# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-83-OWNER-REAL-ENCRYPTED-PRIVATE-KEY`

Risk Level: `LEVEL 3`（Owner 真实数据库备份解密私钥与本人密码）

Status: `ISSUED — PHASE B RELEASED`（Work 已独立审查固定脚本；仅允许一次 Owner 在场的可见窗口执行）

Assignee: `Codex + Work + Owner`。Codex 只准备并静态检查无秘密的精确本机运行器；Work 对候选做高风险预运行审查、决定是否放行 Phase B；Owner 在独立可见 Windows 终端亲自输入和纸质记录真实密码。复用现有 Codex 会话。

## Authority and fixed object

Owner 已授权继续备份准备，密码需要时由本人输入；已决定备份和密钥不使用云同步、私钥密码另写纸质副本并与电脑/U 盘分开放置。AUTH-69/81/82 是本任务前置合同与虚构演练，AUTH-82 不证明真实无录制终端。固定真实私钥目标仅为 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem`。这张任务不创建证书或 U 盘副本，不连接服务器、数据库或云。

## Phase A：仅准备候选，停在 Work 预运行门

1. 核对本地 `D:\EliteSync-v10` main、HEAD、工作区与控制文件；保留两个无关未跟踪目录。只读确认固定密钥目录及父路径规范、非重解析、ACL 仅当前用户/SYSTEM/Administrators 且无继承；精确目标文件当前不存在。只读复核当前 Windows 已配置同步根与目标不重叠，同时记录 Owner 的无云同步声明和第三方技术观察限制。身份或权限不符停。
2. 仅新增 `EVIDENCE/AUTH-83-OWNER-REAL-ENCRYPTED-PRIVATE-KEY/launch.ps1` 和 `EVIDENCE/AUTH-83-OWNER-REAL-ENCRYPTED-PRIVATE-KEY/plan.md`，不写真实密钥目录或 U 盘。运行器仅使用固定 `C:\Program Files\Git\usr\bin\openssl.exe`，在独立可见的本机 PowerShell 窗口中以 `genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -aes-256-cbc -out <精确目标>` 生成 **1/1** 把加密私钥；不用 `-pass`、环境变量、脚本变量、输入重定向或 Codex PTY 传送真实密码。Owner 自行在 OpenSSL 原生提示中输入并确认；以后用一次 `pkey -in <精确目标> -noout` 原生提示验证可解锁，预算 1/1。脚本和启动命令不得含真实密码或恢复密钥。
3. 运行器必须在任何写入前再次核对唯一目标不存在、目录不转向、ACL 与精确 OpenSSL 路径；进程不启用 transcript/日志，不向 Codex 收集子窗口 stdin/stdout/stderr。只允许把退出码、文件存在/非空、加密 PKCS#8 头布尔、ACL 分类和首个失败类别作为脱敏结果。若失败后存在不完整目标，保留受限目录并停止，由 Work 另行决定精确处置；不得临场重试、换目录/算法或生成无密码私钥。运行器不得自行删除真实私钥。
4. 在 Phase A 仅做脚本语法/静态安全检查，不启动窗口，不生成密钥、不要求 Owner 输入密码。候选交 Work 审查后停止。Work 将在核对具体脚本和可见窗口输入边界后，修改本任务状态以放行或拒绝 Phase B；未明确放行前 Codex 不得执行。

## Phase B：待 Work 预运行审查

Work 的预运行审查与 Owner 无录制/共享及纸质准备确认已记录于 `EVIDENCE/AUTH-83-OWNER-REAL-ENCRYPTED-PRIVATE-KEY/plan.md`。启动前须再次核对 `launch.ps1` SHA-256 精确为 `ED3DCD63A3DC4B50EE32C1763BA47C2BD0569A9514C06D07E3372B0260692F20`，目标仍不存在。Codex 可启动**一次**不采集输入/输出的可见独立窗口，Owner 在该窗口亲自输入真实密码。完成后 Codex 只读检查精确文件的加密头、ACL、长度及脚本有限退出状态，形成 `EVIDENCE/AUTH-83-OWNER-REAL-ENCRYPTED-PRIVATE-KEY/summary.md` 候选，停在 Work LEVEL 3 独立验收门。密码不得进入聊天、Codex 终端、脚本、参数、环境变量、剪贴板自动化、普通证据、Git 或 Git bundle。

本任务不验证证书配对、U 盘副本、纸质 BitLocker 恢复密钥实用性、服务器 CMS、真实备份或恢复；这些各需独立任务。不得提交/推送 Git、自接受或派发后继。保留无关工作区内容，不访问旧 `D:\EliteSync`。
