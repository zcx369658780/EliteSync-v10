# EliteSync V2 P0.4.2 R1 集中工程复验

2026-11-22（北京时间）。**CODEX_REPORTED / R1 PARTIAL / ANDROID CANDIDATE VERIFIED / DEVICE ACCEPTANCE NOT_RUN / CLOSED BETA NO_GO / PRODUCTION NO_GO**。

本回执归入[原 P0.4.2 固定任务单](https://github.com/zcx369658780/EliteSync-v10/blob/fbf89b4248f2151d029b64ea82542043e9eee0a4/docs/versions/v2/V2_P0_4_2_CONVERSATION_GENERATION_HISTORY_ISOLATION_AND_DEVICE_GAP_CLOSURE_TASK_20261121.md)。顾问集中复验与 Owner 产品验收待完成。

## 固定工程身份

| 项目 | 固定值 |
| --- | --- |
| 本机构建和运行工作树 | `D:/EliteSync-v10/build/p042-v2-worktree`，`codex/v2-function-completion-20261121`，工作树及暂存区干净 |
| 本地工程源码 | `3344427e9c6073e13955e6ce7754145b9c10caf2` |
| GitHub 同树工程源码 | `8c0fc3b2f869bd6ef902267dcf55a85eb0279d80` |
| 共同 Git tree | `4d7a0bac0514515b71771e3ef5036ea5697d25a8` |
| 治理分支固定提交 | `fbf89b4248f2151d029b64ea82542043e9eee0a4` |
| R1 业务镜像 | `elitesync-v2-function:p042-r1-3344427e`，`sha256:8192180a6cd60ac9b072b223b55ab1f2942824eb6f2978cd753e88bfce3aa0ee` |

历史起点的 GitHub 源码 `1f32b1e1`、交付 `6f896ad4` 和本地源码 `4572b9e4`、文档 `683e70d7` 继续用于追溯。R1 源码修复使用后续已核对同树的提交。延续原工作树、原脏 main 和既有数据库卷。此份交付只更新脱敏文档。

## 历史访问与离线合同

D-03 使用保守历史访问策略，关闭 Connection 或撤销消息同意后关闭旧代访问。APP-T07 将 Conversation 的授权与路由身份及传输状态分开。服务端按 CN 与 MC 组成代际，并将读取、预览、搜索、ACK、回复、附件与通知绑定到当前代际。PHP 的会话授权、消息读写和 Block 路径按用户 ID 升序逐条加锁，锁后继续验证当前权限。[D-03 合同](../../../architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md) · [APP-T07 合同](../../../architecture/ELITESYNC_V10_APP_T07_CONVERSATION_AVAILABILITY_MESSAGING_CONSENT_FOUNDATION_ACCEPTANCE_V0_1.md) · [源码差异](https://github.com/zcx369658780/EliteSync-v10/compare/1f32b1e1c71d3785abbf9a714e36ebfbf4b43f6b...8c0fc3b2f869bd6ef902267dcf55a85eb0279d80)

Owner 已确认方案 B 首版。离线阅读授权从签发起最多 24 小时，绑定账号、设备、登录上下文和代际。持续离线只显示授权内已下载文字及同代文字引用，媒体、通知和列表正文预览需在线复核。冷启动需联网解锁，离线前后台切换遵守当前授权有效期，恢复联网须以当前服务端代际重新核验；失权或换代时旧正文、旧附件、旧引用和旧预览被撤回。完全离线期间，服务端撤权由设备恢复联网后获知；有效期届满也关闭本地阅读。30 天密文保留期限单独管理。[Owner 方案 B 决定](../../../decisions/OWNER_V2_P0_4_2_OFFLINE_HISTORY_OPTION_B_20261122.md)

## 同源实测矩阵

| 项目 | 实际结果与范围 |
| --- | --- |
| PHP 8.4.28 / SQLite | 57 项、822 断言，56 PASS、1 FAIL。唯一失败为 `V1011SocialTest::test_privacy_posts_and_revocation_do_not_disclose_deep_fields` 的历史 409/200 断言。旧用例修订为 OWNER_DECISION_REQUIRED |
| Flutter 静态分析 | 原 L3 回执记录变更文件定向分析通过。新增的会话重验和通知测试文件分析无问题 |
| Flutter 执行 | 原五套 69/69 PASS，含 66 项 Widget。补跑会话重验 13/13 和通知中心 41/41，七套累计 123/123 PASS，含 107 项 Widget 和 16 项纯 Dart |
| 专用 MariaDB 10.11.19／HTTPS | `elitesync_v2_function`，`server_id=2621121`，原卷保留。既有并发矩阵 9/9、68 个 HTTP 响应，双方向并发 HTTP 500、1213 均为 0。新增 9/9、118 个 HTTP 响应，覆盖旧通知脱敏、分页／搜索、ACK、预览／未读、回复、旧 Conversation、同一 CN 内换 MC，以及旧消息和 Conversation 行保留 |
| 同镜像独立 MariaDB／私信附件 | `server_id=2621123`，现有本机测试运行。附件矩阵 8/8 PASS，双向上传合成 PNG，受众可读，Block 换代后拒绝旧 URL 和旧附件重用，新代可读。旧附件关联、旧消息行和存储文件 SHA-256 前后一致 |
| Workerman 真实 WebSocket | 前序 4/4 PASS，回环实际收到 101，覆盖握手、轮询、撤权关闭和换代重连。新增 1/1 PASS，旧令牌轮换后现有连接关闭，旧令牌及错账号握手拒绝，现行令牌重连收到真实事件。正向 socket 与附件共 133 个辅助 HTTP 响应，HTTP 500 为 0 |

专用合成夹具的私信发送策略实测拒绝附件并返回 `422 fixture_text_only`，附件正向验证在同镜像独立库执行。中途有一次驱动误用通知表名，读取日志保留，改用项目模型后通过。正式矩阵只使用合成账号及媒体。独立测试服务已停止，专用库及回环 R1 服务保持运行。

**ADVISOR_SOURCE_SPOTCHECK**：原顾问限定接受 A09 服务端候选。独立 GPT L3 已核对缓存竞态、限制范围和事务锁，结论为静态范围可接受。这里的 PASS 来自本机实际运行，等待集中顾问复验与 Owner 接受。[独立 L3 源码回执](V2_P0_4_2_R1_BUILDER_L3_REVIEW_20261122.md)

## 候选、历史账与准入

- **APK 已核验**。`com.elitesync.v2functionp042r1`，`1011807`，ARM64，209,094,080 字节。APK SHA-256 `6ab17ca59e3f788b2f37ea7e3bea37d664a836e11e46e32c3c56aa1ccc786983`，APK v2 证书 SHA-256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。AAR／APK 内的 `libapp.so` 逐字节相同，原生与 Dart API 均为 `https://127.0.0.1:18444/`。嵌入与实时 TLS 证书 SHA-256 均为 `41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`。候选原件保留在本机。
- **FAIL 保留**。1011806 A09 实机旧代消息重现、PHP 历史 409/200、旧版本并发 500 与 1213 均保留原始证据。前序运行环境 10013、10057 和构建包装工程缺失保留原分类。历史 1011806 首次安装受限的原因维持 UNKNOWN。
- **设备 NOT_RUN**。1011807 安装、冷启动和 A/B 双端换代、24 小时离线与重联真实设备、Photo Picker、手机 PNG/JPEG 上传及故障窗口、图像/缩略图缓存和历史受众、过期 URI／旧通知及 WLAN 四个故障窗口待实机验证。1011805、1011806 仍并存。本轮无设备写操作。Owner 单独授权须绑定上述 APK SHA-256 和 `25060RK16C`。
- **封闭内测与生产 NO_GO**。真实旧管理员恢复及本人验证、共享受限 HTTPS、未验收实机范围、顾问集中复验和 Owner 准入仍待。当前 24 小时离线合同已有 Owner 决策，PHP 旧断言修订单列待决。

[补充清单](V2_P0_4_2_R1_VERIFICATION_CHECKLIST_20261122.md) · [脱敏证据索引](V2_P0_4_2_R1_EVIDENCE_INDEX_20261122.md)
