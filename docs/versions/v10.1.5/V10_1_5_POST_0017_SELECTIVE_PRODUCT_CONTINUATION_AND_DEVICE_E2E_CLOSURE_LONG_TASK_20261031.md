# EliteSync v10.1.5｜0017ce7有界接受之后：选择性产品接续、APP/WS/媒体贯通与剩余验收集中收口｜Owner综合长任务

签发：2026-10-31（Asia/Singapore）。
**状态：OWNER_APPROVED_CONTINUE_V1015 / TASK_PUBLISHED_OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NOT_EXECUTED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_FALSE / REAL_PUSH_PROVIDER_PENDING / V10.1.6_NOT_STARTED。**

## 0. 权限语义与真实目标

Owner在2026-10-31看到Astra对`0017ce7`的F1/F3/F4有界验收及“下一步集中APP设备和集成验收”的建议后，明确答复“可以，看起来开发环境搞定了，v10.1.5也彻底结束。我授权继续”。**本次授权按上下文限定为继续完成v10.1.5剩余软件/设备验证和一个集中研发候选**，不把Owner对进度的乐观判断解释成授权更改冻结AC、宣布整版接受、自动进入v10.1.6、合并main、放行G2、使用任意设备/系统权限、清理旧备份或接入真实供应商。

本长任务的成功工作目标不是继续研究Laravel环境：在已接受Laravel13/PHP8.4干净开发入口上，从Astra有界接受的`0017ce7`源码逐项接续真实F1/F3/F4产品，完成同一候选Flutter APP→HTTP/具名WS（若合法可用）→Laravel13 API→新独立MariaDB→重启/再读，以及必要的Web使用点、Android真实私有存储/OS通知和合成H264等**已获准且实际可执行**的正反例；同时对AC05 RTC/AEC、撤权后5秒停媒的可测条件作定点审查与在原有许可内的有界验证。普通源码/测试错误同任务内修复，一次候选交付、Astra独立验收。

**执行优先级：①精确接续已验软件源码且保护L13/既有v10.1.4；②APP真实源构建资格和可运行设备端到端；③WS/Android密文/OS通知/H264缺口；④AC05具名质量和安全证据；⑤只对本轮变化所需定向回归。** 单一设备/供应条件不成立只阻断对应分项，不能让已经可实施的软件源交付退化为又一次纯环境任务。

## 1. 开工 authority 和固定证据，精确对象不可混写

- 权威仓库：`zcx369658780/EliteSync-v10`。开工先fresh读取live `main`/Root、`docs/workflow/ACTIVE_STATE.md`、`CURRENT_WORKFLOW.md`、`TASK_DISPATCH_CLOSURE_PROTOCOL.md`和本任务全文/Blob，观察全部既有STOP/原dirty归属。编制前main `8fb1ff72c9b4d9daf8976d828ac14e8977bc7622`、Root `96c789d82a96a51799ed25b194f4a8d5129e5fb2`；**这是签发前快照，创建文档和同步状态会推进main，Codex使用实际开工fresh main作唯一研发Parent**，不能reset回旧SHA。编制前apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `049a8676cc90b3b830e32a524c172720e800fa37`；开工重验。
- 不可修改的冻结功能合同：`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`，AC01–AC11、F1–F5及原Owner同意、隐私、CN/MC、Block、实名TEST_ONLY边界均保持。
- 本轮接受**软件来源**是候选 `0017ce7aa6b991360b2b26b7f5785b86bce2f369`，sole Parent `a71c1429a0bfaf9ed2fd379eb2944907dd057b7b`，Root `778437c50759cb5f057618ee95db78af981e4c89`；其apps `2c72ceb889d95766a05c77047592f5886739d1c2`、services `5033dd8e45979d3b01b904f0ea5951ed3f95d3df`。正式Result `V1015_POST_L13_F1_F3_F4_PRODUCT_CONTINUATION_RESULT_20261031.md` Blob `8cd6affe37d2ec16ae08610a316df3145f7d7542`，Manifest `v1015_post_l13_f1_f3_f4_artifact_manifest_20261031.json` Blob `ca56fd86a7ddc0a88aa5d259748c13f74a83b6ce`。其中`source_mapping`精确列71条产品/测试 path/mode/Blob/size；**仅这71条是已有有界接受的软件源码输入**，不是整个候选分支/报告/旧历史全部业务自动获准。相对main差异要实际核验，不盲合完整Tree。
- Astra独立Review Commit `b5e2c9754aa2710d2d40eea22ba8d9a6b2960d4e`，Review Blob `5679481e0b7ffd5259fae0efdbfe0c8b8fb54e10`，固定报告 `docs/versions/v10.1.5/0017CE7_F1_F3_F4_POST_L13_ASTRA_INDEPENDENT_BOUNDED_REVIEW_20261031.md`；**Review Commit不是新任务Parent**。它接受本轮有界源码/API/DB/Web/Flutter软件证据，保留APP/Android/WS/H264、PREPARE及AC05等缺口。
- 已限定接受的新L13干净本地入口：`08747eeec778340a82bf3c11a3f4181847dd037a`的独立审查文件Blob `afa9cbac11484bdff53171e96774f80072e12462`；旧L11默认根继续保留。禁止为了本任务重新迁移框架、装114包、重做此前问卷2项复测或旧90表83行重启任务；原`270 Flutter/128 PHP`通过也不能冒充最终新候选运行。

