# EliteSync V2｜阶段C：来源/用途/派生与对象级权利——合并工程任务单 V1

日期：2026-11-20（Asia/Singapore）  
状态：`PHASE_C_OWNER_AUTHORIZED / CODEX_EXISTING_SESSION_HANDOFF_PENDING / PHASE_D_NOT_AUTHORIZED / A6_MEETING_DEFERRED / NO_MAIN_MERGE_OR_RELEASE`  
Owner授权：[阶段B限定终验及C工程启动](../../decisions/OWNER_V2_PHASE_B_FINAL_SCOPED_ACCEPTANCE_AND_PHASE_C_ENGINEERING_AUTHORIZATION_20261120.md)。  
路线图：[已接受四阶段总体方案](../../product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md)的C1–C4。  
阶段B固定交付：[Codex报告](https://github.com/zcx369658780/EliteSync-v10/blob/1780f6add9a439c109f527eb7f58c2f96ab8bfa5/docs/versions/v2/phase-b-20261120/PHASE_B_ENGINEERING_REPORT.md)，交付commit `1780f6add9a439c109f527eb7f58c2f96ab8bfa5`；[顾问限定验收](../../workflow/V2_PHASE_B_ADVISOR_SCOPED_ACCEPTANCE_20261120.md)。  
**本任务为单个合并阶段，不拆成G04/G05/G06/G07等独立Owner小型审批，也不代表真实法律/生产验收已获得批准。**

## 0. 执行模型与唯一真实开发身份

- **先保护现有成果**：阶段B远端分支`codex/v2-phase-b-home-content-audience-20261120`固定交付`1780f6ad...`，含阶段A+B已验收范围内的安全保护。前次本地开发根据Codex报告为`D:\EliteSync\development\v2-phase-a-20261119`，不是本次保证仍活动的文件系统权威。原`D:\EliteSync-v10`脏main（43已跟踪变化、213未跟踪）及S1审阅根（独立分支/未跟踪）不能触碰或清理。
- 现有EliteSync本地Codex会话先只读核实际Git根、origin、branch/HEAD、dirty/index、当前AGENTS/ACTIVE_STATE，确认以包含B交付的合法来源安全隔离建立`codex/v2-phase-c-...`分支/工作树。若身份冲突/会覆盖未提交文件，停止危险动作并报告Owner；不盲目的checkout/reset/pull/stash/clean。
- Codex负责子任务自治、实施与自动化自验、GitHub非main**脱敏备份**；Owner终验、网页GPT集中里程碑审阅。阶段C结束仅交**一包完整报告**并停在Owner审查点，不能自动跨入D。

## 1. C1｜SOURCE/PURPOSE/AUDIENCE/SNAPSHOT独立、同用途合法复用（G04）

**Owner精确依据**：[O04/O05](../../decisions/OWNER_V2_O04_O05_DATA_REUSE_AVATAR_PUBLICATION_20261119.md)、[DATA-D1/D2](../../decisions/OWNER_V2_DATA_D1_D2_PURPOSE_REUSE_CORRECTION_PUBLICATION_ACCEPTANCE_20261119.md)。

**工程建议范围**：
- 建立可追溯的**来源事实**、**具名用途决定**、**对外受众**、**已发布版本/快照**四个独立领域合同或映射，复用现有User/Matching Inputs/Showcase/Lifestyle/玄学输入时优先读真正权威事实，避免复制出互相矛盾的“另一份真实事实”。
- **当前用途有效且具适用合法依据**才能复用已保存的必要事实；新用途缺许可时仅向用户呈现具名目的、所需字段和实际影响，允许拒绝与返回；拒绝可选用途不连带禁用其它已有合法功能。**不能**凭“技术上有一条记录”就推定用户许可/适用法律依据，更不能预勾跨目的授权。
- 许可来源/版本/账号/撤销/读权应有可核事实及有界授权回执；撤销许可不等于删除所有历史存储，也不能悄悄在后台预填恢复。不同用途/资料类别（身份、出生资料、社交展示、匹配/独立玄学工具等）禁止默认绑定。
- 真实法律依据尚未确证的敏感跨用途数据采集/对外发布必须`UNKNOWN/BLOCKED`，只在隔离虚构数据中验证接口；不得将所设计的`purpose_grant`一类内部字段冒充现实法律认可的有效同意。

**验收AC**：
- `C1-AC1` 有效用途许可可在同一具名目的下按需复用可靠字段而不重复填报；未授权/撤销/过期/不匹配用途必须阻断计算或外显。
- `C1-AC2` 独立用途拒绝不影响其它独立合法能力，不能自动授给星盘/八字/紫微/社交/匹配一揽子权限；准确标注事实来源、批准和撤销版本。
- `C1-AC3` 本人可预览与对外受众/已发布版本严格分离；切号、Block、旧版本与UNKNOWN拒绝无权读写。

## 2. C2｜事实纠错、真实派生依赖和新发布资格（G05/G06）

**Owner精确依据**：DATA-D2、O05/O05-X A、HIS-D2、O09。

**工程建议范围**：
- 只对**实际受更正输入影响**的派生结果记录依赖、来源版本/签名和`NEEDS_REVIEW`等具名状态；未受到影响的字段、独立合法服务、旧已成立关系及可用入口继续有效。不能把所有资料修改解释为全局失效，或在没有真实核验能力时假称已重新计算。
- 计算/核查/发布三个权威阶段分开：未重新核实的受影响派生结果不得作为“已验证有效”对新受众发布；仅有合法用途/资料/独立本人确认和真实发布回执后才可新外显。UNKNOWN先有权只读核验，不自动重发高影响发布。
- 保留A2既有候选原批准发布版本绑定和当前失权检查；用户本人改资料/主头像只更新依赖默认值的本人预览，**不自动**向已有候选推新版，不改变其他独立已发布场景受众。
- 如既有计算/派生算法并不能真实核实某用途，保守保留`NEEDS_REVIEW`并阻断该结果新“已验证”外显；不要以Mock算式代替真实计算认可。

**验收AC**：
- `C2-AC1` 更正来源事实A只使依赖A的受影响结果进入需核查状态，不冻结无关B与合法独立功能；撤回相关用途后无权继续计算/新发布。
- `C2-AC2` 未核查内容不能被新受众作为有效结果读取，真实已通过核查+具名发布决定才可生成新快照；本人预览与发布回执可独立追溯。
- `C2-AC3` 旧Match候选仍读原合法绑定版或按当前权限隐藏；新发布不能静默替换旧版，Block/失权/过期/旧缓存安全回退。

## 3. C3｜本人作品/评论对象级删除**请求**与受理/完成分级（G07）

**Owner精确依据**：[NEW-PC-03](../../decisions/OWNER_V2_NEW_PC03_INITIAL_OBJECT_LEVEL_DELETION_REQUEST_ENTRY_OPTION_A_ACCEPTANCE_20261119.md)、[RET-D1/D2](../../decisions/OWNER_V2_RET_D1_D2_REVOCATION_DELETION_CONCEPT_ACCEPTANCE_20261119.md)、[OBJ-D1](../../decisions/OWNER_V2_OBJ_D1_POST_TAKEDOWN_THIRD_PARTY_COMMENTS_ACCEPTANCE_20261119.md)、NEW-PC-01/02、O09。

**必须区分的四种不同事实**：
- 作品撤下/SELF、评论作者撤回本人评论展示、作品作者隐藏第三方评论是**展示/阅读权利变更**；
- 本人对特定**本人作品或本人评论**表达“申请删除数据”的独立意愿；
- 有合法真实后台渠道且取得权威回执的**已受理/处理中**；
- 仅对**确切对象、范围及主副本/附件/保留例外**有证据的**已完成删除**。

**获准的工程实施边界**：
- 可在本地隔离测试里实现本人对象定位、合法身份/版本/幂等/UNKNOWN确认、明确入口说明和**受理/处理中/完成的不同数据与UI状态合同**。对具备真实有效合法流程的通道可在另具授权时启用；没有这些外部事实时**真实提交端必须fail-closed**，只能准确展示可用渠道与限制，不发布假工单、假回执或“所有副本永久删除”。
- 不能以“阶段C实施授权”为由绕过NEW-PC-03原本只是**首期入口规划方向**的产品范围：开发接口/控件技术准备可以，但**不视为Owner对真实运营受理、具体法定期限或第三方删除权的批准**。
- 作品作者删除本人作品的请求**不替第三方评论者请求删除其原文/回复/安全必要记录**；评论者可请求属于自己的对象，不因作品当前对他失权而失去合法必要申请资格，但此请求不能恢复作品正文读权。
- 如果系统没有真实处理机构/法律事实/备份删除能力，则返回中性`REQUEST_CHANNEL_UNAVAILABLE / LEGAL_SCOPE_UNVERIFIED`等适当安全说明，接口不得写入任何具有“受理”法律意义的生产回执；Mock与本地内存测试仅标`TEST_ONLY`。
- 不做真实主副本、备份、第三方素材或Safety记录的不可逆删除，不宣称全域已删除，不联系供应商/律所代替Owner裁决。

**验收AC**：
- `C3-AC1` 本人作品与本人评论两个对象/入口及权限独立，第三方无权冒名请求；作者隐藏/撤下≠真实删除申请/已受理/完成。
- `C3-AC2` 未启用合法真实渠道时无假受理编号/假进度/假完成；有合法测试受理器的隔离试验要显式TEST_ONLY，不映射生产能力。
- `C3-AC3` 仅确认的对象与范围才有受理/完成回执；UNKNOWN先只读查询当前合法结果，切号/请求重放/Block/第三方评论与媒体/备份例外拒绝或分流。
- `C3-AC4` 不破坏已接受的B3分主体撤回/隐藏与独立回复的合法当前读权，也不把历史依法保留等价为当前外显许可。

## 4. C4｜跨模块安全/历史缓存/授权回归（G04–G08）

- C1/C2/C3一切读取与写入要核**当前账号、具名用途、受众、原快照、Block/撤销、版本、请求幂等及命令结果**；跨设备/本地迟到响应，无法确认一律安全隐藏或UNKNOWN。
- A1真实身份TEST_ONLY仍只在合法testing+SQLite内存使用，正式Match与依赖真KYC链继续fail-closed；A2旧候选形象冻结、A3 Lifestyle先查后重试、A4/B历史评论原受众必须定向回归。
- 保留B1官方访客空内容（无具名授权官方正文前）、B2普通新作品`FRIENDS+FRIENDS_ONLY`、B3分主体评论权利与父回复保守投影、B4媒体字节及通知/深链当前读权。任何C新增数据视图都不得越权把私聊、安全材料或出生精确输入外显给无关用途。
- 产生真实合法依据前，技术脚手架可部分通过，但对外动态不能以隔离Mock证明真实服务或法律有效性。

**验收AC**：有已授权路径的正向、拒绝、过期、Block、用途撤销、SOURCE纠错、旧快照、旧深链/媒体、账号切换、请求UNKNOWN与重复键、历史NULL等正反/拒绝场景；未经真实设备/数据库条件运行的专项写`NOT_RUN`。

## 5. 实施环境、既有失败与集成前置证据

**允许**：在已确认无真实个人信息/生产连接的安全隔离分支中改Flutter/PHP/必要DB schema与迁移**定义**；使用非生产SQLite内存测试库及确已具合法隔离的PHP/Flutter单元/Widget/服务级集成测试；按需对有证据的非生产PHP8.4/MariaDB配置做定向兼容补证。如环境不明确则停相应高风险操作，记`ENVIRONMENT_UNAVAILABLE`，绝不连接生产/共享DB。
- 阶段B具名回归：PHP149项/1,936断言、Flutter226项、17个Dart分析零问题，是Codex报告且已被Owner**限定终验**，不是PHP/Flutter全量通过。
- PHP全量截至阶段B仍`FAIL`：B 1,487项/81errors/108failures，A基线1,477项/81errors/109failures，零新失败的逐例对照属于`CODEX_REPORTED`；Flutter Status+Buddy扩围65通过/3失败，复现于A亦为Codex报告。不要删失败用例/跳过检查/降低拒绝标准来“绿测”。
- PHP项目约束`~8.4.0`，此前实测PHP8.5.3；MariaDB并发、JSON/迁移/回滚和跨端真实设备仍`NOT_RUN`，阶段C尤其注意新授权表与删除请求**状态**不能只以SQLite行为代表MariaDB。
- 真实KYC/Push/RTC、法域/合法依据、第三方保留/删除范围和原43PNG `PENDING_BINARY_UPLOAD`、F-01 `READABILITY_PARTIAL`、历史1011804/UI-AUDIT-01旧FAIL/UNKNOWN/NOT_RUN均按原样留存。
- 禁止真机/模拟器、生产/共享DB、真实数据/密钥、不可逆删除、联系/采购/集成真实供应商，正式A6会议，main合并与公开发布；禁止自动实现阶段D全量旅程/通知及视觉收尾。

## 6. 唯一集中交付和阶段结束停止

由Codex在原有EliteSync项目会话自主拆子任务，集中交**一份阶段C中文工程包**，包含：

1. **真实身份**：当前Git根、远端、分支/父基线/源码HEAD/交付HEAD、dirty/index、A/B继承范围；怎样保护老main和S1工程树。
2. **合同矩阵**：C1–C4映射Owner具名决定、PRESENT/PARTIAL/ABSENT/UNKNOWN的工程证据、真实文件/符号/迁移定义、开放的法律/产品细节。
3. **动态证据**：实际执行的PHP/Flutter/安全测试DB、命令和版本、正向/拒绝/撤销/派生/UNKNOWN/旧读权、PASS/FAIL/UNKNOWN/NOT_RUN；结果原始日志SHA、脱敏摘要与本地私有留存。
4. **回归比较**：A+B现有具名测试保护、PHP/Flutter全量旧FAIL/新增FAIL逐项比较；PHP8.4/MariaDB环境是否仍OPEN，任何真实法务/设备/供应商证据不得伪造。
5. **风险与推荐**：对象级删除真实渠道是否确切`UNAVAILABLE`、用途依据/旧快照/衍生结果是否具可验证门禁，保守默认，后续阶段建议与`PHASE_C_PASS/PARTIAL/FAIL/UNKNOWN`**工程自验**。

阶段C报告交付后停止，不自动开展阶段D、正式A6、main合并或发布。若必要法律/外部证据未具备，可将工程脚手架及可独立安全功能记`PARTIAL/BLOCKED_BY_EXTERNAL_FACT`，不能粉饰为真实对象删除可用。Owner保留最终阶段验收与下一阶段授权。

终态：`PHASE_C_OWNER_AUTHORIZED / CODEX_HANDOFF_PENDING / PHASE_D_NOT_STARTED / A6_DEFERRED / NO_MAIN_OR_RELEASE`。
