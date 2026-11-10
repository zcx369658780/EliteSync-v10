# EliteSync v10.1.4｜Owner批准的单次安全集成与连续代码基线｜Codex唯一综合任务

2026-10-21｜Astra签发。**OWNER_APPROVED_SINGLE_SAFE_INTEGRATION / READY_FOR_OWNER_MANUAL_DISPATCH / V10.1.4_FUNCTION_ACCEPTED_WITH_OBSERVATIONS / INTEGRATION_NOT_STARTED / V10.1.5_NOT_STARTED**

Owner已明确批准v10.1.4**单次安全集成**。这是对功能已接受候选的一次字节身份准确集成，不是重新开发、返修R1、重新核验整个App、重跑旧算法或进入v10.1.5。由Owner将本任务手动转交本地Codex后，Codex可在下述边界内自主完成安全代码集成、最小静态校验、正式文档归档、必要状态和本地干净连续代码基线接续、非作者有界静态复核、普通non-force发布和远端回读；不要反复要求微任务审批。Codex不得自行写`INTEGRATION_ACCEPTED`，最终第二道独立验收属于Astra。

## 一、角色、现行工作流和不可变验收身份

- Owner：最终产品、外部/付费/真实身份和数据用途、不可逆资产决定权限；此次仅批准**本版单次安全集成**，不授权生产/真实活动/身份供应商/清理/新版本。
- Astra：已经直接发布 `docs/versions/v10.1.4/acceptance.md`，结论`V10.1.4_FUNCTION_ACCEPTED_WITH_OBSERVATIONS`，B1（退出后合法最小报告）与B2（已收案最小历史来源的受控调查连续性）同版R1关闭。本次集成后仍由Astra独立接受，不由作者代录最终裁决。
- Codex：只可使用以下已接受源码，不许私自补修不属于接受Git对象的代码或修改冻结AC。正常代码对象操作自动完成；发现未知产品后继、真实风险或权限越界，停受影响部分集中报告。

**首读**：
`docs/workflow/ACTIVE_STATE.md`、`docs/workflow/CURRENT_WORKFLOW.md`、`docs/workflow/ACCEPTANCE_INTEGRATION_SOURCE_SYNC_20261021.md`；
`docs/versions/v10.1.4/plan.md`、`task_order.md`、`ASTRA_REVIEW_AND_R1_TASK_20261021.md`、`acceptance.md`；
`docs/versions/v10.1.3/integration_acceptance.md`；Owner2026-10-19决定及后续路线。旧动态目录里的“当前/未接受/待集成”仅为当时快照，不据此重派。

| 对象 | **唯一固定Git身份** |
|---|---|
| Astra功能接受文档 | `docs/versions/v10.1.4/acceptance.md` Blob `f9a82ff9174c59d5e1506af881046df02f7a7d70` |
| 冻结plan | `docs/versions/v10.1.4/plan.md` Blob `6f4157eeee47bc8d2fc4bbda5767025de0691347` |
| 综合原任务 | `docs/versions/v10.1.4/task_order.md` Blob `67f01f8841a7882a907d1782136ff520caed977c` |
| Astra R1冻结任务 | `docs/versions/v10.1.4/ASTRA_REVIEW_AND_R1_TASK_20261021.md` Blob `36d6b3549e0fd1dff2fc44f6db72ac62c7d4f0fa` |
| 原源码Commit | `e7e246dc70f72846a05a31e022efadee0838ab83` |
| 原完整交付Commit | `4f303bc3674edc599c9602e6704a97deb6dce4ba` |
| **最终接受R1源码Commit** | **`1062603bfd5866eb4c40b4773657343a1eca2af7`** |
| 最终接受Root Tree | `aa4c47569d60a5e5638c25e9b0e3c0d7e1760da5` |
| **接受完整apps Tree** | **`3468a3dd97da7accfda2539a0f8d8f68931a6110`** |
| **接受完整services Tree** | **`0cb1f9d19659291a462488b3686fd0a07a6698ac`** |
| R1最终完整交付Commit | `01622dfffc48649911fd88f0cd0a9ed340260d37` |
| R1交付Root Tree | `ce17197dccbdac481e3d39b767c8a6758502a546` |
| **最终唯一实施报告** | `docs/versions/v10.1.4/IMPLEMENTATION_REPORT.md` Blob `d34b7ea10e6d5fb6024a1911fcde570794cd7e32` |
| **原制品清单** | `docs/versions/v10.1.4/artifact_manifest.json` Blob `107817209f195d183392f3a6fda96d456fd5059f` |
| **R1制品清单** | `docs/versions/v10.1.4/artifact_manifest_R1.json` Blob `9772bf5f43c12443951852cf47de12747df5f108` |
| 原审阅Commit | `8e639a3f22fe85eaf267f518c7205e4973dd5092`（39份脱敏文本，独立分支） |
| R1审阅Commit | `d59cb76d41a0a0d81947d584ac6228554c82fda0`（36份脱敏文本，独立分支） |