## 2. 一份综合长任务中的自主实施

### A｜选择性源码接续与PREPARE fail-closed修正

- 在**全新独立干净工作树/任务根**以fresh main为基底，使用Manifest 71项的原生Git Blob/mode/来源与current main进行逐路径验证，仅精确迁入已限定接受的F1/F3/F4业务/测试代码；旧未接受分支、Review报告、task-only验证器、LOCAL_ONLY、私人配置不可自动混入。遇与main兼容性冲突，限于本版依赖以实际源码修复，并保留原证与新修复列表。不得触碰历史dirty工作根做pull/reset/stash/clean/rebase/prune/force。
- 本次新的task-owned执行器/日志层须先修正前次`incoming/source.json`写前logger TypeError导致的**PREPARE记录缺口**：在新任务任何写入/进程启动之前执行受控的PREPARE→flush/fsync→真实操作→exit/Hash receipt闭环，logger失败即STOP对应写入；旧缺口不可追溯伪造PASS，也不能修改旧STOP账本。新的执行入口可在task私有目录实现最小安全修正，公共仓只交付必要非敏感修复/回执。
- 在不修改已接受隐私/真实性判断前提下，解决本候选与现行L13 session/time、消息幂等、通知替身、媒体权限及Flutter客户端的真正版本差异。定点排查此前`flutter analyze exit1 / 0 errors / 0 warnings / 8 info`（可能为已存在的info）；保留原退出码，不通过改测试、忽略分析或新增suppress伪造分析PASS。

### B｜从软件源码走到真实APP设备/API/DB（条件许可，优先实物）

- 以任务自有合成账号、**新独立、事前确认空且已保存恢复点的MariaDB测试库/卷**、已有可信L13私有API及已有已核Flutter/Android工具链运行。任何迁移、seed、重启前资格化有效`APP_DB_CONNECTION`优先于`DB_CONNECTION`、host/port/socket/schema/user/GRANT/volumes/端口归属，禁止3306/旧事故库/生产/云、旧已STOP合成库写入。只使用127.0.0.1私有开发端口，不能打开LAN/公网。
- **若Gradle/G2和Android/AVD资格真正成立**，基于本任务最终源码实际构建debug APK（可核packageId/version/signature/source commit）、受控安装至当前已批准且明确属于本任务的开发AVD/设备；用A/B/C合成账号在设备端真实登录、消息幂等重试/断线、图片picker/私有媒体、CN/MC/Block、切号/旧响应、通知拒绝/权限、UI错误恢复，逐项做APP操作→实际API→MariaDB→重启/读回→授权反例。留最小截取的测试轨迹、APK source/build/hash、Android系统权限状态，真实密文原始字节/设备日志/密钥仍LOCAL_ONLY。
- **当前G2为false，且上一轮APP/AVD/Gradle资格未成立**。本次“继续”不自动放行旧G2、未获准的Gradle Producer、SDK/共享缓存写入、系统级权限、更换真实设备、USB/ADB安全策略或新增下载。只有经原生资格核验已获Owner批准的受控工具/设备才能真正Popen/build/install；如果资格不成立，**不能用已存在的旧APK冒充这次新源码APK**，把APP/设备项记`NOT_RUN_GATE_CLOSED`，保留可审新源码及独立API/DB测试结果和最小下一门资格说明，不再次分拆多份只读环境审计。
- 新增原生Android存储实测须从当前源码验证`flutter_secure_storage`实际插件安全落盘、冷启动锁定、未核验状态不显示缓存、受控测试密文按15/30天注入/清理失败与账号切换；只有授权测试namespace，绝不读取或删除旧私有记录。允许时间注入证明逻辑，物理实际经过15/30日只能记NOT_RUN；不声称远端撤权可即时穿透断网设备。系统通知仅真实观察OS权限/最小内容交互；没有批准的Push供应商仍`PENDING`，不发送真实Push。

