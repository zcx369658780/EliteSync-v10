# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-77-USB-BITLOCKER-PROTECTION-READONLY`

Risk Level: `LEVEL 2`（Owner 真实 U 盘的加密状态读取；可能需要 Owner 批准本机 UAC）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。复用现有本地执行会话。Work 独立 LEVEL 2 审查；Owner 仅亲自批准准确核对目标后的本机 UAC，不向 Codex 提供密码或恢复密钥。

## Authority and fixed target

AUTH-76 的 Owner 回执见 `EVIDENCE/AUTH-76-OWNER-USB-BITLOCKER-ENABLEMENT/summary.md`：Owner 报告 E: 加密完成，实际恢复密钥已纸质记录、核对并与电脑/U 盘分开。**这是未独立验证的回执。** 本任务只读核验同一只 `E:`、25～35 GiB 的 USB 可移动 `Kingston DataTraveler Duo`，Disk/Partition 与卷一一映射；任何身份不符立即停止。工作区两个既有无关未跟踪目录须保留。

## One bounded result

在重新复核本地任务与设备身份后，用 Windows 本机 BitLocker 状态读取，分别将 `VolumeStatus`、`ProtectionStatus`、`LockStatus` 和加密百分比归为固定脱敏值，并保存到 `EVIDENCE/AUTH-77-USB-BITLOCKER-PROTECTION-READONLY/summary.md`。读取若需管理员权限，可准备精确的只读本机命令/脚本并由 Owner 亲自核对和批准 UAC；不得自动批准、输入凭据或修改策略。先尝试一次当前令牌读取；若 `ACCESS_DENIED`，只允许一次经 Owner UAC 的提权读取。每种尝试预算 1 次，失败即记录原因并停，不换工具反复探测。

只记录脱敏分类和目标匹配结果，不记录恢复密钥、密码、保护器 ID、卷 GUID/序列号、原始完整输出或文件内容。不要格式化、解锁、加密、解密、暂停/恢复保护、添加/删除保护器、移除或重插设备、写入 E:。若不能独立读取，保护状态保持 `UNKNOWN`，不得将 Owner 回执升级为证明。

成功标准仅为当次固定 E: 的 `FullyEncrypted`、`ProtectionOn`、`Unlocked` 与 100% 加密（若 Windows 返回这些字段）。此结果只证明当次状态，不证明重新插入会锁定、Owner 密码可解锁或恢复密钥可用；这些留给后继独立任务。作者交候选与证据后停在 Work LEVEL 2 审查门，不提交、不推送、不自接受、不派发后继。
