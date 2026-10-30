# Laravel13 来源选择与差异映射（2026-10-30）

状态：SOURCE_SELECTION_STATIC_ONLY / RUNTIME_NOT_RUN / ASTRA_REVIEW_PENDING。

## 权威与选择原则

唯一Parent `7a4595c60ac2fced957cd3bffd132daa23b4db74`，Root `7d9005590deda0cd5f4e98f9676eae8c9a5daa23`；来源候选 `9b74ca6fef89e2507f966870c1f0d04f4fe09ba6`，Root `3b9690c1cdd6313d8f192c0ca4105352b8b40188`。来源Astra审查 `9026a5bb04bbb23358eb8c6f61afba66ae4f2318` / Blob `456c8d47ec98e815c467e9d5f38ea3b4ddf12680` 只给予有界接受。

52个services差异逐条分类：框架10，未接受业务/相关测试语义26，旧任务专用工具16，UNKNOWN=0。其余主线产品文件为 ALREADY_ACCEPTED_MAIN。**254个main app业务源码保持原生Blob；未选择的1411个main产品路径原始字节与main一致。** 不接入整个来源services Tree `9427d6deba3be2d44fce94122661a21668976e20`。

来源apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`整体不接入；目标apps必须保持已接受main `3468a3dd97da7accfda2539a0f8d8f68931a6110`。

## 全部52项

表中路径相对 `services/backend-laravel/`。保留main/缺席表示来源更改未引入；最终候选原生Tree与Manifest绑定实际所选Blob。

| 路径 | main Blob | 来源 Blob | 分类 | 处理/所选 Blob |
| --- | --- | --- | --- | --- |
| `app/Console/Commands/ChatWebsocketServerCommand.php` | `b315fc8fc43edbaacbcdefce1bfeb6e64bf012e5` | `486be26a6e44221def9d7aac520ae18856816719` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`b315fc8fc43edbaacbcdefce1bfeb6e64bf012e5` |
| `app/Domain/MessagingReplayContract.php` | `ABSENT` | `55b757fff40588f572251a776503e2a6074a3c20` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`ABSENT` |
| `app/Domain/NotificationDeliveryContract.php` | `ABSENT` | `3173eb35e174612139f5b68c85821c7bccf1d434` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`ABSENT` |
| `app/Domain/TrustedLoginTimeContract.php` | `ABSENT` | `a710bbc673f4bb5f030e3661dd42e95b9bc3548e` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`ABSENT` |
| `app/Http/Controllers/Api/V1/AuthController.php` | `9a3bfbcd2cdae86ff6d18dd84728e22a80e2b817` | `f69e06670e6584a02862f965d82fc37dee407224` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`9a3bfbcd2cdae86ff6d18dd84728e22a80e2b817` |
| `app/Http/Controllers/Api/V1/MessageController.php` | `e4166fa6c4b5ef6ffc34ccef7c3ad9345836a9bd` | `892adcb18b45750579bc71fec2b53a9841ed542d` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`e4166fa6c4b5ef6ffc34ccef7c3ad9345836a9bd` |
| `app/Http/Controllers/Api/V1/NotificationController.php` | `6271cb8ecc45b525ff86689ea9a9a5ed9ee313f0` | `562065876c6a78f7b25a6a4bcb332bad4f6320a7` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`6271cb8ecc45b525ff86689ea9a9a5ed9ee313f0` |
| `app/Http/Controllers/Api/V1/NotificationPreferencesController.php` | `ABSENT` | `011fecb63606b303671efbc53c913fdf54dc54e6` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`ABSENT` |
| `app/Http/Middleware/DenyUnverifiedMessagingLiveAccess.php` | `8eb33d864572ffbe226be7ba6517630c4cd29075` | `737a90e2842f386dba4a421b5a65ab303775d131` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`8eb33d864572ffbe226be7ba6517630c4cd29075` |
| `app/Http/Middleware/EnsureAccountActive.php` | `bd15a3558336e117450266e2172838939a2299eb` | `fb6f088e6dccf80b06a2433f7eb71471d9dab8b5` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`bd15a3558336e117450266e2172838939a2299eb` |
| `app/Services/Accounts/DeviceSessions.php` | `6ed72abb06a2d2158ad989883a3e00a0234af2aa` | `03754bed3a62f58f26db2913bbb786f8775e98f7` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`6ed72abb06a2d2158ad989883a3e00a0234af2aa` |
| `app/Services/ChatWebsocketAuthorizationService.php` | `042ed6982c0395cd385fd71e1d262035562c0815` | `d71c8f438d6f09d4b40ac6e90692b32ab1c9453c` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`042ed6982c0395cd385fd71e1d262035562c0815` |
| `app/Services/ConversationAtomicSendService.php` | `a6196e5fdd268d7bd27c3026d21d65dc8ad1158e` | `0152f24226ad821ade592a7e0f0e540c962a0fa0` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`a6196e5fdd268d7bd27c3026d21d65dc8ad1158e` |
| `app/Services/LiveConsentService.php` | `5d3d09533bdcca15374140fee75a4e7ddbae6886` | `6200ed876ca6189fb97f9f39355691bdcdf2d365` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`5d3d09533bdcca15374140fee75a4e7ddbae6886` |
| `app/Services/NotificationDeliveryService.php` | `ABSENT` | `3b9835bfed135d2a990f3e4a0d85077d47cc7cf9` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`ABSENT` |
| `app/Services/NotificationService.php` | `6dad47ad1a7b2d13258f5a862139fcf2cd614470` | `9e45e8988d2aefbbec667cfea3fc975ab949dc4c` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`6dad47ad1a7b2d13258f5a862139fcf2cd614470` |
| `app/Support/PrivateMariaDbQualification.php` | `ABSENT` | `a4682f9c9870b1a4cdaa6a9bdfd24f551a07c48f` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `composer.json` | `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1` | `130793decf84ff8ab93faa0300117b7fab9d1826` | 框架/依赖输入或必要框架测试适配 | 引入：`130793decf84ff8ab93faa0300117b7fab9d1826` |
| `composer.lock` | `66327f584d3961c2b53391bb012047dda9cc9d23` | `e236fbc960c1dd08c1fecb9aeed4926b4cab3933` | 框架/依赖输入或必要框架测试适配 | 引入：`e236fbc960c1dd08c1fecb9aeed4926b4cab3933` |
| `config/session.php` | `7036d0a4140b419fd35005b84bcef12f16449f34` | `dbcb582d0afbab3a0dc95576797730555ce3cd8d` | 框架/依赖输入或必要框架测试适配 | 引入：`dbcb582d0afbab3a0dc95576797730555ce3cd8d` |
| `database/migrations/2026_10_21_210000_trusted_device_login.php` | `ABSENT` | `038874c4dd773099cb5e0cff670c2d2fa5732fa7` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`ABSENT` |
| `database/migrations/2026_10_21_220000_create_notification_delivery_contracts.php` | `ABSENT` | `6c3c383751c8ec3625f34ece6b60ca50d1b34a9b` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`ABSENT` |
| `phpunit.task-mariadb.xml` | `ABSENT` | `3e70b2942b789e72721890b25120093a5175ce82` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `routes/api.php` | `2fb22267a726c42035b70d6f5d458fc6f3c88fa6` | `fcb4d81338b6ec4b908ba16d1e729d76f98ca101` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`2fb22267a726c42035b70d6f5d458fc6f3c88fa6` |
| `tests/E2E/MainlineConsentService.php` | `ABSENT` | `07ec5821def47d3612dc10b141998515753f4375` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `tests/E2E/MainlineEnvironment.php` | `ABSENT` | `531de57e70fec78bfefd293f669232a887bd5a8b` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `tests/E2E/PhpRuntimeQualification.php` | `ABSENT` | `23696d832431a8a329f19926ef33bf5bcbb19a74` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `tests/E2E/RunningDockerEnvironment.php` | `ABSENT` | `a5c5b9021285b719c6e91e8c26eee30e623a5ccb` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `tests/E2E/bridge.php` | `ABSENT` | `043f26091a776abac1839517e4386e16b53a397c` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `tests/E2E/php_runtime_probe.php` | `ABSENT` | `9613bcb9f8c2c3dd19dbd0771e999010a9a05aa7` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `tests/E2E/running_docker_fixture.php` | `ABSENT` | `9052fafbe3756ab3e4afb0e8c0f1766414aba2c6` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `tests/E2E/running_docker_router.php` | `ABSENT` | `b1a6fdee75c6336426a0e0087520f81b92e3bc3c` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `tests/E2E/server.php` | `ABSENT` | `4e68305bf399c55ce0c04b39d7e46d0bec3878c2` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `tests/Feature/Api/V2/TransportEnvelopeTest.php` | `60434c0a70f7a768496e30dd937cfca4c15411b0` | `e1cb4b09d88afdbea4ac4e641db70094b2bf2211` | 框架/依赖输入或必要框架测试适配 | 引入：`e1cb4b09d88afdbea4ac4e641db70094b2bf2211` |
| `tests/Feature/ConversationCapabilityFoundationTest.php` | `241f0bf6ea598e4a50a0a5dcea24aa6694eed95a` | `be05eb2c7b0c3bb598d96b4807ecb68fb6ec9cc5` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`241f0bf6ea598e4a50a0a5dcea24aa6694eed95a` |
| `tests/Feature/FrameworkSessionCompatibilityTest.php` | `ABSENT` | `b43bdc530389f509c1290a77e940767ed3aba2a8` | 框架/依赖输入或必要框架测试适配 | 引入：`b43bdc530389f509c1290a77e940767ed3aba2a8` |
| `tests/Feature/Laravel12CompatibilityTest.php` | `ABSENT` | `575eeb747fa696765a8bdb3b6989001de4ca7662` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `tests/Feature/MediaUploadEndpointTest.php` | `565c8794aefa271a5364febedc741d87fca4e6c6` | `745980a60f1cd3b7319cde375113b694518f75bf` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`565c8794aefa271a5364febedc741d87fca4e6c6` |
| `tests/Feature/V1006AdminWebTest.php` | `0424114bd380fd32c350e76dc53b83b396f6ed8f` | `ba9bc580140c0d975b79c7be76f51e520ff5e851` | 框架/依赖输入或必要框架测试适配 | 仅CSRF别名，保留main旧refresh测试：`d67921e90c4bde8a6b2644929140978016325ecf` |
| `tests/Feature/V1007PrivateMediaTest.php` | `08e3e3ea0216868bb8fb29c3dd85784df3dbe391` | `5f9e288537aafb162e8a74d63f93df483e02fd2b` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`08e3e3ea0216868bb8fb29c3dd85784df3dbe391` |
| `tests/Feature/V1008MatchingOperationsWebTest.php` | `ad7f01eb267ebbdc8a82d4fe0289a25a5270a50b` | `edf9ad8811898bfa2d39cedf63f5cc93e274f254` | 框架/依赖输入或必要框架测试适配 | 引入：`edf9ad8811898bfa2d39cedf63f5cc93e274f254` |
| `tests/Feature/V1008SessionWebTest.php` | `8085ee4da23e8bf7e313e85fa29e67986d38a5a2` | `80754a18a09d679a0d14309ea8b171c67ca13e65` | 框架/依赖输入或必要框架测试适配 | 引入：`80754a18a09d679a0d14309ea8b171c67ca13e65` |
| `tests/Feature/V1014SafetyContinuityR1Test.php` | `bbc187dff4dbb9f6c3b738f323abca9d7af4e2d7` | `acbc201e312c40b9c9970867df771a64591a9e91` | 框架/依赖输入或必要框架测试适配 | 引入：`acbc201e312c40b9c9970867df771a64591a9e91` |
| `tests/Feature/V1015MessagingTest.php` | `ABSENT` | `1cdaa400d7b8e4ba57eab49a2245f7edbd6ec3b5` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`ABSENT` |
| `tests/Feature/V1015NotificationDeliveryTest.php` | `ABSENT` | `e54e3c125c99f7ddc811d8e16c80c0f7414a8be2` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`ABSENT` |
| `tests/Feature/V1015TrustedLoginTest.php` | `ABSENT` | `840c75065c0af5b7021721c4e6d5f5f3b05ebdf4` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`ABSENT` |
| `tests/Pure/SoftwareIntegrationContractsTest.php` | `ABSENT` | `e502e9f4488804aa641c81011ddc58fc2d255af8` | 未接受为正式main的v10.1.5业务/测试语义 | 保留main/缺席：`ABSENT` |
| `tests/Support/PrivateMariaDbQualification.php` | `ABSENT` | `1088491ac158c796138eaac3a779896a08c0369c` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `tests/TestCase.php` | `1889200bbdfd26c6e3b3d0fd798d2e75a1ba3a76` | `24e3d0ba91599aea21046eba9b25b6b793d03a48` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`1889200bbdfd26c6e3b3d0fd798d2e75a1ba3a76` |
| `tests/Unit/PrivateMariaDbQualificationTest.php` | `ABSENT` | `a56aa79db9403f9e5411402b5d5982419efa2023` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |
| `tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php` | `c68f82adf44af65ca80e51d7fc73bf1522b81980` | `b024d4d043e57ac71d1c8562f991ea3dd6be339e` | 框架/依赖输入或必要框架测试适配 | 引入：`b024d4d043e57ac71d1c8562f991ea3dd6be339e` |
| `tools/validation/v1015_private_scenario.php` | `ABSENT` | `35a23c74d2fa2e55adf3901170e15c15de106051` | 旧任务专用资格/E2E/Windows工具 | 保留main/缺席：`ABSENT` |

## 重要语义与未引入范围

- composer.json/lock精确保持 `130793decf84ff8ab93faa0300117b7fab9d1826` / `e236fbc960c1dd08c1fecb9aeed4926b4cab3933`；config/session.php精确使用 `dbcb582d0afbab3a0dc95576797730555ce3cd8d` 的php序列化配置。
- V1006只采用CSRF import别名，保留main对旧个人token升级refresh的原断言；不把9b的DeviceSessions/T0测试夹具整段带入。
- 其余所选测试仅query私有helper改名、PHPUnit12 DataProvider属性、CSRF类别名和新增array-store session序列化用例；未删除既有权限负例。
- 不接F1/F3/F4新业务域、控制器、中间件、锁顺序、可信T0/通知偏好迁移及路由；不改main SQLite TestCase guard，不接旧MariaDB/Windows资格工具，不接Laravel12资格测试。
- composer profile并非单纯声明版本：清空scripts与插件白名单，旧package:discover和composer dev入口消失；Lock同时改变Guzzle7.10.0→8.3.1、Workerman5.1.9→5.2.3、lunar-php1.4.0→1.4.7。遵循任务精确输入，不静默恢复scripts或改锁；这些兼容性尚未运行验证。
- 仅生成独立源码候选。没有证明其可用，无新vendor或已启动基线；不能用来源9b旧258测试替代本目标main差异回归。

## 额外本轮工作树处理

初始独立稀疏Git工作树的HEAD/所有Tree对象精确为fresh main，初始Git状态clean。继承的checkout行尾/索引缓存使后续原始字节检查出现差异；仅在本轮独立repo中设置core.autocrlf=false、core.eol=lf，从原生main Blob恢复相同字节并以相同main mode/Blob刷新新index缓存。最终只剩上述10条预期差异；原用户工作根/index/全局Git配置均未修改。
