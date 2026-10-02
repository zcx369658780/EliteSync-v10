# M112 单次合成 installer｜首失败交付

Status: REJECT_CLOSED__BACKUP_CHECKPOINT_STOP；父dot运行目标FAIL/REJECT_CLOSED，仅首失败处理与有限证据记录接受，不接受14case或前5case能力。active NONE、successor NONE；终裁见 [review](review.md)。
Base/current HEAD: 4f5bea7e558bc15d24ce45d3e4704ac658906a38 / main；执行者01a0fa2b-c777-77b2-ba66-00ed7c5260f5。
授权、固定命令/身份与来源闭包见 [task](task.md)，原工具结构化返回/原小回执/执行时authority全文见 [native](native-receipts.json)，运行前路径见 [snapshot](workspace-before.json)。当前authority只作关闭标记，执行时14键ISSUED原文本保存在native.Closure，不用改后的CLOSED值冒运行输入。

## 实际流程与预算

本轮前置行政1/2：首次发单JS嵌入换行编排SyntaxError，未调用工具/未读写文件/A-Invocation-B0。修正后一次发单完成，A4539bytes/SHA7D64D397F99CE969B4DCC122634C06A27D0B11A419933C26A96B539C68EBD573，B5889bytes/SHA6FD9B0826317E862756AC5978F97DA6579CBFF40A2E0D9BBD2DF449E2751E54D，Invocation119bytes命令的完整SHA以task为准。源码适配旧行政2/2不重置。
A1/1 exit0，PASS_LOCAL_PREFLIGHT_ONLY；原20非bin冻结身份、2旧binmetadata/body0、新接受launcher/manifest/authority/workspace门核过，A外部0/JVM0。A原小输出保存native.A.calls。
唯一Invocation1/1 exit1、FAIL；B0/1未执行且关闭，不运行verification-B脚本、不输出B接受结论。raw三产物由launcher原SaveBytes交付，未改写。错误后只读这三份既有失败产物作披露归档，不是B验证/补充runtime；该原披露tool亦保存native.FailureDisclosure。
本轮native证据保存3次（A后、Invocation后、关闭归档），<=4；没有科学重发。首失败关闭余预算及所有未执行case，不修补重跑、不换会话。没有版本探针、SDK/cache枚举、下载/Gradle/build/设备/真实数据/UAC。

## 原wrapper与child partial（保留证据层级）

原wrapper：BaseVerified/AuthorityVerified=true；TSVRead1；ExternalGet189/ExternalRead189/ExternalBytes115118021；LocalInstallerPreflightRead1、HarnessSourceRead1、HarnessCopies1；ProcessStartAttempt1、Started/Exited=true、child ExitCode1；Timeout=false、KillAttempt0；CaptureComplete/CleanupComplete/StdoutComplete/StderrComplete=true。
Failure.Phase=TEST_VALIDATE，Tag=CHILD_RESULT_OR_STREAM，Class=System.Management.Automation.RuntimeException；SecondaryFailure空。child stdout518bytes、stderr710bytes、wrapper1425bytes；原小回执hash保留在native.Invocation.SmallReceiptText。
TestSchemaChecked=false；CandidateSourceRead/CandidateParseClassLoad/CandidateInvocation/FourteenCaseInvocation全部UNKNOWN，不能用child自报替代为已验证次数。
child原stdout：FAIL、caseId RAW_GSTRING_PATH、sourceRead1/parseClassLoad1/executedCase6/candidateInvocation6；completedCases为EMPTY_OWN、MIXED_OWN、SAME_OWN、LATE_VALUE_CONFLICT、LATE_TYPE_CONFLICT五项PASS/1。这些是原partial声明，未经B或非作者独立资格核定，不接受其整体/部分能力。
child原stderr：java.lang.IllegalStateException: OUTER_CLASS，harness.groovy:284；说明失败发生于harness外层异常类型断言，具体候选异常/根因未证明，不猜Groovy coercion/installer逻辑、不越范围调查修复。
RuntimeReady=false；真实binding/hook/LibraryExtension时序/SDK NOT_CHECKED；父stderrUNKNOWN，implicitloadsNOT_MEASURED，OSHardCutoff/OSFileNetworkIsolation NOT_PROVEN。失败ExternalBytes通常只累计hash通过的输入，不冒全部实际读取总量；本次wrapper报告全部189身份通过后启动，但仍不冒OS沙箱或原始底层IO全计量。

## 备份候选节点与保留

