# AUTH-115｜远端受控只读探针程序 Phase A 虚构候选

**作者候选，待 Work LEVEL 2 独立审查。** 2026-09-26；本地 `D:\EliteSync-v10`、`main`，启动 HEAD `3de0b32789ef98e2149f7d876ca17849fb1eac62`。仅新增本目录的 `probe_program.py`、`test_probe_program.py` 和本回执；AUTH-107～114、Work 控制文件只读，两个无关未跟踪目录保留。**本轮没有部署或现场运行授权。**

## 固定候选与依赖

| 文件 | SHA-256（本轮最终字节） |
| --- | --- |
| `probe_program.py` | `88B8BDE3E61A47A1E6B50A5B947619A29E9CF465D987512205DC818BD5E259B6` |
| `test_probe_program.py` | `B4F69CF8CD5FF715E51A07B1AA96ECA05602DCE646E2E02AFAF1B13A8288FC11` |

程序要求调用方显式提供绝对**虚构**工具路径、精确允许文件名、小写预期 SHA-256、文件大小上限、总时间上限和 `mysqldump`/`mariadb-dump` 文本标签。它在新目录内按固定 SHA-256 `D4D8CBA362362892FD55791BAE8955DD12490D893E7C998D22E66FE7CC1C9C18` 只读加载 AUTH-114 的文件身份函数；若来源变化、路径为相对/重解析点、名称/字节哈希不匹配或文件不合上限，直接失败，不启动工具。AUTH-114 的符号链接运行用例仍 `NOT_TESTED`；当次文件字节匹配不证明随后执行的进程来自同一文件。

身份门通过后，程序最多顺序启动两次无 shell 的参数数组，工具首参数固定 `--no-defaults`，之后仅 `--version` 或 `--help`。stdin 关闭，环境为空；每次 stdout/stderr 同时排空，版本 stdout 最多 256 bytes、帮助 stdout 最多 24,576 bytes、各 stderr 最多 256 bytes。总执行期限由调用方明确传入且最多 10 秒；超限/超时杀死并等待子进程，回收另给最多 2 秒。第一次失败不调用第二次；任一次非零、stderr 非空、捕获不完整或文本校验不合均返回固定失败，无 stdout。`Popen` 启动自身阻塞不能由当前结构硬中断，不能将参数上限误称完整墙钟硬上限。

仅在两次进程都完整退出 0 后，程序检查严格 UTF-8、终止换行、控制字符、有限 10.11 版本 banner 与帮助首行的一致性；不按 AUTH-106 人为布局推断选项支持。成功才写出一行 LF 终止、最多 2 KiB 的固定 JSON，并返回程序状态 0；失败 `main()` 返回 1，且不输出原始字节、路径、异常或部分肯定。JSON 与 AUTH-113 九字段相容：两个**程序内看到的虚构工具退出值**为 `[0,0]`，九个选项全为 `UNKNOWN`，版本仅给定文本候选，身份状态为 `CALLER_CANDIDATE_UNVERIFIED`。该 JSON/程序返回的关系还不是实际 SSH 进程与目标远端程序的运行证明。

## 本轮验证

| 检查 | 用量与结果 |
| --- | --- |
| 临时虚构工具套件 | **2/3 轮**。第 1 轮退出 0、`SYNTHETIC_CHECKS_PASS=12`；随后静态复核发现 DEL/C1 控制字符拒绝不完整，修复并加用例。第 2 轮退出 0、`SYNTHETIC_CHECKS_PASS=13`。覆盖固定参数顺序/两次调用、正常单行并由 AUTH-113 解析、第一/第二次失败、stderr、双流突发/超限、超时终止、版本/帮助不匹配、控制字符、错误文件哈希/名称/时间输入及秘密标记不回显。 |
| 静态检查 | **1/2 轮**，两个 Python 文件 AST 可解析，尾随空白 0 行；上表为最终文件 SHA-256。 |

测试适配层拦截并核对 `Popen` 对虚构文件路径的参数，再直接启动临时 Python 子进程提供合成 stdout/stderr；不会执行该虚构文件。因此验证的是候选构造的调用、采集、投影和 `main()` 的 0/1 返回，**未证明操作系统层实际执行该文件或程序自身在独立进程中的退出传播**。符号链接/重解析点、文件核验后替换、`Popen` 启动阻塞、终止失败、子孙进程继承管道、Windows 与目标 Linux 差异、真实帮助格式、真实工具路径/别名/哈希及环境净化仍 `UNKNOWN`。

Owner 当前在 Work 会话回复“我在”只满足到场条件；本任务没有 SSH、UAC、密码输入或目标主机授权。AUTH-107 Phase B 未放行，未来还须独立锁定主机/host-key、SSH 身份、远端程序在目标机的准确字节/路径和启动方式、工具实际身份、环境与本地单退出接收器。真实备份仅以数据库内数据和对象为目标，但内部对象全集、目标/权限、一致性、加密传输与隔离恢复仍 `UNKNOWN`，须 Owner LEVEL 3 单次授权。AUTH-17/107 已耗预算不重置。

本轮未读取真实工具、`.env`、凭据、私钥、真实业务行、备份或旧 `D:\EliteSync`；未连接 SSH/DB、运行真实 dump 工具、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。不提交、推送、自接受或派发后继，停在 Work LEVEL 2 独立审查门。

## Work LEVEL 2 独立审查（2026-09-26）

**ACCEPT，仅限本机临时虚构工具子进程的 Phase A 受控程序候选。** Work 核对本地 `main` HEAD `3de0b32789ef98e2149f7d876ca17849fb1eac62`、工作区差异、`probe_program.py` 与 `test_probe_program.py`，候选仅新增本证据目录。Work 独立核对最终程序 SHA-256 `88B8BDE3E61A47A1E6B50A5B947619A29E9CF465D987512205DC818BD5E259B6`、测试 SHA-256 `B4F69CF8CD5FF715E51A07B1AA96ECA05602DCE646E2E02AFAF1B13A8288FC11` 与依赖 AUTH-114 文件 SHA-256 `D4D8CBA362362892FD55791BAE8955DD12490D893E7C998D22E66FE7CC1C9C18`，均匹配候选声明。Work 对最终版本独立运行 `python -B EVIDENCE/AUTH-115-REMOTE-READONLY-PROBE-PROGRAM-SYNTHETIC-CANDIDATE/test_probe_program.py`，退出 0、`SYNTHETIC_CHECKS_PASS=13`；`git diff --check` 通过。作者套件 2/3、静态检查 1/2，Work 独立复跑另记。

本接受只证明候选在本机测试适配层下构造固定两次参数、有限捕获并于成功时生成安全单行 JSON，失败分支未向测试 sink 写原文。虚构文件并未作为操作系统可执行文件启动；独立程序进程退出传播、`Popen` 启动阻塞、符号链接/替换竞争、子孙进程、终止失败、目标 Linux 行为及真实工具帮助格式仍 `UNKNOWN`。代码虽有可调用入口，**没有现场部署或执行授权**。AUTH-107 Phase B、SSH、真实工具/DB 和备份均未放行；下一步须先补固定部署/调用身份和独立进程级虚构负向验证，再审查一次现场只读任务。
