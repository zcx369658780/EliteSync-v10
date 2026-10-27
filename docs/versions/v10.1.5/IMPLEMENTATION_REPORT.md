# EliteSync v10.1.5 实施与候选交付报告

结论：**PARTIAL / OPEN_BLOCKERS**。状态：`V10.1.5_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE / PRODUCT_MAIN_NOT_INTEGRATED / REAL_PUSH_PROVIDER_PENDING`。这是 Codex 实施交付，不是 Astra ACCEPTED。核心期限清理及 RTC 媒体等缺口未关闭，不以 Push 供应商待定豁免。

## 权威与固定源码

| 项目 | 固定身份 |
|---|---|
| 仓库 / 来源 main / 源码唯一 Parent | `zcx369658780/EliteSync-v10` / `9283b7f6ed7f37971fd9f64c60e9747c7896b09d` |
| plan Blob | `7d3466b3be67135dc641cfee7c7faef78937ba03` |
| task_order Blob | `0df56f69712a85541b5f24bef281e2a9a61520a4` |
| 源码 Commit | `6ca68617fd6e18648a9ccd4c923fa1850761fbec` |
| 源码 Root Tree | `d43b98c77edbb0c4b74ab93a2574b50a0bf3f1c7` |
| 完整 apps Tree | `d0343174cb8587d9e27303f180a37380616b6262` |
| 完整 services Tree | `c32fc724fde29a595084e8c1ec066340d892e8fe` |
| 来源 apps / services | `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac` |
| 候选分支 | `codex/v10.1.5-communication-private-cache` |

冻结文档全文及 Blob 已核，开工与交付前 live main 一致。源码共62文件、4421增加/258删除；报告和 manifest 后继提交只变文档，产品两子 Tree 保持上述身份。报告所在 Git 提交即文档交付身份；避免在文件中递归写入自身提交哈希，实际发布回读身份由交付回执给出。未改 frozen plan/task、旧接受文件、main 或历史候选。

## 入口短矩阵与实现

| 分层 | 已核内容与本版处理 |
|---|---|
| 已有且接受 | v10.1.4 apps/services 来源；CN/MC/消息幂等、私有媒体/Range、RTC和通知既有合同复用，不移植旧AC通过结论。 |
| 已有但缺真实接线 | 15/30天纯策略、明文/全局缓存、WS配置、通知偏好及实际Live页面；本版接线并验证已说明部分。 |
| 本版新增/修复 | 服务端成功login T0/设备family/15天期限；refresh不续期；锁后当前授权重验；WS仅发conversation_changed指针；未知结果同键重试；安全存储、账户/设备/对象命名空间、进程可信经过时间、启动锁定、离线只读和清理回执；通知类别/静默/权限GUI/TEST_ONLY token生命周期。 |
| 外部尚未批准/不可用 | 真实Push Provider/Key/费用/远端锁屏送达；新增实体音频设备、麦克风/摄像头、UDP/防火墙及公网。未执行。 |

实际路由为 LiveConversationListPage/LiveChatPage，验证未以备用聊天页面代替。原生picker返回后核原账户、新epoch并做当前HTTP读取，随后才允许上传。缓存排队写入固定调用时账号，防止旧A写入借B会话。时间异常、未知凭据、跨进程启动、校验异常、已知撤权均锁定；只对精确transport故障允许既有授权缓存只读。Bearer敏感调试输出路径已移除。Android禁止备份；应用重启需在线重新核验。

一次旧源定点检查：既有具名图谱中 VoiceMessage/Map 查询未证明来源；当前 LocationContractController 不含地图SDK或实时定位。结论 `NOT_PROVEN / UNKNOWN / OUT_OF_SCOPE`，不能推断旧版绝不存在。未新增语音留言、附近人或地图模块。

## 冻结 AC-10.1.5-01～11

所有实测为 `NEW_RUN / CODEX_REPORTED`，合成数据与时间/transport fixture另标 `TEST_ONLY`。测试数量不替代真实链。

| AC | 结果 | 正例、负例与剩余门禁 |
|---|---|---|
| 01 基线/保护 | PASS（核验范围内） | 真实main和两产品Tree、独立空MariaDB/专属volume、有效APP_DB_CONNECTION和测试隔离事前验证。五保护根HEAD/branch/index/status终检一致，全部事前refs和私密.env hash未变。未做历史所有SQL/APK事前逐文件hash，不作全资产一致保证。 |
| 02 消息幂等/故障恢复 | PARTIAL | 同APK双AVD真实GUI登录、文字/图/视频发送接收；HTTP同键同id、异payload409、附件只绑定一次；最终6消息/3附件/每消息1通知。WS101及最小指针，API中断显示密文只读并禁发送/选图/选视频；前后台恢复后当前HTTP重读新视频。未知结果同键重试有widget回归；实际设备网络“请求已提交但响应丢失”故障注入未跑，故不宣称全部AC闭合。 |
| 03 授权/迟到响应 | PARTIAL | MariaDB RR精确reader43/writer42 users PRIMARY RECORD锁等待，writer撤销COMMIT后旧reader401、无私密正文，双exit0。真实MC撤销、CN关闭、Block后旧消息/图片/视频/Range均404，新发404；logout旧JWT401。禁用合成C后旧凭据被401/403集合校验拒绝，但脚本后续断言失败，未单独保存精确状态，不冒称该整脚本PASS。切号/迟到响应与缓存跨号队列由本版定向测试覆盖；完整真实GUI切号/账号注销及WS撤权关闭时序矩阵未完成。 |
| 04 图片/短视频 | PASS（本组受控旅程） | 同版本APP原生picker发送图片/2秒H264视频，B可见图及私有视频播放/暂停状态；视频源hash与DB相同。有权200/206、第三人404、同视频键仍message6；假MP4返回422未READY。专属DB与APP重启后重新GUI登录可读取/播放既有视频；MC撤销后实际播放器“视频不可用”，旧图/视频Range404。无音轨视频不证明音频质量，未重跑全部旧媒体。 |
| 05 RTC | PARTIAL / OPEN | 实际HTTP创建、拒绝、接听、结束及旧LiveKit入口404；RTC retry定向7/53 exit0。未运行双端SFU媒体、实际重连/撤权5秒停止；AEC/人耳为NOT_RUN/DEVICE_PENDING。控制面不能证明媒体目标。 |
| 06 可信15/30天 | PARTIAL / CORE_OPEN | 真实login产生账号/设备绑定T0，refresh不续期；持久服务端TEST_ONLY时间fixture：15天前60秒200、15天/后60秒/未来锚401。客户端采用服务端锚+进程Stopwatch，冷启锁定。真实Android15/30天边界及完整同账号期限时序未证，不把纯策略/回填T0等同实际经过时间。 |
| 07 加密缓存/清理 | PARTIAL / CORE_OPEN | 双AVD真实FlutterSecureStorage密文、SharedPreferences无测试名称/消息明文；同进程API断开只读，发送控件enabled=false；离线冷启登录门无旧私密内容。widget覆盖时间异常/切号/丢密钥/30天清理成功与失败、跨号排队。最终APK无可达可信时钟seam，不能即时证明Android30天到期清理正反例；NOT_RUN/NOT_PROVEN。未修改设备全局时钟，不能把登出清理冒充到期清理。 |
| 08 通知 | PARTIAL | 真GUI站内入口/类别/静默；消息类别关闭且MariaDB持久为false，silent=1。OS拒绝、允许状态及系统设置撤销可见；撤销导致进程重启回登录门。API偏好过滤、通用文案/最小payload；撤权Block后旧消息通知0条。锁屏文案仅契约，未声称真实远端投递；真实旧卡片点击、完整GUI Safety/禁用矩阵未完成，相关后端有限回归不替代GUI。 |
| 09 Push隔离 | PASS（隔离合同） / PROVIDER_PENDING | 独立provider接口、token注册/轮换/撤销/去重回执由8/69定向测试与真实HTTP合成登记验证，token仅hash。全部transport为TEST_ONLY；无真实Provider/SDK Key/费用，REAL_PUSH_NOT_RUN。 |
| 10 运行/回归 | PARTIAL | 固定源码APK双端安装回取hash一致；真实API/MariaDB旅程、精确RR、实际媒体与重启读回。9指定表重启hash全同；PHP23文件lint exit0；后端50/286及RTC7/53 exit0含2 deprecations；Flutter定向通过。analyze exit1，0error/0warning/8info，8条均基线未改文件；未伪称全绿。核心期限及RTC实物缺证仍开放。 |
| 11 交付/复核 | PASS（交付范围） / AWAITING_ASTRA | 唯一报告/manifest、固定源码和产品Tree、独立短期脱敏审阅分支、非作者有界静态复核。6项发现修复后无未关闭高置信P1/P2；审稿者未跑设备/DB/声学，不是Astra接受。发布与回读后停候选，不main、不v10.1.6。 |

## 实际测试、命令与原始失败

| 本版回执 | stdout / exit |
|---|---|
| auth-green-expanded | 9 tests /42 assertions /exit0；2 deprecations |
| notification-green-expanded | 8/69 /exit0；2 deprecations |
| backend-auth-notification-regression | 50/286 /exit0；2 deprecations |
| backend-messaging-rtc-regression | 19/159，7 errors /exit2；旧RTC fixture缺合法friendship |
| backend-rtc-current-fixture | 仅补合法friendship，7/53 /exit0；2 deprecations，不弱化产品门或删断言 |
| flutter-targeted-initial → chatroom-final | 首轮182通过/1失败；修正文案后目标组28通过/exit0 |
| new-safety-fixed2 / live-cache-expiry / cache-queue-green | 5 /5 /10项通过，exit0；队列RED原证保留 |
| live-chat-regression-third | 9项通过 /exit0 |
| live-chat-reliability → picker-fixed | 5通过/2生命周期fixture失败；fixture修正后另2通过/exit0，共7独立case |
| analyze-source-fixed | exit1，8条旧info，0error/0warning |
| final-changed-php-lint | 23份PHP文件，全部exit0 |
| assembleDebug离线固定源码构建 | BUILD SUCCESSFUL /exit0 |
| http-journey-first / rr-first / rtc-control-fixed | 真实HTTP/DB、精确RR、RTC控制面均exit0 |
| trusted-boundary-http / video-http-positive / block-http-final / notification-after-revoke | 持久时间fixture、图片视频Range、Block后拒绝、旧通知隐藏均exit0 |

可复核命令：`php tests/Integration/v1015/runtime.php {identity,migrate,seed-relations,snapshot}`；`python tests/Integration/v1015/{journey,rr,rtc_lifecycle}.py`；额外视频/Block/边界脚本在独立review分支。PHP定向测试通过phpunit的testing/sqlite/:memory: fail-closed门运行；Flutter定向日志保留完整stdout和exit，公开包给最小尾段。构建命令：`assembleDebug -PflutterDartDefines=ELITESYNC_V1015_LOCAL_BUILD=true -PrelationshipDualDeviceBuild=true --offline --console=plain`。回环API为`php -S 127.0.0.1:8021 -t public public/index.php`，WS为`php artisan chat:ws --host=127.0.0.1 --port=8022 --poll=1`。最终lint逐改变文件执行`php -l`。原始空白检查exit2；历史CRLF规则检查exit0，原失败未改写。

其余原失败全部保留：初始seed exit0但stdout为现行Match拒绝，补合法合成friendship后成功；notification初轮缺phone；旧RTC脚本/hangup404后改/end；旧JDK路径猜测失败；缓存队列RED；生命周期fixture失败。补测脚本先误期望403而实际404、误写REVOKED而实际MC_REVOKED、误用/blocks路由404，均非通过回执；不恢复已撤权状态，续接正确状态后最终Block脚本exit0。禁用/旧通知组合脚本要求存在旧卡片而列表已过滤为空，exit1；单独旧通知过滤脚本exit0。GUI类别首次substring误点，后来精确节点操作及DB读回确认；系统撤权重启导致旧页面断言失败。下载首份ZIP截断hash不符，未执行；续传完整hash通过。工具输出/本地原证与失败文件继续保留。

## APK、便携视频工具与实物来源

APK：`com.elitesync.v1015dev` /`10.1.5-dev` /code `1010501`，x86_64+arm64，开发签名SHA256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。固定源码APK SHA256 `60655c9f3440bb3c8aecfcffd88643f2b150e14ec7e92907dbd62961a92f1d97`；两个AVD安装路径回取字节均相同。早期APK另存，不混用最终包。

Owner在本轮明确批准项目记忆无法定位时下载视频工具。仅本版目录便携下载 `https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip`，114768076字节，SHA256 `60f467265b1e312373dbcd92200c2618a74850f98d3d078e94296bb3fa2047ba`，与发布者sha256文件一致（不是数字签名证明）。生成2秒320×240/15fps/H264/yuv420p/无音轨MP4，11508字节，SHA256 `ee92709753412dd169e70c9205ba51e2b98d2e0e03f674a917b5e8a4781f7584`，服务端asset3/message6精确匹配。APP原生图片选择器可能重编码，DB图片asset2 hash为 `b5fa8d43f3a284c229ab5f35df417e61fbb56402a74b6532c6e418715b3586c4`，不声称与选择前PNG原字节相同。

## 数据库恢复、保护与收尾

本版新空库`elitesync_v1015_dev`、新volume `elitesync-v1015-dev-data-20261021`，mysql/127.0.0.1:43326/local；93表，MariaDB10.11，镜像digest `8020e05c4c498d06c87f0a1db010eb79bd6f8fb30e9b763d4690c34ce1e61008`。每个写入harness先验证effective连接、DB/host/port/env/url/socket；未连接旧3306或旧库。空库恢复点、重启前SQL、负例后最终SQL均LOCAL_ONLY保留。最终SQL180577字节，SHA256 `c7141bdeb3c32b278321dd5d87ffc44230cdd82ee16b05d06bc45027c15de02d`。重启前SQL172632字节，SHA256 `00544ebc456792dcf2eeb0b1700169a838700c628f26203d3b9e9f0cef00ea87`；仅完成dump，未声称另库restore演练通过。

重启对users/device_sessions/chat_messages/message_attachments/notifications/product_connections/messaging_consents/notification_preferences/notification_devices共9表做逐表排序内容hash，前后全同；API/WS及APP当时停止以避免写入噪声。媒体通过重启后真实当前reader及GUI播放另核，并非所有93表hash证明。负例终态CN_CLOSED/MC_REVOKED/Block、合成C禁用保留，未自动复活权限。

五保护根：原dirty根、旧仓及三个历史工作树的HEAD/分支/index hash/status与事前全同；全部事前Git refs不变，私密.env hash不变。ignored仅事前清单，未做全历史SQL/APK逐字节基线，不作超出核验范围的保护保证。连续树构建更新可重建build输出；旧正式归档与备份未操作。全部本版API/WS/AVD停止，只有本版8021/8022 reverse移除；专属DB停止、volume保留。未停全局ADB/Docker/WSL，未历史清理。

## 非作者复核与证据层次

独立非作者Sol/high静态复核固定源码及新增测试：未发现未关闭高置信P1/P2。6项已修：时间异常旧列表、锁后凭据重验、WS正文TOCTOU、非网络错误误启离线、锁定草稿、picker旧epoch。RTC fixture只补合法friendship。审稿者未执行测试/DB/设备/声学；主代理归档简录位于独立review分支。

- `CODEX_REPORTED / LOCAL_ONLY`：实际Windows/AVD/API/MariaDB/密文/截图/XML/原始日志，Astra尚未直接核验。
- `TEST_ONLY`：全部虚构账户/合成图视频/持久时间fixture/transport替身，不是远端Push送达或物理15/30天。
- GitHub源码及脱敏文本可直接读取；这不使本地实测自动成为`ASTRA_DIRECT`。
- `REUSED_EVIDENCE`只用于旧接受合同的来源，不迁移为本版测试PASS。

独立审阅分支 `review/temporary-evidence-v1015-20261021`，固定commit `7f7a1036e4a4567be7797e41530011b2dbb06684`，Root Tree `b931e43fabe46167cc40cd3c137eb47801798cac`，目录`docs/_temporary_review/v1015-20261021/`，23份允许文件及Blob逐项列于manifest。普通non-force发布；不得合并该分支到main/产品候选，未清理。未上传SQL/APK/截图/XML/token/签名密钥/私密配置/设备标识。manifest包含原证hash及来源分级，不能仅凭hash视为Astra已读原件。

断网设备无法即时得知远端撤权；只读资格依赖此前建立的可信上下文，联网后先重验。不能保证抹去对方已下载副本，也不能把离线未知状态解释为当前服务器许可。

## 开放阻断与交付出口

1. `CORE_TRUSTED_DEVICE_TIME_AND_PURGE_NOT_PROVEN`：实际Android15/30边界、可信离线完整时序、30天受控密文清理成功/失败实物回执未完成。现有安全策略为重启锁定；不能用widget或日期回填宣称闭合。
2. `RTC_MEDIA_5S_NOT_PROVEN / AEC_DEVICE_PENDING`：无本版双端SFU媒体/重连/撤权5秒终止及声学证明。
3. `REAL_GUI_EDGE_MATRIX_PARTIAL`：实际响应丢失同键重试、切号/注销/旧通知点击/Safety完整GUI矩阵尚缺，相关单测/HTTP仅证明已列部分。
4. `REAL_PUSH_PROVIDER_PENDING / REAL_PUSH_NOT_RUN`：外部供应商未批准，隔离合同通过不能代替真实投递。

集中提交唯一报告及manifest、固定源码与独立脱敏材料，等待Astra独立功能验收及Owner后续决定。本次不生成acceptance/integration_acceptance，不集成main、不执行v10.1.6，不扩展生产、硬件或历史清理权限。


---

## v10.1.5 R1 有界返修集中交付（2026-10-22）

**PARTIAL / OPEN_CORE_BLOCKERS / NOT_ACCEPTED / PRODUCT_MAIN_NOT_INTEGRATED。** 本节仅追加R1；上文首轮原报告和 `artifact_manifest.json` 保留，原提交与审阅分支不改。Codex没有签署Astra ACCEPTED，不启动R2或v10.1.6。

完成候选交付后的状态：`V10.1.5_R1_CANDIDATE_DELIVERED` / `AWAITING_ASTRA_INDEPENDENT_FUNCTION_REREVIEW`。这里的自测结果不是Astra功能复审。

### R1权威、固定源码与制品

