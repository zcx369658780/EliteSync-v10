# v10.1.14阶段A实施报告

2026-11-15。工程自验六项AC按下列具名代表范围PASS，顾问独立验收和Owner接受均PENDING。交付分支为 `codex/v10.1.14-product-readiness-core-journeys-20261115`。集中交付后的下一动作是顾问独立验收。

## 代码与候选身份

| 项目 | 固定身份 |
| --- | --- |
| 唯一父基线 | `5dd0c9e6625699947f8dd0755ff568a3edfe0b04` |
| 任务文档固定提交 | `866ccb269603ab451f84e948fa23d7361362f33f` |
| APP源码 | `88540f7f4d5a64500996b67eb04bfd9aba7c0af3` |
| API最近改动提交 | `d9c49dd8d6f5721c56f5cfc87b2cbaf721819883` |
| Web沿用源码 | `e2448e2c4d630fad31168e3c0b70d3831011215f` |
| 最终候选 | 10.1.14-dev / 1011402，Debug，arm64-v8a |
| 包名 | com.elitesync.v1015dev |
| APK SHA256 | `b5cc7e9bbca910a0e4da3af0a64e56d99eb82bb848743786c62244bb59c8e2b1` |
| APK字节数 | 123928582 |
| 签名SHA256 | `7c023c0fbdab8cd4f53daedbc95badb47d5f968b2c267d94fa695655f391bd42` |
| 构建 | 退出码0，76.07秒 |
| 安装后核对 | A5580/用户11、B5582/用户12哈希均与最终APK相同，保留应用数据 |
| 数据库迁移 | NONE，复用现有主媒体外键 |

1011401已由中间候选占用，修复P1后顺延至1011402。原APK及失败记录保留。构建快照中的BUILD_COMPLETED_UNVERIFIED与NOT_STARTED属于构建完成时的阶段字段，后续签名、安装及运行回执分别验证。最终交付提交包含本报告与manifest，产品代码由上列源码提交固定，远端同步结果由最终同源回读回执绑定。

## 路线同步与实现

编码前完成九份文档的Git Blob与规范化内容比较，并提交路线ACK。完整路径及Blob见[同步回执](LOCAL_DOCS_SYNC_RECEIPT.json)。DEVELOPMENT_ALIGNMENT的六个源码锚点在实施后对固定父基线对象补核，全部匹配。起始跟踪树干净，父基线到任务文档提交只有文档变化。源码锚点补核的时间阶段按实际记录。

社区沿用cover_media_asset_id和MediaAsset。API接受ready私有图片，或带既有ffprobe验证标记的MP4视频。视频保持25MiB、30秒、H.264及可选AAC约束。APP保留标题、正文、SELF/FRIENDS，主媒体图片或视频二选一，卡片主动打开既有私有播放器，具备加载、失败、播放和暂停反馈。现有私有鉴权及逐次权限重验继续执行。旧图片记录由原字段读取。

发现P1 `V10114-P1-01`，系统文件浏览器返回触发权限代际更新，会清空未发布草稿并丢弃选择结果，阻断发布。修复使作者草稿与上传绑定原会话token，权限代际刷新继续清除远端Feed和图片。切号清空草稿及丢弃旧结果。先红后绿的五项页面回归及最终候选普通文件浏览器发布已验证。

## 六项AC工程结论

| AC | 工程状态 | 实际范围与交付 |
| --- | --- | --- |
| AC14-01 | PASS | [核心旅程矩阵](CORE_JOURNEY_MATRIX.md)覆盖规定旅程，区分历史范围、当前入口、证据、未覆盖和P0至P3。具名范围未发现新增P0，P1已修复，P2保留。 |
| AC14-02 | PASS | 真实APP/API/私有媒体视频发布、作者播放暂停、好友撤回、完整与Range鉴权、临时视频删除。PHP负向覆盖拉黑、账号禁用等，详见摘要。 |
| AC14-03 | PASS | 普通APP保留20图文+5视频，3个虚构账号核边界、分页、作者页、互动、删除、切号、重登和冷启动。[内容索引](QA_CONTENT_INDEX.md)及[25份许可清单](MATERIAL_LICENSES.json)。 |
| AC14-04 | PASS | 登录切号、资料隐私、资格拒绝、独立CN/MC、两模拟器消息136、社区、好友/Buddy和工具历史具名代表验证，P1修复通过。 |
| AC14-05 | PASS | [服务恢复手册](LOCAL_SERVICE_RECOVERY.md)，原服务有序重启、就绪探测和持久读回；独立卷104表全行与59媒体哈希恢复一致。 |
| AC14-06 | PASS | 最终1011402候选及本机Owner评估包已准备，签名/安装哈希/资源状态具名记录。[功能目录](FEATURE_CATALOG.md)及[实机检查表](OWNER_DEVICE_CHECKLIST.md)，手机动作均OWNER_ACTION_PENDING。 |

当前软件检查范围与Owner手机操作分别记账。六项工程PASS限本表和[证据摘要](EVIDENCE_SUMMARY_20261115.json)中的实际通道及条件。

## 测试与运行证据

