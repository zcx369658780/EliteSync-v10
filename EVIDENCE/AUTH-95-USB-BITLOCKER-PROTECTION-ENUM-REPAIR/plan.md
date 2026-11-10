# AUTH-95｜E: BitLocker 保护枚举静态修复 Phase A

状态：**仅静态修复候选，待 Work LEVEL 2 预运行审查；Phase B 未放行。** 本轮未运行脚本、UAC 或真实 `Get-BitLockerVolume` 查询。

## 当前授权与错误边界

- 本地 `D:\EliteSync-v10`、`main`，启动 HEAD `ed4ad88acdf3ae09eea37e6e2aac4114c61f5001`；`TASK_CURRENT.md` 为 `AUTH-95-USB-BITLOCKER-PROTECTION-ENUM-REPAIR`、`ISSUED — PHASE A STATIC REPAIR ONLY`、LEVEL 2。两个原有无关未跟踪目录保留。
- AUTH-93 的一次启动只返回 `UAC_OR_LAUNCH_FAILED`，未取得状态；AUTH-94 一次新预算由 Owner 亲自批准 UAC，返回 `Unlocked/FullyEncrypted/100%`，保护字段为 `OTHER`。Work 独立判定旧脚本比较了不存在的 `ProtectionOn`；AUTH-94 原始保护值未保存，仍为 `UNKNOWN`。旧任务各 1/1 预算已耗尽，不在本任务重跑。
- 只读反射本机 `Microsoft.BitLocker.Structures.dll`：`BitLockerVolume.ProtectionStatus` 的属性类型为枚举 `Microsoft.BitLocker.Structures.BitLockerVolumeProtectionStatus`，枚举名精确为 `Off`、`On`、`Unknown`。反射没有读取固定 E: 的 BitLocker 状态。

## 候选与受限差异

仅在本任务目录新增 `owner-usb-bitlocker-readonly.ps1`，SHA-256 `DB45FD59BC587850F20042EDAE6C46D4AA6BA9D291E84614F79A33F81EA04861`。它从已审查的 AUTH-93 脚本复制，保留普通/提权双重固定 E: 身份门、唯一 USB `Kingston DataTraveler Duo`、25～35 GiB、唯一分区/卷映射、Removable，以及提权端唯一一处 `Get-BitLockerVolume -MountPoint 'E:'`。原 AUTH-93 脚本未改。

受限差异为：更新候选自身的固定路径与 `AUTH95_RESULT` 类别名；保护字段仅接受真实枚举类型的 `On` 为通过，`Off`、`Unknown` 分别映射到有限类别，缺失/错误类型/非法枚举值归 `INVALID`；子进程用有限退出码传递保护类别与其他三字段的不匹配位，父进程只显示有限类别和已知退出码。只有四字段同时匹配时才回报 `ALL_FOUR_MATCH`。不输出原始 BitLocker 对象、异常文本、保护器 ID、卷 GUID、密码、恢复密钥或文件名。

## 静态与虚构检查

- PowerShell 语法解析错误 **0**；文本中固定 `Get-BitLockerVolume -MountPoint 'E:'` 查询点 **1**，`RunAs` 启动点 **1**，尾随空白 **0**。新旧脚本的受限 diff 已检查：设备身份门、查询参数、提权启动参数均未变化。
- 只从脚本语法树提取 `Get-ProtectionClass` 函数并用本机反射枚举的**虚构值**调用：`On → 0`、`Off → 1`、`Unknown → 2`、非法枚举值/错误类型/null 均 `→ 3`。没有运行脚本其余部分或读取 E: 状态。
- 退出码布局：成功 `0`；若保护为 `Off/Unknown/INVALID`，分别用类别区间 `116～129`、`132～145`、`148～161` 叠加其他三字段有限不匹配位；`On` 但其他字段不匹配落在 `101～113` 的有效位组合。保留身份、UAC/启动、查询失败的固定分类；不认识的子进程退出码归 `CHILD_EXIT_UNEXPECTED`。任何不匹配不构成保护开启证明。

## 后继停点

Work 须独立复核脚本、枚举映射、哈希并临运行只读核对当前 E: 设备身份，才可考虑放行 Owner 亲自核对/批准 UAC 的一次普通进程启动。新提权状态查询预算当前 **0/1、未放行**。若 UAC、身份、查询或字段失败，停且不改参数或重试；本任务不写 U 盘或真实私钥副本。纸质恢复密钥能否用于失钥恢复、真实备份与恢复均未证明。

本轮未读取 U 盘文件或私钥正文，未修改 BitLocker/ACL/卷，未写 `E:` 或备份目录，未连接服务器/DB/云/Docker/GitHub，也未访问旧 `D:\EliteSync`；不提交、推送、自接受或派发后继。

## Work Phase A 独立预运行审查与 Phase B 单次放行（2026-09-25）

**LEVEL 2 ACCEPT 静态枚举修复，放行一次 Owner UAC 下的固定 E: 只读查询。** Work 逐行核对 AUTH-93→95 diff：设备身份门和唯一查询点未改；修复仅使用本机 DLL 的精确 `BitLockerVolumeProtectionStatus` 枚举类型，将 `On` 定为通过，`Off/Unknown/INVALID` 各自有限返回。退出码分段互不混淆，只有四字段同时匹配才返回成功；无秘密或写盘路径。独立核对本地 HEAD `ed4ad88acdf3ae09eea37e6e2aac4114c61f5001`、脚本 SHA-256 `DB45FD59BC587850F20042EDAE6C46D4AA6BA9D291E84614F79A33F81EA04861`；临运行 `E:` 仍唯一映射 `Kingston DataTraveler Duo` USB Removable、容量约 28.8 GiB。审查前候选计划 SHA-256 为 `20823B78A0179972C03E08942769686AF9096E9F98D2EA6427CCB9F09F2F51E1`。

仅放行**一次**固定脚本启动，由 Owner 本人核对并批准 Windows PowerShell UAC；新查询预算 **0/1 已用，待运行**。任何失败或保护为 `Off/Unknown/INVALID` 均停且不重试，不能写入恢复副本。此放行不等于当前保护已确认开启。
