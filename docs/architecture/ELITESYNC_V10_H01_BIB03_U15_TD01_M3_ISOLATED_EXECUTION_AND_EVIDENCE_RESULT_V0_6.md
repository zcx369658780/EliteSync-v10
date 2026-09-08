# EliteSync v10｜已验证派发接入与条件式隔离M3结果 v0.6

Status: `PROPOSED — M3 PRECONDITION BLOCKED — HOST DISPATCH INTEGRATION SELFTEST INCOMPLETE — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`

最终分类：**M3 PRECONDITION BLOCKED — HOST DISPATCH INTEGRATION SELFTEST INCOMPLETE**。

Owner对v0.6的直接批准已记录；本轮专用RemoteSigned宿主进程策略门通过，但006实际接入的RunNative/RunBatch未完成六组集成验收。任务允许的两个自产代码纠错轮次和三个宿主自测进程均已耗尽，且任务要求最后一次宿主自测通过后才可启动Sandbox。因此没有启动Sandbox、客体、工具复制、真实pub或M3；AAR保持NOT_CHECKED。

Attempt=`M3-ISO-V02-006`；日期2026-09-09（Asia/Shanghai）。Owner在Codex界面选择GPT-5.6 Sol、Medium；未修改模型配置或调用辅助代理，不另行推断宿主完整model ID/加载链。

## 1. 固定身份、批准与输入

实时main A=`f3430901bdc06607d5506a90b69988de24ee353f`；FIRST交接blob=`18485c95262051e43892436fb52413132c5ee626`。任务分支指向T=`a0f3c52034ce64c67fd01dfcff9377b46de4f631`，任务blob=`1dcbc970a89b7c4b989b4c6ff4e11791ed4e55e6`；T唯一父A，且相对A只新增任务单。

Owner本条指令明确批准v0.6：只在本任务专用宿主自测和沙箱客体入口进程使用RemoteSigned，限定冻结脚本路径/hash/生命周期；允许新建006工作区、接入派发修复及条件满足后的禁网准备、一次离线pub和一次M3。没有把v0.5授权视为自动续期。

A中七个精确仓库输入blob均匹配。固定A对象最初在本地不可用，按任务仅fetch到`refs/elitesync/m3-iso-v02-006-input`；Git同时更新既有`origin/main`跟踪信息。没有checkout、status或默认index操作。local HEAD=`d1b45cc5da30bba3f377ef4ead2c677d0fb6eb88`仅作上下文。

新工作区`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-006`开始时不存在，字面祖先均为普通目录。固定Git对象的Flutter模块过滤快照机械物化526个文件；defines按三处精确键解析为EMPTY，即零个追加参数。该物化未形成产品源码分析。

## 2. 旧来源和006脚本绑定

七项旧来源开始/结束SHA-256均匹配：

| 来源 | SHA-256 |
| --- | --- |
| 005 guest.ps1 | `701405E5B5FF33E542FB539C1EA7D6AC5D5F30B40B97EC2C998F0FF288BA52CB` |
| 005 copy.ps1 | `C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC` |
| 005 host-selftest.ps1 | `4907E638B03A1717D215546621603BDA11DD78A28CEA11094403A7F3162AA8A8` |
| 005 result.json | `04578F2DFD5294992E586CDB6F6A5185C94749A11D2F27000960C4FBD99DC928` |
| CMD-001 dispatcher snippet | `9CC6B72536D21119B01E2AEBA925DAD9A60D96C6DF97A931BDFCEFCD5485A894` |
| CMD-001 minimal patch | `4F0532B9A632B2747E90F6E80FC26C2F85AF5F884FB5C0DA8964DE8FE009350A` |
| CMD-001 test-results.json | `8E9BE24817C722F6FC54E3F162F75D526DCFA4C2A398EBE5AA7E986BCC3BBC5A` |

006脚本通过PowerShell 5.1 AST语法解析，最终字节为：

| 脚本 | SHA-256 | 状态 |
| --- | --- | --- |
| scripts/copy.ps1 | `C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC` | 与005字节一致；未执行复制 |
| scripts/dispatch.ps1 | `65004B90BB332CF33AEDFAA957849C3B4C07E336DEAB90E8D244778CFC172A13` | 接入候选；宿主测试发现参数绑定缺陷 |
| scripts/host-selftest.ps1 | `A724E7375C42B8C127E184909C78F6B89E4F5AC8DEAB9EFCD7C6A5F45B7CED04` | 两次有限纠错后的最终版本；仍未PASS |
| scripts/guest.ps1 | `AB7A2B5A8A22EB705EAD31AE4372ADFFA1AB764C8ED6B520E222E7309208FC83` | 已生成但未部署/执行 |

