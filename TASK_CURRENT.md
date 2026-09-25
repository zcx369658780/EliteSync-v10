# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-78-USB-REINSERT-LOCK-OWNER-UNLOCK-PROOF`

Risk Level: `LEVEL 3`（Owner 真实加密 U 盘的物理重新接入与本人密码解锁）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex + Owner`。复用现有本地执行会话；Codex 负责固定身份与脱敏只读观察，Owner 亲自安全移除/重插和在可信本机界面输入密码。Work 独立审查和最终接受；Codex 不得自接受。

## Authority and prerequisite

Owner 已授权连续推进 U 盘加密恢复副本路线，并已亲自启用固定 `E:` BitLocker、纸质保管恢复密钥。AUTH-77 Work LEVEL 2 接受当次固定 E: 为 `FullyEncrypted`、`ProtectionOn`、`Unlocked`、100%。本任务只检验重新接入后的锁定与 Owner 密码解锁；不使用或暴露纸质恢复密钥，不演练失钥恢复。执行前重新核对本地 `main`、任务与工作区；两个既有无关未跟踪目录须保留。

## One bounded operation

1. Codex 只读重新核对当前 `E:` 是唯一的 25～35 GiB USB 可移动 `Kingston DataTraveler Duo`，单一分区/卷映射。身份不符立即停。不得读取 U 盘文件内容。
2. Owner 使用 Windows 安全移除功能，亲自物理拔出这只 U 盘一次。Codex 仅核验原 E: 卷不再呈现；若安全移除失败、设备未消失或出现另一候选，停止，不强制移除。
3. Owner 物理重插同一只 U 盘一次，暂不输入解锁密码。Codex 再次核对唯一固定设备身份；若盘符改变、映射不明、系统已自动解锁或系统要求格式化，停止并记录脱敏类别。只允许一次经 Owner 本人核对批准 UAC 的只读 BitLocker 状态查询，预期 `Locked`、`ProtectionOn`、`FullyEncrypted`；不输出原始对象/保护器信息。若无法查询，则锁定证明为 `UNKNOWN`，不以弹窗代替。
4. 仅在锁定状态证明通过后，Owner 在可信 Windows 界面亲自输入密码解锁一次；不向 Codex/Work 展示或提供密码。若失败、恢复密钥被要求或目标不明即停。解锁后 Codex 重新核对固定设备，允许一次经 Owner 本人 UAC 的只读状态查询，预期 `Unlocked`、`ProtectionOn`、`FullyEncrypted` 和 100%。
5. 仅将设备匹配、拔出/重插、锁定与解锁状态的固定脱敏分类及首个失败类别写到 `EVIDENCE/AUTH-78-USB-REINSERT-LOCK-OWNER-UNLOCK-PROOF/summary.md`；不保存密码、恢复密钥、保护器 ID、卷 GUID/序列号、完整原始输出、U 盘文件列表或内容。作者报告后停在 Work LEVEL 3 审查门。

任何一步失败、Owner 不在场或拒绝 UAC 即停止。只允许一次安全移除/物理重插和一次 Owner 密码解锁；锁定与解锁各 1 次提权状态读取预算。不得自动批准 UAC、输入秘密、格式化、加密/解密、修改保护器或自动解锁设置、写入 E:、提交/推送 Git 或派发后继。完成本任务也不证明恢复密钥可用、真实私钥副本或数据库备份/恢复。
