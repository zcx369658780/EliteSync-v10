# EliteSync v10.1.3｜独立搭子＋好友可见社区｜Codex唯一综合开发长任务

签发2026-10-21 Astra。状态：**OWNER_CONDITIONAL_ENTRY_APPROVED / PLAN_FROZEN / MANUAL_CODEX_DISPATCH_REQUIRED / IMPLEMENTATION_NOT_STARTED**。

本版不得恢复旧“版本一页一任务／不断重规划”或全仓考古流程。Owner前置条件——v10.1.2安全集成经Astra独立验收、无需返修——已经满足。**将本任务手动转交Codex即授权其在已冻结的受控开发范围内连续实施、必要修复、真实验证、有限非作者复核和集中候选交付；尚未转交不得执行。**

## 1. 不可偏离的权威与固定来源

- 本版唯一冻结计划 `docs/versions/v10.1.3/plan.md`，Blob **`74b67f4a61d2b38f7993dcfcb345510bc57cd65a`**，须读全文并严格按其AC-10.1.3-01～12交付。
- v10.1.2完整已接受产品：apps Tree `365810451b6faad98e041835be6c86f4f81be0a9`、services Tree `96b2972a19ec49108cf5c11d144179e5693570a9`；源码接受Commit `88ffeccce4042f13ce4edccf7604b835b06c8f2d`。
- v10.1.2集成完成GitHub main里程碑 `418dd43acb2ef7a3bd279c40fc3821c4a0a234e2`，Root Tree `15ec973a95106cfbda7d297e9a2e6aa805b55fce`；之后已追加Astra验收与v10.1.3规划的**纯文档提交**。开工前实读最新main/Tree、其apps/services及所有当前合法后继，不能硬恢复旧main。
- 两份Astra正式验收 `docs/versions/v10.1.2/acceptance.md` 与 `docs/versions/v10.1.2/integration_acceptance.md`；Owner 2026-10-19决定、路线 §6.3、2026-09-12已接受设计；`CURRENT_WORKFLOW.md`、2026-10-21轻量补充、唯一 `ACTIVE_STATE.md`。
- 权限：Owner重大不可逆/真实数据/费用/公网；Astra产品冻结和独立终验；Codex收到派发后完成单版全部工程与集中回执。无需强制Claude/Gemini多链复评。Codex不得改Owner已决定内容、替Astra自签ACCEPTED或合产品main。

## 2. 一次实现范围

A. **独立Buddy真实链**：先定点读取现有 `BuddyCompanionPage` Mock、路由排除测试、Social邀请和CN/MC、Profile和matching应用入口，保留有用UI资产但以真实服务端事实替换Mock。MEAL/STUDY双人活动，创建人明确DRAFT/OPEN、当前好友+收件Buddy许可可定向邀请；没有好友也可由创建人主动发**独立高熵单次48h可撤销token**，接收人持token主动兑换后，创建人明确确认。不得通过数字用户ID直接骚扰陌生人、开放全站列表或把活动卡伪装为社会公开场地。每项生命周期server UUID/revision/actor/idempotency/currentUser，申请/接受/拒绝/撤回/取消/结束/过期一致写入独立持久MariaDB，最多2人/活动，默认3未完成活动/账号上限以DB和事务守护；不新建恋爱Match/CN/MC/普通会话或自动转好友。非婚恋虚构A/B必须完成真实正例。

B. **活动最小字段与来源收敛**：明确枚举`MEAL/STUDY`、主题长度、开始结束UTC、粗city（可空）、ONLINE/公共空间未具体化的place_kind、预算LOW/MID/HIGH/UNSPECIFIED。禁止经纬度、精确住址/单位、身份证/电话/生辰、自由文本地点及未经批准的公开陌生人发现。UI只展示当前合法邀请接收人必要最小活动字段；跨账号、结束后旧token、Block/注销/禁用、过期、暂停、接收许可关闭均fail closed。原拒绝是正常用户选择，不生成Safety Finding。

