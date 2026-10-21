# EliteSync v10.1.2｜单次安全集成、连续代码基线与项目源同步｜Codex唯一综合任务

签发：2026-10-21｜Astra。Owner已明确批准**本次单次安全集成**并授权有界工作流/项目源同步。

**OWNER_APPROVED / READY_FOR_MANUAL_DISPATCH / FUNCTION_ALREADY_ACCEPTED / INTEGRATION_NOT_YET_EXECUTED / V10.1.3_NOT_STARTED**

## 0. 只派发一次；不要再做功能开发或重复计划

这是v10.1.2**已接受功能候选**的安全集成，不是重做v10.1.2、R1、模型评估/用户测试、重规划工作流或启动v10.1.3。Owner手动转交本任务后，Codex可在本任务已有授权内自主执行Git对象迁移、必要静态检查、正常Git提交与non-force发布、归档正式报告、更新实时入口、同步项目源版本镜像、本地干净连续代码基线，不逐命令请示。所有本机证据`CODEX_REPORTED / LOCAL_ONLY`；Astra将在候选交付后**另行独立验收集成**，Codex不得自签ACCEPTED。

现行Authority：Owner最终产品/外部/不可逆权限；Astra长线顾问/独立终验；Codex单次综合任务执行。已生效：[当前工作流](../../workflow/CURRENT_WORKFLOW.md)；[2026-10-21轻量工作流补充](../../workflow/ACCEPTANCE_INTEGRATION_SOURCE_SYNC_20261021.md)；[唯一当前入口](../../workflow/ACTIVE_STATE.md)。无需额外多模型循环、Work/dot实时监督、单文件微任务串联或再次大规模仓库考古。

## 1. 不可变接受对象／正式审阅身份

仓库：`zcx369658780/EliteSync-v10`。

| 对象 | 固定身份 |
|---|---|
| **唯一接受源码Commit** | `88ffeccce4042f13ce4edccf7604b835b06c8f2d` |
| 接受源码Root Tree | `42052f5f9ee596f82cf525884e1f77256fc7727b` |
| **接受 apps Tree** | **`365810451b6faad98e041835be6c86f4f81be0a9`** |
| **接受 services Tree** | **`96b2972a19ec49108cf5c11d144179e5693570a9`** |
| 原v10.1.2功能源码/完整交付 | `ebade52179b6ac7b76ba2f2992d31981fa995a00` / `900942426e965092d3852771c4126d77210677c4` |
| R1接受源码唯一Parent | `900942426e965092d3852771c4126d77210677c4` |
| R1最终报告交付Commit | `bdf86e69e4c9802699dfb3cda6dfc98b3227ed02` |
| 最终 `IMPLEMENTATION_REPORT.md` Blob | `6ad7e7f9678d2cb9f7f81f4c3812e5eed93712b4` |
| 原 `artifact_manifest.json` Blob | `55eb35bc8bb8e2ff9dbc5ac5fba465a837f1a24a` |
| 最终 `r1_artifact_manifest.json` Blob | `efa0ea0c013f52fce1228adc2a0ba8c24f86d857` |
| 冻结 `plan.md` Blob | `2ebd2ea05b3d7dae52cc3995de913eeb0fde375e` |
| Astra R1冻结审阅任务Blob | `75d98dd1be027230d923572be8e4ac94594839dd` |
| **Astra直接归档功能裁决** | `docs/versions/v10.1.2/acceptance.md`；`V10.1.2_ACCEPTED_WITH_OBSERVATIONS` |
| R1临时审阅固定Commit | `94f41f4ef2455b7c89258437a5162c19cca2f1e8` |
| 原v10.1.2临时审阅固定Commit | `70e122ddfbaa2d89e6c46bb21fb49a8fe8ae44d4` |

源产品相对最近已接受的v10.1.1旧基线包含**47个产品文件差异（22新增、25修改）**，不是R1最近15个更动路径。集成对象是两个**完整接受产品子Tree**，不得只拣R1的15条，也不能整体merge候选历史把旧doc覆盖到main。

