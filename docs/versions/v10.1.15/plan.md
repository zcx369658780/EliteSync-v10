# v10.1.15计划：Lifestyle Discovery与渐进式偏好

## 1. 产品定义

Lifestyle Discovery是注册后的默认欢迎体验。它用少量生活场景让用户自然表达偏好，替代初次注册时过多的重复问卷和表格。用户可跳过，跳过不影响注册和匿名社区；未来每周慢约会匹配需要完成。

它不是正式MBTI、心理诊断或确定性人格测试。它记录用户选择，并用透明、可修改的本地规则生成生活方式偏好摘要。

## 2. 体验原则

- 默认邀请，不强迫；
- 4—6个场景，每个2—3个选项；
- 一屏一个场景，视觉信息清楚，减少文字；
- 选择后自然过渡；返回时动画反向播放；
- 自动保存每个场景进度，用户无需点击“保存”；
- 用户可跳过、继续、返回、修改、重做；
- 完成后展示简洁偏好摘要，允许纠正；
- 不收集与此流程无关的身份/出生/信用资料。

## 3. 数据与规则

建议最小模型包含：
- questionnaire_version；
- answers（scene_id、option_id、answer_revision）；
- progress_status（not_started / in_progress / skipped / completed）；
- preference_projection_version；
- derived_preferences（dimension、value、source_answer_ids、rule_id、confidence/strength）；
- completed_at、updated_at。

具体数据库设计由Codex根据现有数据合同确定。原始答案与推断结果分开保存。映射必须可追溯、可解释、可纠正。置信程度不是心理测量准确率，不得用虚假百分比制造科学感。

## 4. 匹配门禁

服务端每周慢约会匹配申请增加Lifestyle Discovery完成条件。未完成则返回独立、可解释的资格原因和补齐入口。客户端展示不能替代服务端校验。

普通社区、好友、Buddy和允许的普通聊天不受该门禁影响。实名核验是另一条独立状态，不在本版接入。

## 5. 美术与动画工作流

1. Astra生成艺术指导：统一色板、几何语言、人物造型、构图、安全区和各场景提示词。
2. 最新在线GPT Image模型生成正式场景素材；记录实际模型版本和日期。
3. 资产筛选后提交GitHub：原图/优化图、preview/contact sheet、prompt、asset manifest、SHA256。
4. Codex只引用固定路径，不在代码里嵌入外部URL；APP运行时使用本地资源。
5. 动画优先由Flutter本地动画控制器组合场景层，支持forward/reverse，不依赖网络视频。
6. 若Astra或GPT Image暂时不可用，先交付prompt pack并标记ASSET_GENERATION_PENDING；不擅自替换模型或素材。

## 6. 推荐执行顺序

- 同步V3.0及本次Owner补充决定；
- 审计现有注册、首次登录、匹配资格API、资料数据模型；
- 设计题库V1和映射规则；
- 完成Astra艺术指导与GPT Image素材包；
- 实现探索流程、持久化、跳过/恢复/修改；
- 实现每周慢约会服务端门禁；
- 定向验证普通社区不受影响；
- 构建1011501或顺延候选，完成报告和证据。

## 7. 成功定义

新用户注册后无需填一堆资料即可进入APP；默认可以体验生活方式探索，也可以跳过。探索中断不会丢失已完成答案。用户可返回修改，动画可正反向播放。完成后得到可解释、可纠正的偏好摘要。未完成者仍可使用普通社区，但无法进入每周慢约会匹配；服务端同样执行门禁。整个流程不调用运行时AI，不收集真实身份或信用数据。
