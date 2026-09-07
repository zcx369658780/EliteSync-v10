# EliteSync v10｜M3 执行条件收敛决定 v0.2

Status: `ACCEPTED — OWNER APPROVED OPTION 1 — NEXT = ISOLATED OFFLINE EVIDENCE / CONDITIONAL ONE-SHOT M3`

日期：2026-09-07。原候选结论：**B — OWNER SCOPE DECISION REQUIRED**。

Owner 于本次验收明确选择报告 §4 的**选项1：无外部网络的隔离证据范围**。本页状态更新仅记录该 Owner 决策；原候选的技术判断、边界、证据账本与未证明事项均保持其原意。选项1批准不等于已经执行、也不等于允许原工作树写入或外部网络下载。

## 1. 固定依据与新增证据

- 原固定main M：`bb2027ce077b00deb2fdaa1161f357d303ef8cd0`。
- 原任务T：`2c2d1dcf3d501ab1de01480238c71ef6c8ef4544`；任务blob：`0da93232427233f7f9ab94524591ced7987db575`。
- 原候选：`1a675d9138a4740f10910138f46f9f42c04e3e38`；本报告候选blob：`9466dba2800e12bf1f17414606e34af452134741`。
- 候选已由 ChatGPT 独立验收，并以无 tree 变更接受提交 `26ccca5b28f31330e6b8e5711c29b681c8ee7d49` 推进 main。
- Owner 随后明确选择选项1，形成下一任务所需的范围扩展授权。

## 2. 四项必要判断

### 2.1 网络控制

原结论保持：`--no-pub` 或 Gradle `--offline` 不能单独证明 Flutter → Gradle → wrapper 整个进程树无网络；若执行 M3，必须通过进程树级隔离控制。

### 2.2 缓存与写入

原结论保持：Flutter SDK、pub、Gradle user/project、wrapper、module `.android/**` 与 `build/**` 都可能涉及读写。选项1改用隔离客体承载必要写入，禁止写原 `D:\EliteSync-v10`。

### 2.3 下一次最小前置证据合同

Owner批准将前置证据、隔离准备、控制验证和**条件式一次 M3** 合并在一张后续有界任务中。允许：

- 对具名 Flutter/Java/Android 工具与相关环境变量做有限只读定位；
- 用 Git 对当前本地 HEAD 及 `apps/flutter_elitesync_module` 的已提交对象生成不可变来源快照，不读取默认 index 或 dirty 工作区内容；
- 在专用 `D:\EliteSync-M3-readiness-v02` 根准备隔离输入、配置和证据目录；
- 使用 Windows Sandbox 或等价已批准的 OS 隔离，外部网络为零；
- 在完整参数、工具路径、离线输入和控制验证都闭合时，于隔离客体中执行一次顶层 M3；30 分钟上限、无自动重试；
- 与该 attempt 绑定一次定点产物存在性证据；不复用历史 M1 lane。

若任何必要输入或隔离能力未闭合，停止对应步骤并报告；不自动安装、下载、联网或改原仓库。

### 2.4 结果语义

原语义保持：前置通过、命令退出0、产物定点命中、M2宿主解析和可安装 App 分别是不同证据层，不能互相替代。

## 3. 官方证据账本

沿用原候选 `9466dba2800e12bf1f17414606e34af452134741` 的官方读取账本；本次状态更新不重复网络研究。

## 4. Owner 选择

**已选择：选项1 — 无外部网络的隔离证据范围。**

授权边界：

- 专用宿主根：`D:\EliteSync-M3-readiness-v02`；不存在才创建，存在未知内容则停止，不覆盖。
- 原 `D:\EliteSync-v10` 只允许已批准的 Git 元数据/对象读取，不允许工作区源码写入、cache 写入、build 写入、clean/reset/stash/index 操作。
- 来源快照只取当前本地 HEAD 中 `apps/flutter_elitesync_module` 的已提交对象；不打包工作区 dirty/untracked/staged 内容。
- 隔离客体外部网络必须禁用；不得下载依赖或工具。
- 可把宿主已有工具/缓存作为**只读输入种子**复制进客体内部专用可写位置；只对具名路径进行定位与复制，不目录遍历式考古，不输出敏感内容。
- 条件式 M3 只能在完整命令和必要输入闭合后执行一次；否则 `PRECONDITION BLOCKED`。
- 失败/超时保留批准的日志证据，不清理原仓库或宿主缓存。

## 5. 历史处置与边界

旧任务 `8b640576822b01ae00bb04b9b5deaa75db53365c` 继续不得恢复。M2仍 deferred。Owner选项1仅新增上述隔离 M3 证据权限，不产生产品实现、Backend/Database设计、LC-03/04、Phase36或真实用户/数据权限。

`OWNER APPROVAL OF OPTION 1 != M3 SUCCESS`

`ISOLATED M3 ATTEMPT != M2 SUCCESS`

`LEGACY V9 FUNCTIONAL FACT != V10 IMPLEMENTATION AUTHORITY`
