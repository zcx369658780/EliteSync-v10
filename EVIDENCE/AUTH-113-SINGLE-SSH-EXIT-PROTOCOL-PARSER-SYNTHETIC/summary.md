# AUTH-113｜单 SSH 退出协议解析纯虚构候选

**作者候选，待 Work LEVEL 2 独立审查。** 2026-09-26；本地 `D:\EliteSync-v10`、`main`，启动 HEAD `e9bdab4b7ddb46716155fce15a50142aaaf1953d`。本任务仅新增本目录的 `single_exit_parser.py`、`test_single_exit_parser.py` 和本回执；AUTH-107～112 及控制文件只读，两个无关未跟踪目录保留。

## 候选边界

`parse_single_exit()` 是纯函数，只接收调用方给出的虚构 stdout/stderr 字节、两流完整标志和**一个** SSH 本地退出候选；接口没有 `remote_exit` 输入，也不会从同一 SSH 数值补造第二个独立实测值。两流各限 2,048 bytes；任一流不完整、stderr 非空、超限、SSH 退出未知、255 或其他非零均不给肯定投影。SSH 255 的连接错误/远端命令自身 255 歧义保持失败，不猜原因。

SSH 候选为 0 时，仅接受 LF 终止的一行严格 UTF-8 JSON；拒绝 BOM、原始控制字符/ANSI、额外行、重复/额外/缺失键、非法类型与未知协议版本。沿用 AUTH-110 的九字段安全 schema：`error_class=NONE`、声明的两个工具 `exit_codes=[0,0]`、有限 `10.11.x` 版本文本候选、`BOUNDED_UNPARSED` 帮助状态、合法字节数和九项始终 `UNKNOWN` 必须同时一致。JSON 报固定失败或任何内部矛盾都不输出部分肯定。普通错误结果清空候选和计数，不回显原文、路径、输入或异常文字。

成功普通结果只标 `PROTOCOL_CONSISTENT_TEXT_CANDIDATE`，并固定附 `SSH_EXIT_OBSERVED_CANDIDATE`、`UNVERIFIED_PROTOCOL_DECLARATION`（远端程序与工具两个状态）和 `UNVERIFIED` 身份。这里的 SSH 数值在本轮仍由测试调用方提供；即使格式一致，也**没有证明真实 SSH、远端固定程序、两个工具、主机身份或备份能力**。AUTH-112 的联合判定合同仍需未来独立实现与现场风险门。

## 本轮验证

| 检查 | 用量与结果 |
| --- | --- |
| 纯虚构字节套件 | **1/3 轮**，`python -B test_single_exit_parser.py` 退出 0，`SYNTHETIC_CHECKS_PASS=34`。覆盖正常、SSH 255/非零/未知、成功 JSON 与非零退出矛盾、SSH 0 但 JSON 固定失败、工具退出声明非零/缺失、两流超限/不完整/stderr、重复键、多行、BOM、控制字符、非法 UTF-8、秘密标记不泄漏和 `UNKNOWN` 选项。测试文件没有启动子进程。 |
| 静态检查 | **1/2 轮**，两个 Python 文件 AST 可解析，尾随空白 0 行。 |

本轮没有 SSH、远端程序或工具运行；真实进程输出和退出来源、host-key、固定程序/工具路径与哈希、环境净化、启动阻塞、DB 目标与权限均 `UNKNOWN`。AUTH-107 Phase B 未放行。Owner 已决定本次备份仅包含数据库内数据与对象，不含数据库外上传文件；数据库内部对象全集与恢复能力仍未证明。真实备份仍须前置门和 Owner LEVEL 3 单次授权。

没有读取 `.env`、凭据、私钥、真实业务行、备份或旧 `D:\EliteSync`；没有启动任何测试子进程、SSH、真实工具/DB、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。AUTH-101/17/107 已耗预算不重置。候选停在 Work LEVEL 2 独立审查门；不提交、推送、自接受或派发后继。

## Work LEVEL 2 独立审查（2026-09-26）

**ACCEPT，仅限纯虚构字节的单 SSH 退出协议解析。** Work 核对本地 `main` HEAD `e9bdab4b7ddb46716155fce15a50142aaaf1953d`、工作区差异、`single_exit_parser.py` 与 `test_single_exit_parser.py`；候选仅新增本证据目录。Work 独立运行最终候选 `python -B EVIDENCE/AUTH-113-SINGLE-SSH-EXIT-PROTOCOL-PARSER-SYNTHETIC/test_single_exit_parser.py`，退出 0、`SYNTHETIC_CHECKS_PASS=34`；`git diff --check` 通过。作者套件 1/3、静态检查 1/2，Work 独立复跑另记。

公开接口只有一个 SSH 退出候选；255、其他非零、未知及 JSON 内部失败均无肯定投影。成功结果固定标明本地 SSH 退出只是调用方观察候选，远端程序和工具退出为 `UNVERIFIED_PROTOCOL_DECLARATION`，所有选项仍 `UNKNOWN`。本接受不证明真实 SSH、主机/host-key、固定远端程序、工具身份、权限或备份可用；AUTH-111 的进程接线也未因此自动改造。AUTH-107 Phase B 继续未放行；未来现场调用仍须新任务、固定字节/身份、启动阻塞与双流限额风险门。
