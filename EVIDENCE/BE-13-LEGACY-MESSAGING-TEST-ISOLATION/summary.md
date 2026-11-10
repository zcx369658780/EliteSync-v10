# BE-13｜旧消息内部测试的单类隔离候选｜2026-09-27

**作者结果：三份指定 Feature 文件在各自内存 SQLite 进程中首跑通过；待 Work 独立 LEVEL 3 审查。** 本地 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，原有 modified/untracked 保留，未提交、拉取或推送。

## 固定预检与差异

修改前哈希完全符合任务单：`MessageApiTest.php` `23B25F2953C14C67F8D0E3BA6C3DB1B2F55F210B33811545A00EC8BC4A0E0303`，`ConversationCapabilityFoundationTest.php` `DEA6BEDF98D1E1CEA89C4F771227B60B9DCCA5D69A650D5FEB9BAC76AFCEA824`；BE-12 新保护测试 `43CEA0249D53A525A9B0A0DC5A0C49558EF3A538F12DE8B72C66B73CE00728A8`、路由 `6E1769E4728F8E1E703EDD432457CCD6F608E24AD7ABAA14892CA13FD15A0675`。`bootstrap/cache/config.php` 不存在；`phpunit.xml` 选 SQLite `:memory:`，应用配置优先 `APP_DB_CONNECTION` 且 SQLite URL 可由 `DB_URL` 覆盖，故每次测试显式覆盖。前置条件均满足。

仅在两份旧 Feature 类各新增 `DenyUnverifiedMessagingLiveAccess` 的 import 和 `setUp()`：先 `parent::setUp()`，再 `$this->withoutMiddleware(DenyUnverifiedMessagingLiveAccess::class)`，并注明这些断言只检验 legacy controller/service/storage 内部行为，**不授予 v10 live read/send**。没有使用无参数 `withoutMiddleware()`，没有关闭 `auth:sanctum`，没有改旧断言或跳过测试。生产路由、guard、服务与 BE-12 新保护测试未修改。

| 文件 | 修改后 SHA-256 |
| --- | --- |
| `services/backend-laravel/tests/Feature/MessageApiTest.php` | `6CE62CECD774C9A99DC19ED14C4A2777AC4B6B73942668B533DAE05A8A51E354` |
| `services/backend-laravel/tests/Feature/ConversationCapabilityFoundationTest.php` | `97CD987BDA73C0FE42038D08F5FF40DEA6AF14ECEB1457F2F21EFD35868AB56E` |

BE-12 新保护测试与路由的修改后 SHA-256 仍分别为上述固定值。两份旧测试 `git diff --check` 退出 0。

## 预算内验证

在 `services/backend-laravel` 对两份修改测试分别运行一次 `php -l`，均退出码 0、无语法错误。下面三份文件分别首跑一次，均在该次独立测试 shell 中显式设置 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空），再执行 `php vendor\bin\phpunit tests\Feature\<文件名>`：

| 定向文件 | 退出码 | PHPUnit 回执 |
| --- | --- | --- |
| `MessageApiTest.php` | 0 | 12 tests / 116 assertions；0 failure/error，2 deprecations |
| `ConversationCapabilityFoundationTest.php` | 0 | 9 tests / 85 assertions；0 failure/error，2 deprecations |
| `MessagingLiveGateFailClosedRouteTest.php` | 0 | 2 tests / 24 assertions；0 failure/error，2 deprecations |

合计 **23 tests / 225 assertions**；各文件原始状态均为 `OK, but there were issues!`，不是无警告 PASS。无修正、无复跑、无非 SQLite/非内存连接迹象；完整套件及其他文件 `NOT_RUN`。旧测试的成功发/读、released `DatingMatch`、block 后历史读取等正例仅在本类测试进程绕过**指定单一 middleware**时成立，不能作为新 live 权限证据。BE-12 新保护文件未绕过 middleware，仍验证七路由统一 opaque 404、无私密读写副作用及 ws stub 独立边界。

回退仅撤销两份旧测试中的本次 import、`setUp()` 和本摘要；保留 BE-12 guard、路由绑定及新保护测试。未运行真实消息/数据库、SSH、云/生产 API、备份/密钥/恢复或部署。作者停 Work LEVEL 3 独立 ACCEPT/REJECT，不自行接受或启动后继。
