# AUTH-116｜探针程序独立进程退出虚构隔离候选

**作者候选，待 Work LEVEL 2 独立审查。** 2026-09-26；本地 `D:\EliteSync-v10`、`main`，启动 HEAD `03b2efd8678df69423697939170b73991946eda1`。只新增本目录的 `test_adapter.py`、`test_process.py` 与本回执；AUTH-112～115 和控制文件只读，两个无关未跟踪目录保留。

## 固定来源与隔离方法

AUTH-115 `probe_program.py` 最终 SHA-256 独立核对为 `88B8BDE3E61A47A1E6B50A5B947619A29E9CF465D987512205DC818BD5E259B6`；其依赖 AUTH-114 `file_identity.py` 为 `D4D8CBA362362892FD55791BAE8955DD12490D893E7C998D22E66FE7CC1C9C18`。两者未修改。AUTH-113 单退出解析器本次核对为 `9AC7451FAE3D0A956B7D62546D0CCD97F06FBF383DDD190B6FD5A983314E4D3D`。

外层 `test_process.py` 每例直接启动一个**独立本机 Python 进程**运行临时适配脚本；适配脚本先核对 AUTH-115 固定源码哈希，再以 `runpy` 执行该原文件的 `__main__`，让 `SystemExit(main(...))` 真正决定进程退出码。适配脚本仅在该进程内拦截 `subprocess.Popen`，核对 AUTH-115 构造的虚构文件路径、`--no-defaults` 首参数和 `--version`/`--help`，然后使用保存的原始 `Popen` 启动临时 Python 虚构工具。临时虚构文件由 AUTH-115/AUTH-114 身份门核验，**它本身没有被操作系统执行**。此注入隔离只用于本机测试，不是远端程序部署或真实工具执行证据。

外层对程序进程 stdout/stderr 两流并发采集，各最多 2,048 bytes，整体等待最多 3 秒，超限/超时杀死并等待；只在测试进程内部检查有限原始字节，普通回执仅写固定状态。成功输出交 AUTH-113 纯解析器验证，但此处传入的是**本机 Python 进程**退出值，不是实测 SSH 退出。

## 验证与观察

| 检查 | 用量与结果 |
| --- | --- |
| 本地独立进程虚构套件 | **1/3 轮**，`python -B test_process.py` 退出 0，`SYNTHETIC_CHECKS_PASS=6`。正常用例观察到程序进程退出 **0**、stderr 空、一行 LF 终止安全 JSON，AUTH-113 对给定字节返回 `PROTOCOL_CONSISTENT_TEXT_CANDIDATE`；第一/第二次工具失败、stderr、注入 stdout 写入异常四例均观察到程序进程退出 **1**、两流空，AUTH-113 对该非零值不给肯定投影。注入工具启动阻塞一例由外层超时杀死并等待，归 `TIMEOUT`，没有秘密标记输出。 |
| 静态检查 | **1/2 轮**，两个新 Python 文件 AST 可解析、尾随空白 0 行。`test_adapter.py` SHA-256 `7B8A4801B6E5BE2CDF712FFEE1881D67D452495AA2FECA7094942748E215638F`；`test_process.py` SHA-256 `697C8A1D05409D6D1C236B95F9ED264D3DD620F1F06EBAD86D14FB210CF65E07`。 |

**结论仅限测试注入下 AUTH-115 原源码在本机独立 Python 进程的 stdout/stderr 与退出传播。** 已观察的 0/1 是该本机程序进程真实退出码；虚构工具的启动、输出和失败由适配层注入，不证明操作系统执行被哈希的虚构文件。外层工具启动阻塞测试证明外层可以终止这个本机 Python 进程；不证明 AUTH-115 自身能硬中断 `Popen`，也不证明子孙进程、终止失败、Windows 以外或目标 Linux 行为。测试适配层、固定远端程序部署/启动、实际工具身份与真实 SSH 退出语义都需另门。

AUTH-107 Phase B 未放行。主机/host-key、SSH 身份、目标机程序字节/路径、真实工具/环境、DB 目标与权限仍 `UNKNOWN`。Owner 已决定只备份数据库内数据与对象，内部对象全集、一致性、加密传输与隔离恢复未证明，真实备份仍需 Owner LEVEL 3 单次授权；当前 Work 会话的“我在”只确认到场，不授权本轮 UAC 或密码输入。AUTH-17/107 旧预算不重置。

本轮未读取真实工具、`.env`、凭据、私钥、业务行、备份或旧 `D:\EliteSync`；未执行 SSH、真实 dump/DB 工具、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。临时虚构文件仅由本任务临时目录自动清理。不提交、推送、自接受或派发后继，停在 Work LEVEL 2 独立审查门。

## Work LEVEL 2 独立审查（2026-09-26）

**ACCEPT，仅限测试注入下 AUTH-115 原源码在本机独立 Python 进程的输出和退出传播。** Work 核对本地 `main` HEAD `03b2efd8678df69423697939170b73991946eda1`、工作区差异、`test_adapter.py` 与 `test_process.py`，候选仅新增本证据目录。Work 核对 AUTH-115 程序、AUTH-114 依赖及 AUTH-113 解析器固定哈希仍与回执匹配；新适配脚本 SHA-256 `7B8A4801B6E5BE2CDF712FFEE1881D67D452495AA2FECA7094942748E215638F`、测试 SHA-256 `697C8A1D05409D6D1C236B95F9ED264D3DD620F1F06EBAD86D14FB210CF65E07` 匹配候选声明。Work 独立运行最终候选 `python -B EVIDENCE/AUTH-116-PROBE-PROCESS-EXIT-SYNTHETIC-ISOLATION/test_process.py`，退出 0、`SYNTHETIC_CHECKS_PASS=6`；`git diff --check` 通过。作者套件 1/3、静态检查 1/2，Work 复跑另记。

测试观察到独立本机进程成功退出 0、单行安全 JSON，四个失败用例退出 1 且无输出；外层超时可终止启动阻塞用例。工具启动由测试适配层注入，**被核验的虚构文件未被操作系统执行**；外层把本机进程退出值送入 AUTH-113 只是格式测试，不能宣称 SSH 退出实测。AUTH-115 自身无法硬中断 Popen 启动，子孙进程、终止失败、目标 Linux、固定远端程序部署和真实工具身份仍 UNKNOWN。AUTH-107 Phase B、SSH、真实 DB 和备份继续未放行。
