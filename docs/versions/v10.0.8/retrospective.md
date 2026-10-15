# EliteSync-v10｜v10.0.8 Astra版本复盘（已接受初始业务＋R1）

2026-10-15。版本状态：**ACCEPTED WITH OBSERVATIONS / R1-01 OWNER SANCTION APPEAL CLOSED / K08 PRODUCT INTEGRATION PENDING**。以[唯一冻结计划](https://github.com/zcx369658780/EliteSync-v10/blob/ac57d3370a2f2f17c042987a758d86c9aa725650/docs/versions/v10.0.8/plan.md)的8项AC与Owner批准D1/D2/D3为准；最终被接受候选`d37121eb11d3cc845f1606a631d17ca01fe6105a` / Tree `6d260f525de8976b7aea5e4a1fe6c9282d91a332`。正式[独立验收](acceptance.md)记录源码、原证/Windows访问边界及观察项；不重新发布一个平行真值。

## 交付结果与实际推进价值

本版把v10.0.6已通过的Blade登录/禁用雏形扩成**独立可操作的Web管理模块B01～B05＋B06本地Android开发渠道版本管理**，不是Flutter里的一组管理假页面：Web session/CSRF与管理员白名单/角色；同事务用户处罚/限制及会话撤销；D1运营资格接真实APP和新Matching；D2举报处理/受控恢复；Blade发起Matching queue并由worker完成真实run和发布；D3问卷preview/prune与当前资格、历史快照的兼容；Web release元数据与APP version check/DB读回。源码与真实虚构账号MariaDB、Web/APP截图、必要服务/DB/worker重启相互对应。其结果不意味着原9.x全部能力或生产/真实业务数据已经恢复。

初始候选`cff049ae602049adf49014ec2ed27963dc40aff5`曾因R1-01 **被restrict的账号没有本人处罚申诉入口**未被接受。Astra指出旧`/moderation/reports/{id}/appeal`是`reporter_id`的举报申诉，不是被处罚target用户申诉；若只复用旧接口，会让Owner D2“受限仍可申诉”流于页面文案。Codex在原0.8版本内新增独立可信账号入口、sanction_appeals持久存储、服务端锁/归属/active restrict安全校验、受授权管理员Blade查看与轻量view审计，且不把申诉等同自动解罚。一次集中R1复核通过，没有扩大为R2或退回B01～B06重新开发。

## 可复用的工作流经验

1. **顾问交接可无损继承已冻结AC**：上一会话GitHub归档Commit`38f5ee6814e52cfa1391e1c59f87f7b70fecd45e`与Blob`9ae48420a425de714fc19885a5b63f9a1e6e31a1`，新会话实际读取原冻结plan、Owner决定、旧R1审查和实时候选。没有因切换会话重复派发、重做功能设计或重新确认D1/D2/D3。
2. **产品权限不能靠邻近入口替代**：举报人的appeal与被处罚用户的appeal是独立权利/身份。必须以服务端受罚账户、当前有效sanction、状态/复权/并发为界，而不是将旧`reporter_id`判断全局移除；管理员view也需名单＋role和不复制敏感说明的审计。
3. **原目标内缺陷定点修，保留真实成功证据**：R1仅变更10个源码/测试文件，与初始候选相比前进2commit；既有Matching、问卷、版本、处罚正常路径保持业务hash。没有重做0.6、0.7或0.8所有场景，没有把fixture Match2当新匹配consumer成果。仍以跨端真实业务和重启验证为完成门，而非提交次数/文档数。
4. **原始失败的退出码与业务结果须同时看**：首次R1数据库migration在Docker尚未ready时exit1，ready后成功；首次append fixtures出现SQL QueryException却exit0，明确BUSINESS_FAILED并在事务回滚后以新合法fixture修正。PHP先RED后GREEN，Flutter原测试fixture/滚动修复前exit1后相关21项通过；所有原失败和vendor弃用不删除。
5. **证据分层避免二次证明膨胀**：Astra读取GitHub源码与关键JSON/raw stdout、实看APP和Blade截图；Windows本地物理包与进程/工作树仍只能`CODEX_REPORTED`。`web-appeal-readback.png`、`web-restart-appeal.png`的相同Blob说明不能将两个文件名当两次独立截图；但重启后数据库不变、APP刷新与追加管理员audit提供足够交叉支持。未来证据索引应更注重独立性、来源与真正改变的受影响范围，减少重复图片。
6. **产品候选与发布元数据需在正式分发前再对齐**：R1客户端有新APK SHA，development channel存储的是初始0.8候选版本（相同0.08.04/80400）的旧包hash；原B06仅实际证明版控metadata闭环，未验证托管URL/下载及R1新APK入release记录。不能称R1物理包已从Web更新渠道正式发布，也不因固定AC未要求发行而在验收之后添加新门槛。准备真实内测或包分发时务必通过具名新版发布操作更新版本/sha与实际可下载URL。
7. **跨端隐私避免派生泄露**：v10.0.7 R1通知投影修复继续生效，0.8申诉说明仅本人和有权管理员可查；审计不存说明正文；历史开发库旧通知明文仍属独立保留观察。新申诉状态`submitted`只是登记，不是自动裁决/恢复MC/令牌/发布资格。自动审批与运营申诉处理政策不因这个UI自然获批。

## 保留缺口与下一门

- R1相关PHP **31/367 exit0（2 vendor deprecations）**、Flutter相关**21 exit0**、全范围Dart analyze `No issues found!` exit0、最终R1 AAR/debug APK构建/安装exit0；R1全PHP/全Flutter suite和新Matching worker均NOT_RUN。原0.7旧Flutter带fixture821/3 exit1、0.8初始测试与失败留存，不重写为全绿。
- R1物理 debug APK SHA`76817f85f8267552f23e07deb08bbf93879719f9606c4bf9096800a03dfed43b`；release AAR SHA`72e04eb1ef628870a6f66cd969c3239debdc940f26b7d2d6416acc5430187562`，仅本地LOCAL_ONLY。R1不代表Web发展渠道已更新至此物理包。
- v10.0.6/0.7仍限定验收并已K08；原dirty根、不相关LOCAL_ONLY、v10.0.6/0.7验收卷及历史SQL/VHDX保护保持；真实账号/生产/供应商费用与身份认证未获本版授权。
- **主APP仍待完整恢复**：RTC双端音视频、完整紫微与高精西占及算法/许可、Buddy/Social真业务、旧其它媒体类型、地图/系统Push、获准历史数据/附件，软件说明/跨端联合终验尚待具名交付。不能因为管理后台已接通就将它们静默延后至半年至一年内测运营结束。
- 四种状态：`Acceptance=ACCEPTED_WITH_OBSERVATIONS`；`GitHub product integration=K08_PENDING`；`Local continuation=CODEX_REPORTED R1 worktree CLEAN, K08_PENDING`；`Runtime=R1真实开发链已演示、最终服务/DB/AVD停止且持久卷保留（CODEX_REPORTED）`。本文提交main仅保存版本验收/复盘，**不是产品源码已合main**。
- 后续按[CURRENT_WORKFLOW K08](../../workflow/CURRENT_WORKFLOW.md)，由Owner**手动转交Codex**进行final R1候选安全代码集成、与main文档双向保护及本地连续接续；必要差异回归，禁止强制重建worktree/全历史重审/覆盖dirty根。v10.0.9**未启动、未冻结或派发**。

**复盘终点：V10.0.8 ACCEPTED WITH OBSERVATIONS — R1 SANCTION APPEAL VERIFIED — K08 PENDING — NO NEXT VERSION AUTO DISPATCH。**
