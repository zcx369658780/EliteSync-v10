# AUTH-97｜Owner 可见窗口恢复对复制入口 Phase A 候选

状态：**仅 `.cmd` 入口候选，待 Work LEVEL 3 预运行审查；Phase B 未放行。** 本轮没有运行入口或原复制脚本，没有触发 UAC、BitLocker 查询或 E: 写入。

## 派发与只读预检

- 本地 `D:\EliteSync-v10`、`main`，启动 HEAD `9cf00c30e52a15bc6ff33804ef360ca88bc5b8b0`；`TASK_CURRENT.md` 为 `AUTH-97-OWNER-VISIBLE-USB-KEY-PAIR-COPY-RETRY`、`ISSUED — PHASE A ENTRY CANDIDATE ONLY; NO UAC OR COPY`、LEVEL 3。两个原有无关未跟踪目录保留。
- AUTH-96 获 Work LEVEL 3 REJECT 恢复对副本写入目标；唯一旧启动约 80 秒后仅返回 `UAC_OR_LAUNCH_FAILED`，两精确 E: 目标不存在，旧 1/1 预算已耗尽。Owner 后续说明当时不在电脑前、未看到 UAC，并请求到场时重新触发；旧失败原因仍 `UNKNOWN`。AUTH-97 是新任务，不能追溯重用旧预算。
- 固定 AUTH-96 复制脚本 `D:\EliteSync-v10\EVIDENCE\AUTH-96-ENCRYPTED-USB-KEY-RECOVERY-PAIR-COPY\owner-copy-encrypted-key-pair.ps1` SHA-256 `A79C3715E2DD08085D8BD0AEEEBE5388A0A9C2ADE197C656C6DD7EF032C6EB6C`，与任务单一致，未修改。
- 只读预检固定私钥：非重解析普通文件、2666 bytes、加密 PKCS#8 首行、当前用户 Owner、继承关闭且仅当前用户/SYSTEM/Administrators 三条显式 FullControl；公有证书非重解析、1541 bytes、公开 DER 指纹与 AUTH-91 一致。没有输出私钥正文或哈希。
- 只读预检 E:：唯一 `Kingston DataTraveler Duo` USB Removable，25～35 GiB、分区/卷映射唯一、剩余至少 1 MiB；两个精确恢复目标逐一不存在。没有枚举 U 盘目录或读取文件，也没有查询当前 BitLocker 状态。

## 唯一候选与窗口控制

本目录只新增 `owner-visible-copy-entry.cmd`，SHA-256 `01F311DAA38FBC658AD39B6EF090A2EFCB0FC285C8DBF8E84D81B6F83E923735`。Owner 仅在 Work 放行后从 Explorer 手动双击一次。入口固定 Windows PowerShell 绝对路径，先检查程序及 AUTH-96 脚本存在，再以一次**无 UAC、无脚本执行**的 PowerShell `-Command` 静默核对原脚本是非重解析普通文件且 SHA-256 精确匹配；任一失败直接显示固定失败类别并保留可见 CMD 窗口。

哈希通过后，入口在同一前台窗口以 `-NoProfile -ExecutionPolicy RemoteSigned -File` **只调用一次**固定 AUTH-96 脚本。原脚本的有限 `AUTH96_RESULT` 在此窗口可见；入口另显示 `AUTH97_RESULT=SCRIPT_EXIT_ZERO` 或 `SCRIPT_EXIT_NONZERO` 及 PowerShell 退出码。每个分支都显示按键关闭提示并执行唯一 `pause`；Owner 未按键前 CMD 窗口保留。入口没有 `start`、`WindowStyle Hidden`、后台运行、录制/重定向输出、口令参数、网络或额外目标。原 AUTH-96 脚本自身的提权子进程仍按经审查的固定实现运行；本入口不修改其参数或窗口方式。

原复制脚本静态复核：普通/提权固定 Kingston 身份门，提权端唯一 `Get-BitLockerVolume -MountPoint 'E:'`，真实枚举 `On` 与 `Unlocked/FullyEncrypted/100` 写入前门；两个精确目标分别只有一次 `[IO.File]::Copy(..., false)`，进程内比较源/副本长度及 SHA-256，失败保留部分文件，输出有限类别、不输出私钥正文或哈希。此为结构核对，不证明实际 BitLocker 状态、复制或恢复。

## 静态检查与停点

入口纯文本检查：固定 `-File` 调用 **1**、脚本 SHA-256 检查 **1**、`pause` **1**，所有 `goto` 标签存在；禁用删除、格式化、解锁、复制、网络、隐藏窗口和日志命令命中 **0**，尾随空白 **0**。`if exist`/哈希检查与最终脚本打开不是不可分割事务；Work 临运行前须重新核对脚本哈希、两源、两个目标及固定 E:，并裁决剩余并发风险。当前新任务手动双击/原脚本启动/BitLocker 查询/两文件复制预算均 **0/1，未放行**。

