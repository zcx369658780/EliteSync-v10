# APP-G11-04｜通知与 Chat 历史身份的剩余兼容边界映射

状态：`ISSUED`；风险 `LEVEL 2`（通知/Chat 身份与权限边界，docs-only）；派发 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。唯一交付本目录 `plan.md`，然后停 Work 独立 LEVEL 2 审查。

## 目标与固定来源

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 保留。先读根五文档与本地 workflow 技能、APP-G11-01～03 的 `work-review.md`、`docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md` 的 G-11。限定只读检查当前本地 `apps/flutter_elitesync_module/lib/features/notification/presentation/pages/notification_center_page.dart`、`domain/entities/notification_item_entity.dart`、`app/router/app_router.dart` 中 Chat/通知路由与 `chatRouteStateFromPath`、`features/chat/domain/entities/chat_route_state.dart`、`data/dto/conversation_dto.dart`、`presentation/pages/conversation_list_page.dart`、`chat_room_page.dart`，及这些符号的直接调用定义/对应定向测试；若图谱结果不足，回退到固定文件并注明范围。

`plan.md` 用精确文件/符号证据区分：通知 `routeName`/`routeArgs` 的各兼容入口、已接受的 `status_author`/`chat_room` 失败关闭；Chat 直接 URL、typed extra、legacy peer、eligible match、stored conversation 的身份解析与权限门；哪些仍是 APP-T12 G-11 兼容债、哪些已有本地防护、哪些需要上游真实 actor/audience 或产品决定。只建议**一张**无需真实数据的最小后继工程切片，列明输入、候选允许文件、可验证负例和不能证明的权限。不得凭旧 route/payload 身份推断同意、会话读取、发送或真实通知投递，也不得重复把 APP-G11-01～03 已接受切片当新缺口。证据不足则写 `NOT_READY` 与缺少的精确来源。

## 预算与停点

最多两轮本地只读静态核对，逐轮记录固定来源和发现；不得运行测试、构建、包管理、网络、DB 或设备命令。只新增/修改本目录 `plan.md`，交付时报告文件 SHA-256、目标状态、两轮预算及未解门。作者不发布后继、不自验收、不提交/pull/push，不访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API。旧预算不重置；真实 Conversation 权限、G-08、AUTH-170、AUTH-155 Phase B 和账号/恢复门不变。
