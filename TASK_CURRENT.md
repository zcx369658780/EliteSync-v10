# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-58-LOCAL-SYNTHETIC-FD-CMS-PREFLIGHT`

Risk Level: `LEVEL 2`（无服务器落盘 CMS 管道方案的本机虚构预检；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。仅交付一次本机虚构文件描述符/CMS 预检候选及受限回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-57 docs-only 方法已获 Work LEVEL 2 ACCEPT，但服务器用文件描述符/管道接收虚构公有证书并在不落盘条件下进行 CMS AES-256-GCM 加密仍 `UNKNOWN`。Work 只读发现本机 Git Bash `C:\Program Files\Git\bin\bash.exe` 与其 OpenSSL 3.5.5 可用，`/dev/fd/0` 的只读可访问测试退出 0；本机 Docker daemon 当次不可达。本任务仅用固定虚构样本预检同型的文件描述符传递与本机配对解密，**不连接服务器**；本机成功也不能证明服务器 OpenSSL 3.0.13 的同一路径。Owner 密码与 32GB U 盘此阶段不需要。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、项目本地 workflow 技能及 AUTH-48/49/50/57 验收；核对 `D:\EliteSync-v10` 本地 `main`、HEAD 与工作区。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。状态或派发不匹配则停止。
- 只允许新增 `EVIDENCE/AUTH-58-LOCAL-SYNTHETIC-FD-CMS-PREFLIGHT/run.ps1` 与 `summary.md`。先静态核对 PowerShell 语法、固定路径、命令参数、进程输出处理及精确清理。不得修改源码、历史证据或控制文件。
- 固定虚构明文为 ASCII `AUTH57-SYNTHETIC-001\n`（21 字节）。只在任务固定临时目录 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth58-fd-cms-preflight` 存放一次性无密码**虚构**证书与私钥；创建前验证规范化绝对路径、非重解析父目录和目标原先不存在，退出时只对本次精确目录清理并确认不存在。不得在服务器或真实备份/密钥目录写入任何内容。
- 单次本地运行可生成一对一次性虚构证书/私钥；经本机 Git Bash 标准输入送公有证书，使用可静态审查的 fd 3 或等价管道路径让 Git Bash OpenSSL `cms -encrypt -aes-256-gcm` 只读取固定虚构明文并将 DER 密文送本机进程内存，**不落盘密文**。随后用本次虚构私钥在本机做有上限隔离解密；仅在退出 0 且与固定 21 字节完全匹配后记配对成功。任何 fd 路径不通、命令异常、超限、输出不完整或未能证明无密文落盘均 FAIL 并清理，不切换到普通临时文件方案。不要显示或保存私钥、公有证书全文、原始密文/明文或原始 stderr；回执仅保留脱敏阶段状态、退出码、长度、首个失败、清理状态。
- 本地脚本运行最多 **1/1 次**；失败不得改参重跑。PowerShell 静态解析检查可先进行；`git diff --check` 最多 1 次，新文件另做只读尾随空白检查。不得运行 Docker、WSL 容器、SSH、CloudShell、云 API、数据库或真实备份/恢复。不得访问旧 `D:\EliteSync`、本机真实备份/密钥目录内容、U 盘、Owner 密码或业务数据。

## Stop and review

本机 Git Bash/OpenSSL 预检即使 PASS，也仅说明这次本机虚构 fd/CMS 管道可运行；服务器对应能力、CMS 跨端互通、认证失败消费者门、真实规模和备份恢复仍 `UNKNOWN`。Codex 不提交、制作 bundle、推送、自接受或派发后继；本机一次预算后停在 Work LEVEL 2 独立门。服务器执行须另立固定一次 SSH 任务。
