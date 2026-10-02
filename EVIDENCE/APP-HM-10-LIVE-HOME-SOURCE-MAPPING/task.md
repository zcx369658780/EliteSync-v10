# APP-HM-10｜Home 活态来源边界的本地静态映射

状态：`ISSUED`；风险 `LEVEL 2`（Home read-model / 权威来源，docs-only）；派发 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。唯一交付本目录 `plan.md`，然后停 Work 独立 LEVEL 2 审查。

## 目标与来源

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 全部保留。先读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`，本地 workflow 技能，APP-HM-09 的 `work-review.md`。以 `docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md`、`docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md` 的 Home/APP-T12 G-08 为规划边界。

限定静态读取当前本地以下实现及其直接 import/调用所需的同仓库定义：`apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart`、`state/calm_home_projection.dart`、`pages/home_page.dart`，`features/match/presentation/providers/match_providers.dart`，`features/connection/presentation/providers/connection_presentation_provider.dart`，`features/chat/presentation/state/conversation_access_state.dart`，`services/backend-laravel/app/Http/Controllers/Api/V1/HomeController.php`、`app/Domain/CalmHomeReadOnlyCompositionEvaluator.php`、`routes/api.php`；可只读参考对应现有 Home 测试与 `EVIDENCE/APP-HM-01-*` 至 `APP-HM-09-*` 已接受审查。不得访问旧 `D:\EliteSync`、真实账号、DB、备份、密钥、SSH 或云/生产资源。

`plan.md` 用精确文件/符号证据列出：当前 Flutter Home 每个摘要字段的输入及 synthetic/静态来源；当前 Laravel Home 端点及 read-only evaluator 实际提供什么；客户端与后端之间是否已有可消费的 live Home 合同，哪些字段没有权威 producer 或 actor/audience 绑定；哪些既有 feed/路由只是旧内容面，不可误当 Calm State Hub 活态来源。最后只建议**一张**后续无需真实数据的最小工程切片，写清它的输入、允许文件候选、验证边界及明确未证明项；若证据不足则写 `NOT_READY` 和缺少的精确来源，不发明状态/权限/产品策略。不修改代码或发布后继。

## 预算与停点

最多两轮本地只读静态核对；每轮记录读取的固定来源与发现。不得运行测试、构建、`pub get`、Composer、网络或任何 DB 命令。只新增/修改本目录 `plan.md`；交付时记录文件 SHA-256、`git status --short` 的目标路径、静态预算消耗和未解门。旧预算不重置。候选作者不得自验收、提交、pull、push 或启动后继。真实 APP-T12 G-08、AUTH-170、AUTH-155 Phase B、CMS 认证/隔离恢复及账号回填均保持原状态。
