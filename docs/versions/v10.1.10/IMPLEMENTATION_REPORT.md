# v10.1.10 工程实施报告

2026-11-14，北京时间。**ENGINEERING_PASS / ADVISOR_PENDING / OWNER_PENDING**。六项 AC 在本版约定开发范围内工程 PASS；这不表示独立算法精度、顾问接受、生产就绪或发布。集中交付后停止，不开始 v10.1.11。

## 身份与本地同步

- 稳定根：`D:\EliteSync-v10-product-v1015-20261101`；origin：`git@github.com:zcx369658780/EliteSync-v10.git`。
- 分支：`codex/v10.1.10-self-knowledge-specialty-tools-20261114`。
- 固定任务父基线：`8e74d1f7496f066a586afb1e5653ed563b64c46d`；任务文档提交：`ffbc2a3c2e03f7128e78a75eca108a114f9eb0c0`。
- 开工已保护原主库与稳定根状态；七份必要任务/Owner/工作流文档 Git Blob 与规范文本核对，`LOCAL_DOCS_SYNCED`：`2026-11-14T15:15:32.264946+08:00`。原主库不切分支、不覆盖。
- 后端源码：`b4ffe9df247f46f2f556e0394567bb1f2fc8e0cd`；最终 APP 源码：`0ffc8e4aaf942f50de7de77e046457e2b3ab6059`。其后仅文档/去敏证据交付，不改变候选源码。

## 最小盘点与补齐

路径以下按稳定根相对路径记，不递归考古。

| 模块 | 已有能力与实际断点 | 本版实现 |
| --- | --- | --- |
| MBTI | `MbtiProfileController`、`MbtiAttempt`、`mbti_center_page.dart` 已有配置计分与 latest；缺本人历史、固定 attempt 确认及未知结果的命令保护 | 有界历史/详情、提交 UUID 幂等与载荷校验；提交后读固定 attempt；同账号合法作答及未确认原命令保留，切号/权限代际隔离迟到响应 |
| 本命三盘 | `NatalProfileController`、`NatalCalculationService`、`UserNatalProfile` 已有真实计算、版本/CAS和当前保存；纠错会替换旧快照，APP缺历史入口 | 在原 owner/记录锁内归档旧输入/结果；本人只读历史，详情按原签名重验；历史与当前表单分开；高级参数折叠 |
| 动态盘/双人盘 | `DynamicChartController`、`DynamicChartService`、`UserDynamicChart` 已有五盘型和多记录；缺旧 revision 管理、确认删除及新建响应未知重试保障 | 旧版本历史、删除及历史清除；最小命令表防重复新建/修订，删除后旧 key 为410；APP冻结原 path/body/key，删除结果未知保留原 id |
| 输入/状态 | 既有时区、时间精度、地点、算法性别、盘型/参数与解释组件 | 保留合法输入；区分422/409/明确拒绝与网络未知；清失权结果/历史/可选项；旧账号或权限代际响应不得污染当前页 |

直接改动为三份 APP 页面、独立 `presentation/widgets/tool_revision_history.dart`、相关定向测试；后端新增 `ToolRevisionController`、`ToolRevisionHistory`、`UserToolRevision` 及迁移。完整22条变更路径在 manifest。没有确需后台管理的新业务，Web 本版未改。

沿用 `resources/natal/calculation-profile-registry.json`：Skyfield **1.55 / DE440s**、`6tail/lunar-php` **1.4.0**、iztro **2.5.8**及既有官方2.6.1特定数据修正。没有重建引擎、没有使用 Swiss Ephemeris。动态仍为 `synastry/comparison/transit/solar_return/lunar_return`；Comparison 是双盘对照，不是 Composite。`DynamicChartService` 仅放行新增 `request_key` 输入字段；该服务参与原签名，因此旧动态盘可能按既有机制显示 STALE 并要求重算，不能把旧结果误标当前有效。独立精度始终 **UNVERIFIED**。

## 六项 AC 与实际链

所有普通链使用既有虚构账号及真实 Laravel / MariaDB / 本地计算进程；无直接业务 SQL 写入、无受控成功响应。最终 APP 均为1011002，Android模拟器A用户11，包名与数据保留。API写入与APP写入分别记账。

