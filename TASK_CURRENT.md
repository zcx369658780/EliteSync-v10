# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-91-OWNER-REAL-RECIPIENT-CERTIFICATE`

Risk Level: `LEVEL 3`（现有真实加密私钥解锁并创建固定用途公有证书）

Status: `ISSUED — PHASE A SCRIPT CANDIDATE ONLY`

Assignee: `Codex + Owner`，复用现有本地执行会话；Work 独立 LEVEL 3 预运行审查和最终验收。Owner 仅在获批后从 Explorer 启动并输入现有密码。

## Authority and fixed boundary

AUTH-88 留下精确加密 PKCS#8 私钥，AUTH-89 修复文件 ACL，AUTH-90 本次 Owner 原生提示密码解锁检查获受限 ACCEPT。纸质副本、跨端 CMS、U 盘恢复、真实 DB 备份仍未证明。本任务只用同一现有加密私钥创建**一个公有 X.509 收件人证书**；不修改、复制或导出私钥，不接触服务器、U 盘或数据库。

## Phase A — candidate only; no certificate operation

1. 核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区和 AUTH-81/88/89/90 接受边界，保留无关未跟踪内容。只读核对私钥固定路径 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` 为规范非重解析普通文件、长度大于 0、首行精确加密 PKCS#8 标记、当前用户 Owner、继承关闭且仅当前用户/SYSTEM/Administrators 三条显式 FullControl。固定证书目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.cert.pem` 必须不存在。核对必要父目录与固定 OpenSSL 非重解析、OpenSSL SHA-256 匹配 AUTH-88；任一不符即停止。
2. 仅在 `EVIDENCE/AUTH-91-OWNER-REAL-RECIPIENT-CERTIFICATE/` 准备纯 `.cmd` 候选，供 Owner 从 Explorer 双击。唯一写入命令为固定 OpenSSL `req -new -x509 -sha256 -days 365 -key <精确私钥> -out <精确证书> -subj /CN=EliteSync-v10-DB-Backup-Recipient -addext basicConstraints=critical,CA:FALSE -addext keyUsage=critical,digitalSignature,keyEncipherment -batch`，只调用一次。不得使用 `-passin`、`-keyout`、口令环境变量/文件、重定向、管道、转录或日志；Owner 只在原生非回显提示输入现有密码。脚本调用前检查精确私钥存在、证书目标不存在、OpenSSL 存在；失败即停止，所有分支有限类别并 `pause`。不重试、不删除或覆盖目标、不调用 PowerShell。
3. 静态核对脚本、全部分支、唯一写入命令与 SHA-256；保存脱敏候选与检查结果到同目录 `plan.md`。不得运行脚本、`req` 或任何真实/虚构密码测试。停在 Work LEVEL 3 Phase A 预运行审查；不提交、推送、自接受或派发后继。

## Phase B — reserved, not yet authorized

Work 静态审查、临运行复核文件/权限/目标不存在/程序和 Owner 在场无录屏共享后，才可放行一次 Owner Explorer 双击。证书生成预算 **1/1，当前 0/1 未放行**。若提示异常、密码回显、非零或输出异常，立即停并只报告有限类别，不重试；任何部分目标保留供 Work 判定。成功后 Work 仅对**公有证书**做只读解析，核对 PEM 类型、Subject、RSA 3072、SHA-256、365 天窗口、CA:FALSE、keyUsage、文件权限与精确路径；私钥仅复核元数据与权限，不读取正文或再次解锁。证书与私钥公钥配对、CMS 跨端互通及 U 盘副本另立任务。

禁止运行 AUTH-88/90 旧脚本，读取/输出/复制/删除/改写私钥正文，写 `E:` 或备份目录，连接服务器/DB/云/Docker/GitHub，访问旧 `D:\EliteSync`。不得把公有证书生成写成真实备份或恢复证明。
