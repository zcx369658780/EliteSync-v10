# AUTH-02｜纠正私钥后的阿里云 SSH 与部署源码身份事实候选

状态：`BUILDER FACT CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`，分支 `main`，发布及执行基线 HEAD `197afe2005eddb7bd3a4ebf876537f9cf7941c08`。AUTH-01 的旧私钥认证失败事实及原预算保持原状；本文件只记录 AUTH-02 的新授权。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。

## 一次远端只读核验

Owner 纠正的精确私钥路径 `C:\Users\zcxve\.ssh\CodexKey.pem` 与现有 `known_hosts` 均经本地存在性检查为存在；未读取私钥或主机密钥内容。对 `root@101.133.161.203` 启动 SSH 进程 **1/1** 次，使用 `BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，并关闭密码及键盘交互；外部等待上限 20 秒。进程在预算内退出，代码 **0**，固定成功标记 `AUTH02_OK` 出现。严格主机密钥检查通过到认证阶段，指定私钥下 SSH 认证成功；未接受或改写主机密钥，未重试或切换凭据。

远端仅执行精确目录 `/opt/elitesync/services/backend-laravel` 的 `test -d`，再对下表两条精确源码路径执行 `sha256sum`。成功链及固定标记证明该目录检查通过、两条哈希命令成功返回；没有读取远端源码正文或其他文件。

| 源码路径（同一 backend-laravel 根下） | 远端 SHA-256 | 本地 SHA-256 | 字节比较 |
|---|---|---|---|
| `routes/api.php` | `2cdffe4b9cbb48a8059f09afa1eb74f521d1dcf96203c527814d528a65b6fb70` | `b267673f89d9bd4a804a7a19f3c1917c8ccb0d3b21861856270f77dfe11d9365` | **不同** |
| `app/Http/Controllers/Api/V1/AuthController.php` | `460abc3314521ac1bf12278c738887ccad0f93b54d595a81335e27ee4df84551` | `460abc3314521ac1bf12278c738887ccad0f93b54d595a81335e27ee4df84551` | **相同** |

本地哈希分别读取 `services/backend-laravel/routes/api.php` 和 `services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php`。`api.php` 差异只说明本次哈希对应的字节不同；未拉取远端文件、修改任一端或推断差异原因。文件存在与哈希不证明服务器实际运行哪条路由、源码部署来源、可信在线登录事件 `T0`、15/30 天计时、Connection/Consent/CV 权威、数据权利或生产就绪，这些均 **NOT ESTABLISHED**。

## 范围与检查回执

本轮只读核对本地控制文档、指定本地源码、指定私钥与 `known_hosts` 的存在性及 Git 状态。未读取 `.env`、Token、日志、DB、用户资料、媒体或私钥内容；未运行 API、`php artisan`、服务管理、部署、远端写入、产品测试或设备操作。未访问旧 `D:\EliteSync` 或 GitHub。唯一新增路径为本回执；`git diff --check` 按预算运行 **1/1 次，退出 0**；未跟踪文档另作只读尾随空白检查，**0 行**。候选不提交、备份、推送、自接受或派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT 事实门。

## Work 独立验收（2026-09-24）

**LEVEL 2 ACCEPT — 仅严格 SSH 认证与两份源码的字节身份事实。** Work 核对本地发布基线 `197afe2005eddb7bd3a4ebf876537f9cf7941c08`、唯一新增路径、原有未跟踪目录及实际 SSH 调用/输出。调用仅一次，使用 Owner 纠正的 `CodexKey.pem`、指定 `root@101.133.161.203`、严格主机密钥与非交互选项；远端命令仅为目录检查、两条精确源码路径的 `sha256sum` 和固定标记。进程退出 0 且标记出现。Work 独立核对本地两文件哈希和文档尾随空白；暂存差异检查见本地接受提交。

结论限于本次读取的路径：远端 `AuthController.php` 与本地 SHA-256 相同，远端 `routes/api.php` 与本地不同。未读远端正文，差异原因、实际路由、运行中的版本、可信登录事件 `T0`、权限来源和生产行为均 **NOT ESTABLISHED**；不得用成功 SSH 或相同哈希替代这些证明。
