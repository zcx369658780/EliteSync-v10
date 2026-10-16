# EliteSync-v10｜v10.0.9 R3 临时源码审阅终结论（非产品验收）

2026-10-17。**R3_SCRIPT_SOURCE_REVIEW_PASS_WITH_OBSERVATIONS / READY_FOR_NEW_EXPLICIT_OWNER_AUTHORIZATION / REAL_UAC_AND_FIREWALL_WRITE_NOT_RUN / AC-09-03 NOT_PROVEN / V10.0.9 NOT_ACCEPTED**。

## 身份与可复核的原证

- Codex独立临时审阅分支：`review/temporary-evidence-v1009-r3-20261016`，固定审阅 Commit `1ec67749fe8d6129cc0593a8de19703620e3a403`、Tree `a7da76b27e621adb02bba1061c6f5607d661bea9`，提交唯一父节点 `2d490942271b2ee91da007ff9f3fccbe121f1e8d`。本次Astra通过GitHub连接实读，不采用Codex声称已读的文件来代替。
- 固定子树 `docs/_temporary_review/v1009-r3-20261016`，Git tree SHA `b421d34be69038fb202dc7fd417b8008c48fe539`，独立GitHub递归枚举 **324个blob / not truncated**。来源/脱敏manifest **317**个映射条目；额外7个是发布入口、索引、脱敏、安全和实时资源摘要；`FILE_INDEX.md`有323条普通文件记录（自文件索引不自列）。317条映射均存在于实际Git子树，索引/manifest对应条目的原始与公开SHA字段无冲突。
- Astra直接读取了全部 **7个实际运行脚本及5个离线测试脚本**，并在本轮使用独立的UTF-8 SHA256算法重算**这12个公开副本**，全部与 `ORIGIN_AND_REDACTION_MANIFEST.json` 中公开副本SHA吻合。公开12脚本中10个声明与原件字节相同，2个源码`runtime/contract.py`、`runtime/FirewallAdapterCore.ps1`因私有本地路径脱敏而与原始SHA不同；Astra未获得这两份本地原始字节，故**不能**自称独立复算它们的原始SHA。原始7脚本bundle身份仍按Codex原证 `abff4948f8cb18e11b3b8c3c5efd3e776d48946a36ae3f55637f022b9f1b1425`（CODEX_REPORTED，公开副本不是可运行原包）。
- 实读：`audit/TEST_BINDING.json`、`audit/INDEPENDENT_REVIEW.md`、原R2→R3脱敏diff、`MATRIX_RESULTS.json`三套、顶层实际exit JSON、`audit/DEVELOPMENT_DIAGNOSTICS.json`、`PUBLICATION_SAFETY_REVIEW.md`及本轮`CURRENT_RESOURCE_STATE.json`。没有在Astra运行环境执行Windows NetSecurity、UAC、设备或媒体测试，也未声称独立重跑48+37+5。

## 实际源码安全判断

**PASS的内容：**

