# EliteSync v10.1.5 顾问验收结论 R1

日期：2026-11-12  
审阅对象：2026-11-12 顾问验收包、其声明的最终APP源码及相关交接。  
结论：**CHANGES_REQUIRED / PARTIAL——本轮任务尚未全部完成，签发同版本集中补充任务，不进入v10.1.6。**

工作流交接按Owner本轮声明视为完成。本次不是重新迁移治理，也不恢复旧的逐动作GPT审批。现有成果继续保留；本轮要求补的是已确认缺陷、可由普通工程完成的关键流程、必要的证据适用性和材料一致性。

## 一、审阅基线与可信范围

| 项目 | 本轮核对结果 |
|---|---|
| 仓库/验收分支 | zcx369658780/EliteSync-v10；codex/v10.1.5-advisor-acceptance-20261112 |
| 固定验收包提交 | 85197adec124ef94bbef2994c0668dc990f9bed4 |
| 本轮读取到的验收分支HEAD | 3c0bb382b0d0d58eaaf18a7d154eea06818928e0；比固定包前进1次提交，仅涉及5份治理/交接文件，包及产品源码未变 |
| APP源码 | 0badb31c38db63fe0fb1b5fcbfb43e5cb4e68d3f |
| APP提交Root Tree | cab9e7f5700eb8f7402401ee56cdc6e4e92d795f |
| apps / services Tree | a4e4b62f58a1c6de353d2f69bace6c9d51eb6bd9 / 8bc64ce9d43e84897eac0c56782c8f17870ae05f |
| 配套后端源码 | 6549f02880968f99ae3f45439d15a37c1b3d5251 |
| 材料声明的APK | EliteSync-v10.1.5-dev-0badb31c-arm64-debug.apk；154570461字节 |
| APK SHA256 | 1e9adad71b962c8adfcfd280450ed9ae9e5b1f7127988d225a036e3c3826dfea |
| 包名/版本 | com.elitesync.v1015dev；10.1.5-dev / 1010501 |
| 接受对象的限制 | restorationLocalBuild开发变体；不是正式发布包全部路径的验收 |

来源：[固定验收入口][package]、[制品清单][manifest]、[最终安装摘要][install]、[APP提交][appcommit]、[最新本地交接][handoff]。APP提交及根Tree通过仓库对象核对；APK身份在manifest与安装摘要之间一致，但本轮未取得APK二进制重新计算其hash。

### 实际完成的审阅

- 读取功能说明、按钮/导航、测试结果、实施报告及其历史节点、制品/发布清单和当前工作流交接。
- 读取29/29份去敏证据摘要；逐项区分实际结果、来源引用与历史叙述。
- 获取120/120张PNG，逐张核对索引SHA256并解码；完成全部联系表总览，对发现问题与关键RTC状态放大原图复核。
- 对已取得的38份文本材料核对发布清单中的大小与SHA256，未发现发布内容不匹配。
- 定点核查最终源码的资格提交page/provider、MBTI题页与主题、引导、作者页及相关差异；确认0bad相对26c只修改来电页和其测试。

这是一轮远端材料、截图和定点源码审阅，没有运行本地Windows工程、操作手机、重新执行产品测试或独立读取所有LOCAL_ONLY原始回执。静态截图不等于交互回放；私有原回执hash只能用于日后对照，不能独立证明运行事实。以下结论始终保留候选、设备与证据类型。

## 二、已有成果及可继续使用的范围

本轮不将“10 PARTIAL”解释为十项没有完成任何工作。以下具名证据足以保留各自对应流程的工程成果，后续仅需检查复用条件或补受影响部分。

