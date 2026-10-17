# EliteSync-v10｜v10.0.9 真实四规则窗口 exit31：Astra 独立归因审查

2026-10-17。**ROOT_CAUSE_PARTIAL_ACCEPTED / SOURCE_COLLECTION_ORDER_DEFECT_CONFIRMED / FIRST_EXCEPTION_LINE_UNKNOWN / R3_REAL_WINDOW_FAILED / RESIDUAL_CLEARED_CODEX_REPORTED / AC-09-03 NOT_PROVEN / V10.0.9 NOT_ACCEPTED**。

## 一、固定审阅身份及范围

Astra通过GitHub连接实际读取临时审阅分支 `review/temporary-evidence-v1009-exit31-20261017`，其固定Commit `09ed26b611959aa4a8b141180c41a7020a98b4ad`、Tree `dc197ea5503ddca1fc5204d7b2cf3d0d92790ad6`、唯一父节点 `cd76d51a277f99b412d14cf1fcaf38606264f7ae`；GitHub树完整枚举 `docs/_temporary_review/v1009-exit31-20261017/` 下39个文件，无截断。审阅内容包括 `ROOT_CAUSE_REPORT.md`、`FILE_INDEX.md`、`evidence/FAILED_WINDOW_REPORT.md`、`worker-result.json`、`network-parent.stdout`、`network-observed-exit.json`、`RESIDUAL_READONLY_DIAGNOSIS.json`、`FINAL_CLEANUP_RECEIPT.json`、`CURRENT_RULES_READBACK.json`，以及 `source/network_core.py.txt`、`live_provider.py.txt`、`FirewallAdapterCore.ps1.txt`、`Remove-One-Owned-Residual.ps1.txt`、controller及文件/哈希清单。39个文件中索引表列37项，另外2项是自索引`FILE_INDEX.md/json`，未发现漏传的索引目标；原私有地址与脚本绝对路径未上传。

**重要证据等级**：Astra实读并独立比对了公开源码/原证副本与Git树；真实Windows防火墙规则及时间、退出回执来自Codex采集，属于`CODEX_REPORTED`；私有原始PowerShell返回数组和完整原始字节未向Astra公开，不能假称重新在用户Windows运行。

## 二、独立可证实的代码缺陷与一致性

1. `network_core._normalized()`仅规范单个CIDR文本，不对`remote_addresses`作无序成员处理；`live_provider.LiveProvider._map()`以该比较条件决定是否将系统返回记录映射为固定参考spec。若系统返回63项集合相同而顺序不同，则映射不发生。
2. `network_core.run_transaction`中`adopt(rows)`要求`row.spec == attempted spec`；该比较将Python列表顺序计入身份相等。原回执`RESIDUAL_READONLY_DIAGNOSIS.json`记录1条目标规则的marker、Description和实例一致、remote数63、类型str、同一成员集合、排列不同；因此它不能被adopt。
3. 原`worker-result.json`记录`created_count=0 / removed_count=0 / remaining_count=1 / errors_safe=[CREATE_FAILED,FINAL_RESIDUAL] / exit=31`。这里`created_count=0`仅代表未被Python收编，不是Windows创建0条；原`network-parent.stdout`证明父层观察到子进程31、独立读回1条残留；这与`finally`进入但`owned`为空、没有调用实际删除相符合。
4. `FirewallAdapterCore.ps1`当前Remove路径用两个JSON的完整字符串相等验证记录，也会对系统重排产生敏感性；**本Run尚未进入这个删除分支**，它是同一类别的潜在第二缺陷，不把其写成此次已发生的删除失败。
5. 因为`LiveProvider._call`原实现丢弃PowerShell stderr且不保存各次cmdlet退出码，缺少首次异常栈。可以把首次失败缩小到**首条已创建后读回/收编/回执/身份确认**的某一阶段，不能精确声称发生在某行或取得了某个PowerShell原生exit值。保留`ROOT_CAUSE_PARTIAL`，不升为`ROOT_CAUSE_CONFIRMED`。
6. 实读`Remove-One-Owned-Residual.ps1`显示后续单次具名清理使用名称、run marker、实例SHA、全部规则参数、原参考SHA和来源集合排序后逐成员比较，再进行一次精确删除。`one-rule-cleanup-result.json`及`FINAL_CLEANUP_RECEIPT.json`均报告exit0；2026-10-17 02:02:10 UTC最新只读`CURRENT_RULES_READBACK.json`报告ActiveStore和PersistentStore的4条目标规则分别为0、查询exit0。此状态对用户Windows属于`CODEX_REPORTED`，但审阅副本内回执一致。

## 三、验收结论与唯一下一阶段

**本轮只读取证/归因：PASS_WITH_OBSERVATIONS；缺陷定位为已确认的系统返回成员顺序与严格spec相等冲突。** 先前R3`SOURCE_REVIEW_PASS_WITH_OBSERVATIONS`指*离线代码与模拟测试*，不保证真实Windows可用；本Run真实窗口确实FAILED，不能由清理成功倒推已经通过。

**批准原v10.0.9范围内下一项“纯本地定点代码修复及离线故障注入”任务，不批准真实系统操作。** 修复边界：

- 保留Owner固定四规则、TCP7881/UDP7882、原WLAN/宿主绑定、63项Block互补、3项Allow精确来源、请求数组顺序严格门、全部冻结AC、原受限时间/Run ID/marker/实例与外来规则不可收编的约束；
- **仅对系统返回记录**做严格类型、数量、无重复、归一化表示及成员集合等价判断，然后回填固定参考顺序；处理create回执、读回、owned收编、verify、remove前live映射及PowerShell删除复核时的等价性，但仍须校验外部规则的其它精确字段/身份/Store归属；
- 增强安全的操作序号/阶段/真实PowerShell子进程退出码/失败类型记录；只保留白名单错误类别和哈希/计数，不输出原私网地址、完整stderr、JWT或设备信息；
- 必须新增经**实际LiveProvider及共享PowerShell操作核心**隔离替身的用例：四条规则每一种乱序、Create/Query不同顺序、重复Query再次乱序、创建生效后异常重排并回滚、所有来源替换/扩张/遗漏/重复拒绝、marker/实例/其它参数变化不误删、部分清理失败及残留/UNKNOWN非零、既有请求乱序拒绝。原48/37/5测试不降低断言，按受影响范围回归；
- 执行前保护R3原包，修订产物以新SHA/Bundle固定，独立非作者审阅，结果真实退出码与失败保留。Astra通过**独立短期、公开可安全脱敏审阅包**核验后再做新的系统操作授权判断。不得把脱敏副本冒充可执行原始Bundle。

**本任务不授权**UAC、四规则创建/删除、启动DB/SFU/API、操作设备、语音/视频窗口、下载/驱动/权限扩大、覆盖原dirty root、合main/K08或后继版本。原一次性窗口授权已使用完毕；本修复完成亦不能自行重试网络，必须Owner另行明确批准。

## 四、临时分支清理

这39个文件仅用于本轮独立审阅，完成正式归档后允许按`docs/workflow/TEMP_REVIEW_EVIDENCE_PROTOCOL.md`仅清理该独立分支的临时目录。Astra在可用连接器能力内作无force快进、移除临时目录并回读；删除短期远端分支引用仍由Codex按精确HEAD执行，Astra最终回读404。任何清理均不宣称已从Git历史/外部缓存永久删除。
