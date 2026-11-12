# v10.1.5 已有功能实机验收与顾问资料

2026-11-12。当前 **EXISTING_FEATURE_ADVISOR_PACKAGE_WITH_OPEN_ACCEPTANCE_ITEMS**。本轮范围为已有功能实机测试、实际缺陷修复与顾问资料整理。冻结判定保持 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**。

## 当前代码和安装包

- APP源码 `0badb31c38db63fe0fb1b5fcbfb43e5cb4e68d3f`，Root Tree `cab9e7f5700eb8f7402401ee56cdc6e4e92d795f`，apps Tree `a4e4b62f58a1c6de353d2f69bace6c9d51eb6bd9`，services Tree `8bc64ce9d43e84897eac0c56782c8f17870ae05f`。后端 `6549f02880968f99ae3f45439d15a37c1b3d5251`。
- 当前离线构建46.0227167秒、退出0、v2签名、arm64 Debug。APK 154570461字节，SHA256 `1e9adad71b962c8adfcfd280450ed9ae9e5b1f7127988d225a036e3c3826dfea`。手机A与5580/B保留登录和聊天更新，base.apk实读一致。5582/A保留旧cdb与暂停状态。

## 本轮实际结果

1. Owner确认通知页“正常，不再闪烁，按钮可用”。版本误降级、通知轮询隔离/失败停住及手动重试按e5/8216具名原证保留。昵称恢复原名、通知偏好恢复原值。
2. 原生选图后上传成功但等草稿核验而停住的实际问题已修。两条生命周期/延迟历史回归先RED，修后聊天33项通过。26c同包正常双向文字120/121、自动图片122/asset17、视频123/asset18通过，手机预览及播放至0:02/0:02。最终0bad仅改变来电页，该业务源码与26c相同。
3. 原B进程出现两次ANR与32条Dart堆耗尽。新进程强制GC后仍保留1880个会话/479118个事件，恰为最新20通/5097事件的94份快照，路径经sessionProvider依赖保留旧FutureProvider元素。后台扫描已独立读取数据源。17项及选择器4项通过。26c观察240.906秒，末次采样处于新来电期间为4/4对象。最终0bad另观察120.843秒，端点GC后65会话/120事件均保持，堆140628224→140298784字节。最终模拟器20秒熄屏、唤醒、重入既有对话与设置滚动通过，当前进程日志OOM为0。旧进程分配栈未符号化，长时稳定性仍在待验范围。
4. 实际call45自然过期后原来电页仍等待，手动刷新才能见missed。现有来电页已增加有条件4秒状态读取，保持视图，错误/终态停住，失败动作一次重读，保留权限/账号/epoch门。15项及analyze通过，非作者复核无确定P1/P2。最终同包call46实际30秒自然过期自动显示未接通并撤去接听/拒绝，call47实际正常拒绝后双端终态rejected。
5. 手机虚构A正常完成可选MBTI三题及ENFP服务端读回，产品内人格问卷20题逐题正常提交、结果及两条历史读回。本人虚构三盘保存版本1/1，4柱/12宫/10主体；两个本人快照Synastry保存版本1/1、44相位。三盘链中正式用户行及B资料相同，双盘链B历史相同。独立盘面准确性保持UNVERIFIED。其它盘型沿历史5a模拟器原证，该页面和服务源码与当前相同。
6. 模拟器B正常退出并确认服务端撤销、再登录保留既有聊天。手机重播5步引导完成，日间主题切换后恢复夜间，密码空输入校验通过。注册表单、注销回执空态为只读查看。密码成功修改、真实身份提交和账号注销按未运行范围记录。
7. 独立Web真实Chrome登录、读取10个管理页、登出后受保护页面回登录，4个长页完整补图。管理写操作仅沿具名历史结果。首页/进展/搭子/关系/社区等当前状态已采图，A的平台权限拒绝及缺当前匹配对象只证明这些条件下的实际页面。

## 资料和限制

[验收目录](acceptance/README.md)提供功能说明、全部已盘点控件/导航及120张截图索引，逐张保留来源候选。正式构建变体、条件不足的叶页与管理写操作按SRC_ONLY或NOT_RUN记录。工程定向检查、主代理实测、Owner听感/通知确认、顾问总验收和最终接受分别记录。

自有媒体开发服务再次耗尽3次自动重启后退出，已保留5次authority_monitor TimeoutError原证并普通重启恢复Room0，根因UNKNOWN。原始失败保留。自然15/30天、硬件密钥库/物理故障、完整权限/并发/停媒/长通话、蓝牙及真实Push条件仍待完成。真实供应商、生产、重大版本、main与发布决定由Owner保留。

