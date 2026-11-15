# 生活方式探索题库 V1

2026-11-15。题库 `lifestyle_v1`，映射 `lifestyle_rules_v1`。五场景、十五选项，依据 Astra 艺术指导定稿。

每个维度仅记录该题近期选择。原始答案私有，支持返回改选、重做和账号删除。映射记录来源 scene_id、option_id、answer_revision、rule_id 和解释。所有选项平等，无总分或准确率。共餐人数只表达这一餐的偏好。相聚安排不推断承诺水平。

| 场景 | 维度 | 选项与规则 |
| --- | --- | --- |
| 在家放松时，你更喜欢哪种氛围？ | `home_atmosphere` · 居所声音氛围 | `quiet` 安静一点 · `lifestyle_rules_v1.home_atmosphere.quiet`<br>`background_sound` 有些背景声音 · `lifestyle_rules_v1.home_atmosphere.background_sound`<br>`situational` 看当天状态切换 · `lifestyle_rules_v1.home_atmosphere.situational` |
| 去一个新地方走走，你喜欢怎样安排？ | `travel_structure` · 旅行安排方式 | `planned` 提前排好主要行程 · `lifestyle_rules_v1.travel_structure.planned`<br>`open` 到了再随兴探索 · `lifestyle_rules_v1.travel_structure.open`<br>`mixed` 定几个去处，其余留白 · `lifestyle_rules_v1.travel_structure.mixed` |
| 空出半天时，你通常更想做什么？ | `weekend_activity` · 空闲活动偏好 | `rest` 放空休息 · `lifestyle_rules_v1.weekend_activity.rest`<br>`movement` 出门走走活动一下 · `lifestyle_rules_v1.weekend_activity.movement`<br>`making` 做点手作或创作 · `lifestyle_rules_v1.weekend_activity.making` |
| 有空好好吃一顿时，你更想怎样度过？ | `meal_company` · 共餐人数偏好 | `one_to_one` 和一个人慢慢聊 · `lifestyle_rules_v1.meal_company.one_to_one`<br>`small_group` 三五个人一起吃 · `lifestyle_rules_v1.meal_company.small_group`<br>`solo` 自己自在地吃 · `lifestyle_rules_v1.meal_company.solo` |
| 长期相处中，你更喜欢怎样安排相聚时间？ | `shared_time` · 相聚时间安排方式 | `regular` 留出固定的相聚时间 · `lifestyle_rules_v1.shared_time.regular`<br>`spontaneous` 有空时再约 · `lifestyle_rules_v1.shared_time.spontaneous`<br>`flexible_plan` 提前商量，也留出调整空间 · `lifestyle_rules_v1.shared_time.flexible_plan` |
