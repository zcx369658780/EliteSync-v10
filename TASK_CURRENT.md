# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-135-DB-STRUCTURE-LOCAL-RECONCILIATION

Risk Level: LEVEL 3（生产数据库结构声明与后续备份范围有关；本轮仅本地静态重建）

Status: COMPLETED — WORK LEVEL 3 ACCEPT STATIC RECONCILIATION ONLY; LIVE SCHEMA UNKNOWN; FIELD ACTION NOT RELEASED

Assignee: 最新合资格 Codex 执行会话 `01a0dc31-b629-76a3-85fd-f71566b03056`；Work 独立 LEVEL 3 审查。

## 背景与唯一结果

Owner 转来旧版 Codex 的只读搜索回复：在旧仓库其搜索范围内未找到原始实例购买/创建/交接记录，只有部署、SSH 盘点和审计指针；这份回复是 Owner 提供的外部线索，Work 未访问旧 `D:\EliteSync` 或独立核验其旧仓库断言。Owner 现要求“自行理清服务器上的数据结构”。结合首次数据库备份上下文，本任务先针对**数据库内对象结构**，从实时 v10 本地迁移/模型与已经接受的部署目录只读元数据重建可证基线；不能把本地源码写成当前线上完整 schema。

唯一主要结果为 `EVIDENCE/AUTH-135-DB-STRUCTURE-LOCAL-RECONCILIATION/summary.md`。Codex 只可新增/修改此文件；其他项目文件只读。保留两个无关未跟踪目录。

## Phase A 交付

1. 在 `D:\EliteSync-v10` 内核对当前 Git/任务/风险门，读取 `services/backend-laravel/database/migrations/` 中相关迁移与必要模型，以及 AUTH-14/16/20/65/67 和 AUTH-104 的已接受结论。可用现有 codebase-memory 图谱定位源码；图谱索引不能代替原文件核对。不要访问旧仓库、云控制台、SSH 或真实 DB。
2. 给出**本地设计表级清单**：按账号/认证、匹配/问卷、会话/媒体、运营/安全、框架基础等功能类别列出每个由当前迁移 `Schema::create` 定义的表及来源迁移；区分多表迁移、后续 `Schema::table` 修改、迁移账本 `migrations` 表和可能的 raw SQL/非标准建表。至少核对迁移文件数、静态建表调用数、唯一表名数；若解析不能证明穷尽，标明方法局限。不得因本地数量与旧部署 43 张接近就推定集合相等。
3. 将**部署端仅已接受的事实**单列：AUTH-14 的迁移账本可见状态、AUTH-16 固定字段/索引存在性、AUTH-20 目标/估算、AUTH-65 对象类型计数、AUTH-67 引擎计数。每项标观察时点、CLI 当前配置/权限可见范围与不能推出的结论。不得输出真实 DB 名/标识、业务行、原始对象列表、凭据或原始探针输出。
4. 做一张三栏矩阵：本地源码可推断、旧部署聚合可证、当前目标实例仍 `UNKNOWN`。特别覆盖 Web worker/CLI 同库、权威对象全集与逐项权限、视图/触发器/例程/事件是否被权限隐藏、表列/索引实际集合、数据行/外键与一致性、外部文件边界。Owner 的备份范围只含数据库内数据和对象，不能称整站恢复。
5. 明确要证明**当前服务器**结构仍需新任务固定目标身份、权威目录来源与最小只读元数据读取；目前 host-key/端口门未闭，既有 SSH 和 AUTH-121/122/123、AUTH-128 的 1/1 预算不重置。不得在本轮给可运行现场命令或申请现场预算。作者最多两轮本地静态检查，报告 SHA-256 和范围，停 Work LEVEL 3。

## 禁止

不得访问旧 `D:\EliteSync`、其他项目、Owner 账号/控制台、命令助手、VNC、SSH、云 API、真实 DB、`known_hosts`、密钥、备份或无关未跟踪目录；不得运行 dump、部署、停写、传输、恢复、触发密码/UAC、提交或推送。不得自接受或派发后继。
