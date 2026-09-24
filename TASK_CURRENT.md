# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-03-DEPLOYED-ROUTE-READONLY-DIFF`

Risk Level: `LEVEL 2`（真实服务器源码只读核对与登录入口解释；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。仅交付精确文件的差异事实候选，停在 Work LEVEL 2 独立验收门。

## Objective and authority

AUTH-02 已接受：严格 SSH 读取的部署 `/opt/elitesync/services/backend-laravel/routes/api.php` SHA-256 为 `2cdffe4b9cbb48a8059f09afa1eb74f521d1dcf96203c527814d528a65b6fb70`，与本地 `services/backend-laravel/routes/api.php` 不同；部署 `AuthController.php` 与本地同哈希。本轮 Owner 明确要求继续推进。只读核对**这一个**部署路由源码文件与本地同路径的具体差异，特别是 `v1/auth/login`、`v1/auth/refresh` 的方法、控制器与中间件声明是否同字节/同语义，以及是否有新增、删除或改动的路由声明。不要从静态源码推定线上实际路由缓存、请求行为、可信登录事件 `T0` 或 15/30 天规则已实现。

先核对本地 `main`、HEAD、工作区，阅读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、项目本地工作流技能、AUTH-02 回执及本地精确路由文件。仅当本任务仍为 `ISSUED` 且分派匹配时执行。

## Remote read boundary

仅一次 SSH 进程调用：`root@101.133.161.203`，私钥 `C:\Users\zcxve\.ssh\CodexKey.pem`，`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，关闭密码/键盘交互，外部等待上限 20 秒。远端命令仅对精确文件 `/opt/elitesync/services/backend-laravel/routes/api.php` 执行 `cat`；从 stdout **仅在内存中**计算 SHA-256 与本地逐行比较，不将整份远端源码保存到磁盘、证据或普通工具输出。最多输出必要的差异行及其本地/远端行号，且不得输出意外出现的凭据字面量；若文件缺失、读取失败、哈希与 AUTH-02 所记值不一致、内容无法安全归类或输出量过大，记录分类后停止推断，不重试或改查其他路径。

严禁读取私钥内容、`.env`、配置/环境变量值、Token、日志、数据库、用户数据或媒体；不运行 `php artisan`、HTTP/API、服务管理、部署、远端写入或其他 SSH 命令。不访问旧 `D:\EliteSync`、不 pull/push GitHub。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

## Allowed output and verification

唯一允许新增 `EVIDENCE/AUTH-03-DEPLOYED-ROUTE-READONLY-DIFF/summary.md`。报告远端 SHA-256 是否仍匹配 AUTH-02、本地 SHA-256、变化的路由声明或仅非路由文本差异、auth login/refresh 精确结论及未核验项；只包含必要的非私密差异片段，不粘贴整份源码。不修改本地/远端路由。仅运行一次 `git diff --check`，未跟踪新文档另作尾随空白检查；不运行产品测试或设备操作。

Codex 不自接受、不提交、不备份、不推送、不派发后继。Work 作 LEVEL 2 独立 ACCEPT/REJECT；成功的静态差异核对不授权真实身份、Token 生命周期、Conversation 权限或生产变更。
