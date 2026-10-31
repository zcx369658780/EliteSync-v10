# EliteSync v10.1.5｜Laravel 13 基线之后的 F1/F3/F4 产品接续与同源贯通｜Owner 综合长任务

**签发日期：2026-10-31（Asia/Singapore）**
**状态：OWNER_REQUESTED_TASK_PUBLICATION / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NOT_EXECUTED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_FALSE / REAL_PUSH_PROVIDER_PENDING / V10.1.6_NOT_STARTED**

## 0. 这份任务的权限、目标、终点

Owner 在2026-10-31当前会话明确要求：已接受新的 Laravel13/PHP8.4 本地开发入口后，回到 v10.1.5 冻结功能计划、核对未完事项并下达一份综合长任务。Astra获准**发布此正式任务并同步状态**；只有 Owner 随后将启动 Prompt 手动交给本地 Codex，才算派发。文档发布≠Codex执行≠服务启动≠产品接受≠main产品集成。

**任务目标：** 在当前main已经接受的Laravel13/PHP8.4框架、已限定接受的新干净本地开发入口上，一次性接续冻结v10.1.5的**F1消息可靠性、F3可信15/30天与加密离线只读、F4通知隐私和Push预留**，将旧候选中有依据的功能实现按差异选入、与当前主线整合并修复实际缺陷，尽可能在授权的合成环境完成**Flutter APP / 独立API / MariaDB持久化 / Web已有管理使用点**的同源正反贯通。F2 RTC仅做受影响权限/接口回归和证据移交，**AC05的AEC/媒体停止安全门继续OPEN**；F5仅一次有界旧源判读。完成一次集中候选交付给Astra独立验收，**不得自行写ACCEPTED、合并main或启动v10.1.6**。

不再重复Laravel11→Laravel13框架迁移、114包安装、原问卷两项定向复测、90表83行MariaDB真实进程重启、原PowerShell脚本正常启停等已有限接受工作；不为了60项完整回归/备份恢复演练的观察缺口开启一串新环境任务。若某项功能实际变化要求定向回归，执行其所需测试，不能用之前58+2拼成“本轮60/60”。

## 1. 开工必须fresh核验：authority、冻结合同与实际开发基线

1. GitHub authority：`zcx369658780/EliteSync-v10` 的实时 `main`、Root Tree、`docs/workflow/ACTIVE_STATE.md`、`CURRENT_WORKFLOW.md`、`TASK_DISPATCH_CLOSURE_PROTOCOL.md`。本任务创建前main仅为参考快照：`8c888ff0cb97545fb0f519cd4073f9a6e3839f37` / Root `268e1d8b023bfcda123a89f46b5a264b2c13aef6`；发布本任务与状态会推进main，不可重置回旧SHA。Codex开工时必须fresh获取自己的准确main Parent。
2. **不可变功能计划**：`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`，AC01—AC11与F1—F5不追改；路线 `docs/architecture/ELITESYNC_10X_POST_RESTORATION_ROADMAP_20261019_V1_0.md` §6.5仅为规划依据。Owner隐私、关系和独立同意边界不因工程迁移改变。
3. **当前产品基线**：main apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services Tree `049a8676cc90b3b830e32a524c172720e800fa37`（开工fresh复核）。services是有界接受的L13框架树，不代表F1/F3/F4已合入；旧v10.1.4业务冻结接受仍需保护。
4. **新开发入口有界接受**：`docs/versions/v10.1.5/B21F0955_L13_THREE_GAPS_CLOSURE_ASTRA_INDEPENDENT_ACCEPTANCE_20261031.md` 固定审查Commit `08747eeec778340a82bf3c11a3f4181847dd037a`、Blob `afa9cbac11484bdff53171e96774f80072e12462`；候选 `b21f09550a64f1c14bf59964c371aceb5b871323`（不是研发Parent）。新干净入口可接续但原本地Laravel11默认根未切换；上一任务资源已STOP，服务最终全停，不得借旧任务额度启动。
5. **具名历史功能证据**：原v10.1.5 `r1_independent_review.md`（R1消息丢响应和Android测试注入/离线清理证据）、`REMAINING_ACCEPTANCE_7773B989_ASTRA_REVIEW_20261025.md`（RTC/PCM部分接受、AC05仍OPEN），以及 `docs/versions/v10.1.5/`下此前F1/F3/F4实现、测试/真实E2E harness、报告、Manifest和审查对象。以固定Git Commit、Blob、实际差异确认来源；不可把某旧候选的整棵apps/services Tree直接merge/cherry-pick覆盖当前L13框架，更不可把旧测试回执当新源码实际通过。
6. 开工先用最小只读核查确认本地干净L13代码根、已有vendor/本地镜像、Docker/PowerShell原脚本、Flutter/Android能力实际可用、授权边界、相关旧备份与dirty根身份。历史LOCAL_ONLY结果属于`CODEX_REPORTED`；不能因GitHub文档存在而冒称本机状态持续在线。

