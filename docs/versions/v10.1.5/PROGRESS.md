# v10.1.5 版本进度总账｜2026-11-08

**SOFTWARE_COMPLETENESS_IN_PROGRESS / 10_PARTIAL_AC05_OPEN / G2_FALSE / REAL_PUSH_PENDING**

Owner已明确：[整个v10承接旧EliteSync增加功能、提高APP完成度](../../decisions/OWNER_V10_SOFTWARE_COMPLETENESS_SCOPE_20261108.md)。完成v10.1.6后仍有软件完善、整合、联合质量和评议；版本号不自动触发运营。当前继续v10.1.5，未启动v10.1.6；远期公司/资质/收费/运营另行决定。既有恢复义务、接受成果、冻结AC及保护边界保留。

本表汇总现有具名证据与剩余项，不按提交数/测试数换算完成率，也不将不同候选、不同设备或后端子范围拼成整版PASS。旧plan/task_order签发时IMPLEMENTATION_NOT_STARTED不是当前进度。冻结标准见[plan](plan.md)，本表不降低或重新冻结标准。

## 11项验收状态

| AC | 当前成果/有效证据 | 尚需关闭 | 状态 |
|---|---|---|---|
| 01 基线/数据保护 | 独立产品树、具名源码与运行合同；原dirty根/index、旧库/原证/STOP保护持续核对 | 最终候选统一身份与完整交付保护回执 | PARTIAL |
| 02 消息幂等/故障恢复 | 真机文字往返、冷启；真实MariaDB双同键并发；本次图片同键重放/不同payload冲突与跟踪状态保持 | 当前APP弱网/超时/重连等剩余用户旅程 | PARTIAL |
| 03 授权/跨账号晚响应 | MC/Block/CN关闭/peer禁用的真实后台锁交接；旧peer Bearer401；图片旧URL full/Range拒绝；保留前序WS与切号分项 | 其他接口/主体/时序、APP/WS/cache并发、旧JWT/room与跨账号晚回调、设备缓存直接证据 | PARTIAL |
| 04 私有图片/短视频 | 图片与短视频上传→消息/DB/hash→200/206→撤权旧URL后端子范围通过；Linux真实validator已核2秒合成H.264；本次APP头像上传200/私有文件已核，发信锁页停止 | 修正候选新产包/真机再验；APP图片渲染、视频选择/发送/播放、同最终APK重启及媒体并发 | PARTIAL |
| 05 RTC保护/质量 | 既有RTC实现与历史分项证据保留 | 合格双端RTC/AEC、旧令牌拒绝与撤权提交后≤5秒停媒真链 | OPEN |
| 06 可信15/30计时 | 实际登录T0与冷启/在线恢复不续期已有证据 | 15/30边界、可靠时钟异常/回拨及对应受权路径的剩余验证 | PARTIAL |
| 07 加密离线/清理 | 已修正同namespace单索引损坏/丢失的清理恢复；27项相关Flutter单元检查通过，离线闭锁分项证据保留 | 新源码尚未产APK；Android真实密钥库/密文/清理失败真链、双索引均失及后台/停用边界仍未闭合 | PARTIAL |
| 08 通知隐私/权限 | 既有站内通知、偏好与消息最小payload基线保留 | 当前系统权限拒绝/撤销、锁屏文案、旧通知点击重验及相关撤权矩阵 | PARTIAL |
| 09 Push供应商隔离 | 不将本地开关/替身写成真实送达，真实Push保持PENDING | token登记/轮换/注销与隔离transport剩余检查；真实供应商另需资格/授权 | PARTIAL；真实Push PENDING |
| 10 同候选运行/重启 | 源码Debug产包/真机安装/attach热重载；真机登录/消息/冷启/退出；持久MariaDB后台子范围 | 同一最终APK→API→MariaDB→独立Web→受控重启读回集中验证 | PARTIAL |
| 11 集中交付/审阅 | 节点原证、固定源码/manifest/本地与GitHub回执、非作者复核已持续保存；本表建立集中入口 | 最终整版唯一实施报告/manifest/候选包及统一复核；非作者Codex不是外部独立验收 | PARTIAL |

