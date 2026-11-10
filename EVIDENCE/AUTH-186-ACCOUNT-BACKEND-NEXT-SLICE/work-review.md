# AUTH-186 Work 独立审查｜2026-09-27

**LEVEL 2 ACCEPT，仅接受 docs-only 的下一后端切片建议，不接受登录代码变更。** 唯一交付 `plan.md` SHA-256 `266C24705722313EE1A68B84FCAC1909B2DED0F564643E3CD66A60D128AAA784`；作者本地核对 2/2 轮已耗尽，未运行 PHP/tests。Work 独立只读核对固定源码/测试：`AuthController::login` 当前在 `Hash::check` 返回 false 时给统一 422，之后才签发 token；AUTH-159 的现有未提交测试覆盖人工 bcrypt 正确/错误口令，却无损坏/不支持格式的负例。候选把后继限制在该失败路径与人工账号，明确禁止广义 `Throwable` 捕获、真实数据、重哈希、schema 或账号来源规则，符合现有接受边界。

尚未证明当前 verifier 对所选异常格式是返回 false 还是抛出可狭义识别异常；下一任务须先以定向负例观察，只有必要且异常来源明确时才改控制器。该审查不接受任何旧库哈希兼容结论、最终 nickname/schema、跨库来源或真实账号回填。AUTH-170 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B 与真实恢复继续 `NOT_READY`。Work 未运行测试、数据库或网络动作，未提交、pull 或 push；AUTH-186 预算不重置。
