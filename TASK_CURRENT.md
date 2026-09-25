# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-90-OWNER-PRIVATE-KEY-UNLOCK-CHECK`

Risk Level: `LEVEL 3`（真实私钥的 Owner 密码解锁验证；不输出私钥）

Status: `ISSUED — PHASE A SCRIPT CANDIDATE ONLY`

Assignee: `Codex + Owner`，复用现有本地执行会话。Codex 只准备候选，Work 独立 LEVEL 3 预运行审查并放行后，Owner 本人从 Explorer 双击并在 OpenSSL 原生提示输入密码。

## Authority and fixed boundary

AUTH-88 的真实生成返回成功且固定文件首行表明加密 PKCS#8；当时文件 ACL 不合格，完整目标被 REJECT。AUTH-89 已独立 ACCEPT 精确文件 ACL 修复。仍未证明 Owner 密码可解锁、密钥与证书配对或恢复。本任务只验证**现有同一文件**可由 Owner 密码在 OpenSSL 中解析，不生成或导出任何密钥，不创建证书。

## Phase A — candidate only, no unlock

1. 核对本地 `main`、HEAD、工作区、AUTH-88/89 接受边界及固定目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem`。只读核对它是规范非重解析普通文件、长度大于 0、Owner 为当前用户、继承关闭且仅当前用户/SYSTEM/Administrators 三条显式 Allow FullControl；仅读取第一行并判断是否精确加密 PKCS#8 标记，不读取正文。若任一不符立即停止。核对固定 `C:\Program Files\Git\usr\bin\openssl.exe` 哈希与 AUTH-88 放行值匹配；不运行解锁。
2. 只在 `EVIDENCE/AUTH-90-OWNER-PRIVATE-KEY-UNLOCK-CHECK/` 准备 Owner 可从 Explorer 手动双击的纯 `.cmd` 候选。它只调用一次固定 OpenSSL：`pkey -in <固定私钥目标> -noout`；不得使用 `-passin`、`-out`、重定向、管道、环境变量、口令文件、日志或 PowerShell。入口先核对固定文件与程序存在；仅显示有限成功/失败类别并在所有分支 `pause`。真实密码只在 OpenSSL 原生非回显提示由 Owner 输入；不由 Codex/Work 终端捕获。
3. 静态核对命令、全部分支及 SHA-256，保存候选、前置受限事实、测试未运行和失败停点至同目录 `plan.md`。不启动 `.cmd`、不运行 OpenSSL 解锁或模拟真实密码。停在 Work LEVEL 3 Phase A 预运行审查；不提交、推送、自接受或派发后继。

## Phase B — reserved, not yet authorized

Work 静态审查、临运行复核文件/ACL/程序和 Owner 在场、无录屏/共享后，才可放行 Owner Explorer 双击 **一次**，OpenSSL 解锁预算 **1/1，当前 0/1 未放行**。Owner 只在原生非回显提示输入密码；若提示异常、密码回显、错误密码或失败类别，立即停止，不重试、不在聊天中报告密码或原始错误。成功只回报固定类别；Work 后续独立只读复核目标文件仍存在、长度与 ACL 不变，作 LEVEL 3 受限验收。

禁止运行 AUTH-88 生成入口，生成/输出/复制/删除或改写真实私钥，不得写 `E:` 或备份目录、连接服务器/DB/云/Docker/GitHub、访问旧 `D:\EliteSync`。本任务不授权证书、U 盘副本、数据库备份或恢复。
