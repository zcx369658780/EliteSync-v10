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
