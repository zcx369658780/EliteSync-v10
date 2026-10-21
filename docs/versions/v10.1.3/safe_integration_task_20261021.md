# EliteSync v10.1.3｜Owner批准的单次安全集成与本地连续代码基线｜Codex唯一综合任务

签发：2026-10-21｜Astra。**OWNER_APPROVED / READY_FOR_MANUAL_DISPATCH / V10.1.3_FUNCTION_ACCEPTED_WITH_OBSERVATIONS / INTEGRATION_NOT_STARTED / V10.1.4_NOT_STARTED**。

Owner已明确批准**本版一次安全集成**。本文件供Owner手动转交本地Codex；手动派发后允许在本冻结范围自主完成Git精确产品集成、必要静态保护检查、最少正式文档归档、非作者有界复核、正常non-force发布、独立回读和本地干净连续**代码**基线接续。无需日常逐命令请示、不再开第二份集成规划或恢复旧Work/dot任务总线。本任务**不是**重新开发v10.1.3、重复功能验收、启动v10.1.4或授权真实生产操作。Codex只可交`CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_INTEGRATION_ACCEPTANCE`，不得自行写集成已接受。

## 1. Authority、当前真值与精准产品对象

- Owner：最终产品取舍，费用、真实数据/账号、不可逆文件及系统/云端/第三方供应商权限。当前已批准本单次安全集成，不自动批准别的动作。
- Astra：已独立完成并直接归档`docs/versions/v10.1.3/acceptance.md`，裁决`V10.1.3_FUNCTION_ACCEPTED_WITH_OBSERVATIONS`；本次产品集成后的第二道独立终验仍由Astra执行。
- Codex：依本任务在受保护的本地专用环境实施，不改接受产品源码或原冻结AC。

**优先实读并按既有约束**：
`docs/workflow/ACTIVE_STATE.md`、
`docs/workflow/CURRENT_WORKFLOW.md`、
`docs/workflow/ACCEPTANCE_INTEGRATION_SOURCE_SYNC_20261021.md`、
`docs/versions/v10.1.3/{plan.md,task_order.md,acceptance.md,IMPLEMENTATION_REPORT.md,artifact_manifest.json}`、
`docs/versions/v10.1.2/{integration.md,integration_acceptance.md}`及当前Owner决定、10.x路线。历史动态索引里的旧“待验/未开工”只按当时时点解释。

Astra本单签发时直接回读的main：
- main Commit：`202bae5a67ab1feb4ad9badc9e505323c862ad29`；
- Root Tree：`8e6d8866439d45315b6f9c7dce7c9643430f3606`；
- main apps（已接受v10.1.2）：`365810451b6faad98e041835be6c86f4f81be0a9`；
- main services（已接受v10.1.2）：`96b2972a19ec49108cf5c11d144179e5693570a9`。

**v10.1.3唯一已接受产品**：
- 产品源码Commit：`e27db2012e2c57390c4da179330552a6b64a728d`；
- 产品Root Tree：`cf670270aaac7d641d58939eaea7737c23b89417`；
- **完整apps Tree：`d4569b330629d74c6e5f3ee1d6438245d7bfd024`**；
- **完整services Tree：`4d637a3fd827e00974887d9ce515a1833a8f3a8a`**；
- 最终报告交付Commit：`7d19ed5fe4850b30f80c30775eb637df404a089c`；交付Tree：`dbd009a520dabc18384f244d24dc94abb35019f0`；
- 正式`IMPLEMENTATION_REPORT.md`接受Blob：`5f8a0fec8e26844cd7bf4386ff30c03212cc2b7d`；
- 正式`artifact_manifest.json`接受Blob：`ccba7af0b399c33877e0f403b3321590b1e1ca8f`；
- `plan.md`冻结Blob：`74b67f4a61d2b38f7993dcfcb345510bc57cd65a`；
- `task_order.md`冻结Blob：`249981ba9dc3d1aac8f6f676d99504a79d5c8b12`；
- `acceptance.md`：由Astra已直接归档，签发前应重新实读原Blob并禁止改写；
- 原候选分支：`codex/v10.1.3-buddy-friend-community`，固定HEAD为完整交付Commit；
- 临时审阅分支：`codex/review-v10.1.3-20261021`，固定审阅Commit `a8c234e4b6f3e8837ab2e6978ab29ca43a38d172`，审阅Tree `f853f13166939b671e982f4ddb6d4c11ab9c36a5`，54项脱敏材料。

目前接受源码相对上述main产品有**34个产品路径差异**，但两个版本的Git历史分叉；**严禁直接merge整条候选分支**。必须从实时main复制**完整接受apps与services两个Git子Tree**，绝不只挑34条作为未经核验的覆盖清单。34条只是期望差异的独立交叉检查；若实时main产品路径在执行期间发生并发后继，停止可能覆盖产品的子项、集中报告，不得覆盖其它合法来源。