## 2. 本任务可自主完成的综合实施（以真实产品结果为目标）

### W1｜F1 消息可靠性及媒体读写

- 以当前L13业务源码、旧候选已具名的`ConversationAtomicSendService`、客户端attempt/idempotency和真实WebSocket/站内通知通路为起点做**定点**差异核查：保留在当前源码仍有效的修复，不重复实现已经合格的功能。
- 两个合成且合法授权的账号在同源APP/API/DB完成文字发送、ACK丢失后的**同client_message_id**重试、同键相同payload回放、同键不同payload冲突、失败/断线/前后台恢复、历史消息读回、消息顺序与去重；服务端每个逻辑消息/附件/通知至多一份，客户端不得因超时虚构已送达。
- 检查Block、CN/MC关闭或撤权、禁用、过期/旧JWT、换账号、晚到响应、并发竞争、旧URL/缓存/推送点击不得复活已失效权限。相关数据库事务/锁使用真实MariaDB有界负例验证；不得以永久拒绝所有合法通信来获得安全“绿灯”。
- 图片/短视频仅复用已授权的合成媒体和既有私有Range/200/206实现；错误、撤权、过期及处理失败不能显示READY；无合法可用视频fixture则标该项NOT_RUN，不造假H.264结果。

### W2｜F3 可信登录时间、加密离线只读与到期清理

- 原冻结方案B不改：T0=账户/设备可验证的**真正成功在线登录**；refresh、重启、资料更新不能刷新T0。保留0—15天、15—30天条件只读、满30天拒绝/清理的原合同与服务端权限边界。所有时间窗用受控测试时钟与真实Android/加密存储时，必须明确标`TEST_INJECTION`，绝不声称物理经过30日。
- 对当前L13登录/refresh与Flutter实际持久化链做同源验证，确保重启时未经重新在线核验不能仅凭本地token/profile展示私密数据；只有已经持有**可证明有效离线读取上下文**的已存密文可按条件只读，不能离线发送、更新私密记录或排队发送；时间回拨、缺受信时钟、撤权状态未知、跨账号或异常恢复须fail-closed。
- 清理`chat_draft_*`等已确认旧明文/无账户隔离泄露面；敏感草稿、摘要、选定缓存消息/媒体等使用账号隔离的加密存储。只在**本任务新建合成测试密文**上演练到期实际删除成功、失败保持锁定与回执，不触碰旧LOCAL_ONLY原证/备份。明确`PURGE_DUE`与`PURGE_COMPLETED`不同。
- 复用之前通过的34/34 Android受控时间注入等有限证据，但任何跨Laravel13差异涉及登录状态或密钥协议，必须重测受影响路径，不直接把旧APP APK标成新主线APK。

### W3｜F4 通知、权限与真实Push供应商隔离

