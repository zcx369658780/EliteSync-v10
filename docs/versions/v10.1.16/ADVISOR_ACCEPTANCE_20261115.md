# v10.1.16 B2 独立顾问验收报告

日期：2026-11-15（北京时间）  
结论：`CONDITIONAL_ACCEPTANCE_IN_NAMED_SCOPE — R1_01_OPEN — NO_R2`

## 一、验收对象与固定身份

- 仓库：`zcx369658780/EliteSync-v10`
- 分支：`codex/v10.1.16-user-state-automation-center-20261115`
- 唯一父基线：`b981796e68ca512beeed2a18b40aeb8b09e26bc2`
- 固定任务文档：`89ce556ab67c6ea759d3a2ffea7016edf11b892e`
- 产品源码：`00cec7843911bb3341304c004059de0a91e12f16`
- 本次审阅交付提交：`c635dcadbbeec93e9b4287aaab9ae187742e226a`
- 候选：`10.1.16-dev / 1011601`
- APK SHA256：`ac86f8df05d1e39abfead445ba5d6e23bcb457b6c73030c02fa38d2d2cedb055`
- 任务分支HEAD与交付提交一致；相对父基线5 commits ahead、0 behind。产品源码提交与最终文档交付提交分别记录，未混淆。
- 源码提交同源origin fetch及ls-remote回读：PASS。

## 二、总体结论

v10.1.16已形成真实可用的用户状态聚合与单一白名单自动化试点。核心架构符合B2方向：现有权威状态聚合、scope独立授权、默认OFF、明确同意、有限任务、幂等、lease/fencing、未知结果核对，以及不自动创建匹配轮次、不自动接受候选、不建立连接/消息同意/正式关系。

但独立代码复核发现一项P1授权边界缺陷：自动化授权的暂停、撤销或到期可能暂停用户此前独立手动报名的慢约参与，即使该参与从未绑定自动化授权。该行为超出本版自动化scope，应修复后再关闭顾问验收。

## 三、七项AC具名评估

| AC | 顾问评估 | 依据与边界 |
|---|---|---|
| AC16-01 | PASS | 状态来源图区分权威源、派生投影、命令与隐私字段；没有复制第二套用户状态真相 |
| AC16-02 | PASS_IN_NAMED_SCOPE_WITH_R1_LIMIT | 只读聚合API、private/no-store、双账号隔离和字段裁剪有具名证据；R1同时要求授权绑定变化正确推进参与状态来源revision/freshness |
| AC16-03 | CONDITIONAL — R1-01 | 默认OFF、scope授权、CAS/幂等、pause/resume/revoke/expiry已实现；暂停/撤销/到期对未委托的手动参与有越权副作用 |
| AC16-04 | PASS_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS | 真实隔离MariaDB的提交前/后SIGKILL、双worker、撤销竞态具名通过；API重启后本机调度需手动恢复；最终备份独立恢复NOT_RUN |
| AC16-05 | CONDITIONAL — R1-01 | 独立持续参与授权、旧ACTIVE不静默迁移、现有轮次复用、资格复核和不执行匹配算法有证据；R1要求自动化只能暂停其实际委托的参与 |
| AC16-06 | PASS_IN_NAMED_SCOPE | 现有Me/慢约入口展示状态、授权、任务结果、暂停/恢复/撤销；未重排四入口或执行B3 |
| AC16-07 | PASS_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS | 104项PHP/1115断言、4项Widget、5文件Dart分析、16文件PHP语法、真实HTTP/隔离DB和模拟器具名验证通过；保留12项基线旧失败及全部NOT_RUN |

## 四、R1-01：P1授权边界与参与状态来源一致性

### 4.1 发现

源码位置：

- `AutomationAuthorizationService::command()`：`services/backend-laravel/app/Services/AutomationAuthorizationService.php`
- `AutomationAuthorizationService::pauseParticipation()`：同文件
- 到期处理：`services/backend-laravel/app/Services/AutomationService.php`
- 委托绑定：`services/backend-laravel/app/Services/AutomationService.php` 的 `apply()`
- 状态来源投影：`services/backend-laravel/app/Services/UserStateService.php`

当前暂停/撤销授权命令在更新授权记录后，无条件调用`pauseParticipation()`。该方法只检查`matching_participations.state === ACTIVE`，没有检查该参与是否绑定本自动化授权。

因此存在以下可复现路径：

1. 用户先通过既有手动流程报名，`matching_participations.state=ACTIVE`，`automation_authorization_id=NULL`；
2. 用户完成资格条件并单独授予每周持续参与自动化；
3. 在后台首次执行并绑定该参与之前，用户暂停或撤销自动化，或授权先到期；
4. 当前实现仍会调用`SlowDatingService::participate(..., 'pause', ...)`，把原本独立手动报名的ACTIVE状态改成PAUSED。

