# v10.1.5｜固定控制台角色的独立VM源验证

2026-11-02，Owner在当前接续上下文明确“请继续，我授权”。此前入口已指明下一项为结合具名控制台角色的独立VM/Flutter候选；本节点只落实其中VM源验证。该许可不补充已耗scope，不启动Flutter、Gradle或实际产包。

独立scope `v1015-vm-source-qualified-console-20261102/case01`，最多1次。实际创建尝试前独占写不可退款claim；启动失败、非零退出、STOP、无结果均耗这一次，不能重跑或换目录续额。原配置3+3+1及Dart/cache/stdio/OS库存/合成控制台的旧claim、失败和STOP保持。

精确入口为现有dartvm.exe，参数与此前固定stdio源诊断一致：两个逻辑launcher路径参数及自有stdio_stage_probe.dart。仅读取六项终端/ANSI元数据getter，前后同步JSONL标记；不读stdin内容。原SDK只读，写面仅任务私有目录/输出。网络、剪贴板、音视频和设备映射关闭；仍为90秒运行上限、15秒独立heartbeat、4GiB私有工作面/512MiB输出采样边界，保留采样非原子及UDP目的地UNKNOWN限制。

唯一已知镜像为固定VM及guest `C:\Windows\System32\conhost.exe`，后者长度1003520、SHA256 `c86146188b78e484f32cc29e2331689659943b47689a85570342044f499938ac`。输入校验和首次进程绑定均用有界OS哈希/身份检查，未知镜像立即STOP；不增加通配或宽泛微软签名许可。guest kernel32版本固定10.0.26100.6713、CLR4.0.30319.42000，漂移在VM创建前拒收。

复用依据为上一合成scope的固定manifest、原始receipt和verified-result三份SHA，而非重新调用旧scope的frozen或重跑它。只接受其具名OS角色；本轮仍须验证真实VM路径。当前生成native从固定base与已审控制台生成源衍生，保存完整原文/patch/变换报告；不改旧native或claim。版本字符串及具名文件哈希不宣称完整已加载DLL闭包。

成功必须真实root0、无STOP/watchdog、精确两成员及不同PID的VM/控制台镜像样本、完整14条标记、Job空及全部句柄退出；getter异常另列，不推断唯一根因。明确的输入/环境/CreateJob/Spawn失败可封存REJECTED，不能因收集器exit0升格成功。结果仅覆盖固定VM源脚本，不覆盖Flutter snapshot、锁、BAT等价性、完整native树、Gradle、AAR或APK。

工程角色沿现行Local-first：Codex实施、检查及工程裁决；非作者Codex源码复核不称外部独立验收。手机现行一般许可保留，本scope不访问设备或媒体；AC05 OPEN、G2 false、10 PARTIAL和真实消息Push PENDING保持，不合main、不发布、不启动v10.1.6。实际结果及证据见唯一进度细表，本文件不是额度计数器。

## 继后独立Flutter私有缓存负例

上述VM源scope已成功并永久消耗1/1（退出0、14标记、精确双镜像、无STOP、完整清理），不再执行。沿本次Owner对已指明VM/Flutter候选的继续授权，下一项另立 `v1015-flutter-vm-qualified-console-20261102/case01`，同样独立max1及不可退款claim；不继承原CLI缓存失败scope余额。

目标是在刚核实的直接VM路径运行现有Flutter snapshot的固定负例：两个逻辑launcher路径参数、固定私有package_config/snapshot及 `--suppress-analytics --no-version-check --machine assemble`。原CLI/BAT不执行，原SDK/stamp不修；10份固定控制文件由现有源只读复制到任务自有fixture，进入guest私有Flutter根，锁必须由Flutter正常创建，严禁FLUTTER_ALREADY_LOCKED。此前源码顺序说明此参数组合在构建分派前拒绝；成功标准为实际exit2、固定错误句、lock0字节/nonreparse和legacy version、双镜像/无STOP/watchdog/清理完整。锁文件存在只是佐证，不冒称直接观察了锁持有。

