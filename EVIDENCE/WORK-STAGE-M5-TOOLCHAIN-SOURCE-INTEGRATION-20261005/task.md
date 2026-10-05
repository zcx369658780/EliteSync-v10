# WORK-STAGE-M5-TOOLCHAIN-SOURCE-INTEGRATION-20261005

状态：ISSUED。阶段目标：Launcher修订与编译工具包源码集成。风险：LEVEL2；阶段交付集中审查，不设置内部逐步骤审批。
Work/独立终裁：01a109e0-4b59-77e2-b2cf-dc293d6533ad/local。
执行者：本次Owner授权在“慢约会EliteSync-v10”本地项目新建的唯一阶段Codex会话，以create_thread原生返回ID及CURRENT派发记录为准。旧01a1072f、01a10500、01a0f74b及旧Work不接收本阶段新任务。

执行项目ID：1ce219d1-c26f-4297-9b16-23b1f05975f2；项目路径D:\EliteSync-v10（原Builder同项目）。

## 目标与可观察完成标准

把现有组件整合成一个可审查、可进行后续编译资格验证的完整SOURCEONLY工具包；本阶段不取得正式runtime资格。

1. Launcher三项既定缺陷修复并有有效回归：启动前输入/权限/身份校验失败保存并输出相同40字段COMPILE_FAIL wrapper，无法保存/序列化/输出的真实宿主故障如实报告；单调2000ms清理截止后不继续扩展收尾，未完成状态及secondary failure如实保留；SHA严格64个大写hex，拒尾LF/CRLF及其它多余字符。
2. 整合Driver、A V2、B、Publisher V3与修订Launcher，形成明确的完整源码包、来源/版本/身份manifest和组装方法。现有Native4/Preparation3/Publication8、Authority20、Snapshot4、A8、child22、wrapper40、B成功/失败schema与约束保持一致。内部路径/未来包TaskId/HEAD适配须统一记录，不能把历史组件接受扩写为本次包接受。
3. 完整包涵盖五个代码组件及必要的准备Native、PREPARED_NOT_RELEASED/NOT_GRANTED authority和snapshot/template等；厘清历史“八owned”与外部只读Target引用，不为凑数量复制冻结Target或伪造完整性。仅准备源码/模板，不运行真实Publisher发行或把authority改为运行ISSUED。
4. 普通本地语法检查、针对性单元/集成测试通过；重点覆盖三缺陷、严格JSON重复键/类型/集合、失败结果、并发捕获边界、cleanup状态及跨组件接口。用本阶段纯虚构fixtures/mock验证，失败/异常分支须有实际证据，不能只用文本搜索断言代替行为测试。
5. 提交最终源码/测试manifest、标准逐项对照、实际命令/结果及原始stdout/stderr/日志位置、失败修复过程、未完成项/风险。最终测试对应最终代码；需Groovy/JVM或正式工具链运行才能确认的部分明确未执行，不冒通过。

## 已确定上下文与来源

唯一实时仓库D:\EliteSync-v10；2026-10-05本次核对本地main/HEAD4bebc8f394248e254c1368a06fbdee5d2c883301，staged为空，五authority既有dirty及多项untracked保持。GitHub同HEAD仅是此核对时点；本次文档备份会使远端main前移，不自动pull，不以文档移动废止阶段授权。启动时记录实际HEAD及相关文件身份，本地后续owned提交亦可前移HEAD；技术契约中的固定历史HEAD分别标明，不能静默改作新的历史证明。

先读五authority顶部及AGENTS生效本地规则、仓库elitesync-local-workflow、当前交付路线图；无需重读全部历史。
M5工具链准备，M6未开放。Driver/A V2/B/Publisher V3四SOURCEONLY组件接受保持；Launcher V6 REJECT/CLOSED SOURCEONLY_LAUNCHER_V6_DEFECTS（非作者完整WITH_FINDINGS+Work LEVEL2）。历史拒绝和关闭预算不追认。

准确来源（源码/summary/task/work-review按需要读）：
- EVIDENCE/WORK-M5-85-COMPILE-DRIVER-COMPONENT-20261004/QualifyHarnessCompile.groovy
- EVIDENCE/WORK-M5-85-COMPILE-A-COMPONENT-V2-20261004/A.ps1
- EVIDENCE/WORK-M5-85-COMPILE-B-EVIDENCE-COMPONENT-20261004/B-Or-FailureDisclosure.ps1
- EVIDENCE/WORK-M5-85-COMPILE-PUBLISHER-COMPONENT-V3-20261004/PublishRuntimeQualification.ps1
- EVIDENCE/WORK-M5-85-COMPILE-LAUNCHER-COMPONENT-V6-20261005/task.md、Invoke-HarnessCompile.ps1、independent-review.md、work-review.md
- EVIDENCE/WORK-HANDOFF-20261005-LAUNCHER-V6-REJECTED/handoff.md