本轮使用自有服务和虚构测试资料。新增消息/测评/问卷/私有盘/测试来电是有意的开发数据变化。截图、APK、SQL、凭据、许可证和原始日志仅本地，顾问资料包由Owner后续提供。

---

## 历史节点原文

# v10.1.5 已有功能实机验收进行中

2026-11-12。当前 **EXISTING_FEATURE_DEVICE_ACCEPTANCE_IN_PROGRESS**。Owner范围为已有功能实机测试、实际问题修复及顾问验收资料。保持 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**。

## 当前候选身份

- APP源码 `bd4c07e74327c75296745adcc63f2619bcb8a835`，Root Tree `ac6daf6afcd3d74023a74ba88308041d5df1756e`，apps Tree `6e53b4def597fe51111c61538541ccc8286d6352`，services Tree `8bc64ce9d43e84897eac0c56782c8f17870ae05f`，后端仍为 `6549f02880968f99ae3f45439d15a37c1b3d5251`。
- 离线构建44.5956731秒、退出0、v2签名，APK 154569196字节，SHA256 `f5f6d80e8d124f96a0c772722d1f726b59879e6a8e9588863cfc6deec7c27277`。手机A与模拟器5580/B保留账号聊天更新，并实读base.apk一致。5582/A继续暂停保留旧包。

## 选图返回后的发送衔接修复

手机与模拟器先在e5aa包通过正常UI双向文字115/116，真实保存两条。随后模拟器原生选图上传成功为asset14，因picker暂停清空草稿核验标记、返回后全量历史与图片加载尚未完成，发送被草稿覆盖保护挡住。一次明确重试复用asset14完成message117，原失败保留。

bd4c在成功的当前对话短GET后复用既有加密草稿读取与校验，再继续选中附件。账号、peer、epoch与当前会话门保持，发现旧pending attempt后返回等待原编号明确重试。image/video两条实际生命周期与延迟历史回归先RED，修后聊天页33项通过，受影响analyze clean。非作者静态复核无确定P1/P2，测试和设备由主代理执行。

当前同包正常UI选图及选视频均自动发送，重试动作0，真实message118/asset15与message119/asset16各一条。手机打开收到图片预览，并把2秒视频播放到0:02/0:02。通知45项、版本9项54断言及此前Owner语音/通知反馈沿原候选身份保留，截图逐张标明采样版本。

功能、控件、截图与结果见[验收目录](acceptance/README.md)。其余现有页面继续采集，完整顾问资料包仍在整理。私有截图/APK/日志/SQL仅本地。

---

## 前一e5aa候选节点

2026-11-12。当前 **EXISTING_FEATURE_DEVICE_ACCEPTANCE_IN_PROGRESS**。Owner已决定集中完成已有功能实机测试、实际缺陷修复和顾问资料包。冻结判定继续 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**。

## 当前固定候选

- APP源码 `e5aa6a29a76711b0e4bdb01613e269759d1ffe8e`，Root Tree `3a756162be77871e465f1d0a71919637a13160b9`，apps Tree `9d34988f33b30759744da5bf00ee427320f3c338`，services Tree `8bc64ce9d43e84897eac0c56782c8f17870ae05f`，后端最后源码 `6549f02880968f99ae3f45439d15a37c1b3d5251`。
- 离线构建32.4737954秒、退出0、arm64 Debug、v2签名。APK 154568851字节，SHA256 `398d9e1a30a92b39e6a8f95c8218a3ea1a528e7baedb924636f5f8705f6a7608`。手机A与5580/B保留数据安装同包并核base.apk，5582/A暂停保留旧cdb包。

## 已有功能测试与修复

