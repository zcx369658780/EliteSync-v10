# M112 RAW_GSTRING_PATH 静态诊断（候选，未终裁）

日期：2026-10-02。本地基线：main / 71fa57f8c734bf4ea2597b4bf453515ef3c37461。
范围：本轮授权的有界源码诊断及单份记录；不是 M112 重试或新运行任务发布。GitHub push 两次审批拒绝保留为单独待办，本轮未再推送。

## 原证与可定位结论

- 原执行 harness：EVIDENCE/APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE/cwd/harness.groovy。
- 原 installer：EVIDENCE/APP-M5-84-RAW-OBJECT-INSTALLER-BOUNDARY-SOURCE/LocalExtraRecipeInstaller.groovy。
- 原回执：同 M112 根的 stdout.bin、stderr.bin、probe-wrapper.json、native-receipts.json、runtime-authority.json。native 的 Budgets 为 A1 / Invocation1 / B0 / Closed=true，关闭原因 INVOCATION_EXIT1_FAIL；现 authority CLOSED_AFTER_FAILURE。
- harness 第179–186行：case index 5（第6例）构造插值路径，Object bound 赋值 GString，随后 SPEC_RAW_GSTRING 断言。第262行以 install.invoke(null, [target, bound, recipes] as Object[]) 调用；第263–264行仅捕获 InvocationTargetException 并取 targetException。
- 第284行 OUTER_CLASS 断言要求 failure 非 null 且精确类为 IllegalStateException。stderr 指向该断言。它只证明此联合条件未通过：failure 可能为 null，也可能为别的类；现有输出不区分，不能据此指定异常类或断言没有异常。
- installer 第20–31行以 Object 接收参数；第26行要求 rawBoundProjectPath.getClass() 等于 java.lang.String，拒绝分支抛 ES_INPUT，且处在 try 内。第128–135行 catch(Throwable) 包装 IllegalStateException，保留原 cause。若真实 GString 原样进入这些检查，按源码预期应产生 INPUT / completedSets=0 / attemptedSets=0 的包装异常，cause 为 IllegalArgumentException / ES_INPUT。此为条件性源码推导，不是已测能力。
- 原 stdout 在 RAW_GSTRING_PATH 记录失败，并自报6次调用、此前5例 PASS。wrapper TestSchemaChecked=false、候选读取/解析/调用计数 UNKNOWN、runtimeReady=false；不能将 child 自报转为独立接受事实。OUTER_MESSAGE / CAUSE_CLASS / CAUSE_TAG / 读写状态的后续断言均没有通过证据。

最小可定位原因目前是“输入类型与候选结果之间存在观测缺口，且 OUTER_CLASS 把两类结果合并成一个标签”，不是已证明的 installer 缺陷。SPEC_RAW_GSTRING 未先失败支持构造时 GString 断言通过的控制流解释，但没有证明参数数组构造、Groovy 动态反射调用及方法入口仍保留此类型。

## 有界假说与修复分岔

1. GString 在数组构造/动态反射分派边界被转换为 String，installer 正常返回，failure 留为 null。此假说可解释标签，但尚无数组类型或返回记录证据。
2. 捕获到了另一类 targetException。原证不含该对象；不能猜测它的类、消息、包装层次或来源。
3. 原始 raw type 检查在实际 Groovy 分派中表现不同于源码条件推导。需先排除调用边界转换，才能判断 installer 需要修复。

不要删除或放宽 GString 拒绝规则，不把 OUTER_CLASS 改成宽松 PASS，也不接受前5例能力。如果新观测证实正常返回且存在输入转换，应优先修复 harness 的调用边界；若真实 GString 到达安装器仍未被拒绝，再准备独立 installer 修复候选。任何转换原因均须另立有限验证，不用猜测直接改产品保护语义。

## 下一项精确方案（PROPOSED / NOT_ISSUED）

建议新单例诊断，只执行 RAW_GSTRING_PATH 一次，不执行前5例、后8例或原14case表。先准备 SOURCEONLY 诊断 harness 与适配 launcher 并经非作者审查；本记录不物化这些源码、不发布 runtime authority。

