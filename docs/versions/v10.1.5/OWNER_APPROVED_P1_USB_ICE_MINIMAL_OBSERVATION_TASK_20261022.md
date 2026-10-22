# EliteSync v10.1.5｜Owner批准 P1 USB/ICE-TCP 最小动态观测任务（唯一集中长任务）

日期：2026-10-22（Asia/Singapore）。
**OWNER_APPROVED_P1_MINIMAL_DYNAMIC_ICE_OBSERVATION / PLAN_A_RETAINED / LONG_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_PENDING / EXECUTION_NOT_STARTED / NO_PRODUCT_SCOPE_CHANGE / NO_R2 / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / MAIN_PRODUCT_NOT_INTEGRATED**

## 1. 授权与明确非授权

Owner在Astra接受`ice_topology_independent_review.md`的**只读审计交付（不是RTC功能验收）**后明确“可以我授权，请继续”。此处解释为Owner按上一条建议批准**一次 P1（旧 USB＋宿主loopback＋隔离 SFU ICE/TCP）短时、有界、为取得客观ICE缺失字段而做的动态观测**，不是批准重新规划版本、无界重复通话、自动修复网络或更改RTC安全边界。

**仅本次授权**：
- 当Owner确实将自己的**一台**安卓真机经USB插入、亲自信任ADB调试后，在这台明确匹配设备上运行**已安装且校验包身份**的`com.elitesync.v1015r1dev`受控开发APP；不得自动选中AVD/其他手机；
- 复用此前明确归属的独立v10.1.5 R1测试MariaDB、现有隔离SFU镜像／guard／Laravel、**既有host loopback、原USB-TCP信令和ICE设计**，只对本任务拥有且事前验证无冲突的端口使用原限定ADB reverse（API按需8031、信令7894、ICE/TCP7891；8032仅真有消息WS需要才加）；合法合成账户和HTTP-only受控peer用于接听（**不当作第二媒体APP**）；
- 在一个短时观测窗口只做**一次**合法RTC音频call的`Room.connect`尝试（维持现有30秒限时和fail-closed），在运行时短时只读提取**容器内实际ICE/TCP监听接口、Docker到容器后端路径、同call相关ICE候选tcpType和角色、ICE pair检查/nominated/selected与STUN握手阶段、DTLS连接状态**；如无需新系统权限，允许仅针对本版进程/端口采集最小协议元数据，原始敏感网络资料须LOCAL_ONLY。不做全设备/全局抓包、消息正文或环境音录制；
- 可做非破坏性启动顺序就绪检查（如guard readiness再SFU），和当前来源允许的普通本版容器/进程开启、停止，不允许用“故障修复”名义更改冻结代码或安全门。

**明确不授权**：独立LAN接口暴露、局域网媒体转发、UDP/TURN、修改Windows/Android防火墙/UAC、Docker host-publish/容器监听bind地址/LiveKit候选声明、SDK下载／升级／新镜像、增加第二真机、摄像头、宿主麦克风、真实用户/支付/公网/费用、私有设备数据访问、root、无线ADB、清理APP数据/旧卷/备份、放宽CN/MC/Block/rtc-guard或5秒撤权安全阈值、任何产品源码改动。**如果确证容器内部ICE只绑定loopback导致旧Docker端口映射不可用，只在报告中标记该事实和可选具名变更，不直接修改。** 新操作权限/防护规则一律先停相应分项并将最小申请交给Owner。

## 2. 固定 authority／已知限制

- GitHub `zcx369658780/EliteSync-v10`，任务签发前live main：`f8561693cafe3cb01995cfed720ae4d4e60b3faf`（**纯文档权威，不是v10.1.5产品代码**）；Codex开工须重新只读确认live main及其apps/services Tree，绝不能reset到main使候选丢失。
- Astra最新ICE只读独立复审`docs/versions/v10.1.5/ice_topology_independent_review.md`固定Blob **`f24e293c59a289fb259a20ae4c5b0e69b8ba3d15`**；原审计交付`7fd2b9f205df7edcf4f713d1374e924e6a6caad6`；审计报告Blob`bffb7d1fb520fdd5da6e7e24a9b9a06a6c237971`、清单Blob`cbbe7ff5c61a0f66b1dee7674f6c5b20bff98b3d`。原只读审计在其范围内`ACCEPTED_WITH_OBSERVATIONS`，但`NO_VERIFIED_ICE_MEDIA_PATH`。
- 固定v10.1.5 R1源码Commit `1c5cd2bb7919c435e8486a76959db75e9ccc367f`／Root Tree `165eb1f362db533ca94bfe1db677ff6f7bd477ed`／apps `0784c8aa7b0915a04b83693a45401197e31d93a2`／services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。此前USB真机交付`fe2e4397e4db894257276238c1a3118ba3c6a5f9`及全部报告/原失败保留；当前手机测试APP版本`10.1.5-r1-dev`、包`com.elitesync.v1015r1dev`、SHA256 `2c54dcae8d26f85995750b2e45e8d12fa0e5f450c7747fddc76274c7a40d0466`，复用设备上已有安装；不覆盖或重装。
- 冻结`AC-10.1.5-05`四项硬门：**两份实际APP双向真实流动媒体／same-call真实媒体重连／旧JWT首入与重入拒绝／撤权COMMIT后真实流动媒体停止≤5秒**，全仍OPEN或NOT_RUN。P1此次重点是**ICE前置诊断**，纵使这次手机单向track成功，也不等于双APP通过；另一端HTTP peer仅控制端，无LiveKit SDK音频。
- 旧ICE清单20条候选：SFU本地TCP2，PHONE remote UDP12／TCP6，P9/S11；SFU候选IPv4 loopback TCP7891与USB反向7891/host Docker7891的**数字与协议**相符。但`tcpType`、完整selected pair、STUN check、DTLS及**容器内部真正listener接口**缺；这些是本次优先采集字段。UDP没有通过此前USB TCP reverse，不能因此宣布“必需UDP”。
- 之前手机`Room.connect`约30.224s后`MediaConnectException`，仅60个有明确track数组的样本为空，另655个样本字段缺失；mic在`Room.connect`成功之后才激活，授权记录不等于采集证据。本次不得把旧日志混充新运行。

