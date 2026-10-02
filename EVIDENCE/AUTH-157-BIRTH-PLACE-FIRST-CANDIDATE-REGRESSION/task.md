# AUTH-157｜同一账号出生地点冲突的回归测试

状态：`ISSUED`。风险 LEVEL 2（auth 响应与私密资料来源优先级）；派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`。唯一主要结果是现有 Feature 测试文件中的一个有界 synthetic 冲突用例；交付后停 Work 独立 LEVEL 2 审查。

## 固定依据和范围

先核对 `D:\EliteSync-v10` 的本地 `main`、HEAD、dirty 工作区与 `TASK_CURRENT.md`。只读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、`.agents/skills/elitesync-local-workflow/SKILL.md`、`services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php`、`services/backend-laravel/app/Http/Controllers/Api/V1/ProfileController.php`、`services/backend-laravel/app/Models/User.php`、`services/backend-laravel/app/Models/UserAstroProfile.php`、`EVIDENCE/AUTH-156-V10-ACCOUNT-TARGET-CONTRACT/work-review.md` 以及目标测试文件。无需发现或访问其他仓库或数据库。

仅允许修改 `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php`，新增 `EVIDENCE/AUTH-157-BIRTH-PLACE-FIRST-CANDIDATE-REGRESSION/summary.md`。已有测试和其他工作区改动均保留。若现有 fixture 无法在此范围内构造冲突，记录精确阻塞，不扩大路径。

## 交付与验证

在现有“private 为空则回退 profile”测试旁，新增一个虚构账号的 Feature 用例：`users.private_birth_place` 和同一 `user_id` 的 `user_astro_profiles.birth_place` 均为非空且不同；登录响应的 `user.birth_place` 与 `user.private_birth_place` 必须取前者。可同时断言该账号读取基础资料时同一优先级，但不要扩大到真实备份或两个数据库的跨库合并规则。用例不得输出真实个人信息或真实哈希；不修改生产代码、schema、认证流程或产品展示权限。

验证预算：对目标测试文件执行一次定向 PHPUnit；若因本任务新增测试自身缺陷失败，可在允许文件内修正并最多复跑一次同一文件。一次 `php -l` 可作为前置语法检查。记录每次实际命令、退出码、tests/assertions、是否修正；未运行的检查标记 `NOT_RUN`。回退仅撤销本任务新增测试及摘要，不动任何既有改动。交付 diff 与短 `summary.md` 后停 Work LEVEL 2 ACCEPT/REJECT。

不得访问旧 `D:\EliteSync`、SSH、云、备份/密钥目录、真实账号行、生产 DB 或 API；不得解密、恢复、迁移、提交、拉取或推送。AUTH-152～156 和 BE-01～10 的旧预算不重置。Owner 的“第一个”只在已核定的同一账号来源顺序内生效，不能据此确定双库来源优先级或账号集合。