本任务签发前已读main旧接受产品：
apps `1ddc864a8f7f8f7e024d6102a36057252bc77bab` / services `e4ae92d12d0bbac81a8ed7730a061aaec214da13`；**实际开始时必须重新读live main Commit/Tree/apps/services**，保留自签发后的所有合法Owner/治理/验收文档提交，不能把签发时某个SHA当永久HEAD。

## 2. 准备及保护

保护原dirty `D:/EliteSync-v10`、历史 `D:/EliteSync`、所有已归属worktree、v10.1.1误清库恢复卷/备份、v10.1.2开发库/新卷/原APK/R1重建APK/失败证据与原本LOCAL_ONLY资产。仅对必要根/待使用的干净工作树登记HEAD/index/tracked/untracked及归属；不为重复证据新建多套worktree或扫描全部旧项目。

禁止盲`pull/reset/rebase/clean/stash/prune`、强制推送、移除worktree、数据库迁移/清库/seed/恢复、删除卷/备份、修改云端/系统防火墙/端口/USB/SDK、真实供应商操作或费用。已有干净连续开发树归属明确时可安全复用；有未知dirty先保留，换隔离树或局部阻断，不自动清掉别人的结果。

## 3. 精确代码集成

1. 实读并验证源Commit、Root Tree、apps/services两个完整Tree和R1报告/manifest/Astra直接验收文档；原候选和审阅分支只读。
2. 从**真正live main**新建或复用具名安全集成候选分支（建议`codex/v10.1.2-safe-integration`）。比较源apps/services与当前main：若仍为已接受1.1且无并发产品修改，可利用Git树对象精确恢复/替换两个接受子树；并发存在产品后继差异则先分析归属，不能盲覆盖。
3. 确认整个apps Tree精确 `365810451b6faad98e041835be6c86f4f81be0a9`、services Tree精确 `96b2972a19ec49108cf5c11d144179e5693570a9`。逐路径核新/删/改的mode和Git Blob；不得重排源码、统一CRLF、重格式化冻结接受文件或重新编译源码生成变化。
4. **产品集成Commit以最新合法main为唯一Parent**；不要把原候选的报告/状态历史随分支merge拉入，也不再运行功能测试来“证明同字节不同环境”。
5. main其余所有文件必须保留：2026-10-19 Owner决定和10.x路线、原06/07产品接受、v10.1.0 PARTIAL、v10.1.1验收与误清库事故、最新 `CURRENT_WORKFLOW.md`、`ACCEPTANCE_INTEGRATION_SOURCE_SYNC_20261021.md`、`ACTIVE_STATE.md`、`docs/memory/navigation.md`、冻结v10.1.2 plan及本安全集成任务。
6. `docs/_temporary_review/v10.1.2-20261020/` 与 `docs/_temporary_review/v10.1.2-r1-20261021/`及原审阅分支**不进入main，不删除**。源候选 `90094242...` 和R1候选、失败与私密原件全部保留。

## 4. 正式版本记录与唯一报告

`docs/versions/v10.1.2/acceptance.md`**已由Astra直接签署**，不得改写或由Codex代签。确保下列正式长期文件在集成后main的path/Blob精准一致：原接受源码报告的**最终R1追加版本** `IMPLEMENTATION_REPORT.md`（Blob `6ad7e7f...`）、原 `artifact_manifest.json`（`55eb35bc...`）、R1 `r1_artifact_manifest.json`（`efa0ea0c...`）；旧冻结 `plan.md`（`2ebd2ea...`）原字节保留。需要引用原审阅副本时用固定外部分支Commit链接，不混入main。

只新写一份本次综合安全集成记录 `docs/versions/v10.1.2/integration.md`，载入真实执行时父main/RootTree、接受源码与最终子树、产品集成Commit唯一Parent、文档与项目源同步差异、必需静态检查命令exit、准确保护结果与NOT_RUN，以及最终non-force发布远端对象回读。不得先写`INTEGRATION_ACCEPTED`；报告最终Commit SHA若不可自引用，仅在Codex最终消息给出，不造Git自引用Commit循环。

## 5. 有限静态集成检查（默认不重跑功能）

