# EliteSync v10.1.5｜最后一轮设备与RTC验收门：WebSocket生命周期、视频验证、Android安全与AC05集中收口｜Owner正式综合长任务

签发日期：2026-10-31（Asia/Singapore）。
状态：**OWNER_APPROVED_TASK_PUBLICATION / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NOT_EXECUTED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / V10.1.6_NOT_STARTED**。

## 0. 授权、真实目标与最终结果上限

Owner在阅读Astra对`b441d180`的正式有界审查及“下一步直接制定v10.1.5最终设备与RTC专项收口任务”建议后明确答复“我同意，请继续”。本次授权**仅允许Astra按A-D协议发布本综合开发/验证任务，Owner随后手动交给本地Codex执行**；不代表Owner已批准G2放行、Gradle/SDK Producer、真机USB/麦克风/摄像头/网络权限、新软件供应、真实Push服务商、费用、删旧资产、切换默认环境、产品main集成或自动启动v10.1.6。

任务目标：**停止重复已接受的Laravel13环境搭建与普通API/DB回归**，在一次集中候选中修复与冻结AC直接相关的当前确定源码缺口，准备和执行**实际上已有合规设备/工具资格**的APP/Android/视频/WS/RTC验证；提供不能执行部分的精确失败门、最小必要外部授权条目。没有证据的门保持NOT_RUN/OPEN，不能为了“最终”字样自动把整版判为PASS。

两条独立出口：①修复真实软件缺陷后交付可审非main候选；②由实际合格设备/SDK/媒体运行获得新的场景证据（若具名资格不成立则保留明确未运行，不把任务整体变成又一次长环境取证）。两者均停在Astra独立验收，不允许Codex自签整版接受。

## 1. 开工证据绑定和唯一真实研发Parent

