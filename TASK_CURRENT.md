# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-89-REAL-PRIVATE-KEY-FILE-ACL-REPAIR`

Risk Level: `LEVEL 3`（真实私钥文件的精确权限修复；不读私钥正文或密码）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`，复用现有本地执行会话；Work 独立 LEVEL 3 验收。

## Authority and fixed boundary

AUTH-88 的唯一真实生成返回成功，精确目标存在且首行是加密 PKCS#8 标记，但 Work 只读核对文件 ACL 仍继承三条 FullControl ACE，完整安全目标已 LEVEL 3 REJECT。旧生成预算耗尽，绝不再运行生成命令。本任务只对精确既有文件关闭 ACL 继承并保留原有三主体权限；不得访问文件正文、密码或其他密钥。

## One bounded result

1. 核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区及 AUTH-88 验收边界，保留无关未跟踪内容。精确目标仅为 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem`。操作前只读检查目标是规范、非重解析普通文件、长度大于 0；Owner 必须为当前用户，文件 ACL 必须恰有当前用户、SYSTEM、Administrators 三条**继承的** Allow FullControl，无拒绝或其他 ACE。必要父路径须为非重解析目录。任何不符立即停止，不尝试修复。
2. 在上述全部前置条件满足时，仅对该精确文件执行**一次** ACL 变更：关闭继承、将现有三条 ACE 转为显式 ACE，维持相同三主体 Allow FullControl；不增加或删除主体、不改目录 ACL、不改文件正文或属性。变更预算 **1/1**。若失败，记录有限类别并停止，不重试或另用工具试错。
3. 变更后只读核对文件仍为相同精确普通文件且长度未变，Owner 仍是当前用户，继承关闭，恰有上述三条显式 Allow FullControl、无拒绝或其他 ACE。仅输出布尔/类别和长度，不输出私钥内容、完整 SDDL 或密码。将脱敏前后权限分类、一次变更结果和未解决目标写入 `EVIDENCE/AUTH-89-REAL-PRIVATE-KEY-FILE-ACL-REPAIR/summary.md`；停在 Work LEVEL 3 独立审查门，不提交、推送、自接受或派发后继。

禁止运行 AUTH-88 生成入口或 OpenSSL 解锁，读取/复制/删除/覆盖私钥正文，访问其他密钥、写 `E:` 或备份目录，连接服务器/DB/云/Docker/GitHub，访问旧 `D:\EliteSync`。本任务不建立密码可解锁性、公有证书或恢复副本证明。
