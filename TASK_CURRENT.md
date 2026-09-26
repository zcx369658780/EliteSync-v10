# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-147-SSHD-TOOL-IDENTITY-STATIC-CANDIDATE

Risk Level: LEVEL 3（生产 SSH 信任路径的下一步候选；纯本地静态）

Status: COMPLETED — PHASE A STATIC ACCEPT; FIELD NO-GO

Assignee: Codex 已交候选；Work 已独立 LEVEL 3 审查。Owner 保留下一次现场调用裁决。

## 固定结果

`EVIDENCE/AUTH-147-SSHD-TOOL-IDENTITY-STATIC-CANDIDATE/plan.md` 中的完整 Shell 候选只解析 `sshd`、`systemctl`、`service` 名称到受限绝对路径字符串，**不执行三个工具**，不读配置、密钥、端口或 DB。作者交付前 SHA-256 `FACEBEE2CC7A53B5E17398DBF669905627AD6F80011758F013BFB2933D3AC32D`，两轮本地静态检查；Work 独立逐行核对后仅接受路径形态候选，不接受工具字节身份、服务状态或 host-key/端口结论。本轮现场预算 0，未运行脚本或访问控制台。

## 当前高风险停点

候选正常结果将包含三个程序的**绝对路径原值**。阿里云命令助手可能长期保存脚本、结果与审计副本，可见者/期限未知；Owner 此前只接受无秘密脚本及纯类别结果的留存风险，尚未针对路径原值、显式 root 和本脚本的一次现场调用作具体决定。因此现场 `NO-GO`。即使 Owner 同意风险，仍须新任务复核同一目标/表单、固定脚本哈希、10 秒参数、一次预算及失败停点，并经 Work LEVEL 3 临运行裁决。不得把静态 ACCEPT 当成现场 GO。

AUTH-140/142/144/145/146 及其他旧已耗预算不重置；`TARGET_BINDING`、主机公钥信任、有效 SSH 端口、DB 结构和备份就绪仍 `UNKNOWN`。SSH、PEM、DB、dump、传输与恢复均未放行。保留两个无关未跟踪目录；不访问旧仓库，不自动 pull/push。
