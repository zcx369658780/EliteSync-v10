# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-124-SERVER-HOST-IDENTITY-AND-PORT-TRUST-PATH-STATIC

Risk Level: LEVEL 2（未来 SSH 服务器身份和有效端口的信任来源；本轮静态设计）

Status: ACCEPTED — STATIC TRUST PATH ONLY; NO CONSOLE OR SSH

Assignee: 最新合资格 Codex 执行会话 `01a0dc31-b629-76a3-85fd-f71566b03056`；Work 独立 LEVEL 2 审查。前任过长会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115` 不再派发。

## 目标与依据

AUTH-123 Phase B 已由 Work 独立接受仅单次本机格式诊断受限事实：`INPUT_CR / FORMAT_INVALID`、已检查 0 条、目标候选 `NO`、端口/信任 `UNKNOWN`，真实读取 1/1 已耗尽，见 `EVIDENCE/AUTH-123-LOCAL-FORMAT-RECEIVER-SYNTHETIC-REPAIR/work-review.md`。Owner 提到的本机“sshkey”可能是客户端身份密钥，不能当作服务器主机密钥的独立可信指纹；阿里云登录密码和真人识别只说明 Owner 可能有控制台访问能力，不自动证明服务器指纹或端口。

本任务主要结果为 `EVIDENCE/AUTH-124-SERVER-HOST-IDENTITY-AND-PORT-TRUST-PATH-STATIC/plan.md`。只允许在该新目录写 `plan.md`；其他文件只读，保留两个无关未跟踪目录。

## Phase A 允许范围

1. 核对本地分支、HEAD、工作区、五份入口、项目技能、AUTH-02/17/107/120～123 的受限结论。只读公开阿里云/SSH 官方资料可用，但须记录精确来源、可支持的事实和不足；不得把资料泛述当作本目标主机的事实。
2. 分清客户端登录公钥/私钥、服务器 SSH host key、连接端口和阿里云账号登录凭据。设计一条 Owner 可在**独立可信控制面**核对目标实例身份、实际 SSH 服务端口和服务器 host-key 指纹的最小路径，以及 Work 能接收的脱敏回执。不得猜测端口为 22，不得从本机 `known_hosts` 的 `INPUT_CR` 类别推断可信指纹，不得把首次网络握手的指纹当独立来源。
3. 明确控制台界面本身是否提供足够的 host-key 指纹；若官方资料不能证明，写 `UNKNOWN`，并把任何通过控制台终端/云助手在实例内读取 host key 的办法列为**未来单独授权的高风险现场候选**，包括目标绑定、只读命令、无密码/密钥外泄、输出最小化、失败即停和 Owner 在场要求。不得本轮执行。端口的来源与 host-key 来源分别建门。
4. 说明在可信来源和端口都未闭合前，对 AUTH-107 Phase B、SSH、生产工具、DB 和真实备份的停止条件。静态检查最多 2 轮；不做运行测试。记录候选哈希、未证明项、下一风险门，停 Work LEVEL 2 独立审查。

## 禁止与停点

不得登录阿里云控制台、调用云助手或远端终端、SSH/HTTP 探测、枚举/读取其他 SSH 文件、重读真实 `known_hosts`、运行 AUTH-123 固定候选、运行真实 dump/DB 工具、触发 UAC/密码、部署、备份、导出、传输、停写、DDL/DML、提交或推送。AUTH-121/122/123 的真实读取各 1/1 均已耗尽，不重置；AUTH-107 Phase B 未放行，AUTH-99 禁止运行。Phase A 静态候选不授权现场控制台、SSH 或数据库。Owner 当前“我在”仅满足到场条件，不是上述现场动作授权。

Work 已在 `EVIDENCE/AUTH-124-SERVER-HOST-IDENTITY-AND-PORT-TRUST-PATH-STATIC/plan.md` 独立 LEVEL 2 **ACCEPT 仅静态信任路径**。实例身份、有效 SSH 端口、独立 host-key 指纹及控制台能否直接展示指纹均未获现场证明，继续 `UNKNOWN`。未登录控制台、无 UAC/密码、SSH/DB/备份。后继现场候选须另立任务和风险门；当前不放行。
