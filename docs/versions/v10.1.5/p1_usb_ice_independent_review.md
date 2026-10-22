# EliteSync v10.1.5｜Astra P1 USB／ICE-TCP 最小动态观测独立复审

日期：2026-10-22（Asia/Singapore）。独立评审者：Astra／EliteSync GPT顾问。

**P1_BOUNDED_DIAGNOSTIC_DELIVERY_REVIEWED_WITH_OBSERVATIONS / ACTUAL_ICE_PATH_NOT_VERIFIED / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / SOURCE_UNCHANGED / OWNER_DECISION_REQUIRED / NO_AUTO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

本文件是对本次有界任务的GitHub固定对象、Codex发布报告与清单、现有Flutter/Laravel固定源码进行独立复审，不是Astra直接操作Android手机、Windows、MariaDB或Docker SFU的现场验收。任务过程和历史原始设备/数据库/SFU回执仍为`CODEX_REPORTED/LOCAL_ONLY`，独立可证的Git提交、报告正文、清单一致性属于`ASTRA_GITHUB_DIRECT`。**交付和安全停机证据可在限定范围内认可，不代表ICE真实可用、RTC媒体已建立或完整AC-10.1.5-05已接受。**

## 一、独立身份与历史连续性

- 本次复审前live `main`：`7ce7c91d82147db5742a9ea5a543dae754f064b7`；仍为接受版本v10.1.4产品，apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`／services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 唯一冻结任务：`docs/versions/v10.1.5/OWNER_APPROVED_P1_USB_ICE_MINIMAL_OBSERVATION_TASK_20261022.md`，Blob `5957cf95b4d41fc27344de5cb6e56955b1d43a75`。上轮ICE只读审计Astra独立裁决Blob `f24e293c59a289fb259a20ae4c5b0e69b8ba3d15`；冻结v10.1.5 AC未更改。
- R1固定产品源Commit `1c5cd2bb7919c435e8486a76959db75e9ccc367f`、Root `165eb1f362db533ca94bfe1db677ff6f7bd477ed`，完整apps Tree `0784c8aa7b0915a04b83693a45401197e31d93a2`，完整services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。
- 本次最终交付Commit **`62f0cd6d6df80f2f22855c0f75fd67ff52c753a7`**，Root **`146c32d866f6986e48b80f7a4e3bd8c1ccc2638a`**，唯一Parent `22844b1eaae32d08d3b53705235601696935c250`。三段连续提交：`7fd2b9f205df7edcf4f713d1374e924e6a6caad6`→`c84669d91107a16b541457cdf5b6119f14880986`（首次无手机）→`22844b1eaae32d08d3b53705235601696935c250`（再次手动派发仍无手机）→本次终交付；前两个无手机失败不是本次一次Room.connect的重试计数。
- GitHub从上轮只读审计`7fd2...`比较到本次最终交付，ahead3／behind0，变动仅两份docs：`docs/versions/v10.1.5/P1_USB_ICE_DYNAMIC_OBSERVATION_REPORT.md`（Blob **`f3e5282d803afa5c444427de1ab0b81c691c1754`**）和`p1_usb_ice_dynamic_observation_manifest.json`（Blob **`6cdb8aded51bc876588f278649c4ee35fa178150`**）。最后交付与上轮原审计的**完整apps/services子Tree相同**，通过Git Tree直接核对`SOURCE_UNCHANGED`。原旧报告、本地原证和main产品未被此次候选替换。
- 本次报告和清单正文已直接读取；保护快照、Android包回取、SQL/录音未由Astra现场执行。

## 二、G0—G5分层裁决

| 工作门 | Astra审阅结论 | 必须保留的证据等级 |
|---|---|---|
| **G0设备/包/独立库** | `SUPPORTED_FROM_CODEX_LOCAL_RECEIPTS` | 第三次Owner明确继续后手机在ADB确认为device；固定APP包、APK SHA256、原签名和此前已授mic权限被本地回执核对。有效R1隔离MariaDB、卷、原恢复点与配置亦作了本地核验。此前两次无手机须继续保留，不能归作产品设备故障。 |
| **G1 容器ICE listener** | **`SUPPORTED_IN_FIRST_RUNTIME_WINDOW`** | R1既有SFU镜像、配置未改。按`/proc/net/tcp{,6}`及进程FD/inode关联，报告真实LiveKit进程仅有IPv6 unspecified 7891 LISTEN；Docker host loopback TCP7891→容器非loopback地址的目标有界TCP探测成功。这个窗口里**没有证成container loopback-only bind mismatch**，不授权擅自修bind。但普通TCP接通不等于STUN/ICE成功。 |
| **G1/G2实例连续性** | `IMPORTANT_OBSERVATION` | 因待Owner补充确认成功连接后自动启用手机mic，第一窗口资源曾关闭；Owner同意后恢复原容器、镜像、配置字节。**G2没有再做/proc listener快照**，因此G1 listener的PID/inode/namespace不能当G2同运行实例的原始证明，尽管恢复配置未变。 |
| **G2一次Room.connect** | **`FAILED_30_209_SECONDS`** | 仅新建一条合成call 4，一次手机APP点击、一次Room.connect、无重连；HTTP-only peer正常accept／heartbeat，**不具媒体SDK**。APP记录start1／OK0／FAIL1，MediaConnectException约30.209s；RTC PeerConnection的gathering/complete和connecting/failed/closed为聚合事件，均不证明nominated/selected pair。 |
| **G2候选与ICE** | `CANDIDATES_RECORDED_BUT_HANDSHAKE_UNVERIFIED` | 本次候选**24条**（publisher9、subscriber15；SFU本地TCP2、Phone UDP12／TCP10）。tcpType/active-passive/完整pair checklist、STUN交换、selected/nominated、DTLS均没有适足观测，不能凭多4条候选推论更接近成功，也不能将部分网络地址格式解析不明猜为具体接口。 |
| **G2轨道** | `NO_VERIFIED_MEDIA` | 60份观测中30份能见room，15份能见participant且**其tracks显式为空**，其余样本不可扩充为成功/失败媒体统计；generic网络包无轨道/codec归属。旧源码证实`room.connect`成功后才显式setMicrophoneEnabled(true)，当前没有此分支或local audio bind的日志，不能把已授RECORD_AUDIO写成已采音。 |
| **G3因果定位** | `ROOT_CAUSE_UNDETERMINED` | 故障层收敛在候选产生以后、媒体连接成功以前。SFU SIGNAL_SOURCE_CLOSE早于APP最终30s超时，属于关联观测而非已证唯一根因。没有证据证明必需开放UDP／LAN、SFU代码安全BUG或特定TCP角色不兼容。 |
| **G4非作者审查** | `BOUNDED_STATIC_REVIEW_NO_CONTENT_BLOCKER` | 非作者GPT-6.1 Sol/high核对20份安全摘要与11组字段，不曾运行设备或重核原密钥、SQL和1047份保护文件；不能替代Astra功能接受。 |
| **G5资源及保护** | `SUPPORTED_LOCAL_ONLY_WITH_LIMITATIONS` | Codex报告已结束call、停本轮APP/guard/bridge/API/SFU及专用DB、仅移除本轮3条reverse；保留手机安装数据、旧镜像及SQL/APK。历史5保护根、1047具名文件、492 refs与私密env一致为本地回执；第一历史根Git status有153条Windows长路径警告，不能说所有深层缓存均完整hash。 |

**特记数据库数据变化**：本轮隔离库因合法登录和合成call而新增记录，已有261行被报告为字节一致，另两条旧行的正常`last_read_at/last_used_at`等时间字段更新。故不能说“数据库内容整体零变化”；保护指旧权威同意、旧RTC记录、原备份和特定历史数据没有被覆写，且这些证明由本地回执支持。

## 三、关键判断及冻结AC

1. **G1原有H02猜想（容器仅在自身loopback监听、Docker桥接无法抵达）**：本次G1窗口的实际监听与有界连接检查对它构成**不支持/未复现**的证据，不能再把该假设当作`CONFIRMED`而提出未经批准的SFU bind修复。未来新G2实例实际监听若没有快照仍不能绝对排除在不同时点的变化。
2. **手机+USB P1候选仍`ICE_CONNECTIVITY_NOT_PROVEN`**：24条候选说明SFU接收了ICE候选信息，不能证明候选pair检查、STUN/DTLS或媒体成立；仅IP端口/协议/普通TCP接通不足以归因。
3. **现有instrumentation不足**：在当前授权与现有工具下，tcpType、候选pair/check、STUN状态及DTLS字段仍未取得。任何新diagnostic build、安装工具/SDK、短时协议头部采集或更改观测接口，都需要Owner**明确新授权**；不把本次结果自动派发为另一轮循环尝试。
4. 冻结AC-10.1.5-05仍为：`DUAL_APP_FLOWING_MEDIA=NOT_VERIFIED`（一台媒体APP＋一个HTTP-only控制端），`SAME_CALL_RECONNECT=NOT_RUN`、`OLD_RTC_JWT_FIRST_JOIN_REENTRY=NOT_RUN`、`COMMIT_TO_FLOWING_MEDIA_STOP_LE_5S=NOT_RUN`。音视频/AEC、实际Push另留原有门禁。仅先前已独立限定接受的v10.1.5消息幂等、加密离线、私有媒体/通知证据继续保留。
5. 不授权**main集成、改变原AC、自动切到LAN/UDP/TURN/P2、更换手机设备或启动v10.1.6**。当前方案A保持：RTC作为独立未验阻断。

## 四、正式裁决与Owner下一门

**此次有界P1诊断工作作为任务交付，可记`BOUNDED_DIAGNOSTIC_DELIVERY_REVIEWED_WITH_OBSERVATIONS`；G1前置在其实际窗口有证据支持，但G2依旧`PARTIAL / FAILED_TO_CONNECT`。故整个v10.1.5正式状态为`PARTIAL / NOT_ACCEPTED / AC05_OPEN`。**

**优先下一步建议**：不是再用相同工具重试一次30s通话，也不是直接切隔离LAN/TCP；而是将单机RTC工作暂停到Owner选择是否批准一个极小的**连接前／失败时诊断观测能力**：如现有设备/SDK允许的ICE pair+tcpType/DTLS字段输出或单任务归属7891端口的最小非敏感STUN元数据（不得公开raw candidate/JWT）。未来如果可核实本地USB路径确实无法形成有效pair，再单独向Owner提交P2接口与权限/回滚方案。**本轮只提出建议，不构成已经授权。**

当前Astra仅完成GitHub只读审查及文档归档，不操作手机、SFU、数据库或其他运行资源。候选源码及历史保护对象不清理。