- 只读核验实时main `be21598ef8738ab4d8e5dbd20f210f473e0b51f7`；R1全文Blob `be3045b206b75b7ccd0d8b28bc366678fc890302`。冻结plan Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`、task Blob `0df56f69712a85541b5f24bef281e2a9a61520a4`，原AC未修改。R1正文固定入口：[Astra R1任务](https://github.com/zcx369658780/EliteSync-v10/blob/be21598ef8738ab4d8e5dbd20f210f473e0b51f7/docs/versions/v10.1.5/ASTRA_REVIEW_AND_R1_TASK_20261021.md)。
- R1源码 `1c5cd2bb7919c435e8486a76959db75e9ccc367f`，唯一Parent `47e30a3ef5bc7aacb42b6e32b6bc822dbdbb0962`；Root `165eb1f362db533ca94bfe1db677ff6f7bd477ed`；apps `0784c8aa7b0915a04b83693a45401197e31d93a2`；services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。从原最终候选安全新建 `codex/v10.1.5-r1-bounded`，没有把当前main覆盖到产品源码，没有更新本地旧main。
- 14项R1源码路径/mode/Blob见本版新增 `artifact_manifest_R1.json`；其后的交付提交只追加本报告并新增R1 manifest。原产品源码 `6ca68617fd6e18648a9ccd4c923fa1850761fbec` 与原最终候选 `47e30a3ef5bc7aacb42b6e32b6bc822dbdbb0962` 均保留。
- 最终普通开发APK：`r1-app-final.apk`，包 `com.elitesync.v1015r1dev`，versionCode `1010511`，versionName `10.1.5-r1-dev`，SHA256 `2c54dcae8d26f85995750b2e45e8d12fa0e5f450c7747fddc76274c7a40d0466`。固定源码构建exit0；A/B已安装包分别pull读回，双端均同哈希（`final-installed-apk-identities.json`）。
- Android期限专用包：`r1-retention-probe-isolated.apk`，`com.elitesync.v1015r1probe`，SHA256 `fa7c3ad5233ab98c5b44afaaba29d3fe2156753df3e266f6edaa50778e56de89`。它在后续无关聊天竞态修复之前构建/实测；probe入口及期限依赖源码与最终源一致，不能冒称该旧probe APK由最终commit重新构建。普通最终APP没有导入probe入口。
- Probe需两重local define及宿主debug bootstrap；release宿主任务配置阶段实际拒绝（预期Gradle exit1，验证外层exit0）。probe与普通R1 AAR有独立仓库、源码/defines摘要坐标，移除仅CI目录存在就跳过构建的逻辑；非作者发现的AAR串包P2已关闭。

### R1-B1：Android期限和受控密文清理

**SUPPORTED_ANDROID_TEST_INJECTION / ASTRA_REVIEW_PENDING；REAL_PHYSICAL_ELAPSED=NOT_CLAIMED。** 在既有AVD和独立MariaDB对应真实HTTP成功登录后，真实Android进程委托真实FlutterSecureStorage，完成34/34检查及实际force-stop/relaunch后的锁定检查。成功原证是 `android-retention-native-after-anchor.json` 和 `android-retention-native-restart.json`，不是早期cat失败文件。

检查包括服务端login T0/账户设备绑定、refresh不续期、当前reader HTTP200后保存、15天前/当/后、20天离线只读拒写、30天前/当/后拒读。可信wall/monotonic推进只在测试进程注入；没有修改系统全局时钟、生产T0或正式时间合同，未声称物理经历15/30天。

A对象在30天边界实际删除本版namespace的密文和manifest，native读回均null；回执 `completed / deleted_objects=1 / native_delete_completions=2 / locked=true`。B对象仅对精确测试namespace的委托delete抛受控异常，回执 `failed / injected_delete_failures=1`，真实密文及manifest仍在但锁定。**这是DELETE_ERROR_INJECTION，不是实际OS文件系统故障。** 重启后B密文仍在，但无可信anchor，offline read拒绝且locked。真实SecureStorage文件读回2766bytes、无probe payload/手机号明文（只记录文件身份/扫描结果，不公开prefs密钥值）。

### R1-B2：虚拟音频尝试与核心剩余阻断

**CORE_OPEN；未建立可验收的双端APP/SFU流动媒体。** Owner额外明确批准仅已有A/B AVD的虚拟麦克风权限、既有Emulator Controller合成PCM和既有SFU的loopback TCP；不含宿主真实麦克风/摄像头、手机、UDP、防火墙、UAC或SDK。

实际向R1测试包授予RECORD_AUDIO，核验两端既有gRPC booted。专属SFU复用既存image，未pull/build新镜像，只发布loopback TCP7894/7891，raw SFU不发布；首次发生 `authority_monitor_failed / sfu_fail_closed`，原日志保留。普通修复式恢复同一容器后，GUI观察到呼叫/来电；第一次因自动化接听延迟进入missed，未接通。

合成440/880Hz注入尝试返回 `UNAVAILABLE / connection reset` 与 `DEADLINE_EXCEEDED`（命令exit1），随后B AVD进程退出、A界面dump及logcat阻塞。**这里只报告同次环境故障现象，没有证成RPC是崩溃根因。** 当次没有成功媒体证据；第二次GUI操作未形成完整接通原证。暂停音频注入，仅重启同两AVD完成其它GUI负例，未扩大设备或网络权限。原WAV/指标即使存在也不作为媒体成功或人耳听感证据。

剩余具名门禁：`R1_B2_DUAL_APP_SFU_MEDIA_NOT_VERIFIED`、`R1_B2_SAME_CALL_RECONNECT_NOT_VERIFIED`、`R1_B2_OLD_RTC_JWT_FIRST_REENTRY_NOT_VERIFIED`、`R1_B2_FLOWING_MEDIA_STOP_LE_5S_NOT_VERIFIED`。无授权camera source，视频NOT_RUN；AEC物理听感仍 `DEVICE_PENDING`。HTTP控制面、WS消息门和静态RTC门都不能替代以上门禁。

### R1-B3：真实响应丢失、切号与旧通知

**消息故障原失败已修复且实物复测通过。** 受控loopback代理先读完真实Laravel已提交响应，再抑制HTTP字节24秒，使APP发生真实20秒receive timeout。首测发现 `_load` 的WS/current-read先清attempt但保留draft，超时后重试换key，产生消息id2/3；原重复行和通知不删除。修复为仅由POST/同键重试确认清attempt/current draft，当前read不提前清key；权限拒绝、切号、期限锁定仍清理并递增epoch。

最终APK实测：消息id4第一次POST `client_message_id=c9630ad0-e88b-43cd-977f-07db37860fb5`；界面明确“发送结果尚未确认”和“使用原消息编号重试”；GUI重试复用同key，真实响应 `id=4 / idempotent_replay=true`，MariaDB该消息一行、该消息通知一条，界面转“服务器已确认此消息”。原证 `real-fixed-loss-gui.txt` exit0、`proxy-observed.stdout.jsonl`、`message-retry-final-audit.json`。

有限切号：真实A私密读取HTTP200被代理延迟60秒，APP经实际退出确认（服务端logout200）登录C；C界面读取未授权会话404，无A的消息/对端名。延迟响应随后记录 `old_private_response_client_closed`，再读C GUI仍无A内容。`late-response-account-switch-result.json`、`switch-c-after-late-attempt.json` 与代理日志共同绑定。60秒是LOCAL_ONLY测试代理调度延迟，不是产品超时设置。

Safety使用同一独立库的明确 **TEST_ONLY_DIRECT_SAFETY_FIXTURE_NOT_WORKFLOW_ACCEPTANCE**：D本人GUI和当前通知点击只显示本人最小状态，私密陈述marker不显示；F读取该案404，本人列表空；D禁用后登录403。D首次旧卡片在点击前就已失效，未计为旧点击成功。E的另一条受控旧通知则在禁用提交后约49ms实际tap，当前Safety GET403，APP退出且无私密内容。该fixture不接受完整平台活动/Safety writer工作流。

WS综合脚本已执行断连/重连、pointer和MC撤权，但最后“upgrade后close”断言失败且未在断言前序列化全部中间值；**保留exit1，不宣称整个脚本PASS或精确active-close耗时。** 补充当前拒绝实测：MC不重新激活，HTTP404、WS在HTTP upgrade前关闭，APP真实聊天内容清空。该消息WS结果不能升格为RTC媒体撤权证明。部分UI脚本还保留错选图片按钮、登录框残留输入和未等待新帧的原断言失败；均未作为成功原证。

### R1-B4：定向测试、复核与原失败

| 检查 | 实际结果与限制 |
|---|---|
| PHP隔离回归 | 47 tests / 1769 assertions / exit0；2 deprecations及2 PHPUnit deprecations保留，`backend-r1-targeted-isolated.txt`。SQLite只作回归，不代替本版真实MariaDB链。 |
| 初次PHP回归 | 47 errors / 0 assertions / exit2；继承local环境，被测试写前隔离门拒绝，未削弱保护门。正确命令进程显式设置testing/sqlite/:memory:后才通过。 |
| Probe单元/分析 | 5项exit0；probe分析exit0，早期testing-only分析警告保留。 |
| 消息竞态回归 | 8项exit0，新增pending POST→current-read已见同key→receiveTimeout→同body/key retry→单ACK；测试文件分析及生产live_chat分析均exit0。不是物理APP替代证据。 |
| PHP语法 | 本次3个服务及R1 runtime脚本4份均无语法错误；原证 `php-syntax-tool-transcript.txt`。 |
| 构建/安装 | probe release拒绝预期；probe后普通CI构建exit0；修复APK构建exit0；固定源码再构建exit0/38项up-to-date，同哈希双端安装读回。Dokka远程package-list下载警告保留，未更换SDK。 |
| 空白检查 | 原 `git diff --check` exit2保留；历史CRLF规则 `core.whitespace=cr-at-eol` exit0。 |
| 非作者复核 | 独立GPT-6.1 Sol/high只读，检查构建隔离、期限入口、精确DB门、代理与pending-send竞态；AAR P2关闭，未发现新增高置信P1/P2。不运行设备/DB，也不签Astra接受。 |

可复核命令入口为 `php vendor/bin/phpunit` 的本版定向filter（须testing/sqlite显式隔离）、`flutter test --no-pub test/dev/v1015_r1_retention_probe_test.dart`、`flutter test --no-pub test/features/chat/presentation/pages/v1015_live_chat_reliability_test.dart`、`dart analyze lib/features/chat/presentation/pages/live_chat_page.dart`，以及 `gradlew :app:assembleDebug -PflutterDartDefines=ELITESYNC_V1015_LOCAL_BUILD=true;ELITESYNC_V1015_R1_LOCAL_BUILD=true -PrelationshipDualDeviceBuild=true --offline --console=plain`（PowerShell中defines须作为一个引号参数）。完整stdout/exit及本地设备脚本在R1原证目录；前述构建不支持target、AAR路径、chunked转发、空会话404、cat错误等原失败不删除。

### 冻结AC-01～11对应（不改合同）

| AC | R1证据状态 |
|---|---|
| 01 | 5受保护根、首轮260文件、旧refs与私密env核验无变；新独立库/卷与恢复点具名。 |
| 02 | 实际响应丢失竞态修复，同键重试及消息/通知唯一实测支持；首轮双端消息成果保留。 |
| 03 | 有限切号/迟到结果、Safety禁用、当前WS拒绝及APP内容清空支持；综合WS脚本原失败/缺中间序列化保留，不推广为全部矩阵。 |
| 04 | 首轮图片/无音轨视频/Range与重启成果复用；R1未重复全包验证。 |
| 05 | **PARTIAL / CORE_OPEN**：双端SFU媒体、同call恢复、旧RTC JWT、流动媒体≤5秒停止缺证；视频与AEC门禁仍开。 |
| 06 | 真实Android测试进程注入34项轨迹、真实HTTP T0/refresh及重启锁定；物理经过15/30天不作声称，待Astra独立判定。 |
| 07 | 真SecureStorage受控密文30天边界实际删成功、注入删失败后锁定及重启拒读；非OS故障、非物理30天。 |
| 08 | 当前Safety通知最小化、真实旧卡片禁用后点击403和切号负例支持；未接受完整Safety writer业务。 |
| 09 | 首轮TEST_ONLY Provider隔离沿用；真实Push供应商/密钥/费用NOT_RUN。 |
| 10 | 定向PHP/Flutter与APP/HTTP/MariaDB证据具名；B2及WS脚本限制保留，整体PARTIAL。 |
| 11 | 固定源码/树、最终APK双端读回、原报告附章、新manifest、非作者复核和脱敏审阅包集中交付；等待Astra独立复审。 |

### 数据库与历史保护回执

本版仅 `elitesync_v1015_r1_dev` / `127.0.0.1:43327`，容器 `fa7862c5066e8b037980ce8838cec2f3cc07c0ad2022538fd3139a78e2dad407`，独立新volume `elitesync-v1015-r1-data-20261022`。迁移前有效APP_DB_CONNECTION/mysql、库/host/port/url/socket、空库及归属已核；空库恢复点1348bytes、SHA256 `4b1ce64e9da8b945ba587d700f1232e13db20b5f1597542e136f5b3ca1efef55`。运行93表；最终SQL `165674` bytes / SHA256 `14f266cc8fb75d783eb6fe13d54ee5d37f49176fa1d86d05e531fa00d8435c4d` / exit0。SQL、APK、WAV、prefs/密钥原值均LOCAL_ONLY，未公开。

保护终检：5根HEAD/branch/index/status与事前一致；首轮260文件hash/bytes全部一致；原本已有heads/tags均未变；连续工作树私密.env hash未变。**该核验覆盖声明的快照与260文件，不声称所有历史目录的每一份SQL/APK都已事前独立hash。** 没有reset/clean/stash/prune、历史文件删除、旧库启动/覆盖或main集成。只停止本版API/WS/proxy/authority/bridge/SFU/DB和所启两AVD，回收本版4个reverse，保留容器/卷与原证；全局ADB/Docker/WSL未停止。R1未改schema，未重复首轮已证明的数据库重启项。

### 脱敏审阅与停止门

最小脱敏审阅分支 `codex/v10.1.5-r1-review-evidence`；Commit `6e9b7441839954d0d8847399c91482354c61e473`，Root `ad834e85f5fb5ce1e435bbfa3be46446862d35b2`，10份文件的path/mode/Blob见R1 manifest。固定入口：[R1脱敏审阅](https://github.com/zcx369658780/EliteSync-v10/tree/6e9b7441839954d0d8847399c91482354c61e473/docs/_temporary_review/v1015-r1-20261022)。原短期review分支保留。候选及审阅材料只普通non-force发布，并以独立REST/Git对象及fixed-SHA raw bytes回读；具体发布身份以包含本附章的Git提交及本地publication receipt为准。

R1原证根 `LOCAL_ONLY:v1015-r1-evidence-20261022`；核心剩余阻断为上述R1-B2媒体/重连/旧JWT/5秒门禁，另保留视频source与AEC设备门、综合WS脚本缺口、真实Provider和历史ZIP `BYTE_MIRROR_PENDING`。没有生产/公网部署、真实Push/用户/支付/外部AI或系统权限扩展。

**交付后停止：V10.1.5_R1_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_FUNCTION_REREVIEW / PARTIAL。** 等待Owner把本次集中候选交给Astra；不得自行ACCEPTED、集成main或启动下一轮/版本。


## 2026-10-25 综合长任务续接：当前集中交付

**当前结论：PARTIAL / OPEN_BLOCKERS / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE。** 本末章及当前 `artifact_manifest.json` 表示最新集中交付；前文首轮/R1原始叙述逐字节保留为历史，不把旧NOT_RUN迁移为本轮PASS，也不重签Astra结论。

### 权威、来源与精确源码

完整读取当前唯一task_order及F节，固定Blob `d737c3a813d81ada7a9ca9a60aa310e9e14e0960`；plan仍为 `7d3466b3be67135dc641cfee7c7faef78937ba03`。从live main原始base64内容解码后，Git原字节Blob精确核对；连续候选中的旧任务文件未被改写，当前执行合同引用main上该固定Blob。ACTIVE_STATE Blob `2b9ab05eebc21712070065c75f9f0b1aae90d571`。已读v10.1.4双接受、原综合任务、Gate1/D0-C接受及历史失败。R1 Astra复审Blob `ff9916e0b227dc0996165b2b6d5024b6199ead17` 已重新读取，其B1/B3限定支持与RTC核心OPEN均保留。

| 对象 | 身份 |
|---|---|
| 核验live main / Root | `a6c321a85ec6433a2cfc5eda56e72178e688b47a` / `087adc701c36de429a53470f386fcf26d882ed3d` |
| 已接受main完整apps / services | `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac` |
| 连续候选起点 / 本次源码唯一Parent | `f9d281d03d1f9ad7a3f7b0b3f3e85582c8580dff` |
| 本次源码Commit / Root | `3e20809f5b91f18545047f05a52164f1d59d6455` / `957ac75c9ae19e19aa4ea7eaacdaa80e4f196022` |
| 本次完整apps / services Tree | `785822ca072943c5bfefa3ccc37ede01c2af5164` / `21eebf69bbc6397b1562d40f8cd9ebd7b246720f` |
| 连续候选分支 | `codex/v10.1.5-source-faithful-serializer-conditional-sdk` |

当前apps Tree未改变；十项源码/测试差异在services。三个Service仅给本轮新专属库 `elitesync_v1015_long_dev` / loopback端口43328增加精确pair；local/testing、loopback、socket及原端口检查保留。PlatformAccess继续单独拒绝URL；**LiveConsent/Rtc既有代码没有独立URL拒绝，testing分支仅检查sqlite，不能把PlatformAccess或测试runner更严格的规则泛化给它们。** 实际受控harness在任何迁移/seed前另核完整effective配置与URL/socket，测试runner锁定testing/sqlite/:memory:。

六个旧Feature测试的夹具/断言与当前已接受合同对齐，另新增配置选择器正负例测试：bare released Match不再被伪装成有效关系，合法CN/MC先建立独立ACTIVE Friendship；bare Match、单方同意拒绝仍有明确负例。Block后当前read404但历史row不删；未认证媒体请求由真实认证中间件先返回401且无原媒体字节。RTC Friendship只在active()加入，纯match-alone负例保持。未增加middleware豁免，旧Foundation测试原有豁免不作真实middleware贯通证据。

| 入口分层 | 本轮处理 |
|---|---|
| 已有且已接受 | v10.1.4主线双Tree保持；原CN/MC/媒体/隐私合同复用，未重集成。 |
| 已有而仍需实物证明 | RTC流动媒体/同call重连/旧JWT入房/≤5秒停止，当前完整apps新APK仍未证。 |
| 本轮修正并新验证 | 专属开发库精确允许项、旧回归夹具及断言、真实WS全序列证据与逐步落盘、当前API/DB/媒体重启。 |
| 外部或前置门未满足 | 真实Push、实体AEC/新增设备权限；Gate2加载不兼容导致37/条件SDK/Producer/30解析未运行。 |

### Gate 2：新预算已消费，Writer仍未运行

历史WinPS入口有效Restricted，原0.375秒SecurityError预算保持已消费，未重试。现有PowerShell7.6.6有效RemoteSigned/FullLanguage；按其已允许的普通本地 `pwsh -NoProfile -NonInteractive -File` 入口建立独立新预算 `LONG_F3_GATE2_PWSH7_20261025`，总限15秒。未修改策略、ACL或系统配置，未用Bypass/内容执行桥。独立非作者静态比较仅host变化、其余七文件逐字节相同，绑定八项pins。

唯一新启动实际 **exit1，进程退出确认，控制器总耗时0.390秒**。阶段为startup，`System.TypeLoadException`：现有.NET10宿主加载既有.NET Framework程序集时缺少 `System.Web.UI.WebResourceAttribute`。先前类型可解析只证明元数据可见，不证明运行兼容。原child结果的 `status=FAIL` 是启动失败记录；**正例/负例、Write-Aggregate、Serializer实际调用、fallback均NOT_RUN、调用数0、receipt0**，不能报Writer或Serializer运行FAIL。控制器保存的stdout/stderr、Run ID、监督结果/退出确认与Hash均LOCAL_ONLY，摘要在独立审阅包。

D0-A仍原一次15次Serialize、约0.688秒；本轮0次。Gate2没有通过，因此完整37案例suite、Sandbox SDK、Producer、libs.jar及30项Configuration.resolve()均NOT_RUN，未重置任何预算。当前Host APK/ICE标志实物仍未证明，未借旧R1包冒充新完整apps Tree构建。未对未知guest作HCS处置。

### 新运行、普通失败修复与持久化

| 运行 | 真实结果与范围 |
|---|---|
| 后端核心定向 | 31 tests / 245 assertions，exit0；保留2项PHP与2项PHPUnit deprecation。 |
| 后端关联回归 | 修正后61 / 472，exit0；最后RTC Friendship移至active()后该类12 / 94再次exit0，不重复计为额外独立用例。 |
| Flutter定向 | 任务自有精确源码副本，缓存工具、no-pub：55及97 tests passed，均exit0；不是设备/SFU实测。 |
| Dart分析/PHP语法 | RTC services、storage、auth interceptor、LiveChat四项均exit0且No issues；十改变PHP文件lint及CRLF规则diff检查exit0。 |
| HTTP/MariaDB | 真登录/refresh不续T0、消息同键同id、异payload409、私有图片字节、通知偏好/TEST_ONLY登记均通过。 |
| 精确MariaDB并发 | REPEATABLE-READ；reader54等待writer53的users PRIMARY RECORD；writer撤销session提交在前，reader随后401且私密正文缺失，双exit0。 |
| 实际WebSocket | 初连/断开/重连、最小conversation_changed指针通过；MC撤权后0.735秒当前连接关闭；旧token重连实测InvalidMessage（未收到合法握手/connected），未猜具体HTTP拒绝码；旧HTTP404。按当前API恢复MC后继续独立测试。 |
| 私有短视频 | 合成1秒H264无音轨MP4，非摄像头录制；有权200及Range206字节/Content-Range匹配、第三方404、MC撤权后全量/Range404、假视频422。API层证据不等于本轮APP播放。 |
| RTC控制面 | 新库真实创建/拒绝/接听/结束、旧join入口404，exit0；仅CONTROL_ONLY，无SFU流动媒体。 |
| DB重启 | 本任务专属容器重启，9表规范快照完全相同，同token消息响应字节相同、视频Hash相同；有dump，未声称异库restore。 |

普通失败均留原证：初次backend cache Windows绝对路径被框架拼接，20 error/0 assertion，修正任务自有相对cache路径并核selector JSON；首次扩大旧回归52/197、16error/6fail；旧fixture与Block合同不符，修正后剩61/468一条未认证期望404，按真实认证401且无媒体修正后通过。没有靠产品放权、跳过/删除测试取得绿灯。Flutter副本初缺package_graph，补复制已有元数据后通过，无pub/download；第一次Dart文件路径错误exit64，修正后四项干净。初次HTTP媒体配置422、RTC开关404是本轮启动配置问题，分别改为既有私有disk与本地RTC guard后运行；不隐去失败。

新库/专属volume是本轮创建前不存在的资产，端口43328/API8041/WS8042开始前核空闲；没有使用旧3306、旧数据库或未知原生mysqld。空库0表身份与SQL事前恢复点已保存，迁移/seed后仅写本轮合成账号/媒体。最终SQL **172222 bytes / `546a4a8f10b3f034e33b5b61b8d0a919a985dd9938ae23c8f3d70195bf687a05`** LOCAL_ONLY。API/WS两个归属进程已按身份关闭并确认退出，本任务容器已stop、volume与恢复点保留，旧容器未启动/删除。Docker Desktop及adb server在工具可用性检查中启动并保持可用；本轮无AVD/手机/宿主麦克风/摄像头操作、没有主动修改共享SDK源码、全局配置或下载升级；工具缓存副作用未作全SDK逐字节验收。

### 当前冻结AC逐项结果

| AC | 当前结论 | 证据与限制 |
|---|---|---|
| AC-10.1.5-01 | `SUPPORTED_BOUNDED_PROTECTION` | NEW_RUN；新独立空MariaDB/volume、有效选择器与迁移前恢复点；22,482具名历史文件、五保护根及受保护旧refs一致。 |
| AC-10.1.5-02 | `SUPPORTED_BACKEND_AND_REUSED_GUI` | NEW_RUN + REUSED_EVIDENCE；真实HTTP幂等回放/409、WS断开重连与最小指针通过；R1已支持的GUI丢响应同键重试证据保留。本轮没有当前完整apps Tree的新APK/GUI旅程。 |
| AC-10.1.5-03 | `SUPPORTED_BOUNDED_NEGATIVES` | NEW_RUN + REUSED_EVIDENCE；MariaDB reader54等待writer53的users PRIMARY RECORD锁；COMMIT撤权后旧reader401，双exit0。当前WS撤权关闭/旧token拒绝和HTTP404通过；切号/迟到结果与Safety旧卡片GUI复用R1限定证据，未声称全矩阵新跑。 |
| AC-10.1.5-04 | `SUPPORTED_API_MEDIA_AND_REUSED_APP` | NEW_RUN + REUSED_EVIDENCE；真实图片与H264短视频持久读回、200/206、撤权/第三方404、假视频422；新库重启后视频Hash一致。APP播放为既有版本证据，非本轮新GUI。 |
| AC-10.1.5-05 | `PARTIAL_CORE_OPEN` | NEW_RUN_CONTROL_ONLY / MEDIA_NOT_RUN；RTC创建/拒绝/接听/结束及旧入口404通过；双APP有效SFU媒体、同call重连、旧RTC JWT首次重入拒绝、流动媒体≤5秒停止仍未证。AEC/视频源设备门保留。 |
| AC-10.1.5-06 | `SUPPORTED_TEST_INJECTION_WITH_LIMITS` | NEW_RUN + REUSED_EVIDENCE；真实login/refresh T0不续期及后端期限回归通过；R1 Android 34/34受控注入时序由Astra限定支持，非真实物理30天。相关期限源码未在本次修改。 |
| AC-10.1.5-07 | `SUPPORTED_NATIVE_INJECTION_WITH_LIMITS` | REUSED_EVIDENCE + NEW_RUN_TESTS；R1真实FlutterSecureStorage到期删除成功/失败及冷启锁定证据保留；新55项缓存/晚响应/通知与97项RTC/期限测试通过，不能代替新设备演练或现实删除完备性。 |
| AC-10.1.5-08 | `SUPPORTED_BOUNDED_PRIVACY` | NEW_RUN + REUSED_EVIDENCE；本轮真实API类别/静默/最小通知及旧权限负例、Flutter点击重验回归通过；GUI权限/旧通知/Safety限定证据复用R1，完整Safety业务与新GUI未重跑。 |
| AC-10.1.5-09 | `PASS_TEST_ONLY_ISOLATION` | NEW_RUN / REAL_PUSH_NOT_RUN；合成transport token登记及已有生命周期正反回归通过；真实Push供应商/SDK/Key/费用和后台锁屏远端送达仍PROVIDER_PENDING。 |
| AC-10.1.5-10 | `PARTIAL_CURRENT_HOST_AND_RTC_OPEN` | NEW_RUN + REUSED_EVIDENCE；后端31/245和61/472、最终RTC夹具12/94、Flutter55+97、四项分析、真实API/持久DB重启通过；当前完整apps Tree未构建安装，新Host APK与条件SDK链未运行。 |
| AC-10.1.5-11 | `DELIVERY_SUPPORTED_AWAITING_ASTRA` | STATIC_REVIEW + CODEX_REPORTED；唯一报告/当前manifest、固定源码双Tree、十文件非作者复核和最小独立审阅分支；尚非Astra功能接受，不合main。 |

B7只复用原具名旧源检查：语音留言/地图来源仍NOT_PROVEN/UNKNOWN，不把RTC当语音留言；本轮未重复架构规划或增加新模块。R1的Android34/34期限/清理注入与GUI丢响应/切号/旧通知支持严格标REUSED_EVIDENCE，相关非RTC源码在当前apps中未发生变化；新纯测试与API运行不会升级为当前完整APP现场结果。

### 非作者复核、公开材料与停止

非作者Sol/high对十项diff、准确工作树SHA256/行号、上述保存回执做只读复核，当前无未关闭发现。其结论仅SUPPORTED_STATIC_REVIEW，没有独立执行设备/DB；源文件Git规范化SHA256与实际执行工作树SHA256均列manifest，差异仅Git的CRLF→LF，未混淆两套字节。另一次只读文本筛查对最小公开包无泄漏删减发现，原凭据/SQL/APK/设备和进程日志不上传。

独立审阅分支 `codex/v10.1.5-long-continuation-review-20261025`，Commit `9e240a1f622ba179b696184a23d45c5dd38a360e`、唯一Parent `3e20809f5b91f18545047f05a52164f1d59d6455`、Root `9a49ef77aa72cded42568eb1b702d2ca182aa130`，8件path/mode/Blob列manifest。[固定审阅入口](https://github.com/zcx369658780/EliteSync-v10/tree/9e240a1f622ba179b696184a23d45c5dd38a360e/docs/_temporary_review/v1015-long-continuation-20261025)。WS公开脚本只是去凭据派生副本，未执行；原harness实际运行Hash单列，不声称公开派生件与原件字节相同。短期包不进入产品候选或main，未清理任何旧审阅分支。

保护核验：22,482具名历史文件Hash/字节、五历史根HEAD/branch/index/status、516个旧refs中的受保护项保持；仅本次自有候选ref允许前进。其范围不等于全盘或所有活设备逐字节验收。历史失败、原D0预算、旧SQL/APK/refs及原dirty根保留。原报告字节作为本文件前缀不变；旧manifest可从来源commit精确取得，R1 manifest文件未修改。

普通non-force发布连续候选并回读Commit/Parent/Root、双Tree、报告/manifest Blob和原字节；文档交付提交自身身份由最终回读回执提供，避免文件内自引用。**V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED。** 完成集中交付后停止，等待Astra一次性独立验收；不自动恢复37/SDK链或后继版本。


## 2026-10-25 同一长任务继续：加载根因与RTC异步取消修复（最新）

**PARTIAL / OPEN_BLOCKERS / AC05_OPEN / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE。** 本末章与当前manifest更新上一集中交付；前面44,070字节及历史失败原件不改。没有新版本、微任务派发、预算重置或自签接受。

### Fresh权威和源码

重新全文读取task_order（Blob `d737c3a813d81ada7a9ca9a60aa310e9e14e0960`，含F节）、冻结plan（`7d3466b3be67135dc641cfee7c7faef78937ba03`）与ACTIVE_STATE（`659eebbc773d1fc85e60d5c70a7c3ac5255ca29b`），三文档均从固定live main原始字节核Git Blob。live main已为 `9b574425d59f00903192ca7a6db450bf6c3af688`，Root `f9c4bb7b35e86282cf4a61fdaedc8638b36d334f`；接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。连续候选实时起点 `079ea1097788c533a57f5909e1e2348e0cf9e724`，开工工作树干净，未reset旧SHA。

| 本次身份 | 固定对象 |
|---|---|
| 源码Commit / 唯一Parent | `67f83b053096b181ff64366f3eaad0e5e44815f8` / `079ea1097788c533a57f5909e1e2348e0cf9e724` |
| 源码Root | `444d558e0ba6912501c3ef94a03b11625d4e89ca` |
| 完整apps Tree | `e9ed3a1dee4c892840831b0e31f6f96669fa17d5` |
| 完整services Tree | `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`（本次未改后端） |
| 连续候选分支 | `codex/v10.1.5-source-faithful-serializer-conditional-sdk` |

### TypeLoadException：已核验的实际依赖差异

原D0-C Writer实际SHA256仍 `9b494ac7e45b4a27dfaaef73b48bb6c9b60d25dc6521c32a968b80f5e3297512`，其余七项pins亦由只读核验确认。Writer明确以 `System.Web.Extensions` 的原JavaScriptSerializer构造parser；真正aggregate Serialize在Write-Aggregate，未更换Serializer、投影或fallback。

本轮以明确子进程可执行文件身份查询现有三个宿主，**没有构造Serializer、Deserialize、Serialize或启动Writer**：

| 已检查宿主 | 依赖/策略事实 |
|---|---|
| PowerShell7.6.6 / .NET10.0.12 | 有效RemoteSigned；默认加载的System.Web v4为15,144字节facade，无DefinedTypes，仅转发HttpUtility，缺少WebResourceAttribute。 |
| Windows PowerShell5.1 x64 / .NET Framework4.8.10008 | ReflectionOnly读取原Extensions引用System.Web v4；完整Framework System.Web中存在该属性；所有策略scope Undefined，有效Restricted。 |
| Windows PowerShell5.1 x86 / .NET Framework4.8.10008 | 同样ReflectionOnly确认所需类型存在，有效Restricted；未执行原被拒绝脚本入口。 |

这支持上一启动TypeLoadException来自Core宿主与Framework API依赖不兼容，不能用“GAC类型可解析”替代可运行性证明。原失败没有异常栈，**仍不能精确区分顶层assembly load、类型绑定、构造或首次Deserialize表达式的throw点**；不能猜成Serialize运行失败。当前核验仅覆盖上述具名宿主，不宣称全机不存在其它未知入口。

最初native元数据命令继承了Core模块搜索路径，Security模块autoload失败；保留exit1原stdout/stderr，随后仅在元数据子进程把PSModulePath指向已有原生PSHOME Modules后查询成功。它没有改变策略/ACL/global配置，也没有执行Writer。另一次工具shell选择仍报告PS7，该结果不作为native宿主身份，最终以显式子进程路径、版本与进程自身路径核实。未复制Framework DLL进入Core宿主、未用Bypass/脚本内容执行桥、未替换原Serializer。微软[宿主运行时差异](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell)与[JavaScriptSerializer定义](https://learn.microsoft.com/en-us/dotnet/api/system.web.script.serialization.javascriptserializer?view=netframework-4.8.1)作为依赖背景，实际结论来自本机记录。

**历史0.375秒WinPS策略拒绝与0.390秒PS7 TypeLoad启动失败两预算均保持已消费，本轮Gate2新增启动0、Writer调用0、D0-A重跑0。** 在已核宿主中尚未找到同时满足原依赖和当前脚本策略的入口，Gate2仍ENVIRONMENT_BLOCKED。正负例仍NOT_RUN，不重试被拒绝入口，不重置或再铸造一次性预算；37案例、条件Sandbox SDK、Producer/libs.jar及30解析仍NOT_RUN。

### 独立推进的真实软件缺陷及修复

RTC凭据请求未完成时离开，原 `_connecting` 要等旧Future结束才清除，可能挡住下一呼叫；旧catch/finally又可能影响同call的新attempt。用唯一attempt对象替代重复bool状态：外部leave立即取消所属attempt，内部换room保留当前attempt，迟到成功/错误/清理只能处理所属attempt。没有新权限或新RTC协议。

非作者复核发现诊断分支迟到endCall的finally，以及旧heartbeat终态/错误/finally还会影响同call重试；在同一任务内补回归复现后修复。诊断退出清理检查attempt；heartbeat以generation、room、callId及disposed检查成功、错误与inFlight清理的归属。错callId leave、授权拒绝、ICE native guard及音视频禁令保持。

| 新执行证据 | 结果 |
|---|---|
| 凭据取消回归RED | 旧11通过＋新4失败，exit1；修复后15通过。覆盖同call/不同call、迟到不可用/错误。 |
| 诊断迟到结束RED | 7通过＋2失败，exit1；修复后通过。 |
| 旧心跳RED | 9通过＋2失败，exit1；终态/错误均复现关闭同call新attempt。 |
| 最终RTC＋路由 | **95通过 / exit0**，全部三文件与实际测试副本SHA逐字节绑定。 |
| 最终诊断开关测试 | **11通过 / exit0**，含四项与普通运行重叠的基础用例，不能把95＋11当106个互异案例。 |
| 最终静态检查 | 三文件Dart analyze No issues / exit0，格式及CRLF规则diff检查通过。 |

诊断测试使用受控Room、source和native MethodChannel替身及三Dart编译开关；**未运行真实ICE、设备、SFU或麦克风/摄像头，不证明宿主ICE标志**。本轮APP源码改变，当前APK构建/安装与真实媒体测试未完成，不能把源码/单测修复当AC05闭合。条件Producer链依赖仍不越过；未把所有其它普通构建方式笼统宣称不可能。原API/MariaDB/GUI/Android期限证据可复用的部分严格标REUSED_EVIDENCE，本轮不重复无关后端/数据库测试。

### 当前AC与保护、集中出口

| AC-10.1.5 | 当前结果 |
|---|---|
| 01 | Fresh main/Root/双Tree及三权威Blob核验；22,482历史文件、五根与受保护旧refs保持，上一长任务40件具名原证Hash再核一致。 |
| 02 | REUSED_EVIDENCE：此前真实幂等/丢响应GUI/WS支持保留，非本轮新GUI。 |
| 03 | REUSED_EVIDENCE：此前MariaDB精确锁等待→COMMIT→401、WS撤权与切号/迟到响应限定结果保留。 |
| 04 | REUSED_EVIDENCE：此前真实图片/视频/Range/撤权及重启支持保留，当前新APP播放NOT_RUN。 |
| 05 | **PARTIAL_CORE_OPEN**；新增RTC取消/迟到回调缺陷有回归修复。双端流动媒体、同call真实重连、旧RTC JWT重新入房拒绝、≤5秒停止及AEC仍未证。 |
| 06 | REUSED_EVIDENCE：真正login/refresh及Android受控注入支持保留，未虚称物理30天。 |
| 07 | REUSED_EVIDENCE：原生密文/期限清理及冷启锁定支持保留，本轮未操作旧密文。 |
| 08 | REUSED_EVIDENCE：通知偏好、current-read及限定GUI支持保留，未重验完整Safety流程。 |
| 09 | 原TEST_ONLY隔离支持保留，REAL_PUSH_PROVIDER_PENDING / REAL_PUSH_NOT_RUN。 |
| 10 | PARTIAL；新增95/11及三文件分析通过；原后端92例/717断言与真实API/DB重启为复用，新APK/媒体未跑。 |
| 11 | 当前报告/manifest及准确源码对象、三文件非作者复核、六件最小独立审阅包；仍待Astra功能接受。 |

非作者Sol/high静态复核关闭上述两个发现，最终无未关闭finding，三文件完整Hash及证据限制在审阅包。其最终回复未独立读取单列的三文件analyze-final输出，主代理已核该exit0原件；不扩大其审查范围。六件公开包另经只读隐私筛查无删减项。

审阅分支 `codex/v10.1.5-loader-rtc-review-20261025`，Commit `76b6ea718ed030415a406bf07c22aaaf5a2473fb`、唯一Parent `67f83b053096b181ff64366f3eaad0e5e44815f8`、Root `d9ffa27054b5faac649445f50aa52afe8230bd48`；六件Blob及原字节已回读。[固定审阅包](https://github.com/zcx369658780/EliteSync-v10/tree/76b6ea718ed030415a406bf07c22aaaf5a2473fb/docs/_temporary_review/v1015-loader-rtc-20261025)。原两个审阅分支、报告前缀、manifest来源对象、SQL/APK/refs/dirty根、旧budget原件保留；新原证根只用LOCAL_ONLY标签 `v1015-long-resume-loader-20261025`，不上传整目录/私密原件。

原候选分支普通non-force后继发布后核Commit/Parent/Root、完整产品双Tree、两文档Blob及原始字节；交付提交自身身份由最终回读回执提供。**V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。集中交付后停止等待Astra；未改变main、系统安全设置、真实供应商或未知guest。


## 2026-10-25 同一综合长任务：Owner授权USB真机续接（最新）

**PARTIAL / OPEN_BLOCKERS / AC05_OPEN / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE。** 本章为当前结论，历史正文53,303字节原样作为前缀保留。没有新版本、微任务或预算重置；本次只更新运行证据与集中交付文档，没有修改产品源码。旧章节的`NO_HOST_APK`是历史状态；最新G节授权下已取得普通开发APK实物，不能据此升级ICE诊断标志或条件SDK门。

### Fresh权威与真实源码

开工重新全文读取唯一task_order（含F/G，Blob `43b2396b2fba046d5c0ab00bea87293783d1c2fd`）、冻结plan `7d3466b3be67135dc641cfee7c7faef78937ba03`、ACTIVE_STATE `6b443e19e968b610c795cf37ca993a9d8e60aa4d`，原字节核Git Blob。live main为`a391398fdc6a0547ba4b4354fc300def6da9acb5`、Root `85359b9dfb80f24eb083096006ce4b3f58758884`；接受v10.1.4产品仍apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。Astra局部RTC取消竞态复核Blob `d66c5b0ce1c4999698e56d2075e9f43b23d698c5`仅支持其限定范围，AC05仍OPEN。

连续候选/实际构建输入为`c445554f01fbd8c9aef641302f3f090900703786`，唯一Parent `67f83b053096b181ff64366f3eaad0e5e44815f8`，Root `a964881253000ed86601978d136dfba5820606fc`。完整apps仍`e9ed3a1dee4c892840831b0e31f6f96669fa17d5`，services仍`21eebf69bbc6397b1562d40f8cd9ebd7b246720f`；底层实现即上一已局部复核源码67f83b。**735件tracked apps文件在连续工作树与实际隔离构建副本逐项SHA256相同，构建后再次一致**；本次产品Tree未变化。完整源码pins及实际工具/命令路径仅留LOCAL_ONLY，摘要给出pins文件Hash。

### 当前APK、设备与操作边界

唯一USB目标为Xiaomi `25060RK16C`、Android16/API36、arm64-v8a。最初unauthorized，无RSA提示；一次针对目标的普通transport reconnect后成为device，未换密钥或USB策略。后续手机锁屏时仅读取焦点/锁屏状态并等待Owner手动解锁，未读取通知内容或锁屏凭据。已有目标开发包和签名核对一致，旧APK先保存，未clear/uninstall。

使用既有Flutter3.41.7/Dart3.11.5、JDK17、Gradle8.14及Android36/既有NDK缓存；源码、Flutter SDK及Gradle/Pub缓存复制至任务自有隔离构建目录。普通`:app:assembleDebug --offline`，仅`ELITESYNC_V1015_LOCAL_BUILD=true,ELITESYNC_V1015_R1_LOCAL_BUILD=true`、main.dart，未启ICE_DIAG或retention probe。**构建exit0，392.437秒，进程退出确认**；Kotlin增量缓存错误经编译器回退完成，deprecation与native符号strip告警保留。offline依赖解析不等于整进程树NO_NETWORK证明；未下载安装新工具/SDK。

- 包名`com.elitesync.v1015r1dev`，versionCode `1010511`，versionName `10.1.5-r1-dev`。
- APK 405,007,373 bytes，SHA256 `8a11cee98402bd64e04593374b9dfa06efa1a78686a7865147c93e5ae4c35582`；`install -r`后回取APK字节SHA相同，旧用户数据保留。
- 开发签名证书SHA256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`，与已有开发包一致。
- 普通Flutter AAR `1.0-v1015r1-7b05bcf44b8a`，SHA256 `ca6b3ed40864d864654648ca85ddb22d27e7c23bb118a760fff8dffe7d0f75c2`。这是本次普通APK依赖实物，不是原条件式Sandbox SDK/Producer/libs.jar验收。

