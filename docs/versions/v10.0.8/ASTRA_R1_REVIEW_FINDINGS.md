# EliteSync-v10｜v10.0.8 Astra独立候选审查 R1 定点返修意见

2026-10-15。**V10_0_8_INITIAL_CANDIDATE_REVIEWED / TARGETED_R1_REQUIRED / NOT_ACCEPTED / ORIGINAL_AC_UNCHANGED / NO_MAIN_PRODUCT_INTEGRATION / NO_V10_0_9**。

本文件是Astra使用已授权GitHub连接对固定初始候选的独立审查，不修改[唯一冻结v10.0.8计划](https://github.com/zcx369658780/EliteSync-v10/blob/ac57d3370a2f2f17c042987a758d86c9aa725650/docs/versions/v10.0.8/plan.md)或Owner决定，不新增AC或重做已验v10.0.6/0.7/K08，也不把候选自报提升为独立ACCEPT。

## 1. 固定Git身份、材料和证据级别

- 实施技术起点：`a75b8d4061ae012937ef4823120b396f257d3aec`，Tree `89637891276cdf4280f918ccad7eb4c5030f55be`。
- 唯一冻结计划：Commit `ac57d3370a2f2f17c042987a758d86c9aa725650` / Blob `0856e7372d1f91fadfa3350b30f926f7af9cf809`；8项 `AC-08-01～AC-08-08`保持不变。Owner D1/D2/D3：Commit `cacfa889128f9a3a4b443efa87f4c347a178f1d5` / Blob `4f84f1968ee2737b842f828ad2e0cbdd5c929936`。
- 初始候选 Commit `cff049ae602049adf49014ec2ed27963dc40aff5`，Tree `0da1d69a06a91be3c765d9f4bb6a1febac69d08f`。GitHub现核 `codex/v10.0.8-web-admin`远端HEAD与候选完全一致；相对技术起点16 ahead/0 behind、merge-base精确为技术起点。产品源码锚 `1f73a80afd2e0678006ce62e019235dc5ec36374` / Tree `9f7071412a0341604563ee73a9556116b6b1bc28`；锚后仅1笔报告/证据提交，`apps/services`源码未变。
- 验收前main仍是 `e1dec331d7fc4d6d42fb2fffa63e02987d52e4a0`；产品候选未合main。
- Astra实际独立读取[EXECUTION_REPORT](https://github.com/zcx369658780/EliteSync-v10/blob/cff049ae602049adf49014ec2ed27963dc40aff5/docs/versions/v10.0.8/EXECUTION_REPORT.md)、[TEST_RESULTS](https://github.com/zcx369658780/EliteSync-v10/blob/cff049ae602049adf49014ec2ed27963dc40aff5/docs/versions/v10.0.8/TEST_RESULTS.md)、[manifest](https://github.com/zcx369658780/EliteSync-v10/blob/cff049ae602049adf49014ec2ed27963dc40aff5/docs/versions/v10.0.8/manifest.json)、Runbook、原始安全stdout/stderr/exit与关键HTTP/DB结果、管理服务/授权/worker/问卷源码及PHP测试，并以base64实际读取查看Blade/APP固定截图。Owner转来的Blade发布版本截图与GitHub固定截图呈现一致。不是将全部INDEX证据逐个下载，也不是Astra在Windows本机运行服务、MariaDB或AVD；实际物理APK/AAR及LOCAL_ONLY原证仍**CODEX_REPORTED**。
- 实读最终PHP原始stdout：146 tests/1457 assertions、2 vendor deprecations、exit0；Flutter相关41与30项分别exit0，范围不同不累计；全范围Flutter未跑，旧0.7的3项历史失败/exit1保留；全范围Dart analyze原stdout `No issues found!` exit0。最终AAR/host Build05 `BUILD SUCCESSFUL` exit0、APK install `Success` exit0、设备回读SHA相同（物理hash由Codex本地计算）。不宣称全后端/全Flutter测试已PASS。
- 固定源码APK本地sha `f2e025c9e9f3d4ace1183467d8f753ed5b7ffd395cf0793d323abdc3ef15b11d`，AAR `a22561393b09f6e57e1ef913fa174b1fbe6120b91d073ad3ec05c778308a27c9`，版本0.08.04/80400；两包仅Windows LOCAL_ONLY，Astra未直接计算物理SHA。

## 2. 本版确有独立证据支持的业务成果（保留，不重做）

- **AC-08-01**：独立Blade session登录轮换、logout、CSRF419、stale409、同revision并发[200,409]及角色/名单/禁用旧会话拒绝；同库审计存在。具体回执`evidence/session-rotation-real.json`、`web-real-csrf-version-concurrency.json`及固定Web截图。
- **AC-08-02**：UserGovernance共用User行锁、DisableUser凭据/会话撤销，原API和Web禁用合流；最终Alice ID2禁用、token/session撤销、APP回登录、Bob正常。真实`after-final-disable.stdout`、`app-final-disabled-session.png`和数据库快照；原禁用前持久session属于具名非Web fixture，不能误称Alice真实浏览器会话。
- **AC-08-03**：D1运营审核approve/pending/reject及理由/APP卡片；ProfileReadinessService及MatchingRun最终资格回读使用真实审核/有效题条件。历史Match/CN/MC仍在DB。
- **AC-08-04除申诉缺口外**：举报公开动态→Web处理和软删，restricted停止新匹配/公开发布和**双方新私信收发**，仍能按当前合法授权读取历史；banned/restore的token/MC、独立处罚前态等有源码、测试与实际HTTP/DB正反例。原R1隐私通知继续无泄漏/无撤权后导航。
- **AC-08-05**：Blade匹配执行→数据库队列Job→consumer终态、轮次、零候选、失败lease及重试新attempt、题库变化的input_changed、reveal/close与APP站内事件均有真实快照；不能把后续pair0当新匹配成功，交付报告已如实区分。
- **AC-08-06**：题目影响dry-run/签名/revision审计、旧answers/attempt/Match保留，Alice有效题20→19不足→补答恢复，DB重启比较具名记录。
- **AC-08-07**：Blade Android development release活跃版0.08.04/80400；同库APP About版本中心显示`development / database / 0.08.04`，停用时显示config fallback；没有声称APK URL实际提供文件、系统Push或生产发布。
- **AC-08-08的材料**：最终AAR/APK构建/安装及设备sha回读的本地原证、联合Web/Laravel/worker/同volume MariaDB/APP重启前后24字段一致的公开记录；最后自有服务停止、原0.6/0.7卷与dirty根保留属CODEX_REPORTED。全范围Flutter本版NOT_RUN，不在此伪造通过。

## 3. 唯一必须返修：R1-01｜Restrict被处罚账号没有真正可用的本人申诉入口

**对应已冻结D2与AC-08-04，不是新增功能。** D2原文要求受限用户保留“登录、合法历史只读和申诉能力”，AC-08-04亦要求restrict保留“合法历史只读/申诉”。

Astra实际读取初始候选：
- `services/backend-laravel/routes/api.php`的`POST /api/v1/moderation/reports/{reportId}/appeal`唯一可见的appeal API；
- `services/backend-laravel/app/Http/Controllers/Api/V1/ModerationController.php::appeal`：查询`ModerationReport`时强制`where('reporter_id', currentUserId)`，只允许**举报人**更新该举报的`appeal_status/appeal_note`，被举报、随后restrict的`target_user_id`无权就**自己的处罚**走该入口；
- `services/backend-laravel/tests/Feature/ModerationApiTest.php::test_report_block_and_appeal_flow`测试中仍由最初举报者提交appeal，未证明受限目标账号申诉；
- 本版新增`admin_sanctions`有可靠sanction ID/actor/reason/active/report_id和恢复审计，但现有路由、Controllers及本版测试中没有独立“受限者对自己当前有效处罚提出申诉”的处理器、持久动作或APP有效入口。Web report页面的“申诉说明”属于原举报记录字段，并非处罚对象已提交的申诉。

因此，**已实测“受限账号能继续合法历史只读”，但未交付“受限账号能够就其本人处罚申诉”**。仅保留受限账号的登录token、允许举报者申诉，或在文案写“可申诉”都不能通过原冻结D2/AC-08-04。

**定点R1应实现并提供：**
1. 在已有v10.0.8受控真实开发环境中，给已登录且`restricted`、拥有本人的可追溯活跃处罚的虚构用户一个真正能提交处罚申诉的具名可用入口。可选最小Web/APP入口与独立受保护API，由Codex在冻结边界内选择，不建立外部申诉平台或新管理员体系。申诉对象绑定服务端当前身份与当前active sanction（必要时关联report），不能由客户端传别人的user_id、偷看举报人、目标消息或密钥。
2. 申诉记录必须持久、可由已授权管理员在现有Web举报/用户管理页最小化查看，并有可信actor、sanction ID、时间、必要安全说明、状态及审计。不把举报者现有`appeal_status`冒充处罚对象申诉，不将申诉自动当作已核实事实、自动解除restrict或恢复原token/MC/Connection。
3. 实际**虚构被限制用户**使用真实APP/具名用户入口发起→真实Laravel认证/授权→v1008独立MariaDB落库→管理员现有Blade可核查；重复、非处罚本人、非active/已restore、普通越权与disabled旧token等有负例；申诉内容不上公共列表/不泄露举报人身份，存储/日志最小化。受限用户继续能读合法历史但不可新增发消息/发布/参与匹配。
4. 仅对相关受影响代码运行安全测试与真实HTTP/数据库/APP验证；如修改Flutter/Android产品源码，必须重建最终AAR/debug APK并安装关联hash，否则以Git子树身份证明包可复用。重启数据库后申诉状态仍在、没有重seed或清理旧业务；保留最初成功业务和失败日志。
5. `ModerationController::appeal`现有举报者申诉合同可独立保留，不得将其直接改成对所有target开放；区分“举报人申诉”与“受处罚者申诉”，不擅自增加自动处罚复核政策。若实现涉及超范围真实法律身份/外部第三方服务，只报告该具体部分的风险；一般本地安全入口不需再问Owner。

## 4. 状态及下一步

| 冻结AC | 初审状态 |
|---|---|
| AC-08-01、02、03、05、06、07 | **核心真实证据支持，等待最终联合裁决** |
| AC-08-04 | **TARGETED_R1_REQUIRED：restrict受限者本人申诉未交付；其它处罚、举报和合法历史读回已有证据** |
| AC-08-08 | **交付证据支持，最终产品包身份需随是否修改客户端更新；保持全量Flutter NOT_RUN** |

**终裁暂缓：NOT_ACCEPTED_PENDING_TARGETED_R1**。固定plan Blob `0856e7372d1f91fadfa3350b30f926f7af9cf809`和Owner政策不改、不合并产品main、不启动0.9。保留最初候选和真实 Web/APP/DB、Matching、问卷、版本及联合重启原证；一轮同版最小返修后Astra只重验缺口及受影响回归，不强制重做B01～B06或重复0.7/K08。
