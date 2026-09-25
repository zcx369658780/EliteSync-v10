# AUTH-90｜Owner 现有加密私钥解锁检查 Phase A 候选

状态：**仅脚本候选，待 Work LEVEL 3 预运行审查；Phase B 未放行**。本轮没有启动 `.cmd`、运行 OpenSSL 解锁或接收密码。

## 当前授权与受限只读事实

- `D:\EliteSync-v10` 本地 `main`，启动 HEAD `ca3829adedb6486f444b788d0b371114cc8554f8`；`TASK_CURRENT.md` 为 `AUTH-90-OWNER-PRIVATE-KEY-UNLOCK-CHECK`、`ISSUED — PHASE A SCRIPT CANDIDATE ONLY`、LEVEL 3。两个无关未跟踪目录保留。
- AUTH-88 的唯一真实生成留下固定文件，但其当时继承 ACL 使完整安全目标被 REJECT；旧生成预算耗尽。AUTH-89 已获 Work LEVEL 3 ACCEPT，仅证明精确文件 ACL 修复，不证明密码可解锁。
- 本次只读核对固定文件 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem`：规范非重解析普通文件，长度 **2666 bytes**、Owner 当前用户、ACL 继承关闭，恰有当前用户、SYSTEM、Administrators 三条显式 Allow FullControl；仅读取第一行并将其分类为精确 `BEGIN ENCRYPTED PRIVATE KEY` PEM 标记。未读取私钥正文或完整 SDDL。
- 固定程序 `C:\Program Files\Git\usr\bin\openssl.exe` 为规范非重解析普通文件，SHA-256 `21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`，与 AUTH-88 放行值相同。本轮未运行该程序。

## 唯一候选及静态检查

同目录唯一候选 `owner-unlock-check.cmd` SHA-256：`716A3195831BAFA273BA69C2C6AFDB223710D85E3F2D1ED7206ED667115FD775`。Owner 仅在获批后从 Explorer 手动双击，入口先检查精确文件和固定程序存在，再以同一前台 CMD 控制台**只调用一次**：`pkey -in <固定私钥> -noout`。实际密码只由 Owner 在 OpenSSL 原生非回显提示输入。脚本不生成、导出、复制、删除或改写私钥。

静态检查：精确 `pkey` 命令 **1 处**，固定 OpenSSL 执行行总数 **1**；两个存在性预检均位于调用前，所有 `goto` 目标存在，成功/文件缺失/程序缺失/解锁非零分支均进入唯一 `pause`；无 `-passin`、`-out`、重定向、管道、环境变量、口令文件、日志、PowerShell、其他脚本、删除或网络调用。脚本只输出固定有限类别 `AUTH90_UNLOCK_EXIT_ZERO` 或 `AUTH90_FAILURE=...`，然后等待 Owner 按键关闭。OpenSSL 自身提示/错误仅在 Owner 本机窗口可见，不采集进 Codex/Work 普通证据。静态结构不证明原生提示行为或密码可解锁。

## Phase B 预留门（本轮不执行）

Work 须先独立复核脚本哈希、目标文件/首行/ACL、程序哈希、Owner 在场和无录屏/共享，才可决定是否放行一次 Owner Explorer 双击。若提示异常、密码回显、密码错误或出现失败类别，Owner 停止并只报告有限类别，不重试、不提供密码或原始错误。若脚本回报 `AUTH90_UNLOCK_EXIT_ZERO`，Work 仍须只读复核固定文件存在、长度与 ACL 不变后作 LEVEL 3 受限验收。当前解锁预算 **0/1、未放行**。

本任务不证明与公有证书配对，也不授权证书、U 盘副本、数据库备份或恢复。没有运行 AUTH-88 生成入口、修改真实私钥、写 E: 或备份目录、连接服务器、DB、云、Docker、GitHub 或访问旧 `D:\EliteSync`。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 3 预运行审查门。

## Work Phase A 预运行审查与 Phase B 单次放行（2026-09-25）

**LEVEL 3 ACCEPT 脚本候选并放行一次 Owner 手动解锁检查。** Work 逐行审查 CMD：固定 OpenSSL 路径、唯一 `pkey -in <固定文件> -noout`、调用前存在性检查、无输出文件/密码参数/重定向、失败即停及所有分支 `pause`。独立复核本地 HEAD `ca3829adedb6486f444b788d0b371114cc8554f8`、脚本 SHA-256 `716A3195831BAFA273BA69C2C6AFDB223710D85E3F2D1ED7206ED667115FD775`、OpenSSL SHA-256 `21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`；真实目标仍为非重解析普通文件、2666 bytes、加密 PKCS#8 首行、当前用户 Owner、继承关闭且仅原三主体显式 FullControl。审查前候选计划 SHA-256 为 `6510F9EB94E6959FCD56D56B75F52D6949C3027B0B30AA0F58172AE1FCB8B321`。

Owner 已在本轮会话确认在电脑前、没有录屏/共享屏幕且密码已准备好，且已完成 AUTH-88 本机原生提示输入；没有相反状态报告。仅放行其从 Explorer 双击固定 CMD **一次**，仅在 OpenSSL 原生非回显提示输入密码。不得由 Codex/Work 启动、捕获窗口或接收密码。若提示异常、密码回显或非零，停并只回报有限类别，不重复；放行不等于解锁成功或最终验收。
