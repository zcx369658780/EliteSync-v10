# v10.1.5｜固定控制台角色的独立VM源验证

2026-11-02，Owner在当前接续上下文明确“请继续，我授权”。此前入口已指明下一项为结合具名控制台角色的独立VM/Flutter候选；本节点只落实其中VM源验证。该许可不补充已耗scope，不启动Flutter、Gradle或实际产包。

独立scope `v1015-vm-source-qualified-console-20261102/case01`，最多1次。实际创建尝试前独占写不可退款claim；启动失败、非零退出、STOP、无结果均耗这一次，不能重跑或换目录续额。原配置3+3+1及Dart/cache/stdio/OS库存/合成控制台的旧claim、失败和STOP保持。

精确入口为现有dartvm.exe，参数与此前固定stdio源诊断一致：两个逻辑launcher路径参数及自有stdio_stage_probe.dart。仅读取六项终端/ANSI元数据getter，前后同步JSONL标记；不读stdin内容。原SDK只读，写面仅任务私有目录/输出。网络、剪贴板、音视频和设备映射关闭；仍为90秒运行上限、15秒独立heartbeat、4GiB私有工作面/512MiB输出采样边界，保留采样非原子及UDP目的地UNKNOWN限制。

唯一已知镜像为固定VM及guest `C:\Windows\System32\conhost.exe`，后者长度1003520、SHA256 `c86146188b78e484f32cc29e2331689659943b47689a85570342044f499938ac`。输入校验和首次进程绑定均用有界OS哈希/身份检查，未知镜像立即STOP；不增加通配或宽泛微软签名许可。guest kernel32版本固定10.0.26100.6713、CLR4.0.30319.42000，漂移在VM创建前拒收。

复用依据为上一合成scope的固定manifest、原始receipt和verified-result三份SHA，而非重新调用旧scope的frozen或重跑它。只接受其具名OS角色；本轮仍须验证真实VM路径。当前生成native从固定base与已审控制台生成源衍生，保存完整原文/patch/变换报告；不改旧native或claim。版本字符串及具名文件哈希不宣称完整已加载DLL闭包。

成功必须真实root0、无STOP/watchdog、精确两成员及不同PID的VM/控制台镜像样本、完整14条标记、Job空及全部句柄退出；getter异常另列，不推断唯一根因。明确的输入/环境/CreateJob/Spawn失败可封存REJECTED，不能因收集器exit0升格成功。结果仅覆盖固定VM源脚本，不覆盖Flutter snapshot、锁、BAT等价性、完整native树、Gradle、AAR或APK。

工程角色沿现行Local-first：Codex实施、检查及工程裁决；非作者Codex源码复核不称外部独立验收。手机现行一般许可保留，本scope不访问设备或媒体；AC05 OPEN、G2 false、10 PARTIAL和真实消息Push PENDING保持，不合main、不发布、不启动v10.1.6。实际结果及证据见唯一进度细表，本文件不是额度计数器。
