# AUTH-88｜Owner 纯 CMD 真实加密私钥入口 Phase A 候选

状态：**仅脚本候选，待 Work LEVEL 3 预运行审查；Phase B 未放行**。本轮未启动 `.cmd` 或运行任何密钥命令，也未接收真实密码。

## 授权与只读预检

- `D:\EliteSync-v10` 本地 `main`，启动 HEAD `dbebdede7a4ed89edcbbff3ba0e0e5a484519b99`；`TASK_CURRENT.md` 为 `AUTH-88-OWNER-CMD-REAL-ENCRYPTED-PRIVATE-KEY`、`ISSUED — PHASE A SCRIPT CANDIDATE ONLY`、LEVEL 3。两个无关未跟踪目录保留。
- AUTH-81 是已接受的实施前参数候选，AUTH-82 只证明虚构 OpenSSL 原生口令交互。AUTH-83 的旧一次真实脚本启动失败且真实目标不存在；AUTH-84/85 的 PowerShell 窗口/探针目标未成，旧预算耗尽；AUTH-86 只读诊断未确定原因；AUTH-87 已接受一次**无秘密**纯 CMD 可见窗口与按键路径，不证明真实密码提示。Owner 已决定真实密码本人输入、另写纸质副本并与电脑/U 盘分开放置，固定密钥/备份目录不采用云同步；其他第三方同步技术覆盖仍非全局证明。
- 固定目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem` 当前**不存在**。`C:\`、`C:\Users`、当前用户目录、固定密钥目录均为规范、非重解析目录；密钥目录 Owner 为当前用户，ACL 继承关闭，仅当前用户、SYSTEM、Administrators 三条显式 FullControl。
- 固定程序 `C:\Program Files\Git\usr\bin\openssl.exe` 是规范、非重解析普通文件；SHA-256 `21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B`，本次只运行只读 `version`，返回 OpenSSL **3.5.5**。未运行 `genpkey` 或 `pkey`。

## 唯一脚本与控制流

候选仅为同目录 `owner-generate-encrypted-key.cmd`，SHA-256 `BADB715650F0208E81925876B992AEA95D3E8417C837A6FE3BEFA359133273E5`。它由 Owner 在获批后从 Explorer 手动双击，在同一个可见 CMD 前台窗口先检查精确目标不存在、固定 OpenSSL 程序存在；任一失败只输出固定类别，**不调用生成**。随后仅有一行固定调用：`genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -aes-256-cbc -out <上述精确目标>`，预算 **1/1**；密码只由 Owner 在 OpenSSL 原生提示输入并确认。

该脚本没有 `-pass`、环境变量取密、口令文件、输入/输出重定向、管道、转录或日志；不运行 PowerShell、其他脚本、网络或 U 盘命令。生成返回非零、目标缺失、目标原先已存在或程序缺失均进入不同固定类别，所有正常/失败路径最终显示 `AUTH88_PRESS_ANY_KEY_TO_CLOSE` 并 `pause`。它不删除、不重试、不换目录或算法，也不生成无密码私钥；如出现不完整目标，保留并由 Work 另行决定精确处置。OpenSSL 的提示和任何错误只在 Owner 本机窗口可见，不由 Codex/Work 采集原始流。

纯文本静态检查：精确生成命令 **1 处**，固定 OpenSSL 执行行总数 **1**；目标与程序预检查位于调用之前；所有 `goto` 目标存在，`pause` **1 处**；未发现禁用参数、密码来源、删除、后台或网络调用。此检查不证明实际 CMD/OpenSSL 提示、文件加密状态或权限。`if exist` 与 OpenSSL 打开输出之间不能提供原子防覆盖保证；若 Work 认为并发创建风险必须被技术性排除，应在 Phase B 前拒绝此候选并另立安全入口，不能把静态不存在检查写成绝对防覆盖证明。

## Phase B 预留门（本轮不执行）

Work 须独立复核脚本和程序精确哈希、目标仍不存在、目录 ACL/同步边界、Owner 在场及无录屏/共享、纸质副本准备后，才可决定是否放行一次 Owner Explorer 双击。Owner 若未见预期非回显原生提示、看到密码回显或出现窗口异常，应停止并报告固定类别，不重试。生成后只允许按任务只读核对目标存在、长度、加密 PKCS#8 首行及 ACL；**密码解锁、公有证书、U 盘副本和备份恢复另立任务**。当前实际生成预算 **0/1、未放行**。

本轮没有修改真实密钥目录、备份目录、E:、服务器、DB、云、Docker、GitHub 或旧 `D:\EliteSync`。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 3 预运行审查门。

## Work Phase A 独立预运行审查（2026-09-25）

**LEVEL 3 ACCEPT 脚本候选，Phase B 暂待 Owner 当下现场条件确认。** Work 逐行审查纯 CMD 控制流：唯一固定 `genpkey` 调用具备 RSA 3072 与 AES-256-CBC 参数，目标/程序存在性预检在调用前，失败停止且所有路径进入按键提示；没有口令参数、密码捕获、重定向、日志、删除或重试。独立核对本地 HEAD `dbebdede7a4ed89edcbbff3ba0e0e5a484519b99`、脚本及 OpenSSL SHA-256 与作者值一致、真实目标仍不存在；密钥目录 Owner 为当前用户，三主体显式 FullControl 且继承关闭，必要父目录均非重解析。审查前候选计划 SHA-256 为 `2D79CA8634C1A2C5FD2BD3DB9C581CADCF709129F5EC811B960E86D59E41E719`。

`if exist` 与 OpenSSL 开始写入之间没有原子排他保证；Work 接受这是当前单用户受限目录下的剩余竞争风险，必须在 Phase B 前再次核对精确目标不存在，不把预检称为绝对防覆盖。脚本的正常退出与文件存在也不证明文件已加密或可解锁；后续必须独立只读核对。Owner 当下无录屏/共享、在场和纸质密码准备确认之前，**不放行执行**。