- 完成站内通知类别偏好、静默/暂停、系统权限请求/拒绝/撤回的APP交互及API/数据库持久读回；默认锁屏payload只有非敏感通用文案，点击/旧通知返回时先获取**当前服务端授权**。
- 消息、好友/搭子、动态、平台活动、Safety的既有通知仍依据现行授权/用途边界；禁用、拉黑、撤回、退出、切号、旧路由不得泄露私聊正文、身份、生辰、举报、处罚及关系状态。
- 用独立可取消的测试替身验证provider接口、token登记/轮换/注销、幂等与撤权，真实供应商未获批准时明确`REAL_PUSH_PROVIDER_PENDING / DELIVERY_NOT_VERIFIED`，禁止调用真实SDK、凭据、采购或将模拟回执写成后台系统送达。

### W4｜同源贯通与已有Web使用点（不是仅做mock/文档）

- 以当前L13的真实路由、服务、迁移、权限和合成MariaDB为权威；相同源码版本的Flutter/APP与独立Web管理已有使用点，经真实API写入并从持久化库重读/受控重启确认业务事实。Web若原来没有相应管理操作，不凭本任务新增大管理面板或允许管理员任意读取私聊。
- 最小端到端矩阵包含：两个合法账号的消息发收/幂等，第三账号越权拒绝；Block/MC撤权/切号及晚响应；指定私有媒体；T0登录/refresh/重启锁定/安全离线测试；通知开关/拒绝/点击重鉴权；后端授权管理员可见的**最小运营状态**和越权普通用户拒绝；DB断连/重启后可解释恢复。建立“APP动作→API→MariaDB→再次读取/重启→负例”逐行实测/NOT_RUN记录。
- 先验证开发DB连接优先级（`APP_DB_CONNECTION`高于`DB_CONNECTION`、URL/socket/host/port/schema/actor/grants、testing/sqlite/:memory:），不得连3306、旧事故库、生产、云库或任何未具名旧卷。只使用新独立空库/数据卷与虚构账户；可在当前可用L13入口启动**任务自有**服务、创建独立测试库、迁移和填充合成测试数据，先执行所有者/空库/volume及后备恢复点检查。原已通过的90表83行合成卷优先只读保留为来源，不擅自清空或回写。
- 允许在本任务独立新工作根和合成环境内运行既有的受控PHP/HTTP/MariaDB、Flutter纯软件测试、必要静态检查、已批准AVD的debug安装验证，前提是每个真实工具/设备/build依赖的**既有授权且可用执行资格**已实际成立。不得借本任务跳过G2或Gradle/SDK Hook守卫；任何新的真实手机、麦克风/摄像头、ADB/USB系统权限、UDP/防火墙、新外部镜像/下载安装均非自动授权。若APP构建/设备环境确实不可用，完成独立API/DB和源码/Widget可执行部分，将真实APP E2E记`NOT_RUN_GATE_CLOSED`，不要用小任务反复折腾环境或冒称完整E2E。
- 单次开发中允许对本版范围内代码、测试夹具和E2E harness的普通缺陷集中修复并有界重跑；不得降格业务断言来报绿。已接受v10.1.1—v10.1.4的权限、Activity/Safety、身份和算法不可回退。

### W5｜F2及F5有限接续，而非偷放行

- F2只验证本次改动确实触及的RTC token/epoch、旧room/媒体通知、Block/MC撤权与用户退出路径，沿用已接受PCM/Room清理/真机有限结果。**AC05仍OPEN**：AEC/回声、5秒媒体停止客观证据、真机声学及未证明的native清理路径不得凭新L13运行自动PASS。Gate2为false，不能申请或调用既往已STOP预算/未获准SDK Producer/构建/媒体实验；若新Owner设备或系统许可确有必要，作为一条集中的具名门禁请求报告，别对本轮其它软件交付进行全局阻断。
- F5对旧语音留言/附件、地图/地点仅一次具名文件/接受结论核查，输出`RESTORED`、`NOT_IMPLEMENTED`或`UNKNOWN`且附证据；无真实源不无限考古，不新增附近人、实时追踪、大地图或不在v10.1.5冻结范围的业务。

