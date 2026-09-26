# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-123-LOCAL-FORMAT-RECEIVER-SYNTHETIC-REPAIR

Risk Level: LEVEL 2（本机历史信任记录诊断接收层；本轮仅虚构修复）

Status: ACCEPTED — PHASE A SYNTHETIC RECEIVER ONLY; PHASE B NOT RELEASED

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-122 单次真实入口退出 0、stderr 空，但外层脱敏接收 `OUTPUT_INVALID`，未取得阶段/类别；其 1/1 预算已耗尽。Work 静态审查及虚构 JSON 证明旧接收命令把 `ConvertFrom-Json` 的 `System.Int64` 错误限定为 PowerShell `[int]`。Owner 已选择继续完成本机格式诊断；先修复并**独立验证接收层**，不读取真实 `known_hosts` 或重跑 AUTH-122。

主要结果为 `EVIDENCE/AUTH-123-LOCAL-FORMAT-RECEIVER-SYNTHETIC-REPAIR/summary.md`；可在同一新目录新增固定 PowerShell 接收核心、未来固定启动入口候选及纯虚构测试。只允许写该目录；其余项目文件与证据只读，保留两个无关未跟踪目录。

## Phase A 允许工作与预算

1. 核对 Git/工作区、五份入口、项目技能、AUTH-120～122 精确证据和旧接收命令。固定未来 Python 入口仅为 `EVIDENCE/AUTH-122-LOCAL-KNOWN-HOST-FORMAT-DIAGNOSIS/local_format_entry.py`，其 SHA-256 `896EA25307601D4416F41219076800020526B96BC19D56338C09F60D14E3E928`。不得读取真实 `C:\Users\zcxve\.ssh\known_hosts` 正文。
2. 修复外层接收协议：严格限制 stdout/stderr 字节或字符、总等待与回收、单行 JSON、唯一且精确的六字段、固定阶段/类别、`checked_entries` 的整数类型与 0～256 上限、前置关系和进程退出关系；PowerShell `Int64` 的有效 JSON 数字必须被接受，布尔、字符串、浮点和超限数字必须拒绝。Work 以纯虚构发射器确认固定 Windows Python 文本 stdout 末尾为单个 CRLF（末尾码点 13、10），故单行 JSON 仅允许单个末尾 LF 或单个末尾 CRLF；其他 CR、多行、重复结尾仍须拒绝。普通结果仅固定阶段/类别、封顶计数、异常前候选标志、`UNKNOWN` 端口/信任与退出码；任一失败不输出原始 stdout/stderr、异常、其他主机或路径。
3. 纯虚构测试必须覆盖真实 PowerShell JSON 解析后的 `Int64`、负数/257、非法类型、额外/重复/缺失字段、非零退出/空 stderr 矛盾、stderr、超限/超时、LF/CRLF 正常结尾及其他 CR/多行拒绝、固定输出投影。可启动**仅本机虚构发射器**验证进程级接收，但不得启动真实 AUTH-122 入口或读取任何真实 SSH 文件。作者虚构测试 3/3、静态检查 2/2 均已耗尽；本次修订不得重置或补跑作者预算，由 Work 独立复核最终候选。记录最终文件哈希、预算和未证明项；停 Work LEVEL 2 审查。
4. 禁止 SSH、阿里云控制台、远端命令、真实工具/DB、生产 API、Laravel CLI、Docker、OpenSSL、UAC、密码输入、部署、备份、导出、传输、停写、DDL/DML、删除、提交或推送。AUTH-121/122 的两次真实读取预算均已耗尽、不重置；AUTH-17/101/107 旧预算不重置，AUTH-99 禁止运行。

## 停点

AUTH-123 真实本机读取 Phase B 预算目前 **0/1 未放行**。只有 Work 独立接受最终接收层、固定启动字节和虚构进程级输出后，才可另作一次本机只读诊断的临运行裁决。失败即停，不重试。即使诊断成功，独立服务器 host-key 来源、有效 SSH 端口、AUTH-107 Phase B、DB 和真实备份仍未建立。Owner 当前“我在”只满足到场条件。

Work LEVEL 2 已在 `EVIDENCE/AUTH-123-LOCAL-FORMAT-RECEIVER-SYNTHETIC-REPAIR/work-review.md` 独立 **ACCEPT 仅 Phase A 虚构接收层候选**：最终虚构套件 50 项 PASS；固定启动候选未运行，进程启动阻塞与全部子孙进程回收未证明。上述 Phase B 0/1 仍未放行；下一步仅临运行风险复核，不从本次接受推导真实读取许可。