| AC | 工程结果 | 普通运行证据 | 补充与限制 |
| --- | --- | --- | --- |
| AC10-01 MBTI | PASS | API创建attempt3、主动更新4；最终APP实际答三题并提交attempt6/INFP，读取本人历史attempt3；重登读回6 | 当前为 `lite3_v1` 简版配置计分，非完整标准题库、非诊断；与20题匹配问卷分离；运行匹配权重0。幂等/变载荷409、私有404、503重试/迟到响应为定向测试及具名API检查 |
| AC10-02 本人三盘 | PASS | 普通API先保存未知时间/缺地点的真实部分结果，再纠正时间与地点并调用三个现有引擎；最终APP将12:00改12:02，保存并重读输入/结果版本3，历史版本2仍12:00 | 未知时间不制造精确时刻；西洋UNKNOWN如实返回。时区Europe/London及America/New_York普通输入；DST gap/非法参数/计算故障由受控测试验证。独立精度UNVERIFIED |
| AC10-03 动态盘 | PASS | API创建行运id8并改到rev2；最终APP将事件15:01改15:02，保存rev3/结果rev3并读旧rev2 | 明确手填输入；当前/历史及参数分开。太阳/月亮回归最终APP逐盘型全矩阵NOT_RUN，计算器未变，本轮代表链为Transit |
| AC10-04 手填双人盘 | PASS | API手填Synastry id9；最终APP纠正第二盘13:00→13:02至rev2，读旧rev1；APP另建Comparison id11真实计算、确认删除，API详情/历史均404，DB无当前/历史行 | 保留id9供重登重读。另有API Comparison id10删除后原key重放410；他账号17读/删id9均404。未查找另一账号出生资料；不宣称Composite |
| AC10-05 持久化/纠错 | PASS | 当前MBTI6、本命3、行运8/rev3、Synastry9/rev2及五条归档真实落库；DB/API重启前后所有选定当前与历史API响应逐项相等；APP撤销当前设备会话→密码重登，读回MBTI及本命；force-stop冷启后读回Synastry及旧rev1 | 未删除数据/AVD。WS逻辑未变且未主动重启。开发DB/API重启属实际运行，不是夹具时间。最小删除命令墓碑只留key/hash/id/revision防复活 |
| AC10-06 解释/状态/参数 | PASS | 最终APP各普通页显示输入/结果版本、计算状态、来源与UNVERIFIED；未知输入普通API部分结果；当前结果和历史可独立读取，高级参数折叠 | 明确拒绝、离线/503、CAS冲突、失败重算、过期隐藏、空态、迟到响应以受控PHP/Widget补充；最终APP真实断网/故障注入NOT_RUN。全局UI/文案留1.12 |

## API与持久化

- MBTI：`GET /api/v1/profile/mbti/history[?before_id=…]`、`GET …/history/{id}`；submit可选 `request_key`，返回 `attempt_id`。
- 三盘：`GET /api/v1/profile/natal/history`及`/{archiveId}`。
- 动态：`GET /api/v1/profile/dynamic/{id}/history`及`/{archiveId}`；save支持可选原UUID；`DELETE /profile/dynamic/{id}`删除当前盘及历史。
- 历史每页至多20条，只列元数据；详情按当前 owner、当前许可及计算签名重验，过期隐藏旧结果，私有响应不缓存。
- 迁移 `2026_11_14_150000_add_private_tool_history` 已执行：MariaDB `10.11.19-MariaDB-ubu2204`，开发库 `elitesync_v10_1_5_dev`，migration id83 / batch9。新增 `user_tool_revisions`、`dynamic_chart_commands`，MBTI增加可空命令key/hash及用户内唯一约束。
- 后端继续既有 bind mount。十份改动后端运行文件已与稳定根物理SHA匹配，并记录Git Blob/LF摘要；后端重启后产品读回通过。没有重新创建环境或替换数据库volume。

## 验证与原失败

只统计最终互不重复的批次：

