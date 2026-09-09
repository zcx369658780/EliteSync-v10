# EliteSync v10｜M3 隔离执行与证据结果 v0.8-R1

Status: `PROPOSED RESULT — AWAITING INDEPENDENT REVIEW — M3 PRECONDITION BLOCKED — SANDBOX STARTUP NOT ESTABLISHED — NO M2 AUTHORITY`

日期：2026-09-09（Asia/Shanghai）。本报告记录一次已获Owner直接批准的v0.8-R1续行。执行者不自我接受，不更新main，不执行M2或产品实现。

## 1. 权威入口与旧008边界

实时GitHub main为`16225ef1db6063dacadd3bfc8b033b325c11d5df`；FIRST交接blob为`18485c95262051e43892436fb52413132c5ee626`。任务`d7d384b6616cbccd5a27a8ba2de649f07c624fea`的唯一父为该main，任务blob为`58cbfef2a382ae7aeeb78f17e1819fb0761ac251`，相对父提交只新增任务单。

旧v0.8任务`8262bc30815530f550cb472fda08b125efa1f5b0`因其固定main树错误而停止，没有GitHub候选。本轮确认ChatGPT tree-repair main恢复了007候选的精确树：CURRENT_CONTEXT、v0.7 task/result及其他规定输入blob均匹配。本结论不把旧v0.8伪造成已发布结果。

## 2. 旧host证据绑定与冻结runner

仅只读绑定`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence`中的四份精确证据，未覆盖、修改或重跑旧host测试：

| 证据 | SHA-256 | 绑定结果 |
| --- | --- | --- |
| result.json | `2F7EC60B608B821F1EB1271D6E17D6FE5CFFF99D26B77C23EB65E4D5304ABA0E` | 旧分类为固定main快照输入失配；Sandbox/pub/M3未启动，AAR未检查 |
| host-dispatch-selftest-1.json | `CA0657AD2FB8F9135D09744BB35622BD0C7668B055B3094A22A99E90B26E4DC4` | ordinary native 4/4 PASS；batch 6/6 PASS；两类exit37均原样传播 |
| script-preflight.json | `E0DF3472FDA26F726CBDDFED1B41CAAFE463370454512A58A2B2FAA770A079B8` | dispatch绑定到规定2C0A哈希 |
| host.log | `E2B5871BFBB5750A915806344364D5BC1EDB83F5E711BBB59283F1AFDA062655` | 解析并绑定；结束hash不变 |

旧host记录证明普通exe `override_present=false`、批处理`override_present=true`。旧host 4+6没有重跑。最终RunNative修复保持显式存在性语义：

```powershell
param(
    [string]$SerializedArguments,
    [switch]$UseSerializedArguments
)

if ($UseSerializedArguments.IsPresent) {
    $startInfo.Arguments = $SerializedArguments
} else {
    $startInfo.Arguments = ($ArgumentList | ForEach-Object { '"' + $_ + '"' }) -join ' '
}
```

RunBatch显式传`UseSerializedArguments=$true`；普通native调用不传该开关。PowerShell 5.1 AST、部署字节与调用点静态检查通过。冻结runner：

- copy.ps1：`C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`
- dispatch.ps1：`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`
- guest.ps1：`578F97570EED07274A2E783730F5130126A5D12C8A03FA3F4B0E9A41C1889D39`

## 3. 本轮准备证据

从tree-repair main的固定Git对象机械物化`apps/flutter_elitesync_module`，过滤后526个文件、reparse=0。三个允许来源重新定点解析`flutterDartDefines`，结果为`EMPTY`，因此M3形状预定追加0个define参数。

新WSB SHA-256为`2E92D5D446028AC0E7FC4831C0AB70DFC8EBD23AC74079DD138F98ACE6D9FB51`。XML静态核验记录Networking、Clipboard、Audio、Video、Printer及VGpu均为Disable；八项输入映射均ReadOnly，唯一宿主可写映射为`evidence/resume-r1`。

## 4. Sandbox实际结果

本轮只调用一次Windows Sandbox启动。`Start-Process`返回后，自有启动记录语句把PowerShell布尔字面量写成`true`而不是`$true`，导致PID/创建时间/exit尚未序列化时记录步骤失败。没有进行第二次Sandbox启动。

随后限定恢复未发现仍活动的匹配Sandbox进程；新nonce的`guest.started`在固定等待期限内未出现，guest结果文件也未生成。因此本轮只能记录：

`M3 PRECONDITION BLOCKED — SANDBOX STARTUP NOT ESTABLISHED`

这不是禁网隔离PASS，也不证明Windows Sandbox功能不可用。由于原始Process对象身份和exit未保存，启动器具体失败层保持UNKNOWN；不能把自有记录错误改写为guest启动或隔离失败。

## 5. 未发生阶段与进程收尾

| 阶段 | 本轮状态 |
| --- | --- |
| guest Process/effective RemoteSigned | NOT_RUN |
| guest nonce/网卡/默认路由隔离 | NOT_RUN |
| guest ordinary native冒烟 | NOT_RUN |
| guest batch pub/M3/exit37冒烟 | NOT_RUN |
| 八项复制 | NOT_RUN |
| 真实Git `--version` | NOT_RUN；exit=null |
| 真实Java `-version` | NOT_RUN；exit=null |
| `flutter pub get --offline` | NOT_RUN；exit=null |
| release-only M3 | NOT_RUN；exit=null |
| exact AAR | NOT_CHECKED；probe_count=0 |

专用证据绑定进程已结束；guest Job从未创建。恢复时没有活动匹配Sandbox进程，但因启动PID未序列化，不能给出该原始启动器的精确exit或完整父链。旧008四份证据首尾hash一致。

## 6. 证据限制与后续决定

本轮没有取得guest隔离、复制、真实Git/Java、pub、M3或AAR新证据；M2仍deferred。host 4/4与6/6是旧008已保存并在本轮绑定的事实，不是本轮重跑。

若独立审查接受本失败记录，最小剩余缺口仅是对一次新任务的Sandbox启动编排进行定点修正：必须先原子保存返回Process的PID/创建时间，再等待guest nonce；不得重跑host 4+6、重做dispatch/复制/策略方法研究，也不得由本报告直接续跑第二次Sandbox。
