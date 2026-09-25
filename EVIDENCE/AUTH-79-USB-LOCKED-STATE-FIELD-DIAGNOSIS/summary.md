# AUTH-79｜重插 E: U 盘锁定状态字段只读定位

状态：**作者受限字段候选，待 Work LEVEL 2 独立 ACCEPT/REJECT**。查询时点：2026-09-25 14:03:11 +08:00。

## 派发与设备门

- 执行前本地 `D:\EliteSync-v10`、`main`、HEAD `388a5788e554efe74b8c1a5731d3732c9417f744`；`TASK_CURRENT.md` 为 `AUTH-79-USB-LOCKED-STATE-FIELD-DIAGNOSIS`、`ISSUED — NOT STARTED`、派给 Codex、LEVEL 2。仅有两个任务单点名的无关未跟踪目录，均保持原状；本任务只新增本回执。
- 已核对项目入口、风险门、workflow 技能与 AUTH-77/78 的接受边界。固定 `E:` 在普通令牌及提权进程内均核对为单一匹配的 `Kingston DataTraveler Duo` USB 可移动卷，磁盘约 `28.819 GiB`、处于 25～35 GiB，Disk/Partition/卷映射唯一；未读取卷内文件。
- AUTH-78 的原锁定阶段 1/1 预算已耗尽，且其 `FIELD_UNKNOWN` 未保留具体字段。本任务仅使用新下达的 **1/1 次**提权只读查询，不追溯修改旧事实。

## 静态门与一次读取

提权前对固定脚本文本做 PowerShell 语法解析：**PASS**；静态核对仅一个字面 `Get-BitLockerVolume -MountPoint 'E:'` 查询点及四个独立字段映射函数。`VolumeStatus`、`ProtectionStatus`、`LockStatus` 分别归到有限枚举或 `MISSING_OR_INVALID`；`EncryptionPercentage` 独立归到 0～100、`MISSING` 或 `INVALID`。百分比缺失或越界不会覆盖前三个字段。提权后又对纯虚构对象做函数调用语义检查，固定的 `FullyEncrypted/On/Locked` 分别映射为对应枚举；该检查未访问 E:。

Owner 已亲自回复“已核对并批准”本机 UAC；提权进程再次核对设备身份，仅一次读取固定 E: 的 BitLocker 状态对象，通过退出码向普通进程传回固定分类。无原始对象、异常文本或完整工具输出传回或保存。本任务查询预算 **1/1 次**，结果如下：

| 字段 | 当次脱敏分类 | 证明边界 |
|---|---|---|
| `LockStatus` | `LOCKED` | 本次直接锁定状态候选 |
| `ProtectionStatus` | `UNKNOWN` | 本次不能证明 `ProtectionOn` |
| `VolumeStatus` | `MISSING_OR_INVALID` | 本次不能证明 `FullyEncrypted`；未保留原始值，无法再细分 |
| `EncryptionPercentage` | `MISSING` | 本次不能证明 100%；不覆盖锁定字段 |

本轮直接支持重插后当前 E: 的 `Locked` 字段；**不满足**任务单所述 `Locked/ProtectionOn/FullyEncrypted` 三字段同时明确返回的完整锁定候选条件。AUTH-78 的 `FIELD_UNKNOWN` 原次由哪一具体字段触发仍不能事后确定；本次的 `VolumeStatus` 未映射、百分比缺失与 `ProtectionStatus=UNKNOWN` 分别足以使旧全字段门不能通过，但仅是新时点观察。AUTH-77 的先前 `FullyEncrypted/ProtectionOn/Unlocked/100%` 不补作本次状态。

未解锁、输入密码或恢复密钥，未移除/重插设备、写 E:、格式化、修改保护器/自动解锁/系统策略，也未读取保护器 ID、卷 GUID/序列号、文件名或内容。无密码解锁、纸质恢复密钥可用、真实私钥副本或数据库备份/恢复证明。作者不提交、推送、自接受或派发后继，停在 **Work LEVEL 2 独立审查门**。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT — 仅接受新时点固定 E: 的 `LockStatus=Locked` 及其余字段不可判定的受限事实。** Work 核对派发 HEAD、唯一候选文件与执行记录：脚本在提权进程再次验证设备身份，固定 `Get-BitLockerVolume -MountPoint 'E:'` 只调用一次，通过退出码传回独立字段分类，没有传回原始对象或秘密。结果为 `LOCKED`、保护 `UNKNOWN`、转换 `MISSING_OR_INVALID`、百分比 `MISSING`。这解释 AUTH-78 全字段门为何仍不能满足，但不能追溯确定 AUTH-78 当次具体哪个字段异常；不宣称本次保护开启或完全加密。Work 未重跑已耗尽预算；审查前 SHA-256 为 `073F9D50AA7BC16AA759873B9CF494423324E699F2DAF72B0B6A58F3F435BCD3`，另核未跟踪文件尾随空白 0 行。

Owner 随后说明曾亲自测试 E: 可以用密码解锁，之后又拔出重插，当前再次锁定，并提供显示 E: 带锁标识的资源管理器截图。这是**独立 Owner 回执**，其操作先后并非 AUTH-79 查询日志所证；截图没有作为本任务原始状态证据或纳入 Git，也不能把本次锁定时的 `UNKNOWN` 字段改判。解锁后的保护状态须另立任务只读核验。
