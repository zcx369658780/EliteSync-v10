# AUTH-93｜当前 E: Kingston BitLocker 只读预检 Phase A

状态：**仅无秘密脚本候选，待 Work LEVEL 2 预运行审查；Phase B 未放行。** 本轮没有启动 UAC、脚本或 `Get-BitLockerVolume`，未读取 U 盘目录/文件。

## 授权与边界

- 本地 `D:\EliteSync-v10`、`main`，启动 HEAD `b827871ae6c92db5d0d521056f4b20f62c4264e7`；`TASK_CURRENT.md` 为 `AUTH-93-CURRENT-USB-BITLOCKER-READONLY-PREFLIGHT`、`ISSUED — PHASE A SCRIPT CANDIDATE ONLY`、LEVEL 2。原有两个无关未跟踪目录保留。
- AUTH-79 只接受旧时点固定 Kingston `E:` 的 `Locked` 及其余字段不可判定；AUTH-80 只接受 Owner 当次解锁及旧时点 `Unlocked/ProtectionOn/FullyEncrypted/100%`；AUTH-92 只接受本机一次虚构 CMS 往返。旧状态和旧预算不转用为当前设备证明。
- Work 的本轮非提权观察：当前 `E:` 可见、Removable、FAT32、约 28.8 GiB，唯一 USB 磁盘名 `Kingston DataTraveler Duo`；非提权保护查询发生 `CimException`，因此**当前保护状态 UNKNOWN**。本 Phase A 不重复该查询。

## 唯一候选

候选 `owner-usb-bitlocker-readonly.ps1` SHA-256：`9C2D281BA57BE16ACE71C7E4957BC4687FD5C1EBB54933FAF8FEF28F223EDB84`。脚本在普通与提权进程内分别确认自身固定路径、`E:` 唯一分区、系统唯一 USB 磁盘、磁盘 `FriendlyName` 精确 `Kingston DataTraveler Duo`、总容量 25～35 GiB，以及分区号、卷对象、盘符和 `DriveType=Removable` 的唯一对应。身份失败立即停止，不进入 BitLocker 查询。

普通进程身份通过后，只启动一次固定 Windows PowerShell 的 `RunAs` 子进程；子进程隐藏窗口、重新核对身份和管理员令牌，再仅调用一次 `Get-BitLockerVolume -MountPoint 'E:'`。原始对象留在子进程内，四字段只映射为 `Unlocked`、`ProtectionOn`、`FullyEncrypted`、`100` 是否匹配的四位有限类别，经子进程退出码传给父进程。父进程只输出固定结果类别及已知退出码；查询异常、结果数量不为一、UAC/启动失败或意外退出码都有有限类别，不输出异常文本、保护器 ID、卷 GUID、密码、恢复密钥或文件名。若四项全部匹配，脚本仅报告本次受限状态，不写入任何副本。

脚本未包含解锁、启停保护、格式化、删除、复制、文件枚举或网络命令，也不修改 ACL 或卷。查询点、提权启动点各 **1** 处；PowerShell 静态语法解析错误 **0**，尾随空白 **0**。这只是文本与语法检查，不证明设备当前仍相同、UAC 会出现、提权查询可运行或四项状态满足条件。

## Phase B 预留门与 Owner UAC 指引草案

Work 先独立核对脚本哈希、逐行命令、当前固定 E: 身份和现场条件，才可放行一次运行。Owner 应在本机亲自核对 UAC 申请方是 Windows PowerShell，且此次操作仅为固定 `E:` 的只读 BitLocker 状态查询；不符则取消，只回报有限结果。无论取消、身份失败、查询失败还是字段不符，均不改参数或重试。提权查询预算当前 **0/1、未放行**。

Work 随后只按有限回执和必要的只读复核做 LEVEL 2 验收。即使四项匹配，也不能由本任务推导纸质恢复密钥可用、真实私钥副本已写入或备份恢复成立；任何实际复制另立任务。本轮不提交、推送、自接受或派发后继。

## Work Phase A 独立预运行审查与 Phase B 单次放行（2026-09-25）

**LEVEL 2 ACCEPT 无秘密只读脚本候选，放行一次 Owner UAC 与固定 E: 状态查询。** Work 逐行审查普通/提权双重 Kingston 身份门、唯一 `Get-BitLockerVolume -MountPoint 'E:'`、四字段位掩码、有限退出码与异常分类；没有文件枚举、秘密输出、解锁、BitLocker 变更或写盘。独立核对本地 HEAD `b827871ae6c92db5d0d521056f4b20f62c4264e7`、脚本 SHA-256 `9C2D281BA57BE16ACE71C7E4957BC4687FD5C1EBB54933FAF8FEF28F223EDB84`；当前非提权映射仍为单一 `Kingston DataTraveler Duo` USB、`E:` Removable、约 28.8 GiB。审查前候选计划 SHA-256 为 `664021463A38C5E9C462BEBC9F0412FBD4A03B4EC6674875AA5103E28EC3277F`。

仅放行一次普通进程启动脚本，由 Owner 本人核对并批准 Windows PowerShell UAC；查询预算 **0/1 已用，待运行**。若 UAC 不符、设备变化、查询失败或字段不匹配，停且不重试。放行不等于当前 BitLocker 状态通过或私钥副本写入授权。

## Work Phase B 独立审查（2026-09-25）

**LEVEL 2 REJECT 当前 BitLocker 四字段核验目标；ACCEPT 一次 `UAC_OR_LAUNCH_FAILED` 的受限回执。** Work 仅一次按放行脚本启动，普通进程约 2.66 秒返回 `AUTH93_RESULT=UAC_OR_LAUNCH_FAILED`、退出 1；无保护状态字段或提权查询成功证据。Owner 随后说明当时正在打字，**可能**误取消了窗口，并明确请求重新触发；是否显示/取消 UAC 仍不能从这次有限类别确定。旧任务查询预算 **1/1 已耗尽**，不得在 AUTH-93 内重试。

当前 `E:` 的 BitLocker 四字段仍 `UNKNOWN`，不能据此写入真实私钥副本。Owner 对新的一次尝试已有明确授权，须另立有界任务，重新核对脚本哈希和设备身份后才可调用；失败仍须停止。
