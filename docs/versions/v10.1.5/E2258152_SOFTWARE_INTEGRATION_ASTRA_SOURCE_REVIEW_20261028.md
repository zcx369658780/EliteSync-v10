# EliteSync v10.1.5｜e2258152 消息、离线与通知软件研发候选｜Astra独立源码审查

日期：2026-10-28（Asia/Singapore）。

**正式裁决：`E2258152_BOUNDED_SOURCE_DELIVERY_ACCEPTED_WITH_REQUIRED_VALIDATION`。**  
**产品整版仍`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED`。**

此裁决接受一次符合指定范围的、可定位的**软件源码/测试源码候选交付**及其静态/纯逻辑证据分级。**不**接受Flutter客户端已编译、Laravel真实持久化/并发、设备加密、15/30日物理时间、真实Push、真实APK或v10.1.5产品AC。任何待运行项均仍为`NOT_RUN`，不得把31纯契约/23 lint变成端到端PASS或自行集成main。

## 一、权威与Git身份的独立核验

- 正式Owner综合任务：`docs/versions/v10.1.5/V10_1_5_MESSAGING_OFFLINE_NOTIFICATION_SOFTWARE_INTEGRATION_TASK_20261028.md`，Blob `b8553497a6e98f524550c4f6e89d8ccdccb79e62`，限定产品源码实施、独立安全工作面、离线纯逻辑/PHP语法检查、无真实DB/API/Flutter-Dart CLI/Gradle/G2/设备/旧ACL/系统权限操作。
- 开审fresh main `6a90c05538d1de8d648e645693ef9b1bf23b78f0` / Root `f5ac305a5f9eaa04bf2346322811909ff00ef047`；main已接受产品仍v10.1.4，apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 唯一候选Commit `e22581525a934377e094820e57bfc608ecdfc395`，sole Parent与开审main完全相同，Root `573382c8bca9c9d84e8a85bb72135399ced5b3e6`；GitHub compare返回ahead1/behind0且仅60条产品源码/测试路径变更以及两份本任务新文档。无main产品集成。
- 报告 `docs/versions/v10.1.5/SOFTWARE_INTEGRATION_IMPLEMENTATION_REPORT_20261028.md` Blob `b7b79462fea3f860dfe6c1685f641cdab8eb6529`；Manifest `docs/versions/v10.1.5/software_integration_artifact_manifest_20261028.json` Blob `ecee2e5abfe41ac31758999ea589ce4a8714d528`。两文件均通过GitHub直接读正文，Manifest能解析。
- 递归Root Tree `573382c8bca9c9d84e8a85bb72135399ced5b3e6` count6261，未截断；候选完整apps Tree `61c0dd9a70fcd56af00053f1d055884cecf052f0`（729个Blob），services Tree `cc61686579f4a89ac092f3f557ba1f8191471528`（711个Blob），共**1440产品Blob**，两子Tree查询均未截断。
- Manifest `SOURCE_PROVENANCE` 正好60条，逐条SHA/mode与GitHub递归Tree中的对应对象相等（60/60）；归类：31项定点采纳参考、18项定点重做、10项当前任务直接实施、1项main为基础的局部处理。上述是**Git身份/清单核验**，不是Astra对所有60个文件做了逐行语义检验，也不是额外执行所有62份原始文件的独立UTF8/SHA256重算。Astra对下面关键源码做了GitHub直接正文审读，未现场启动任何测试。

## 二、F1消息可靠性：接受源码交付，不接受并发功能闭环

直接阅读`ConversationAtomicSendService.php`、`MessagingReplayContract.php`、`MessageController.php`、`ConversationCapabilityService.php`、LiveConsent相关及LiveChat/ChatRoom源：
- 同一sender/clientMessageId和接收方/内容/有序attachment构成可比较指纹；候选把已提交同键回读放在新的附件ready验证之前；当前发送授权在回放判断中重新核验，避免旧合法消息借同键逃过Block/Connection/MC的当前状态。对应`V1015MessagingTest.php`有同键重放、异payload冲突、Block/成员退出和附件状态回退的真实Feature测试**源码**。
- 客户端保留未知确认的attempt，用session/epoch与回执ID校验；断响应、换号与旧WS信号不直接作为已发送证明。这些是源码层面可审的设计与变更，而不是已证真实HTTP断包和MariaDB RR并发。
- **必留门禁**：需在隔离合法MariaDB＋服务端API环境验证唯一键、事务、授权锁、两端竞态、附件/通知计数及响应丢失后持久重放；客户端Flutter编译与真实会话/撤权/晚响应定向测试均未运行。既有`firstOrCreate`/事务和事件日志的顺序不能仅凭纯指纹测试宣布完全正确。不得以PHP无框架纯契约代替MariaDB数据库正反回执。

## 三、F2离线密文：接受代码形态与保守锁定，保留平台/时间未证