仅使用合成账号、合成文字和任务专属本地会话。未读取个人照片/视频、短信、通讯录或其他应用内容；相机未启用，没有录制原始私人音视频。手机序列号、JWT/凭据、原始日志、UI XML、APK与SQL均LOCAL_ONLY，未上传整目录。

### 真机新证据、失败与限制

| 新执行 | 结果与证据边界 |
|---|---|
| 实际UI文字 | 服务端确认提示、对端真实API读回同一message id1/client_message_id，当前库仅1条，重启后仍1条。先前控制脚本误点/键盘动画断言失败原件保留，按可见UI操作完成后核无重复。 |
| 来电/呼出/拒绝/挂断 | 实际呼出call3、来电提示并拒绝call5；call7等待接听时挂断，call9/10来电接听后取消，均有UI及实际API/DB终态。不能把`in_call`或RoomConnected事件当媒体成功。 |
| 取消连接后再呼叫 | call9等待媒体连接时挂断，leave后call10再次出现真实Room.connect start；两次UI挂断均ended。未人为延迟真实endCall/heartbeat，也未运行同call重试；相应精确竞态仍引用原95/11测试，不简单相加为106个互异案例。 |
| 未过期旧JWT撤权 | call12旧JWT在撤权HTTP成功返回后剩余约118.8秒；撤权前validate200，之后validate403、首次撤权后WS403，拒绝在撤权HTTP成功响应收到后约0.360秒观察，未测精确DB COMMIT时点；当前join/聊天读写/详情404，guarded新库确认call ended、active0、消息仍1条。该JWT此前未承载媒体，不能声称成功通话的媒体重入或≤5秒停止。 |
| 冷启动 | 实际APP重启回到登录页，无旧合成联系人/消息；这不等于15/30天离线读取或新的物理30天清理实验。 |
| 通知GUI/权限 | 静默true、message类别false经真实UI持久到新库；系统通知授予后显示已允许。撤销使Android重启应用并锁回登录，PM确认denied、旧私密文本不显示，原denied状态恢复。没有执行原生授权弹窗“拒绝”，没有真实Push送达。 |
| 持久化/退出 | 本轮新独立容器/volume、迁移前0表及dump；手机/服务退出与测试账号会话撤销后，十表规范快照在该新容器重启前后完全相同。不是异库restore证明。 |

RTC传输仍有**实际阻断**：当前回环TCP7891路径上，真机Room.connect最终出现MediaConnectException；合成PC SDK对端也超时，无nominated pair或RTP。普通TCP socket可建立不代表ICE配对成功。初始PC预检采用服务端默认ICE配置并产生srflx，未抓包，因此不能声称其全程无公网STUN/进程树NO_NETWORK；停止后明确空ICE服务器列表，后续仍未连通。手机源码原已有空列表，未改共享SDK、系统策略、防火墙、路由或浏览器安全限制。精确ICE根因仍未解决，未转用LAN/UDP/公网或另一物理设备。

因此**双向真实音视频、同call媒体重连、流动媒体≤5秒停止、实际麦克风/摄像头媒体启停和物理AEC仍NOT_RUN/NOT_PROVEN**。没有用单测、模拟器、轨道事件、控制面或单条合成文字替代媒体证据。

普通失败均原样保留：SFU第一次冷启动超时而fail-closed；补足本轮RTC环境开关并预热后重启。首个撤权harness错误期待已失权通话详情200，实际404导致exit1；修正仅测试断言/取证方式，用新call重测并记录全部HTTP状态及guarded DB终态，exit0。通知harness错误期待撤销权限后页面原地恢复而exit1；保留真实锁回登录行为，另以当前PM/登录页/DB正确定义后置条件核验exit0。未放宽产品权限或删除失败来取得绿灯。

### 原Gate 2与固定预算

D0-A保持原15次Serialize、约0.688秒；旧WinPS Restricted启动0.375秒exit1、PS7/.NET10依赖TypeLoad启动0.390秒exit1均仍已消费且Writer/Serializer未运行。本次没有重试原入口、没有新Gate2预算、没有运行Writer或Serialize；此前原依赖/宿主元数据根因分析复用。Gate2仍ENVIRONMENT_BLOCKED，完整37案例、条件Sandbox SDK、Producer/libs.jar及30项Configuration.resolve()均NOT_RUN。

### 当前AC逐项结果

| AC-10.1.5 | 当前结论 | 来源及实质限制 |
|---|---|---|
| 01 | `SUPPORTED_BOUNDED_PROTECTION` | NEW_READONLY_AND_DEVICE_NEW_RUN；live main/Root/两产品Tree、43任务Blob；新空库0表、专属volume、迁移前dump；22,482文件、五历史根和受保护旧refs保持。 |
| 02 | `SUPPORTED_BOUNDED_DEVICE_TEXT_AND_REUSED_FAILURE_MATRIX` | DEVICE_NEW_RUN + REUSED_EVIDENCE；本机真实UI发送合成文字，界面服务器确认、对端真实API读回唯一id/client_message_id，数据库重启后仍1条；去重/丢响应/409与旧WS矩阵复用原证，不声称本轮双APP全量旅程。 |
| 03 | `SUPPORTED_BOUNDED_DEVICE_AND_GUARD_NEGATIVES` | DEVICE_NEW_RUN + NEW_HTTP_GUARD + REUSED_EVIDENCE；撤权后当前RTC join、聊天读写及通话详情404；未过期旧JWT validate/首次撤权后WS均403；原精确MariaDB并发与迟到HTTP/切号回归复用。 |
| 04 | `REUSED_MEDIA_EVIDENCE_CURRENT_DEVICE_NOT_RUN` | REUSED_EVIDENCE / CURRENT_DEVICE_NOT_RUN；原图片/视频/Range/撤权/持久读回保留；本次新手机未选择图库、未重做图片或视频发送播放。 |
| 05 | `PARTIAL_CORE_OPEN` | DEVICE_NEW_RUN_CONTROL + MEDIA_NOT_ESTABLISHED；实际呼出、来电提示、拒绝、接听、挂断、取消后再呼叫及撤权拒绝；双方ICE媒体连接未成功，双向RTP、同call媒体重连、流动媒体≤5秒停止、麦克风/摄像头媒体启停及物理AEC仍未证明。 |
| 06 | `REUSED_T0_BOUNDARIES_WITH_LIMITS` | REUSED_EVIDENCE；此前真实login/refresh T0与15/30边界及Android受控注入保持；本轮合成登录不是新的物理15/30天实测。 |
| 07 | `SUPPORTED_DEVICE_COLD_LOCK_WITH_REUSED_RETENTION` | DEVICE_NEW_RUN + REUSED_EVIDENCE；本轮冷启动、OS权限撤销重启均锁回登录页，不显示旧合成联系人/消息；既有原生密文/受控30天删除复用，未把本轮冷启当完整离线或实际30天清理验收。 |
| 08 | `SUPPORTED_BOUNDED_DEVICE_NOTIFICATION_PRIVACY` | DEVICE_NEW_RUN + REUSED_EVIDENCE；真机静默/消息类别开关持久到本轮MariaDB；通知权限授予显示已允许，撤销后锁回登录、PM确认denied且恢复原态；原生权限弹窗拒绝NOT_RUN，旧RTC卡片在撤权后无当前可读提醒。 |
| 09 | `REAL_PUSH_PROVIDER_PENDING` | REUSED_TEST_ONLY / REAL_PUSH_NOT_RUN；未接真实Push Provider/SDK/Key/生产服务；本轮账户notification_devices为0，不把OS权限授予当远端投递。 |
| 10 | `PARTIAL_MEDIA_OPEN_CURRENT_APK_VERIFIED` | DEVICE_NEW_RUN + BUILD_NEW_RUN + REUSED_TESTS；本候选普通R1 main.dart APK构建exit0、更新安装及回取字节一致；新DB十表重启一致、手机消息仍1条；原后端92/717、Flutter152及RTC95/11为复用，媒体/条件SDK链仍未通过。 |
| 11 | `CONSOLIDATED_DELIVERY_AWAITING_ASTRA` | CODEX_REPORTED / BOUNDED_NON_AUTHOR_REVIEW；唯一报告/manifest、当前产品Tree、最小脱敏审阅包和LOCAL_ONLY原证Hash；非作者静态结果另列，不代替Astra独立功能接受。 |