| 范围 | 已有支持 | 不自动推导的结论 |
|---|---|---|
| 通知与设置 | 通知偏好持久化、失败停住后手动重试、闪烁修复、昵称独立保存与恢复 | 全部旧通知路由及真实系统Push已经通过 |
| 版本检查 | dev版本误判为0并提示降到旧版本的问题已有后端修复、测试和运行证据 | 正式发布升级全链已验收 |
| 消息/图片/短视频 | 26c有双向文字120/121、图片122、视频123及手机预览播放等具体结果 | 所有弱网、并发、在途撤权及媒体失败矩阵均通过 |
| 最终来电 | 0bad的call46自然过期自动终态、call47正常拒绝，有截图与事件摘要相互支持 | 最终候选已实际接听、完成双向媒体及音质验收 |
| 问卷与私有盘 | 20题提交/结果/历史、可选MBTI结果、三盘及Synastry保存和读回 | 盘面独立精度已经验证，或下游匹配关系闭环已经完成 |
| 登录与日常使用 | 正常退出、服务端撤销读回、再登录、引导重播、主题恢复 | 注册成功、改密成功、首次自动引导、账户注销均完成 |
| 管理端 | Web登录、10个页面只读浏览、退出及长页面截图 | 本轮已经完成全部管理写操作 |
| 历史可靠性证据 | 未知POST冷启重放、受控15/30天、Android插件清理故障、历史撤权停媒、Owner有界听感等 | 这些结论无需说明便全部适用于最终候选 |

来源：[功能说明][functions]、[测试结果][tests]、[实施报告][implementation]、[26c媒体摘要][media]、[最终来电摘要][incoming]。0bad的最后改动没有触及聊天业务，因此没有要求重跑全部聊天或重拍120张截图的依据。

## 三、影响本轮完成判断的发现

### F1｜资格提交失败仍关闭表单：确定的源码错误分支

最终源码中，页面执行`await submit(...)`后只检查`mounted`便`router.pop()`；provider的`submit()`返回`Future<void>`，捕获异常写入`state.error`后正常返回。由此，提交失败同样继续返回上一页，表单控制器销毁，本次输入丢失。

这是**源码确认、尚未由本轮实机重现**的缺陷；导航材料也描述了该行为，不能仅因已经写进说明而视为通过。应以明确成功结果控制返回；失败保留输入、显示错误和显式重试，同时处理账号/页面已变化的迟到结果。若POST已成功但状态读回失败，应显示未确认状态，避免自动重复提交。

来源：[资格提交页][verification-page]、[资格provider][verification-provider]、[导航说明][navigation]。仅需虚构输入和受控响应，不要求调用真实认证供应商。

### F2｜MBTI已选答案不可读：截图可见，相关源码仍被最终候选保留

截图050显示已答3/3，但三个已选A项成为纯蓝填充区域，文字不可读；未选B项正常。原图放大后现象仍成立，索引中仍存在相应选项文案。用户因而不能在提交前复核已选答案。

bd4c和最终0bad的MBTI题页同为Blob`5eebf867c7cb062b0f1721840b05abf20b956f1c`，相关明暗主题/颜色文件也分别未变。题页只对选中项设置`primaryContainer`背景，没有匹配的前景覆盖。因此该旧图揭示的样式问题仍保留在本次最终源码；本轮没有重新运行最终APK。补充应限定为选中态前景/背景和状态可辨识性，定向复核A/B切换、重选、提交前回看及明暗主题，不重做整套测评。

来源：[截图050][shot050]、[MBTI源码][mbti]、[暗色主题][dark-theme]、[亮色主题][light-theme]。

另有两项可并入现有流程的低成本修正：当前引导仍说“首页用于查看慢约进展”，而交付变体将其放在“进展”；连接空态直接显示`Bad state`实现细节，应在验证连接流程时区分正常暂无匹配与请求失败，提供用户可理解的下一步。它们不构成大范围UI重做理由。[引导源码][onboarding]；[截图086][shot086]；[导航说明][navigation]。

### F3｜自有SFU超时并退出：恢复不等于故障关闭

实施报告当前节点记录5次`authority_monitor TimeoutError`，服务耗尽3次自动重启后退出；摘要记录退出码1、重启前次数3，根因仍为UNKNOWN。随后恢复到Room0只证明一次恢复，不证明重复退出原因已经修复。

该问题属于当前自有开发服务的可控可靠性范围。需要从已有原始日志确定超时阶段、依赖和触发条件，修复确认的问题，做一次有限恢复链并核房间/采集收尾、旧令牌拒绝和恢复后的正常短通话。不能靠关闭鉴权监控或无限扩大重启/超时阈值宣告完成。

