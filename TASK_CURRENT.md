# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-74-USB-BITLOCKER-ACCESS-DIAGNOSIS-READONLY`

Risk Level: `LEVEL 2`（Owner 指定 U 盘加密能力与权限的只读定位；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付固定本机加密能力与权限的脱敏只读回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-72/73 已确认当次 `E:\` 是单一 USB 可移动卷；根目录唯一条目为 Windows 系统元数据，未观察到用户数据。两种 BitLocker 状态查询分别失败，卷保护仍 UNKNOWN。Owner 已授权使用及必要时快速格式化准确核对后的 E 盘，但格式化不会自行建立加密保护。Work 只读读取 Windows EditionID 为 `Professional`；仍不证明当前进程有管理 BitLocker 的权限。本任务定位查询失败的安全类别与可用加密入口，不格式化或启用加密。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区、任务 ID/状态/派发；读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本文件、`REVIEW_GATE.md`、本地 workflow 技能及 AUTH-69/70/72/73 验收。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 与 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/__pycache__/`，不得移动、删除或纳入提交。状态或派发不匹配即停。
- 只允许新增 `EVIDENCE/AUTH-74-USB-BITLOCKER-ACCESS-DIAGNOSIS-READONLY/summary.md`；不写脚本或其他路径。先只读复核 E: 为单一匹配 USB 可移动卷、容量 25～35 GiB，失败即停。
- 一次只读确认当前 Windows EditionID、BitLocker PowerShell 模块/命令存在、固定系统路径的 `manage-bde.exe` 存在、当前进程管理员令牌是否启用；只输出固定枚举/布尔，不输出账号、组、卷序列号或原始权限信息。不要搜索用户主目录或安装新软件。
- 在设备身份门通过后，允许对 `E:` 各最多一次新的只读 `Get-BitLockerVolume` 与 `manage-bde -status` 状态尝试，以有限时间/输出缓冲捕获到本机内存；只将退出码和异常归类为 ACCESS_DENIED / NOT_SUPPORTED / INVALID_VOLUME / TOOL_FAILURE / OTHER / SUCCESS，若输出能安全解析固定保护/转换/锁定字段则返回状态，否则 UNKNOWN。不得显示或保存原始 stdout/stderr、恢复密钥、保护器 ID、卷 GUID、序列号、用户名或任何密码。第二种查询即使第一种失败也只用于本任务的诊断，不重用 AUTH-72/73 已耗预算；两种均失败不反复尝试。
- 可只读核对固定已安装路径 `C:\Program Files\VeraCrypt\VeraCrypt.exe` 与 `C:\Program Files (x86)\VeraCrypt\VeraCrypt.exe` 是否存在，仅报告存在性；不得启动、下载或安装。回执明确区分操作系统可用性、当前令牌权限、实际 E 盘保护状态及下一步是否需 Owner 在场批准系统提权/输入密码。 `git diff --check` 最多 1 次，新文件另查尾随空白。

## Stop and review

不得格式化、删除、加密、解锁、写入 E 盘；不得启动 UAC、提权、改变策略、安装软件或要求 Owner 输入密码。不得 SSH、CloudShell、云 API、Docker、真实 DB、备份/密钥目录内容、账号/Token/消息/媒体或旧 `D:\EliteSync`。Codex 不提交、制作 bundle、推送、自接受或派发后继。停在 Work LEVEL 2 独立审查门。
