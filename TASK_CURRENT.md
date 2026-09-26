# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-151-SSH-PUBLIC-TRUST-READONLY-COMMAND-CANDIDATE

Risk Level: LEVEL 3（生产实例首次 SSH 信任；本轮纯本地静态候选）

Status: ISSUED — STATIC CANDIDATE ONLY; FIELD EXECUTION 0/1

Assignee: 最新合资格 Codex 执行会话；Work 独立 LEVEL 3 审查与现场控制。

Owner 已确定当前上海唯一轻量实例为目标，不再要求证明它与旧开发服务器同一。Owner 接受在该实例的阿里云命令助手中以 root **最多一次**只读检查：使用系统自带工具、不逐字节预验工具，查看当前 SSH 配置、监听端口及最多四个公钥候选；接受脚本与结果可能被阿里云留存。不得读取 host 私钥、DB 或其他秘密。此任务只交付可审查的静态候选，现场执行前须 Work 独立 LEVEL 3 裁决。AUTH-148/149 等旧预算不重置。

## 作者范围与交付

只读本地治理文件与 AUTH-129/130/146/149/150 证据、必要官方 OpenSSH/Ubuntu/阿里云资料。唯一允许写入 `EVIDENCE/AUTH-151-SSH-PUBLIC-TRUST-READONLY-COMMAND-CANDIDATE/plan.md`。固定一个最小完整 Shell 命令候选及系统工具依赖、执行身份、目标实例复核、默认超时 10 秒或更小、可预期最大输出、正常/异常双流行为和阿里云留存风险；或给出精确 `NOT_FIXED` 停点。只读取受限 SSH 配置/公钥文件及监听状态，不打开私钥；候选公钥上限四个，超界直接停而不是截断成成功。禁止扫描任意目录、输出配置全文、访问 `.env`、DB、密钥、备份或更改配置。

优先输出有限公钥指纹/算法、有效监听端口与可关联依据，原值只经受保护会话供 Work 比较；普通聊天、Git、普通证据不得写公钥、指纹、IP、端口或配置原值。若只得到任意 `.pub` 文件而不能关联运行中 sshd，明确 `HOST_KEY_SOURCE=UNKNOWN`；若候选依赖 `sshd -T` 读私钥，则 `NO-GO`。首次 SSH 仅可在此后单独严格匹配预固定公钥，绝不能跳过 host-key 检查。需要独立云侧规则核验时不得把主机监听当外部准入 PASS。

## 停点与预算

作者最多两轮本地静态/虚构检查，报告文件 SHA-256、检查数与差异；不运行候选脚本、不访问控制台/API/SSH/真实 DB、不提交、pull、push 或启动后继。现场执行仍为 `0/1`，Work 独立审查并复核表单/实例后才可消耗，失败即停不重试；任何密码、真人识别或 UAC 前停。保留两个无关未跟踪目录。Owner 要求 SSH 登录核验完毕后保存本 Work 会话进度并准备交接，未登录则记录精确停点。
