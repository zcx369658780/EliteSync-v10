# EliteSync-v10｜v10.0.9 版前交付提案 v0.1｜原APP待恢复用户能力优先

**2026-10-15。V10_0_8_K08_COMPLETE / V10_0_9_PREPLAN_READY / NOT_FROZEN / NOT_IMPLEMENTED / OWNER_SCOPE_AND_DEPENDENCY_CHOICES_PENDING。**

本文件由Astra基于v10.0.8固定集成结果、Owner批准的完整APP＋独立Web管理目标、现行路线图和唯一功能恢复台账制定。它只是**单份版本范围与技术风险收敛入口**；不修改现行Owner政策、v10.0.6～v10.0.8验收或路线图，不创建正式`v10.0.9/plan.md`，不自动调用Codex实现、启动Docker/SFU/算法依赖、改变任何权限或运行生产。

## 一、固定当前基线，已接受成果不重开

- 仓库`zcx369658780/EliteSync-v10`；本提案编制前实际GitHub main：**`3a8f7989aa208285b885f1c80f4365f38488ac54` / Tree `95fadde468d8a21b39c544fdb74093dd35184717`**。产品K08集成Commit`4f1b3c52d09346cf831249ee7e8186f2679b2217` / Tree`8088a870c979d8697aa781456d994076a158d799`。
- [v10.0.8 K08](../v10.0.8/integration.md) 已实读，产品`apps`/`services`/`question_bank`与最终接受R1候选`d37121eb11d3cc845f1606a631d17ca01fe6105a`对应Git对象完全相同。最近工作树接续CLEAN属Codex本地报告，不由Astra远端观察。8个PHP文件lint exit0，空白检查exit1且属已接受格式、其它新测试/构建/运行`NOT_RUN`。开发版release记录仍对应初始0.8 APK旧hash，不等于R1包已对外托管发布。
- v10.0.6～0.8均**在各自冻结范围内ACCEPT WITH OBSERVATIONS并完成K08**；本版不再为它们重写计划、重做完整业务实测或覆盖原失败。v10.0.7带同次fixture Flutter全量821过/3失败exit1（旧展示/导航合同），v10.0.8全量Flutter未运行；保留为未来受影响差异回归或最终联合验收观察，不声称整个APP已全绿。
- **这次提案及后续纯文档提交不改变v10.0.9可用的产品技术起点**。正式冻结前重新核实实际main/工作树及源码差异，不以此文档Commit当构建起点。

## 二、当前路线为什么需先收口功能再全端终验

Owner在[产品决定](../../PRODUCT_DECISIONS.md)与[路线图](../../architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)明确：恢复**可实际使用的完整APP（选定原版已实现主要功能）＋独立Web后台**，主要功能在内测开始前完成；新增设想允许后置，但必须具名，真实取舍仍由Owner决定。原路线暂将v10.0.9称为`APP/Web联合验收`、v10.0.10为`完整交付`，并允许根据真实缺口扩展功能版本；**这些版本名不是已冻结承诺**。

当前[单份恢复台账](../../architecture/RESTORATION_CAPABILITY_MATRIX.md)显示，APP与后台主链已限域通过，但以下具名能力**尚无完整端到端接受**：
- A06：RTC两端音视频；语音/视频等其它原版媒体及附件使用点，实时WS能力。
- A07：完整紫微排盘及准确性oracle；西占本命/宫位、合盘、行运与返照的真实计算服务/许可/时区与坐标；八字本地链已有限度接受，不等于完整三种排盘。
- A08：Buddy与Social真实双端业务，部分地图/系统Push/设置同步（目前已核Flutter页面多为静态/mock）；须分清旧版确已实现的功能与未实现的新设想。
- A03/A09：原历史业务数据/附件来源及获准恢复范围UNKNOWN，全能力联合测试、安装部署、失败重试及操作/算法说明尚待完成。
- v10.0.8 B06 release metadata目前不等于最新R1本地APK被托管/发布；实际内测分发前需对齐hash、URL及应用内下载行为。

**Astra的建议（不是Owner已批准的改排）**：下一阶段优先交付真实用户功能缺口，只有这些主要功能收口或Owner批准明确排除后，再冻结“完整APP＋后台联合终验”和最终软件交付。否则把未恢复RTC/算法/社交列为NOT_RUN却用一个联合验收版宣布软件完成，会违背Owner目标。为加速，不建立多个连续只读考古版本或微页面任务。