### C｜WebSocket、合成H264与Web管理使用点（各门相互独立）

- WS真正E2E仅在已有可信PHP/Workerman/pcntl或明确已接受的等价运行途径具备且不需新外部供应/系统改动时执行：验证有效MC+CN旧/新授权、token轮换、断线重连、Block、旧WS连接定期重鉴权及旧缓存不会越权重显。上轮缺可信镜像pcntl，不能借改系统/随机拷贝DLL/降权临时绕过；确实无合法环境则保持`WS_NOT_RUN`并保留源码静态和已有软件结果。
- H264/视频用本任务已有合法来源或已获准现有编码器从纯合成素材产生可验证的短视频与Hash，先检查来源/编码能力/资源许可；无有效素材和环境就`H264_NOT_RUN`，不可从PNG或不符合容器字节假造通过。私有200/206、失败不冒READY、旧URL与撤权使用点仅对本轮真实触及面验证，不重新重建RTC或运行全部旧媒体oracle。
- Web只测试已存在独立管理面板的真实authorized operator和普通用户拒绝/最小数据，不新增APP管理入口、不让管理员任意看私聊，必要时真实浏览器UI而不是仅用HTTP替代。

### D｜AC05 RTC/AEC 具名门的有限收口尝试

- 先针对已有`REMAINING_ACCEPTANCE_7773B989_ASTRA_REVIEW_20261025.md`、真机call4/call5、PCM/Room清理和旧token首次WebSocket403的已接受范围做**一次定点来源及可用资源核查**；不能推翻既有有界结果，不无限重新审历史；这次产品代码受影响的CN/MC/token/RTC调用权限做有限回归。
- 真正声学AEC、人耳音质、双端流动媒体、撤权COMMIT起到≤5秒可观察停媒、旧token reentry及native清理失败路径只有在**已批准**设备/麦克风/摄像头/SFU/网络条件均成立且能同步时间基准时才运行，并逐场景记原始观测上界/退出码。历史合成PC对端/单手机与过往10.125秒保守观察不能提升成双真机/5秒/声学PASS。未经另外具名授权，不能使用新物理手机、系统驱动、麦克风/摄像头、USB权限、UDP/防火墙、未核SDK或G2预算。
- 若该条件无法成立，严格保持`AC05_OPEN / G2_FALSE`，给出唯一紧凑的下一门所需资源、权限与能否条件分离的事实；**不以降低冻结AC或声称v10.1.5彻底完成来结束**。

## 3. 运行预算、保护、允许自主修复与真正STOP

