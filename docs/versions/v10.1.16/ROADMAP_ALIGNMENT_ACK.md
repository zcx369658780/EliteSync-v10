# v10.1.16 路线与开发思路对齐确认

2026-11-15。当前仅授权V3.0阶段B2，执行依据为固定任务提交 `89ce556ab67c6ea759d3a2ffea7016edf11b892e`，唯一父基线 `b981796e68ca512beeed2a18b40aeb8b09e26bc2`。稳定根为 `D:\EliteSync-v10-product-v1015-20261101`，origin为 `git@github.com:zcx369658780/EliteSync-v10.git`，任务分支为 `codex/v10.1.16-user-state-automation-center-20261115`。

## 编码前核验

初始稳定根为v10.1.15 R1修正提交 `0db7f5731fea642b5facc7fa1a6e92f785ac549a`，tracked工作树与index清洁，原 `%SystemDrive%/` 保留。原库与稳定根的HEAD、分支、status、tracked/cached diff及index原字节已保存到Owner本机 `v10116-current`。目标提交的十六个新增/改动路径均为文档，已从目标提交建立本任务分支并设置对应upstream。

十四份具名路线、Owner/顾问接受、任务合同及入口材料已逐Git Blob与本地内容核验为 `LOCAL_DOCS_SYNCED`。[同步回执](LOCAL_DOCS_SYNC_RECEIPT.json)

开发库确认为 `elitesync_v10_1_5_dev`，MariaDB 10.11.19，SQL只读探测成功。DB/API/WS运行，SFU exited。两个AVD数据目录和现有构建工作区、v10.1.15私有原证保留。模拟器端口的本轮只读观察记录在同步回执中，旧runtime状态文字按其记录时点保留。

## 本版工程合同

- B2为唯一授权范围。以现有ProfileReadinessService、LifestyleDiscoveryService、SlowDatingService、MatchRoundProjectionService和其他域权威来源进行实时、账号私有、只读聚合。
- 状态API采用字段白名单、来源revision/更新时间和generated_at。原始答案、精确出生资料、私聊、peer字段、安全内部案卷和匹配内部评分排除在聚合输出之外。
- 自动化按scope默认关闭，用户明确授权后才执行，支持暂停、恢复、撤销、到期及策略版本失效。没有既有强制期限时，持续授权的expires_at可为空，并明确说明持续条件。
- 每周慢约试点先审计既有授权文案与matching_participations合同，再选择复用既有持续授权或新增默认关闭的窄scope。每次执行复核授权revision、当前资格和proposal状态。
- 白名单执行具备持久幂等记录、有限重试/退避、lease/fencing、UNKNOWN业务事实核对及最小审计，复用现有Laravel和本机DB设施。
- 管理员轮次创建、执行、重试、揭晓及受保护matching consumer维持原权限边界。自动接受候选、建立Connection、Messaging Consent、Conversation或Relationship排除在自动化scope之外。
- APP接入位于现有Me/Progress/慢约会入口。B3、B4及阶段C继续按未授权状态记录。
- Owner整体实机验收延期至B1+B2+B3完成。本版采用虚构账号、模拟器与真实本机APP/API/DB链进行工程验证。

## 执行与停止点

先产出状态来源图并核对现有只读与副作用边界，再按七项AC实现与定向验证。候选建议 `10.1.16-dev / 1011601`，构建前核占用。集中交付实施报告、manifest、证据摘要、状态来源图、自动化合同、运行恢复说明及最终候选，固定提交和同源远端回读后等待GPT顾问独立验收。

本确认在本版产品源码修改之前创建并提交。
