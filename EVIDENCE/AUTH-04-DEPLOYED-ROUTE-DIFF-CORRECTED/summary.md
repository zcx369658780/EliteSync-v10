# AUTH-04｜部署路由源码差异事实候选

状态：`BUILDER FACT CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`，分支 `main`，派发及执行基线 HEAD `9dde66d805aefc1dd116644537727ea05e4b444c`。AUTH-03 的 SSH 预算和差异任务拒绝结论保持原状；本文件只记录 AUTH-04 的新授权。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。

## 纯本地预检

在连接服务器前，用 Python 标准库 `difflib.unified_diff` 对当前本地 `services/backend-laravel/routes/api.php` 做两项检查：与自身比较 **0** 差异行；与 `git show e34d6530270d:services/backend-laravel/routes/api.php` 的本地历史字节严格 UTF-8 解码后比较 **19** 差异行，非零且有限。两项通过后才执行远端读取。这里的 19 行是本次比较器输出计数，不是远端差异。

## 一次远端只读读取

SSH 进程调用 **1/1** 次，使用 `root@101.133.161.203`、`C:\Users\zcxve\.ssh\CodexKey.pem`、`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，关闭密码和键盘交互，外部等待上限 20 秒。远端命令仅为 `cat /opt/elitesync/services/backend-laravel/routes/api.php`；进程在预算内退出 **0**。远端 stdout 只在内存中读取，未保存或打印整份源码，未调用其他远端命令。

远端读取 **15,271 字节**，SHA-256 `2cdffe4b9cbb48a8059f09afa1eb74f521d1dcf96203c527814d528a65b6fb70`，与 AUTH-02/03 所记值相同；本地 SHA-256 `b267673f89d9bd4a804a7a19f3c1917c8ccb0d3b21861856270f77dfe11d9365`。远端 257 行、本地 261 行。严格 UTF-8 解码、敏感字面量启发式检查及不超过 64 KiB 的上限检查均通过；本地到远端的完整受限 `unified_diff` 为 **28 行**，在 120 行输出预算内。以下只摘录变更事实，不粘贴整份源码。

## 静态文本差异

| 方向（本地 → 远端） | 精确源码事实 |
|---|---|
| 远端缺少本地四条 v2 POST 声明 | `/contracts/application-envelope` → `TransportEnvelopeController`；`/canonical-match/evaluations` → `CanonicalMatchEntryController::evaluate`；`/canonical-match/invalidations` → `CanonicalMatchEntryController::invalidate`；`/runtime-readiness/evaluations` → `RuntimeReadinessEvaluationController`。本地行 38–41；对应三个 controller 的 `use` 声明在远端也缺少（本地行 28、30–31）。 |
| 远端多一条 v1 media POST 声明 | `Route::post('/{assetId}/process-demo', [MediaController::class, 'processDemo'])`，附 `whereNumber('assetId')` 与 `throttle:media`；位于 `media` 前缀组，本地无该声明。远端差异 hunk 从行 129 开始。 |

`v1/auth/login`：本地行 55、远端行 48 均为 `POST /login` → `AuthController::login`，行内中间件 `throttle:auth`，声明逐字相同。`v1/auth/refresh`：本地行 56、远端行 49 均为 `POST /refresh` → `AuthController::refresh`，行内中间件 `auth:sanctum`，声明逐字相同。两侧的 `v1` 与 `auth` 前缀组声明文本也相同；本次逐行差异未涉及这些入口。以上仅是该文件静态声明核对，不证明线上路由缓存、请求行为、真实认证成功事件 `T0`、Token 生命周期或 15/30 天政策已实现。

没有读取私钥、`.env`、配置/环境变量值、Token、日志、DB、用户/媒体数据；没有执行 `php artisan`、HTTP/API、服务管理、部署、远端写入或读取其他线上路径。未修改本地/远端路由。Connection/Consent/CV 权威、数据权利与生产可用仍 **NOT ESTABLISHED**。

## 范围与验证

只读核对本地控制文档、AUTH-02/03 回执、本地精确路由文件及 Git 状态。未运行产品测试、设备或全量搜索，未访问旧 `D:\EliteSync` 或 GitHub。`git diff --check` 按预算运行 **1/1 次，退出 0**；本文件作为未跟踪新文档另作只读尾随空白检查，**0 行**。作者不提交、备份、推送、自接受或派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT 事实门。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受指定部署源码文件的静态差异事实。** Work 核对发布基线 `9dde66d805aefc1dd116644537727ea05e4b444c`、唯一候选路径、AUTH-02/03 已接受的远端哈希及本地文件 SHA-256；本地行 38–41、53–56 与所报四条 v2 声明和 auth 两入口一致。回执明确记录本地预检先通过、新任务 SSH 1/1、远端哈希仍为 `2cdffe4b9cbb48a8059f09afa1eb74f521d1dcf96203c527814d528a65b6fb70`，且两类差异与字节数、行数变化相容。Work 核对新文档无尾随空白，工作区只有该候选及受保护的无关未跟踪目录；不再连接服务器或重耗 Codex 的一次验证预算。

本接受结论限于作者当次内存读取的源码比较回执；远端全文未保存，Work 不能离线重算远端 diff。服务器正在使用的路由缓存、HTTP 行为、真实登录事件与权限、15/30 天规则和部署安全性仍 **NOT ESTABLISHED**。部署源码缺少本地四条 v2 POST 路由，属于后继需评估的环境差异；本验收不授权修改服务器。
