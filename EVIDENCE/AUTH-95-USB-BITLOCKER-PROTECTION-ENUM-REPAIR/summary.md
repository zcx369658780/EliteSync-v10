# AUTH-95｜固定 E: BitLocker 枚举修复后单次只读回执

状态：**作者受限运行回执，待 Work LEVEL 2 独立审查。** 运行完成时点：2026-09-25 18:16:58 +08:00。

## 授权与临运行门

- 本地 `D:\EliteSync-v10`、`main`，Phase B 启动 HEAD `c4fde1b29445f4d40cf2a86225c2e59a8a976806`；`TASK_CURRENT.md` 为 `AUTH-95-USB-BITLOCKER-PROTECTION-ENUM-REPAIR`、`ISSUED — PHASE B RELEASED; OWNER UAC AND QUERY PENDING`、LEVEL 2。Work 已在同目录 `plan.md` 独立审查并放行一次固定只读查询。两个既有无关未跟踪目录保留。
- 固定脚本 `owner-usb-bitlocker-readonly.ps1` 的临运行 SHA-256 为 `DB45FD59BC587850F20042EDAE6C46D4AA6BA9D291E84614F79A33F81EA04861`，与放行值一致，未修改。新旧脚本差异与本机 `Off/On/Unknown` 枚举静态核验见 `plan.md`；AUTH-93/94 旧预算均已耗尽，未复用。
- 临运行非提权只读设备门通过：固定 `E:` 为唯一 `Kingston DataTraveler Duo` USB 可移动卷，容量在 25～35 GiB，盘符、分区及卷映射唯一。没有读取卷内目录或文件。

## 唯一启动与有限结果

仅一次使用固定 Windows PowerShell `-NoProfile -ExecutionPolicy RemoteSigned -File <本任务固定脚本>` 启动。Owner 对本次 UAC 独立回报：**看到 Windows PowerShell UAC 并亲自批准**；未提供密码、截图或原始窗口内容。运行约 4.99 秒，父进程退出码 **0**，唯一固定回执为 `AUTH95_RESULT=ALL_FOUR_MATCH;CHILD_EXIT=0`。

经已审查脚本的成功分支，只有提权进程再次通过固定 E: 身份门、一次 `Get-BitLockerVolume -MountPoint 'E:'` 返回唯一状态对象，并且 `LockStatus=Unlocked`、真实 `ProtectionStatus` 枚举为 `On`、`VolumeStatus=FullyEncrypted`、`EncryptionPercentage=100` 同时满足，才传出子进程 0 并由父进程报告 `ALL_FOUR_MATCH`。因此作者报告本次固定 E: 四字段受限只读核验通过，仍待 Work 独立 LEVEL 2 验收。没有保存原始状态对象或独立第二次查询。

本任务新提权查询预算 **1/1 已耗尽**，没有更改脚本、参数或窗口方式，也没有重试。此次状态不证明纸质恢复密钥在失钥时可用、真实私钥副本已写入、数据库备份或恢复；实际写入须另立任务。本轮未读取 U 盘文件或私钥正文，未修改 BitLocker/ACL/卷，未写 `E:`、密钥或备份目录，未连接服务器/DB/云/Docker/GitHub，未访问旧 `D:\EliteSync`。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 2 独立审查门。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT 本次固定 E: 四字段只读状态。** Work 对照新旧脚本受限 diff、修正后的真实枚举 `On` 判断、固定哈希、唯一运行记录和 Owner 亲自批准 UAC 的回执；审查前候选摘要 SHA-256 为 `E3CB935926EC90F03F7CDD50AE4D0B2B91F8C33E62D6831A23EC72E8C7889D9F`，尾随空白 0 行，`git diff --check` PASS。固定 `ALL_FOUR_MATCH;CHILD_EXIT=0` 只有提权端再次通过唯一 Kingston 身份门、一次查询返回 `Unlocked/On/FullyEncrypted/100` 后才能出现。Work 未重跑已耗尽的 1/1 查询预算。

接受仅限该时点的加密卷状态，不证明重新锁定后的保护、纸质恢复密钥实际可用、恢复副本或数据库备份。Work 随后非提权只读观察当前 E 仍为 Kingston USB Removable、FAT32、可用 30,925,275,136 bytes，两个拟定根目录文件名尚不存在；这些观察不替代未来写入前的同进程保护状态门。