### 恢复点、非作者复核与集中出口

最终本轮独立库SQL `185561` bytes / `6420a4292c281b9f4d514e0099457a2e3b259dfd86524091f603b3bf124938af`，连同事前空库dump、重启前备份、原始Hash/命令/退出/耗时留LOCAL_ONLY。所有本轮合成账号session family与access token已撤销，activeCalls=0；手机APP进程已退出、开发包保留。API/WS/authority/bridge、SFU、合成浏览器及自有Gradle daemon已停；七个本轮端口释放，四个本轮ADB reverse移除并恢复先前空列表。专属容器/volume与旧资产保留；全局adb/Docker daemon未擅自关闭。

22,482具名保护文件、五历史根、516旧refs中的受保护项再核保持；此结论不等于整盘或其它应用/设备状态审计。最小审阅包为派生脱敏摘要与具名原证Hash，原始字节不外传。非作者只读审查状态：**SUPPORTED_BOUNDED_EVIDENCE_REVIEW**；范围及Hash以其单列回执为准，不代表Astra运行或接受。`codex/v10.1.5-usb-device-review-20261025`，Commit `0eada1acbbf834fdcdcb3777f55c972daad5d643`、唯一Parent `c445554f01fbd8c9aef641302f3f090900703786`、Root `38fc229033c4f6a7a8df2ac7f3453185c67dfa73`；7件原始字节/Blob另经回读。

本次普通non-force候选后继只提交唯一报告和manifest，最终Commit/Parent/Root、两文档Blob/原始字节及完整产品双Tree由最终远端回读回执给出，避免自引用。**V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / HOST_APK_BUILT_INSTALLED_BYTE_VERIFIED / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / REAL_PUSH_PROVIDER_PENDING。** 完成交付即停止，等待Astra一次性独立验收。

## 2026-10-25｜ICE 与媒体续接集中交付（最新）

**PARTIAL / OPEN_OBSERVATIONS / AC05_OPEN / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE。** 本章接续同一综合长任务；本次已有真实双向媒体及同 call 手动重连证据，仍不自行接受整版。此前报告 `65594` 字节原样作为前缀保留，原 USB 交付、Astra 有界接受和所有失败均不倒改。

### 权威、实时身份与本次源码

开工全文核对 task_order（含 F/G，Blob `43b2396b2fba046d5c0ab00bea87293783d1c2fd`）、冻结 plan `7d3466b3be67135dc641cfee7c7faef78937ba03`、ACTIVE_STATE `5867eb97b59d97bd60490cc77fb07e2838888d27` 和 Astra USB 复核 `ca03fefe53946784adba0fd94f80507fee656fd1`。开工及发布前 live main 均为 `bee04025237ea099b2b274d06a12cfa2bab5b5e1` / Root `683d8fe2268adbeca05da0ce31224b67d042223c`；接受 v10.1.4 产品仍为 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本轮没有集成产品 main。

连续分支开工及写入前远端为 `dad5d8fe36874095c90e25f651775796bfeba7eb`。本次两个源码提交为 `08df5042378a5887f36e9a1033ff654d993cc38a` → `80f6292a2c3726716ab82152f36428812f23058f`，前者唯一 Parent 为 dad5d8fe，后者唯一 Parent 为 08df5042。**最终待验源码 80f6292a / Root `5dbb0ae4c64bb7cce6db0e4be03625bfa678aed2` / apps `a0ca61faf9e1264f7ae4b638c78ebeae257ea002` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。** 仅 RTC service、page 及其两份测试改变；后端未随本轮源码提交改变。735 件 tracked apps 文件在最终构建副本与实际工作树逐项 SHA256 相同，构建后再次核对一致。

### ICE 定位、单项授权与普通源码返修

同配置复现先证明实际 TCP 连接和 STUN 已到 SFU mux，而没有 STUN 响应或 nominated pair。不能沿用“浏览器根本没到监听器”的旧中间推断；宿主 source-bind socket 失败也不能独自充当 RTC 根因。LiveKit/Pion 对应公开源码表明候选注册使用原始接口 IP，接收路径按 socket 本地 IP 查队列；重复映射为回环地址的候选及实际接收地址与该错配假说一致，但未直接观测原 orphan queue 的 reader 状态。

ACTIVE_STATE 明确限制自行更改 ICE 配置，因此本轮就一项具体试验取得 Owner 直接授权：**仅在本轮自有 SFU 的 rtc 中增加 `interfaces.includes: ["eth0"]`**。node_ip、端口、回环入口、guard、凭据及其它 ICE 参数不变；宿主发布端口再次核实全为 127.0.0.1。接口过滤本身不是监听地址限制；容器内 TCP listener 仍可监听通配地址。既有 image 固定为 `sha256:32d59377b1bd55507719fced7c63efaf441423ab208fc080af0e17bdcfe7276e`，binary 自报 1.13.10；公开 tag 到运行 binary 的逐字节构建映射未证明。无工具下载、共享 SDK 修改、系统网络/防火墙/路由/执行策略变化或公网媒体测试。

单变量试验后真实 SDK 在 1.437 秒连接并产生 STUN 响应与成功提名；该控制脚本随后因 IPC JSON 文件写入尚未完成而 exit1，finally 已结束通话，原件保留，不能称整个控制脚本 PASS。修正证据读取后，手机与合成 PC 对端实际建立双向 RTP。call4 还验证了 mic/camera 开关在对端变为 muted/unmuted，但 SFU 全量重启暴露 native `addTransceiver(): track is null`，手机出站 publication 消失；call4 的重连不能标通过。

08df5042 在全量重连事件时关闭旧 room，通过现有同 call “重新连接”重新读取当前通话和 join 权限并创建新轨道；轻量 resume 事件独立，不被该处理拦截。旧 room 完整 disconnect/dispose 的 Future 屏障阻止新 room 过早启动；disconnect 抛错仍尝试并等待 dispose。旧 room 的 track 事件不能污染新 room。两处清理竞态都先由新测试复现 RED，再修复。

真机返修复测又发现定时刷新用 skeleton 替换内容导致滚动位置丢失。80f6292a 仅保留 refresh 期间的现有内容和控件，reload、身份改变及真实 error 的关闭分支保持；重连操作仍 fresh fetchCall + fresh join。两个真实 AsyncLoading widget 回归先 RED，修复后 **40 项相关 Flutter 检查 exit0**，含错误后再次 pending 不恢复旧内容、取消/迟到响应及终止态边界。Dart 定向静态检查 exit0。一次 Flutter analyze 因隔离 SDK 副本未包含 dev 目录而工具崩溃，保留原 exit1；随后使用该副本自带的受支持 Dart analyzer 完成检查，没有修改全局 SDK。

### APK、同 call 真机媒体与停止时序

在任务自有隔离构建目录使用既有工具/缓存，普通 `:app:assembleDebug --offline`；未启 ICE_DIAG 或 retention probe。两次新构建均 exit0、退出确认，耗时分别 329.625 / 198.329 秒；编译告警原件保留。离线依赖解析不等于整个进程树 NO_NETWORK 证明。

最终包仍为 `com.elitesync.v1015r1dev` / versionCode `1010511` / versionName `10.1.5-r1-dev`，**416,357,439 字节，SHA256 `cbe80dff68fad1a0734557af434cd1d959e194d30b7a1f10969c7ff13f96f59c`**。更新安装保留数据，签名相符；从授权 Xiaomi 25060RK16C、Android16/API36、arm64-v8a 手机回取的 APK 字节 Hash 与构建产物一致。序列号只保留 LOCAL_ONLY。中间包 f26bb08f 原字节保留；最终包 ZIP entry 集合相同、无重复 entry，仅两 ABI libapp 内容改变，额外文件长度属于容器布局/间隙，不能说新增了依赖或混入另一 APP。

**最终 APK 的 call10**：接听后有真实音频/视频双向 RTP；仅重启本任务 SFU，媒体关闭后用实际页面按钮手动重连同一 callId。两次 join-info 读取、旧 room 清理结束、新轨道发布及对端两条已订阅未静音轨道相互对应。重连后四类 RTP 报告均有相隔约64秒的17批采样，计数增长；手机 inbound video 有实际 framesDecoded。视频多 SSRC 按每批报告求和看趋势，不冒精确 wire-byte 计费或唯一流数。没有将新 call 冒称同 call，也未将 `in_call` 或 RoomConnected 单独当媒体证据。

撤权采用**仅限新隔离库、三个精确合成账号、call10 的真实 LiveConsentService::transition**，不是手工设置假回执。先前包含旧 JWT 握手的组合脚本被自动审批拒绝、未执行，没有换入口重试该组合；本次获工具允许的收窄方法不包含 JWT 签发或 WebSocket 负例。两项 MC 变为 MC_REVOKED；同 call 手机产生新的 native leave_complete，对端 disconnected。**从产品服务 transition 前到收到手机清理完成日志的保守上界为 0.790 秒**；COMMIT 位于区间内但未直接打点，不能误称“COMMIT 后精确0.790秒”。清理成功不能仅凭 best-effort 的 leave_complete：现有同一 PID 的新原证另有两次 peerConnection CLOSED、AudioRecord stop done、AudioTrack stop done、camera release，均已在这次上界内收到；不独立宣称整个 Room.dispose 的返回成功。这是 TEST_ONLY 服务层撤权夹具，未宣称本次走了 HTTP/UI 撤权入口。当前 join API、图片/视频完整与 Range 读取随后均404，APP显示无旧详情的通话加载失败。

Owner 对 **同 call10** 直接反馈“听到滴声，结束后已停止”。这是这次合成音的有界听感，不拼接 call4，不是物理 AEC、双人语音可懂度或最后扬声器波形停止计量。**SDK remote PCM capture 清理仍记录一次 ConcurrentModificationError**；本次 fresh 双向媒体和最终清理均已观测，未隐瞒该异常、未声称零异常或修改共享 SDK。该观察项保持开放，交 Astra 判断。

### 独立媒体/通知及证据复用边界

Owner 只选择本轮生成、Hash 固定的纯蓝 PNG 和2秒 H264 彩色测试 MP4；未浏览或导出私人图库。真实 APP 图片发送被服务器确认，对端读取校验为蓝色320×240 JPEG：picker 重压缩，不能声称原 PNG 字节相同。视频首轮未形成消息；本轮 API 进程缺少现有 ffprobe 显式路径，原失败 HTTP 响应未抓到，故不虚构422原证。只补任务 API 进程配置后重新选择，视频 ready/200/206、原文件与完整读回 SHA256 `91efa89716d27ca5528cf2b8182b2719d756c24f3fdc34ce50753fc160e25852` 相同，实际私有播放器显示了变化的合成帧。另一个早期同蓝资产未绑定消息，保留原状；最终仅一条图片和一条视频消息。

真实通知授权弹窗已明确点击拒绝，系统权限仍 false，应用消息和安全入口可用；没有强清 user-fixed 标记或接入真实 Push。旧通知没有当前可读卡片，未冒称已验证不存在卡片的点击路径。图片/原生通知拒绝发生在此前8a11包，视频在中间 f26b 包；最终 cbe8 只改变 RTC 文件，这些作为同任务中未变代码的复用证据，**不重标为最终 APK 上新执行**。最终包冷启动回登录为新证据；实际15/30天经过时间、AEC/真实语音质量仍未运行。

### AC-10.1.5-01～11（本章为最新汇总）

| AC | 结果与证据边界 |
|---|---|
| 01 | NEW_RUN：实时权威/Root/双 Tree、全新独立空库与 volume/有效选择器、22,482具名保护文件、五根及519旧 refs 中保护项保持。不是整盘审计。 |
| 02 | REUSED_ACCEPTED_USB_TEXT + NEW_DEVICE_MEDIA：旧真机文字、幂等/冲突/重试证据复用；本轮新图片/视频各一条，未声称新增文字重试测试。 |
| 03 | NEW_SERVICE_REVOCATION + REUSED_SECURITY：call10当前 join/媒体拒绝和旧room隔离回归；原 Astra 已接受旧 JWT/握手拒绝复用，本次成功媒体 token 的旧 JWT 握手 NOT_RUN。 |
| 04 | NEW_DEVICE_PICKER_PLAYER_RANGE + REUSED_FINAL_BINARY_UNCHANGED_CODE：合成图片/视频真实选择/发送/读回/播放、200/206与撤权404；中间包边界如上，不能当最终包重跑。 |
| 05 | PARTIAL_MEDIA_NOW_SUPPORTED / AC05_OPEN：最终包同call10双向RTP、解码、手动重连、保守0.790秒native退出上界、同call滴声停止反馈；AEC/双人语音品质未证明，SDK清理异常观察仍开放。 |
| 06 | REUSED_T0_BOUNDARIES_WITH_LIMITS + NEW_LOGIN：真正在线登录/T0旧边界测试复用；不把新登录当实际经过15/30天。 |
| 07 | NEW_FINAL_COLD_LOCK + REUSED_RETENTION：最终安装启动锁回登录；原设备密文/受控30天清理复用；物理15～30天离线只读及实际经过30天未运行。 |
| 08 | NEW_NATIVE_PERMISSION_DECLINE + REUSED_PREFS：原生拒绝及仍可用的新证据，旧偏好/撤销证据复用；无旧可读卡片的点击仍NOT_RUN。 |
| 09 | REAL_PUSH_PROVIDER_PENDING / REAL_PUSH_NOT_RUN；原隔离 transport/token 生命周期为REUSED_TEST_ONLY。 |
| 10 | NEW_BUILD_INSTALL_MEDIA_DB + REUSED_BACKEND：最终包构建/回取同Hash、735输入一致、40项Flutter定向检查；本轮DB12表重启一致；旧后端检查复用；Gate2链未运行。 |
| 11 | 集中报告/Manifest、源码四文件最小diff、非作者源码与有界证据复核、脱敏短期审阅及普通候选发布；最终身份由独立远端回读绑定，不自行Astra接受。 |

### 历史预算、收尾与交付

D0-A保持15次 Serialize、约0.688秒；WinPS策略拒绝0.375秒、PS7 TypeLoad启动失败0.390秒两预算已消费。本轮新 Gate2启动0、Writer/Serializer调用0；37案例suite、条件 Sandbox SDK、Producer/libs.jar和30项解析仍NOT_RUN，不能与40项Flutter检查混淆。

测试账号全部撤销，activeCalls/active session families/access tokens 均0；手机APP进程、合成PC浏览器/8054、本任务PHP/bridge、SFU和DB已停止，专属ADB reverse恢复开工空状态，任务Gradle进程停止。容器/volume、SQL/APK、原 dirty 根、历史 refs/失败保持。12张业务/媒体表规范化快照在专属DB重启前后完全相同，两条消息/两附件保持；SQL dump本身含时间等差异，未声称两dump原始字节相同。物理设备未清数据、未卸载其他APP，测试包与合成测试素材保留。

LOCAL_ONLY 原证根标签 `v1015-ice-loopback-continuation-20261025`；原始日志、SDP、令牌、SQL、APK、UI及截图不上传。曾有控件裁图包含预览边缘，该图和原图均不进入公开包。最小脱敏审阅包见 `https://github.com/zcx369658780/EliteSync-v10/tree/2f238f8b72558ee965a1d628f937fd3f19eb7df3/docs/_temporary_review/v1015-ice-loopback-media-20261025`，Commit `2f238f8b72558ee965a1d628f937fd3f19eb7df3` / Parent `80f6292a2c3726716ab82152f36428812f23058f` / Root `113352597d2d4fd82373700aac4df369f20f3d9b`，十件文件逐项 Blob/原字节回读。候选随后仅追加本报告和Manifest，普通non-force发布；精确Commit/Parent/Root/Blob/原字节/产品双Tree见独立最终回读。

