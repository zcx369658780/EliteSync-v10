# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-82-LOCAL-SYNTHETIC-PASSPHRASE-KEY-PROOF`

Risk Level: `LEVEL 2`（未来真实私钥流程的本机虚构交互预检）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`，复用现有本地执行会话；Work 独立 LEVEL 2 审查。

## Authority and fixed boundary

AUTH-81 已由 Work 接受为 docs-only 候选方案，不证明真实口令提示、密钥或 CMS 可用。Owner 已决定真实私钥密码另写纸质副本并与电脑、U 盘分开放置；真实密码只由 Owner 本人输入。本任务**仅使用显然虚构的一次性测试口令和临时虚构密钥**验证本机 OpenSSL 原生提示、直接加密写入、证书生成和配对；不向 Owner 索取或处理真实密码。不得使用固定 `C:\Users\zcxve\EliteSync-v10-DB-Keys`、`...-DB-Backups`、E: 或项目目录存放任何虚构密钥/证书。

## One bounded result

1. 核对 `D:\EliteSync-v10` 本地 main、HEAD、工作区、任务与 AUTH-81 接受门，保留两个无关未跟踪目录。只使用固定 `C:\Program Files\Git\usr\bin\openssl.exe`；核对版本及帮助/选项，不自动更换程序或参数。
2. 精确临时根为 `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-AUTH-82-synthetic`。创建前确认它不存在，规范解析的父目录位于当前用户本地 Temp、不是重解析点；若不满足立即停止。仅允许在该临时根写一个加密虚构私钥和一个虚构公有证书，不产生无密码私钥或明文备份。固定文件名及预期权限在运行前写入执行计划。
3. 用交互式 PTY 启动一次 `genpkey`，RSA 3072、AES-256-CBC，**不使用 `-pass` 参数/环境变量/文件或命令替换**；由 Codex 输入明显虚构的测试口令并确认。测试口令不进入普通证据。仅检查退出码、文件存在/非空、加密 PKCS#8 头的固定布尔分类；不展示密钥字节。生成预算 **1/1 次**，失败不重试。
4. 仅在第 3 步成功时，用同一虚构加密私钥通过交互式原生提示生成一次自签公有证书（固定非个人用途名、365 天、SHA-256、CA:FALSE、keyEncipherment）；证书预算 **1/1 次**。再以有界、无原始密钥/证书输出的检查确认加密状态、Owner 将来需输入密码的路径、证书与私钥公钥配对及证书非敏感参数。允许一次正确虚构口令和一次错误虚构口令的负向解锁检查，错误口令不得产生可消费公钥字节；各预算 1 次。所有子进程输出均限制、分类并丢弃原文，不把秘密或材料写入普通证据。
5. 无论成功失败，按精确文件名清理两个虚构文件并核对不存在，再非递归移除临时根并核对不存在；清理失败时记录类别并停止 PASS 声明。只在 `EVIDENCE/AUTH-82-LOCAL-SYNTHETIC-PASSPHRASE-KEY-PROOF/summary.md` 保存脱敏步骤、预算、匹配结果和停点。作者报告后停在 Work LEVEL 2 审查门，不提交、不推送、不派发后继。

PTY 工具可能记录**虚构测试口令**，所以本任务不证明 Owner 真实密码可在无录制终端安全输入。后继真实密钥任务仍须独立确定可信 Owner 本机交互方式、现时目录/同步边界、实际参数、失败清理和高风险授权。本任务不得连接服务器、真实 DB、云 API、Docker、GitHub 或旧 `D:\EliteSync`；不得生成、读取、删除或修改真实密钥、备份或 U 盘内容。
