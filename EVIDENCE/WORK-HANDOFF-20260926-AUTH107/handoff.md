# EliteSync v10｜Work 交接：AUTH-107 Phase A 静态边界

日期：2026-09-26。实时项目只使用 `D:\EliteSync-v10`，禁止访问旧 `D:\EliteSync`。交接前本地 `main` 基线为 `bacb48fa8d49ab6f2a33fcc7c16b980fe2d1fc10`；本文件及 AUTH-105～107 接受记录拟作为同一有范围检查点提交，**交接后必须以本地 Git 重新核对最终 HEAD 与工作区**，不凭本文件推定。远端未拉取或推送。两个无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 与 `EVIDENCE/AUTH-67-DEPLOYED-DB-ENGINE-METADATA-READONLY/__pycache__/` 须保留原状。

## 本会话进度与独立结论

- AUTH-101 已有 Owner 单次 `AUTH101_RESULT=A_MATCH_AND_CLEAN;EXIT=0`，Work LEVEL 3 仅接受 E: 固定副本的虚构 CMS 往返。启动/UAC/BitLocker/CMS/比较各 1/1 预算已耗尽，AUTH-99 仍禁止运行。没有真实数据库备份或恢复。
- AUTH-102 仅接受真实备份目标、权限和范围的静态预检；AUTH-103 仅接受 Web worker 有效连接身份的静态诊断设计；AUTH-104 仅接受权威对象全集和拟备份账号权限的静态核验设计。运行中 Web 与 CLI 同一真实库、完整对象/账号权限及外部文件范围仍 UNKNOWN。
- AUTH-105：Work LEVEL 2 接受 MariaDB 官方资料的 dump 选项/权限静态候选，见 `EVIDENCE/AUTH-105-MARIADB-DUMP-OPTION-AND-PRIVILEGE-SOURCE-CHECK/plan.md`。官方当前在线文档非目标主机 10.11.14 固定快照；本轮未访问服务器。
- AUTH-106：Work LEVEL 2 接受严格解析器的纯虚构拒绝边界，独立复跑 20 项虚构检查 PASS，见 `EVIDENCE/AUTH-106-DUMP-TOOL-HELP-STRICT-PARSER/summary.md`。人为帮助布局未证明与主机真实输出一致，不能现场使用来宣称工具支持。
- AUTH-107：Work LEVEL 2 **仅受限 ACCEPT Phase A 静态调用边界**，见 `EVIDENCE/AUTH-107-DUMP-TOOL-READONLY-PROBE-CANDIDATE/plan.md`。`--no-defaults` 首参数要求已与 MariaDB 官方文档核对；但没有可运行 SSH/远端受限采集器，作者唯一一轮虚构测试提前失败，修正后未复跑，完整结果 NOT_VERIFIED。Phase B 未放行，SSH、dump 工具、DB、UAC、备份的现场调用均为 0。

## Owner 决定与当前停点

Owner 决定完整数据库备份加密存于本人电脑 `C:\Users\zcxve\EliteSync-v10-DB-Backups`，自完成日起保留 30 天，不云同步；加密私钥独立存于 `C:\Users\zcxve\EliteSync-v10-DB-Keys`，恢复副本在固定加密 Kingston E:，密码只由 Owner 本机输入。Owner 尚未回复本会话的范围问题：本次“完整数据库备份”是否只指 MariaDB 全部对象与数据，服务器文件/上传媒体另立任务，或要求同时纳入。此问题不阻止独立的本地静态准备，但不能被默认回答。

Owner 目前不保证在电脑旁。**任何可能触发 UAC 的后继步骤必须在触发前停下**，直到 Owner 在新的**当前 Work 会话**明确输入“我在”；旧 AUTH-101 到场确认不可复用。此语句仅确认到场，不替代具体任务和风险门。没有收到新的“我在”前，不启动 UAC 或要求密码。

真实阿里云数据库备份仍未具备放行条件：需分别证明 Web/CLI 真实目标、完整对象和账号权限、非 DB 边界、一致性、服务器侧认证加密与密文传输、隔离恢复准备，再由 Owner 对一次真实备份作 LEVEL 3 明确授权。当前没有可据实承诺的日历日期；首次备份后仍须另验可恢复，真实改库另立任务。

## 下一 Work 会话入口

先独立读取根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`，核对本地 Git/工作区、AUTH-105～107 接受段及跨磁盘 bundle；不自动 pull/push，不访问旧仓库。最新合资格 Codex 执行会话为 `01a0d86d-72c8-79d3-8cb9-abe0cdd30115`，先核对其当前长度/状态，未过阈值则复用；旧过长会话 `01a0d6d8-e45e-7820-ade5-7722f0e1e5f7` 不再派发。AUTH-107 已 ACCEPT（受限），不是可再次执行的 ISSUED 任务。

安全的下一步是另立**本地**任务，具体实现并用虚构子进程验证受限采集器的双流限额、非零/超时传播、stderr/异常不泄漏和固定 JSON 投影；AUTH-107 修正后的测试不得冒称已通过。之后 Work 独立审查固定字节/哈希与隐私门，才考虑是否发布单次只读 SSH 现场任务。交接本身不下达后继任务、不放行现场、不重置任何已耗一次预算。