## 3. 唯一连续执行（G0～G5）

### G0. 设备与资产保护（所有写和启动前）

1. 只读核精确Owner真机状态（ADB `device` 且手机端已授权调试）、实际包名/版本/签名/已安装路径；若没接上或`unauthorized/offline`，则`READY_AWAITING_PHONE`并停止，不猜序列号、不尝试无线配对、不操控其他ADB设备。完整设备序列号不得进入公开GitHub。
2. 只读核最新Git权威与单一归属干净工作树；五历史根 HEAD/branch/index/status、旧refs/.env和**上轮907份及之后新增的既有原证**保护快照。禁止`git clean/reset --hard/stash/prune/force`、触碰既有dirty根、删除SQL/APK/快照/volume。
3. 启动任何本版合成数据库/容器/服务之前核其**实际归属、原备份、写前恢复点、有效APP_DB_CONNECTION/DB_CONNECTION、APP_ENV、host/port/database/socket/URL、专用MariaDB旧合成fixture**；一旦目标不明确则`DB_IDENTITY_BLOCKED`，不写。保持旧CN/MC撤权负例不恢复；允许仅在本版归属隔离库内产生必要一条合成call和短暂token。不要新建其他真实账号、读取个人数据。
4. 只检查本任务拟使用端口的**真实占用/归属**，不触碰非本任务的旧监听。原SFU镜像digest、host仅loopback（信令host7894→container受保护gateway；ICE host7891→container7891），raw SFU7880不得公开或绕过。不能把host端TCP connect当容器内ICE listener已经就绪。

### G1. 先诊断listener，再决定是否值得发起单call

在确认隔离容器和归属后，采用Docker既有非特权能力，在**实际运行时**读取本次SFU容器网络命名空间里ICE/TCP `7891`的真实listen接口、IP版本、端口、进程PID/namespace、容器私网地址类别，以及Docker host publish后端目标接口，记录该路径`REACHABLE_FROM_DOCKER_BACKEND`为`SUPPORTED/CONFLICT/UNKNOWN`。先检查guard readiness/隔离，不改启动策略超时、不用反复重启绕开授权。

- 若明确证成**仅容器自身loopback监听而Docker DNAT目标为非loopback容器地址**，则记录`ICE_CONTAINER_BIND_MISMATCH_CONFIRMED`，立即终止进一步通话；不自行更改bind、node_ip、host publish或开启LAN。
- 若监听存在且路径在当前权限下可能成立，才进入G2。
- 若工具不存在／不足或需要管理员权限、额外网络监听／全局包捕获，记`LISTENER_UNKNOWN`，停止在证据边界，不能自行升级工具/特权。

### G2. 一次最小动态ICE观测（仅G1无硬阻断时）

