# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-113-SINGLE-SSH-EXIT-PROTOCOL-PARSER-SYNTHETIC

Risk Level: LEVEL 2（未来只读 SSH 回执的退出语义与安全投影接口；本轮仅纯虚构字节）

Status: ACCEPTED — LOCAL SYNTHETIC PARSER ONLY; NO SSH OR REAL TOOL

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-112 获 Work LEVEL 2 受限 ACCEPT：官方 `ssh(1)` 只给本地 SSH 进程一个退出值，远端命令退出按协议反映在这个值中；255 有歧义且一律失败。AUTH-110/111 的两个调用方退出输入不能变成两个独立实测量。本任务在新目录实现**纯函数新版本**，只用调用方提供的虚构 stdout/stderr、完整性与一个 SSH 退出候选；不修改已接受的 AUTH-110/111 文件，也不启动 SSH 或子进程。

主要结果为新目录 `EVIDENCE/AUTH-113-SINGLE-SSH-EXIT-PROTOCOL-PARSER-SYNTHETIC/summary.md`，可附解析器及测试。仅允许写此新目录；其他证据和控制文件只读，保留两处原有无关未跟踪目录。

## 允许工作与预算

1. 核对本地 Git/工作区、五份入口、AUTH-107～112、项目技能与风险门。不得读 `.env`、凭据、私钥、真实业务行、备份或旧 `D:\EliteSync`。
2. 从 AUTH-110 固定 JSON 拒绝边界构造纯函数新接口：只接收一个 SSH 退出数值，绝不接受或自动补出“独立远端退出码”。两流各最多 2 KiB，完整性、stderr、严格单行 UTF-8、重复/额外键、类型和内部关系均失败即停。SSH 255、其他非零或未知退出一律无肯定投影；SSH 0 但 JSON 报失败、工具 `exit_codes` 非零/缺失或状态矛盾也失败。成功普通返回须固定标明 `PROTOCOL_CONSISTENT_TEXT_CANDIDATE`、`SSH_EXIT_OBSERVED_CANDIDATE` 与远端程序/工具状态只是 `UNVERIFIED_PROTOCOL_DECLARATION`；不宣称主机、程序、工具身份或备份能力。错误与异常不得回显原文、路径或输入。
3. 用纯虚构字节测试正常、SSH 255/非零/未知、成功 JSON 与非零退出矛盾、SSH 0 但 JSON 失败、工具退出声明矛盾、两流超限/不完整/stderr、重复键/多行/控制字符/非法 UTF-8/秘密标记不泄漏。最多 3 轮本任务套件，仅为实际失败修复可重跑；最多 2 轮静态检查。说明一个 SSH 数值与 JSON 声明不能证明真实远端程序执行。
4. 禁止启动任何子进程、SSH、真实工具/DB、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。交候选后停在 Work LEVEL 2 审查；不提交、推送、自接受或派发后继。

## 停点

AUTH-107 Phase B 未放行；AUTH-101、AUTH-17、AUTH-107 既有预算不重置，AUTH-99 禁止运行。Owner 已决定本次只备份数据库，不含数据库外文件；内部对象全集仍 UNKNOWN。真实备份还需目标、权限、一致性、加密传输和隔离恢复门及 Owner LEVEL 3 单次授权。可能触发 UAC 的后继步骤须先等 Owner 在**当前 Work 会话**输入“我在”；旧到场确认不沿用。

Work 已在 `EVIDENCE/AUTH-113-SINGLE-SSH-EXIT-PROTOCOL-PARSER-SYNTHETIC/summary.md` 作 LEVEL 2 受限 ACCEPT：仅纯虚构字节的单 SSH 退出解析，Work 独立复跑 34 项通过。本任务不再处于 ISSUED，不能据此启动现场调用。
