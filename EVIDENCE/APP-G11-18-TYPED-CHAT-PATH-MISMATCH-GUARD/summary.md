# APP-G11-18｜Typed Chat 路径不匹配失败关闭候选

状态：Codex 本地候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；全部既有 dirty/untracked 保留，无提交、pull、push。

| 允许文件 | 输入 SHA-256（与任务单一致） | 最终 SHA-256 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/app/router/app_router.dart` | `88659FA22A70432031594AA660171A4AC253B11C301FFF4B7FBADFE866FA0F81` | `37F80AE948753FB389EABB36F7F257C64B6662E1A299A1F14B5E1B70B387FF12` |
| `apps/flutter_elitesync_module/test/app/router/chat_route_state_router_test.dart` | `E8B4608B87D233E4F8B80C13D6B259F041A86698ED2D6106D9072360674BA8D9` | `5459B50D9DA5FBB86CA31C47BD84EF0BA0A6C655AFBE35352BF1D03CF4DE2A29` |
| `apps/flutter_elitesync_module/test/app/router/stored_chat_direct_route_binding_test.dart`（原已未跟踪） | `E4A57BB5B3B8C325B1B84A9E616108A2A1B68F986DD707DE956EC7B9CB5134E7` | `4A1C1CEFDB1BDAECFF31EBCBE9028BCC86107BAC788A4D5D213F8571D20A3474` |

目标差异：`chatRouteStateFromPath` 遇 `extra is ChatRouteState` 时只接受 `canonicalSegment == segment`；不匹配直接返回 null，不再把数字路径转为 legacy peer。Chat 页面构建器在此类 null 结果且仍有 typed extra 时显示既有 `_InvalidChatRoutePage`，不再进入 `conversation-<id>` 的无 typed 详情回退。完全没有 typed extra 的数字旧 peer 和 stored URL 详情核验保留；普通字符串 extra 的数字旧 peer 行为保留。权限、Chat 页面、DTO、后端与通知未改。

单元测试补 typed stored/eligible 与数字路径不匹配的 null 结果，并明确无 typed extra 数字旧 peer 正例；原 typed canonical 匹配、字符串 extra 旧 peer 正例保留。直达 widget 夹具新增三例：typed stored/eligible 对数字路径、typed stored 对另一 stored URL，均显示安全无效路由页，不构建 `ChatRoomPage`、不显示私密占位文案。夹具先以原无 typed `conversation-41` 正常解析一次详情，再导航到不匹配路径；详情请求列表保持 `[41]`，证明**本次不匹配导航没有新增详情查询**。原无 typed stored URL 正例及五类详情错误/未授权场景保留。

编辑前三文件哈希吻合，`.dart_tool/package_config.json` 和本地 `dart`/`flutter` 可用。必要编辑后对三文件各执行一次 `dart format` 写入（报告 3 文件中 2 文件改变排版）；最终格式下的一次 `flutter test --no-pub test/app/router/chat_route_state_router_test.dart test/app/router/stored_chat_direct_route_binding_test.dart` **退出 0，32 个用例全部通过**，未复跑。三文件各一次只读 `dart format --output=none --set-exit-if-changed` 均退出 0、0 changed；三文件 `git diff --check` 退出 0，仅有 Git LF→CRLF 将来转换提示；原未跟踪 widget 测试另查行尾空白，退出 0。新预算：目标测试 1/1、格式写入各 1/1、只读复核各 1/1、空白检查 1/1；旧任务预算未重用。

本结果只证明人工本地路由身份失败关闭，不证明真实 Conversation consent/read/send、actor/audience 或线上兼容。回退仅撤销本任务三文件新增差异及本摘要，保留 APP-G11-01～17 和全部其它工作区。live 404、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填门不变。