至少做：
- 接受root/apps/services和最终集成apps/services原对象身份；产品path/mode/blob无意外；检查最终产品改动确实为接受源码，不增补任何新增实现。
- 关键R1新增服务/Controller/迁移/路由及Laravel TestsTestCase防误清隔离静态检查；当前库选择`APP_DB_CONNECTION`优先但**不连接数据库**；必要PHP syntax，Flutter源码路径无替换，JSON/manifest解析，Git index冲突/空白例外、lock文件无未接受改动。
- 实际改变的文档、来源快照与Astra验收、短期审阅目录排除检查；原R1真机/AVD/APK仅保留Manifest身份，不重建或操作设备。
- 如最终apps与接受树不同，先判对象来源，不因“补测”绕过身份错配；若发现真实必须修改产品源码，停止对应子项交Astra，不可自行变更接受的功能基线。

`NOT_RUN`：MariaDB、容器/服务启动、迁移/SQL/seed、RR真实竞态、全量PHPUnit/Flutter、APK构建安装/设备、Web真实端到端、RTC/AEC、阿里云/公网/备案、Push/实人身份/支付、全量算法oracle、清理原证。v10.1.2 R1原有效回归44/609、Flutter13及首轮71/713、Flutter39作为历史证据保留，不能冒称本集成重跑。需要外部权限/费用/生产或不可逆资源则局部停报，不扩大授权。

## 6. 项目长期记忆及增量项目源同步——同一任务，不新开版

Owner2026-10-21已授权工作流优化。生效GitHub治理：
- `docs/workflow/ACCEPTANCE_INTEGRATION_SOURCE_SYNC_20261021.md`（不得删）。
- `docs/workflow/ACTIVE_STATE.md`（短入口，**集成完成后Codex更新其中的状态与已读回的接受产品SHA**；注意Git最终Commit不能自引用，可在最终消息补全）。
- `docs/memory/navigation.md`（长期入口指向ACTIVE_STATE）；`CURRENT_STATE.md`、`DOC_INDEX_CURRENT.md`、`docs/versions/README.md`仅必要的小段更新，不再无限追加大段旧“当前”；历史记录不覆盖。
- `docs/workflow/CURRENT_WORKFLOW.md`2026-10-21前瞻补充。工作流优化不改变当版冻结plan/Owner边界。

**项目源ZIP由Astra在本会话创建并提供给Owner**：
`ELITESYNC_PROJECT_SOURCE_UPDATE_20261021_V1012.zip`
ZIP SHA256：
`6781b7e8319037770780cfb202b6f37071031d8c9cec0bb969e39cf082c65c6f`。

包是增量，不是整套：同名替换`01_当前入口与状态.md`、`03_文档证据索引与覆盖缺口.md`、`04_代理协作与近期路线.md`、`PROJECT_SOURCE_INDEX_ELITESYNC_V10_CHATGPT.md`；新增`11_20261021_版本状态与工作流补充.md`，加操作README和SHA256 manifest。**不改原02/05/06/07/08/09/10、Owner原决定/路线完整附件与竞品盘点。**

五个长期源正文的SHA256依次：
- `01_当前入口与状态.md`: `207056f53ccdc14cb6f15023b27aad6235e8f6867d340f9034f4b44e6f1f39c4`
- `03_文档证据索引与覆盖缺口.md`: `faf8297366cb86dde6da1a29fd5ded2f5b137f967f581e8e6a7c04aff2948f61`
- `04_代理协作与近期路线.md`: `e06623910f95d0ef46277df9fdcc7f942ac7583f3801b6e426886e0b6fd2545a`
- `11_20261021_版本状态与工作流补充.md`: `fd09929523242f7b4b2efcac65836881185cc2a39018de07f100eceb1a24c87b`
- `PROJECT_SOURCE_INDEX_ELITESYNC_V10_CHATGPT.md`: `dfec1fcaaedb0a7d7b27594e65c836c0f55b34ac46aecc3a452009c3aa51bef3`

