# EliteSync v10.1.4｜Astra独立功能验收（含同版R1）

日期：2026-10-21。裁决主体：Astra，EliteSync GPT顾问，直接在GitHub归档独立结论，**不是Codex作者自签**。

**V10.1.4_FUNCTION_ACCEPTED_WITH_OBSERVATIONS / R1_B1_CLOSED / R1_B2_CLOSED / MAIN_PRODUCT_INTEGRATION_NOT_STARTED / REAL_EVENTS_AND_PAYMENTS_NOT_AUTHORIZED / V10.1.5_NOT_STARTED**

## 1. 精确接受对象

| 对象 | Git固定身份 |
|---|---|
| 冻结功能plan Blob | `6f4157eeee47bc8d2fc4bbda5767025de0691347` |
| 原综合任务Blob | `67f01f8841a7882a907d1782136ff520caed977c` |
| Astra同版R1任务Blob | `36d6b3549e0fd1dff2fc44f6db72ac62c7d4f0fa` |
| 原v10.1.4源码Commit | `e7e246dc70f72846a05a31e022efadee0838ab83` |
| 原v10.1.4完整交付Commit | `4f303bc3674edc599c9602e6704a97deb6dce4ba` |
| **最终接受的R1源码Commit** | **`1062603bfd5866eb4c40b4773657343a1eca2af7`** |
| R1源码Root Tree | `aa4c47569d60a5e5638c25e9b0e3c0d7e1760da5` |
| **最终接受apps Tree** | **`3468a3dd97da7accfda2539a0f8d8f68931a6110`** |
| **最终接受services Tree** | **`0cb1f9d19659291a462488b3686fd0a07a6698ac`** |
| R1最终完整交付Commit | `01622dfffc48649911fd88f0cd0a9ed340260d37` |
| R1完整交付Root Tree | `ce17197dccbdac481e3d39b767c8a6758502a546` |
| R1追加后唯一实施报告Blob | `d34b7ea10e6d5fb6024a1911fcde570794cd7e32` |
| 原artifact_manifest.json Blob | `107817209f195d183392f3a6fda96d456fd5059f` |
| 新artifact_manifest_R1.json Blob | `9772bf5f43c12443951852cf47de12747df5f108` |
| 原短期审阅Commit | `8e639a3f22fe85eaf267f518c7205e4973dd5092` |
| R1短期审阅Commit/Tree | `d59cb76d41a0a0d81947d584ac6228554c82fda0` / `b1cae2fbc0cc813bf2f2e63e2322b2a41d59004b` |

Astra直接从GitHub核验R1源码和交付commit父子链：R1源码唯一parent为原完整交付；最终交付唯一parent为R1源码。相对原完整交付仅9项产品变化（原有7项范围修改、新增2项）；**9/9文件path/mode/Blob与R1 manifest和Root Tree吻合**。文档后继仅追加一份R1 manifest及唯一主报告的R1章节，原候选和原审阅分支HEAD没有移动。R1新审阅包**36/36路径及Git Blob**与manifest一致。上述是Astra直接的Git对象核验，不等同于下载重放每条物理运行。

审阅时live main仍为`c6ef1fef6d03bfaefc9f334b3b5a6c362dc07e01`，接受产品为v10.1.3两子Tree。**本文件归档不意味着v10.1.4已合产品main**。

## 2. 两项R1阻断最终关闭

### B1——先安全退出，仍能在有限窗口提交本案最小报告：CLOSED

原候选真实HTTP合成反例：A参与后先取消原活动，合法最小报告POST→404、原活动GET→404；没有业务新增副作用。R1独立新增`SafetyParticipation`，根据服务端真实`apply`操作审计、原registration id及co-participation时序重建参与窗口，不以客户端传入的claimed fact或仅INVITED行作为参与证明。**`DEV_SAFETY_HISTORY_7D_V1 / REPORT_ONLY`**的合成开发窗口按本人退出/相关撤权/活动终止与event end的较早界限计算，后续事件不能重新开启；只向本人显示最小event与同史registration指针，无旧标题、场所、联系人、资料或媒体。

