# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-97-OWNER-VISIBLE-USB-KEY-PAIR-COPY-RETRY`

Risk Level: `LEVEL 3`（真实加密私钥固定 E: 恢复副本写入）

Status: `ACCEPTED — CLOSED; 1/1 OWNER MANUAL START USED`

Assignee: `Codex`，复用现有本地执行会话；Work 独立预运行审查并决定是否放行 Phase B。Owner 已请求在其到场时重新触发一次。本任务是新预算；AUTH-96 的 1/1 启动已耗尽且保持关闭。

## Phase A — candidate only

1. 核对本地 `main`、HEAD、工作区、AUTH-96 失败回执及原脚本 SHA-256 `A79C3715E2DD08085D8BD0AEEEBE5388A0A9C2ADE197C656C6DD7EF032C6EB6C`。只读核对固定两源：私钥非重解析、2666 bytes、加密 PKCS#8 首行、当前用户 Owner、继承关闭且仅当前用户/SYSTEM/Administrators 三条显式 FullControl；公有证书非重解析、1541 bytes、公开 DER 指纹与 AUTH-91 相符。仅逐个核对 E: 两个精确目标不存在、当前 E: 仍唯一映射 `Kingston DataTraveler Duo` USB Removable、25～35 GiB、空间至少 1 MiB。不得输出私钥正文、私钥哈希、U 盘目录清单或原始 BitLocker 对象。
2. 只在 `EVIDENCE/AUTH-97-OWNER-VISIBLE-USB-KEY-PAIR-COPY-RETRY/` 创建供 Owner 从 Explorer **单次双击**的 `.cmd` 入口及简短 `plan.md`。入口仅在本地窗口调用固定、经审查的 AUTH-96 PowerShell 脚本绝对路径；调用前按固定 SHA-256 核对脚本身份，失败停止且保持窗口显示；不能用现有 AUTH-96 的普通启动预算作为运行理由。入口保持窗口直到 Owner 按键，并展示固定成功/失败类别及 PowerShell 退出码。无自动重试、隐藏窗口、网络、密码参数、解锁、格式化、覆盖、删除、U 盘目录枚举或额外目标。若需改变原复制脚本，必须作为 AUTH-97 新候选完整审查，不能默改旧脚本。
3. 静态审查 `.cmd` 转义、路径、哈希、单次调用、失败停点和显示语义；复核原脚本中提权端唯一 BitLocker 查询、真实 `On` 枚举、复制前 `Unlocked/On/FullyEncrypted/100` 门、双重 Kingston 身份门、两个目标 `File.Copy(..., false)` 各一次、长度与 SHA-256 内部比较、有限输出。**不得运行入口或原脚本，不得触发 UAC 或写 E:**。只交付候选和证据，停在 Work LEVEL 3 Phase A 审查；不提交、推送、自接受或派发后继。

## Phase B — reserved; not released

Work 于 2026-09-25 独立审查 Phase A 并放行单次 Owner 手动启动。Owner 报告固定成功标记，Work 事后独立核对指定 Kingston E: 两个精确副本与源的长度、SHA-256 均相等、原私钥 ACL 未变，见同目录 `plan.md`。LEVEL 3 ACCEPT 仅限本次加密恢复对副本及字节身份；单次启动预算 1/1 已用尽，不重试。纸质恢复密钥、失钥恢复、真实数据库备份/恢复仍未证明。

固定源：`C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` 和同前缀 `.cert.pem`。固定目标：`E:\elitesync-v10-db-backup-recipient-20260925.key.pem` 和同前缀 `.cert.pem`。不得复制真实数据库或备份密文，不得解密私钥或输出密码/私钥正文/完整私钥哈希，不得修改 BitLocker/卷/ACL，不得连接服务器、DB、云、Docker 或 GitHub，不得访问旧 `D:\EliteSync`，私钥及副本不得纳入 Git、Git bundle 或普通证据。完成复制也不证明 U 盘失钥恢复或真实 DB 备份恢复。
