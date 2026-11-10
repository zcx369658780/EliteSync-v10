# WORK-STAGE-M5-TOOLCHAIN-E2E-SYNTHETIC-20261005

状态：ISSUED。阶段目标：完整工具包入口链集成验证及可重复验证交付。LEVEL2，集中验收。
Owner于2026-10-05确认工作流改进并明确要求继续派发下一长任务；本任务落实该授权，不开放历史冻结的正式运行。
Work/独立终裁：01a109e0-4b59-77e2-b2cf-dc293d6533ad/local。
执行者：原本地“慢约会EliteSync-v10”项目新Codex会话，以同root dispatch.json和CURRENT原生派发回执ID为准。旧执行会话不再接收本阶段新任务。
项目1ce219d1-c26f-4297-9b16-23b1f05975f2；唯一实时仓库D:\EliteSync-v10。

## 目标与可观察完成标准

上一阶段接受了完整准备源码及函数/局部接口证据，但完整Launcher入口在mock External边界停止，正式成功入口未贯通。本阶段把这些相邻步骤整合为一个可复用的隔离集成验证包，实际覆盖发布接口→A→Launcher启动意图/无害子进程/双流捕获/清理/结果序列化→B消费，诊断并修复链上发现的源码与测试问题；结果仍是SOURCEONLY + SYNTHETIC，不赋正式runtime资格。

1. 提供一个有文档的本地统一验证入口，在本阶段隔离sandbox生成虚构准备输入，运行五组件中的可执行PowerShell接口链。Publisher仅使用已说明的synthetic Git/文件替代；Driver的JVM边界由自写无害fixture子进程代替。验证成功链确实越过旧External停点，实际执行意图生成、ProcessStart、stdout/stderr并发捕获、cleanup、准确ToJSON(wrapper)以及B消费；来源和每处替代精确记录，禁止把Driver未运行称为五组件真实运行。
2. 成功链验证生产格式启动intent（6字段/9参数）和40字段wrapper的实际原始字节，以及B成功schema；失败链覆盖有意义的输入/权限/身份失败、child失败/非零退出/stderr、捕获边界或溢出、超时/取消、清理截止及B拒绝不完整或不一致证据。选择非重复的有效组合，不为数量编造测试。保留上阶段有效回归，关键SHA测试能识别旧末尾换行缺陷；测试不只检查字符串出现或手造正确JSON。
3. 测试执行准确生产函数/表达式；对完整入口所需的外部依赖、路径、fixture进程及Git替代，只在明确标记的sandbox副本中实施，自动保存适配diff和源码身份。尽量保持真实控制流、序列化、捕获、cleanup和B消费者不被替换。记录哪些断言是实际行为，哪些是合成计数/输入；不在生产源码增加可绕授权的mock模式或隐藏后门。
4. 对时间要求给出可观察收据：软超时/cleanup测试记录实际Stopwatch测量、配置阈值、发生操作和状态。只证明测试观测范围，不把软截止声称为OS硬隔离。真实失败后允许修复、诊断和重测，不降低原合同标准，不删有效测试。
5. 最终源码包（如无需改源码则保持其身份）、fixture、测试/组装入口、适配差异和说明完整可审查。统一入口可在另一个本阶段新sandbox复现；至少完成最终版本的一次完整验证和一次隔离复现。失败/成功全部run统一索引，包括首次；命令、输入、exit、stdout/stderr原件、源码绑定齐备，明确未完成及风险。
6. 最终delivery.md逐项对照标准并列全部正式未执行项。固定技术交付manifest后向Work通知，附版本、项数、完整SHA。manifest覆盖最终源码/测试/fixture、delivery/最终进度和有效证据；排除其自身、通知回执及Work文件以免递归。通知后不静默改包；需要修订则标明新版本和旧通知失效。只有最终交付时集中独立审查，不按内部实现步骤交Work审批。

## 来源、已确定约束

先读五authority生效顶部、现有交付工作流、路线图及elitesync-local-workflow skill，再按需要读取上阶段源码、测试、fixture和审查；无需重新审计全部历史。
准确来源root EVIDENCE/WORK-STAGE-M5-TOOLCHAIN-SOURCE-INTEGRATION-20261005：work-review.md、independent-review.md、delivery.md、source/manifest.json、source/bundle/、source/assemble.py、tests/、fixtures/、evidence/run-008/及work-review-evidence-final4/。上阶段ACCEPT/CLOSED SOURCEONLY_TOOLCHAIN_SOURCE_INTEGRATION_STAGE_V1保持；Work额外验证脚本也只作参考，不误把探针构造失败当生产源码缺陷。

