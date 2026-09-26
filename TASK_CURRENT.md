# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-122-LOCAL-KNOWN-HOST-FORMAT-DIAGNOSIS

Risk Level: LEVEL 2（本机 SSH 历史信任记录受限诊断；Phase A 仅虚构候选）

Status: REJECTED — PHASE B OUTPUT_INVALID; ONE LOCAL READ EXHAUSTED

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-121 单次真实本机读取返回 `REJECTED / FORMAT_INVALID`，无指纹候选，1/1 预算已耗尽；具体原因未保存，也不得猜测。Owner 明确选择另立**本机格式诊断**任务。先做可审查的纯虚构诊断器，将第一处拒绝归为固定结构类别；Phase A 不再读取真实文件。任何后续真实读取都须 Work 独立裁决和新预算，不作为 AUTH-121 重试。

主要结果为 `EVIDENCE/AUTH-122-LOCAL-KNOWN-HOST-FORMAT-DIAGNOSIS/plan.md`；Phase A 可在同一新目录新增诊断纯函数、固定只读入口候选与虚构测试。只允许写该目录；其他项目文件与证据只读，保留两个无关未跟踪目录。

## Phase A 允许工作与预算

1. 核对本地 Git/工作区、五份入口、项目技能、AUTH-02、AUTH-120/121 已接受或受限失败证据。固定未来目标仅为 `C:\Users\zcxve\.ssh\known_hosts` 和已接受主机字面量 `101.133.161.203`；有效 SSH 端口 `UNKNOWN`。不得搜索/枚举其他 SSH 文件、主机、端口或路径。
2. 在**虚构字节**下，设计并验证对 AUTH-120 `FORMAT_INVALID` 的有限诊断：最多 65,536 bytes、256 行、单行 2,048 bytes；仅输出固定错误阶段/类别、**首个异常前**是否曾见可解析的固定目标候选、有限已检查条目计数（封顶），不输出行号、主机名、原始行、公钥 blob、指纹、盐、哈希、文件路径、异常或其他主机信息。第一处异常即停止分类，不尝试修复、跳过或放宽原解析器。不得把“格式原因”升级为可信 host-key 或目标匹配证明。
3. 如需未来一次真实读取入口，须复用 AUTH-121 的精确文件与依赖身份门或说明等价控制，确保只打开/读取一次并在内存中诊断；Phase A 仅做静态与虚构入口测试，**不得运行真实入口或读取真实 `known_hosts` 正文**。作者纯虚构测试最多 3 轮，静态检查最多 2 轮。记录 SHA-256、预算、负向用例及并发余量，停在 Work LEVEL 2 审查。
4. 禁止 SSH、阿里云控制台/Cloud Assistant、远端命令、真实工具/DB、生产 API、Laravel CLI、Docker、OpenSSL、UAC、密码输入、部署、备份、导出、传输、停写、DDL/DML、删除、提交或推送。AUTH-17/101/107/121 等旧预算不重置，AUTH-99 禁止运行。

## 停点

本任务真实本机读取 Phase B 预算目前 **0/1 未放行**。Work 在 Phase A 候选通过独立审查后，另作精确入口、哈希、目标身份、输出与单次预算的临运行裁决；失败即停，不重试。即使诊断得到结构类别，也不放行 SSH、AUTH-107 Phase B、阿里云控制台、DB 或真实备份。Owner 当前“我在”只满足到场条件。

Work 已在 `EVIDENCE/AUTH-122-LOCAL-KNOWN-HOST-FORMAT-DIAGNOSIS/plan.md` 记录 Phase A LEVEL 2 受限 ACCEPT 与 Phase B 临运行裁决。该裁决曾仅允许固定解释器 `C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe` 以 `-I -B` 单次执行该目录 `local_format_entry.py`；固定哈希、目标元数据及输出边界见裁决。**该一次预算已用完，此段不再是现行执行授权。** AUTH-121 的旧 1/1 也不重置。

Work LEVEL 2 Phase B **REJECT（诊断目标）**：入口单次退出 0、stderr 空，但本地接收层 `OUTPUT_INVALID`，阶段/类别/计数均 `UNKNOWN`；AUTH-122 真实读取 1/1 已耗尽，不能重试。Work 在不读取真实文件的情况下确认接收命令将 `ConvertFrom-Json` 的 `Int64` 误拒为非 `[int]`，见同目录 `plan.md`；此缺陷不能证明当次原始输出或文件格式。Phase A 虚构候选接受范围保持不变；SSH、阿里云控制台、AUTH-107 Phase B、DB 与备份均未放行。