- PHP **21 tests / 173 assertions PASS**（PHP8.4.27，PHPUnit12.5.42）：`V10110ToolHistoryTest`、`V1010NatalApiTest`、`V1011DynamicChartApiTest`、`MbtiApiVersioningTest`。其中计算故障/签名失效/并发反例有mock，不能等同真实计算；真实计算另见普通链。
- Flutter **62项 PASS**：MBTI、动态页、三盘session guard、三盘review fixes及新增工具历史五份测试。涵盖先显示再403/404清理、503保留/原UUID载荷重试、422纠错、删除未知结果及旧代际迟到响应。
- 改动Dart分析：初轮九文件PASS，最终变化的MBTI两文件再分析PASS，其余七份按源码未变继承；不累计批次。
- Codex辅助非作者静态审查检查实现及最终MBTI增量，未报告可证阻断项；这是工程源码审查，不是外部顾问接受。
- 全库analyze本轮 **NOT_RUN**。v1.9原12项静态FAIL档案保留；本轮三份直接受影响旧Widget的session build签名已适配，不声称当前仍有精确12项或全部已清零。

保留的中间失败与处理：后端首批缺旧问卷seed，补挂现有`question_bank`后再跑；旧feature-off测试受开发环境开关影响，测试显式关闭配置后断言通过；MBTI新反例初次pump/viewport不足，修夹具后通过；明确拒绝保留同账号草稿的实际小修导致候选1011001递增1011002。APP首次安装/启动有Activity not found与启动等待超时，之后实际UI就绪；最终候选也曾等待超时后正常显示，精确瞬态原因 **UNKNOWN**。

UI自动化另有底部控件位置、键盘Back、历史详情在屏外、错误的列表键`items`（实际`charts`）、截图等待条件和私有工具默认文本编码失败；修正工具后按实际UI/API核对，没有把这些工具断言当作产品成功。三盘重登验证须经既有“星盘画像→三盘本命·输入与排盘”二级入口。DB重启就绪阶段一次连接重置，随后逐项相等读回通过。原日志与失败均留本机。

## 候选、资源与继承

最终 **10.1.10-dev / 1011002**，`com.elitesync.v1015dev`，source Debug arm64-v8a。APK **123898166 bytes**，SHA256 **`304f7f17dfe3b12d74fb1a9d2c48ac65c44d1a627b4ffec30a43edd552709b64`**；签名SHA256 **`7c023c0fbdab8cd4f53daedbc95badb47d5f968b2c267d94fa695655f391bd42`**。模拟器A安装包base.apk摘要匹配。复用现有稳定离线依赖及构建目录，首轮/最终仅同步5/2份源码，无SDK副本。中间1011001保留为历史候选，非最终交付。

资源实读 **2026-11-14T16:36:33.594739+08:00**：DB/API/WS/SFU running；模拟器A及本包已停止，AVD/用户11数据保留；B本版NOT_STARTED且原数据保留，手机NOT_USED；5038保持USB排除，A的reverse已移除。DB/API为本轮主动重启；SFU启动时间也发生变化，未对其精确触发原因作归因，本版SFU媒体 **NOT_RUN**，不把进程running当媒体成功。

v10.1.9按`8e74d1f…`顾问/Owner接受及R1 `a62b746…`的未变好友/社区/搭子/活动、权限与通知范围继承；v10.1.8 R1 `1074c210…`及call63/64仅继承已接受未变通信范围。本轮不重做通信/硬件全验。真实Push仍 **REAL_PUSH_PROVIDER_PENDING**，历史非注入SFU/RPC精确根因仍 **UNKNOWN**。算法独立精度UNVERIFIED；自然期限/未验硬件不升级。

原主库HEAD、status NUL流、diff与index SHA与开工保护回执一致；稳定根无关`%SystemDrive%/`保留。完整原证、APK、私有工具、凭据和数据库仅留本机。公开证据仅虚构数据截图与去敏摘要，见[EVIDENCE_SUMMARY](EVIDENCE_SUMMARY.json)及[manifest](artifact_manifest.json)。最终固定交付号以远端回读回执及交付回复为准，不将源码提交号冒充文档交付号。

待办仅为新顾问会话复核与Owner接受；不合main、不发布、不自动开下一版。