关键现有入口：[源码Debug产包](../../workflow/V1015_SOURCE_DEBUG_APK_VERIFIED_20261107.md)、[真机源码热重载](../../workflow/V1015_REDMI_ACTUAL_SOURCE_ATTACH_HOT_RELOAD_VERIFIED_20261107.md)、[文字往返/冷启](../../workflow/V1015_REDMI_TEXT_COLD_VERIFIED_LOGOUT_NAV_STOP_20261107.md)、[真机退出撤权](../../workflow/V1015_REDMI_LOGOUT_REVOCATION_VERIFIED_20261108.md)、[双同键/MC并发](../../workflow/V1015_MESSAGE_CONCURRENCY_DUPLICATE_MC_VERIFIED_20261108.md)、[Block/CN/禁用并发](../../workflow/V1015_MESSAGE_PERMISSION_MATRIX_BLOCK_CN_DISABLE_VERIFIED_20261108.md)。这些历史成果本轮未重测，限制继续按各原证保留。

## 本节点：真机头像上传后锁页停止，前台回调修正通过40项单元检查｜2026-11-08

**PHONE_IMAGE_UPLOAD_ONLY_LOCK_STOP / BACKEND_SPENT_1_REMAINING_0 / SOURCE_FIX_GREEN40_VERIFIED / FIX_NOT_ON_PHONE / G2_FALSE**

Owner继续APP媒体验证，并指定本机三张图片用于测试。仅复制三份私有输入，不压缩、不改原件；三图均低于5MiB。加上先前合格的2秒无声合成H.264短片，共四份测试副本导入同一Redmi的独立测试目录并逐份核hash。没有枚举个人图库或读取其他照片；系统选择器无法证明测试目录位置时转Owner手动选择。Owner明确选择第二张头像，实际返回APP后才继续；不以文字回复代替设备观察。设备仍主用户0、包com.elitesync.v1015dev、APK SHA256 `974ef00c5803c87acee457d6010648f4b1fb0868fecc966e61e3ad363017a4dc`；本轮未重编、重装或热重载，APK构建源码c5e2dc34保持。

### 真机实际结果与停止

独立一次范围`V1015_REDMI_PRIVATE_MEDIA_20261108_01`，运行输入源码2ef36835、services树4530ae85754a2f3698d073182a47038708f2cb55。同机同APP调试许可及既有同类本机工程委派承接，旧范围/claim/STOP不改。新私有PHP8.4/MariaDB/WS就绪，真实虚构账号登录、CN/MC放行及APP聊天页通过；同一手机会话/完整UUID绑定的POST `/api/v1/media`实际200。存储中private asset1为ready image/jpeg、16900字节，DB与backing SHA256 `4fdb16490556b2221235ac34d093c0a95727a90d63789ccf764b19c4435552e8`一致；JPEG重新编码后的RGB平均绝对差约0.374，与Owner指定头像原件匹配，三份原件hash均保持。不是合成图片，不把不同编码字节假称完全相同。

**手机未发送成消息**：该phone-image phase无POST `/messages`；8份相邻快照均为asset1、attachment0、只有预置文字message1。回到APP的原生观察显示“会话已锁定”和“可信登录或加密保存未能核验，私密内容已锁定，请重新在线登录。”；检查在预期消息/附件未出现后停止，未点第二次选图或自动续跑。图片实际聊天渲染、短视频选择/发送/播放、APP冷启动读回、媒体撤权重验及退出均**NOT_RUN**。源码可提出生命周期重验重叠机制，但未捕获设备回调/缓存失败原因，**本次真机唯一根因UNKNOWN**。

后端279.391秒，已耗1余0、controller0、cleanup_errors空；手机累计110条ADB、1次Activity、0次force-stop。合计2GiB/启动3072MiB/1800秒/统一45秒收尾/8GiB卷/2GiB输出采样、离线、一次start/migrate/seed、DB restart0保持；fresh核验仅由既有入口完成一次，可用10408MiB/卷空闲353235574784字节只属本次历史快照。新三个容器停止/PID0/无OOM，WS/API/DB退出0/137/0，API137不归因；新卷/网络留存，170个旧容器完整State不变且均停止，共享引擎保持运行。两个reverse、UI临时文件和四份手机测试副本按精确自有路径清理，无个人原件操作；手机最后的APP锁定状态不冒称已正常退出。无新引擎、构建/重装、其他设备、云端或费用操作。

