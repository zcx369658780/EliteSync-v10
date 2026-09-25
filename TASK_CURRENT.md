# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-60-SERVER-SYNTHETIC-CERT-FD-READONLY`

Risk Level: `LEVEL 2`（真实服务器一次虚构公有证书 fd 读取观察；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付一次有界 SSH 的虚构公有证书 fd 读取事实与回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-56 已接受当次服务器 OpenSSL 静态列表列出 AES-256-GCM；CMS 实际互通未建立。AUTH-58/59 的本机 Git Bash 预检停在 OpenSSL 从 `/dev/fd/3` 读取证书失败，原因 `UNKNOWN`，不能外推服务器 Linux。AUTH-57 docs-only 方法要求服务器无落盘证书入口先有界核验。Owner 已授权按路线图继续；本任务只用一次性**公有虚构证书**观察该服务器 OpenSSL `x509` 能否从 fd 3 读取，不运行 CMS 加密。无需 Owner 密码或 U 盘。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、项目本地 workflow 技能及 AUTH-49/56/57/58/59 验收；核对 `D:\EliteSync-v10` 本地 `main`、HEAD 与工作区。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。状态或派发不匹配则停止。
- 只允许新增 `EVIDENCE/AUTH-60-SERVER-SYNTHETIC-CERT-FD-READONLY/run.py`、`test_run.py`、`summary.md`。先静态核对固定命令、SSH 选项、限量采集、证书/私钥分离、失败停点与精确清理；本地纯虚构 targeted 测试最多 2 次。
- 本机仅在固定 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth60-cert-fd-readonly` 生成一次性无密码虚构证书/私钥；创建前核对规范化绝对路径、非重解析父目录、目标原先不存在。**仅公有证书字节**进入 SSH stdin；私钥始终在本次本机临时目录，绝不发送服务器。证书须有本地字节长度上限与摘要核对；运行后按精确目录清理并确认不存在。不得保存公有证书全文、私钥或原始命令输出到普通证据。
- 只允许向既有 `root@101.133.161.203` 发起 **1 次** SSH 连接，私钥仅为 `C:\Users\zcxve\.ssh\CodexKey.pem`，使用既有 `known_hosts`、`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`；不重试、换入口或降低校验。SSH 失败/超时立即停止并在本会话向 Owner 反馈。
- 远端固定无副作用 shell 只做：保留 SSH 标准输入为 fd 3、对本次公有虚构证书运行一次 `openssl x509 -in /dev/fd/3 -noout`，并输出唯一带退出码的固定标记。stdout/stderr 仅在本机进程内有界读取，严格验证唯一标记、SSH 退出码与无额外字节；不得显示或保存原始 stderr。远端不创建文件、不运行 `cms`、加解密、密钥生成、数据库、Laravel、服务重启或云 API。若 fd 读取异常，仅记录退出码与 `PASS/FAIL/UNKNOWN`，不增加探测命令或推测根因。
- `git diff --check` 最多 1 次；新文件另做只读尾随空白检查。不得访问旧 `D:\EliteSync`、本机真实备份/密钥目录内容、真实 DB、账号/Token/消息/媒体、U 盘或 Owner 密码。

## Stop and review

本次即使 x509 fd 读取 PASS，也仅证明当次虚构公有证书入口可读，不证明 CMS fd 收件人读取、AES-256-GCM 加密、跨端互通或真实备份恢复。Codex 不提交、制作 bundle、推送、自接受或派发后继。SSH 1/1 预算与本机一次性材料清理后停在 Work LEVEL 2 门；进一步 CMS 虚构执行须另立任务。
