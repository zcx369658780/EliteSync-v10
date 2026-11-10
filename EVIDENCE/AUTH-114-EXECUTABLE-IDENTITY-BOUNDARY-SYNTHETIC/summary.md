# AUTH-114｜文件身份边界虚构候选

**作者候选，待 Work LEVEL 2 独立审查。** 2026-09-26；本地 `D:\EliteSync-v10`、`main`，启动 HEAD `15c00431c72a576a2696486cd00b7c162cb81cda`。仅新增本目录的 `file_identity.py`、`test_file_identity.py` 与本回执；AUTH-107/109/111～113、控制文件只读，两个无关未跟踪目录保留。

## 候选行为与界限

`inspect_file_identity()` 只接受调用方给出的绝对规范路径、精确允许文件名、小写 64 位 SHA-256 预期值和单次大小上限（最高 16 MiB）。它检查每层父路径及目标的 `lstat`，对符号链接或 Windows 重解析点、目录/非普通文件、空文件、超限文件、名称不符和读取失败固定拒绝。目标通过后以最多 64 KiB 分块读取；POSIX 可用时附加 `O_NOFOLLOW`，并对打开前、打开句柄及读取后文件的设备号、文件号和大小做一致性比较。读中增长超过上限也拒绝。成功只返回 `FILE_BYTES_MATCH`、有限大小、哈希相等布尔值和 `FILE_BYTES_CANDIDATE_ONLY`；普通结果不含路径、文件原文、预期哈希或异常文字。

这是**核验当次可读文件字节**的候选，不能证明文件随后未被替换、执行时使用的仍是该句柄，也不能证明远端程序或工具的来源、选项和备份能力。Windows 重解析语义、不同文件系统的文件号稳定性、目录组件替换及检查与使用之间的竞争条件仍 `UNKNOWN`；未来若要绑定实际运行，须另立明确的身份、启动与风险任务。AUTH-109 的调用方 SHA-256 格式门和 AUTH-111 的固定解析器哈希不由本任务自动升级为工具执行身份。

## 验证预算

| 检查 | 用量与结果 |
| --- | --- |
| 临时虚构文件套件 | **1/3 轮**，`python -B test_file_identity.py` 退出 0，`SYNTHETIC_CHECKS_PASS=13;SYMLINK_TEST=NOT_TESTED`。覆盖正常/错误哈希、大小上下界、空文件、目录、不存在、名称/相对路径/参数错误、模拟读取失败及秘密标记和路径不回显。仅在自动清理的临时目录创建虚构文件；本环境普通权限下未能创建测试符号链接，未提权，符号链接拒绝分支未获运行验证。 |
| 静态检查 | **1/2 轮**，两个 Python 文件 AST 可解析，尾随空白 0 行。 |

未读取真实 `mysqldump`、`.env`、凭据、私钥、业务行、备份或旧 `D:\EliteSync`；未启动任何测试子进程、SSH、真实工具/DB、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。Owner 已限定本次备份为数据库内数据与对象，数据库内部对象全集及实际恢复能力仍 `UNKNOWN`。AUTH-107 Phase B、真实备份及 UAC 后继步骤未放行；AUTH-101/17/107 旧预算不重置。候选停在 Work LEVEL 2 独立审查门；不提交、推送、自接受或派发后继。

## Work LEVEL 2 独立审查（2026-09-26）

**ACCEPT，仅限本地虚构普通文件的有限字节身份候选。** Work 核对本地 `main` HEAD `15c00431c72a576a2696486cd00b7c162cb81cda`、工作区差异、`file_identity.py` 与 `test_file_identity.py`，候选仅新增本证据目录。Work 独立运行最终候选 `python -B EVIDENCE/AUTH-114-EXECUTABLE-IDENTITY-BOUNDARY-SYNTHETIC/test_file_identity.py`，退出 0，`SYNTHETIC_CHECKS_PASS=13;SYMLINK_TEST=NOT_TESTED`；`git diff --check` 通过。作者本任务套件 1/3、静态检查 1/2，Work 独立复跑另记。

代码对调用方给定的规范绝对路径、文件名、普通文件、大小及分块 SHA-256 采用固定类别，普通回执不带路径、字节或原始异常；但符号链接拒绝分支因普通权限测试条件未满足，**没有运行证明**。Windows 重解析/目录替换、核验后替换和执行进程绑定仍 `UNKNOWN`。本接受不允许把候选指向真实工具或远端程序，不证明工具来源、功能、目标 DB 或备份能力；AUTH-107 Phase B、真实 SSH 与备份继续未放行。
