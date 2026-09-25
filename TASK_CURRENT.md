# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-96-ENCRYPTED-USB-KEY-RECOVERY-PAIR-COPY`

Risk Level: `LEVEL 3`（真实加密私钥与公有证书的固定 E: 恢复副本写入）

Status: `ISSUED — PHASE A SCRIPT CANDIDATE ONLY`

Assignee: `Codex + Owner`，复用现有本地执行会话；Work 独立 LEVEL 3 预运行审查和最终验收。Owner 在获批后亲自核对并批准 Windows PowerShell UAC；无需提供私钥或 U 盘密码。

## Authority and fixed boundary

Owner 已决定私钥在本人电脑独立目录、密码由本人保管，恢复副本放在已加密的 `E:` U 盘；Owner 授权使用该空 U 盘。AUTH-95 在一次固定 Kingston `E:` 的旧时点只读取得 `Unlocked/On/FullyEncrypted/100`，不能当作写入瞬间的永久状态。AUTH-92 仅证明本机虚构 CMS 往返。本任务只复制**现有加密 PEM 私钥原样字节**及对应公有证书到同一受保护 U 盘根目录的两个精确目标，并核对源/副本字节身份；不解密、生成或修改原私钥，不写真实备份。

## Phase A — candidate only; no UAC/copy

1. 核对本地 `main`、HEAD、工作区、AUTH-69/80/88～92/95 接受边界，保留无关未跟踪内容。固定源：`C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` 与同前缀 `.cert.pem`。固定目标：`E:\elitesync-v10-db-backup-recipient-20260925.key.pem` 与同前缀 `.cert.pem`。只读核对源私钥规范非重解析、2666 bytes、加密 PKCS#8 首行、当前用户 Owner 与三主体显式受限 ACL；公有证书规范非重解析、1541 bytes、公开 SHA-256 指纹与 AUTH-91 匹配；目标两个精确文件名均不存在。不得读取私钥正文到普通输出或枚举 U 盘文件。
2. 只在 `EVIDENCE/AUTH-96-ENCRYPTED-USB-KEY-RECOVERY-PAIR-COPY/` 准备固定 PowerShell 脚本与 `plan.md`。普通及提权进程内都必须确认 `E:` 是唯一 `Kingston DataTraveler Duo` USB Removable 卷，25～35 GiB，盘符/分区/卷映射唯一，剩余空间至少 1 MiB。提权进程在任何复制前对固定 `E:` **只调用一次** `Get-BitLockerVolume`，使用本机真实枚举 `On`，要求 `Unlocked/On/FullyEncrypted/100`；任何不符立即停止。再重新核对固定源/目标条件。复制只允许一次每个精确源到目标，使用禁止覆盖的原子目标创建方式（例如 .NET `File.Copy` 的 overwrite=false）；先私钥后公有证书，禁止临时明文私钥。复制后在进程内比较两对 SHA-256 与长度，只输出 MATCH/FAIL 有限类别，不输出私钥正文、哈希、原始对象或路径。失败保留任何已创建的受保护 E: 文件供 Work 定点处置，绝不自动删除、重试或改目标。
3. 静态核对脚本唯一 BitLocker 查询点、双重身份门、源/目标绝对路径、原子非覆盖调用、失败停点、无密码/解密/网络/删除/目录枚举、无秘密输出及 SHA-256。不得启动脚本、UAC 或复制测试。候选只写任务证据目录，停在 Work LEVEL 3 Phase A 预运行审查；不提交、推送、自接受或派发后继。

## Phase B — reserved, not yet authorized

Work 独立审查脚本并临运行核对源/目标、当前 E 身份与 Owner 在场后，才可放行**一次**脚本启动和 Owner 本人批准 UAC。BitLocker 状态查询与两文件复制各预算 **1/1，当前 0/1 未放行**。若 UAC、保护状态、身份、写入或字节核验失败，立即停止，不改参数或重试。Codex 只交付有限执行回执；Work 独立核对 E 两精确文件存在、长度与源副本 SHA-256 相等，并复核原私钥元数据/ACL 后作 LEVEL 3 验收。成功复制本身不证明 U 盘丢失时的恢复密钥可用或失钥恢复演练；须另立任务。

禁止读取 U 盘其他目录/文件，复制任何真实数据库或备份密文，输出私钥正文/口令/完整哈希，修改 BitLocker/卷/ACL、删除或覆盖任一现有文件，连接服务器/DB/云/Docker/GitHub，访问旧 `D:\EliteSync`。不得将私钥或副本加入 Git、Git bundle 或普通证据。
