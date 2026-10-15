# EliteSync-v10｜APP恢复与Web管理功能台账

2026-10-15 R1更新：A06/A08消息通知已补服务端最小存储/旧通知通用投影及当前MC导航门，真实block/revoke/禁用反例见[R1报告](../versions/v10.0.7/R1_EXECUTION_REPORT.md)。R1源码锚d3fa5f2，初始成功链/原数据保留；仍为候选待Astra终验。未恢复功能和后续版本位置不变。


## 2026-10-15 v10.0.7候选实测更新（独立验收待定）

源码锚 `7f8da6954db8ef994f91e586c8a4f91fa0bc0a4f`；真实链及固定原证见[集中报告](../versions/v10.0.7/EXECUTION_REPORT.md)、[manifest](../versions/v10.0.7/manifest.json)。本节覆盖下文旧0.7 NOT_IMPLEMENTED时点，**不将候选自验升为已独立验收**。全量Flutter6失败/analyze3 info保留。

| ID | 本版真实开发恢复结果 | 保留缺口/后续位置 |
|---|---|---|
| A01/A02 | 最终源码AAR/debug APK安装；隔离MariaDB58迁移，157源题/137 enabled/20研究inactive；真实服务及联合重启 | 原业务备份仍UNKNOWN，非生产部署；包LOCAL_ONLY |
| A04 | 登录、完整出生/城市资料、canonical问卷20题、服务端draft/attempt版本、APP重启/重登续填 | 真实SMS/历史账号内容未运行；旧readiness只读summary尚未接在线权威，不授予权限 |
| A05 | 实际MatchingRun consumer/fence/重试/发布、APP current/history；持久CN独立请求/接受/拒绝/撤回，MC另行双方决定 | 完整后台运营UI留0.8；Match/Connection/MC/Relationship不合并 |
| A06 | 七条消息HTTP仅本版local当前许可；双账号文字、列表/未读已读、私有图片上传处理关联下载；block/revoke并发及禁用拒绝 | HTTP拉取；RTC双端、WebSocket、视频/语音附件留0.8及后续具名用户恢复包，不能称已完成 |
| A07 | lunar本地真实八字输入/版本/来源/降级/跨日；APP可选MBTI ENFP attempt读回；MBTI人格不排序；排除算法权重0 | 完整紫微/西占引擎、oracle/许可/时间地理源后续具名决定；原seed/估计不冒真实排盘 |
| A08 | APP动态发布/点赞/作者soft-delete、非作者拒绝；真实消息/匹配事件通知及read_at；本地主题/性能重进保留 | Buddy/Social真业务、地图、OS Push/SMS和云同步未恢复，按plan第3节保留在后续用户恢复包，非永久删除 |
| A09 | 原APP同账号/双账号、Laravel/数据库重启、权限正反例及最终包hash留证 | 全APP/生产/跨设备/所有历史功能仍NOT_RUN，0.9/0.10联合验收及说明未派发 |
| B01/B04 | 既有Blade实际禁用Bob及撤销旧凭据；admin matching HTTP→实际consumer回归 | 不冒完整Web后台恢复；0.8独立Web管理方向保留但未启动 |

原3306、SQL gzip/VHDX及真实账号/生产未访问；0.6验收卷未修改/重seed，原dirty根保持。后续版本须Owner新派发，Astra终验前不合并候选。

## 以下为先前调查时点

2026-10-15更新：v10.0.6 **ACCEPT WITH OBSERVATIONS**，已完成[K08](../versions/v10.0.6/integration.md)，产品commit `78aba03a68cb5dcc0302ea7e9c20ff783f5169d5` / Tree `c027d70c37b353d3e37c3570b23f673c1033dd0f`。当前单份台账继续维护，具名源码链、旧来源Blob、推荐组合/AC及少数决定见[v10.0.7版前建议](../versions/v10.0.7/FEASIBILITY_RECOMMENDATION.md)。**0.7 NOT_FROZEN / NOT_IMPLEMENTED**；以下初始口径中的待定位/未证明不覆盖本次限域更新，其余未知保留。

