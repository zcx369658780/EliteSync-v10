# AUTH-156｜v10 账号、认证与基本资料目标合同核对（作者候选）

**结论：`UNKNOWN/NOT_READY` — 五项最低回填目标是 `ACCEPTED_PRODUCT_DIRECTION`，但固定来源不足以确定新的 v10 auth/account 字段合同、旧库逐字段映射或认证兼容。** 当前 Laravel 模型、控制器、迁移与测试仅属 `CURRENT_CODE_FACT`；下表类型/约束与受众是 `PROPOSED_TARGET`，不是已接受 schema。本文只供 Work 独立 LEVEL 2 审查，以及审查后另发工程任务和 AUTH-154 后续结构映射使用；不授予迁移、真实数据读取或生产动作。

## 固定来源与预算

本地 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，工作区原有 modified/untracked 保留。`TASK_CURRENT.md` 将本任务标为 `ISSUED — DOCS-ONLY`，唯一允许写入本文件。固定来源静态核对 **2/2 轮**：第一轮对任务单列出的产品方向、已接受文件、模型、控制器、迁移和两份 Feature test 作定向摘取；第二轮对相同精确来源作逐项复核。没有借名称搜索旧仓库、备份、密钥、业务行、`.env` 或未列明代码。对来源缺口不作猜测。

主要依据：`PRODUCT_DECISIONS.md` 的 2026-09-27 回填最低范围和 2026-09-24 登录/离线决定；`docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md` §2(8)、§4；两份 backend authority planning acceptance 的“规划不等于 schema/API/实现”界限；任务单所列五份迁移、两份模型、`AuthController.php`、`ProfileController.php` 和两份 Feature test。`EVIDENCE/AUTH-154-TWO-DB-ACCOUNT-STRUCTURE-AUDIT-PATH/work-review.md` 仅接受 docs-only 双库结构核对路径；`EVIDENCE/AUTH-155-LOCAL-ISOLATION-CAPABILITY-PREFLIGHT/work-review.md` 保持现场 Phase B `NOT_READY_TO_RUN`。

## 五项最低目标矩阵

| 项目 | `ACCEPTED_PRODUCT_DIRECTION` | `CURRENT_CODE_FACT`（只限列明代码） | `PROPOSED_TARGET`：目的/受众、类型与约束候选、隐私层 | 来源未知与目标字段准备度 |
| --- | --- | --- | --- | --- |
| 账号／登录标识 | 后续必要账号信息回填；具体账号集合未定。 | `users.id` 主键，`phone` 长度 32 且唯一；`AuthController` 注册/登录以 phone 查找并签发 Bearer token。`email` 在初始迁移可空且唯一。 | 仅供账户识别与认证服务的稳定标识；候选为内部不可复用 account ID 加受验证的登录标识，唯一性、格式、空值、变更及冲突处理待定；Private Identity。 | 旧两库实际账号键、phone/email 完整性、跨库同人判定、来源优先级均 `UNKNOWN`；新字段与约束 `NOT_FIXED`。不能把现有 phone 唯一约束直接继承为产品决定。 |
| **现有密码哈希** | 仅回填已存在的哈希；不索取、恢复或处理明文密码。 | `users.password` 非空 string、模型 hidden 且 `hashed` cast；注册和改密使用 `Hash::make`，登录与改密用 `Hash::check`。`AuthPasswordApiTest` 只验证测试凭据的旧 API 行为。 | 候选为认证服务独占的不可展示哈希材料；受保护类型/长度、算法标识、升级状态和失败处理需合同；不进普通 profile/API/证据。 | 备份哈希算法、参数、编码、截断/损坏与目标 verifier 兼容性 `UNKNOWN`。**结构可映射 ≠ 可验证登录**；目的字段 `NOT_FIXED`。 |
| 昵称 | Owner 将昵称列为最低目标；MVP 无 globally public Profile，Private Identity / Matching Inputs / Readiness / Showcase 分用途。 | `User` 的 `$fillable` 与所列迁移没有独立 `nickname`；有可空 `users.name`，注册、基础资料与响应使用 `name`；`ProfileController` 一处计算输入用 `$user->nickname` 作回退，但固定来源没有为它建立持久字段。 | 候选为可编辑显示称谓 string，长度、唯一性、空值、审核与各受众展示规则待定；默认不建立全局公开资料。 | `name` 的旧含义和备份昵称字段是否存在 `UNKNOWN`；不得自动等同。独立目标字段及受众 `NOT_FIXED`。 |
| 生日 | Owner 最低回填目标。 | 迁移有 `users.birthday` nullable date，模型 cast 为 date；注册与 `ProfileController` 基础资料 API 接收 `Y-m-d`，登录/资料响应返回日期。 | 候选为 Private Identity 内的 date；格式、有效范围、缺失值、变更/核验来源和为特定用途派生年龄的边界待定，非默认公开。 | 两库字段、精度、真实性与授权用途 `UNKNOWN`；是否沿用单列、是否需要独立来源/可见性字段 `NOT_FIXED`。 |
| 出生地点 | Owner 最低回填目标；Private Identity 与用途分层适用。 | `users.private_birth_place` nullable string(255)；`user_astro_profiles.birth_place` nullable string(255)，以 `user_id` 一对一关联。`AuthController`/`ProfileController` 优先取 private 值、缺失时回退 astro profile；基础资料写 private 值并触发 astro profile 重算/镜像。另有 `city`、经纬度字段，语义不同。 | 候选为仅授权用途可读的私密出生地点输入；原始文字、规范化地名/坐标、精度、来源和重新计算派生资料的边界待定。不能把展示地理位置或 `city` 等同出生地点。 | 两处旧承载的权威顺序、冲突、派生/镜像关系及备份实际字段 `UNKNOWN`；新目标字段与公开/匹配/占星用途 `NOT_FIXED`。 |

