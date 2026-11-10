# AUTH-94｜固定 E: BitLocker 单次只读重试回执

状态：**作者受限回执，待 Work LEVEL 2 独立审查。** 查询完成时点：2026-09-25 18:07:30 +08:00。

## 派发与临运行门

- 本地 `D:\EliteSync-v10`、`main`，启动 HEAD `92e2cd36c8abe6877825af0ca71b96ebb32f52d4`；`TASK_CURRENT.md` 为 `AUTH-94-USB-BITLOCKER-OWNER-UAC-RETRY-READONLY`、`ISSUED — ONE NEW ATTEMPT AUTHORIZED`、LEVEL 2。两个既有无关未跟踪目录保留。
- AUTH-79/80 只证明旧时点的锁定、Owner 解锁及保护状态；AUTH-93 一次启动返回 `UAC_OR_LAUNCH_FAILED`，四字段未取得且旧 1/1 预算已耗尽。本任务基于 Owner 明确请求重新触发一次的独立预算执行，不追溯修改旧结论。
- 固定脚本 `EVIDENCE/AUTH-93-CURRENT-USB-BITLOCKER-READONLY-PREFLIGHT/owner-usb-bitlocker-readonly.ps1` SHA-256 为 `9C2D281BA57BE16ACE71C7E4957BC4687FD5C1EBB54933FAF8FEF28F223EDB84`，与任务单精确一致，未改写。临运行非提权只读设备门通过：`E:` 为唯一 `Kingston DataTraveler Duo` USB 可移动卷，容量在 25～35 GiB，盘符、分区及卷映射唯一；未读取卷内目录或文件。

## 唯一启动与有限结果

仅一次以固定 Windows PowerShell `-NoProfile -ExecutionPolicy RemoteSigned -File <固定脚本>` 启动。Owner 对本次 Windows PowerShell UAC 独立回报：**看到并亲自批准**；未提供密码、截图或原始窗口内容。普通进程约 7.13 秒返回固定类别，父进程退出码 **1**，子进程已知退出码 **102**：

| 字段 | 本次有限分类 |
|---|---|
| `LockStatus` | `UNLOCKED` |
| `ProtectionStatus` | `OTHER`，不能判定为 `ProtectionOn` |
| `VolumeStatus` | `FULLY_ENCRYPTED` |
| `EncryptionPercentage` | `100` |

脚本的固定退出码映射中，`102` 是四字段掩码的保护状态位不匹配；该类别**不区分**其他原始保护值或原因。由此，本次固定 E: 的四字段通过条件未满足，不能写成保护开启，也不能授权真实私钥副本写入。查询预算 **1/1 已耗尽**；没有调整脚本、参数或窗口方式，也没有重试或追加 BitLocker 查询。

本回执只保存有限类别和进程退出结果；未保存原始 BitLocker 对象、异常文本、保护器 ID、卷 GUID、密码、恢复密钥、文件名或内容。没有修改 BitLocker/卷/ACL、写 `E:` 或真实密钥/备份目录，没有连接服务器、DB、云、Docker、GitHub 或访问旧 `D:\EliteSync`。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 2 独立审查门。

## Work 独立审查与静态错误定位（2026-09-25）

**LEVEL 2 REJECT 当前四字段保护状态目标；ACCEPT 本次 UAC 批准与受限字段回执。** Work 核对派发 HEAD、固定脚本哈希、唯一启动及 Owner 亲自批准 UAC 的回执，审查前候选摘要 SHA-256 为 `4CBD828A98561A99E2E5D495F94DAC13B4CECFEA3A29216ACABD81812930A6DB`，尾随空白 0 行，`git diff --check` PASS。`LockStatus=Unlocked`、`VolumeStatus=FullyEncrypted`、百分比 100 在脚本的有限映射下可采信；保护字段的 `OTHER` **不能**用来判断保护关闭。

Work 只读检查本机 Windows `Microsoft.BitLocker.Structures.dll` 的 `BitLockerVolume.ProtectionStatus` 属性类型，枚举值精确为 `Off`、`On`、`Unknown`。AUTH-93/94 脚本把该值与不存在的字符串 `ProtectionOn` 比较，因此保护位必然不匹配；旧 AUTH-80 使用的受限类别不受本脚本此处错误追溯改写。本次原始保护值没有保留，仍 `UNKNOWN`。AUTH-94 查询预算 **1/1 已耗尽**，不得在本任务重试；后继须先静态修复枚举映射，再另立单次只读核验。私钥副本写入继续停止。
