# AUTH-96｜固定加密恢复对复制单次启动回执

状态：**作者受限失败回执，待 Work LEVEL 3 独立审查。** 观察时点：2026-09-25 18:31:41 +08:00。

## 授权与临运行门

- 本地 `D:\EliteSync-v10`、`main`，Phase B 启动 HEAD `7110ce345b89fb4db626215ac5204a7351e4d82a`；`TASK_CURRENT.md` 为 `AUTH-96-ENCRYPTED-USB-KEY-RECOVERY-PAIR-COPY`、`ISSUED — PHASE B RELEASED; OWNER UAC AND COPY PENDING`、LEVEL 3。Work 已在同目录 `plan.md` 独立审查并放行一次固定脚本。两个既有无关未跟踪目录保留。
- 临运行固定脚本 SHA-256 `A79C3715E2DD08085D8BD0AEEEBE5388A0A9C2ADE197C656C6DD7EF032C6EB6C`，与 Work 放行值一致，未改写。只读复核固定源：私钥非重解析、2666 bytes、加密 PKCS#8 首行、当前用户 Owner 与三主体显式 FullControl 且 ACL 继承关闭；公有证书非重解析、1541 bytes、公开 DER 指纹与 AUTH-91 一致。未输出私钥内容或哈希。
- 临运行非提权 E: 门通过：唯一 `Kingston DataTraveler Duo` USB Removable、25～35 GiB、分区/卷映射唯一、剩余至少 1 MiB；两个精确目标当时均不存在。没有枚举或读取 U 盘其他内容。

## 唯一启动与停止点

仅一次以固定 Windows PowerShell `-NoProfile -ExecutionPolicy RemoteSigned -File <固定脚本>` 启动。约 80 秒后普通进程返回固定类别 `AUTH96_RESULT=UAC_OR_LAUNCH_FAILED`，退出码 **1**，没有子进程退出码或 BitLocker/复制成功回执。该类别合并 UAC 取消与启动失败等可能，**具体原因 UNKNOWN**。Owner 对本次 UAC 是否看到/批准的独立回执目前**待回复**；不能自行推断。

随即仅检查两个精确 E: 目标的存在类别：`E:\elitesync-v10-db-backup-recipient-20260925.key.pem` **ABSENT**，同前缀 `.cert.pem` **ABSENT**。没有读取目录、文件正文或执行额外状态查询。此时没有副本写入的观察证据，也没有证明提权子进程执行了 BitLocker 查询。

本任务唯一脚本启动预算 **1/1 已耗尽**；BitLocker 查询和两次复制是否进入均未由该有限结果证明，保持 `UNKNOWN/NOT_CONFIRMED`，不得在 AUTH-96 内重试、改参数或清理。当前不能接受恢复副本写入目标。没有修改 BitLocker/卷/ACL、写真实备份、解密或读取私钥正文，没有连接服务器/DB/云/Docker/GitHub，也没有访问旧 `D:\EliteSync`。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 3 独立审查门。

## Work 独立审查（2026-09-25）

**LEVEL 3 REJECT 恢复对副本写入目标；ACCEPT 一次启动失败与两目标不存在的受限事实。** Work 对照任务单、经审查脚本哈希和作者唯一执行回执，审查前候选摘要 SHA-256 为 `6867BF88A3E00DEE235800811A356C0E684B4B04712AB0B6E23A279ED081A05D`，尾随空白 0 行，`git diff --check` PASS。Work 独立只读确认当前仍是 Kingston USB Removable E:，两个精确副本目标均不存在；本机源私钥仍 2666 bytes、ACL 继承关闭且三主体。约 80 秒后的 `UAC_OR_LAUNCH_FAILED` 不区分 UAC 取消、窗口/启动错误或其他异常；Owner 后续说明当时不在电脑前、未看到 UAC，故是否曾弹出以及失败具体原因仍 `UNKNOWN`。不得推定 BitLocker 查询或复制已执行。

旧脚本启动预算 **1/1 已耗尽**，不得在 AUTH-96 内重试。后继只可另立有界任务，先准备 Owner 从 Explorer 手动启动并保持窗口可见的入口，静态审查后才考虑新的一次运行；不因旧授权自动放宽保护门或覆盖目标。