## 三、v10.0.9 首选产品工作包（待可行性收敛及Owner确认）

### 首选主链：A06 RTC真实双方通信＋已实现的其它消息媒体

以已接受0.7`Match → 独立Connection → 独立Messaging Consent → Conversation`为权威，不让released Match、旧token或客户端本地状态直接授予RTC权限。按实际源与许可对**本地受控、无需付费第三方的RTC方式**给出可操作方案：指定双设备/模拟器、真实信令与SFU/ICE/媒体通道、创建→呼叫→响铃→接听/拒接→双方真实音/视频收发→结束/断线/重连。证明同一`call_id/room_key`双方真实媒体帧或RTP统计/听到声音/见到画面，而不是仅token或状态API成功。基于动态当前CN/MC及D2处罚、禁用、block、同意撤销，**每个join/token/通话操作使用点均需服务端复核并失效**；production默认fail-closed。

当前GitHub具名源事实（固定K08 main）：
- `services/backend-laravel/app/Services/RtcSessionService.php::canCall`的当前允许线索是已发布Match、block等，**未能仅凭现有源码证明已按CN/MC及restrict等最新真实权限闭环**。`LiveKitTokenService::issueJoinInfo`在配置有效时签JWT且`RtcController::livekit`读取会话参与者；令牌发放仍需审查当前合法通话状态、双方同意、终止/撤权和现有通话对端范围。不得把新发短期JWT视为撤销旧token已完成。Flutter的`rtc_livekit_service.dart`使用`livekit_client`，并有收发音轨诊断代码；**客户端存在不证明SFU服务、设备双方实际已连通**。
- `config/livekit.php`默认关闭且URL/key/secret需要具名设置，绝不能推断已开通外部提供商、许可证或生产端口。建议Codex先列最小**本地隔离SFU部署及第二端/媒体权限**，需Owner批准的新Docker镜像/UDP端口/外联范围单列，获批前不得实际启动、下载或访问。
- `MediaAssetService`可识别image/video/audio并有Job/存储，但当前0.7只对真实图片消息闭环接受；其它音频/视频消息必须核APP真实捕获/上传→媒体处理→消息附件→当前授权下载→重启及撤权拒绝。若旧版实际有但本版需新增依赖，单列许可/编解码/设备权限；不存在的类型不伪造已恢复。现有消息通知R1隐私最小化必须保留。

### 作为其它主要功能的并列收口，不偷渡为已授权

- **A07完整紫微与西占**：在0.9版前**只给出可核验算法oracle、输入签名、时区/坐标、许可证与最小隔离运行路线**。当前`config/ziwei.php`默认off且仍可fail-open至种子路径，完整排盘真实性未被接受；`config/astrology_dependency_gate.php`将Swiss/pyswisseph/Kerykeion默认blocked，不能通过research_mode或导入旧Python文件默许生产商业用途。若Owner批准合规引擎路线，可在同一0.9功能版组合实现或安排紧接着的完整A07恢复包；**未获许可时不运行被阻止的高精依赖，不把seed/CRC/估计输出当oracle**。
- **A08 Buddy/Social**：当前`buddy_companion_page.dart`直接读取`_mockCandidates`且需求卡标本地/mock，举报仅展示；现行和已核旧具名页面不能证明真实线上业务已有完整原实现。应在具名来源范围内一次判定已实现功能与需要Owner批准的新产品业务；不能因为旧MVP Later标签静默取消，但也不能凭愿望将整个新社交系统写成已存在能力。
- **地图/系统Push/真实SMS**：手工出生地点/坐标与站内通知目前可用作无第三方替代，但不能称地图搜索、FCM/APNs或SMS投递恢复；若确在选定原版恢复基线，必须在后续功能交付前选具名服务、配额、最小权限及成本上限。
- **A03历史记录及附件**：当前备份内容/可恢复范围UNKNOWN，不触碰原SQL gzip/VHDX/真实用户；以后在Owner批准具名副本和脱敏用途后做隔离恢复，不把空开发库当原历史资料恢复。

### 原路线v10.0.9联合验收怎么保留

推荐将当前暂定的`v10.0.9联合验收`推迟到主要用户恢复工作包之后（可在v10.0.10或新增功能迭代中具名安排），同时每个功能版自身均做真实APP/Web/DB/任务/重启验收，不等待最后才联调。版本编号和实际内测窗口是不同概念，后续集成和材料不能取代缺失用户功能。本建议仅是版前排程，**最终范围和任何费用/许可由Owner决定，未得到Owner决定不修改已批准目标**。