1. 仅在Owner已将其真机保持USB授权、真机已安装固定APP、无已有重复端口映射时，为这台精确指定设备临时创建最少`adb reverse tcp:8031 tcp:8031`、`tcp:7894 tcp:7894`、`tcp:7891 tcp:7891`（仅实际需要消息WS才包含8032），记录事前/事后列表。只允许这些**同机本地TCP端口**，不改防火墙/UDP/网络配置。
2. 使用已获准的合成测试账号和合法CN＋双方MC，在隔离数据库中完成**一条call**；Phone运行现有APP/LiveKit，另一方使用既有HTTP-only合成控制端及时accept，只证明call状态，**不是媒体APP**。仅一次`Room.connect`窗口，保持原超时上限，不无界重试、不开麦克风采音实验或摄像头，不制造录音。若当前APP先要求RECORD_AUDIO权限，仅检查先前已授的权限，不采集自然音或要求额外权限。
3. 在同call时间窗口里记录RTC gateway准入状态、SFU观察的candidate边界，**只读**Client和Server已现成可观察的local/remote SDP必要字段或可用ICE候选统计：`tcpType(active/passive/so)`、transport UDP/TCP、candidate IPv4/IPv6与端口类别、ICE role／state、pair checklist/selected/nominated、STUN/ICE frame阶段、DTLS state、track count。严格使用既有SDK日志或最少的现有本版诊断接口；**本次不授权修改Flutter/SDK实现、重建安装包或注入宽范围新日志**。缺字段标`NOT_OBSERVABLE_WITH_CURRENT_TOOLING`。
4. 对容器后端和Phone之间的同call元数据只进行有界关联：最小采样频率、时间戳来源、单call/candidate身份关联；如已有非特权针对专属7891端口的短时STUN首部计数工具才可读取包头/UDP/TCP协议统计。不得新装/下载抓包工具、提权、截取payload/密钥或采集全机流量；没有观测能力即写UNKNOWN，不能把`nc connect`/gateway JOINED当STUN或ICE成功。
5. 原安全链 fail-closed持续可见，无JWT/raw入口拒绝是静态负例，不是旧RTC JWT重入实际成功证明；不要强行做撤权试验，除非已有合法流动媒体才另标`OBSERVED`，但本任务**不是**授权开展全AC05负例或多次电话实验的轮次。若`Room.connect`成功，可仅记录ICE selected pair/DTLS和有无音轨；**不自动启用合成声音、测试AEC或开始多角色重连**，暂停进一步媒体安全验证。
6. 超时/失败立即合法end当前合成call并停；保留原失败、准确错误类、客户端/SFU的时间基准，禁止把`SIGNAL_SOURCE_CLOSE`推测成唯一ICE失败原因。

### G3. 有证据的因果边界与下一授权建议（离线分析）

构建一份按真实时序分开的 `candidate→check→nominated/selected→DTLS→track` 漏斗，按每条字段分类`DIRECT_RUNTIME/LOCAL_RECEIPT/NOT_OBSERVED/UNKNOWN`。只在具名可靠证据成立时下确证结论。区分两种情况：
- 证成bind/发布端点矛盾：给出**未来**同loopback约束下最小具体修正建议（哪个角色监听、在哪个namespace、需要哪些配置/回滚/拒绝负例），不在本任务改；
- 容器listener和Candidate角色均支持P1但STUN或nominated失败：报告最接近的已见检查步骤与仍未知层，不把环境问题写成产品P1或断言必须UDP。

最多给一条优先的现有P1具体修正假设和一个Owner可选择的P2隔离LAN/TCP后备提案；**不实施任何配置变更**。不允许声称第二个APP存在或者四RTC硬门已闭合。

### G4. 独立审阅与隐私门

非作者一次有界只读复核新报告、各证据来源等级、候选身份/port/role匹配、漏失字段、STUN与ICE区分、是否不当将HTTP-only peer当媒体端、是否维持old JWT/≤5秒冻结要求与raw SFU隔离。公共GitHub只写角色、协议、端口、候选类别、状态及不可逆匿名关联ID，私人IP/序列号/SSID/MAC/JWT/密钥/原SDP/raw ICE candidates/STUN payload/设备日志/声学声音只在LOCAL_ONLY原件，绝对不发送GitHub。此前曾发生网络候选输出流入本地工具会话的问题，必须默认白名单脱敏、先预检再发布。

### G5. 唯一报告、证据清单与收尾

最终只发布：
- `docs/versions/v10.1.5/P1_USB_ICE_DYNAMIC_OBSERVATION_REPORT.md`
- `docs/versions/v10.1.5/p1_usb_ice_dynamic_observation_manifest.json`

需包括前置G0完整身份、G1 listener与Docker target真实观察、G2是否发起及仅一条call的限定证据、源/配置/设备/APK身份、明确保留的旧失败、G3判断与最小Owner新授权要求、AC-05仍OPEN的声明、G4非作者意见、原证hash/bytes、五历史根及本版资源恢复回执。本轮源码`SOURCE_UNCHANGED`，只新增两份文档；若无法在已授权下补齐关键字段，不得修改产品代码/重新建包、做无界诊断或追改旧source commits。

成功或阻断后，仅停止本次归属的API/guard/SFU/DB及phone测试APP进程，移除本次新增的**精确ADB reverse**，保留真机安装与数据、原备份/volume、旧原证/已接受main，不停全局ADB/Docker/WSL、不清历史。候选普通nonforce发布与独立固定Git SHA/Tree、两份Blob及完整apps/services Tree回读，原先本地/private证据不上传。

**任务出口之一**：
- `P1_BIND_MISMATCH_CONFIRMED / OWNER_CONFIGURATION_CHANGE_REQUIRED`：无call，写明可实施但**未授权的**最小bind修改；
- `P1_ICE_OBSERVATION_PARTIAL / MISSING_PAIR_OR_STUN_EVIDENCE`：本权限范围内观测不足；
- `P1_ICE_PATH_OBSERVED_CONNECTED / AC05_STILL_OPEN`：只代表媒体路径/ICE证据，**不**代表双APP或撤权5秒通过；
- `DEVICE_NOT_PRESENT`等前置不可用状态，仍需如实停止。
一律最终为`AWAITING_ASTRA_INDEPENDENT_REVIEW / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。

**Codex交付后停止，不自行签ACCEPTED，不合产品main，不自动重复连接、切换P2或开放任何新网络能力。**