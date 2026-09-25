# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-63-LOCAL-CMS-CIPHERTEXT-IDENTITY-GATE-REPAIR`

Risk Level: `LEVEL 2`（认证解密前密文身份核对与消费者门修复；Work 独立审查）

Status: `ACCEPTED — CLOSED`（Work LEVEL 2；仅本机虚构身份门矩阵，见 `EVIDENCE/AUTH-63-LOCAL-CMS-CIPHERTEXT-IDENTITY-GATE-REPAIR/summary.md`）

Assignee: `Codex`。只交付本机虚构密文身份门修复、targeted 测试及一次新虚构运行回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-62 完整矩阵被 Work LEVEL 2 REJECT：正常路径虽然计算了密文摘要，却把 `identity_ok=True` 固定传给消费者门，未用实际输入字节核对密文长度/摘要；旧本机 1/1 预算已耗尽。其正常 1/21 与负向 0/0 仅作为受限事实。AUTH-49 合同要求固定来源、长度、内容摘要和 CMS 认证均通过后才可消费。本任务用新的本机虚构材料修复身份门，不改历史 AUTH-62，不连接服务器，不触碰真实密钥或备份。Owner 密码和 U 盘不需要。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、项目本地 workflow 技能及 AUTH-48/49/50/61/62 验收；核对 `D:\EliteSync-v10` 本地 `main`、HEAD 与工作区。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。状态或派发不匹配则停止。
- 只允许新增 `EVIDENCE/AUTH-63-LOCAL-CMS-CIPHERTEXT-IDENTITY-GATE-REPAIR/run.py`、`test_run.py`、`summary.md`。可复制并修复 AUTH-62 代码，但不得修改历史证据、产品源码或控制文件。先静态检查唯一消费者调用点、身份比较、异常清零、固定临时路径及清理。
- 固定虚构明文仍为 ASCII `AUTH57-SYNTHETIC-001\n`（21 字节）。仅在 `C:\Users\zcxve\AppData\Local\Temp\elitesync-auth63-cms-identity-gate` 生成本次一次性无密码虚构证书/私钥及错误私钥；创建前核对规范化绝对路径、非重解析父目录、目标原先不存在，结束时只清理本次精确目录并核对不存在。明文、密文与解密输出只在有上限内存，不能落盘或进入普通回执。
- 本次新虚构 CMS 加密成功后，在本机内存固定**本次**预期密文字节长度和 SHA-256；这只标识本次虚构来源，不宣称真实备份身份。消费者门必须从**实际传给解密进程的密文字节**重新计算长度与摘要并与预期值比较，不能由调用方传入固定 True 或绕过比较。正常路径只有密文身份匹配、解密退出 0、完整 21 字节及固定明文摘要均通过后才调用一次内存消费者，精确交付 21 字节；其余情况消费者 0 次/0 字节，暂存缓冲清零。
- 新的一次本机完整运行最多 **1/1 次**，在固定正常路径后按依赖门覆盖篡改、截断、错误私钥、超限和中断/超时。篡改/截断输入须通过实际密文字节比较得出身份不匹配；若仍调用 OpenSSL，退出码另记但不替代身份门。错误私钥的密文身份可匹配，但解密非零/内容不符须拒绝；超限、中断可为明确标注的受控模拟。所有适用负向路径消费者 0/0、缓冲清零并清理 PASS 才可候选完整 PASS。失败即停，不重跑或放宽门。
- 纯虚构 targeted 测试最多 2 次，必须包括“传入篡改密文、伪造解密退出 0 且明文内容正确”仍因实际密文身份不符被拒；还覆盖正确密文/正常放行与错钥/非零/异常拒绝。测试不得运行 OpenSSL 或服务器。回执只保存阶段状态、脱敏长度/摘要、退出码、消费者次数/字节、清零、首个失败、清理；不得保存原始证书/私钥/明文/密文或 stderr。
- `git diff --check` 最多 1 次，新文件另做只读尾随空白检查。不得连接 SSH、CloudShell、云 API、Docker、真实 DB、备份/密钥目录内容、U 盘、Owner 密码、账号/Token/消息/媒体或旧 `D:\EliteSync`。

## Stop and review

本机虚构身份门即使 PASS，仍不证明 AUTH-61 历史密文的负向处理、真实数据规模、真实备份身份/一致性或可恢复性；真实密码保护私钥与 U 盘副本也未建立。Codex 不提交、制作 bundle、推送、自接受或派发后继；停在 Work LEVEL 2 独立审查门。