这不是自动化授权本身的必要效果。用户撤销“未来自动参与”不应撤销或暂停此前独立作出的手动报名。当前UI承诺的是停止今后自动报名、当前提案按原规则保留；它没有告知用户撤销自动化会暂停独立手动参与。

### 4.2 同一R1的状态来源问题

`AutomationService::apply()`为已经ACTIVE的参与写入`automation_authorization_id`、`automation_authorization_revision`和`automation_round_id`时，没有同步递增`matching_participations.revision`或更新`updated_at`。

而`UserStateService::read()`把`delegated`与参与`source_revision/source_updated_at`一起返回。因此在既有手动ACTIVE记录被委托绑定时，`delegated`可从false变为true，但该参与域的revision/freshness不变。自动化域revision另有变化，但参与域自身的来源版本仍不完整。

### 4.3 必须修正

R1-01限定修正：

1. 自动化pause/revoke/expiry只暂停确实绑定到当前自动化授权记录的参与。未绑定自动化的手动ACTIVE参与必须保持原状态、generation、revision和intent。
2. 对已委托参与，pause/revoke/expiry仍应暂停未来参与，并保留现有proposal合同；不得自动接受、拒绝或撤回proposal。
3. 判断委托关系必须依据参与记录的授权绑定，而不能仅凭参与状态为ACTIVE。到期处理时授权revision可能已递增，应正确识别仍绑定到该授权记录的旧revision。
4. 当委托绑定字段发生实际变化时，推进参与来源revision并更新`updated_at`；effect receipt应记录绑定完成后的最终参与revision。不要在绑定未变化时重复递增。
5. 保留当前User→task锁序、fencing、幂等、UNKNOWN核对和有限重试合同。

### 4.4 必须新增/补充的定向测试

- 既有手动ACTIVE → grant → 尚未产生自动化effect → pause：参与仍ACTIVE且revision/generation/intent不变。
- 既有手动ACTIVE → grant → 尚未产生自动化effect → revoke：参与仍ACTIVE且revision/generation/intent不变。
- 既有手动ACTIVE → grant → 到期/策略版本失效 → scheduler tick：参与仍ACTIVE。
- 自动化effect已产生并绑定 → pause/revoke/expiry：委托参与按既有规则PAUSED，未来任务停止。
- 自动化绑定被用户手动opt_in清除后，再撤销自动化：手动ACTIVE参与保持ACTIVE。
- 已有ACTIVE手动参与被成功绑定时，delegated变化有新的参与revision/updated_at；generation不被无故增加，effect receipt记录最终revision。
- 当前proposal和slot在pause/revoke时保持原值；原有withdraw权限和决定门禁不变。

只需执行上述定向PHP/API/隔离MariaDB测试、相关PHP语法和必要的受影响测试。无需重复104项全套、重建APK或操作Owner手机，除非修正触及APP源码。

## 五、其他证据边界与保留事项

以下均按原状态保留，不因顾问复核改写：

- PHP：104项唯一测试、1115断言PASS；Widget 4项PASS；5个Dart文件分析PASS；16个PHP文件语法PASS。
- 12项固定基线旧测试失败继续FAIL；完整全量回归NOT_RUN。
- 真实隔离MariaDB四项worker可靠性场景具名PASS。
- 两个虚构账号HTTP隔离及模拟器授权生命周期、冷启动、A→B→A切号具名PASS。
- 主开发APP新开放轮次报名NOT_RUN；真实跨周日历等待NOT_RUN。
- 首次数据库探测误连主开发库，迁移返回Nothing to migrate，业务fixture写入被guard阻止；该次前后逐表摘要UNKNOWN。保留UNKNOWN，不得改写为零变更证明。
- 后续主开发库增量迁移已按正确APP_DB配置完成，迁移前/最终SQL备份身份和哈希已记录；最终备份独立恢复NOT_RUN。
- 新自动化表账号擦除集成专测NOT_RUN。
- B2调度随API容器退出，API重启后需要按本机运行手册手动恢复；长时间生产负载NOT_RUN。
- Owner手机及整体实机验收NOT_RUN，按Owner决定延期至B1+B2+B3完成。
- B3、B4、阶段C、main集成、正式发布和真实运营均未授权/NOT_RUN。

## 六、最终验收决定

`CONDITIONAL_ACCEPTANCE_IN_NAMED_SCOPE — R1_01_OPEN — NO_R2`

- 已接受部分：AC16-01、AC16-06；AC16-02、AC16-04、AC16-07按具名范围及限制接受。
- 待R1关闭：AC16-03、AC16-05。
- R1-01：OPEN，P1，代码+定向回归。
- R2：NOT_REQUIRED。
- Owner接受：PENDING。
- main集成/正式发布：NOT_RUN。
- B3/B4/阶段C：未授权。

R1修正后由Codex推送同一任务分支、固定提交并完成同源远端回读，随后请求GPT顾问第二轮复核。无需重跑本报告列明的所有已通过测试，也无需Owner中间版本实机验收。
