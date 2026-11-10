# EliteSync v10｜Work 交接｜2026-09-25 AUTH-101

此文件是本次 Work 会话的交接索引，不代替新会话对 `D:\EliteSync-v10` 的本地核验。Owner 明确要求当前长会话完成 AUTH-101 候选验收、保存进度后交接；本会话不发布新任务、不启动 AUTH-101 Phase B。

## 启动与固定边界

下一 Work 会话先读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`，再独立核对本地 `main` HEAD、工作区、AUTH-101 三件候选与审查记录。不要访问旧 `D:\EliteSync`，不要自动拉取或推送 GitHub，不要用本文件或聊天摘要替代本地证据。两个无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 与 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/__pycache__/` 保留，不清理或暂存。

Owner 希望连续 Codex 执行会话约承载 20 张任务；本次原执行会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 已明显过长，Owner 要求交接，不向它自动派发 AUTH-101 Phase B 或后继。新 Work 会话可先审查已存在任务，不要在交接本身重复创建任务。

## 本次已核验和未完成

- AUTH-96 的一次启动返回 `UAC_OR_LAUNCH_FAILED`，Owner 当时不在、未看到 UAC；两 E: 目标当时不存在。Work LEVEL 3 REJECT 副本目标，旧 1/1 启动预算耗尽。
- AUTH-97 在新任务中由 Owner 手动双击可见入口；Owner 报告复制成功标记，Work 独立确认指定 Kingston E: 的两精确副本分别与本机加密私钥和公有证书长度及 SHA-256 相等，源私钥受限 ACL 未变。LEVEL 3 ACCEPT 仅限本次副本及字节身份；启动 1/1 已用尽。
- AUTH-98 docs-only 设计获 LEVEL 3 ACCEPT：A 为 E: 私钥副本对固定虚构内容的 CMS 往返，B 为重插后的 U 盘密码解锁，C 为纸质 BitLocker 恢复密钥演练；三项不得互代。
- AUTH-99 候选被 LEVEL 3 REJECT，**禁止运行**：`cms -decrypt` 的 `2>$null` 可能隐藏 Owner 的原生密码提示。AUTH-100 的虚构诊断受限事实显示提示出现在 stderr，`2>$null` 把它隐藏；但三次虚构调用均非零，且执行违反失败即停，完整目标 LEVEL 2 REJECT。旧预算耗尽。
- AUTH-101 新修订候选见 `EVIDENCE/AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR/`。Work LEVEL 3 **ACCEPT 仅 Phase A 静态候选**：Owner 前台 CMD 直接调用 OpenSSL、原生 stderr 可见；解密唯一显式 `-inkey` 为 E: 加密私钥副本，先经 Owner UAC 下的单次只读 BitLocker 保护门；虚构临时文件在仓库外固定任务目录。`owner-visible-usb-cms-entry.cmd` SHA-256 `72CEF5684B0F34C715C63B0A3AF4D2A1B708149A153506F41DA726EC0F648E3C`，`usb-preflight.ps1` SHA-256 `5CAEA4AA65C11B36C3DD88AAEE6F49CEEC6ED47E4C7950BFCD6EA7AD467C2E29`。**Phase B 未放行，启动/UAC/BitLocker/encrypt/decrypt/compare 使用量均 0/1。**

AUTH-101 临运行前须重新审查固定脚本哈希、OpenSSL 哈希、E: 唯一 Kingston 身份/两文件有限元数据、任务 Temp 目录不存在以及 Owner 在场，再独立裁决剩余的身份检查和虚构输出创建之间的非原子并发余量。若放行，仅允许 Owner 本人从 Explorer 单次启动、亲自批准 UAC、仅在 OpenSSL 原生非回显提示输入现有私钥密码；不得把密码/恢复密钥发到聊天。失败即止、不重试。成功后仍需 Work 事后核对虚构临时目录清理、E: 副本有限元数据及本机私钥 ACL，才可决定 LEVEL 3 执行验收。B、C 与真实数据库备份/恢复均另受任务门约束。

## Owner 决定与资料边界

完整数据库备份加密保存于 Owner 电脑 `C:\Users\zcxve\EliteSync-v10-DB-Backups`，自完成日起保留 30 天，无云同步/云备份；私钥独立存于 `C:\Users\zcxve\EliteSync-v10-DB-Keys`，E: 加密 U 盘保存恢复副本。私钥密码纸质副本和 BitLocker 恢复密钥由 Owner 分开放置，本人输入。恢复演练优先本机独立环境。没有真实数据库备份、恢复、改库或纸质 BitLocker 恢复密钥实测。完整备份和任何真实密钥、密码不得入 Git/Git bundle/普通证据/第三方云服务。任何 SSH、真实数据库和恢复任务须独立授权与风险门；不得复用旧一次预算。

本地 Git 已用于有范围的检查点。跨磁盘 Git bundle 位于 `C:\Users\zcxve\.codex\backups\EliteSync-v10\`；下一会话应核对最新清单和 bundle 是否覆盖精确 HEAD，不从聊天推断。远端本轮未同步。
