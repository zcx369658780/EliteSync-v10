# EliteSync v10.1.5｜Astra独立功能初审与同版R1有界返修

日期：2026-10-21。独立裁决者：Astra（EliteSync GPT顾问），**不是Codex自签**。

**V10.1.5_CHANGES_REQUIRED / NOT_ACCEPTED / OPEN_CORE_EVIDENCE_BLOCKERS / BOUNDED_R1_TASK_READY / OWNER_MANUAL_DISPATCH_REQUIRED / MAIN_PRODUCT_NOT_INTEGRATED / V10.1.6_NOT_AUTHORIZED**。

本次只读独立核GitHub Git对象、冻结合同、当前源码的关键使用点、实施报告及脱敏审阅证据；没有实际操作Windows、SQL、AVD、SFU或物理音频设备。现存有价值成果保留，不因部分未完成重写全部版本，不将测试替身/报告等同实际设备和长期物理计时。

## 1. 核验身份、来源与交付隔离

- 唯一冻结plan `docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；唯一长任务 Blob `0df56f69712a85541b5f24bef281e2a9a61520a4`。不修改原AC-10.1.5-01～11。
- Astra审阅时live `main`：`9283b7f6ed7f37971fd9f64c60e9747c7896b09d`；源码唯一Parent也精确是该main。源码Commit `6ca68617fd6e18648a9ccd4c923fa1850761fbec`，Root Tree `d43b98c77edbb0c4b74ab93a2574b50a0bf3f1c7`；apps `d0343174cb8587d9e27303f180a37380616b6262`；services `c32fc724fde29a595084e8c1ec066340d892e8fe`。GitHub compare显示62条源码path变化、单源码提交。
- 最终文档交付Commit `47e30a3ef5bc7aacb42b6e32b6bc822dbdbb0962`。源提交之后领先2、落后0，变动仅 `docs/versions/v10.1.5/{IMPLEMENTATION_REPORT.md,artifact_manifest.json}`，没有新的apps/services源码差异。
- 正式实施报告 Blob `ae7b8d0cf2a616e198da23ea4db6a8d9e53c5bb6`；artifact manifest 的证据等级与报告PARTIAL状态一致。独立短期review commit `7f7a1036e4a4567be7797e41530011b2dbb06684`，报告对应Root `b931e43fabe46167cc40cd3c137eb47801798cac`；GitHub固定目录 `docs/_temporary_review/v1015-20261021` 内**23/23路径和Blob与artifact_manifest清单一致**，是本轮GitHub直接核验。尚未亲见任何LOCAL_ONLY原始SQL、APK、截图或原始日志。
- 已定点直接读取 `PrivateCacheService`、`OfflinePrivateRetentionPolicy`相关设计、`AuthLocalDataSource`与`SessionNotifier`、`LocalStorageService`和`CacheKeys`、`DeviceSessions`、`AuthController`、`RtcAuthorityService`、`ChatWebsocketAuthorizationService`、`NotificationDeliveryService`及API设置。代码体现真实login T0、token有效期、按账户/设备存储、站内通知current authority和TEST_ONLY隔离，不应将其误写为纯占位。
- GitHub脱敏回执可以确认“报告确实存在及其精确文本”，但APP/设备/DB/SFU物理运行证据均仍`CODEX_REPORTED/LOCAL_ONLY`，非Astra执行；后台大集合量回归exit0不替代漏掉的核心真实验收。

## 2. 冻结AC的独立裁决

| 冻结AC | Astra当前结论 | 关键范围与不得升格的证据 |
|---|---|---|
| AC-01 基线/保护 | `SUPPORTED_WITH_OBSERVATIONS` | 提交/Parent/apps/services直接核准；本机五根/SQL/库属于CODEX_REPORTED，原备份非全部独立hash。 |
| AC-02 消息可靠性 | `PARTIAL` | 双AVD文字/图片/视频与幂等真实回执、Socket指针和离线禁发送有受限证据；“请求服务端已接受但响应丢失→同键重试”未做实际故障注入。 |
| AC-03 撤权与迟到结果 | `PARTIAL` | RR reader43/writer42撤权后401与媒体404、Block等提供有价值正反例；切号/删除、旧响应/WS/旧通知完整真实GUI未闭合，禁用组合脚本仍有原失败。 |
| AC-04 私有媒体 | `SUPPORTED_WITH_OBSERVATIONS` | 真实APP选图/无音轨H264短视频、200/206/404、重启读回可保留，非“所有格式或所有声学”接受。 |
| AC-05 RTC | `PARTIAL / CORE_OPEN` | 只验证呼叫控制HTTP、拒绝/接受/结束与终态404；SFU双端媒体/网络恢复/撤权5秒内停止均NOT_RUN。静态`RtcAuthorityService`已有拒绝和设备失效逻辑不能替代实际媒体停止。AEC真机听感是另一个受限设备门禁，不能写PASS。 |
| AC-06 15/30天 | `PARTIAL / CORE_OPEN` | 成功登录T0与refresh不续期、持久TEST_ONLY时钟边界HTTP 200/401受支持；真实Android可信经过时间、冷启动后期限完整轨迹尚未成立。纯fixture不是实际物理15/30天。 |
| AC-07 加密离线与到期清理 | `PARTIAL / CORE_OPEN` | 代码`PrivateCacheService.purgeExpired`依赖已建立进程内计时；本版双AVD断网同进程只读和冷启动锁定、加密缓存收据有价值，但**实际Android达到30天的可验证清理成功/失败**未发生。Widget注入时间和登出清理不能代替此项。 |
| AC-08 通知隐私 | `PARTIAL` | 真GUI偏好/OS权限变化及后端当前鉴权有证据；旧卡片点击、Safety/禁用/退出/切号完整负例未闭合。 |
| AC-09 真实Push | `PASS_ISOLATION_ONLY / PROVIDER_PENDING` | TEST_ONLY供应商接口/最小payload和撤销可认可为隔离交付；真实Push仍NOT_RUN，不属于本版无授权软件缺陷。 |
| AC-10 综合运行 | `PARTIAL` | PHPUnit50/286、RTC7/53、Flutter定向及9表重启受支持；初版后端19/159 7 errors/exit2保留，fixture修复后定向7/53 exit0；`flutter analyze` exit1、0errors/0warnings/8旧info，不伪称全绿。核心AC仍未通过。 |
| AC-11 交付 | `DELIVERY_VERIFIED / ACCEPTANCE_PENDING` | 正式报告、manifest、23/23短期审阅Git对象、非作者有界静态报告存在；非作者无未关闭高置信P1/P2的结论不是本版功能验收。 |

**正式独立结论：`V10.1.5_CHANGES_REQUIRED / NOT_ACCEPTED_YET`。** 这不是对既有有效证据的否定，也不是认定新安全回归P1已经实际发生；原因是冻结AC-05/06/07存在不可直接豁免的真实验证缺口，AC-02/03/08有具名遗漏。不得以真实Push Provider缺席伪装软件缺口，也不得将所有NOT_RUN等同BUG。原已接受v10.1.4完整产品main保持权威。

## 3. 唯一同版R1有界返修任务（待Owner手动派发）

Codex从**固定原v10.1.5最终交付Commit `47e30a3ef5bc7aacb42b6e32b6bc822dbdbb0962`**及源码Commit `6ca68617fd6e18648a9ccd4c923fa1850761fbec`安全接续一条R1候选，**绝不以旧主线reset/丢弃首轮成果**。首先比对真实远端现状及本地历史保护身份；保留冻结plan/task和首轮失败及原审阅分支不变。只在R1-B1～B4中做必要实施和验证，不开新版本、不重跑未受影响的全量旧业务：

- **R1-B1（核心，AC-06/07）——Android实际可信期限与受控到期清理**：在已允许的开发AVD/新独立TEST_ONLY库/合成密文范围，证明成功online login T0、refresh不续期、同账户/设备可信时间连续性、15天前后权限、15～30天离线只读、达到30天时实际应用层删除本版受控密文及失败锁定并有真实读回/清理回执。允许使用**仅测试构建/测试进程**的可审计可信时间/单调时钟注入和合成边界推进来缩短实验，不准通过系统全局改时钟、重写生产T0、客户端伪称服务端时间可信、删除历史文件或给正式生产增加时间绕过开关；要分开标`ANDROID_TEST_INJECTION`与`REAL_PHYSICAL_ELAPSED`。如果不能证成真实设备上的可信安全期限/30天清理合同，仍保持`CORE_OPEN`并准确报告，绝不写“真实度过30天”。重启/换号/已知撤权/时间异常仍fail-closed，旧程序的私密快照与draft不可偷偷绕过加密/权限门。
- **R1-B2（核心，AC-05）——双端SFU媒体与撤权5秒终止**：只在已有明确授权和归属的隔离RTC/SFU/测试设备与网络中验证双方APP实际音视频建立、网络恢复、挂断及Block/CN/MC或设备session失效后的旧JWT首入/重入拒绝、已经流动媒体在5秒内停止（具名时间/结果/原始脱敏证据）。不把控制面200/404、RTC fixture7/53或模拟断连冒成真实SFU证明。现有本地受控SFU如无权启动、缺音频/视频设备、需开防火墙/UDP/UAC/真实手机/新镜像，只暂停该高风险验证并列明所缺Owner授权，继续其余R1；**禁止暗中扩大设备、云端或网络权限**。AEC物理听感在没有实际同意与音频设备时保留`DEVICE_PENDING`，不因它声称RTC媒体已达标。
- **R1-B3（AC-02/03/08）——有限真实异常/GUI矩阵**：在允许的同APK两开发账号与受控HTTP中实际注入“服务器已提交但应答丢失”，验证客户端同一`client_message_id`安全重试、DB与通知不重复且未知状态不假显示成功/失败；完成具名切号/迟到网络结果/注销或禁用后的旧通知点击/平台活动或Safety通知最小化与GUI重新鉴权、WS断开前后当前授权。无需重建完整Android UI，至少各有一项真正前端入口及API/DB负例；用受控测试替身的场景要分开标明。
- **R1-B4（共同验证与交付）**：执行上述改变所需定向PHP/Flutter/真实DB测试、准确保存exit/stdout和先失败后成功的负例；如客户端变更重建开发APK并对双端install/readback SHA。独立非作者定点检查新的权限/时间/离线/RTC差异，保存原失败/deprecation与原保护资产不变。首轮已经有证据的图片/视频Range、主通信、通知TEST_ONLY无需重新整包执行，除非R1实际改动引入关联回归。不要自动运行生产/公网/外部Push/真实供应商、下载新SDK或改变Owner既有安全边界。

**交付方式：** 在原唯一 `docs/versions/v10.1.5/IMPLEMENTATION_REPORT.md` 尾部追加一段清晰的R1结果；另以`artifact_manifest_R1.json`列本次变化path/mode/Blob、固定源/Parent/新的Root/apps/services/制品身份与测试、保护证据。保留首轮manifest原件和先前提交Git对象。若GUI/Android实物证据物理只存本机，GitHub仅发布最小脱敏报告/审阅副本，按固定分支回读；不要把SQL、APK、完整Token、个人隐私和设备敏感标识发往公开仓库。原短期Review分支/旧库/旧APK/恢复证据仍不自动删除。

完成R1候选即停：`V10.1.5_R1_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_FUNCTION_REREVIEW / PRODUCT_MAIN_NOT_INTEGRATED`；若B1/B2无法在现有授权与设备条件下关闭，交付`PARTIAL / OPEN_CORE_BLOCKERS`和最小具体阻断即可，**不得自行调降冻结AC、不得自行签`ACCEPTED`或进行安全集成、不得提前开始v10.1.6**。只有Owner手动派发本R1正文才可继续实际执行。

## 4. 完成后的下一门禁

Astra只基于R1实际候选及先前可复用证据进行独立复审。只有所要求核心范围具真实支持时才可能签正式 `acceptance.md`；否则继续保留`NOT_ACCEPTED/PARTIAL`并呈交Owner对客观外部门禁做具体决定，不默认进入R2或放弃冻结AC。**即使未来功能接受，产品进入main仍需Owner单次安全集成批准与Astra第二道集成验收。** 历史v10.1.0整体PARTIAL、v10.1.1数据库事故、未接真实身份/Push/支付/运营外部门禁与2026-10-21项目源ZIP字节镜像问题继续分层保留。