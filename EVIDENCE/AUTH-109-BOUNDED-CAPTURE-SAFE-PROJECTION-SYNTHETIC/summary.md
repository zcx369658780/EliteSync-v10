# AUTH-109｜有界采集与安全投影虚构集成候选

**作者候选，待 Work LEVEL 2 独立审查。** 2026-09-26；本地 `D:\EliteSync-v10`、`main`，启动 HEAD `0fe6a77cda0b8f707b0eb2a32365b6800be21144`。仅新增本目录的 `integrated.py`、`test_integrated.py` 和本回执；AUTH-107/108 只读，原有控制文件修改与两个无关未跟踪目录保留。

## 候选行为

`observe_synthetic()` 要求调用方显式提供绝对可执行路径、预期工具名和 64 位十六进制 SHA-256 **候选**。它不查找程序，不读取默认环境值，不用 shell；子进程 stdin 关闭、环境为空。最多顺序启动两次，实际传给 `Popen` 的参数数组精确为 `[executable, '--no-defaults', '--version']` 和 `[executable, '--no-defaults', '--help']`。第一步失败即不启动第二步。两步共用一个执行期限；版本 stdout 上限 256 bytes、帮助 stdout 上限 24,576 bytes、各 stderr 上限 256 bytes，两流并发排空。超限或超时杀死并等待该子进程；回收另给最多 2 秒，失败归类 `TERMINATION_FAILED`。

原始 stdout/stderr 只在同一进程的私有采集和投影局部变量中保留至各自限额，不写文件、日志、异常或对外返回。两次捕获都完整、退出零、stderr 为空后，才对原始字节做严格 UTF-8、终止换行、控制字符与有限 banner 检查。成功仅返回给定文本的 `10.11.x` **版本候选**和 `BOUNDED_UNPARSED` 帮助状态；九个选项始终 `UNKNOWN`，不采用 AUTH-106 的人为选项布局作现场支持结论。帮助首行若不匹配同一版本 banner，全部投影回 `UNKNOWN`；第二次任何失败也不保留第一次的部分肯定结果。普通返回值只含固定类别、候选状态、字节计数、两次真实退出码与 `CALLER_CANDIDATE_UNVERIFIED` 身份状态，不含路径、原文、异常文字或环境内容。

工具名与 SHA-256 当前仅为**调用方声明的输入格式**；本候选不解析符号链接、不读取或哈希实际可执行文件，也不证明该路径与预期身份绑定。AUTH-107 `projector.py` 的完整测试仍 `NOT_VERIFIED`；本轮没有调用或修改它，采用新目录内更窄的同进程投影，不重置旧预算或接受结论。

## 本轮验证

| 检查 | 用量与结果 |
| --- | --- |
| 本地虚构子进程套件 | **1/3 轮**，`python -B test_integrated.py` 退出 0，`SYNTHETIC_CHECKS_PASS=12`。覆盖固定首参数和两次顺序、正常版本/帮助、版本与帮助不匹配、第一/第二次非零、stderr、双流突发、超限、控制字符、非 UTF-8、秘密标记不回显、超时子进程终止、无效输入不启动。 |
| 静态检查 | **1/2 轮**，两个 Python 文件 AST 可解析，尾随空白 0 行。 |

测试用临时生成的 Python 虚构子进程；测试适配层拦截并核对 `Popen` 的固定参数数组，再直接启动该 Python 子进程。因此已验证集成函数构造的调用参数及本地捕获/投影逻辑，**尚未**证明一个真实可执行文件在操作系统层收到这些参数。当前 Windows 虚构测试见一次超时杀死/等待；终止失败注入、子孙进程继承管道、其他系统行为仍 `UNKNOWN`。真实帮助格式、二进制路径/别名/符号链接/哈希绑定、环境净化、SSH 身份与 host-key，以及实际工具来源和能力均 `UNKNOWN`。

本轮未读取 `.env`、凭据、私钥、真实业务行、备份或旧 `D:\EliteSync`；未执行 SSH、网络、真实 dump 工具、生产 API、Laravel CLI、DB、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。AUTH-107 Phase B 与真实备份未放行；AUTH-101/17/107 既有预算不重置。候选停在 Work LEVEL 2 独立审查门；不提交、推送、自接受或派发后继。

## Work LEVEL 2 独立审查（2026-09-26）

**ACCEPT，仅限本地虚构子进程的有界采集与同进程安全投影候选。** Work 核对本地 `main` HEAD `0fe6a77cda0b8f707b0eb2a32365b6800be21144`、工作区差异、`integrated.py` 和 `test_integrated.py`；候选写入仅在本证据目录。Work 独立运行一次 `python -B test_integrated.py`，退出 0，`SYNTHETIC_CHECKS_PASS=12`。固定两次参数、失败即停、双流限额、非零/stderr/超时、第二次失败抹去部分肯定结果及秘密标记不进入普通结果，均有本地虚构用例支撑。作者本任务用量为套件 1/3、静态检查 1/2；Work 独立审查运行另记，不改变作者预算。

本接受不证明操作系统层真实工具参数、路径/符号链接/哈希绑定、环境净化、真实帮助格式、SSH/host-key、DB 权限或备份可用。异常后的子进程终止失败、子孙进程继承管道及跨系统行为没有负向注入证据，均保持 `UNKNOWN`；`CALLER_CANDIDATE_UNVERIFIED` 是准确身份状态。AUTH-107 `projector.py` 的完整测试仍 `NOT_VERIFIED`，Phase B 未放行。任何现场调用须另立任务并独立审查固定字节和风险门；真实备份仍须全部前置门及 Owner LEVEL 3 单次授权。
