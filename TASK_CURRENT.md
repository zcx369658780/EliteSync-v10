# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-52-OPENSSL-CAPABILITY-PARSER-PREFLIGHT`

Risk Level: `LEVEL 2`（后续服务器工具能力核验的本地解析门；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED — LOCAL SYNTHETIC PARSER PREFLIGHT ONLY`

Assignee: `Codex`。仅交付本地纯解析器、虚构测试及受限回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：纯内存版本与 AES-256-GCM 列表解析预检 LEVEL 2 ACCEPT，仅限虚构输入；作者报告最终 12/12 测试 PASS。解析器不能独立证明远端输出采集完整，后继只读任务须设置捕获上限和截断失败门。见 `EVIDENCE/AUTH-52-OPENSSL-CAPABILITY-PARSER-PREFLIGHT/summary.md`。

## Authority and objective

AUTH-51 的一次 SSH 预算 1/1 已耗尽，Work LEVEL 2 REJECT 完整能力目标：命令退出 0 可作受限事实，服务器版本与 AES-256-GCM 是否列出仍 `UNKNOWN`，原始输出未保存。Owner 已授权继续，并要求 SSH 异常及时反馈。本任务先用纯本地虚构输入建立可审查的版本及算法列表解析门，避免未预检的过滤逻辑再次消耗服务器连接。32GB U 盘和 Owner 密码此阶段均不需要。本任务不触及服务器、真实密钥、备份或数据库。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、`.agents/skills/elitesync-local-workflow/SKILL.md`、AUTH-51 验收；核对本地 `main`、HEAD 与工作区。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。若任务状态或派发不匹配，停止。
- 只允许新增 `EVIDENCE/AUTH-52-OPENSSL-CAPABILITY-PARSER-PREFLIGHT/parser.py`、`test_parser.py`、`summary.md`。不得改动产品源码、旧证据、控制文件或其他路径。
- 解析器只处理调用方传入的内存字符串与命令退出码，不运行进程或读取文件/环境变量。版本仅从明确的 `OpenSSL` 版本行提取；异常、空值、过大或无法确认格式一律 `UNKNOWN`。算法仅在命令退出 0、完整可解析列表中，将大小写不敏感且具有完整 token 边界的 `AES-256-GCM`（包括明确等价的 `id-aes256-GCM`）判为列出；不能把 `AES-256-GCM-SIV`、前后拼接或普通正文提及误判为列出。无法确认列表完整性时为 `UNKNOWN`，不得将无匹配直接当作服务器不支持。
- 用纯虚构输入覆盖版本成功与失败、大小写差异、OID/别名、相似但不等价算法、非零退出、空/畸形/超限输出及无匹配但格式有效的情况。测试数据不得复制服务器原始输出。以最小稳定接口供未来另立的只读任务调用；不在本任务判断实际服务器能力。

## Verification and stop

本地 targeted 测试最多 2 次；`git diff --check` 最多 1 次，新文件另做只读尾随空白检查。回执写明精确测试数和 PASS/FAIL、候选范围及 `UNKNOWN` 边界。不得连接 SSH、使用 CloudShell/云 API、访问旧 `D:\EliteSync`、本机真实备份/密钥目录内容、数据库、账号、Token、消息或媒体。不得生成密钥、要求 Owner 输入密码、读写 U 盘、制作备份或恢复。

Codex 不提交、制作 bundle、推送、自接受或派发后继。Work 独立验收前，不得用本解析器开始新一轮 SSH；若验收通过，服务器补测仍须另立固定连接预算与停点的任务。
