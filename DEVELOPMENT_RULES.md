# 2026-10-12 生效：网页 Astra 管理与 Codex 版本实现

当前规则见 [CURRENT_WORKFLOW](docs/workflow/CURRENT_WORKFLOW.md)，导航见 [DOC_INDEX_CURRENT](DOC_INDEX_CURRENT.md)。Owner保留方向决定；网页Astra负责版本规划、最终独立验收与复盘；Codex按冻结版本自主实现、测试、诊断修复并集中交付。旧Work/dot实时管理、逐步骤审批及强制新增多模型循环被本次Owner指令替代。产品/科学定义、真实数据、不可逆风险及历史固定证据保留。

下方为历史记录：其中旧路由、ISSUED、微审批、逐调用预算、审查角色和Git禁令不构成当前迁移或未来版的自动授权/默认流程。本轮仅文档迁移与正常GitHub发布；旧任务保持暂停，第三阶段由Owner手动启动。普通错误自主诊断；真正边界/决定/持续阻碍才报告。现状以 CURRENT_STATE.md 为入口，冻结版仍按其原计划和证据身份解释。

---

# Development Rules

1. GitHub `main` is the source of truth.
2. AI agents operate within task scope.
3. Architecture changes require Owner confirmation.
4. Server remains business truth.
5. Prefer implementation over excessive planning.
6. Validate changes appropriately for their scope and risk.
7. Historical documents are not active requirements.
8. Keep documentation minimal and current.
9. Do not migrate code or dependencies without explicit scope.
10. Keep commits bounded and reviewable.