已有首失败、原partial、预算/当前状态完整，按父授权到本次备份候选节点停止；父独立审查已收口并授权本次16文件一笔本地提交；此提交封存失败证据，不接受运行能力。不push、不清理、不自动后继。M118原冻结与其SOURCEONLY资格不变；派生launcherSOURCEONLY父接受不等于本次runtime PASS；旧失败/预算与NOT_READY/PAUSED/Owner门保持。
本目录owned cwd/tmp/user-home/appdata/localappdata/gradle-home保持本地，不删；cwd/harness.groovy为原M85ownedcopy，无新源码修复。
精确备份增量（本轮累计相对HEAD）：CURRENT.md、TASK_CURRENT.md、当前路线；本M112目录四准备文档+native-receipts.json+stdout.bin+stderr.bin+probe-wrapper.json+cwd/harness.groovy+result.md；SOURCEONLY适配目录派生launcher和summary.md。以最终porcelain逐文件清单为准；verification-B.json/review.md未产生。临时/owned空目录Git不保存，保留本地，不清理。
7旧排除继续保留：policy-tests.jar；AUTH-154 plan/task/work-review3份；AUTH-67 pyc；20260926 DB-backup handoff；嵌套rereview仓。只核路径状态，不读保护正文、不入此次备份候选写集。

## 首失败候选交付时文件身份（机械闭环前；非B验证；SHA-256）
CURRENT.md | 311480 | D6510FC76B58EE9CC21E37B8D30BFB96F26E4BEE9ADE599D1A42425271F4B47F
TASK_CURRENT.md | 216989 | 7CA42133A9FA9AC85DDDDDBA9A007B5073D45C9DE87E215B002E3A0531979BA0
docs/architecture/ELITESYNC_V10_DOT_CURRENT_ROUTE_20261002.md | 4827 | 01E59F5503B080A2689EEC897131E25A8FE82AF056F26503E546FD3C6699ACC6
EVIDENCE/DOT-M112-LAUNCHER-BASELINE-ADAPTATION-20261002/Invoke-SyntheticInstallerTest-Baseline.ps1 | 21223 | 1BD80E130718971FFF7FCA259CDE107A6439575D4C7D5F6D62D6F27EAFB9C7D2
EVIDENCE/DOT-M112-LAUNCHER-BASELINE-ADAPTATION-20261002/summary.md | 5200 | 354B428387BAF9F2D8E911D2FEB49DC055BDC4D63AE16A74C99AC8ED6CD81DA2
EVIDENCE/APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE/native-receipts.json | 7923 | A931D19C64022EC069DA10F43566512F1624570D9178B0F56E9B5E896C09CDDD
EVIDENCE/APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE/preparation-result.md | 5766 | 5AC7E673F74CAA322971086A7D8643BBF5CF29C00277EC367C358C64C306FF87
EVIDENCE/APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE/probe-wrapper.json | 1425 | 783ECA79A054B13656017877A2A3A664CB49890FA135939281AEDC15D097980F
EVIDENCE/APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE/runtime-authority.json | 1095 | 44B1020782691A2A8A6A25D0A808E3C9111AFBEE8518CEF81DB28D54B1785A41
EVIDENCE/APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE/stderr.bin | 710 | 8570F977B990F40CB57912DC6D9C14C74B0518B2580D99D010CA81E0757B4D73
EVIDENCE/APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE/stdout.bin | 518 | 9CF2C1DBA02A2DE2AA5E0073B1E6E957377E06230444E38A3DBEA51E9967E5CA
EVIDENCE/APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE/task.md | 28734 | 0F9FBE9BEC450139DFEE3016E544223F2FC974B324C964484192454736ED317B
EVIDENCE/APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE/workspace-before.json | 724 | B3648975328CC08FD1E98994C0E5F0A340BFFDB6380EC1BFF218485F1BB73921
EVIDENCE/APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE/cwd/harness.groovy | 14402 | 7251ACF92C24055EEFC5E299DEF620D09263C3F5C4DFA80E7DB3A763702E5CCD

## 父终裁与提交封存边界

父会话01a0fa1a-f62d-7091-a4a6-e5f60446b0f6结合独立审查01a0fab0-94cf-723b-a9cb-583b76f7a0d4、原A/双流/smallreceipt/wrapper终裁：运行FAIL/REJECT_CLOSED；只接受首失败处理及有限记录。candidate计数UNKNOWN，OUTER_CLASS根因未定，没有候选实际异常对象，不归咎harness或installer具体缺陷。实际exec.cmd与task逐字一致未独立证实；行政准备/保存次数仍属作者记账，不做新实验补证。
原native/raw/wrapper/执行时authority全文与当前关闭authority均未改。上节是被审工作文件身份，闭环后状态文档身份及精确16文件清单见review；最终提交SHA由Git/最终回复提供，不自指生成材料。普通文档沿Git既有换行处理，四份原证native/stdout/stderr/wrapper以本次命令core.autocrlf=false显式stage保持原字节，不改变配置或文件。