历史VM的manifest/receipt/verified-result和先前合成OS证据均按精确SHA复用；本轮重新核完整只读SDK、10份控制源和全部映射/镜像/生成源/环境。仍仅允许固定VM/conhost双镜像及同样kernel/CLR；未知进程立即STOP。完整字节输入、原文、patch和执行回执私有保留。此单次失败或无结果同样永久耗尽，不退款、重跑或自动追加后继额度。

该负例不产AAR/APK、不执行assemble构建动作、不操作手机、媒体或供应商；真实产包claim尚未建立，G2仍false。本项支持也不证明stock BAT等价性、完整native树、实际构建/安装或整版工程验收。

### 实际拒收与静态候选

本独立Flutter scope已执行并永久耗尽1/1：root255，无supervisor STOP/watchdog，双成员及清理完整；尚未创建缓存锁，预期exit2/错误句未到达，明确REJECTED。原stderr首先报告process/src/interface/common.dart:60:49的空值断言；所选process5.0.5源码该行解引用PATHEXT，本次固定环境确实缺此键。事后CACHE_LOCK_NOT_CREATED是症状。当前证据支持缺PATHEXT是这次首异常的直接原因，不能据此承诺补齐后完整缓存路径成功。

新增纯静态候选只给私有环境字典副本加入PATHEXT=.EXE，拒其它扩展、重复Windows变量名和锁绕过，不继承宿主环境，不改已执行controller/SDK或旧claim。它没有启动能力，未接入任何新运行。现有Flutter _WindowsUtils._which源码在canRun后会调用where；where.exe尚未资格化，不能把.EXE扩展当作新的镜像许可。

### 后续具体验证提案（PROPOSED_NOT_AUTHORIZED）

需Owner对下一组有限运行另行确认，不修改上述两个已耗scope，也不自动续额。提案最多3个独立scope、每个最多1次，不是现有scope的重跑：

1. `v1015-where-image-inventory-20261102/case01`：仅在禁网guest由自有只读fixture核实固定System32/where.exe文件及Windows Catalog签名、版本、SHA、长度、句柄身份；不执行where，不映射SDK/产品/设备。固定文件结果若不完整或漂移即停止。
2. `v1015-where-execution-qualification-20261102/case01`：只有第1项支持、具体guest字节pin/完整输入/观察器固定并通过纯检查后，运行该固定where.exe的 `/Q __ELITESYNC_V1015_NEGATIVE_LOOKUP__`，期望exit1且无结果匹配。精确允许该where与已有具名conhost角色；不是宽泛系统工具白名单。具体长度/hash由第1项的immutable原证消费，未得到完整结果时不得执行。
3. `v1015-flutter-pathext-cache-recheck-20261102/case01`：前两项及现有VM角色均成立后，在本静态候选的私有环境上验证同一snapshot负例，精确加入已资格化where镜像。旧SDK/10份控制源不变，正常缓存锁，不执行stock CLI/BAT或构建分派；仍须真实exit2、固定错误句/缓存状态/精确镜像/完整清理共同满足才支持。

各scope启动前独占写max1不可退款claim，失败、无结果、STOP同样耗尽，无自动后继。每次仍90秒/15秒heartbeat、同等磁盘/只读映射/禁网/未知镜像STOP，实际准备后固定全部输入、命令、生成源与环境hash，再做非作者源码复核和适用纯检查；无法固定即NOT_RUN。签名无效、版本漂移、新映像、下载/网络或清理不完整只停止受影响分项，不重试、不放宽守卫。此次提案不含下载安装升级、AAR/APK/手机/媒体/供应商/生产/费用、main合并或发布，G2 false、AC05 OPEN保持。当前三项都未建执行claim、未运行，Owner现有一般APK/USB许可仍保留。

### 本组三项授权记录

Owner针对上述具名问题明确答复“授权按提案执行这三个独立单次验证”。上文PROPOSED_NOT_AUTHORIZED与未建claim是授权前的原时点状态；现允许按顺序准备和执行这三个各max1范围。前项不支持则后项NOT_RUN，不退款、重置、借旧余额或追加后继。实际执行以各任务根永久claim/原证为准；本授权不含产包、手机、媒体、供应商、生产、费用或main合并。
