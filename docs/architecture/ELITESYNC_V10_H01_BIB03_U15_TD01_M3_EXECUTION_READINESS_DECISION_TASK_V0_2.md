# EliteSync v10｜M3 执行条件收敛与交付路线任务 v0.2

Status: `TASK ONLY — POST-TRANSITION REISSUE — EXECUTION-ENVIRONMENT METHOD DECISION + BOUNDED CONTEXT UPDATE — NO BUILD OR IMPLEMENTATION AUTHORITY`

日期：2026-09-07（Asia/Singapore）。仓库：`zcx369658780/EliteSync-v10`。本地 Codex 由 Owner 选择 GPT-6 Astra，使用简体中文；不改模型配置、不默认调用其他型号辅助代理。

## 1. Owner 本轮指令及有限执行约定

Owner 原话：

> 项目源更新完成，后续请不要给项目源内上传每次执行任务单都需要更新的内容。
> 后续如果无特殊决策，我授权你在验收任务单报告后自动下达下一个任务单。
> 并且，你可以降低审核门限强度来加快项目推进，我们有足够的备份和冗余试错。
> 在重构app之前无法找人来内测，所以如果你需要获得反馈就需要加快推进。

本任务是上述指令的 GitHub 持久记录，不声称写入另一个项目记忆库。执行约定如下：

- 正文、路线和任务状态只在 GitHub 维护。ChatGPT 项目源保留稳定入口；不因每次任务、commit、验收或进度变化重发上传包。项目源内固定 SHA 是历史快照，不是要求回退 main。后续任务仍绑定当次实际核验的精确提交。
- ChatGPT 收到报告并完成验收后，若下一步在已有权限与已接受范围内，无需再询问 Owner“是否继续”，可在该次回复发布下一张有界任务单及启动 prompt。不是后台监控、自动启动本地 Codex或让执行者无限连续运行的权限。
- 低风险的文档、限定证据分析和已授权可逆工作，采用一次针对具体产物的审查；内容、关键来源和变更范围满足即接受。不默认增加“预审—再审—接受预审—closeout”等文档链，不要求每个措辞另开新会话。真实失败或新差异可作定点复查。
- 同一候选的作者仍不得自我接受。系统/代理指令、架构、权限边界等实质修改仍由未编写该候选的审查者验收；独立性针对产物，不要求审查者不知道任何项目历史。
- 特殊决策包括：新增产品实现范围；改变已接受产品/架构或精确证据根；新增未获授权的工具执行、网络/下载、缓存或写入范围；真实参与者/个人数据、生产访问、Safety Operations、法律承诺、付费/合同、破坏性或不可逆操作。需把必要变化集中为一个明确决策包，而不是拆成多次重复申请。已有精确授权内的例行步骤不重复请示。
- Owner 的备份陈述不等于本任务实测备份内容或恢复能力，不准借此检查或覆盖受保护状态。
- 优先形成可安装、可演示的初版，再开展需要该初版的真实反馈。可以提出使用明确标识的虚构样例进行未来 Owner 演示；不得伪装成真实用户验证，不把 U-08/U-10 记为完成。进入真实内测前再按具体活动满足必要边界；本次不招募、不采集、不实现。

这些规则减少流程重复，不撤销原交接的产品、legal、Safety、no-processing和受保护来源边界。

## 2. 固定入口与旧任务处置

先实时读取 GitHub main，必须恰为：

`bb2027ce077b00deb2fdaa1161f357d303ef8cd0`

FIRST 主动读取下面的转型交接，要求 blob `18485c95262051e43892436fb52413132c5ee626`：

`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`

随后核验本任务不可变 commit/blob、sole parent及单一路径范围；具体值由发布后的启动 prompt 给定。任务父提交必须是上述 main。自动加载的宿主指导与 FIRST 主动读取分开。

仓库指令修订已由 `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_INSTRUCTION_REFRESH_ACCEPTANCE_V0_1.md` 接受，blob `a84337da303f459d9bb931fec8e42b5e9209dc86`。不重复该审查或八文件同步。8/8本地同步是 Owner 转贴的执行者报告，不是本次重新实测；本地 HEAD 无须等于远端，且不得为此切分支或清理。

