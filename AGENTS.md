# EliteSync-v10 工程约定

生效：2026-11-15。当前版本依据[Owner接受v10.1.12顾问范围并授权v10.1.13](docs/decisions/OWNER_V10_1_12_ADVISOR_ACCEPTANCE_AND_V10_1_13_AUTHORIZATION_20261115.md)，普通工程自治与简化验证沿用[11月10日决定](docs/decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。历史事实及已耗记录不重写。

## 产品目标

EliteSync是Relationship Decision Support System。保持Home / Progress / Messages / Me主入口；Match、Connection、Messaging Consent、Conversation、Relationship保持独立语义。产品功能、真实持久化、可理解体验优先，不做AI关系判官、安全权威或参与度最大化系统。整个v10不安排公司、内测、运营或正式发布。

v10.1.12集中UI版本已获顾问具名范围接受，R1-01 CLOSED。R1源码尚未进入安装候选；原1011204只绑定旧源码，不能声称包含R1。Owner整版接受状态继续按ACTIVE_STATE记录，不与顾问接受混淆。

## 当前执行范围

执行[v10.1.13任务](docs/versions/v10.1.13/task_order.md)、[计划](docs/versions/v10.1.13/plan.md)和[启动Prompt](docs/versions/v10.1.13/CODEX_START_PROMPT.txt)。本版是全局集成与关键旅程可靠性收口：R1源码候选、模拟器真实TalkBack、关键导航/已实现深链、APP受控结果未知恢复、虚构开发环境API/DB重启持久性和有限联合回归。不新增大型业务、不重写后端业务模型或权限合同。

任务分支：`codex/v10.1.13-integration-reliability-20261115`；唯一父基线：`ffddf23dd07743538c43ef8f9a6dd7f1ff580467`。R1 APP源码：`3e0e75758acf81e1ea754f739c9687226fbfcaff`。原1011204仅绑定`ac7fb5b28396394e58c72002e19cc9bbad805941`。GitHub发布不代表本地同步，Codex先核实际工程并保护dirty/index。

## 自主执行与验证

Owner负责方向和重大不可逆决定；顾问按要求独立验收；Codex负责拆解、实现、调试、必要测试、工程审查和常规Git。在授权范围内连续完成工作，不逐动作申请。普通可恢复错误自主修复；超出手机、真实用户/生产数据、外部供应商/费用、main或正式发布边界时停止受影响动作。

仅做受影响代码分析和本版AC定向验证，不重跑全部历史AC。真实APP/API/DB/Web链、Widget、TalkBack实际服务会话、受控故障注入、API/DB重启分开记账。NOT_RUN/UNKNOWN/UNVERIFIED如实保留。文档整理不构建APK、不启动服务。

## 资产与权限

保护原D:\\EliteSync-v10及当前稳定目录未提交成果、index、私有配置、数据库、AVD、APK、凭据和原始证据。不盲pull/reset/rebase/stash/clean/prune，不force push，不夹带无关内容。GitHub远端不等于本地资产备份。

普通开发、必要定向测试、Debug APK、本机独立开发服务、虚构数据、必要双模拟器及常规Git沿Owner长期授权。不操作Owner手机，不访问真实用户或生产数据，不接新供应商/付费服务，不合main、不正式发布、不开展公司/内测/运营。

## 历史限制

真实Push为REAL_PUSH_PROVIDER_PENDING；历史非注入SFU/RPC精确根因UNKNOWN；算法独立精度UNVERIFIED；未覆盖手机、RTC硬件、全部深链/通知、全部社交/排盘变体按原报告NOT_RUN。v10.1.13不自动解除这些限制。集中交付后停下供顾问验收，不自动启动下一版。
