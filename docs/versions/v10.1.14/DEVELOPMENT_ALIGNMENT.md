# v10.1.14 开发思路对齐文件

本文件是本版编码前必读的产品方向约束，防止Codex按旧路线或一般社交APP思路偏离。

## 1. 当前只执行阶段A

阶段A = 产品评审准备与核心旅程收口。
本版目标是现有产品可用性、核心阻断问题、社区测试语料、开发环境恢复和Owner评审包。

阶段B = 低操作成本、Lifestyle Discovery、统一用户状态中心、后台自动化和全APP功能整合。本版不得提前实现阶段B。

阶段C = 身份/Push/信用/支付/外部发行等条件性事项，未授权。

## 2. 产品价值不是使用时长

EliteSync帮助用户用尽可能少的时间获得高质量关系机会。不要增加无限Feed、短视频推荐、连续签到、无意义点赞、推送轰炸或强迫确认。20图文+5视频只为本地测试社区的显示、上传、播放、权限和数据持久化，不是产品方向转向内容平台。

## 3. 已确认的未来产品原则（本版只记录，不实现）

- 注册后默认欢迎Lifestyle Discovery，但允许跳过；跳过不阻止注册和匿名社区；未来参与慢约会匹配必须完成。
- 题库4—6场景的建议尚未冻结；具体题目后续会议设计。
- AI分析是未来方向，本版不接模型、不上传用户偏好。
- 视觉风格已确认：低分辨率质感、色块、几何构成、低刺激；小游戏使用二次元卡通/构成主义画风。Owner要求下次会议前不再调整。
- 用户意愿驱动自动化；只自动执行已授权、可逆、低风险行为。
- 实名、信用和蚂蚁积分不接真实服务；真实身份核验适配仅保留未来占位。
- 出生时间/地点不作为匹配强制信息，只在用户主动使用相关计算功能时按需收集。
- Android权限在用途触发时请求，不在首次启动时一次性弹出所有权限。

## 4. 本版唯一新增的社区媒体范围

当前StatusPost只支持图片封面，后端验证media_type必须为image；视频动态是Owner明确提出的有限测试需求，因此本版允许增加单视频动态能力。仅单视频、MP4、复用现有私有媒体管线、现有验证器和鉴权；不增加短视频推荐/直播/编辑/多媒体服务。

## 5. 测试内容不是真实社区运营

20图文+5视频必须：
- 由虚构QA账号创建；
- 通过真实APP发布流程；
- 仅保存在本机开发数据库和本地私有媒体目录；
- 使用许可明确的免费素材，逐项记录作者/来源/许可/下载日期/SHA256；
- 只测试SELF/FRIENDS等现有受众边界；
- 不上传二进制素材、密码、令牌或真实个人数据到GitHub。

## 6. 禁止思维偏差

- 不把“少点击”解释成取消用户授权。
- 不把“自动化”解释成自动公开、自动同意消息或自动建立关系。
- 不把MBTI/场景选择解释为心理诊断或科学确定性。
- 不把芝麻信用、征信或积分作为匹配质量代理。
- 不把社区测试内容数量解释为用户增长目标。
- 不以视觉统一为由在本版重构全APP UI。
- 不因测试数据需要而公开真实位置、出生资料、身份或私聊。


## 7. 当前源码核验锚点

本版计划中的“社区当前仅支持图片”来自v10.1.13固定源码，不是对旧截图的推测：

| 文件 | 源码提交 | Git Blob SHA | 核对结论 |
|---|---|---|---|
| `apps/flutter_elitesync_module/lib/features/status/presentation/pages/status_square_page.dart` | `2b4fdcc9f342b972a37b35de74fbf099827a7c2e` | `f3463af95d0ad799bf47f9eaf1d1498698b0b7f0` | 动态创建使用ImagePicker和封面图片上传 |
| `services/backend-laravel/app/Http/Controllers/Api/V1/StatusPostController.php` | `47e1b4fd8fad3dd8165d1be6dc9f059095290e75` | `d75125a1ef3adb7b03486ba8679b6cea024f051d` | `cover_media_asset_id`必须属于作者且media_type为image |
| `services/backend-laravel/app/Models/StatusPost.php` | 同上 | `d8bc516b040cab6c50652ec614bf6dbcfb1592ba` | 现有媒体关联为coverMediaAsset |
| `apps/flutter_elitesync_module/lib/features/status/presentation/widgets/status_post_card.dart` | `2b4fdcc9f342b972a37b35de74fbf099827a7c2e` | `9f6e1db8ecd6295c78b9384f91675d5973e3b9bf` | 当前动态卡片只渲染认证图片 |
| `services/backend-laravel/app/Http/Controllers/Api/V1/MediaController.php` | `47e1b4fd8fad3dd8165d1be6dc9f059095290e75` | `f4e24d408911dc6b9520a1ac5889f2339ceda942` | 已有私有媒体上传、内容读取和当前权限检查基础 |
| `services/backend-laravel/app/Services/PrivateVideoValidator.php` | 同上 | `b56c5e5c01bbebce2f2b0c3654fa817cdc5e8be4` | 已有MP4/H.264/可选AAC、25MiB、30秒、不转码验证器 |

Codex开工时必须重新确认这些路径和Blob仍与本地候选一致。若本地工程存在后续改动，按本地实际源码重新核实，不盲目用上述历史文件覆盖。