### 新源码候选及定向单元检查

修正源码`65b22f632cf108f34018fd22de6665eb81933757`，apps树`588c408dd594eabcc83599a2af9596b4c7cb1691`，services树保持。只改LiveChatPage及定向测试：已在前台时忽略重复resumed通知，实际后台→前台仍重新验证；统一current guard及picker返回都明确拒绝timeLocked。保留epoch/session/account/服务器权限与真正安全存储失败的硬锁，不因上传已成功就强发消息；PrivateCacheService本节点未改。新增两例：暂停一次真实fake-store写期间重复resumed不得作废同代保存；picker期间缓存确实写失败锁页后，旧picker返回不得触发preflight、上传或发信。

预先计划的RED/GREEN各一次且均已耗1余0。RED真实启动SDK/root，root1/controller32；两例目标判据失败，同时受`--no-test-assets`缺ink_sparkle着色资源影响，随后包装器还出现GBK打印错误。原始UTF8日志/outcome保留，**不称干净产品RED**。后续只为原计划GREEN启用既有本地UI test assets、修正日志打印，没有下载/Pub安装/SDK升级或重跑RED。

GREEN **40项Flutter检查通过**（聊天可靠性21、Socket生命周期4、缓存15），20.813秒、root/controller0，峰Job2314915840字节；Job4GiB/64进程/启动5120MiB/SDK300秒/host360秒/共享45秒收尾/8GiB卷/2GiB输出采样保持。仅物化79个直接传递输入，无SDK复制；79文件与当前产品hash一致，两改动文件另绑定最终Git Blob。5个已存在SDK关键文件hash不变，legacy version前后均不存在。stderr保留隔离夹具`Error: unable to find directory entry ... assets/config`诊断，测试退出0且40项通过；不是完整素材/APP环境验收。内存Secure/虚构时间/受控API与picker替身仍不是Android实际密钥库、相机/图库或端到端通过。

启动前新增选择器/混合界面/原子收尾记录7项纯检查通过，4项静态P2在启动前关闭；真实磁盘故障注入未测。非作者源码复核无P1/P2；实际停止原证与GREEN非作者复核无P1/P2，不是外部独立验收。新源码**尚未产包/装机**，不得把GREEN或代码机制当作原手机锁定原因已证、原APK已修复或AC04/07闭合。

LOCAL_ONLY根名`v1015-redmi-private-media-20261108-case01`：先读IMPLEMENTATION_REPORT.md、verified-phone-image-upload-only-private.json、phone-media-failure/cleanup、phone-image各快照、completed-phone-media-stop-source-fix-seal-private.json、GREEN outcome/result/原始stdout及保留RED failure/stdout、非作者复核与最终回执。ledger承接21400项，仅追加本节点和上一最终回执；三张指定原件只核既定hash，不重扫旧SDK/AVD/Sources。原dirty根255项/index与%SystemDrive%保护。仍10 PARTIAL/AC05 OPEN/G2 false/真实Push PENDING，不合main/发布、不启v10.1.6或运营。后续新产包/同机后端复测须另有明确当前一次范围，旧STOP/已耗不退款、不靠换目录续额。

## 前序节点：私有短视频真实后端链通过｜2026-11-08

**REAL_PRIVATE_VIDEO_LINUX_VALIDATOR_UPLOAD_DB_RANGE_REVOCATION_VERIFIED / SPENT_1_REMAINING_0 / APP_PLAYBACK_NOT_RUN / AC04_PARTIAL / G2_FALSE**

