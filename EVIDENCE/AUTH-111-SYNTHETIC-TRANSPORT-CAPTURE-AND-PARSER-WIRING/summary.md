# AUTH-111｜虚构传输采集与解析衔接候选

**作者候选，待 Work LEVEL 2 独立审查。** 2026-09-26；本地 `D:\EliteSync-v10`、`main`，启动 HEAD `5181204ee15adef64e381285d3b4c21f8ed9b158`。只新增本目录的 `wiring.py`、`test_wiring.py` 和本回执；AUTH-107～110、Work 控制文件只读，两个无关未跟踪目录保留。

## 候选边界

`capture_and_parse_synthetic()` 只接受调用方显式传入的绝对虚构可执行路径和不可变参数元组；不发现程序，不用 shell，子进程 stdin 关闭、环境为空。stdout/stderr 分别由线程并发采集，各最多保留 2,048 bytes；执行期限设为最多 30 秒，从尝试启动前计时。超限或超时杀死并等待子进程，终止回收另给最多 2 秒；回收失败固定归类 `TERMINATION_FAILED`。`Popen` 自身阻塞无法由当前结构严格中断，故启动耗时的硬上限仍未证明。不完整、非零退出或 stderr 非空都不会进入解析器。普通结果和异常不返回原始字节、参数、路径或环境内容。

两流完整且本地进程退出零后，候选只在内存中把有限字节交给 **AUTH-110 已接受的纯解析器**。读取的解析器源码须匹配 SHA-256 `FF6268D37C539F89843EE40652D3F284C4BC848AEB40E95527475D32CA7B25B0`，不匹配就固定失败；从源代码编译加载，不生成旧目录的 bytecode。没有改写 AUTH-110。

本地进程的退出码仅作为这次**虚构进程**的退出候选传给解析器。另一个 `remote_exit_candidate` 必须由调用方显式提供并标为 `UNVERIFIED`；缺失时解析器返回 `EXIT_UNKNOWN`，本地退出 0 不能替它补证。所有普通结果固定带 `SYNTHETIC_LOCAL_PROCESS_ONLY` 与 `UNVERIFIED_CALLER_CANDIDATE`。即使解析状态为 `TEXT_CANDIDATE_ONLY`，也只说明本次虚构进程的字节通过 AUTH-110 格式门，不证明 SSH 或远端程序的独立退出。

## 本轮验证

| 检查 | 用量与结果 |
| --- | --- |
| 临时虚构子进程套件 | **2/3 轮**，第 1 轮 `SYNTHETIC_CHECKS_PASS=11`；复核发现启动耗时未计入期限，修正计时起点；第 2 轮修复后再次退出 0、`SYNTHETIC_CHECKS_PASS=11`。覆盖正常单行、远端退出缺失/非零、解析失败、stdout/stderr 超限、stderr 非空、本地非零、双流突发、超时杀死并等待、秘密标记不泄漏和无效输入。仅启动临时生成的 Python 虚构子进程。 |
| 静态检查 | **2/2 轮**；修复前后各一次，均为两个 Python 文件 AST 可解析、尾随空白 0 行。 |

`Popen` 启动阻塞、终止失败、子孙进程继承管道、Windows 以外系统行为及真实 SSH 退出语义仍 `UNKNOWN`。真实远端退出来源、远端程序部署/身份、主机/host-key、工具路径/别名/哈希、环境净化、真实帮助格式、DB 目标与权限均未证明。AUTH-107 Phase B、真实备份和 UAC 后继步骤未放行；AUTH-101/17/107 旧预算不重置。

本轮未读取 `.env`、凭据、私钥、真实业务行、备份或旧 `D:\EliteSync`；未启动 `ssh.exe`、远端程序、真实 dump/DB 工具，未连接网络或执行生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。候选停在 Work LEVEL 2 独立审查门；不提交、推送、自接受或派发后继。

## Work LEVEL 2 独立审查（2026-09-26）

**ACCEPT，仅限当前 Windows 本地临时虚构子进程的双流采集与 AUTH-110 纯解析器接线。** Work 核对本地 `main` HEAD `5181204ee15adef64e381285d3b4c21f8ed9b158`、工作区差异、`wiring.py` 与 `test_wiring.py`。AUTH-110 解析器当前 SHA-256 独立核对为 `FF6268D37C539F89843EE40652D3F284C4BC848AEB40E95527475D32CA7B25B0`，匹配候选固定值。Work 独立运行最终候选 `python -B EVIDENCE/AUTH-111-SYNTHETIC-TRANSPORT-CAPTURE-AND-PARSER-WIRING/test_wiring.py`，退出 0，`SYNTHETIC_CHECKS_PASS=11`；`git diff --check` 通过。作者本任务套件 2/3、静态检查 2/2，Work 独立复跑另记。

候选在采集完整、两流不超限、本地退出零及 stderr 为空后才把局部原始字节交给哈希固定的解析器；普通结果保留 `SYNTHETIC_LOCAL_PROCESS_ONLY` 与 `UNVERIFIED_CALLER_CANDIDATE`，不会用本地进程退出码填补远端退出候选。`Popen` 启动阻塞不能由当前结构硬性中断；终止失败、子孙进程继承管道和跨系统行为也未验证，均为 `UNKNOWN`。此接受不放行用任意实际路径调用候选，不证明 SSH/远端程序独立退出、host-key、工具身份、DB 目标或备份。AUTH-107 Phase B 继续未放行；现场任务须先解决这些独立风险门。
