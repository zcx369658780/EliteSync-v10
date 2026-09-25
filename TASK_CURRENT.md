# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-73-OWNER-USB-ROOT-ITEM-AND-PROTECTION-DIAGNOSIS`

Risk Level: `LEVEL 2`（Owner 指定 U 盘只读条目分类与加密状态定位；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付固定 `E:\` 的脱敏只读定位回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-72 当次接受事实：Owner 指定的 `E:\` 为单一可移动 USB 卷，FAT32、约 28.802 GiB，但根目录含 1 项，性质未知；BitLocker 工具可解析而固定卷状态查询失败，保护/锁定仍 UNKNOWN。Owner 已授权使用 E 盘且称其为空，不采用云同步。本任务仅判断根条目是否属于固定已知系统元数据类别，并用一次独立只读工具查询定位卷保护状态；不删除、格式化、加密、解锁或写入。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区、任务 ID/状态/派发；读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本文件、`REVIEW_GATE.md`、本地 workflow 技能及 AUTH-69/70/72 验收。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 与 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/__pycache__/`，不得移动、删除或纳入提交。状态或派发不匹配即停。
- 只允许新增 `EVIDENCE/AUTH-73-OWNER-USB-ROOT-ITEM-AND-PROTECTION-DIAGNOSIS/summary.md`，不写脚本或其他路径。先只读复核 E 盘仍为单一匹配 USB 可移动卷、25～35 GiB、同分区关系；失败即停，不查看根条目或加密状态。
- 身份通过后，仅一次 `E:\` 根目录 `-Force`、非递归枚举，内存中取得条目名称/属性但不读取内容、子目录或文件数据。若恰为一项且精确名称属于固定系统元数据 allowlist（`System Volume Information` 或 `$RECYCLE.BIN`），仅输出对应固定类别、目录/隐藏/系统属性布尔；其他名称只输出 `OTHER_OR_UNKNOWN`，不得输出原名、哈希或路径。若不止一项/出现异常，停止分类并保留 NONEMPTY。即使是系统元数据，也不删除或视为物理空盘，只可标记 `NO_USER_DATA_OBSERVED_AT_ROOT`，不能证明整个盘无用户数据。
- 身份通过后，只允许一次独立于 AUTH-72 的 `manage-bde -status E:` 只读查询；限定输出字节数与等待时间，在本机内存仅解析卷转换/保护/锁定的固定状态，不保存或显示原始输出、恢复密钥、保护器 ID 或卷序列号。解析不全、访问被拒、工具非零或输出超限即报告脱敏类别及 UNKNOWN，不重试或换工具。可一次读取本机 Windows EditionID 的非敏感系统元数据，但它不替代卷保护状态。
- 回执只记查询时点、设备匹配、根条目固定类别/计数、加密状态或 UNKNOWN、失败类别。不得以一项系统目录推导已加密或可写入私钥；后继真实加密仍需 Owner 交互输入与独立任务。 `git diff --check` 最多 1 次，新文件另查尾随空白。

## Stop and review

不得 SSH、CloudShell、云 API、Docker、真实 DB、备份/密钥目录内容、Owner 密码、账号/Token/消息/媒体或旧 `D:\EliteSync`；不得递归枚举、读取 U 盘条目内容、删除、格式化、加密、解锁、复制或写入。Codex 不提交、制作 bundle、推送、自接受或派发后继。停在 Work LEVEL 2 独立审查门。