Owner回复“可以请继续”，结合既有同类普通本机工程委派，为已准备的合格视频输入建立独立一次范围`V1015_PRIVATE_VIDEO_20261108_01`；不是重试前序图片或已耗范围。旧grant/nonce/claim/STOP与失败保留，未恢复额度。输入源码`0a2db4b1991a473e22ac7c5c869276d79ef5d036`，只扩充脱敏媒体证据helper与纯检查的MP4 MIME判据，未改APP、鉴权、消息或媒体产品服务；apps树02ccf83153d0ce9ab5b522816aac2b1925c27862、services树4530ae85754a2f3698d073182a47038708f2cb55保持。复用726文件服务快照和114包/9161文件vendor，不重复复制；Linux工具及短片只读挂载，238个Linux输入文件hash由启动入口核验。

真实PHP8.4.27/Laravel13.39.0/MariaDB新独立空库：迁移前，固定Linux ffprobe实际执行成功，真实`App\Services\PrivateVideoValidator`直接校验只读短片，未替换容器绑定、探针结果或存储。实际得到video/mp4、H.264、128×128、2000ms、25976字节、无音轨及validation=`ffprobe-mp4-h264-v1`；ffprobe文件hash与固定输入一致。只接受本进程固定路径/共享库目录，没有安装镜像内工具、改系统PATH/网络、下载、接受新许可或启动引擎。

同一纯合成短片SHA256 `01354babdf240a57f6345df930002b49908c359a6c8ad5303676cdf9023ec80d`实际经multipart上传，private asset1 ready→message1/attachment1→持久DB与backing文件哈希/元数据一致。未绑定owner200、receiver/第三人404、匿名401；绑定后a/b完整200、两段Range206（0–15与末8字节），实际字节/长度/Content-Range及private/no-store/max-age0、Vary Authorization/Cookie、Accept-Ranges、nosniff均匹配。异主附件422、同键重放同ID、不同payload409，逐操作快照中的6类媒体/消息状态保持；坏图片/坏视频/伪造storage/public URL各422，不生成假READY。

真实MC route200提交后，同一个旧URL的a/b完整及Range共四404，旧消息history/旧键重放两404；无视频字节、成功身份、URL或私有caption/key/hash泄漏。CN保持ACTIVE revision2、双MC变REVOKED revision3；assets（含本任务backing hash）、messages、attachments、消息通知、message_sent events、processing_jobs六类具名状态前后一致，不宣称所有DB字段或设备缓存零写入。26条媒体HTTP结果与实际body逐一核hash/长度，原始请求/响应及快照仅本地保留。

8项纯协议检查通过，新增MP4完整/Range字节、MIME/隐私拒绝及multipart类型/内容检查；本机PHP仅语法预检，实际运行资格来自本次PHP8.4实例。非作者静态候选复核无P1/P2；实际原证非作者复核无P1/P2（seal、26条实际body、DB/hash、撤权副作用与收尾一致），不是外部独立验收。

后端实际101.796秒，已耗1、余0，无重试，controller0/verified=true/cleanup_errors空。合计2GiB、启动3072MiB、1800秒/共享45秒收尾、8GiB工作卷/2GiB输出采样保持；一次start/migrate/seed，DB restart0、离线。完整fresh核验仅由既有入口执行一次，可用10623MiB/卷空闲353442820096字节只属于本次历史快照。新WS/API/DB均停止/PID0/无OOM，退出0/137/0；API137保留、不归因。新卷/网络留存，167个既有容器完整State保持且均停止，共享引擎继续运行；新引擎启动、手机/ADB、SDK/AAR/APK/安装、云端/真实数据/费用均0。

此结果关闭的是短视频Linux校验与后端正向子范围，**APP选择/播放、相同最终APK受控重启、媒体撤权并发均NOT_RUN**；旧手机APK仍不含前序缓存恢复修正。AC04/AC03仍PARTIAL，AC05 OPEN，整体10 PARTIAL/G2 false/真实Push PENDING；不合main/发布、不启v10.1.6或运营。

LOCAL_ONLY根名`v1015-private-video-lifecycle-20261108-case01`：先读`IMPLEMENTATION_REPORT.md`、`linux-real-validator-private.json`、`verified-private-video-private.json`、`completed-private-video-seal-private.json`、实际HTTP body/前后快照、outcome/cleanup、非作者复核与最终回执。保护ledger承接21139项，仅追加本节点和上轮最终回执，不重扫旧SDK/AVD/Sources；原dirty根255项状态/index及%SystemDrive%保留。原证、工具/短片、凭据、SQL、许可原件不上传GitHub。