来源：[实施报告当前节点][implementation]、[SFU恢复摘要][sfu]。

### F4｜内存修复方向有证据，但持续验证尚不足

旧bd4c材料有2次ANR、32条堆耗尽消息；1880个会话与479118个事件对象对应94份旧快照累积。后续已移除旧FutureProvider快照积累路径。26c观察240.906秒，最终0bad观察120.843秒，端点GC后的65个会话/120个事件未增长，当前进程未发现OOM，另有一次20秒熄屏恢复。

这些是有效的短时修复证据，**不能据此认定仍在泄漏，也不足以关闭已出现过的持续累积风险**。应依据旧故障机制安排一次有限观察，覆盖轮询、页面进退、来电过期/拒绝及前后台/熄屏；记录正常运行内存趋势、可比较静稳时点的保留对象、峰值/回落和ANR/OOM。不要求无限压力测试，也不要求反复抓完整堆。

来源：[历史ANR/OOM摘要][anr]、[修复后观察][memory26c]、[最终观察][memory0bad]、[实施报告][implementation]。

### F5｜关键证据继承尚未清楚，部分已有功能只有入口或受限状态

609候选已有MC数据库提交至采集停止的保守上界4.874250秒；后续又修改权限窗口、采集恢复、输出路由等。最终0bad的call46/47摘要明确没有接听或麦克风操作。旧证不能直接改名为最终候选实测，最终过期/拒绝也不能替代撤权停媒。

应按实际源码与影响依赖建立简短适用性表。原证充分且未受影响的直接继承；对已变化的关键RTC授权/采集路径补最终候选定向验证，明确实际COMMIT或可证明时间区间、测量误差、双端停止及旧JWT/房间不能复活。历史Home请求到采样的5.016/6.047秒和MC提交后5秒不是同一度量，不能混算成一次失败。

另外，注册仅表单、改密仅空输入校验，慢约/连接/正式关系/搭子/社区多为空态或权限拒绝，反馈草稿为SRC_ONLY。管理端本轮是只读。需要对当前可达的关键成功链和必要失败/返回条件补证，使用虚构账号和既有受控开发环境；历史通过且相关实现未变的，不重复运行。真实身份条件单列，不用合成夹具冒充真实认证。

作者页固定无权态、稍后查看不保存书签、反馈仅本地草稿等属于实际能力边界。应明确披露，不能因入口存在就标为功能完成，也不把此次补充扩为公开作者资料、收藏系统或反馈后端开发。

29份摘要中，部分决定性历史原证仍只有实施报告叙述/LOCAL_ONLY hash；应优先从已有回执提供去敏摘要。`rtc-latest20-event-count.json`仅来源引用，`final-resource-state.json`没有可独立判断的结果字段，不能承担超出其内容的证明责任。

来源：[实施报告][implementation]、[测试结果][tests]、[功能说明][functions]、[导航说明][navigation]、[证据目录说明][evidence]。

### F6｜两处历史源码与APK映射错配，需依据原回执纠正

| 清单位置 | 材料不一致 |
|---|---|
| prior_candidate_ba | source写ba5a5c26，APK字段却是5e023b06的文件名、d60d8bc…hash、154567981字节；实施报告中的ba是cc1be2f69ecf96486628fb31584c7fc3e89b4ea26e843998ac277f1e2017fa14、154560362字节 |
| prior_candidate_5e | source写5e023b06，验证仍对应call44，APK字段却对应e5aa6a29的398d9e…hash和154568851字节 |

这证明历史材料映射存在错误，**不证明设备曾经安装错包**。当前0bad顶层与安装摘要没有同类冲突。只需用现存本机构建/安装回执校正并注明修订原因，不猜hash、不重建历史APK。

同时明确本次交付的是restorationLocalBuild开发变体：消息为Live页面、慢约为SlowDatingJourneyPage、连接为LiveConnectionPage。正式构建另一套消息/匹配/连接实现不能被这些证据代证，也不因此自动要求本轮同时完善两套应用。

