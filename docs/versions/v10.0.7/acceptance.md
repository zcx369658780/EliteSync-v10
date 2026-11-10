# EliteSync-v10｜v10.0.7 Astra独立最终验收

2026-10-15。**ACCEPT WITH OBSERVATIONS — ORIGINAL REAL APP RESTORATION + TARGETED R1 VERIFIED / NOT FULL FLUTTER SUITE PASS / K08 INTEGRATION PENDING**。

本文件是Astra的独立裁决，不是Codex自评。严格沿用[固定v10.0.7计划](https://github.com/zcx369658780/EliteSync-v10/blob/ef1bf4d07f5d7b84a38fb0f59f2efbe951ff4307/docs/versions/v10.0.7/plan.md)（Commit `ef1bf4d07f5d7b84a38fb0f59f2efbe951ff4307`，Blob `151d75b67238826841467fa93c140825ebf61282`），AC-07-01～AC-07-08不变，不新增事后“全套测试必须全绿”标准，也不将任何exit1写为PASS。

## 固定代码与访问口径

| 对象 | 固定身份 |
|---|---|
| 实施起点 | `0989812c141ce892915b67c14e9291d34e3c7053` / Tree `c2dd89f3a0726bff6cd18fb8fe0008c2f347aadf` |
| 初始业务候选 | `69b3f26c6ed28a7306e4ba6b902aac2475bfe103` / Tree `09982c2349fb47c276018ff24aa30ac2f267dc34` |
| 初始APP构建源码 | `7f8da6954db8ef994f91e586c8a4f91fa0bc0a4f` / Tree `754b9a65b41ac9393687417836e380effc81c09b` |
| R1源码提交 | `d3fa5f2bc891931fc9bb86eeb196d233d8686d71` / Tree `66b0050ed85d74cd3a55509264cd2c095089f4a5` |
| **接受的最终R1候选** | **`cf0c359b86e35c794da389a58ba0b687c3c0bd32` / Tree `11f1d086b0c9180998a3684c0df176e1d9c4d2b2`** |
| 候选分支 | `codex/v10.0.7-app-restoration`，GitHub已核HEAD与R1一致；相对初始候选ahead2/behind0、merge-base正是初始候选 |

Astra实际通过GitHub读取：[初始执行报告](https://github.com/zcx369658780/EliteSync-v10/blob/69b3f26c6ed28a7306e4ba6b902aac2475bfe103/docs/versions/v10.0.7/EXECUTION_REPORT.md)、[初始TEST_RESULTS](https://github.com/zcx369658780/EliteSync-v10/blob/69b3f26c6ed28a7306e4ba6b902aac2475bfe103/docs/versions/v10.0.7/TEST_RESULTS.md)、[初始Manifest](https://github.com/zcx369658780/EliteSync-v10/blob/69b3f26c6ed28a7306e4ba6b902aac2475bfe103/docs/versions/v10.0.7/manifest.json)、[Astra R1审查](ASTRA_R1_REVIEW_FINDINGS.md)、[R1报告](https://github.com/zcx369658780/EliteSync-v10/blob/cf0c359b86e35c794da389a58ba0b687c3c0bd32/docs/versions/v10.0.7/R1_EXECUTION_REPORT.md)、[R1归因](R1_TEST_ATTRIBUTION.md)、[R1 Manifest](R1_manifest.json)、相关Laravel/Dart源码、实际命令receipt、stdout/stderr、真实HTTP/DB结果与初始APP/Blade截图。不是逐项下载全部R1证据文件；采用针对安全缺口及关键业务证据的定点交叉验证。

Windows Docker/MariaDB/AVD的实际操作、专用树CLEAN及物理AAR/APK重算SHA为**CODEX_REPORTED**；Astra未远程访问本机、重启设备、下载Windows包或独立计算物理文件哈希。GitHub内的提交、Blob、源码和公开证据则已独立读取。R1安装/新APP全流程**NOT_RUN**，APP/Android/Flutter产品lib Git Tree与初始候选完全一致，因此沿用初始实测而非虚构重复通过。

## 冻结八项AC裁决

| 固定AC | 结论 | 实际证据与限定 |
|---|---|---|
| **AC-07-01** 来源与隔离环境 | **PASS** | Git身份及分支回读，当前源码/题库与MariaDB专用库 `elitesync_v1007_dev`（43317）、volume、媒体disk、具名虚构用户身份有记录；原0.6库/dirty根不变由Codex具名保护比对支持，Windows状态非Astra直接访问 |
| **AC-07-02** 完整资料与真实问卷 | **PASS** | APP存出生信息、157题去重（137启用，research20 inactive）、Alice/Bob20题，Bob保存3题后APP/服务及DB重启与清本版APP数据重登续答；同user ID的答卷/attempt、负例和旧题库5项关联PHP失败修复有记录 |
| **AC-07-03** 实际匹配与APP读取 | **PASS** | 真实matching consumer、prepare/claim/execute/finalize/reveal、retry/lease/零题否定与无资格对照；Match4在APP/API/DB同一记录，未验证玄学模块权重0；旧Match1–3的历史不重写 |
| **AC-07-04** 独立Connection和Messaging Consent | **PASS** | Bob/Alice独立请求/接受，CN_ACTIVE rev2，read/send MC_ACTIVE rev2，两条生命周期不混合；Charlie decline、Dave withdraw、stale/nonparticipant/revoked等拒绝与DB重启证据 |
| **AC-07-05** 合法文字/图片及保护 | **PASS（R1隐私修复）** | 双账号原APP实际消息发送/图片接收/已读、七条HTTP合法/非法、媒体authorized200/nonparticipant404、撤销/block并发等待提交后发送与图片404；R1补消息通知服务端最小化、旧通知当前reader再鉴权与真实HTTP撤销/block/disabled反例 |
| **AC-07-06** MBTI/八字和规则解释 | **PASS** | APP测评MBTI Lite及attempt持久结果、MBTI/人格不参与排序；本地lunar-php四柱、样例/跨时区/缺时降级、资料及解释重登读回；紫微seed/高精西占不冒完整排盘 |
| **AC-07-07** 动态/通知/设置 | **PASS（R1隐私修复）** | APP状态publish/like/作者软删除，非作者403及DB重启读回；match/message站内通知事件、未读/已读与设置本地重启保持；R1通知新存储通用文案、真实有效授权时派生会话导航，block/撤销后无导航但通知和已读功能仍可用 |
| **AC-07-08** 交付及可审测试 | **PASS WITH OBSERVATIONS** | 初始源码AAR/debug APK构建安装/业务/重启证据完整；R1产品客户端源码不变，GitHub对Android与Flutter lib嵌套Tree独立比对相同；原失败日志保存，R1通知PHP27/332、相关Flutter36、全域Dart exit0；**带同次fixture全量Flutter821/3 exit1、普通全量793/5 exit1，不得称全套通过**。本地物理包仅LOCAL_ONLY。 |

## R1-01～03独立复核

1. **R1-01（安全）PASS**：`ConversationAtomicSendService`传通用title/body及最小消息指针；`NotificationService::createForUser`集中屏蔽消息原文/发送者/payload敏感字段；`presentationForUser`不信任旧通知payload，仅验证当前live_read、实际receiver及真实room后产生有限导航，异常/权限失效则通用无导航；通知四路由增加account.active。原GitHub安全原证中R1 notification10：MC ACTIVE时API body通用、可信conversation_id2，DB只存 `{source:message,message_id:5}`；block与MC REVOKED时body通用、payload/route_args空，messages/media404；disabled后旧token notification/unread401。旧Alice notification1/2已读取时隐藏明文及身份，原记录保留不改写。新的私信摘要不再明文落库。**旧0.7开发库的通知行原明文仍保留，未批量清洗；以后部署/数据迁移须具名处理存储保留政策，不把本轮API修复谎称历史磁盘清除**。
2. **R1-02（测试）PASS WITH OBSERVATIONS**：本轮typed mock断言更新为代码实际确定ID 990000499，其他identity/idempotency断言保留，相关36项Flutter exit0。两诊断测试实际带同次独立PHP虚构fixture成功，不提供fixture时仍严格失败。Codex导出固定实施起点441具名package对象、运行5文件得20通过/5失败exit1：旧受限消息文案、旧Match headline与旧synthetic UNKNOWN导航这3个失败相同，另2个必须同次fixture失败。Astra已核查相关源/测试的固定Git Blob相等和基线原始stdout；**剩余3项是已存在legacy合同缺口，不能称修复或全绿，也未证明完整旧APP均无其它问题**。现有live Match独立CN/MC与服务器使用点保护另有真实正反例，不把旧headline当权限授予。
3. **R1-03（静态检查）PASS**：旧3条info在固定基线analyze exit1可复现；仅将已锁定crypto 3.0.7声明为dev_dependency、字符串等价插值，包版本/生产依赖不升级；当前全范围与产品lib analyze均明确 `No issues found!` / exit0。

## 保留观察与收尾

- R1相关PHP **27/332 exit0**（vendor deprecations 2）；初始相关PHP **139/1162** 及后续匹配投影 **5/34**均有旧成功原证，不累加成新的独立覆盖数。R1 Flutter带fixture全套**821通过3失败exit1**，普通**793通过5失败exit1**；不能写“Flutter全绿”或虚构修复。三项既有legacy测试日后在受影响功能版本按实际合同收口，**本版不再因它们重开无限返修**。
- 保留旧明文通知数据的存储审计/清理或未来真实数据迁移安全政策、旧UI合同文案、PHP8.5 vendor弃用及Android strip警告为后续具名观察，不自动升级依赖/重写历史证据。
- 未验范围：生产、真实用户与备份导入、全部9.x恢复、RTC双端/WebSocket、完整紫微与西占、Buddy/Social真业务、系统Push/地图/SMS、全部Web管理模块、R1本地新APP构建安装及全套业务重跑。全部不得由v10.0.7接受推断为PASS。
- **Acceptance：ACCEPTED WITH OBSERVATIONS（冻结v10.0.7范围）**；**GitHub产品源码集成：NOT_YET_DONE**；**本地连续基线：R1专用树CLEAN为CODEX_REPORTED，K08待接续**；**目标运行：原0.7成功，R1服务/DB/PHP-front停止、持久卷保留为CODEX_REPORTED**。本次验收文档写入main不是产品代码合并。
- 下一步遵循[CURRENT_WORKFLOW K08](../../workflow/CURRENT_WORKFLOW.md)，经Owner手动转交Codex安全集成最终接受的R1代码、保留main文档与候选安全证据，按实际源码差异选择必要回归；不默认新worktree/全历史复测、不触碰dirty根。**v10.0.8没有启动或派发**。

**终裁：V10.0.7 ASTRA FINAL ACCEPT — WITH OBSERVATIONS — R1 PRIVACY AND ATTRIBUTION VERIFIED — K08 INTEGRATION PENDING。**