**执行要求：** 优先使用Owner提供/放在Codex安全专用工作目录的ZIP，在不触碰脏根的前提下验证ZIP及内部MANIFEST SHA256，再将这五个正文及README/manifest准确发布到仓库新版本化目录 `docs/gpt-project-sources/20261021_v1012/`，保留旧`20261019_10x/`整包不动。对上述五个源码逐个算SHA256并与固定值核对，确保项目源仓库镜像和本次ZIP一致；不批量把ChatGPT旧项目源或不相关来源纳入本任务。

**若本地没有取得ZIP**：不得搜索整个Windows硬盘或编造相同字节；可从当前GitHub已签署`acceptance.md`、轻量工作流补充、ACTIVE_STATE和旧版本化项目源精确重建**语义一致的候选快照**，但必须标`SOURCE_ZIP_NOT_AVAILABLE / BYTE_MIRROR_UNVERIFIED`，只发布已核实来源的安全文档，并在唯一integration报告列真实diff/hash与仍待人工上传的文件。不能用缺ZIP阻断已接受产品子树的安全集成。交付后Owner可手动上传ZIP到ChatGPT Project Sources；Codex**不能**声明已更新ChatGPT账户Memory或已自动替换现有Project附件。只有Owner真实上传/替换后才能说该Project已更新。

项目源“v10.1.2功能接受／安全集成尚待执行”属于2026-10-21**历史里程碑快照**，集成完成后不要把ZIP旧文案倒改；新实际完成状态由ACTIVE_STATE及集成报告覆盖。

## 7. 本地代码连续基线接续与远端发布

在实际产品集成候选安全通过后普通commit及non-force发布main；如main已有并发纯文档更新，保留其差异并在新main上安全重做准确后继；出现不明产品并发则暂停危险合并，不force、不以旧Git主线覆盖。受保护分支拒绝直接推送时走现有受允许的非强制提交流程，不绕过治理。

确认新main完整Root Tree、apps/services、精确源路径、正式报告与治理文档远端GET/blob回读。集成的产品提交唯一Parent必须是实际集成前main，后继文档提交不改接受产品子Tree。

复用归属明确的干净连续本地**代码**工作树，进行无损Git代码同步并记录最终接受产品一致；忽略/未跟踪个人配置、APK和数据库不移动、不清理。源树末尾文档Commit与最终main可能存在后继，仅记录最终main HEAD并标明是否实际本地HEAD相等；不能把“产品代码一致”写作“本地服务/数据库运行已验证”。

## 8. 必须保留的限制及最终交付格式

- v10.1.0整版`PARTIAL / NOT_ACCEPTED`与AC-10.1-08 PARTIAL保留。
- v10.1.1开发库误清/恢复31表与历史失败、v10.1.2首次失败/正式关系B1、提案B2修复前复现、R1的原attempt01～03及错误脚本均不清理。
- 正式关系受控TEST_ONLY合成身份仅证明开发状态机；真实供应商/支付/公网/活动/对外真实运营未获授权。
- 冻结的07/08/09 Owner与原接受设计、隐私用途、Match/CN/MC/Relationship独立同意不改。浏览器/GitHub与本机运行证据分层。
- 保留所有候选、短期审阅分支与本地SQL/卷/恢复点，不自动删。临时审阅清理必须独立精确授权。

交付**一个** `docs/versions/v10.1.2/integration.md`，连同上述项目源版本化目录、ACTIVE_STATE最小更新及必要正式状态记录；汇报源码Commit/Tree、产品子Tree完全匹配、集成Parent、最终main Commit/Tree、文档Blob、ZIP镜像核验结果、本地代码基线、静态exit、保护和NOT_RUN。正常发布独立readback并提供可审阅的精确GitHub位置，停在：
`V10.1.2_SAFE_INTEGRATION_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_INTEGRATION_ACCEPTANCE / SOURCE_SYNC_STATUS_EXPLICIT / V10.1.3_NOT_STARTED`。

不得写`INTEGRATION_ACCEPTED`、不得启动v10.1.3或交叉执行其它项目任务。Owner回传结果后由Astra一轮独立集成验收；如仅文档/ZIP缺位，准确分项分类，不重开功能开发。
