# EliteSync-v10 工程约定

生效：2026-11-15。当前路线权威为[V3.0](docs/architecture/ELITESYNC_V10_PRODUCT_ROADMAP_V3_0.md)及[Owner补充决定](docs/architecture/ELITESYNC_V10_PRODUCT_ROADMAP_V3_0_ADDENDUM_20261115.md)。普通工程自治沿用[Owner长期授权](docs/decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md)。

## 当前接受与授权

v10.1.14六项AC及Xiaomi Android16实机补证已获顾问与Owner具名代表性范围接受，NO_R1/NO_R2；三项P2和NOT_RUN/UNKNOWN/UNVERIFIED边界继续保留。Owner记录见[OWNER_ACCEPTANCE](docs/versions/v10.1.14/OWNER_ACCEPTANCE_20261115.md)。

当前授权版本为v10.1.15「生活方式探索与渐进式偏好」（V3.0阶段B1）。任务见[task_order](docs/versions/v10.1.15/task_order.md)、[plan](docs/versions/v10.1.15/plan.md)、[DEVELOPMENT_ALIGNMENT](docs/versions/v10.1.15/DEVELOPMENT_ALIGNMENT.md)。

## 产品原则

EliteSync是低频、高意图、低操作成本的Relationship Decision Support System，不以DAU、停留时长、无限Feed或频繁互动为目标。用户表达意愿，系统完成已授权准备；隐私、分享、身份、消息同意、关系承诺和不可逆动作仍由用户明确控制。

## v10.1.15范围

注册后默认展示Lifestyle Discovery，但可跳过；跳过不影响注册、匿名社区、好友或Buddy；未来每周慢约会匹配必须完成。4—6个场景、每场景2—3选项；自动保存、返回修改、正反向动画；原始答案和可解释映射分开保存，用户可纠正。

Astra用于艺术指导；最新在线GPT Image用于静态美术素材；资产放GitHub固定路径并有精确模型版本/日期/提示词/SHA256 manifest。运行时不接AI，不上传用户偏好。视觉风格冻结，等待后续会议再调整。

## 未授权边界

B2通用状态与自动化中心、B3全局低操作成本重构、B4运行时AI、阶段C外部身份/信用/Push/支付均未授权。不得收集实名、出生时地或信用数据；不得改变匹配算法和关系状态机；不得将探索设为社区/Buddy/好友门槛。

## 自主执行与验证

Owner负责方向和重大不可逆决策；Codex负责授权范围内拆解、实现、调试、定向验证和常规Git，不逐动作请示。先同步本版路线/授权/任务文件并创建ROADMAP_ALIGNMENT_ACK再编码。只做本版必要测试，不重跑所有历史AC。NOT_RUN/UNKNOWN如实记录。

保护本地dirty/index、数据库、AVD、私有配置、素材和原始证据；不盲pull/reset/rebase/stash/clean/prune，不force push。真实用户/生产数据、Owner手机、外部付费服务、main集成、正式发布和运营不在本版授权内。集中交付后停止等待顾问验收。