## 前序节点：离线缓存单索引恢复修正与视频输入准备｜2026-11-08

**CACHE_SINGLE_INDEX_RECOVERY_UNIT_VERIFIED / VIDEO_DEPS_PREPARED / LINUX_VIDEO_NOT_RUN / APK_NOT_REBUILT / G2_FALSE**

Owner继续既定v10软件完善工程，并明确回复“允许补齐短视频依赖”：范围只为私有工具/合成片准备，先核来源与许可，不升级现有环境、不自动接受额外条款，不启动设备或消耗新后端/AAR/APK额度。旧范围、nonce、claim与STOP保持封存，没有恢复余额；v10.1.6及运营均未启动。

### 离线清理修正及实际检查

源码固定`747247ee697f7d6c9530aa5046bde5dfbfdee630`，apps树`02ccf83153d0ce9ab5b522816aac2b1925c27862`，services树4530ae85754a2f3698d073182a47038708f2cb55保持。仅改`private_cache_service.dart`及其定向测试：原单一manifest丢失会被当空，坏JSON则无法完成清理；现在同一已知账号/device namespace内增加恢复索引，保存按恢复索引→主索引→对象写入，保存和清理都读取可解析索引并集。每索引≤128，清理并集最多256；超过写容量拒写并锁定。存在损坏且没有有效索引时清理failed/锁定，不把坏索引当清理完成；对象逐删除/回读成功后才删除并核验两个索引，失败保留可重试清单。保存、removeObject及索引解析统一拒绝控制键名。兼容旧主索引，不枚举全局存储、其他账号、凭据或历史原证。

同进程可信时钟、15/30天语义、重启后必须重新在线核验的锁定行为不变。双索引同时缺失仍不能区分新空namespace与失索引孤立对象；后台/停用设备的物理到期删除及跨重启离线授权没有因此获得保证。这些边界继续保留，AC06/07仍PARTIAL，无需重开已冻结的fail-closed方向选择。

定向GREEN **27项Flutter单元检查通过**：缓存15项（新增10项单索引丢失/损坏、保存后清理、无有效索引失败、清理重试、恢复索引写失败、控制名隔离及旧格式兼容），旧明文键清理4项，15/30策略8项。实际运行约40.078秒、controller/root0、原生Job4GiB/64进程/SDK300秒/host360秒/45秒收尾，峰Job1729736704字节；启动门5120MiB、卷8GiB/输出2GiB采样及离线保持。只准备11个直接相关项目文件，无SDK复制、Pub下载或设备/Gradle/AAR/APK/后端；5个已存在SDK关键文件hash前后一致，legacy version一直不存在。11个测试输入逐个与产品工作树核对，两个变更文件另绑定最终Git Blob。

预先计划RED/GREEN两次定向单元调用；首次RED控制调用因主代理加入被原边界禁止的`FLUTTER_ALREADY_LOCKED`参数而停止，root_create_attempted=false、sdk_start_observed=false、controller32，未执行产品测试。其claim已耗1余0保留，不记作产品RED复现。修正适配时删除该参数，未放松原边界；随后只执行原计划GREEN一次，该范围已耗1余0，无自动重跑。非作者发现新测试wrapper的STOP写盘失败可跳过收尾，启动GREEN前修正为无条件held-controller收尾、SDK审计及回执尝试，保留原错误和共享截止时间；3项纯故障注入检查通过，真实故障注入未测。非作者最终源码/输入/原证复核无P1/P2，非外部独立验收。

27项结果使用MemorySecure替身和虚构时间，未测Android密钥库或手机实体删除，也未真实经过15/30天。**本节点未重编APK；已安装旧APK不含这次缓存修正**，不能据本节点关闭APP/加密离线/最终候选门。

### 视频依赖与合成输入