## 2. 原地保护和安全工作树

保护`D:/EliteSync-v10`原dirty主根、`D:/EliteSync`旧历史仓、既有v10.1.1/v10.1.2/v10.1.3专用工作树和所有未提交成果、测试用库/卷、SQL恢复点、APK实体/签名、原截图、审阅脚本、所有原失败与真实账号/密钥。只对有关保护根和拟使用的专用树作最低必要身份检查（HEAD、branch、index、tracked/untracked/ignored风险、原资产路径/必要哈希），完成后复核不变。

不得盲`pull/reset/rebase/stash/clean/prune`，不得force/force-with-lease推送或删除原工作树、分支、备份、SQL卷、媒体、证据。复用经确认归属明确、干净的现有专用代码树；确实无法安全复用才创建**一个**隔离工作树，不为同任务再复制多套完整仓。旧仓仅需要时验证保护身份，不作全量源码考古。

## 3. 唯一产品集成

1. 实时GET `origin/main`、Git Commit/Root Tree、apps和services；记录这一**执行时真实main**为唯一集成Parent，不能强制回到本任务签发时SHA。
2. 实读唯一接受源码Git Commit/Tree和报告/manifest，核准两完整产品Tree精确；核准现有main产品仍等于接受的v10.1.2 apps/services或确认无冲突合法后继。
3. 从live main建立安全集成候选`codex/v10.1.3-safe-integration`或复用经证实安全的等价隔离分支。在干净索引中精确引入两个接受产品子Tree，保留main所有其它目录与最新文档。
4. 建立一个**仅产品变化**的正常单亲本产品集成Commit。无额外源码增删、迁移重命名、格式化、CRLF统一、生成制品替换或隐式包升级。提交后检查整个apps Tree=`d4569b33...`、整个services Tree=`4d637a3f...`，不满足则不能进入发布完成态。
5. 将实际从执行前main到产品集成Commit的所有apps/services变化与接受源码Tree逐路径比较：path、文件type、mode、Blob、增删状态；初始预期34项，但以**真实差异和完整子Tree**为准。确认产品提交不碰`docs/`及任何其它main合法对象。
6. 未经Owner另授权，不以安全集成为由重新开发Buddy、Comments、权限、迁移、Flutter或Laravel；发现接受范围内真实代码缺陷只标后续Astra判断，不能自行改接受Tree并伪称同一产品对象。

## 4. 正式长期文档与状态最小更新

从固定最终交付Commit准确归档：
- `docs/versions/v10.1.3/IMPLEMENTATION_REPORT.md`：Blob精确等于`5f8a0fec8e26844cd7bf4386ff30c03212cc2b7d`；
- `docs/versions/v10.1.3/artifact_manifest.json`：Blob精确等于`ccba7af0b399c33877e0f403b3321590b1e1ca8f`；
- 冻结`plan.md`与`task_order.md`、Astra直接签署的`acceptance.md`保持原字节；
- 唯一新增本集成报告：`docs/versions/v10.1.3/integration.md`。

当前`CURRENT_WORKFLOW`、2026-10-21轻量工作流补充、`docs/memory/navigation.md`、`docs/workflow/ACTIVE_STATE.md`、`CURRENT_STATE.md`、`DOC_INDEX_CURRENT.md`、版本登记、全部Owner决定/路线、旧06/07设计、各版本原验收/事故/恢复记录不退回。必要状态只更新唯一`ACTIVE_STATE.md`及极少数入口指针：**产品已集成候选、等待Astra独立集成验收，不能写集成已ACCEPTED**。旧“待集成”只视为历史时点或指向ACTIVE_STATE，不再给CURRENT_STATE顶端反复堆长段落。

不得将`docs/_temporary_review/v1013-20261021/`或原短期审阅branch/任何本地原证合main；保留全部原候选及失败而不是清理它们。无关的v10.1.2 ZIP同步`BYTE_MIRROR_PENDING`是可分离长期文档缺口：若Owner确实向当前专用目录提供固定SHA256`6781b7e8319037770780cfb202b6f37071031d8c9cec0bb969e39cf082c65c6f`的原ZIP，可在**不触碰已接受产品字节**的前提下按现行版本化规则顺带补精确镜像，并注明实际逐文件hash；若未取得，不全盘搜索、不再重写候选快照、不阻断本次集成，准确延续PENDING。Owner先前已表示ChatGPT Project Sources手动更新完毕，GitHub原ZIP的byte mirror是另一事项，Codex不能把“缺原ZIP”反写成Owner未更新项目源。

## 5. 有限静态验证；默认不重跑运行功能

