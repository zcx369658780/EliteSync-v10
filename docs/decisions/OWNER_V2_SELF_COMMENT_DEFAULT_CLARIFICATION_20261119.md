# EliteSync V2｜Owner关于SELF作品默认评论与好友评论的澄清决定

日期：2026-11-19（Asia/Singapore）  
治理分支：`governance/home-matching-product-freeze-20261117`  
状态：`OWNER_SELF_DEFAULT_OFF_WITH_FRIENDS_CLARIFICATION / OTHER_TRANSITION_DETAILS_OPEN / DESIGN_ONLY / CODEX_NOT_AUTHORIZED`

## 1. 原话及接受范围

顾问在[S01–S16四批审阅汇总](../product/ELITESYNC_V2_S01_S16_FOUR_BATCH_CONSOLIDATION_AND_OPEN_GATES_V0_1_20261119.md)后仅针对`SELF`（仅自己可见）作品推荐“默认`OFF`”，并指出具体变更及旧作品迁移仍需以后决定。

Owner回复：

> 好的我同意你的建议，请继续（虽然我认为默认不允许他人评论不太合适，应该是默认不允许陌生人评论，好友还是能评论的）

本决定按已有`SELF / FRIENDS / PUBLIC_AUTHENTICATED`语义作**范围限定**，既保留Owner对**SELF特例默认OFF**建议的接受，也明确其补充意见——**普通新建用户作品不应默认所有人都无法评论；默认是陌生人不能评论、当前有权好友可以评论**。

该解释不新设“好友可评论但无权读取SELF作品”的越权例外；若Owner以后希望这样的特殊互动，须另行明确修改作品受众/阅读合同，而不能从一句评论偏好直接推断新权利。

## 2. 各受众的当前确认规则

| 作品受众 | 当前可读范围 | 默认评论或实际可评论边界 | 决定性质 |
|---|---|---|---|
| `FRIENDS` | 作者本人及符合当前双向好友等有效权限的用户 | 新作品评论默认`FRIENDS_ONLY`；有权好友可评论，陌生人不能 | **此前O01方案A已确认，本次Owner再次强调** |
| `SELF` | **只有作者本人** | 默认`OFF`为本次接受的SELF特例；好友因无正文阅读权，不能在SELF期间评论 | **Owner对SELF特例建议接受，范围明确** |
| `PUBLIC_AUTHENTICATED` | 当前有权登录用户（非访客） | 从FRIENDS扩大受众时评论仍不会自动扩大至`ALL_ELIGIBLE`；维持先前适用的`FRIENDS_ONLY`或作者另行明确设置；须同时有阅读权且未被Block | **此前O01/O02已确认** |

访问作品正文是可评论的必要条件；评论资格还要满足当前账号有效、作品受众、作者当前评论策略及Block等全部适用门禁。即使朋友关系有效，`SELF`作品也不会因评论策略设置而向朋友展示。

## 3. 不可由本次澄清推断的新增行为（OPEN）

- 从`SELF → FRIENDS`时，实际评论策略字段是否自动恢复`FRIENDS_ONLY`、显示受众建议还是要求作者选择；如果作者曾明确选择`OFF`，系统能否重置其明确偏好；
- `FRIENDS → SELF`时旧好友评论的服务端保留/撤回、历史附件/引用、对旧通知/媒体缓存的处理；不能因为当前SELF就虚称后台已删除；
- `SELF`状态下作者本人是否可发布单人自评/笔记、评论控件如何显示，以及评论设置内在字段是否存储为OFF还是只计算“当前不可评论”；
- 旧作品迁移、受众切换时原设置/显式覆盖、旧评论许可和保留期限；
- 实际后端是否支持该策略、字段映射、UI变更和测试证据；既有1011804未按V2完整实现公开作品域。

上面未决细节将作为[作品受众×评论权限联动与切换顾问草案](../product/ELITESYNC_V2_SELF_FRIENDS_COMMENT_AUDIENCE_TRANSITIONS_V0_1_20261119.md)单独讨论，不能将顾问提出的默认迁移策略称为Owner已批准。

## 4. 执行与证据界限

本决定仅冻结**概念级默认意图与SELF例外的范围**，不是新的数据schema、评论历史删除合同、实现任务或动态PASS。

A6正式UI会议继续暂缓，Codex未获新V2实施授权。禁止修改APP/API/Web/DB、设备/模拟器、构建APK、合main或发布；真实实人核验供应商/Push未接入、旧1011804 NOT_RUN/UNKNOWN及43份PNG原件远端PENDING_BINARY_UPLOAD均不改变。
