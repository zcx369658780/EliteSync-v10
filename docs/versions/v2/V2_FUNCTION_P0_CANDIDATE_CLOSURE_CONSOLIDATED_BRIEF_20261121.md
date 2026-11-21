# EliteSync V2｜功能P0候选收口：单批集中工程任务（顾问建议）

2026-11-21。权限：依现有Owner[功能优先](../../decisions/OWNER_V2_FUNCTION_COMPLETENESS_BEFORE_SOFTWARE_COPYRIGHT_AND_CLOSED_BETA_20261121.md)和已授普通本地隔离工程职责，在**已确定产品范围**内允许Codex自治实现/自验；本文件不新增真实人/真实云/设备/收费供应商/正式内测许可。依据[上批顾问限定验收](../../workflow/V2_FUNCTION_COMPLETION_ADVISOR_SCOPED_ACCEPTANCE_20261121.md)及[固定报告](https://github.com/zcx369658780/EliteSync-v10/blob/3b42dfe4328fc2fe520cab1fe9561830fcb8ca56/docs/versions/v2/cloud-r0-20261121/V2_FUNCTION_COMPLETION_QUALITY_REPORT_20261121.md)。

## 0｜最短安全起点

- 原工程基线R0 `9baa82aa0cdf947dcc4996d2a584c92e4f4535f1` →本批源码 `63a2bbf24c4dff9b892ef94ba99dd34d0888f226` →交付报告`3b42dfe4328fc2fe520cab1fe9561830fcb8ca56`。实际唯一活动工作区root/origin/HEAD/dirty/index先核，保护脏main/S1/IP13I/治理树与原始证据，不盲reset、pull、删除。
- 继续使用本轮合法的`elitesync-v2-function`独立PHP8.4/MariaDB10.11/WSL Docker；重新核有效专属DB、卷和端口后只用虚构账户。云Staging/备份/真实管理员迁移和PC清理阶段已暂停，不重启。
- 单表状态追踪：`S01–S16 + G01–G10`与APP、API、Web、MariaDB、Android、Owner/外部法务门对应，不增加重复文档。要分清`CODEX_REPORTED`、固定源码核查、实际Android、真供应商与未跑。
- 在已确定的功能范围内只做针对性缺口修复和必要扩围；不删除旧测试、不通过永久模拟跳过KYC/用途/私密权利。

## 1｜四个P0收口流（按依赖优先）

### F1. 正式慢约与Relationship链：区分“代码功能”与“外部资格”

- 阅读当前真实Match/readiness/round/proposal/acceptance/Relationship/Connection状态机与API/Flutter入口，梳理从有效报名到发布候选、双边决策、可选Connection/消息同意、Relationship确认/退出与通知历史的**实际缺口**。报告之前的好友合成Connection PASS只证明它独立的一条文本链，不能推定正式匹配链PASS。
- 优先实现当前已定义的UI、API、DB、后台调度/审计及原快照保留；安全使用**仅本地独立实例、有效期和批次绑定**的测试资格覆盖成功与取消、过期、Block、重放及失权。真实KYC门保持fail-closed，不伪造已认证用户/官方验签；如果没有安全合成资格可用，则正向真实资格`BLOCKED_EXTERNAL`，完成代码和拒绝/状态可达性测试后继续其它P0。
- 禁止把正式Match、Relationship、Connection、MC、Conversation合并成一个状态，禁止通过`APP_ENV=local`或外部Header全局打开权限。关系构建和授信来源在审计中可区分。

### F2. Android当前版本具名功能实测（前置先审设备授权）

- 构建独立开发APK、固定源码commit、应用ID/版本/签名/安装APK SHA；原生`BuildConfig.API_BASE_URL`与Dart配置必须均指向本轮独立受控测试服务，且有可验证的**无回退旧云站**断言。网络/证书不可达时停在原因，不通过跳过TLS/信任链解决。
- 在Owner明确授权的**单台测试手机**上跑：首页与冷启动、账号A注册→偏好→资料→本命已知/未知时刻与历史、账号B切换、Connection→双向消息同意→文本消息→Block/撤权及旧深链、好友社区作品/评论受众、Buddy草稿/发现/申请/退出、站内通知；包含退出后缓存清理、网络不可达与后继恢复；当前版本不再借Q旧APK`1011804`记录作为新版本PASS。
- 未获得新设备使用/屏幕/媒体/辅助技术的具名Owner许可时，仅准备APK和不涉及设备的自动化，并记`DEVICE_OWNER_GATE`。不得使用真实人资料、误触生产账号或真实相机/RTC权限。

### F3. PHP旧12项和媒体/管理员正反收口

- 按同SDK/相同数据库前置将旧12条**每一条**的`class.method/assertion/error_signature/R0→当前`列入同一失败账；报告旧Web登录/续期500/401、旧Connection与通知夹具409属于高风险入口，不能以“原来也失败”就全部豁免。
- 每一条分为当前代码BUG、测试夹具缺资格、历史合同待决、运行环境差异；尽可能在不损害现行权限下补足可信用户与旧用例隔离资格；切勿删除测试或伪造HTTP200。新P0核心链出现实际回归必须修复或明确BLOCKED。
- 覆盖真实媒体正向：已存私有封面/头像（和许可范围内的附件/短视频）上传、大小/格式/权限、原受众、Block及历史深链字节；当前合成Connection只允许文本且附件被拒，**不得把它宣称媒体聊天通过**。若真实供应商/设备不具备，标明可运行安全分支和负例。
- Web后台以合成管理员做CSRF、session、审核/本人发布、举报、停用与审计；逐项明确配置与申诉等剩余P0，非本次必要能力进入P1而不是掩盖真实缺口。

### F4. 候选评审与软著资料增量准备

- 补充S01–S16/G01–G10最关键的2×字、返回、无障碍、导航、冷启动/切号/刷新与失权，按真实本轮证据计PASS，不追求无关全量用例数字“归零”。
- 软件著作权**准备**：选定候选版本/软件名称暂案，形成操作说明目录、可录屏/截图页面清单、需要对应的源码片段与版权/第三方许可核对表；真实权利主体、截图最终版本与正式登记需要Owner确认；不得声称登记成功。
- **封闭内测仍NO_GO直到**当前版具名主旅程与安全负例、可用的受控网络与服务、缺真实供应商明确降级、个人信息/用户告知渠道及Owner批准。不要以“功能开发阶段通过”自动推出开测资格。

## 2｜报告与质量证据

只交一次中文综合报告（固定非main提交+hash），包括：
1. 固定开发branch/源码/报告/可重建运行身份及与前批的compare；旧保护工作树状态；
2. 单表最新P0/P1分层：代码已完成、模拟具名PASS、真实设备PASS、外部依赖阻断四种证据不能混写；
3. 每一核心链`APP route→API status→MariaDB rows/revision→revoke→旧读拒绝`正反证据、命令exit/JUnit、私有日志SHA；当前APK身份；
4. 12条PHP旧失败逐项基线对照和本轮真实改善/剩余，不再只给总数；原Q全量46errors/122failures、旧盘25与Flutter扩围5继续据实际记账；
5. Owner两项独立产品取舍旧盘A/B/C、注册可信离线T0整理为一份紧凑决策建议，但未获选择前保持fail-closed；真实KYC/Push/RTC、法定删除受理、正式A6/原43PNG/F01保留真实状态；
6. 候选定版与软著材料清单，分开判断`LOCAL_FUNCTION_SCOPED_PASS`、`ANDROID_INTERNAL_CANDIDATE_READY`、`CLOSED_BETA_NO_GO/GO_PENDING_OWNER`，不合main、不启动真实内测或服务器迁移。

每日常规工程步骤Codex自治连续处理，出现不可逆Owner产品决定/真实人、设备、云、钱或法务门才停对应分支，避免分裂成多轮云端/G0b计划。
