# AUTH-163 作者交付｜2026-09-27

**纯虚构监督器候选已交，待 Work 独立 LEVEL 3 ACCEPT/REJECT。** 本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，原有 dirty 工作区保留。编辑前三个精确交付路径均不存在；本任务只新增本目录 `supervisor.py`、`test_supervisor.py`、本摘要。

| 新文件 | SHA-256 |
| --- | --- |
| `supervisor.py` | `024F2BDB70C3121C838C630B426A832FBD745D1B3566058667B4D6D54ABA9F4B` |
| `test_supervisor.py` | `6BE187F3F4D80719FA23A1539F7D06454BA55092C94B7B39520C655B4C90C555` |

## 实际候选边界

监督器只接受内部五个固定人工场景名，启动 `sys.executable -I -B -c` 的固定 Python 片段，`shell=False`；不接受调用方命令、路径、脚本正文或敏感输入。stdin 管道立即关闭；stdout/stderr 由两个线程分别只计数，应用层最多计入各自限额加 1 字节作为超限证据，不显式保存、返回或打印原文。底层管道缓冲可能预取更多字节，**严格的实际读取/暂存上限尚未证明**。当前函数将子进程执行期限限定在最多 2 秒的参数范围，超时/任一流超限立即进入直接子进程终止尝试；退出非零、超时、超限、启动异常及终止不确定都不视为 `COMPLETE`。只返回枚举状态、退出码及受限观察字节数。任何 `COMPLETE` 也仅是虚构片段完成，**没有**消费者或真实恢复放行。

此实现只检查**直接子进程**的退出；启动 `Popen` 本身是同步调用，未证明其耗时可由执行期限强制上限约束。终止尝试最多另用 0.6 秒，随后有短的读线程等待，因此执行期限不等于整个调用的绝对墙钟上限。子孙进程清理、PowerShell 可执行文件身份、无 UAC/服务自动启动、pagefile/WER/锁页、防明文落盘及 Docker/容器隔离均 `NOT_PROVEN`。故不得用本候选运行 AUTH-155 的现场表达式，也不能将它当 AUTH-153 的 CMS 明文暂存或认证失败消费者 0/0 证明；Phase B 仍 `NOT_READY_TO_RUN`。

## 有界语法与唯一测试首跑

两份新文件分别用设置 `PYTHONDONTWRITEBYTECODE=1` 的 `python -B -c` 内置 `ast.parse` 做一次只读语法检查，均退出 0；未调用 `py_compile`，本目录 `__pycache__` 不存在。`python -B test_supervisor.py` 在同样禁写字节码设置下首跑 **1/1 次**，退出 0，**6 tests**，无失败或复跑；每个用例至多一次 `Popen` 尝试。测试仅用固定人工 Python 片段；启动错误用 `unittest.mock` 模拟 `Popen` 抛 `OSError`，该例没有真实子进程。

| 虚构场景 | 执行期限；stdout/stderr 限额（字节） | 状态 | 退出码 | stdout/stderr 受限观察字节数 |
| --- | --- | --- | ---: | ---: |
| 正常 | 1.0 秒；32/32 | `COMPLETE` | 0 | 2/0 |
| 非零且已有 stdout | 1.0 秒；32/32 | `EXIT_NONZERO` | 7 | 1/0 |
| stdout 超限 | 1.0 秒；32/32 | `STDOUT_LIMIT` | 1 | 33/0 |
| stderr 超限 | 1.0 秒；32/32 | `STDERR_LIMIT` | 1 | 0/33 |
| 睡眠超时 | 0.2 秒；32/32 | `TIMEOUT` | 1 | 0/0 |
| 模拟启动异常 | 1.0 秒；32/32 | `START_ERROR` | `None` | 0/0 |

退出码 1 是此次 Windows 直接子进程终止后的观察值，不是可移植约定；33 字节仅是限额加 1 的超限证据，不含原文。两份新 Python 逐行只读检查均无尾随空白。完整套件 `NOT_RUN`。未运行 AUTH-155 候选命令，未访问 ACL、Docker/WSL、注册表、隔离目标、密文/私钥、真实 DB、SSH/云/生产 API，也未触发 UAC；未提交、拉取或推送。

回退仅移除本目录的三份新文件，保留所有既有证据、代码和工作区内容。作者停 Work LEVEL 3 独立审查，不自接受、不启动真实预检。
