# EliteSync V2｜阶段D集中独立顾问限定验收（2026-11-20）

**顾问结论：`PHASE_D_ADVISOR_SCOPED_ACCEPTED_WITH_RESERVATIONS`；整体内部候选`PARTIAL`；`PRODUCTION_NO_GO`；`OWNER_FINAL_PENDING`。**

## 1. 核实身份及Authority

- Owner已明确授权D1–D4和D0安全兼容收尾，参见[Owner C限域接受与D授权](../decisions/OWNER_V2_PHASE_C_FINAL_SCOPED_ACCEPTANCE_AND_PHASE_D_ENGINEERING_AUTHORIZATION_20261120.md)及[阶段D集中任务书](../versions/v2/V2_PHASE_D_JOURNEY_NOTIFICATION_EXPERIENCE_CONSOLIDATED_EXECUTION_BRIEF_20261120.md)。
- C完整安全基线：`15b45a0068c65615dd600b314037965e31244584`，含A+B+C。
- D实际开发分支：`codex/v2-phase-d-journey-notification-20261120`，远端HEAD审阅时为`40ba853a3e9fed9062e8527b22c0b8ca9471e9ce`。
- D固定源码：`cdfd8f2753147ac3eaacd24af30d69a7efb3d07e`；D0提交`399f34c5f3245758a433ecbbb562f8f228c97c0c`。GitHub C→D比较：ahead 3、behind 0，merge-base为C；源码→最终交付ahead 1、只新增本报告，无源码修改。
- [Codex D固定综合工程报告](https://github.com/zcx369658780/EliteSync-v10/blob/40ba853a3e9fed9062e8527b22c0b8ca9471e9ce/docs/versions/v2/phase-d-20261120/PHASE_D_ENGINEERING_REPORT.md)已直接读取；独立读取变更文件、重点服务及测试源码，未执行Windows测试、未回读本地原始JUnit及日志SHA，未操作真实设备/数据库。
- 工程root、dirty/index、原脏main与S1及治理工作树保护情况仅为`CODEX_REPORTED`，顾问的GitHub提交/源码/测试断言审核仅为`ADVISOR_SOURCE_SPOTCHECK`。

## 2. D0–D4源码与断言抽样结果

| 模块 | 顾问限域判断 | 证据与保留 |
|---|---|---|
| D0 旧排盘兼容 | **PARTIAL** | `astro_profile_provider.dart`针对`LEGAL_BASIS_UNVERIFIED`停止自动重试；`AstroOverviewPage`提供“打开本命手填工具”；Flutter `astro_profile_page_test.dart`断言可进入独立手填页面。旧POST `/profile/astro`仍409，资料保存不再自动计算，旧客户端兼容或旧核心能力退役**尚需Owner单独产品取舍**，新增25条C阶段兼容FAIL仍保留。 |
| D1 关系旅程/提案 | **SCOPED_PASS** | `LifestyleController`验证答案实际修订+具体选项的回执，未知时先只读reconcile，不自动重发；`SlowDatingService::decisionResult`按actor/提案/操作/版本/原键返回最小APPLIED/NOT_APPLIED/CONFLICT/UNKNOWN；`SessionBoundPage`在安全失败场景查原结果后经用户确认才同键重试；`SlowDatingJourneyPage`拒绝旧通知定位到新提案。PHP `V1017MatchingJourneyTest`与Flutter `journey_pages_test.dart`具名负例可见。仅隔离合成环境有效，真身份正向链未运行。 |
| D2 站内通知/待办 | **SCOPED_PASS** | `NotificationService`对提案/联系请求/双同意当前权利验证、实际业务deadline、历史最小投影；`NotificationController`区分current/todo/history、已读独立于待办；Flutter通知打开前`fetchNotification`重读，账号/authority epoch变更阻断旧回包，Back后刷新频道。PHP `NotificationApiTest`含已读仍待办、过期历史和Block拒绝；Flutter `notification_center_page_test.dart`含切号、迟到、空页游标及标读失败。外部Push依`REAL_PUSH_PROVIDER_PENDING`禁用；无真实投递证据。 |
| D3 既有UI/可访问性 | **SCOPED_PASS FOR NAMED WIDGETS, OVERALL PARTIAL** | `lifestyle_page_test.dart`涉及欢迎跳过、保存未确认停留、1×/2×字体、语义和Reduced Motion；通知Widget含返回及文本放大；`section_reveal.dart`对减少动效保守呈现。但读屏真实软件、键盘完整焦点路线、实机、正式A6和原43PNG身份均未核。 |
| D4 条件性联测 | **PARTIAL** | Laravel HTTP + SQLite内存、Flutter Widget与受控虚构响应的具名证据可审；实际跨设备和真APP→API→DB环境、PHP8.4/MariaDB/真实KYC/Push/RTC以及法务均NOT_RUN。S01–S16及G01–G10不能因文档覆盖或Widget局部通过写整体PASS。 |

特别保留：NotificationService的`unreadCount`逐条游标读取并逐条权威检查，当前审阅不足以证明大数量通知下的性能与并发时延；不列安全失败，也不把它记作生产性能PASS。通知动态读权在不同查询点可变化，已见客户端对打开前重读的安全措施，真实竞态仍待MariaDB/设备证据。

## 3. Codex运行证据与原失败对照

- PHP具名：`CODEX_REPORTED PASS`，175项/2,265断言。
- Flutter具名：`CODEX_REPORTED PASS`，383项；另31项在`ELITESYNC_V1017_LOCAL_BUILD=true`条件下通过，**不等于31项全新或完整APK真实构建/设备验证**。
- Dart改动22文件分析0问题：`CODEX_REPORTED`，非全仓PASS。
- PHP全量：**FAIL**，1,498项/26,154断言、83 errors、131 failures、另1 deprecation/4 skipped/3 risky；C遗留25项新增兼容错误或失败全部仍在，B原189项仍在，D本次未见新增失败为Codex的原始JUnit对照报告，**顾问未逐例复算**。
- Flutter扩围：**FAIL**，65通过/3失败，据报告与C原三项身份相同；Flutter全仓NOT_RUN。
- 当前没有D新增迁移定义。安全SQLite测试不能代表MariaDB锁、JSON或生产迁移。
- 真实官方访客正文仍空；原43PNG`PENDING_BINARY_UPLOAD`、F-01`READABILITY_PARTIAL`，历史1011804/UI-AUDIT-01 FAIL/UNKNOWN/NOT_RUN仍原判。S05、S07整屏本轮NOT_RUN；其它S/G多为PARTIAL或有真实环境欠证。

## 4. 顾问统一结论、下一步

**阶段D具名隔离软件合同有充分抽样依据，建议Owner可在明确保留项下予以“限域接受”，不要求重做A/B/C既有验收**。但是工程整体仍`PARTIAL`，生产仍`NO_GO`，与Codex的区分一致。

未关闭重点：
1. **旧排盘客户端/API能力取舍**：25条C兼容失败仍OPEN；现有App安全手填入口不等于旧客户端全面兼容。由Owner决定保留兼容桥、明确退役方案或限定内测的阻断策略，不能恢复无许可自动复用，也不能靠删测试变绿。
2. **全量与扩围失败**：PHP83 errors/131 failures、Flutter扩围3 FAIL不变；作为后续质量收口显式跟踪。D新增0失败属于Codex对照，非独立日志验真。
3. **环境/法域依赖**：PHP8.4、MariaDB真实迁移与并发、设备跨端、真实KYC/Push/RTC、用途合法依据、对象真实删除受理和备份/第三方权利仍OPEN/NOT_RUN，阻断生产GO；未授权真实供应商、生产数据、设备及不可逆删除。
4. **UI及资源**：正式A6、辅助技术实测、43份原PNG身份/来源、F-01仍开放，不因D3 Widget通过自动关闭。

**审阅终态：`PHASE_D_ADVISOR_SCOPED_ACCEPTED_WITH_RESERVATIONS / INTERNAL_CANDIDATE_PARTIAL / PRODUCTION_NO_GO / OWNER_FINAL_PENDING / A6_MEETING_DEFERRED / NO_MAIN_MERGE_OR_RELEASE`。**

本报告仅顾问独立审阅与建议，**不构成Owner阶段D最终接受，不追加阶段E/正式A6/真实服务或发布授权**。
