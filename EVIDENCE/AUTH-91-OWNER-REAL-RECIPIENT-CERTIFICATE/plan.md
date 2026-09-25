# AUTH-91｜真实公有收件人证书 Phase A 脚本候选

状态：**仅脚本候选，待 Work LEVEL 3 预运行审查；Phase B 未放行**。本轮未启动 `.cmd`、`req` 或任何密码交互。

## 授权与受限只读前置事实

- `D:\EliteSync-v10` 本地 `main`，启动 HEAD `201664a2503218651207e99973bf6eb9d49f35c7`；`TASK_CURRENT.md` 为 `AUTH-91-OWNER-REAL-RECIPIENT-CERTIFICATE`、`ISSUED — PHASE A SCRIPT CANDIDATE ONLY`、LEVEL 3。两个无关未跟踪目录原样保留。
- AUTH-81 仅接受候选参数；AUTH-88 留下加密私钥但完整安全生成目标因 ACL 继承被 REJECT；AUTH-89 已独立 ACCEPT 文件 ACL 修复；AUTH-90 已独立 ACCEPT **本次 Owner 原生密码输入可解锁现有私钥**这一受限事实。旧生成、ACL 和解锁预算均已耗尽，不能复用。本任务仅准备一个公有证书，不建立 CMS、U 盘或备份恢复证明。
- 固定私钥 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` 本次为规范非重解析普通文件、长度 **2666 bytes**；仅读第一行，精确分类为加密 PKCS#8 PEM 标记。Owner 为当前用户，ACL 继承关闭，恰有当前用户、SYSTEM、Administrators 三条显式 Allow FullControl；未读取正文或完整 SDDL。必要父目录规范非重解析。
- 固定公有证书目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.cert.pem` **不存在**。固定 `C:\Program Files\Git\usr\bin\openssl.exe` 为非重解析普通文件，SHA-256 `21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`，匹配 AUTH-88 放行值；本轮未运行该程序。

## 唯一写入命令候选

同目录 `owner-generate-recipient-cert.cmd` SHA-256 为 `AB5B542EECA9F5EF9BC7F3582A9D37BD3C2CA988984657681A2DC2574C6CC3B2`。Owner 仅在获批后从 Explorer 手动双击。脚本在调用前依次检查精确私钥存在、证书目标不存在及固定 OpenSSL 存在，然后在同一可见 CMD 前台窗口只运行一次：

`req -new -x509 -sha256 -days 365 -key <精确私钥> -out <精确证书> -subj /CN=EliteSync-v10-DB-Backup-Recipient -addext basicConstraints=critical,CA:FALSE -addext keyUsage=critical,digitalSignature,keyEncipherment -batch`

真实密码只由 Owner 在 OpenSSL 原生非回显提示输入。脚本不含 `-passin`、`-keyout`、口令环境变量/文件、重定向、管道、转录、日志、PowerShell、删除或重试命令。非零、文件缺失、目标已存在或输出缺失均进入固定失败类别；成功只显示 `AUTH91_REQ_EXIT_ZERO` 与 `AUTH91_CERT_OUTPUT_PRESENT`。所有正常/失败分支均进入唯一 `pause`，由 Owner 按键关闭。任何部分证书保留待 Work 判定，不自动删除。私钥没有作为输出目标，也不复制或导出。

静态核对：固定 `req` 调用 **1 处**、OpenSSL 执行行合计 **1**，三项调用前检查均在该行之前，所有 `goto` 目标存在，`pause` **1 处**，禁用参数及重定向/网络/删除均未发现。此为文本结构结论，不证明密码提示、证书内容、证书 ACL 或私钥公钥配对。证书目标的 `if exist` 检查与 OpenSSL 打开输出之间不具原子排他性；不能把该预检表述为绝对防覆盖。Work 应在放行前裁决这一剩余风险并再次核对目标不存在。

## Phase B 预留停点（本轮不执行）

Work 须独立审查脚本/程序哈希、私钥限定状态、证书目标不存在、Owner 在场且无录屏/共享，再决定是否放行一次 Owner Explorer 双击。若提示异常、密码回显、非零或输出异常，Owner 停止且只报告固定类别，不重试。成功后 Work 仅解析**公有证书**的 PEM 类型、用途名、RSA 3072、SHA-256、365 天有效期、`CA:FALSE`、keyUsage、文件 ACL 与路径；私钥仅复核元数据/权限，不再次解锁或读取正文。证书配对、跨端 CMS 和 U 盘副本仍需独立任务。当前证书生成预算 **0/1、未放行**。

本轮没有生成、读取正文、复制、删除或改写私钥；没有写 E: 或备份目录、连接服务器、DB、云、Docker、GitHub 或访问旧 `D:\EliteSync`。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 3 预运行审查门。

## Work Phase A 预运行审查与 Phase B 单次放行（2026-09-25）

**LEVEL 3 ACCEPT 脚本候选并放行一次 Owner 手动证书生成。** Work 逐行审查唯一 `req` 命令、固定私钥/证书/程序路径、用途名、365 天、SHA-256 和扩展参数；没有密码参数、私钥输出、重定向、日志、重试或删除。独立核对本地 HEAD `201664a2503218651207e99973bf6eb9d49f35c7`、脚本 SHA-256 `AB5B542EECA9F5EF9BC7F3582A9D37BD3C2CA988984657681A2DC2574C6CC3B2`、OpenSSL SHA-256 `21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`，私钥仍为 2666 bytes、加密 PKCS#8 首行、当前用户 Owner、继承关闭且仅三主体显式 FullControl，精确证书目标仍不存在。审查前候选计划 SHA-256 为 `934885A46C3E4258BF00BF2E092442BC27EE322FC7D3B78605965EC3D0B55BCC`。

与 AUTH-88 相同，`if exist` 与实际写入之间不具原子排他性；在当前受限目录与临运行目标不存在核对下接受剩余竞争风险，不宣称绝对防覆盖。Owner 此前在本轮会话确认在电脑前、无录屏或共享，且已两次亲自在本机 OpenSSL 原生提示使用密码；无相反状态报告。仅放行其从 Explorer 双击固定 CMD **一次**，在非回显原生提示输入现有密码。若现场条件变化、提示异常、密码回显或失败类别，停下且不重试。放行不等于证书内容或配对已被验收。