## 3. 运行范围、安全边界与不复用旧预算

- **新任务独立身份**：`V1015_POST_L13_F1_F3_F4_E2E_20261031`；只用一处具名、与原dirty及所有历史STOP分离的本地task-owned root、attempt-0001和持久ledger。先核实际空闲容量、现有镜像/vendor及服务所有者，记录来源hash、必要快照、端口与当前停止态后才能运行；所有实际启动/修改/失败包括重试均按新任务自身账本记载。**旧任务任意未用余额不可续用**；不为刷绿建立第二执行根或重开旧STOP。Owner未为本次新任务规定数值化一次性硬次数/耗时上限，不得私自将旧任务的6/6、2/2、G1/G2额度转成当前额度；在当前隔离能力与可用空间内做必要的有界测试，资源不够时STOP该项并报告。
- 允许：只在新task-owned合成开发根中，利用已有可信本地L13/PHP8.4/vendor/MariaDB容器镜像和已有合法Flutter SDK/AVD，做确需的隔离端口启动、业务代码/测试实现、MariaDB独立空库迁移seed、合成账号、loopback HTTP/WS、targeted Flutter/PHP测试与必要的debug build/install（须单独满足已批准Android/AVD/Gradle资格）；运行后恢复服务停止或明确列出具名保留状态，绝不改变本地默认Laravel11入口。
- 禁止：真实客户/旧Cookie/旧APP_KEY/旧数据库、生产/云、公网监听与第三方费用/实人/Push/支付/AI外传；系统级安装、UAC/ACL/防火墙、共享SDK/系统目录、全盘扫描、读取其它项目或改写任何历史任务ledger/原证；无来源依赖下载、Docker pull/build原生供应、强制push、裸merge、reset/rebase/stash/clean/prune或覆盖/删除原dirty树。原`D:/EliteSync-v10` dirty252、refs527、原Laravel11.48、11,066文件/240,617,393byte备份（Manifest SHA256 `3f66535d75bce70c7978338acefea8912aea855134538d04d8dd429dee07d48d`）、受限原证/事故恢复资源与全部旧STOP继续保护；只对本任务实际触及范围做足够的前后身份核验，不虚称全盘重扫。
- `LOCAL_ONLY_RAW`：真实数据库行、私密HTTP token、环境、APK、手机日志、音视频、绝对机器路径和未脱敏安全回执不上传公开GitHub/ChatGPT Project。公开只提交代码、非敏感合成fixture、脱敏总结与可核对象/Hash。若发现密钥/Bearer在新增日志中暴露，必须在受影响功能链内修复。
- 原四历史事故、`WINDOWS_E_NOTIMPL`、`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`、`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`、`RESTRICTED_IDENTITY_GATE_BLOCKED`、`OS_ENFORCEMENT_NOT_PROVEN`、`EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED`、物理15/30天、真实L11 Cookie、数据库逻辑备份恢复NOT_RUN继续保留。
- 普通测试/代码问题可在本任务自主修复；遇无法证明的执行资格、非法触及旧资产、真实供应商/设备/公网/费用、系统策略拒绝或不可逆风险时只STOP风险分项，记录完整缺口，其余合法软件工作继续，禁止改变执行策略或绕过守卫。

## 4. 按AC01—AC11提交可检验结果（逐行、不能合并假PASS）

