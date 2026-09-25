# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-99-USB-KEY-SYNTHETIC-CMS-DRILL-ENTRY`

Risk Level: `LEVEL 3`（真实 U 盘私钥副本参与虚构 CMS 解密；本轮仅脚本候选）

Status: `ISSUED — PHASE A SCRIPT CANDIDATE ONLY; NO RUN OR PASSWORD`

Assignee: `Codex`，复用现有本地执行会话；Work 独立预运行审查和放行、最终验收及后继任务发布。

## Phase A — candidate only

1. 从 `CURRENT.md`、AUTH-92/95/97/98 已接受证据恢复边界，核对 `main`、HEAD、工作区及固定脚本/工具来源。只读核对当前 E: 为唯一 `Kingston DataTraveler Duo` USB Removable、25～35 GiB、分区卷映射唯一；精确 E: 私钥副本非重解析、2666 bytes、加密 PKCS#8 首行；精确 E: 公有证书非重解析、1541 bytes、公开 DER 指纹与 AUTH-91 匹配。不得输出私钥正文或哈希，枚举 U 盘目录或查询 BitLocker 状态。保留无关未跟踪目录。
2. 仅在 `EVIDENCE/AUTH-99-USB-KEY-SYNTHETIC-CMS-DRILL-ENTRY/` 准备 Owner 从 Explorer 单次双击、窗口保持到按键的固定 `.cmd` 入口、必要的固定本地脚本及 `plan.md`。脚本必须强制 OpenSSL 唯一 `cms -decrypt` 的 `-inkey` 为字面绝对路径 `E:\elitesync-v10-db-backup-recipient-20260925.key.pem`，不能存在 C: 私钥路径、通配符、回退或候选列表。公有证书固定为 E: 同前缀 `.cert.pem`。Owner 只在 OpenSSL 本机原生非回显提示输入现有私钥密码；不得通过脚本参数、环境、文件、管道、重定向或聊天获取密码。所有结果仅有限成功/失败类别及退出码，不回显 OpenSSL 原始错误、密码、私钥正文或哈希。
3. 未来执行前须固定核对入口/脚本/OpenSSL 身份、E: 设备及两个精确文件、三个固定虚构临时目标不存在。提权只读子过程对 E: 最多一次 `Get-BitLockerVolume`，要求 `Unlocked/On/FullyEncrypted/100`，且在任何读取 E: 私钥前完成；失败停下。设计固定 ASCII 虚构标记、AES-256-CBC CMS 加密与解密各最多一次、`fc /b` 比较最多一次；成功后只清理三个精确虚构临时文件并核对不存在，失败保留现场供 Work 定点审查。临时文件不得位于 E:、真实备份目录或 Git 跟踪范围；不触碰真实 DB/用户数据。检查返回码和第一失败类别，不自动重试、改路径/算法或清理可能的失败现场。
4. 静态审查 Windows PowerShell/CMD 转义与语法、唯一 E: `-inkey` 和单次调用、UAC/BitLocker 只读门、来源身份、临时文件路径、失败停点、输出抑制、清理精确性和禁止项。**Phase A 禁止运行任何入口、脚本、OpenSSL 加解密、UAC 或 BitLocker 查询**。候选只交 Work LEVEL 3 预运行审查，不提交、推送、自接受或派发后继。

## Phase B — reserved; not released

Work 独立审查候选及临运行状态、Owner 在场后才可决定是否放行一次手动启动及 Owner 本人 UAC/私钥密码输入。任何失败停止，不复用旧任务预算。成功回执仍须 Work 独立核对固定虚构临时目标清理、E: 副本有限元数据与源私钥权限未变，才可作受限验收。本任务即使成功也不证明 U 盘重插/纸质恢复密钥、真实数据库备份或恢复。

禁止修改 BitLocker、卷、源私钥、证书或 E: 副本，删除/覆盖其他文件，连接服务器、DB、云、Docker 或 GitHub，访问旧 `D:\EliteSync`，把任何真实密钥、密码或备份纳入 Git、Git bundle 或普通证据。
