# AUTH-60｜服务器虚构公有证书 fd 只读观察回执

状态：**作者候选；一次受限观察 PASS，待 Work LEVEL 2 独立 ACCEPT/REJECT**。日期：2026-09-25（Asia/Shanghai）。

## 入口与静态门

- 本地 `D:\EliteSync-v10`、`main`，执行前 HEAD `7a220e2908fa7c1fe1407b26a7e40731176c9ed7`。任务 `AUTH-60-SERVER-SYNTHETIC-CERT-FD-READONLY` 为 `ISSUED — NOT STARTED`、指派 Codex、LEVEL 2；无关未跟踪目录保留原状。
- 已读项目入口、产品决定、风险门、本地 workflow 技能及 AUTH-49/56/57/58/59 验收。仅新增本目录 `run.py`、`test_run.py` 与本回执。
- 两份 Python 文件静态 AST 解析 PASS；固定远端命令仅保留 SSH stdin 为 fd 3、运行一次 `openssl x509 -in /dev/fd/3 -noout`，并输出唯一退出码标记。SSH 固定账号、私钥、既有 known_hosts、严格主机校验、非交互、单一身份与 8 秒连接超时；进程 stdout/stderr 分别有 16384 字节内存采集上限，整体 SSH 等待上限 30 秒。严格帧解析拒绝前后额外字节或重复标记。
- 本地纯虚构 targeted 测试 **1/2 次**，3/3 PASS；只测试帧拒绝和固定命令边界，未启动 SSH 或生成证书。执行前固定 Temp 父目录及工具/SSH 文件检查通过，目标目录原先不存在。

## 一次运行的脱敏事实

| 阶段 | 状态 | 受限事实 |
|---|---|---|
| 固定本机预检 | PASS | 目标原先不存在。 |
| 一次性无密码虚构证书/私钥生成 | PASS | OpenSSL 退出 0；公有证书 1147 字节；SHA-256 `8CC14E2E1F20B697F0277F4AC7DD21B27C3903FF21448B268B1495FD86EBF89B`。 |
| 唯一 SSH 连接 | PASS | 预算 **1/1**；SSH 退出 0。只有本次公有虚构证书字节进入 stdin，私钥未发送。 |
| 服务器 `x509` 从 fd 3 读取 | PASS | 唯一固定标记严格解析；远端命令退出 0，stdout 无额外字节。 |
| 本机临时目录精确清理 | PASS | 脚本按固定目录清理并核对不存在。 |

远端命令将 `x509` 正常输出及错误输出丢弃，仅返回脱敏退出码；本机 SSH stderr 在内存中有界读取并丢弃。原始证书、私钥、stdout/stderr 和路径清单未保存进普通证据。服务器未创建文件，未运行 CMS、加解密、密钥生成、数据库、Laravel、服务重启或云 API。本次也未触碰真实备份/密钥目录内容、U 盘、Owner 密码、业务数据或旧 `D:\EliteSync`。

此 PASS 只支持当次服务器 OpenSSL 可从 fd 3 读取这份虚构公有证书；不证明 CMS fd 收件人读取、AES-256-GCM 加密、跨端互通或真实备份恢复。AUTH-58/59 的本机失败结论保持原状。作者不提交、制作 bundle、推送、自接受或派发后继；停在 Work LEVEL 2 独立门。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT — 仅接受当次服务器读取虚构公有证书 fd 的受限事实。** Work 对照派发 HEAD `7a220e2908fa7c1fe1407b26a7e40731176c9ed7`、任务单与三个候选文件，静态确认本机只生成一次性虚构证书/私钥，SSH stdin 只传公有证书；远端固定命令仅从 fd 3 运行一次 `openssl x509 -in /dev/fd/3 -noout`，stdout 仅返回规范退出码标记。脚本限制采集大小、严格拒绝额外字节和重复标记，固定目录清理前再次核对路径与重解析属性。作者报告本地虚构测试 1/2 次 3/3 PASS；Work 未重跑 SSH、证书生成或预算内测试。

审查前 SHA-256：`run.py` 为 `F306C0D0F25BFA78A9036826B1ADA0A56081C5C486A3D769EC5749A726E7EAF7`，`test_run.py` 为 `0D018958269F4B3A1FB09612E2B762C4B5C6A0E0F5833FAFF76286C4D71569F7`，本文件为 `6BE17A7454976080421E1A91F58689A80C0A72A346335366D4AD83CBD9E855DC`；三文件独立尾随空白检查均为 0 行。Work 只读确认固定临时目录不存在，与作者清理 PASS 一致；无关未跟踪目录保留。原始远端输出未保存，连接与 fd 读取事实依赖作者受限回执。此 ACCEPT 不外推 CMS 收件人读取、AES-256-GCM 加密、跨端互通、真实密钥或备份恢复。SSH 1/1 已耗尽，后继须另立任务。
