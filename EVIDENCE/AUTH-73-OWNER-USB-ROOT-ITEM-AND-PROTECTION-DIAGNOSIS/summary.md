# AUTH-73｜Owner 指定 E: U 盘根条目与保护状态只读定位

状态：**作者受限事实候选，待 Work LEVEL 2 独立 ACCEPT/REJECT**。查询时点：2026-09-25 13:01:27 +08:00。

## 入口与只读范围

- 执行前为本地 `D:\EliteSync-v10`、`main`、HEAD `746048d20fca0b3861a68cb28f1a99af6f52d55d`；工作区仅有任务单指定的两个无关未跟踪目录，均保留原状。`TASK_CURRENT.md` 为 `AUTH-73-OWNER-USB-ROOT-ITEM-AND-PROTECTION-DIAGNOSIS`、`ISSUED — NOT STARTED`、派给 Codex、LEVEL 2。
- 已读项目入口、产品决定、风险门、workflow 技能及 AUTH-69/70/72 接受证据。本任务仅新增本 `summary.md`；没有写脚本、控制文件或 U 盘。

## 当次脱敏观察

| 检查 | 结果 |
|---|---|
| 固定 E: 身份门 | 单一可移动 USB 卷、同分区/磁盘匹配、`28.802 GiB`、FAT32；指定 25～35 GiB 范围内，`PASS` |
| E: 根目录一次 `-Force`、非递归枚举 | 条目总数 **1**；精确名称匹配固定 allowlist 类别 `SYSTEM_VOLUME_INFORMATION`；目录、隐藏、系统属性均为 `True` |
| 根目录用户数据观察 | `NO_USER_DATA_OBSERVED_AT_ROOT`；仍为物理 `NONEMPTY`，不证明子目录或整盘无用户数据 |
| 一次独立 `manage-bde -status E:` | 在限定 `32,768` 字节 stdout/stderr 缓冲与 `15` 秒等待内，工具返回非零；脱敏类别 `NONZERO_EXIT`，原始输出未保存或显示 |
| 卷转换 / 保护 / 锁定 | 均为 `UNKNOWN`；未重试或换工具 |

首个未闭合的后继门为 `ENCRYPTION_STATUS_UNKNOWN`，其本次定位类别是 `NONZERO_EXIT`。根目录的固定系统元数据类别解释了 AUTH-72 的一项计数，但不改变 AUTH-72 当次 `NONEMPTY` 事实，也不证明该 U 盘已受加密保护或可以写入私钥恢复副本。未来真实加密、Owner 交互输入及副本写入仍须独立授权与审查。

收尾：`git diff --check` 按预算 **1/1 次**退出 0、无输出；不覆盖未跟踪的新文件。本文件另做只读尾随空白检查，**0 行**。

没有输出条目原名、路径、哈希或 `manage-bde` 原始输出；未读取条目内容、子目录或文件数据。未删除、格式化、加密、解锁、复制或写入 U 盘；未访问其他可移动盘、备份/密钥目录内容、Owner 密码、SSH、云 API、Docker、真实 DB、业务数据或旧 `D:\EliteSync`。无真实私钥、副本、备份或恢复证明。作者不提交、制作 bundle、推送、自接受或派发后继，停在 **Work LEVEL 2 独立审查门**。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT — 仅接受当次 `E:` 根条目固定类别与加密查询失败事实。** Work 核对派发 HEAD `746048d20fca0b3861a68cb28f1a99af6f52d55d`、唯一候选文件和 AUTH-72 的范围；作者报告同一 USB 身份、根目录唯一项符合 `SYSTEM_VOLUME_INFORMATION` 类别、目录/隐藏/系统属性均真，一次 `manage-bde -status E:` 返回非零。Work 未重查原始卷对象或错误输出；接受的只是作者脱敏回执。作者 `git diff --check` 1/1 退出 0；Work 对未跟踪新文件另查尾随空白 0 行。审查前 SHA-256 为 `3E5A907532F9DA017BD248789F7F34144EC7E98C2F58979E05CAC7406AF9BF56`。

根目录没有观察到用户数据，不证明整盘无数据或已加密；转换、保护与锁定仍 `UNKNOWN`。Owner 随后明确授权可快速格式化 `E:`，这是后续独立任务的权限，不追溯改变本次只读观察，也不自动证明格式化必要或加密可行。本任务未删除、格式化或写入 U 盘；无真实私钥、副本或恢复证明。