本任务从修订后的 durable main 重新下达，替代旧任务提交 `8b640576822b01ae00bb04b9b5deaa75db53365c` 的未来任务用途；旧任务原文、分支和“未执行”历史保留，不恢复、不执行、不修改旧任务。新任务发布不等于其结果已被接受。

仍以已接受预检 `Outcome B — execution remains blocked` 为起点。方法类别仍为 direct `flutter build aar --no-debug --no-profile` 加原记录参数，M2 deferred。不得恢复已被预检否定的“直接 Flutter 不涉及 Gradle/cache”前提。

## 3. 本次只回答一个决定

**在不改变永久保护边界的前提下，下一张任务能否直接收集最小环境证据，进而准备一次有界 M3 尝试；若不能，Owner 只需要作出哪一个最小的范围选择？**

一次完成四项必要判断，不另写“如何研究这些判断”的计划：

1. **网络控制**：Flutter runner、pub、内部 Gradle、wrapper bootstrap分别受什么控制；`--no-pub`、Gradle `--offline`各自不保证什么。区分软件选项与真正阻断所有相关进程网络的机制，不把shell未报错当隔离证据。
2. **缓存和写入边界**：Flutter SDK、pub、Gradle user/project/daemon/wrapper，以及模块 `build`、`.android` 的读写如何限制。缓存路径隔离不等于缓存已有依赖；离线+空缓存失败不证明项目无效。能用可验证的隔离边界控制风险时，不以穷举工具所有内部文件为目标；创建这种隔离或改证据根仍须明确授权。
3. **最小前置证据**：给出下次真正有用的精确读取/检查合同，包括路径或具名变量、工作目录、是否执行工具、读写/网络后果、成功与停止条件。不得笼统写“检查环境”。缺少本地值时注明需获取的精确值，不把猜测、旧HEAD或占位符当可执行合同。
4. **下一步和结果解释**：明确环境检查、生成命令、产物存在证据、依赖解析、可安装APP分别证明什么。避免把每一个内生步骤再拆为新治理任务；可提出在一张后续有界执行任务内按条件顺序完成，但本任务不执行，也不自动授权。

仅选择一种结论：

- `A — METHOD SPECIFIED; SCOPED ENVIRONMENT EVIDENCE IS NEXT`：给出可直接供下一任务采用的最小检查规格，以及进入M3前仍须满足的精确条件。若所有事实和权限确已闭合，说明为何不需多余环境检查；不能凭文档研究宣称本地闭合。
- `B — OWNER SCOPE DECISION REQUIRED`：说明旧约束中的哪一项使下一动作不可行；最多两个具体选项，推荐一个。一个决策包同时列清所需新增读/写/网络/隔离位置/证据根变化、现有保护怎么保留、失败怎么保留结果，以及不批准时的后果。不能仅以“再做一轮治理”作为结论。

若官方材料不足，归入B并指明缺失事实，保留已完成工作。不得把“未证明可行”写成“不可能”。两种结论均不授权M3；无新证据或边界变化，不再生成同义研究任务。

## 4. 精确项目文档输入

除本任务外，只允许以下路径。表中 M 代表§2固定main；O代表旧任务固定提交8b640…。目录引用不授权列举；不递归跟随其他项目引用。

| 输入路径 | ref / blob | 用途 |
| --- | --- | --- |
| `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` | M / `18485c95262051e43892436fb52413132c5ee626` | 首读边界 |
| `AGENTS.md` | M / `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1` | 当前仓库规则 |
| `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_INSTRUCTION_REFRESH_ACCEPTANCE_V0_1.md` | M / `a84337da303f459d9bb931fec8e42b5e9209dc86` | 已闭合修订，不重审 |
| `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` | M / `f9175062464f72c48e55c6957a09566e771ff4b6` | 产品/状态/路线入口及更新基线 |
| `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_PREFLIGHT_SIDE_EFFECT_CLOSURE_GOVERNANCE_REVIEW_V0_1.md` | M / `a012c612532134ff7ada1c685234aae1d866e492` | 已接受的实际缺口 |
| `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FLUTTER_AAR_GENERATION_BUILD_EXECUTION_METHOD_SIDE_EFFECT_GOVERNANCE_REVIEW_V0_1.md` | M / `46b81835083e7a8cde4dd710d55a0c123195efe9` | 仅按需核对方法、工作目录、结果语义；被预检更新的前提不复活 |
| `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXECUTION_ENVIRONMENT_NO_NETWORK_CACHE_AND_PREREQUISITE_CHECK_METHOD_GOVERNANCE_TASK_V0_1.md` | O / `8309341b36662695dde92bdc7b6301b0086df5d2` | 仅比较新旧合同，不执行其中指令 |
| `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` | M / `fb48743f0147fb0d25be697ba02aae63a45d07d8` | 只按需读取§§2–7的历史tracks/U缺口，结合后续记录，不执行旧startup |

