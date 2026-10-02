# AUTH-161｜纯内存私密账号候选归一化

状态：`ISSUED`，风险 LEVEL 2。派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`。唯一主要结果为一个无 DB/API 的 synthetic PHP domain 切片及其 Unit test；交付后停 Work 独立 LEVEL 2 审查。

## 固定入口与允许路径

先核对 `D:\EliteSync-v10` 本地 `main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、dirty 工作区和当前任务。读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地 workflow/runtime 技能、AUTH-160 `plan.md`/`work-review.md`、AUTH-158 的 review 和 synthetic 出生地点测试、精确 `User`/`UserAstroProfile` 模型与 `AuthController.php`/`ProfileController.php` 中已有来源优先级。不得访问旧 `D:\EliteSync`、备份/密钥目录、`.env`、服务器、真实业务行。

仅允许新增下列两份原先不存在的文件及本目录 `summary.md`：

- `services/backend-laravel/app/Domain/PrivateAccount/PrivateAccountTargetCandidate.php`
- `services/backend-laravel/tests/Unit/PrivateAccountTargetCandidateTest.php`
- `EVIDENCE/AUTH-161-SYNTHETIC-PRIVATE-ACCOUNT-CANDIDATE/summary.md`

若前两精确路径在编辑前已存在即停 Work 核对，不覆盖。不得改模型、controller、迁移、现有测试、服务配置、路由或 DB。

## 候选行为

实现一个只接收**调用方显式标注为 synthetic**的纯内存候选归一化接口，无文件/数据库/网络 I/O，不注入或读取容器、User、环境与时钟。入参至少携带同一个人工账号身份、旧 `name`、显式 `nickname`、`users.private_birth_place` 与 `user_astro_profiles.birth_place` 的虚构值及精确来源身份；任一来源账号身份与主账号不一致时 fail closed，不拼接不同用户资料。可选择不可变 value object 或静态纯函数，但返回结构需能区分值、选用来源、缺失与冲突类别，不能输出认证/登录许可。

昵称只可来自显式昵称候选；缺失/空白时为 null，不能回退到旧 `name`。出生地点只在来源身份一致且来源顺序为**已核定的当前两处**时取第一个非空值：`users.private_birth_place` 优先、空缺才取 `user_astro_profiles.birth_place`；两处非空而不同要保留冲突标记，不让后一个静默覆盖第一个。若调用方声称未知/两备份库的顺序，拒绝选择，不能沿用当前两处优先级。trim 规则、空白/零值处理须明确并有负例；不做地名规范化、经纬度派生、生日/手机号/哈希验证、账号去重或任何真实导入。

Unit test 仅用人工虚构字符串，覆盖：显式昵称与旧 name 冲突、只有旧 name、出生地点第一处非空且第二处不同、第一处空白回退第二处、两处皆空、来源账号错配、未知顺序拒绝、空白和 `'0'` 等边界；不得使用真实值、敏感样本、factory/数据库。结果是候选整理，不是 v10 最终目标合同或真实来源映射。

## 预算与停点

两份新 PHP 各一次 `php -l`；在 `services/backend-laravel` 对新 Unit 文件首跑 PHPUnit **1 次**。若仅本任务新代码/测试缺陷造成失败，可修正后最多复跑该文件 **1 次**；其他失败停审。`git diff --check` 仅检查本次新文件（未跟踪文件须另做只读尾随空白检查）。不跑完整套件。`summary.md` 记录文件哈希、测试退出码/tests/assertions、复跑、候选与权限边界、回退只移除三份新文件。不得运行真实 DB、备份/解密/恢复、SSH、Docker/WSL、UAC，不提交、拉取或推送。保留原有 dirty 内容和旧预算；作者停 Work LEVEL 2 ACCEPT/REJECT，不自接受或启动后继。
