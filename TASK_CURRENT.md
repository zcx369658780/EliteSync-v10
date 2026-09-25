# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-93-CURRENT-USB-BITLOCKER-READONLY-PREFLIGHT`

Risk Level: `LEVEL 2`（真实私钥恢复副本写入前的当前设备只读身份与保护核对）

Status: `ISSUED — PHASE A SCRIPT CANDIDATE ONLY`

Assignee: `Codex + Owner`，复用现有本地执行会话。Codex 只准备无秘密只读候选；Work 独立预运行审查后，Owner 亲自核对并批准一次 Windows UAC；Work 作 LEVEL 2 最终验收。

## Authority and fixed boundary

AUTH-79/80 曾证明同一只 Kingston `E:` 在旧时点锁定、Owner 解锁及 `ProtectionOn/FullyEncrypted/100%`；不能当作当前状态。AUTH-92 只建立本机虚构 CMS 往返。Work 本轮非提权只读观察当前 `E:` 为可见、Removable、FAT32、约 28.8 GiB，唯一 USB 磁盘名 `Kingston DataTraveler Duo`；非提权 BitLocker 状态查询返回 `CimException`，因此当前保护状态仍 `UNKNOWN`。本任务只核对**当前**设备身份、卷映射和 BitLocker 保护，不读 U 盘文件或写副本。

## Phase A — candidate only; no UAC/query launch

1. 核对本地 `main`、HEAD、工作区、AUTH-79/80/92 接受边界并保留无关未跟踪内容。只在 `EVIDENCE/AUTH-93-CURRENT-USB-BITLOCKER-READONLY-PREFLIGHT/` 准备固定 PowerShell 只读脚本与 `plan.md`；不得启动提权进程或调用 `Get-BitLockerVolume`。
2. 脚本在普通及提权进程内都须确认：`E:` 映射唯一 USB 可移动磁盘，FriendlyName 精确 `Kingston DataTraveler Duo`，磁盘容量在 25～35 GiB，分区/卷映射唯一。身份不符立即停止。提权进程对固定 `E:` **只调用一次** `Get-BitLockerVolume -MountPoint 'E:'`，仅将 `LockStatus=Unlocked`、`ProtectionStatus=ProtectionOn`、`VolumeStatus=FullyEncrypted`、`EncryptionPercentage=100` 四项映射为有限状态/类别返回；不得输出原始 BitLocker 对象、保护器 ID、卷 GUID、密码、恢复密钥、文件名或异常文本。Parent 只记录有限分类及进程退出结果。
3. 静态检查脚本身份门、唯一 BitLocker 查询点、无写入/解锁/格式化/删除/网络命令及 SHA-256。记录无运行的候选与 Owner UAC 指引草案，停在 Work LEVEL 2 Phase A 预运行审查；不提交、推送、自接受或派发后继。

## Phase B — reserved, not yet authorized

Work 独立审查精确脚本、固定哈希与当前 E 设备身份后，才可放行**一次** Owner 亲自核对并批准的 UAC；提权状态查询预算 **1/1，当前 0/1 未放行**。若 UAC、身份或查询失败，记录有限类别并停止，不改变参数或重试。Work 独立审查回执后才可考虑另立真实私钥副本写入任务；本任务不授权复制、解锁、写入或 U 盘恢复演练。

禁止读取 U 盘目录/文件，访问真实私钥正文、密码或恢复密钥，修改 BitLocker/ACL/卷，写 `E:` 或备份目录，连接服务器/DB/云/Docker/GitHub，访问旧 `D:\EliteSync`。旧 AUTH-79/80 查询预算不得复用。
