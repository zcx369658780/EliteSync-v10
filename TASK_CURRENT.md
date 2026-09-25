# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-92-REAL-KEY-SYNTHETIC-CMS-ROUNDTRIP`

Risk Level: `LEVEL 3`（现有真实私钥解锁参与本机虚构内容 CMS 加解密）

Status: `ISSUED — PHASE B RELEASED; OWNER MANUAL DOUBLE-CLICK PENDING`

Assignee: `Owner + Codex`，复用现有本地执行会话；Work 已独立 LEVEL 3 预运行审查并放行一次 Owner 手动双击，最终验收仍由 Work 负责。Owner 只在 OpenSSL 原生提示输入现有密码。

## Authority and fixed boundary

AUTH-88/89/90 建立受限的现有加密私钥、权限与一次 Owner 密码解锁事实；AUTH-91 建立固定用途公有证书元数据。实际私钥/证书配对和 CMS 兼容尚未证明。本任务只用**固定虚构标记**在本机完成一次 CMS 加密、解密与逐字节比较；不读取真实数据库、备份、用户数据，不复制/导出私钥，不连接服务器或 U 盘。成功仅证明此本机工具链与这对材料的本次演练，不证明服务端 OpenSSL、真实备份或恢复。

## Phase A — candidate only; no CMS operation

1. 核对本地 `main`、HEAD、工作区、AUTH-88～91 接受边界并保留无关未跟踪内容。只读核对固定私钥 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` 的规范非重解析、长度 2666、加密 PKCS#8 首行、当前用户 Owner 与三主体显式受限 ACL；固定公有证书 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.cert.pem` 为规范非重解析 X.509 文件，记录公开 SHA-256 指纹并核对 AUTH-91 值。固定 OpenSSL 哈希须匹配 AUTH-88。任一不符即停止。
2. 只在 `EVIDENCE/AUTH-92-REAL-KEY-SYNTHETIC-CMS-ROUNDTRIP/` 准备一个纯 `.cmd` 候选和 `plan.md`。脚本使用同目录三个**精确且原先不存在**的虚构临时文件：固定 ASCII 标记、CMS DER 密文、解密标记。先逐一检查三目标不存在；只写固定非秘密标记，随后用固定 OpenSSL 对公有证书运行一次 `cms -encrypt -binary -aes-256-cbc -outform DER`，再用同一证书和现有私钥运行一次 `cms -decrypt -binary -inform DER`；Owner 仅在解密时原生非回显提示输入密码。用 `fc /b` 一次逐字节比较标记与解密文件。每一步非零即停，不重试或换算法。成功后只删除本次三个精确虚构临时文件并核对不存在；失败时保留它们供 Work 限定检查，不自动扩大清理。所有分支输出有限类别并 `pause`。
3. 静态核对唯一 encrypt/decrypt/compare 调用、文件边界、失败停点、精确清理和 SHA-256；不运行脚本、OpenSSL CMS 或任何虚构/真实密码测试。不得使用 `-passin`、环境变量、口令文件、管道传密、输入重定向、转录或日志，不得让私钥成为输出文件。候选仅写任务目录，停在 Work LEVEL 3 Phase A 预运行审查；不提交、推送、自接受或派发后继。

## Phase B — reserved, not yet authorized

Work 已于 2026-09-25 静态审查并临运行核对固定文件、脚本哈希、三个临时目标均不存在和 Owner 在场无录屏/共享条件，见同目录 `plan.md`，**放行 Owner Explorer 双击一次**固定 CMD SHA-256 `3F6680FE7894EA005436457065F91A1A6D94D58A4B7F9368A324755B4417497A`。CMS encrypt/decrypt/compare 各预算 **1/1，当前 0/1 已用**。Owner 只回报固定成功或失败类别，不发送密码、截图或原始输出。失败不重试；Work 独立只读检查私钥/证书元数据及三个临时文件存在类别，决定后续处置。成功仍须 Work 独立验收，不能推定服务器能力或真实备份/恢复。

禁止运行旧 AUTH-88/90/91 脚本，读取/输出/复制/删除/改写私钥正文，写 `E:` 或真实备份目录，连接服务器/DB/云/Docker/GitHub，访问旧 `D:\EliteSync`。本任务不授权任何真实数据库、密钥副本或恢复操作。