来源：[制品清单][manifest]、[实施报告][implementation]、[导航说明][navigation]。

## 四、截图如何支撑结论

120张均可用、来源可辨；它们来自8个源码节点，其中105张APP、15张后端。最终0bad仅4张，分别是116—119。保留历史候选身份是正确做法，不要求把120张全部换成最后候选。

按用户完成目标的顺序，本轮看到的是：

1. **登录/准备账户：** 已有登录、退出及恢复证据；注册成功和改密成功仍缺。
2. **填写资料/问卷：** 问卷结果与历史可见；资格提交失败处理有源码缺陷；MBTI有可读性缺陷。
3. **进入慢约/建立连接：** 多张图显示资格、审核或无匹配条件；086是空态/错误态，不能证明成功连接。
4. **消息与通话：** 具名文字、图片和视频链可以保留；116/117与事件证据一起支持过期收口，118支持拒绝，不支持最终实时音质结论。
5. **设置/管理：** 通知、主题、重播引导与Web只读可以分项保留；119一次唤醒后页面存在，不证明长期稳定性。

120号是历史5e通话图，包含in_call、采集暂停、麦克风关闭和远端音频活动状态；不能代替最终0bad双向通话。017旧强制降级故障已有023修复后状态，本次不重复判为当前缺陷。

来源：[截图索引][screenshots]及[截图元数据][screen-index]。截图复核没有发现要求整体视觉重构的依据。

## 五、与原AC和当前状态的关系

当前公布的`10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING`继续作为已有记录保留。顾问判断依据是上述具体事实，不是标签数量。下一次材料应提炼当前AC表，分清“工程未完成”“历史证据可继承”“外部受限”“等待顾问/Owner决定”。

| AC范围 | 本轮处理 |
|---|---|
| 01 技术基线/数据保护 | 继续使用已具名来源和保护记录；当前真实根、分支、工作区由本地Codex最小核对，不重开历史迁移 |
| 02 消息可靠性、04 私有媒体 | 保留具名实测；核未知POST等历史原证适用性，仅补具体未覆盖或受影响链 |
| 03 授权/晚响应 | 核当前变化涉及的切号、在途撤权、旧通知/媒体等代表性正反例，避免全组合重跑 |
| 05 RTC | 服务退出、持续观察、当前撤权适用性仍需补充；音质/硬件限制按实际分级 |
| 06 可信计时、07 加密离线 | 优先补现有原回执去敏摘要及继承说明；受控边界与自然时间、插件故障与硬件故障分别记 |
| 08 通知、09 Push隔离 | 保留通知偏好/错误修复，定向核点击重验；真实Push继续PENDING |
| 10 关键运行与复用 | 收尾时组合一次与改动相称的短联合旅程，记录当前APK/后端及必要持久事实 |
| 11 集中交付 | 修正历史映射，提供准确当前完成度、变体范围及必要补充证据 |

来源：[版本功能标准][plan]。其中旧派单/冻结执行器/预算程序已由当前工作流替代；历史G2 false不直接等于当前构建失败，不能据此复活旧执行链。当前材料已记录实际成功构建，二者必须说明关系。[最新交接][handoff]；[当前Owner决定][owner]。

## 六、本轮补充与停止条件

已形成一份集中补充任务，分为五个可由Codex自行安排的工作块：

1. 自有SFU故障处理和RTC有限持续观察。
2. 关键权限/媒体与旧证据适用性。
3. 资格提交、MBTI显示修复和已有主要交互补完。
4. 历史制品映射、当前构建变体及能力说明校正。
5. 最终短联合旅程、准确完成度表、manifest与必要去敏证据。

**保留限制：** 真实Push；缺少设备条件的蓝牙/硬件/复杂AEC；自然15/30天；独立盘面精度；真实身份、生产和运营等。它们不冒充PASS，不掩盖可修软件缺陷，也不阻挡其他已授权工程完成。普通工作继续使用当前长期授权；手机动作按最近具体授权与实际连接安排。