1. 版本中心实际复现10.1.5-dev被提示强制更新到旧0.07.04，根因后端解析不支持dev后缀而回退0。已保留旧字母后缀顺序并正确比较预发布和metadata。4条行为RED后9项/54断言GREEN，隔离CLI仅testing/sqlite/:memory:。真实HTTP及手机原5e包复测均无误降级提示，发布记录保持原身份。
2. 手机通知静默/消息类别经正常UI切换、真实服务读回、页面再入后保持及恢复原值通过。昵称经正常UI独立保存、服务端读回、重入保持并恢复原名，其他资料响应相同。两条流程绑定原5e候选，其对应业务源码在当前候选保持。
3. Owner实际发现通知中心反复“正在读取通知”且闪烁。根因为后台来电扫描每2秒invalidate共享列表，通知页随loading清空history并重建ListView。已改后台扫描独立读取，通知list在页面监听期单次读取、失败停住，离开释放后重入读取一次，手动刷新与权限变化继续有效。
4. 通知/来电相关45项定向检查及受影响analyze通过。非作者指出备用入口登录门和排队导航归属缺口，已各经行为RED/GREEN补齐。最后的手动刷新异常由页面错误态承接，单独RED/GREEN通过。
5. 8216同包手机跨多个来电扫描周期滚动位置保持、无loading闪烁，单条已读使服务端未读50→49。最终e5包受控通知GET503后停留错误态，服务恢复及独立后台读取不刷新失败页面，明确UI重试恢复真实列表。Owner确认“正常，不再闪烁，按钮可用”。原工具误点/观察失败按本地原证保留，临时代理已停且手机API直连恢复。

此前5e call44通话错误状态注入恢复、采集保持暂停、明确开麦后Owner“很清晰”反馈继续沿原身份保留。VM对象句柄差异不单独证明新音轨，相关实际事件UNKNOWN。蓝牙因无耳机NOT_RUN，路由故障设备注入NOT_RUN。媒体服务偶发超时根因UNKNOWN，原空房间自动恢复证据范围保留。

## 顾问资料包与剩余流程

[验收目录](acceptance/README.md)包含功能说明、UI导航与控件、[截图索引](acceptance/SCREENSHOTS.md)和[实际测试结果](acceptance/TEST_RESULTS.md)。当前继续消息媒体及其余现有页面。截图、APK、SQL、凭据与原始设备日志仅本地。截图逐张保留原采样候选，最终变更影响的通知页已经用新包复验。资料仍在整理，顾问总验收待提交。

以下为具名历史候选报告。

---

# v10.1.5 实机扬声器与前后台恢复候选

2026-11-12。当前 **OWNER_PHYSICAL_SPEAKER_AND_BACKGROUND_SLICE_PASSED**。冻结判定 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**，Owner总体产品接受待定。

## 当前代码与包

- APP源码 `ba5a5c26c6036086639f156573e826af2b872b34`，Root Tree `5e3d73f5d78273453ef767c0c3cd39175afc7740`，apps Tree `cc2a4d1a54adff243b034960487973cea383ddfd`，services Tree `d5ce843aacffb34fe8727c59aa6434d5f955ba14`，后端源码 `25bc01f7d6ce848f5fe964bbc544e9be87325a0e`。
- `com.elitesync.v1015dev / 10.1.5-dev / 1010501 / arm64-v8a Debug`，离线47.496801秒、退出0、v2签名已核。APK 154560362字节，SHA256 `cc1be2f69ecf96486628fb31584c7fc3e89b4ea26e843998ac277f1e2017fa14`，本机固定交付文件 `delivery/EliteSync-v10.1.5-dev-ba5a5c26-arm64-debug.apk`。
- 手机实际A与5580实际B保留数据更新同包，安装base.apk SHA均核一致。5582的A AVD已暂停，数据与cdb包保留。机器清单见[artifact_manifest.json](artifact_manifest.json)。

## 扬声器切换实现

通话页增加扬声器与系统听筒/耳机偏好切换，Android/iOS支持入口显示。明确切换成功后才提交偏好，失败显示中文重试反馈。切换与播放路由重放串行，绑定Room/连接/采集代次，迟到结果不写入后来的通话。新call默认扬声器，同call重连保留偏好。切输出不会清除前台返回后的采集暂停。

134项RTC服务/页面/权限/来电/聊天定向检查通过，最终4文件analyze clean。非作者Sol/high发现共享旧Room可能被新页面扬声器入口操控的P2，按钮显示、handler及迟到反馈已补connectedCallId匹配。两个明确RED回归后全组134通过，复核确认该P2关闭。本结论仅覆盖本轮变化，既有播放启动、自动路由重放及订阅异常的完整可见恢复反馈P2保留。

## 本轮实机结果

