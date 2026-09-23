# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-02-ALIYUN-CORRECTED-KEY-SOURCE-IDENTITY`

Risk Level: `LEVEL 2`（真实服务器只读连线与部署源码身份；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPT — SOURCE HASH FACTS ONLY; REAL-AUTHORITY GATE; NO ACTIVE CODEX TASK`

Assignee: `Codex`（已交付并由 Work 独立接受事实回执）。接受证据：`EVIDENCE/AUTH-02-ALIYUN-CORRECTED-KEY-SOURCE-IDENTITY/summary.md`。

Next gate: 指定私钥下 SSH 成功，部署 `AuthController.php` 与本地同哈希，`routes/api.php` 不同哈希；差异原因、实际运行路由和可信登录事件仍未核验。后续若需读取远端源码正文或其他线上状态，另立精确只读任务并审查；不得从本回执直接接入真实登录、权限或清理。当前无活动 Codex 执行单。

## Authority and objective

AUTH-01 已独立接受为指定旧 `codexkey` 对 `root@101.133.161.203` 一次认证被拒、远端未核验的事实，原预算不重置。Owner 随后明确纠正私钥为 `C:\Users\zcxve\.ssh\CodexKey.pem`，该精确文件名已在本地核对存在。基于这项新授权，本任务**另给一次**同一主机、历史候选 `root` 用户的只读 SSH 尝试；不得把新尝试写回 AUTH-01。

先核对本地 `main`、HEAD、工作区、`AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md` 与项目本地工作流技能。成功认证后，远端仅判断 `/opt/elitesync/services/backend-laravel` 是否为目录，并读取两份**源码**文件的 SHA-256：

- `/opt/elitesync/services/backend-laravel/routes/api.php`
- `/opt/elitesync/services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php`

与本地 `services/backend-laravel/routes/api.php`、`services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php` 的 SHA-256 分别比较。只报告认证、目录、文件身份和字节相同/不同的事实；不由源码哈希推定路由运行、可信在线登录事件、15/30 天计时、Connection/Consent/CV、生产授权或部署来源。若哈希不同，不拉取远端文件、不修改任一端。

## Exact SSH budget and stop

只允许使用 `root@101.133.161.203`、`C:\Users\zcxve\.ssh\CodexKey.pem`、`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，关闭密码和键盘交互；只用现有 `known_hosts`，不自动接受或改写主机密钥。最多 **1 次 SSH 进程调用**，外部等待上限 20 秒。远端命令仅限精确目录的 `test -d`、上述两文件的 `sha256sum` 和固定非私密成功标记。主机密钥不匹配、认证拒绝、超时、路径缺失、命令异常或交互请求时即停，不重试、不换用户/密钥/参数、不扩大范围。

不读取或输出私钥内容、`.env`、环境变量值、Token、日志、DB、用户资料或媒体；不执行 `php artisan`、服务管理、API、部署或远端写入；不访问旧 `D:\EliteSync`，不 pull/push GitHub。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

## Output and verification

唯一允许新增 `EVIDENCE/AUTH-02-ALIYUN-CORRECTED-KEY-SOURCE-IDENTITY/summary.md`。可只读本地控制面、AUTH-01 接受回执及两条本地源码路径。回执记录本地 HEAD、SSH 尝试次数、严格主机密钥和认证结果、远端目录与两文件哈希或准确 NOT CHECKED、与本地哈希比较、未核验项。仅运行一次 `git diff --check`；新文档另作尾随空白检查。不运行产品测试、设备、HTTP/API、DB 或全量搜索。

Codex 不自接受、不提交、不备份、不推送、不派发后继。Work 独立 ACCEPT/REJECT 事实回执；本任务不授权真实权限接线或清理。