保持 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / REAL_PUSH_PROVIDER_PENDING`。本次未自行宣布Astra或整版接受，集中交付后停止。

## 2026-10-25｜PCM capture 清理返修集中交付（最新）

**SDK_CLEANUP_REPAIR_CANDIDATE / PARTIAL_NOT_ACCEPTED / AC05_OPEN / AWAITING_ASTRA_INDEPENDENT_REVIEW。** 本章继续同一综合长任务。修复前已用真实 SDK 复现异常，修复后定向检查与受影响真机路径获得有界支持；没有自行关闭 Astra 的观察项或接受整版。此前 78699 字节报告原样作为前缀保留。

### 实时权威、源码与最小改动

开工及发布前重新核验 live main `2d5467e8de5b5a87d086e0767b31318109e5c1cb` / Root `9fb331e395179f64380985afd27578bcb784f5e3`，冻结 task Blob `43b2396b2fba046d5c0ab00bea87293783d1c2fd`（含 F/G）、plan `7d3466b3be67135dc641cfee7c7faef78937ba03`、ACTIVE_STATE `635dbb2d5741fee941eadfef4f32b5ddf9cae252`、最新 Astra 复核 `221809532229947ae298ca76f84bd98690c94bfa`。接受产品仍 v10.1.4：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。

连续候选远端开工为 `2204c7439cca344795a9a4cc5e9c4d3e27b30d12`；源码后继 **`1f9d1483268e957f7184625483ff6406071c1867`**，唯一 Parent `2204c7439cca344795a9a4cc5e9c4d3e27b30d12`，Root `9beff929abf3939ac863cd4096ee9fb09a64a48d`，完整 apps `a5c6182ea9e064db4ef73e1627a6e38591c953cc` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。后端源码未随本轮改变。最终隔离构建全部 **1036 件 tracked apps 输入**与该连续工作树逐项 SHA256 相同，构建后再次核验；原 dirty 根保持。源码查询图谱没有当前工作树索引，本轮使用具名源码和精确 diff，不把旧图谱当当前身份。

原 LiveKit 2.10.0 的 `AudioTrack.stopCapture` 在 await native stop 时遍历 live Map；页面 renderer cancel 同时移除组，触发 ConcurrentModificationError。还确认重复 native stop 与旧 cancel 删除替换组的问题。remote participant 的停止顺序使 APP 的 TrackUnsubscribed 事件无法可靠提前串行化这段 SDK 私有清理。

因此将**既有缓存的 2.10.0 运行源码**纳入 `apps/flutter_elitesync_module/third_party/livekit_client`，使用应用自有 path 依赖 `2.10.0+elitesync.1`，没有下载升级或修改共享 SDK。原包 archive SHA256 `9160950ff87d1946959e4911c16236ea7a3e74ac1987990b258132fd4ed0fca9` 保留；具名上游 local.dart Blob `3a3cea8c67d7ea5985df7e80f0791ba5664892dc` 与原缓存原字节一致。297 件原运行文件中 **295 件完全不变**，仅 local.dart 和 pubspec.yaml 有明确修改；LICENSE/NOTICE/版权头保留，两个修改文件均加修改声明。另三件文件说明来源、297 文件原 Hash 和完整两文件最小 upstream diff。Dart 示例/测试/顶层 fixtures 未复制；平台目录内 native tests 原样保留。

行为仅为：同步 snapshot 并清空 Map 后再 await；旧 cancel 只移除自己仍拥有的组；每组 stop 共享单次 Future 并同步停止回调；track 等待包括 cancel 在内的所有在途清理。真实 PCM 频谱保持。APP pubspec/lock 仅改该依赖，其余版本和原 lock 校验值保留。Android AAR digest 和 Gradle inputs 加入 lock 与自有 SDK，避免依赖变化复用旧 AAR。除应用依赖接线、构建输入、八例测试及 vendored runtime 外无新产品功能。

关键最终源码 SHA256：local.dart `bcee035a699ba345e84291a5c8cc246a5e93cad9624d4c4110ce435c848a3686`；八例测试 `0da1a9b412766d13850ceabd4ec53015296b2dfb5dbfd7a12ecdd84b800fc4f4`；完整 upstream patch `8e746f1508bc33fb223f809eb5344f0e6c9a4870c2645339d7eb8ca955d9eecf`。其余文件路径、行号、Git Blob 与实际 Hash 见审阅包 source-reference/non-author-review。APP pubspec 沿用工作树 CRLF、Git 规范 LF，两种 Hash 分别标注；297 件 vendor 文件 Git Blob 与实际原字节全部相同。

### 原始失败、定向回归与构建

- **RED：原版 SDK 六例 1 通过 / 5 失败，exit1，24.969 秒**；真实复现 ConcurrentModificationError、重复 native stop、旧 cancel 丢失新组归属。原 stdout/stderr 保留。
- 修复后六例通过；新增等待完成、多格式和迟到帧边界后八例通过。最终源码上的 **48 项相关 Flutter 检查 exit0，26.422 秒，退出确认**，包含八例新 PCM 边界与既有 40 项 RTC service/page/spectrum；中间计数不重复累加为独立案例。
- 测试直接执行真实 RemoteAudioTrack、grouping、订阅、cancel 和 stopCapture，仅替换 MethodChannel/EventChannel 的 native 传输；不是复制清理算法。Native start/stop 原有错误处理未改变，不能因此宣称平台故障均可恢复。
- 定向 Dart analyzer 最终 exit0、No issues found。最初未使用 import 的 info 已移除；未改变行为。非作者只读静态复核为 NO_NEW_BLOCKING_FINDINGS_STATIC，许可证逐文件修改声明及 README 范围问题已修正；另核五件脱敏材料，未发现将失败、单测或旧证据冒称新真机 PASS 的矛盾。复核没有亲自执行测试或读取原始设备日志，不代替 Astra。
- 中间普通构建 exit0，335.563 秒；纳入最终构建指纹/许可证声明后，**最终普通 `:app:assembleDebug --offline` exit0，197.953 秒，退出确认**。既有 deprecation/工具告警原字节保留。未启 ICE_DIAG/retention probe，使用 R1 main.dart；离线依赖解析不等于整个进程树 NO_NETWORK 证明。

### 新 APK 与有界真机清理验证

同一授权 Xiaomi 25060RK16C / Android16 API36 / arm64-v8a 手机现装旧包先回取，仍为前次已验 `cbe80dff...`。手机曾临时拔离，未连接时不安装、不改 USB；Owner 接回后再次核对。新包 `com.elitesync.v1015r1dev` / code1010511 / name10.1.5-r1-dev，**416357439 bytes，SHA256 `83f622f301803d92ccb92650b614334914db97f75ac1dffe5eb5a057257fd678`**，原开发签名一致，`install -r` 保留数据，回取 APK 字节 Hash 相同。首次启动锁在登录页，随后仅登录本轮新空库中的合成账号。序列号、令牌、原始日志/UI/APK/SQL 均 LOCAL_ONLY，没有拍录或上传私人音视频。

在新专属库/volume、原有回环服务、获准的既有 eth0 过滤 SFU 配置与合成 PC 对端中，仅补受影响路径。**call1 实际接听、媒体连接→仅重启本任务 SFU→实际同 call 页面重新连接→新媒体持续流动。** 重连后的四类音视频收发 RTP 各有约16秒的计数增长，真机视频解码增长。随后 harness 为找挂断控件执行 uiautomator 时未获得 UI idle，**脚本 exit1，不能称该脚本整段 PASS**；finally 通过真实服务 API 结束当前 call、关闭对端，原始失败完整保留，没有重新跑已接受旅程。

清理后仅补 **call2 的新连接**：实际接听，真实双向 RTP/解码继续增长，对端两条轨道已订阅未静音；再通过真实 service API 结束，补测脚本 exit0。本轮两次结束均不是新的 UI 挂断验收，也不是新撤权时间实验。两个 call 的八类分组计数全部增长；同一新进程日志有六次 PeerConnection CLOSED、三次 AudioRecord stop done、三次 AudioTrack stop done、三次 camera release（重启、call1结束、call2结束），没有 ConcurrentModificationError/Unhandled Exception/PlatformException/MediaConnectException/StateError 字符串。**这些是限定日志窗口内的观察，不是全平台零异常或 native PCM handle 全量普查。**

既有 Astra 接受的同 call10 媒体、约64秒17批采样和撤权保守0.790秒 native 停止证据全部保留为 REUSED_ACCEPTED_EVIDENCE；未重测、未改写为本轮结果。本轮没有新的人耳听感/AEC/波形停止计时，没有独立证明 Room.dispose 整体成功、所有平台错误恢复或成功媒体 token 的旧 JWT 重入负例。

### AC-10.1.5-01～11（本章为最新汇总）

| AC | 当前结果 | 来源与限制 |
|---|---|---|
| 01 | `SUPPORTED_BOUNDED_PROTECTION` | NEW_READONLY_AND_NEW_OWNED_DB；Fresh authority, accepted v10.1.4 trees, new empty owned DB/volume; 1036 app input pins; 24005 named files, five roots and protected old refs unchanged. |
| 02 | `REUSED_ACCEPTED_MESSAGE_EVIDENCE` | REUSED_EVIDENCE；Prior text/idempotency/timeout/retry and media message evidence retained; this focused PCM run sends no new messages. |
| 03 | `REUSED_ACCEPTED_AUTHORIZATION_WITH_LIMITS` | REUSED_EVIDENCE；Prior revocation/old JWT/current-read and race evidence retained. No new successful-media-token JWT reentry or revocation timing test. |
| 04 | `REUSED_ACCEPTED_DEVICE_MEDIA_WITH_BINARY_LIMITS` | REUSED_UNCHANGED_MEDIA_CODE；Prior synthetic picker/player/200/206/404 evidence retained at its original APK identities; not relabeled as a new final-APK journey. |
| 05 | `PARTIAL_AC05_OPEN_PCM_REPAIR_CANDIDATE` | DEVICE_NEW_RUN_AND_REUSED_ASTRA_ACCEPTED_MEDIA；Real same-call restart/rejoin and followup real audio/video after cleanup; counters and decode grow; no CME in captured process log. Both endings are service API paths. No new AEC, human hearing or exhaustive native handle census. Repair awaits Astra. |
| 06 | `REUSED_T0_BOUNDARIES_WITH_LIMITS` | REUSED_EVIDENCE_AND_NEW_SYNTHETIC_LOGIN；Previous real login/refresh T0 and boundary tests retained; physical elapsed 15/30 days NOT_RUN. |
| 07 | `SUPPORTED_NEW_COLD_LOCK_WITH_REUSED_RETENTION` | NEW_DEVICE_ENTRY_AND_REUSED_EVIDENCE；New APK first entry requires login; prior ciphertext and controlled purge retained; physical 15-30 day offline read and actual 30 elapsed day cleanup NOT_RUN. |
| 08 | `REUSED_NOTIFICATION_PRIVACY_WITH_GUI_LIMITS` | REUSED_EVIDENCE；Prior permission decline/revoke/preferences retained at original identities; no new stale-card GUI scenario or push delivery. |
| 09 | `REAL_PUSH_PROVIDER_PENDING` | REUSED_TEST_ONLY_REAL_PUSH_NOT_RUN；Provider transport/token seam retained; no real supplier, credentials or external delivery. |
| 10 | `SUPPORTED_TARGETED_PCM_BUILD_DEVICE_DB_WITH_OPEN_GATES` | NEW_BUILD_DEVICE_DB_AND_REUSED_BACKEND；Final 48 related Flutter checks, targeted analysis, source-matched APK install/pull and twelve-table owned DB restart snapshot equality. Old backend tests reused; Gate2 dependencies NOT_RUN. |
| 11 | `CONSOLIDATED_PARTIAL_CANDIDATE_AWAITING_ASTRA` | SOURCE_STATIC_REVIEW_AND_SANITIZED_READBACK；One appended report/manifest, source commit and nine-file review branch; raw evidence local. No self acceptance, main integration or successor. |

### 预算、恢复点、发布与停止

D0-A 仍为15次 Serialize/约0.688秒；WinPS策略拒绝0.375秒、PS7 TypeLoad启动失败0.390秒两历史预算已消费。**本轮新 Gate2 启动0、Writer/Serializer调用0**；37案例、条件 Sandbox SDK、Producer/libs.jar/30解析均 NOT_RUN。普通 Flutter SDK 修复与这条条件 SDK 链不混淆。

本轮测试结束后 activeCalls/session families/access tokens 均0，手机APP进程退出，合成浏览器、API/WS/authority/bridge、SFU、DB及任务 Gradle 均停；四条专属 ADB reverse 恢复先前空状态，七个本轮端口释放，容器/volume 保留。新库12表规范化快照重启前后相同，本轮 chat_messages=0；不是重跑旧消息旅程。最终 SQL 155947 bytes / SHA256 `6926afa77402b23446d929b173fe989fe63c0d8a504dcf0442b32d5ae761516d` 及前置空库、重启前备份均保留 LOCAL_ONLY；两个 dump 的原字节 Hash 不相同，不冒称 dump 字节相同。24005具名保护文件、五历史根及520开工 refs 中受保护项保持；不是整盘审计。

LOCAL_ONLY 根标签 `v1015-pcm-cleanup-continuation-20261025`。最小脱敏审阅包为九件文件，普通 non-force 分支 `codex/v10.1.5-pcm-cleanup-review-20261025`，最终 Commit `d2ff4693000c774f50d09eee5396d7b7a6bbc4f8` / Parent `b1efcfb5f13dd78279f4aafbdb78424037595aac` / Root `2b0b49595af683e4442809304fb8e277bbb6d8aa`，source base `1f9d1483268e957f7184625483ff6406071c1867`；初始审阅提交保留。九件文件 Blob/原始字节及审阅 Commit/Parent/Root 已远端回读。地址：https://github.com/zcx369658780/EliteSync-v10/tree/d2ff4693000c774f50d09eee5396d7b7a6bbc4f8/docs/_temporary_review/v1015-pcm-cleanup-20261025 。原始设备/DB/凭据证据不上传；审阅派生结果去掉已过时的阶段标记，原始回执未改。

候选原分支普通 non-force 发布上述源码及本章报告/Manifest；最终 Commit/Parent/Root、两文档 Blob/原字节与产品双 Tree 由独立远端回读绑定，避免自引用。保持 **V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / SDK_CLEANUP_REPAIR_CANDIDATE_AWAITING_ASTRA / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / REAL_PUSH_PROVIDER_PENDING**。集中交付后停止等待 Astra，不自行接受、合 main 或启动下一 Gate。

## 2026-10-25｜剩余验收综合长任务集中交付（最新权威汇总）

**V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / REMAINING_ACCEPTANCE_CANDIDATE / AWAITING_ASTRA_INDEPENDENT_REVIEW。** 按同一冻结版本继续完成当前可执行范围；未自行接受整版。前 91517 字节报告原样保留，本章覆盖旧章节的当前状态，不改写旧运行或失败。

### 权威、产品和源码身份

正式剩余任务 Blob `fec31d6318524a40b9ff8f0dab49b60aa7fa3490`；冻结 plan `7d3466b3be67135dc641cfee7c7faef78937ba03`；原综合 task_order 含F/G `43b2396b2fba046d5c0ab00bea87293783d1c2fd`；ACTIVE_STATE `fdfbb4177c9c3b7272e01833914b2105845d5c22`；Astra上次PCM局部接受 `327ca8f7c68bf469c412a24129dc4d83c7742fe5`。Fresh live main仍为 `36593e0b5082602f2060fae94d7e88894a1193f4` / Root `84751dbee1ebe9c89021084d1a7691560b3ab007`，完整已接受产品 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。这些是v10.1.4产品树，未把候选当产品main。

源码 Commit **`a25e7c1012bce3f2a2d7048f284f17ebd8a0915c`**，唯一 Parent `1a3a9ff9daa315fe5e688f6f0aab8e378e1db97c` / Root `21243e8f60dccae5106d9d04bd739ef587d05646`；候选完整 apps `db3a2936ee37bf9610053fb8fd67b360fc377a94` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。17件源/测试/来源文件变化；后端源码不变。1040件 tracked apps 构建输入在构建前后均与实际连续源码逐项匹配。关键14件路径/SHA256/Git Blob和完整改变路径见审阅包 source-reference；连续工作树不是受保护原dirty根，未reset任何旧状态。

### 本轮实现及真实失败回归

修复三项：inactive AudioTrack已经启动PCM但旧stop提前false导致漏清；Room.dispose并发提前返回且早期错误可跳过后续资源；publication通用disposer吞track错误使Room可能误报完成。现在track dispose等待PCM；disposing/disposed或持久停止失败后不接受新renderer；Room专用memoized Future让并发调用共享同一完成/错误，所有拥有的阶段均尝试后再抛首错。Room移除前snapshot track/publication并直接等待，以保留真实publication链中的PCM错误。APP明确按renderer cancel→disconnect→dispose等待，记录完成或失败；失败后不将leave冒成成功，也不直接开始下一join。

**generic Disposable原字节不变。** 新增local直接清理对true采用dispose、false采用stopCapture；未改变上游publication本来仍可停止false选项local track的行为，不宣称完整修复该上游选项语义。APP使用默认true。频谱动态绘制排除semantics并保留稳定标签；此改动没有使系统uiautomator在实时媒体中可靠idle，取证工具问题单独处理。有限信号统计抽出纯函数，未存原始PCM。

应用自有LiveKit仍来自既有2.10.0缓存，版本 `2.10.0+elitesync.2`，未下载/升级/修改共享SDK。297件上游文件中292原字节不变，5件具名patch（room.dart、native.dart、local.dart、track.dart、pubspec.yaml）；另一本地包内测试不计入上游297。LICENSE/NOTICE、逐修改声明、上游Hash清单及完整patch保留。非作者源码静态复核 `NO_NEW_BLOCKING_FINDINGS_STATIC`；它没有亲自跑设备/测试，也不代替Astra。

曾发现本轮代理未署名的local.dart及四例增量。Owner明确回复没有其它会话后，原字节和diff已封存、逐项审查并通过回归后纳入本候选；**作者来源仍未确认**，不改写为已确认作者。

原接受SDK对新增dispose用例RED：8通过/10失败，exit1、25.969秒；native停止错误RED：1通过/3失败、exit1；真实Room→RemoteParticipant→Publication→inactive RemoteAudioTrack链RED：吞异常使预期PlatformException未返回、exit1。原始stdout/stderr均保留。修复后最终 **67项相关检查exit0，6.078秒，退出确认**，含PCM15、native failure4、Room3、publication1和关联RTC/UI/spectrum44。SDK测试执行真实track/Room/publication算法，native传输及受控Engine生命周期边界被替换；APP/UI检查使用显式fixture，不声称物理平台故障恢复已全证明。另17项ICE guard检查exit0，3.438秒；这些不是设备诊断旗标证明。

Dart分析exit0：0错误、0告警、19条既有上游样式info；19条均逐行与原上游匹配，未新增ignore/降低门槛。普通debug离线构建exit0、320秒、退出确认，使用R1 main.dart，未开ICE_DIAG或retention probe。离线依赖解析不等于整个进程树NO_NETWORK证明。

### 最终APK、真机按钮与清理链

同一授权Xiaomi 25060RK16C / Android16 API36 / arm64-v8a，ADB device。最终包 `com.elitesync.v1015r1dev` / code1010511 / name10.1.5-r1-dev，**405007373 bytes / SHA256 `68e9bc37c785976713a7fbe0d18f82c1dcde0d1bbfe2641e26558e71f8cb2717`**。先回取旧已接受83f622包；新包签名一致、install-r保留数据、安装后回取Hash完全相同。新冷入口锁登录，只用任务专属新空库合成账号登录。没有读取私人图库/短信/通讯录或保存原始私人音视频；设备标识、JWT、UI树/日志、APK和SQL原件均LOCAL_ONLY。

call1系统dump无法idle、call2重复UiObject查询超时，均exit1并在finally真实API结束，未标PASS。使用既有Android SDK公开UIAutomator API构建任务自有小测试Jar，只查目标APP的可访问性树；不下载工具/安装额外APP/改安全设置。各版失败（包含缺inner-class和打包次序错误）保留；最终v6打包outer/inner两class并检查JUnit `OK (1 test)`，不会把exit0但JUnit FAIL当通过。测试进程的同步timeout设置在finally恢复，不改变系统安全策略。

- **call3：实际接听、双向媒体→真实UI麦克风/摄像头off/on→HOME后台两轨muted→前台明确恢复两轨。** 对端每阶段两条订阅轨道状态与按钮操作相符。此旅程随后因重新连接按钮仅露12px而未真正调用重连，整段exit1；finally真实API结束，不能把前段支持拼成整段PASS。
- **call4：只补受影响的同call重连和真实UI挂断，exit0。** 控件须充分可见，否则先滚动；仅重启自有SFU，UI重新读取join并连接同一call。重连后7批约24秒四方向RTP均增长，视频decode94→574；outbound视频为同一采样时刻3路simulcast计数求和，不混比不同层。随后真实点击挂断，API状态ended，新增renderer_cancel_complete、room_disconnect_complete、room_dispose_complete、leave_complete均多于挂断前计数；不是挪用重连阶段旧事件。
- **call5：在call4清理后再次真实接听/建媒体，exit0。** 四方向RTP在约4秒的两批采样增长，视频decode89→169。复用该成功媒体PC SDK实际用过的原token（撤权前尚余107.49秒），真实LiveConsentService.transition撤权后，对真实guarded WebSocket Upgrade做**首次且仅一次**重新入房，返回403，未新mint token。它证明有效成功媒体token的新请求被拒，不能单独代替旧媒体已停止。

call5还观察到Room.dispose和leave完成、PeerConnection CLOSED、AudioRecord/AudioTrack停止与camera release。原测试host从PHP进程启动前到完成观察的保守上界是 **10.125秒**，包含9.750秒的进程引导/服务调用；因此**本轮不宣称新的5秒内停止PASS**。native与server时间戳仅作跨时钟佐证，没有精确COMMIT时刻/同步误差证明；之前Astra接受的0.790秒native停止仅按原身份复用。camera close中code4/5和trackDispose-null日志仍保留为观察，不虚称所有native路径零警告或完整handle普查。限定原进程采样窗口中CME/Unhandled Exception/PlatformException/MediaConnectException/StateError字符串均0；不外推所有平台。

有限合成信号只记录call5本地20份、远端同活动窗口19份440/880与幅值派生量，不存PCM样本。日志hardwareProcessingRequested=false、engineWasAlreadyInitialized=true、effectiveMode=unverified；没有AEC开关对照、声学标定、真实双人语音可懂度或最后可闻波形计时。结论仅 `LIMITED_SYNTHETIC_SIGNAL_OBSERVATION`，**AEC/真实音质NOT_PROVEN**。

### 通知与其余AC边界

通过真实服务request/accept建立下一代MC，用真实消息API发送一条明确合成文本，当前APK会话列表可见。通知中心只显示通用隐私文案。加载后真实服务撤权，第一份快照仍有旧卡片，下一次当前读取前卡片已被权威刷新移除；**未发生实际旧卡片点击**，该项 `NOT_RUN_CONTROL_NO_LONGER_VISIBLE`。通知read_at、消息read_at/is_read、会话last_read_message_id前后均不变。早期夹具使用错误表名的QueryException原样保留并修正为真实conversation_members；后续卡片消失造成的脚本exit1也保留，不改标整体PASS。

其余未变的消息幂等/故障恢复、图片/视频与Range、登录T0/refresh、密文/受控清理、通知系统权限/偏好、后端鉴权结果，按原Commit/APK与Astra局部接受身份复用，未冒作当前APK全量重测。实际经过15/30天与物理30天清理仍WAITING_ELAPSED_TIME/NOT_RUN；未改系统时钟。真实Push Provider未授权/未接入，测试transport seam不代替真实投递。

| AC | 当前结论 | 证据类别 | 范围及限制 |
|---|---|---|---|
| 01 | `SUPPORTED_BOUNDED_PROTECTION` | NEW_READONLY / NEW_OWNED_DB | Fresh main and accepted product trees; 1040 build inputs; 24510 named files, five roots and old protected refs unchanged. |
| 02 | `REUSED_ACCEPTED_MESSAGE_RELIABILITY_PLUS_NEW_NOTIFICATION_FIXTURE` | REUSED_ACCEPTED / DEVICE_NEW_RUN | Earlier idempotency/timeout/retry remains at original identities. One new real synthetic API message was visible in the final APK conversation list and persisted across DB restart; no new full message journey claim. |
| 03 | `SUPPORTED_SUCCESSFUL_MEDIA_TOKEN_REENTRY_REJECTION_WITH_LIMITS` | DEVICE_NEW_RUN / REUSED_ACCEPTED | Call5 successful media token, still unexpired, first post-revoke real WebSocket Upgrade 403, exactly one attempt. Old authorization/race tests reused. New media-stop <=5-second timing NOT_PROVEN; old 0.790-second evidence reused separately. |
| 04 | `REUSED_ACCEPTED_DEVICE_MEDIA_AT_ORIGINAL_IDENTITIES` | REUSED_ACCEPTED | Unchanged media sender/player and old synthetic image/video/Range/revocation evidence reused; no new final-APK picker journey. |
| 05 | `PARTIAL_AC05_OPEN_TARGETED_CLEANUP_AND_DEVICE_SUPPORTED` | DEVICE_NEW_RUN / TEST_ONLY / REUSED_ACCEPTED | Call3 controls/background supported but whole script exit1; separate call4 reconnect/UI hangup and Room completion; call5 new media and token negative. No all-platform handle census or physical AEC/voice quality PASS. |
| 06 | `REUSED_T0_BOUNDARIES_WAITING_ELAPSED_TIME` | REUSED_EVIDENCE / NEW_SYNTHETIC_LOGIN | Final APK cold entry locks; synthetic real login succeeds. Prior trusted T0/refresh boundaries retained. Actual 15/30 elapsed days NOT_RUN, no system-clock change. |
| 07 | `SUPPORTED_COLD_LOCK_WITH_REUSED_RETENTION_LIMITS` | DEVICE_NEW_RUN / REUSED_TEST_ONLY | Current cold entry/login lock observed, prior ciphertext and controlled boundary/purge proofs reused. Real elapsed offline 15-30 days and physical 30-day cleanup WAITING_ELAPSED_TIME. |
| 08 | `SUPPORTED_CURRENT_AUTHORITY_CARD_REMOVAL_STALE_CLICK_NOT_RUN` | DEVICE_NEW_RUN / REUSED_ACCEPTED | Notification uses generic text, stale card disappears before a real click after service MC revocation, message and notification read facts unchanged. Actual stale-card clicking NOT_RUN; previous OS permissions/preferences reused. |
| 09 | `REAL_PUSH_PROVIDER_PENDING` | REUSED_TEST_ONLY / NOT_RUN | Existing provider/token transport seam retained; no real supplier or external delivery authorized or tested. |
| 10 | `SUPPORTED_TARGETED_TEST_BUILD_DEVICE_DB_WITH_OPEN_GATES` | NEW_RUN / DEVICE_NEW_RUN / REUSED_BACKEND | 67 related checks and separate 17 ICE guard checks exit0; analyzer 0 errors/0 warnings/19 unchanged upstream infos; final APK source pins and installed hash match; 12-table restart equality. Backend unchanged/reused; Gate2 chain NOT_RUN. |
| 11 | `CONSOLIDATED_PARTIAL_CANDIDATE_AWAITING_ASTRA` | STATIC_REVIEW / SANITIZED_REMOTE_READBACK | One appended report/manifest, source and key Blobs, bounded ten-file sanitized review; raw private evidence remains local. No product main integration or successor. |

### Gate2只读、环境保护与恢复点

PE元数据只读确认PS7 System.Web.dll（15144 bytes）定义0个type且没有WebResourceAttribute，而既有Framework System.Web（5401912 bytes）定义2715个type并含该类型；Extensions为1832288 bytes/395 types。精确Hash见gate2-readonly。没有加载/执行程序集，注册表读取不等于完整effective policy授权；较新TypeLoad原始栈在本次具名根未找到，故不宣称已取得精确异常栈或完成运行根因证明。可审查方案仍要求既有允许的文件入口与完整Framework实现同时成立；当前未证明此交集，不复制Framework DLL进Core、不换Serializer、不修改策略/Bypass/换eval入口尝试。

D0-A仍15次Serialize/约0.688秒，WinPS策略拒绝0.375秒与PS7 TypeLoad启动失败0.390秒两历史预算已消费。**本轮新Gate2预算/启动/Writer/Serializer调用均0**；完整37案例、条件式Sandbox SDK、Producer、libs.jar、30项Configuration.resolve全部NOT_RUN。普通Flutter应用SDK清理测试不与该条件链混淆。

本轮独立空库/volume和回环服务归属在迁移前核验，旧库未动；复用Owner已允许的本地SFU eth0过滤配置，未改系统网络/策略。最终三合成账号activeCalls/session families/access tokens均0，手机进程、合成PC及自有API/WS/authority/bridge/SFU/DB/任务Gradle均停止，四条专属ADB reverse恢复开工空状态，容器/volume与APP安装保留。原closure脚本在全部停机/备份后因TIME_WAIT端口重新bind检查exit1；**未重跑停机或测试**，另只读核验原owned PID不存在/退出、七端口无listener且连接拒绝。SFU容器Stopped但记录exit1，DB exit0，不声称所有child均exit0。

12张表规范化快照在DB重启前后完全一致，真实合成消息仍1条。最终SQL 188049 bytes / SHA256 `1e8fe52a679fd41f0e2940c0b2e7715a700f555004d65906c3987ac4a3749435`；前置空库与重启前后备份均LOCAL_ONLY。两个SQL dump原字节Hash不同，不以快照相同冒dump字节相同。24510份具名保护文件、5历史根及521开工refs中受保护项均保持；不是整盘字节审计。

LOCAL_ONLY根标签 `v1015-remaining-acceptance-continuation-20261025`。十件最小脱敏审阅包：分支 `codex/v10.1.5-remaining-acceptance-review-20261025` / Commit `fd3320712f82b312e524854c596740b728f16202` / Parent `a25e7c1012bce3f2a2d7048f284f17ebd8a0915c` / Root `385d01449f8d8cc9b68e23064919d6a8d92c3288`；source base `a25e7c1012bce3f2a2d7048f284f17ebd8a0915c`，十件Blob及原字节已远端回读。地址：https://github.com/zcx369658780/EliteSync-v10/tree/fd3320712f82b312e524854c596740b728f16202/docs/_temporary_review/v1015-remaining-acceptance-20261025 。非作者另核脱敏陈述边界，不代替Astra。

原连续候选分支普通non-force发布源码和本报告/Manifest；最终文档Commit/Parent/Root/Blob/原字节与完整产品双Tree由独立远端回读绑定，避免自引用。保持 **V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / REAL_PUSH_PROVIDER_PENDING**。当前可执行范围集中交付后停止，等待Astra；不合产品main、不启动下一Gate或v10.1.6。


## 2026-10-25｜同版本 R1 集中返修交付（最新状态；等待 Astra）

**V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / R1_REPAIR_CANDIDATE_AWAITING_ASTRA。** Owner在当前会话完整手动派发R1返修任务；这是本次执行依据，不是v10.1.6或产品main集成。原107310字节报告原样保留。远端既有Astra复核Blob `5e5851cc54185d488490706e99deaed57cb67802`的正文是有界接受/整版PARTIAL；未把它改写成整版接受或另一个历史裁决。当前Owner明确返修方向按本次派发执行。

### 实时权威与源码身份

开工fresh main `4df2e7f0f36cc7b80258faa73e80dad682cff6c5` / Root `03b0ecfcc360e38a462539dd50690c64b663a21e`；正式剩余任务Blob `fec31d6318524a40b9ff8f0dab49b60aa7fa3490`与冻结plan `7d3466b3be67135dc641cfee7c7faef78937ba03`保持。已接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。

本轮源码Commit **`e7cbbe6030b033c5c9244c599bd42fcff312a8c6`** / 唯一Parent `7773b98986d9c9395841623e6ef244379fddc865` / Root `3871583648176b69a2d0ebb1053b23a07770fec5`，apps `0581a5286300d8c39fd7ffaf3dce37af0257419e` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。仅改变RTC service与对应test两文件；应用自有LiveKit 2.10.0+elitesync.2的runtime、LICENSE/NOTICE、297上游Hash清单及最小patch原字节保持，后端/授权/token/Upgrade源码不变。1040件tracked apps在构建输入副本与连续源码逐项匹配；构建后再次核验一致。最终候选Commit/Parent/Root、报告/Manifest Blob与原字节在提交后由外部final-readback绑定，避免自引用。

### 已修复缺陷与定向检查

首个leave在native清理前撤销Room/call身份；此时带callId的重复leave会走身份不匹配早退，提前报告其Future完成。现在该早退分支先等待已有`_roomTeardown`，不触碰新Room/代际/连接状态。两个新增成功/失败用例在原代码均因提前完成RED，exit1；修复后完整service **22项exit0**，三份关联RTC页面 **27项exit0**，两个改变Dart文件分析exit0、No issues found。失败路径继续确认清理失败后不得请求新join凭据。非作者只读源码审查未见新增阻断问题；没有由审阅者运行测试或设备。SDK清理交错、Room并发/错误传播及disconnect失败仍继续dispose沿用已有证据，未无谓重跑原67项和17项ICE检查。

普通debug构建修正后exit0、288.969秒；最终APK `com.elitesync.v1015r1dev` / code1010511 / name10.1.5-r1-dev，**405007373 bytes / SHA256 `30ca72ab1e53c55ff324ee2763d84ceab7867a7c54617e5b76bcbaa83c966a12`**。install-r保留数据、签名一致，回取Hash相同；新APK冷启动先锁登录，随后仅用任务合成账号登录。

构建保护偏差如实保留：初次隔离复制停在大量无用Gradle文档，副本保留；缩小复制遗漏依赖包lib/test引起页面编译失败，补回既有本地原件后27项通过，未改断言。首次APK构建虽外层offline，内层wrapper仍尝试下载Gradle；主代理发现后终止自有进程树，exit1，**7941328字节partial及Hash保留**，不能声称本轮全程无下载。随后仅在本轮ignored构建副本内让wrapper直接调用已存在、314件运行文件字节一致的Gradle 8.14，无网络fallback，并监测再次下载入口；修正构建通过。共享工具/全局网络/系统安全策略和产品源码未因此修改。Java夹具默认编码与登录脚本BACK误退的原失败也保留；普通修复未降低检查门槛。

### R1根call1：真实撤权与有界停止时序

这是独立的新call，不与旧call3/4/5拼接。新APK同一PID下，两批四方向RTP bytes/packets均增长，入站视频decode **66→226**。outbound视频是同批次simulcast计数之和，不冒称线缆精确字节。真实guarded `LiveConsentService::transition`在独立新空开发库执行，PHP先完成bootstrap与精确三合成账号/call归属核验，输出READY后等待GO。主机在发送GO前打单调时钟，PHP收到GO才能进入真实transition/commit，COMMITTED输出确认transactionLevel0。

READY后再次取得同PID基线，并确认本call尚无disconnect_start；每次日志读取固定/核对该PID。native事件必须在同一手机日志时钟中位于本call新disconnect_start之后；手机时间只排序，不与server/host做时差相减。主机收到COMMITTED在原始区间0～0.062秒内；这不是精确COMMIT打点。renderer cancel原始观察0.312秒，PeerConnection两次CLOSED、AudioRecord stop done、AudioTrack stop done与camera release在0.625秒内可见，disconnect/Room.dispose/leave完成在0.875秒内可见。

Python monotonic实现为GetTickCount64，分辨率15.625ms；额外加入两端合计**31.25ms**量化余量。最终保守上界 **0.90625秒**（含日志获取/调度开销）；COMMIT区间含余量上界0.09325秒，仍不声称精确提交时间。该结果仅支持**此次指定native/生命周期端点在撤权后5秒内可见**，不证明最后可闻波形停止、AEC、所有native handle或所有平台路径。限定同PID采样窗口保留camera close code4/5计数6与trackDispose-null计数5；五种异常字符串计数0仅限该窗口，不宣称全平台零警告。

旧call3整体exit1、call4真实UI重连/挂断、call5成功媒体旧token首次403、旧10.125秒及历史0.790秒分别按原Commit/APK保留。call5三个原始日志Hash再次匹配；本次未改token/consent/Upgrade路径，只复用旧成功token首次重入拒绝命题，未冒作新APK重新运行。AEC仍NOT_PROVEN；hardwareProcessingRequested=false/engine already initialized/effectiveMode unverified不是有效AEC证明，未补做声学对照或私人语音采集。

### 通知旧卡片：实际UI action与限制

通知代码未改；本轮在回取Hash核验过的原APK `68e9bc37c785976713a7fbe0d18f82c1dcde0d1bbfe2641e26558e71f8cb2717` / 源码a25e7c上执行独立场景，不写成新APK全量重测。三合成账号真实消息API创建一条通知；确认唯一卡片后，经真实服务撤权。预先就绪的本轮UIAutomator辅助程序在GO后取得**当前仍可见的所属页面控件**，执行真实Android可访问性ACTION_CLICK，平台返回成功，JUnit OK(1 test)。这不是物理触屏声明，也不是tap空坐标。

点击后仍在通知中心，出现“暂时无法打开这段会话，请稍后重试”反馈；对既有XML只读同时核text与content-desc，均无合成消息正文。通知read_at、消息read_at/is_read、conversation last_read_message_id前后保持。既有服务logger未记录这次单独HTTP状态，故**不声称通知点击返回403**。本轮结论为有界真实失效卡片点击后未打开私密路由；旧卡片提前消失导致NOT_RUN的历史未重写。

### AC-01～11及未关闭门禁

| AC | 当前结论 | 证据类别 | 限制 |
|---|---|---|---|
| 01 | `SUPPORTED_BOUNDED_PROTECTION` | NEW_READONLY | Live main product still v10.1.4; 1040 build inputs, 25609 named files, five roots and protected old refs unchanged. |
| 02 | `REUSED_ACCEPTED_MESSAGE_RELIABILITY` | REUSED_ACCEPTED / NEW_NOTIFICATION_FIXTURE | Unchanged reliability path reused at original identities. New real synthetic message for notification test, not a repeated full reliability journey. |
| 03 | `SUPPORTED_BOUNDED_NATIVE_STOP_PLUS_REUSED_TOKEN_REENTRY` | DEVICE_NEW_RUN / REUSED_ACCEPTED | R1 call1 bounded native/lifecycle stop <=0.90625s incl clock allowance. Prior call5 first successful-media-token Upgrade 403 reused separately; no new token-negative run. |
| 04 | `REUSED_ACCEPTED_MEDIA_AT_ORIGINAL_IDENTITIES` | REUSED_ACCEPTED | No new image/video picker/player/Range journey. |
| 05 | `PARTIAL_AC05_OPEN_BOUNDED_NATIVE_LIFECYCLE_5S_SUPPORTED` | DEVICE_NEW_RUN / TEST_ONLY / REUSED_ACCEPTED | Three-line repeated call-scoped leave fix; 22+27 checks; R1 call1 flow and eight completion endpoints. AEC, last audible waveform and native handle census not proven. |
| 06 | `WAITING_ELAPSED_TIME` | REUSED_EVIDENCE / NOT_RUN | Trusted T0/refresh reused; actual 15/30 days not elapsed/proven; no system-clock changes. |
| 07 | `WAITING_ELAPSED_TIME_PHYSICAL_PURGE_NOT_RUN` | REUSED_TEST_ONLY / DEVICE_NEW_RUN | Current APK cold entry locks. Actual offline 15-30 days and physical 30-day purge not run. |
| 08 | `SUPPORTED_BOUNDED_REAL_STALE_CARD_ACCESSIBILITY_CLICK` | DEVICE_NEW_RUN_ON_PRIOR_UNCHANGED_NOTIFICATION_SOURCE | Original APK 68e9...; real visible-node ACTION_CLICK after service revoke; blocked feedback, no body in text/description, read facts unchanged. No physical-tap or individual HTTP-status claim. |
| 09 | `REAL_PUSH_PROVIDER_PENDING` | NOT_RUN / REUSED_TEST_ONLY | No provider/SDK/credentials/fees/external delivery. |
| 10 | `SUPPORTED_TARGETED_TEST_BUILD_INSTALL_WITH_OPEN_GATES` | NEW_RUN / REUSED_BACKEND | 22 service +27 distinct page checks exit0, scoped analyzer0, corrected build/install hash match. Initial wrapper tool-download deviation preserved. Backend restart evidence reused, no new DB restart or Gate2. |
| 11 | `R1_CANDIDATE_AWAITING_ASTRA` | STATIC_REVIEW / SANITIZED_REVIEW / REMOTE_READBACK | One appended report and one manifest, ten sanitized review files. Raw local evidence retained. No main integration/successor. |

实际15/30天与物理30天清理仍WAITING_ELAPSED_TIME/NOT_RUN；可信T0/加密缓存/受控边界与旧DB重启快照按原身份复用，未改系统时钟或冒充自然时间经过。真实Push继续PENDING/NOT_RUN。ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN、OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS保持。

Gate2无新授权：WinPS策略拒绝0.375秒、PS7 TypeLoad启动失败0.390秒预算均保持已消费，D0-A仍15次Serialize/约0.688秒。本轮Gate2启动/Writer/Serializer调用均0，37案例、条件Sandbox SDK、Producer/libs.jar/30配置解析全部NOT_RUN；没有Bypass、策略变更、Framework DLL复制或替换Serializer。

### 资源、保护与交付

任务进程、手机APP进程和合成PC已停，活动call/session families/access tokens均0；SFU stopped exit1与DB stopped exit0分别记录，不写成所有child exit0。四条专属ADB reverse恢复开工空状态，七端口无listener，任务Gradle停止；APK安装、容器/volume、SQL和原始日志保留。新最终SQL 151058 bytes / SHA256 `1e9fa88549fb26a56ed53a30a805558c471e52c9ae9ac442e7a692d14862a4a6`保持LOCAL_ONLY；本轮未重复DB重启旅程。25609具名保护文件、5历史根及522开工refs中的受保护项保持；不是整盘审计。

LOCAL_ONLY根标签`v1015-r1-remaining-repair-20261025`。十件最小脱敏审阅包分支`codex/v10.1.5-remaining-r1-review-20261025`，Commit `220e29b148dd0994d3a2798a98a79e2943a099d4` / 唯一Parent `e7cbbe6030b033c5c9244c599bd42fcff312a8c6` / Root `d6b45cf2df417365cb5517f0bae046d19925ad50`；公开安全派生摘要与静态夹具副本不包含原始设备/UI日志、APK、SQL、私人音视频、凭据或标识。
地址：https://github.com/zcx369658780/EliteSync-v10/tree/220e29b148dd0994d3a2798a98a79e2943a099d4/docs/_temporary_review/v1015-remaining-r1-20261025 。报告/Manifest原字节及完整apps/services Tree和候选身份在普通non-force发布后集中回读，最终结果见本轮final-readback。

保持 **V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / AWAITING_ASTRA_INDEPENDENT_REVIEW / NO_PRODUCT_MAIN_INTEGRATION / V10.1.6_NOT_STARTED**。候选交付后停止；未改冻结合同、未合main、未自行接受或启动下一Gate。


## 2026-10-26 Owner派发：构建离线入口与APP RTC清理聚焦交付

状态：**V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / FOCUSED_CANDIDATE_AWAITING_ASTRA**。本次仅执行Owner具名聚焦任务，不自行接受整版。冻结计划Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`未修改；任务分支HEAD `5fd7e853943e14a087f5a3a90544904a39609f0c` / 任务Blob `bbda6d136e19271d4a377a7cfe48b0069f16c1fa` / Astra R1复核Blob `c2ab5035b84985b5e8a87e32fc34d2fe9352c31e`。R1有界接受与其未完成项分别保留，不把候选树当产品main。