已核旧源码来源为D:/EliteSync HEAD `0f06e895a89629a7f4f0cf0c62b784446ecf515a`的具名题库/算法/客户端文件，源码存在与运行完成分开；未选定或实测整个旧APP。新功能均RUNTIME_NOT_RUN；数据库备份内容和原3306继续保护。

2026-10-14初始化。唯一用途：逐项对应“原版功能→现有前端/后端/数据库→恢复结果→实际验收”。依据[当前路线图](ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)；本页不是完整软件已恢复的声明，也不新增治理任务。

## 基线与证据口径

- 选定的原版恢复基线（版本/源码位置/可用包）：待v10.0.6内实际定位，当前UNKNOWN。不从聊天记忆编造版本，不为此独立启动全仓考古。
- 已有v10主线核查点：db1300bb19182f2de46b4ff5b1f7d9b947907b69。v10.0.0～v10.0.5限定接受可复用，不等于下表端到端恢复完成。
- 数据备份文件/时间/可恢复范围/附件来源：当前未实读，UNKNOWN；结构迁移成功与历史数据恢复是不同事实。
- 独立Web管理方向已批准；具体实现框架、管理员认证配置、开发环境在v10.0.6按实际资产确定，不假设已有独立Web应用。
- 状态可用：来源待核、已有代码待联通、开发环境已联通待验收、已恢复并验收、具体阻塞、Owner明确排除。组件历史ACCEPT另列证据，不自动把整行升为“已恢复”。
- 后续只增改实际涉及的行，记录具名源码/提交、API、表/迁移和一项实际验证入口。未经选定或未实现的旧设想不计入“原版必恢复”；已在恢复基线内的功能不得仅因旧MVP标Later而删除。

## A. APP、服务与数据库

| ID | 功能组 | 已知源码线索（不证明运行） | 本轮可确认状态 | 恢复完成的可观察结果 | 建议交付包 |
|---|---|---|---|---|---|
| A01 | APP安装/后端运行基线 | apps/android、apps/flutter_elitesync_module、services/backend-laravel | 0.6宿主/AAR/APK→实际Laravel→MariaDB城市链已限域验收，K08接续；全APP未证 | 指定Android包可安装，实际连接受控后端并完成一条真实业务读写 | v10.0.6 |
| A02 | 数据库结构/基础数据 | backend-laravel内migrations及配置；旧交接有本地MariaDB迁移历史 | 0.6专用库57迁移/3虚构账号已限域验收；当前题库源缺失，问卷与匹配需补 | 独立目标库结构及必要字典/题库可用，与当前服务匹配 | v10.0.6起 |
| A03 | 历史业务数据/附件恢复 | 具名备份和媒体原件待定位，不能只凭旧备份计划 | UNKNOWN，尚未读取备份 | 从获准副本导入隔离目标库，核必要记录/关联/媒体引用；缺失单列，原件不动 | v10.0.6起，联合验收收口 |
| A04 | 账户/资料/问卷 | routes/api.php的auth、profile、questionnaire及对应Flutter功能 | 城市/禁用链已验收；完整资料和问卷有HTTP/持久代码，题库需从固定旧资产恢复 | 开发账号登录、资料编辑、问卷保存/恢复经过后端实际持久化，重进仍正确 | v10.0.6～7 |
| A05 | 匹配/连接及必要任务 | matches、match-rounds、既有Matching服务/领域代码；前版有synthetic接受 | 真实MatchingRun/consumer/engine存在但未运行；Connection主要synthetic合同，live writer未接 | 开发账号匹配流程、独立连接同意、结果保存/失败行为与APP一致 | v10.0.7 |
| A06 | 交流/消息/媒体/RTC | conversations、messages、media、rtc路由和客户端资产 | 7条HTTP固定404保留；底层消息/media有实现，独立Connection+消息同意未接HTTP；RTC缺服务/第二端 | 所选原版能力在指定开发环境实际通信/存储；合法访问成功、越权拒绝，非两端mock | v10.0.7～9 |
| A07 | 原版特色算法/解释 | mbti、astro summary/chart/pair等路由及历史算法资产 | 八字有本地lunar计算；MBTI业务关闭/UI历史展示；紫微默认seed未校验，西占legacy估计且Python服务未入树 | 所选既有算法可执行、APP有结果与限制说明，算法文档对应实际代码；不默认推迟到Phase 2 | v10.0.7～10 |
| A08 | 通知/动态/设置等原功能 | notifications、status、home/discover、app/version路由 | Status/站内通知有API与表未运行；设置本地，Buddy/Social具名旧页亦mock/静态；地图/push依赖待决定 | 恢复基线内功能实际读写/投递或明确受支持方式，UI与后端一致；非原版设想另列后期 | v10.0.7～9 |
| A09 | 持久化/重启/异常与软件材料 | 前版限域回归和已接受状态/路由修复可复用 | 0.6城市/禁用重启已限域验收并保留；0.7及全APP联合运行NOT_RUN | 关键状态与用户操作重启后正确，错误可恢复；安装/部署/算法/数据与使用说明匹配最终包 | v10.0.9～10 |