- 新task_id：`V1015_POST_0017_DEVICE_E2E_FINAL_CLOSURE_20261031`。**唯一新task-owned工作根、attempt-0001、单一持久ledger**；所有真实运行/失败/重试前记PREPARE并落盘。旧G2false、旧停止的所有task账本与剩余额度不可复用或重置。Owner本次没有批准新的具体数值化硬次数/时长/空间上限，不臆造“已获”硬预算；执行时先核任务可用空间/端口/进程/私有源，持续记录新任务资源，普通缺陷在一个集中执行范围内做合理有限重试，资源/资格不足立即停止该受限项。**新增外部下载、SDK/Gradle补供应、Composer install、Docker pull/build、真实付费或OS改动额度为0**，已有可信运行资源只在证明可用且此前未保留单次硬禁止时使用。
- 原`D:/EliteSync-v10` dirty252/refs527/旧Laravel11.48、`D:/EliteSync`、11,066件/240,617,393bytes原备份（Manifest SHA256 `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`）、所有historical STOP/事故/2ACL/旧原证/LOCAL_ONLY/私密数据库和现有云端运行保持受保护。按本轮实际触及范围做启动与STOP后身份校验；不将Astra远端审查冒充本机保护证明、不为了构建腾空间清理旧根。
- 不改生产、真实用户数据、外部云/备案、公网、付费、真实实名认证/Push、第三方API、系统全局权限/Firewall、供应商密钥；不得把JWT、密文、真实个人资料、SQL/设备原始日志/绝对机器路径推到公开GitHub或项目源。记录原`WINDOWS_E_NOTIMPL`、跨attempt预算问题、`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`、`RESTRICTED_IDENTITY_GATE_BLOCKED`、`OS_ENFORCEMENT_NOT_PROVEN`、早期只读回执问题，均不因本轮正常测试自动清零。
- 允许在以上限定环境中自主修复本版APP/API/测试/受控harness的真实缺陷，不把正常测试失败拆为微任务，也不得修改断言制造绿灯。被实际策略拒绝时记录失败并fail-closed，不改策略、不通过未授权替代执行路径绕过。PREPARE/资格/保护/设备风险必须成为对应分项STOP；其他合法功能继续。
- 与先前冻结验收一致，**源码审查、功能限定接受、main代码集成、本地APP运行、真实供应商及公开运营是分别记录的事实**。若功能证据缺失，最终状态只能PARTIAL或CHANGES_REQUIRED；不得因用户“彻底结束”的表述把v10.1.5整版或AC05倒签PASS。

## 4. 一次集中交付与AC01–11逐项审阅

- 交付新具名Result `docs/versions/v10.1.5/V1015_POST_0017_DEVICE_E2E_CLOSURE_RESULT_20261031.md`，新Manifest `docs/versions/v10.1.5/v1015_post_0017_device_e2e_closure_manifest_20261031.json`，必要源码、合成测试、同源E2E harness及最小脱敏证据。**不得覆盖**原Result/Manifest/失败/原验收；有新真实软件缺陷就修源码，若无法运行设备仍要交付精确接续且可审的产品候选/阻断清单，而非只交又一份环境规划。非作者有界审查优先关注新权限写入口、并发MariaDB RR、跨账号晚响应、加密失败与通知/RTC撤权。
- AC01 权威源码/独立合成库与受保护原证；AC02 客户端消息实机/API/持久幂等；AC03 CN/MC/Block、切号、旧token/WS/迟到数据；AC04 Android picker/合成PNG/H264媒体/授权Range与失败；AC05 **RTC/AEC/5秒停媒独立门**；AC06 服务端T0和测试注入，物理15/30天另记；AC07 原生Android加密落盘、冷启与实际测试密文删除；AC08 OS通知权限、站内偏好与当前read；AC09 test_only provider且真实Push PENDING；AC10 同一候选APK→API→MariaDB→既有Web用户/管理员→重启读回；AC11 固定源码对象/Manifest/退出码/脱敏验收记录。每项按`DIRECT_GITHUB_OBJECT / CODEX_REPORTED_LOCAL_RUNTIME / DEVICE_REAL / TEST_INJECTION / LOCAL_ONLY_RAW / NOT_RUN / NOT_PROVEN`列证据和反例，不拼原版本测试数。
- Codex以开工fresh main为sole Parent做**唯一非强制研发候选**，可先源码提交后集中Result/Manifest文档提交，维持清楚的父子链并核全部path/mode/Blob、完整apps/services Tree、Github main仍未变；review临时分支须遵守既有脱敏协议。**不能自行将候选合main，不能自写`FUNCTION_ACCEPTED`或`INTEGRATION_ACCEPTED`，不能将Astra的Review Commit当研发Parent。**
- 完成后STOP、保存任务自有资源身份/终态且停止由本任务启动的服务（仅保留允许的合成卷与源文件），绝不删除旧原证/重启旧任务；单次交付结果、精确缺口和若仍需Owner特殊设备/供应商/G2授权的最小说明，等待Astra独立验收。不自动派发新任务、不改变默认Laravel11入口、不启动v10.1.6。
- 本次授权上限结果可为`V10.1.5_POST_0017_DEVICE_AND_SOFTWARE_CANDIDATE_DELIVERED_AWAITING_ASTRA`或`PARTIAL_DELIVERY_WITH_EXPLICIT_DEVICE_GATES`。**直到AC05及整版冻结条件实际通过并独立签字，当前状态一律`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_FALSE / REAL_PUSH_PROVIDER_PENDING`。**
