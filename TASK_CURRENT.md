# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-136-LIGHTWEIGHT-INSTANCE-REOBSERVATION-READONLY

Risk Level: LEVEL 3（已登录生产控制面只读查看，服务于当前数据库结构诊断；不含实例内动作）

Status: ISSUED — LOGIN HANDOFF TO OWNER; AUTHENTICATED VIEW NOT STARTED (0/1)

Assignee: Work 亲自执行一次受限 UI 查看并独立记录；Codex 不派发现场动作。

## Owner 授权与精确范围

Owner 在当前 Work 会话明确选择：**新设一次 1/1 的阿里云官方控制台只读查看**，限上海地域轻量应用服务器“服务器列表→其唯一实例概览”，只核对产品、地域、实例标识存在性、运行状态与当前地址一致性。不刷新、不重试、不保存原值；不运行命令助手、VNC、SSH、云 API、真实 DB、dump、传输或恢复。AUTH-128 的旧页面查看 1/1 继续视为耗尽，不转借/重置；本任务是新预算，查看前 0/1。

唯一主要结果为 `EVIDENCE/AUTH-136-LIGHTWEIGHT-INSTANCE-REOBSERVATION-READONLY/summary.md`。普通证据和聊天仅报观察类别、时点、失败类别与预算，不含账号、实例 ID、IP、端口、公钥/指纹、页面原文或截图。两个无关未跟踪目录保留。

## Work 临运行门

入口仅阿里云公开资料指向的 `https://swasnext.console.aliyun.com/servers/` 或已打开的同一官方控制台页。Work 先只读确认页面属于轻量应用服务器、预期账号/上海地域可见且列表恰有一个条目；再最多一次进入该条目概览。若页面已在概览，最多只读观察该页，缺列表佐证即记录 `PARTIAL`，不倒退/刷新以凑齐。页面跳转、账号/地域/产品不符、零或多个实例、字段缺失、地址漂移、缓存状态无法判断或 UI 异常均失败即停，不换入口/筛选/实例。

到达登录密码、真人识别、权限提示或可能 Windows UAC **之前**停，由 Owner 本人处理；当前 Work 会话尚未收到“我在”，不得触发 UAC。Work 不输入凭据、不解 CAPTCHA、不接受额外权限。若只见登录门而未读账号内容，记录停止且新查看预算保留 0/1；开始读已认证列表或概览后，不论成功失败记 1/1。

本次仅接受一次 UI 观察，不能因 Owner 选择或页面地址与历史吻合而把 `TARGET_BINDING=UNKNOWN` 升为独立技术绑定。它不验证 host-key、有效 SSH 端口、实例内运行身份、Web worker/CLI/备份同库或当前数据库对象结构；任何后继控制面命令/真实 DB 读取须另立任务与 LEVEL 3 门，Owner 对具体现场调用单独授权。所有旧 SSH、本机与控制台耗尽预算不重置，首次备份未开始。
