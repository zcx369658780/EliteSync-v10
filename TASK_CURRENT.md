# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-107-DUMP-TOOL-READONLY-PROBE-CANDIDATE

Risk Level: LEVEL 2（生产主机工具身份与选项的未来只读观察；本轮仅本地候选）

Status: ACCEPTED — PHASE A STATIC BOUNDARY ONLY; PROJECTOR NOT VERIFIED; PHASE B NOT RELEASED

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-105 接受 MariaDB 官方资料的静态选项语义；AUTH-106 仅接受虚构帮助文本的严格解析拒绝边界。AUTH-106 的人工布局未证明与目标主机实际 `--help` 一致，不能直接当现场工具能力 PASS。AUTH-17 的 `mysqldump 10.11.14` 是旧一次主机观察且预算耗尽。本任务为将来**单次只读 SSH 工具观察**形成具体可审查候选，当前不连接主机。

主要结果为 `EVIDENCE/AUTH-107-DUMP-TOOL-READONLY-PROBE-CANDIDATE/plan.md`；可在同一新目录附固定调用器、只读远端片段及纯虚构负向测试。仅允许写该新证据目录，其他项目文件/证据只读；保留两个既有无关未跟踪目录。

## Phase A 工作范围与预算

1. 核对本地 Git、入口、AUTH-17/105/106、既有受限 SSH 模式和风险门。只读使用本地已经接受的 SSH 目标身份/host-key 约束作为设计输入，不输出主机名、用户名、私钥路径/正文、连接串、对象名或原始错误；不得访问旧 `D:\EliteSync`。
2. 设计一次性、固定目标的未来 SSH 只读工具观察：只检查 `mysqldump`/`mariadb-dump` 可执行文件身份、版本和**关闭默认选项文件读取后的**帮助选项文本，不连接 DB，不列库/表、不读取环境或配置值。严格限制进程、远端命令、超时、stdout/stderr 字节、认证方式和 host-key；不可把 AUTH-17 的 SSH 预算复用。若 `--no-defaults` 的位置/语义与目标工具版本不确定，先保留 UNKNOWN，不临场猜测或读取可能含敏感默认值的帮助输出。
3. 候选必须在受控进程内从原始帮助内容只投影固定安全字段，并解决 AUTH-106 虚构布局不适用的问题：要么给出可证明不误判的有限解析方案及纯虚构负向测试，要么明确只取得版本/帮助摘要而将选项支持保持 UNKNOWN。不得把帮助文本中选项名出现等同为运行支持或默认值证明。
4. 明确可能的工具别名/符号链接、帮助输出变化、stderr 提示、非零退出、管道退出码丢失、截断、重复行和 ANSI 控制字符的停点。普通证据只记录固定类别、版本候选、工具哈希或安全摘要、调用/字节计数与 UNKNOWN/PASS/FAIL；不保存或转发原始 stdout/stderr。任何真实执行前还须 Work 对固定脚本字节/哈希、主机/密钥/host-key、预算与并发风险独立审查。
5. 本轮最多一轮纯虚构测试套件和一次静态检查；不得执行 SSH、生产 HTTP/API、Laravel CLI、真实 DB、Docker、云控制台、OpenSSL、UAC、部署、真实 dump 工具、备份、导出、传输、停写、DDL/DML 或删除。只交候选后停在 Work LEVEL 2 审查，不提交、推送、自接受或派发后继。

## 停点

Phase A 接受不放行 SSH 或任何真实工具调用。未来单次现场只读观察须另由 Work 发布明确 Phase B 任务并过风险门；真实备份须目标、权限、范围、一致性、加密传输和隔离恢复准备成立后另由 Owner LEVEL 3 单次授权。若任何步骤可能触发 UAC，必须在触发前停下，待 Owner 在当前 Work 会话输入“我在”，且仍须具体任务授权。AUTH-101 各一次预算已耗尽，旧 AUTH-99 禁止运行。

Work 已在 `EVIDENCE/AUTH-107-DUMP-TOOL-READONLY-PROBE-CANDIDATE/plan.md` 作 LEVEL 2 **受限 ACCEPT 仅 Phase A 静态边界**。`projector.py` 的完整虚构测试未通过且修正后未复跑；无可运行 SSH/远端受限采集程序，Phase B 不放行。本任务状态已非 ISSUED，不得自动执行。当前 Work 会话达到交接长度，交接只保存进度，不下达后继；下一 Work 会话应先核对本地状态，再决定新的独立实现/虚构验证任务。
