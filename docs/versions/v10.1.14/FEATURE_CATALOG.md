# v10.1.14 功能目录

候选目标：`10.1.14-dev / 1011402`，包名 `com.elitesync.v1015dev`。本目录根据 v10.1.14 任务范围及 APP 路由表整理，供产品评审和实机检查定位。路由存在只说明代码提供入口，不代表该功能已在 Owner 手机验收；状态以实施报告和证据摘要为准。

## 用户入口

| 功能域 | APP入口 | 评审关注点 | 边界与状态 |
|---|---|---|---|
| 注册、登录与退出 | `/auth/register`、`/auth/login` | 新用户进入、已有账号登录、退出及切号 | 使用虚构 QA 账号；逐账号检查数据隔离 |
| 四入口主导航 | `/home`、`/progress`、`/messages`、`/me` | 入口可达、切换后状态恢复 | 由候选构建实机确认 |
| 个人资料与准备状态 | `/me`、`/me/readiness`、`/me/matching-inputs`、`/profile/edit` | 资料保存读回、匹配准备信息 | 按现有隐私设置和用途收集 |
| 个人展示与隐私 | `/me/showcase`、`/me/privacy-settings`、`/profile/showcase`、`/profile/settings/privacy` | 展示内容、受众选择及隐私保存读回 | 不改变默认受众或隐私合同 |
| MBTI 与问卷 | `/profile/mbti`、`/questionnaire`、`/questionnaire/result`、`/questionnaire/history` | 已有工具结果和历史记录 | 不作为心理诊断或确定性结论 |
| 星盘及命盘工具 | `/profile/astro`、`/profile/astro/overview`、`/profile/astro/bazi`、`/profile/astro/natal`、`/profile/astro/ziwei`、`/profile/astro/advanced`、`/profile/astro/chart-settings` | 既有结果、设置和历史读回 | 用户主动使用时按需提供相关资料 |
| 匹配 | `/progress/match` | 未就绪、无候选、资格拒绝时的准确状态；候选解释与确认 | 不改匹配算法及关系状态机 |
| Connection 与消息许可 | `/progress/connection` | Match、Connection、Messaging Consent 独立状态 | 不将其中一个状态推定为另一个状态 |
| 消息与会话 | `/messages`、`/messages/chat/:chatIdentity` | 会话进入、文字收发、失败反馈、账号隔离 | 真实 Push 未接入；通知到达不作承诺 |
| 社区动态 | `/status/square`、`/status/author` | 图文及单媒体动态的发布、列表、详情、互动和受众读取 | 本版视频为单个图片或视频媒体；视频复用私有媒体验证与鉴权，不含推荐、直播或自动播放 Feed |
| 好友与 Buddy | `/buddy` | 好友关系、好友视角及既有 Buddy 场景 | 用虚构 QA 账号检查好友与非好友边界 |
| 通知中心 | `/notifications` | 页面打开、已有通知展示与返回 | 真实 Push 未接入；通知卡精确 ID 以证据摘要记录，未知项不据此判通过 |
| 实时通话 | `/rtc/call`、`/rtc/incoming`、`/rtc/result`、`/rtc/permission` | 权限提示、呼入呼出、后台恢复、麦克风/摄像头、耳机/扬声器及双设备通话 | 手机+模拟器语音67和视频69已按本轮范围验证；耳机、人耳听感、双实机、跨公网及完整硬件矩阵NOT_RUN |
| 反馈与账号设置 | `/inner-test/feedback`、`/profile/settings`、`/profile/settings/password`、`/profile/settings/about` | 反馈提交、设置保存、返回主流程 | 账号支持/反馈具体能力以候选实际行为为准 |
| 身份核验与正式关系 | `/verification/status`、`/verification/submit`、`/formal-relationship` | 确认未配置能力的提示和边界 | 未接入真实身份供应商；正式核验及依赖其建立的正式关系不视为可用 |

## 评审范围说明

- 核心旅程覆盖注册/登录/退出、资料/隐私、特色工具、匹配、独立关系与消息许可链、好友/社区/Buddy、平台活动入口、账号支持/反馈，以及身份核验未配置边界。逐项证据、未覆盖条件和问题级别见核心旅程矩阵。
- 社区测试内容仅用于本机虚构 QA 环境的上传、播放、权限和持久化评估。素材许可逐项见素材许可清单，二进制素材不随公开仓库交付。
- 不包含 Lifestyle Discovery、阶段 B 全局交互重构、AI 关系解释、真实身份核验、真实 Push、支付或新供应商。
- 原交付时对应项目初始状态为`OWNER_ACTION_PENDING`。Owner已授权本轮手机补证，当前结果见实机报告及更新检查表，后续Owner体验与接受意见另记。

2026-11-15实机补证已按Owner本轮授权执行，实际项目状态见[更新检查表](OWNER_DEVICE_CHECKLIST.md)和[实机报告](PHONE_TEST_REPORT_20261115.md)。耳机、人耳听感、双实机和跨公网矩阵沿具名未执行状态。
