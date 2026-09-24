# AUTH-09｜隔离 synthetic 登录锚事件候选判定

状态：`BUILDER CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`、`main`，派发及执行基线 HEAD `1ea7de7c299b6baeeec20702de6beb54460933a9`。类型：backend Domain 的 synthetic/dev-test 纯判定与单元测试；不涉及 DB、路由、Flutter、部署或真实凭据。

## 候选结果

仅新增三条授权路径：

- `services/backend-laravel/app/Domain/SyntheticLoginAnchorTransitionEvaluator.php`
- `services/backend-laravel/tests/Unit/SyntheticLoginAnchorTransitionEvaluatorTest.php`
- `EVIDENCE/AUTH-09-SYNTHETIC-LOGIN-ANCHOR-TRANSITION/summary.md`

判定器输入是调用方显式声明的当前锚、事件和目标账户/设备；不读系统时间、Token、数据库或服务端状态。只有 `INTERACTIVE_LOGIN` 且来源确认声明为 `true`、账户/设备一致、严格递增整数顺序、有效整数 `T0`，并且 `T0` 不早于原锚时，才返回可形成候选及建议锚。首个锚也要求全部字段。refresh、register、restore、token rotation 与未知事件均不重锚。重放、乱序、跨账户/设备、缺来源确认、缺顺序或时间、时间倒退及无效当前锚明确拒绝。拒绝时保留有效原锚；当前锚本身无效时不返回锚。

每项结果均声明 `caller_claims_only=true`、`server_source_verified=false`、`zero_writer=true`，并令 `authentication_grant`、`offline_read_grant`、`online_read_grant`、`send_grant` 全为 `false`。`source_confirmed=true` 仅是调用方提供的合成声明，判定器不验证签名、身份或服务端事实；建议锚不能作为真实 `T0` 或离线凭据。现有 AUTH-07 缺口及 AUTH-08 合同所列真实来源、可靠时间、15/30 天执行与私密内容清理仍为 **NOT ESTABLISHED**。

## 定向验证

| 检查 | 实际回执 |
|---|---|
| `php vendor/bin/phpunit tests/Unit/SyntheticLoginAnchorTransitionEvaluatorTest.php` | 运行 **1/2** 次允许预算，退出码 0；**13 tests, 272 assertions**。覆盖首锚、严格更新、各非交互事件、重放/乱序、跨账户/设备、缺或无效声明、时间倒退、无效上下文/旧锚，以及候选无读发 grant。 |
| `php -l app/Domain/SyntheticLoginAnchorTransitionEvaluator.php` | 运行 **1/1** 次语法检查，退出码 0；`No syntax errors detected`。测试文件由上述 PHPUnit 成功加载执行。 |
| `git diff --check` | 运行 **1/1** 次，退出码 0、无输出；该命令不覆盖未跟踪新文件。 |
| 三个新增文件尾随空白 | 单独只读检查：源码 130 行、测试 198 行、回执 26 行，均为 **0 行**尾随空白。 |

未运行服务、构建、API/HTTP、DB 或设备操作；未读 `.env`、私钥、实际 Token、日志或用户/媒体数据，未访问旧 `D:\EliteSync` 或 GitHub。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。作者不提交、备份、推送、自接受或派发后继；候选停在 Work LEVEL 2 独立 ACCEPT/REJECT。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅隔离 synthetic 登录锚候选判定。** Work 核对发布基线 `1ea7de7c299b6baeeec20702de6beb54460933a9`、三条新增允许路径与代码：只有调用方声明的交互登录、来源确认、同账户/设备、严格更新事件顺序和不倒退时间才形成候选；refresh/register/restore/token rotation、重放/乱序、跨账户/设备、缺项和无效当前锚均不得重锚。结果固定 `server_source_verified=false` 且各类读发 grant 为 false，没有接入 AuthController、路由、DB、Flutter 或清理。Work 独立重跑精确 PHPUnit 文件，**13/13 tests、272 assertions PASS**；三个新文件尾随空白均为 0，暂存差异检查见本地接受提交。

这里的 `source_confirmed=true` 只是虚构调用方声明，判定器没有验证服务端事实、签名或设备身份；`can_form_candidate=true` 绝不可作为真实 `T0`、离线读取或在线授权。可信登录事件来源、持久化、15/30 天执行和离线凭据仍 **NOT ESTABLISHED**。
