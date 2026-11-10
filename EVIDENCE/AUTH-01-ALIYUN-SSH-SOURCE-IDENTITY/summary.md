# AUTH-01｜阿里云 SSH 与部署源码身份事实候选

状态：`BUILDER FACT CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`，分支 `main`，派发与执行基线 HEAD `cddb0003529f7d305ae2cbf8477ee3419731a4e9`。工作区原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留；本轮仅新增本文件。

## 一次远端尝试

Owner 本轮指定的 `C:\Users\zcxve\.ssh\codexkey` 与现有 `known_hosts` 均经本地存在性检查为存在；未读取私钥内容或主机密钥内容。使用 `root@101.133.161.203`，SSH 进程调用 **1/1** 次，启用 `BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，并关闭口令及键盘交互。进程外部等待上限 20 秒；实际在该上限内结束，退出码 **255**。本地仅将 SSH 错误归类为 **`AUTHENTICATION_REJECTED`**，远端标准输出为空。未观察到主机密钥拒绝；严格检查保持开启，认证阶段的失败不建立远端登录成功或部署身份事实。未改写 `known_hosts`，未换用户、私钥或参数，未重试。

远端预定只读命令是对 `/opt/elitesync/services/backend-laravel` 执行 `test -d`，随后仅对指定两条源码路径执行 `sha256sum`，最后输出固定成功标记。因 SSH 认证失败，远端目录存在性、两个文件存在性与哈希均为 **NOT CHECKED**；不能比较部署与本地源码是否同字节。

## 本地源码哈希

| 本地精确路径 | SHA-256 | 远端对应文件 / 比较 |
|---|---|---|
| `services/backend-laravel/routes/api.php` | `b267673f89d9bd4a804a7a19f3c1917c8ccb0d3b21861856270f77dfe11d9365` | `routes/api.php`：NOT CHECKED / UNRESOLVED |
| `services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php` | `460abc3314521ac1bf12278c738887ccad0f93b54d595a81335e27ee4df84551` | `app/Http/Controllers/Api/V1/AuthController.php`：NOT CHECKED / UNRESOLVED |

这些只是本地文件的当前字节哈希。没有读取远端源码、`.env`、Token、日志、DB、用户数据或媒体；没有执行远端写入、API、部署、服务管理或产品测试。真实身份来源、成功在线登录事件 `T0`、15/30 天计时、Connection/Consent/CV 权威、数据权利、线上路由运行及生产可用均 **NOT ESTABLISHED**。

## 范围与验证

本轮仅只读核对本地控制文档、指定本地源码、私钥/`known_hosts` 的存在性及 Git 状态；没有访问旧 `D:\EliteSync`、GitHub 或其他凭据。`git diff --check` 按预算运行 **1/1 次，退出 0**；本文件为未跟踪新文件，另作只读尾随空白检查，**0 行**。作者不提交、备份、推送、自接受或派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT 事实门。

## Work 独立验收（2026-09-24）

**LEVEL 2 ACCEPT — 仅认证失败及本地哈希事实；远端 NOT CHECKED。** Work 核对本地 `main` 基线 `cddb0003529f7d305ae2cbf8477ee3419731a4e9`、唯一新增路径、原有未跟踪目录和实际执行回执。SSH 进程使用任务指定的用户、地址、私钥及严格主机密钥选项，只有 **1 次**；回执为 `SSH_EXIT=255`、`SSH_RESULT=AUTHENTICATION_REJECTED`、`SSH_STDOUT_PRESENT=False`。没有观察到远端命令输出，因此不接受部署目录或远端源码存在、同字节、运行状态或真实身份权威的任何结论。Work 独立核对本地两文件 SHA-256 与尾随空白；暂存差异检查见本地接受提交。更换私钥或用户需另获 Owner 明确范围，不能从历史地图自动推定当前凭据有效。
