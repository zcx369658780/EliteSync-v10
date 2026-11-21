# EliteSync V2｜P0候选收口独立顾问复核

日期：2026-11-21。结论：**`P0_LOCAL_ENGINEERING_DELIVERY_ADVISOR_SCOPED_ACCEPTED_WITH_RESERVATIONS / CORE_FUNCTIONS_PARTIAL / ANDROID_ARTIFACT_FIXED_DEVICE_NOT_RUN / FORMAL_MATCH_MARIADB_POSITIVE_NOT_RUN / COPYRIGHT_PREPARATION_PARTIAL / CLOSED_BETA_CANDIDATE_NO_GO / PRODUCTION_NO_GO`**。

## 1. 固定证据与提交链

- Codex固定源码：`36ae37206f482109e0bfc7a0f95335fc056da323`；固定报告：`6e3f52522033da04bc84d0c291d11d13f2dff36d`。
- 开发分支：`codex/v2-function-completion-20261121`，GitHub远端HEAD回读为报告SHA。相对上批源码`63a2bbf24c4dff9b892ef94ba99dd34d0888f226`，本轮源码ahead3/behind0，merge-base为上批源码；报告相对源码ahead1/behind0且仅增加中文报告。
- 本轮源码文件涉及Android原生/Dart双端API绑定、TLS、Flutter session/路由、`MediaController`、`FormalRelationshipService`、`RelationshipContactPolicy`、MariaDB烟测和测试夹具。
- 网页顾问直接读取GitHub固定报告、Android ApiClient/build.gradle、Flutter`api_transport_policy`/main bootstrap、`FormalRelationshipService`/RelationshipContactPolicy/TrustedIdentityService、`MediaController`、`function-smoke.py`、V1017测试与TestCase helper；证据等级`ADVISOR_SOURCE_SPOTCHECK`。未实际下载APK、未运行本地PHP/Flutter/WSL或安装设备，所有运行命令、日志SHA和本机文件身份均为`CODEX_REPORTED`。不把日志哈希等同于顾问独立复算。

## 2. 本轮质量与功能范围

| 项 | Codex报告结果 | 顾问结论 |
|---|---|---|
| PHP精选 | 46项/401断言/0失败 | `CODEX_REPORTED_SCOPED_PASS` |
| PHP扩围 | 117项/1,496断言 | `CODEX_REPORTED_SCOPED_PASS`，与精选集合有重叠，不累加 |
| PHP头像 | 10项/91断言 | `CODEX_REPORTED_SCOPED_PASS` |
| Flutter | 128项通过 | `CODEX_REPORTED_PASS`，测试宿主，不是整机 |
| Dart分析 | 8文件零问题 | `CODEX_REPORTED_PASS` |
| HTTPS烟测 | 80条具名状态/持久化检查 | `CODEX_REPORTED_PASS`，80不是80个独立测试用例 |
| APK | 构建、签名、双端URL与证书固定 | `ARTIFACT_IDENTITY_REPORTED` |
| Android安装/旅程 | `NOT_RUN / DEVICE_OWNER_GATE` | 未通过 |
| PHP/Flutter全量 | `NOT_RUN` | 未通过 |

原PHP精选12项逐项复验已PASS。顾问抽查发现相关测试方法保留，`CreatesAcceptedMainMatch`补入完整匹配准备字段并调用`authorizeTestParticipation()`，TestCase通过HMAC`V1012_LOCAL_TEST_ONLY`签名凭据在`testing + sqlite :memory:`签发。当前测试夹具对齐现行资格合同，而不是删掉旧测试或放松生产身份门。V1006新增/保留登录刷新、旧凭据撤销等断言。Codex仍需在未来报告保留完整原JUnit及R0逐项签名对照。

### 2.1 慢约与Relationship：通过与未通过要分层

- `V1017MatchingJourneyTest`在PHP测试中运行实际轮次准备/执行、候选揭示、双边接受、Connection、独立Formal Relationship双方确认、幂等、Block后关系`ENDED`、active slot清空和旧连接404；测试主体使用`authorizeTestParticipation`的HMAC TEST_ONLY身份。
- 源码`TrustedIdentityService::participationAllowed()`仅在`APP_ENV=testing`、SQLite`:memory:`且签名有效时返回true。签名issuer也限制在测试SQLite或既有专用开发库，且`register/issue/revoke`要求CLI。故这一正向流程**不是MariaDB/Flutter/Android/真实KYC正向链**。
- 同一报告的MariaDB HTTPS烟测证实：具备合法好友来源可创建`PENDING_MUTUAL`请求，但当前真实provider缺失时确认返回403、`confirm`动作不开放。FormalRelationshipService创建记录明确标`test_only=true`。这是保持真实身份fail-closed，不得为了把MariaDB测试改200而将可信身份全局打开。
- 因而当前状态为`SIGNED_TEST_ONLY_SQLITE_POSITIVE_PASS / MARIADB_REAL_IDENTITY_DENIAL_PASS / MARIADB_SYNTHETIC_POSITIVE_NOT_RUN / REAL_KYC_BLOCKED_EXTERNAL`。正式慢约及Relationship尚不能视为完成。