| 候选/通话 | 实际观察 |
|---|---|
| cdb call37 | Owner接听时媒体容器authority monitor TimeoutError后fail-closed退出1，另观察到2GiB guest将前台APP以LMKD结束。两者关系UNKNOWN，原日志保留。恢复自有SFU一次，B guest改4GiB，A AVD暂停 |
| cdb call38 | 手机接听、双端入房，Home后采集停止观察上界0.375秒，返回保持关闭。Owner拔下PC AR眼镜并要求重启模拟器，明确开麦后的声音恢复在此call未完成，正常挂断 |
| cdb call39/40 | 39邀请超时missed。40当前PC扬声器下Owner确认双向清晰，手机Home停止观察上界0.406秒、返回保持关、Owner明确开麦后双向恢复且原生mic active，正常挂断清房 |
| ba call41 | Owner确认双向清晰，初始原生speaker切至earpiece，Owner确认听筒人声清晰。Home后停止观察上界0.406秒，返回保持关；输出偏好往返切换时，每次UI后置状态、暂停提示及原生采集关闭均核实 |
| ba call41边界 | 首次要求不同远端SID的观察窗口超时，实际SID沿用，新的自动订阅事件未确认。后续computed preferred device为null，路由重订阅保留实际结果UNKNOWN。Owner报告扬声器及最终双向清晰，但后置原生查询时call已ended，未据此声称捕获到该次mic恢复。B自动息屏及采集暂停有日志，之后peer_disconnected/sfu_removed，完整断开归因未定 |
| ba call42 | 主代理正常UI从手机创建、B接听。新call默认扬声器UI已核。手机Home后采集停止观察上界0.453秒，返回保持关，主代理明确点击开麦后立即捕获原生mic active，Room双参与者保持。Owner随后明确确认两边人声清晰。正常挂断后42 ended、Room0，手机及B采集均inactive |

上述Home时长使用同一主机monotonic，从Home请求开始到停止采样的观察上界。609 MC commit后4.874250秒结论保留原候选身份，ba本轮未重测撤权5秒资格。当前实测支持本机两设备、已有权限及当前音频输出条件下的语音/听筒与扬声器选择、暂停时切输出、前后台和明确开麦恢复。蓝牙/有线插拔、同call重连、复杂AEC、完整弱网/长时中断矩阵继续待验证。

## 本机服务与测试工具恢复

媒体服务另一次authority monitor TimeoutError发生在最后call预检前，尚未发起新通话。已为当前自有开发SFU配置Docker `on-failure:3`。一次空房间内网关进程受控退出后，Docker restart count增加且恢复运行，ListRooms为0、无效token请求403。网关文件SHA前后相同，保护阈值保留。实际监控超时在该策略下的受控复现未运行，超时发生于哪一步及其底层原因UNKNOWN。首次可选HTTP检查过早出现RemoteDisconnected，随后只补只读检查，没有重复故障注入；精确恢复耗时UNKNOWN。

B guest内存由2GiB调至4GiB以容纳arm64 Debug在x86模拟器的运行，实际guest MemTotal约4GiB。自动息屏后UI观察失败原证保留，当前工具已唤醒并使用既定30分钟测试超时。手机仍沿Owner设置，账号/聊天保留。部分模拟触屏点击未产生预期页面变化，当前手机助手改为150ms正常触屏按压并验证后置UI，原因未唯一确定。

四个自有开发服务继续运行，B为当前ba，A AVD暂停。手机连接及精确本机USB反向映射保留，专用5038 USB排除，手机使用5039。原始日志、截图、SQL、APK与配置回执仅本机。先前合成音RPC期间源模拟器退出仍为UNKNOWN根因，此后未重复该RPC。历史STOP及已耗记录保留。

前序消息/媒体/通知/存储/期限/权限并发及服务重启结果继续沿下方cdb/609原候选身份，当前ba没有重复全部联合旅程。

---

# cdb候选无声修复历史

2026-11-12。当前 **NO_AUDIO_FIX_OWNER_SHORT_VOICE_RETEST_PASSED**。同cdb手机与模拟器call36已确认双向清晰人声，短通话无明显回声/杂音，正常挂断后双端采集释放。冻结仍 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**。

## 当前实机短通话结果

Owner再次从手机A发起call36，模拟器B正常接听，双端入房及四方向音频bytes/packets持续增长。Owner明确反馈“双向人声清晰”，继续交谈约20秒后明确反馈“没有明显回声或杂音”。正常APP挂断后call36 ended、Room0，手机及模拟器的原生CAMERA/RECORD_AUDIO均inactive已核。

本子项通过范围为同cdb候选、当前手机/模拟器及当前电脑音频设备的短语音通话。完整音频路由切换、长通话、复杂回声条件、实机后台/中断矩阵仍待覆盖，AC05继续OPEN。call35沙沙声原失败及配置更正保留。私有回执 `phone-noaudio-host-audio-recall-result-20261112-private.json`，原始日志和截图仅本地。

## Owner实机复测与模拟器宿主音频更正

