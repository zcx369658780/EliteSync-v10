# AUTH-160｜v10 私密账号基本字段目标准则候选

状态：`ISSUED`；风险 LEVEL 2，**本轮 docs-only**。派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；唯一主要交付为本目录 `plan.md`，完成后停 Work 独立 LEVEL 2 审查。

## 固定入口与来源

先核对 `D:\EliteSync-v10` 本地 `main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、dirty 工作区和当前派发。只读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地 workflow 技能；AUTH-156 的 `plan.md`/`work-review.md`、AUTH-157/158/159 的 `work-review.md`、AUTH-154/155 的 `work-review.md`；AUTH-156 任务单列出的精确 `User`/`UserAstroProfile`、Auth/Profile 控制器、五份迁移和两份 Auth Feature 测试。禁止访问旧 `D:\EliteSync`、备份/密钥目录、`.env`、服务器、真实业务行或未经列明的其他代码。旧预算全部为历史，不能重用。

## 唯一交付 `plan.md`

1. 给五项最低目标写一份**可供 Work 审查的 proposed target semantic contract**：账号身份/登录标识、现有密码哈希、昵称、生日、出生地点。逐项固定目的、允许受众/接口、缺失/冲突/更新规则、与现有 Laravel 字段的关系及必须保留的 `UNKNOWN`。须区分产品方向、当前实现事实和本次建议，不能将建议冒充已接受 schema。
2. 明确昵称是否应独立于当前 `users.name`，列出不把现有 `name` 静默迁为昵称的兼容策略候选；生日与出生地点为私密身份资料，`city` 不等于出生地点。Owner 已决定同一账号的重复出生地点依已核定来源顺序取第一个非空值，可后改；当前代码两处来源顺序是 `users.private_birth_place` 优先、缺失回退 `user_astro_profiles.birth_place`，不得把它扩展成两个备份库的优先级。跨库账号集合、去重、版本来源顺序留待恢复后的逐对象结构核对及 Owner 决定。
3. 密码只处理现有**哈希**的目标保护与验证策略，不索取、恢复或生成真实明文。AUTH-159 的人工 bcrypt synthetic 探针只能证明该路径；旧库算法/参数/编码/截断与兼容性仍 `UNKNOWN`。不兼容时须 fail closed，不能静默清空/重置/重哈希真实哈希。
4. 角色/管理员权限、15 天在线登录锚、16～30 天离线只读与清理、账户/设备绑定凭据分别列为依赖门；不得将旧 `users.role`、Sanctum token 或当前姓名字段提升成新产品权威。若字段类型/长度/唯一性及受众依据不足，列成 Work/Owner 待决选项与建议，不补造来源事实。
5. 给出一张**下一最小纯本地 synthetic 后端任务**的候选：精确建议路径、字段或接口变更边界、负例和定向验证；须先受独立审查，不在本任务写 migration、API、代码或测试。另列 AUTH-153/154/155 本机隔离与结构核对的独立门及目标合同不能替代它们。

最多两轮对固定来源的静态核对；仅新增 `EVIDENCE/AUTH-160-PRIVATE-ACCOUNT-TARGET-SEMANTICS/plan.md`，记录实际来源、预算使用、当前 HEAD、限制和 `NOT_RUN`。不运行测试/构建、Docker/WSL、SSH、DB、CMS、UAC，不创建目标目录，不解密/恢复/读取账号行，不提交/pull/push。原有修改及无关未跟踪目录全部保留。作者停 Work LEVEL 2 ACCEPT/REJECT，不自接受或启动后继。
