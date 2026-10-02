# BE-13 Work 独立审查｜2026-09-27

**LEVEL 3 ACCEPT，仅接受两个历史 Feature 类在测试进程中的精确 guard 隔离；生产路由仍默认拒绝。** 修改后 SHA-256：`MessageApiTest.php` `6CE62CECD774C9A99DC19ED14C4A2777AC4B6B73942668B533DAE05A8A51E354`、`ConversationCapabilityFoundationTest.php` `97CD987BDA73C0FE42038D08F5FF40DEA6AF14ECEB1457F2F21EFD35868AB56E`；作者摘要 `1FF08B4BD6D7AF770E730702F67042EF63DC77FFC4455423BF3B8A9E53502714`。

差异仅为各类导入 `DenyUnverifiedMessagingLiveAccess` 并在 `parent::setUp()` 后以类参数调用 `withoutMiddleware`。没有全局关闭中间件、修改旧断言、跳过测试或更动生产 guard/路由。历史测试的 released-match、会话、block 后只读正例只证明被隔离的旧 controller/service/storage 路径；不构成 v10 live 权限。BE-12 新路由保护测试哈希及路由哈希未变，独立运行时未绕过 guard。

作者两份修改测试语法检查退出 0；三个定向 Feature 文件各首跑退出 0，分别 12/116、9/85、2/24，合计 **23 tests/225 assertions**，每文件另有 2 deprecations，无失败或复跑。本审查未重复运行。`git diff --check` 对两份修改测试退出 0。完整套件仍 `NOT_RUN`；另有其他历史 Feature 文件引用这些路由，须下个有界任务分类，不应统一绕过 guard。

本接受不恢复真实消息读发、历史访问、可信 CN/MC 来源或部署；不涉及 SSH、真实 DB、备份/恢复、提交或 GitHub 同步。旧预算不重置。
