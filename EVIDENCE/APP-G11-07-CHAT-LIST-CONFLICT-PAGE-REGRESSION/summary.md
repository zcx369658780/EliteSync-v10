# APP-G11-07 作者候选摘要

状态：test-only 候选交付，待 Work 独立 LEVEL 2 审查；未自接受。本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be` 未移动，无提交、pull、push。

## 候选

只在 `conversation_list_page_test.dart` 新增四个人工列表点击负例：`legacy_peer`、`eligible_match`、缺省类别携带会话 ID，以及 `stored_conversation` 缺失 ID。每例检查现有安全提示、路径仍为列表、Chat 目标路由未构建、没有 typed extra 传入、目标页私密占位文案未显示。文件原有有效 stored typed-route 正例保留并在目标文件复跑中通过。测试未接入真实 writer；不进入 Chat 目标页是本次对 writer 不触发的局部页面边界证据，非真实发送权限证明。

## 一次性验证与格式限制

- 指定 `flutter test --no-pub test/features/chat/presentation/pages/conversation_list_page_test.dart` 首跑 **1/1、退出 1**：既有用例通过，四个新增负例因新夹具根路由缺少 `Scaffold`，`AppFeedback.showInfo` 无处显示而失败。仅在新夹具补 `Scaffold`。
- 唯一夹具修正复跑 **1/1、退出 0、20/20 通过**，包括四个新增负例和既有 stored 正例。复跑后未改测试语义。
- 对目标文件执行一次 `dart format` 写入（退出 0）与一次只读 `dart format --output=none --set-exit-if-changed`（退出 0、当时 0 changed）。该写入同时改动了大量既有排版；随后为保留任务范围内的最小差异，从未改的 Git 内容恢复既有排版，仅保留新增测试。**最终文件未再执行格式复核，不能宣称最终格式通过**；格式预算已耗尽。最终没有重跑测试，因为恢复只涉及既有排版且新增测试内容未变。此项留给 Work 独立审查裁决。
- 最终目标文件 `git diff --check` 退出 0；差异仅新增 87 行。未运行完整套件、设备、网络或后端验证。

| 文件 | 输入 SHA-256 | 最终 SHA-256 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/test/features/chat/presentation/pages/conversation_list_page_test.dart` | `8851A2D8E4F1E097C27A72CFC06BDFA834A521F85A1A58DC4702FE1C85274515` | `2D4D2664C4A97571FEBC87E1CCCACF68FA298408DE52C55DA48AB95F36B89935` |

回退仅撤销目标测试文件新增的四个测试及本摘要，保留 APP-G11-01～06 与全部无关 dirty/untracked。人工本地 provider、列表导航证据不建立真实 Conversation consent、read/send 或 actor/audience 权限；G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、账号与恢复门不变。
