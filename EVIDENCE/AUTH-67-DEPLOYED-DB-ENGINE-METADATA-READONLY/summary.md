# AUTH-67｜部署目录 DB 引擎元数据一次只读观察

状态：**作者候选，待 Work LEVEL 2 独立 ACCEPT/REJECT**。执行前本地 `D:\EliteSync-v10`、`main`、HEAD `870c6fa7a1d26d7236464cdf5e7435d26cf8f4a3`；`TASK_CURRENT.md` 的任务 ID、`ISSUED — NOT STARTED`、Codex 派发、LEVEL 2 与本次一致。原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留；本次仅新增本目录 `run.py`、`test_run.py`、`summary.md`。

## 前置门与预算

- AUTH-66 探针从工作区原始字节计算的 SHA-256 为 `5E0BCB9C4AE7EA2A90A23E12759BFE7804C090B5BA0E0B7E9B96D5844DA2DB9D`，与任务锁定值相同；运行脚本在连接前再次核对。指定私钥和既有 `known_hosts` 仅核对存在，没有读取或显示内容。
- 静态核对：一个 SSH 启动点；固定远端 PHP 命令；stdin 只送 SHA 锁定探针的原始字节；严格主机校验、无 PTY、8 秒连接超时、35 秒外部等待、stdout/stderr 各 16 KiB 上限；单行严格 UTF-8 JSON、重复/额外键拒绝、类型和固定值核对。异常与标准错误原文不输出。
- 纯虚构解析测试 **1/2 次**，首次 **8/8 PASS**。覆盖白名单正常、重复/额外/缺失键、尾随字节、畸形 UTF-8、错误类别畸形、版本/指纹不符、计数类型/超限、43/0 与分项不一致及异常脱敏；未启动 SSH、真实 Laravel 或 DB。第二次测试未使用。

## 唯一现场读取

严格 SSH **1/1 次**，退出码 0，未超时或超限，stderr 为空；stdout 只在本机上限内存中接收并严格解析，未保存或显示原文。使用指定身份及既有主机指纹校验；远端部署目录中 PHP 从 stdin 执行锁定探针，没有保存探针文件或追加探测。

| 固定字段 | 当次 CLI 连接可见值 |
|---|---:|
| 家族 / 规范化版本与 AUTH-65 比较 | `MariaDB` / `10.11.14`，MATCH |
| 目标指纹与 AUTH-65 比较 | MATCH |
| 基表 | 43 |
| InnoDB 基表 | 43 |
| 明确非 InnoDB 基表 | 0 |
| 引擎 NULL 基表 | 0 |
| 视图 | 0 |
| 基表和视图与 AUTH-65 的 43/0 比较 | MATCH |

探针报告且解析强制 `scope_completeness=UNKNOWN`、`backup_consistency=UNKNOWN`。这只描述当次 Laravel CLI 当前配置连接可见的 `information_schema` 固定聚合；权限可能隐藏对象，CLI 与 Web worker 是否同库、真实实例身份、并发 DDL/写入下的一致性、完整 dump 范围及真实恢复能力均未建立。可见基表全为 InnoDB **不证明**可以直接用事务快照完成全库备份。

`git diff --check` 按预算运行 **1/1 次**，退出 0、无输出；此命令不覆盖未跟踪新文件。三个新文件另做只读尾随空白检查，各 0 行；无 tracked 改动。

本次没有读取业务表行、原始对象名或引擎名、主机/库名、凭据、SQL 输出或错误流；没有 HTTP/API、Docker、CloudShell、云 API、备份、导出、恢复、删除、DDL/DML、部署或访问旧 `D:\EliteSync`。无提交、bundle、推送、自接受或后继派发；SSH 预算已耗尽，停在 **Work LEVEL 2 独立审查门**。

## Work 独立审查（2026-09-25）

**LEVEL 2 ACCEPT — 仅接受当次部署目录 CLI 连接可见的引擎聚合事实。** Work 核对派发 HEAD `870c6fa7a1d26d7236464cdf5e7435d26cf8f4a3`、三个候选文件与 AUTH-66 探针精确哈希；静态确认唯一 SSH 调用、固定远端命令与 stdin、严格主机校验、等待/输出上限、单行 JSON 白名单及失败停点。作者报告纯虚构解析测试 1/2 次、8/8 PASS，以及严格 SSH 1/1 退出 0、stderr 空、解析通过。Work 从仓库根以模块名独立调用测试时，因测试文件的 `from run` 依赖脚本目录而在导入阶段失败；这是调用目录差异，未运行任何测试用例。按任务的最多 2 次测试预算已用尽，Work 未再次运行。此限制不改变静态代码审查和作者脱敏回执的受限事实范围。三个新文件尾随空白均为 0 行，`git diff --check` 退出 0。

审查前 SHA-256：`run.py` 为 `F9976CCBDB4514B15E12F521FB294505D8FC3DCB79547B2375CE4197F9E10DF8`，`test_run.py` 为 `5ECF345AB5278F1E6C5A4355DFEB590DF0968C5F3B6A83886F4C8E034A7E8FFE`，本文件为 `40DA52729586BDE8E6753FDBAB405C4A400E162ED3FD4E4A5485BC30F86BE32C`。Work 未重连服务器或看到原始远端输出。接受值限于当次可见 43 张基表中 InnoDB 43、其他 0、NULL 0，视图 0；权限范围、Web worker 同库、并发写入/DDL 一致性、完整备份和恢复继续 `UNKNOWN`。AUTH-67 SSH 1/1 已耗尽。