- Git：执行前main/产品提交唯一Parent、两接受子Tree精确、path/mode/blob 34项预期及实际差异、Git index无unmerged、`git diff --check`正确判历史行尾例外、正式文档Blob、未引入任何未批准文件、旧审阅refs身份保持。
- 语法：对本版新增/改变的关键PHP Controller/Service/迁移/路由运行`php -l`；对manifest JSON解析、相关脚本仅做必要静态语法检查；`TestCase/phpunit.xml`中测试数据库选择`APP_DB_CONNECTION`优先且`sqlite/:memory:`的防误清源合同保持。**静态检查不得初始化Laravel应用/加载真实.env以连接数据库**。
- APK：从已接受manifest继承最终开发包`com.elitesync.v1013dev`、version `10.1.3-dev/1010301`、双ABI、签名、APK SHA256 `a134e5c1fecfed3449ede1c996c57e2972774ee777071d071cd59a6017c2ed6d`，不重新build/install/ADB pull；不存在R1产品字节变化，复用原功能验收范围是合理的。
- 不重新执行39/584后端、55项Flutter受影响套件、额外5+30入口测试、3组MariaDB RR，18表重启、APP两角色、Web审核、通知与原APK验收。它们属于原`CODEX_REPORTED`功能证据，不得因为本次集成`NOT_RUN`而归零，也不能宣称重跑成功。

**NOT_RUN（除非发生独立新授权且准确列明）**：MariaDB/SQL/容器/服务迁移或seed；PHPUnit/Flutter运行；APK构建安装、真实手机/AVD/ADB、WS/RTC/AEC；真实身份/Push/支付/云端/防火墙/备案、公司运营、第三方费用；所有数据库/备份/审阅临时branch清理；v10.1.4。不能在普通集成时触碰既有历史原证或公网资源。

## 6. 本地连续代码基线、GitHub非强制发布与回读

- 在安全、干净且已有归属的开发代码树上接续最终main的完整产品对象及最新有限文档。区分`SOURCE_OBJECT_MATCH`、`LOCAL_CODE_BASELINE_SYNCED`、`RUNTIME_NOT_RUN`和`PRODUCT_MAIN_INTEGRATED`；没有证据不声称本地服务可正常运行。
- 可完成正常Git add/commit/普通**non-force** push、远端REST读回。产品Commit需要以真正执行前live main为唯一Parent；文档后继仅改变必要docs与当前入口，产品子Tree不再变化。如果main同时前进，只有已验证安全的纯文档后继才能适配；涉及其它产品字节或不明归属立即局部停止，不绕过branch protection，不force，不覆盖别人工作。
- 发布之后独立GET最终live main Commit/Root Tree、apps/services两个完整Tree与接受源码、产品Commit唯一Parent、正式文档Blob和所有实际改变路径；核验旧候选/审阅refs仍在、保护根HEAD/index/status没变，并报告所有实际exit。
- 只有最终GET确证两个产品子Tree完全一致、旧main docs完整、正常提交历史与保护通过，才可交`V10.1.3_SAFE_INTEGRATION_CANDIDATE_DELIVERED`；**不是**Astra集成已接受。最终报告不能预先写自身提交的最终SHA以制造自引用，收尾消息报告最终main Commit/Tree即可。

## 7. 唯一集中交付

只产生一份`docs/versions/v10.1.3/integration.md`作为真实集成回执，包含：
1. Owner对本次安全集成的明确批准、Astra原功能接受/冻结Blob。
2. Codex实际起始live main/Root/apps/services与接受源码Commit/Root/apps/services。
3. 产品单亲本Commit、最终main/Tree、两个产品子Tree完全一致、逐路径mode/Blob差异、有效compare。
4. 上述正式报告/manifest/Astra acceptance及现行工作流、旧冻结计划的Blob完整性。
5. 必需静态命令、exit/stdout摘要、历史失败和本轮所有NOT_RUN；不把功能验收套件当集成重跑。
6. 本地连续代码基线及4类受保护资产核验，均标`CODEX_REPORTED / LOCAL_ONLY`，原事故、数据库备份/卷/APK/短期证据保留。
7. 有无取得原2026-10-21项目源ZIP及真实`BYTE_MIRROR`状态；若未取得标PENDING，不产生无谓阻断。
8. 普通Git提交/non-force发布/REST对象与旧refs精确回读、实际有限变更目录、非作者有界静态复核。
9. v10.1.0`PARTIAL/NOT_ACCEPTED`、AC-10.1-08 PARTIAL、真实实名供应商`PROVIDER_PENDING`、私密数据和RTC/通知旧限制沿袭；不打开v10.1.4。

**正常最终交付状态**：
`V10.1.3_SAFE_INTEGRATION_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_INTEGRATION_ACCEPTANCE / COMPLETE_PRODUCT_TREES_MATCH_ACCEPTED_SOURCE / V10.1.4_NOT_STARTED`。

未完全完成则真实`PARTIAL / BLOCKED`，指出阻断的精确阶段、已完成部分和证据。结束后停止，把唯一集成报告和最终main/Tree/子Tree/Blob交还Owner，让Astra进行第二道**独立集成验收**。不要自动把候选判ACCEPTED、不要清理历史、不要启动下一版本。