源码差异建议：
- 从现有 harness 保留 imports、synthetic fixture、独立 expected/keys、installer size/hash 校验、parseClass 与精确 Object/Object/Object 方法定位；删除14例循环及 PASS 表，只构造 index5 的相同输入。
- 将参数数组显式保存为 Object[] invokeArgs，记录 bound 与 invokeArgs[1] 的 class.name、是否 instanceof GString、是否精确 String；保留相同动态 Method.invoke 机制，不预先 toString、不先替换为另一调用路径。显式局部数组是本次观测性改动，不声称与原 inline 语法已运行等价。
- 调用前计数 attempt=1；InvocationTargetException 解包到 candidateFailure，额外 catch(Throwable) 只记录 reflectionFailure，二者不能合并。最多一次候选调用，绝不为取得对照再调用。
- OUTER_CLASS 断言前输出一次诊断 JSON：input types、returnedPresent/returnedClass、candidateFailurePresent/class、causePresent/class、reflectionFailurePresent/class、代理 reads/sets 序列、own 是否仍为空、caller map 是否未变。消息仅记录是否等于期望包装字符串及 ES_INPUT，其他消息仅长度/摘要，不输出参数值或任意异常正文。
- 正常返回或捕获预期/非预期候选异常均输出 DIAGNOSTIC_ONLY，绝不 PASS 或 runtimeReady=true。无观测完整性即 FAIL。source/parse/构造/反射基础设施失败首失败停点；不继续其他case。

输入和预算须在独立放行中固定：
- 已知本仓 M84 installer，SHA256 7D45926082F323750A696439C4CE6E1791C89C9B867A26615DB1CB830888DB37 / 6141bytes；不修改它或22冻结项；两旧bin正文0。
- 新诊断 source/launcher 的精确路径、bytes/hash及允许差异先审定。复用已知188分发jar的准确 TSV 清单与 Java locator，不枚举邻库/SDK/cache；如运行获准，189文件各新 GetItem1/ReadAllBytes1，预期合计115118021bytes须 fresh 核对，沿用旧身份事实不能代新核验。
- 仅一个新 JVM ProcessStartAttempt<=1；installer sourceRead<=1 / parseClassLoad<=1 / candidate invocation attempt<=1；fixture 全 synthetic，仅内存 own-map。Groovy隐式类加载并非这些读取计数所覆盖，不假称所有JVM文件访问只有189次。
- 新目录建议 EVIDENCE/DOT-RAW-GSTRING-SINGLE-CASE-DIAGNOSTIC-ONCE；仅诊断脚本、launcher、authority/snapshot和 stdout/stderr/wrapper/native 小回执；不写 M112 旧目录或现有冻结源码。
- launcher 使用现有 capture/cleanup/首失败原则，30秒超时，stdout/stderr各8192bytes上限（诊断JSON目标<=4096 UTF8bytes），溢出或不完整即停止；至多1次终止尝试，OS硬截止/文件网络隔离仍 NOT_PROVEN。预期 stderr0，意外stderr不放宽为测试通过。
- 新 A 预检<=1，Invocation<=1，成功完整捕获后的本仓 B 校验<=1；失败后只允许预先定义的一次原回执读取披露，不补跑或修源码再运行。新外部/进程预算必须独立批准；旧 M112、所有旧拒绝及消耗不变。行政修正预算如需要，须事先单列种类/次数，不能扩读取或进程预算。
- 不调用 Gradle、构建、设备、真实数据、安装/下载、安全配置、旧仓或旧项目；不启动自动化。runtimeReady=false / NOT_READY / PAUSED保持。
- 本次若得到 returnedPresent=true，结合 type snapshots 定位转换边界；若 candidateFailurePresent=true，依据实际 class/cause 比较检查；若这些仍不足，再提出入口类型探针的 SOURCEONLY 差异供审，不在同一预算追加调用。

## 本轮操作与限制

本轮只读取相关本仓材料，使用已运行 PowerShell 与只读 Git；JVM/Gradle/设备/外部189读取0，无产品代码改动、commit或push。唯一新增文件为本记录。
CURRENT/TASK 顶部的 M112 关闭状态与 native 关闭预算一致；历史段落的“未建未派未跑”不作当前事实。一次批量入口展示被工具截断，未据未展示内容宣称全文恢复；关键代码和原回执单独读取，关键行号另取。
本记录是作者静态诊断候选，保留独立审查与 dot 终裁、Owner 保护门；下一诊断未运行。当前上下文能支持此有界诊断，后续接续不得重置任何预算。
