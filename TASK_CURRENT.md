# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-07-LOCAL-LOGIN-REFRESH-T0-GAP-MAP`

Risk Level: `LEVEL 2`（真实 auth 生命周期与私密缓存计时来源的本地静态映射；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。交付纯本地只读证据清单，停在 Work LEVEL 2 独立验收门。

## Authority and objective

Owner 已决定：在线登录持续 15 天；最后一次**成功在线登录**后第 16～30 天，满足其他条件时离线可继续只读已保存的按账户加密内容；满 30 天清理；自动 Token 续期不重置该时钟。AUTH-02 接受的部署 `AuthController.php` 与本地同哈希，AUTH-04/06 接受的部署源码及 Laravel CLI 视图中 `v1/auth/login`、`v1/auth/refresh` 静态入口存在；这些都不证明可信 `T0`、期限执行或真实客户端权限。四条缺席 v2 路由属于 synthetic/dev-test 入口，尚无部署授权；本任务不处理部署。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能以及 AUTH-02/04/06 证据。只有本任务仍为 `ISSUED` 且派发匹配才执行。

目标：从本地源码精确追踪 `POST /api/v1/auth/login`、`refresh` 的认证、发 Token、有效期、撤销及响应字段；再定位 Flutter 当前调用/持久化入口。逐项判断是否已有可信的“最后一次成功在线登录 T0”来源和持久记录、15 天在线登录边界、refresh 不重置 T0、30 天加密缓存清理触发条件。只报告代码直接证明的状态、缺口和后继合同/实现需要的来源；不得把约定或测试桩写成真实运行证明。

## Scope and verification

只读范围限当前仓库 `services/backend-laravel/routes/api.php`、`app/Http/Controllers/Api/V1/AuthController.php`、其直接使用的 User/token/Sanctum 配置与相关认证 Feature 测试，以及 `apps/flutter_elitesync_module/lib` 内已识别的登录、刷新、session/token 调用链。可用精确符号搜索定位直接依赖；不要读取 `.env`、实际配置值、设备存储内容或全仓泛搜。唯一允许新增 `EVIDENCE/AUTH-07-LOCAL-LOGIN-REFRESH-T0-GAP-MAP/summary.md`，用路径/行号写出正反证据与 UNKNOWN。无需运行测试或构建；只运行一次 `git diff --check`，新文档另作尾随空白检查。

不连接服务器，不使用 SSH、HTTP/API、DB、设备或真实数据；不读私钥、Token、日志、用户/媒体数据；不修改 auth 代码、缓存、路由、配置或部署，不访问旧 `D:\EliteSync`，不 pull/push GitHub。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。Codex 不自接受、不提交、不备份、不推送、不派发后继。Work LEVEL 2 独立 ACCEPT/REJECT；真实 auth、离线凭据与生产变更仍需后继明确任务及相应风险门。