C. **好友社区真值**：已有 `StatusPostController`、`status_posts`、`status_post_likes`、Media私有内容、Block与Moderation是当前长期权威，不另建完整独立Post真值；新增一级comment表＋API＋UI，并保留原帖文/图片、点赞、作者删改受众、举报。SELF/FRIENDS由本人明确选择，当前好友才能见FRIENDS；陌生人/Block用户对postId、commentId、author、图片cover URL、列表分页、旧通知、缓存刷新无权读。评论长度<=280 Unicode字符、每十分钟5次/本人、20条/页，拒绝把评论当新私信/附件/语音入口。不新增收藏、多级回复、转发、公开搜索或无限推荐Feed。受众撤销和未授权评论竞争必须在MySQL锁后当前读，参照1.1 R1与1.2 R1精确barrier，不借旧快照泄漏标题、评论/封面内容或产生点赞/通知副作用。

D. **APP/ Web/安全**：Home次级Buddy与Progress独立分区，好友动态入口有限流，四Tab不变；新评论、请求、接受、取消是APP可操作实际API。离线、旧响应/切号、后退、请求失败/重试、无活动/无好友明确区分，旧BuddyMock页面不能冒充真实结果。Web仅现有Admin受控只读/报告/必要评论审核，不可代用户达成Buddy同意，不能把普通好友升级为MC或恋爱关系。非作者有限复核针对陌生可达性、旧token、竞争与通知/媒体副作用；其它版本原有效证据按范围复用。

## 3. 开发环境与持久化保护

- 只使用本版新的独立本地合成DB `elitesync_v10_1_3_dev`，新归属容器/新volume、loopback建议43324，API8017，WS8018（只在确认端口无主后使用）；不得直接接续旧v10.1.2库、v10.1.1误清库/备份或真实云端用户库。任何迁移/seed前实核`APP_DB_CONNECTION`有效选择优先于`DB_CONNECTION`，host/port/db/URL/socket、local/testing和备份恢复点；普通`RefreshDatabase`测试只许安全SQLite memory。
- 原dirty `D:/EliteSync-v10`、旧`D:/EliteSync`、已有干净连续代码树、候选/审阅分支、本地SQL/备份/volumes/APK/截图及v10.1.2原失败保持；不盲pull/reset/rebase/stash/clean/prune/force push，不删除历史，当前版本独立候选分支开发；无关Docker/设备/系统端口/云资源不触碰。
- 原有明确授权AVD可用于本版开发功能链及APK安装readback，未经授权不接手机USB、相机/麦克风、RTC实际媒体、系统防火墙、UDP、UAC/SDK全局安装、阿里云、公网备案、Push/身份/支付或第三方费用。受控测试图片必须合成/授权，不把图片原证推公开GitHub。
- 可开展必要服务/本版卷启动、明确新库迁移与seed、带保留失败的受控回归，结束停止本版专属临时资源、保留volume及恢复点。任何启动/重启/配置实测按`LOCAL_ONLY/CODEX_REPORTED`，不要让GitHub回执替代现场事实。

## 4. 必须由真实证据支持的验收测试

