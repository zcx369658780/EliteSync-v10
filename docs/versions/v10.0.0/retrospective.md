# EliteSync-v10｜v10.0.0 独立版本复盘

> 2026-10-13；与 [最终独立验收](acceptance.md) 对应，结论 `ACCEPT/CLOSED WITH OBSERVATIONS`。本文件是版本**事实复盘**，不补充或追改 [冻结计划](plan.md) 的目标/验收门，不自动成为未来版本的永久流程门禁。

## 1. 计划与实际对照

| 维度 | 冻结目标 | 最终观察 |
|---|---|---|
| 版本范围 | A（有限来源）、B（已接受 Product Connection 的必要回归）、D（真实11-test+证据） | 交付对应的 scoped candidate；C 未纳入。 |
| 旧 R18/R18-R1 | 不重做已接受修复，不恢复 rejected 分支 | R18-R1 历史 ACCEPT 被保留，adapter 无产品源码改动；当前测试增强新提交。 |
| 源码纳入 | 仅真实依赖的有界文件，不覆盖原 root | source-intake 26 项，manifest 55 项；相对代码父提交只有一份现有测试文件新增232行，产品源代码 0 改。 |
| 行为验证 | 11个指定类，保护合同、存储/读回/失效和负向 | JUnit 301 tests/4056 assertions/11 classes/0 failures/errors/skips；初始工具失败留证。 |
| 交付 | 独立可读取的固定 Git 候选和证据 | 候选 `18daf9746e2f031fbbbe18682bf0c742aad92a09`、tree `e5ee225f8084dd275278337bb90a8a5414ef6e22`，manifest blob `a4ff50f...`；Astra 实际核 55/55 Git blobs。 |
| 终裁 | 网页顾问独立核实冻结目标后集中验收 | 单轮候选交付，经 Astra 审阅 ACCEPT/CLOSED（限 synthetic/dev-test），未合并 main。 |

## 2. 实际可量化指标与未知项

- **新增测试数据集**：139 组，48 shape、44 type、43 value、2 binding pair positive、2 descriptor negative。JUnit 该测试类总 149 cases；总组合为 301 tests/4056 assertions。不能把 301-旧 130 的差额全部归因于本版新增，因为组合测试文件范围已经不同。
- **可验证正式 suite 尝试**：run-001 参数错误导致没有测试启动（wrapper exit1，child exit UNKNOWN）；run-002 完整运行一次 exit0，并在此前工具诊断后保留原始错误。完成后的文件身份记录相符；没有声称多次完整 PASS。
- **run-002 计时**：runner elapsed 1.484 秒（JUnit 对应自身聚合时间更短）；不是整个版本真实工时。
- **全部项目工时、Token/额度真实消耗、Owner 等待、开发中独立人工介入次数**：UNKNOWN，未提供可审计汇总；不推算提速百分比或与旧版本成本比较。
- **发布变更量**：相对于 `4bebc8f...`，27 个候选 Git 变更路径（其中包含原计划/规则/交付证据）、唯一既有测试文件新增 232 行、产品源代码 0 行；manifest 55 项其中26 selected、25 evidence/repro、4 prior acceptance。候选提交没有 merged。
- **风险项**：运行期间保留 1 项 PHP deprecation 与 2 项 PHPUnit deprecation；并非隐藏问题或本版既定阻塞。

## 3. 已观察到的有效做法

1. **Codex 先报 READY_WITH_FINDINGS，Astra 才冻结：** 避免把已经接受的 R18-R1 旧缺陷重新开发，同时把难以客观验收的 backend→Flutter bridge 拆出。这是有实际证据的版前范围收敛。
2. **冻结一次、集中交付一次：** 中间普通命令参数失败由 Codex 自主修正，没有进入逐步 Work 审批循环；已保留原始失败和修复路径。这里不推断作者整个开发过程没有别的隐形尝试，只按已发布记录评价。
3. **测试代码、运行证据与 Git 身份相互约束：** 固定 parent、逐对象 intake、55-file manifest、11-class JUnit 可交叉审查；比仅有“测试通过”作者摘要更可靠。
4. **历史/新成果区分：** 旧 R18 拒绝、R18-R1 接受、BE-05/BE-08 依赖、本版新增 139 dataset 各有身份和时间；不把历史原件重写成当前 PASS。
5. **同步保护范围独立：** 候选隔离 worktree，不触碰原 root 工作树的 staging、dirty/untracked 和保留的旧证据；原本地保护只在报告级别和具名回执获核，不扩张声称全机全树已审计。

## 4. 问题、处理与风险归属

| 观察 | 类型 | 本版处理 | 后续建议（非派单） |
|---|---|---|---|
| runner 参数 `--colors never` 误传 | 执行工具问题 | 原始 stdout/空 JUnit 与 UNKNOWN child exit 保留，修复后 run-002 通过 | 可复用 `--colors=never` 形式及先落 child receipt 的习惯；不新增永久硬门 |
| PHP8.5/ PHPUnit11 的弃用提示 | 兼容性/技术债 | 如实留下，未弱化测试 | 将来相关依赖升级时同域评估 |
| 原本地 code 与 GitHub main 文档基线不同 | 配置管理与版本身份 | 代码候选以 `4bebc8f...` 为父、明确 whitelist；计划 `8072ba...` 单独固定 | 未来合并/发布先做准确集成评估，不能贸然 pull/rebase 本地主树 |
| 历史大量 LOCAL_ONLY EVIDENCE 与保护文件 | 证据可达性 | 当前55项和11-class运行证据 GitHub 可读；原历史原证继续 LOCAL_ONLY | 只在实际后续验收需要时有界提供 |
| C 桥/正式运行/生产资格仍未验证 | 保留产品风险（非本版偏差） | 本版明确排除，安全状态未提升 | 由 Owner 决定独立后续版本路线，不从本版 ACCEPT 直接推定授权 |
| hygiene whole-package diff-check exit1 | 原始证据行尾与格式 | raw CRLF及冻结文档空格保持原貌，不掩饰退出码；作者代码/报告检查 exit0 | 避免把 raw 保全与代码空白规范误混成产品测试失败 |

## 5. 工作流试运行结论

首次 `Astra 版前计划/冻结 → Codex 自主实现与有界验证 → 集中交付 → Astra 独立终验/复盘` 的实际试运行已**在具名 v10.0.0 范围内形成完整链**。证据支持“无需逐命令审批也能保存有效失败、经合同不漂移的最终候选、可供网页独立核验的结果”，但**不支持**推出整体研发速度提升百分比、生产/平台资格通过、所有遗留工作完成或未来每版都应照搬本版的 11-test 套件。

**归档：`V10.0.0 RETROSPECTIVE COMPLETE — PROCESS PILOT PASSED WITH BOUNDED OBSERVATIONS — NO AUTOMATIC SUCCESSOR`**
