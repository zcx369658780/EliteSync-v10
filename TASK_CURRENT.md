# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-75-OWNER-BITLOCKER-TO-GO-INTERACTIVE-CONTRACT`

Risk Level: `LEVEL 2`（Owner 在场的 U 盘加密实施前合同；实际启用属于独立高风险操作）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付一份 docs-only 的 Owner 交互操作与验收合同，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 指定 `E:\` 32GB U 盘用于密码保护私钥的加密恢复副本，授权必要时快速格式化，但不接受云同步。AUTH-72～74 的当次事实：E 为单一 FAT32 可移动 USB 卷、约 28.802 GiB；根目录唯一可见项为 Windows `System Volume Information`，未观察到用户数据；当前未提权进程的两种 BitLocker 状态查询为 ACCESS_DENIED，卷保护 UNKNOWN。Windows EditionID 为 Professional，固定 VeraCrypt 路径未发现。格式化系统元数据目录并不能解决管理权限。本任务只准备可让 Owner 最终审查的 BitLocker To Go 交互步骤，不打开系统界面、不触发 UAC、不格式化或加密。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区、任务 ID/状态/派发；读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本文件、`REVIEW_GATE.md`、本地 workflow 技能及 AUTH-49/69/70/72～74 验收。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 与 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/__pycache__/`，不得移动、删除或纳入提交。状态或派发不匹配即停。
- 只允许新增 `EVIDENCE/AUTH-75-OWNER-BITLOCKER-TO-GO-INTERACTIVE-CONTRACT/plan.md`。不修改历史、控制文件、源码或配置。仅文档；不得调用 BitLocker 工具或打开系统 UI。
- 计划必须按顺序写明：在实际操作前重新核对 E 与 28.8 GiB USB 的唯一映射；如需管理员提示仅由 Owner 在本机批准；只选择 E 盘的 BitLocker To Go；密码仅由 Owner 亲自输入，不能让 Codex 接收；恢复密钥由 Owner 选择并保存在独立离线位置，绝不可保存在 U 盘本身、聊天、Git、普通证据或云端。若 Owner 尚未确认恢复密钥离线保管方式，则保持操作停点，不启动加密。
- 说明当次根目录只有系统元数据，通常不必为此格式化；Owner 的快速格式化授权仍有效，但若界面要求更换文件系统或确有需要，应另立精确任务并再次核对目标。不要写自动执行格式化命令。若采用 BitLocker 向导，空盘可考虑“仅加密已用空间”，但必须说明选项和兼容性由实际界面确认，不推定该机一定提供。
- 计划须包括独立验收：向导完成后核验 E 盘保护开启和加密完成，移除/重新接入后锁定与 Owner 密码解锁，恢复密钥可由 Owner 找到且未进入普通证据；之后才可另立真实私钥生成/副本任务。任何 UAC 拒绝、设备身份变化、向导失败、恢复密钥无法离线保管或保护状态不可证，均停止，不写私钥。仅保存脱敏状态、容量/设备匹配、失败类别与时间；不记录密码或恢复密钥。
- `git diff --check` 最多 1 次，新文件另查尾随空白。作者不提交、制作 bundle、推送、自接受或派发后继。

## Stop and review

不得连接服务器、真实 DB、云 API、Docker；不得读取备份/密钥目录内容、U 盘文件内容、Owner 密码或旧 `D:\EliteSync`。不得打开 UI、触发 UAC、提权、格式化、删除、加密、解锁、复制、写入 E 盘或创建真实密钥。停在 Work LEVEL 2 独立审查门。
