# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-134-HISTORICAL-INSTANCE-PROVENANCE-LOCAL-INVENTORY

Risk Level: LEVEL 3（结果可能影响生产实例身份信任判断；本轮仅本地只读来源清点）

Status: COMPLETED — WORK LEVEL 3 ACCEPT SOURCE_NOT_FOUND_IN_V10 ONLY; EXTERNAL SOURCE LOCATION PENDING; FIELD ACTION NOT RELEASED

Assignee: 最新合资格 Codex 执行会话 `01a0dc31-b629-76a3-85fd-f71566b03056`；Work 独立 LEVEL 3 审查。

## 背景与唯一结果

Owner 确认最近一周没有另存的实例记录；更早旧版 EliteSync 时期这台服务器曾部署和调整。AUTH-133 仅接受 `NOT_FIXED` 停止结论，下一步需判断是否有**早于 AUTH-128 且独立于其页面观察**的受保护创建/交接、部署记录。本任务只在实时 `D:\EliteSync-v10` 的受版本控制资料及其**本地 Git 历史**中清点可能的记录，不访问旧 `D:\EliteSync`、其他项目、Owner 账号或现场服务器。

唯一主要结果为 `EVIDENCE/AUTH-134-HISTORICAL-INSTANCE-PROVENANCE-LOCAL-INVENTORY/summary.md`。Codex 只可新增/修改此文件；其他文件只读。保留两个无关未跟踪目录，不读取其内容。

## 清点边界

1. 先核对本地 Git、任务/接受层级，再仅从 v10 仓库的已跟踪 Markdown/配置清单及本地 Git 历史中寻找**来源类别、创建时间、提交身份和可追溯路径**。优先看 AUTH-02/24/128/133 已引用材料及可能的旧版迁移/部署记录；无需扫描无关源码、文件系统或私密目录。
2. 将候选记录分为：独立的实例创建/交接记录；部署时的服务/执行用户/工具清单；旧 SSH/已登录控制台观察；衍生转述。只报路径、提交/时间、记录类别、能否事前独立绑定当前实例及尚缺的保管链。不要在普通证据或聊天记录账号、实例 ID、IP、端口数字、用户名、host-key/指纹原值、配置全文或密钥；发现可能含原值的文件，仅做受限来源元数据判断，不复制内容。
3. 明确旧版部署事实与**当前**阿里云上海唯一轻量实例的同一性、当前运行环境及现时 host-key 是不同命题。旧 `known_hosts` 或成功 SSH 不得充当独立主机信任锚；AUTH-128 页面 1/1 已耗尽，不重看。
4. 若未找到可信独立记录，结论为 `SOURCE_NOT_FOUND_IN_V10`，**不推断 Owner 在仓库外一定没有**；给出唯一下一问题：Owner 是否知道旧版部署资料存放的受保护位置/类别，由 Owner 决定是否另立限定读取任务。若发现候选，也只交来源路径与独立审查条件，不直接写 `TARGET_BINDING=YES`。
5. 本轮最多两轮本地静态检查，交文件 SHA-256 与实际检查数；停 Work LEVEL 3。现场预算 0，AUTH-121/122/123 各 1/1、AUTH-128 页面 1/1 及其他旧耗尽预算不重置。

## 禁止

不得访问旧 `D:\EliteSync`、其他项目、Owner 账号/控制台、命令助手、VNC、SSH、云 API、真实 DB、`known_hosts`、`.ssh`、密钥、备份或无关未跟踪目录；不得运行 dump、部署、停写、传输、恢复、触发密码/UAC、提交或推送。不得自接受、派发后继、将旧部署事实升级为现时技术绑定。
