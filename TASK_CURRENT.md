# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-142-ONE-SHOT-CAPABILITY-PROBE-REATTEMPT

Risk Level: LEVEL 3（生产轻量实例命令助手新预算一次只读提交）

Status: STOPPED — NEW ONE-SHOT SUBMIT ATTEMPT CONSUMED (1/1); FIELD RESULT UNKNOWN

Assignee: Work 亲自临运行复核与执行；Codex 不派发现场动作。

## Owner 新决定与固定对象

AUTH-140 的一次按钮动作已计 `1/1` 且 `SUBMIT_UNCONFIRMED`；AUTH-141 新的一次只读列表 1/1 未看到对应记录，但不能证明绝无后台执行。Owner 在明知此不确定性及重复探测可能性后，**明确批准全新一次执行预算**，仅限同一上海轻量实例、AUTH-140 已审的 11 行只读 Shell 能力探针。旧 AUTH-140 执行预算不重置。Owner 对本条短探针以 `root`、脚本/结果可能被命令助手长期留存的批准按相同目标和内容沿用；没有 SSH、DB、密钥或备份授权。

固定脚本为 `EVIDENCE/AUTH-140-ONE-SHOT-COMMAND-ASSISTANT-CAPABILITY-PROBE/plan.md` 内“唯一拟粘贴文本”的 11 行，执行前该文件 SHA-256 `1B6CC2D1414619B5F8BDB656348DE4BB336A51361FD60DC29253B00FFC37ABF3`。仅输出身份类别与 `sshd/systemctl/service` 名称可定位类别，不读配置、主机密钥、客户端 PEM、数据库或业务行，不写文件/改服务。历史 root/22/跳过主机校验线索不放行 SSH。

## Work LEVEL 3 临运行门与单次预算

只操作当前用户已登录的官方上海地域 Owner 指定唯一轻量实例命令助手。先读旧表单状态，不点击旧“确定”前核对目标 URL/地域及表单：Shell、输入命令内容、无参数、名称 `AUTH-140-readonly-capability-probe`、用户 `root`、超时 10 秒、执行路径仍为原默认 `/root`、编辑器恰好上述 11 行加可忽略尾随换行。若表单失效或字段变化，只允许在**同一实例同一表单**精确恢复这些固定值一次；任何登录、真人识别、权限/UAC、内容无法完整核对或异常即停。不切换实例、用户、脚本或工具。

核对按钮实际可用、无覆盖层/禁用/验证错误后，由 Work 用页面语义控件对“确定”提交**至多一次**；动作开始即计新预算 `1/1`，不论是否可见成功。不得因页面未变化再点第二次。提交后只读观察是否出现本命令的新记录或白名单结果；最多查看对应记录一次，超出白名单/来源不明即停。普通证据只留 `UID=ROOT|NONROOT`、三个工具位 `YES|NO`、状态/退出类别、时间与预算，不存账号、实例 ID、IP、脚本原始执行输出、错误全文或截图。无记录则 `SUBMIT_UNCONFIRMED`，不推断绝无后台运行。AUTH-128/136/138/141 页面预算及 AUTH-121/122/123 本机预算不重置。

唯一主要结果 `EVIDENCE/AUTH-142-ONE-SHOT-CAPABILITY-PROBE-REATTEMPT/summary.md`。任何成功仅证明命令助手该次环境类别，不证明 host-key、实际 SSH 端口、SSH 可信或 DB 结构。SSH、DB、dump、备份继续为 0；保留两个无关未跟踪目录，不访问旧仓库或自动 pull/push。

## 执行与停点

Work 核对旧表单及已审脚本后，用页面“确定”语义按钮作一次提交尝试，预算 `1/1` 耗尽；页面无状态变化、无记录/回执、无确认对话框，`SUBMIT_UNCONFIRMED`、`FIELD_RESULT=UNKNOWN`。没有第二次点击。证据见 AUTH-142 `summary.md`。本任务停止；不据此 SSH 或进入 DB，后继需要新任务/预算并处理自动化提交无可靠回执与潜在重复风险。
