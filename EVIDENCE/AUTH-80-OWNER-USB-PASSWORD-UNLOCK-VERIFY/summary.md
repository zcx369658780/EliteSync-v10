# AUTH-80｜Owner 密码解锁 E: U 盘及解锁后保护状态回执

状态：**作者当次目标候选 PASS，待 Work LEVEL 3 独立 ACCEPT/REJECT**。查询时点：2026-09-25 14:12:48 +08:00。

## 派发、设备与 Owner 交互

- 启动前本地 `D:\EliteSync-v10`、`main`、HEAD `b2776324845d488a845811e18ff56f4f4838dd6d`；`TASK_CURRENT.md` 为 `AUTH-80-OWNER-USB-PASSWORD-UNLOCK-VERIFY`、`ISSUED — NOT STARTED`、派给 Codex + Owner、LEVEL 3。工作区仅有两个任务单点名的无关未跟踪目录，保持原状；本任务只新增本回执。
- 已核对项目入口、风险门、workflow 技能及 AUTH-77～79 的受限接受范围。解锁前、Owner 报告解锁后以及提权查询进程内，固定 `E:` 均通过设备身份门：单一 `Kingston DataTraveler Duo` USB 可移动卷，磁盘约 `28.819 GiB`、在 25～35 GiB 范围，Disk/Partition/卷映射唯一。未访问 U 盘文件内容。
- Owner 在 Windows 可信界面本人输入一次固定 E: 的解锁密码，报告 **解锁成功**；没有向 Codex/Work 提供密码或纸质恢复密钥。Owner 另明确确认本任务的 Windows PowerShell UAC 由本人亲自核对并批准。Codex 未代输密码、代批 UAC，也未移除或重插设备。

## 一次只读状态查询

查询前固定脚本通过 PowerShell 语法解析，且仅含一个字面 `Get-BitLockerVolume -MountPoint 'E:'` 查询点。提权进程再次核对设备身份后，仅执行本任务 **1/1 次**固定 E: 状态读取，通过进程退出码向普通进程传回各字段的有限分类；未传回原始状态对象、异常文本或完整输出。

| 固定字段 | 当次脱敏结果 |
|---|---|
| `LockStatus` | `Unlocked` |
| `ProtectionStatus` | `ProtectionOn` |
| `VolumeStatus` | `FullyEncrypted` |
| `EncryptionPercentage` | `100%` |

本次四字段满足任务单成功标准，首个失败为 `NONE`。它与 Owner 的一次密码解锁回执一起，仅支持**本次固定 E: 的 Owner 密码解锁与解锁后保护状态**。AUTH-79 的先前锁定时点只有 `LockStatus=Locked` 明确，其余字段不可判定；本次解锁后的完整字段不追溯改写那个时点。纸质恢复密钥能否在失钥场景使用、真实私钥及加密副本、数据库完整备份与隔离恢复均未建立。

未读取、接收或记录密码、恢复密钥、保护器 ID、卷 GUID/序列号、原始 BitLocker 对象/完整输出、文件名或内容；未格式化、写 E:、修改保护器或自动解锁设置，也未再次拔插或重复查询。作者不提交、推送、自接受或派发后继，停在 **Work LEVEL 3 独立审查门**。

## Work 独立审查（2026-09-25）

**LEVEL 3 ACCEPT — 仅接受本次固定 E: 的 Owner 密码解锁回执及解锁后保护状态。** Work 核对派发 HEAD、唯一候选文件、Owner 在可信 Windows 界面输入一次密码并报告成功的回执，以及其本人确认批准 UAC。执行记录显示解锁前/后及提权进程内固定 Kingston 身份核对通过；提权脚本仅一次 `Get-BitLockerVolume -MountPoint 'E:'`，只以退出码传回固定字段。回传 `Unlocked/ProtectionOn/FullyEncrypted/100%`；没有原始对象或秘密。Work 未重跑已耗尽查询预算；审查前 SHA-256 为 `3A0E4DC529CDD5775CAAD1BF8D25CEE060359D47EA7AA1B8A55F62C50AC838E0`，另核未跟踪文件尾随空白 0 行。

结合 AUTH-79 新时点 `Locked` 与本任务解锁后状态，可接受该 U 盘本轮重插后锁定、Owner 密码解锁和保护开启的受限证明。纸质恢复密钥在失钥情形下能否使用、真实私钥及 U 盘副本、完整数据库备份和隔离恢复仍未证明；本接受不直接授权写入真实私钥。