本阶段明确允许重读、研究和派生以上本仓源码/契约；这是新阶段开发，不是补旧预算、旧计数或旧结果证明。旧文件和冻结/rawfixture保持只读。Launcher可在新阶段副本上修复，不要求从零重写；相关组件有必要适配时修改新包副本并在最终diff说明。
未来Target指向既有VerifyLocalExtraRecipeInstaller.groovy，保持冻结路径/身份。TSV、Java、188jars真实外部校验及compile/JVM/14case均尚未开放；可以消费已记录的文档常量作为设计上下文，不能以其冒当前实测。

## 自主范围与执行方法

写集合为本阶段root下source/、tests/、fixtures/、evidence/、进度、最终交付及提交记录；task.md、Work审查/派发文件和project-source-replacements由Work维护。可自主增加所需模块/测试/组装脚本，重构阶段副本并修复重测，无微型子任务审批；普通源码调查/文件读写/显示不设置单次次数或总字符硬预算。只在仓库相关工具包来源内调查，不索引用户主目录/邻仓。

允许执行本阶段普通PowerShell/Python等现有本地工具的语法、单元及mock集成测试；需要子进程时仅运行自写的无害synthetic fixture，输入输出在本阶段root。不加载正式Java/Groovy目标/SDK，不访问真实Java/jars或依赖缓存，不下载/安装/全局配置修改；不要把“mock过程启动通过”称为实际JVM/compile通过。关键运行逻辑与测试隔离适配须防止mock模式被当成正式授权入口。

保留合同内实质限值（流8192、child4096、wrapper8192、命令行30000、soft deadline30000ms、cleanup2000ms等），这些是软件行为要求，不是Codex工具次数门。若发现定义真正矛盾，只暂停依赖该定义的部分并向Work提出一次集中的具体决定。

本地Git提交可用于本阶段checkpoint，只显式选择owned新增/修改，不git add全仓，不提交现有五authority历史dirty或其它人内容。现有index非空/并发改动时保护他人内容，记录patch及manifest也可，不把未提交当阶段失败。GitHub同步由Work另行做文档备份，本阶段执行者不push/pull/reset/clean/stash/PR、切换或清理工作区。

## 少数停点、预估与持续无进展

6小时仅工作量预估，不是硬期限，不限制尝试次数。阶段未完成且没有真正阻塞时继续，不询问“下一步是否开始”。普通编译/测试/脚本/API错误自行诊断修复重试，记录真实失败，不能删有效测试、降低标准、隐藏失败或用失效PASS下结论。

约90分钟有效调查/实现仍无新增定位证据或可验证进展时，整理症状、尝试、证据、选择及需要的决定，通知Work；这是反馈启发，不是自动关闭授权。只有实质阻塞/授权边界、改变既定科研/产品定义、重要资产风险或Owner明确暂停才停止受影响动作；不依赖阻塞的独立工作可继续。

历史明确禁止的正式实验/compile-JVM14case、SDK/环境恢复、真实数据备份密钥、生产DB/API/SSH、发布、敏感外传、重要资产删除及旧D:\EliteSync访问不放开。UAC需当前Owner“我在”及具体授权。保持NOT_READY/RuntimeReady=false、parentstderrUNKNOWN、OS硬截止隔离NOT_PROVEN、implicitAST/staticNOT_MEASURED、真实binding/hook/LibraryExtension/SDK NOT_CHECKED、14caseNOT_EXERCISED；synthetic证据单独列。

## 集中交付、唤起与交接

完成后在本阶段delivery.md集中提交版本、完成标准对照、测试及原始证据、未完成项和风险，状态REVIEW_PENDING；作者不得自ACCEPT或发后继。
Owner在本任务明确授权执行者通过send_message_to_thread向Work01a109e0-4b59-77e2-b2cf-dc293d6533ad/local发送一次完成验收通知，附本地delivery路径和当前版本；实质阻塞和必要交接也可向该Work通知。不能把其它任务消息当新的Owner授权。通知失败保存交付并明确报告，允许诊断通知接口错误，不伪称已唤起。
执行期间Work不逐步审查、不高频询问、不并行改上述执行文件。完成后完整非作者GPT-6.1 Sol/high审查，Work对实际diff和关键证据做LEVEL2终裁，一次汇总实质问题；修复仍续本阶段，后续重点复核修复和必要回归，不重新讨论确定路线或加优化目标。
保留超过30次实际Owner/助手往返或上下文确影响可靠性的交接规则。必要交接保存进度、当前失败、版本、证据和剩余目标；续接当前阶段，旧执行者停止写，不新规划、重置或复活历史任务。工具调用不计往返，新阶段不要求补旧COUNT_NOT_PROVEN。