# EliteSync v10.1.5｜8186cebc 受限身份OS隔离＋SDK写面｜Astra独立验收

审查日期：2026-10-28（Asia/Singapore）

**有界裁决：`8186_BOUNDED_BLOCKED_DELIVERY_ACCEPTED_WITH_REQUIRED_OBSERVATIONS`。**

本裁决仅接受**按冻结任务报告的一次受控子进程异常、无法取得权限矩阵回执、准确报告fixture恢复残余、定点SDK静态证据和停止交付**。受限身份OS门**未通过**；18项fixture严格恢复**未通过**；不得以本报告授予G2启动或其它工程权限。

**继续：`RESTRICTED_IDENTITY_GATE_BLOCKED / CHILD_EXIT_STATUS_DLL_INIT_FAILED_CLASS_ONLY / CHILD_ACCESS_MATRIX_NOT_RUN_14_OF_14 / FIXTURE_EXACT_SECURITY_DESCRIPTOR_RESTORATION_FAILED_18_OF_18 / OS_ENFORCEMENT_NOT_PROVEN / SDK_WRITE_CLOSURE_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / INPUT_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`。**

## 1. Astra直接GitHub身份和范围核验

- 任务合同 `docs/versions/v10.1.5/V10_1_5_RESTRICTED_IDENTITY_OS_WRITE_GATE_AND_SDK_SURFACES_TASK_20261028.md` Blob `f11cef5f3b729ae20120a184fc5a4ea085d6f5e0`，已直接读取。冻结授权限于用户态可撤销的任务自有微型fixture Windows权限检查、静态SDK写面；Gradle/JVM/Flutter、G2/claim、AAR/APK、D盘新清理、提权/全局ACL修改及实际工程进程为0。
- 本轮最新main `34b06e3c6dd9ae09cd767468052f1828a5a5ced0`，Root `0c54cb1201afe960fd8d8007db2f37849a44a86c`；已接受v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 候选 `8186cebc94661bcdc229ee5b62b31871dc784a4c`、唯一Parent `76e46d9966dcb29c9e7dea72f41a1cd59fe0e6d7`、Root `1d9ec83dbfe6c211d95f713d5aa4ab93f69d8bf7`；递归Tree共6666项、`truncated=false`，apps `5af7a9d0042be19437616e969e260658b67e9353`、services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`，与未接受来源76e两个完整产品Tree完全一致。
- 直接compare 76e→8186 ahead1/behind0，**仅新增2份安全文档**：`G2_RESTRICTED_IDENTITY_OS_AND_SDK_WRITE_GATE_REPORT_20261028.md` Blob `e773c0139dc4c0d6c91abad7553508382975d4e0`（20300 bytes）；`G2_RESTRICTED_IDENTITY_OS_AND_SDK_WRITE_GATE_EVIDENCE_INDEX_20261028.json` Blob `0cfc46b50f092b5c1c10df7ea4e065af3141144a`（32990 bytes）。Astra已读取两份正文、解析索引，核对Root对应path/mode/Blob/size。未将Codex本地输出升级为Astra直接Windows见证。
- 最新Astra前置76e裁决 `76E46D99_BOUNDED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`（Blob `fcbfcdf0b8fd5ba941ed7d0d030efb3612019fcb`），Seed 3183份属于Codex本地独立副本证据，OS整体仍BLOCKED，旧本地Seed不得因本次任务被改动。

## 2. Windows受限身份：部分进程创建证据成立，访问资格未证明

- Codex报告一次`CreateRestrictedToken`成功，随后一次`CreateProcessAsUser`成功创建微型受限子进程，并在suspended阶段检查token限制SID及非提升身份，之后resume；控制器exit90，子进程exit signed `-1073741502` / unsigned `0xC0000142`。记录子进程已退出及相关task-owned token/thread/process句柄关闭。**Astra没有运行该Windows API，也没有得到本地token/原始进程日志**。
- 微软NTSTATUS表把`0xC0000142`命名为`STATUS_DLL_INIT_FAILED`，只能解释错误类别；不能据此认定具体DLL、desktop、profile或启动时权限的唯一原因。参考：https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-erref/596a1078-e883-4972-9bbc-49e60bebca55
- 子进程首事件、stdout/stderr和文件测试回执**没有捕获**。访问矩阵14项（read/private-write、write/open、WRITE_DAC、owner、删除、rename、父目录及别名等）全部`NOT_RUN_NO_CHILD_RECEIPT`，并无任何受限child实测写入拒绝码。不得借用前一76e fixture的Win32 Error5作为本轮child证据。单次launch没有retry或另用普通token/提权入口；这是符合STOP门的受阻交付，不等于运行通过。
- pywin32 311封装签名、限制SID tuple格式、`WRITE_RESTRICTED`等的来源属于Codex引用的源码/接口语义，创建token和进程成功不推出完整ACL/parent/owner安全资格，也不认证未来实际Gradle进程的token继承。

## 3. Fixture恢复：存在实质残留，不可降级

- 18个task-owned fixture依次尝试恢复。Codex先发现PySID字符串表示比较不可靠，改为规范SID只读对比：ACE顺序/多重集合18/18、owner/group、FileId和保留文件原始内容均一致；**但descriptor control 18/18不一致，初值`0x8404`、恢复后`0x8004`，严格恢复0/18通过**。没有改共享SDK/cache/旧Seed的ACL或内容，也没有在失败后继续创建子进程。
- 差值`0x0400`对应Windows `SE_DACL_AUTO_INHERITED`（继承控制位）；此属性与ACL继承行为有关，不是只看ACE列表相同就可忽略的纯显示差异。参考微软：https://learn.microsoft.com/en-us/windows/win32/secauthz/security-descriptor-control 。**实际下一次权限实验前必须把本任务fixture的未恢复状态作为具名阻断和修复前提**；不能自动改现有fixture/共享目录ACL，不批准仅修改比对逻辑伪造恢复PASS。
- 本轮从report/index能独立确认记录与结论一致，但本地fixture原始SDDL和原件仍`LOCAL_ONLY_RAW`，并未由Astra直接复算。

## 4. SDK静态写面：有界新增事实，不等于工程运行环境闭合

- 报告给出14个原生插件脚本和5个Flutter tooling源的pin及静态映射，实际运行均为0。重要新增：`module_plugin_loader.gradle`在`projectsLoaded/rootProject.beforeEvaluate`路径中，按`project(':flutter').projectDir.parentFile`计算`plugins_build_output`目标，可有条件执行`mkdirs`，属于`CONFIG_PHASE_WRITE`潜在写入；须未来对精确canonical destination及任务私有边界取证。
- Flutter`forceNdkDownload`与CMake DSL目前只定位声明/控制流，AGP/SDK Manager/native写入未知；`generateLockfiles`命令位于`doLast`（TASK_ACTION_ONLY）不证明G2图选择。Flutter SDK bin/cache、NDK/SDK许可、Gradle二进制索引、included tooling缓存和HOME/AppData/Pub/Android等配置fallback仍未闭合。
- 因真实配置未执行，无法声称SDK已只读安全、Dokka未选中、AAR/POM实际产出、网络或旧TCP因果已经解决。

## 5. 预算、保护与终止

- Codex报告首尾101件具名原证、五保护根、527 refs、3183旧Seed只读Hash/FileId、schema2七项与source 14/5匹配，旧partial 7,941,328 bytes SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`，旧APK claim SHA256 `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、旧G claim SHA256 `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`。均为`CODEX_REPORTED_LOCAL_EXECUTION`，非Astra现场复算。
- 原APK/G各1/1耗尽，原A门禁封闭；G2据本地回执`max1/reserved0/Popen0/claim absent`，此轮并未使用、没有解锁。工程Gradle/JVM/Flutter、G2、AAR/APK、设备/RTC/网络/实际观察器/Job、Gate2等均未运行；仅本轮用户态微型OS子进程一次。
- 任务`256MiB` cap未触发。公开索引交付文件写入前task-owned `FILE_STANDARD_INFO allocated=12,095,240 bytes`，Owner转述最终约20.2MB若来自LOCAL_ONLY receipt不能视作Astra现场读取；前后采样没有证明全卷精确瞬时峰值。保护报告没有D盘盘点/清理，本次D盘副线保持延期。
- `RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / INPUT_CLOSURE_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE`；v10.1.5仍`PARTIAL_NOT_ACCEPTED / AC05_OPEN / GRAPH_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / DOKKA_TASK_SELECTED_NOT_PROVEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。AEC、native handle、真实15/30日及物理清理、Push与旧TCP因果等继续开放。

## 6. 后继建议（尚未授权也未下达）

不重复尝试同一个restricted child，也不能在描述符未恢复时直接继续微型负例。若Owner批准新一阶段，限定为**子进程初始化早期可观测性设计/权限最小根因诊断 + task-owned fixture原始描述符完整恢复资格**，要求必要的字节/hash、SDDL control、严格无效状态强停；真实新launch仍需另明示具体次数/进程/安全边界。必要时应使用只读日志/Windows已安装诊断途径先调查`STATUS_DLL_INIT_FAILED`，不以缺失stderr断定失败DLL。任何共享路径权限、管理员身份或系统全局安全更改仍须Owner独立批准。D盘目录处理不在此范围。

**审查分支仅归档本评审文档/独立状态，不合并产品main、未启动工程/G2、新进程实验或清理，也不自动发布后继任务。STOP等待Owner。**
