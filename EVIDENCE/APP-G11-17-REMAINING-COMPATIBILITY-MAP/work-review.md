# APP-G11-17 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，限定接受 docs-only 的当前 G-11 剩余边界映射。** Work 核对 `plan.md` 当前 SHA-256 `A8ECE829E76A1365760CC65E70BD4897A497179EFE1B027338FB70B57BEDFFDF`。当前 `chatRouteStateFromPath` 在 typed extra 与数字路径不匹配时继续解析数字并构造 legacy peer，确有本地身份降级候选；此前定向测试没有覆盖该组合。通知 payload 历史名称全集及真实权限仍无证明，APP-T12 G-11 不因此结清。作者两轮静态预算 2/2，未运行测试或改代码。

**后继范围修正**：仅让解析函数在 typed 不匹配时返回 null，仍可能使 `/chat/conversation-<id>` 进入页面构建器的 stored URL 详情回退。若下一任务要求 typed 不匹配一律失败关闭，必须同时核对并守住 `app_router.dart` 的页面构建器，保留完全没有 typed extra 时的合法直达 URL 和数字旧 peer。原计划的唯一后继建议只作为选题，不直接作为充分实现方案。

该映射和建议不证明实际真实权限突破；live Conversation 路由仍 404。G-11 其它债、G-08、AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填不变。旧预算不重置，本地 main HEAD 未动，无提交、pull、push。
