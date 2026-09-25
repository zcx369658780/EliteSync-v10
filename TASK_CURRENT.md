# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-80-OWNER-USB-PASSWORD-UNLOCK-VERIFY`

Risk Level: `LEVEL 3`（Owner 本人在真实加密 U 盘输入密码并验证解锁后保护状态）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex + Owner`，复用现有本地执行会话。Codex 只做设备身份和一次脱敏只读状态核验；Owner 在可信 Windows 界面亲自输入密码、核对 UAC。Work 独立审查。

## Authority and current state

AUTH-77 已接受 E: 在加密完成后当次 `FullyEncrypted/ProtectionOn/Unlocked/100%`。AUTH-78 接受安全移除、原 E: 消失、重插后 Kingston 身份，但完整锁定/解锁目标被拒；AUTH-79 新时点明确返回 `LockStatus=Locked`，锁定时其余字段不可判定。Owner 随后说明曾自行测试可用密码解锁，又拔出重插，因此当前 E: 再次要求输入密码；并提供资源管理器截图。截图与口头报告仅为 Owner 事实，不能代替本任务解锁后状态读取。纸质恢复密钥不用于本任务。

## One bounded operation

1. Codex 先核对本地 `main`、HEAD、任务与工作区，保留两个无关未跟踪目录；只读确认当前 `E:` 唯一对应 25～35 GiB 的 USB 可移动 `Kingston DataTraveler Duo`、单一 Disk/Partition/Volume 映射。身份不符停止。不得访问 U 盘文件内容。
2. 仅在设备身份通过后，Owner 在 Windows 可信界面亲自输入一次 E: 解锁密码并报告成功/失败；不得向 Codex/Work 提供密码或恢复密钥。若 Windows 要求恢复密钥、提示格式化、目标变化或解锁失败，立即停，不尝试其他凭据。
3. Owner 报告解锁成功后，Codex 再次核对 E: 设备身份，然后准备一次固定 `E:` 的提权只读 `Get-BitLockerVolume` 状态读取。若需要 UAC，由 Owner 本人核对并批准。仅将 `LockStatus`、`ProtectionStatus`、`VolumeStatus` 与加密百分比映射为固定脱敏分类；成功标准为 `Unlocked/On/FullyEncrypted/100%`。查询预算 **1/1 次**；失败或字段不明即记录 UNKNOWN，不重试、不换工具。
4. 只在 `EVIDENCE/AUTH-80-OWNER-USB-PASSWORD-UNLOCK-VERIFY/summary.md` 记录 Owner 解锁回执、设备匹配、一次查询的固定状态及首个失败类别。作者报告后停在 Work LEVEL 3 审查门。

不得自动输入密码、读取或记录秘密、保护器 ID、卷 GUID/序列号、原始状态对象、文件名/内容；不得格式化、写 E:、移除/重插、改变保护器/自动解锁设置、提交/推送 Git 或派发后继。成功仅证明本次 Owner 密码解锁及解锁后保护状态；纸质恢复密钥的实际失钥恢复、真实私钥副本及数据库备份/恢复仍未建立。