### 实时身份与源码

开工及交付前fresh main `4df2e7f0f36cc7b80258faa73e80dad682cff6c5` / Root `03b0ecfcc360e38a462539dd50690c64b663a21e`；产品apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`仍v10.1.4。前候选d45cd08f939f6dfc6b4efe2420f4a117efc99e68，唯一Parent e7cbbe6030b033c5c9244c599bd42fcff312a8c6、Root9a2997eacbbc386f48d2a2dc259221a2319997dd，两旧文档Blob和118904/169748原字节按身份保留。

本轮源码 `02fac2b20da52e56b373f6ae8ae2da838fd51901` / 唯一Parent `d45cd08f939f6dfc6b4efe2420f4a117efc99e68` / Root `2b975e3b90d6844d51500726ebee1516cefaf5b2`，apps `81a86b9dc9c2fc68edecb60a742b911539c68f3c` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。仅7个项目构建入口/guard/observer/测试/说明路径变化，1046份已复制apps输入逐文件Hash再次对应；**APP Dart、LiveKit vendor及后端未改**。文件Hash见Manifest.source.changedFiles。新候选只在本源码上追加本报告和一个Manifest，远端Commit/Parent/Root/Blob与原字节在发布后另行回读绑定。

### A：入口已实现，实际普通debug构建未通过并停止

项目入口offline_debug.py要求调用方独立pin的兼容完整缓存inventory；核对本地Gradle8.14运行文件、版本receipt、bin Hash、依赖定义和各缓存scope。缺少工具/依赖、Hash错误或路径不安全在启动Gradle前拒绝，不退回Wrapper。外层和内层AAR静态调用本地Gradle；禁用JVM工具链自动下载，固定普通R1 debug参数，无ICE/retention扩展。项目init仅去除私有AAR发布的Javadoc classifier以免Dokka独立外链，不更改vendor/runtime artifact。继承Java opts等被清理。

`python apps/android/scripts/test_offline_debug.py`：入口不存在的原RED exit1；两次10项夹具失败由选取inventory[0]不确定导致，原始stdout/stderr/exit全部保留，明确选择目标root后恢复，未降低断言。随后12/13/15项阶段检查通过，最终15项exit0。真实CLI负例缺缓存和错误manifest pin均exit2 / PREFLIGHT_REJECTED / buildProcessesStarted0。

唯一实际构建使用inventory SHA256 `ad08b37917d289bb90b9919c03b277528618751d39420e188a2e25774a19e49f`；94573个具名文件/23个定义，来源为原R1成功兼容缓存，非未知缓存自证。preflight通过后直接调用已存在Gradle8.14 `:app:assembleDebug --offline --console=plain --no-daemon --max-workers=2`并固定本地参数。真实构建9.953秒、57次采样后观测任务java.exe两个UDP端点，触发保守stop；**outer exit90 / Gradle exit1 / NETWORK_ATTEMPT_OBSERVED / 无重试**。端点目的地未知；未观测non-loopback TCP且无下载日志，既不能断言已外联，也不能证明没有联网。有限进程/TCP/UDP采样不证明绝对无网络。已终止自有树，已观测3个PID与合成对端PID的独立终末只读查询均不存在。

构建验收的普通debug exit0 **未满足**，不与历史成功拼接。没有新APK或本轮安装；尚未到达内层AAR，Kotlin DSL实际编译和内层直接Gradle调用**未证明**。Wrapper trap未触发只限已到达窗口，不能冒作完整链通过。完整命令/退出码/stdout、stderr与采样Hash见Manifest.build。本次构建stdout SHA256 `74db0edd1fc9509d2da9123bcd08f2156c2414b2c371f88848b24894529b9076`，stderr为空Hash，observation SHA256 `2e9a5d59996cc3ce220e6df523b9d2bbf8ac2a021bdb46fcb71c635cbd45cdb4`。首次R1误下载的7941328字节partial / SHA256 b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4原件保护不变。本次保护触发后没有放宽规则/重发构建。

### B：新call1复现与有界归因，无APP修复

Owner接回原手机并启动原有Docker引擎后，复用已存在镜像/工具（pull=never），在任务独立合成数据库/服务上观察。现装R1 APK回取405007373字节，SHA256 `30ca72ab1e53c55ff324ee2763d84ceab7867a7c54617e5b76bcbaa83c966a12`一致；运行源码e7cbbe，不称本任务新构建。登录辅助BACK误退及一次错误Activity具名启动失败原证保留；改用既有正确Activity和既有登录流程后进入，无APP修改。初次Docker未运行的准备失败也保留。

聚焦LOCAL_ONLY根的独立call1：同PID，四方向RTP bytes/packets均增长，入站视频decode70→148；执行真实APP UI挂断，服务端ended。新日志delta中renderer_cancel_complete、disconnect_start/complete、dispose_start/complete、leave_complete各一次，PeerConnection CLOSED2、AudioRecord stop done1、AudioTrack stop done2、camera release1均在该次结束后可见。挂断前基线/媒体窗口无指定警告；挂断后camera raw code4×3/code5×4共7条**W**，trackDispose-null5条**D**。五种指定异常字符串计数0只限该窗口，不代表所有日志无错误，也不代表native handle全部释放。

APP只有一次disconnect/dispose序列并完成，重复leave/new join等待barrier保持原R1修复；源码未变，因此复用R1两个RED→GREEN、22+27检查，不无谓重跑。未发现本次可证明的APP重复close缺陷，不因警告计数修改APP或vendor。LiveKit Track.stop→mediaStreamTrack.stop后，LocalTrack.stop仍再调用同一stop；flutter_webrtc每次stop均发送trackDispose，native localTracks缺项时D日志后返回。这是SDK幂等二次关闭的可解释路径，**不是每一条null日志的排他归因**。

相机观察来自CameraDevice-JV-1的W日志。现有Android36参考源码在onDeviceError含同一字面量但为DEBUG下Log.d，与设备日志级别不同；未取得设备固件字节匹配源码或数字常量映射，不能把raw code4/5等同StateCallback CAMERA_DEVICE/SERVICE。正常abort与平台问题仍未充分区分，归于SDK/framework关闭窗口观察，保留未定项；不宣称正常无害，不消日志、不改SDK。引用位置见脱敏rtc-warning摘要，原始运行证据Hash见索引。

本call仅证明指定生命周期/native端点可见，未做撤权新计时，不证明最后可闻波形、AEC或完整handle census。R1撤权保守上界0.90625秒仅历史复用；更早10.125秒、0.790秒及旧call3/4/5分别保留，不拼接成完整旅程。通知R1实际可见卡片ACTION_CLICK有界证据按原APK复用，非本轮新跑。

### AC-01～11与证据类别

| AC | 状态 | 证据类别 | 限制 |
|---|---|---|---|
| 01 | SUPPORTED_BOUNDED_PROTECTION | NEW_READONLY | 26228 named files, five roots and protected old refs unchanged; product main remains accepted v10.1.4. |
| 02 | REUSED_ACCEPTED | REUSED | No message reliability source change or new full journey. |
| 03 | REUSED_R1_BOUNDED_STOP_AND_PRIOR_TOKEN | REUSED | R1 <=0.90625s bounded native endpoints and older call5 first token Upgrade403 remain separate; no new revoke timing. |
| 04 | REUSED_ACCEPTED | REUSED | Picker/player/Range unchanged; not re-run. |
| 05 | PARTIAL_AC05_OPEN | DEVICE_NEW_RUN_PLUS_REUSED | Focused call1 RTP/UI hangup; warnings reproduced; no APP-owned fix supported; AEC/waveform/handles unproven. |
| 06 | WAITING_ELAPSED_TIME | REUSED_NOT_RUN | No new proof of actual 15/30 days; no system clock changes. |
| 07 | WAITING_ELAPSED_TIME_PHYSICAL_PURGE_NOT_RUN | REUSED_NOT_RUN | Prior controlled tests retained; physical 30-day purge not newly proven. |
| 08 | REUSED_R1_BOUNDED_STALE_CARD_CLICK | REUSED | R1 real accessibility ACTION_CLICK retained at original APK/source; not a new notification test. |
| 09 | REAL_PUSH_PROVIDER_PENDING | NOT_RUN | No provider, keys, production or new fees. |
| 10 | PARTIAL_BUILD_STOPPED | NEW_TEST_AND_FAILED_BUILD_PLUS_REUSED | 15 final guard tests exit0, two negative CLI probes exit2 before children; real build UDP stop, outer90/child1/no new APK; R1 22+27 checks reused. |
| 11 | FOCUSED_CANDIDATE_AWAITING_ASTRA | STATIC_REVIEW_AND_REMOTE_READBACK | Consolidated report/manifest, sanitized review package, normal candidate and fresh raw-byte readback required. |

真实15/30天与物理30天清理仍WAITING_ELAPSED_TIME/NOT_RUN，无新自然时间证明；真实Push PENDING/NOT_RUN，AEC NOT_PROVEN，ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN、OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS保持。Gate2新启动/Writer/Serializer均0；0.375/0.390秒已消费，历史D0-A15次/约0.688秒不重跑。37案例、条件Sandbox SDK、Producer/libs.jar、30配置解析均NOT_RUN。

### 资源、保护、非作者复核与集中交付

任务进程/合成对端/手机APP已停；活动call/session families/token均0，7端口无listener，4条ADB reverse恢复开工空状态；本任务Gradle stop exit0，具名观测PID终末查询全部不存在。SFU stopped exit1、DB stopped exit0分别保留。Owner启动的全局Docker/ADB保持，APK、容器/volume、原始失败、SQL与LOCAL_ONLY不删除。最终SQL153219字节/Hash320ac08d7b2594f8ebc8f9ee48b19e00121424a4d8f7dac3f940a0948edc29bf仅LOCAL_ONLY。26228份具名保护文件、5历史根及523开工refs中受保护项一致，不称整盘审计；D盘dirty根未改。

非作者只读复核入口源码和脱敏派生摘要，4项入口问题已修正且最终15项通过；后补具名进程关闭回执。派生静态脚本副本曾因默认编码把中文动作字符串写坏，非作者发现后以显式UTF-8重生成并核对原执行源一致；初始审阅Commit67db5e91c17ea1b42cc6baabfb5ccaf4cbba4733保留，通过普通non-force追加提交修正，原执行源/设备证据不变、不重跑。复核者没有执行本地测试/构建/设备操作，不替代Astra独立验收。原始设备/UI日志、APK、SQL、凭据、标识不上传；仅7件最小脱敏审阅包和Hash索引，分支codex/v10.1.5-build-app-cleanup-review-20261026，路径docs/_temporary_review/v1015-build-app-cleanup-20261026/。外部Commit/Root及两文档Blob/原字节、apps/services完整Tree在普通non-force发布后核验，最终绑定在LOCAL_ONLY `v1015-build-app-cleanup-focused-20261026/final-readback.json`。

集中候选交付后停止，等待Astra；**没有产品main集成、v10.1.6、Gate2、生产/真实Push/新增费用或历史清理**。

最终脱敏审阅包Commit `ad2206ba3b9a6d65e8265e0aef5277b92d50de3f` / Parent `67db5e91c17ea1b42cc6baabfb5ccaf4cbba4733` / Root `db135b18d2922a89b65a8a86edb5dcc052b0fa1e`；初始审阅提交保留在普通追加链中。


## 2026-10-26 Owner手动派发：UDP观察器证据语义窄修正

**V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / AWAITING_ASTRA**。本轮仅分类修正、隔离单元测试和静态检查，不获得真实构建重跑授权。

### 权威、实时身份与受限差异

Owner在本会话明确确认正式派发。任务分支 `owner/v10.1.5-udp-observer-semantics-task-20261026` fresh HEAD `8fd8f9dd360c373259003e7a485a8adf8164e1b5`，任务Blob `cca9cf539370325ea2827cf914ffe7b83d18305e`，ACTIVE_STATE Blob `2d8fdd64fcc130a9cd692b89945c6a52a42d9d89`；前次Astra复核Blob `53a91243fe1e7155e71e5a44cb65238e13964574` 的CHANGES_REQUIRED已读取。冻结计划Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`未改。

