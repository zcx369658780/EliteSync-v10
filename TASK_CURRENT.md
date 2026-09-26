# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-111-SYNTHETIC-TRANSPORT-CAPTURE-AND-PARSER-WIRING

Risk Level: LEVEL 2（未来只读 SSH 回执的本地进程采集与解析衔接；本轮仅临时虚构子进程）

Status: ACCEPTED — LOCAL SYNTHETIC PROCESS ONLY; NO SSH OR REAL TOOL

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-109 已接受本地虚构工具的进程内投影；AUTH-110 已接受调用方给定纯虚构字节的有限解析。尚未验证一个**本地进程采集器**能在双流限额、整体超时和退出码门内把虚构单行投影接给解析器。仅用临时虚构子进程证明此衔接；不调用 `ssh.exe`、远端程序或真实工具。远端程序退出码如何从 SSH 传输中独立证明仍是设计缺口，候选须明确它与 SSH 退出码不可简单视为两个独立实测量。

主要结果为新目录 `EVIDENCE/AUTH-111-SYNTHETIC-TRANSPORT-CAPTURE-AND-PARSER-WIRING/summary.md`，可在该目录附候选和测试。仅允许写此新目录；AUTH-107～110 与控制文件只读。保留两处原有无关未跟踪目录。

## 允许工作与预算

1. 核对本地 Git/工作区、五份入口、AUTH-107～110、项目技能和风险门；不读 `.env`、凭据、私钥、真实业务行、备份或旧 `D:\EliteSync`。
2. 实现仅接受调用方显式给出的绝对**虚构子进程**路径与固定参数数组的本地适配候选：stdin 关闭、无 shell、双流并发逐流限 2 KiB、整体期限最多 30 秒，超限/超时杀死并等待。普通返回与异常不能含原始字节、环境、路径或命令。只有完整且合格的采集才调用 AUTH-110 解析器；不得默默把本地进程退出码冒充已独立证明的远端程序退出码。可通过调用方提供的纯虚构且显式标为 `UNVERIFIED` 的远端退出候选进行接线测试，最终普通结果必须保留来源未证状态。
3. 用临时生成的虚构子进程测试正常单行、双流突发、stdout/stderr 超限、stderr 非空、非零、超时及进程终止、解析失败、秘密标记不泄漏；最多 3 轮本任务套件，仅实际失败修复可重跑；最多 2 轮静态检查。说明终止失败、子孙进程继承管道、Windows/其他系统差异及真实 SSH 退出语义未证明。
4. 禁止实际启动 SSH、远端程序、dump/数据库工具或任何生产连接；禁止 UAC、Docker、云控制台、OpenSSL、备份、导出、传输、停写、DDL/DML、部署或删除。交候选后停在 Work LEVEL 2 审查，不提交、推送、自接受或派发后继。

## 停点

AUTH-107 Phase B 仍未放行。真实工具路径/别名/哈希、主机/host-key、环境净化、远端退出来源、Web/CLI DB 同一性、账号权限、对象全集、一致性、加密传输和隔离恢复均 UNKNOWN。真实备份须独立前置门及 Owner LEVEL 3 单次授权。可能触发 UAC 的后继动作必须先等 Owner 在**当前 Work 会话**输入“我在”，且仍要具体任务授权；此前确认不沿用。AUTH-101、AUTH-17、AUTH-107 既有预算不重置，AUTH-99 禁止运行。

Work 已在 `EVIDENCE/AUTH-111-SYNTHETIC-TRANSPORT-CAPTURE-AND-PARSER-WIRING/summary.md` 作 LEVEL 2 受限 ACCEPT：仅本地临时虚构进程采集与 AUTH-110 解析器接线，Work 独立复跑 11 项通过。本任务不再处于 ISSUED；下一现场步骤须有新任务和独立风险门。