对旧视频交付的3份直接相关记录作有界只读查找，Q绝对路径/旧工具来源仍UNKNOWN，未扩大考古或启动旧环境。发布项目由旧BtbN路径规范重定向至`FFmpeg-Builds/FFmpeg-Builds`；原连接器ID端点不支持、一次匿名REST返回rate limit，随后按规范公共仓库读取固定发布，没有切换凭据或修改网络。

选定发布`autobuild-2026-11-07-12-47`（release ID437572827），稳定8.1分支`n8.1.3-34-ga35157abb9`的Linux x86_64与Windows x64 **LGPL shared**包，私有稳定根名`toolchains/ffmpeg-8.1-a35157abb9-lgpl-shared-20261107`。Linux归档SHA256 `67260ceeaa91dfc464dbad72e6d6b47e4548ff657a98cd65d619165f6a595e64`；Windows归档`1ae156959395f0f0b3ad97674de02dc21fb3bbee01142a0d8f744467b5cd5886`。两者同时核GitHub资产digest和同版checksums.sha256；这是发布方完整性校验，不冒称签名者认证或可复现构建。LGPLv3原许可证及其所引用的GPLv3/上游源许可说明保留；无gpl/nonfree/x264/x265开关，没有点击接受额外条款或改变系统PATH。Linux archive内部共享库别名在NTFS物化为同字节文件，未要求系统链接特权。464个工具/文档/归档文件共923936361字节有本地manifest，二进制/许可原件不上传GitHub，不装入既有后端镜像。

Windows端实际完成6条工具自检/准备命令：ffmpeg/ffprobe版本、编码器及选项、生成、ffprobe解码计帧。使用纯testsrc2图案与Windows已有MediaFoundation软件H.264编码器（hw_encoding=0），不调用摄像头/麦克风/手机，不引入GPL编码器。所得MP4为128×128、2.0秒、无音轨、20帧经实际解码计数，25976字节，SHA256 `01354babdf240a57f6345df930002b49908c359a6c8ad5303676cdf9023ec80d`。这是真实合成H.264输入，不是伪造ffprobe JSON或模拟素材状态。

Linux端ABI/动态链接、PHP真实PrivateVideoValidator、后台上传/消息绑定及APP播放均**NOT_RUN**。已存无claim的输入候选：后续可在获准新实例只读挂载Linux目录，设定精确ffprobe路径与本进程LD_LIBRARY_PATH；不修改系统库/网络、不借用已耗范围。此次后端/生产SDK构建/AAR/APK/安装/手机启动均0；Windows工具准备不等于AC04视频正向通过。实际新后端验证还需其独立当前范围与一次fresh检查。

LOCAL_ONLY根名`v1015-video-dependencies-and-offline-recovery-20261108`：先读`IMPLEMENTATION_REPORT.md`、`verified-source-and-video-binding-private.json`、`verified-video-inputs-private.json`、GREEN outcome/stdout、保留的RED failure、`prepared-video-input-candidate-private.json`及最终回执。原dirty根255项状态/index及%SystemDrive%保护；ledger承接20567项，仅追加本节点和新获准工具输入，不重扫旧SDK/AVD/Sources。整体仍10 PARTIAL/AC05 OPEN/G2 false/真实Push PENDING；不合main/发布，不启v10.1.6/运营。

## 前序节点：私有图片真实后端链通过

任务`V1015_PRIVATE_IMAGE_20261108_01`，在Owner当前继续和既有同类普通本机工程委派下建立独立一次范围；前次所有已耗claim/STOP保持，不退款/重试。源码输入`063379626f5b282bc16c7b3023e0dbdd29d8c79a`；新增[媒体证据helper](../../../tools/acceptance/v1015_private_media/README.md)，未修改产品APP、鉴权、媒体或消息服务。apps树b673913a4ff0ff1a8bfc83ca98951ff1556a2f23、services树4530ae85754a2f3698d073182a47038708f2cb55保持。复用只读726文件服务快照/114包vendor，没有重复物化源码/SDK或框架迁移。

实际PHP8.4.27/Laravel13.39.0 HTTP API与持久MariaDB，新空库93表/单事务4虚构账号；3个账号真实登录、a/b真实CN/MC放行。使用本轮生成的32×32纯合成PNG，99字节，SHA256 `a99021907f3411b56426e791a2199d43d00a0a50b5ef3b09f02ad89b30e43943`，无个人照片或旧媒体输入。

