# AUTH-160｜私密账号基本字段目标准则（作者候选）

**结论：`PROPOSED_TARGET`，待 Work 独立 LEVEL 2 ACCEPT/REJECT。** Owner 已接受五项最低回填方向和同账号出生地点选择规则；这不等于已接受 v10 字段、旧库映射、账号集合或迁移权限。当前 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，原有 dirty 工作区保留。本轮只新增本文件。

## 依据与用语

固定来源静态核对 **2/2 轮已耗尽**：入口核对后，第一轮读取 AUTH-156 `plan.md`/`work-review.md`、AUTH-157/158/159 和 AUTH-154/155 `work-review.md`，以及 AUTH-156 任务单列出的模型、Auth/Profile 控制器、五份迁移、两份 Auth Feature 测试、三份设计接受文件和 `PRODUCT_DECISIONS.md`；第二轮只对这些精确来源作字段、接口、验证和边界摘取。AUTH-157 原测试因 MariaDB 环境失败而 `REJECT/NOT_VERIFIED`；AUTH-158 在新预算的内存 SQLite 下接受同账号出生地点负例；AUTH-159 仅接受人工 bcrypt 的本地登录探针。AUTH-156 `plan.md` 只获“准备度/缺口矩阵”接受，最终 schema 仍 `NOT_READY`。以下把 `ACCEPTED_PRODUCT_DIRECTION`、`CURRENT_CODE_FACT`、`PROPOSED_TARGET` 与 `UNKNOWN` 分开；历史设计接受文件是产品/规划来源，不授予字段、API 或迁移实现。

## 五项 proposed target semantic contract

| 最低目标 | 已接受方向与当前代码事实 | `PROPOSED_TARGET`：目的、受众/接口、缺失/冲突/更新 | `UNKNOWN` / 待审选择 |
| --- | --- | --- | --- |
| 账号身份／登录标识 | `ACCEPTED_PRODUCT_DIRECTION`：账号为后续最低回填目标，集合未定。`CURRENT_CODE_FACT`：`users.id` 为旧内部键，`phone` 是长度 32 的唯一登录字段；现有 AuthController 按 phone 查找、签发 Sanctum token。 | 将稳定内部账号身份与可变登录标识分开；登录标识仅供认证与本人账户管理接口，默认不进入匹配、Showcase 或普通公开响应。缺失标识或唯一性冲突时将候选隔离为不可登录、不可自动合并；变更须另有经审查的持有人验证、审计和旧标识失效规则。 | 旧两库账号键、phone/email 可用性、同人去重、格式/唯一域、可空性、主登录方式和变更证明均未固定。不能把当前 phone 约束直接提升为新产品决定。 |
| **现有密码哈希** | `ACCEPTED_PRODUCT_DIRECTION`：只处理已有哈希，不处理明文。`CURRENT_CODE_FACT`：`users.password` 为模型 hidden、`hashed` cast；当前登录用 `Hash::check`。AUTH-159 只证明人工 bcrypt 在本地可验证且该探针未静默改写。 | 作为认证服务独占的不可展示、不可回显材料；普通 Profile、客户端和通用证据不得接收哈希。缺失、损坏、未知算法、参数不兼容或验证失败均 fail closed，不签发 token；不得静默清空、重置或重哈希。更新只经已批准的成功交互认证后换密/显式恢复流程及审计；兼容升级另定。 | 旧库实际算法、参数、编码、截断、长度和 verifier 兼容性均 `UNKNOWN`。结构上能放入 string 不证明能认证；存储保护、算法 allowlist、升级/恢复规则待审。 |
| 昵称 | `ACCEPTED_PRODUCT_DIRECTION`：昵称在最低目标内，MVP 无 globally public Profile。`CURRENT_CODE_FACT`：固定 User/迁移无独立 `nickname` 持久字段；有可空 `users.name`，Auth/Profile 使用它，Profile 一处 `$user->nickname` 回退不证明字段存在。 | **建议昵称独立于旧 `users.name`**，仅作经受众规则授权的显示称谓；默认限本人 Private Identity 读取/编辑，不自动公开到 Matching Inputs 或 Showcase。缺失时保持未设置，不从 `name` 无声回填；重复、非法或争议值不自动借用姓名，编辑、展示审核、撤回和历史称谓处理待独立合同。兼容候选：保留旧 `name` 供旧端读取；新字段显式写入后新端才优先显示，旧字段迁移须有来源证明、本人确认和回退门。 | 昵称类型/长度、唯一性、字符规则、展示受众、是否及如何从旧 `name` 迁移、两库是否有昵称来源均 `UNKNOWN`。独立字段是本次建议，不是已接受 schema。 |
| 生日 | `ACCEPTED_PRODUCT_DIRECTION`：生日为最低目标；Private Identity 与其他用途分层。`CURRENT_CODE_FACT`：`users.birthday` 为 nullable date，当前 Auth/Profile 接受 `Y-m-d` 并在本人资料响应返回。 | 作为 Private Identity 的私密日期输入，仅给本人资料管理及经明确目的批准的派生计算，不在公开资料中直接给出。缺失保持未知，不用生肖、年龄或其他派生值反推；无效/冲突日期隔离待核，不默认选一方。本人更新须校验、记录来源/版本并按后继规则重算派生数据；更正不自动覆盖旧库原件。 | 两库源字段、精度、真实性、闰日/范围、受众与更正证明、是否沿用当前列均 `UNKNOWN`；不能以旧 API 格式定新目标合同。 |
| 出生地点 | `ACCEPTED_PRODUCT_DIRECTION`：同一账号的重复候选按**已核定来源顺序取首个非空值**，以后可修改。`CURRENT_CODE_FACT`：当前两处已知承载按 `users.private_birth_place` 优先，缺失回退 `user_astro_profiles.birth_place`；AUTH-158 的 synthetic 冲突测试已接受。`city` 不是出生地点。 | 作为 Private Identity 私密地点输入；仅本人及经独立目的授权的计算使用，普通公开接口不回显原始/精确地点。缺失保持未知；同账号且来源已核定时依 Owner 规则取值，保留被排除候选的来源/冲突记录，不静默覆盖。本人更正可更新目标值，并按已批准规则重算派生结果；经纬度、规范化地名与原文应分别定受众。 | 当前两处顺序**不扩展到两份备份库**。跨库账号集合、合并/去重、版本来源优先级、地名精度/规范化、坐标处理及旧值是否同义均待逐对象结构和 Owner 决定。 |

