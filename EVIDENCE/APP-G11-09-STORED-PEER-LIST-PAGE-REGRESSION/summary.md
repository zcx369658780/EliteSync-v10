# APP-G11-09 作者候选摘要

状态：test-only 候选已交付，待 Work 独立 LEVEL 2 审查；未自接受。本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be` 未移动；无提交、pull、push。

## 候选与结果

仅在 `conversation_list_page_test.dart` 新增三个人工 stored 列表点击负例：正 `conversationId=41`、数字旧 `id='23'`，但 `peerUserId` 分别为 null、0、-1。逐例核对现有安全提示、路径仍是列表、Chat 目标路由没有构建、没有 typed extra 传入，目标页私密占位文案未显示。文件原有显式正 peer 的 stored typed-route 正例和 APP-G11-07 四类矛盾项负例均在目标文件首跑中通过。

## 一次性预算与验证限制

- 指定 `flutter test --no-pub test/features/chat/presentation/pages/conversation_list_page_test.dart`：首跑 **1/1、退出 0、23/23 通过**；夹具修正复跑 **0/1**。没有运行完整套件、设备、网络、后端或真实数据验证。
- `dart format` 写入 **0/1**，`dart format --output=none --set-exit-if-changed` 只读复核 **0/1**。该目标文件已有 APP-G11-07 接受时保留的最终格式未复核限制；为保持本任务仅新增测试的精确差异，未让 formatter 改写既有段落。**最终格式工具结果未建立**，不得写成通过。
- 最终目标文件 `git diff --check` 退出 0。相对 Git HEAD 的 168 行新增包含 APP-G11-07 已接受的 87 行；本任务新增 81 行，未改已有测试和产品代码。

| 文件 | 输入 SHA-256 | 最终 SHA-256 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/test/features/chat/presentation/pages/conversation_list_page_test.dart` | `2D4D2664C4A97571FEBC87E1CCCACF68FA298408DE52C55DA48AB95F36B89935` | `9D7D5749C759F19DA44AA3D61B753F9938C78EA7250FD68CCE408C2F8387E239` |

回退只撤销本任务新增的三例与本摘要，保留 APP-G11-01～08 及全部无关 dirty/untracked。人工列表与本地 router 夹具不证明真实 Conversation consent、read/send、actor/audience 或生产兼容；G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填门不变。
