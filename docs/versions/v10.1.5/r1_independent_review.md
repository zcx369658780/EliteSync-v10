# EliteSync v10.1.5｜Astra独立R1功能复审

日期：2026-10-22（Asia/Singapore）。评审者：Astra／EliteSync长期GPT顾问。此文件为**独立复审裁决**，不是Codex自签，亦非`acceptance.md`或`integration_acceptance.md`。

**V10.1.5_R1_INDEPENDENT_REREVIEW_COMPLETE / PARTIAL / NOT_ACCEPTED / RTC_MEDIA_CORE_GATE_OPEN / OWNER_DECISION_REQUIRED / NO_R2_AUTODISPATCH / NO_MAIN_INTEGRATION / V10.1.6_NOT_AUTHORIZED**

## 1. 精确身份与真实来源

- 本轮只读核验 live `main` = `be21598ef8738ab4d8e5dbd20f210f473e0b51f7`（此次复审归档前），仍为已接受的v10.1.4产品；无v10.1.5源码集成。
- 原首次v10.1.5候选 `47e30a3ef5bc7aacb42b6e32b6bc822dbdbb0962`。R1源码 `1c5cd2bb7919c435e8486a76959db75e9ccc367f` 唯一Parent精确等于原最终候选。R1 Root Tree `165eb1f362db533ca94bfe1db677ff6f7bd477ed`，完整 apps Tree `0784c8aa7b0915a04b83693a45401197e31d93a2`，services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。R1 **14/14项改变的源码path/mode/Blob** 与Root递归Git Tree精确一致，非只看报告。
- 最终交付 `6da9a05156fda8b603224fd10e04ac1cc997ad79` 的唯一Parent为R1源码。对比原最终候选，ahead2/behind0；仅14项产品变化、追加原 `IMPLEMENTATION_REPORT.md` R1段和新增 `artifact_manifest_R1.json`；旧 `artifact_manifest.json` 与旧源码/旧审阅原件保留。
- 正式R1报告位于 `docs/versions/v10.1.5/IMPLEMENTATION_REPORT.md`，当前Blob `fe25b0e0f3a7c31977514939a359e32333132088`；R1 manifest Blob `fab9d9b54be295f1451a73f39b0daf00fadb703b`。原冻结计划 Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`、原长任务 Blob `0df56f69712a85541b5f24bef281e2a9a61520a4`、已签发有界R1 Blob `be3045b206b75b7ccd0d8b28bc366678fc890302`；冻结AC未被追改。
- 独立R1脱敏审阅 Commit `6e9b7441839954d0d8847399c91482354c61e473`，Root `ad834e85f5fb5ce1e435bbfa3be46446862d35b2`；清单记录的**10/10路径、type/mode和Git Blob均与真实Git Tree吻合**，选择性再次读取六份关键脱敏文件也与清单Blob相同。后端/真实Android/AVD/本地SQL/APK/虚拟音频运行是`CODEX_REPORTED/LOCAL_ONLY`，不是Astra现场运行；审阅文本可用不能自动升级成独立设备实测。

## 2. R1四项分项审阅

**B1｜Android期限、离线缓存与到期清理：`SUPPORTED_WITH_TEST_INJECTION_OBSERVATIONS`，本次限定目标可收口。**

- 真正通过GitHub直接核R1源码中的独立probe/Gradle/入口约束：要求测试开关、本地测试构建、native debug identity和隔离appId；正常`lib/main.dart`与普通产品入口不import probe，Gradle拒绝probe release/profile任务。源端仍需未来打正式包时检查生产构建不包含调试能力。
- 实际Android进程经受控测试时钟推进与原生`FlutterSecureStorage`存储，R1脱敏结果**34/34阶段均`passed=true`**：真实后端登录T0与refresh不续期、当前读取、15天前/当/后、20天只读、30天前/当/后、实际测试namespace密文＋manifest的删除成功（`completed/deleted_objects=1/native_delete_completions=2`）、受控删除异常后`failed`并锁定，及force-stop/relaunch后旧密文仍存在却无可信锚、读取拒绝。
- **`ANDROID_TEST_INJECTION`不等于`REAL_PHYSICAL_ELAPSED_30_DAYS`。** 这里不要求真的等待30天才能验证一个可注入时间边界的程序，但也不据此保证实体设备连续30天运行、OS实际故障、跨重启续期、现实撤权即时传播或法律上的数据删除完备性。现有生产策略为冷启动锁定并重新在线核验；这一限制必须保留在UI/文档与未来运营合同。

**B2｜RTC/SFU及5秒撤权：`CORE_OPEN / NOT_ACCEPTED`。**

- 真实GUI仅有初步呼叫/来电可见，未建立双端有效流动SFU音视频媒体；同一通话重连、旧RTC JWT首入/重入拒绝、权限撤回后流动媒体≤5秒终止四项均无成功物理回执。旧RTC HTTP200/404或静态权限门不能替代该证明。
- R1实验范围经Owner特批只包含已有双AVD的虚拟麦克风、现有Emulator Controller合成PCM和loopback TCP SFU；不允许真实宿主麦克风/摄像头、手机、UDP、UAC、防火墙或新SDK。合成440/880Hz注入分别出现`UNAVAILABLE / connection reset`和`DEADLINE_EXCEEDED`（exit1）；B AVD退出、A UI/logcat阻塞。SFU首次`authority_monitor_failed/sfu_fail_closed`，恢复后仍未形成真实双端媒体成功证据。
- **环境故障根因尚未证明**：这些事实不构成“RTC代码必有P1”的证据，也不能当RTC PASS。真机AEC/人耳音质 `DEVICE_PENDING`，无授权摄像头源的视频实验 `NOT_RUN`。冻结AC-05依然是当前阻止整版独立功能接受的核心门，不能由GPT在未获Owner批准时静默降低。

**B3｜消息丢响应、切号、旧通知：`SUPPORTED_WITH_RETAINED_WS_LIMITATION`。**

- 从真正“Laravel已提交响应、loopback代理拦截导致Dio receive timeout”的失败样本中找出竞态：并行current-read过早清除attempt，首次重试换新client_message_id，造成历史id2/id3重复。R1源码对`LiveChatPage`采取只有POST或相同键重试的确认才清attempt，保留旧失败原行而不修饰。
- 修复后真实GUI同键`c9630ad0-e88b-43cd-977f-07db37860fb5`再次POST返回原message id4、`idempotent_replay=true`，MariaDB id4一行、相关通知一条；源码与相关定向测试相符。不因此承诺所有任意网络状况绝不重发。
- A原有私密读取延迟时服务端logout、切C账号后新会话拒绝不授权读取，迟到旧结果不出现在C界面；另一受控Safety旧通知在账号禁用后真实点击，当前GET403且无私密内容。Safety负例使用具名`TEST_ONLY_DIRECT_SAFETY_FIXTURE`，不等于完整真实活动writer重验。
- 综合消息WS断开/重连最后断言`exit1`且中间步骤不完整序列化：**不能标记WS端到端全部PASS**；已独立声明的当前HTTP404/WS pre-upgrade close是有界安全结果，未见具体可复现越权事实。此项保留为观察与未来关联回归，不与RTC媒体撤权混为一谈。

**B4｜测试与保护：`DELIVERY_SUPPORTED_WITH_OBSERVATIONS`。**

- 后端隔离回归47 tests/1769 assertions exit0；初次环境隔离保护拒绝导致47 errors/exit2，正确`testing/sqlite/:memory:`后通过，原失败不抹。Probe5 tests exit0、消息8 tests exit0，相关Dart analyse exit0；最初空白检查exit2，既有CRLF规则后exit0，原失败保留。非作者静态审查报告未发现未关闭高置信P1/P2，AAR/P2构建缓存与原消息键竞态经过有界审查，但**并非实际设备独立审查**。
- 正式R1开发APK由Codex报告固定源码构建和双AVD拉回hash `2c54dcae8d26f85995750b2e45e8d12fa0e5f450c7747fddc76274c7a40d0466`；独立测试probe与普通调试APK分开，不把probe旧源码字节冒称主APK新构建。
- 五保护根状态、首轮260文件hash、既有refs与私密env一致及R1专属资源停止，仅由Codex具名回执支持；未获Astra本地全面物理核验，也不推定全部未列历史私密文件都已哈希。

## 3. R1后冻结AC结论

| AC | 独立复审判定 |
|---|---|
| 01 | `SUPPORTED_WITH_LOCAL_PROTECTION_OBSERVATIONS` |
| 02 | `SUPPORTED_R1_REAL_RESPONSE_LOSS_RETRY` |
| 03 | `SUPPORTED_BOUNDED_NEGATIVES / WS_COMPREHENSIVE_EXIT1_RETAINED` |
| 04 | `FIRST_ROUND_PRIVATE_MEDIA_EVIDENCE_RETAINED` |
| 05 | **`PARTIAL_CORE_OPEN_RTC_SFU_MEDIA_AND_5S`** |
| 06 | `SUPPORTED_ANDROID_TEST_INJECTION / REAL_PHYSICAL_ELAPSED_NOT_CLAIMED` |
| 07 | `SUPPORTED_NATIVE_ENCRYPTED_TEST_PURGE / REAL_OS_FAILURE_NOT_RUN` |
| 08 | `SUPPORTED_BOUNDED_CURRENT_NOTIFICATION_GUI / FULL_SAFETY_FLOW_NOT_RERUN` |
| 09 | `PASS_TEST_ONLY_ISOLATION / REAL_PUSH_PROVIDER_PENDING` |
| 10 | `PARTIAL_DUE_RTC_AND_WS_OBSERVATION` |
| 11 | `DELIVERY_VERIFIED / FUNCTION_ACCEPTANCE_NOT_GRANTED` |

R1在B1和B3实现了可辨的改进，能按其实际范围视作满足本轮有界验证。**整版最终独立裁决仍为`V10.1.5_PARTIAL / NOT_ACCEPTED / RTC_CORE_GATE_OPEN`**。未把`NOT_RUN`无证据升格“BUG”，也未把`CODEX_REPORTED`升格Astra实际执行。没有为通过而追改冻结AC-10.1.5-05或拆下未验RTC后悄悄接受整版。

## 4. 下一门仅待Owner选择——不自动发布R2

当前不再自动派新任务/反复诊断、重新冻结v10.1.5、生成R2、修改产品源码或安全集成main。Owner下一条指令可以选择：

1. **单次具名RTC环境/设备授权后再补AC-05**：限定在现有受控SFU、合法双端设备/音视频资源范围，对`authority_monitor_failed`、Emulator Controller虚拟音频故障和raw/guard入口做一次定点根因与实际媒体验证；只有取得流动媒体→撤权COMMIT→5秒内停止和旧JWT拒绝等结果，才重议整版接受。任何新增真实设备、摄像头、麦克风、UDP、防火墙、新镜像/费用，仍须Owner明确另授，不能据既有测试偷用。
2. **明确批准调整交付分界**：保留RTC作为具名未验能力，另作受控的版本范围/交付策略决策，具体划分及不影响既有v10.0.9接受边界的安全关闭方案需Owner授权。不得把这一选项等同“已接受v10.1.5或允许非RTC源码直接main”；即便批准受限成果集成也需重新形成可审合同与独立集成门。

无论何种选择，`main`当前仍为v10.1.4接受产品；v10.1.6未获自动启动权。实时Push真实投递、实体音质/AEC、真实身份供应商、生产/公网/支付、v10.1.0历史PARTIAL和旧数据库事故/原证继续保留。