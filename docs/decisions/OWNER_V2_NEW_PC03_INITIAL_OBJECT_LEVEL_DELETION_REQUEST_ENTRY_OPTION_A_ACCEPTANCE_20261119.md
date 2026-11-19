# EliteSync V2｜Owner NEW-PC-03 方案A：首期对象级删除请求入口规划方向

日期：2026-11-19（Asia/Singapore）  
状态：`OWNER_NEW_PC03_OPTION_A_CONCEPT_ACCEPTED / REAL_DELETE_REQUEST_CAPABILITY_OPEN / DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`  
治理分支：`governance/home-matching-product-freeze-20261117`

## 1. Owner具名决定与接受范围

网页GPT顾问提出并在[NEW-PC-03首期删除请求入口与对象范围V0.1](../product/ELITESYNC_V2_NEW_PC03_INITIAL_DELETION_REQUEST_ENTRY_SCOPE_CONCEPT_REVIEW_V0_1_20261119.md)中对照方案A/B。紧接着单独询问：“是否认可 NEW-PC-03 方案A——V2首期优先规划本人作品和本人评论的对象级删除申请入口，但不提前承诺后台删除能力、法律处理期限或真实回执？”

Owner明确答复：

> 我认可NEW-PC-03 方案A，请继续

所以本文件**只**把下列首期产品规划方向记作`OWNER_CONFIRMED`。它不是对全文顾问草案、法定期限、真实工程实现、运营投入或其它NEW-PC-04/05方向的一揽子批准。

## 2. Owner确认的最小产品方向（OWNER_CONFIRMED）

1. **首期优先规划的对象**：在有权的本人作品管理场景与本人评论管理场景，为“申请删除本人的指定作品数据”和“申请删除本人的指定评论数据”预留清楚、分别可理解的对象级入口与说明。
2. **操作语义独立**：作品受众收窄/撤下、[NEW-PC-02作品作者隐藏第三方评论](OWNER_V2_NEW_PC02_AUTHOR_CONTROL_THIRD_PARTY_COMMENT_DISPLAY_DIRECTION_ACCEPTANCE_20261119.md)、[NEW-PC-01评论者撤回本人评论展示](OWNER_V2_NEW_PC01_COMMENT_AUTHOR_WITHDRAWAL_OPTION_A_DIRECTION_ACCEPTANCE_20261119.md)及真正“申请删除数据”互不等同。单次撤下/隐藏/撤回不暗含物理删除请求，更不能冒称删除已完成。
3. **具名用途撤销独立**：原有用途管理/撤回入口在实际合法条件下与对象删除请求分开，不因操作成本目标捆绑为一键全删、默认重复授权或强制隐式同意。
4. **只有真实能力才可显示真实成功**：仅在已存在、合法、当前有权且可核实的删除请求受理机制下允许发起对应真实提交或查询；没有这类能力时只可准确说明真实可用的渠道/当前限制，不制造假申请、假受理编号、假进度或假删除完成。写入`UNKNOWN`先有权只读查权威事实，不自动高影响重放。
5. **分期不免除适用义务**：账户级删除/导出、跨用途事实、匹配旧快照、第三方内容、Safety必要资料、备份/媒体等首期精确入口仍待未来确定；这不代表用户依法可行使的请求权可以被取消。具体处理需要实际适用的法律与合约证据。

## 3. 承接既有合同

- [RET-D1/D2](OWNER_V2_RET_D1_D2_REVOCATION_DELETION_CONCEPT_ACCEPTANCE_20261119.md)：撤销授权或阅读权、删除请求获权威受理、指定范围完成删除是三种各自独立状态。
- [OBJ-D1](OWNER_V2_OBJ_D1_POST_TAKEDOWN_THIRD_PARTY_COMMENTS_ACCEPTANCE_20261119.md)：作者删除本人作品的请求不代第三方评论者删除其原始记录；历史附件/评论读取仍遵守原受众与当前作品读取权交集。
- NEW-PC-01与NEW-PC-02是两种不同的展示控制权；不增加任何一方对第三方数据的永久删除权限。
- O09高影响`UNKNOWN`、Block、跨账号重验与当前读权安全保护继续适用。

## 4. 本次没有确认的事项（持续OPEN）

| 分类 | 仍待确认的真实依据/取舍 |
|---|---|
| `PRODUCT_CONTRACT_OPEN` | 各对象精确入口、申请选项文案、错误与撤回、评论媒体/回复引用、账号级删除与导出产品范围、申诉及处理反馈 |
| `LEGAL_OR_EXTERNAL_FACT_OPEN` | 适用法域、本人及第三方权利、必要留存、合法例外、身份核验与申诉义务、实际数据处理责任及具体期限 |
| `ENGINEERING_EVIDENCE_REQUIRED` | 真实删除受理API与权威回执、对象/副本范围、存储与备份、缓存媒体、请求幂等、跨设备传播、操作权限版本及动态QA |
| `NOT_RUN / UNKNOWN` | 实际应用、后台、设备、真实供应商与数据处理证据；不得凭文档表述判成`PASS` |

注意：**首期“规划”不是“首期上线承诺”**，更不是对未确定合法机制的技术授权。

## 5. 后续静态设计任务与Authority

网页GPT可在当前治理分支继续把NEW-PC-01/02/03与RET/HIS/OBJ组成**权限主体×对象×动作×用户可见状态**静态矩阵，作为下一轮顾问产物；未获批准的精确细则必须标`ADVISOR_PROPOSAL / OPEN`。NEW-PC-04旧候选新版形象自愿分享和NEW-PC-05正式官方转载首期范围仍为`DEFERRED_ADVISOR_RECOMMENDATION`，未产生新的Owner批准或变更既有O05/O11安全默认。

**持续`DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`**；不下Codex V2工程任务、不读取/改动APP/API/Web/DB、启动设备/模拟器、构建APK、合main或发布、连接供应商。旧`10.1.18-dev / 1011804`的UI-AUDIT-01 `NOT_RUN/UNKNOWN`不变、G01–G10新动态全`NOT_RUN`；真实身份核验与Push尚未接入，43原PNG远端仍按记录`PENDING_BINARY_UPLOAD`，本次未验二进制。GitHub治理分支不代表本地工程已同步。
