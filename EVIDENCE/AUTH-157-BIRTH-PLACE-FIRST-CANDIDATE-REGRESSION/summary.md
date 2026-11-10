# AUTH-157 作者候选与验证回执｜2026-09-27

**结论：候选测试已新增，行为 `NOT_VERIFIED`，停 Work 独立 LEVEL 2 审查。** 本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；原有 modified/untracked 工作区内容保留，未提交、拉取或推送。

唯一代码差异是 `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php` 在原有“主字段为空则回退 profile”用例旁新增一个 synthetic 用例：同一虚构账号的 `users.private_birth_place` 和同一 `user_id` 的 `user_astro_profiles.birth_place` 均非空且不同；基础资料读取的 `birth_place`、登录响应的 `user.birth_place` 与 `user.private_birth_place` 都应为主记录值。未改控制器、模型、迁移、认证流程或展示权限。目标测试文件 SHA-256：`F0D9FE995012B74E30515DC527A120343C98E13C7B1449B3808D7A7F332F342B`。

| 验证 | 实际命令与次数 | 结果 |
| --- | --- | --- |
| 语法 | 在 `services/backend-laravel` 执行 `php -l tests\Feature\AuthPasswordApiTest.php`，1/1 次 | 退出码 0；`No syntax errors detected`。 |
| 定向 Feature | 在同目录执行 `php vendor\bin\phpunit tests\Feature\AuthPasswordApiTest.php`，首跑 1/1 次 | 退出码 1；`Tests: 6, Assertions: 0, Errors: 6, Deprecations: 2`。六个用例均在 `RefreshDatabase` 初始化阶段失败：测试配置尝试 MariaDB 连接，返回 `SQLSTATE[HY000] [2002]` 连接被拒绝；新增断言未执行。 |

失败不是已证实的新增测试自身缺陷，故不满足任务单“修正新增测试缺陷后才可复跑”的条件；复跑 **0 次，NOT_RUN**，不更改数据库配置或扩大测试范围。没有成功迁移或读写业务行的回执；本次测试启动曾尝试数据库连接，连接被拒绝。不能据此宣称行为 PASS 或 FAIL。其他测试、真实备份/账号/数据库、SSH/云/生产 API 均 `NOT_RUN`。

回退仅撤销本任务新增测试段及本摘要，保留既有测试、AUTH-156 接受状态和无关工作区改动。Owner 的“第一个非空”仅用于已核定的同一账号两处现有字段顺序，不确定两份备份数据库间的来源优先级、账号集合或真实迁移。作者不自 ACCEPT、不启动后继；待 Work 独立 LEVEL 2 判定候选与环境阻塞。