直接审读`PrivateCacheService`、`AuthLocalDataSource`、`SessionNotifier`、`DeviceSessions`、`TrustedLoginTimeContract`和相应特定测试源码：
- T0由服务端真实成功密码登录生成，refresh不刷新其原始锚；注册/历史凭据不冒称成功登录。客户端当前进程使用server anchor＋Stopwatch，墙钟作为异常检查；重启保守锁定，而不是假造跨进程离线授权。
- 缓存通过安全存储接口按account/device/session/object隔离，有进程内read grant、写队列代际检查、task-owned manifest/删除读回，以及到期与异常路径的失败保守策略。新存储/退出交错测试源存在。
- **必留门禁**：没有Dart analyze/test、实际平台keystore/Flutter Secure Storage API、真实设备重启/进程回收和真实已过去15/30天/物理清理证据；缓存密文“已由OS安全存储加密”仍是接口前提而非当前实测。尤其需要核实Async跨登录/退出/cleanup失败路径，以及是否残留原来local profile等敏感快照；目前不能给真实离线/清理PASS。历史用户缓存及真实个人数据不得用来试验。

## 四、F3通知：接受最小披露设计，真实权限和投递尚未证实

直接审读`NotificationDeliveryService`、`NotificationService`、`NotificationController`、`NotificationPreferencesController`、API路由/迁移、Dart通知偏好页面及Feature测试源码：
- 新TEST_ONLY transport的返回envelope固定title/body和notification_id，没有实际Push provider；偏好分类/静默、登录设备session及过期、重放去重记录和当前资源presentation都被纳入代码逻辑；`/api/v1/notifications/{id}`按owner当前查回并设no-store，客户端旧通知不能只凭旧payload直接授予资源访问。
- **需后继定向安全测试的具体观察**：`notification_devices`以客户端给出的`device_id`作为唯一记录标识；重新绑定同一device ID到另一个账号在当前TEST_ONLY测试中被允许。当前代码由有效用户会话与匹配device_session约束，但没有验证实际**物理设备持有证明**；不能推广到真实Push token所有权或公开生产身份。此为后续供应商/真实设备门的安全设计审查项，不能静默接通生产Push。
- 新增两项数据库migration只在源码交付，尚未执行，通知的偏好/设备/attempt表不存在于main现行实测库的风险需在下一独立受控DB验证中处理。真实OS通知权限、后台回调、锁屏显示、系统拒绝/撤权回调和Push供应商均NOT_RUN/PENDING。

## 五、测试、环境、预算与保留风险

- Codex报告31项独立PHP纯契约检查exit0、23个变更PHP文件`-l` exit0；执行器为任务私有cwd/HOME/TEMP、`php -n`禁第三方ini、禁网络/进程函数、未bootstrap Laravel/vendor/DB，属于`CODEX_REPORTED_LOCAL_EXECUTION`；Astra没有现场复跑，也未把PHP8.5的语法检查替代目标部署环境PHP兼容性验证。
- Dart本包/相对import文本检查与内部非作者Sol/high只读复核是有界静态证据，**不是**Flutter/Dart编译或Astra独立运行验收。新增客户端widget tests、后端Laravel Feature tests及迁移尚未运行。
- 本轮报告的任务目录logical `136871626`、allocated `139835928` bytes低于任务256MiB两项限制，但只是Codex本地离散报告，Astra没有现场测连续峰值/最终receipt。
- 交付没有自称真实APP/DB/API/WS/设备/G2/PUSH成功，保持`PARTIAL_NOT_ACCEPTED`与`AC05_OPEN`。不改写旧完整APK及Gradle G各1/1耗尽、旧A关闭、独立G2条件余额0/1但本轮未授权；历史受限child `0xC0000142`、14项权限矩阵NOT_RUN，SDK/Gradle图、Dokka/TCP因果、AAR/POM、RTC AEC/last audible/native handle、真实15/30天及物理清理、真正Push和旧18件SD恢复均未关闭。
- `PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`作为Owner已封存历史事故继续不可更改；两棵旧ACL实验树、旧18件、122具名原证、五根、527refs及旧Seed不因本轮新软件源码交付而清理。此轮报告原始错误/red-green回执为`LOCAL_ONLY`，并非Astra逐字节现场验证。

## 六、裁决范围与下一唯一推荐门

**`E2258152_BOUNDED_SOURCE_DELIVERY_ACCEPTED_WITH_REQUIRED_VALIDATION`**：接受候选的Git身份、准确交付、合法源码工作面方法、已编写业务源码与测试源码、准确的`NOT_RUN`披露及本轮有界PHP纯逻辑/语法检查回执。

**不是`V10.1.5_FUNCTION_ACCEPTED`，也不授权产品main集成。** 在任何本版功能接受之前，必须至少获得经Owner另授权的合法Flutter/Dart类型检查与有界widget测试，以及隔离MariaDB/Laravel Feature/API持久/权限/并发回执；真实设备、15/30天、AEC、Push/G2等原冻结AC按实际证据继续标NOT_RUN/OPEN，不能由“静态通过”覆盖。不能盲继承参考候选全部未接受代码或篡改冻结计划的验收范围。

**下一建议：由Owner单独批准一份“在可信、隔离工具链及独立合成DB条件下的v10.1.5定向软件验证和必要同版修复”综合任务。** 目标是不重复旧ACL/Gradle调查，优先真实运行关键Flutter/Laravel正反例；环境无法满足的项保留NOT_RUN，停止相关动作，避免无限做只读preflight。此是建议，不是当前得到新的运行许可。

**STOP，等待Owner选择下一步；不得自动发布新任务、开始数据库/Flutter/G2、合main或启动v10.1.6。**