开工与交付前live main `4df2e7f0f36cc7b80258faa73e80dad682cff6c5` / Root `03b0ecfcc360e38a462539dd50690c64b663a21e`；产品接受仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。前候选825344124313c4d88690983809a6fb95a05551f4 / 唯一Parent02fac2b20da52e56b373f6ae8ae2da838fd51901 / Roota13bb45df8d01dffacfce6395b5ae34ef68fafb5，报告Blob1639609a27cd25ee6a2a02d510110660023b287a、Manifest Blobc0a7338316c4f4210579881249fe2bd7545fcc2f重新核验。

本轮源码 `c1055f3cf5dcb80d0ec003de1846b940b5186aad` / 唯一Parent `825344124313c4d88690983809a6fb95a05551f4` / Root `5684d0d5785fe9304379e5d2cf24b4e8992bcee3`；apps `df307a66c5d725aa9733de0746d58405e3702e3f` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。仅4个白名单路径改动，build.gradle.kts、APP Dart、LiveKit vendor、后端/token/consent/Upgrade均未改。候选仅在本源码上追加报告与Manifest；候选Commit/Root/两文档Blob及原字节发布后外部绑定，不在文档内制造自引用Hash。

| 变更文件 | Git Blob | SHA256 |
|---|---|---|
| apps/android/scripts/offline_debug.py | `38c0306ad931b8599ea4b2273704814f87655e0a` | `274535109001034af044bcefa8dcf14264e0136c9292e7730fc4a4040b705d74` |
| apps/android/scripts/windows_build_observer.py | `a6c4eebe690402a8e240c692d8670143c788af4d` | `2e146c48dbf6d90aee0e0a36a54188d14cc8db39deea845fde40523ccea13a72` |
| apps/android/scripts/test_offline_debug.py | `75c291384dc11c1c50fe881aba0251734b34245a` | `8a220294e993e6327d4ec1da068eb4d0fea7887a0e489f9b40132801df4adfe0` |
| apps/android/scripts/README.md | `e7d0a99b59e4d0daecdbb7aca58de3730b030b4b` | `128c76f6802d6fd4e82fd9017f1a4bef11985866a2697d8e0695e538e877b8fa` |

### 分类语义与保持的停止边界

抽取纯函数observation_stop_reason：UDP owner-PID表只证明任务拥有本地endpoint，remote不可得且不证明实际发出数据报，分类 `UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE`，仍停止；非loopback TCP只证明采样到远端socket/state，不证明payload传输，分类 `NON_LOOPBACK_TCP_ENDPOINT_OBSERVED`，仍停止。日志规则明确匹配为 `DOWNLOAD_ATTEMPT_OBSERVED`；观察器故障/无法读取/缺根进程/异常socket为 `OBSERVER_FAILED`。None只表示当前采样未观察到已分类信号，不是绝对无网络。

分类接回原停止分支，没有跳过UDP、改变loopback策略或自动重试。根进程不可观测时，即使随后child已退出也不再返回安全完成；启动前观察能力失败以OBSERVER_FAILED前缀拒绝、构建子进程不启动。运行时异常细节另列observerFailureDetail；退出后最终下载日志仍扫描并单列downloadLogObserved。优先级保持保守：故障/异常、UDP、非回环TCP、下载；最终下载日志匹配另有字段，不抹去已有停止原因。没有独立实际出站流量证据，所以不生成已证实outbound attempt标签。

### 本轮纯函数/mock测试与静态检查

运行命令为本地Python3.11 `python -B apps/android/scripts/test_offline_debug.py`（-B仅禁止pyc）。原实现对31项隔离测试出现RED，exit1，unittest原摘要failures5/errors17（包含subtest），原stdout/stderr完整保留；这不是实际构建失败。实现后31项GREEN，非作者提出两处文字/隔离修正后最终 **31项exit0、无skip**。最终stdout SHA256 `069dcc56ced8c4863327cca60204d2a361e7f2e1c91af7b9b2edcf2d6082aeb0`，stderr SHA256 `9115881c08e325df27ae213618862afb6c33dcb5cfc316a88f6ae5498029a9e7`；RED/GREEN/FINAL全部命令、退出码和Hash见Manifest.unitRuns，不覆盖原始RED。

8项新分类方法覆盖UDP remote=None、非loopback TCP的多种state、IPv4/IPv6 loopback、下载日志、无信号、观察失败、异常字段、UDP与loopback共存。6项新增完全mock生命周期验证UDP/TCP触发后只停止一次、无重试/无继续sleep、观察器读失败、根不可见且child已退出、启动前能力失败、退出后下载日志。另加2项调用execute但在预检即拒绝的负例：缺缓存/错误Manifest，断言Observer和Popen均未调用。原15项均保留；共31方法，逐项模式和源码行号在Manifest.isolation.testModes。

测试入口在导入被测模块前安装**仅本测试进程**的audit hook，拒绝真实subprocess.Popen、os.system/exec/spawn/startfile、socket.*和ctypes.dlopen；即使被测代码捕获阻断异常，tearDownModule仍因事件计数非0失败。所有执行生命周期用例的Observer/sample、Popen、taskkill/run、poll/wait均完全mock；没有导入/调用真实Windows观察器或网络表。最终stdout明确audit真实process/socket/native-DLL事件 **0**。临时夹具仅本地字节和ZIP receipt，不是Gradle或APK；mock stdout中的PID1234、buildProcessesStarted1及Gradle命令字符串只是夹具输出，不能当作真实启动证据。

静态检查用compile(source bytes, filename, 'exec')仅生成内存代码对象，不执行模块、不产生pyc；三份Python源码通过，git diff --check exit0，白名单4路径一致。静态stdout SHA256 `3e9f66380784051fd44280ae0c6fd6ace0ee3d36203c4d024cd34456c737c104` / stderr SHA256 `e0b960b260823b0b2aab962db5a75cd4f4e3ef05ce267f600742b1fe337a76d8`。一次额外只读git diff --stat误在LOCAL_ONLY目录执行返回exit1/Not a git repository，原工具输出和具名note保留；独立静态检查exit0，不把该命令误报通过。没有因此重跑任何真实工具。

### 前次停止原证保持，真实构建仍未完成

前次唯一真实构建仍outer exit90/Gradle child exit1、57次采样、9.953秒，原label NETWORK_ATTEMPT_OBSERVED原样保存。stdout Hash `74db0edd1fc9509d2da9123bcd08f2156c2414b2c371f88848b24894529b9076`，stderr Hash `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`，采样Hash `2e9a5d59996cc3ce220e6df523b9d2bbf8ac2a021bdb46fcb71c635cbd45cdb4`。其可支持事实仅为java拥有两个UDP端点、目的地不可见；本次语义修正不把它改写成已发包或新运行，也不据此证明无联网。此前嵌套AAR未到达、Kotlin DSL与完整debug未证明，无新APK/安装；**ACTUAL_BUILD_NOT_COMPLETED**保持。原R1 7941328字节partial / SHA256b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4原件不变，前根197件索引Hash只读复核全匹配。

本任务真实构建入口、Gradle/Wrapper、Flutter/AAR/Kotlin、APK生成/安装、设备、RTC/服务启动、实际网络观察器均0。纯函数/mock测试未访问真实网络；GitHub权威读取、正常Git发布与远端回读是交付所需的治理网络操作，单独区分，不声称宿主机所有无关流量为0。没有调用ADB、修改共享工具/系统网络/防火墙/管理员策略或全局环境变量；测试只修改传给假Popen的环境副本。前次资源关闭仅历史引用，本轮未作当前手机/系统资源普查，不将旧0活动call结论冒作新设备运行。

### AC状态、保护与非作者复核

| AC | 状态 | 证据类别 | 限制 |
|---|---|---|---|
| 01 | SUPPORTED_BOUNDED_PROTECTION | NEW_READONLY | 26688 named protected files, five historical roots, protected old refs; product main remains v10.1.4. |
| 02 | REUSED_ACCEPTED | REUSED_PRIOR_CANDIDATE_AT_ORIGINAL_IDENTITIES | No message reliability source change or new full journey. |
| 03 | REUSED_R1_BOUNDED_STOP_AND_PRIOR_TOKEN | REUSED_PRIOR_CANDIDATE_AT_ORIGINAL_IDENTITIES | R1 <=0.90625s bounded native endpoints and older call5 first token Upgrade403 remain separate; no new revoke timing. |
| 04 | REUSED_ACCEPTED | REUSED_PRIOR_CANDIDATE_AT_ORIGINAL_IDENTITIES | Picker/player/Range unchanged; not re-run. |
| 05 | PARTIAL_AC05_OPEN | REUSED_PRIOR_CANDIDATE_AT_ORIGINAL_IDENTITIES | RTC diagnostics and R1 evidence reused unchanged; no APP/device/observer/RTC run in this task. SDK/framework camera warnings unresolved, AEC/waveform/handles unproven. |
| 06 | WAITING_ELAPSED_TIME | REUSED_PRIOR_CANDIDATE_AT_ORIGINAL_IDENTITIES | No new proof of actual 15/30 days; no system clock changes. |
| 07 | WAITING_ELAPSED_TIME_PHYSICAL_PURGE_NOT_RUN | REUSED_PRIOR_CANDIDATE_AT_ORIGINAL_IDENTITIES | Prior controlled tests retained; physical 30-day purge not newly proven. |
| 08 | REUSED_R1_BOUNDED_STALE_CARD_CLICK | REUSED_PRIOR_CANDIDATE_AT_ORIGINAL_IDENTITIES | R1 real accessibility ACTION_CLICK retained at original APK/source; not a new notification test. |
| 09 | REAL_PUSH_PROVIDER_PENDING | REUSED_PRIOR_CANDIDATE_AT_ORIGINAL_IDENTITIES | No provider, keys, production or new fees. |
| 10 | PARTIAL_ACTUAL_BUILD_NOT_COMPLETED | NEW_PURE_MOCK_TESTS_AND_STATIC_PLUS_REUSED_FAILURE | 31 final isolated Python tests exit0; compile/diff0. No real Gradle/Flutter/AAR/Kotlin/APK/device/network validation; prior real build remains stopped. |
| 11 | UDP_SEMANTICS_CANDIDATE_AWAITING_ASTRA | STATIC_NON_AUTHOR_REVIEW_AND_REMOTE_READBACK | One appended report, one manifest preserving previous delivery; candidate ordinary non-force; stop for Astra. |

本轮保护范围26688份具名历史文件（包含前根原证、APK、SQL、partial）、5历史dirty/工作根、524开工refs中的受保护项；开工及源码后核验一致，候选自身本地/远端refs是具名允许前进项，非整盘审计。前报告129841字节前缀逐字节保留，原Manifest248555字节对应Blob在历史提交保留，并完整嵌入新Manifest.previousDelivery。D盘dirty根不写入；不删除任何历史原件或refs。

非作者GPT-6.1 Sol/high只读审查4路径diff，发现并修正“prove no datagram”措辞和旧mock用例遗漏显式run mock两处，终末 `NO_NEW_BLOCKING_FINDINGS_STATIC`。31项执行/audit0/静态检查是主代理观察，审阅者没有运行测试、观察器、构建、设备或网络，不替代Astra验收。无需新的独立审阅分支：公开代码、逐项模式、Hash和派生摘要集中放入本报告与Manifest；原始测试日志/路径和历史设备/SQL/APK等仍LOCAL_ONLY。

Gate2启动/Writer/Serializer保持0；旧0.375/0.390秒预算和D0-A15次/约0.688秒不重置。37案例/条件Sandbox SDK/Producer/libs.jar/30配置解析NOT_RUN。RTC关闭警告SDK_FRAMEWORK_CLOSE_WINDOW_UNRESOLVED、AEC、最后可闻波形、handle census、实际15/30天/物理30天、真实Push、ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN及OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS均不因本轮脚本单测而关闭。

普通non-force候选发布后核验Commit/Parent/Root、两文档Blob/原字节和完整apps/services Tree，完整绑定保留在LOCAL_ONLY `v1015-udp-observer-semantics-20261026/final-readback.json`。随后停止等待Astra集中独立验收；不合产品main、不启动v10.1.6、不请求或推定真实构建重跑授权。


### UDP交付回读修正记录（同一任务，普通追加）

首次发布018c0d95ef7cf79ee458448aa40c4bfd9af48bd4 / Root3047235ba517c3e188e6f4c421da8158cbf83fa6的源码/文档原字节及产品Tree匹配；嵌入历史Manifest对象身份检查exit1：通用脱敏函数递归替换了历史对象中的工作树路径。首次发布的新Manifest Blob36c97d82079aea50edc5152b81dda0537bf31f4d包含该嵌入偏差；前候选82534412的原Manifest Blobc0a7338316c4f4210579881249fe2bd7545fcc2f、248555原字节以及129841字节报告前缀均未改。不能把首次整体回读写成PASS。

修正仅使previousDelivery与前原Manifest JSON对象完全相同，不再对该历史嵌入应用新路径规范化；首次发布及失败记录保留，普通non-force追加，不amend/force/reset。最终候选的直接唯一Parent为018c0d95ef7cf79ee458448aa40c4bfd9af48bd4，实际源码仍c1055f3cf5dcb80d0ec003de1846b940b5186aad；从源码到最终候选累计仍仅报告与Manifest两路径变化。源码31项最终测试/静态结果不变，无单测重跑、真实入口、设备或网络观察器运行。最终远端身份/原字节及历史对象一致性重新只读核验后绑定final-readback。


## 2026-10-26 Owner派发：单次真实离线Debug重新验证（预算已耗1/1）

**V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / AWAITING_ASTRA**。唯一真实构建触发非loopback TCP强停止，outer入口exit90、Gradle child exit1；不重试、不换入口，不生成/安装APK，不继续RTC或后继任务。

### 开工权威、实时身份与最小源码

