# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-145-ONE-RECORD-COMMAND-DETAIL-READONLY

Risk Level: LEVEL 3（生产实例命令助手单条结果只读查看）

Status: STOPPED — DETAIL CLICK 1/1; DETAIL_OPEN_UNCONFIRMED; FIELD_RESULT UNKNOWN

Assignee: Work 亲自做一次受限只读查看与 LEVEL 3 裁决；Codex 不派发现场动作。

## Owner 授权与精确范围

AUTH-144 由 Owner 手动提交一次，当前页面新增唯一一条同名命令记录并标记“执行完成”，但未查看详情，`FIELD_RESULT=UNKNOWN`。Owner 在此事实及平台详情可能包含原始输出的提示后，明确授权**只读打开这条记录一次**，仅提取退出状态与 `AUTH140` 白名单类别。AUTH-144 手动点击 1/1 不重置；本任务绝无执行命令、SSH、PEM、DB、dump、备份或页面刷新/导航授权。

只在当前已打开的阿里云官方上海轻量实例命令助手页，对 AUTH-144 新增的唯一一条同名“执行完成”记录，点击其“查看命令详情”**至多一次**。动作开始即本任务详情查看预算 1/1；不看其他记录、不重新打开、不修改、下载、复制或分享详情，不调用隐藏 API。若当前记录不再唯一、名称/目标/状态不符，或页面要求登录、密码、真人识别、UAC/权限，点击前停止。若打开后来源不明或有非白名单输出，按异常类别停止，不转发原文。

只允许普通证据保留：是否看到明确退出码及其 `ZERO|NONZERO|UNKNOWN` 类别、`AUTH140=OK|ID_ERROR|OTHER|MISSING`，成功行中的 `UID=ROOT|NONROOT` 与 `SSHD/SYSTEMCTL/SERVICE=YES|NO`，缺失/重复/额外输出类别，控制面状态、时间和预算。不得保存账号、实例标识/IP、原始输出、平台错误原文、截图、脚本或任何密钥/DB 内容。唯一结果 `EVIDENCE/AUTH-145-ONE-RECORD-COMMAND-DETAIL-READONLY/summary.md`。即使成功，仅证明该次命令助手 Shell 的身份类别和名称解析位，不能证明主机公钥、实际 SSH 端口、二进制可信、DB 结构或备份就绪。

旧 AUTH-128/136/138/141 及本机 AUTH-121/122/123 预算均不重置。保留两个无关未跟踪目录，不访问旧仓库，不自动 pull/push。

## Work LEVEL 3 停点

Work 点击当前唯一同名记录的“查看命令详情”一次，详情查看动作预算 `1/1` 耗尽。随后当前页面可见状态没有详情、退出码或白名单结果，也没有新标签页；记录仍显示“执行完成”。`DETAIL_OPEN_UNCONFIRMED`、`FIELD_RESULT=UNKNOWN`。不能证明详情绝未请求或命令失败；不得重复点击或改用隐藏接口。本任务停止，后继需新授权。
