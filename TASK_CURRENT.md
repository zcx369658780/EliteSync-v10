# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-121-LOCAL-KNOWN-HOST-ONE-SHOT-ENTRY

Risk Level: LEVEL 2（本机 SSH 历史信任记录只读提取；Phase A 仅静态与虚构）

Status: REJECTED — PHASE B FORMAT_INVALID; ONE LOCAL READ EXHAUSTED

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-120 的纯函数只在虚构字节下已受限接受。准备一次**本机精确 `known_hosts` 只读提取**的固定入口，供 Work 审查后决定是否放行 Phase B 1/1；本任务不把本机历史信任记录当作独立服务器身份来源，不连接 SSH 或阿里云。

主要结果为 `EVIDENCE/AUTH-121-LOCAL-KNOWN-HOST-ONE-SHOT-ENTRY/plan.md`；Phase A 可在该新目录新增一个最小固定入口和纯虚构入口测试。其他项目文件与证据只读，保留两个无关未跟踪目录。

## Phase A 允许工作与预算

1. 核对本地 Git/工作区、五份入口、项目技能、AUTH-02、AUTH-117～120 已接受证据，固定 AUTH-120 解析器最终 SHA-256 `2D139A7C397FD1DAC2C8719F5C4D939679571D434F689CCAE19D37FC9975E346`。精确输入只可为 `C:\Users\zcxve\.ssh\known_hosts`；目标仅为 `101.133.161.203` 的无端口字面/哈希形式。有效 SSH 端口仍 `UNKNOWN`，不猜 22 或枚举其他位置。
2. 候选入口须在任何真实读取前检查固定依赖哈希、精确文件身份（普通文件、非重解析/链接）与最多 65,536 bytes 上限；仅读取一次并在内存中交给 AUTH-120 纯函数。文件身份检查与打开之间的并发风险要明确；发现身份变化即失败，不宣称字节与检查时对象严格绑定。普通输出仅固定状态/拒绝类别、匹配类别、有限算法名和公有主机密钥 SHA-256 指纹候选；不得输出原始行、公钥 blob、其他主机、异常、目录枚举或文件内容。失败不输出部分肯定。
3. Phase A **不得读取真实 `known_hosts` 正文或运行真实入口**。可用纯虚构输入检查入口的注入/输出边界，最多 2 轮虚构测试、2 轮静态检查。写明最终文件哈希、预算及 Phase B 的精确触发前复核和 1/1 停点；Work LEVEL 2 独立审查前不得执行 Phase B。
4. 禁止 SSH、阿里云控制台、远端命令、真实工具/DB、生产 API、Laravel CLI、Docker、OpenSSL、UAC、密码输入、部署、备份、导出、传输、停写、DDL/DML、删除、提交或推送。AUTH-17/101/107 等旧预算不重置，AUTH-99 禁止运行。

## 停点

Phase B 真实本机读取预算目前 **0/1 未放行**；仅 Work 对固定入口、依赖、文件身份及失败/输出边界独立审查后可作单次裁决。任何异常即停止，不重试、不换路径。即使本机指纹候选成功，独立服务器主机指纹来源仍 `UNKNOWN`，SSH、AUTH-107 Phase B、DB 和真实备份均未放行。Owner 当前“我在”只确认到场，不替代具体任务风险门。

Work 已在 `EVIDENCE/AUTH-121-LOCAL-KNOWN-HOST-ONE-SHOT-ENTRY/plan.md` 记录 Phase A 受限 ACCEPT 及 Phase B 临运行 LEVEL 2 裁决。该裁决曾仅允许固定解释器 `C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe` 以 `-I -B` 单次执行 `EVIDENCE/AUTH-121-LOCAL-KNOWN-HOST-ONE-SHOT-ENTRY/local_known_host_entry.py`；解释器、入口、依赖哈希及目标元数据见裁决。**该一次预算已用完，此段不再是现行执行授权。** Codex 只交固定脱敏类别与退出码，未复制原始 `known_hosts`、其他主机或异常文本。SSH、阿里云控制台、UAC、密码、DB 和备份预算均为 0。

Work LEVEL 2 Phase B **REJECT（指纹候选目标）**：固定入口一次返回 `REJECTED / FORMAT_INVALID`、退出 1、无指纹候选，见同目录 `plan.md`；具体格式原因 `UNKNOWN`。本机读取预算 1/1 已耗尽，AUTH-121 不得重试或换路径。Phase A 虚构候选接受仍仅限虚构测试；真实 SSH、阿里云控制台、AUTH-107 Phase B、DB 与备份均未放行。
