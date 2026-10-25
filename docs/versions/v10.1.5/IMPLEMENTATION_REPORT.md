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
