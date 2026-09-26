# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-120-LOCAL-KNOWN-HOST-FINGERPRINT-CANDIDATE

Risk Level: LEVEL 2（生产 SSH 主机身份核对准备；本轮仅本机虚构 Phase A）

Status: ACCEPTED — PHASE A SYNTHETIC CANDIDATE ONLY; NO REAL KNOWN_HOSTS READ

Assignee: 最新合资格 Codex 执行会话 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`；Work 独立 LEVEL 2 审查。旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。

## 目标与依据

AUTH-02 曾以现有本机 `known_hosts` 严格检查 SSH，但没有保存服务器主机指纹。Owner 所说的本机 SSH key 是客户端私钥，不能作为独立服务器主机指纹记录。准备一个只读**本机已信任记录**的有限提取候选，供未来与经阿里云控制台独立取得的服务器公有主机密钥指纹比较；本任务不声称本机记录本身为独立可信来源。

主要结果为 `EVIDENCE/AUTH-120-LOCAL-KNOWN-HOST-FINGERPRINT-CANDIDATE/summary.md`；可在同一新目录新增最小解析/入口脚本与纯虚构测试，所有新增文件须在该目录内。其余项目文件和证据只读，保留两个无关未跟踪目录。

## 允许工作与预算

1. 核对本地 Git/工作区、五份入口、项目技能与 AUTH-02、AUTH-117～119 已接受证据。固定目标仅为 AUTH-02 已接受的主机字面量 `101.133.161.203` 和本机 `C:\Users\zcxve\.ssh\known_hosts`；AUTH-02 未保存有效 SSH 端口，不得凭未写 `-p` 推定端口 22。不得搜索、枚举或猜测其他主机、端口或文件。
2. Phase A 只在**虚构 known_hosts 字节**下实现/测试有限提取：匹配固定目标的明文或 OpenSSH 哈希主机名条目；带端口的括号主机名因有效端口未锁定须拒绝。拒绝未知标记、通配/模式、格式错误、重复/歧义及超限输入；只返回有限算法名、SHA-256 公有主机密钥指纹候选和匹配类别，绝不返回原始行、公钥 blob、其他主机、异常原文或文件路径。若平台语义需要外部工具、网络或系统写入，停在静态设计并报告限制，不把未验证实现当可运行入口。
3. 仅允许读取本任务新目录的虚构夹具与代码；**不得读取真实 `known_hosts` 正文**，不得运行真实提取入口。作者纯虚构测试最多 3 轮，静态检查最多 2 轮。记录最终文件 SHA-256、预算和未证明项，候选停在 Work LEVEL 2 审查。
4. 禁止 SSH、阿里云控制台登录、Cloud Assistant/Workbench、远端命令、真实工具/DB、生产 API、Laravel CLI、Docker、OpenSSL、UAC、密码输入、部署、备份、导出、传输、停写、DDL/DML、删除、提交或推送。AUTH-17/101/107 等旧预算不重置，AUTH-99 禁止运行。

## 停点

Work 仅可在独立审查 Phase A 候选后决定是否另行放行一次本机精确 `known_hosts` 只读提取。即使本机候选与未来独立渠道指纹相等，仍须审查来源/时点/算法和现场 SSH 的独立任务；本任务不放行 AUTH-107 Phase B、真实 SSH/DB/备份。Owner 当前“我在”只满足到场条件，不放行任何 UAC、密码或生产动作。

Work 已在 `EVIDENCE/AUTH-120-LOCAL-KNOWN-HOST-FINGERPRINT-CANDIDATE/summary.md` 作 LEVEL 2 Phase A 受限 ACCEPT；本任务不再 ISSUED，真实 `known_hosts` 仍未读取。作者测试 2/3、静态检查 2/2；Work 独立复跑 36 项通过。
