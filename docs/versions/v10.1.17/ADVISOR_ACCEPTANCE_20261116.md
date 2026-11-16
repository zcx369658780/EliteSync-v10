# v10.1.17 B3 独立顾问验收报告

日期：2026-11-16（北京时间）  
结论：`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`  
R1：`NOT_REQUIRED` · R2：`NOT_REQUIRED`

## 一、固定验收身份

- 仓库：`zcx369658780/EliteSync-v10`
- 任务分支：`codex/v10.1.17-low-operation-cost-journey-integration-20261116`
- 唯一父基线：`99a05c6f6d509c0607d8bff0d63b122d5cc84eec`
- 固定工程交付提交：`93cb9e4db01ed5262d100f5982b5e01bf4799015`
- 最终产品源码提交：`1953582093d3469a48cd7275864309cb09eb0e53`
- 候选：`10.1.17-dev / 1011703`
- applicationId：`com.elitesync.v1017dev`
- ABI / build：`arm64-v8a / source-debug`
- APK SHA256：`729be2af7d215f4701c49e494d1767e59d350b1aee5bf83ecb553910f050f8ea`
- 签名证书 SHA256：`7c023c0fbdab8cd4f53daedbc95badb47d5f968b2c267d94fa695655f391bd42`
- 安装候选 SHA256与APK SHA256一致（工程manifest记录）。
- 任务分支HEAD与固定工程交付提交一致；相对唯一父基线10 commits ahead、0 behind。
- 产品源码提交与最终交付文档提交分离。源码提交之后的三个提交只增加实施报告、manifest、操作成本对比、路由地图、证据摘要、截图清单和工作流文档，没有再修改产品源码。
- 最终分支、提交及13份关键交付文件已从GitHub远端读取核对。

## 二、总体结论

`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`

v10.1.17 / V3.0 B3的八项AC均在各自具名工程范围内通过顾问验收。B3实现了以用户目标为中心的Home / Progress / Messages / Me整合；复用B2状态聚合和既有业务服务；保留四个底部主入口；没有合并Match、Connection、Messaging Consent、Conversation与Relationship状态机；没有增加运行时AI、外部身份/信用/Push/支付服务或无限Feed。

本轮独立源码复核和九张模拟器截图视觉复核未发现已确认的P1/P2产品阻断问题。无需R1或R2。

本结论不等于Owner整体实机接受、正式发布或main集成。Owner整体实机验收现已达到原定时点：B1+B2+B3均已完成，仍待Owner在真实手机上统一执行。

## 三、八项AC最终评估

| AC | 顾问结论 | 依据 |
|---|---|---|
| AC17-01 当前旅程与操作成本审计 | ACCEPTED_IN_NAMED_SCOPE | 20份路线/任务文档同步回读；编码前四份审计材料完成；九项真实模拟器基线在产品源码修改前冻结 |
| AC17-02 信息架构与导航 | ACCEPTED_IN_NAMED_SCOPE | 四个底部入口保留；默认冷启动进入Home；旧别名、typed chat、通知及受限Buddy路由有具名回归 |
| AC17-03 Home | ACCEPTED_IN_NAMED_SCOPE | 读取B2 `/user-state`；校验contract_version和subject_user_id；只映射服务端首个既有next_action；未知code不推断替代动作 |
| AC17-04 Progress | ACCEPTED_IN_NAMED_SCOPE | 准备、Lifestyle、参与、自动化、轮次、提案、CN、MC、Conversation及Relationship分开呈现；读取失败保持未知；会话进入重新核验 |
| AC17-05 Messages | ACCEPTED_IN_NAMED_SCOPE | 消息列表有独立站内通知入口；通知与聊天分开计数/已读；通知返回会话前做当前权限预检 |
| AC17-06 Me | ACCEPTED_IN_NAMED_SCOPE | 资料/偏好、隐私/账号、可选工具、参与记录按目的分组；私密资料与展示资料直达既有编辑器；状态自动化链接同一规范页 |
| AC17-07 交互与权限 | ACCEPTED_IN_NAMED_SCOPE | Lifestyle改选后可直达保存摘要；账号隔离、revision、幂等、授权和受众确认合同保留；未改变OS权限请求策略 |
| AC17-08 联合验证与交付 | ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS | 九项成本前后测量；213项唯一Widget case、23项兼容构建case、11个Dart文件分析、50项PHP case、13项隔离HTTP、9项APP旅程；候选身份核对 |

## 四、操作成本独立复核

冻结基线使用保留的1011601候选；后测使用1011703。相同模拟器、屏幕配置、虚构账号和逻辑初始状态，按同一计数合同比较：

- 总动作：53 → 35，减少33.96%（报告四舍五入为34.0%）。
- 减少至少一个不必要页面跳转：6/9，达到冻结目标。
- 总动作减少至少20%：5/9，达到冻结目标。
- J1理解当前状态与下一步：2 → 0，Home首屏直接显示。
- J3修改已有偏好：8 → 4，修改后直接回已保存摘要。
- J5提案独立选择：6 → 2，Progress直接呈现当前提案及明确决定。
- J6连接、消息许可与有权会话：3 → 2，仍保持CN/MC分别确认和会话权限复核。
- J7 Buddy保持单步；J8仍保留标题、正文、受众选择及明确发布；J4保留授权确认及暂停/恢复/撤销。

J4原编码前OFF基线保留；另在1011601从REVOKED状态补测，与1011703的REVOKED起始状态对齐，均为7动作。J8最初SELF受众试做不计入结果，原失败保留，随后以明确FRIENDS受众完成重测。J9目标为到达可选工具中心，基线隔离服务开关缺失导致的410保留；候选服务配置修复后中心及API可读。上述调整均在对比材料中说明，没有覆盖原始失败记录。