修复后，A退出并被Block仍能从实际APP/HTTP提交本次权限内报告，POST201并产生OPEN Case+两条密封的最小来源，旧私有GET仍404；跨活动/陌生人/错误指针404，客户端伪造参与422、旧JWT401，重复相同键不重复创建，内容冲突409。Widget证明历史目标能与现行活动卡并行选择、切号迟到结果不混入。这些真实HTTP、APP和持久数据库运行均是Codex的`CODEX_REPORTED/LOCAL_ONLY`，Astra读取了相应脱敏结果和实际实现。

### B2——撤权后受控内部案卷继续程序性调查、但不恢复旧私权：CLOSED

原候选合成HTTP反例：合法案卷的具名Web证据GET原来200，参与方Block之后普通活动GET404且Web案卷证据也404，形成调查断路。R1在原`safety_case_evidence`增加`source_fact/fact_hash/retain_until`，收案时只封存与当前合法参与关联的有限case/event/registration、审计参与起点、当时state/revision/capture时间及用途哈希；**`CASE_INVESTIGATION_ONLY / HISTORICAL_AUTHORIZED_FACT`**，不复制私聊、证件、照片、个人精确定位或可向他人公开的声誉资料。

R1实际读取：Block/退出后私有活动/报告一般读取仍404，具名有权Web管理员能以具体理由取得限定历史源并在同一事务审计；程序性TRIAGE/INVESTIGATE/DISMISS可运行。历史源不等于当前仍有参与资格、发生真实危险行为或自动Finding：在纯历史源下，即便同活动两份举报也不能直接SUBSTANTIATE/处罚（422）；丧失/过期/篡改的来源仅显示`CURRENT_SOURCE_UNAVAILABLE / INSUFFICIENT_EVIDENCE`，不显示旧源ID或完整事实。旧无封存数据的case仅在原source_hash+服务端apply审计可严格重建时受控补封，无证据不推定原始事实。

具名角色降权403、真实Web会话撤销401，原独立CN/MC/Block/处罚及已撤权资料未复活。**两举报人规则只是合成开发的保守门槛，不是已批准的现实严重事件裁决标准**。真实纠纷重大处置与法定证据保留期限仍需Owner以后独立决定。

## 3. 独立核过的R1证据及证据等级

- **定点后端：28 tests / 1644 assertions / exit0**；包含新增10项R1+18项关联旧平台Safety Feature，遗留2个PHP及2个PHPUnit deprecations。Flutter定向平台Widget **15 tests / exit0**，7项PHP lint均exit0。
- **执行前后真实HTTP/DB：**原B1/B2均可复现404，标为`BASELINE_FAIL`而非“观测器exit0即产品PASS”；修复后201/200正常正例及相关404/409/422/401/403负例有脱敏摘要、源码和测试。
- **R1精确MariaDB REPEATABLE-READ竞态：**reader连接99，writer98；定位读在事务外，观测到同一`users.PRIMARY`的真实锁等待，写者`PlatformAccess::revokeAdminSession` COMMIT之后受阻的Web旧会话返回401，没有泄漏案卷内容或越权报告/证据/审计/通知/处罚写入。已直接核对应时间序列及事务ID，不把全局锁等待数/500/死锁算成功。物理执行由Codex完成，Astra未在Windows重跑。
- **受控重启：**本次只对10张本版相关参与/Safety表做重启前后行数与full-value SHA256相等核验；**首轮已验证的87张业务表结果保留但本次没有全量重跑**，两次证据不能混写。
- **最终R1 APK：**`com.elitesync.v1014dev`、`10.1.4-dev / 1010401`，接受apps Tree`3468a3dd97da7accfda2539a0f8d8f68931a6110`，最终APK与AVD安装回取SHA256均为`76e43dc2b9f187ec2824bbc636ae42b32cf30b95c90ea66158b1550182938eec`；签名开发证书SHA256`9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`，双ABI。Astra只核报告/清单与脱敏回执，未亲自获得本地APK字节或操作AVD。
- 本次R1主代理实际APP提交历史报告、Web具名调查/审阅及冷启后本人最小收据的回执可相互对照；非作者独立审阅者只做有界Git/源码静态复核，修复其发现的无关撤权截断和APP历史目标隐藏问题，结论无未关闭静态阻断，不能替代Astra终验。
- 原v10.1.4 51/1182后端及Flutter30证据、模拟活动和预算/真实Web/APP/DB功能链、87表重启、两组旧RR保留有效范围；R1没有重做所有原功能。原44 tests/387 assertions/5个历史同源失败exit1及其它首次运行失败、警告、原APK、原备份均保留。

