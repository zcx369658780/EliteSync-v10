# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-129-FIRST-BACKUP-CONNECTION-TRUST-STATIC-CANDIDATE

Risk Level: LEVEL 2（真实备份前的服务器连接信任与现场步骤设计）

Status: ACCEPTED — PHASE A STATIC CANDIDATE ONLY; FIELD ACTION NOT ISSUED

Assignee: 最新合资格 Codex 执行会话 `01a0dc31-b629-76a3-85fd-f71566b03056`；Work 独立 LEVEL 2 审查。

## 目标与依据

Owner 现明确指定 AUTH-128 控制台内上海地域唯一轻量应用服务器为本次数据库备份的后端目标，并授权继续推进、条件具备时尝试第一次备份。此指定确定 Owner 的目标选择，不证明该实例的独立 host-key、实际 SSH 端口、数据库连接/权限/完整范围、一致性、服务器侧加密及本机恢复。AUTH-128 的控制台单次查看 1/1 已耗尽，AUTH-121/122/123 的真实读取预算各 1/1 耗尽；不可复用。

本任务唯一主要结果为 `EVIDENCE/AUTH-129-FIRST-BACKUP-CONNECTION-TRUST-STATIC-CANDIDATE/plan.md`，只允许新增或修改此文件；其他项目文件只读。以 AUTH-24/68/102～107/124～128 的已接受边界为起点，设计下一次最小现场步骤，使 Owner 指定实例、服务器 host-key 独立来源及有效 SSH 端口能够分别核对。可匿名只读访问阿里云**轻量应用服务器**官方公开文档及 OpenSSH/MariaDB 官方资料，不登录账号、不访问已打开的控制台页。

## Phase A 交付

1. 独立核对本地分支/HEAD/工作区、当前任务、AUTH-128 脱敏回执与 Owner 最新目标指定。分别列出已关闭与未关闭的第一备份前置门；不把 Owner 指定解释成 host-key 或 DB 证明。
2. 依据可核验的轻量应用服务器官方资料，给出**一个**优先的最小现场信任核验路径及失败停点；若官方资料不能证明控制台可显示 host-key/有效端口，应明确 `UNKNOWN`，仅设计后继对精确实例的只读公钥指纹与监听/配置观察。固定未来必须预先确定的路径、算法、命令/页面、输出白名单、一次预算与密码/UAC 停点；不可在现场搜索、猜测或临时换路径。
3. 说明连接信任通过后，真实备份还欠哪些独立门：CLI/Web worker 同库、权威对象全集及拟备份账号权限、事务/DDL 一致性、现时 dump 工具、服务器侧认证加密和本机密文及隔离恢复准备。给出最短顺序与每步 GO/NO-GO，不能交可运行真实 dump 命令或把静态方案当备份授权。
4. 普通证据不含账号、实例 ID、IP、host-key 公钥/指纹原值、端口数字、DB 名/对象、凭据、页面原文或截图。作者最多做 2 轮文档静态检查，交最终 SHA-256、来源与限度，停 Work LEVEL 2 独立审查。

## 禁止与停点

本轮只作公开资料与本地证据的静态候选；不得继续浏览 Owner 已登录控制台、刷新/重试 AUTH-128、登录账号、点击远程连接/命令助手/VNC、访问 SSH 或 known_hosts、运行远端命令/生产 HTTP/真实 DB/dump、读取密钥/备份目录正文、触发 UAC/密码、传输/恢复/停写/部署或提交/推送。AUTH-107 Phase B 和真实备份均未放行。作者候选停 Work LEVEL 2，不自接受或派发后继。