当可由本地工程解决的补充项完成，材料准确且仅剩明确外部限制，可交付`SUPPLEMENT_SCOPE_COMPLETED_WITH_EXTERNAL_PENDING`；无此限制可交付`SUPPLEMENT_SCOPE_COMPLETED`。这些是补充任务状态，不等于Owner已接受整版或已批准发布。若仍有本轮可修缺陷或关键证据缺口，保持`CHANGES_REQUIRED/PARTIAL`并列清原因。

完成本轮集中目标后，Codex保存并按现行授权分支同步，停下提交复核，再由Owner讨论是否接受和后续版本方向。本轮不合main、不发布、不启动v10.1.6。顾问未在此次审阅中改动产品仓库或运行用户设备。

[package]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/README.md
[manifest]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/artifact_manifest.json
[install]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/evidence/runtime-fix-0badb31c-installed.json
[appcommit]: https://github.com/zcx369658780/EliteSync-v10/commit/0badb31c38db63fe0fb1b5fcbfb43e5cb4e68d3f
[handoff]: https://github.com/zcx369658780/EliteSync-v10/blob/3c0bb382b0d0d58eaaf18a7d154eea06818928e0/docs/workflow/V1015_ADVISOR_ACCEPTANCE_HANDOFF_20261112.md
[owner]: https://github.com/zcx369658780/EliteSync-v10/blob/3c0bb382b0d0d58eaaf18a7d154eea06818928e0/docs/decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md
[functions]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/APP_FUNCTIONS.md
[tests]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/TEST_RESULTS.md
[implementation]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/IMPLEMENTATION_REPORT.md
[navigation]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/UI_NAVIGATION_AND_CONTROLS.md
[media]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/evidence/phone-emulator-media-26c88ddb-runtime.json
[incoming]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/evidence/incoming-expiry-final-phone-runtime.json
[verification-page]: https://github.com/zcx369658780/EliteSync-v10/blob/0badb31c38db63fe0fb1b5fcbfb43e5cb4e68d3f/apps/flutter_elitesync_module/lib/features/verification/presentation/pages/verification_submit_page.dart
[verification-provider]: https://github.com/zcx369658780/EliteSync-v10/blob/0badb31c38db63fe0fb1b5fcbfb43e5cb4e68d3f/apps/flutter_elitesync_module/lib/features/verification/presentation/providers/verification_provider.dart
[shot050]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/screenshots/050-mbti-answered.png
[mbti]: https://github.com/zcx369658780/EliteSync-v10/blob/0badb31c38db63fe0fb1b5fcbfb43e5cb4e68d3f/apps/flutter_elitesync_module/lib/features/profile/presentation/pages/mbti_center_page.dart
[dark-theme]: https://github.com/zcx369658780/EliteSync-v10/blob/0badb31c38db63fe0fb1b5fcbfb43e5cb4e68d3f/apps/flutter_elitesync_module/lib/design_system/theme/dark_theme.dart
[light-theme]: https://github.com/zcx369658780/EliteSync-v10/blob/0badb31c38db63fe0fb1b5fcbfb43e5cb4e68d3f/apps/flutter_elitesync_module/lib/design_system/theme/light_theme.dart
[onboarding]: https://github.com/zcx369658780/EliteSync-v10/blob/0badb31c38db63fe0fb1b5fcbfb43e5cb4e68d3f/apps/flutter_elitesync_module/lib/features/onboarding/presentation/first_use_onboarding_page.dart
[shot086]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/screenshots/086-connection-current.png
[sfu]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/evidence/sfu-memory-candidate-recovery.json
[anr]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/evidence/emulator-idle-focus-anr.json
[memory26c]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/evidence/rtc-memory-fixed-observation.json
[memory0bad]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/evidence/rtc-memory-final-0badb31c-observation.json
[evidence]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/evidence/README.md
[screenshots]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/SCREENSHOTS.md
[screen-index]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/advisor-acceptance-20261112/screenshot-index.json
[plan]: https://github.com/zcx369658780/EliteSync-v10/blob/85197adec124ef94bbef2994c0668dc990f9bed4/docs/versions/v10.1.5/plan.md