四文件精确Zone.Identifier读取均为流不存在；未删除来源标记、解锁、改信任或绕过签名检查。copy、原策略流程和Job C#控制未被执行性重写。

## 3. 宿主策略和三次集成自测

每次专用进程均使用System32 Windows PowerShell：

`-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command <bounded bootstrap>`

最终策略记录：MachinePolicy/UserPolicy/CurrentUser/LocalMachine=Undefined，Process=RemoteSigned，effective=RemoteSigned。Security manifest经GetFullPath规范化后Name及Path匹配；ModuleBase/Version未设附加门。

| 进程 | 实际结果 | 是否加载派发器 |
| --- | --- | --- |
| round 1 | bootstrap把斜杠形式差异误判为Path不等，并误用只读自动变量`$Host`保存hash | 否 |
| round 2 | 策略门通过；host绑定的嵌套`(path,hash)`数组被PowerShell扁平化，GetAttributes收到合并字符串 | 否 |
| round 3 | 策略门通过，copy/dispatch实际加载；六组调用未通过 | 是 |

两次纠错分别只做Path规范化/变量改名，以及将脚本绑定改为显式对象；未改策略、信任、复制算法或系统。三个进程和两个纠错预算均已耗尽。

round 3的直接证据：

- `RunBatch`将形参命名为PowerShell自动变量`$args`，实际参数数组未保留。前五组最终Arguments均只含批处理目标，没有pub/M3/define等参数；五个目标均无ENTERED、exit=1，exit37也未被保留。
- host-selftest的六组`$cases`仍使用会被扁平化的嵌套数组。第六组字段错位：目标变成已有plain目录，cwd变成`pub get --offline`；`ProcessStartInfo.Start()`保存`PROCESS_START_FAILURE`和“The directory name is invalid”，没有batch记录。
- 因此不能采用“前五组成功、第六组仅负例未捕获”的较强说法。实际为0/6通过，host集成总结果FAILED。
- 该失败属于006自产接入/采证代码，不推翻已接受CMD-001独立合成结果；但在当前冻结006中，不能宣称修复已正确接入。

最终宿主控制器PID 36748以及已启动cmd PID 24628、32612、10600、28864、45296均已退出。未按进程名终止其他会话。

## 4. 未执行阶段

| 阶段 | 结果 |
| --- | --- |
| Host RemoteSigned/模块绑定 | PASS |
| Host六组集成测试 | FAILED，0/6 |
| 脚本冻结/只读部署 | 未满足前置 |
| Windows Sandbox | NOT_STARTED |
| Guest策略/隔离/派发冒烟 | NOT_RUN |
| 八项工具/seed复制 | NOT_RUN |
| 真实`flutter pub get --offline` | NOT_RUN；dispatch=false，entry=NOT_ESTABLISHED，exit=null |
| M3 release-only | NOT_RUN；dispatch=false，entry=NOT_ESTABLISHED，exit=null |
| AAR | NOT_CHECKED；probe_count=0，size/hash=null |
| M2条件 | 不具备 |

普通宿主收尾进程未带ExecutionPolicy参数：五个scope均Undefined，effective=Restricted，exit=0。不存在持久RemoteSigned策略变化证据。

## 5. 证据保存与下一精确缺口

证据根：`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-006/evidence`。保存Owner激活状态、固定输入、源码物化、defines=EMPTY、脚本hash/语法、三轮bootstrap/控制台、最终策略、每次ProcessStartInfo记录、stdout/stderr原始字节、两个纠错说明、终态result及普通策略对照。未发生阶段不伪造日志。

最小剩余缺口是修正006接入层的两个PowerShell绑定问题：避免使用自动变量名`$args`作为RunBatch形参，并用非扁平结构表达六组cases；之后必须在新的明确任务/预算下重新取得同一runner的六组PASS。当前任务已到自身硬停止点，不能在冻结后继续热改或追加第四个宿主自测。

这不是新策略、Git、长路径或cmd方法研究需求，也不支持重新复制SDK来验证。没有外部网络、安装、Sandbox、Flutter/Dart/Java/Gradle、真实pub/M3/M2、artifact probe或产品实现。原仓库、宿主SDK/cache、用户配置和旧证据未写。

候选仅新增本报告并更新CURRENT_CONTEXT页首/§1/§4/§5；§2/§3/§6/§7原文保持。执行者不自我接受、不更新main、不另发任务、不更新AGENTS或项目源。
