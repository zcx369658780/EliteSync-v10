# v10.1.5 P1 USB/ICE-TCP 最小动态观测报告

2026-10-22（Asia/Shanghai）。**DEVICE_NOT_PRESENT / READY_AWAITING_PHONE / P1_PRECONDITION_BLOCKED / SOURCE_UNCHANGED / AC05_OPEN / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

本次在G0必需设备门停止：17:10:08（UTC+08）一次ADB设备清单读取exit0，未匹配到此前Owner明确选定的USB手机，状态为NOT_PRESENT。它不证明手机物理上未插入或硬件故障，只说明本次ADB清单中既定身份不可用。没有选择其他设备或AVD，没有再次枚举/试连，没有启动APP/数据库/SFU/guard、创建reverse或发起Room.connect。**本次call数和Room.connect尝试数均为0；没有新的listener、candidate pair、STUN或DTLS观测。**

本报告集中交付前置阻断；不是旧媒体结果复测，更不是ICE连接或RTC接受。

## 固定Authority与源码

| 对象 | 固定身份 |
|---|---|
| 正式任务 | `OWNER_APPROVED_P1_USB_ICE_MINIMAL_OBSERVATION_TASK_20261022.md`，Blob `5957cf95b4d41fc27344de5cb6e56955b1d43a75`；全文读取、原字节Blob重算并与main固定路径关联核验。 |
| 实时main | `7ce7c91d82147db5742a9ea5a543dae754f064b7`；Root `d547e0e6f038f1ca2eb16e26fee8b81a83a40be3`。 |
| main接受产品 | apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，仍为v10.1.4；未以main覆盖R1候选。 |
| 固定R1源码 | `1c5cd2bb7919c435e8486a76959db75e9ccc367f`；Root `165eb1f362db533ca94bfe1db677ff6f7bd477ed`。 |
| R1完整产品Tree | apps `0784c8aa7b0915a04b83693a45401197e31d93a2` / services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`；本次完整保留。 |
| 本候选唯一Parent | 上轮只读审计 `7fd2b9f205df7edcf4f713d1374e924e6a6caad6`；Root `fd50d00e817ceabdbd5fc35b84ebd0dba55cc5a1`。 |
| 旧审计原件 | 报告Blob `bffb7d1fb520fdd5da6e7e24a9b9a06a6c237971` / 清单Blob `cbbe7ff5c61a0f66b1dee7674f6c5b20bff98b3d`，未改写。 |
| Astra审计复审 | Blob `f24e293c59a289fb259a20ae4c5b0e69b8ba3d15`，完整读取；只读审计范围的ACCEPTED_WITH_OBSERVATIONS不等于RTC产品接受。 |

使用原单一归属干净工作树，分支 `codex/v10.1.5-p1-usb-ice-observation`，仅新增本报告和 `p1_usb_ice_dynamic_observation_manifest.json`。最终候选SHA/Root/两文档Blob由发布后的对象回读回执列明，避免文档自身哈希循环。

## G0～G5 实际执行

| 门 | 本次结果 | 证据与停止边界 |
|---|---|---|
| G0.1 USB及安装身份 | **DEVICE_NOT_PRESENT** | 只执行一次ADB清单；精确选定身份未出现。没有adb -s设备命令；实际包版本、安装路径、签名、当前APK字节和当前麦克风权限均NOT_RUN。 |
| G0.2 Git及历史保护 | VERIFIED_LOCAL，终检见后 | 新main/固定任务、R1/旧审计对象已核；五历史根及950份既有文件、原refs/private env建立本轮基线。 |
| G0.3 数据库恢复点/有效连接 | NOT_RUN_DEVICE_GATE_NOT_MET | 未访问/启动数据库，不读取活库身份、不发SQL，不把旧恢复点或旧fixture状态当本次实核。 |
| G0.4 占用/SFU镜像归属 | NOT_RUN_DEVICE_GATE_NOT_MET | 未查运行时端口、未启动或inspect本轮SFU，未用host TCP connect替代容器listener。旧镜像digest仅是历史引用。 |
| G1 容器内ICE7891 listener与Docker后端 | **NOT_RUN** | G0不满足，未启动任何服务；REACHABLE_FROM_DOCKER_BACKEND=NOT_ASSESSED。本次不能确证或排除bind mismatch。 |
| G2 唯一Room.connect | **NOT_RUN（0次）** | 未运行APP或HTTP peer，未新建call/token/reverse；没有selected pair/STUN/DTLS/track结果。未消耗Room.connect机会，也未自动安排下一窗口。 |
| G3 因果定位/修正 | PRECONDITION_BLOCKED | 唯一已证阻断是既定手机在ADB清单中不可用；本次不新增ICE根因或配置修正结论。 |
| G4 非作者复核 | 见下 | 对本次门禁、身份与分层结论作一次静态审查，不补造设备或网络运行。 |
| G5 交付/资源收尾 | NO_NEW_RUNTIME_RESOURCES | 本轮没有需停止的APP/服务/容器，也没有需移除的新增reverse；未向旧资源发送stop/kill或全局ADB/Docker/WSL操作。 |

预期复用APP为 `com.elitesync.v1015r1dev` / `10.1.5-r1-dev`，预期APK SHA256 `2c54dcae8d26f85995750b2e45e8d12fa0e5f450c7747fddc76274c7a40d0466`。**这些是冻结任务及历史已验证身份，不是本次设备包核验结果**；没有重装、覆盖或回取包。原独立库、镜像、权限及CN/MC也未被当作已恢复运行。

## 本次观测漏斗与保留缺口

| 层 | 本次等级/结果 |
|---|---|
| 选定设备出现在ADB清单 | LOCAL_RECEIPT：NOT_PRESENT；一次查询，exit0。 |
| 实际容器ICE/TCP listen接口、namespace、Docker backend | NOT_RUN；无新DIRECT_RUNTIME记录。 |
| candidate/tcpType/ICE role | NOT_RUN；不能将上轮20条快照改为本次数据。 |
| pair checking/STUN/nominated/selected | NOT_RUN；没有协议头采样或端口试连。 |
| DTLS/track/归属音频 | NOT_RUN；未启麦、无合成声音或环境音录制。 |
| HTTP-only peer | NOT_RUN；历史控制端仍不是第二个媒体APP。 |

旧Room.connect约30.224s失败、SIGNAL_SOURCE_CLOSE、20候选/715观测及历史输出边界事件均保持原件；本次没有重跑或赋予新因果含义。初次设备检查的**ADB本身exit0**，本地门禁封装因 `READY_AWAITING_PHONE` 断言返回exit1，是遵守停止条件，不是SFU/SDK产品缺陷。完整ADB清单未持久化，以白名单选定身份匹配/state摘要留证；不保存或公开其他设备详情。没有伪造原stdout或补跑来取得第二份清单。

## 后续最小条件与权限

首先需要Owner使**同一台已授权USB手机**在ADB中可见并保持此前调试信任，再明确继续此受限任务；本次不会后台轮询或自动恢复。再次执行时必须重新做G0安装身份及数据库/恢复点/端口归属核验，然后才可到G1。

本次没有形成新的P1修复建议：旧审计中的容器bind与Docker后端路径潜在矛盾仍是HYPOTHESIS，不能据此改监听、node_ip或publish。未来若G1确证仅容器loopback监听与非loopback DNAT目标冲突，按原任务立即停在call前，只提交具名最小配置变更供Owner决定。P2隔离LAN/TCP仍只是先前后备提案，需要接口/设备/端口/候选及必要防火墙的单独批准；本次不切换P2，不开放LAN/UDP/TURN，也不改SDK或产品代码。

四项冻结硬门全部保留：双APP双向真实媒体NOT_VERIFIED；same-call真实媒体重连、旧JWT首入/重入拒绝、撤权COMMIT后流动媒体停止≤5秒均NOT_RUN。没有流动媒体、HTTP控制状态或新ICE证据可以替代它们。

## G4 非作者有界复核

独立非作者GPT-6.1 Sol/high完成一次有界静态复核，结果BOUNDED_STATIC_REVIEW_COMPLETED_NO_CONTENT_BLOCKER。核对指定文档、6份匿名证据bytes/hash及本地Git对象，确认ADB exit0与封装exit1分层、G0停止、Room.connect=0、无新增资源、历史身份未冒充本次实核及四项AC05仍OPEN。

非作者未进行设备、DB/API、容器、网络、测试或写操作，不构成动态验收或产品ACCEPTED。其提出的交付前完成项（主代理保护/隐私终检、回填复核和发布身份回读）均分别由真实回执承载，不把静态复核当作950文件现场重算。

## G5 保护及发布

本地终检：5个历史保护根的HEAD、branch、index SHA256与dirty/untracked状态全部与本轮基线一致；950份既有文件bytes/SHA256不变，原490个refs及private .env不变。保留原907份及上轮审计新增原件。当前代码树仅有两份指定新docs；没有改产品或任何旧证据。未生成/停止运行资源，未触及手机安装/数据、旧volume、备份或全局ADB/Docker/WSL。此为主代理LOCAL_ONLY保护回执，不冒称Astra本机核验。

公共材料仅含匿名设备别名、状态/协议角色、预期包身份、Git对象与原证hash/bytes；不上传序列号、私人IP、SSID/MAC、JWT/密钥、原candidate/SDP、完整设备日志、SQL/APK或声音。该目录的新设备摘要不含原序列号。旧资产只读取/计算hash，未清理任何工作树、审阅分支、SQL/APK、备份、volume或手机数据。

仅普通nonforce发布本次两文档候选，核验最终Git SHA/Root/Parent、两份Blob和R1完整apps/services子Tree；main不集成。**DEVICE_NOT_PRESENT / READY_AWAITING_PHONE / AWAITING_ASTRA_INDEPENDENT_REVIEW / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。


## Owner再次手动派发后的唯一观测（2026-10-22 17:30:52 UTC+08）

此节为Owner在上次阻断交付后再次正式派发同一任务的执行记录。上文17:10:08检查与候选 `c84669d91107a16b541457cdf5b6119f14880986` 原样保留；两次ADB清单属于两次明确手动派发，不能合称一次查询。本次单独一次查询，不是后台轮询或自动重试。

重新完整读取任务并确认GitHub固定路径Blob `5957cf95b4d41fc27344de5cb6e56955b1d43a75`；实时main仍为 `7ce7c91d82147db5742a9ea5a543dae754f064b7`。连续工作树开工HEAD为上次候选 `c84669d91107a16b541457cdf5b6119f14880986`，Root `b0415672164abf249d3e8222d4c1621126479478`；工作树干净。apps/services完整Tree仍与固定R1相等，产品代码未改。

**本次G0：DEVICE_NOT_PRESENT / READY_AWAITING_PHONE。** 17:30:52的一次ADB设备清单返回exit0，既定Owner身份未出现；本地封装明确按门禁SystemExit(1)结束。原stdout共28 bytes、SHA256 `bbfcc7239a6f1be3544814ebdc6bcc9b66bf5b1f0b03baa3340808f19265a630`，本次已完整保存LOCAL_ONLY；不是上次未保存的stdout，也不补造上次原件。没有adb -s命令，没有实际安装包/签名/权限核验，没有选其他手机或模拟器。

| 门 | 本次结果 |
|---|---|
| G0 Git/历史保护 | 固定任务、实时main、固定R1产品Tree已核；5历史根及983份既有文件建立本次快照。 |
| G0 手机 | NOT_PRESENT；一次清单，exit0；封装门禁exit1。 |
| G0 DB/恢复点、SFU镜像、端口 | NOT_RUN_DEVICE_GATE_NOT_MET。 |
| G1 ICE7891实际listener/Docker目标 | NOT_RUN；REACHABLE_FROM_DOCKER_BACKEND=NOT_ASSESSED。 |
| G2 单call/Room.connect | NOT_RUN，均0次。 |
| G3 candidate→check→selected→DTLS→track | 全部NOT_RUN；无新ICE或bind mismatch因果结论。 |
| G4 非作者复核 | 本次复核结果随交付回填。 |
| G5 资源收尾 | 本次未启动APP/DB/SFU/Laravel/guard、未创建reverse；无新增运行资源，无stop/kill操作。 |

本次仍未消耗Room.connect尝试。设备/运行时前置不满足，不能用历史APK、DB、镜像或旧ICE候选代替本轮实核。旧JWT首入/重入、same-call真实媒体重连、撤权COMMIT后媒体停止≤5秒以及双APP双向媒体门禁不变，AC05 OPEN。后续仍需Owner让同一授权手机可见并明确继续；无自动轮询、无配置变更、无R2或v10.1.6。

本轮保护检查的范围为五历史根的HEAD/branch/index/status和983份具名既有文件。Git status读取返回exit0，但对历史深层缓存目录产生Windows长路径警告；不将status快照声称为这些不可遍历目录的逐文件保护证明。既有SQL/APK/备份与原证的具名hash核验单独记录。终检和非作者意见见下方追加回执。

本次独立候选分支为 `codex/v10.1.5-p1-usb-ice-observation-resumed`；保留原候选分支及c846固定提交。保护终检已完成：5历史根HEAD/branch/index/status一致、983份具名既有文件bytes/SHA256一致、491个开工refs和private .env不变。第一历史根status exit0保留153条长路径警告，原始警告LOCAL_ONLY；未修改全局Git长路径配置。终检回执SHA256 `7251feddfd8a4f29764ce0e48e49d26fab0901bde654b4a3b8a3c57c35f7c27a`。

本次G4：独立非作者GPT-6.1 Sol/high完成有界静态复核，BOUNDED_STATIC_REVIEW_COMPLETED_NO_CONTENT_BLOCKER；确认两次手动派发分别记账、ADB exit0与门禁封装exit1分层、零connect/资源、APK/DB未实核、AC05 OPEN及R1产品Tree不变。其要求的本轮原证列表、保护/隐私与复核回填已完成；发布身份回读由独立GitHub读取回执承载。复核未读取本轮原始设备清单、未独立重算其hash或983份保护文件；未作动态验收，ACCEPTED=false。

本次公共文件白名单隐私预检通过：无设备序列号、私人IPv4原值、MAC或JWT，无原SDP/ICE内容或私密配置。原始设备清单仅LOCAL_ONLY。最终仍为 DEVICE_NOT_PRESENT / READY_AWAITING_PHONE / AWAITING_ASTRA_INDEPENDENT_REVIEW / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN。

原失败保留：文档隐私回填工具首次用默认GBK读取UTF-8清单触发UnicodeDecodeError，Python exit1；同批后续Git检查exit0使外层批返回0，不能冒称整批通过。修正为显式UTF-8后仅续做文档检查，没有新增设备查询、服务或Room.connect。失败回执LOCAL_ONLY列入清单。


## Owner连接手机并明确继续后的实际观测（本报告最新执行结果）

2026-10-22（UTC+08）。**P1_ICE_OBSERVATION_PARTIAL / MISSING_PAIR_OR_STUN_EVIDENCE / SOURCE_UNCHANGED / AC05_OPEN / AWAITING_ASTRA_INDEPENDENT_REVIEW**。本节为Owner“刚忘记接入手机，请继续”之后的新执行；此前两次DEVICE_NOT_PRESENT及其原候选均保留，不覆盖或混称本次失败。本轮唯一call是本地合成call 4；一次按钮动作、一次Room.connect、零重连。最终仍不是RTC功能接受。

### 本轮G0：设备、权威、数据库与恢复点

17:45:22唯一一次设备清单确认原Owner手机PHONE_A处于device且精确身份匹配。对该包执行pm path、dumpsys package及只读回取base APK：包 `com.elitesync.v1015r1dev`，versionName `10.1.5-r1-dev` / versionCode `1010511`；实际APK 416357439 bytes、SHA256 `2c54dcae8d26f85995750b2e45e8d12fa0e5f450c7747fddc76274c7a40d0466`，与冻结身份相等。现有apksigner验证exit0，证书SHA256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。RECORD_AUDIO原权限为已授；没有安装、清数据、改权限或读取私人资料。G2恢复前另做一次精确设备get-state，仍device；不是第二次ADB枚举。

重新核固定任务全文/Blob，实时main仍 `7ce7c91d82147db5742a9ea5a543dae754f064b7`。开工连续树HEAD `22844b1eaae32d08d3b53705235601696935c250` / Root `80a7390f18a8c3ff56460ed47b621c91715047f7`，干净；本候选以其为唯一Parent。R1固定源码和完整apps/services Tree保持上文身份。新分支 `codex/v10.1.5-p1-usb-ice-observation-connected`，保留前两个候选分支。

五历史根及1047份具名既有文件建立本轮保护基线。Docker Desktop最初未运行，首次inspect exit1；仅启动现有开发工具，server readiness一次exit0，没有安装、提权/UAC、SDK下载或网络配置修改。依精确历史容器ID/image、v1015-r1标签、volume名称/挂载点及loopback43327映射核专用库。历史Mounts只保存Type/Name/Destination/RW四字段，初次错误地与完整inspect结构全等比较触发断言；改按同四字段投影并另外核实volume后通过，不是卷身份变更。

启动前以真实Laravel bootstrap核有效APP_ENV=local、APP_DB_CONNECTION/DB_CONNECTION=mysql、专用R1库、loopback43327、URL/socket为空、无缓存配置覆盖。旧停库恢复点177609 bytes、SHA256 `dae557065fbe7828216b1a7a35edc0b42b3606d3cffb817ad5fcebd78aab765a`核对后复制留存。启动后只读SELECT再核MariaDB实际身份、既有8名合成用户及手机fixture 7/8，未新建用户或恢复旧CN/MC。dump-before exit0（本轮独立写前快照）；所有运行写入只在专用R1库。无迁移、无历史库覆盖。

### 本轮G1：实际listener、namespace和Docker后端

使用原隔离镜像 `sha256:32d59377b1bd55507719fced7c63efaf441423ab208fc080af0e17bdcfe7276e`，为保护旧容器与bridge原证，创建本轮专属容器和空bridge目录。复制原配置、gateway.env及既有诊断脚本原字节，不改监听、node_ip、SDK或安全阈值；publish仍仅宿主loopback TCP7894→受保护gateway7884及7891→7891，raw SFU7880未publish。旧SFU容器保持停机、未修改。

Guard初次使用历史初始记录的错误cwd，三次readiness未就绪，Laravel router找不到根目录index.php；原stdout/stderr保留。仅核对并停止本轮PID，cwd改为public后readiness HTTP200，未改源码、guard规则或超时。再启动既有bridge和SFU。

本轮采用容器已有Python读取/proc/net/tcp及tcp6，按7891 LISTEN inode关联livekit-server的fd/PID及同一网络namespace，**实际只有一个IPv6 unspecified监听**；不是只在容器loopback监听。Docker inspect记录bridge非loopback容器后端和精确loopback publish。一条容器内非loopback后端TCP7891连接及一条宿主loopback7891连接均成功，均未发送应用payload。`REACHABLE_FROM_DOCKER_BACKEND=SUPPORTED`只适用于本次G1窗口；两个普通TCP连接不能冒充STUN、候选检查或ICE成功。

因此本次**没有证成bind mismatch**，不能据静态bind配置实施改监听方案。配置中的bind_addresses与ICE7891实际socket行为必须分开陈述；此前loopback-only假设在此运行中不成立，历史运行本身的listener仍未被补证。

### G1与G2的资源窗口及Owner新增有界确认

固定R1服务在Room.connect成功后会自动setMicrophoneEnabled(true)，源码行893与919；本P1原任务要求不采集自然音且不改包，故连接前先停在该边界向Owner确认。等待期间已停止本轮资源、保存首窗口快照。Owner随后明确批准“周围无人声，可继续唯一连接”，仅允许成功后短暂自动启麦，不播放测试音、不录音、不启摄像头。

按此批准，重新核精确设备和数据库身份，恢复**同一个本轮容器、同镜像、同配置字节**以及本轮guard/bridge/API。此为等待授权后的资源恢复，没有多做Room.connect。**G1的/proc inode/namespace和两条TCP探测来自第一个运行实例；G2没有再次取得/proc快照。不得将G1 namespace当作G2同一实例的实物记录。** G2有自身inspect/启动日志及同call日志，完整保存这一证据限制，不在失败后追加探测补齐。

### 本轮G2：唯一call及真实APP连接结果

只为精确手机新增8031、7894、7891三条同机TCP reverse；没有8032/UDP/LAN/TURN/防火墙操作。复用现有固定APP和透明loopback API observer（未启任何故障注入），合成账户通过正常登录、已有会话及语音按钮创建唯一call 4。HTTP-only peer正常accept、heartbeat，不持LiveKit媒体SDK，不是第二APP。APP PID专属日志LOCAL_ONLY；既有只读SFU观察器缩短至60秒、1秒采样，无全局抓包。

| 真实观测 | 结果与来源等级 |
|---|---|
| APP Room.connect | DIRECT_RUNTIME：start 1、OK 0、FAIL 1；30.209秒后MediaConnectException，原30秒参数未改。 |
| Phone peer-connection回调 | DIRECT_RUNTIME：connecting 2、failed 2、closed 2；gathering 2、complete 2。这是聚合PC状态，不是selected pair证明。 |
| SFU同call关联 | APP room与SFU候选总结一致，匿名room SHA256 `df5745c3ac8d7cb69120a8c1e7b1cbd0d68f49bc939e97abc2b866923c151947`；仅此一call。 |
| 候选 | DIRECT_RUNTIME：24条记录，publisher9/subscriber15；SFU local TCP2、Phone remote UDP12/TCP10。不是24条唯一物理路径或候选对。 |
| 端点类别 | SFU TCP2为IPv4 loopback固定7891；Phone UDP4条可解析为IPv4 private nonloopback、2条IPv6 loopback，另6条地址日志字段无法可靠解析；Phone TCP5条IPv6 loopback、另5条地址无法可靠解析。未把这些未知字段猜成IPv6、mDNS或具体网卡。 |
| tcpType/ICE role | NOT_OBSERVABLE_WITH_CURRENT_TOOLING；日志省略active/passive/so，不能凭TCP端口或候选条数推断。 |
| checklist/STUN/nominated/selected | NOT_OBSERVABLE_WITH_CURRENT_TOOLING / NOT_OBSERVED；容器既有tcpdump/tshark/dumpcap/ss均不存在，未安装或提权抓包。 |
| DTLS | NOT_OBSERVABLE_WITH_CURRENT_TOOLING；没有CONNECTED实证。 |
| track | 60份1秒观察样本中，30份见room、15份见participant，15份participant的tracks明确为空；其余无participant的样本不是缺失track字段的成功样本。无媒体成功证据。 |

时间严格分开：SFU在10:10:33.304Z记录participant初始化，10:10:48.533Z记录SIGNAL_SOURCE_CLOSE并在同一秒输出候选总结、connectionType=unknown；APP在10:11:02.871Z记录30.209秒连接失败。之后才有本轮合法end和API_DELETE收尾。**SIGNAL_SOURCE_CLOSE早于APP最终超时，但这些记录不足以把它认定为唯一ICE失败原因。** 不将HTTP accept/in_call、TCP连接、候选收集或generic PC失败拼接为ICE或媒体成功。

一次失败后立即合法end HTTP200；未点击重新连接或第二次通话。没有Room.connect OK，也没有after_enable_microphone或本地音轨绑定日志，未进入冻结源码的显式启麦分支；本次未开展采音/播放/录制实验，不把权限已授当作实采证据。

### 本轮G3：定位结论与最多两个后续选项

已确认层为：授权设备/安装包与隔离DB有效；G1实际SFU listener和宿主publish前置可达；G2真实APP经guard进入同房间的信令/候选收集；之后PC失败，未见selected/DTLS/track。故障最接近的已见边界是**候选产生后、媒体连接完成前**。仍不知道Phone是否对SFU TCP候选发起STUN/何种角色，也不知道检查失败或未开始的具体环节。不能定性为产品代码缺陷、bind缺陷或必须UDP。

优先P1建议仅一项：未来单独授权一次**连接前及失败时**可导出tcpType、ICE role、candidate-pair/selected/DTLS的定向诊断能力，并默认静音；或使用已批准的专属7891头部计数能力定位Phone→reverse→SFU检查是否真正发出。当前工具未提供这些字段，本次不改APP/SDK、不新装抓包工具，也不实施任何bind修正。新诊断包/观测权限须Owner具名批准，本任务不自动进入新开发轮。

可选P2仍只有原隔离LAN/TCP后备路径：需Owner另行明确允许选定接口、该手机/端口、候选声明以及必要防火墙；本次没有实施，不新增UDP/TURN。

四冻结AC05硬门继续OPEN：双实际APP双向媒体NOT_VERIFIED；same-call媒体重连、旧JWT首次/重入拒绝、撤权COMMIT后真实流动媒体停止≤5秒均NOT_RUN。唯一HTTP控制peer与本次单手机失败不足以关闭任何一项。

### 本轮G5：数据库与资源回执

G1第一窗口结束时dump-before/after原字节相等；G2正常登录、打开既有聊天和唯一call后，库从263行到310行，其中261条旧行原字节保留。两个旧行仅为conversation_members的last_read_at/updated_at以及personal_access_tokens的last_used_at/updated_at更新；CN、MC、consent events以及原3条RTC行完整保留，新增恰一条RTC call。新增正常登录device session/token、通知、app/RTC事件分别列入清单，不冒称全库未变。不恢复旧撤权负例，不迁移、不重置fixture。

本轮最终备份exit0，原SQL及新SQL均LOCAL_ONLY。合法end后停止已启动测试APP，保留安装和数据；三条新增reverse逐条移除，canonical列表恢复原状。两次窗口拥有的guard/bridge、API/observer、PID logcat及SFU observer均已停止/退出，SFU/独立DB均停止。SFU退出1来自本轮SIGTERM supervisor的既有os._exit(1)收尾行为，不冒称观测中fail-closed故障；DB退出0。没有停止全局ADB/Docker/WSL；为运行现有工具启动的Docker Desktop按“不停止全局Docker”边界留运行。旧SFU容器、卷、备份及历史证据保留。

本轮保护、隐私及非作者终检结果在以下追加回执回填；最终仅发布原指定两份文档。保留此前所有失败，以及本轮环境启动、错误cwd、旧GBK JSON读取和离线SQL/候选分类修正的实际失败记录；分析失败没有触发额外设备通话或数据库重跑。

本轮保护终检已完成：5历史根HEAD/branch/index/status一致，1047份具名既有文件bytes/SHA256不变，492个开工refs及private .env不变。第一历史根status exit0仍有153条长路径警告，未声称覆盖全部隐藏缓存。主代理LOCAL_ONLY保护回执SHA256 `9d78223ac3680558e4037aea1eb3d76cae9abb3efe1f1087414d9671e61c1606`；动态SQL变化与资源恢复如上单列，不以静态保护代替它们。

本轮G4最终回执：独立非作者GPT-6.1 Sol/high有界静态复核无阻断性错误；核20份安全回执bytes/hash和11组字段，独立计数24候选P9/S15及11个未知地址字段，核对单call/30.209秒、DB行变化、两文件范围及R1产品Tree。未读取secrets、原设备日志、SQL/APK或受保护原证，未独立重核60观察样本/1047保护文件；不构成动态验收。对shutdown回执原有临时分析文字，在清单另给最终启麦分支结论，原回执字节保留。公共白名单/JSON检查通过；候选固定对象和产品Tree回读由发布后的本地交付回执承载。

最终：P1_ICE_OBSERVATION_PARTIAL / MISSING_PAIR_OR_STUN_EVIDENCE / AWAITING_ASTRA_INDEPENDENT_REVIEW / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN。仅本轮两份文档候选普通nonforce发布，SOURCE_UNCHANGED；不签ACCEPTED，不合main，不启动R2/v10.1.6，不再连接。
