# EliteSync v10｜交付工作流与任务契约｜v0.1

> 本页保留原工作流历史。实时工作流以仓库根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md` 为入口；GitHub 仅用于备份、里程碑与发布。已发布任务的精确预算与停止条件继续有效。

维护修订：2026-09-21 / delivery-refresh-2。`PROSPECTIVE REVISION CANDIDATE — NON-AUTHOR ACCEPTANCE REQUIRED`。
本版本替代上一工作流的未来任务编写建议；仅在精确 blob 独立接受并进入 main 后生效。AGENTS 保持不变。任何已发布任务，尤其 R18-R1，继续遵守自己的范围、次数和首次 PASS 停止规则；不追认 R18 历史偏离。

## 1. 一个可验证增量，一次独立审查

默认交付：已批准目标／边界 → 实现＋必要自检 → 最终候选验证 → 非作者一次 ACCEPT/REJECT → 精确集成及必要状态维护。task、候选（代码／测试／一份结果）、独立 verdict 即为通常所需文件；有交接需要才写 handoff，不增加同义阶段。

合包按同一可验证行为，不按“越大越好”。代码、目标测试、相关回归及结果应同行；已有 Package A 顺序阶段保留，不重新讨论。出现新权限／数据用途／领域政策或不可审查的大变更时拆开受影响边界；不能为减少轮次降低负向测试或自我接受。

优先级：宿主指令 > Owner 本轮明确约束 > 当前精确 task 与 accepted 契约 > 生效工作流 > 规划建议。高优先级不能创造不存在的合法／生产／真实数据授权。

## 2. 任务最小必填信息

```text
TASK / AUTHOR-EXECUTOR-REVIEWER ROLES
VERIFIABLE_BEHAVIOR_AFTER_DELIVERY / AUTHORIZATION / NEW_DEFECT_OR_EVIDENCE
EXACT_EXECUTION_BASE / TASK_PATH-BLOB / READ_SET / WRITE_SET
ACCEPTED_CONTRACT / UNDECIDED_BOUNDARIES / FAILURE_BEHAVIOR
ORDERED_PHASES_IF_NEEDED / COMMANDS / SIDE_EFFECTS / ATTEMPT_BUDGET
VALIDATION_MODE / FINAL_TESTED_IMPLEMENTATION_MANIFEST
FRESH_GATE / NAMED_MAIN_MOVEMENT_POLICY / PASS-STOP
IMMUTABLE_RECEIPT / INDEPENDENT_REVIEW / EXACT_INTEGRATION
AUTHORIZED_FACT_ONLY_STATUS_PATHS_IF_NEEDED
```

文档任务 runtime=NONE；实现任务列完整命令，不能写“运行必要测试”。每个 source 给真实 path/ref/blob 与所需章节，禁止“最新版／相关文件自行找”。活动任务应自包含于必要来源闭包，不复制全部治理历史。

## 3. 精确来源与资产复用

对已接受、无相关新反例的契约直接消费，不因换会话／模型重审产品。Product Connection 优先使用 R17-R3 自包含契约与 acceptance、当前修正及实作源码；历史 R16/R17 rejected/correction 链按具体矛盾展开，不把“曾是来源”变成永远必读。

v10 已有 UI／接口在实际接入点验证可用性，最小适配优先；“继承”包括真正的适配代码，不只是读文档。不得访问旧 9.x 仓库，不建立整仓考古或全面重写任务；发现确有不可替代来源时只提出有界需求，不擅自读取。

缺精确定义只暂停依赖该定义的动作。来源补全由 task author 在同一发布闭环完成，不让执行者默认扩大扫描。

## 4. 风险分层

| 类型 | 核心控制 |
|---|---|
| 纯事实状态／非权限文案 | 精确范围与来源检查；不额外运行项目 |
| accepted 契约内离线开发 | 合包实现验证、明确预算、一次非作者审查 |
| binding/consent/identity/lifecycle/writer 语义敏感 | 即使 synthetic 也须严格契约、负向／组合反例、影响审查 |
| acquisition/环境变化/迁移/部署/真实数据 | 各自明确副作用、根、预算、停止及恢复；不继承普通单元测试许可 |

本表不授予任何命令权限，也不解除历史 one-shot。

## 5. 未来验证协议：FINAL_CANDIDATE_VALIDATION

仅未来精确任务显式选择此模式时启用。旧任务未写该模式仍按原规则。

开发验证允许在同一读写／语义边界内因测试失败或新发现的具体缺陷修正。一次绿色开发结果不是终身禁止修正，也不证明后来修改过的代码已测。

作者完成静态契约检查后，冻结代码、测试及影响运行的配置，记录 `path -> Git blob / SHA-256` 的 implementation manifest，再执行精确组合验证。报告文档可在测试后添加，因此不用制造“测试前知道最终报告 commit SHA”的自引用要求。

| 事件 | 允许动作 |
|---|---|
| 开发验证通过、无新问题 | 可将它认定为最终验证，前提是覆盖完整必需命令且被测内容与发布内容一致；不重复跑 |
| 出现具体新缺陷且仍在预算／范围内 | 记录问题，撤销旧 PASS 对待发布版本的适用性，返回开发状态、修正、重验最终版本 |
| 代码／测试／运行配置有变化 | 必须获得该新版本对应验证；不能借旧 PASS 发布 |
| 仅补结果说明／来源指针 | 不因此自动重跑项目；仍检查文档范围与证据一致性 |
| 预算耗尽、超范围或副作用未知 | 停止相关交付，不删测试、不改断言凑过关、不申请无限重试 |

预算由 task 明定。例如最多三次命令，其中最后一次必须覆盖最终代码；这只是可选预算模板，不是全局授予三次。每次启动失败、真实进程次数、开发／最终用途分别如实记录，计数口径须事前确定。没有内容变化／新失败不为安心重跑。

采用硬顺序 Phase A/B 时，Phase A 全通过后才开始 B；若 B 中修改影响 A 的共享代码，最终回归须包含 A，并重新证明其条件。物理数据库、网络、依赖安装、设备操作各按精确任务授权。

## 6. 验证覆盖与最终证据

依变化范围覆盖 source-order permutation、associative-key order、真实字段／类型不匹配、incomparable namespace、缺依赖、actual context mismatch、terminal/invalidation 保留、direct typed payload equality、UNKNOWN/REJECTED 不可用。R17/R18 已有反例变成回归资产，不反复增加抽象政策文档。

修改共享 storage/validator 必须点名相关既有家族回归；不以断言数量代替行为覆盖。schema/key sets/非权威字段未测或仅静态检查时明确说明。客户端单元／组件／后端 HTTP 不能替代指定平台安装启动和实际交互证据。

记录最终 implementation manifest、命令、尝试顺序、真实结果、警告和未观察事项；发布 candidate 后核验其实现文件与已测 manifest 一致。reviewer 不重跑时明确依赖执行器回执，不宣称新的运行证据或全局 cleanliness。

## 7. main 移动与尚未开始任务

区分三种状态：任务未开始、已过 fresh gate 在途、已发布候选。不得混用。

默认 fresh gate 不匹配即停。未来 task 可显式允许具名的无关文档移动，前提是控制规则、消费源码及写路径未变；reviewer 分别核验 frozen base 下的候选拓扑与当前 main。未知移动、AGENTS/任务规则/代码变化、路径冲突均暂停相关集成，不自动 rebase。

未开始任务因文档集成需要换首次基线时，应在现有 dispatch／发布回执中明确旧 base、新精确 base 的取得方式、固定源码不变、candidate sole parent；无需复制整份技术任务，但必须有明确授权。它不是追认“早已通过 gate”的在途例外。本次 R18-R1 仅使用本次 dispatch 的精确重发，不从通用条款获得新预算。

## 8. 非作者审查与原样集成

reviewer 核验精确 authority/task/parent/tree/changed paths/固定 blobs 后做一次实质 ACCEPT/REJECT。新缺陷必须提出，不因减流程放行；无新矛盾不重审全部历史。

作者不得自受；改后的 candidate 是新对象。ACCEPT 后原样集成获审查 blob，保留 current main 其他文件，只允许 fast-forward。竞争失败即停止，不 force、不覆盖未知提交。

REJECT 只发布具体问题及影响，不自动集成或启动下游。后继由已有委托下的 task author 发布；发布日期、路线顺序、工具可用均不等于自动执行许可。

## 9. 平台反馈与执行资源

把 M5 的最小平台运行证明前移，不等所有后端完成：最小值为明确平台／设备、精确版本、启动及一项可验证行为。未验证部分显式 unavailable；最终完整 synthetic 主循环须说明实际 adapter、测试状态驱动及保存／恢复，不用假成功界面替代。

平台 task 必须先解析受限工具链 lane 的适用入口，再精确给出命令／隔离根／副作用／预算；不默认安装或恢复旧 M1/M2/M3/DEP13/B12。默认一条核心工程任务与至多一条独立准备；第二工程 lane 仅在有执行者、无共享写集合且另行授权后开始。单个执行者交错工作不宣称并行。

## 10. 状态、工时与本地保护

在明确获准的维护路径内，接受／拒绝／新 dispatch 同时更新当前状态及准确来源；路线仅里程碑／依赖改变时改。纯事实维护由已有审查和发布闭环承担，不独立排三道关；新的流程／产品规则仍审查。所有历史 accepted/rejected artifacts 保留原文。

可在正常回执附：新增行为、证据层、被测内容标识、实际编辑／读源／测试／审查时长（未观测写未知）、等待／环境／返工原因。不是产品埋点、会话分析或新 analytics/measurement；不扫描历史日志补数。预测比例是目标，不能写成已测工时或完成率。

本地同步与远端集成分开。没有明确同步根／清单／冲突检查不写原工作区；不 pull/reset/clean/stash/全仓 status/default index，不覆盖无关 staged/untracked/modified。可按精确任务导出至新隔离文档目录，不宣称整仓已同步。

## 11. 强制不变边界

README exhausted、FD02 excluded、旧仓库禁止、accepted ADR/UNKNOWN、D02/U-12/U-14/TP/PUI、受保护本地状态、工具链 M1/M2/M3/DEP13/B12、legal/Safety/no-processing 均保留。

本工作流不授权代码／HTTP／Messaging／auth/session/token／状态写入／网络 acquisition／环境恢复／真实或私密数据／研究招募／telemetry/analytics/measurement／Safety Operations／新法律研究／LC-03/LC-04/Phase36／生产部署。执行仍以明确 task 为准。

参考：Owner 转交外部报告 §§3、5–8、10–13（SHA-256 `387d875de016154cd40c8e4fecf33eb2c3c6f14781b6d883b1e1e690704027fb`）；DORA small batches、Google small CLs、Flutter testing overview 仅支持一般实践，不提供本项目工期数据。本修订不复制外部报告全文入仓库。