上述“本人接口”均是目标受众建议，不表示当前 Auth/Profile 响应已符合新隐私合同。字段类型、长度、唯一性和 API 形态未获产品接受时维持 `NOT_FIXED`；不把现有 Laravel 列直接称作 v10 最终目标。

## 独立依赖门

- **角色与管理员**：当前 `users.role`、`account_type` 和 `User::isAdminRole()` 属 `CURRENT_CODE_FACT`，不是新权限签发依据。目标角色集、管理员认证/授权与账号合并后的权限继承均 `UNKNOWN`；不得把旧 role 随字段回填静默提升权限。
- **登录与离线**：Owner 已接受在线登录 15 天、服务端确认成功交互登录建立 `T0`、自动 token refresh 不更新 `T0`、第 16～30 天在仍离线且其他条件满足时仅对已保存的按账户加密内容只读，以及连续 30 天无成功在线登录时清理。当前 `createToken('mobile-access')`、refresh 和 `expires_at` 列不证明这些行为已实现。账户/设备绑定离线凭据、撤销、可靠时间/回拨先锁定、清理失败处置、已知撤权 fail-closed 与离线撤权传播上限均须独立合同和验证；不从当前 `realname_verified` 或 Sanctum token 推定新身份保证。
- **哈希兼容门**：只可先用人工合成哈希覆盖正确/错误口令、未知算法、异常参数、损坏/截断、编码和升级失败的负例；AUTH-159 的 bcrypt 结果不适用于任何实际备份。若不兼容，保持账号不可登录，走另行批准的恢复流程，不修改真实哈希。
- **恢复与来源门**：AUTH-153/154/155 只接受静态方案；隔离目标/ACL、普通权限监督器、Docker 无自动启动、资源限额、明文防落盘和失败消费者 0/0 尚不足以运行 Phase B。两库逐对象结构、账号行与来源优先级尚未观察；即使本目标合同获接受，也不能代替隔离恢复、结构核对或导出时独立比较源/无冲突 DDL 证明。

## 下一最小纯本地 synthetic 后端任务候选

**须先由 Work 审查本目标准则并另行发单。** 建议只做无 DB/API 的显式候选归一化边界：拟新增 `services/backend-laravel/app/Domain/PrivateAccount/PrivateAccountTargetCandidate.php` 与 `services/backend-laravel/tests/Unit/PrivateAccountTargetCandidateTest.php`；输入仅为人工构造的 `legacy_name`、`explicit_nickname`、`private_birth_place`、`astro_birth_place` 及各自同账号来源标签，输出只给出“昵称仅来自显式候选／缺失为 null”和“已核定的当前两处出生地点顺序所得候选或 null”，同时保留冲突标签，不写 User/DB，也不声明登录或权限。负例覆盖空白值、两处冲突、来源身份不一致、只有旧 `name` 时昵称仍缺失、未知来源顺序时不擅自选择；定向运行这一 Unit 文件及语法/差异检查。若 Work 不接受昵称独立或上述输出接口，则先定语义，不启动代码。手机号/账号唯一性、生日校验、真实哈希兼容、跨库合并及 15/30 天凭据链均不塞进这个切片；后继各需自己的精确任务与验证预算。回退只移除该新 synthetic 切片，不能修改当前用户数据。

## 停点

`NOT_RUN`：PHPUnit、Composer、Artisan、Docker/WSL、UAC、DB/账号行、SSH/云/生产 API、密文/私钥/解密/恢复、迁移/导入及真实哈希验证。未写代码、测试或迁移；未提交、拉取或推送。回退本轮只撤销此 `plan.md`，保留其他工作区内容和旧预算。作者在 Work 独立 LEVEL 2 审查前不自接受、不执行下一任务；即使接受本文件也仅接受文档候选，不放行真实账号迁移、生产改库或 Phase B。
