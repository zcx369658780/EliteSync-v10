# v10.1.16 R1-01：自动化授权不得暂停独立手动报名

状态为 `CLOSED`。

严重程度为 `P1`，范围为 `SOURCE + TARGETED TESTS`。

顾问报告：[ADVISOR_ACCEPTANCE_20261115.md](ADVISOR_ACCEPTANCE_20261115.md)

## 固定对象

- 分支：`codex/v10.1.16-user-state-automation-center-20261115`
- 被审阅交付提交：`c635dcadbbeec93e9b4287aaab9ae187742e226a`
- 产品源码：`00cec7843911bb3341304c004059de0a91e12f16`
- 唯一父基线：`b981796e68ca512beeed2a18b40aeb8b09e26bc2`

## 首轮发现（对应原产品源码）

`AutomationAuthorizationService::command()`在pause/revoke后无条件调用`pauseParticipation()`；该方法只检查慢约参与状态是否ACTIVE，没有检查`matching_participations.automation_authorization_id`是否绑定到该自动化授权。

因此，用户先前独立手动报名（ACTIVE、无automation_authorization_id），之后授予自动化但尚未发生自动化effect，再暂停/撤销/到期时，系统会把该手动参与改为PAUSED。这超出“停止未来自动报名”的授权范围。

同一绑定路径还在`AutomationService::apply()`中写入参与委托字段，却未推进`matching_participations.revision/updated_at`；`UserStateService`返回delegated与参与source_revision/source_updated_at，因而来源版本不能完整反映委托绑定变化。

## 修正要求

1. pause/revoke/expiry只暂停确实绑定到本scope授权记录的参与；未绑定的手动ACTIVE参与必须保持state、generation、revision、intent不变。
2. 已委托参与在pause/revoke/expiry后仍按原规则停止未来参与；不得自动处理当前proposal。
3. 到期时授权revision可能已经递增，正确识别同一授权记录的既有绑定；不能因revision变化漏掉真正委托的参与。
4. 委托绑定字段发生实际变化时，推进参与revision并更新updated_at；effect receipt记录绑定后的最终参与revision。重复相同绑定不重复递增。
5. 保留锁序、fencing、幂等、UNKNOWN核对和有限重试合同。

## 回归测试

- 手动ACTIVE → grant → 未产生effect → pause：手动参与保持ACTIVE，generation/revision/intent不变。
- 手动ACTIVE → grant → 未产生effect → revoke：同上。
- 手动ACTIVE → grant → policy/expiry失效 → scheduler：同上。
- 已委托ACTIVE → pause/revoke/expiry：按合同暂停未来参与。
- 用户手动opt_in清除委托绑定后，再revoke自动化：手动ACTIVE不被暂停。
- ACTIVE手动参与被绑定后：delegated变化推进参与revision/updated_at；generation不被无故改变；effect receipt记录最终revision。
- pause/revoke不改变proposal及slot原记录。

只在虚构账号、隔离MariaDB/测试库运行。不得对主开发库做测试性清理或尝试重建首次误连探测的逐表摘要；原UNKNOWN必须保留。

## 验证与交付

- 运行上述定向PHP/API/隔离MariaDB测试、受影响PHP语法检查及必要相关测试。
- 不要求重复104项全套、重建APK或操作Owner手机，除非实际修改APP源码。
- 更新实施报告、manifest、证据摘要及本R1关闭记录。
- 推送原任务分支并完成同源远端回读。
- R1修正后停止，等待GPT顾问第二轮复核；R2当前不需要。

## 明确不做

不修改匹配算法、候选排序、管理员轮次控制、matching run consumer、Connection、Messaging Consent、Conversation或Relationship状态机；不合main、不发布、不启动B3/B4/阶段C。

## 2026-11-16 工程关闭回执

R1-01已按原修正要求完成，状态为 CLOSED。关闭主体为 Codex 工程执行，GPT 顾问第二轮复核 PENDING，Owner 接受 PENDING，NO_R2 沿首轮记录。

修正源码 `4bfa9245f06548197532ecec2d5da0397ba8d33d`。暂停/撤销/到期按授权记录 ID 选择真正委托的 ACTIVE 参与，独立手动参与及手动清除绑定后的参与保留完整行。实际绑定字段变化推进参与 revision/updated_at，effect 收据记录最终 revision。相同绑定重复执行保持版本。

- PHP/API定向27项、267断言通过，其中新增十个R1参数化case。
- 新隔离MariaDB的十个场景、36次真实回环HTTP请求通过。
- 隔离MariaDB中两种SIGKILL窗口、双worker并发、撤销竞态四项通过，旧锁序、UNKNOWN核对及有限重试由本轮定向组覆盖。
- 四个受影响PHP文件语法和固定源码运行身份核对通过。
- 已委托参与停止后proposal/slot原值保留，接受门禁及用户withdraw权限验证通过。

APP源码沿初次提交，1011601原APK SHA256核对一致。原始误连探测逐表摘要继续UNKNOWN。原数据库保持停止，验证数据仅写入本轮新建隔离库。

完整结果见[实施报告](IMPLEMENTATION_REPORT.md)、[manifest](artifact_manifest.json)及[证据摘要](EVIDENCE_SUMMARY_20261115.json)。本关闭记录由其所在最终文档提交固定，推送和同源远端回读结果列于交付回复。完成后等待GPT顾问第二轮独立复核。


## 2026-11-16 GPT顾问第二轮复核

第二轮顾问复核结果：`PASS — R1-01 CLOSED`。确认暂停/撤销/到期只影响绑定到本授权记录的ACTIVE参与；未绑定的独立手动参与保持完整；实际绑定变化推进参与revision/updated_at，effect receipt保存最终revision；proposal/slot和显式withdraw边界保持。R1无需R2。详见[第二轮顾问复核报告](ADVISOR_R1_REREVIEW_20261116.md)。Owner整版接受仍PENDING。
