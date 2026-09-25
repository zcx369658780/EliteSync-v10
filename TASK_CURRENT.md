# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-72-OWNER-USB-IDENTITY-ENCRYPTION-READONLY`

Risk Level: `LEVEL 2`（Owner 指定 U 盘的只读身份、空盘与加密能力核验；Work 独立审查）

Status: `ACCEPTED — CLOSED`（Work LEVEL 2；仅 `E:\` 当次只读受限事实，见 `EVIDENCE/AUTH-72-OWNER-USB-IDENTITY-ENCRYPTION-READONLY/summary.md`）

Assignee: `Codex`。只交付固定 `E:\` U 盘的脱敏只读事实回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 已明确指定当前空的 `E:\` 32GB U 盘，授权将其用于密码保护私钥的加密恢复副本；备份与密钥均不采用云同步。密码只由 Owner 本人输入。Work 当次只读观察 `E:` 为 USB 可移动卷、约 30.9 GB、FAT32；未核验盘内为空或加密状态。AUTH-69 要求先核验设备身份与加密保护，再写入恢复副本。本任务只读观察，不格式化、加密、解锁或写盘。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区、任务 ID/状态/派发；读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本文件、`REVIEW_GATE.md`、本地 workflow 技能及 AUTH-49/69/70 验收。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 与 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/__pycache__/`，不得移动、删除或纳入提交。状态或派发不匹配即停。
- 只允许新增 `EVIDENCE/AUTH-72-OWNER-USB-IDENTITY-ENCRYPTION-READONLY/summary.md`；不写脚本、E 盘、控制文件或其他路径。固定查询仅针对字面 `E:\`：当前卷类型、总量/剩余量、文件系统、物理连接类型、对应磁盘/分区匹配与卷健康状态。核对可移动 USB、容量在 25～35 GiB、单一目标；如果 E 指向不同设备、多个候选或权限不明，停止后续查询并报告身份 UNKNOWN。
- 在设备身份门通过后，最多一次只读、非递归检查卷根目录**条目总数**（含隐藏/系统条目），只输出整数和 EMPTY/NONEMPTY/UNKNOWN，不输出文件名或读取内容；任何条目存在即不得作空盘结论。不得查询其他盘或格式化。
- 在设备身份门通过后，只读检查本机对该固定卷的加密能力及当前保护状态：可用的 BitLocker To Go / 系统工具、是否已有卷保护、是否锁定、失败类别。每种固定状态查询最多一次；不得启用保护、创建恢复信息、显示恢复密钥、保护器 ID、卷序列号或原始命令输出。工具不可用或解析不确定则 `UNKNOWN`，不下载或安装替代软件。FAT32/容量事实不证明适合存放完整备份；本 U 盘当前仅作私钥恢复副本候选。
- 回执只保存脱敏设备匹配、容量/文件系统、根条目计数、加密能力和保护状态、首个失败/UNKNOWN、查询时点。不能将 Owner 的“空盘”声明替代读回结果，也不能以可用加密命令推定已加密。 `git diff --check` 最多 1 次，新文件另做只读尾随空白检查。

## Stop and review

不得 SSH、CloudShell、云 API、Docker、真实 DB、备份/密钥目录内容、Owner 密码、账号/Token/消息/媒体或旧 `D:\EliteSync`。不得格式化、清空、加密、解锁、复制、写入 U 盘或访问其他可移动盘；不得创建私钥、备份、恢复或改库。Codex 不提交、制作 bundle、推送、自接受或派发后继。停在 Work LEVEL 2 独立审查门。
