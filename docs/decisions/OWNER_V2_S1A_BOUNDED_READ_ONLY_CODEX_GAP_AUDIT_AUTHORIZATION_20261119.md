# EliteSync V2｜Owner S1-A一次性受限只读工程差距核查授权

日期：2026-11-19（Asia/Singapore）  
仓库：`zcx369658780/EliteSync-v10`  
治理分支：`governance/home-matching-product-freeze-20261117`  
状态：`OWNER_S1_A_READ_ONLY_AUTHORIZED / CODEX_S1_READ_ONLY_ONLY / V2_IMPLEMENTATION_NOT_AUTHORIZED / A6_MEETING_DEFERRED`

## 1. 明确的Owner授权

网页GPT顾问在[未来S1授权草案V0.1](../workflow/V2_S1_BOUNDED_READ_ONLY_GAP_AUDIT_AUTHORIZATION_PROPOSAL_20261119.md)中单独请Owner选择`S1-A`（未来由指定本地Codex在实际唯一工程根下，对R1–R5作一次受限**只读源码与合同差距核查**，不运行测试、不改动源码，交付一份脱敏静态差距报告）或`S1-B`（仍不开放本地代码审阅）。顾问明确询问：“您是否同意授权S1-A，只进行一次受限只读的本地工程差距核查？”

Owner明确回复：

> 我同意授权，请继续

本次确认有唯一明确对象，即前一轮S1-A。根据项目本地优先工作流，受授权方为**当前已有的EliteSync本地Codex项目会话**，不新开独立会话。**本文件只是GitHub中记录Owner的授权，网页GPT当前未连接/操作Owner的Windows代码树，也没有代Codex完成S1。**

## 2. 授权目的、范围及身份先决条件

目的：只读辨认本地真实工程中哪些现有结构**可证明存在**、部分存在、缺失、或目前无法确认；与已经具名Owner接受的V2业务规则对照，形成单份差距报告。

- 允许从**现有EliteSync Codex项目会话的工作目录**开始，使用不会改变代码/工作树的命令辨认实际本地Git工程根、remote(只报告去敏仓库身份)、分支、HEAD、工作树是否存在未提交变化。项目候选历史根有`D:\EliteSync-v10-product-v1015-20261101`，但这是历史路径**不是**“当前唯一活动根已核实”的证明。若实际活动工作树是另一已有worktree，须依据本地既有项目上下文和Git身份确定；不得因历史路径名相似而盲切换或复制。
- 若工作树、所属仓库、活动根或Owner授权对象无法唯一确认，**立即停止深层审阅**，仅报告`IDENTITY_UNRESOLVED`与可公开的去敏路径信息，等待Owner决定；绝不搜索遍历全部磁盘或擅自修改工程根。
- 一经确认唯一活动根，可**只读**审阅其源码、接口/类型声明、配置键名、迁移**定义文件**、已有测试**源码**与必要架构文档；只通过静态阅读确定现有能力，不读取运行中的真实数据库或服务。
- 允许只读终端工具完成身份和文件定位，例如`pwd`、`git rev-parse`、`git branch --show-current`、关闭可选锁的`git status --porcelain`、`rg`/`git grep`、列目录及读取获准文件；**只读命令允许，不等于允许执行项目代码、测试/构建/脚本或连接网络**。
- 可通过本次会话提供的GitHub**治理文档固定引用**判断Owner产品合同；不为取得新资料而`git fetch/pull`或改变本地工程。不同版本信息要注明身份，不用治理HEAD代替本地HEAD。

## 3. 严格禁止的动作

- **不改动任何本地工作树文件**，包括源码、配置、迁移、测试、报告、任务单、Git index/工作树重置；不新建分支、commit或push。必要报告**仅在现有Codex会话回复中给出**，不默认向本地目录/GitHub写报告文件。
- 不运行任何项目执行命令、编译、单元/集成/设备测试、依赖安装、代码生成、服务启动、数据库/Redis查询或写入、迁移、APK、模拟器或真实手机操作。
- 不执行`git checkout/fetch/pull/push/reset/rebase/stash/clean/merge`，不创建新worktree或更换项目工作根；不扫描其它非项目路径。
- 不连接真实身份核验、Push、RTC、外部API、生产环境或第三方账号；不联系或采购供应商，不请求付费服务。
- 不读取/复制/输出`.env`值、密钥、SSH私钥、token、真实身份材料、用户聊天内容、生产数据库配置值、受保护原始日志或任何不必要敏感信息。允许查看非敏感配置**键名/类型声明**；如无法避免接触敏感文件，标`UNKNOWN/SENSITIVE_ACCESS_REQUIRED`并跳过。
- 不召开A6正式UI会议，不发布、合main、申请系统提权或改变产品权利。S1授权**不复活任何旧版一次性测试权限**。

## 4. 一次性合并核查与唯一交付

按[集中证据准备包](../workflow/V2_CONSOLIDATED_FUTURE_EVIDENCE_READINESS_DOSSIER_V0_1_20261119.md)和[S1草案](../workflow/V2_S1_BOUNDED_READ_ONLY_GAP_AUDIT_AUTHORIZATION_PROPOSAL_20261119.md)将G01–G10合并为：

- **R1** 实人核验、Lifestyle、Match/Connection/Messaging Consent/Conversation/Relationship（G01/G09）；
- **R2** 访客/登录内容分域、Block、评论/回复原受众、历史媒体（G02/G03/G08）；
- **R3** SOURCE/PURPOSE/AUDIENCE/SNAPSHOT、用途许可、派生依赖与外显版本（G04/G05/G06）；
- **R4** 对象级删除申请/受理/完成、UNKNOWN、跨账号与幂等（G07/G08/G09部分）；
- **R5** 消息/通知、真实Push接入状态的静态结构、原设计资产路径清单（G09/G10仅结构）。

对每一组/重要缺口提供`PRESENT / PARTIAL / ABSENT / UNKNOWN`的**静态证据状态**、实际文件/符号/行号、具名Owner合同来源、安全默认、外部/法律依赖。仅在查完被授权范围后才能称`ABSENT`，不得把静态`PRESENT`改为运行时`PASS`。**动态G01–G10继续全部`NOT_RUN`**。

一份综合报告应含：实测的本地根/branch/HEAD/dirty-status(不泄露敏感)、R1–R5矩阵、可复核源码证据位置、最重要差距/未知、无法通过静态阅读证明的外部/法律/设备事项、下一步待Owner审批建议；**报告只在既有Codex会话内返回，Owner随后按需转交顾问**。不拆十份任务/审批。

## 5. 结束与不授予的后续权限

本次为**一次性S1只读**授权，形成报告或因身份/隐私风险停止后即结束，不自动进入补修、真实动态验证、供应商选择、S2/S3/S4或下一版本。任何工程实现、正式UI会议、设备、发布、真实供应商均需Owner**新的明确授权**。

保持：`S1_READ_ONLY_AUTHORIZED / V2_IMPLEMENTATION_NOT_AUTHORIZED / A6_MEETING_DEFERRED / G01_G10_RUNTIME_NOT_RUN`。历史旧`CODEX_NOT_AUTHORIZED`仅指本次授权前/除S1外的工程操作，不可用以否定本项新有限授权，也不可反过来当成所有CodeX工程权限已解除。原`10.1.18-dev / 1011804`及UI-AUDIT-01旧`UNKNOWN/NOT_RUN`、实人核验/真实Push未接入、原43 PNG `PENDING_BINARY_UPLOAD`和F-01`READABILITY_PARTIAL`不变。