当前签发时live main `fb3da748d9fa46d6325cee78d950fb1b0b745628` / Root `8fd7259cfbf2124fe7ee2722e65ace34a2e5d623`，当前仍是已接受v10.1.3产品apps `d4569b330629d74c6e5f3ee1d6438245d7bfd024` / services `4d637a3fd827e00974887d9ce515a1833a8f3a8a`。**开工前必须实时GET live origin/main及其Commit/Tree**；上面SHA为签发快照不是永久父对象。产品若仍无额外并发变化，接受源码相对于此main为**39个产品文件路径差异（19新增、20修改、0删除）**，而不是原v10.1.4的36项或者R1最近9项；两条分叉的Git commit历史绝不能整体merge覆盖当前docs。

## 二、保护及归属

在动任何树之前核相关工作树HEAD/branch、index/tracked/untracked/ignored、必要受保护原件hash与资源归属。包括：原dirty `D:/EliteSync-v10`、旧`D:/EliteSync`、v10.1.1事故恢复资产、v10.1.2/1.3/1.4各已归属树、原SQL/备份/volume、v10.1.4首轮与R1两版APK/签名、现场截图日志及39＋36短期审阅证据。仅检查本任务必要的保护范围，不全盘考古/盲跟踪其它项目；不用固定保护根数量充作强制质量指标。

- 优先复用已经验证归属且干净的v10.1.3连续**代码**基线；该树若已有受保护未提交成果则不动，只在必须时使用**一棵**新隔离集成树。
- 禁止对未知或受保护根执行盲`pull/reset/rebase/stash/clean/prune`、强制推送、删worktree/分支/旧卷/备份，禁止迁移/恢复/seed旧库、移动原设备资料或泄露本地凭据。
- 短期脱敏审阅原分支保留HEAD及文件字节；**不合入main，也不自动删除**。历史失败原样保留。

## 三、精确产品集成（唯一产品提交）

1. 实际确认开始时live main/Root/apps/services；验证接受源码Commit `1062603...` / Root `aa4c475...` 与两个完整Tree对象均存在。若当前main产品与上表的v10.1.3已接受Tree不同，查明是否有合法并发产品后继；无法精确判断时暂停可能覆盖的产品集成，绝不硬覆盖。
2. 从真正live main派生本次具名候选分支（建议`codex/v10.1.4-safe-integration`，也可使用经核归属的等价安全分支），使用干净索引从Git对象级**准确引入完整接受apps/services两个子Tree**，不得以`git merge`整个旧R1候选历史替代。
3. 创建仅包含产品路径的正常**单亲本Commit**；唯一parent必须为真实执行前main，而不是签发快照或旧候选分支。逐path/type/mode/blob核对真实39处增改（从实际main起始若已有合法文档后继，其产品变更数仍应一样），并以两个完整产品Tree SHA **精确相等**作为必要门禁：apps=`3468a3dd97da7accfda2539a0f8d8f68931a6110`，services=`0cb1f9d19659291a462488b3686fd0a07a6698ac`。
4. **产品提交不能改docs及任何其它合法main顶层对象**；不能重新规范化CRLF、批量格式化已接受源码、增依赖或修改版本Manifest。接受的源对象如果需要真实产品修复，应停报Astra另裁，不私改后仍沿用接受名号。
5. 先核精确静态差异再按允许normal non-force/原子push发布；主分支如已并发前进只可有界分析纯文档后继并重新建立正确parent，不能force、绕过保护或丢掉别人文档。

## 四、正式长期归档（唯一集成报告）

从固定最终R1交付 `01622dff...` 原样获取：
- 最终`IMPLEMENTATION_REPORT.md`，Blob=`d34b7ea10e6d5fb6024a1911fcde570794cd7e32`；
- 原`artifact_manifest.json` Blob=`107817209f195d183392f3a6fda96d456fd5059f`；
- R1`artifact_manifest_R1.json` Blob=`9772bf5f43c12443951852cf47de12747df5f108`。

`acceptance.md`由Astra已经直接签署，**保持原Blob**。plan/task_order/R1 Task、Owner决定、v10.1.3双重接受、2026-10-21工作流补充、ACTIVE_STATE、版本索引及memory导航保持当前合法文档。旧动态标题“NOT_ACCEPTED/待Owner确认”是过去时点证据，不追改旧报告；仅在`ACTIVE_STATE.md`及必要索引顶端做简短新当前状态，不反复增一长段历史。

**只新建一份**`docs/versions/v10.1.4/integration.md`（Codex实际安全集成回执），包含真实执行前main/Root/product身份、产品单亲本Commit/Root和接受子Tree、正式文档与报告Blob、必要静态检查exit、状态更新、非作者有界静态review、保护和NOT_RUN及远端readback。不能在integration报告中声称“Astra安全集成ACCEPTED”或用不可成立的最终自身Commit SHA自引用；最终main/Tree可只在最后Codex回执消息给出。