## 四、一次性具名可行性收敛（仅必要技术与决策，不另开只读考古版本）

在同一次有限任务中，Codex基于**集成后的实际main**与现有v10.0.7可行性报告第A06/A07/A08节、当前恢复台账及具名源码完成一份`docs/versions/v10.0.9/FEASIBILITY_RECOMMENDATION.md`：

1. **主链方案**：列出RTC真实源/APP入口/信令/SFU、Android宿主权限、双端设备、网络端口/UDP/ICE/TURN和Media/Conversation/LiveConsent的具体差异；明确当前JWT可否在撤销或结束后继续入房及最小失效策略。给出一个可在本地受控运行、真实媒体可测的推荐部署方案；如需要新镜像、服务、端口和外联则具体列Owner授权，不实际启动。
2. **旧媒体**：一次列具名已实现类型、APP输入入口、后端处理与用户权控，区分已经0.7通过的图片、其它可直接恢复的语音/视频消息及仍无旧实现/UNKNOWN；推荐与RTC同版可行组合，不把仅有media_type字段当功能。
3. **算法路线**：给出紫微与西占各自原版来源、当前seed/legacy与可独立验证的引擎/测试oracle、许可证决策、明确的可信结果与不可信降级边界；许可证被禁止时只读审查，不安装/调用外部依赖。是否能将某段合规可实现的紫微算法与本版RTC并行恢复，须以真实工程依赖说明。
4. **Buddy/Social/地图/Push**：只核具有明确来源和恢复台账记录的既有功能，明确是否为新业务及最小Owner决策；将未实现的新设想与原版既有功能分开。不要重复把整个D:/EliteSync或全部SQL/VHDX做广域考古。
5. **冻结建议**：明确提出v10.0.9应该仅含RTC＋哪些已实现媒体及相关权限，或经过合法许可决定后是否可另含A07真实算法链；给出6～8个*候选*AC（真实双设备/APP/SFU/HTTP/DB及负例、final build/install、重启/断线），未冻结不得当正式验收。对后续算法、Buddy及完整联合验收给具名排程，不宣称已获Owner取舍。
6. **复用/隔离**：用已接受的0.8产品源码、现有Flutter/Android及Laravel锁定依赖；本版正式获准后才另建独立0.9 MariaDB、容器、持久volume/媒体区与虚构用户，不覆盖0.6、0.7、0.8验收卷、原dirty根和原3306。Web/APP同库受控真实链必测，任何“本地服务”不能借口改生产JWT/全局安全门或读取真实账号。
7. **发布回执**：以固定report GitHub Commit/Blob、实际产品代码main/tree、具名来源、未运行事项、明确Owner待决事项一次集中回报；无需实时监督、逐项审批、另建worktree或再做知识图谱/全部文档审计。

本版前阶段只有具名源码/公开证据**只读核查和安全Markdown文档发布授权**；**不授权**拉取/启动LiveKit容器、开放新UDP端口、安装Node/Python高精算法依赖、改产品业务代码、建0.9库、运行APP/两端媒体、改原release数据库、额外设备wipe或系统级提权。普通联网用于GitHub审查不等于外部SFU/SMS/API业务访问许可。

## 五、仅需Owner后续集中决定的问题

A. **下版优先级**：是否同意优先以“RTC真实双端＋旧可恢复媒体”取代原暂定0.9单纯联合验收，完整联验与最终软件包排在核心功能收口之后；本提案强烈推荐是。

B. **RTC测试设施**：优先本地自托管受控SFU（若实际代码/网络可行），而不是付费第三方。正式实施前需允许特定版本的官方Docker镜像、孤立本地端口/必要UDP、第二专用测试端及短期虚构JWT；绝不默认开放云生产RTC或使用真实个人音视频。

C. **算法许可与新业务**：完整紫微/西占如需iztro/Kerykeion/Swiss或商业许可、以及Buddy/Social是否作为新业务完整实现，待具名来源和技术/合规建议后一并由Owner明确；**暂不批准任何许可证绕过或购买**。无决策只暂停风险子功能，不影响可执行RTC/媒体等其它已授权工作。

**终点：V10.0.9 PREPLAN_READY — SCOPED FEASIBILITY PENDING — NO IMPLEMENTATION DISPATCH。**
