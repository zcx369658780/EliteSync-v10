# EliteSync V2｜功能闭环批次顾问独立限定验收（2026-11-21）

状态：**`V2_FUNCTION_LOCAL_E2E_ADVISOR_SCOPED_ACCEPTED_WITH_RESERVATIONS / CORE_FUNCTIONS_PARTIAL / PHP_SELECTED_REGRESSION_FAIL_12 / ANDROID_CURRENT_BUILD_NOT_RUN / COPYRIGHT_MATERIALS_INDEX_ONLY / CLOSED_BETA_CANDIDATE_NO_GO / PRODUCTION_NO_GO`**。

## 一、固定证据和GitHub读回

- 工程提交：[固定源码`63a2bbf24c4dff9b892ef94ba99dd34d0888f226`](https://github.com/zcx369658780/EliteSync-v10/commit/63a2bbf24c4dff9b892ef94ba99dd34d0888f226)；综合报告：[固定`3b42dfe4328fc2fe520cab1fe9561830fcb8ca56`](https://github.com/zcx369658780/EliteSync-v10/blob/3b42dfe4328fc2fe520cab1fe9561830fcb8ca56/docs/versions/v2/cloud-r0-20261121/V2_FUNCTION_COMPLETION_QUALITY_REPORT_20261121.md)，报告Git blob `9c9b0a7a753234c887872dacd9a7d6b1277764e5`。
- GitHub现场compare相对已核R0 `9baa82aa0cdf947dcc4996d2a584c92e4f4535f1`：ahead4/behind0、merge base=R0。固定源码到最终报告ahead1/behind0且仅新增该报告；真实开发分支`codex/v2-function-completion-20261121`远端HEAD核实为报告SHA。
- 顾问直接审阅GitHub报告、`SyntheticConnectionScope`及Console grant、`LiveConsentService`、`ConversationCapabilityService`、`ConversationAtomicSendService`、`DenyUnverifiedMessagingLiveAccess`、数据库迁移和Compose、Flutter`LiveConnectionPage`与HTTPS集成测试和后端`function-smoke.py`片段；证据等级`ADVISOR_SOURCE_SPOTCHECK`。本地测试/WSL Docker/MariaDB/Flutter宿主日志的真实运行仅`CODEX_REPORTED_LOCAL_E2E`；网页顾问没有执行Windows程序，没有检查原JUnit与原始日志hash，不将“报告有SHA”视为独立复算。
- 环境为本机隔离WSL PHP8.4.28/Laravel13.39、MariaDB10.11.19，单独`elitesync-v2-function`，Nginx仅回环TLS；既有阿里云旧服务与真实管理员资料、PC清理全部未触碰。

## 二、完成与不足

| 能力 | 顾问限定结论 | 证据边界 |
|---|---|---|
| Connection→双向消息同意→文本发送/收信→撤销 | **`LOCAL_FIXTURE_E2E_SCOPED_PASS`** | Flutter测试真实router+API客户端+HTTPS受信证书，使用两个合成用户，发送后接收端读回同一message_id，撤销和旧深链404；还验证Block/失权、旧消息、DB重启的相邻API链。但这是测试宿主，不是手机APK、真实身份/正式匹配/Relationship或WebSocket/RTC。 |
| 合成资格安全边界 | **`ADVISOR_SOURCE_SPOTCHECK_PASS_WITH_OBS`** | `SyntheticConnectionScope`固定APP_ENV=staging、测试origin、专用DB name/user/host/port/server-id、MariaDB版本、开关与`is_synthetic/account_type=test/synthetic_batch`双主体，CLI限时grant/revoke。关开关/非回环/非此库/生产拒绝按Codex报告。测试资格并不授予正式身份证明；固定源迁入正式环境前仍要验证默认关闭、配置隔离、失权回归。 |
| Web 管理与社区/Buddy | **`LOCAL_SELECTED_E2E_SCOPED_PASS`** | 报告具名HTTPS真实Web表单/CSRF、形象审核→用户本人发布、举报分流、停用账号与审计；Buddy管理与发现申请/确认/失权、好友评论原受众与Block。仍缺完整APP与设备侧闭环、全部管理能力、媒体/视频及真实人员。 |
| 用户账户、三盘/资料 | **`PARTIAL`** | 当前本地HTTPS注册/退出、资料读回、三盘已知/未知和版本冲突可用；新Android整机录入/重启/错误恢复未跑。三盘仍`COMPUTED_UNVERIFIED`，不能上升算法真值已验证。 |
| 正式慢约Match→Relationship | **`BLOCKED/PARTIAL`** | 真实KYC及有效轮次未打通，正式手动参与403符合现行门禁。合成Connection自好友上下文起步**不证明**正式匹配发布→提案→关系成立完整正向链。 |
| 通知、音视频、身份及数据删除 | **`PARTIAL/BLOCKED_EXTERNAL`** | 可见最小站内通知与失权片段；实时双机、Push、RTC、真实KYC、真实对象删除受理未知，不能因模拟通过即标DONE。 |
| PHP精选与Flutter测试 | **`CODEX_REPORTED`** | Flutter本批39项exit0；先前125项+37项可能重叠不可累加。单项Flutter真实路由HTTPS测试exit0，126为**HTTP状态检查数**不是126独立测试。PHP精选46项/120断言**12 FAIL**，报告称固定R0同名同签名12项，顾问未见私有完整JUnit，暂标`BASELINE_EQUIVALENCE_CODEX_REPORTED`，不是已独立证实全量无新增缺陷。旧Q全量46errors/122failures、旧星盘25、R1 Flutter扩围5 FAIL、全仓本轮NOT_RUN保留。 |
| 软著与封闭内测 | **`PREPARATION_ONLY / CLOSED_BETA_NO_GO`** | 固定源码、功能目录和依赖许可索引已提供；同版APK/操作说明/截图/权属来源未齐。正式软件著作权申请、封闭内测及发布尚未获执行授权。 |

## 三、需要优先注意的边界

1. **正式匹配/正式关系闭环**与合成好友Connection是两条独立能力；不能把后者标为正式慢约功能完成。可在具名合法隔离环境编写“正式流程的测试数据与角色资格”但不可伪造真实KYC或外部凭据。安全测试资格与真实业务授权要分离。
2. **PHP旧12项FAIL**：Web登录/续期500或401、旧Connection与通知夹具409均涉及用户入口或权限，不能单凭“旧基线也失败”永久降优先级。下一次按`test_class+method+signature`逐项附录核真实合同、fixture与在用API，优先对当前真实Web/关系安全相关做隔离验证；不得删测或降低门禁。
3. **合成安全隔离**：现场只读源码已显示以固定staging库、server ID、开关和双方具名虚构账号绑定，跨环境禁止。需要进一步验证配置不可误用于正式云/Android，测试结束合成授权有TTL/撤销及日志，不应用HTTP自报开关替代内部资格。
4. **新Android APK/真实设备**为当下关键用户可见P0，不应用Flutter测试宿主替代。从当前版本生成包前同时锁原生`BuildConfig.API_BASE_URL`和Dart`ELITESYNC_API_BASE_URL`及证书/包名，排除回落旧生产，优先自用受控设备具名旅程；不扩大相机/麦克风与真实账号数据权限。
5. **正式外部准入依赖**与实际未实现要分层，真实身份/KYC、Push、RTC、法定删除受理等合格供应商或运营主体未入时不得自造完成回执。Owner两项产品决定：旧排盘A/B/C、注册可信离线T0仍未选择。
6. 现有Owner要求：**先补齐功能→软著材料→封闭内测→再考虑更换服务器**。G0b与旧管理员还原、新阿里云采购、PC清理不应重新阻断当前功能开发。

## 四、顾问判定与建议

**接受本批次的本地既定范围成果**：Connection文本链、Web后台具名旅程和Buddy社区API/DB形成重要跨层证据。整体`PARTIAL`，不得标为全功能PASS，不得提交封闭内测GO或正式软著已完成；没有授权合main、生产发布或真实用户处理。

下一批只聚焦一张功能缺口表和一份集中交付：优先 **P0正式匹配与Relationship合成正反链（不伪造实名）、Android同版APK的账户/三盘/私信/社区/Buddy实测、PHP旧12项用户/管理/消息相关失败分诊修复、媒体与权限撤销**；软件著作权资料允许同步按现有证据做索引，不要求完全软著材料定版前停工。
