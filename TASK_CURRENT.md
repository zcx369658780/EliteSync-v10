# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-79-USB-LOCKED-STATE-FIELD-DIAGNOSIS`

Risk Level: `LEVEL 2`（Owner 真实加密 U 盘的固定状态字段只读复核）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`，复用现有本地执行会话。Work 独立 LEVEL 2 审查；Owner 只亲自核对并批准本机 UAC，不输入密码或恢复密钥。

## Authority and fixed target

AUTH-77 已接受固定 E: 当次 `FullyEncrypted`、`ProtectionOn`、`Unlocked`、100%。AUTH-78 的 Owner 安全移除/重插回执及重新识别获受限接受，但锁定阶段唯一一次提权查询返回 `FIELD_UNKNOWN`，具体字段未保存；完整锁定/解锁目标被拒，旧预算已耗尽。当前 Owner 尚未输入重插后的解锁密码。此任务只对当前重新插入的固定 `E:`、25～35 GiB USB 可移动 `Kingston DataTraveler Duo` 做一次新的状态字段定位；盘符/型号/容量/唯一 Disk-Partition-Volume 映射不符即停。

## One bounded result

1. 核对本地 `main`、HEAD、任务及工作区，保留两个无关未跟踪目录；只读确认固定 E: 身份，且不读取卷内文件。
2. 准备并静态检查精确只读查询：在提权进程内再次核对设备身份，仅调用一次固定 `E:` 的 `Get-BitLockerVolume`，逐字段将 `VolumeStatus`、`ProtectionStatus`、`LockStatus` 映射到既定有限枚举；`EncryptionPercentage` 映射为 0～100 的整数或 `MISSING/INVALID`。单个字段异常不得遮蔽其余已获得的安全分类。仅把固定分类传回未提权进程，不输出原始对象、异常文本或保护器属性。
3. Owner 在本机亲自核对并批准至多一次 UAC，执行一次提权只读查询；若拒绝、设备身份不符、查询失败或超时，立即停并记脱敏原因。**本任务查询预算 1/1 次**，不重试、不换工具补查。
4. 将各字段的固定分类、哪一字段使 AUTH-78 总体 `FIELD_UNKNOWN`、是否有 `Locked/ProtectionOn/FullyEncrypted` 的直接当次证明，以及未解决项写入唯一允许路径 `EVIDENCE/AUTH-79-USB-LOCKED-STATE-FIELD-DIAGNOSIS/summary.md`。作者报告后停在 Work LEVEL 2 审查门。

若 `LockStatus=Locked`、`ProtectionStatus=On`、`VolumeStatus=FullyEncrypted` 均由本次对象明确返回，可作为**当前重插后锁定**候选；百分比未知仍单独标 UNKNOWN，不补造。此任务不解锁，不验证密码或恢复密钥。不得格式化、写 E:、修改 BitLocker/自动解锁设置、接收或记录秘密、保护器 ID、卷 GUID/序列号、完整原始输出，或提交/推送 Git、派发后继。现有 AUTH-78 与更早任务预算不重置。