| AC | 本任务要求的证据输出 |
|---|---|
| AC01 | 当前main/Tree/L13开发源绑定、任务独立合成DB与原dirty/备份保护前后身份；仅本轮真实核验范围 |
| AC02 | F1 APP/API/DB真实幂等、丢ACK重试、并发、旧消息重读及通知唯一性；若APP不可运行，精确拆分API_DB_PASS/APP_NOT_RUN |
| AC03 | CN/MC/Block/禁用、旧JWT、晚响应、切号、私有媒体、WS/旧通知使用点的服务端负例与并发数据 |
| AC04 | 受控合法图片/短视频发送、200/206、撤权、持久读回、处理失败；无合法视频素材标NOT_RUN |
| AC05 | RTC受影响权限回归与原有限证据引用，`AEC/5s/真实设备`仍OPEN直至独立具名证据 |
| AC06 | 真实L13登录T0/refresh与账号/设备绑定、测试时钟15/30边界；物理经过时间另记NOT_RUN |
| AC07 | 安卓/Flutter密文隔离、冷启锁定、切号/离线只读及本任务测试密文实际清理成功/失败 |
| AC08 | 通知偏好/拒绝撤权、最小内容、旧路由点击当前授权/活动和Safety安全反例 |
| AC09 | 测试替身及token生命周期，真实Push严格PENDING/NOT_RUN |
| AC10 | 同一commit APP（若资格允许）、API、MariaDB重启读回；Flutter/PHP必要分析/测试原始exit与stdout分层 |
| AC11 | 一次非强制Git候选、正式报告/manifest、受影响源码身份、脱敏审阅材料、非作者有界代码复核，等待Astra |

即使W1/W2/W3软件测试达到有限PASS，只要AC05仍OPEN或关键APP/离线使用点未运行，**不得宣布v10.1.5整版FUNCTION_ACCEPTED**。反之，真实Push供应商、生产/公网、物理30日不具备资格不得反过来否决已实测的普通功能成果。

## 5. 一次集中交付与不可跳过的STOP

- 固定新结果：`docs/versions/v10.1.5/V1015_POST_L13_F1_F3_F4_PRODUCT_CONTINUATION_RESULT_20261031.md`，清单：`docs/versions/v10.1.5/v1015_post_l13_f1_f3_f4_artifact_manifest_20261031.json`；不得覆盖原`IMPLEMENTATION_REPORT.md`、原Manifest/失败/评审。代码/测试与报告共同固定到一个可审查候选，必要时允许功能源码Commit加一份最终文档Commit，均non-force、追溯单一开工fresh main Parent；不要另建微任务链。
- 报告先写：本次真正改动与其旧候选来源、L13迁移冲突及处理；AC01–11逐项`SOURCE / CODEX_REPORTED_LOCAL_TEST / TEST_INJECTION / DEVICE / LOCAL_ONLY_RAW / NOT_RUN`；实际测试、build/APK SHA、DB持久数据/权限负例、最新成功/失败退出码、受影响正反例、尚需Owner设备/供应商许可最小清单。非作者审查着重服务端权限、幂等事务、账号/密钥缓存边界，不要求强制新增外部多模型链。
- 候选发布到独立非main审阅/开发分支（如须临时脱敏审阅，遵守既有短期材料协议）；逐项GitHub原生回读最终Commit、sole Parent/源基础、Root、所有变更path/mode/Blob、apps/services Tree和main当前状态；原生GitHub对象身份不等于本地运行成功。
- 成功的软件候选最多声明 `V10.1.5_F1_F3_F4_SAME_SOURCE_SOFTWARE_CANDIDATE_DELIVERED_AWAITING_ASTRA_REVIEW`；如真实APP或关键安全软件链受阻，声明 `DELIVERED_PARTIAL_WITH_EXPLICIT_GATES` 并给出已完代码、未完成运行和下步最小授权请求，不允许以分析报告替代能够实施的普通源码。
- **提交后STOP**，不自动合产品main、切默认L13入口、处理原备份、放行G2、关闭AC05、使用真实Push或启动v10.1.6。Astra独立验收；如整版最终具备资格才谈功能接受，后续安全集成和下一门依Owner实际权限与正式任务另议。

**最终等待状态：`TASK_CANDIDATE_DELIVERED_AWAITING_ASTRA_REVIEW / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / G2_FALSE / REAL_PUSH_PROVIDER_PENDING / V10.1.6_NOT_STARTED`。**
