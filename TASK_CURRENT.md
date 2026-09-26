# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-138-LIGHTWEIGHT-DETAIL-DIRECT-READONLY

Risk Level: LEVEL 3（已登录生产控制台实例详情的一次只读观察）

Status: COMPLETED — ONE DETAIL-PAGE READ CONSUMED (1/1); SSH/DB NOT RELEASED

Assignee: Work 亲自作一次限定只读观察并记录；Codex 不派发现场动作。

## Owner 授权与精确范围

Owner 在 AUTH-136 页面 1/1 已耗尽后，**新明确授权**直接在网页端的服务器详情查看信息。本任务单独设 `0/1` 的只读详情页观察预算，仅限当前已打开的阿里云官方轻量应用服务器上海唯一实例详情，不刷新、不重试、不切换实例、不倒退或重开列表。开始读取已认证详情即记 `1/1`，不论成功失败。

只核对页面**直接显示**的产品、地域、实例标识存在性、运行状态、公网/私网地址与 Owner 新提供的候选是否一致，以及是否直接展示当前 SSH 端口、服务器 host-key 公钥/指纹的来源和时点。未直接显示的字段填 `UNKNOWN`，不得点击远程连接、命令助手、网络/防火墙、密钥对、购买或其他功能，不查看其他页签/页面，不用云 API、SSH 或真实 DB。页面原文、截图、账号、实例 ID、地址、端口、公钥/指纹原值不进入普通证据或聊天；只留脱敏类别与预算。唯一主要结果为 `EVIDENCE/AUTH-138-LIGHTWEIGHT-DETAIL-DIRECT-READONLY/summary.md`。

## Work 临运行门与停点

若当前页不是官方控制台的上海轻量服务器详情，或出现登录、真人识别、权限/UAC、账号/地域/实例冲突、页面异常或缓存状态不明，失败即停；不通过刷新或其他导航“修复”。Work 不输入任何凭据、接受权限或运行实例内动作。旧 AUTH-128/136 各自的页面 1/1 仍耗尽，AUTH-121/122/123 本机读取也不重置；保留两个无关未跟踪目录。

本任务即使看到地址/端口与 Owner 陈述相等，也只证明该控制台页的对应字段，不能独自证明实例内 sshd 现时监听、SSH 首次握手可信或当前数据库结构；`TARGET_BINDING` 和 `PORT_VERIFIED` 依独立来源及后继风险门判定。SSH、命令助手、真实 DB、dump、传输、恢复与首次备份在本任务中预算均为 0。

## 执行与 LEVEL 3 结论

Work 已在本次 Owner 新授权下读取当前已认证详情页一次，预算 `1/1` 耗尽；脱敏回执见 `EVIDENCE/AUTH-138-LIGHTWEIGHT-DETAIL-DIRECT-READONLY/summary.md`。仅接受页面上产品、地域、实例存在/运行状态及两类地址与 Owner 候选一致的观察。页面未直接提供服务器 host-key 公钥/指纹或实例内有效 SSH 端口，`SERVER_TRUST_SOURCE=UNKNOWN`、`PORT_VERIFIED=UNKNOWN`、`LIVE_DB_SCHEMA=UNKNOWN`。未点击其他功能或启动现场命令；后续须新任务与独立高风险门。