1. `contract.py`从固定SHA256本地参考提取四条规则，要求精确集合TCP/7881＋UDP/7882的Block/Allow、既有WLAN/指定宿主、63项互补IPv4与3项精确来源；`validate_authorization`拒绝TCP子集、旧/错Run ID、错误bundle、过期/未签发许可，绑定最长1200秒且剩余不足300秒拒绝。
2. `network_worker.py`默认非执行，真实网络动作仅显式`--execute`和Owner授权材料、实际管理员`LiveProvider`经过验证才进入；离线模式分开。`LiveProvider`检验管理员令牌，调用固定PowerShell wrapper＋共同Core，实际创建参数必须在四规则合同之内。
3. `FirewallAdapterCore.ps1`创建前后精确检查规则名、动作、协议、端口、完整来源成员与原私有参考SHA；创建规则受限于WLAN/原宿主、Inbound/RemotePort Any/Program Any/Service Any/EdgeTraversal Block；不接受包装地址或异常来源集合。查询覆盖大小写变体，删除须匹配本run marker、实例和可观察规则字段；不删除不明归属同名规则。
4. `network_core.py`使用唯一Run ID、不可覆盖目录、独立STOP；逐项创建，失败立即停；对“先创建后报错”重读收编可证明属于当次的对象，异常/正常均尝试删除；最终独立查询有残留返回31、未知返回32，创建失败即使清净仍返回非零，外层继承真实退出码。`launch_owner_window.py`显式UAC、GetExitCodeProcess、再次只读回读，未根据伪造PASS文件推断成功。
5. `run_adapter_matrix.py`确实通过`LiveProvider._call/query_all/create/remove`路径，用精确的真实PowerShell命令文本（包含`Invoke-FirewallOperation`共享Core）与`OfflineAdapterHarness.ps1`的隔离函数覆盖系统Get/New/Remove，且禁止真实防火墙调用；不是一套替代运行逻辑直接冒充实际入口。明确测试UDP来源扩大、错动作/端口、私有marker、异名/大小写规则、系统作用后抛错、部分清理失败、最终UNKNOWN等。
6. 实读通过的测试记录为：原核心48/48、适配器37/37、启动器WinAPI替身5/5，三份对应顶层exit均0；并实读两次早期离线fixture错误exit99原因，没有抹去失败。`TEST_BINDING.json`源文件身份与测试输出对应；`PUBLIC_SAFETY_SCAN`报告无公开内容问题。

**不越界解释的限制/观察：**

- 37/37中调用系统防火墙命令的实际运行代码，但NetSecurity操作被纯离线mock代替；启动器WinAPI亦使用替身。**没有**证明真实UAC、真机网络规则创建/删除可用、系统挂起/强杀/Provider异常下硬实时删除。Window上Docker管道当前查询exit1，容器及卷实际状态UNKNOWN；APP和设备账号/安装hash未在本轮重新查。
- PowerShell公开副本两处只有私有路径替换；两份真正原始脚本哈希/完整参考内容由Codex本地校验、Astra不能直接自证。下一次真实执行需再次核SHA与私有参考，并重查设备/来源，任何差异立即停止。
- 规则回读字段不构成Windows规则全部潜在属性或外部并发篡改的形式化证明；不可保证额外外部策略不干扰。四规则脚本只管理防火墙，**不代替**DB/SFU/API/APP/RTC的自动退出监督。应当在实际创建规则前核对环境服务监督和Owner当时可参加人工试听，任何尚未审批的扩展动作都停止。
- 公开资料只适用于源码安全审阅；可能被其他人从Git历史/克隆保留。敏感资料从未进入本临时包，且清理远端分支也不能保证历史字节彻底消失。

## 结论、后续权限及清理

**R3网络脚本源码门：PASS_WITH_OBSERVATIONS，已足以进入Owner下一次独立系统网络与语音测试授权审查，不再要求无原因的R4脚本重写。** 这不是Owner已批准运行，更不是AC-09-03的真实双向语音PASS。R1-1/R1-2此前结论保留，v10.0.9总版仍`NOT_ACCEPTED`；无正式`acceptance.md`、无`main`产品集成、无K08/后继版。

根据Owner已批准的[临时审阅材料清理协议](../../workflow/TEMP_REVIEW_EVIDENCE_PROTOCOL.md)，完成此固定源码复核后可清理临时审阅子树/独立分支：优先以一次**仅影响临时分支**、非force的反向树提交从其最新HEAD移除该临时目录，并回读GitHub分支工作树；当前GitHub连接器不提供删除远端branch引用，需Codex按唯一具名分支精确执行远端分支删除并由Astra核验。**不能**删除`main`、`codex/v10.0.9-rtc-media`或原LOCAL_ONLY，不能对Git仓库prune、reset、历史重写或声称Git对象已不可恢复。清理动作是否完成须依后续真实GitHub结果另登记。
