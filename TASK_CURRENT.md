# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-127-LIGHTWEIGHT-SERVER-BINDING-VIEW-STATIC-CANDIDATE

Risk Level: LEVEL 2（未来轻量应用服务器控制面只读目标绑定；本轮静态候选）

Status: ACCEPTED — STATIC LIGHTWEIGHT VIEW CANDIDATE ONLY; NO ACCOUNT LOGIN

Assignee: 最新合资格 Codex 执行会话 `01a0dc31-b629-76a3-85fd-f71566b03056`；Work 独立 LEVEL 2 审查。

## 依据与目标

AUTH-24 `EVIDENCE/AUTH-24-ALIYUN-BACKUP-RESOURCE-CHOICE-PACKET/packet.md` 第 9、13、47 行记录：2026-09-24 Owner 当时确认上海后端目标为**轻量应用服务器**，且同次 ECS 上海列表未见实例。这是历史 UI 事实，不证明今天资源现状。AUTH-126 因错误预设 ECS 获 Work REJECT，未访问账号。AUTH-124 通用信任路径仍有效；AUTH-125 ECS 官方资料不能当目标控制面步骤。目标实例、现时公网地址、独立 host-key 来源和实际 SSH 端口仍 UNKNOWN。

本任务仅形成未来**一次阿里云轻量应用服务器控制台只读绑定查看**的精确静态候选。主要结果为 `EVIDENCE/AUTH-127-LIGHTWEIGHT-SERVER-BINDING-VIEW-STATIC-CANDIDATE/plan.md`；只允许写这个新文件，其余文件只读，保留两个无关未跟踪目录。

## Phase A 工作

1. 核对本地 Git/工作区、五份入口、项目技能及 AUTH-02/17/24/107/123～126 精确状态。仅匿名只读查看**阿里云轻量应用服务器官方文档**，记录可核验 URL、访问日、适用产品和正文支持范围；若页面不可达/内容不足，标 `UNVERIFIED`，不借 ECS 文档补齐。
2. 固定未来 Owner 只读查看的轻量应用服务器官方入口/页面类别、允许的最小页面范围和失败退出点；列出账号、地域、唯一服务器、现时公网地址、实例标识和观察时点的绑定条件。历史目标地址仅为待比较线索；任一不符、多候选、资源更换、页面变化即停，不自行改走 ECS/RDS/其他地域或实例。
3. 普通回执仅固定 `TARGET_BINDING=YES|NO|UNKNOWN`、产品类别、来源/时点、失败类别与预算，不保存账号、实例 ID、IP、页面原文、截图或凭据。登录页、密码、验证码/真人识别、权限提示及任何 UAC **之前停止**；未来 Phase B 要经 Owner 当前会话具体授权，Owner 自行处理密码。实例绑定不证明服务器 host-key、实际端口或 SSH/DB/备份权限。
4. 记录未来单次预算、权限/审计/退出与并发风险，作者静态检查最多 2 轮，不运行测试；交最终哈希、未证明项，停 Work LEVEL 2 独立审查。

## 禁止与停点

不得打开 Owner 账号控制台或登录、触发密码/真人识别/UAC、访问轻量服务器网页的私有页面、远端终端、SSH/DB、重读 known_hosts、运行真实工具、备份/导出/传输、修改生产状态、提交或推送。AUTH-121/122/123 的真实读取各 1/1 已耗尽，AUTH-107 Phase B 未放行，AUTH-99 禁止运行。Phase A 不放行任何现场动作。

Work 已在 `EVIDENCE/AUTH-127-LIGHTWEIGHT-SERVER-BINDING-VIEW-STATIC-CANDIDATE/plan.md` 独立 LEVEL 2 **ACCEPT 仅静态候选**。官方产品页面范围已缩到轻量应用服务器服务器列表/唯一概览，但目标账号主体/地域尚无本次可固定权威，现为 `PRECHECK_MISSING`；地域字段位置及今天的唯一实例/公网地址均未证明。无现场预算放行。下一步在受限方式明确账号主体、地域和 Owner 现场方式后，另作具体风险裁决；遇密码/真人识别/UAC 前按 Owner 指示停止。
