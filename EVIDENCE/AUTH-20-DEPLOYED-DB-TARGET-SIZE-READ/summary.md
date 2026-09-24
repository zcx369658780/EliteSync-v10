# AUTH-20｜部署目录当前 DB 目标与规模一次只读观察

状态：`BUILDER FACT CANDIDATE — PENDING WORK LEVEL 2 INDEPENDENT REVIEW`。本地 `D:\EliteSync-v10`、`main`，派发基线 HEAD `5d0856734097546e1f532898253c9374ccd32b0d`。类型：本次部署目录 Laravel CLI 当前配置连接下的固定聚合元数据投影；不代表 Web worker 同库或生产实例身份。

## 前置门与唯一远端读取

- 已接受 AUTH-19 探针的本地 SHA-256 精确为 `22D97E89DAD575B1AC0778D298329644489F9BE3771253F8A7AB62D472038DDE`，与任务单一致；运行前在本地进程内再次核对文件字节。指定私钥及既有 `known_hosts` 仅检查存在，均存在；未读取内容。先运行虚构 adapter 测试 **1/1 次**，退出码 0，**22 checks PASS**，未连接真实 DB。
- SSH 进程 **1/1 次**：指定用户、主机和私钥；`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，禁用密码和键盘交互，`-T` 禁用 PTY。唯一远端命令为 `cd /opt/elitesync/services/backend-laravel && php -d display_errors=0 -d log_errors=0`；stdin 仅送入上述已接受探针的原始文件字节，未在远端保存文件或追加探测。外部等待上限 30 秒，stdout/stderr 合计上限 64 KiB。
- 本次 SSH 退出码 **0**，stderr **0 bytes**，stdout **207 bytes**，未超时或超限。原始 stdout/stderr 仅在本地进程内接收，未保存或全文显示。stdout 通过单行严格 UTF-8 JSON、重复键拒绝、固定键/类型、driver 与家族白名单、版本/指纹形状、非负整数及无额外字段的完整检查。

| 固定输出 | 当次 CLI 观察值 |
|---|---|
| DB driver / 家族 / 规范化版本 | `mysql` / `MariaDB` / `10.11.14` |
| 目标指纹 SHA-256 | `c21262611093ac9b13dc96071af5b8e95b9af46386ea25e47ee28a57adf44a29` |
| `information_schema.tables` 当前库条目数 | `43` |
| `data_length + index_length` 合计估算 | `7,176,192 bytes` |

指纹仅由当次服务器标识与当前库名生成，是未来以同一探针重复核对的线索；原始标识未输出。`information_schema.tables` 的计数可能包括视图，字节数是该视图的估算，不是完整 dump 体积、磁盘需求或备份可存放证明。MariaDB 版本与 AUTH-17 主机 `mysqldump` 报告的版本相同，但未核验实际工具兼容、备份完整性或可恢复性。目标实例身份、Web worker 是否同库、账号/关联数据分类、备份位置和保留期限仍 `UNKNOWN`，后两项待 Owner 决定。

## 范围与停点

仅新增本 `summary.md`。`git diff --check` 按预算运行 **1/1 次**，退出码 0、无输出；该命令不覆盖未跟踪新文件。本文件另作只读检查，尾随空白 **0 行**；无 tracked 改动。未人为打开或输出 `.env`、私钥内容或配置值；Laravel bootstrap 可能按框架机制读取连接配置。未读取账号/Token/日志/媒体或其他业务数据行；未运行 HTTP/API、设备、数据库写入、备份、导出、恢复、迁移或部署。原有无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留。作者不提交、备份、推送、自接受或派发后继；候选停在 **Work LEVEL 2 独立 ACCEPT/REJECT**。未来备份、隔离恢复或改库须另立精确任务和 Owner 高风险门。

## Work 独立审查（2026-09-24）

**LEVEL 2 ACCEPT — 仅接受本次部署目录 CLI 连接的固定聚合元数据事实。** Work 核对发布基线 `5d0856734097546e1f532898253c9374ccd32b0d`、唯一新增路径、原候选 22 行无尾随空白与已接受探针的 SHA-256 `22D97E89DAD575B1AC0778D298329644489F9BE3771253F8A7AB62D472038DDE`。作者回执记载先通过 22 项虚构检查，再一次 SSH 执行精确 stdin 探针，退出 0、stderr 0 字节、stdout 207 字节，完整白名单解析通过；由此报告 MariaDB `10.11.14`、目标指纹 `c21262611093ac9b13dc96071af5b8e95b9af46386ea25e47ee28a57adf44a29`、43 个 `information_schema.tables` 条目及 `7,176,192 bytes` 估算。Work 未再连接服务器，原始 stdout 未保存，远端执行与解析细节依赖作者的一次性回执。

版本与 AUTH-17 报告的 `mysqldump` 数字相同，不是完整兼容性或恢复证明。指纹只供同一方法下比较；未证明 Web worker 与 CLI 同库，数据量也不等于 dump 大小。账号分类、完整备份存放/期限、加密方式、隔离恢复目标和可恢复性仍 `UNKNOWN`；AUTH-20 的 SSH 预算已耗尽。