## 4. 明确保留的观察和禁止误解

1. 七天`REPORT_ONLY`与三十天`CASE_INVESTIGATION_ONLY`是**本版TEST_ONLY的开发默认**，并非Owner确认的真实投诉期限、真实隐私保留期限或合规法律判定；R1由受控测试时钟测试期限，没有物理等待7/30天。案卷过期不等同自动删除真实记录。
2. 受限历史参与只佐证“曾参与/曾有交集”，不自动证明严重不当行为；当前规则的两举报人硬条件也非真实线下安全处置合规标准。实时威胁/严重单案、真实调查程序、证据取得许可及具体运营流程未开放。
3. 本版本仍是合成活动与模拟预算，**没有真实招募、场地订位、实际付款、真实GPS签到、外部LLM自动评分/处罚、正式Push或实名Provider验证**。本版应用/DB/Web/设备的证明仅为受控开发环境。
4. 旧v10.1.0整体`PARTIAL/NOT_ACCEPTED`和AC-10.1-08 PARTIAL、v10.1.1库误清/恢复、旧RTC/AEC与通知GUI未完全走通、当前真实身份Provider PENDING、项目源旧ZIP GitHub BYTE_MIRROR_PENDING保留；这次无权删除历史候选、原短期审阅或本地SQL/APK/恢复卷。
5. Codex记录的五保护根原位未变、旧APK/SQL原证hash未变，本版API/DB/AVD已停止、专属卷与恢复点保留，**这些仅为`CODEX_REPORTED / LOCAL_ONLY`，非Astra实地核验**。

## 5. Astra终裁与下一门禁

**最终独立裁决：`V10.1.4_FUNCTION_ACCEPTED_WITH_OBSERVATIONS`。** B1/B2本轮有直接源码修复及受控执行回执，达到冻结版本的Safety最低授权/连续性合同，不需第二轮功能返修。完整产品仍只在候选分支，不等于v10.1.4安全集成完成，不授权生产或真实运营。

下一步若Owner批准，才可按上一版已成功简化的工作流发**v10.1.4单次安全集成**：从真实live main仅接入接受的完整apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`与services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，保留Owner决定、v10.1.3所有接受/审阅和本次Astra结论；正式报告/原及R1 manifest准确归档；必要静态检查及本地连续代码基线，不重跑功能测试；Codex交付后Astra独立第二道集成验收。此结论不自动派发、不合main或启动v10.1.5。

**来源：**[追加R1的唯一实施报告](IMPLEMENTATION_REPORT.md)、[原制品清单](artifact_manifest.json)、[R1制品清单](artifact_manifest_R1.json)、[原R1冻结审阅任务](ASTRA_REVIEW_AND_R1_TASK_20261021.md)、[R1公开脱敏审阅](https://github.com/zcx369658780/EliteSync-v10/tree/d59cb76d41a0a0d81947d584ac6228554c82fda0/docs/_temporary_review/v1014-r1-20261021)。
