# EliteSync V2｜G01–G10未来证据收集模板（仅设计阶段文字版）

日期：2026-11-19（Asia/Singapore）  
状态：`ADVISOR_EVIDENCE_TEMPLATE / OWNER_REVIEW_PENDING_FOR_UNDECIDED_DETAILS / ALL_G01_G10_RUNTIME_QA_NOT_RUN / NO_ENGINEERING_AUTHORIZATION`  
来源：[DESIGN-AUDIT-02](V2_STATIC_DESIGN_CONTRACT_AUDIT_02_P0_EVIDENCE_LEDGER_20261119.md)、[P0三分流](../product/ELITESYNC_V2_P0_OPEN_TRIAGE_PRODUCT_EXTERNAL_ENGINEERING_V0_1_20261119.md)、[原G01–G10矩阵](../product/ELITESYNC_V2_P0_FAIL_CLOSED_SCREEN_AND_EVIDENCE_MATRIX_V0_1_20261119.md)与[独立Owner决策目录](../product/ELITESYNC_V2_OWNER_ACCEPTED_SOURCE_INDEX_AND_AUDIT_SNAPSHOT_20261119.md)。

**本文件不是工程任务书、测试计划启动令、当前实现状态或新的产品合同批准。** 不发给Codex执行，不调用真实供应商，不读取运行代码/数据库/设备。`DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`不变。

## 1. 每项证据的统一填写模板（目前只定义字段）

| 字段 | 填写规则 |
|---|---|
| Gate / 业务目标 / 对象 | G01–G10的编号；具体用户动作、来源/用途/受众/快照及受保护数据 |
| `OWNER_CONFIRMED` | 只引具名决策文件的准确范围；不得把顾问矩阵新设计细节一并写成已批 |
| `PRODUCT_CONTRACT_OPEN` | 尚需Owner选择的可描述用户状态、交互、边界及替代路径；不重复已批准原则 |
| `EXTERNAL_DEPENDENCY_OPEN` | 缺少的供应商、法域、合法依据/第三方权利、真实回执或合同；未核实不猜测 |
| `ENGINEERING_EVIDENCE_REQUIRED` | 将来经Owner**另行授权**才需检查的字段、数据、API、权限/媒体、版本、缓存、幂等、设备和测试 |
| 安全默认 / 未知恢复 | 未核实时允许什么、禁止显示什么、如何安全返回；高影响写入UNKNOWN先有权只读查权威事实，不盲重放 |
| 证据身份 | 未来记录实际本地工作树/代码/安装包、配置/提供者版本、固定场景、回执及时间，不以本治理HEAD代替 |
| 实测结果 | 每一条保留`NOT_RUN`直至合法授权且实际执行；届时才按客观证据标`PASS/FAIL/UNKNOWN`，不能凭设计文本推断 |
| 复核与关闭 | 需要的Owner审批、外部核实和独立审计结果；评估不等于软件/发布准入 |

## 2. G01–G10三分流：未来证据需求（顾问分类，不代表已批准排期）

| Gate | 仍可做产品合同讨论（P） | 等外部/合法依据（E） | 未来授权后工程核查（I） | 当前结果 |
|---|---|---|---|---|
| **G01 实人核验/Match** | 失败、过期、撤销、申诉文案及安全返回 | 真实身份供应商、资质/协议、回执范围与有效期 | 准入Gate、身份关联、回执验真、不能报名时的真实行为 | `NOT_RUN` |
| **G02 官方/用户作品分域** | 可读空态、受众变更前提示及安全入口 | 正式公开域的有效权限/素材转载合法依据（如适用） | 访客/账号/Block、搜索、缩略图、媒体URL与深链的一致校验 | `NOT_RUN` |
| **G03 历史评论/附件** | 评论者撤回/删除、旧受众恢复及变更取消的可理解交互 | 第三方独立权利、留存及删除适用范围 | 原受众与当前读权交集、媒体签发、旧数据迁移与缓存隔离 | `NOT_RUN` |
| **G04 具名用途** | 必要字段许可颗粒度、拒绝/撤销回流 | 数据处理/来源的合法依据与许可范围 | 来源事实、权限版本、用途撤销后计算和外显拒绝 | `NOT_RUN` |
| **G05 事实纠错/派生结果** | 受影响结果“待核查”的提示及选择性重核入口 | 外部计算或资料许可（仅适用时） | 依赖图、受影响集合、结果版本、核验/新发布回执 | `NOT_RUN` |
| **G06 外显快照/UNKNOWN** | 旧候选未来是否允许自愿新版同步、冲突提示 | 适用发布/撤销合同（如涉及） | 新旧快照身份、受众/Block、只读权威结果、幂等与失权 | `NOT_RUN` |
| **G07 撤权/删除** | 请求对象/操作入口、撤销与删除回执的用户文案 | 第三方权利、法域、保留/备份必要例外 | 受理/完成的不同回执、请求幂等、媒体/副本/备份范围 | `NOT_RUN` |
| **G08 跨账号/失权** | 无权、未知或失效时的无泄密提示与返回 | 涉及跨端提供者政策时再取依据 | 切号、旧缓存/通知/深链、Block、延迟回包与媒体撤权 | `NOT_RUN` |
| **G09 消息/通知/Push** | 站内待办、已读、失效历史及许可回流文案 | 真实Push供应商与平台权限/投递依据 | 双方Consent/Block、站内通知幂等、设备发送接收真实回执 | `NOT_RUN` |
| **G10 原始设计/可用性** | 动态D/I/N/A/W阈值及无障碍目标若需精确化 | 素材权属与原件来源必要证明（如适用） | 原43 PNG逐份可核身份/SHA、实机截图/读屏/字体放大/Back/减少动效 | `NOT_RUN / BINARY_NOT_CHECKED` |

P/E/I可能重叠。**现有已确认的默认受众、评论权限、用途分离、撤销/删除状态分离及O09 UNKNOWN原则不重新作为OPEN申请。** 表中P栏只标真正仍待细化的可选产品合同。不得由P栏直接创建开发工单或以E栏需求默认批准采购。

## 3. 未来单项Gate的证据登记样式（空白，不表示已有证据）

```text
Gate:
Owner具名规则链接及已确认范围:
顾问仍OPEN的产品合同（如有）:
依赖的外部/法定依据（未知项写UNKNOWN）:
当前安全缺省/禁止误导性成功:
未来受授权工程核查的最小对象与证据:
真实工作区/版本/设备/提供者身份: NOT_CHECKED
测试设计/前置资格: NOT_AUTHORIZED
本次实际动态结果: NOT_RUN
证据附件/权威回执: NONE
Owner新授权: NONE
结论: EVIDENCE_GATE_OPEN
```

## 4. 当前共同停止条件

- G01–G10新运行时QA全部`NOT_RUN`；无法用静态对照表替代实际测试。
- 实人核验与真实Push未接入；正式真实匹配报名禁用；高影响UNKNOWN不自动重放。
- 原43 PNG远端二进制仍依据现行记录`PENDING_BINARY_UPLOAD`，本模板没有重新检验SHA或二进制。
- 旧`10.1.18-dev / 1011804`及UI-AUDIT-01的`UNKNOWN/NOT_RUN`不改判。
- 未来任何APP/API/Web/DB、设备/模拟器、APK、main、发布或供应商操作必须有Owner新的明确授权；本文件不能解锁。

**状态：`ADVISOR_TEMPLATE_ONLY / P0_EVIDENCE_OPEN / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`。**
