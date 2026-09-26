# AUTH-110｜有界投影传输解析纯虚构候选

**作者候选，待 Work LEVEL 2 独立审查。** 2026-09-26；本地 `D:\EliteSync-v10`、`main`，启动 HEAD `908e4d4bacccad17b627bfbd5907fc2dd7a0312b`。只新增本目录的 `transport_parser.py`、`test_transport_parser.py` 与本回执；AUTH-107～109 和控制文件只读，两个无关未跟踪目录保留。

## 候选边界

`parse_transport()` 是纯函数，仅接收调用方显式给出的虚构 SSH stdout/stderr 字节、SSH 与远端程序退出码候选，以及两流完整标志；不启动进程、不读文件、不接网。两流分别严格限制为 **2,048 bytes**。非完整、stderr 非空、退出未知/非零或超限先返回固定失败类别，普通结果不包含任何输入原文或异常文字。

仅接受一条以 LF 终止的严格 UTF-8 JSON；拒绝 BOM、原始控制字符/ANSI、额外行、重复键、额外/缺失键、未知协议版本、非法类型与字段关系。schema 对齐 AUTH-109 的九个固定字段：版本候选仅 `10.11.x` 或 `UNKNOWN`，帮助仅 `BOUNDED_UNPARSED`/`UNKNOWN`，版本/帮助字节数分别限于 256/24,576，两项工具退出码须为有界整数或 `null`，九个选项必须全部 `UNKNOWN`，身份状态只能是 `CALLER_CANDIDATE_UNVERIFIED`。远端错误类别采用固定白名单；`error_class=NONE` 还要求两项工具退出 0、正字节数及完整的文本候选关系。否则不交付肯定投影。远端报告固定失败时，本地只返回 `REMOTE_REPORTED_FAILURE`，不转发远端错误正文或部分版本候选。

成功普通结果仅标记 `TEXT_CANDIDATE_ONLY`、给定 JSON 中的有限版本文本候选、帮助未解析状态、两个有界计数、全部 `UNKNOWN` 选项和 `UNVERIFIED` 身份。**它仍不证明 JSON 来自真实主机、程序或工具。** 失败普通结果统一清空候选与计数，给固定类别；SSH 与远端原始 stderr 均不回显。

## 本轮验证

| 检查 | 用量与结果 |
| --- | --- |
| 纯虚构字节套件 | **1/3 轮**，`python -B test_transport_parser.py` 退出 0，`SYNTHETIC_CHECKS_PASS=42`。覆盖正常回执、SSH/远端退出未知或非零、完整性、两流超限和 stderr、重复/额外/缺失键、版本/类型/计数/选项错误、UTF-8、BOM、换行/多行、控制字符/ANSI、秘密标记不泄漏及远端失败不产生部分肯定。测试代码没有启动子进程。 |
| 静态检查 | **1/2 轮**，两个 Python 文件 AST 可解析，尾随空白 0 行。 |

这只验证调用方提供的**虚构字节**与纯解析逻辑；SSH 进程级超时/限额、远端程序退出码来源、远端投影程序部署/完整性、主机与 host-key、工具路径/别名/哈希、环境净化、真实帮助格式和 DB 权限均 `UNKNOWN`。AUTH-107 Phase B 与真实备份未放行；AUTH-101/17/107 已耗预算不重置。没有读取 `.env`、凭据、私钥、真实业务行、备份或旧 `D:\EliteSync`；没有执行 SSH、任何测试子进程、真实工具、DB、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写或 DDL/DML。候选停在 Work LEVEL 2 独立审查门；不提交、推送、自接受或派发后继。

## Work LEVEL 2 独立审查（2026-09-26）

**ACCEPT，仅限调用方给出的纯虚构字节的有界传输解析。** Work 核对本地 `main` HEAD `908e4d4bacccad17b627bfbd5907fc2dd7a0312b`、工作区差异、`transport_parser.py` 与 `test_transport_parser.py`；候选只新增本证据目录。Work 独立运行 `python -B EVIDENCE/AUTH-110-BOUNDED-PROJECTION-TRANSPORT-PARSER-SYNTHETIC/test_transport_parser.py`，退出 0、`SYNTHETIC_CHECKS_PASS=42`；`git diff --check` 通过。作者预算为套件 1/3、静态检查 1/2；Work 独立复跑另记，不改作者用量。

解析器对两流各 2,048 bytes、完整性、stderr、双层退出、单行终止、严格 UTF-8、重复/额外字段、固定枚举及内部成功关系采用拒绝式检查；普通结果不带输入原文，固定选项保持 `UNKNOWN`。这只接受**给定字节的解析行为**。SSH 进程是否按限额采集、远端退出码的真实来源、固定远端程序、主机/host-key、工具身份与选项、DB 权限、备份和恢复均 `UNKNOWN`。AUTH-107 Phase B 未放行，真实备份仍须独立前置门和 Owner LEVEL 3 单次授权。
