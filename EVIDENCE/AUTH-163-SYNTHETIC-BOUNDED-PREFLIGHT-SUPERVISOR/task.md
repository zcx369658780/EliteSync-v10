# AUTH-163｜纯虚构有界预检监督器探针

状态：`ISSUED`；风险 LEVEL 3（真实恢复前工具链的一项前置能力，本轮仅 synthetic）。派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；唯一主要结果是本目录的虚构子进程监督器候选和测试，交付后停 Work 独立 LEVEL 3 审查。

## 固定入口与范围

先核对 `D:\EliteSync-v10` 本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、dirty 工作区和当前任务。只读根治理文件、workflow 技能、AUTH-153 `plan.md` 中认证失败消费者 0/0、AUTH-155 `plan.md`/`work-review.md`、AUTH-71 `run.py`/`test_run.py`/`summary.md` 的虚构边界。仅允许新增本目录原先不存在的 `supervisor.py`、`test_supervisor.py`、`summary.md`；若路径已存在即停 Work 核对。不改既有代码/文档、状态或配置。

## 仅 synthetic 行为

实现普通权限下对**本任务固定的人工 Python 子进程**的一次有界启动/捕获探针：无 shell、无网络、无文件或敏感路径输入，分别设置硬墙钟上限、stdout/stderr 字节上限；输出仅有限状态 `COMPLETE/EXIT_NONZERO/TIMEOUT/STDOUT_LIMIT/STDERR_LIMIT/START_ERROR/TERMINATION_UNCERTAIN`、退出码及两流实际**受限**字节数，不保存或打印子进程原文。任何启动/超时/超限/终止不确定都 fail closed；超限时须立即尝试终止而非继续无限读取。测试只用 `sys.executable` 的人工固定 `-c` 片段，覆盖正常、非零且已有 stdout、stdout 超限、stderr 超限、超时、启动失败；每例最多一次进程调用。若平台不能可靠确认终止或子孙进程清理，明确 `TERMINATION_UNCERTAIN`/`NOT_PROVEN`，不得自称可监督真实现场命令。测试不可调用 PowerShell、Docker/WSL、OpenSSL、注册表、ACL、真实备份/密钥或数据库。

此工具**不得**把任何 stdout 传给消费者，也不得成为 AUTH-153 的真实解密暂存；不处理 CMS 明文、Owner 密码或私钥，不接受任意外部命令作为本轮测试输入。普通 Python 子进程的合格结果不能证明 PowerShell 可执行文件身份、无 UAC/服务自动启动、进程树全清、pagefile/WER/锁页、防明文落盘、容器隔离或 AUTH-155 Phase B 可运行。

## 预算与停点

两份新 Python 各一次 `python -m py_compile` **会生成字节码文件则不得使用**；改以 Python 内置 `ast.parse` 对两文件各一次只读语法检查，设置 `PYTHONDONTWRITEBYTECODE=1`。`test_supervisor.py` 首跑一次，若仅本任务新代码/测试缺陷失败可修正后最多复跑一次；记录每例状态、退出码和有限字节数，只在普通证据中写脱敏摘要，不写原始 stdout/stderr。新文件未跟踪，需单独做尾随空白检查。完整套件 `NOT_RUN`。

`summary.md` 记录前后路径存在性、SHA-256、每个虚构场景的状态/退出/限额、测试退出码/用例数、复跑、不能外推的边界和回退只移除本目录三个文件。不得访问旧 `D:\EliteSync`、本机候选隔离目标、备份/密钥、SSH/云/生产 API、真实 DB、Docker/WSL、UAC、注册表或 AUTH-155 表内候选命令；不提交、拉取或推送。作者停 Work LEVEL 3 ACCEPT/REJECT，不自接受或启动真实预检。