正式任务分支 `owner/v10.1.5-single-offline-build-revalidation-20261026` fresh HEAD `a513de4b5a078c5d86ad782aab27116cbb6b1592`，任务Blob `6c09cca14b120cb0eb39cc2909e84a7203d252ed`、ACTIVE_STATE Blob `6c3c60627c42d5ad6f8bb14aeddc5e796ccecdf2`；已读取Astra接受UDP语义窄修正记录 `7dab2d315c4e9ea48fa901ed737ebefdda2c6369`。Owner本会话手动明确最多一次真实构建，无需再请求普通步骤批准。冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03`不改。

开工及启动前fresh main `4df2e7f0f36cc7b80258faa73e80dad682cff6c5` / Root `03b0ecfcc360e38a462539dd50690c64b663a21e`，接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。前候选7674b5e60a219cb76aba387dd2cee85cae67bd0a，唯一Parent018c0d95ef7cf79ee458448aa40c4bfd9af48bd4、Root66929e9c4af27a8249fa3c14776360e7ced9f4f6；报告Blob978176687efa914767115c5014939c11a489a8ea、Manifest Blob7ab43f3cd6df3e05ba1fa6c92e92fb46bc5442f7与本地原字节一致。

本任务源码 `12d4e284feea609935eab12c973f5fd2efbc2992` / 唯一Parent `7674b5e60a219cb76aba387dd2cee85cae67bd0a` / Root `1fbd4a7a2de6dc56b42b0e3a51f7d74f712d7250`，apps `cea01309fa9da5f99ccc9829654c6ec279c8c343` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。仅3白名单路径改动：入口、测试、说明；windows观察器结构不变，build.gradle.kts、APP Dart、vendor、后端/consent/token/Upgrade均未改。最终候选在本源码上仅追加报告与Manifest；Commit/Parent/Root/两文档Blob在发布后外部绑定，避免自引用Hash。

| 文件 | Git Blob | SHA256 |
|---|---|---|
| apps/android/scripts/offline_debug.py | `a10bcb28626ef6d58f3222dc94423223eeaca0d6` | `e98de911d37fb181ce22d7de0458bb9fda4b5e3edf606c3e703b29ae1d757f89` |
| apps/android/scripts/test_offline_debug.py | `54e296f305c8813ec77710beffe95a54db81e29e` | `c1afcaa22b212e7ebc5bdfded2bcfd2050d0225567844c21e83bf97b608fc819` |
| apps/android/scripts/README.md | `58d333056df88f2956ad645bcad4fb2c25f476ad` | `94d97832aff1ba5981d20e8a7796c0fa698e91b01eac2d9c649f330a016985ea` |

### 策略修正、隔离回归和预算防重复

默认UDP保守停止策略保留。只有显式 `--single-attempt-authorized`、独立pin清单声明本任务Blob/maxStarts1/testsExit0/staticExit0且实际回执和源码Hash事先核验时，UDP endpoint单独记为未知目的地观察而不停止；不宣称发包或未发包。纯分类优先故障/下载/非回环TCP，再UDP；私有样本同时保留classification、stopReason与UDP行数。下载、非回环TCP、观察器故障/异常结构、依赖/工具/清单/定义Hash失败继续fail-closed。

唯一入口外有entry-dispatch.once.json的exclusive guard；入口在真实Gradle Popen前以open('x')创建工作根single-offline-build-20261026.claim.json。重复claim、退回默认模式或已有APK均拒绝；模拟Popen失败也不撤销claim，不能换目录/入口恢复已耗授权。该声明是本地防重放与主代理核验，不冒称Owner身份认证机制。唯一真实根启动计数为1，内部AAR属于同一受控树，不计成新授权预算；当前剩余0，两份guard保留。

隔离命令 `python -B apps/android/scripts/test_offline_debug.py`：先RED41项exit1，unittest failures3/errors12原文保留；核心修正41项GREEN；再补已有APK拒绝与模拟Popen失败留claim两项，最终**43项exit0，无skip**。最终stdout SHA256 `3213a6fe5809bf1796eae578ac7a1bae71afdbb51b071c42c24a5cec50bb9137` / stderr SHA256 `3f038c806fc6b4b29567990ed730ea6bdd5945c9bd05260987b7e844d2f5a23e`。audit真实process/socket/native-DLL事件**0**；全部lifecycle的Observer/Popen/run/wait/poll完全mock，临时fixtures不生成真实Gradle工具或APK，mock PID/命令及buildProcessesStarted是夹具而非真实启动。每项模式见Manifest.testIsolation.eachTest。

静态compile只生成内存代码对象、不执行或产生pyc，改变的两份Python源码通过，git diff --check exit0；stdout SHA256 `145bf6490c19778db454174234f4c06505f8c68a8e7c21a13b496d7bb4fab5f4` / stderr SHA256 `9c0728e3d7e14d2449a0a3b43802fd801f2da2f7004800fa47c11f134bc51861`。真实构建在这些检查通过后才允许启动；测试失败期间没有真实构建。少量只读rg未命中/进度读取误cwd缺文件在tool transcript和notes保留，不把它们当单测/构建通过或失败，不改失败原证。

### 工具/缓存身份与唯一实际构建

从具名既有R1本地工具/缓存准备任务专用副本，不下载工具、不写旧根。旧pin `ad08b37917d289bb90b9919c03b277528618751d39420e188a2e25774a19e49f` 的94573项逐文件比对：**94563原字节相同、5项声明路径替换、4项当前已提交输入、1个仅换回执路径的禁止Wrapper trap**；无缺项、无额外文件、无未解释漂移。清单中4项当前输入含此前观察器说明版本，不等于本任务Git改了4文件。本任务Git差异仍3路径。23个构建/依赖定义在路径规范化后与旧pin匹配，1046 tracked apps源码与本源码逐文件一致；任务专用android-user2文件另做源/副本配对Hash，未冒称被旧7根清单覆盖。清单范围是声明的输入集合，不声称解决任意动态依赖图；R1成功来源仍按原身份报告。

新库存SHA256 `3eafdc458ee7a0dd06b3a5e47fb1d26396aa30faac950732e82fd20c26f1c0c6`。入口再次完整预检，Gradle8.14 bin SHA256af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab、314运行文件与版本receipt/缓存/定义Hash通过后才认领并调用现有本地Gradle `:app:assembleDebug --offline --console=plain --no-daemon --max-workers=2`，固定普通R1本地Debug参数和localOfflineGradleBin，禁用工具链下载，无ICE/retention/任意额外flags，无Wrapper fallback。

入口总505.485秒，真实构建记录窗口**92.375秒**；**734个样本**。682个样本含UDP endpoint、累计4478条端点行观察，不是唯一socket数/数据报/发包计数。681个主分类为UDP观察的样本继续执行；最后一个强停止TCP样本也含UDP，强条件没有被UDP掩盖。真实日志已进入嵌套AAR任务（含flutter:assembleAarRelease），但独立内层进程身份未单独充分记录，不据此宣称完整构建成功。此前未到内层的历史结论不改写为本轮结论。

最后采样到任务java.exe拥有非回环IPv4 TCP endpoint、state5（连接状态），按既定策略立即break/taskkill自有树，**stopReason NON_LOOPBACK_TCP_ENDPOINT_OBSERVED / entry90 / Gradle1**。无新增内部TCP例外，也没有重试。远端地址和原始进程/socket日志LOCAL_ONLY；该socket行不证明payload、下载或具体远程服务，未收集包内容。downloadLogObserved=false只表示未匹配既有下载日志规则，不证明绝对无网络/无下载。有限采样仍可能漏掉短暂事件。

Gradle stdout SHA256 `0fbc2c233ab87dd83f152c23e23f7ed58ddf59ee79481a3f2f7822d47fe346d5` / stderr SHA256 `6d3b8ee7dc564a062738d52cd5a473391565b56f664e9528daa54201b0fff5aa` / 观察JSONL SHA256 `19222dde39878d8a8f755db0f7d22b6903bb671d74c7b9d2e7e7dae6d5d5f0cd`。stderr中原始Java registry key WARN保留，未隐藏。外层entry打印回执的stdout Hash与Gradle原始stdout另列，不混淆两个通道。Wrapper trap未触发；没有生成普通Debug APK、没有新build/install/pull Hash，安装项 **NOT_RUN_BUILD_STOPPED**。原设备虽由Owner报告恢复连接，探测未找到匹配的既有ADB服务；因构建失败不执行安装或进一步设备流程，不启动/重置全局ADB。

### 终态、历史保护与AC

保护停止后15个具名入口/构建进程均不存在，没有另启Gradle --stop。27084项声明的不可变SDK/JDK/Gradle、缓存module文件及Flutter库/Dart运行输入回核无漂移；1046 tracked源码无漂移。只对声明不可变范围作Hash结论，私有可变cache indexes/生成输出不冒称全树原字节不变。7个任务端口开工/结束无listener，无本任务reverse增删；因无匹配ADB未作设备reverse新普查，不伪造device readback。没有服务/DB/RTC/认证操作，因此本任务未创建call/session/token，不把以前的DB零计数当新数据库快照。原APK未被本任务安装/卸载，不宣称新设备Hash验证。全局Docker/ADB及系统网络/防火墙/代理/环境策略未更改。

26784具名保护文件、5历史根、524开工refs中的受保护项一致；只允许本候选本地/远端分支前进，非整盘审计。前报告142619字节前缀与原Manifest288861字节/Blob在历史提交保留，previousDelivery深比较必须与前原JSON相同；新字段脱敏不递归作用于历史对象。原57次UDP停止记录、10.125秒/0.790秒/R1 0.90625秒与call3/4/5均在各自身份保留。本轮没有RTC旅程，不拼接。原R1下载7941328字节partial / SHA256b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4不变，所有SQL/APK/旧refs/LOCAL_ONLY保留。

| AC | 状态 | 证据类别 | 限制 |
|---|---|---|---|
| 01 | SUPPORTED_BOUNDED_PROTECTION | NEW_READONLY | 26784 named files, five historical roots and protected old refs preserved; candidate not product main. |
| 02 | REUSED_ACCEPTED | REUSED_PRIOR_CANDIDATES_AT_ORIGINAL_IDENTITIES | No message reliability source change or new full journey. |
| 03 | REUSED_R1_BOUNDED_STOP_AND_PRIOR_TOKEN | REUSED_PRIOR_CANDIDATES_AT_ORIGINAL_IDENTITIES | R1 <=0.90625s bounded native endpoints and older call5 first token Upgrade403 remain separate; no new revoke timing. |
| 04 | REUSED_ACCEPTED | REUSED_PRIOR_CANDIDATES_AT_ORIGINAL_IDENTITIES | Picker/player/Range unchanged; not re-run. |
| 05 | PARTIAL_AC05_OPEN | REUSED_PRIOR_CANDIDATES_AT_ORIGINAL_IDENTITIES | No RTC/UI/media run. Prior cleanup diagnostics/AEC limits remain unchanged; no APP/vendor/backend changes. |
| 06 | WAITING_ELAPSED_TIME | REUSED_PRIOR_CANDIDATES_AT_ORIGINAL_IDENTITIES | No new proof of actual 15/30 days; no system clock changes. |
| 07 | WAITING_ELAPSED_TIME_PHYSICAL_PURGE_NOT_RUN | REUSED_PRIOR_CANDIDATES_AT_ORIGINAL_IDENTITIES | Prior controlled tests retained; physical 30-day purge not newly proven. |
| 08 | REUSED_R1_BOUNDED_STALE_CARD_CLICK | REUSED_PRIOR_CANDIDATES_AT_ORIGINAL_IDENTITIES | R1 real accessibility ACTION_CLICK retained at original APK/source; not a new notification test. |
| 09 | REAL_PUSH_PROVIDER_PENDING | REUSED_PRIOR_CANDIDATES_AT_ORIGINAL_IDENTITIES | No provider, keys, production or new fees. |
| 10 | PARTIAL_ACTUAL_BUILD_NOT_COMPLETED | NEW_ISOLATED_TESTS_AND_ONE_FAILED_REAL_BUILD | 43 unit checks/static0, one root build preflight passed then TCP strong stop, entry90/Gradle1, no APK/install. No retry. |
| 11 | SINGLE_BUILD_CANDIDATE_AWAITING_ASTRA | STATIC_NON_AUTHOR_REVIEW_AND_REMOTE_READBACK | Append report and one manifest, exact old JSON preserved; ordinary candidate then stop for Astra. |

非作者GPT-6.1 Sol/high仅只读最终diff及安全派生材料，`NO_NEW_BLOCKING_FINDINGS_STATIC`；确认1/1预算、UDP行数非发包、TCP state5不证明payload/download、库存准备字段不泛化为运行网络结论。43项执行、实际构建、PID/Hash终态是Codex主代理回执，审阅者没有执行本地测试/构建/设备或网络，也不代替Astra验收。

Gate2新启动/Writer/Serializer0；旧0.375/0.390秒已耗、D0-A15次/约0.688秒不重置，37suite/条件Sandbox SDK/Producer/libs.jar/30配置解析NOT_RUN。AEC、最后可闻波形、完整native handle、真实15/30天/物理30天、真实Push、SDK_FRAMEWORK_CLOSE_WINDOW_UNRESOLVED、ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN、OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS不闭合。没有产品main集成、v10.1.6、生产/真实Push/费用或历史清理。

普通non-force候选发布并远端核验Commit/Parent/Root、完整apps/services Tree及两文档Blob/原字节后停止；LOCAL_ONLY完整绑定为 `v1015-single-offline-build-20261026/final-readback.json`。本次构建预算已经耗尽，不自动请求新预算或派发后继任务，等待Astra集中独立验收。


## 2026-10-27 Owner方案一：项目自有AAR init源级修复候选（零真实构建）

**V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / SOURCE_LEVEL_JAVADOC_REQUEST_REMOVED_BOUNDED / PUBLISH_GRAPH_NOT_EXECUTED / AAR_POM_RUNTIME_NOT_PROVEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / BUILD_BUDGET_EXHAUSTED_1_OF_1 / GATE2_NOT_AUTHORIZED / AWAITING_ASTRA**。本轮是Owner正式派发后的最小源码修复和Python隔离回归，不是新构建授权。没有真实Gradle/Wrapper/Flutter/AAR/Kotlin/JVM、任务图查询、APK、设备、服务或实时观察器运行；旧构建预算已耗1/1、剩余0。

### 权威、源码和交付身份

任务分支 `owner/v10.1.5-scheme1-aar-init-javadoc-source-repair-20261027` fresh HEAD `836b0ad12be91400c7638a1982c2bcd1383ddc3e` / Root `b99412cdaf43003b165fe529ba9ec9d7c57ecf23`；正式任务Blob `f2f12b5ab2d766090d66e5d221e6a30658acc483`，ACTIVE_STATE Blob `8efa7a34d735e23ca642c762b6d1e38c90b9ec50`。冻结plan `7d3466b3be67135dc641cfee7c7faef78937ba03`不改；Astra上轮静态接受Blob `74b369ee8d64de9db72651e005484a5b0c5271f8`已读，仍保留根因与具体边未证明。

fresh main `4df2e7f0f36cc7b80258faa73e80dad682cff6c5` / Root `03b0ecfcc360e38a462539dd50690c64b663a21e`；接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。新候选不是产品main。此前静态报告候选3d0c656d59e8621ffa6a935313b5cd4c860a16b1 / Parent7abea213feacc52a1e43c6ed58a40c83009c74df / Root5f0dbe066ba64b1b8ab05c1698a9c48c19fb9553保持原分支/Blob。

连续工作树干净核验后，从最新静态候选建立新分支 `codex/v10.1.5-scheme1-owned-aar-init-20261027`，未reset/stash/amend/force，原源码分支cdf候选不移动。源码Commit `50d79396195ed8b4b86c218584ab59864ad600be` / 唯一Parent `3d0c656d59e8621ffa6a935313b5cd4c860a16b1` / Root `d3c8e2cfbe28e3a1a4e13ac217b868f5cbb7ae20`；apps `e6bff4bc8e359e6afe80c02f25212ee8b6195eab` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。源码提交仅11条白名单路径，最终候选在此基础上只追加本报告和一个Manifest；最终Commit/Parent/Root/Blob及原字节外部绑定LOCAL_ONLY final-readback，避免文档自引用Hash。

### 方案A、许可与最小差异

选择A（跟踪受控衍生副本），因已核验的Flutter BSD-3-Clause许可允许保留声明后的源码再分发，文件仅数KB。没有用方案B运行时生成或替换共享SDK。来源为既有库存定位的Flutter SDK `packages/flutter_tools/gradle/aar_init_script.gradle`：原SHA256 `b6b870954405c5d52afea183bb51b3220100c234401142d8c1bf3e2410cee2c2`。源、原LICENSE与安装版本回执在实施前后只读Hash一致；版本回执为3.41.7 / frameworkRevision cc0734ac716fbb8b90f3f9db8020958b1553afa7，这是本地安装回执，不冒称本轮从上游重新验证的tag或下载来源。

项目拥有目录 `apps/android/scripts/owned_flutter_aar_init/`包含衍生init、原字节FLUTTER_LICENSE、SOURCE.json、UPSTREAM.patch及局部.gitattributes。许可证SHA256 `a3a9fd82f800a47377f7d3f60c60a5c91cae0495be8f329031e1448ce0f5dab9`，副本SHA256 `364295d4d861d81ca3113d25acf6e45dd422ebce64b412ef9baf20e02d32c48d`（7851字节），provenance SHA256 `0f14efe7ed1a2d84be53f2a76a70a343a8bece8dc42f34b368c637c9b17a5f51`，补丁SHA256 `d07b565e23003351d1f9d92df9f50183d8d095b86de026784de1e1267c53b947`。版权/许可与原Hash可审查；没有打包其它SDK、字体或个人数据。

从原始字节使用两组唯一上下文（带对应缩进的withSourcesJar/withJavadocJar相邻行）删除flavor和无flavor分支各一处请求，添加版权及显式scope fail-closed前缀。原源为190个CRLF行；除两条删除行外原body字节均保留。首次准备工具误用LF上下文，检查exit1后保留tool transcript，改为原字节CRLF精确匹配；不是源Hash漂移或真实构建。反向恢复的源Hash仍精确等于原件。局部Git属性防止审计字节在checkout/index被自动改换行，同时保留正常whitespace规则并识别CRLF；没有改全局Git配置。

`withSourcesJar()`两处、singleVariants已有配置guard、maven-publish、from component、AAR注册、finalizedBy publish、插件AAR依赖和其余上游body均保留。没有禁用javaDoc任务、GenerateModuleMetadata、publish/POM或必要runtime产物。**字节保留是静态证据，不等于发布图/产物已通过。**

### 消费路径、Hash与新库存门

Kotlin `syncFlutterAar`在普通R1且非ICE、非retention时选择固定项目副本，并传入 `elitesyncOwnedAarInit=v10.1.5-ordinary-r1-runtime`；scope只是执行合同，不是Owner运行授权。其它R1分支仍选择原SDK init，非R1原Flutter CLI路径未改。已存在的其它模式限制/拒绝行为也未被修复或绕过，本轮不声称这些模式可运行。

新路径在消费前核验原SDK source/LICENSE、项目LICENSE/SOURCE.json/patch/init固定Hash；路径必须在固定项目/SDKroot中，无穿越、符号链接、reparse/other属性或realpath重定向。失败抛出且没有fallback。受控init含scope guard；副本和来源文件被声明为Gradle任务inputs，不能仅因旧AAR目录存在就复用同步任务。旧本地Gradle8.14、offline、无Wrapper fallback与工具链禁下载参数保持。

Python `owned_aar_init.py`执行纯字节推导/验证，不写SDK或生成执行副本。`offline_debug.py`在Observer和任何构建子进程前要求新 `ownedAarInitContract`，以及六个REQUIRED_PROJECT_INPUTS同时出现在inventory与definitions并匹配当前Hash。旧库存不能悄悄证明新图：**NEW_BUILD_INPUTS_REQUIRE_NEW_TRUSTED_INVENTORY**。本轮没有创建新的生产可信构建库存；隔离测试中的小清单只是合成fixture，更没有新构建预算。

### 隔离RED/GREEN、关联回归和静态检查

先运行新源码合同RED：3项、exit1、failures3，原stdout/stderr与退出回执保留。实现后新套件37项exit0；既有关联入口加一项旧库存不能越过新门的回归，共44项exit0，无skip。**这37项是新的Python受控init检查，不是未授权的历史Gate2/Serializer 37-case suite。** 两套测试进程process/socket/native-DLL审计事件均0。新套件使用真实临时字节/路径fixture验证来源、许可证、复制Hash、唯一定位、flavor/无flavor、路径/重定向、来源漂移和新清单；8种模式组合从实际Kotlin选择器提取为受限布尔AST检查，不运行Kotlin。关联44项仍保留UDP/TCP分类、下载/故障强停、Popen失败保留claim和不可重试等mock生命周期断言。

| 运行 | 命令 | case/exit | stdout SHA256 | stderr SHA256 |
|---|---|---|---|---|
| owned-red | `python -B apps/android/scripts/test_owned_aar_init.py` | 3 / 1 | `317a0056618902f5d4de18524791a5667a3ab84181892c18102447db279184e7` | `fa0693650f60daba59f7824d5a5bbdc36c5b8346a9a93664f8a923e52e258cad` |
| owned-green | `python -B apps/android/scripts/test_owned_aar_init.py` | 37 / 0 | `317a0056618902f5d4de18524791a5667a3ab84181892c18102447db279184e7` | `a5e6eadd0e3e966a86c102250dfca9e7dc15aff9361c8efd85c01d14e0421d4e` |
| offline-associated | `python -B apps/android/scripts/test_offline_debug.py` | 44 / 0 | `679ef1f92cbe51cba0332160ca6535c80259b63f2bd03bd4f25eafd37baf645b` | `c381d5bb6c28c2c9fede7a213d4af3008a065338787f3bc0dc72924be925a421` |

本轮LOCAL_ONLY交付准备器首次因多行字符串引号错误SyntaxError/exit1，在写出任何报告前失败；修正后完成。原工具transcript保留，不将它称为产品测试或构建结果，不补造stdout/stderr Hash。

四份修改/新增Python源码用compile(bytes, filename, 'exec')只在内存检查语法，不执行或生成pyc；git diff --cached --check exit0，staged原始字节逐文件与worktree匹配。Kotlin/Groovy只读源码合同和有界非作者静态复核，**未用Gradle/Kotlin/Groovy/JVM解析或编译**；不能写成真实配置/依赖图PASS。Git曾提示未来普通文本换行转换的原警告保留；受控副本/许可/patch的原字节通过局部属性精确跟踪。

非作者GPT-6.1 Sol/high只读白名单diff、受控来源/许可/Hash、测试定义和README，NO_NEW_BLOCKING_FINDINGS_STATIC。审阅者没有执行本地测试、构建、设备或原始日志读取，不替代Astra验收。81项Python执行和Hash为主代理本地回执。

### 源码文件身份

| 路径 | Git Blob | SHA256 |
|---|---|---|
| apps/android/app/build.gradle.kts | `92a2147843756f3ff2c9217250e04cdb2856b9cd` | `0ab0fb3de880ba70d4c3a3e964bcae7d305bbf31676222296f70997493741aee` |
| apps/android/scripts/README.md | `eede4c149250727d267238d9a1dc3b9607bb454a` | `b0f89df727d4e6b2d07c9bf8191b76b2a990a978ff17af2c09dbcc82cbbf7172` |
| apps/android/scripts/offline_debug.py | `635ab8e8dd719db95a2a347e9212d57563a64d45` | `7a854f4723aab8e2fd026f17e63c16abdc1cd33e1f9672d064599eb4bbb154ab` |
| apps/android/scripts/owned_aar_init.py | `526bdcf4764b677a496861328ed2b7f2706e4ead` | `4857b3613aa5762be27a98f34823cb2369c86ac91c68ec0c4c176f3d890d4c0a` |
| apps/android/scripts/owned_flutter_aar_init/.gitattributes | `3067bf834be8e4882a55762d583fff336f199005` | `807fd4a1b5c6ef61391b958edba1d6c87eaf4f3428001ef81d541a9dbb8fb693` |
| apps/android/scripts/owned_flutter_aar_init/FLUTTER_LICENSE | `af093156acc618463cd3f5a502ec6481482897bc` | `a3a9fd82f800a47377f7d3f60c60a5c91cae0495be8f329031e1448ce0f5dab9` |
| apps/android/scripts/owned_flutter_aar_init/SOURCE.json | `3a39b994c2ef705bf0247c57ae77fb331fd9b1bc` | `0f14efe7ed1a2d84be53f2a76a70a343a8bece8dc42f34b368c637c9b17a5f51` |
| apps/android/scripts/owned_flutter_aar_init/UPSTREAM.patch | `1cf1b5de415a0a9aa6190b324f9cb5ae4f1f40c3` | `d07b565e23003351d1f9d92df9f50183d8d095b86de026784de1e1267c53b947` |
| apps/android/scripts/owned_flutter_aar_init/aar_runtime.init.gradle | `7654d90a8b2cc3fd31fafcb18fe589624486a3a2` | `364295d4d861d81ca3113d25acf6e45dd422ebce64b412ef9baf20e02d32c48d` |
| apps/android/scripts/test_offline_debug.py | `e8ba5aaf47e0d6245101a5fc54fa0f50e9e4c88f` | `0aaab4bfa091c69f3939130132c81795529eeabe238b0c7d6e85b3ac59429ff7` |
| apps/android/scripts/test_owned_aar_init.py | `8175888c112acb0b59039ff35d802396107ea496` | `b0a1820f0cb03fe782ec798a6ff32d6540df7e117c711100c96694b8f6e18f60` |

### 资源、保护、剩余AC与终态

结束保护读取器首次因新Manifest预算字段名与旧schema不同发生KeyError/exit1；只修改新任务拥有的读取器，改与原final-readback的固定旧ledger pin核对，再做只读核验。没有改写旧Manifest、claim或保护资产；该工具错误原transcript保留。

开工核验26784具名保护文件、5个历史Git根与524个开工refs中的既有项一致；本轮结束按同一具名范围核验，并核原source/LICENSE/版本回执3文件、52项旧根证据及旧claim。新分支为新ref，原候选/审阅/Owner/main分支不移动；这不是整盘、所有共享SDK或全缓存审计。受保护dirty根不写入，旧SQL/APK、历史失败与LOCAL_ONLY原证不清理。7941328字节partial及SHA256 b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4保留，旧claim Hash07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8不改。

只启动已结束的Python隔离检查/纯文件准备与Git治理进程；没有服务/设备/RTC/认证/DB操作，未创建本任务call/session/token，不冒称新的全局DB零计数或手机/端口普查。SDK/cache未写入。没有新APK、安装或回取Hash，旧APK安装状态未被本任务改变。

AC01～11沿用原证各自身份，未受影响项目未重新运行；AC05_OPEN不关闭。AC10本轮只增加源级修复及隔离证据，真实构建仍ACTUAL_BUILD_NOT_COMPLETED；AC11是待Astra验收的集中候选。Dokka/TCP因果ROOT_CAUSE_NOT_PROVEN、具体历史EDGE_NOT_PROVEN均保留，不能声称文档任务已从真实解析图消失或TCP已消除。AEC、最后可闻波形、完整native handle、真实15/30天与物理30天、真实Push及其它历史限制继续保留，call3/4/5和不同APK不拼接。

Gate2/Writer/Serializer新调用0；旧0.375/0.390秒及D0-A15次/约0.688秒不重置；历史37suite、条件Sandbox SDK、Producer/libs.jar、30配置解析NOT_RUN。产品main未集成、v10.1.6未启动、无生产/真实Push/费用或系统安全策略变更。

证据分为NEW_ISOLATED_PYTHON_RUN、CODEX_REPORTED_STATIC_SOURCE_AND_BYTES、DIRECT_GITHUB_READBACK、REUSED_PRIOR_IDENTITY_ONLY、LOCAL_ONLY_RAW；不把旧实际构建/PID日志写成本轮新运行，不把Codex本地Hash提升为Astra亲验。旧报告155137字节原前缀不改，旧Manifest343530字节/Blob在历史与LOCAL_ONLY保留，新previousDelivery与旧原JSON对象深比较一致，不对历史对象重新脱敏改写。

普通non-force发布一个同版本候选并完成远端Commit/唯一Parent/Root、完整apps/services Tree、全部变更Blob和原字节回读后停止等待Astra。本轮不申请、不运行下一次真实构建，不创建后继任务，不自行接受产品或整版。
