# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-94-USB-BITLOCKER-OWNER-UAC-RETRY-READONLY`

Risk Level: `LEVEL 2`（Owner 明确要求的第二次、独立预算 E: BitLocker 只读核查）

Status: `ISSUED — ONE NEW ATTEMPT AUTHORIZED`

Assignee: `Codex + Owner`，复用现有本地执行会话；Codex 只执行固定脚本一次并交付有限回执，Work 独立 LEVEL 2 审查。Owner 本人核对并批准可能出现的 Windows PowerShell UAC。

## Authority and fixed boundary

AUTH-93 的唯一一次启动返回 `UAC_OR_LAUNCH_FAILED`，当前保护状态未取得，旧 1/1 预算耗尽。Owner 说明可能在打字时误取消 UAC，并明确要求“重新触发一次”。本任务基于该新授权提供**一张独立任务单、仅一次新尝试**，不追溯改写 AUTH-93。复用经 Work 静态审查的精确只读脚本 `EVIDENCE/AUTH-93-CURRENT-USB-BITLOCKER-READONLY-PREFLIGHT/owner-usb-bitlocker-readonly.ps1`，SHA-256 必须为 `9C2D281BA57BE16ACE71C7E4957BC4687FD5C1EBB54933FAF8FEF28F223EDB84`；不得修改脚本或参数。

## One bounded result

1. 核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区、AUTH-79/80/93 接受边界并保留无关未跟踪内容。临运行只读核对固定脚本哈希精确匹配，当前 `E:` 为唯一 `Kingston DataTraveler Duo` USB 可移动卷，容量 25～35 GiB、分区/卷映射唯一；任一不符立即停止，不启动 UAC。不得读取 U 盘文件或私钥正文。
2. 仅以固定 Windows PowerShell、`-NoProfile -ExecutionPolicy RemoteSigned -File <上述脚本>` **启动一次**。脚本内部普通/提权身份门及唯一 `Get-BitLockerVolume -MountPoint 'E:'` 均不修改。Owner 本人核对 Windows PowerShell UAC，只在相符时批准。提权查询预算 **1/1**，无论 UAC 是否出现或通过，脚本启动即耗尽；不调整窗口、参数或启动方式重试。
3. 只记录父进程固定 `AUTH93_RESULT` 类别、退出码，以及 Owner 对 UAC 是否看到/批准的独立回执；不保存原始 BitLocker 对象、异常文本、保护器 ID、卷 GUID、密码、恢复密钥或文件列表。把受限执行回执写入 `EVIDENCE/AUTH-94-USB-BITLOCKER-OWNER-UAC-RETRY-READONLY/summary.md`。若成功四字段均匹配，也仅证明本次固定卷 `Unlocked/ProtectionOn/FullyEncrypted/100%`，不授权本任务写 U 盘。作者停在 Work LEVEL 2 独立审查，不提交、推送、自接受或派发后继。

禁止修改 BitLocker/卷/ACL，写 `E:`、密钥或备份目录，读取私钥正文，连接服务器/DB/云/Docker/GitHub，访问旧 `D:\EliteSync`。若本次再次失败，当前状态仍 `UNKNOWN`，需另行定位，不得自动发起第三次。