手机保留数据更新cdb，实际base.apk SHA匹配，A账号和已有B对话保留。call35正常接听后SFU为2参与者，手机与模拟器的四方向RTP增长、接收音频能量有变化。Owner报告只有手机听到沙沙声，电脑端无声，无法听清电脑说话。本次双向人声验证失败，声音/AEC接受继续待定。

进一步实读两个保留AVD的config.ini发现`hw.audioInput=no`及`hw.audioOutput=no`，generated hardware也为false。此前“音频开启”的运行元数据仅凭启动参数未带no-audio，遗漏硬件配置核验，该表述在当前节点更正。正常挂断call35、Room0后顺序停止自有AVD，将两项改为yes并重启，generated hardware两项true已核。B另用SDK console支持的`avd hostmicon`启用宿主麦克风，结果OK，测试语音音量调至8/15。保持已安装APK与账号数据，A模拟器APP暂停避免重复接听。默认Windows输出会随AR眼镜连接切换，未改系统默认设备。

首个240秒UI观察窗未出现新call，最后仍call35 ended，仅记录等待到期。Owner随后重拨call36，结果见顶部。先前合成音RPC期间退出的根因继续UNKNOWN。

## 当前固定身份

- APP源码 `cdb0b46dc4613b35eba7adb0c50415a455f3063c`，Root Tree `9d6ffa2683be0c3df8748f55893d64c331cd9adc`，apps Tree `8d29c5136ae6279938fc55252822e0d2d7d81679`，services Tree `d5ce843aacffb34fe8727c59aa6434d5f955ba14`，后端源码 `25bc01f7d6ce848f5fe964bbc544e9be87325a0e`。
- arm64 Debug，`com.elitesync.v1015dev / 10.1.5-dev / 1010501`，离线37.5032738秒、退出0、v2签名已核。APK 154557386字节，SHA256 `85c6deddd3463d06188137aa9658879fbc054e04867178c04e710bbb27c25fc8`，两模拟器实际base.apk匹配。
- 本机私有delivery文件 `EliteSync-v10.1.5-dev-cdb0b46d-arm64-debug.apk`。机器清单见[artifact_manifest.json](artifact_manifest.json)。

## 缺陷与修复

旧609在接听端首次Android麦克风授权时实际复现call26只有单方入媒体房间，接听端mic关闭。权限窗口导致inactive，初连被暂停后未继续。手机call24同样未形成双端媒体，窗口来源仍UNKNOWN。c1将voice麦克风及video麦克风/相机权限前置，覆盖来电、普通聊天、LiveChat直接创建、深链与重连。权限页只承接自己的授权窗口往返，真实后台、换账号/通话及迟到结果继续失效。媒体未就绪时显示实际连接状态。

c1连续call32又暴露旧终态页inactive后的共享service暂停残留。cdb在已通过前台、权限、通话身份和代次检查的新连接前恢复采集意图，换callId时按当前前台状态重置页面暂停标记。同一通话后台返回继续要求明确恢复。三项新增回归覆盖共享残留、同State前台换call及后台实际换call。

83项RTC/权限/来电/聊天定向检查通过，受影响两文件analyze无问题。c1原80项及10文件检查按原身份保留。非作者Sol/high分别复核权限/取消和cdb新通话恢复改动，未发现这些改动的剩余确定P1/P2。既有播放、强制路由和订阅失败的可见恢复反馈P2继续保留。

## 双模拟器实际结果

| 候选 | 实际范围 |
|---|---|
| c1 call28/29 | 接听端与发起端首次麦克风授权后双端入房、mic active，call29四方向音频计数增长，正常挂断清房 |
| c1 call30 | 接听端首次相机授权后双端mic/camera active，Home后停采集观察上界5.016秒，返回保持关闭，明确开麦与开相机分别恢复 |
| cdb call33 | 双端入房及发布/订阅音轨，随后诊断RPC期间源模拟器退出，客户端报SocketException，退出根因未定，服务端按sfu_removed结束，原失败保留 |
| cdb call34 | 保留终态页经历inactive/resumed后正常创建/接听新call，双端媒体及mic active，四方向音频bytes/packets持续增长 |
| cdb call34 Home | 语音Home后停止观察上界6.047秒，返回保持关闭，明确开麦恢复。正常APP挂断后Room0且双方采集停止 |

Home观察时长保留实际数值。609 call22的commit后4.874250秒停媒证据属于原候选，cdb本轮未重测MC撤权时限。c1首次授权原生结果及609消息、附件、通知、期限、存储和服务重启结果均沿原候选身份保留。