| 实际操作 | 真实结果 |
|---|---|
| 坏图片、坏视频、伪造storage/public URL三次上传 | 各422；前后所跟踪6类媒体/消息数据均为空且相同，未造假READY |
| multipart PNG上传→发信→持久化 | private v1009 asset1 ready，实际文件/asset SHA与99字节一致；message1/attachment1/通知/发送事件各1；normalize job succeeded |
| 未绑定与绑定读取 | 未绑定owner200，receiver/第三人404、匿名401；绑定后a/b完整200，均为相同原始PNG字节 |
| Range与隐私头 | bytes0-15/99及91-98/99均206，分别16/8字节且等于原PNG切片；Content-Range、private/no-store/max-age0、Vary Authorization/Cookie、Accept-Ranges、nosniff合格 |
| 异主附件、重放与冲突 | 异主发送422；同键同payload返回同ID/replay；同键不同payload409；逐操作相邻快照确认6类跟踪数据无重复或原地改写 |
| 真实MC撤权后旧入口 | MC route200提交，CN仍ACTIVE revision2、双MC REVOKED revision3；同一个旧URL的a/b完整及Range共四404，历史/旧键重放两404，无PNG、私有caption/key/hash、成功身份或URL指针；跟踪状态不变 |

共26条媒体HTTP结果/body有hash与长度原证；登录/授权请求另记。捕获范围为assets（含本任务私有backing文件hash）、messages原始存储、attachments、message notifications、message_sent events及processing jobs，不宣称所有数据库字段/系统零写入。实际图片handler与存储未替换，不用Storage fake或mock kernel。HTTP禁代理/重定向，返回URL须匹配本任务精确loopback origin/asset，令牌不发到外部地址。

6项纯检查通过；内存中绕过拒绝身份判据会被纯检查拒绝。启动前非作者复核发现并修正两P2：解码URL/成功字段/私有marker漏判；foreign422/replay/conflict缺相邻快照。实际原证非作者Codex复核无P1/P2，不是外部独立验收。原生PHP8.5仅语法预检，本次图片链已在合格PHP8.4实际运行；真实故障注入收尾未测。

后端实际95.453秒，已耗1、余0，无重试，controller0/verified=true/cleanup_errors空。合计2GiB、启动3072MiB、1800秒/共享45秒收尾、工作卷8GiB/输出2GiB采样、一次start/migrate/seed及DB restart0、离线保持。完整fresh核验只在既有入口执行一次：可用11727MiB、卷空闲354579017728字节仅为本次历史值。新WS/API/DB均停止/PID0/无OOM，退出0/137/0，API137不归因；新卷/网络留存。164个既有容器完整State前后一致且均停止，共享引擎保持运行；本轮没有新引擎、手机/ADB、产包/安装、云端、真实数据、外部服务或费用操作。

短视频正向**NOT_RUN**：开发配置没有合格ffprobe路径，对既有停止PHP实例的两个具名`/usr/bin/ffprobe`与`/usr/bin/ffmpeg`只读路径检查均不存在，旧实例State保持；不据此宣称全机不存在工具。未下载安装、接受新许可或用模拟verifier替代；坏视频422仅为负例。历史v10.0.9接受的视频成果保留，未按旧运行手册启动旧库/服务或无限寻找旧资产。当前APP选择/渲染、重启及媒体撤权并发均NOT_RUN，AC04/AC03仍PARTIAL、G2 false。

LOCAL_ONLY根名`v1015-private-media-lifecycle-20261108-case01`：先读`IMPLEMENTATION_REPORT.md`、`verified-private-image-private.json`、`api-observations`具名前后快照、`backend-storage/media-http`结果/body、`non-author-actual-image-review-private.json`及最终回执。原dirty根255项状态/index及%SystemDrive%保护；ledger承接20304项仅追加本节点和上一最终回执，不重扫旧SDK/AVD/Sources。配置/token/SQL/私有日志/媒体不上GitHub。不合main/发布、不启v10.1.6，不自动建立后继动态额度。
