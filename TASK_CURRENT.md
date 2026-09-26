# EliteSync v10｜TASK_CURRENT

Task ID: AUTH-126-ECS-INSTANCE-BINDING-VIEW-STATIC-CANDIDATE

Risk Level: LEVEL 2（未来阿里云控制台目标实例只读绑定；本轮仅静态候选）

Status: REJECTED — WRONG PRODUCT CLASS; NO LOGIN OR SITE ACTION

Assignee: 最新合资格 Codex 执行会话 `01a0dc31-b629-76a3-85fd-f71566b03056`；Work 独立 LEVEL 2 审查。

## 目标与授权边界

AUTH-124/125 仅接受静态信任路径和公开官方资料预检；云账号、地域、实例 ID、现时公网地址、服务器 host-key 独立来源和有效 SSH 端口仍 UNKNOWN。Owner 已说可取得阿里云账号登录权限，但密码/真人识别须由本人本机处理；Owner 要求遇到密码或可能 UAC 前停。`AUTH-123` 的本机 `INPUT_CR` 不提供服务器信任。

本任务只制作未来**一次 ECS 控制台实例绑定只读查看**的精确候选，主要结果为 `EVIDENCE/AUTH-126-ECS-INSTANCE-BINDING-VIEW-STATIC-CANDIDATE/plan.md`。只允许写这个新文件；其余项目文件只读，保留两个无关未跟踪目录。

## Phase A 工作

1. 核对本地 Git/工作区、五份入口、项目技能、AUTH-02/17/123～125 的精确受限结论和官方 ECS 实例详情文档。固定未来只读查看的官方入口/页面类别、允许点击的最小范围及退出点；若公开资料不能可靠固定 URL/步骤，就标 `UNKNOWN`，不得猜测或访问 Owner 账号。
2. 定义未来单次查看前必须由 Work 固定的旧目标地址/实例线索，以及 Owner 在控制台内如何确认账号、地域、唯一实例、实例 ID、当前公网地址与观察时点；一个字段缺失、多实例、地址漂移或页面变化即止。普通证据只接收 `TARGET_BINDING=YES|NO|UNKNOWN`、来源/时点、失败类别和预算，不保存账号、实例 ID、页面原文、截图或凭据。既有历史地址只能当待核对线索，不当目标事实。
3. 明确登录页、密码、验证码/真人识别、权限弹窗、UAC 之前的停止条件。Phase B 将来若可能涉及这些步骤，须另经 Owner 在当前 Work 会话具体授权；本轮不打开登录页、不请求密码、不诱导 Owner 提交截图。实例绑定即使成功也不放行 VNC、云助手、SSH、host-key 读取或 DB。
4. 记录未来预算、失败即停、审计/退出和并发/页面变更风险；作者静态检查最多 2 轮，不运行测试。写最终哈希、未证明项，停 Work LEVEL 2 独立审查。

## 禁止与停点

不得登录阿里云、打开账号控制台/VNC/Workbench/云助手、输入或请求密码、触发 UAC、连接 SSH/DB、重读 `known_hosts`、运行任何真实工具、备份/导出/传输、修改生产状态、提交或推送。AUTH-121/122/123 的真实本机读取各 1/1 已耗尽，AUTH-107 Phase B 未放行，AUTH-99 禁止运行。本轮静态候选不是现场许可。

Work 已独立 REJECT 本任务 ECS 产品类别前提，见 `EVIDENCE/AUTH-126-ECS-INSTANCE-BINDING-VIEW-STATIC-CANDIDATE/plan.md`：AUTH-24 记录 Owner 当时确认后端为上海轻量应用服务器，同次 ECS 列表未见实例。作者仅交错误类别停点记录，未登录或访问目标。后继须另立轻量应用服务器的静态任务，不能复用本任务为现场许可。