默认blocking合成音诊断期间源模拟器退出，客户端报SocketException，退出根因未定，已恢复自有AVD及精确映射。此前实验模式失败和本次失败均保留，后续RPC重复0，客观扬声器声源结果UNKNOWN。双向RTP与原生mic状态按各自观察记录，当前实机短通话听感已补充在顶部，完整AEC和路由覆盖继续待验证。

早期UI未idle/安装后未绘制窗口、过早读取RTP尾日志及挂断后过早采样均保留。普通APP重启恢复画面，同call34补读完整日志、等待原生teardown后收尾成功，未重复发送消息。

私有原证、APK和诊断工具均在本机。Owner出门期间手机操作0。Owner返回并确认连接后，已保留数据更新cdb，后续结果见本报告顶部。其余冻结未完成项沿下方609报告原范围保留。

---

# 历史609候选固定报告

2026-11-12。状态 **V10.1.5_CANDIDATE_DELIVERED / AWAITING_OWNER_DEVICE_ACCEPTANCE**。按Owner要求完成本轮软件收口并停下，实机协助后继续相应验收。冻结判定保留 **10 PARTIAL / AC05 OPEN / G2 false / REAL_PUSH_PENDING**。产品接受由Owner决定。

## 固定交付身份

| 项目 | 固定值 |
|---|---|
| 产品分支 | `codex/v10.1.5-software-continuation-20261101` |
| APP源码提交 | `60930170e3a437da0b77e877c55ed4dd1a92f9ca` |
| 源码Root Tree | `41c8653140c77089e58e8f7822ce2ce988e0f438` |
| apps Tree | `f586b9eb5bb2f1c970cee0ec93602b407f996c1e` |
| services Tree | `d5ce843aacffb34fe8727c59aa6434d5f955ba14` |
| 后端源码节点 | `25bc01f7d6ce848f5fe964bbc544e9be87325a0e`，services Tree与交付一致 |
| 包与版本 | `com.elitesync.v1015dev / 10.1.5-dev / 1010501` |
| 构建 | arm64-v8a Debug，离线30.3414811秒，退出0，v2签名已核 |
| APK | 154546416字节，SHA256 `d8af0c896ceeb43d2251c89d1080eced593392d5127b0276c95db7ba88b89b67` |
| 本地交付文件 | 私有根下 `delivery/EliteSync-v10.1.5-dev-60930170-arm64-debug.apk` |

交付文档提交继续引用上述源码身份。机器可读清单为[artifact_manifest.json](artifact_manifest.json)。本机API/WS/SFU及虚构持久库是此Debug候选的运行环境。实机连接配置在Owner协助阶段核定。

## 本轮修复

- RTC显式创建并登记替换轨道，暂停时覆盖inactive。持续保留Room和采集代次归属，SDK重连清空publication时仍能清理原轨道。迟到发布按自身归属清理，用户明确开麦与开摄像头分别生效。
- 通话授权失效页提供中文反馈和返回会话入口，终态去掉恢复采集提示。
- 附件上传ready后保留重试入口，直到相匹配的持久化消息attempt接管。已有其他attempt时阻止新附件点击隐式重发，重试素材从原attempt绑定取得。补充等待发送确认文案。
- 既有同会话在线核验后恢复加密草稿及原提交编号逻辑纳入最终候选。

## 检查及非作者复核

| 范围 | 实际结果及身份 |
|---|---|
| RTC/来电 | 94fd/b4源码108项定向检查通过，四文件analyze无问题 |
| RTC失权反馈 | 2dce源码27项页面检查通过，相关analyze通过 |
| 附件接管/聊天/历史/缓存 | 5af源码97项通过，两文件analyze通过，两条精确RED原证保留 |
| 最后ready文案 | 609源码1项定向检查通过，最终两文件analyze无问题 |
| 草稿冷启安全 | 3c源码109项及四文件analyze通过，按原候选保留 |
| 非作者代码复核 | Sol/high检查RTC代次与附件接管，未发现剩余确定P1/P2 |
| call22计时复核 | 非作者独立复算4.874250秒，核对隔离/事务、版本、AppOps完整性及采样尾窗，无剩余确定问题 |

上述检查按实际源码和日志分别归属。最终609仅在5af后改变一处ready文案，RTC和后端逻辑保持。非作者复核属于工程证据，Owner产品接受继续待定。最终交付材料的复核结论在本报告末尾记录。

## 最终609的实际开发链

