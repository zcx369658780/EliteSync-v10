# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-06-DEPLOYED-V2-ROUTE-LIST-READONLY`

Risk Level: `LEVEL 2`（真实服务器 Laravel 路由列表只读核对；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。仅交付一次受限命令的事实候选，停在 Work LEVEL 2 独立验收门。

## Authority and objective

Owner 已在 2026-09-24 明确授权另立有界任务，**仅只读核对服务器当前加载的路由列表**。AUTH-04/05 已接受的有限事实：部署 `routes/api.php` 相对本地缺少四条 v2 POST 声明；本地四条入口有 controller、合成测试与接受文档，实际服务器路由仍未知。AUTH-04 的 SSH 1/1 预算保持耗尽，本任务使用 Owner 新授权的独立预算。先核对本地 `main`、HEAD、工作区和 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-04/05 证据；仅在本任务 `ISSUED` 且派发匹配时执行。

目标是核对 Laravel CLI 在此次执行时列出的 `api/v2` 路由，准确报告 `/api/v2/contracts/application-envelope`、`/api/v2/canonical-match/evaluations`、`/api/v2/canonical-match/invalidations`、`/api/v2/runtime-readiness/evaluations` 四条是否出现，以及出现时的方法、action、middleware。此结果是**部署目录的 CLI bootstrap 路由视图**；即使成功，也不证明 Web worker 的即时状态、HTTP 触达、调用量、真实身份或生产权限。

## One remote process and fail-closed parsing

最多 **1 次 SSH 进程调用**，使用 `root@101.133.161.203`、`C:\Users\zcxve\.ssh\CodexKey.pem`，启用 `BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，关闭密码及键盘交互，外部等待上限 30 秒。唯一远端命令是 `cd /opt/elitesync/services/backend-laravel && php artisan route:list --json --path=api/v2`。不要先行探测或重试；若 SSH、PHP、JSON 解析失败或超时，记录分类即停，不换命令、用户、密钥或路径。

用本地 Python `subprocess.run(..., stdin=DEVNULL, capture_output=True, timeout=30)` 将 stdout/stderr 仅收入内存；stdout 超过 256 KiB 即停。严格 UTF-8 解码并解析 JSON 数组，检查每条对象的 uri、method、action、middleware 字段；若输出混有非 JSON、结构异常或有疑似凭据/敏感值，不打印原始输出，记录分类并停。只写入总路由数、上述四条精确 URI 的匹配结果和必要的非私密路由字段；不保存完整列表或 stderr。若输出为空，准确分类，不等同于四条路由不存在。记录 UTC 执行时刻、命令退出状态和是否耗用 1/1 预算。

## Scope and verification

唯一允许新增 `EVIDENCE/AUTH-06-DEPLOYED-V2-ROUTE-LIST-READONLY/summary.md`。不读取私钥内容、`.env`、配置/环境变量值、Token、日志、DB、用户/媒体数据；不执行其他 SSH 命令、HTTP/API、服务管理、部署或远端写入，不修改本地/远端代码；不访问旧 `D:\EliteSync`，不 pull/push GitHub。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

回执区分 Laravel CLI 路由视图、AUTH-04 静态文件、未核验 Web/HTTP 行为；只运行一次 `git diff --check`，新文档另作尾随空白检查，不运行产品测试或设备操作。Codex 不自接受、不提交、不备份、不推送、不派发后继。Work LEVEL 2 独立 ACCEPT/REJECT；本任务不授权部署修复或进一步服务器核验。