代码线索来源：[当前API路由](../../services/backend-laravel/routes/api.php)、[历史迁移完成记录](https://github.com/zcx369658780/EliteSync-v10/blob/db1300bb19182f2de46b4ff5b1f7d9b947907b69/docs/ELITESYNC_V10_ARCHITECTURE_RESET_HANDOFF.md)。源码存在只作为复用线索，必须在实施中补实测结果。

## B. 独立Web管理面板

| ID | 模块 | 已知复用线索 | 当前恢复状态 | 完成行为 | 建议交付包 |
|---|---|---|---|---|---|
| B01 | 管理端入口/登录/用户管理 | Flutter AdminDashboard/AdminUsers；AdminController、admin/users等路由 | 0.6独立Blade登录/查询/禁用及APP失效已限域验收，K08已集成；其它管理模块不追认 | Web管理员登录、查询并对开发测试账号完成一项现有操作，APP显示数据库实际结果；普通用户不能管理 | v10.0.6首个闭环，v10.0.8补齐 |
| B02 | 验证审核 | Flutter AdminVerification；verify-queue、verify/{uid} | 页面/API线索已存在，Web操作未证 | 待审列表→具名决定→结果入库→APP状态更新；不发明身份资格政策 | v10.0.8 |
| B03 | 举报/内容处理 | AdminModeration、AdminReportDetail、reports/action | 页面/API线索已存在，Web闭环未证 | 处理记录与结果可查询，作用于实际恢复功能；只访问管理所需内容，不无限制浏览私聊 | v10.0.8～9 |
| B04 | 匹配运营 | AdminMatchingController及MatchingRound/Run服务 | 存在prepare/execute/reveal/retry/close；执行consumer未必已配置 | 轮次创建→实际执行任务→公布/失败重试/关闭→用户APP反映；不是只生成待办记录 | v10.0.8～9 |
| B05 | 问卷运营 | questionnaire quality-stats/prune等已有路由 | 原版管理范围和操作效果待核 | 已选管理功能可操作并持久化，与用户问卷读取一致 | v10.0.8 |
| B06 | 版本/通知/必要配置 | 现有APP对应接口和管理需求线索 | 管理API/面板具体覆盖UNKNOWN | 对实际恢复范围需要管理的项有可用入口；没有后端实现时明确补齐，不伪造可操作按钮 | v10.0.8～10 |

复用依据：[Flutter现有管理代码](../../apps/flutter_elitesync_module/lib/features/admin/)、[AdminMatchingController](../../services/backend-laravel/app/Http/Controllers/Api/V1/AdminMatchingController.php)、[管理路由](../../services/backend-laravel/routes/api.php)。Web框架和全部模块的运行状态都尚未完成本轮实测。

## 更新规则

本轮仅初始化已知事实，不运行服务、不导入数据库、不填造备份/功能通过率。v10.0.6内部直接补齐选定来源并推进真实恢复。每行的完成证据应能落到固定代码版本和可重放用户/管理员操作；可将较大日志保持本地，仅发布必要安全摘要并标明可访问性。某项缺源/需产品取舍时仅阻塞该项，未完成清单必须显式交付，不能静默从范围移除。
