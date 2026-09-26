# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-147-SSHD-TOOL-IDENTITY-STATIC-CANDIDATE

Risk Level: LEVEL 3（生产 SSH 信任路径的下一步候选；本轮纯本地静态）

Status: ISSUED — PHASE A STATIC CANDIDATE ONLY; FIELD BUDGET 0

Assignee: 最新合资格 Codex 执行会话 `01a0dc31-b629-76a3-85fd-f71566b03056`。Work 独立 LEVEL 3 审查；Owner 保留下一次现场调用裁决。

## 本轮单一问题

AUTH-146 已通过 Owner 单次手动打开详情，确认 AUTH-140 短探针在同一上海轻量实例的命令助手 Shell 中退出 0、`UID=ROOT`、`SSHD/SYSTEMCTL/SERVICE=YES`。这仅证明当时的命令名称可定位，不证明可执行文件身份、服务在运行、配置、公钥或端口。AUTH-139 的整体 host-key 发现候选仍 `NOT_FIXED`；AUTH-144/145/146 预算均已耗尽，不重置。

本任务只准备**更小的下一次只读工具身份发现** Phase A 静态候选：在已知 root 和三个名称可定位的前提下，是否能固定一条完整、无秘密、失败即停的命令助手 Shell 文本，仅识别 `sshd` 与必要观察工具的解析类型、绝对程序身份候选及最小元数据，供后续有效配置/公钥来源脚本审查。候选不得读取 sshd 配置、host-key 公钥/私钥、监听/端口、DB、业务文件或凭据，不执行 `sshd`、`systemctl`、`service` 本体，不写文件或修改状态。若必须猜路径、依赖未审工具、输出不受控或无法使结果有实际增量，就明确交 `NOT_FIXED`，不要填补猜测。

## 作者允许范围与验证

仅读取本地根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、AUTH-139/140/144/146 已接受证据及必要的公开官方 Shell/OpenSSH 文档；不访问旧 `D:\EliteSync`。唯一允许写入路径为 `EVIDENCE/AUTH-147-SSHD-TOOL-IDENTITY-STATIC-CANDIDATE/plan.md`。其中若能形成完整候选，固定脚本字节、预期解释器/依赖、显式 root、10 秒超时、无参数/路径/环境变更、stdout/stderr 白名单与长度上限、错误/非零/额外输出/超时停点、命令助手可能长期留存脚本和结果的风险、一次预算申请及不能证明的事项。实例目标复核只可作为未来临运行门，不重看旧控制台页面。普通证据不存实例 ID/IP、程序路径原值、配置、公钥、指纹、平台错误全文或截图；若候选确需临时查看路径原值，先在方案中界定受控接收/留存通道，不在本轮执行。

至多两轮**本地静态/虚构输入**检查，报告实际检查、候选文件 SHA-256 和差异；不运行任何候选 Shell 或真实 `sshd`/`systemctl`，不进入控制台、云 API、SSH、DB 或备份，不触发密码/真人识别/UAC。保留两个无关未跟踪目录，不改现有权威文件，不提交或推送。交付 Phase A 后停 Work LEVEL 3；作者自检不构成现场 GO。Work 接受静态设计也不放行真实命令，下一次调用必须新任务、独立临运行复核与 Owner 精确授权。
