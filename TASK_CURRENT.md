# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-137-SSH-TRUST-AND-LIVE-SCHEMA-ENTRY

Risk Level: LEVEL 3（拟对生产实例建立 SSH 信任并调查真实数据库结构；当前仅范围与授权记录）

Status: PREPARATORY — SSH DIRECTION AUTHORIZED BY OWNER; CONNECTION NOT RELEASED; TRUST SOURCE NOT FIXED

Assignee: Work 固定下一受限候选与 Owner 决策；当前不派发现场动作。

## Owner 新授权与当前停点

Owner 明确授权以 SSH 连接方式调查数据库结构，并允许必要时询问截图所示旧项目 Codex 会话。这是**方向与目的授权**；本任务尚未固定实例绑定、独立 host-key 来源、有效端口、身份、准确命令、只读 DB 元数据范围、输出及一次预算，不作为立即发起 SSH、命令助手或真实 DB 查询的临运行放行。

前一 AUTH-136 仅接受已登录上海轻量服务器列表唯一运行中条目的观察；概览因 UI 异常未核，查看 1/1 耗尽。AUTH-130 仅接受 `NOT_FIXED` 停止结论。旧项目会话 `01a0666b-6f87-7aa1-924c-75c021c9dbaf` 经 Owner 授权的定向只读回复为 `NOT_FOUND_IN_SEARCHED_SCOPE`：在其旧仓库文档/Git 历史及 2026 年 8—9 月相关本地会话范围内，未找到独立于 SSH/known_hosts 的云实例身份或主机公钥来源；此回复是外部线索，Work 不访问旧 `D:\EliteSync`，不能把搜索范围外推为不存在。

唯一主要结果拟为 `EVIDENCE/AUTH-137-SSH-TRUST-AND-LIVE-SCHEMA-ENTRY/decision.md`，先记录可信连接与最小 schema 元数据读取的顺序、留存/权限边界、单次预算及失败停点；本轮无现场预算。普通证据不含账号、实例 ID、地址、端口、公钥/指纹原值、登录材料、DB 名或业务行。保留两个无关未跟踪目录。

## 不可跳过的门

先独立绑定 Owner 指定实例，并从独立于 SSH 握手/旧 known_hosts 的可信通道固定现时服务器公有 host-key 与有效 SSH 端口；再经单独 LEVEL 3 临运行审查对固定指纹作比较，才可尝试 SSH。旧 AUTH-02/17 成功、AUTH-121/122/123 的耗尽读取及 AUTH-128/136 页面观察不能替代。若只能通过阿里云命令助手获取实例内事实，须先单独固定无秘密只读脚本、执行身份、白名单输出、留存/可见者风险、实例绑定、一次预算和失败停点，并取得 Owner 对**该精确现场动作**的明确授权；之前接受留存风险仅用于准备候选。

SSH 信任门通过也不直接授权读取业务行或 dump。首次 live schema 任务只应查询最小元数据与权限，先核对 Web worker/CLI/备份连接是否同一权威 DB，再逐类核对表、视图、触发器、例程、事件、列/索引/约束和可见性；输出只保留经审查的聚合/比较结论。任何密码、真人识别、额外权限或可能 UAC 在触发前停；Owner 当前会话尚未回复“我在”。实例失配、指纹/端口不能独立核验、额外输出、超时或权限不足均失败即停，不重试或改道。当前 `SSH_BUDGET=0`、`DB_READ_BUDGET=0`、首次备份未开始。
