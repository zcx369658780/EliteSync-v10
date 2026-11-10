# AUTH-96｜加密 U 盘私钥恢复对副本 Phase A 脚本候选

状态：**仅脚本候选，待 Work LEVEL 3 预运行审查；Phase B 未放行。** 本轮没有启动脚本或 UAC，没有执行 BitLocker 查询、复制、解密或任何写 `E:` 操作。

## 当前授权与只读预检

- 本地 `D:\EliteSync-v10`、`main`，启动 HEAD `e1022f3b5450ee4ff5ac1f5ad0f633f24dbc347f`；`TASK_CURRENT.md` 为 `AUTH-96-ENCRYPTED-USB-KEY-RECOVERY-PAIR-COPY`、`ISSUED — PHASE A SCRIPT CANDIDATE ONLY`、LEVEL 3。两个原有无关未跟踪目录保留。
- AUTH-69 为分门实施前合同；AUTH-80 只证明旧时点 Owner 解锁 E:；AUTH-88/89/90 建立现有加密私钥及 ACL/一次解锁的受限事实；AUTH-91 建立公有证书，AUTH-92 证明本机一次虚构 CMS 往返；AUTH-95 只证明旧时点固定 E: `Unlocked/On/FullyEncrypted/100`。这些既有预算均不转为本任务的写入或当前保护状态证明。
- 固定源私钥 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem`：本轮只读预检为非重解析普通文件，2666 bytes，加密 PKCS#8 首行，Owner 为当前用户，继承关闭，恰有当前用户/SYSTEM/Administrators 三条显式 Allow FullControl。没有输出或保存私钥正文及其哈希。
- 固定公有证书同目录同前缀 `.cert.pem`：非重解析普通文件，1541 bytes，公开 DER SHA-256 指纹与 AUTH-91 的 `3AB76496F11B2AF5D3AE7975569A6100FD54E6BC99A41BBF7A22967ED5567461` 一致。
- 固定目标仅为 `E:\elitesync-v10-db-backup-recipient-20260925.key.pem` 和同前缀 `.cert.pem`；本轮逐一核对均不存在，没有枚举 U 盘文件。非提权设备元数据预检：当前 E: 唯一映射 `Kingston DataTraveler Duo` USB Removable、25～35 GiB、分区/卷唯一、剩余空间至少 1 MiB。**本轮未读取当前 BitLocker 状态**。

## 唯一候选与控制流

候选仅在本目录 `owner-copy-encrypted-key-pair.ps1`，SHA-256：`A79C3715E2DD08085D8BD0AEEEBE5388A0A9C2ADE197C656C6DD7EF032C6EB6C`。普通进程先检查固定脚本路径、E: 身份和空间、两固定源元数据/私钥 ACL/加密首行/公有证书指纹及两个目标不存在；失败给固定类别，不启动 UAC。Owner 获批后启动一次固定 Windows PowerShell 提权子进程。子进程再次核对 E:，且在任何复制前仅执行一次 `Get-BitLockerVolume -MountPoint 'E:'`，要求唯一状态对象满足 `Unlocked`、真实保护枚举 `On`、`FullyEncrypted`、`100`。之后重新核对固定源/目标及 E: 身份，任何不符停下。

受保护状态门通过后，脚本先以 `[IO.File]::Copy($keySource, $keyTarget, $false)` 创建**加密 PEM 私钥原样副本**，在进程内核对源/副本长度 2666 和 SHA-256 相等；再以同样的非覆盖调用复制公有证书，核对长度 1541 和 SHA-256 相等，最后再次核对私钥对。只有全部通过，子进程才退出 0，父进程才输出 `AUTH96_RESULT=PAIR_MATCH;CHILD_EXIT=0`。私钥哈希只在进程内比较，不显示或存入证据。脚本没有密码输入或解密路径，也不会生成明文私钥。

每个固定目标仅有一处非覆盖复制调用；复制抛错或字节核验不符立即给有限类别。任何已创建的 E: 文件（包括不完整文件）都保留供 Work 定点处置，脚本没有删除、覆盖、重试或改名路径。`File.Copy(..., false)` 可阻止目标已存在时的覆盖，但先前不存在检查与实际复制、身份/保护检查与写入不是不可分割的原子事务；Work 须在 Phase B 前裁决这一剩余并发/设备变化风险，且临运行再次核对源、目标和设备。

## 静态核对与停点

PowerShell 语法解析错误 **0**；文本中固定 BitLocker 查询点 **1**、`RunAs` 启动点 **1**、两处 `[IO.File]::Copy(..., false)`；禁用的解锁、格式化、删除、目录枚举、网络和解密命令命中 **0**，尾随空白 **0**。这些仅证明候选结构，不能证明提权、BitLocker 当时状态、实际复制或字节身份。Phase B 的脚本启动、状态查询和两文件复制预算均为 **0/1，未放行**。

Work 须独立审查脚本哈希、绝对路径、源/目标与当前固定 E:，确认 Owner 在场后才可决定放行一次手动 UAC 与脚本启动。Owner 仅核对 Windows PowerShell UAC，不发送密码、私钥、截图或原始输出。失败不重试；成功后 Work 须独立核对两个精确目标存在、长度与源副本 SHA-256 相等，以及原私钥元数据/ACL 未变，才能作 LEVEL 3 验收。复制不证明纸质恢复密钥可用或失钥恢复演练。

本轮不提交、推送、自接受或派发后继；不访问旧 `D:\EliteSync`、服务器/DB/云/Docker/GitHub，不把私钥或副本纳入 Git、Git bundle 或普通证据。

## Work Phase A 独立预运行审查与 Phase B 单次放行（2026-09-25）

**LEVEL 3 ACCEPT 脚本候选，放行一次 Owner UAC 下的固定恢复对复制。** Work 逐行审查普通/提权双重唯一 Kingston 身份门、提权端唯一 BitLocker 查询及真实枚举 `On`、源私钥受限 ACL/加密首行与公有证书指纹门、两个精确目标不存在、`File.Copy(..., false)` 各一次、源副本长度/SHA-256 进程内相等、失败保留部分副本且不自动删除/覆盖/重试。脚本不解密或输出私钥、口令及哈希。独立核对本地 HEAD `e1022f3b5450ee4ff5ac1f5ad0f633f24dbc347f`、脚本 SHA-256 `A79C3715E2DD08085D8BD0AEEEBE5388A0A9C2ADE197C656C6DD7EF032C6EB6C`；当前 E 仍为唯一 `Kingston DataTraveler Duo` USB Removable、约 28.8 GiB、余量 30,925,275,136 bytes，两精确目标不存在，源私钥/证书长度仍 2666/1541，私钥 ACL 继承关闭且三主体。审查前候选计划 SHA-256 为 `FDBD5FC7B85FAF527F7D0FE8FB0A06A2F03080CF9C72A452ECAD387CA2047905`。

身份/保护检查与两次写入不构成不可分割事务；在同一提权进程中写入前近时核对、固定设备/路径以及目标非覆盖创建的条件下接受剩余并发/设备变化风险，不能宣称原子隔离。Owner 已明确授权将私钥恢复副本放到这只已加密 E 盘，且同意使用该盘；密码已由 Owner 本人保管，复制不需要输入。仅放行**一次**固定脚本启动和 Owner 亲自核对/批准 Windows PowerShell UAC。任何失败停下，保留已创建文件供定点处置，不重试；放行不等于副本或失钥恢复验收。