15项唯一Dart定向测试，包括10项实体/卡片/私有播放器与5项P1页面测试。PHP为9 tests、86 assertions。四个改动Dart源码分析通过，P1页面与新测试最终分析通过。通过后的未改代码沿具名结果复用。文本日志保留通过信息，其独立进程退出码未作为单独字段存档。构建退出码0及本轮运行助手退出结果有回执。

非作者只读代码审查在固定父基线至88540f7f范围未定位具体P0/P1。建议补充的延迟picker和真实列表provider测试已经加入。上传发出后切号再延迟回执的专门测试仍缺，回执消费前的token guard已复核。该工程审查与顾问独立验收分别记录。

25条内容均经普通APP发布。I01至I04使用1011401，后续21条使用1011402，最终候选读回全部内容。23条FRIENDS、2条SELF。16为作者，17为好友，21为非好友。16和17服务端synthetic为true，21为既有虚构账号且标记false，保留原标记。所有素材在发布前逐份检查Commons CC0来源、作者、许可和哈希，使用中性题材和原创英文配文。5段视频经本机QA预处理成约4.4至8秒静音H.264，产品上传执行原验证直通。

好友17播放V04后，作者通过普通API撤为SELF，等待2.5秒后播放器显示不可用，旧完整/Range均404，finally恢复FRIENDS。原生缓冲零尾延迟UNVERIFIED。临时视频36由APP发布及删除，好友原Range206，删除后完整/Range404。上传者仍可读取本人已解绑媒体200/206，符合既有上传所有权规则。初次删除脚本把作者所有权也断言为404，后按实际合同纠正并保留原失败。

消息136由A普通APP发送，B普通APP实际接收，API确认单条归属16→17。CN3、MC45和MC46及其revision在社区动作后、服务重启后均一致。非好友21→16读消息和发送均404。本人城市保存、隐私履历保存后清除、SELF受众revision1通过。合成作者的synthetic_account_excluded反馈准确。21本人MBTI历史8及反馈7版本2 resolved读回。

Buddy和平台活动的当前终态由API记录确认，APP确认入口可达。17张代表截图保留原可视区域，截图说明逐张区分可视内容和API/UI层级原证。[截图索引](evidence/SCREENSHOTS.json)。原料媒体二进制及原始日志继续由Owner本机保管。

## 服务、恢复及资产保护

开工备份恢复104张表行数与20个媒体哈希一致。最终备份数据库3235863字节、整个storage/app归档18237440字节。独立新卷、network none恢复后，104表全部canonical行值一致，59个媒体文件哈希一致。两恢复容器均停止，卷及原证保留。

原WS/API/DB有序停止启动，SQL及HTTP/TCP逐次探测回执保留，容器ID、挂载和网络模式一致，25条内容、消息136和CN/MC重新读回。API登录页200，WS TCP可达。SFU本版短暂启动，内部健康200，主机根403对应已有鉴权网关，随后停止。最终DB/API/WS运行，SFU exited。双模拟器停止，AVD和数据保留，adbd恢复普通shell，B临时输入设置恢复null。手机NOT_USED，PC指针与键盘未接管。

原D:\EliteSync-v10的HEAD、分支、porcelain-v2 status、index字节、跟踪diff及cached diff与本版开工完全匹配。最初比较用了不同porcelain格式及untracked展开参数，纠正为开工v2后匹配。稳定根原有%SystemDrive%/保留。私有配置、数据库、媒体、SDK、AVD和历史失败保留。

## 评估包和保留事项

本机评估目录为 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev\v10114-current\OWNER_REVIEW_1011402`。含APK与SHA256、说明、QA账号本机凭据、功能目录、旅程矩阵、素材许可、恢复手册和Owner检查表。Owner自行操作手机，安装/升级、系统权限、键盘、通知、后台恢复、音频外设和双设备RTC均OWNER_ACTION_PENDING。

- P2 `V10114-P2-01`，2GiB模拟器在文件选择期间LOW_MEMORY回收，未发布内存草稿丢失，重启后可重填发布。最终A使用同一AVD/数据和3GiB内存，B2GiB。OS回收后的草稿与lost picker data恢复留后续。
- 视频样本全部静音，人耳听感NOT_RUN。真实Push、真实身份核验、算法独立精度和RTC硬件矩阵沿原范围。
- 新注册/改密、全盘型矩阵、新Buddy邀请及全部等待态本版NOT_RUN，具体未覆盖见旅程矩阵。
- v10.1.13的DB首轮逐次探测回执缺失、辅助日志误追加、原status历史原因UNKNOWN和通知卡精确ID UNKNOWN保留。本版原库状态匹配仅证明本版起终点。
- 首次隔离导入曾因mariadb-admin ping误判认证就绪失败，后改SQL SELECT1并恢复成功。metadata限速429按Retry-After等待，原限制保留。Gboard笔输入教程拦截通过模拟器临时设置处理，结束前恢复。原始失败与重试回执均留本机。

阶段A工程交付完成后等待顾问独立验收，Owner接受PENDING。main集成和正式发布NOT_RUN。后续阶段按Owner新指令推进。