私有原证根为 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev`。清单只记录原证文件名、摘要和SHA256，原始内容保留本机。

| 子链 | 本次实际观察 | 私有回执 |
|---|---|---|
| 双端身份 | 5580实际B/user2、5582实际A/user1，两端安装base.apk字节SHA一致 | `candidate609-installed-20261112-private.json` |
| 未知POST冷启 | 一次正常APP发送109，真实200确认被本机观察代理替换503。离线冷启隐藏，在线同会话/peer核验恢复原UUID。明确原编号重试返回同109和200 replay，一条密文、一通知、一事件，确认后冷启pending为空，自动POST为0 | `candidate609-pending-completed-20261112-private.json` |
| 视频/图片 | 正常APP上传并发送视频110/asset12、图片111/asset13，真实DB关联和文件hash正确，视频播放至0:02，图片预览及对端读取 | `candidate609-image-video-runtime-20261112-private.json` |
| 系统通知拒绝 | A的POST_NOTIFICATIONS为denied，实际通知设置提示核心入口可用。一条正常A→B文字112持久化为密文、单通知/事件，B正常冷启读取，原权限状态恢复 | `candidate609-notification-denied-message-20261112-private.json` |
| 旧通知真实点击 | B实际点击通知168的打开动作，已观察到handler发出的detail GET。转发该GET前正常撤MC，真实API响应清空route/args/payload，含撤权耗时0.281秒。APP留在通知中心，目标read POST为0、read_at保持。正常双向重新同意至generation13 | `candidate609-stale-notification-click-20261112-private.json` |
| RTC当前/旧权限 | call22双端当前JWT验证200，旧JWT在未过期时撤权后及新同意后均403。当前图片/视频双方full200/Range206、字节/hash相符，撤权后旧URL拒绝。旧房间消失 | `candidate609-rtc-authorization-tail-verified-20261112-private.json` |
| RTC原生停媒 | 同一主机monotonic时钟，以最后ACTIVE查询开始/首REVOKED查询结束夹住commit。autocommit1、无活动事务、RR普通SELECT，revision/generation对应。CAMERA/RECORD_AUDIO统计行完整。commit后保守停止上界4.874250秒，包含时钟余量。随后15次双端inactive采样覆盖约2.016秒并越过commit上界后5秒，尾窗内未见反弹 | 同上 |
| 持久服务重启 | APP先暂停，仅原四个owner匹配容器按SFU→WS/API→DB停止，DB→API/WS→当前authority就绪→SFU启动。4用户、112消息、13媒体及指定全体snapshot事实前后相同 | `candidate609-controlled-services-restart-20261112-private.json` |
| 重启后APP | 两端同包正常冷启重读112，B打开持久图片、视频播放到0:02，零发送，指定持久事实继续保持 | `candidate609-post-restart-app-readback-20261112-private.json` |
| 独立Web | 重启前后分别完成真实HTTP登录、搜索、详情、列表、退出9项，业务突变0。既有浏览器渲染证据按原节点保留 | `final-web-before-restart-20261112-private.json`、`final-web-after-restart-20261112-private.json` |

重启比对包括原用户、原1–104消息不可变字段、原7媒体、CN/MC、session/token/T0、所有新增消息与附件绑定、每逻辑消息通知/事件数量及媒体文件hash。正常消息已读时间属于可变字段。MC观察与恢复在重启基线前完成，重启时保持同generation13。

## 可信期限与原生故障的验证范围

- 实际Laravel HTTP kernel和MariaDB事务内受控服务端时钟16项通过。真实密码登录生成账户/设备/T0绑定，verify/refresh保持原期限，15/30天前/当/后路由权限符合预期。finally清除受控时钟并回滚，原users/sessions/tokens指纹相同。回执 `retention-route-boundary-20261112-private.json`。
- 独立包 `com.elitesync.v1015probe.v1015dev` 使用真实Android加密存储插件、独立UID与Keystore namespace。受控wall/elapsed及synthetic receipt覆盖15前/当、30前/当，四单故障和连续三故障，共7次选择性wrapper故障。locator末步失败后真正force-stop，新PID冷启重试完成，原产品加密文件hash保持。回执 `cache-native-probe-runtime-20261112-private.json`。
- 自然经过30天、物理磁盘故障和硬件Keystore的实机验证仍待完成。受控边界与插件故障证据的范围按上述条件保留。

## 沿用证据及原始失败

- 同键200/不同payload409和单副作用在相同后端源码25bc真实核验，消息105。ready附件一次明确重试、一次上传/消息108在5af候选实际通过。最终609的18秒延迟观察窗口超时，正常发送已完成110，该记录只支持正常发送，609的明确附件重试实际观察仍UNKNOWN。5af后的附件逻辑保持，原候选与最终候选的实际观察分别记录。
- 既有Block、CN关闭、peer禁用和MC撤权的MariaDB锁等待证据按11月8日原候选保留。当前授权协调核心沿用，MessageController新增分页、LiveConsentService新增43326开发库白名单。本轮未重跑完整actor/peer、所有detail/mutation、APP/WS/cache及媒体在途竞态矩阵，AC03继续PARTIAL。相关[MC并发记录](../../workflow/V1015_MESSAGE_CONCURRENCY_DUPLICATE_MC_VERIFIED_20261108.md)和[Block/CN/peer禁用记录](../../workflow/V1015_MESSAGE_PERMISSION_MATRIX_BLOCK_CN_DISABLE_VERIFIED_20261108.md)保留。
- call15前台返回采集再次active、call20 request-start停止上界5.078秒且缺commit真点、call19观察工具GBK失败和先前UI/时序助手错误均保留。call20保持未获得5秒资格，call22按独立commit夹测结论记录。heartbeat仍2秒。
- 2d候选曾上传ready视频asset9后丢失重试入口，该未关联素材继续保留为失败原证。两条RED及5af修复均有独立记录。
- 账户/问卷隔离、资料/头像、好友/动态/搭子/合成活动、三盘/动态盘、UI首轮及传输封装按[PROGRESS](PROGRESS.md)中具名候选沿用。地图/地点与其他旧附件恢复UNKNOWN，语音留言OUT_OF_SCOPE/NOT_IN_SCOPE，依据冻结F5的有界来源判断。

## 冻结AC与Owner实机入口

| AC | 保留判定 | 当前结论及待补范围 |
|---|---|---|
| 01 | PARTIAL | 代码/原库/index保护、候选和私有原证已记录，最终接受待定 |
| 02 | PARTIAL | 最终pending冷启、正常双向文字、旧候选并发/附件重试有效，弱网与时序覆盖有界 |
| 03 | PARTIAL | 历史真实消息权限并发及当前JWT/URL/通知重验有效，完整权限/在途竞态矩阵仍有未测路径 |
| 04 | PARTIAL | 最终同包图片/视频发收、撤权及重启读回有效，全部媒体故障/竞态覆盖待扩充 |
| 05 | OPEN | 模拟器RTP/画面、采集停媒与旧JWT有证据，实机音质、AEC、路由/后台体验待Owner协助 |
| 06 | PARTIAL | 真实认证路由受控时钟边界通过，实机时钟/设备恢复和自然时间运行待观察 |
| 07 | PARTIAL | 真插件受控多故障及新进程重试通过，硬件Keystore/物理故障待验证 |
| 08 | PARTIAL | 最终拒绝通知权限仍可消息、旧通知真实点击重验通过，全部类别/主体界面覆盖按原范围保留 |
| 09 | PARTIAL | provider/token契约已有，真实Push供应商与送达PENDING |
| 10 | PARTIAL | 最终APP/API/MariaDB/Web及四服务重启旅程完成，跨设备总体接受待定 |
| 11 | PARTIAL | 唯一报告/manifest、固定APK及非作者有界复核交付，Owner功能接受待定 |

Owner实机阶段优先核安装/登录与权限体验、双端文字图片视频、通话听感/AEC/音频路由、前后台与撤权、加密存储及设备重启。硬件条件和真实Push分别按实际权限处理。独立精度/解释AI沿后续路线保留。

## 停下时状态

两端APP正常force-stop，AVD、登录及数据保留，两模拟器保持运行。DB/API/WS/SFU四自有服务保持运行，房间0且双方采集停止。原主库255项dirty、index差异0字节的只读快照保留，本轮对此根写入0。产品无关 `%SystemDrive%/` 保留，当前分支只提交具名源码及文档。手机、默认5037和历史STOP/已耗记录保持原边界。最终本地/远端HEAD及资源实读结果写入日期化私有保存回执。

## 最终交付材料复核

非作者Sol/high已核对固定源码/Root/apps/services、APK字节数/SHA及16份具名原证hash，检查候选归属、609明确附件重试UNKNOWN、原失败、受控边界和硬件实机范围、冻结AC与隐私发布边界，未发现确定P1/P2。随后主代理补齐最终资源实读和当前私有节点，原主库以相同porcelain-v1 NUL格式核验与先前摘要相同，255项dirty/index差异0字节。最终Git身份由日期化私有保存回执补齐。
