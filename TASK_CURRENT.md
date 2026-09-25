# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-56-SERVER-OPENSSL-CIPHER-LIST-READONLY`

Risk Level: `LEVEL 2`（真实服务器一次只读算法列表复核；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付一次有界 SSH 静态观察候选及脱敏回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-53 当次 OpenSSL 版本 token 为 `3.0.13`、`cms -help` 命令退出 0，但算法列表未通过旧解析器，AES-256-GCM 是否列出仍 `UNKNOWN`；AUTH-53 的 1/1 SSH 预算已耗尽。AUTH-55 新解析器已获 Work LEVEL 2 本地接受：虚构测试 12/12 PASS，且本机 OpenSSL 3.5.6 的 9010 字符完整列表当次解析为 `LISTED`。本机格式不证明远端状态。Owner 已授权沿路线图推进；本任务仅对既有阿里云服务器做新的**一次**只读算法列表观察，不做 CMS 加解密或备份。无需 U 盘或 Owner 密码。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、项目本地 workflow 技能及 AUTH-53/55 验收；核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。状态或派发不匹配则停止。
- 只允许向既有 `root@101.133.161.203` 发起 **1 次** SSH 连接，私钥仅为 `C:\Users\zcxve\.ssh\CodexKey.pem`，使用既有 `known_hosts`、`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`。连接失败或超时立即停止并在本会话向 Owner 反馈；不得换入口、密钥、用户、主机校验或重试。
- 远端只运行固定无副作用 shell 查询：`command -v openssl` 的布尔结果，以及一次 `openssl list -cipher-algorithms`；不得重复版本或帮助命令，不运行加解密、密钥生成、文件写入、服务重启、数据库、Laravel 或云 API。
- SSH stdout/stderr 只在本机进程内有上限地完整读取；严格分帧并核对命令退出码、字段长度和采集终止。超限/截断、缺帧/混帧、非零退出、非 ASCII 或解析不符时，算法结果为 `UNKNOWN`；不得将部分列表当 `NOT_LISTED`。列表使用**已接受 AUTH-55** 的解析器，不能更改它或以 AUTH-52/54 版本替代。只保留脱敏的连接/命令退出码、采集字符数、`LISTED/NOT_LISTED/UNKNOWN`、失败阶段；如格式不符，可保留首个不识别行的抽象类别与长度（如花括号/别名/provider/其他），不得保存、显示或复述该行内容、完整列表、路径、环境变量或凭据。任何 `NOT_LISTED` 仅指该次完整采集列表未列出，不等于服务器不支持。
- 只允许新增 `EVIDENCE/AUTH-56-SERVER-OPENSSL-CIPHER-LIST-READONLY/run.py`、`test_run.py`、`summary.md`。先静态检查固定远端命令、SSH 选项、限量采集与严格分帧；纯虚构本地 targeted 测试最多 2 次；SSH 严格 1/1；`git diff --check` 最多 1 次，新文件另做只读尾随空白检查。

## Stop and review

报告分阶段 `PASS/FAIL/NOT_CHECKED` 与首个失败；明确此静态列表观察即使 `LISTED`，也不证明 CMS AES-256-GCM 端到端可用、与本机密文互通或真实备份恢复。不得访问旧 `D:\EliteSync`、本机真实备份/密钥目录、真实 DB、账户/Token/消息/媒体、U 盘或 Owner 密码；不创建密钥、备份、解密或恢复。Codex 不提交、制作 bundle、推送、自接受或派发后继。SSH 预算耗尽后不得追加探测；Work 独立验收决定后续门。
