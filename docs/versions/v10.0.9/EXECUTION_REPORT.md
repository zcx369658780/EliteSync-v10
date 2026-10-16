# v10.0.9 候选交付报告：等待 Astra 独立终验

## 2026-10-16 最终候选集中报告

**V10.0.9 CANDIDATE DELIVERED — AWAITING ASTRA FINAL ACCEPTANCE / NOT_ACCEPTED**。本节为最终状态；后文所有阻塞、未安装、未测试、运行中或FROZEN_NOT_RUN是原时点，不覆盖本节。候选分支`codex/v10.0.9-rtc-media`，只普通non-force推送，未合main、未K08、未启动后继版本。最终远端Candidate Commit/Tree以交付回执及Owner收到的固定链接为准（文档不能自含自身Git hash）。

远端首次交付已于2026-10-16T18:18:23.462471+08:00普通推送并读回：[Commit 635d9088dd7d182bfc250387ac963b575f96b223](https://github.com/zcx369658780/EliteSync-v10/commit/635d9088dd7d182bfc250387ac963b575f96b223)，Tree `b30372bafe10717ee4f96db7baab51b48fd2be26`。随后只登记这份交付状态，不改产品；最终交付文档提交的精确Commit/Tree在Owner收到的最终回执固定。

关键公开资料：[安全媒体统计](evidence/20261016-final-device-safe-summary.json)、[旋转/前后台统计](evidence/20261016-rotation-background-safe-summary.json)、[横屏](evidence/final-video-landscape.png)、[回前台设备保持关闭](evidence/final-video-return-devices-off.png)、[完整播放片中](evidence/final-private-video-mid.png)、[片尾](evidence/final-private-video-complete.png)、[撤权错误界面](evidence/final-call-revoked-error.png)。均为已筛选的AVD/统计，不公开手机/真实摄像头原件。

产品源码及测试锚 **e0eb86ada8f8dff95a7b384969ace058385e2c37 / Tree a6be76c7963fcd2cff42e207660503c3b0856424**，来自原专用树6150d104924355a5427868f5b429ef82cf1eab51；固定plan68d57f755d0091bc15cb867b96d3a21caee83690 / Blob042cf7298b75169a89b1dcd7c9fb113f6ddd72e3未变，8AC未变。远端main另有cab5e7c07d214572385521a33fdacc0eb1c8fc2f，只读观察、未引入此版本。

### 结果与最终包

- 音频设备阻塞已解除；Owner明确确认电脑/手机播放与话筒正常，第三版回声少或无、正常与轻声清楚、静音再开麦仍保持。Android首次初始化请求voice processing及AEC/NS/HPF/AGC，禁用硬件处理请求；不声称原生最终实现已证明为纯软件AEC。
- 授权检查数据库异常不再伪装永久撤权；Laravel Routing Pipeline中的数据库异常恢复到最外层事务，最多3次处理并发错误，失败generic503，无partial allow-list。完整非作者审查发现原始PDO边界，已补回滚和统一503并实测关闭该P2；不替代Astra终验。
- Windows单worker本地开发front串行完整上游请求，同25MiB+1文件在真实语音中6.755秒422、双方RTP继续增长；原30秒502及所有失败保留。RTC查询禁用叠加的框架默认retry，避免授权404时一直加载；call59两端真实错误卡及停止媒体已核。
- 最终APK `77d4b0215d710a3a749814d386059d4763eaefa73101d9b31bc14b8ba7bca5ca`，414145599字节；AAR `dd1e869f34eea40693793871e03de895cc4a50d3f131255b9edd9e2d05642d9e`，8708051字节；arm64-v8a+x86_64，签名校验0，双端独立实读base.apk等于该hash。独立测试包com.elitesync.v1009test，保留数据，手机每次安装均取得当次Owner确认、失败不自动重试。Android manifest仍显示既有0.08.04，治理版本为v10.0.9，未混称显示版本已改。
- 物理包及完整原证位于本会话version-regression/provider-fix-artifacts及同目录原证，LOCAL_ONLY。音频引擎、依赖与Owner确认第三版的对应源字节相同，后续只增加通话查询错误处理；构建消费的产品源与最终源码锚逐项核同。

### 固定8AC提交情况（CODEX_REPORTED，待Astra裁决）

| AC | 已提交的实证与限制 |
|---|---|
| 09-01 | 独立0.9 DB/volume、官方固定LiveKit及最终image、具名手机与AVD的双APP同源hash、源码diff/许可证记录；原dirty根/旧库卷/无关untracked不动。最终Commit/Tree由远端读回回执固定。 |
| 09-02 | Match→CN→双方当前MC独立真实同意，pending/单方同意/处罚/block/非参与者及错误call拒绝；真实create/独立accept/connect/join/重连正反例与对应PHP测试。新fixture追加不reseed，原CN1 CLOSED revision3保留。 |
| 09-03 | Owner双端听感、静音再开麦；最终包call59双向RTP及正常结束/历史、拒接/忙线/未接/超时原证；mic系统拒绝及APP媒体关闭错误卡call56，恢复后call57双端各28条RTP；call37正向重连、call55断网撤权复网拒绝。采集许可/网络/时间退出码原证均保留。 |
| 09-04 | 最终包call60双方不同合成图及视频帧/RTP；camera拒绝call58双方StateError/leave、OSfalse及无RTP；恢复/手机1→0→1切换/关闭原证。call61实际1440×3120→3120×1440、ROTATION_90→原ROTATION_0，横屏时in_call且手机解码855→885；后台camera client与RECORD_AUDIO app-op都由active转inactive，回前台仍inactive，手动启用后解码1792→2775。原旋转设置恢复、结束后无采集残留。 |
| 09-05 | MC/CN/block/Web restrict/ban及end的分项有效媒体停止原证；call49 CN关闭0.521/0.745秒且声音源继续/QEMU后续为0，call54 block1.815/2.092秒，call59 MC0.551/0.524秒；call61真实APP挂断0.790/1.125秒且5秒后无RTP、旧JWT余51.69秒时Join404/validate及WS403。call55实际离线期间撤MC、恢复原网络及反向通道后不重入；原始SFU bypass、看门狗/故障/未知权限与有限重试原证保留。 |
| 09-06 | 原真实APP picker→ffprobe校验→持久asset1/message/attachment→另一APP播放链；重启后最终包实看2.333秒运动帧及4.933秒片尾，完整/Range权限200/206/404；播放中撤权销毁原证、伪MIME/损坏/25MiB/30秒/重复/非本人asset/幂等冲突等真实HTTP负例。HTTP补证不替代APP原链，无公开fallback，不声称转码或生成封面。 |
| 09-07 | 原文本/私有图片及通知最小化、CN/MC独立阶段、Web处罚/申诉/D1使用点的受影响实链与定点回归保留；本轮不重做B01～B06。全量PHP失败是下列明确观察项，未冒称全套绿。 |
| 09-08 | 最终包双端安装hash、音视频/撤权/权限/旋转/前后台、DB/API/SFU/worker/双APP联合重启选定持久字段一致、视频再次完整播放、相关测试/构建/退出码/失败/固定源码锚；安全统计及少量AVD截图入候选，手机/真实摄像头原件与大包LOCAL_ONLY，最终普通推送后停止等Astra终验。 |

### 验证和必须保留的观察项

- 最后PHP相关明确选集`V1009|V1007LiveConsent|V1008EligibilityConsent`：37项/325断言，exit0；RetryTest7项/53断言，rawPDO两用例先RED后GREEN。此前39/281为不同选集，未伪造累加。Dart RTC最后32项exit0，新增用例保留实际provider并启用LiveKit，拒绝不新增Join、查询恢复不自动重启媒体；局部analyze及双ABI构建/签名均exit0。仅测试文件在通过后格式化，产品源未变。
- 全量PHP最近1063项/14037断言仍4errors+12failures、exit2，发生于最后HTTP异常边界修复之前；最终只重复必要相关选集。16个名称与本轮死锁修复前相同，**不证明它们全都早于0.9**，保留交Astra审阅。未重跑全套Flutter，不冒称全套通过。
- 尚存锁序环，最多3次尝试不保证1.5秒总预算；网关超时仍fail-closed。有效Android原生处理模式UNVERIFIED。framework默认异常report可能含SQL，完整日志LOCAL_ONLY；自定义安全诊断不含SQL/绑定/JWT。
- 本地front串行队列无总等待上限，短body完整性为既存trusted本地入口风险；不是生产并发/公网加固方案。完整非作者静态审查原PDO P2已修复复核、无新阻断；独立代码审查不等同产品ACCEPT。
- 手机摄像头call60原图包含测试图外屏幕边缘/上方背景，全部LOCAL_ONLY；GitHub只放经过查看的AVD合成画面/错误状态截图。Astra不能从GitHub亲自运行或读取本地原证，相关结论统一CODEX_REPORTED/LOCAL_ONLY。

### 资源及交付边界

最后Owner批准窗口起点 **2026-10-16T18:04:13.882207+08:00**，配置最多1200秒、自动截止2026-10-16T18:24:13.882207+08:00；本轮完成后 **2026-10-16T18:13:00.027507+08:00提前收口**，未自动续时。停止前核每个PID完整命令归属，0.9 DB/SFU、5个owned服务、relay及两端测试APP均停止；DB卷、媒体、私配/原失败、Owner现有AVD及4条既有临时防火墙规则保留，**不是全部资源关闭**。原Windows麦克风静音未改；模拟器方向设置已恢复。

原prepare-sfu.py及无关untracked保留在工作树，不加入候选；冻结plan原Blob再核相同。仅提交本轮13个产品/测试对象、固定文档、恢复台账和已筛选证据。下一步仅Astra独立ACCEPT/REJECT；Codex不自接受、不合main、不K08、不启动后继版本。


## 2026-10-16 17:53 审查及封存进度（最新，仍未候选交付）

本轮产品源码/测试已本地提交：e0eb86ada8f8dff95a7b384969ace058385e2c37 / Tree a6be76c7963fcd2cff42e207660503c3b0856424。尚未推送“完成候选”，NOT_CANDIDATE_DELIVERED / NOT_ACCEPTED。原prepare-sfu.py及无关untracked完整保留，未加入此提交。远端main只读观察为cab5e7c07d214572385521a33fdacc0eb1c8fc2f；不将其合入冻结版本。

- 新包call60真实双端不同测试图、音视频RTP及帧增长已核，手机镜头关闭后end；手机约1.242秒、AVD约1.734秒leave，5秒后无RTP。摄像头画面带到显示器边缘/上方背景，原件仅LOCAL_ONLY，不公开。
- 新源码组合联合重启完成，选定14类持久字段/计数全部一致、原SFU image及DB volume保留。最终APP重启后再次完整播放原5秒私有视频，2.5秒截图实际时间码2.333、6.2秒截图末帧4.933且播放按钮恢复；完整/Range有权200/206，无权404，旧call59/60Join404。59旧JWT重启后已过期，不冒充未过期测试；未过期证明来自即时call59/55原证。
- 完整非作者审查发现原始PDO异常可能绕过外层回滚/通用503。两处改为PDOException（QueryException及DeadlockException均继承它），普通HTTP拒绝不变。真实HTTP先写再抛rawPDO及begin前抛rawPDO两用例先RED；修复后RetryTest7项53断言通过，最终明确filter V1009|V1007LiveConsent|V1008EligibilityConsent 为37项325断言exit0。它与此前39项的选集不同，不伪造39→41计数。全量仍4errors12failures且未在最后PDO修复后重复全量。审查复核原P2闭合，无新阻断，不构成ACCEPT。
- 已按冻结计划核归属后停止0.9 DB/SFU、五个owned服务、临时relay及两端测试APP，保留DB卷/媒体/原证。最后窗口于17:34:45启动，最多1200秒；本版资源停止于17:50:08完成，提前收口且未续时。Owner现有AVD保留；实际只读仍四条既有防火墙规则。不能声称全部资源关闭。
- 最终逐项复核发现call39旋转仅请求但surface_orientation为空，前后台对照最终call为异常终态。此前“新包视频/联合重启完成”不消除这两项缺证，AC-09-04仍PARTIAL。已弹窗请求新的同范围最多20分钟及手机前置遮挡后视频准备；回答前不启动新窗口、不拨打。无需重装APP，不改冻结AC。

公开准备材料仅安全统计及三张已查看的AVD截图：evidence/20261016-final-device-safe-summary.json、final-private-video-mid.png、final-private-video-complete.png、final-call-revoked-error.png。完整手机/摄像头截图、设备标识/私网/私配/原始框架日志均LOCAL_ONLY。尚待旋转/前后台有效回归，再完成固定报告/manifest/runbook/台账的最终普通non-force独立候选交付；不合main、不K08、不启动后继版本。


## 2026-10-16 17:30 新包及本窗口收口（最新状态）

IMPLEMENTATION_IN_PROGRESS / NOT_CANDIDATE_DELIVERED / NOT_ACCEPTED，8AC不改，无Git提交/推送。

- Owner授权的纯语音窗口09:09:52.314Z启动，实际09:29:52.503Z自动停止（上海17:09:52～17:29:52）；没有续时。四条旧临时防火墙、0.9 DB/SFU/API/worker/AVD仍保留，不能声称全部资源关闭。
- call55新入口串行转发在真实语音中测试同25MiB+1文件：6.755秒422，上传中及之后双方RTP继续增长、call保持in_call，未重现502。未把HTTP上传诊断冒充APP picker E2E。
- call55 AVD原wifi_on=1，关闭Wi-Fi并移除原有8000/7884反向通道，实际核offline后服务端撤MC200。恢复原Wi-Fi及两条同端口映射；原SDK已进入reconnecting，恢复后不再room_connected/reconnected，5秒后无RTP；旧JWT仍余44.26秒时Join404、validate/WS403。此前call37为正向重连，不能混淆二者。网络与通道原状已恢复。
- call56实际AVD系统麦克风拒绝，OSfalse及APP“媒体连接已关闭/检查权限及网络”错误卡已实拍。权限和原flags恢复后call57真实双端语音RTP各28条、双向各14条，正常end200。恢复时旧call56已终态，fresh UI点击重连安全拒绝，原失败保留。
- Owner当次另准call58摄像头拒绝入口；预先拒绝双方CAMERA，手机额外user-fixed拒绝确保不拍摄，AVD系统拒绝实际点击。双方当前PID原日志各有ROOM_CONNECT_FAIL StateError与leave_complete，无RTP；AVD错误卡实拍。随后两APP先force-stop，再恢复双方CAMERA/RECORD_AUDIO及所有原flags，逐项相同，无手机拍摄。
- call55恢复后发现404持续骨架屏。锁定Riverpod3.3.2默认重试与每4秒invalidate叠加；仅rtcCallProvider设retry返回null，保留既有poll与fail-closed error/leave，影响同provider的来电及结果页也会更早显示错误，可按既有刷新恢复。未改变音频引擎/AEC/NS/AGC配置。
- 真实datasource抛Exception；最初Fake抛StateError导致假绿，随后一次脚本GBK解码失败未修改Fake，均保留。显式UTF8修正Fake后真实Exception用例RED exit1；provider修复后整个RTC32项exit0。按非作者审查建议，两新用例启用LiveKit，核拒绝不新增Join、查询恢复不暗中重启媒体；再次32项通过。局部analyze通过。
- 首次构建因进程未指向既有SDK而exit1，原输出保留；仅给该构建进程配置既有SDK/JDK/Flutter，无全局改动，第二次双ABI构建exit0，签名0。APK SHA256 77d4b0215d710a3a749814d386059d4763eaefa73101d9b31bc14b8ba7bca5ca；AAR dd1e869f34eea40693793871e03de895cc4a50d3f131255b9edd9e2d05642d9e。显示versionName仍为既有0.08.04，本版治理标识为v10.0.9测试包，不虚报Android manifest版本已改。
- 手机取得当次准备确认后仅安装一次Success，模拟器一次Success，均保留数据；两端base.apk实读hash等于新APK。首次安装后导航一次ADB input timeout，未创建call；核当前界面及无call后重新fresh导航，旧失败保留。初次AVDcollector在APP未launch时失败；实际启动后重绑，不拿无输出代替媒体证据。
- 新包call59真实双端voice接通及双向RTP增长；MC revoke200后手机0.551秒、AVD0.524秒leave，5秒后无RTP；旧JWT余45.87秒时Join404、validate/WS403。两端实际截图均显示“通话加载失败/Not found”，不再持续骨架屏。没有打开摄像头。

当前MC已撤销（call59），CN2仍active；原CN1 CLOSED revision3保留。下一需要新通话时先经真实request/accept更新MC，不复活旧call。当前无新TCP窗口授权。新包视频复核及最终联合重启/证据封存/独立候选尚未完成；不得整版PASS、自接受、合main、K08或启动后继版本。

本地证据根同本会话version-regression：voice55-permission58-safe-summary.json、call55-offline-revoke-restore.json、mic56-denied-os-state.json、mic56-restored.json、device-permissions-after58-restored.json、rtc-provider-fix-media-enabled-suite.txt、provider-fix-preliminary-test-limitations.json、provider-fix-build-v2-receipt.json、provider-final-installed-package-hashes.json、provider-fix-final-package-manifest.json、provider59-safe-summary.json与relay-voice-final.stdout。截图/完整日志/标识/私配均LOCAL_ONLY，安全摘要仅CODEX_REPORTED。


## 2026-10-16 17:04 接续状态（覆盖前面的较早快照）

IMPLEMENTATION_IN_PROGRESS / NOT_CANDIDATE_DELIVERED / NOT_ACCEPTED。冻结8AC不变；本段无手机安装、无新视频拨打、无Git提交。当前会话01a14250-b40a-7410-ac1d-61dde1ec0644，工作树HEAD6150d104924355a5427868f5b429ef82cf1eab51。

- 音频设备阻塞已由Owner实听解除：第三版回声少/无、正常与轻声清楚，静音再开麦保持；原生最终处理模式仍UNVERIFIED，不声称已证明纯软件AEC。
- call49在有效语音及合成源继续播放时关闭CN：AVD0.521秒、手机0.745秒离房，5秒后无RTP；源继续7.326秒，QEMU后续11个输出样本peak=0。旧JWT尚余12.60秒时join404、validate/WS403。原CN1保留CLOSED revision3。
- 追加虚构Match3/CN2供权限回归；未重seed、未覆盖旧CN。CN_PENDING、仅CN_ACTIVE、MC_PENDING的RTC create均403，双方独立MC完成后可通话。过长week_tag失败回滚证据保留。
- mic拒绝call50/51、camera拒绝call53：真实系统拒绝及OS权限false成立，但等弹窗期间发生超时/peer_disconnected，APP即时错误卡证据不足，不能登记整项PASS。原CAMERA/RECORD_AUDIO权限与flags均已恢复；call52语音及call54视频双端RTP持续增长，恢复有效。
- call54原生手机摄像头确证1→0→1，最后16:54:49设备1断开。Owner已逐次批准视频及两侧遮挡后的切换。block真实200后手机1.815秒、AVD2.092秒leave_complete，记录5秒后无RTP；双方实际截图ended/权限失效。已unblock，旧call54维持ended。补探测join404、validate/WS403时旧JWT已经过期117秒，不算未过期JWT证据；其它有效旧JWT用例仍保留。没有录制手机场景。
- 精确核PID身份后完成0.9 DB/SFU/API/authority/bridge/worker/双APP联合重启，volume保留、SFU image未变、选定持久字段一致；第三版APK两端再次实读hash相同。重启后真实APP完整播放原5秒合成私有视频。未清数据或重装。
- HTTP负例完成伪MIME、损坏MP4、禁止public_url/storage_key、非本人asset、重复附件ID、client UUID重放及冲突、失败不增asset。31.194792秒合成片streamcopy校验后实际422（30秒限值）；原archive/bin及媒体hash核对保留。这些HTTP补证不替代真实APP播放链。
- 新发现开发front并发问题：同25MiB+1 payload（SHA256 1b55f713d105dc0e7be77b11a4b2db46534405560d7dfe4265d1e6dac74441aa），idle/direct约5.75/6.46秒422；双APP活跃时30秒502，两次复现。40秒DB状态采样未见长时间等待，不足定位PHP内部根因。
- local-http-front.py仅在发往单worker PHP的完整request/response阶段持互斥锁；客户端收体/回包在锁外。仅重启已核owned front，相同双APP活跃场景改为4.546秒422并明确25MiB限制；真实完整/Range有权200/206、匿名/非参与者404保持。源码非作者只读审查无阻断。锁等待总时限未限定，仍有队头等待风险；正在通话的心跳表现尚未补证，不夸称完整并发修复。
- 最终PHP相关39/281 exit0；全量1063/14037仍4errors12failures，名称与本轮修复前一致，最终HTTP边界后仅相关回归。Flutter第三版37项、局部analyze、双ABI构建通过。原失败保留。

当前精确证据入口（均CODEX_REPORTED/LOCAL_ONLY）：call49-cn-safe-summary.json、call54-block-safe-summary.json、device-permissions-restored-final.json、final-joint-comparison.json、final-joint-installed-package-hashes.json、joint-video-complete-playback.json、real-private-media-negative-matrix-v2.json、overduration-front-backend-diagnostic.json、oversize-front-polling-probe.json、oversize-front-serialized-probe.json、front-serialized-private-media-regression.json。绝对根为本会话version-regression目录；完整截图、日志、设备标识及凭据禁止公开。

仍需：权限拒绝期间APP可观察无媒体闭环；真实断线期间撤权后恢复网络的SDK负例；正在通话时入口修复必要回归；最终源码锚/产物/报告/manifest/runbook/台账及独立候选封存。不得自接受、合main、K08或后继版本。

当前窗口16:46:58.401～17:06:58.401，最长1200秒自动停止，未续。四条原防火墙规则及0.9 DB/SFU/本版服务仍保留，不能声称资源全关。最新front PID归属见owned-services-after-joint.json，不能盲用旧PID。


## 2026-10-16 接续增量（下文保留原时点）

**IMPLEMENTATION_IN_PROGRESS / NOT_CANDIDATE_DELIVERED / NOT_ACCEPTED**。8项AC不变，尚未提交本轮候选。

- Owner已确认电脑及手机播放/话筒正常；第三版处理策略下回声很少或无，正常及轻声均清楚，静音再开麦后保持。第三版APK SHA256为`904efe1429740b2a435c511343586b4d9e5b4a1f7f5d84e37bdaa3b642cb20bd`，本段未再安装。
- call43真实复现授权检查数据库死锁被误写为永久权限失效。修复保留正常拒绝，异常向最外层事务传播、并发错误有限尝试；恢复Routing Pipeline已渲染响应所附数据库异常后再回滚/重试，耗尽返回通用503。guard失败不返回成功的部分allow-list。安全诊断不含SQL/绑定/JWT；框架原始日志仍LOCAL_ONLY，不宣称框架日志全部脱敏。锁顺序环和1.5秒总时限风险尚未完全消除。
- call46两端不同测试画面及帧/RTP增长，手机摄像头随后关闭。20次并发列表均200且通话保持；MC撤销后手机约0.607秒、AVD约1.157秒离房，5秒后无RTP继续；旧JWT尚余约26秒时新join404、validate/WS403。该有效对照远离窗口到期。短视频新播放器在运动帧中撤权后退出并提示不可用。
- 最终相关PHP定点回归39项/281断言exit0，存在依赖弃用警告。全量最近一次1063项/14037断言仍4错误/12失败，16个名称与本轮修复前相同；最终HTTP边界修改之后仅跑上述相关回归，不冒称最终全量PASS。原128M耗尽、测试fixture及其它失败全部保留。
- 详细增量、精确限制、回执及原证均为CODEX_REPORTED/LOCAL_ONLY：`C:/Users/zcxve/.codex/visualizations/2026/10/16/01a14250-b40a-7410-ac1d-61dde1ec0644/version-regression/CONTINUATION_RESULT_20261016.md`；音频试听在同会话`audio-echo-software/`。完整设备截图、框架日志及私配不得公开。
- 本轮最后窗口15:47:05～16:07:05（上海）已实际自动停止。CN关闭独立媒体停止、部分设备权限/切换、最终联合重启及候选封存仍未完成。0.9 DB/SFU及四条既有临时防火墙规则仍保留，不能声称全部资源关闭。
- Owner新增：每次开始APP视频通话先弹窗取得当次准备确认，网络授权不能代替。只测当次确认的前置构图，核图后关闭手机摄像头；下一次窗口须另批。最后语音准备确认在窗口末尾收到，未拨打，不能算CN用例通过。

## 2026-10-15 原执行记录

2026-10-15。**IMPLEMENTATION_IN_PROGRESS / AUDIO_DEVICE_VALIDATION_BLOCKED / NOT_CANDIDATE_DELIVERED / NOT_ACCEPTED**。

本报告不宣告8项AC完成。双端视频、私有视频消息、部分真实撤权及持久化链已有实证；最终包的双端可辨虚构语音播放仍缺证据。当前Android Emulator原生音频注入多次退出或挂起，不能用静音RTP、JWT、API状态或Widget测试替代AC-09-03。冻结计划、Owner D4～D6和已接受0.6～0.8均不改写。

## 1. 固定身份与权限

- 计划Commit `68d57f755d0091bc15cb867b96d3a21caee83690`，Blob `042cf7298b75169a89b1dcd7c9fb113f6ddd72e3`；Owner决定Commit `4bda572e225b64a3b4d826ae75e355e958251c58`，Blob `85dd5f9b88840104b0d5c26ba57d96fad4a17f11`。
- 产品技术起点 `3a8f7989aa208285b885f1c80f4365f38488ac54` / Tree `95fadde468d8a21b39c544fdb74093dd35184717`；本次实际回读main `03c7de98d79c3075d4b3adb93a9b383dd342377f`。未合main、未执行K08。
- 当前实现锚 `29ebda1ba71bdcb17d260cceec616031f1360ca6` / Tree `13910eac5c882e21cb76156a28ce2cef891d71be`。此后报告/证据提交不是新的产品源码起点，也不是完成候选。
- 专用树 `C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`，分支 `codex/v10.0.9-rtc-media`。当前任务环境thread ID `01a13afa-b74f-7c11-b7e0-01a04335168d`，未借用来源会话ID。
- 本地原证根Q：`C:/Users/zcxve/.codex/visualizations/2026/10/14/01a13afa-b74f-7c11-b7e0-01a04335168d/v1009`。GitHub仅含经过筛选的安全摘要；Windows原流/设备/数据库属于 **CODEX_REPORTED / LOCAL_ONLY**，不能冒称Astra亲自运行。

## 2. 已实现的模块

| 模块 | 具体源码与行为 |
|---|---|
| 当前RTC权限 | `services/backend-laravel/app/Services/RtcAuthorityService.php`、`RtcSessionService.php`：每call绑定独立随机room、参与者identity及当前CN/MC revision签名；create/accept/connect/heartbeat/join/sweep重读当前状态，双向block、restrict、disabled及未知环境拒绝；临近邀请期限独立接听后有新的30秒连接期限 |
| 入房与失效 | `LiveKitTokenService.php`、`Http/Controllers/Api/V1/RtcGuardController.php`、`Http/Middleware/RtcTransaction.php`、`config/rtc_guard.php`、`routes/api.php`：短期JWT不替代当前授权；内部可信门与用户身份分开；生产/未知环境不开放 |
| SFU边界 | 本目录 `rtc-gateway.py`、`rtc-watchdog.py`、`authority-bridge.py`、`Dockerfile.rtc`：受控7884入口，原SFU7880不发布；每次validate/WS重新授权；失效DeleteRoom，控制失败停止SFU；独立进程通过匿名pipe监督成功授权脉冲，避免网关主循环阻塞导致看门狗失效 |
| APP通话 | `apps/flutter_elitesync_module/lib/features/rtc/domain/services/rtc_livekit_service.dart`、`presentation/pages/rtc_call_page.dart`、`rtc_incoming_call_page.dart`：显式接听/拒绝、真实发布订阅与视频渲染、静音/摄像头/切换、当前授权失败关闭媒体；显式重连先重新读取服务端session及Join信息，无自动接听或无限重试 |
| 私有视频 | `PrivateVideoValidator.php`、`MediaController.php`、`ConversationAtomicSendService.php`、`config/media.php`：MP4/H.264（可选AAC）、25MiB/30秒、真实ffprobe校验；ready为validated passthrough，**未声称转码/生成封面**。私有存储、消息附件关联、当前权限及Range读取 |
| APP视频附件 | `features/chat/presentation/pages/live_chat_page.dart`、`widgets/private_video_player.dart`：实际picker、上传、附件发送、认证原生播放器；播放前及每2秒当前权限检查，撤权/会话变化/后台关闭播放器，无公开URL fallback |
| 测试与复现 | RTC/媒体/权限PHP及Flutter窄测试；本目录具名运行、UI、浏览器、数据库快照、授权探测和看门狗诊断工具。私配、token、设备发现秘密及物理包均未入Git |

## 3. 真实链结果与AC当前状态

| AC | 已有实证 | 尚未完成的部分 |
|---|---|---|
| 09-01 | 独立0.9 MariaDB/volume、两台专用AVD、官方固定镜像及实际image ID；最终APK两端安装hash一致；原dirty根HEAD/index/status摘要前后一致 | 版本尚未形成完成候选 |
| 09-02 | alice2/bob3独立CN/MC；真实APP创建/独立接听/连接/Join；真实HTTP Match alone403、非有效处罚状态拒绝；PHP针对当前revision/撤销/超时/未知环境断言通过 | 完整实链状态矩阵及最终设备重连仍待收口，不能由单测替代 |
| 09-03 | call7真实两APP语音发布/订阅、双方RTP增长及非零解码音频帧；初始虚构音注入有completed回执 | **BLOCKED**：最终包的双方同时可辨虚构音与对应播放证据不足；后续多种注入使原生模拟器退出/挂起。拒接/忙线/权限拒绝/重连的完整真实语音矩阵亦未完成 |
| 09-04 | call8、10、最终包call11真实双端视频；摄像头运行时许可、前后摄像头切换、本地与远端虚构测试图；两端视频framesEncoded/framesDecoded/RTP增长 | 旋转、完整前后台、摄像头拒绝、静音及重连的所有实际操作尚未完成，不登记整项PASS |
| 09-05 | call7真实Web restrict、call10真实MC revoke、最终包call11真实Web banned；SFU删除对应room、当前Join404、保存的**尚未过期**JWT validate403、原7880/7881宿主不可达。call11两端room_disconnected/leave_complete均在真实处罚表单提交后约1.2秒内 | CN close/block/end逐个双端媒体停止、SDK自动刷新/真实断线重入的完整矩阵未完成。最后独立进程看门狗修复只重测了故障停服，不冒称其后又完整跑双端媒体 |
| 09-06 | 真实APP选择5秒虚构MP4→真实ffprobe→MariaDB asset1 ready、message1 attachment1→Bob APP打开并启动原生播放；owner/receiver完整200、Range206；匿名/非参与者404；MC revoke后所有完整/Range404；重启同asset/关联/hash存在 | 播放截图为起播帧，不冒称完整5秒已播放完毕；撤权时已缓冲播放器的实际销毁、失败类型/重复绑定的全实链矩阵待收口（相关单测通过） |
| 09-07 | APP真实文本message2、私有图片asset2/message3；Blade restrict/banned/restore；受限用户真实HTTP历史读200、新私信404、新RTC403、本人申诉201且申诉后仍403；恢复不复活旧token，明确新登录才200 | 本轮申诉是定点HTTP回归，未冒称重做0.8整套APP/Blade验收；通知安全实际依赖相关PHP回归，未重做所有后台链 |
| 09-08 | 四轮AAR/APK构建及最终双端安装、当前源码分析/相关测试；API/授权监听/worker/DB/SFU与APP已有重启；同库持久记录比对一致 | 不是完整最终联合验收；语音与其相关失效/重连门未通过，因此不提交完成候选 |

安全摘要与少量图片见 [evidence](evidence/)。逐原证hash/退出码见 [manifest](manifest.json)。

### 3.1 已观察的真实撤权时序

- call10 MC撤销HTTP响应 `1792072931.3405583`，SFU room_removed `1792072931.6365023`，约0.296秒；观测窗口内后续媒体样本停止。旧JWT于 `1792072938.51225` 再验证403。不能把删除房间单独当作整个09-05完成。
- call11 Blade banned表单提交 `1792073476.809656`，响应 `1792073477.5018787`，room_removed `1792073477.33057`。主机实时收流记录Bob断开/释放约 `1792073477.893`，Alice约 `1792073477.955`，均在表单提交后约1.2秒内。两APP在操作前有实际双端视频RTP/解码增长。设备时钟曾与宿主差约18～21秒，**未直接混用设备epoch与宿主epoch求差**。
- 当前阶段只声明这些具名序列；不外推生产、网络全故障或尚未实测的所有撤权种类。

## 4. 镜像、网络与包

- 官方LiveKit v1.13.10索引：`sha256:89ca9ce0791e18d6e03bf6e2c49ceb27e1c754eae8bd50c989386c1a5963791a`；amd64 manifest `sha256:e96a42b8623f738919a3f2006d433aeb19d0f3c67ce11eb986ea20e2cf65fbf5`。首次pull前保留Registry原文、digest与许可证。客户端锁仍为livekit_client2.10.0/flutter_webrtc1.6.0，未升级。
- Python官方基镜像digest `sha256:d9368b3a5ac59afea7b5d4f2e2aea0941dbf9fdee9c369c5bec00b98244bc929`。最终组合镜像image ID `sha256:32d59377b1bd55507719fced7c63efaf441423ab208fc080af0e17bdcfe7276e`。后者包含最后独立进程看门狗，实际运行读回一致。
- 宿主仅发布 `127.0.0.1:7884/TCP`、`127.0.0.1:7882/UDP`；7880/API仅容器loopback；AVD ICE地址10.0.2.2。无公网/TURN/收费Cloud，无全网卡防火墙修改。
- 数据库 `elitesync_v1009_dev`，容器 `elitesync-v1009-db`，volume `elitesync-v1009-db-data`，`127.0.0.1:43319`。API8000→8001，独立同代码同DB的授权监听8002，均loopback。
- Android包源码锚 `c2ba84cc50a1946e697a8e94e50181201304bb12` / Tree `d15e2023bd7492684f88d1529fb105a178145886`；之后实现锚29ebda1只修改本地SFU/诊断工具，无Flutter/Android/PHP产品变化。
- AAR：`Q/artifacts/fourth-flutter_release-1.0.aar`，4,451,332 bytes，SHA256 `a621e4989c39e34af5df0b54bb1e18b90ce77e8c2f8966bb824e074cc9d7c4c8`。
- debug APK：`Q/artifacts/fourth-app-debug.apk`，223,877,338 bytes，SHA256 `3358c629a9884e433cb501d02b364e2aea4c2354f33cd3b5003817d4cd8674cc`。`emulator-5584`/`emulator-5586`安装base.apk回读均同hash；两AVD名分别elitesync_v1009_a/b。大包不发布GitHub，未写development release或生产分发。

## 5. 自动验证与原始失败

| 验证 | 实际结果 |
|---|---|
| `integrated-php-first` | exit1，39通过/1失败、399断言；过期call旧测试要求新增heartbeat，修为不得复活，失败原件保留 |
| `integrated-php-final` | exit0，46项/372断言；RTC、私有视频、原私有媒体/R1通知隐私、0.8申诉和处罚；vendor弃用及旧doc-comment提示保留 |
| `accept-deadline-final` | exit0，15项/113断言；首轮测试假设修正的exit1亦保留 |
| `flutter-related-final` | exit0，38项；RTC及真实聊天/私有播放器相关测试 |
| `dart-full-final` | 全范围No issues found，exit0 |
| `reconnect-tests-first` / `audio-diagnostic-tests-first` | 11项/7项，均exit0；独立接听前的红测/Scaffold失败原证保留 |
| `build-first`～`build-fourth` | 均exit0；前面包不是当前物理包，不能混淆hash。第四轮最终安装两端exit0 |
| 全Flutter/全PHP历史套件 | **NOT_RUN**；历史0.7三项既存Flutter失败与原exit1不改写，本轮不称全套通过 |
| 辅助语法检查 | Python与PHP最终分别exit0；一次误把PHP交给Python的helper-compile-first SyntaxError/exit1保留 |

其它语义失败：初次fixture week_tag过长时CLI曾exit0却含SQL错误，按失败保留，修正后仅向本0.9库写具名fixture；该fixture不是matching consumer实证。早期音频注入helper曾exit0但receipt有RPC失败，**这些是失败，不是PASS**；helper现已按receipt异常返回非零。原始stdout/stderr/exit与结构化回执共同判断。

内部只读窄审查发现共享事件循环watchdog风险后已修为独立进程。首轮独立进程诊断的容器退出观察约11.3秒/断言失败保留：SFU先被杀，但namespace PID1不接收内部未处理SIGKILL；补明确SIGTERM处理后，`process-watchdog-final` exit0，阻塞10秒的测试中宿主观测容器约4.714秒内退出。此为故障停服测试，未把它冒充带双端媒体的完整09-05。

## 6. 最小具体阻塞及下一门

现有官方Android Emulator36.4.10（build15004761）、Android36.1 x86_64两专用AVD在gRPC injectAudio/streamAudio方案下，多次出现UNAVAILABLE/10054、DEADLINE_EXCEEDED、QEMU退出/ADB挂起。试过先前并发采集、仅注入、24/48k、实时/缓冲和禁用宿主音频后端；未安装驱动、未打开宿主真实麦克风。Windows具名事件记录有 `qemu-system-x86_64-headless.exe` / `combase.dll` / `0xc0000602`。**不能把所有退出都归因为同一个已证明根因**，但当前路径不能稳定取得最终双端虚构音播放证据。

仅暂停受影响的真实语音/关联媒体验收子项。计划5.2明确：现有AVD不可用时，只能使用Owner另行具名指定的无真实账号测试设备。因此最小Owner决定为：具名指定受控替代Android测试端，或明确授权一个项目隔离、官方固定版本的替代emulator runtime验证方案（不改全局SDK、不装系统音频驱动）。决定前不接入个人设备、不升级系统、不降AC。

恢复后仍须按原8AC补齐：最终双端可辨语音及播放、拒接/忙线/权限/断线重连、各具名撤权及旧/刷新JWT实链、短视频完整播放与撤权缓存销毁、最后看门狗版本下必要媒体回归。不能仅因本报告已发布转入Astra最终接受或K08。

## 7. 保护与资源最终状态

原dirty根D:/EliteSync-v10的HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`、index SHA256及normal status SHA256与本轮起点完全一致。没有重做历史109项全量验证。旧LOCAL_ONLY、`%SystemDrive%/`、工作树缓存及其它未提交成果未清理/未混入提交。

0.6/0.7/0.8数据库容器继续停止、各持久volume保留，未重seed；0.9持久业务记录也未重seed。只在本0.9首次开发库创建虚构账号/题库及具名已发布Match测试fixture。

本0.9 SFU/数据库容器、Laravel/front/授权监听/bridge/worker和两专用AVD已停止；volume、media、私配和原始失败保留。当前Bob3保留受限处罚3及申诉1，旧处罚1/2已受控restore；CN/MC/账号状态以Q/before-owned-stop.stdout为准，不能盲目从初始fixture重置。恢复运行说明见 [RUNBOOK](RUNBOOK.md)。


### 17:07窗口收口

relay-final-camera.stdout已实际记录17:06:58.579（上海）relay_stopped，无续时、无新增拨打。纯语音准备问题在窗口内未收到回答，因此未执行，不能复用该问题启动新窗口。DB/SFU/本版服务及四条旧临时防火墙仍保留。

最终源码/产物复核：第三版5个源文件及APK/AAR哈希全部匹配构建清单；交接SHA256仍匹配。front Python compile及错误Host400、负数长度413、传输封套超限413三检查通过；首轮脚本误把负数长度期望为400而AssertionError，保留front-boundary-initial-failure.json，未修改既有拒绝逻辑。14项当前安全证据存在性/字节/hash索引为continuation-safe-evidence-index.json。仍NOT_CANDIDATE_DELIVERED / NOT_ACCEPTED；下一媒体窗口需Owner新授权，视频拨打仍须当次准备确认。
