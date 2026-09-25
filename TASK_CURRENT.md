# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-102-DB-BACKUP-TARGET-IDENTITY-PREFLIGHT

Risk Level: LEVEL 2（真实数据库备份前的目标、权限与范围识别；本轮仅本地静态候选）

Status: ACCEPTED — PHASE A LOCAL STATIC PLAN ONLY; NO LIVE PROBE RELEASED

Assignee: Codex 接续执行会话 01a0d86d-72c8-79d3-8cb9-abe0cdd30115；Work 独立 LEVEL 2 审查。旧过长执行会话 01a0d6d8-e45e-7820-ade5-7722f0e1e5f7 不再派发。

## 目标与依据

Owner 要求继续推进，并询问何时可开始阿里云服务器数据库备份。AUTH-101 已受限 ACCEPT：本次 E: 私钥副本对虚构内容的本机 CMS 往返成功，全部一次预算耗尽。它不证明真实数据库目标、完整范围、服务器侧加密备份、传输或恢复。AUTH-68 已接受的合同将真实实例与连接身份、备份账号权限和数据类别列为真实备份前置门；AUTH-20/65/67 只报告部署目录 Laravel CLI 当前连接可见的聚合事实，不能证明运行中 Web worker 同库或权限完整。

本任务只准备可审查的下一步只读核验候选，不执行现场核验。主要结果放在 EVIDENCE/AUTH-102-DB-BACKUP-TARGET-IDENTITY-PREFLIGHT/plan.md；必要时可在同一目录提供固定探针和纯虚构负向测试。仅允许写该新证据目录。现有源码、配置、已接受证据和控制文件只读；保留两个无关未跟踪目录。

## Phase A 工作范围

1. 核对 D:\EliteSync-v10 的 main、HEAD、工作区，以及 CURRENT.md、PRODUCT_DECISIONS.md、REVIEW_GATE.md、AUTH-20/25/49/65/67/68/101 的当前接受边界。只读定位本地 Laravel 数据库连接与 Web 请求路径；不得读取 .env、凭据、私钥、真实业务表行或旧 D:\EliteSync。代码定位优先使用可用图谱，结果不足时再用文件搜索并说明。
2. 设计一个最小、固定目标、失败即停的后继只读核验：分别说明如何证明部署目录 CLI 的有效连接身份、运行中 Web worker 的有效连接身份，以及二者是否指向同一真实目标。明确区分“配置声明相同”“同算法指纹相同”和“实际实例/连接相同”；若无法在不部署新入口或不暴露敏感信息的范围内证明 Web worker，标记 UNKNOWN，并给出需要单独授权的最小替代步骤，不伪造 PASS。
3. 对拟备份账号的全库对象可见性及 dump 所需权限提出最小核验方法，明确 information_schema 可能按权限隐藏对象，因而可见 43 张 InnoDB 表不等于整库完整。列出外部媒体/文件等非 DB 类别待 Owner 或数据责任方界定的边界；不读取、输出或保存对象名、行内容、主机名、库名、用户名、连接串或原始错误。
4. 如果提供候选探针/调用器，固定允许的只读查询、连接/调用次数、超时、输出字节上限、单行脱敏白名单、字段类型、目标指纹比较、错误分类和停点；仅运行纯虚构解析/边界测试，记录精确预算。不得在 Phase A 执行 SSH、HTTP/API、Laravel CLI、真实 DB、Docker、云控制台或 OpenSSL，也不得改生产代码、备份、导出、传输、停写、DDL/DML、部署或删除。
5. plan.md 给出明确 PASS/FAIL/UNKNOWN 表、剩余问题及下一阶段运行前需 Work/Owner 裁决的范围。只交候选和有限证据，停在 Work LEVEL 2 独立审查；不提交、推送、自接受或派发后继。

## 停点

Phase A 的候选通过不自动放行任何真实连接。后续只读 SSH/Web 观察须由 Work 另定精确目标、身份、调用预算与隐私门；真实完整加密备份须在目标/范围、权限、一致性、加密传输、本地密文和隔离恢复准备分别成立后，另立 LEVEL 3 一次性任务并由 Owner 明确授权。AUTH-101、AUTH-99 和其他旧任务的已耗预算不可复用。

Work 已在 EVIDENCE/AUTH-102-DB-BACKUP-TARGET-IDENTITY-PREFLIGHT/plan.md 作 LEVEL 2 ACCEPT，仅接受本地静态预检方案。现有 Web 健康入口不能证明与 CLI 同库；真实目标、拟备份账号权限和完整数据范围仍 UNKNOWN。此任务不再可执行，不准以该 ACCEPT 自动发起 SSH、Web 诊断或真实备份。生产诊断方式与具体受限运行须另经任务及风险门，涉及部署或真实数据时由 Owner 对具体候选决定。