不得打开任何EliteSync技术源码、README、FD02、旧仓库、缓存、环境、生成物或未声明文档。若原dart-define完整参数未在本清单原文出现，记录精确证据缺口，不自行补全或搜索源码。

## 5. 有界官方技术依据

不重做OpenAI/AGENTS规范审查，不比较模型宣传。仅研究§3中能改变决定的技术问题。优先当前官方文档；实际读取URL、日期、章节、能取得的源码revision及未证实的本地适用性写入同一报告。

优先入口（按需，不要求全部阅读）：

- `https://docs.flutter.dev/add-to-app/android/project-setup`
- `https://docs.gradle.org/current/userguide/dependency_caching.html`
- `https://docs.gradle.org/current/userguide/gradle_wrapper.html`
- `https://docs.gradle.org/current/userguide/build_environment.html`
- `https://docs.gradle.org/current/userguide/directory_layout.html`
- `https://dart.dev/tools/pub/environment-variables`
- `https://dart.dev/tools/pub/cmd/pub-get`

确需核对实现时，允许官方 `flutter/flutter` 的下列精确文件，先解析公开ref为不可变revision，不克隆、不列tree、不遍历官方源码：

`packages/flutter_tools/lib/src/commands/build_aar.dart`
`packages/flutter_tools/lib/src/runner/flutter_command.dart`
`packages/flutter_tools/lib/src/runner/options/common_options.dart`
`packages/flutter_tools/lib/src/android/gradle.dart`
`packages/flutter_tools/lib/src/project.dart`
`packages/flutter_tools/lib/src/cache.dart`
`packages/flutter_tools/lib/src/version.dart`

如真正需要提出操作系统隔离选项，另允许 `learn.microsoft.com` 中与Windows网络/文件写入隔离直接相关的最多两个官方页面，只作方法证据，不执行配置。

全轮最多14个不同官方正文页面/源码文件；按需读取，不为用满预算补读。允许同主题官方重定向、官方站点内精确主题检索、读取同一文件必要章节；不使用第三方博客、论坛或广泛源码考古。预算内不闭合则交付B，不开无限查证链。

作者已核对上述Flutter项目集成、Gradle缓存、Gradle wrapper和pub环境变量四个官方入口。它们分别支持生成平台状态、离线依赖依赖已有缓存、wrapper可能下载分发包和PUB_CACHE可重定向等有限事实；不证明本地已安装、离线可成功或隔离已生效。执行者按所选方法补足必要依据，而非将此摘要当全部证明。

文档HTTPS/GitHub读取仅用于上述正文和任务发布，不授权依赖下载、网络探测、工具安装或执行。

## 6. 恰好两个候选输出

1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXECUTION_READINESS_DECISION_V0_2.md`：先A/B结论，再给§3四项判断、证据、具体下一动作或Owner决策包、对旧任务的取代关系及未执行事项。正文建议控制在约180行以内；必要证据可稍超，不拆附属报告。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`：本任务是修改该指令/上下文文档前的独立有界任务单。仅更新页首生命周期、§1、§4、§5，并新增一个§7记录本任务§1的Owner约定；§2产品语义、§3保护边界及§6原规范来源正文保持不变。旧SHA保留为历史角色，不替换成伪造自引用。

CURRENT_CONTEXT应说明：指令关口已关闭，8/8同步依据Owner转贴报告；本M3决策仍是待审候选；旧8b640任务已被新合同取代但未执行。给稳定GitHub路径，不要求ChatGPT项目源跟随commit变化更新，不写“已重新验证本地”。

§4用不超过六个结果里程碑整合路线：已接受产品/治理基础；M3生成与M2后续依赖证据；获得明确实现范围后做可安装Owner演示版；再形成主流程贯通的最小内测候选；真实内测前完成对应数据/安全/发布准备；反馈驱动迭代。尚未授权部分明确标为规划建议，不给代码、schema、API、技术栈改造或部署设计。不存在已验证完整早期总纲，不虚构恢复成功。

