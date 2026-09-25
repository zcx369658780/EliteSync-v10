# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-51-SERVER-OPENSSL-CMS-CAPABILITY-READONLY`

Risk Level: `LEVEL 2`（真实服务器只读工具能力观察；Work 独立审查）

Status: `WORK LEVEL 2 REJECTED — VERSION AND AES-256-GCM LISTING UNKNOWN`

Assignee: `Codex`。只交付一次限定范围的服务器只读观察与回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：一次 SSH 及 `openssl`、三个子命令退出 0 的受限作者事实回执可接受；版本过滤未得到版本值，区分大小写匹配不足以判断 AES-256-GCM 是否列出，且无原始输出可补判。完整工具能力目标 LEVEL 2 REJECT，见 `EVIDENCE/AUTH-51-SERVER-OPENSSL-CMS-CAPABILITY-READONLY/summary.md`。SSH 预算 1/1 已耗尽；本次不发布后继任务。

## Authority and objective

Owner 已选择在本机保存加密数据库备份，密码由本人输入，密钥与密文分目录，并确认备份目录不受云同步或云备份覆盖。AUTH-49 接受了认证成功前消费者不得接收明文的合同；AUTH-50 仅在本机虚构样本中验证该门。下一项缺口是当前阿里云服务器所装 OpenSSL 对 CMS 和 AES-256-GCM 的工具层可用性。Owner 已提供该服务器 SSH 入口并授权继续推进此备份前核验链；本任务只取得工具层事实，不读数据库、不制作备份或密文。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、`.agents/skills/elitesync-local-workflow/SKILL.md`，及 AUTH-49、AUTH-50 回执；核对仓库 `D:\EliteSync-v10` 的本地 `main`、HEAD、工作区。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。若任务未处于 `ISSUED` 或本次派发不匹配，停止。
- 只允许向既有目标 `root@101.133.161.203` 发起 **1 次** SSH 连接，私钥仅为 `C:\Users\zcxve\.ssh\CodexKey.pem`，使用既有 `known_hosts`、`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`。禁止换用户、换密钥、降低主机校验、重试或借浏览器/CloudShell 补跑。连接失败即停止并如实记为未核验。
- 远端只运行一段固定的无副作用 shell 查询：解析 `openssl` 是否存在、读取 `openssl version`、读取 `openssl cms -help` 的命令可用性，以及 `openssl list -cipher-algorithms` 中 AES-256-GCM 是否列出。每项至多 1 次。只读标准输出/错误流；不运行加密、解密、密钥生成、文件写入、服务重启、数据库或 Laravel 命令。若命令返回异常，保留失败事实，不增加探测命令。
- 只保存经整理的布尔、OpenSSL 版本、各子命令退出码与首个失败阶段；不得保存完整命令输出、环境变量、路径清单、凭据或服务器文件内容。工具列表和帮助文本只能作为静态能力线索，不得声称服务器已与本机 CMS 密文互通或具备真实备份/恢复能力。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-51-SERVER-OPENSSL-CMS-CAPABILITY-READONLY/summary.md`，不得修改源码、旧证据或其他控制文件。`git diff --check` 最多 1 次；新文件另做只读尾随空白检查。报告精确记录一次连接预算是否消耗、分阶段 `PASS/FAIL/NOT_CHECKED`、静态观察与 UNKNOWN、禁止项未执行、下一道门。不得把工具安装或帮助信息判作 AES-GCM CMS 端到端 PASS。

Codex 不提交、制作 bundle、推送、自接受或派发后继。不得访问旧 `D:\EliteSync`、云 API、真实数据库及账户/Token/消息/媒体，亦不得读取或改动本机真实备份/密钥目录内容。真实密钥、密码、数据库读取、完整备份、传输、恢复、清理、改库和生产部署各需独立任务权限；本任务不授权这些动作。
