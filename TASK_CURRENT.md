# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-146-OWNER-MANUAL-COMMAND-DETAIL-OPEN

Risk Level: LEVEL 3（生产命令助手单条详情；Owner 单次手动打开）

Status: COMPLETED — EXIT=ZERO; AUTH140=OK; UID=ROOT; SSHD/SYSTEMCTL/SERVICE=YES

Assignee: Work 负责只读复核、GO/NO-GO 和受限详情投影；Owner 本人负责获 GO 后的唯一手动点击。Codex 不派发现场动作。

## 精确授权

AUTH-144 的命令记录控制面显示“执行完成”，但技术结果 `UNKNOWN`。AUTH-145 自动化点击一次“查看命令详情”后无可见变化，预算 1/1 已耗尽，不能重试。Owner 明确同意**本人在 Work 重新核对并给出 GO 后**，对当前唯一同名记录手动点击“查看命令详情”一次。它可能重复打开同一详情，但不会重新执行命令；Owner 在 GO 前不要点击。AUTH-144 命令执行 1/1 与 AUTH-145 详情点击 1/1 均不重置。

Work 只在当前已打开的阿里云官方上海轻量实例命令助手页，做一次只读临运行复核：目标 URL/地域与 AUTH-144 相同，表中恰好一条 `AUTH-140-readonly-capability-probe` 且状态“执行完成”，该行有“查看命令详情”入口，无正在执行或异常提示。任一不符，或需要登录、密码、真人识别、UAC/权限，即 `NO-GO`。不刷新、导航、重新执行命令、读取别的记录或使用隐藏 API。

复核通过后 Work 可给出仅此记录的手动 GO。Owner 点击该行“查看命令详情”**至多一次**，动作开始即本任务手动详情预算 `1/1`，无论结果是否出现都不重试。Work 在 Owner 报告点击后只读查看当前详情一次，仅保留明确退出码的 `ZERO|NONZERO|UNKNOWN` 类别、`AUTH140=OK|ID_ERROR|OTHER|MISSING`，以及唯一成功行中的 `UID=ROOT|NONROOT`、`SSHD/SYSTEMCTL/SERVICE=YES|NO`；任何额外、重复、非白名单或平台错误只记异常类别并停。不得保存/转发详情原文、截图、账号、实例标识/IP、密钥或业务数据。

本轮 Work 临运行核对 `1/1`，Owner 手动详情点击 `1/1`。唯一主要结果 `EVIDENCE/AUTH-146-OWNER-MANUAL-COMMAND-DETAIL-OPEN/summary.md`。即使探针成功，也仅为命令助手 Shell 的身份和名称可定位类别，不证明公钥信任、实际 SSH 端口、二进制可信、DB 结构或备份就绪。SSH、PEM、DB、dump、传输、恢复均未放行；其他旧预算不重置。保留两个无关未跟踪目录，不访问旧仓库，不自动 pull/push。

## Work LEVEL 3 临运行裁决

当前页 URL 与 AUTH-144 同目标、地域为上海；表中恰有一条同名命令，状态“执行完成”，唯一“查看命令详情”入口可见，无执行中状态或登录/权限弹窗。Work 本轮只读复核 1/1 已耗尽，LEVEL 3 **GO：仅 Owner 本人在该行手动点击“查看命令详情”一次**。Work 不代点；动作开始即 Owner 本轮详情预算 1/1。GO 发出时尚未收到 Owner 点击报告，技术结果仍 `UNKNOWN`。

## Owner 手动查看与最终审查

Owner 报告已手动点击一次，本轮详情预算 `1/1` 耗尽。Work 对当前打开详情作一次受限只读观察：命令类型 Shell；控制台明确显示退出码 `0`，结果为唯一一行完整白名单 `AUTH140=OK UID=ROOT SSHD=YES SYSTEMCTL=YES SERVICE=YES`。未复制原始详情、脚本或其他字段，未点击、刷新或再次执行。Work LEVEL 3 **ACCEPT 仅该次命令助手 Shell 的退出与四个类别位**；`YES` 只表示当时的命令名称可定位，不能证明 SSH 二进制、服务状态、主机公钥/端口、DB 或备份。