Work 独立审查后若放行，Owner 须在电脑前亲自从 Explorer 双击固定入口，核对 Windows PowerShell UAC 后自行决定是否批准；只回报固定类别，不提供密码、私钥、哈希、截图或原始输出。任何失败不重试、不删部分副本；Work 对成功回执仍须独立核验两个精确目标与源的长度和 SHA-256 身份及源 ACL。复制不证明失钥恢复或真实 DB 备份恢复。本轮不提交、推送、自接受或派发后继。

## Work LEVEL 3 Phase A 独立审查与 Phase B 单次放行（2026-09-25）

**ACCEPT 固定可见入口候选；放行新任务的一次 Owner 手动启动。** Work 逐行审查 `.cmd` 的固定 PowerShell 与原脚本绝对路径、非重解析及 SHA-256 检查、唯一 `-File` 调用、失败停点、有限结果/退出码和唯一 `pause`。独立核对入口 SHA-256 `01F311DAA38FBC658AD39B6EF090A2EFCB0FC285C8DBF8E84D81B6F83E923735`、原脚本 SHA-256 `A79C3715E2DD08085D8BD0AEEEBE5388A0A9C2ADE197C656C6DD7EF032C6EB6C`，原脚本未改；再次审阅其提权端唯一 BitLocker 查询、真实 `On` 枚举、保护状态门、双重固定 Kingston 身份门、两处非覆盖 `File.Copy` 与内部长度/SHA-256 比较。入口不采集输出、不传递密码、不复制或删除文件。

Work 本轮独立只读核对固定私钥 2666 bytes、加密 PKCS#8 首行、非重解析、Owner 当前用户及三主体显式 FullControl 且继承关闭；公有证书 1541 bytes、非重解析、公开 DER 指纹与 AUTH-91 匹配；当前 E: 为唯一 Kingston USB Removable、25～35 GiB、余量至少 1 MiB，两个精确目标均不存在。核对不包含当前 BitLocker 状态；脚本在任何写入前仍必须通过自身提权查询。另一次公开证书 API 读取调用因接口用法不符而报错，随即使用证书 PEM 的公开 DER 字节复核指纹匹配；该失败调用不涉及私钥或 E:，不影响指纹结论。

`if exist`/哈希检查与后续脚本打开、保护状态与写入之间不是单一原子事务；在固定本机文件和设备、提权进程内再次核验身份/保护、目标非覆盖创建的约束下，接受这次单次操作的剩余并发风险。Owner 已授权恢复副本写入这只加密 U 盘，并明确请求在其到场时重新触发。仅放行 **一次**由 Owner 从 Explorer 双击此固定入口并本人核对/批准 UAC；若窗口未出现、UAC 取消或任一步失败即停止，不重试。成功分支仍须 Work 对两个固定目标和源作独立长度/哈希身份及原私钥 ACL 复核，才能接受写入结果。此放行不代表已复制，也不证明失钥恢复能力。

## Work LEVEL 3 执行结果独立验收（2026-09-25）

**ACCEPT 固定加密恢复对副本写入及本次字节身份；AUTH-97 单次启动预算 1/1 已用。** Owner 从 Explorer 单次双击后报告同一窗口出现 `AUTH96_RESULT=PAIR_MATCH;CHILD_EXIT=0` 与 `AUTH97_RESULT=SCRIPT_EXIT_ZERO`。Work 没有代 Owner 操作或读取 UAC 原始界面；这两个标记按经审查脚本控制流要求提权子进程通过固定 E: `Unlocked/On/FullyEncrypted/100` 查询门、双重身份/源/目标门、两次非覆盖复制和内部字节身份比较，不能当作未来持续保护状态证明。

Work 事后独立只读核对：E: 仍唯一匹配指定 Kingston USB Removable；本机与 E: 四个精确文件均为非重解析普通文件；加密私钥源/副本各 2666 bytes、公有证书源/副本各 1541 bytes；两对 SHA-256 在核验进程内分别相等，只输出布尔结果，未输出或保存私钥哈希、正文或密码。源私钥 Owner 仍为当前用户，ACL 继承关闭，恰有当前用户/SYSTEM/Administrators 三条显式 Allow FullControl。入口及原复制脚本 SHA-256 均与放行值相同。没有再运行入口或查询 BitLocker，没有删除、覆盖、解密或复制其他内容。

验收范围仅为本次加密 PEM 与公有证书在指定受保护 U 盘上的固定副本及字节身份。纸质恢复密钥能否解锁、拔出重插后的保护行为、本机源文件不可用时从 U 盘恢复、真实数据库备份/解密/恢复均未由本任务证明；后继须另立有界任务。无关工作区目录保留，未连接服务器/DB/云或 GitHub。
