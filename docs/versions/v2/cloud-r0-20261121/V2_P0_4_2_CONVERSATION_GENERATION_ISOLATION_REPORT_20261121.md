# EliteSync V2 P0.4.2｜会话代际隔离工程回执

2026-11-21（北京时间）

**本地候选已实现，SQLite 隐私回归通过。MariaDB、Flutter Widget 和修复后实机复验未完成。封闭内测与生产仍为 NO_GO。**

## 固定身份和工作树

- 治理提交 411e6d91a77106944aa953ce2c391c24d1eafec6。P0.4.1 实机源码 00ca46f6b020afa25ce472509c2fd3227f74c461，设备报告 e4d1588acee62d8f8f166042c328e26cc951c14a，原交接 9fd84d2f2fd27d7226e8eb792de5d8cc829e9e82。
- 按 Owner 指示，从固定交接提交在 D:/EliteSync-v10/build/p042-v2-worktree 建立独立 Git 副本，沿用 codex/v2-function-completion-20261121。副本使用原仓库的只读 Git 对象作为基线。原脏 main、旧工作树及设备证据留在原位置。
- P0.4.2 候选源码 4572b9e4d6b6a07e04fabb6e33c244575c9d61bc。Android 1011805、1011806 及其数据未操作。新候选 APK 未构建、未安装。

## A09 的服务端修复

- 现行 CN 和消息同意的服务端授权生成独立的 room key。新消息和 Conversation 使用同一个代际标识，通过现有 room_id 索引与 room_key 唯一约束隔离。换 CN 或在同一 CN 内换 MC 都创建新的读取范围。
- 既有未标代际的 pair room 没有可证明的 CN/MC 归属。启用代际授权的链路默认隔离这些历史，已有 CN 的账号对也无法退回旧 pair room。旧记录与附件原样保留，无回填、迁移或删除。
- 列表、分页、搜索、已读、回复引用、同键重放、附件下载、通知跳转、预览和未读均绑定当前代际。旧 Conversation ID 失效。WebSocket 握手和轮询绑定当前代际并在 pair 锁内核验；授权范围变动后旧连接失效。
- Flutter 从服务端读取代际标识。发现切换后清除展开历史、预览及旧缓存并重读。搜索结果也按代际清理。暂时离线时继续遵循既有私有缓存策略；设备脱网后发生的远端撤权须待联网获知。

## 回归与证据

| 检查 | 本轮结果 |
|---|---|
| PHP 双向 Block、建立第 2 代 CN 与 MC、A/B 收发新消息 | SQLite 通过。两个 Block 方向均覆盖。 |
| PHP 同一 CN 内撤销并建立新一代 MC | SQLite 通过。当前会话只读取新一代 MC 下的消息。 |
| PHP 消息列表、latest/after/before、搜索、已读、回复、同键、附件和旧 URL | SQLite 和本机合成 PNG 用例通过。 |
| PHP 两代会话详情、预览、未读、旧通知及 WebSocket 授权 | SQLite 通过。真实 Workerman socket 连接未跑。 |
| 数据保留 | SQLite 用例逐字段比对旧消息原始行，确认旧 Conversation、附件关联及合成 PNG 字节保留。专用 MariaDB 的 Docker Linux 引擎未连接，本轮 MariaDB 为 NOT_RUN。 |
| PHP 具名结果 | ConversationGenerationIsolationTest，3 项、216 断言通过。另一次扩围同时包含 V1007PrivateMediaTest、V1011NoticeRevocationTest、V1015WsAuthorizationTest、ConversationCapabilityFoundationTest、MessageApiTest、V1011SocialTest，共 57 项、869 断言，56 项通过。 |
| 历史 PHP FAIL | V1011SocialTest::test_privacy_posts_and_revocation_do_not_disclose_deep_fields 再现预期 409、实得 200。P0.4 的 60/61 历史原结果保留。 |
| PHP 运行身份 | PHP 8.5.3、PHPUnit 12.5.42。114 个 Composer 包版本与来源引用对照 lock 一致。项目要求的 PHP 8.4 未复验。所有变更 PHP 文件通过语法检查。 |
| Flutter | 两份改动 Dart 页面和具名回归文件通过静态分析。live_chat_history_test.dart、conversation_revalidation_gate_test.dart、notification_center_page_test.dart 的测试运行器在本机回环连接阶段报 10057，未加载测试，执行结果为 NOT_RUN。 |
| 实机遗漏 | Photo Picker 选图返回、端上 PNG/JPEG 上传、SELF/FRIENDS 全历史受众、缩略图缓存、旧链接、过期和跨账号对象、正向候选/正式关系和 Buddy 双方链均未补测。 |
| 无线和 USB | 1011806 仍固定回环端点。USB reverse 可用与真实无线链路中断是两项独立测试。本轮无 USB 操作，真实无线四窗口均为 NOT_RUN。 |

顾问集中验收待进行。A09 的 1011806 实机历史 FAIL 仍保留，修复后正式验收待补。真实旧管理员恢复与共享受限 HTTPS 仍是封闭内测硬门。软著材料仍为准备稿。
