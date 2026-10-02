# APP-G11-03 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，限定接受本地 Chat 通知到已存会话路由的身份绑定修复。** Work 核对两允许文件当前 SHA-256：`notification_center_page.dart` 为 `EF06A8D40544338DB51C3DC3EDB1CD208D7D1FA54BFE703F1F722640869E69CE`，其测试为 `FBBBB85B857AEC6811F6C3D8DF132BA05A3E6C012914092DD3F461CBE420CE8C`，与作者摘要一致。候选只在 `chat_room` 分支要求解析结果明确为 `stored_conversation`、返回正会话 ID 等于通知 ID 且 peer ID 为正；路由身份使用已解析 ID，不再由通知参数补造。正常 stored 测试及原 `status_author` 失败关闭保留。

人工缺失 ID、不同 ID、legacy、eligible 和 unknown kind 五个负例核对不导航、不自动标记已读、使用安全提示且不显示 raw 私密文案。作者目标测试文件首跑退出 0、20/20 通过；两文件最终格式复核与 `git diff --check` 退出 0。Work 未复跑测试或复用作者预算。

这只证明本地人工 provider override 下的入口行为。真实 Conversation 读取/发送权限、通知后端真实性及生产兼容仍未建立；G-11 其它债、APP-T12 G-08、AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B、真实 CMS 认证/隔离恢复及账号回填不变。旧预算不重置，既有工作区保留，无提交、pull、push 或受保护操作。
