# EliteSync V2｜阶段D：连续旅程、通知、体验和条件性联测——合并工程任务单 V1

日期：2026-11-20。状态：`PHASE_D_OWNER_AUTHORIZED / CODEX_EXISTING_SESSION_KICKOFF_PENDING / NO_MAIN_OR_RELEASE`  
Owner授权：[阶段C最终限定接受与D启动](../../decisions/OWNER_V2_PHASE_C_FINAL_SCOPED_ACCEPTANCE_AND_PHASE_D_ENGINEERING_AUTHORIZATION_20261120.md)。基线：[C固定工程报告](https://github.com/zcx369658780/EliteSync-v10/blob/15b45a0068c65615dd600b314037965e31244584/docs/versions/v2/phase-c-20261120/PHASE_C_ENGINEERING_REPORT.md)与[顾问限域审查](../../workflow/V2_PHASE_C_ADVISOR_INDEPENDENT_SCOPED_REVIEW_20261120.md)。产品范围为[Owner接受的四阶段路线图](../../product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md)D1–D4。

**一个合并工程阶段；Codex自治拆分、实现和自验；交一份阶段报告，不拆成G小任务逐次Owner许可。**

## 0. 真实工程起点和安全前置

C交付固定提交`15b45a0068c65615dd600b314037965e31244584`（B祖先`1780f6add9a439c109f527eb7f58c2f96ab8bfa5`）。C已获Owner**限域最终接受并保留风险**，不是C全量PASS。报告中的本地根`D:\EliteSync\development\v2-phase-a-20261119`、C分支`codex/v2-phase-c-data-rights-purpose-20261120`仅为Codex历史回执，启动前只读核实际origin/HEAD/index/dirty/活动树；若工作区存在冲突，停止危险Git动作保护成果。保留`D:\EliteSync-v10`脏main、`D:\EliteSync-v10-product-v1015-20261101` S1树和独立治理同步树，不盲pull/reset/rebase/stash/clean。可自行安全建立新D非main分支或隔离工作树，不要求同步GitHub main才开发。

**D0保留债务**：C全量83errors/131failures、Flutter扩围3fail，不可当PASS；对C新增25条旧排盘/基本资料/登录兼容差异按四类测试分别具名归因，优先确保独立手填流程和旧客户端安全替代提示。保留非法自动复用的409/fail-closed；对不改变Owner核心决定的兼容Bug可在本阶段修复，对实际废弃核心API/旧能力需Owner另作具名产品取舍。不可仅通过删测/改断言/禁用失败实现“通过”。D0不能借此阻断不相关的D1–D4安全开发；交付时保持历史基线与新增结果分账。

## D1｜连续关系旅程与状态可解释（G01、G08、G09）

**目标**：在现有关系业务服务上建设连续的用户旅程，不发明新的关系授权态。
- Lifestyle首次欢迎可以略过，五场景在**已权威保存成功**后再引导下一题；失败或UNKNOWN不得当成功自动推进或重发。
- 以Home/Progress/Messages/Me已接受导航方向为起点，复用现有Proposal、Connection、双方Messaging Consent、Conversation、正式Relationship和Buddy各独立的状态/受众资格；不得把Match、Connection、许可和聊天合成一个“已匹配”权利。导航和信息可连续，但任何下一步按钮仅在该步真实具名权限成立时可用。
- 拒绝/撤回/过期/Block/账号切换/深链失权后安全返回与清除旧快照；旧Match仅其原受控绑定版，C用途与评论历史失权延续。真实身份未配置时正式Match、自动参与、正式Relationship资格仍拒绝，不得靠合成TEST_ONLY宣布真实正向链通过。
- 分离首屏引导和已有高级用户状态，不强制重复问卷/无限打扰。

**AC D1**：至少覆盖首次/重入、五场景每步确切保存与UNKNOWN、可跳过、拒绝/Block、权限过期、旧候选版、双方同意各阶段独立、旧深链以及切号迟到响应。以真实源码/调用/Widget或隔离集成测试证明，不可仅画静态UI。

## D2｜站内通知、待办、到期及安全回流（G08）

- 已读状态、待办有效与权限当前性独立；通知可以已读却仍待办，也可未读却已过期或失权；不能用标读当完成任务。
- 真实权威截止期和状态进入受控待办投影；不猜本地倒计时作为业务权威。历史已失效通知保留最小非泄密展示，读正文、用户/关系、附件/媒体、旧深链在点击时复核当前身份、Block、受众、用途与版本。
- 处理动作有明确确认/拒绝、幂等键、UNKNOWN先只读求证，不可重复履约；完成后安全返回当前通知频道和有权列表，不暴露旧账号信息。
- 可开发测试站内通知；真实Push provider未配置时保持禁投递、不可把本地消息/测试receipt称真实Push成功。

**AC D2**：读/未读vs待办、过期、撤回、Block、老通知、错号、登录切换、丢响应和同键重试、返回路径；站内投影的正文/媒体字节级权限；实际Push仍NOT_RUN。

## D3｜既有UI、可访问性与资产边界（G10、A6前工程）

- 基于已接受的Home/Progress/Messages/Me及既有页面体系减密度、一屏一目的、单一明显合法主操作；拒绝、撤回、隐私设置、说明和错误重试必须可见，不产生误导性合规/正式Match已可用文案。
- 在批准的**既有方向**内实现语义标签、读屏顺序、文字放大/布局溢出、系统Back、Reduced Motion、键盘/焦点等安全变更，并用可用的静态/Widget与资源验证提供证据。涉及新产品架构/重大交互取舍只提Owner决策，不自动冻结新视觉规范。
- 43份PNG原件`PENDING_BINARY_UPLOAD`、F-01`READABILITY_PARTIAL`保留，不能用重新画的图、截图或工具生成素材替代原资产身份；正式A6设计会议、真机/模拟器无障碍演练和正式资产上线均不在D授权内。

**AC D3**：具名屏幕与导航路径的UI更改清单；文字放大/读屏与焦点、Back、动效减少的静态/Widget用例及明确不能证明的真实设备事项；资产manifest含来源身份与缺口，不伪造二进制回读。

## D4｜条件性联测、风险和V2内部候选判据（G01–G10）

- 使用确证隔离、非生产、虚构账号数据的PHP/Flutter/SQLite内存/HTTP/Widget等具名验证；如确实具安全、合法隔离的PHP8.4/MariaDB环境，可以在不连接共享/生产库条件下做兼容定向补证，否则`NOT_RUN`。不操作设备/模拟器。
- 将S01–S16及G01–G10映射到已执行证据，分别注明正向/拒绝/UNKNOWN/NOT_RUN；**S01–S16静态文档覆盖不等于真实端到端PASS**。
- 真实KYC、真实Push、RTC、法域/删除、生产数据、跨设备传播仍为外部证据线E1/E2/E3，未具则继续fail-closed；不得以TEST_ONLY授权绕过。
- 验证对A/B/C具名安全功能的受影响回归（Block、旧候选版、历史评论、媒体/深链、用途撤销、对象请求假受理阻断），并对D新模块建立最小可检查负例。未运行全仓不得宣称全仓PASS。

**AC D4**：一张D1–D4 × AC × PHP/Flutter/迁移/环境 × 状态/原始日志hash的证据表；全量旧FAIL与D新增FAIL逐项对比（原C新增25条单列）；内部候选`PASS/PARTIAL/FAIL`与生产`NO_GO`明确分列。

## 实施许可/硬停点

D只开放已批准路线范围内Flutter/Laravel/相关Web、必要安全迁移定义和隔离自动化验证；非main脱敏Git备份可自行安排。**不开放**真机/模拟器、正式A6会议、生产或共享数据库/真实个人数据、物理删改、真实KYC/Push/RTC供应商联络采购集成、系统提权、main合并和正式发布。若无合法依据，旧数据跨用途复用、正式Match和真实对象删除受理继续关闭。不许可隐式退休旧星盘等核心产品能力。

## 唯一集中交付

Codex完成后交一份中文报告：①本机工程root/origin/branch/源码及交付SHA/dirty/index、保护树状态；②D0及D1–D4产品合同和具体文件符号/变更；③实际命令/环境版本/隔离证明/具名测试及原始日志SHA；④S01–S16/G01–G10和A+B+C受影响回归/历史失败与新增失败；⑤安全、外部和产品取舍OPEN，UI资产限制，内部候选与生产GO/NO_GO分账；⑥自身`PHASE_D_PASS/PARTIAL/FAIL`自验。阶段D交付后停止，在Owner/网页GPT集中审查节点等候，不进行main、发布或正式A6。
