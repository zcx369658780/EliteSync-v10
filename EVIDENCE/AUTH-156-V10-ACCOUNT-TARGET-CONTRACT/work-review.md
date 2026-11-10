# AUTH-156 Work 独立审查｜2026-09-27

**LEVEL 2 ACCEPT，仅接受 docs-only 的 v10 账号目标准备度与缺口矩阵；最终 auth/account schema 仍 `NOT_READY`。** 审查对象 `plan.md`，审查前 SHA-256 `DD96DDDAB037919DAF9359A7091D0B96BF93A8469F88B15D8ABECB0AB3A7DF97`。作者固定来源静态预算 2/2 耗尽，本审查未重用其预算或运行代码、数据库、备份动作。

Work 对照 Owner 在 `PRODUCT_DECISIONS.md` 的最低回填范围和 15/30 天登录/离线决定，核对当前 `User`、`AuthController`、指定迁移与测试。候选正确区分 `ACCEPTED_PRODUCT_DIRECTION`、`CURRENT_CODE_FACT` 和 `PROPOSED_TARGET`：现有 `users.phone/name/password/birthday/private_birth_place` 及 `user_astro_profiles.birth_place` 只能证明旧实现；固定迁移/模型中没有独立 `nickname` 持久字段，`ProfileController` 的 `$user->nickname` 回退不证明字段存在。`name` 不自动等于昵称，`city` 不等于出生地点，当前 `role` 字符串不等于新权限模型。旧库哈希的算法、参数与 Laravel verifier 兼容性，以及两库账号集合/去重和来源优先级均 `UNKNOWN`。

候选将现有 Sanctum `createToken`/`refresh` 与 Owner 已接受的服务端成功交互登录 `T0`、15 天在线、16～30 天条件离线只读和 30 天清理分开，没有把 token 表的 `expires_at` 列误当运行证明。哈希兼容建议仅限 synthetic 测试方案；不兼容时的实际恢复流程仍需后继合同。候选没有写生产 schema、导入脚本或读取真实字段值。

本接受**不**固定新 v10 字段类型/唯一性/受众、不接受现有 `users` 表为迁移目标，也不放行真实账号行、哈希值、AUTH-153 解密/恢复、AUTH-154 Phase B、生产 DB 改库或账号迁移。下一独立工程可以先用人工生成的哈希做本地验证器兼容性负例，不接触备份；昵称/登录标识/出生地点的最终目标语义与账号范围仍须后续证据和 Owner/Work 决策。`git diff --check` 退出 0，但不覆盖未跟踪候选；Work 已单独读取本文件并核对哈希。原有修改和无关未跟踪内容未处理，未提交或推送。
