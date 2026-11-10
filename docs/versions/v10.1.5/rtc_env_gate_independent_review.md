# EliteSync v10.1.5｜RTC环境门禁 Astra 独立复审

日期：2026-10-22（Asia/Singapore）。
**INDEPENDENT_REVIEW_COMPLETE / PARTIAL / NOT_ACCEPTED / RTC_MEDIA_HARD_GATES_OPEN / SOURCE_UNCHANGED / OWNER_DECISION_REQUIRED / NO_AUTOMATIC_R2 / NO_PRODUCT_MAIN_INTEGRATION**。

本报告是Astra独立复核GitHub固定对象、源码来源、正式交付文本和匿名脱敏审阅材料后的裁决，不是Codex自评，亦不构成Astra直接本地设备实测。冻结AC-10.1.5-05和所有已接受版本证据不变。

## 1. GitHub独立对象核验

- 本轮审阅前live main：`4080742585bfdc5a7f376ba7106ede5d05be3b04`，为此前签发任务及状态文档，不含v10.1.5产品源码。
- 所依据任务`docs/versions/v10.1.5/OWNER_APPROVED_RTC_ENV_GATE_TASK_20261022.md`，Git Blob `4839dc276921f36a8fbe3076b9c285fbea36811c`；v10.1.5冻结计划Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；R1独立复审Blob `ff9916e0b227dc0996165b2b6d5024b6199ead17`。
- R1固定产品源`1c5cd2bb7919c435e8486a76959db75e9ccc367f`，Root Tree`165eb1f362db533ca94bfe1db677ff6f7bd477ed`，完整apps`0784c8aa7b0915a04b83693a45401197e31d93a2`、services`1e1e20bb3500bedb1a521e5f2ddeece915d09424`；本RTC专项未改变源代码。
- 本次候选文档交付commit`7a5dc0d85ef82fdfc5db4a098ae4150164e2b999`、Tree`129c35a9163f68991dcc7e862e027f571438b13a`，唯一父提交`6da9a05156fda8b603224fd10e04ac1cc997ad79`；对父提交ahead1/behind0，唯一变更为`docs/versions/v10.1.5/RTC_ENV_GATE_EXECUTION_REPORT.md`及`rtc_env_gate_manifest.json`两个新增文档。自R1源到本次交付ahead2，仅原R1后附报告/manifest及本轮两份文档变动；无本轮产品源码提交。
- 报告Git Blob `e4b341352c8cbd594a690532d02e8c9a6741db48`、manifest Git Blob`fca9f59949aa4a50f1c2a830934d5aef7cb3968b`已直接读取。
- 单独审阅分支Commit`55c1c30df95918abb8b2e5fcafbafe882a3f9d78`、Root`d68bac49afa06ca3ffe776df36109a4075e06449`；其`docs/_temporary_review/v1015-rtc-env-gate-20261022/`内6/6份列名证据Path/Mode/Blob经Git Tree直接核对全部匹配；定点读取的environment-findings、gates-source-protection、non-author-review及README Git Blob亦一致。受保护数据、原始运行stdout、视频/音频、私有SQL、APK均LOCAL_ONLY，不能将GitHub文档相等解释为Astra亲自复测硬件。

## 2. 环境诊断中可支持的事实

**authority链**：首次SFU启动时bridge向guard读取超时，回执为`TimeoutError`，观察elapsed 1531ms、无成功HTTP状态；随后`authority_sweep / safe_reason=authority denied`并触发`sfu_fail_closed`。这证实在本次测试观察到的**超时与安全关闭路径**，不证实RTC令牌授予、流动媒体或冷启动延迟的底层唯一原因。未延长原1.5秒bridge timeout、2.5秒入口freshness、3.5秒watchdog或更改安全拒绝行为。

两次受限guard readiness HTTP200（109ms、32ms）后，同一SFU容器取得43个空闲健康样本、跨度约216.30秒、最大所记录sweep约91.601ms；raw SFU host不可直达、无JWT gateway GET403。**仅IDLE_CONTROL_CHAIN_SUPPORTED**，并非旧有效RTC JWT拒绝试验。

**Emulator音频路径**：原先两端非音频gRPC getStatus均booted=true；仅对A进行20包共预期0.4秒440Hz PCM的单次`injectAudio`时返回`DEADLINE_EXCEEDED`、exit1。之后A的ADB身份查询超时，另一次直接getStatus RPC也超过3秒；B继续booted=true。没有本次真实RTC call或双端传输，不能用PCM生成冒充注入/接收成功；也不能将A的控制调用阻塞叙述成已证实的进程崩溃，更不能直接判断产品RTC代码有BUG。原`injection_end_epoch`包含随后健康检查，不能计算为纯注入RPC耗时。

