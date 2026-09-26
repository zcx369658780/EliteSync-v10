# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-144-OWNER-MANUAL-CAPABILITY-PROBE

Risk Level: LEVEL 3（生产实例命令助手；Owner 单次现场动作）

Status: GO ISSUED — AWAITING OWNER'S ONE MANUAL CLICK; NO RESULT YET

Assignee: Work 负责临运行只读核对、GO/NO-GO 和证据；Owner 本人负责获 GO 后的唯一手动点击。Codex 不执行现场动作。

## Owner 新授权与固定范围

Owner 在获知 AUTH-140/142 两次提交尝试均无回执、可能已送达且手动重试可能重复后，明确同意**本人等待 Work 的 GO，再手动单击一次**。本任务只给 Owner 新的一次手动点击预算；Work 不得代点、自动化点击或代 Owner 操作提交。旧任务预算不重置。若 Owner 在 GO 前已点击，立即停并核对，不补点。

目标仅为 Owner 指定的阿里云上海地域唯一轻量应用服务器的**当前旧命令助手表单**。脚本仅为 `EVIDENCE/AUTH-140-ONE-SHOT-COMMAND-ASSISTANT-CAPABILITY-PROBE/plan.md` 的 11 行 Shell 能力探针；该源文件上次复核 SHA-256 为 `1B6CC2D1414619B5F8BDB656348DE4BB336A51361FD60DC29253B00FFC37ABF3`，本次须重新计算。它只输出身份类别和三个工具名称可定位位，不读密钥、配置、端口、数据库或业务数据。Owner 先前明确接受此短探针以 `root`、10 秒运行及脚本/结果可能长期留存；本次手动预算不扩大这些边界。

## 临运行门与预算

Work 仅在**当前已打开的旧表单**做一次只读核对：官方控制台、同一上海实例、Shell、输入命令内容、无参数、同一普通命令名、显式 `root`、原默认执行路径、10 秒超时、编辑器恰为已审 11 行（可有尾随换行），且按钮启用、无可见遮罩或校验错误。不得刷新、导航、改字段、重新打开记录、调用隐藏 API 或读取密钥/业务数据。页面目标、登录状态或任何字段不符，或出现密码、真人识别、UAC/权限提示，即 `NO-GO` 并停止；本任务不授权修复表单。

若全部匹配，Work 可明确向 Owner 发出**仅此当前表单的一次手动点击 GO**，并请 Owner 报告页面是否出现新记录/回执。Owner 单击“确定”的动作开始即消耗新预算 `1/1`，无论页面是否变化；不得第二次点击、自动化补点或切换 SSH。旧提交可能已送达的重复风险继续存在。未拿到可验证回执则记 `SUBMIT_UNCONFIRMED`、`FIELD_RESULT=UNKNOWN`，不得推断绝无后台执行。

本轮 Work 只读表单核对 `1/1`；Owner 手动点击 `0/1`。GO 后可核对当前页面直接显示的白名单结果一次；不再打开命令历史列表。普通证据只留 `UID=ROOT|NONROOT`、`SSHD/SYSTEMCTL/SERVICE=YES|NO`、状态/退出类别、时间、预算和限制；不得保存页面全文、截图、实例标识/IP、原始输出或平台错误。唯一主要结果 `EVIDENCE/AUTH-144-OWNER-MANUAL-CAPABILITY-PROBE/summary.md`。即使成功，也不证明主机公钥、实际 SSH 端口、DB 结构或备份就绪。AUTH-128/136/138/141 与本机 AUTH-121/122/123 预算均不重置；不访问旧仓库，不自动 pull/push，保留两个无关未跟踪目录。

## Work LEVEL 3 临运行裁决

2026-09-26 约 18:13（Asia/Shanghai），Work 对当前旧表单做一次只读核对：官方上海实例 URL 与 AUTH-142 同一目标；Shell、输入命令内容、命令名、参数关闭、目视 `root`、原默认执行路径及 10 秒均符合。编辑器 11 行逐行与已审文本相等，另有允许的末尾空行；按钮可见且启用、无可见遮罩/错误。源文件 SHA-256 重新计算匹配。Work LEVEL 3 对**Owner 本人现在在此旧表单手动单击“确定”一次**给出 GO；Work 不代点。旧两次提交可能已送达的重复风险已由 Owner 明确接受。见本任务 `summary.md`。本次 GO 不授权换页、改字段、重试或 SSH/DB。
