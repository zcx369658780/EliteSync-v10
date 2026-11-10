# AUTH-186｜本地账号后端下一工程切片定位

**2026-09-27 Work 派发；LEVEL 2，docs-only。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。C ABI 对照工具链的固定定位为 `UNAVAILABLE/NOT_FIXED`，不应妨碍无需真实数据的本地后端工作。本任务从既有账号产品边界和当前 Laravel 代码中选出**一个**可独立实施、可测试的安全切片，供 Work 后续另行发布；不直接实施。

## 精确范围

先核对根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、Git HEAD/dirty。只读 AUTH-156、157、158、159、160、162 的 `work-review.md` 和对应 `plan.md`/`summary.md`，及 `services/backend-laravel` 内与 `User`、认证、profile、`PrivateAccountTargetCandidate` 直接相关的源码、迁移和定向测试。代码结构优先用可用的项目代码图谱；不可用时可用 `rg`，说明限制。唯一允许新增/修改本目录 `plan.md`。

`plan.md` 必须区分已接受产品方向、当前代码事实、仅 synthetic 候选和仍需 Owner/Work 定义的目标。指出一个不依赖真实备份/账号行、不会提前固定 nickname/schema、跨库优先级或权限的后端工程切片：精确允许文件、行为变化、主要负向用例、验证命令及建议预算、回退方式、风险级别和审查门。如果现有证据不足以安全选出切片，明确 `NO_SAFE_SLICE` 与精确缺口，不凭猜测给实施授权。不要把现有私密候选接到生产登录/DB 消费者。

## 预算与停点

最多 2 轮固定本地来源/代码核对，最后 1 次交付文件路径/哈希/格式核对。不得修改后端源码、迁移或测试，不运行 PHP/tests/build/Docker/WSL，不访问真实密文、密钥、账号值、DB、SSH/云/API、GitHub 或旧 `D:\EliteSync`，不提交、pull 或 push。保留既有 dirty/untracked；旧预算不重置。作者不自接受、不派发后继，交付后停 Work 独立 LEVEL 2 审查。
