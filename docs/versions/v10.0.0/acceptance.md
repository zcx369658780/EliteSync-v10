# EliteSync-v10｜v10.0.0 Astra 最终独立验收

> **最终结论：ACCEPT / CLOSED — WITH OBSERVATIONS — SYNTHETIC / DEV-TEST BOUNDARY ONLY**  
> 审查日期：2026-10-13（Asia/Shanghai）。  
> 审查者：网页 GPT 顾问（Astra 项目职责），与 Codex 执行作者分离。  
> 本结论仅对具名冻结计划和具名固定候选成立，**不自动合并代码、发行产品、启动下一版本或解除任何保护门**。

## 一、严格身份

- 唯一冻结计划：[v10.0.0/plan.md](plan.md)，冻结文档提交 `8072ba51ad1dde2e3c3262a418af54531dcec7e0`，计划 Git blob `ae84a65e3636fa51a188c687154cb51856f58bf9`，计划范围 **A+B+D**；C 不在本版。
- 交付候选：[`18daf9746e2f031fbbbe18682bf0c742aad92a09`](https://github.com/zcx369658780/EliteSync-v10/commit/18daf9746e2f031fbbbe18682bf0c742aad92a09)，tree `e5ee225f8084dd275278337bb90a8a5414ef6e22`；唯一父提交 `4bebc8f394248e254c1368a06fbdee5d2c883301`。Git 比较为 ahead=1/behind=0。
- Candidate branch `codex/v10-0-0-boundary-closure-20261013` 实际指向上述提交。它是隔离候选，不是 GitHub `main`。
- [作者交付报告](https://github.com/zcx369658780/EliteSync-v10/blob/18daf9746e2f031fbbbe18682bf0c742aad92a09/docs/versions/v10.0.0/execution.md)：blob `ad230da5fa112281e671535e87ff2ed9469454f1`。[技术 manifest](https://github.com/zcx369658780/EliteSync-v10/blob/18daf9746e2f031fbbbe18682bf0c742aad92a09/docs/versions/v10.0.0/manifest.json)：blob `a4ff50f8ccb16c8b79a91969713cf422519cce46`。
- 固定候选相对代码父提交：共 27 个变更路径；唯一现有产品测试文件改动是 `ProductConnectionPersistenceApplicationAdapterTest.php` 新增 232 行、0 删除。**产品源文件 0 改动**；其余为版本证据、工具、临时 PHPUnit 配置及准确冻结计划/规则的候选纳入。
- 原 R18 REJECT 不更改；已接受的 R18-R1 与后续 BE-05/BE-08 依赖不因本次关闭而变成“本版新实现”。

## 二、独立执行的证据审查

使用 GitHub 已授权工具对固定提交实际读取，而非仅引用作者自报：

1. GitHub 真实 commit/parent/tree、与代码父提交差异、具名 candidate branch；主分支未合并。
2. 冻结计划在候选内的 blob **逐字节相同**（`ae84a65...`），未因执行结果追改标准。
3. manifest 共 **55 个具名文件**：按其 exact path 在固定候选提交读取，**55/55 Git blob SHA 一致，0 不匹配、0 缺失**。分布：26 项 selected test closure、25 项版本证据/复现、4 项历史接受文档。manifest 自身的递归哈希未写在自身 JSON 中；以其固定 Git blob 作为验证身份。
4. `evidence/source-intake.json` 选定 26 项与最终 manifest 的可比 Git blob/运行字节 SHA 记录一致；`run-002/receipt.json` 中 27 项最终输入（含测试配置）与 manifest 对应 SHA-256 记录 **27/27 一致**。源输入被作者报告为 run 前后不变；网页端未访问本机重算原始 Windows 字节。
5. 独立解析发布的 [run-002 JUnit XML](https://github.com/zcx369658780/EliteSync-v10/blob/18daf9746e2f031fbbbe18682bf0c742aad92a09/docs/versions/v10.0.0/evidence/run-002/junit.xml)：**301 testcase / 4056 assertions / 11 个准确测试类 / 0 failure / 0 error / 0 skipped**，与 [运行收据](https://github.com/zcx369658780/EliteSync-v10/blob/18daf9746e2f031fbbbe18682bf0c742aad92a09/docs/versions/v10.0.0/evidence/run-002/receipt.json) 的 child exit 0 一致；原 [stdout](https://github.com/zcx369658780/EliteSync-v10/blob/18daf9746e2f031fbbbe18682bf0c742aad92a09/docs/versions/v10.0.0/evidence/run-002/stdout.txt) 保留 1 PHP deprecation 与 2 PHPUnit deprecations。
6. 直接检查新增测试内容与 JUnit dataset 名：48 个缺失/额外键、44 个类型错误、43 个有效类型下值差异、2 个 binding participants 对齐/descriptor 排列正例、2 个 descriptor participants 真实集合差异负例，**合计139个具名数据集**。它们在 current/transition、required/source 两个方向使用实际 adapter、`SqliteInMemoryLogicalPersistenceAdapter` 的内存提交/读回，包含 `UNKNOWN`、`STORED_NEW`、`EXACT_DUPLICATE`、不可用/拒绝及权限 false 检查。原有测试和关联键插入顺序回归保留。
7. 首次 run-001 是 PHPUnit `--colors never` 参数形态导致的**工具启动失败**，实际未启动测试；原始 stdout、空 JUnit、wrapper error 均保留，child exit 未持久记录，作者标 `UNKNOWN`。run-002 改为 `--colors=never` 并事先保存子进程回执后正常运行。未洗成两次 PASS。
8. [隔离 autoload 证据](https://github.com/zcx369658780/EliteSync-v10/blob/18daf9746e2f031fbbbe18682bf0c742aad92a09/docs/versions/v10.0.0/evidence/autoload-probe.json) 指向隔离候选中的 adapter/repository/SQLite；[root-before](https://github.com/zcx369658780/EliteSync-v10/blob/18daf9746e2f031fbbbe18682bf0c742aad92a09/docs/versions/v10.0.0/evidence/root-before.json) / [root-after](https://github.com/zcx369658780/EliteSync-v10/blob/18daf9746e2f031fbbbe18682bf0c742aad92a09/docs/versions/v10.0.0/evidence/root-after.json) 报告原 root HEAD、index/status 身份与具名保护文件不变。**这是审阅已发布的本地工具证据，不是网页独立操作 Windows 重算95项**。
9. 阅读作者复现 runner、source-intake 过程和辅助非作者静态复核。静态复核 `NO_ACTIONABLE_FINDINGS` 只属支持证据，不替代本 Astra 终裁；网页本轮没有独立运行 PHP/Composer 或访问真实数据库。

## 三、冻结 AC 独立裁决

| AC | 终验 | 依据及边界 |
|---|---|---|
| **AC-01 基线** | PASS | 父提交精确、55/55 真实 Git blob、一份有限 source-intake、明确隔离候选；原工作树保护由已发布工具回执支持，非网页本机重验。 |
| **AC-02 合同** | PASS | 保留 R18 REJECT/R18-R1 ACCEPT；新增数据集和既有回归覆盖11命名字段、结构、类型/值差异与 participants 双语义，未改 adapter 生产源码。 |
| **AC-03 有限组合** | PASS | 准确 11 类 JUnit、301/4056、exit 0，raw 双流；首次参数错误与未知 child exit 保留；deprecation 未掩盖。 |
| **AC-04 真实边界** | PASS（限定 synthetic/dev-test） | 真实 adapter + 内存/SQLite submit/retrieve/readback/拒绝与失效相关原合同测试，未授权真实 writer 或线上 permission。 |
| **AC-05 独立读取** | PASS | GitHub 固定 candidate 提供源码/测试/manifest/原始 run-002 和 run-001 证据；55 项 Git 对象逐项匹配。 |
| **AC-06 残留缺口** | PASS | 作者交付按 `ALREADY_ACCEPTED`、`CLOSED_BY_V10_0_0`、`RETAINED_OUT_OF_SCOPE`、`UNKNOWN` 等分类，没有把 C、V57、平台运行或真实数据标成通过。 |
| **AC-07 交付/复盘** | PASS | 候选、证据和风险集中交付；由本独立 acceptance 与 [retrospective.md](retrospective.md) 记录最终结论和首版流程复盘。 |

## 四、保留观察，不作为本版失败

- **OBS-01 环境与弃用：** PHP 8.5.3 / PHPUnit 11.5.55 下 1 项 PHP deprecation、2 项 PHPUnit deprecations。均无失败/错误/跳过；是否未来迁移 PHPUnit/PHP 属另版考虑。
- **OBS-02 原始测试由执行端运行：** 网页顾问独立核查仓库代码、manifest、JUnit 和运行日志，**并未重新执行 PHP 运行时**；其限定性在本版 AC-03/05 范围内可接受。未来声称真实设备、平台运行或生产需新增实际证据。
- **OBS-03 本地保护证据层级：** 原主工作树/95项本地保护由具名工具收据报告；网页无法直接独立读取 `D:/` 本地内容。没有以此假定原始历史 EVIDENCE 全树得到核验。
- **OBS-04 工作包 C 与保护资格：** 跨 backend→Flutter consumer bridge、V57/H1、H2/D0、正式 Driver/JVM/14case/SDK、生产数据库/用户私密消息/恢复/发布均不在本版；`NOT_READY`、`RuntimeReady=false`、`M6 CLOSED`、`S2 unsigned`、`OwnerEnvironment PENDING` 继续。
- **OBS-05 Git 交付与发布：** 本次验收**不等于**授权合并候选至 main、发布客户端或转换真实来源。候选仍在 `codex/v10-0-0-boundary-closure-20261013`，下一次整合须另有明确版本与源身份判断。没有凭历史“首次 PASS 关窗”给未来版本增加硬门。
- **OBS-06 原始文本卫生：** hygiene 回执中 whole-package diff-check exit=1，源于保留的 Windows CRLF raw 及冻结 Markdown 空格；作者源码与交付报告检查 exit=0，已独立观察其分类。原始失败/收据未为求整洁重写。

## 五、最终结论与权限

`ACCEPT / CLOSED — v10.0.0 A+B+D PRODUCT CONNECTION SYNTHETIC/DEV-TEST CURRENT-DEPENDENCY REGRESSION CLOSURE`

已接受对象：**这份固定候选在限定本地环境中的测试增强与可复现边界收口**。未接受对象：真实 backend↔Flutter 消息桥、正式平台资格、部署/生产、真实账号/备份及任何暂停的旧任务。

候选代码未合并 main。v10.0.0 终验关闭后，**不自动下达 v10.0.1**。Owner 对后续方向、合并/发布和受保护操作继续拥有决定权。