**两套脱敏审阅目录禁止进入main**；原候选与R1候选和历史失败分支不移动、不清理。

2026-10-21的ChatGPT Project Sources已由Owner此前手动更新，但GitHub的原ZIP字节镜像仍`BYTE_MIRROR_PENDING`，这是独立长期文档缺口，不是v10.1.4集成阻断。若Owner将SHA256 `6781b7e8319037770780cfb202b6f37071031d8c9cec0bb969e39cf082c65c6f`的原ZIP放入**本任务可读的具名安全目录**，可按既有版本化工作流最小同步并真实逐项hash；否则只延续PENDING，不在本次安全集成时重建/搜索全盘/伪造镜像/触碰既有语义候选，不另开治理长任务。

## 五、有界静态门；默认不重复功能测试

核验如下最小集合：
- 唯一产品集成Parent=执行时main，完整apps/services Tree=上述接受Tree；预期39处文件差异逐path/mode/blob、无unmerged index、`git diff --check`按Windows历史CRLF规则作有效判断（不修改原接受Blob）。
- 关键R1新增Service`SafetyParticipation/SafetyCaseService/PlatformEventService`及迁移`2026_10_21_200000_add_safety_case_source_seals.php`、受影响PHP/Blade路由/测试进行必要`php -l`静态语法核验；JSON两个manifest实际解析与Blob一致。确认`tests/TestCase.php`、`phpunit.xml`和`config/database.php`中的测试连接隔离与`APP_DB_CONNECTION`有效选择源合同，没有静态检查期间初始化未知Laravel.env/未知数据库。
- 源树没有重新格式化、凭据、原APK/截图/SQL进入Git；docs保持原main、功能接受和历史Owner/roadmap/恢复点。
- 本版本功能候选已证明的受控数据/APP证据保持引用身份，但**无需本轮再次重跑**后端原51/1182及R1的28/1644、Flutter原30及R1的15、87张表/10张表持久性、原/R1精确MariaDB RR、APK构建/安装/回取/真实手机/RTC/云端。其执行层统一`CODEX_REPORTED / LOCAL_ONLY`，本轮`NOT_RUN`不等于新物理基线验证通过；apps字节**同已接受Tree**因此不需要重新APK构建。
- R1新APK可保留其正式manifest身份`com.elitesync.v1014dev`，version`10.1.4-dev/1010401`，签名SHA256`9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`，APK／安装pull SHA256`76e43dc2b9f187ec2824bbc636ae42b32cf30b95c90ea66158b1550182938eec`。本次仅视为原Codex已报告的受控APK，不以Git源码Object替代设备运行。

## 六、发布与连续本地代码基线

在受保护的干净代码树把安全集成后的main准确同步：仅无损移动本次归属的Git状态，记录实际HEAD／main等同性与无tracked/untracked变更，以及保护原dirty根和所有SQL/APK不变；如有受保护/ignored资产，不移动不清除。若只能确认源码一致、不能确认实际服务，标`LOCAL_CODE_BASELINE_CODEX_REPORTED`和`RUNTIME_NOT_RUN`，不要暗示数据库已连通。

普通`non-force`提交和推送产品集成后，再提交最少正式文档，最终独立HTTP/REST GET回读：live main Commit/Root、产品提交Parent、完整apps/services Tree、报告与原／R1 manifest Blob、Astra原功能接受/工作流Owner原件，以及旧候选/短期review refs HEAD。后继文档不能再修改已接受的两个产品子Tree。必要记录真实exit/stderr/回读失败及重试，不凭一张截图宣称所有字节已检查。

本次**全部NOT_RUN**：MariaDB、Laravel/API、迁移/种子/SQL/备份恢复、Flutter/PHPUnit运行、模拟器/手机/ADB、APK重新build/install、RTC/AEC、WS、Web真实功能、支付/Push/实名/外部AI/云端/公网/备案/场地/真实用户、所有清理历史和v10.1.5。

## 七、交付终态与不得跨门

集中交一份`docs/versions/v10.1.4/integration.md`，与正式R1报告/两个manifest及最小状态更新一起发布；最后消息给最终main Commit/Root Tree、apps/services Tree、产品集成Commit唯一Parent、完整path/mode/blob校验数量和测试真实exit、连续代码基线、五类历史原证保护及明确所有NOT_RUN。以Astra后续独立验收为唯一`INTEGRATION_ACCEPTED`依据。

**正常出口**：
`V10.1.4_SAFE_INTEGRATION_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_INTEGRATION_ACCEPTANCE / COMPLETE_PRODUCT_TREES_MATCH_ACCEPTED_SOURCE / V10.1.5_NOT_STARTED`。

遇产品并发来源冲突或原重要资产风险则如实`BLOCKED / PARTIAL`并保存已完成结果，不能force覆盖，也不能启动新版本或清旧库/审阅分支。**不可自行宣布ACCEPTED，不可自动启动v10.1.5**。
