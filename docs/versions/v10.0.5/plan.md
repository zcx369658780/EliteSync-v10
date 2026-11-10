# EliteSync-v10｜v10.0.5 正式冻结计划｜Progress 三阶段只读摘要与安全导航

> **FROZEN_PLAN / AWAITING_OWNER_MANUAL_DISPATCH / IMPLEMENTATION_NOT_STARTED**  
> 冻结日期：2026-10-14（Asia/Shanghai）。Owner已批准进入v10.0.5的规划；Astra结合Codex `V10.0.5 PLAN REVIEW — READY_WITH_FINDINGS — IMPLEMENTATION_NOT_AUTHORIZED`及GitHub源码复核冻结。**冻结并不等于实施授权**，Owner须手动把固定计划交给指定Codex并明确派发。
>
> **候选唯一代码父提交：`4a7091b580977044861ae50ff9b404842ed68283`，Tree：`79674652c6a39c66bdab5f2a86979741aa94d4bd`。** 本计划首次GitHub发布的固定commit/blob即最终冻结身份；不得为获得测试PASS事后改写目标或AC。
>
> **唯一开发切片**：在已有Progress页只读消费既有`calmHomeProjectionProvider`提供的**Readiness、Match、Connection三域摘要**，展示来源与有限状态，保留原Match/Connection入口，并提供到既有Readiness页的查看导航。不可从投影创造任何Match、Connection、Conversation或Relationship授权。

## 1. 接受资产、当前缺口及复用限制

- GitHub固定代码父时`main=4a7091...`。v10.0.0～v10.0.4均已按各自synthetic/dev-test有界验收、将必要代码定点集成并经Codex本地隔离基线有限回归；旧候选、失败原证及冻结AC保持不变。
- `apps/flutter_elitesync_module/lib/features/progress/presentation/pages/progress_page.dart` 当前Git Blob `8dd79b804c0d82a52eff5f876918d0f4673b2ed4`：静态`ProgressPage`、两个入口`progress-match-entry`和`progress-connection-entry`，分别导航`/progress/match`与`/progress/connection`；没有状态provider订阅或阶段摘要。这是本版唯一确证的用户可见增量，不重造下游Match/Connection页。
- 已存在`calm_home_projection_provider.dart` Blob `a07e0863573db74fd7705a4657cdedc3295ba91c`及`calm_home_projection.dart` Blob `b253b9f87990f9140d495ad6fa6a733b329842ac`：四域`HomeStateSummary`承载`domain/authority/stateCode/statusLabel`，本版只取**前三域**；Dev且`useSyntheticHomeProjection`为真时合成状态才参与，默认非Dev返回保守`CalmHomeProjection.current`。不得把`authoritativeNextDecision`/ `nextDecision`直接复用成Progress动作——它可指向Messages或Progress自身。
- **Match限界**：`CanonicalMatchLifecycleAdapter` 的`noRound/noCandidate`可得到`targetState=null`，但Home汇总仍可能标`syntheticDevelopment`、`stateCode=null`；没有逐项`presentationCondition`可供Progress推断详细原因。不能把空状态解释成成功、失败、不合格、completed、expired；Match loading/error/failed/closed在汇总中应保守显示`UNKNOWN`或“当前无法确认”，不可沿用历史正向代码，不另造availability oracle。
- **Connection限界**：Dev显式开关下`ConnectionPresentationController`可演示CN_ACTIVE、CN_PAUSED、CN_CLOSED等，只读汇总须跟随其变化；Readiness UNKNOWN不自动撤销Connection。Connection ACTIVE也不是独立消息同意或生产授权，不能显示“可聊天”。
- v10.0.3已接受真实GoRouter动态Guard刷新及合法路径保持，`app_router.dart` Blob `2eebd3f0959414f95e2a3ec61e94d73a2779d795`，相关测试Blob `6811828ffc8c2c37f752902d7f91513d6c5dc478`；APP-INT-05的Home synthetic主循环已接受。本版不重做Router/Home/Conversations/Guard，不将第四域Conversation作为Progress展示、消息入口或新权限。
- Codex已报告当前干净隔离基线`C:/Users/zcxve/.codex/worktrees/elitesync-main-d49c308/EliteSync-v10`，HEAD `d49c308...`，与冻结代码父仅有五份文档差异、没有产品源码差异；原`D:/EliteSync-v10` dirty main HEAD `4bebc8f...`、index `2be660...`、43 tracked/208 untracked和109具名保护仍需保全。旧脏root的`SyntheticRelationshipCard`为`LOCAL_ONLY_UNVERIFIED`，不纳入本版。
- 产品IA始终`Home | Progress | Messages | Me`；`Match != Connection != Conversation != Relationship`，`Projection != Permission`。BE-12七条live私信路由opaque404、V57/H1/H2/D0暂停/未签、`RuntimeReady=false`、`M6 CLOSED`等均保持，正式必需Readiness集合及身份/准入政策继续UNKNOWN。