### 2.2 媒体与隐私

- `function-smoke.py`的MariaDB HTTPS P0烟测覆盖multipart私有封面和头像上传、错误MIME/超限422、头像修订409、好友读取原始字节与`private,no-store`、第三方拒绝、后加好友不能读旧封面、Block后旧封面/头像/作品链接404；`MediaController::privateContent`源码复查在事务中重新计算当前用户/作品受众/Block/关系资格并设`no-store`。
- 这支持`LOCAL_MARIADB_API_MEDIA_SCOPED_PASS`，但当前APK的图片选择器和真实双端撤权未跑；视频、聊天附件/音频仍不属于本轮通过范围。

### 2.3 Android独立APK

Codex报告固定：
- package：`com.elitesync.v2functionp0`
- version：`10.1.18-v2-function-p0`，versionCode `1011805`
- arm64-v8a，209,094,024 bytes
- APK SHA-256：`d6064498bac327f40f2b2df9c5ed9664c819b29dfaffa916eaf6f6df7b649c05`
- Android Debug签名v2，证书SHA-256：`9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`
- native `BuildConfig.API_BASE_URL`和Dart `ELITESYNC_API_BASE_URL`均固定`https://127.0.0.1:18444/`，TLS证书SHA-256 `41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`。

顾问源码抽查确认：
- Gradle只允许V2 function专用构建参数，并将同一endpoint/certificate传递到Flutter AAR和Android宿主；native和Dart均校验endpoint，禁止重定向/跨源/旧站回退。
- 该APK是**本地USB回环联测Debug工件**，127.0.0.1需经获准设备上的ADB reverse映射到本机18444服务；不是可直接在公网运行的内测服务器包。Debug证书也不是正式发布签名。
- APK二进制在本地私有目录，网页顾问未能直接下载和重算SHA；上述包名、签名和hash均为`CODEX_REPORTED`。未安装、未真机、未双机实测。

## 3. 保留的旧问题和产品门

- 正式KYC/真实身份提供商未配置；MariaDB上正式报名/Relationship确认仍按现行合同拒绝。
- 旧排盘A/B/C、注册可信离线T0仍`OWNER_DECISION_PENDING`。
- 全量PHP/Flutter、原Q PHP 46 errors/122 failures、旧排盘25、R1 Flutter扩围5 FAIL及历史1011804的FAIL/UNKNOWN/NOT_RUN不改写。
- 真实Push/RTC、视频/聊天附件、真实删除受理、跨设备缓存/通知、真实管理员账号、正式A6均NOT_RUN或BLOCKED_EXTERNAL。
- 软件著作权已有源码、功能目录、依赖许可索引；操作手册正文、同版截图、权属/委托/素材确认未完成。实际登记申报NOT_RUN。
- 封闭内测还缺当前APK具名设备旅程、受控测试人员/账号/数据范围、告知与停止机制及Owner审批。**CLOSED_BETA_CANDIDATE_NO_GO**；不合main、不迁云、不对外发布。

## 4. 顾问验收与下一批重点

**接受本轮P0本地工程交付的限定范围**：PHP原12项精选失败归零、签名TEST_ONLY SQLite慢约/关系正向、MariaDB API私有媒体和权限撤销、Web及当前Android工件固定。整体仍`CORE_FUNCTIONS_PARTIAL`。

下一批不重做已通过的P0：
1. 在专用`elitesync_v2_function` MariaDB实例上建立**额外严格绑定的合成匹配身份资格**，仅本地专用DB/host/user/port/server-id/MariaDB版本、虚构批次、CLI签发、HMAC、短时有效、审计/撤销；无HTTP签发入口，生产/旧库/普通staging均拒绝。以此跑正式匹配→候选→双边接受→Connection→Relationship双边确认→Block/撤权的MariaDB HTTPS正反链。不得改`APP_ENV=local`绕过或把测试凭据视为真实身份。
2. Android设备门：Owner先具名授权一台自有测试手机，Codex再固定APK hash与签名、确认本机服务/证书和ADB reverse，仅安装1011805；完整跑登录/切号/冷启动/三盘/匹配可见降级/私信/社区封面头像/Buddy/通知/Block和断网恢复，保存脱敏屏幕与日志。未授权不安装、不读设备数据。
3. 在真机截图前先完成软著手册正文骨架、四组功能说明与源码/依赖权属索引；截图只使用最终同版APK/同一固定源码，Owner确认权利主体和素材。
4. 将旧排盘A/B/C、注册可信离线T0整理为一份简明Owner选择包；在决定前保持安全拒绝，其他本地功能继续。

顾问未授权或执行任何真实KYC、外部供应商、云端部署、软著正式申报、内测招募、main合并或生产发布。
