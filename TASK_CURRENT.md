# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-95-USB-BITLOCKER-PROTECTION-ENUM-REPAIR`

Risk Level: `LEVEL 2`（当前 E: BitLocker 只读探针的保护枚举修复与后继一次核验）

Status: `ISSUED — PHASE A STATIC REPAIR ONLY`

Assignee: `Codex + Owner`，复用现有本地执行会话。Codex 仅准备修复候选；Work 独立 LEVEL 2 预运行审查并放行后，Owner 亲自批准可能出现的 Windows PowerShell UAC。

## Authority and fixed boundary

AUTH-94 一次查询已耗尽，返回固定 E: `Unlocked/FullyEncrypted/100%`，但 `ProtectionStatus` 映射有静态错误：本机 `BitLockerVolumeProtectionStatus` 枚举值为 `Off/On/Unknown`，旧脚本却比较 `ProtectionOn`，所以保护位本次必然 `OTHER`，原始值未保存。不得在 AUTH-94 重试。本任务只修复这一枚举判断并在独立审查后新授权一次只读查询；不读取 U 盘内容或写真实私钥副本。

## Phase A — static candidate only, no UAC/query

1. 核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区及 AUTH-93/94 受限验收，保留无关未跟踪内容。只读核对本机 BitLocker module DLL 中 `BitLockerVolume.ProtectionStatus` 属性的枚举类型与 `Off/On/Unknown` 值；不得调用 `Get-BitLockerVolume` 或启动提权窗口。
2. 只在 `EVIDENCE/AUTH-95-USB-BITLOCKER-PROTECTION-ENUM-REPAIR/` 准备从 AUTH-93 经审查脚本派生的固定只读脚本；仅将保护通过条件改为**枚举 `On`**，并把 `Off`、`Unknown` 分成有限类别，不输出原始对象、保护器、卷 GUID、密码或恢复密钥。普通与提权进程仍须双重核对唯一 `Kingston DataTraveler Duo` USB、25～35 GiB、固定 `E:` 分区/卷映射与 Removable；提权端仅有一处 `Get-BitLockerVolume -MountPoint 'E:'`。不得修改旧脚本。
3. 静态核对与旧脚本的受限 diff、唯一查询点、语法、所有输出类别和哈希；只做枚举反射/虚构静态值测试，不查询真实卷。结果写入同目录 `plan.md`，停在 Work LEVEL 2 Phase A 预运行审查。不提交、推送、自接受或派发后继。

## Phase B — reserved, not yet authorized

Work 独立审查固定脚本与枚举映射，并临运行只读核对当前 E 设备身份后，才可放行**一次**普通进程启动；Owner 本人核对并批准 Windows PowerShell UAC。新提权状态查询预算 **1/1，当前 0/1 未放行**。只记录四字段有限类别、已知退出码及 Owner UAC 回执；任何失败或 `Off/Unknown` 均停止，不改参数、不重试、不写 U 盘。Work 独立 LEVEL 2 验收后，才可另立私钥副本任务。

禁止执行或修改 AUTH-93/94 旧任务，读取 U 盘文件或真实私钥正文，改 BitLocker/ACL/卷、写 `E:` 或备份目录，连接服务器/DB/云/Docker/GitHub，访问旧 `D:\EliteSync`。纸质恢复密钥实际可用性不由本任务证明。
