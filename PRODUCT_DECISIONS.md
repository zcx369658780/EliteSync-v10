# EliteSync v10｜已接受产品与架构边界

本页只摘录当前本地主线可追溯的决定，不创造新产品语义；精确依据仍是各接受记录和原文。

- 信息架构：`Home | Progress | Messages | Me`。Progress 是导航容器。主循环按 `Readiness → Match → Connection → Conversation` 分段；Match、Connection、Conversation、Relationship 互不代替。
- 隐私与权限：每段权限独立；Connection active 本身不解锁 Conversation。私密会话不默认用于 AI、训练、排序或广告。Safety 不进入普通兼容性分数；`UNKNOWN` 不等于 false/safe。
- 资料用途：Private Identity、Matching Inputs、Readiness、Showcase 分离；MVP 不设 globally public Profile 或单一权威 Compatibility 总分。
- 阶段：MVP 主线优先；Explore/Relationship 属 Phase 2，optional AI/reference 属 Later，不因本地演示进入当前交付范围。
- Synthetic/dev：虚构本地 session/readiness/Match/Connection/Conversation 只能明确标为开发演示，不能冒充服务器权威、真实同意、生产写入或真实参与者数据。
- 交付：可安装开发演示、邀请制真实内测、公开运营是不同出口。没有对应运行、签名、部署及授权证据，不提升发布声明。

来源：本地主线 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`、`ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md` 及对应已接受的产品/客户端记录。`Date Drop`、AI relationship summary、玄学解释层、backend v2 出现在迁移提案的例子里，本地 v10 未核实接受，不列为决定。
