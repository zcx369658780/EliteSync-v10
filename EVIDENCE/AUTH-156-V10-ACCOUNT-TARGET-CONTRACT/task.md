# AUTH-156｜v10 账号、认证与基本资料目标合同核对

状态：`ISSUED — DOCS-ONLY`。风险 LEVEL 2（auth、账号数据模型与私密资料；本轮仅本地静态合同）。派发最新合资格 Codex 执行会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；唯一交付同目录 `plan.md`，交付后停 Work 独立 LEVEL 2 审查。

## 固定来源与允许路径

先核对实时仓库 `D:\EliteSync-v10`、本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、dirty 工作区和 `TASK_CURRENT.md`。只读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、下列精确现有源码/测试/迁移及已接受设计：

- `services/backend-laravel/app/Models/User.php`
- `services/backend-laravel/app/Models/UserAstroProfile.php`
- `services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php`
- `services/backend-laravel/app/Http/Controllers/Api/V1/ProfileController.php`
- `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php`
- `services/backend-laravel/tests/Feature/AuthQuestionnaireApiTest.php`
- `services/backend-laravel/database/migrations/0001_01_01_000000_create_users_table.php`
- `services/backend-laravel/database/migrations/2026_03_21_120000_add_profile_privacy_fields_to_users_table.php`
- `services/backend-laravel/database/migrations/2026_03_21_200000_create_user_astro_profiles_table.php`
- `services/backend-laravel/database/migrations/2026_04_09_120000_add_account_layer_fields_to_users_table.php`
- `services/backend-laravel/database/migrations/2026_03_11_144705_create_personal_access_tokens_table.php`
- `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md`
- `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md`
- `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_ACCEPTANCE_V0_1.md`
- `EVIDENCE/AUTH-154-TWO-DB-ACCOUNT-STRUCTURE-AUDIT-PATH/work-review.md`
- `EVIDENCE/AUTH-155-LOCAL-ISOLATION-CAPABILITY-PREFLIGHT/work-review.md`

如固定来源不足，精确写 `NOT_FIXED/UNKNOWN`；不搜索旧 `D:\EliteSync`、备份/密钥目录、业务行、`.env`、服务器或未经列明的代码来补。现有 User/AuthController/迁移是**实现现状**，不是新 v10 auth/account schema 的产品接受；历史设计接受也不自动授权 schema/endpoint。

## 唯一交付 `plan.md`

1. 将 Owner 后续回填字段最低目标逐项列成矩阵：账号/登录标识、**现有密码哈希**、昵称、生日、出生地点。每项区分产品决定、当前 Laravel 模型/迁移/API 的观察、可能的 v10 目的/受众、数据类型与约束候选、隐私分层、来源未知项、是否足以确定目标字段。另列先前提及的权限/角色为待核依赖，不把当前 `role` 字符串视为已接受的新权限模型。不得索取或处理明文密码、真实哈希值、生日或出生地值。
2. 特别核对当前 `users.name`、`phone`、`password` cast、`birthday`、`private_birth_place` 与 `user_astro_profiles.birth_place` 的关系；`nickname` 在当前模型/迁移是否有持久字段，只按固定来源定性。禁止把 `name` 自动等同昵称，或把展示地理位置自动等同出生地点；不足时 `NOT_FIXED`。
3. 区分旧密码哈希的**结构可映射**与**认证兼容**：当前 `Hash::check`/Laravel cast 是实现事实，备份中的算法、参数、编码与可验证性未知。只设计离线 synthetic hash 兼容验证与失败/升级策略所需证据，不导出哈希值、不假设可直接登录或静默重置。账号集合、两库来源优先级和去重规则仍待隔离恢复后逐对象结构核对及 Owner 决定。
4. 将 Owner 已接受的 15 天在线登录、最后一次成功交互登录 `T0`、第 16～30 天有条件离线只读和 30 天清理方向与当前 token/session 代码证据分开；列明服务端登录锚、账户/设备绑定凭据、撤销与时间异常所需后继合同，不能宣称现有 Sanctum token 已满足。真实身份 assurance、有效权限签发与生产账号迁移不能从当前 controller 推定。
5. 给出**下一最小后端工程切片**的两种可能：若现有产品决定足以支持纯本地、synthetic、无真实数据的字段合同/校验代码，固定精确文件、接口、负例、定向测试和回退；若目标语义缺失，明确最小 Owner/Work 决策或技术来源缺口，不先写 migration、真实账号导入脚本或生产 endpoint。不得把备份字段名臆造成 v10 来源表，也不得将聚合 43/532/66、18/195/11 当逐对象证明。
6. 结论必须分别标记 `ACCEPTED_PRODUCT_DIRECTION`、`CURRENT_CODE_FACT`、`PROPOSED_TARGET`、`UNKNOWN/NOT_READY`。说明目标合同接受也仅供后继工程任务和 AUTH-154 结构映射使用，不放行 AUTH-153 真实解密/恢复、账号行读取、生产 DB 改库或迁移。

## 预算与停点

最多两轮固定来源静态核对；仅新增/修改 `EVIDENCE/AUTH-156-V10-ACCOUNT-TARGET-CONTRACT/plan.md`，记录检查轮数、关键源摘要、差异和 `NOT_RUN`。不运行 PHPUnit/Composer/Artisan、Docker/WSL/VM、备份/解密/恢复、DB、SSH/云/生产 API，不修改代码、迁移、任务状态或既有证据，不提交/pull/push。保留所有原有 modified/untracked；AUTH-152～155 与 BE-07～10 旧预算不重置。作者交付候选后停 Work 独立 LEVEL 2 审查，不自接受或启动代码后继。
