# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-76-OWNER-USB-BITLOCKER-ENABLEMENT`

Risk Level: `LEVEL 3`（Owner 设备的真实 U 盘加密和恢复信息；Owner 交互及 Work 高风险门）

Status: `PREPARED — OWNER OFFLINE RECOVERY STORAGE INPUT REQUIRED`（未下达执行，Codex 不得启动）

Assignee when issued: `Work + Owner`。Work 负责精确设备复核、打开可信本机 BitLocker 界面与脱敏记录；Owner 本人批准必要 UAC、设置密码、保存恢复密钥并完成交互。Codex 只可在后继独立任务中做已授权的只读验证。

## Authority and pending input

Owner 已指定并授权使用 `E:\` 32GB U 盘，允许必要时快速格式化，不采用云同步，密码由 Owner 本人输入。AUTH-72～75 受限事实/合同已接受：E 为单一 USB 可移动 FAT32 卷、约 28.802 GiB，根目录唯一可见项是 Windows 系统元数据；当前未提权状态查询 ACCESS_DENIED，实际保护状态 UNKNOWN。系统为 Windows Professional。**唯一待 Owner 明确的执行前决定**：BitLocker 恢复密钥的独立离线保管方式。默认建议写在纸上并与电脑、U 盘分开保管；不得发到聊天、存到云、Git、普通证据或同一 U 盘。Owner 尚未答复前保持 PREPARED。

## Proposed single bounded operation after Owner answer

1. Work 先重新核对 `D:\EliteSync-v10` 本地任务状态，再只读确认 `E:\` 仍唯一映射到 25～35 GiB 的可移动 USB；不符即停止。核对根目录无非系统用户数据；不删除系统目录。
2. 仅打开 Windows 本机 BitLocker To Go 交互界面，不用命令参数或脚本传递密码/恢复密钥。Owner 核对界面目标为上述 E 盘，自行批准可能出现的 UAC；提示目标不明或失败即停止。
3. Owner 在可信界面亲自设置 U 盘解锁密码，并按其已确认的离线方式保存、核对恢复密钥。Work/Codex 不观看、接收、复制或记录秘密。若界面要求云端保存或无法完成离线保管，停止，不启动加密。
4. 仅对准确核对的 E 盘启用 BitLocker To Go。若向导提供“仅加密已用空间”可在无已知用户数据的条件下选用；其余模式由实际界面和设备兼容性判断。当前系统元数据目录不构成格式化必要性；若界面要求先格式化/改文件系统，停止本任务，另立精确快速格式化步骤，不临场切换。
5. 加密启动后只记录脱敏阶段状态和异常类别，不将向导完成声明当作独立验收。后继单独任务须核验卷完全加密/保护开启、移除重插后锁定、Owner 密码解锁，以及恢复信息可被 Owner 找到。上述门未通过前不写真实私钥副本。

## Stop

本 PREPARED 文档本身不授权任何操作；不得自动提权、格式化、加密、解锁、写盘或要求 Owner 在聊天中提供秘密。若 Owner 选择不启动或离线恢复信息安排未定，保持停点。真实密钥生成、副本写入及失钥演练仍各需独立任务和风险门。
