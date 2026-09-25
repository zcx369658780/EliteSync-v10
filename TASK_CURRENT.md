# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR`

Risk Level: `LEVEL 3`（真实 E: 加密私钥副本的虚构解密演练入口；本轮仅候选）

Status: `PHASE A ACCEPTED — PHASE B NOT RELEASED; WORK HANDOFF HOLD`

Assignee: `Codex`，复用现有本地执行会话；Work 独立 LEVEL 3 预运行审查和最终验收。

Work 已在 `EVIDENCE/AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR/plan.md` 独立 LEVEL 3 **ACCEPT 静态候选**。Owner 要求当前长会话在验收后交接，故 Phase B **未放行**，手动启动、UAC/BitLocker、OpenSSL 加解密和比较使用量均为 0/1。任何人不得仅凭本状态启动入口；下一 Work 会话须先本地复核脚本哈希、固定 E: 与 Temp 状态、Owner 在场，再做独立临运行门裁决。旧 AUTH-99 拒绝候选仍禁止运行。

## Phase A — revised candidate only

1. 核对本地 `main`、HEAD、工作区和 AUTH-92 成功的 Owner 可见 CMD 原生 OpenSSL 调用、AUTH-97 恢复副本接受范围、AUTH-99 拒绝点、AUTH-100 有限提示通道事实。只读核对固定 E: 身份、两个精确副本有限元数据、固定 OpenSSL 哈希及虚构临时目标不存在；不读私钥正文/哈希，不查询 BitLocker，不运行 OpenSSL 加解密或 UAC。保留无关未跟踪目录。
2. 只在 `EVIDENCE/AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR/` 准备新的 Owner 从 Explorer 单次双击、窗口停留到按键的 `.cmd`、必要的只读保护检查脚本与 `plan.md`。优先沿用 AUTH-92 已在 Owner 窗口成功的人机路径：CMD 在前台直接调用固定 Git OpenSSL，OpenSSL 标准错误**留在 Owner 本机可见控制台**供原生非回显密码提示使用，不重定向或保存其原文。Owner 只报告预定义最终类别与退出码，勿发送窗口原文/截图。不能以 `-passin`、脚本参数、环境、管道、文件、剪贴板或 PowerShell `Read-Host` 接收真实密码。静态核对唯一 CMS 解密调用显式 `-inkey "E:\elitesync-v10-db-backup-recipient-20260925.key.pem"`，公有证书固定 E: 同前缀 `.cert.pem`，不得有 C: 私钥、回退、通配符或候选列表。
3. 任何读取 E: 私钥前，必须有独立提权只读子过程经 Owner UAC 后对当前固定 Kingston E: 执行最多一次 `Get-BitLockerVolume`，要求唯一对象 `Unlocked/On/FullyEncrypted/100`；失败即止。普通进程和提权进程都复核唯一 Kingston USB Removable 身份、分区/卷映射、25～35 GiB、两精确 E: 文件非重解析及长度/加密首行/公开证书指纹。固定脚本/工具身份门在调用前检查。设计 ASCII 固定虚构标记、AES-256-CBC CMS 加密与解密各最多一次、`fc /b` 一次；虚构临时目标在仓库外精确任务 Temp 目录，须确保不覆盖既有文件，成功只清理本任务所建三个虚构文件及空目录并核对不存在，失败保留现场。不得触碰真实备份/DB/用户数据。
4. 静态检查 Windows PowerShell/CMD 转义、输出与退出码、UAC/BitLocker 门、唯一 E: 私钥输入、Owner 可见原生提示、Temp 目标非覆盖与精确清理、失败即停及无自动重试。重点解释 AUTH-100 三次虚构调用非零只说明无人机/输入方式未建立，不否定 AUTH-92 的 Owner 原生窗口成功；也不能据此预判 AUTH-101 成功。**Phase A 禁止运行任何新入口/脚本、UAC、BitLocker 或 OpenSSL 加解密**。只交候选和有限证据，停在 Work LEVEL 3 预运行审查；不提交、推送、自接受或派发后继。

## Phase B — reserved; not released

Work 独立审查脚本及临运行状态、Owner 在场后才可决定是否放行一次手动启动、本人 UAC 与 OpenSSL 原生非回显密码输入。任何失败立即停止，不临场改参数/路径或重试；成功仍须 Work 核对虚构临时文件清理、E: 两文件有限元数据与源私钥 ACL 未变后作受限验收。A 成功不证明 U 盘重插密码解锁、纸质恢复密钥或真实数据库备份/恢复。

禁止修改真实密钥、BitLocker、卷、E: 副本或备份，删除/覆盖其他文件，连接服务器、DB、云、Docker 或 GitHub，访问旧 `D:\EliteSync`，将任何真实敏感材料纳入 Git、Git bundle 或普通证据。