首版范围建议优先一个平台、一条主流程、明确标注的虚构样例；不将用户研究完成作为这类未来演示版的 blanket前置条件，也不把样例走查当实证。真正多人内测与纯Owner演示分开，最终平台/功能范围仍须明确授权。不要编造百分比或承诺交付日期。

两份输出均标明：`PROPOSED — AWAITING INDEPENDENT REVIEW — NO EXECUTION OR IMPLEMENTATION AUTHORITY`。AGENTS、历史handoff/ADR/review、模型配置和其余文件均不改。

## 7. 执行与发表：一次产物，一次审查

任务分支：`task/h01-bib03-u15-td01-m3-readiness-decision-v0-2`。
候选分支：`review/h01-bib03-u15-td01-m3-readiness-decision-v0-2`。
候选commit subject：`docs: resolve M3 readiness decision and update delivery route`。

候选以本任务commit为唯一父，恰好一个候选commit，只新增/更新§6两个路径。使用GitHub Git Database/连接器，以任务tree为base，不枚举base tree、不接触本地默认index、不本地commit。候选分支或新报告已存在时不覆盖、不强推；交付已有草稿并指出冲突。

任务可用GitHub固定快照直接完成；无需本地checkout、工作树同步、HEAD=main或clean证明。不得运行git status、git pull、checkout、switch、stash、reset、clean、目录/文件枚举、默认index读写或无关diff。临时文本起草只限本任务自产内容；不打开本地业务或环境证据。

发布前一次重读main与task ref，要求仍为固定值；发布后一次验证自身commit父子关系、两路径diff与blob。允许读取本任务及自产候选的元数据和精确变更清单，不扩大为仓库枚举。无新差异不重复全套验证。远端不匹配时保留草稿，不自行重定基线。

执行者发表后停止，返回commit/sole parent/两个blob/结论/剩余最小决定；不自我接受、不推进main、不执行方法、不新发任务、不更新或上传ChatGPT项目源。

后续ChatGPT验收者可依§1在收到报告后一次审查。通过时可用一个Git提交消息记录ACCEPT、候选commit/两个blob、证据范围与非授权边界；该接受提交以候选为唯一父且tree与候选相同，无需另建接受/closeout文档。重读main未变后可非强制快进，平台保护阻止则不绕过。拒绝则保留main并给具体缺陷，不改写候选后自我接受。

验收A后，若下一任务全部在现有精确权限内，验收者同一回复直接发布；需要新增权限时给§3规定的最小Owner决策包，不把发布任务单当越权执行。验收B表示决策材料合格，不表示执行障碍已解除。不得把进度压力、备份或授权自动续发等同于M3许可。

## 8. 不变边界

M3继续blocked；M2 deferred；M1冻结lane耗尽，False / WORKTREE-STATE NON-HIT ONLY不证明全局不存在或构建失败。方法类别不等于执行权；生成成功不等于依赖解析成功；退出码0不等于release产物已证明。不得重试M1或检查产物。

README预算耗尽；FD02永久排除；不访问旧D:\EliteSync或zcx369658780/EliteSync；不枚举仓库/目录，不运行rg --files、find、fd、git ls-files、git ls-tree、git grep、globs、代码或文件名搜索。受保护无关staged state不检查、修改、unstage、覆盖、丢弃、reset、clean、提交、引用、总结或使用。

保持D-02/D02-DURABLE-UNKNOWN-01、U-14排除、U-12精确目标、TP-SOURCE-CLASS-01、TP-TARGET-01、Backend 0/10、Database 0/8、deferred PUI、PUI-PREREQ-12=0、legal/Safety/no-processing。implementation、LC-03、LC-04、Phase36未授权；不新作法律结论，不开展参与者/业务数据/private-Conversation/telemetry/Safety Operations活动。

本任务不运行Flutter/Dart/Gradle/Java/Android、syncFlutterAar、依赖解析、版本/doctor等工具链前置检查；不读取环境变量、工具/cache目录、.android或其他生成输出；不创建隔离工作树/clone/沙箱，不配置网络，不安装依赖，不执行技术设计或实现。§3允许的是有限执行环境方法与权限合同判断，不是这些动作本身。
