# EliteSync-v10 工程约定

生效：2026-11-15。当前路线权威为[V3.0](docs/architecture/ELITESYNC_V10_PRODUCT_ROADMAP_V3_0.md)及[B2补充决定](docs/architecture/ELITESYNC_V10_PRODUCT_ROADMAP_V3_0_ADDENDUM_20261115_PHASE_B2_AUTHORIZATION.md)。普通工程自治沿用[Owner长期授权](docs/decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。

## 当前接受与授权

v10.1.15已获Owner具名范围接受：AC15-01/03/04/05/06接受，AC15-02因图像模型精确身份UNKNOWN继续PARTIAL；R1-01 CLOSED、NO_R2。详见[Owner接受记录](docs/versions/v10.1.15/OWNER_ACCEPTANCE_20261115.md)和[顾问报告](docs/versions/v10.1.15/ADVISOR_ACCEPTANCE_20261115.md)。

当前授权版本为v10.1.16「统一用户状态与后台自动化中心」（V3.0阶段B2）。任务见[task_order](docs/versions/v10.1.16/task_order.md)、[plan](docs/versions/v10.1.16/plan.md)、[DEVELOPMENT_ALIGNMENT](docs/versions/v10.1.16/DEVELOPMENT_ALIGNMENT.md)和[B2合同](docs/versions/v10.1.16/B2_USER_STATE_AND_AUTOMATION_CONTRACT.md)。

Owner整体实机验收安排在B1+B2+B3低操作成本主线完成后；B3尚未授权，B4是独立阶段。本版不操作Owner手机。

## 产品原则

EliteSync是低频、高意图、低操作成本的Relationship Decision Support System，不以DAU、停留时长、无限Feed或频繁互动为目标。用户表达意愿，系统完成已授权准备；隐私、分享、身份、消息同意、关系承诺和不可逆动作仍由用户明确控制。

Match、Connection、Messaging Consent、Conversation、Relationship保持独立。正常拒绝、取消、反悔、退出和拉黑不自动违规。

## v10.1.16范围

只实现B2：统一用户状态只读聚合、自动化授权/任务生命周期、有限可靠执行和每周慢约持续参与受控试点。不得建立重复用户状态真相；优先复用现有ProfileReadiness、LifestyleDiscovery、SlowDating、Round及Notification合同。

自动化默认OFF，scope单独授权，支持幂等、有限重试、UNKNOWN核对、暂停、撤销、到期和审计。每周参与试点不得自动创建/执行匹配轮次，不得自动接受候选、建立Connection、Messaging Consent或Relationship。

## 未授权边界

B3全APP低操作成本重构、B4运行时AI关系辅助、阶段C身份/信用/Push/支付/发行均未授权。不得使用真实用户/生产数据，不接新付费服务，不合main、不发布、不开展内测/运营。

## 自主执行与资产保护

先同步V3.0、B2补充决定、v10.1.15 Owner接受、本版任务和对齐文件，逐Blob核验并创建ROADMAP_ALIGNMENT_ACK后再编码。

Owner负责方向和重大不可逆决定；Codex负责授权范围内拆解、实现、调试、定向验证和常规Git，不逐动作请示。保护本地dirty/index、数据库、AVD、私有配置、凭据和原始证据；不盲pull/reset/rebase/stash/clean/prune，不force push。

真实APP/API/DB/Web链、Widget/单元、受控测试和Owner手动实机分别记账。NOT_RUN/UNKNOWN如实记录。Owner整体实机验收安排在B1+B2+B3完成后；本版不得操作Owner手机。集中交付后停下供顾问验收。
