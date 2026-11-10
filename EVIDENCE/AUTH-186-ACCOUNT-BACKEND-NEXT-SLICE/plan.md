# AUTH-186｜下一本地账号后端切片候选：异常哈希登录失败关闭

**结论：存在一个可另行发单的 synthetic 后端切片。** 只在现有登录路径中，用人工构造的异常哈希验证“不能签发 token、不能泄露哈希、不能改写哈希”的失败关闭行为；若目标 verifier 对某类格式抛出可狭义识别的验证异常，才把它映射到现有统一凭据错误。此切片不接入 `PrivateAccountTargetCandidate`、真实账号或备份，也不决定旧哈希兼容策略。本文是 docs-only 候选，待 Work 独立 LEVEL 2 审查后另发实施任务。

## 依据与事实层级

- 本地 `D:\EliteSync-v10`、`main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；原有 modified/untracked 保留。固定本地来源/代码核对 **2/2 轮已耗尽**。项目代码图谱已索引 `User`，但未收录未跟踪的 `PrivateAccountTargetCandidate`；针对该类和精确 Laravel 文件回退到限定路径的直接读取/`rg`，未索引其他项目。
- `ACCEPTED_PRODUCT_DIRECTION`：Owner 的最低回填方向含账号、现有密码哈希、昵称、生日、出生地点；仅同一账号、当前两处出生地点按 `users.private_birth_place` 优先。15/30 天在线/离线方向另有独立合同门。AUTH-156/160 只接受准备度与目标语义文档，不接受最终 v10 schema、昵称字段、账号集合或两库来源顺序。
- `CURRENT_CODE_FACT`：`User` 有 `password` hidden/hashed cast；`AuthController::login` 按现有 `phone` 查找，`Hash::check` 返回 false 时给统一 422 凭据错误，之后才 `createToken`。所读模型/迁移无独立持久 `nickname`；现有 `name`、`phone`、`birthday`、`role` 和出生地点列只是旧实现，不是新目标。`ProfileController` 的 `$user->nickname` 回退不证明字段存在。
- `ACCEPTED_SYNTHETIC_ONLY`：AUTH-158 已接受当前两处出生地点的内存 SQLite 冲突回归；AUTH-159 已接受人工生成 bcrypt 哈希在当前测试环境的登录/错误口令探针；AUTH-162 已接受四来源同账号绑定的纯内存候选。`PrivateAccountTargetCandidate` 目前只在自身 Unit 测试中被引用，调用方声明的 `synthetic_only=true` 不是真实来源证明。
- `UNKNOWN/NOT_FIXED`：真实两库账号集合、来源优先级、旧哈希算法/参数/编码、实际兼容性、最终 nickname/schema、权限与 15/30 天实现均未证。异常哈希在当前 verifier 中返回 false 还是抛出何种具体异常，本轮未运行代码验证。

## 建议的唯一工程切片（需新任务授权）

**精确允许文件**：`services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php` 和 `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php`。不改 `User`、迁移、配置、Profile、路由或 `PrivateAccountTargetCandidate`；尤其保留目标测试文件中 AUTH-157/159 已接受的既有差异。

**行为目标**：用内存 SQLite 的人工账号，把人工构造的损坏/截断/不支持格式哈希直接写入测试行（不输出哈希正文）；对任意输入口令，登录不得签发 token，不增加 `personal_access_tokens`，响应不得包含哈希或内部异常细节，持久哈希字节不得改变。若 `Hash::check` 对这类输入返回 false，现有分支应保持；若它抛出**可狭义识别的哈希格式/算法验证异常**，才在登录的核验边界转换为现有统一 422 凭据错误。不能识别异常来源时停为 `NOT_FIXED`，不得用广义 `Throwable` 捕获吞掉配置、数据库或其他运行故障。正常人工 bcrypt 正确/错误口令与禁用账号的既有行为须保持。

**主要负向用例**：损坏/截断哈希；不支持格式的人工标记；错误口令下不产生 token；响应不含哈希、堆栈或 verifier 文本；验证失败后原哈希不变。正常 bcrypt 对照继续成功，错误口令继续统一失败。所有值为人工生成，测试不得读取真实账号或备份。此处不设算法 allowlist、重哈希/重置策略、旧库兼容结论，也不更改账号身份或授权含义。

**建议验证与预算**：实施前只读确认该测试文件与 AUTH-159 接受差异及进程内 SQLite 前提；对两个改动文件各做 1 次 `php -l`，在单个测试进程环境中固定 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、空 `DB_URL`，定向运行 `php vendor/bin/phpunit tests/Feature/AuthPasswordApiTest.php` **首跑 1/1 次**，再做精确两文件差异/哈希核对。若触及非内存数据库或环境前提不成立，运行前停；失败结果如实记录，复跑需另有明确新预算。当前 AUTH-186 未运行任何 PHP、测试或 build，建议预算不是现行授权。

**风险与审查门**：LEVEL 2（现有认证失败路径），Work 独立实质审查；若后继发现需要改变支持的算法、真实旧哈希处置、登录标识或生产行为范围，另定更高风险合同。回退仅撤销后继在上述两文件的精确新增差异，保留 AUTH-157/159 已接受测试和所有无关 dirty/untracked；不能以 reset/clean 覆盖工作区。

本轮仅新增本 `plan.md`。真实账号行、DB、备份、密钥、解密/恢复、SSH/云/API、GitHub、Docker/WSL、PHP/tests/build 均 `NOT_RUN`；未改后端、提交、pull 或 push。AUTH-170 继续 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B 与真实账号回填 `NOT_READY`。作者停 Work LEVEL 2 `ACCEPT/REJECT`，不自行实施或派发后继。
