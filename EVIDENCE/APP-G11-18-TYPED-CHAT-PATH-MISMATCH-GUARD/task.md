# APP-G11-18｜Typed Chat 身份与路径不匹配时失败关闭

状态：`ISSUED`；风险 `LEVEL 2`（Chat 路由身份/私密导航）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 精确范围

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，全部既有 dirty/untracked 保留。先读根规则、当前状态、APP-G11-05/17 Work 审查，核对 `chatRouteStateFromPath`、Chat 页面构建器的 stored URL 回退和现有直达 widget 夹具。只允许修改：

| 文件 | 输入 SHA-256 |
| --- | --- |
| `apps/flutter_elitesync_module/lib/app/router/app_router.dart` | `88659FA22A70432031594AA660171A4AC253B11C301FFF4B7FBADFE866FA0F81` |
| `apps/flutter_elitesync_module/test/app/router/chat_route_state_router_test.dart` | `E8B4608B87D233E4F8B80C13D6B259F041A86698ED2D6106D9072360674BA8D9` |
| `apps/flutter_elitesync_module/test/app/router/stored_chat_direct_route_binding_test.dart` | `E4A57BB5B3B8C325B1B84A9E616108A2A1B68F986DD707DE956EC7B9CB5134E7` |

另允许新增本目录 `summary.md`。只在 `extra is ChatRouteState` 且 `extra.canonicalSegment != segment` 时失败关闭：不得把数字路径退成 legacy peer，也不得把 `conversation-<id>` 路径交给无 typed extra 的 stored 详情回退；页面显示现有安全无效路由结果，不构建 ChatRoomPage、不触发详情解析。typed canonical 匹配、完全没有 typed extra 时的数字旧 peer fallback 和无 typed extra 的 stored URL 详情核验均保留。普通字符串 extra 的既有数字旧 peer 行为按当前合同保留。不要改权限、Chat 页面、DTO、后端或通知。

定向人工测试至少覆盖 typed stored/eligible 与不匹配数字路径、typed 不匹配 stored URL 路径的页面失败关闭和无详情查询，并保留上述正例；若现有 widget 夹具无法在三文件范围内可靠注入 typed extra，记录 `NOT_VERIFIED` 并停止，不扩大路径或伪称页面已测。可使用最小只读检查确认当前调用者是否依赖此降级，不据此扩大任务。

## 新一次性预算与停点

编辑前核对三文件哈希、`.dart_tool/package_config.json` 和本地 `dart`/`flutter`。必要编辑后只执行一次 `flutter test --no-pub test/app/router/chat_route_state_router_test.dart test/app/router/stored_chat_direct_route_binding_test.dart`；仅本任务三文件夹具/实现缺陷可修后额外复跑同一命令一次。所有必要编辑后每目标文件最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`；若格式写入仅改排版无需复测。三文件 `git diff --check`，未跟踪文件另核行尾空白。不得运行全套、设备、网络、后端或真实数据验证。

`summary.md` 记录前后哈希、差异、用例/退出码、预算、格式/空白检查、限制与回退范围。回退只撤销本任务三文件新增差异和摘要，保留 APP-G11-01～17 及全部无关工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自接受或启动后继。live 404、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填门不变。