原Windows CRLF序列化基线汇总文件已恢复，并与编码前冻结SHA256 `43dcbab6e79f30138f05ba646639dfdc18972d87aea407659d2ff55a70a1ee0d`完全一致；九项原动作数据与独立UI起止回执一致。初次LF重建失败诊断也保留。

## 五、代码与权限边界审查

独立复核的重点源码包括：

- `JourneyOverviewPage`：B2状态读取、账号身份校验、未知状态、路由/前后台重读、提案决定、CN/MC/Conversation分域；
- `AppRouter` / `AppShell`：四入口、冷启动、深链、旧路由和权限redirect；
- `MeLandingPage` / `MePurposePages`：私密资料、展示资料、匹配输入、Lifestyle和可选工具的规范入口；
- `UserStatePage`：B2自动化授权仍需明确授权，暂停/撤销只影响已委托参与；
- `LiveConversationListPage`：通知入口与会话访问控制；
- 相关Widget测试、通知导航测试及PHP消息/同意fixture。

核对结果：
1. Home没有复制资格或匹配真相；B2 user-state的subject不匹配时拒绝展示。
2. 未知next_action不推断替代动作；切号、后台和路由离开时旧投影失效。
3. Progress展示Match、Connection、Messaging Consent、Conversation和Relationship独立状态。
4. 当前提案的接受/拒绝/撤回仍由用户明确触发；打开会话重新检查当前服务端权限。
5. Buddy仍独立于恋爱匹配；社区仍为有限好友场景。
6. B2状态与自动化只有一个规范控制页面；其他页面为上下文链接。
7. 私密资料和展示资料仍分离；分享和发布仍需用户明确行动。
8. 通知与聊天会话分别呈现和处理已读；没有自动发消息或新增Push。

产品后端服务、API、业务表和状态机没有变更。两处PHP变更限于测试fixture准备和显式消息ACK断言，不是生产服务修改。

## 六、验证与证据

交付材料记录：
- B3定向Widget：213项唯一case；默认构建兼容模式23项；
- 受影响Dart产品文件分析：11个；
- PHP唯一case：50项（B1/B2 35项、当前消息/同意15项）；
- 隔离MariaDB/真实HTTP：13项具名检查；
- 模拟器真实APP代表旅程：9项；
- 真实隔离数据库及账号A→B→D切换；
- 通知未读5→4，聊天已读合同独立；
- 自动化tick处理1项，结果`SKIPPED / ROUND_NOT_OPEN`，effect为0、matching_runs维持3；撤销后独立手动ACTIVE参与保持；
- 提案历史保持`MUTUALLY_ACCEPTED`，candidate_available=false时，既有CN_ACTIVE、MC_ACTIVE和有权会话不被客户端错误清除；
- 最终候选冷启动恢复当前登录并进入Home；
- 九张虚构模拟器截图已逐张视觉复核，未见真实用户出生资料或其他明显个人敏感数据。

私有原始日志和QA凭据保存在Owner本机。本顾问读取了GitHub结构化证据、manifest、报告、路由地图、操作成本逐动作回执、集成回执及九张截图；没有直接打开Owner本机私有原始日志，也没有在本会话重新运行全部测试。因此测试执行结论按交付具名证据接受，不表述为顾问重新执行。

## 七、历史失败、保留限制与NOT_RUN

### 已修复的候选/测试问题，原失败保留

- 1011701登录重定向后Home状态读取未启动；
- 1011702默认冷启动仍进入旧准备页；
- J8首次SELF受众试做未达到FRIENDS目标；
- 旧PHP fixture未满足现行准备合同、旧GET自动已读断言；
- 通知测试异步build fixture编译问题；
- 旧路由wrapper期望与本地构建门不匹配；
- 期限探针最初错误期望历史提案变为EXPIRED；
- 隔离运行环境、storage权限和UI启动等待诊断。

最终1011703已修复登录可见性和默认冷启动问题。原失败日志均按报告保留，不将其改写为从未发生。

### 仍未执行或未知

- Owner真实手机整体验收：PENDING；
- TalkBack、系统级权限矩阵、真实设备覆盖：NOT_RUN；
- 双实机、人耳听感及跨公网RTC：不属于本版验证，仍沿历史记录；
- v10.1.15图像模型精确名称/版本：UNKNOWN；
- v10.1.16首次数据库探测逐表摘要及历史status变化原因：UNKNOWN；
- v10.1.16十二项历史基线旧测试失败：继续保留；
- main集成、正式发布、真实运营：NOT_RUN。

新隔离B3 DB/API/WS运行环境与旧开发服务分离；旧开发DB/API/WS/SFU保持EXITED，模拟器已停止并保留数据。原开发库HEAD/index/差异保护状态按Codex报告与开工快照一致。未修改Owner手机。

## 八、最终顾问决定与下一步

`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`

- AC17-01至AC17-08：按各自具名范围接受；
- R1：NOT_REQUIRED；
- R2：NOT_REQUIRED；
- Owner整版/整体实机接受：PENDING；
- main集成/正式发布：NOT_RUN；
- B4和阶段C：未授权。

B1、B2、B3低操作成本主线现已全部完成，达到Owner原定整体实机验收时间点。建议Owner使用1011703候选及[Owner整体实机检查表](OWNER_DEVICE_CHECKLIST.md)统一检查真实手机、字体缩放、TalkBack、权限触发、消息/通知、冷启动和账号切换。不要把模拟器证据替代手机证据。

本顾问报告不授权B4、阶段C、main集成、正式发布或真实运营。下一阶段仍须Owner单独决定。