- Authority：`zcx369658780/EliteSync-v10`。Codex启动时先fresh读live `main`/Root、`docs/workflow/ACTIVE_STATE.md`、`CURRENT_WORKFLOW.md`、`TASK_DISPATCH_CLOSURE_PROTOCOL.md`、本任务全文及其Git Blob、`docs/versions/v10.1.5/plan.md`（冻结Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`）、Owner产品决策及本节固定验收对象。Codex唯一研发Parent必须是开工fresh main，**绝不使用历史候选/Review分支作为Parent**。本文签发前main `12c20cee72ea1af40349da73bd6e6e9db0787fbe`，Root `2bb38dd99069ba0018a61a135db237c4af19dc44`；因本任务和ACTIVE_STATE均将产生docs提交，此SHA不是开工固定Parent。当前main apps/services Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `049a8676cc90b3b830e32a524c172720e800fa37`，开工fresh核实。
- 最近一次软件候选 `b441d1808bb366dbffebbecc03180b7bedd197f7`、Root `11b73b2d3bca69d5212dc11fb7a4f109ca126c35`、apps `92c7caea1ed2d22b3998e79c120d4b31c9572bdf`、services `ca42f315edb27a8993b3591f51991185d1ed3026`；它是**需要按路径选择性接续的接受输入，不是新研发Parent**。
- Astra正式有界Review Commit `923d248385c46d7bcecc1b29dced6f307b1dcb87`、Review Blob `fe1d22b21fddfd7ec5a0bf427faddd7d219be0df`，路径 `docs/versions/v10.1.5/B441D180_POST_0017_ASTRA_INDEPENDENT_BOUNDED_ACCEPTANCE_20261031.md`；该裁决为`V10.1.5_POST_0017_BOUNDED_ACCEPTED_WITH_OBSERVATIONS`，非整版验收。
- b441正式Result：`V1015_POST_0017_DEVICE_E2E_CLOSURE_RESULT_20261031.md` Blob `3587cebce51083cda837f036a241c8d30c3cf92d`；Manifest：`v1015_post_0017_device_e2e_closure_manifest_20261031.json` Blob `f8df511f0f99ca223ccda0ee17ae3fb4589b8fd1`。其`source_mapping`中**84项源码/测试**完整path/mode/Blob/bytes已经Astra独立核实：71项承袭已接受0017、5项lint修正、8项合成E2E harness。此84项为已有限接受的输入，不将2份历史Result/Manifest、非接受实验或整个Review Tree盲合。
- 已有软件实测只引用对应旧身份：Flutter analyzer exit0、Flutter 68项、PHP32/240、API120检查、Web HTTP8、MariaDB93表163行重启哈希、9项PREPARE故障负例。这些是过去`CODEX_REPORTED_LOCAL_RUNTIME`并由Astra有界接受的结果，不冒充新候选已重跑，也不补写旧PREPARE缺口。
- 冻结AC01–11不改。当前v10.1.5仍`10 PARTIAL/1 OPEN`，AC05 RTC/AEC/5秒停媒OPEN、G2 false、真实Push供应商PENDING；v10.1.6未启动。

## 2. 本次综合实施任务

### W1｜选择性接续+WebSocket确定源码缺口修复（必须执行普通开发）

1. 在**全新task-owned干净Git工作面**以fresh main为基准，逐项核对b441 Manifest中的84项所需路径和原生Blob/mode，按现行Laravel13+Flutter源码进行选择性接续；不合整棵历史候选，不携入私有runner/vendor/缓存/旧Result，绝不修改旧dirty工作树。普通冲突集中修复，保留每个新差异的来源和单次可复核测试。
2. `ChatSocketDataSource`须对有效session identity/账号/授权epoch变化实行主动断连：正在connecting、已connected、等待重连和监听终止均须绑定代际及订阅取消；`LiveChatPage`的session/授权变化须同步cancel旧订阅，跨账号晚事件不得触发读回、旧重连不得持有旧token、服务端当前权限为最终事实。防止无限重连/内存资源泄漏、logout后旧连接继续长期存活；确保合法仍有权账号能够正常连接与收消息，不能靠完全禁用WS来报安全PASS。
3. `AppEnv.wsBaseUrl`通过现有受控开发/宿主bootstrap安全接线，明确dev/prod与本地socket入口、端口及ws/wss的合理继承；无可信配置时采用可说明的受控fail-closed或既有明确回退策略，不硬编码无意公网目标。旧入口/生产非授权环境不应因新增字段意外绕过TLS或将Bearer发到陌生地址。
4. 用新增针对性Dart Widget/服务测试覆盖：切号时主动close（不仅frame丢弃）、连接中切号取消、撤权/epoch变化、前后台恢复、异常回调、token刷新不跨代际、正确WS URI、WSS、旧订阅disposed和合法连接正向例。后端WebSocket授权和token/MC/CN/Block/epoch使用点定向负例；若缺pcntl无法启动，记`WS_REAL_RUNTIME_NOT_RUN`，不得从静态/模拟接收推断真实服务器通过。

### W2｜视频验证器与真实H264 API产品链（条件可执行）

1. b441已通过合成H264素材生成/完整10帧解码（SHA256 `a220520c0fbf9aa620cf6a718966f7743ed580b1b8d0d5ced4eb55b23ca23ec9`），实际Laravel媒体API因**无可信ffprobe返回422且未建资产**。不要重复无限次生成素材或将422伪报PASS。
2. 优先只读核对当前已合法持有的ffprobe/已批准视频检测组件，版本/来源/哈希/许可、平台ABI、进程与路径写面，并验证它与真实API的既有检测合同完全相符。**仅当现存可信输入及执行权限完整成立**，允许隔离私有copy（不碰系统PATH/全局安装）在本任务新库运行真实上传→检测READY→消息附件→200/206→重启持久读回→第三方和Block/MC撤权后404、失败素材不得READY。若缺可信组件：`VIDEO_API_VERIFIER_GATE_CLOSED`，提交具体所需来源与最小Owner许可，不下载、不替换陌生二进制、不弱化验证器或直接写DB READY。

### W3｜Android设备、系统权限与G2（严格分层门）

1. **G2_READY_FOR_POPEN_FALSE是现有事实**。本次Owner“同意继续”不自动增加G2/Gradle/SDK Producer或ADB/USB权限；原有历史STOP预算不能复用。Codex先基于已批准源码和当前设备/AVD/SDK所有者的只读资格检查说明确切状态，禁止未经本任务具名许可启动Gradle/Wrapper、生产者、SDK写入或借旧APK冒充本任务新候选。
2. 只有当**可核的既有Owner授权**已经覆盖指定设备/工具/命令/缓存/权限且新的G2资格独立PASS时，才允许同一候选真正debug构建、hash和签名核对、隔离applicationId、安装/运行获准AVD/设备。**本任务本身不构成这样的追加许可**。若G2 false或权限不全，记`APP_DEVICE_E2E_NOT_RUN_GATE_CLOSED`，继续提交W1普通源码和合法W2成果，禁止再造连续环境微任务。
3. 获许可后才可执行同源APP→真实API→新MariaDB→重启读回：两个虚构账号正常消息/丢ACK重试/切号/晚响应/Block/MC/CN，图片/短视频、OS通知权限拒绝/撤销/通用锁屏内容及点击current-read；Android `flutter_secure_storage`真实落盘密文、冷启锁定、跨账号隔离、受控15/30天测试时钟、删测试密文成功与失败。测试只用新appId/测试namespace，不查看/删除旧手机用户资料。受控时间注入≠物理经过30天，断网远端撤权不可称即时传播。
4. 真实Push供应商从未获准：只保留测试替身，`REAL_PUSH_PROVIDER_PENDING / DELIVERY_NOT_VERIFIED`。本轮无真实供应商SDK、凭据、费用、推送外传。

### W4｜RTC AC05 专项可测条件与实际媒体证据（不改变冻结门）

1. 沿用2026-10-25 `REMAINING_ACCEPTANCE_7773B989_ASTRA_REVIEW_20261025.md` Blob `5e5851cc54185d488490706e99deaed57cb67802` 所有有界结论：call4同call重连/UI挂断、call5后续媒体、旧token首次重入403，以及PCM/Room清理；历史10.125秒保守观察**不是**≤5秒停媒证明，合成PC音频并非真实AEC实测。
2. 一次核实名单：可用已批准设备/AVD及其麦克风摄像头权限、合成或实物对端、SFU/guard、时钟同步和可见最后有效RTP/波形；识别尚缺的不可替代条件。只有全部存在**可追溯现行Owner权限**才实际运行相应场景。授权不覆盖真机麦克风/摄像头/UDP/防火墙/新驱动/系统策略时全部继续NOT_RUN，不以“用于测试”代替许可。
3. 若条件满足，至少逐场景测试合法voice/video流动、拒绝/挂断/前后台/同call重连、旧JWT撤权后重入拒绝、撤权COMMIT→最后可观察媒体停止的同一可信时间基准上界≤5秒、AEC on/off可测对照及native stop失败清理并保留退出码。分别裁决，不拼call3失败与call4/call5的成功组成假单次全PASS，不将源代码guard PASS当物理停媒PASS。
4. **无完整证据则AC05 OPEN**，G2仍false。只报告一次具名最小授权/资源包，不再对已经接受的RTC来源重复无限考古。任何降低5秒安全目标或移出RTC范围的产品策略由Owner另作不可逆决策，本任务不得暗改。

### W5｜综合限定E2E与交付

- 在已合法具备的本地合成API/新独立MariaDB及只读Web使用点上，针对本轮变更补齐最小回归；不重复整批旧270/128/120或重新跑Laravel13/114包安装。Web浏览器原先OS error3，若原有受控浏览器入口实际恢复并有权限，仅一次具名视觉验证；否则`BROWSER_UI_NOT_RUN`并保留真实Web HTTP证据，不改系统以求打开。
- 独立非作者只读复核重点：WS主动关闭与授权、wsBaseUrl的host/TLS安全、视频验证器不可绕过、Android密文/测试注入边界和RTC最后媒体停止时间线。
- 所有修改/验证与冻结AC01–11逐行对应，明确区分`SOURCE_VERIFIED`、`CODEX_REPORTED_LOCAL_RUNTIME`、`DEVICE_REAL`、`TEST_INJECTION`、`NOT_RUN_GATE_CLOSED`和`NOT_PROVEN`，有失败就保留。**禁止因本轮名字“最终收口”而自行签FUNCTION_ACCEPTED、声称G2 true或关闭AC05**。

## 3. 单一预算、保护原证、允许范围和停止条件

- 新task_id：`V1015_FINAL_DEVICE_RTC_WS_H264_GATE_20261031`。**仅一个新task-owned执行根+attempt-0001+持久独立ledger**，开工明确程序PREPARE→flush/fsync→操作→exit/Hash、失败即fail-closed。旧b441、0017和全部更早STOP不可追补或重开；旧PREPARE历史缺口只保留观察。
- **本综合任务新预算上界（仅获准操作实际可消耗；并非G2或设备权限）：** 新task执行窗口≤90分钟，任务新增工作面logical与allocated各≤8GiB；实际独立MariaDB进程启动≤2、受控API进程启动≤2、合成DB迁移≤1、seed事务≤1、数据库真实重启≤1、loopback HTTP总操作≤100、Flutter定向test/analyze≤4批、PHP定向test≤3批、WS受控服务真正启动≤1、WS正反旅程≤1批、合成H264真实API验证≤1批、获准浏览器GUI≤1批。计数包含失败、crash和无响应；历史任务余额不抵扣本次新预算，未用额度不跨任务继承。**Gradle/G2/ADB/真机/新USB/音视频采集/外部下载默认运行预算=0**；仅当明确历史或新Owner**具名许可**真实覆盖时，本任务才可按获准次数执行，绝不由本次task文本凭空转换成授权。普通源码修改、必要只读Git验证和非作者审查在同任务范围内集中完成，不因故障另建新的任务根。
- 受保护：原`D:/EliteSync-v10` dirty252/refs527/index/HEAD、原`D:/EliteSync`、Laravel11.48默认入口、11,066件/240,617,393字节原备份（Manifest SHA256 `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`）、旧MariaDB/事故恢复卷、122原证/3183 Seed/历史STOP/两ACL及所有历史设备APK/密钥/日志。只对本轮实际涉及的已获准范围做足够前后Hash与身份核验，不虚称全盘重扫。任何不可逆变动、旧保护资产写入或未授权凭据接触即STOP风险分项并保存原证。
- 新测试数据库必须具本任务独立空库/卷、schema/actor/server_id和最小GRANT，先保存新恢复点，核`APP_DB_CONNECTION`优先于`DB_CONNECTION`及URL/socket/端口/host；**禁止旧/3306/事故/生产数据库**。仅对新任务合成数据迁移、清理；先确认有效命名与归属，不覆盖b441旧任务卷/结果。
- 外网/下载/容器pull/build/新SDK或PHP原生包/全局环境变量/ACL/UAC/防火墙/OS安全策略、第三方AI/Push/媒体、支付、实名、真实用户数据操作均为0授权，不得“先做再补批准”。调试产生的Bearer、真实SQL、原始音视频、设备序列号、私密日志、绝对系统路径一律LOCAL_ONLY_RAW，不上传GitHub或ChatGPT Project。
- 每种缺失门都只进行一次已有输入与许可的具名资格判断；若负例/环境拒绝则该分项`NOT_RUN_GATE_CLOSED`，不得绕守卫、借历史单次余额或转移未授权工具；其它允许范围继续修复/验证。若接近90分钟、8GiB或次数上限应保留已有真实成果、集中生成唯一结果并STOP，绝不重置计时换根刷次数。

## 4. 可观察验收终点与唯一候选

- 针对AC01当前树/源/保护、AC02合法消息/幂等/WS实际回放、AC03切号/旧授权/当前服务端验证、AC04私有PNG/H264与播放器、AC05 RTC物理安全门、AC06可信T0、AC07 Android密文/离线清理、AC08通知OS权限、AC09测试Push隔离、AC10同源码APK/API/DB重启/Web、AC11集中Result/Manifest和独立审阅，逐条给出**成功、失败、跳过、未授权**的证据与实际命令exit/stdout Hash；旧接受来源单列不得冒新本轮PASS。
- 交付路径：`docs/versions/v10.1.5/V1015_FINAL_DEVICE_RTC_WS_H264_GATE_RESULT_20261031.md`、`docs/versions/v10.1.5/v1015_final_device_rtc_ws_h264_gate_manifest_20261031.json`、所需本次真正修改的源码/测试/受控合成入口。不覆盖原Result/Manifest/独立审查，不向公开仓提交本地二进制/原始日志/凭据。若W2/W3/W4仍无法运行，至少交付有实质代码和定向测试支撑的W1及一次最小合并的后续授权说明，不继续拆出多个环境微任务。
- 用开工fresh main作为唯一sole Parent建立**单个非force、非main研发候选**；如先源码Commit再文档Commit，明确完整线性父子关系并按基底比较所有更改path/mode/Blob、Root、apps/services完整子Tree与main未发生产品源修改；不得把Astra Review或已STOP候选当Parent，不允许自动fast-forward main。
- 可提交的状态最多`V10.1.5_FINAL_DEVICE_RTC_GATE_CANDIDATE_DELIVERED_AWAITING_ASTRA`或`PARTIAL_WITH_EXPLICIT_G2_DEVICE_PROVIDER_GATES`。任何设备未运行、AC05未闭或关键用户流程未通过，**整版必须仍`V10.1.5_PARTIAL_NOT_ACCEPTED`**；Codex不能代Astra独立裁决。
- 交付后永久STOP，停止本任务启动的服务、保留获准新合成恢复点和旧资产；不合main、不删旧默认Laravel11、不放行G2、无新Push/费用、不启动v10.1.6。Astra再审，Owner未来另决定整版接受/后续产品集成/必要追加设备授权。
