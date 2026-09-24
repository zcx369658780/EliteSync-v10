# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-47-LOCAL-SYNTHETIC-CMS-ENCRYPTION-PREFLIGHT`

Risk Level: `LEVEL 2`（真实备份前的本机虚构加密格式与篡改拒绝探针；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付虚构探针候选与一次运行回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-46 只确认专用空目录、ACL 和本机 OpenSSL 3.5.6 等受限事实；未建立文件加密方式。Owner 要求实际密码由本人输入。本任务使用**一次性虚构证书/私钥和固定非业务字节**，验证本机 OpenSSL CMS 能否形成可解密的 AES-256-GCM 密文、密文单字节篡改是否被拒绝。探针不生成真实备份密钥，不要求 Owner 密码，不向服务器传输；结果不能证明服务器兼容或真实备份安全。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能、AUTH-25、AUTH-45～46 回执；核对 `D:\EliteSync-v10`、本地 `main`、HEAD、工作区。当前 HEAD 应为仅下达本任务的提交，父提交精确为 `4621f2a4afb15b3adc1473841d915e6b20fb5343`。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。
- 预检本机 OpenSSL 可执行文件固定解析、版本为 3.x；固定临时目录 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth47-synthetic-cms` 必须不存在，且其父目录经规范化位于当前用户的本机 Temp 目录、不是重解析点。任一不符即停；不得枚举或清理其他临时目录。
- 只允许在该固定临时目录内生成一次性**无密码虚构** RSA 3072 私钥、自签收件证书、固定 UTF-8 输入 `AUTH47-SYNTHETIC-ONLY`、原始 CMS DER 密文、解密结果、由原密文复制并仅翻转其中一个非头部字节的篡改副本。私钥只用于这次虚构测试，不能改名冒充真实备份密钥；不得写入 C 盘备份专用目录、Git 或普通证据。
- 用本机 `openssl cms -encrypt -binary -stream -outform DER -aes-256-gcm` 和该虚构证书执行最多 1 次；再用配对私钥 `openssl cms -decrypt -binary -inform DER` 最多 1 次，严格比较恢复字节与固定输入。随后篡改密文副本，解密最多 1 次，必须非零退出且不得得到固定输入。任何失败即停，不换算法、模式、工具或参数重试。若 AES-256-GCM CMS 不支持或篡改未拒绝，明确报告，不降级为 CBC。
- 输出仅保存固定阶段 `PASS/FAIL/NOT_CHECKED`、调用次数、OpenSSL 版本、密文长度整数、原文匹配及篡改拒绝布尔、退出码和首个失败类别、清理结果；不得保存/显示证书、私钥、密文、原文、原始 stdout/stderr 或命令中其他敏感内容。所有运行含清理不超过 120 秒。
- 结束时只对本次创建且解析后的绝对路径仍严格等于上述固定临时目录、且处于该用户 Temp 父目录下的目录执行一次精确递归清理，并只读核对不存在；归属或路径无法证明则不删，记 `CLEANUP_UNRESOLVED`。不得删除/修改其他目录或文件；固定备份目录 `C:\Users\zcxve\EliteSync-v10-DB-Backups` 全程只读核对仍为空即可。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-47-LOCAL-SYNTHETIC-CMS-ENCRYPTION-PREFLIGHT/run.ps1` 与同目录 `summary.md`；不得改控制文件、旧证据或源码。先 PowerShell 静态解析和路径/清理边界检查，再最多执行脚本 **1 次**；失败不修改后重跑、不手动补命令。`git diff --check` 最多 1 次；新文件另做只读尾随空白检查。Codex 不提交、制作 bundle、推送、自接受或派发后继。

不得访问旧 `D:\EliteSync`、SSH、浏览器、云 API、真实 DB、备份文件、真实凭据/密钥或业务数据；不安装软件、不做真实备份、传输、恢复、清理或改库。此任务的虚构私钥可自动生成且不受 Owner 密码输入约束；真实密钥生成、保管与解密将另立任务，并由 Owner 亲自输入密码。
