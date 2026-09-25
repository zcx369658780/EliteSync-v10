# AUTH-65｜部署目录 DB 对象元数据一次只读观察

状态：**作者候选，待 Work LEVEL 2 独立 ACCEPT/REJECT**。执行前本地 `D:\EliteSync-v10`、`main`、HEAD `76a23604e22850520c503d14891ee089495c059f`；任务 ID、`ISSUED — NOT STARTED`、Codex 派发与本次完全一致。原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状。本次仅新增本目录的 `run.py`、`test_run.py`、`summary.md`。

## 前置门与预算

- AUTH-64 探针工作区原始字节 SHA-256：`ED8CB1CC5B3D3C4795595BE3F7E4B3B93589DBE7AAB4D66CDAB1323BB674FD4F`，与任务锁定值相同；执行脚本在连接前再次核对。指定私钥与既有 `known_hosts` 仅核对存在，没有读取或显示内容。
- 静态核对唯一 SSH 启动点、固定远端 PHP 命令、探针原始文件字节 stdin、35 秒外部等待、stdout/stderr 各 16 KiB 内存上限、单行严格 UTF-8 JSON 白名单解析；无远端文件写入或追加探测路径。异常与标准错误原文不输出。
- 纯虚构解析测试 **2/2 次**：首次 7/8 通过，暴露错误类别为列表时未安全拒绝；修正后第二次 **8/8 PASS**。测试覆盖成功白名单、安全错误类别、重复/额外/缺失键、尾随字节、畸形 UTF-8、类型/指纹形状、目标与版本不符、计数超限以及异常脱敏。测试未启动 SSH、Laravel 或真实 DB。

## 唯一现场读取

严格 SSH **1/1 次**，进程退出 0，未超时、未超限，stderr 为空；stdout 在本机内存中严格解析通过，未保存或显示原文。使用指定身份、既有主机指纹校验、无 PTY；部署目录中 PHP stdin 执行 SHA 锁定探针。结果只代表当次 Laravel CLI 当前配置连接可见的 `information_schema` 聚合对象：

| 固定字段 | 当次值 |
|---|---:|
| 家族 / 规范化版本 | MariaDB / 10.11.14 |
| 目标指纹与 AUTH-20 比较 | MATCH |
| 基表 | 43 |
| 视图 | 0 |
| 列 | 532 |
| 索引 | 196 |
| 主键约束 | 43 |
| 唯一约束 | 29 |
| 外键约束 | 66 |
| CHECK 约束 | 39 |
| 触发器 | 0 |
| 例程 | 0 |
| 事件 | 0 |

基表加视图为 43，与 AUTH-20 当次 `information_schema.tables` 条目数相同；这只是跨时点、同算法指纹下的计数比较。探针固定给出 `completeness=UNKNOWN`：权限可隐藏对象，0 不能证明不存在。真实实例身份、权限完整性、Web worker 同库、业务数据类别与行数、写入一致性、完整备份体量及可恢复性均 `UNKNOWN`。

本次没有读取业务表行、原始对象名、主机/库名、凭据、SQL 输出或错误流；没有 HTTP/API、Docker、CloudShell、云 API、备份、导出、恢复、删除、DDL/DML、部署或访问旧 `D:\EliteSync`。无提交、bundle、推送、自接受或后继派发；SSH 预算已耗尽，停在 **Work LEVEL 2 独立审查门**。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT — 仅接受当次部署目录 Laravel CLI 连接可见的元数据计数事实。** Work 核对派发 HEAD `76a23604e22850520c503d14891ee089495c059f`、三个候选文件和 AUTH-64 探针 SHA；静态确认唯一 SSH 调用、固定 stdin 脚本与远端命令、严格主机校验、35 秒等待、双流上限、单行 JSON 白名单及失败停点。作者报告本机解析测试先 7/8 后修正为 8/8，预算 2/2；唯一 SSH 1/1 退出 0、stderr 空、无超时/超限，严格解析通过。Work 不重跑已耗尽预算，也未看到原始远端输出；运行事实依赖作者脱敏回执。三个新文件尾随空白均为 0 行，`git diff --check` 退出 0。

审查前 SHA-256：`run.py` 为 `AD8B03061559187650E6B031C126A92C06A538E9221CFA92F7234EFB86EF8682`，`test_run.py` 为 `BBF8F9E9A4CCD2AA1C82EB7E19B992F5F3722E71FD35251F527F4761C3E79952`，本文件为 `73C1542D4C43AB9DF9265BA6EC1E09CF4BD684FF9FA3E69FC11F4132380ECDD3`。接受的数值为本回执表中 43 张基表、0 视图及其余固定计数；它们仅代表当前连接可见元数据。指纹与 AUTH-20 同算法、当次值相同，不证明真实实例身份或 Web worker 同库。权限完整性、真实业务范围、写入一致性、完整 dump 体量及恢复能力保持 `UNKNOWN`。AUTH-65 SSH 1/1 已耗尽。
