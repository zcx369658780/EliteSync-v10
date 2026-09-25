# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-81-REAL-KEY-GENERATION-LOCAL-PREFLIGHT`

Risk Level: `LEVEL 2`（未来真实密码保护私钥及本机离线保管的实施前核验）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`，复用现有本地执行会话；Work 独立 LEVEL 2 审查。此任务仅只读/文档，不生成任何真实或虚构密钥，也不要求 Owner 输入密码。

## Authority and fixed scope

Owner 已决定：完整 DB 备份密文保存于自己的电脑，自完成日起保留 30 天；真实私钥密码保护并与密文分离，恢复副本在加密 `E:` U 盘，备份和密钥均不采用云同步，密码只由 Owner 本人输入。固定目录为 `C:\Users\zcxve\EliteSync-v10-DB-Backups` 与 `C:\Users\zcxve\EliteSync-v10-DB-Keys`。AUTH-69 是已接受的顺序门合同。AUTH-77/79/80 共同支持固定 Kingston E: 加密保护、重插后锁定及 Owner 密码解锁，但纸质恢复密钥实际可用性仍未演练。本任务只为后续真实私钥生成准备具体可审查方案，不授权写入这些目录或 U 盘。

## One bounded result

1. 核对本地 `D:\EliteSync-v10` 的 main、HEAD、工作区、控制文件及 AUTH-49/61/63/69/70/77/79/80 已接受证据，保留两个无关未跟踪目录。不得访问旧 `D:\EliteSync`。
2. 对固定 `C:\Users\zcxve\EliteSync-v10-DB-Keys`、`...-DB-Backups` 及必要父路径做一次只读规范路径、目录/重解析、ACL 主体/继承与剩余空间复核；对 Windows 已配置的同步根、当前目录是否落在其下做有界只读核对，并区分技术观察与 Owner 的无云同步声明。只输出布尔/归类与容量，不枚举目录文件名或内容，不读取真实密钥或备份。不能证明所有第三方同步客户端不存在时保留该限制，不编造全局无同步结论。
3. 只读核对本机 OpenSSL 版本、固定命令选项/帮助和已接受 CMS 互通证据，形成未来真实密码保护私钥与匹配公有证书的具体候选参数：算法/位数、私钥加密格式、证书身份/有效期、Owner 本机交互密码入口、输出与临时文件边界、公有证书指纹/配对验证、轮换及 30 天备份到期前旧钥保留。不得把密码放进参数、环境变量、脚本、日志、普通证据或自动化 UI；若不能设计可信交互入口，结论为 BLOCKED。
4. 仅新增 `EVIDENCE/AUTH-81-REAL-KEY-GENERATION-LOCAL-PREFLIGHT/plan.md`，写清事实、候选方案、尚待 Owner 决定的实质问题、失败停点及下一张真实生成任务的最小授权范围。不得创建、读取、复制、删除或验证真实/虚构私钥、证书、密文、U 盘内容；不得访问服务器、真实 DB、云 API、Docker 或 GitHub。作者报告后停在 Work LEVEL 2 审查门，不提交、不推送、不自接受、不派发后继。