权限/角色另列为依赖：Owner 曾将权限列入总体目标，但本任务最低五项之外的角色来源与 v10 权限模型尚未固定。当前 `users.role` 为默认 `user` 的 string(32)，`User::isAdminRole()` 仅比较 `'admin'`，Auth 响应回传 role；这些是 `CURRENT_CODE_FACT`，不能当新权限/管理员授权合同。真实 identity assurance、账号合并、用户类别、昵称展示审批与出生信息用途须后继明确；现有 `realname_verified` 标志也不证明新身份保证水平。

## 哈希兼容与失败策略的后继证据

`PROPOSED_TARGET` 的离线 synthetic 验证只用人工生成的测试哈希和测试密码，列出受支持算法/参数/编码、目标 verifier 版本与配置、正确/错误密码、未知算法、损坏/截断、不同参数、升级后复验及日志脱敏的负例；不读取、输出或复制任何真实哈希。若独立隔离结构核对后确认旧哈希格式，仍需在另一个受控任务验证兼容性和失败处置：不兼容或无法证明时锁定登录并进入经批准的恢复/重设流程；兼容时也仅在成功交互认证和已审升级规则下决定是否重哈希，不能静默重置或宣称旧哈希可直接登录。账号集合、两库来源优先级、重复/冲突规则等待逐对象结构核对与 Owner 决定；AUTH-154 既有聚合计数 `43/532/66`、`18/195/11` 不作逐对象证明。

## 在线登录与离线时钟边界

`ACCEPTED_PRODUCT_DIRECTION`：在线登录有效 15 天；最后一次**服务端确认的成功交互登录**建立 `T0`，自动 token 续期不重置 `T0`。第 16～30 天仅在设备仍离线、所保存的按账户加密内容与其他离线只读条件均满足时可读；离线不发送。连续 30 天无成功在线登录须清理该加密私密内容。账户/设备绑定的可验证离线凭据和时间异常先锁定私密内容的方向已接受，凭据格式与协议未定。

`CURRENT_CODE_FACT`：`AuthController` 注册、登录、refresh 均用 `createToken('mobile-access')`，refresh 删除当前 token 后新建；`personal_access_tokens` 迁移有 `tokenable`、`last_used_at`、`expires_at` 等列，初始 users 迁移另有 sessions 表。所列控制器没有可核验的 `T0` 签发、账户/设备绑定离线凭据、可靠时间/防回拨、撤销传播或 30 天清理合同；迁移中有 `expires_at` 列也不能证明 15 天策略已执行。两份 Feature test 验证旧注册/登录、改密和资料行为，未证明上述离线时钟链。

`UNKNOWN/NOT_READY` 的后继合同须分别固定：服务端交互登录事件与 `T0` 的持久签发/校验；账户+设备绑定凭据的生命周期及撤销；15 天在线 token/session 有效性与 refresh 不改 `T0`；可靠时间和回拨/不可判断时的锁定；第 16～30 天只读范围、已知撤权 fail-closed 与离线无法即时获知撤权的风险上限；30 天清理的逐类对象、失败处置和验证。现有 Sanctum token、旧 auth/controller 或测试不能被宣称已满足，也不签发真实身份 assurance 或消息 live 权限。

## 下一最小工程门与回退

本轮选择任务单第 5 项的**语义缺口分支**。五项的回填方向已明确，但登录标识、昵称、生日/出生地点的目标用途和字段形态，旧哈希兼容策略、角色/权限分层、账号合并及跨库优先级尚未固定；因此现在不发布“字段合同/校验代码”的文件、接口或测试清单作为可执行任务。下一步最小可审决策是 Work/Owner 确定 v10 Private Identity 的账号标识与昵称是否独立、生日/出生地点的目的及受众、角色权限是否另立合同，并明确哈希不兼容时的恢复规则；技术来源侧等待受控隔离环境下两库逐对象结构目录及算法/编码事实。之后才可另发 **纯本地 synthetic、无真实数据** 的精确路径工程任务，规定输入 schema、验证接口、缺失/错配/冲突/无效日期/不兼容哈希等负例、限定向测试与“只移除新切片”的回退。本文没有预先授权任何迁移、导入脚本或生产 endpoint。

本次实际修改：仅新增 `EVIDENCE/AUTH-156-V10-ACCOUNT-TARGET-CONTRACT/plan.md`。`NOT_RUN`：PHPUnit、Composer、Artisan、Docker/WSL/VM、备份/解密/恢复、数据库、SSH/云/生产 API；未改代码/迁移、未提交/pull/push。回退仅撤回本候选文档，保留既有状态与无关脏工作区。本文交付后停 Work 独立 LEVEL 2 ACCEPT/REJECT；即使接受也只固定文档目标合同，不放行 AUTH-153 真实解密/恢复、账号行读取、AUTH-154 Phase B、生产 DB 改库或账号迁移。
