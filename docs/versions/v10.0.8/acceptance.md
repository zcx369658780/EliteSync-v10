# EliteSync-v10｜v10.0.8 Astra最终独立验收（初始候选＋R1）

2026-10-15。**FINAL: ACCEPT WITH OBSERVATIONS / R1-01 VERIFIED / FROZEN AC-08-01～AC-08-08 RETAINED / GITHUB PRODUCT INTEGRATION NOT YET DONE / K08 PENDING / V10.0.9 NOT STARTED**。

这是一份Astra从GitHub原始源码、关键HTTP/DB/APP/Blade证据和日志作出的独立结论，不是Codex自评，也不表示Astra亲自连接Windows、MariaDB/AVD或下载物理APK。严格按[唯一冻结plan](https://github.com/zcx369658780/EliteSync-v10/blob/ac57d3370a2f2f17c042987a758d86c9aa725650/docs/versions/v10.0.8/plan.md)（Commit `ac57d3370a2f2f17c042987a758d86c9aa725650` / Blob `0856e7372d1f91fadfa3350b30f926f7af9cf809`）的AC-08-01～08裁决；Owner[D1/D2/D3批准](https://github.com/zcx369658780/EliteSync-v10/blob/cacfa889128f9a3a4b443efa87f4c347a178f1d5/PRODUCT_DECISIONS.md) Blob `4f84f1968ee2737b842f828ad2e0cbdd5c929936`均不改变。

## 一、固定身份与证据分级

| 身份 | 不可混淆的实际提交/Tree |
|---|---|
| 技术实施起点 | `a75b8d4061ae012937ef4823120b396f257d3aec` / `89637891276cdf4280f918ccad7eb4c5030f55be` |
| 已审原始候选（R1前、非最终接受） | `cff049ae602049adf49014ec2ed27963dc40aff5` / `0da1d69a06a91be3c765d9f4bb6a1febac69d08f` |
| R1产品源码与本轮构建锚点 | `788f7d13927d57e6f31a22b5ce1a990b98bd2f53` / `e8ef3f5f1157011df59f415704df5df649cb712c` |
| **最终被接受的R1候选** | **`d37121eb11d3cc845f1606a631d17ca01fe6105a` / `6d260f525de8976b7aea5e4a1fe6c9282d91a332`** |
| 独立候选分支 | `codex/v10.0.8-web-admin`，GitHub实核HEAD一致；相对初始候选ahead2、behind0、merge-base精确等于初始候选 |
| 当前产品main | 尚未将R1候选集成main。接受/复盘纯文档提交不构成产品集成或本地K08。 |

Astra实际读取初始 [EXECUTION_REPORT](https://github.com/zcx369658780/EliteSync-v10/blob/cff049ae602049adf49014ec2ed27963dc40aff5/docs/versions/v10.0.8/EXECUTION_REPORT.md)、[Manifest](https://github.com/zcx369658780/EliteSync-v10/blob/cff049ae602049adf49014ec2ed27963dc40aff5/docs/versions/v10.0.8/manifest.json)与初始Web/APP、Matching/处罚/问卷/版本关键原证；[Astra初审R1](ASTRA_R1_REVIEW_FINDINGS.md)；最终[R1执行报告](https://github.com/zcx369658780/EliteSync-v10/blob/d37121eb11d3cc845f1606a631d17ca01fe6105a/docs/versions/v10.0.8/R1_EXECUTION_REPORT.md)、[R1 Manifest](https://github.com/zcx369658780/EliteSync-v10/blob/d37121eb11d3cc845f1606a631d17ca01fe6105a/docs/versions/v10.0.8/R1_manifest.json)、[R1_TEST_RESULTS](R1_TEST_RESULTS.md)、Runbook、原始receipt/stdout/stderr、真实HTTP及MariaDB JSON快照、PHP/Dart源码与测试；对多个GitHub截图使用base64下载查看。用户发来的截图是同一Blade申诉视图的补充参考。GitHub以外Windows文件内容与APK/AAR物理SHA为**CODEX_REPORTED**，未将路径视为已由Astra读取。R1发布索引134个文件，Astra按关键证据抽核，**未宣称逐项阅读全部134项**。

GitHub独立比较：R1相对初始候选新增/修改**10个**产品源码和测试文件，涉及Flutter Me及处罚申诉组件/测试、PHP API/共享服务/迁移/Blade/API route/测试；自R1源码锚点至最终候选仅证据和动态状态文档，apps/services/题库对象无进一步产品差异。原举报者`ModerationController::appeal`保持原权限合同。

## 二、原冻结AC-08-01～08的最终裁决

| AC | 终裁 | 依据及必要限定 |
|---|---|---|
| **AC-08-01** Web会话/管理审计 | **PASS** | 初始候选已实际证明独立Blade登录、CSRF419、降权旧session拒绝、role-only/list-only/空名单及可信同库审计；R1仅给授权用户详情加受保护申诉读取，`SanctionAppeals::forAdmin`重新核当前AdminAccess，view审计有actor/target/sanction/status，不复制note；对应Web PHP正反例 |
| **AC-08-02** 用户/安全禁用和恢复 | **PASS** | 初始Blade/API复用UserGovernance/DisableUser、token/session撤销和对照用户；R1未改共享处罚写服务，已禁用Alice旧token访问申诉401，独立被Restrict用户仍能合法登录；旧凭据/MC/CN不自动恢复 |
| **AC-08-03** D1运营资格 | **PASS** | 初始候选真实Web pending/rejected/approved→APP状态/当前资格和Matching consumer，历史Match/CN/MC保留；R1仅本APP增加本人处罚申诉入口，不改D1资格/审核；新的虚构受限ID11独立演示不冒用户资格审查已变化 |
| **AC-08-04** 举报/处罚/动态及Restrict本人申诉 | **PASS，R1-01明确补齐** | 初始举报公开动态软删、D2限制/ban/受控restore和权限/审计真实证据保留；R1新增真实APP受限ID11对active Restrict #4提交appeal #1→独立Laravel身份绑定→同库写入→有权Blade显示→重启后同ID读回。非本人12为404，禁用旧token401、已restore/失效404、同文200、异文409，User锁与唯一键保护重试/受控restore竞争。申诉没有改变User/sanction/CN/MC；合法历史读200、双向新send404，原举报人appeal仍单独有效。 |
| **AC-08-05** B04 Matching真实运营 | **PASS（沿用初始真实证据）** | 初始Web真实queue worker、已发布pair1、零候选、lease失效/重试新attempt、input_changed、reveal/close及APP通知证据；R1未改Matching源码，**R1新worker消费 NOT_RUN**，新fixture Match2明确不是consumer产生；不把R1新增fixture记成新增真实匹配 |
| **AC-08-06** B05题库运营兼容 | **PASS（沿用初始真实证据）** | 初始Blade preview/dry-run/revision审计，历史attempt/answers不改、新题计数及补答与APP资格恢复；R1无QuestionOperations变更，原题库/问卷/round/run SHA在R1快照保持一致，未重seed旧验收库 |
| **AC-08-07** B06 development release | **PASS WITH OBSERVATION** | 初始Blade创建/激活/停用元数据和APP database来源0.08.04/80400回读已通过；R1新APK仅作为**未再次Web激活发布**的本地开发候选，版本号/code未变但物理APK SHA已不同，**原0.8开发channel release行仍对应初始包SHA**。R1没有验证新包下载托管/更新元数据，不宣称发布记录与R1新包hash相等；正式分发前必须另行校准发布记录和真实可用URL。固定AC不要求本版托管下载或生产发行，故不因这项明确限制新加门槛。 |
| **AC-08-08** 持久联合交付与最终包 | **PASS WITH OBSERVATIONS** | 初始全Web/APP/DB/consumer多模块联合重启证据继续有效；R1已实测新增APP及受限申诉Laravel+MariaDB+Blade、同0.8持久卷重启前后同user/sanction/appeal记录，原业务SHA一致。R1 Flutter/Android产品lib已改，新增AAR/debug APK重新build/install且设备回读hash一致（本机物理hash为Codex报告）。R1其他B01～B06完整重验、worker、全PHP与全Flutter suite **NOT_RUN**，不冒全套PASS。 |

## 三、R1-01实际身份、数据及权限安全证据

- 申诉表`sanction_appeals`：`sanction_id` UNIQUE/FK、`user_id`FK、`status/submitted_at/note`；与举报人旧`moderation_reports.appeal_note`分别保存。`SanctionAppeals::currentUser`锁当前user，检查non-disabled/active与当前moderation；`eligibleSanctions`只选本人active、未restore、kind=restrict；`submit`先重新校验处罚状态再判断同文重复。服务端从`$request->user()->id`取得user，表单的`user_id/sanction_id/status`被禁止，非本人不暴露处罚原因/举报人身份。
- 初始浏览器截图与APP截图、实际HTTP及DB读取一致：**user11 / sanction4 / appeal1 / submitted_at 2026-10-15 09:33:29**；说明`V1008R1PleaseReviewRestrictionNoAutoRestore`来自用户在APP输入。真实API `GET /moderation/sanctions`返回该申诉，Blade`/admin/users/11`显示同ID/说明，管理员访问生成`admin_operation_audits` actor1、action `sanction_appeal.view`、target1，after_state只有user11/sanction4/status而不含note。
- 初始申诉前DB快照appeals0、之后appeals1；User11一直`restricted`、`disabled=false`、`is_match_eligible=false`；ProductConnection2仍CN_ACTIVE、MessagingConsent5/6仍MC_ACTIVE（read准许仅旧内容，live_send被restrict使用点拒绝）。`history-after.json`依旧HTTP200；本人和peer12的新消息均HTTP404。点击申诉不会恢复旧凭据、独立同意或操作成功显示假象。
- peer12冒用处罚4返回404、原禁用Alice旧token401；有效同文重放200/appeal1，不同文409；独立用户13真实双HTTP得到201/200/同appeal2，实际restore占User锁后后到申诉404/等待约2.953s；恢复后的旧appeal2继续保存为历史，不因当前GET空列表而删除。
- 同一开发库`elitesync_v1008_dev:43318`、同一persistent volume，不重新seed：`restart-before.stdout`与`restart-after.stdout`数据内容及Git Blob完全相同，保留两个appeal、其归属、sanction及原0.8基础业务fingerprints；重启后再次从API和APP读user11/appeal1、新发送仍404。访问审计在截图前与重启后追加了新记录，是**允许的有因副作用**。`web-appeal-readback.png`与`web-restart-appeal.png`的Git Blob相同，**不能算两张独立拍摄的Web截图**；但DB重启后不变、实际APP重新读取及额外管理员view审计提供交叉支持，不因截图文件重复虚报不同操作。

## 四、测试、构建与保留风险

| 实际来源/标签 | 原始结果 |
|---|---|
| R1相关PHP `php-appeal-second` | 31项、367断言、exit0、2项vendor deprecations |
| R1相关Flutter `flutter-appeal-third` | 21项、exit0 |
| Dart `analyze-full` | `No issues found!`、exit0（是全范围analyze，不是全Flutter suite） |
| R1最终AAR/debug APK `build-first` | `BUILD SUCCESSFUL`，exit0，增量6 executed/32 up-to-date，有strip `libapp.so`警告 |
| 最终设备安装 `install-first` | `Success`，exit0 |
| R1旧失败保留 | `php-appeal-red` exit2（7项1 error/6 failures），`php-appeal-first` exit2（31项360断言、1 error，修key fixture），Flutter前两轮exit1；首次Docker握手迁移exit1，ready后迁移exit0；第一次append fixture虽exit0但stdout含QueryException，业务失败，后修正追加账号成功 |
| 更广PHP/Flutter | R1全后端/全Flutter **NOT_RUN**；初始0.8相关PHP146/1457 exit0、Flutter相关41和30分开exit0；0.7旧Flutter带fixture821通过/3失败exit1、普通793/5 exit1，不能冒称已修复 |

最终**R1候选**包（仅Codex本地 Windows物理原件，Astra未直接下载计算SHA）：
- debug APK（0.08.04 / 80400）：`76817f85f8267552f23e07deb08bbf93879719f9606c4bf9096800a03dfed43b`；222,632,154 bytes。
- release AAR：`72e04eb1ef628870a6f66cd969c3239debdc940f26b7d2d6416acc5430187562`；3,964,613 bytes。
- 设备回拉APK hash按Codex报告等于最终R1 debug APK。原始候选旧SHA不同：旧debug`f2e025c...`、旧AAR`a225613...`，不能被新构建/安装冒名重用。

保留观察：原0.8版本元数据指向初始包（R1未重新发布）、缺实际APK下载托管；初始PHP8.5 vendor deprecations2、历史Flutter3项旧失败exit1；Android strip警告；开发库旧通知明文的历史存储（R1 API读取保护已保留但未做原始历史数据清洗）；目前为虚构账号/独立本地环境非生产，没有认证系统、RTC真实音视频、完整紫微/西占、Buddy/Social、其它媒体、Push/地图、历史真实数据及附件恢复等完成证明。未测范围不能推断为PASS。

## 五、验收、集成、本地与运行状态四分法

- **Acceptance**：`ACCEPTED WITH OBSERVATIONS`，严格指v10.0.8冻结8项AC，本报告已经确认原R1缺口闭环；不要求R2。
- **GitHub 产品源码集成**：`PENDING K08`，仍在`codex/v10.0.8-web-admin`，**本acceptance和后续纯文档提交到main≠产品代码合并**。
- **本地代码接续**：R1候选专用工作树CLEAN为`CODEX_REPORTED`；K08尚未执行。原dirty根HEAD/index/normal status及43具名文件前后不变为Codex保护回执，不继承历史109全量核查门。
- **目标运行**：初始0.8全B01～B06受控环境实测以及R1受限申诉链/重启分别有GitHub公开原证；本轮结束后仅本版自有服务、DB容器、AVD停止、持久volume与私配保留为`CODEX_REPORTED`；不代表当前生产或用户设备正在运行。

下一步按[当前工作流 K08](../../workflow/CURRENT_WORKFLOW.md)，**Owner手动转交Codex**把最终接受的R1候选安全集成实际main、保留冻结/验收/复盘和全部原始失败、安全源码；按实改动做必要差异回归，登记集成commit/tree与本地连续基线。不强制新worktree/全量旧套件、不触碰受保护dirty根或0.6/0.7卷。**v10.0.9 NOT_STARTED / NOT_DISPATCHED**；待原版已实现主要功能恢复欠账不能在未来联合验收/内测之后静默放弃。

**终裁：V10.0.8 ASTRA FINAL ACCEPT — WITH OBSERVATIONS — R1 OWNER-APPEAL CLOSED — K08 CODE INTEGRATION PENDING。**