**关键配置相容性线索**：本轮使用模拟器参数`-no-audio`，本地Emulator帮助确认此选项禁用所有音频支持。该配置与希望通过Controller注入PCM验证音频能力存在明显冲突，足以成为下一次受控环境验证必须先解决的前提，但并**未**证明这一选项就是控制RPC阻塞的全部底层根因；也没有已核验的不访问宿主音频设备而启用所需音频引擎的替代配置。不应擅自换真实宿主麦克风/摄像头/音频backend或下载安装SDK来尝试。

## 3. 四个冻结媒体安全硬门裁决

| 硬门 | Astra裁决 | 解释 |
|---|---|---|
| DUAL_APP_SFU_FLOWING_AUDIO | `ENV_BLOCKED / NOT_ACCEPTED` | 合成PCM前置失败，未发起新call；无双方真实publish/receive媒体 |
| SAME_CALL_RECONNECT | `NOT_RUN` | 不存在已流动媒体通话，无法判断重连 |
| OLD_RTC_JWT_DENIAL | `NOT_RUN` | 无带真实旧JWT尝试的首入/重入；无JWT403不等于此项通过 |
| FLOWING_MEDIA_STOP_LE_5S | `NOT_RUN` | 无实际流动媒体、撤权COMMIT及停止时间配对，不能证明≤5s |

`AEC_HUMAN_HEARING_NOT_RUN / VIDEO_CAMERA_NOT_RUN`继续保留。非作者静态复核未发现此次环境副本新增高置信权限松动或敏感数据外泄；它不代替媒体实际运行。

前轮已限定接受的Android期限测试注入34/34、受控密文到期清理、丢消息响应同键重试、媒体Range与切号/旧Safety通知负例均保留，不因本轮ENV_BLOCKED倒退；前轮综合消息WS脚本exit1、真实Push PROVIDER_PENDING和v10.1.0历史PARTIAL继续分层保留。

Codex报告5个受保护根、653个具名旧证据哈希、原refs及私密env未变，数据库SQL除了dump时间注释无数据差异；本次专属SFU/API/guard/bridge/AVD/DB资源已停止、旧volume/SQL/APK留存。保护与物理停止属于`CODEX_REPORTED_LOCAL_ONLY`；Astra无本地全面实核权限。

## 4. 正式处置与Owner下一门

**最终独立裁决：`V10.1.5_RTC_ENV_INDEPENDENT_REVIEW_COMPLETE / PARTIAL / NOT_ACCEPTED / RTC_ENV_PRECONDITION_UNMET / OWNER_DECISION_REQUIRED`。** 本次专项目标不是修复产品程序而是查清为何无法建立媒体验证环境；诊断有进展，尚未有证据证明四条RTC门通过或产品缺陷，故不授权功能接受或产品main集成。

**不自动再次派RCT/R2重试，不自动采购或改SDK/宿主设备，也不追改既有冻结AC。** 建议Owner优先明确版本治理取舍：

- **路径A（建议默认）**：将v10.1.5产品候选与当前`PARTIAL/NOT_ACCEPTED`正式封存为受控可复用成果；将RTC的可验证合成音频环境视为独立前置门禁。需要先核出与当前Controller兼容、确实保留音频引擎且不会使用宿主真实音频的安全配置；没有这种配置就不再循环模拟器任务。Owner以后对具体环境变更作单项授权后再测四条媒体硬门。
- **路径B（Owner另行授权才可）**：另冻“可交付非RTC能力/RTC限用”的产品范围变更和具体风险控制，再讨论仅安全子集何时能进入main，避免整版因外部模拟器环境无限停顿；必须完整校验既有RTC入口不被误开放，且重新进行独立功能与单次安全集成验收。**选择B不等于原v10.1.5已被接受或可直接合main**。当前未获Owner该项权限。
- 现有实验尚不证明更新SDK、使用真机/宿主麦克风、开放UDP、改防火墙会解决问题；这些需要精确新许可，不是本轮隐含权限。

在Owner进一步决定前：冻结状态`V10.1.5_PARTIAL_NOT_ACCEPTED / RTC_MEDIA_UNVERIFIED / MAIN_PRODUCT_UNCHANGED / V10.1.6_NOT_STARTED`。GitHub原候选及全部历史候选/审核/备份保留，拒绝以环境阻断偷换成系统RTC安全PASS。
