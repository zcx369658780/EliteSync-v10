# AUTH-170｜Windows Job 纯虚构预检停点

**作者结论：`UNAVAILABLE`，停 Work 独立 LEVEL 3 审查。** 这表示本任务固定来源和当前候选尚未建立可安全执行的“暂停态纳入 Job → 失败不恢复 → 有界清理”路径；**不表示**已经证明本机 Windows Job API 缺失或不支持。为遵守“无法有界清理则触发前停止”，本轮没有创建 Job、人工父进程或后代，也没有运行目标进程树试验。父/后代存活结论为 `NOT_STARTED`，进程树清空证明为 `NOT_CHECKED`；本轮没有被创建的残留对象，不能由此推断未来启动后的残留状态。

固定人工父/后代若要运行，需先有独立审定的启动原语：保证人工父在任何用户代码运行前保持暂停，成功纳入由本进程拥有且禁止 breakaway 的 Job 后才恢复；纳入失败时不恢复，能够在固定期限内终止并确认仍暂停的直接子进程。现有固定来源仅提出该候选，没有可审的本机实现、失败清理证明或每阶段可强制的有限上界。直接使用 `subprocess.Popen` 的同步启动/直接子进程等待不能补足该证明；临时引入未经审定的 `ctypes` 结构/句柄生命周期、后台线程、服务、UAC 或外部工具会扩大本任务风险。故**启动次数 0、Job 创建次数 0、恢复次数 0**，启动/清理硬限均未声称已强制。任务要求的人工后代存活、父先退和纳入失败负例均 `NOT_RUN`，不能报 `TREE_CLEARED` 或能力 PASS。

本地核对时为 `D:\EliteSync-v10`、`main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；原有 dirty/untracked 保留。唯一新增本目录 `job_probe.py`、`test_job_probe.py`、`summary.md`。前两文件 SHA-256 分别为 `643A9C993C6C7C563A3A23BFC6D5243D7310A5A37A8D4431A7D286E55AB61E28`、`AE1BCF1068547D2ABC483CDC09C64B2CE2DAE21065361FBAE1097D7C2C9EC2D3`。测试前 `python -B` 加禁写字节码的 `ast.parse` 静态核对退出 0；唯一一次定向首跑 **3 tests、退出 0、无复跑**，只验证 `UNAVAILABLE` 回执无启动/清理成功声称，并用补丁监视 `subprocess.Popen` 与 `os.system` 不被调用。测试本身不观察 Job API 或任何人工子进程。本目录未留 `__pycache__` 或额外文件。

AUTH-166 的总墙钟、双流硬字节/内存、进程树清理与 AUTH-167 的峰值内存均未由本轮关闭；CMS、隔离目标、DB 消费者和真实恢复门仍 `NOT_PROVEN/NOT_READY`。如 Work 后续要验证 Job，须另发含已审启动/暂停/纳入原语、每阶段固定可强制时间上界、失败时仍暂停进程的安全终止与独立后代身份核对的新任务；本文件不派发它。未运行 AUTH-155、ACL/注册表/Docker/WSL、UAC、CMS/解密/恢复、真实备份/密钥/DB、SSH/云/API；未访问旧 `D:\EliteSync`，未提交、pull 或 push。旧预算不重置。