启动前Work核定本地HEAD4bebc8f394248e254c1368a06fbdee5d2c883301、index空；执行者记录实际启动基线及相关身份。历史技术HEAD与执行基线分列，后续owned提交不可冒历史身份。GitHub文档备份可以独立前移，不自动pull。

沿用Native4/Preparation3/Publication8、Authority20、Snapshot4、A8、child22、wrapper40及B成功/失败合同；保留8192流/wrapper、4096child、30000命令行及软超时、2000ms cleanup等软件要求。纯虚构fixture可缩小物理依赖集合，但必须明确隔离适配，不能以synthetic 189/115118021等计数声称真实IO。准备包authority仍PREPARED_NOT_RELEASED/NOT_GRANTED、Publication=null；fixture ISSUED只位于sandbox且显著标记SYNTHETIC，不能赋生产权限。

## 自主修改、运行与预算

独立owned写集合为本阶段root下source/、tests/、fixtures/、evidence/、README/进度/最终交付及本地提交记录。task.md、dispatch.json、Work审查和project-source-replacements为Work-owned。上一阶段所有文件、旧来源、冻结Target/rawfixture保持只读；需要改组件时复制到新阶段，记录来源diff、同步组装身份、修复并重测。不得并行改别人文件或覆盖旧接受版本。

可自主调查上述相关仓库源码、选择测试架构和fixture、实现/重构、普通现有PowerShell/Python/.NET本地synthetic验证、运行自写无害fixture子进程、诊断修复重测。测试IO在本阶段sandbox；只为实际所需的入口编写验证，不拓展产品/科研定义。无需逐次申请，不设读写次数、显示总量或尝试次数门。

工作量预计4–6小时，仅规划估计，无硬截止；约90分钟有效工作仍无新定位证据或可验证进展时集中报告症状、尝试、证据、选择及具体所需决定，该反馈不自动关闭阶段。普通代码、测试、脚本、工具或通知错误可自行诊断修复重试。未完成且无真正阻塞则继续，不询问是否开始下一步。

owned本地Git checkpoint允许，仅显式选择本阶段内容；现有dirty/staged/untracked不动，index有他人内容时保护并改用patch/manifest记录。不push/pull/reset/clean/stash/PR/发布，不清理仓库。只允许删除确认为本阶段自己生成的disposable临时文件，原始失败证据、他人内容和重要资产不得删除。

## 少数实质停点与仍冻结事项

只在改变既定目标/合同或科研产品定义、需越过受保护环境/数据/运行边界、重要资产风险、真正持续阻塞或Owner明确暂停时联系Work；不依赖该决定的工作继续。合同有真实矛盾则一次集中提供证据和选项，不自行放宽。

本阶段不执行真实Publisher发行、Java/Groovy/parseClass/compile/JVM/14case，不访问真实TSV/Java/188jars、SDK/依赖缓存、冻结Target、生产DB/API/SSH、真实数据/备份/密钥、旧D:\EliteSync或项目外邻源索引；不搜索PATH/env/registry/HOME/cache，不下载安装或全局配置。UAC仍需当前Owner“我在”及具体授权。这里允许的fixture子进程不是正式运行解冻。

保持M5工具链准备/M6未开放、NOT_READY/RuntimeReady=false、parentstderr UNKNOWN、OS硬截止/隔离NOT_PROVEN、implicitAST/static NOT_MEASURED、真实binding/hook/LibraryExtension/SDK NOT_CHECKED、14case NOT_EXERCISED。旧闭预算、拒绝接受、M5-50和保护冻结均保留。

## 交付通知、验收与续接

完成标REVIEW_PENDING，不自ACCEPT，不自行发后继。本阶段Owner授权执行者通过send_message_to_thread向Work01a109e0-4b59-77e2-b2cf-dc293d6533ad/local发送完成、实质阻塞及必要交接通知；完成通知写清固定版本、manifest项数/SHA与delivery准确路径，回执另存。通知接口失败诊断并保存交付，不能伪称已送达或验收。

Work正常执行期间不逐步骤审查、不高频轮询、不并行修改执行文件。交付后完整非作者GPT-6.1 Sol/high审查，再Work独立LEVEL2集中终裁，一次汇总实质修复；修复续本阶段，后续聚焦修复和必要回归，不新增优化目标。预计工时不是预算关闭条件。

保留已有实际Owner/助手往返超过30次或上下文影响可靠性时的交接；工具调用不算往返。必要交接保留当前目标/授权/版本/证据/失败/剩余工作，续接该阶段，旧执行者停止写，不重规划、不复活旧闭预算。原五分钟自动化仍PAUSED，不新建监督轮询。
