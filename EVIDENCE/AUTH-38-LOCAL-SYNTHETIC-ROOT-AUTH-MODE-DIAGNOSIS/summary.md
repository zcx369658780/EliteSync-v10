# AUTH-38｜本机虚构 root 认证方式对比回执

状态：**三种只读认证方式已按序观察，待 Work LEVEL 2 独立 ACCEPT/REJECT**。本次只在新建的本机隔离虚构容器中执行 `SELECT 1`；未创建业务 schema/行，未运行 dump/restore。执行日期：2026-09-24（Asia/Shanghai）。

## 派发与固定范围

- 本地 `D:\EliteSync-v10`、`main`；执行前 HEAD `79f7f7529751513c6511313241375a36d13dc501`，父提交 `c20d430a2184eed10a39e7cdc5eac34a6fe46701`，符合任务单派发拓扑。执行前工作区只有原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`，保持原状；本任务仅新增本目录的 `run.ps1` 与本文件。
- `TASK_CURRENT.md` 为 `AUTH-38-LOCAL-SYNTHETIC-ROOT-AUTH-MODE-DIAGNOSIS`、`ISSUED — NOT STARTED`、指派 Codex、LEVEL 2。已核对 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地工作流技能及 AUTH-32～37 的受限证据。AUTH-37 的约 20/40/60 秒三次环境变量密码认证均返回 `1045`，旧预算已耗尽。
- `run.ps1` 静态解析 **0 个错误**；静态核对固定唯一容器 `elitesync-auth38-auth-modes`、本地镜像 `mariadb:10.11`、`--pull never`、`--network none`、无宿主挂载/端口、三个容器内 tmpfs、AUTH-32 解析器哈希、启动至少 45 秒后只读认证顺序、安全码白名单与按本次 ID 精确清理。仅使用本任务固定虚构密码。静态检查后执行脚本 **1/1 次**。

## 一次执行回执

| 阶段或方式 | 固定结果 | 实际调用 |
|---|---|---:|
| 本机 context、daemon、固定镜像、唯一名称及解析器预检 | `PASS` | 各 1 次 |
| 固定容器启动和隔离声明检查 | `PASS` | 启动 1 次、inspect 1 次 |
| ① 同一虚构密码经 `MYSQL_PWD` 传入 | `FAIL`；安全码 `1045` | 1 次 |
| ② 同一虚构密码经显式客户端参数传入 | `FAIL`；安全码 `1045` | 1 次 |
| ③ 不传密码的本机 socket 连接 | `PASS`；无错误码 | 1 次 |
| 本次容器精确清理 | `PASS` | 按 ID 删除 1 次、按固定名称核对不存在 1 次 |

认证方式总阶段为 `PASS`，表示第三种方式在本次虚构容器中返回退出码 0 且 stdout 严格为 `1`；最早失败仍记录为 `ENV_PASSWORD_FAILED`。脚本报告总耗时 **52 秒**，低于 120 秒上限。调用账本：parser read 1、context 1、daemon 1、image 1、name preflight 1、run 1、isolation inspect 1、三种认证各 1、remove 1、absence check 1、异常所有权检查 0。原始 stderr/stdout、密码、环境变量、进程参数、Docker inspect/log、SQL 内容和容器 ID 未保存或显示。

验证：`git diff --check` 按预算执行 1/1 次，退出码 0、无输出；该检查不覆盖未跟踪新文件，`run.ps1` 和本文件另作只读尾随空白检查，均为 0 行。无需 Flutter/Laravel 产品测试或构建。

本次现象是：带同一虚构密码的两种方式均获 `1045`，不带密码的本机 socket 方式成功。它不确定镜像的具体认证规则、密码设置或初始化原因，也不能直接解释 AUTH-33 合并 setup 的原始失败，更不能推断真实服务端认证配置。固定隔离声明 `PASS` 不等于实际网络隔离负向测试；未证明虚构 dump/restore、真实 DB 身份或真实备份可恢复。本任务一次运行预算已耗尽，不修改脚本、不重试、不操作截图中的旧容器。未访问旧仓库、浏览器、SSH、云、真实数据库、备份目录、真实凭据/密钥或业务数据，未运行写 SQL、真实备份、传输或改库。作者不提交、推送、制作 bundle、自接受或派发后继，停在 Work LEVEL 2 独立 ACCEPT/REJECT。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受这次虚构容器中三种只读认证方式的观察。** Work 核对派发 HEAD `79f7f7529751513c6511313241375a36d13dc501`、父提交 `c20d430a2184eed10a39e7cdc5eac34a6fe46701`，候选仅本目录 `run.ps1`、`summary.md`；审查前分别 297、26 行，SHA-256 `CB9C998E152CC7F142149CB771CD3651967BF5CAA3ACC44C93D8A6DA389CFC98`、`5C3BF070402A5B8EE4F96F674FF1000C03D2C84EA174A70BB224A66F2CD136FC`，均无尾随空白。Work 静态解析脚本为 0 错误，独立 `git diff --check` 退出 0；未复跑容器脚本。

脚本静态核对了本机固定镜像/名称、无网络/端口/宿主挂载、三个 tmpfs、AUTH-32 解析器哈希、启动后等待、三种只读 `SELECT 1` 的条件顺序、安全码白名单和按本次 ID 清理。作者一次运行回执报告前两种带虚构密码的方式均为 `1045`，第三种不传密码的本机 socket 连接为 PASS，容器按 ID 清理并核对不存在。原始错误及 Docker 对象未保存，这些仍是作者设备回执；不能由此判定 `1045` 的具体配置原因或真实服务端的登录规则。旧预算耗尽；后继若使用此无密码连接，只能在新任务的一次隔离虚构容器内验证，不得套用到真实数据库。
