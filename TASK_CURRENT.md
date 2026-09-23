# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-01-ALIYUN-SSH-SOURCE-IDENTITY`

Risk Level: `LEVEL 2`（真实服务器只读连线与部署源码身份；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。仅交付一次有界 SSH 核验的证据候选，停在 Work LEVEL 2 独立验收门。

## Authority and objective

Owner 于当前 Work 会话明确提供阿里云主机 `101.133.161.203` 与可尝试的私钥路径 `C:\Users\zcxve\.ssh\codexkey`，授权接下来需要服务端连线时由 Codex 尝试。先复核本地 `main`、HEAD、工作区及 `CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`，再做**一次**只读 SSH 尝试。历史 `docs/archive/source-migration/ELITESYNC_BACKEND_SYSTEM_MAP.md` 曾记录该 key 被拒绝，不能以旧记录替代当前尝试，也不能据此自动改用另一把 key。历史记录的 `root` 用户仅作为本次一次尝试的精确候选，不能视为永久凭据。

本任务只建立 SSH 认证/主机身份是否可达及两份部署源码的文件身份事实。成功连线时，远端只判断 `/opt/elitesync/services/backend-laravel` 是否为目录，并对以下两条**源码**路径读取 SHA-256：
- `/opt/elitesync/services/backend-laravel/routes/api.php`
- `/opt/elitesync/services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php`

在本地对 `services/backend-laravel/routes/api.php` 与 `services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php` 读取 SHA-256，分别标记当前部署与本地源码是否同字节。文件存在/哈希相同不证明路由实际运行、真实身份、登录事件 `T0`、15/30 天计时、Connection/Consent/CV 权威、数据权利、生产可用或部署来源。哈希不同只记录差异，不自动拉取远端文件、修改本地或远端。

## Exact execution and stop

只允许使用 `root@101.133.161.203`、私钥 `C:\Users\zcxve\.ssh\codexkey`、`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，关闭口令/键盘交互；依赖现有 `known_hosts`，不自动接受或改写主机密钥。最多 **1 次 SSH 进程调用**，超时预算不超过 20 秒。远端命令仅限 `test -d` 和这两条精确路径的 `sha256sum`，以及固定非私密成功标记；不运行 `php artisan`、`cat`、`find`、服务管理、部署命令或任何写入。若主机密钥不匹配、认证被拒、超时、路径缺失、命令异常或出现交互请求，记录相应分类并停止本任务的远端动作；不得重试、换用户、换 key、改变 SSH 选项或扩大范围。

绝不读取或输出私钥内容、`.env`、环境变量值、Token、日志、数据库、用户资料或媒体；不访问生产 API/DB，不访问旧 `D:\EliteSync`，不 pull/push GitHub。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

## Allowed output and verification

唯一允许新增 `EVIDENCE/AUTH-01-ALIYUN-SSH-SOURCE-IDENTITY/summary.md`。可只读本地控制面、上述历史地图与两条本地源码路径。证据写清本地 HEAD、SSH 尝试次数、严格主机密钥结果、认证结果、远端目录/两文件哈希结果或精确失败分类、与本地哈希的比较及未核验项；不要记录不必要的 SSH 调试详情。只运行一次 `git diff --check`，对未跟踪新文档另作尾随空白检查；不运行产品测试、设备或全量搜索。

Codex 不自接受、不提交、不备份、不推送、不派发后继。Work 独立审查并接受或拒绝**事实回执**；即使 SSH 成功，也不据此授权真实权限接线或清理。
