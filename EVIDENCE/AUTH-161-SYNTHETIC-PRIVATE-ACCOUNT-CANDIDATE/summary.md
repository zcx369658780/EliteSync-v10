# AUTH-161 作者交付｜2026-09-27

**候选已交，待 Work 独立 LEVEL 2 ACCEPT/REJECT。** 本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；编辑前两份精确 PHP 路径及本摘要均不存在。本任务只新增下列三份文件，原有 dirty 工作区未处理。

| 新文件 | SHA-256 |
| --- | --- |
| `services/backend-laravel/app/Domain/PrivateAccount/PrivateAccountTargetCandidate.php` | `00C2811313836861166627D58E2492129EBA116F8F73776BED5C003BE87A04C2` |
| `services/backend-laravel/tests/Unit/PrivateAccountTargetCandidateTest.php` | `CB9A6C863E4BC28FFC7C43B63E7C473A0228159F93A6EA06FBE9CBEAE120DA3F` |

## 候选行为与边界

`PrivateAccountTargetCandidate::normalize(array $input)` 为纯内存静态函数，无容器、时钟、文件、网络、User/DB 访问。调用方必须显式提供 `synthetic_only=true`、非空人工 `account_id`、精确的本地两处 `source_order`、旧 `legacy_name`、显式 `explicit_nickname`，以及两处含 `source`、同一 `account_id`、`value` 的出生地点候选；缺失、来源标签/账号身份错配、两备份库或未知/倒置顺序均抛出 `InvalidArgumentException`，不拼接不同用户资料。该调用方标签只限定本地 synthetic 接口，**不是**真实来源证明。

仅对 string/null 值做 PHP `trim`；空白为缺失，字符串 `'0'` 保留为值，数字 `0` 等非字符串拒绝。昵称只从 `explicit_nickname` 取值，不回退旧 `name`；旧名与显式昵称均非空且不同则给出 `different_legacy_name`。出生地点仅按 `users.private_birth_place`、`user_astro_profiles.birth_place` 的已核定**当前同账号两处**顺序取首个非空值；两个非空且不同则保留 `different_non_empty_sources` 冲突标记，不让后者覆盖前者。输出的每项都有 `value`、`selected_source`、`missing`、`conflict`，没有认证、登录或权限结论。

这只是虚构值整理，不确定 v10 最终字段/受众，也不把当前两处顺序扩展到两份备份库。未做地名规范化、坐标派生、生日/手机号/哈希验证、账号去重或真实导入；不修改旧模型、controller、迁移、配置、路由或既有测试。

## 有界验证

两份新 PHP 分别执行一次 `php -l`，均退出 0。`php vendor/bin/phpunit tests/Unit/PrivateAccountTargetCandidateTest.php` **首跑一次**，退出 0，**11 tests / 15 assertions**，无失败、错误、deprecations 或复跑；测试仅用人工字符串与 `PHPUnit\Framework\TestCase`，无 factory/DB。覆盖显式昵称与旧名冲突、只有旧名、首处优先与冲突、空白回退、两处缺失、字符串 `'0'` 和非字符串拒绝、账号/来源错配、未知顺序及缺少 synthetic/显式字段。

`git diff --check` 仅以两份新文件路径调用，退出 0；因文件未跟踪，该命令不检查其内容，另以只读逐行检查两份文件，均无尾随空白。完整套件 `NOT_RUN`；真实 DB/账号行、备份/密钥/解密/恢复、SSH、Docker/WSL、UAC 和生产 API 均 `NOT_RUN`。未提交、拉取或推送。

回退仅移除本次三份新文件，保留全部原有工作区内容及旧任务预算。作者停 Work LEVEL 2 独立审查，不自接受或启动后继。
