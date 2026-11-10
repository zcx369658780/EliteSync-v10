# AUTH-78｜E: U 盘重插锁定与 Owner 解锁演练受限回执

状态：**目标未完成；仅提交受限事实候选，待 Work LEVEL 3 独立审查**。查询时点：2026-09-25 13:55:46 +08:00。

## 派发与固定设备

- 启动前为本地 `D:\EliteSync-v10`、`main`、HEAD `b9eb82a3b687fd75eca0a341b0e1b873b203b1fe`；`TASK_CURRENT.md` 为 `AUTH-78-USB-REINSERT-LOCK-OWNER-UNLOCK-PROOF`、`ISSUED — NOT STARTED`、派给 Codex + Owner、LEVEL 3。原有两个无关未跟踪目录保持原状；本任务仅新增本回执。
- 已核对本地项目入口、风险门、workflow 技能及 AUTH-77 的独立接受边界。操作前固定 `E:` 一次身份门通过：`Kingston DataTraveler Duo`、USB 可移动、约 `28.802 GiB`、单一 Disk/Partition/卷映射。AUTH-77 只证明此前当次完全加密、保护开启、当前解锁及 100%；不能代替本次重新接入锁定证明。

## 本次顺序与预算

| 阶段 | 脱敏事实 |
|---|---|
| Owner 安全移除并物理拔出 | Owner 报告完成 **1/1 次**；Codex 只读核对原 E: 卷不再呈现，`PASS` |
| Owner 物理重插同一只 U 盘 | Owner 报告完成 **1/1 次**，当时尚未输入密码，未报告格式化提示；Codex 重新核对 E: 唯一 Kingston 身份，`PASS` |
| 重插后锁定阶段提权只读状态查询 | Owner 在本机亲自核对并批准 UAC；预算 **1/1 次**已用。提权进程内设备身份复核通过，固定 BitLocker 字段未形成可判定结果，脱敏类别 `FIELD_UNKNOWN`；`Locked`、`ProtectionOn`、`FullyEncrypted` 均未在本次形成证明 |
| Owner 密码解锁 | **0/1 次，NOT_RUN**；因锁定状态门未通过而停止，未请求 Owner 输入密码 |
| 解锁后提权状态查询 | **0/1 次，NOT_RUN**；依赖门未通过 |

首个失败/未决项为 `LOCKED_STAGE_FIELD_UNKNOWN`。该类别表示本轮固定字段收集或映射未形成完整可接受结果，不能据此断言卷已自动解锁、已锁定、保护关闭或设备损坏；具体字段或原因保持 `UNKNOWN`。锁定阶段一次预算已经耗尽，不重试、不改解析门、不换工具补查。依任务失败即停，不以 Owner 的“尚未输入密码”报告或系统弹窗代替 `Locked` 状态证明。

本任务没有解锁、格式化、加密/解密、暂停/恢复保护、添加/删除保护器或写入 E:；Codex 没有自动安全移除、重插、批准 UAC 或输入秘密。未接收或记录密码、纸质恢复密钥、保护器 ID、卷 GUID/序列号、BitLocker 原始对象/完整输出、U 盘文件名或内容。恢复密钥可用性、Owner 密码解锁、真实私钥副本及数据库备份/恢复仍未证明。作者不提交、推送、自接受或派发后继，停在 **Work LEVEL 3 独立审查门**。

## Work 独立审查（2026-09-25）

**LEVEL 3 REJECT 完整锁定与解锁证明；ACCEPT 受限过程和失败事实。** Work 核对派发 HEAD、唯一候选文件、Owner 的安全移除/重插回执以及 Codex 执行记录。原 E: 卷消失与重插后固定 Kingston 身份可接受；锁定阶段一次提权读取返回 `FIELD_UNKNOWN`，脚本将任一固定字段为空、映射外或百分比越界统一归类，未保存具体字段，因此不能推断 `Locked` 或其他保护字段。Owner 未输入密码，解锁后状态查询未运行。Work 未重跑耗尽预算。审查前候选 SHA-256 为 `0A6DA1BDE0E7D3F478B07B090E6D948D8CCBDE104F909DAC83A38B3AF4AEE16A`；另核未跟踪文件尾随空白 0 行。

后继若需定位字段或完成锁定/解锁证明，必须另立有界任务；当前不得写入真实私钥副本。
