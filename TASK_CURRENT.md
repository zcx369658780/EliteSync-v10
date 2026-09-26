# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-115-REMOTE-READONLY-PROBE-PROGRAM-SYNTHETIC-CANDIDATE

Risk Level: LEVEL 2（未来主机只读工具观察的远端受控程序；本轮仅本地虚构子进程候选）

Status: ACCEPTED — LOCAL SYNTHETIC PHASE A ONLY; NO SSH OR REAL TOOL

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-109 已接受本地虚构进程内有限工具输出投影；AUTH-112/113 已接受未来远端程序单行安全 JSON 与单个 SSH 退出的协议边界；AUTH-114 只接受虚构普通文件的字节身份候选，符号链接用例 NOT_TESTED。尚无可审查的**独立远端程序候选**能把两次工具退出、原文隔离、安全投影和自身退出连成一个固定来源。此任务只准备 Phase A 候选和本机虚构验证，不部署、不连接主机。

主要结果为新目录 `EVIDENCE/AUTH-115-REMOTE-READONLY-PROBE-PROGRAM-SYNTHETIC-CANDIDATE/summary.md`，可附候选源码、测试和固定哈希回执。仅允许写此新目录；AUTH-107～114、控制文件只读；保留两个无关未跟踪目录。

## 允许工作与验证预算

1. 核对本地 Git/工作区、五份入口、AUTH-105/107/109/112～114、项目技能与风险门。不得读 `.env`、凭据、私钥、真实业务行、备份、真实工具文件或旧 `D:\EliteSync`。
2. 提供独立程序候选：调用方显式给出绝对虚构可执行路径、预期文件名/哈希候选及固定时间/字节限额；拒绝相对/重解析路径和不匹配的虚构文件。最多两次不经 shell 的参数数组调用，工具首参数 `--no-defaults`，其后仅 `--version` 或 `--help`。两流同时排空、逐流限额，超限/超时/非零/stderr/捕获不完整即杀死并等待或固定失败；失败不得输出原文、路径、异常或部分肯定。成功才输出与 AUTH-113 相容的一行 LF 终止 UTF-8 JSON，总计最多 2 KiB，固定九项全 `UNKNOWN`、两个真实工具退出值均为 0、版本仅文本候选；程序自身成功退出 0，失败为固定非零。不可为了兼容未知真实帮助格式而宽松猜测。可复用已接受候选，但新程序须自洽且明确依赖固定字节。
3. 仅用本机临时虚构工具子进程检验参数顺序、两次调用、正常一行、第一/第二次失败、双流突发/超限、超时与终止、stderr、版本/帮助不匹配、原文秘密标记不泄漏、程序成功/失败退出关系。最多 3 轮本任务套件，重跑只用于实际失败修复；最多 2 轮静态检查。记录 Popen 启动阻塞、子孙进程、符号链接/替换竞争、Windows 与目标 Linux 差异等未验证风险，不能写成可现场运行。
4. 禁止 SSH、真实 dump/DB 工具、真实数据库、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。交候选后停在 Work LEVEL 2 审查；不提交、推送、自接受或派发后继。

## 停点

Phase A 通过也不放行 AUTH-107 Phase B。现场前还须独立锁定主机/host-key、SSH 身份、远端程序在目标机的准确字节/路径和启动方式、工具身份与环境净化，并复核本地单 SSH 退出接收器；旧 AUTH-17/107 预算不重置。Owner 已决定本次只备份数据库，内部对象全集、目标/权限、一致性、加密传输及隔离恢复仍 UNKNOWN，真实备份须 Owner LEVEL 3 单次授权。Owner 已在**当前 Work 会话**回复“我在”；这只满足到场条件，不代替具体 UAC 风险门或密码输入授权。AUTH-99 禁止运行。

Work 已在 `EVIDENCE/AUTH-115-REMOTE-READONLY-PROBE-PROGRAM-SYNTHETIC-CANDIDATE/summary.md` 作 LEVEL 2 受限 ACCEPT：仅本机虚构 Phase A 候选，Work 独立复跑 13 项通过。本任务不再处于 ISSUED，不能据此现场部署或执行。
