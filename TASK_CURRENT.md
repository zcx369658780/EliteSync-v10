# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-116-PROBE-PROCESS-EXIT-SYNTHETIC-ISOLATION

Risk Level: LEVEL 2（远端受控程序候选的独立进程 stdout/退出传播；本轮仅本机虚构工具）

Status: ACCEPTED — LOCAL SYNTHETIC PROCESS ONLY; NO SSH OR REAL TOOL

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-115 获 Work LEVEL 2 受限 ACCEPT 的是本机测试适配层下 `probe_program.main()` 返回值与内存 sink 输出；没有验证独立程序进程的 stdout/退出传播。未来 SSH 协议依赖“成功单行 JSON + 程序退出 0，失败无原文 + 非零退出”。本任务仅对**同一 AUTH-115 程序源码哈希固定的候选**做独立本机进程级虚构验证，不部署、不连接服务器或真实工具。

主要结果为新目录 `EVIDENCE/AUTH-116-PROBE-PROCESS-EXIT-SYNTHETIC-ISOLATION/summary.md`，可附测试适配脚本和测试。仅允许写此新目录；AUTH-115 和其他旧证据/控制文件只读，保留两个无关未跟踪目录。

## 允许工作与预算

1. 核对本地 Git/工作区、五份入口、AUTH-112～115、项目技能与风险门；固定核对 AUTH-115 程序及 AUTH-114 依赖哈希。不得读 `.env`、凭据、私钥、真实业务行、备份、真实工具文件或旧 `D:\EliteSync`。
2. 用任务临时目录里的虚构文件、虚构 Python 工具子进程以及单独启动的本机 Python 进程运行 AUTH-115 `main()`。可用临时测试适配脚本或受控注入让程序调用虚构工具，但必须明确这不等于操作系统执行被核验工具文件；不能改 AUTH-115 已接受字节。捕获**程序进程本身** stdout/stderr 和真实退出码，逐流限 2 KiB、总时限及终止回收有界；通过 AUTH-113 单退出解析器验证成功单行 JSON 与 0，失败/超限/超时/非零/秘密标记不得成为成功，原始内容不入普通回执。测试脚本不得启动 `ssh.exe`、真实 dump 或其他生产工具。
3. 验证正常、第一/第二次失败、程序 stdout 写入异常或失败返回、程序本身超时/终止、秘密标记不泄漏；区分脚本适配层模拟与未验证的真实目标 Linux 行为。最多 3 轮本任务套件，仅实际失败修复可重跑；最多 2 轮静态检查。若无法做到独立进程且不接触真实工具，交 `NOT_VERIFIED`，不得夸大为 PASS。
4. 禁止 SSH、真实工具/DB、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。临时目录自动清理仅限本任务生成的虚构文件。交候选后停在 Work LEVEL 2 审查；不提交、推送、自接受或派发后继。

## 停点

本任务即使通过也不放行 AUTH-107 Phase B。主机/host-key、SSH 身份、远端程序在目标机的固定路径/字节/启动方式、真实工具身份/环境、Popen 启动阻塞与 Linux 行为仍需独立风险门。Owner 已决定只备份数据库，内部对象全集、目标/权限、一致性、加密传输和隔离恢复仍 UNKNOWN，真实备份须 Owner LEVEL 3 单次授权。Owner 在当前 Work 会话回复“我在”仅为到场条件，不代替具体 UAC/密码授权。AUTH-17/107 旧预算不重置，AUTH-99 禁止运行。

Work 已在 `EVIDENCE/AUTH-116-PROBE-PROCESS-EXIT-SYNTHETIC-ISOLATION/summary.md` 作 LEVEL 2 受限 ACCEPT：仅测试注入下本机独立 Python 进程的输出和退出传播，Work 独立复跑 6 项通过。本任务不再处于 ISSUED，不放行现场 SSH 或真实工具。