## 2. 唯一可修改文件及行为合同

**MODIFY ONLY**：`apps/flutter_elitesync_module/lib/features/progress/presentation/pages/progress_page.dart`。
**CREATE ONLY**：`apps/flutter_elitesync_module/test/features/progress/presentation/pages/progress_page_test.dart`。
此外只可新增`docs/versions/v10.0.5/`下必要的安全运行收据、有限manifest、可选有界验证脚本与执行报告。不得修改任何其它产品源码或已有测试。

- 保留现有`ProgressPage`、两个入口的key/文案基础含义和原路由；可在同文件增加Progress私有只读展示辅助，使用`ref.watch(calmHomeProjectionProvider)`及现有`HomeStateSummary`事实，不新增第二套业务provider、独立聚合权威、score、缓存或持久状态。
- 页面清晰展示`Readiness/Match/Connection`三项状态和**来源类别**；普通非Dev/未开演示标志时只展示静态保守“来源未建立/状态尚未确认”，**不得订阅引发真实业务数据请求**或给出失败/不合格推断。Dev Synthetic阶段必须醒目标明演示/非正式事实/不代表权限。
- 一致性合同：可复用`HomeStateSummary.statusLabel`及标签映射；凡`authority=unknown/notYetEstablished`、`stateCode=null`或未获原合同明确解释的状态，不渲染成已确认进度/提案/成功。空Match代码不等于Match结果；详情交由既有Match页按自身权威展示。Dev Synthetic CN_PAUSED/CN_CLOSED替换旧ACTIVE；不能把关闭/失效翻成Safety或关系结论。
- 同一挂载下，受控Guard/Match Future/Connection synthetic controller连续变化时，摘要即时更新，旧positive stateCode不残留；返回Progress应显示最新快照。Readiness UNKNOWN不得自动修改Connection生命周期。
- 保留到Match/Connection两条原入口；可增一个独立“查看准备状态”入口至`AppRouteNames.meReadiness`，只读/导航，不创建新的许可或绕开`/progress/match`已有Guard。当Readiness未建立时实际点击Match仍应由原Guard重定向。Progress**不**复制Home可能到Messages的`nextDecision`；不得增加RTC/Relationship/Chat导航、关系推断或隐藏写动作。
- 视图兼容窄屏与文字放大、浮动Dock遮挡；只有已冻结范围内实际数据展示，不变更外部领域与Route配置。

## 3. 必需的限域运行与真实证据

- 新测试在真实`appRouterProvider + MaterialApp.router + StatefulShell/AppShell`下运行，使用完整Progress页面和实际Home/Readiness/Match/Connection目标页面；可以复用此前v10.0.3安全fixture/harness但**不可用stub Router代替**。
- 应观察：非Dev/关Home synthetic flag时的三域保守呈现及业务source不启动；显式Dev Synthetic的来源/状态三域同Home投影一致；`Match loading/error/failed/closed/noCandidate/noRound`无旧提案代码或编造原因；Connection `active → paused → closed`后旧ACTIVE显示消失；Readiness UNKNOWN不撤销既有Connection；同挂载切页/返回保持当前状态；Match在Readiness失效后由既有Guard引导到Me Readiness；窄屏/双倍字说明和入口真正可见、可点击。
- Flutter provider即使只用前三域，也会因重用`calmHomeProjectionProvider`**间接watch Conversation synthetic provider**。可以如实记录依赖，但不得发起Conversation writer、消息读取或call。Test fixture应隔离API/Dio/secure storage/remote Match/telemetry、内存storage、禁RTC watcher、stop warmup；`HttpOverrides.runZoned`必须先探针证明能拦截当前测试zone的HttpClient，再断言业务阶段`HTTP=0 / forbidden provider=0 / writes=0`。单独坏localhost URL不足以证明隔离。
- 最终在准确候选字节下运行**新Progress测试+与其真正相关的少量既有Home/Router/Connection测试**（由Codex具名选），两文件限定`dart analyze`；必须同时记录exit code及原始stdout，只有明确`No issues found!`且exit0才可宣称分析无issue。不要机械重跑旧PHP294、v10.0.3全部42或v10.0.4全部13，除非真实直接依赖要求。
- 保留初次失败→诊断→修复→最终真实命令/exit/stdout/stderr、Git源码/fixture身份、受控零调用计数及NOT_RUN。原始自动诊断日志只安全留存，GitHub发布前检查敏感路径/网络/凭据并标明脱敏副本与原流哈希，不篡改旧失败证据。
- 固定R1以外本版新候选必须直接**单父**起于`4a7091...`，保持独立branch/Tree，不自行整支merge；原dirty root、此前所有clean基线/旧候选HEAD/index/status及109保护前后仅核必要事实，禁止blind`pull/reset/rebase/clean/stash`、整包带入LOCAL_ONLY或删旧worktree。环境问题可范围内自主诊断/修复，越产品白名单则报告`BLOCKED_SCOPE_DECISION`。

