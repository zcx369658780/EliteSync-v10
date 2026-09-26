# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-109-BOUNDED-CAPTURE-SAFE-PROJECTION-SYNTHETIC

Risk Level: LEVEL 2（未来主机工具只读回执的原文隔离与投影；本轮仅本地虚构子进程）

Status: ACCEPTED — LOCAL SYNTHETIC INTEGRATION ONLY; NO SSH OR REAL TOOL

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-108 获 Work LEVEL 2 受限 ACCEPT 的双流采集核心只返回安全计数和类别，故不能把受限原始字节传给 AUTH-107 的纯函数投影器；AUTH-107 的投影器完整测试仍 NOT_VERIFIED。继续准备未来只读主机工具观察时，必须在**同一个受控进程内**完成有限捕获和固定安全投影，绝不经普通回执、文件、日志或调用方返回值传递原始帮助文本。本轮只使用虚构子进程，不访问主机。

主要结果为新目录 `EVIDENCE/AUTH-109-BOUNDED-CAPTURE-SAFE-PROJECTION-SYNTHETIC/summary.md`，可在该目录附候选源码和测试。仅允许写此新证据目录；AUTH-107/108 等已接受证据只读，保留两个既有无关未跟踪目录。

## 允许工作与验证预算

1. 核对本地 Git、入口、AUTH-105～108、项目技能与风险门。不得读取 `.env`、凭据、私钥、真实业务行、备份或旧 `D:\EliteSync`。
2. 设计并实现仅接收调用方显式给出的绝对可执行路径、固定参数数组与已锁定预期工具身份候选的本地集成函数。它最多执行两个子进程，每次把 `--no-defaults` 放在工具首参数，之后仅为 `--version` 或 `--help`。不发现真实工具、不执行 shell、不读环境默认值；原始 stdout/stderr 在受控内存逐流限额，只有全部退出/完整性门通过后才在同进程内做固定版本/帮助状态投影。普通返回值仅固定安全字段，不含原始文本、错误、路径或秘密；任何异常也不回显原文。
3. 对帮助文本格式未知保持 `UNKNOWN`；不得复用 AUTH-106 人为格式来宣称目标工具支持。对版本文本也只作“给定文本的版本候选”，不能证明工具来源。明确源路径/符号链接/哈希实际绑定、SSH/host-key、环境净化、真实帮助兼容性仍需未来独立门。若复用 AUTH-107 投影逻辑，必须独立修复/验证其未通过的分支，且不能改写 AUTH-107 旧预算与接受结论。
4. 用临时虚构子进程测试：两次固定参数顺序、版本/帮助正常与不匹配、两流突发、非零/stderr/超时/超限、原文秘密标记不泄漏、第二次失败不产生第一次的部分肯定结果、子进程终止。最多 3 轮本任务虚构套件，重跑仅用于实际失败修复；最多 2 轮静态检查。记录每轮和所有未覆盖的系统/终止风险。不得运行真实 dump 工具。
5. 禁止 SSH、生产 HTTP/API、Laravel CLI、真实 DB、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。交候选后停在 Work LEVEL 2 审查；不提交、推送、自接受或派发后继。

## 停点

即使本地虚构候选通过，AUTH-107 Phase B 仍不自动放行。未来单次现场只读工具观察须另锁定目标、SSH 身份/host-key、工具绝对路径/别名/哈希、采集程序固定字节与隐私门，并经 Work 独立审查；真实备份另需全部前置门与 Owner LEVEL 3 单次授权。可能触发 UAC 的后继步骤须在触发前停下，直到 Owner 在当前 Work 会话输入“我在”，且仍须具体任务授权。AUTH-101、AUTH-17、AUTH-107 的已耗预算不重置，AUTH-99 禁止运行。

Work 已在 `EVIDENCE/AUTH-109-BOUNDED-CAPTURE-SAFE-PROJECTION-SYNTHETIC/summary.md` 作 LEVEL 2 受限 ACCEPT：仅本地虚构子进程的有界采集与安全投影，Work 独立复跑 12 项通过。真实工具、SSH、DB、备份及 UAC 均未获放行。本任务不再处于 ISSUED。
