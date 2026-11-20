# EliteSync V2-Q｜现有本地Codex会话启动Prompt

你好。请**在现有EliteSync本地Codex项目会话中**继续，而不是新建代理会话或恢复GitHub-first派单。Owner已在2026-11-20明确同意阶段D顾问建议的**限定最终接受**，并授权开展“**V2集成质量与产品决策收口**”（V2-Q）；新的阶段不是功能扩张。

请先在只读方式核实当前本机实际Git根、origin、branch、HEAD、dirty/index、当期本地AGENTS与当前工程状态；**保护一切未提交内容、原脏main、S1审阅工作树及独立治理树**，不得盲目pull/reset/rebase/checkout/stash/clean或以GitHub治理HEAD取代本机源码权威。

固定工程参考基线：阶段D完整交付`40ba853a3e9fed9062e8527b22c0b8ca9471e9ce`，原分支`codex/v2-phase-d-journey-notification-20261120`；A+B+C均已包含。实际活动树如果不符则先安全核实差异，不能覆盖。

请从Owner提供的**固定治理提交**中仅读下面具名材料（按顺序），不要递归历史：
1. `docs/decisions/OWNER_V2_PHASE_D_FINAL_SCOPED_ACCEPTANCE_AND_INTEGRATION_QUALITY_AUTHORIZATION_20261120.md`
2. `docs/versions/v2/V2_Q_INTEGRATION_QUALITY_AND_PRODUCT_DECISION_CONSOLIDATED_BRIEF_20261120.md`
3. `docs/product/V2_Q_LEGACY_ASTRO_COMPATIBILITY_OWNER_DECISION_OPTIONS_20261120.md`
4. `docs/workflow/ACTIVE_STATE.md`顶部当前块，遇首个历史分隔线停止；以及当期`CURRENT_WORKFLOW.md`顶部。
5. 只有实际排查某失败或合同需要时才按任务书有界读具名Owner文件和固定A/B/C/D报告。

本轮一次性自治执行质量收口：
- **Q0** 确认D→Q固定基线及原始日志；重建可复核的PHP 214（83 errors+131 failures，其中B189、C新增25、D新增0仅先前Codex报告）及Flutter3条失败差异账。
- **Q1** 逐项分析旧排盘25条和真实客户端引用。**无Owner新的核心能力取舍授权前**继续保持旧自动POST无许可409、资料/登录不隐式跨用途联算、独立本人手填入口；仅做安全兼容Bug/提示/回归，整理一份A/B/C产品选择供Owner一次性决定。不要删掉旧测试、恢复无许可计算或自行退休全部旧盘功能。
- **Q2** 重点诊断并在安全不改权利的范围内修复Flutter扩围三项（`SessionNotifier.build`旧签名、Buddy403旧卡片和丢回执草稿/同键）。同时按风险分诊PHP旧189项，优先A–D安全边界、实际用户阻断与受影响路径，避免盲修全部历史。
- **Q3** 仅在真正独立、非生产、无个人信息环境中做PHP8.4/MariaDB具名测试与迁移/回滚/并发补证；不存在明确安全环境即NOT_RUN；可继续SQLite内存与Flutter Widget隔离测试，不用设备/模拟器。
- **Q4** 形成内部软件合同/设备评估准备/生产发布三层证据与NO_GO表；43 PNG、F-01、S05/S07、真实KYC/Push/RTC、法域删除受理、MariaDB、设备等原OPEN/NOT_RUN不能冒充PASS。

必须保留关系决策辅助的既有业务合同：Match≠Connection≠Messaging Consent≠Conversation≠Relationship；Block/撤销/原候选快照与媒体字节权限、UNKNOWN先查权威、真正合规缺失时fail-closed。安全回归以实际改动风险决定，不能稀释负面测试、无证迁移或绕开真实服务。

**禁止**在本次许可下连接供应商、生产或共享DB、处理真实个人数据或不可逆删除、使用真机/模拟器、举行正式A6、系统提权、合main、公开内测和发布。重大旧产品功能退役或新法律判断必须交Owner批准，暂停该受影响分支，其余安全工程继续。

最后请**只集中提交一份中文V2-Q工程报告**及真实固定source/delivery SHA、变更/安全边界、测试命令/日志hash、失败差异与旧C25归因、已修复缺陷、仍须Owner决定的事项、环境及三层候选/生产判定。自行完成非main去敏Git备份和回读。完工停止在Owner与网页GPT集中验收节点，不自动进入下一版本或正式发布。
