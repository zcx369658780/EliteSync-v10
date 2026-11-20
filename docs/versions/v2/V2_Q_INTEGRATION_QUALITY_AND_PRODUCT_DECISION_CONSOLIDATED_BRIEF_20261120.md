# EliteSync V2-Q｜集成质量与产品决策收口集中工程任务书 V1

日期：2026-11-20（Asia/Singapore）  
状态：`V2_Q_OWNER_AUTHORIZED / CODEX_EXISTING_SESSION_START_PENDING / OWNER_ASTRO_CHOICE_PENDING / INTERNAL_CANDIDATE_PARTIAL / PRODUCTION_NO_GO`。  
依据：[Owner阶段D终验与Q启动](../../decisions/OWNER_V2_PHASE_D_FINAL_SCOPED_ACCEPTANCE_AND_INTEGRATION_QUALITY_AUTHORIZATION_20261120.md)、[D固定工程报告](https://github.com/zcx369658780/EliteSync-v10/blob/40ba853a3e9fed9062e8527b22c0b8ca9471e9ce/docs/versions/v2/phase-d-20261120/PHASE_D_ENGINEERING_REPORT.md)、[D顾问审阅](../../workflow/V2_PHASE_D_ADVISOR_SCOPED_ACCEPTANCE_WITH_RESERVATIONS_20261120.md)、[旧排盘Owner选择备选](../../product/V2_Q_LEGACY_ASTRO_COMPATIBILITY_OWNER_DECISION_OPTIONS_20261120.md)。

**工作定位：一个集成质量/决策收口批次，不是第五个功能扩张阶段。** 由现有本地Codex自治拆分、安全实施、自验，结束交**一份中文综合报告**。网页GPT集中抽样审查，Owner对旧核心能力/对外运营最终裁决。不得把所有214条历史错误当作这个阶段必须在不明环境中盲修完成的KPI；质量要按可验证事实分层。

## Q0｜安全起点与证据基线（先做，限最小审计）

- D固定交付`40ba853a3e9fed9062e8527b22c0b8ca9471e9ce`；D最终源码`cdfd8f2753147ac3eaacd24af30d69a7efb3d07e`；C`15b45a0068c65615dd600b314037965e31244584`，含此前A/B。上次报告本地工作树为`D:\EliteSync\development\v2-phase-a-20261119`，但不是新的实时保证。先只读核实实际Git root/remote/branch/HEAD/index/dirty和当期本地AGENTS；原脏`D:\EliteSync-v10`、S1`D:\EliteSync-v10-product-v1015-20261101`、独立治理交接树及其未跟踪材料不得覆盖/清理，不盲目fetch/pull/reset/checkout/rebase/stash/clean。
- 固定测试基线：D报告PHP全量1,498项/83 errors/131 failures，共214条错误/失败，另4 skipped/3 risky/1 deprecation；阶段B遗留189条、C新增25条，D新增0为Codex本地JUnit对照；Flutter扩围65通过/3失败，Flutter全仓NOT_RUN；PHP8.4及MariaDB实际锁并发NOT_RUN。
- 建立**可审计的失败明细账**：每一JUnit失败定位`test_class + test_method + error_type + failing_assertion/signature`，B/C/D归属及产品/环境原因，有无修复及新结果。先证明分类、重复性与可隔离性，不能简单归纳为“旧失败”忽略。原始日志在本机私有目录留存，以SHA256、脱敏摘要及固定源码证明测试对象。

## Q1｜旧排盘25条及Owner待决产品合同（优先但不阻断无关Q2）

- 逐例核C新增25：`AstroCanonicalApiTest`14 failures、`ProfileBasicRecomputeTest`5 failures、`V1007BaziProvenanceTest`3 failures+2 errors、`AuthPasswordApiTest`1 failure。映射**真实旧API调用、目前APP入口、独立手填替代、资料来源/具名用途/失权与历史快照、真实用户影响是否已证**。
- 形成分类： (a) 可保持现合同下修复的工程BUG；(b) 与Owner已接受用途隔离冲突的**旧期待**；(c) 依赖未确定真实合法处理依据/旧数据权威的BLOCKED；(d) 需要Owner真正批准的功能退役/兼容桥/客户端升级策略。
- 在**Owner新的策略选择以前**，保持旧POST无依据409、本人独立手填可用、基本资料/登录不隐式发起旧计算或回填。可以修复拒绝提示、入口可达性、崩溃或安全兼容缺陷；不得借修改旧测试断言、移除旧端点/测试或恢复旧无许可自动复用宣称“25项归零”。旧测试与新权威合同冲突时可增加并行新契约断言和标注`CONTRACT_CONFLICT_PENDING_OWNER`，保留旧失败记录。
- 输出Owner一次性可裁决的A/B/C产品策略矩阵（见[备选文档](../../product/V2_Q_LEGACY_ASTRO_COMPATIBILITY_OWNER_DECISION_OPTIONS_20261120.md)），若涉及本质退役立即只冻结该分支，不中断其他安全任务。

## Q2｜Flutter3条扩围与相关高风险质量修复

- 严格区分一条`v1013_root_entry_test.dart`的`SessionNotifier.build`签名编译错误，以及`v1019_buddy_pages_test.dart`两条Widget（分页business 403后旧卡片/游标清理；lost response后草稿及原命令保持）。
- 在证明是当前源码兼容缺陷且不会修改Owner产品权利合同的范围内修复；检查切号、权限撤回、迟到响应、幂等键/UNKNOWN，尤其应避免修坏A1–A4/B1–B4/C1–C4/D1–D4既有fail-closed。
- 每条以旧固定证据→Q源码→定向重跑→相邻回归→必要扩围串行运行的顺序收口。编译/失败如与特定旧运行器/依赖有关，显式分离`TOOLCHAIN_COMPATIBILITY`、`CODE_DEFECT`、`ENVIRONMENT_UNKNOWN`，不得无证误归因。
- 对PHP历史189条按用户可见、信息泄密/越权、数据完整性、普通兼容、测试基础设施/老合约四类进行轻量分诊。**优先修复可证明高风险及与Q改动直接相关的缺陷**，其它按风险与合法授权形成受控遗留账，不为总数归零盲改未动的旧模块。

## Q3｜安全隔离环境证据与跨层回归

- PHP项目声明`~8.4.0`、先前实测PHP8.5.3。若本机已有**合法、可证明无生产/真实用户数据**的PHP8.4环境，可定向执行PHP兼容与命名安全测试；否则标`NOT_RUN`，不借此自行安装侵入式系统组件、提权或切换真实服务。
- MariaDB迁移/JSON索引/唯一约束/锁、并发、回滚，在**可证明全新独立实例且不连共享/生产DB**条件下允许定向补证；无法确认即`NOT_RUN`。尤其注意C阶段用途许可、对象请求、历史动态盘降级拒绝，以及D阶段提案结果与通知锁序。SQLite内存PASS不能替代MariaDB。
- 定向A+B+C+D回归：正式Match与真实身份fail-closed、候选旧绑定与Block、评论原受众/媒体字节、用途撤销和来源纠错、删除受理`REQUEST_CHANNEL_UNAVAILABLE`、通知/待办失权、提案同键UNKNOWN、Flutter跨账号迟到回包、2×字体/返回/减少动效。仅凭安全隔离事实，不升级为真机或真实第三方服务PASS。
- 检查构建条件`ELITESYNC_V1017_LOCAL_BUILD`对应的31项与非该条件的主线差异，必要时实施**不涉及设备**的静态/Widget兼容检查。除非已有独立具体授权，不运行模拟器/真机，不接外部收费或生产服务。

## Q4｜产品和发布前置证据账（静态/治理）

建立一张**三层GO/NO_GO矩阵**，分别判断：
1. **已具名安全隔离的内部软件合同/小范围验证**（可据实际证据给SCOPED_PASS/PARTIAL）；
2. **扩大内部候选/真实设备评估的准备程度**（设备未授权即NOT_RUN，不虚构通过）；
3. **对外测试、生产及正式发布**（目前固定`NO_GO`，待真实KYC/Push/RTC/法律依据、部署/迁移、真实设备等具名证据与Owner授权）。

把S01–S16、G01–G10状态中尚未运行的S05/S07整屏、原43PNG`PENDING_BINARY_UPLOAD`、F-01`READABILITY_PARTIAL`、旧UI-AUDIT-01历史FAIL/UNKNOWN/NOT_RUN、访客正式官方正文`public_editorial=[]`逐一保留原状态，说明缺什么外部来源及谁有权限确认。不得假造已取得原PNG的二进制SHA或已获素材授权。

## 非授权范围和风险处理

本阶段仅安全本地代码、必要schema**定义**、合法隔离测试及非main脱敏备份。不授权真实个人资料、生产或共享DB/不可逆删除、真机/模拟器、真实身份核验/Push/RTC供应商接触选型采购集成、系统提权、正式A6视觉会议、main合并、公开内测或发布。真实法务与个人数据权利继续按实际渠道和依据fail-closed。重大旧功能退休、发布所需产品重大取舍保留Owner决定。

**流程约束**：日常工程由现有Codex自治，只有出现真实授权冲突/不可安全操作/重大产品不可逆决策才暂停对应子项。避免再拆成许多网页GPT审查微任务，避免把Owner当日常消息总线。

## 单次集中交付验收AC

1. **身份**：实际根、origin、分支、base/source/delivery commit、dirty/index，保护树状态及差异；以D固定交付为包含全部历史保护的合法起点。
2. **质量账**：214 PHP错误/失败和Flutter3条的逐例分类、起源、修复状态、新增/移除及每次测试结果；旧C25单列。汇报是否仍有安全P0/P1或用户入口受损，不夸大“无新增失败”的证明等级。
3. **产品决定**：旧排盘A/B/C矩阵与Owner仍需明确选择的最小问题；已允许的安全兼容行为与未允许的旧功能退役分开；不得以Q工程自行定产品战略。
4. **验证**：具名与扩围、PHP8.4/MariaDB有界补证（如不可用则NOT_RUN）、原始日志SHA及私有保留、A–D受影响安全回归；G/S状态有据。
5. **候选判定**：内部软件/设备评估/生产三层资格明确列SCOPED_PASS/PARTIAL/FAIL/NOT_RUN/NO_GO；法务/供应商/正式A6/资产例外OPEN。
6. **停点**：交一份中文Q综合工程报告+固定GitHub源码与报告，不自动进入新阶段，不自动宣告上线或关闭真实合规风险，交Owner/网页GPT一次性集中审阅。
