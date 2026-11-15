# EliteSync-v10 工程约定

生效：2026-11-15。当前授权版本为v10.1.14「产品评审准备与核心旅程收口」，路线权威为[V3.0](docs/architecture/ELITESYNC_V10_PRODUCT_ROADMAP_V3_0.md)，Owner决定见[阶段A授权](docs/decisions/OWNER_V10_1_13_ACCEPTANCE_AND_V10_1_14_PHASE_A_AUTHORIZATION_20261115.md)。普通工程自治沿用[Owner长期授权](docs/decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。

## 产品目标

EliteSync是Relationship Decision Support System：低频、高意图、少量清晰匹配，帮助用户以尽可能少的时间建立健康、长期关系。不以DAU、停留时长、无限Feed或频繁互动为目标。Match、Connection、Messaging Consent、Conversation、Relationship保持独立语义。

v10.1.13六项AC具名代表性范围已获顾问与Owner接受，NO_R1/NO_R2；原NOT_RUN/UNKNOWN/UNVERIFIED继续保留。v10.1.14已获Owner授权，唯一当前路线为V3.0阶段A。

## 当前执行范围

执行[v10.1.14任务](docs/versions/v10.1.14/task_order.md)、[计划](docs/versions/v10.1.14/plan.md)、[开发对齐](docs/versions/v10.1.14/DEVELOPMENT_ALIGNMENT.md)和[启动Prompt](docs/versions/v10.1.14/CODEX_START_PROMPT.txt)。必须先同步V3.0路线及Owner决定，生成ROADMAP_ALIGNMENT_ACK后再编码。

阶段A仅做：核心旅程盘点/P0-P1修复；社区单视频动态；20图文+5视频虚构QA语料；本机服务与隔离备份/恢复；新候选与Owner手动实机包。当前StatusPost只支持图片，本版只增加一个视频主媒体，复用既有私有媒体管线，不做短视频平台。

阶段B（Lifestyle Discovery、统一偏好状态、自动化中心、全局低操作成本重构、AI辅助）未授权实现；阶段C（身份/信用/Push/支付/外部发行）未授权。视觉方向已由Owner确认，等待下次会议前不再调整。

## 自主执行

Owner负责方向和重大不可逆决定；Codex负责授权范围内拆解、实现、调试、必要验证、工程验收和常规Git；GPT按需提供独立审阅。普通可恢复错误自主处理，不逐动作请示。

## 验证与资产保护

只对本版改动及P0/P1风险定向验证，不重跑全部历史AC。真实APP/API/DB/Web链、Widget/单元、受控测试、隔离恢复演练和Owner手动实机分别记账。NOT_RUN/UNKNOWN如实保留。

保护稳定工程dirty/index、数据库、AVD、私有配置、APK、凭据和原始证据；不盲pull/reset/rebase/stash/clean/prune，不force push。测试素材只在本机Git忽略目录保存，GitHub只存去敏许可/来源清单；QA账号秘密只本机保管。不得用真实用户/生产数据。

普通开发、必要迁移、定向测试、Debug APK、本机开发服务、虚构数据、必要双模拟器和常规Git沿Owner长期授权。不操作Owner手机，不接新供应商/付费服务，不合main、不发布、不开展公司/内测/运营。集中交付后停下供顾问验收。