## 4. 固定AC-01～AC-07

| AC | 独立验收PASS的必需事实 |
|---|---|
| AC-01 源身份/保护/去重 | 唯一候选父`4a7091b580977044861ae50ff9b404842ed68283`；核既有Home/Progress/Guard/Match/Connection及对应历史接受；原dirty/clean和109具名保护前后有可读本地回执，未携入LOCAL_ONLY/旧拒绝内容。 |
| AC-02 Progress实际UI消费者 | 真实Progress读取既有Home三域摘要、展示有限来源/状态与必要安全说明；Match/Connection入口及key不变，Ready只作只读详情导航，未新增独立来源/领域写入或消息入口。 |
| AC-03 失败关闭与动态清除 | 非Dev/开关关闭保守；Dev明确Synthetic；Match状态空/unknown/loading/error/failed/closed/noCandidate/noRound不会生成详细结果/完成/失败推断；Connection pause/close替换旧ACTIVE，Readiness未知不改Connection，不出现聊天/关系许可。 |
| AC-04 真实路由与受控安全 | 真实Router/AppShell下同次挂载状态切换、切页/返回、既有Match Guard拒绝、三个详情/兼容入口、窄屏和字体放大有UI断言；受控HTTP/API/存储/遥测哨兵有效且所有真实操作计数0，RTC/真实消息关闭。 |
| AC-05 实际范围回归 | 最终候选下新Progress测试及直接相关旧测试exit0、原失败链保留；两文件dart analyze实际stdout `No issues found!`且exit0。若任何不可隔离/未运行，明确PARTIAL/NOT_RUN，不为达标削减冻结行为。 |
| AC-06 固定GitHub证据 | 独立候选Git commit/tree/唯一父、精确两产品路径及版本证据、有限manifest、运行原始/脱敏收据可从固定commit核对，旧源/业务/权限保护不越界。 |
| AC-07 Astra终验/安全后继 | 只有Astra独立AC裁决后才记录Acceptance；GitHub两个已接受对象的定点集成、由Owner手动交Codex建隔离本地新基线、集成后限定重测四种状态分别登记。未自动启动v10.0.6。 |

## 5. 权限、排除与人工派发

本版不构建正式Readiness源、身份/地区准入或具名必需条件，不修改`calmHomeProjectionProvider`、`calm_home_projection.dart`、`app_router.dart`、NavigationGuard、Match/Connection/Conversation/Chat controller、后端/API/权限、M5设备链及旧APP-INT-05。发现必须改白名单外代码才能通过时只报告具体障碍，**不能为了凑绿灯扩写范围或放宽AC**。

禁止真实服务/用户数据/生产DB/API/SSH、部署/Android安装/Release、下载/升级SDK或依赖、UAC、Safety Operations；BE-12 opaque404，V57/H1/H2/D0、M6及未签路径继续关闭。

**执行门**：Astra首次发布此冻结文档后停止；Owner再手动派发固定commit/blob明确授权Codex实施。Codex在白名单内可自主编码、普通修复、测试/重测，完成固定候选后停止等Astra独立终验。验收后依已授权K08做安全定点集成+人工接续本地隔离基线；不自动启动新版本。

**`V10.0.5 FROZEN — PROGRESS_THREE_STAGE_READONLY_CONSUMER_AND_SAFE_NAVIGATION — AWAITING_OWNER_MANUAL_DISPATCH`**