依据plan的AC-01～12逐项PASS/PARTIAL/FAIL/NOT_RUN；至少：
1. 两名**完全未参加恋爱匹配、未持正式Relation**的合成用户在同一APP登录后完成MEAL、STUDY的DRAFT/OPEN→申请/邀请→双方同意CONFIRMED→COMPLETED及取消/过期负例，重启DB后恢复正确。
2. 合法好友＋接收许可、本人显式限期token兑换的两条独立来源正例；陌生ID扫描、禁用/Block、关许可、token重放/撤销/过期、重复申请与恶意跨账号提交的**零敏感返回/零越权DB副作用**。
3. 同活动两个并发受邀者只能一位合法加入；同用户未结束活动限制由真实MariaDB并发守护，幂等/旧revision/旧generation与终态不可旧身份复活。不得把200/409混乱或锁超时假装成功。
4. buddy完成后`product_connections`、`messaging_consents`、`formal_relationships`与普通Conversation无新增；已经合法的CN/MC不因取消Buddy自动清零；Block按旧授权规则关闭联系。
5. 当前好友可见文字/私有合成图片的Status，一级comment、作者删除、点赞/取消、举报/具名审核；无好友、已unfriend、Block、禁用、发帖撤回到SELF后所有列表/post/detail/comment/media/通知点击无新私密泄漏。
6. 至少**两组具名MariaDB REPEATABLE-READ实际锁等待**（内容受众缩减、unfriend/Block中任取两项）须精确reader/writer事务connection ID、目标user PRIMARY/授权行、等待真实发生、作者撤权COMMIT时间、阻塞读者恢复后的HTTP及无副作用，非全局等待计数，也非SQLite sleep假竞争。
7. 一次真正的Laravel业务/API＋独立MariaDB＋获准AVD用户操作验证；站内通知最小元数据，不展示私密活动全文与评论正文；Web管理员RBAC/CSRF负例，已接受1.2身份及MC门禁不被新Buddy写入绕过。
8. 数据库/服务受控重启，对必要核心新表和原Status受众的全值hash/行数与HTTP再读核对；重要失败退出码/stdout/stderr、首次异常原件、资源停止与备份保留。
9. 版本APK从最后固定源码/Flutter树构建：明确applicationId、versionName/code、ABI、开发签名、APK SHA256、install/readback SHA256/AVD包身份。同一APK与本版实际API/DB贯通；若源码再改需重建或显式失配。

## 5. 项目源历史字节镜像待补（不阻断研发）

2026-10-21Astra已独立核实原`ELITESYNC_PROJECT_SOURCE_UPDATE_20261021_V1012.zip` SHA256 **`6781b7e8319037770780cfb202b6f37071031d8c9cec0bb969e39cf082c65c6f`**及内部MANIFEST/五原文hash正确，而上次Codex本机未拿到ZIP。该差异不触及任何产品源码/冻结AC；请在本版综合任务**仅当Owner已把ZIP放入具名受保护专用目录时**，验证SHA后将七个原文件逐字节放入`docs/gpt-project-sources/20261021_v1012/original_zip/`，保留原`20261021_v1012/`的语义候选历史和旧`20261019_10x/`不动；新README/ACTIVE_STATE仅需明确两个版本目录的身份，别回写历史里程碑。未取得则记录`BYTE_MIRROR_PENDING`；不得全盘搜索或为ZIP另开治理长任务。Owner已表示ChatGPT项目源由Owner手动更新，Codex不再写“用户未上传”作为已证事实；此处GitHub字节镜像与真实Project附件是两项不同状态。

## 6. 单一候选交付与终止条件

- 严格单一`docs/versions/v10.1.3/IMPLEMENTATION_REPORT.md`＋必要`artifact_manifest.json`及安全脱敏Review包，记录冻结计划hash、实时开工main与保护状态、所有产品源码变动及完整Commit/Tree/apps/services、API/迁移/测试命令exit、具名SQL RR/APP/Web/DB证据、失败保留、必要安全非作者审阅、新APK/签名/hash、本地恢复点、资源终态及所有NOT_RUN。任何持有真实密钥/照片/私人账号/精确地址/原始JWT/SQL或未授权设备日志均不得推GitHub。
- 非作者只读复核后，正常Git commit及普通non-force推送**独立候选分支**与必要短期审阅分支，并GET精确核Commit/Tree/apps/services/报告/manifest/原冻结plan Blob；不合产品main，不清旧历史/工作树/临时证据，不自行`ACCEPTED`，不启动v10.1.4。
- 对于范围内普通错误自主修复，必要才同版一次集中R1。只有需要超出冻结合同的陌生人公开发现字段、实际地图、付费/云端/真实身份/不可逆权限时暂停对应子项并集中报告；允许其余受控部分继续，不启动一轮新的只读规划。

**正常出口：`V10.1.3_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE / V10.1.4_NOT_STARTED`。**
