# AUTH-06｜部署目录 Laravel CLI v2 路由列表只读事实候选

状态：`BUILDER FACT CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`，分支 `main`，派发及执行基线 HEAD `9465f7a148b9baf78cf00161f8015811d7fcd832`。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留；本轮唯一新增文件为本回执。

## 一次只读路由列表

UTC 启动时刻：`2026-09-24T00:59:32+00:00`。按任务单对 `root@101.133.161.203` 使用 `C:\Users\zcxve\.ssh\CodexKey.pem`，启用 `BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，关闭密码和键盘交互；SSH 进程调用 **1/1** 次，外部等待上限 30 秒。唯一远端命令为 `cd /opt/elitesync/services/backend-laravel && php artisan route:list --json --path=api/v2`。进程在预算内退出 **0**；严格主机密钥检查和认证通过。stdout 为 **661 字节**，非空、低于 256 KiB，严格 UTF-8 解码及 JSON 数组/字段结构检查通过；原始列表与 stderr 未保存或整份输出。

此次 Laravel CLI `--path=api/v2` 结果共 **3 条路由**。对四条任务指定的精确 URI，内存解析得到：

| 精确目标 URI | 匹配数 | 方法 / action / middleware |
|---|---:|---|
| `api/v2/contracts/application-envelope` | 0 | 无匹配项可报告 |
| `api/v2/canonical-match/evaluations` | 0 | 无匹配项可报告 |
| `api/v2/canonical-match/invalidations` | 0 | 无匹配项可报告 |
| `api/v2/runtime-readiness/evaluations` | 0 | 无匹配项可报告 |

这是**本次在部署目录启动的 Laravel CLI 路由视图**中的准确缺席结果，不是空 stdout 或解析失败。AUTH-04 已接受的另一层事实是其当次读取的部署 `routes/api.php` 缺少这四条静态声明；AUTH-05 仅列出本地 controller/合成测试的条件性影响。本次 CLI 观察与该静态差异相容，但没有检查 Web worker 正在使用的路由缓存、前置代理、HTTP 可达性、调用量、真实登录事件 `T0`、15/30 天计时、权限或生产行为。不能据此宣称应用线上请求一定返回 404，也不授权部署修复。

## 范围与验证

仅只读核对本地控制文档、AUTH-04/05 接受证据及 Git 状态；只运行上述一条获授权的远端路由列表命令。未读取私钥内容、`.env`、配置/环境变量值、Token、日志、DB、用户或媒体数据；未执行其他 SSH 命令、HTTP/API、服务管理、部署或远端写入，未修改本地/远端代码。未访问旧 `D:\EliteSync` 或 GitHub，未运行产品测试或设备操作。`git diff --check` 按预算运行 **1/1 次，退出 0**；未跟踪新文档另作只读尾随空白检查，**0 行**。作者不提交、备份、推送、自接受或派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT 事实门。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受此次部署目录 Laravel CLI 路由视图事实。** Work 核对发布基线 `9465f7a148b9baf78cf00161f8015811d7fcd832`、唯一新增证据路径、本地 `routes/api.php:34–42` 的七条 v2 声明及 AUTH-04 已接受的部署源码差异。作者回执记载新任务 SSH 1/1、唯一远端命令退出 0、661 字节 JSON 成功解析为三条 v2 路由，四个精确 URI 各匹配 0；这个计数与部署源码保留前三条、缺少后四条相容。Work 核对新文档无尾随空白及无其他工作区改动；按预算未再次连接服务器。上述远端执行与解析细节依赖作者的一次性回执，未保存原始列表供离线重算。

作者的“未读取 DB”只可理解为**未主动执行 DB 读取命令**；Laravel CLI 启动过程是否内部访问数据库，本轮没有观测。CLI 路由视图仍不能证明 Web worker、代理、HTTP 状态或真实用户影响。四条路由在本地是 synthetic/dev-test 入口，是否应部署到该服务器属于环境与发布决策；本接受结论不授权部署变更、HTTP 探测或进一步服务器命令。
