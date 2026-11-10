# AUTH-89｜真实私钥文件 ACL 定点修复

状态：**作者定点 ACL 修复核对通过，待 Work LEVEL 3 独立审查**。

## 授权与前置分类

- `D:\EliteSync-v10` 本地 `main`，启动 HEAD `2488ce9a9e1ae88c978f968854e0c58c70f2ff8e`；`TASK_CURRENT.md` 为 `AUTH-89-REAL-PRIVATE-KEY-FILE-ACL-REPAIR`、`ISSUED — NOT STARTED`、LEVEL 3。两个无关未跟踪目录保留。
- AUTH-88 的唯一真实生成返回成功，固定文件长度 2666 bytes、首行加密 PKCS#8 标记，但文件 ACL 继承开启，故完整安全目标 Work LEVEL 3 REJECT；旧生成预算 1/1 已耗尽。本任务只修复文件 ACL，不复用生成或密码预算。
- 精确目标 `C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem`。变更前只读元数据：必要父路径均为规范非重解析目录；文件为规范非重解析普通文件、长度 **2666 bytes**、Owner 为当前用户；ACL 继承开启，恰有当前用户、SYSTEM、Administrators 三条继承的 Allow FullControl，无拒绝或其他 ACE。未读取私钥正文或完整 SDDL。

## 一次变更与复核

变更前在同一受限操作中再次核对全部前置条件通过；随后将现有继承 ACE 在内存中转为显式，并对精确文件调用 `Set-Acl` **1/1 次**，退出 0。未新增或删除主体，未修改父目录 ACL。

变更后只读分类：同一精确路径仍为规范、非重解析普通文件；长度 **2666 → 2666 bytes**，文件最后写入时间未变；Owner 仍为当前用户，ACL 继承已关闭，恰有当前用户、SYSTEM、Administrators 三条**显式** Allow FullControl，无拒绝或其他 ACE。文件正文未读取，也未计算内容摘要；长度和时间不构成逐字节一致性证明。

本轮没有调用 AUTH-88 入口、OpenSSL 或密码解锁；没有生成证书、U 盘副本、备份或恢复。此前 AUTH-88 的加密 PKCS#8 首行是历史只读回执，本任务没有重新读取首行；本次 ACL 通过不证明密码可解锁、公钥配对或失钥恢复。没有复制、删除或覆盖私钥正文，没有写 E:、备份目录或访问其他密钥、服务器、DB、云、Docker、GitHub、旧 `D:\EliteSync`。作者不提交、推送、自接受或派发后继，停在 Work LEVEL 3 独立审查门。

## Work 独立审查（2026-09-25）

**LEVEL 3 ACCEPT 精确文件 ACL 修复。** Work 对照任务单及作者受限回执，独立只读复核精确文件仍为非重解析普通文件、长度 2666 bytes、Owner 为当前用户、继承关闭，且仅当前用户、SYSTEM、Administrators 三条显式 Allow FullControl。审查前候选摘要 SHA-256 为 `29AF13544451EFF59E0A0B4AE3C070533AC1DE13EFB10D8D3BBDB20A1DF14F97`，尾随空白 0 行，`git diff --check` PASS。本次仅验收权限；未读取私钥正文或验证密码可解锁。一次 ACL 变更预算已耗尽，不重试。
