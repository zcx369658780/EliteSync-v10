# 交接与任务下达规则摘要

权威正文：`AGENTS.md`、`docs/workflow/CURRENT_WORKFLOW.md`、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md`、`docs/workflow/SESSION_HANDOFF_TEMPLATE.md`。

## 新会话首读
只读三项：`AGENTS.md`全文 → `ACTIVE_STATE.md`最新CURRENT ENTRY → 最新具名handoff全文。完成后停止首读；不递归旧handoff，不默认读plan、全量日志、全部Owner决定或全部Project Sources。

## 按需补读
- 已有明确任务：读正式任务全文，再读任务明确引用的冻结plan/专项合同。
- 需要作产品/技术决策：先明确待决问题，再从GitHub读取直接相关的Owner决定、合同、源码/测试或原始证据。
- 不确定证据是否仍适用：核对源码Tree/Blob、环境、合同版本和失效条件；只做增量复核。

## Session Handoff
固定六项：Current State / Completed / Current Objective / Required Sources / Owner Decisions / Next Action & STOP。目标300–600字，通常不超过1000字；仅保留状态差异、当前目标、必要路径/Blob、授权和停止条件。它是导航摘要，不是第二份ACTIVE_STATE或任务单。

## Codex任务
一份冻结plan、一份综合长任务、一个持久账本、一个候选、一次集中独立验收。任务单只写Objective、Baseline、Scope、References、Acceptance、Budget、Restrictions、Delivery。普通失败在授权范围内自主修复，不拆微任务。

启动Prompt只写任务路径+Blob、fresh读取要求、授权范围、STOP与交付要求；目标约100–200字，不复制任务单正文。Owner手动派发；发布不等于派发，派发不等于执行。

A–D仍是任务发布质量闭环，不是逐步骤审批：核授权/状态/基线/预算；创建唯一任务并读回；更新状态并回读live main/Root/任务/状态；一次交付链接、Blob、最终状态和单一Prompt。一次性预算不重置、不退款、不重试。超范围、生产数据、敏感外传、真实费用、系统安全设置、供应商/实人及不可逆动作须具体授权。
