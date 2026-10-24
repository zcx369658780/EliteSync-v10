# v10.1.5 源同构 Aggregate Serializer 诊断交付

终态：**SOURCE_FAITHFUL_REPRODUCER_IDENTIFIED / D0_B_STATIC_SCOPE_BLOCKED / TARGETED_FIXTURE_NOT_RUN / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

本次为同一任务续接，不重置预算。D0-A真实对照已定位源同构最小重建中的两个独立最小失败字段；续接核验发现投影初稿未满足Owner明确的两字段范围和实际调用要求，因此停止相关源码修改与测试，仅交付停止证据。未运行的fixture不记为运行FAIL。

## 固定身份

- 正式任务 Blob `009a12cae75ef3b714f0156d4edbca2db1660719`；前置Astra复审 Blob `7eae0044f8c1621a5e6fdf8a8f637462b1596385`。
- 唯一Parent `0d18a2362cedfc545c17bf4c4bc207a8cbb2cfc5`，其Root `bba458cf1f054276f6ee519ceede25f0636ec8ea`，Parent的唯一Parent `0ef15686104e0260c3abb34071b8c731f577094a`。
- 分支 `codex/v10.1.5-source-faithful-serializer-conditional-sdk`。本候选仅新增本报告和同目录Manifest；最终Commit、Root、文档Blob及author/committer在提交后独立身份回执和远端回读中固定，避免文档自引用。
- 初始live main `1375e41c7a603c8e1e7f74337b768a32cbf883e6`；续接及D4 fresh main `597570e2191d448bcc64da64ce1a56edeba479ed`，Root `a7c7118074acfd423f4dbc7bf2af6868f6e70ca0`。其间只推进ACTIVE_STATE及本任务会话交接文档；不将任务发布时main当成当前值。
- 续接交接Blob `0b5ebcecda7958440cb7c70e09f222664556f4cc`，ACTIVE_STATE Blob `15d2f903df8a8ae83a5d3a16df1eb3d68e6e7a04`。
- 候选apps Tree `785822ca072943c5bfefa3ccc37ede01c2af5164`（1133条）、services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`（791条），与连续Parent完整path/mode/type/object maps相同。main已接受v10.1.4产品仍是apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，未覆盖研发候选。

## D0-A真实诊断及证据边界

固定fixture、writer、schema、plan Hash已核验；第95行13字段生产表达式和原New-ReceiptParser工厂设置保持。最小body明确为`SOURCE_FAITHFUL_MINIMAL_RECONSTRUCTION`，cases仅一个同源结构合成摘要，actualCount=1。原始37案例body、fixture-body.json/tmp未保存，保持`ORIGINAL_AGGREGATE_OBJECT_NOT_PERSISTED`，未运行原fixture恢复现场。

一次诊断内共15次Serialize（上限32），整体约0.688秒（硬限15秒，含结果读回与退出确认），exit0、进程退出确认、未超时。空字典PASS；13个单字段中11个PASS，`$.started`和`$.finished`分别单独触发TARGET_FAIL，完整13字段body亦TARGET_FAIL。两个最小失败集合各含一个字段，而非两字段必须组合才失败。异常类型为`MethodInvocationException -> InvalidOperationException`，安全摘要为`PSPARAMETERIZEDPROPERTY_CIRCULAR_REFERENCE`。诊断成功是指获得此对照结果，不是Writer通过。

已知时间表达式产生PSObject包装String；同源实验足以隔离失败字段，但未恢复原对象，也没有证明原始serializer内部成员发现的完整引用闭环。历史600秒SDK截止与约269秒后迟到PSInvalidCastException、Decimal回放、原fixture循环异常分别保留；其同因及历史PSInvalidCast根因仍UNKNOWN。不再消费诊断预算。

## D0-B初稿核验与Gate 1停止

任务自有LOCAL_ONLY `AggregatePrimitive.cs`真实存在，12489 bytes，SHA-256 `c6469958b98b50c9f6d4e07b2cbce3ac5987ced635306e3d6d612b6047353c83`。绝对路径、完整源码和相对不存在原文件的新文件diff均保存在LOCAL_ONLY续接核验报告；不存在可比较的旧版C#原文件，故diff是完整新增文件，不能称已完成最小修复。未编译、未执行、未接入WriteAggregate调用点；投影后的运行时字段类型没有观测值。

静态`Project`的PSObject分支只判断BaseObject是否String，没有限定路径为`$.started`或`$.finished`，会在任意schema路径解包String wrapper。全任务搜索仅找到类/方法定义及快照，未找到实际编译或消费接入证据。因此既不能证明只处理两个已定位字段，也不能证明实际序列化边界已经过投影。13个RootKeys、白名单、fallback与原子写入均只是未执行框架。

同一非作者GPT-6.1 Sol/high有界只读复核确认Gate 1不满足，支持按Owner“无法证明仅作用于已定位字段立即停止相关修改”条款停止。原稿及快照Hash保持，不收窄或重写原稿，不运行fixture；这不是投影运行失败或产品缺陷验收结论。未要求Owner重复派发同任务，交付后等Astra裁决。

## 实际预算与后续门

| 阶段 | 本任务实际次数/结果 |
| --- | --- |
| D0-A源同构诊断 | 1次，15次Serialize，退出已确认；未重跑 |
| 投影运行 | 0；初稿静态门阻断 |
| 15秒aggregate正负例 | 0，NOT_RUN |
| 60秒完整37案例suite | 0，37案例均NOT_RUN，WRITER_FIXTURE_NOT_PASS |
| 新Sandbox及SDK/Flutter CLI | 0，SDK_NOT_READY |
| 真实Debug Producer | 0，PRODUCER_NOT_RUN |
| 本轮libs.jar | 未生成、未验收 |
| 正式Configuration.resolve() | 0/30，全部NOT_RUN |
| APK/设备/RTC/SFU/DB/main集成 | NOT_RUN |

后续预算未消耗但门禁关闭，不因此自动放行。未重做历史DAG、HOST、GPU、Git trust或历史SDK预检。未下载、升级工具、修改系统网络/全局Git/ACL，未处置未知guest。

## 证据分层及保护

公开仅本报告与Manifest的脱敏结论和Hash。完整源码/diff、原始stdout/stderr、计时/退出回执、受保护路径、进程及环境材料均LOCAL_ONLY；Manifest逐项固定关键证据Hash。此前准备阶段重复CreateNew引发FileExistsError的工具回执属预处理错误，不算诊断重跑、fixture或产品运行失败。已保存材料不能证明排除了未知的未落盘内存状态。

界面“无法显示内容/Daybreak”提示不等于命令拒绝或软件安全缺陷；现有本任务证据没有具体环境拒绝记录，不以此判Writer/Serializer/SDK FAIL。未申请额外权限或绕过限制。

初始保护22178份具名文件（超过任务最低22094）、515 refs（超过最低514）；续接保护集22227份，包含当前已保存诊断、初稿及快照。终检22227份字节Hash全部保持，五历史Git根HEAD/branch/index/dirty与warning状态不变，515旧refs无缺失/改写；原失败38份JSON保留，SQL/APK/备份/SDK/私密日志仅在具名保护范围内核验。完整产品双Tree/maps保持。该检查不是全盘或活数据库审计。

D4静态停止之后的两次只读快照显示24项相关环境、21项Git环境及解析后的网卡/默认路由状态相同。该时间范围不覆盖先前D0-A，不冒充开工前环境快照或完整系统配置审计。非作者的静态/回执审阅不等于独立重跑。

## 交付约束

非作者最终文档尾检绑定两文件Hash后，普通non-force提交/发布，仅候选分支；远端逐项回读Commit、唯一Parent、Root、author/committer、两文档Blob与原UTF-8字节及完整产品maps。最终回读证据另存LOCAL_ONLY，提交前本文不预先宣称发布成功。

保持`OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。完成发布回读即停止，等待Astra独立验收，不签整个版本ACCEPTED、不自动创建或启动后继任务。
