# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-117-HOST-PROBE-LOCATOR-AND-LAUNCH-ENVELOPE-STATIC

Risk Level: LEVEL 2（生产主机只读探针的目标定位与启动语义；本轮仅本地静态证据）

Status: ACCEPTED — LOCAL STATIC PLAN ONLY; NO SSH OR DEPLOYMENT

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-115/116 已接受本机虚构受控程序及独立进程输出/退出候选；现场仍缺目标主机上该程序的固定来源、启动方式、解释器/工具绝对路径、符号链接关系和实际环境。AUTH-02/17 的当次 SSH 身份与工具版本事实不能自动复用旧 1/1 预算，也没有保存完整工具路径。先从**精确已接受证据**建立定位清单和未来一次只读观察的可审查边界，避免猜路径或直接把 AUTH-115 指向主机。

主要结果仅为新目录 `EVIDENCE/AUTH-117-HOST-PROBE-LOCATOR-AND-LAUNCH-ENVELOPE-STATIC/plan.md`；只允许写该文件。其他项目文件/证据只读，保留两个无关未跟踪目录。

## 允许工作与预算

1. 核对本地 Git/工作区、五份入口、AUTH-02、AUTH-17、AUTH-107、AUTH-112～116 的精确证据/哈希及项目技能。不得读 `.env`、凭据、私钥、known_hosts 内容、真实业务行、备份或旧 `D:\EliteSync`。可仅以本地接受回执中的脱敏事实核对旧 SSH 选项和预算，不把旧连接当现时身份。
2. 区分已知的固定主机/SSH 身份候选、已知但过时的工具版本、未保存的工具绝对路径/别名、未定的解释器及 AUTH-115 程序在目标机的安装/内存传入方式。若精确 locator 不在证据中，写 `UNKNOWN`；不得搜索、枚举、猜测目标主机路径或构造可执行现场命令。
3. 设计**最小未来只读定位任务**的候选上限：固定一个主机和 SSH 身份/host-key，单次进程、零 DB 连接、零远端写入、仅有限程序/工具路径身份与版本/帮助所需的非秘密元数据，原文受控双流限额并投影固定类别；失败即停、不重试。列出 Work 在 Phase B 前必须明确提供的 host-key、解释器/远端启动、工具绝对路径/哈希、环境净化、预算及回退。说明 SSH 远端 shell/参数传递不能凭本地 argv 假设安全。该方案只是静态边界，不是可运行调用器。
4. 静态检查最多 2 轮；没有测试或 SSH 预算。禁止启动 SSH、远端程序、真实工具/DB、生产 API、Laravel CLI、Docker、云控制台、OpenSSL、UAC、部署、备份、导出、传输、停写、DDL/DML 或删除。交候选后停在 Work LEVEL 2 审查，不提交、推送、自接受或派发后继。

## 停点

AUTH-107 Phase B 仍未放行；AUTH-17/107 旧预算不重置，AUTH-99 禁止运行。Owner 已决定只备份数据库，内部对象全集、目标/权限、一致性、加密传输与隔离恢复仍 UNKNOWN，真实备份须 Owner LEVEL 3 单次授权。Owner 在当前 Work 会话回复“我在”只满足到场条件，不放行 UAC、密码或生产动作。

Work 已在 `EVIDENCE/AUTH-117-HOST-PROBE-LOCATOR-AND-LAUNCH-ENVELOPE-STATIC/plan.md` 作 LEVEL 2 受限 ACCEPT：仅静态缺口与未来任务边界；作者两轮静态命令可见，文件表格只逐项记录第一轮，Work 已补记第二轮。此任务不再 ISSUED，不授权现场 SSH。
