# EliteSync V2 P0.4.2 R1｜离线前台、实机换代与媒体续验

2026-11-22（北京时间）。**CODEX_REPORTED / R1 PARTIAL / FOLLOW-UP CANDIDATE VERIFIED / OWNER INSTALL AUTHORIZATION REQUIRED / CLOSED BETA NO_GO / PRODUCTION NO_GO**。

本报告接续[原任务单](https://github.com/zcx369658780/EliteSync-v10/blob/fbf89b4248f2151d029b64ea82542043e9eee0a4/docs/versions/v2/V2_P0_4_2_CONVERSATION_GENERATION_HISTORY_ISOLATION_AND_DEVICE_GAP_CLOSURE_TASK_20261121.md)、[集中工程复验](V2_P0_4_2_R1_LOCAL_CLOSURE_20261122.md)和[首个 1011807 实机回执](V2_P0_4_2_R1_1011807_DEVICE_RECEIPT_20261122.md)。阶段性的 `V2_P0_4_2_R1_RUNTIME_EVIDENCE_20261122.json` 继续留档，其中早期未运行状态的后续证据见集中工程复验。

## 身份与变更

本机 `ZCX_265K`，工程工作树 `D:/EliteSync-v10/build/p042-v2-worktree`，开发分支 `codex/v2-function-completion-20261121`。前台修复本地源码 `f127cc689c6fba1a0ed4b994a148e0a78ebac345`，本地构建 Git tree `810cfdef6513b817810bd99d81e4f7019cea6bff`。GitHub 源码提交 `7e0009df4fe69e48967c4fbc111717626c85ed80`，远端保留此前独立文档提交，因此全树身份分别记录。两端 `apps` 和 `services` 比对无差异，Flutter 模块 tree 均为 `a051f659500cbfa96c76fb7fc9003a722507d9d4`。

专用 Docker 数据根 `/var/lib/docker-r0`，原 MariaDB `elitesync_v2_function`，`server_id=2621121`，原卷 `elitesync-v2-function_r0-dbdata`。既有 R1 应用和 WS 镜像继续运行。此轮更改限定 Flutter 缓存、聊天、会话列表和两份测试。前台返回先隐藏旧内容并发起当前读。在同一可信进程的真实传输失败后，才使用原 24 小时内绑定的本代文字凭据。列表获知换代会撤回对应旧凭据并阻止挂载聊天接受迟到响应，页面已关闭时也生效。换代拒绝旧代和未绑定发送尝试，缓存读故障继续锁定。Owner 的授权期限、内容范围及冷启动规则沿用原决定。[Owner 方案 B](../../../decisions/OWNER_V2_P0_4_2_OFFLINE_HISTORY_OPTION_B_20261122.md) · [GitHub 源码差异](https://github.com/zcx369658780/EliteSync-v10/commit/7e0009df4fe69e48967c4fbc111717626c85ed80)

## 本轮实测

| 项目 | 实际执行数 | 结果 | 本机证据 | 剩余条件 |
| --- | ---: | --- | --- | --- |
| 原 APK 手机持续离线（含远端撤权）、同进程恢复前台、冷启动和重联 | 4 类状态 | 3 PASS、1 FAIL。持续离线和远端撤权期间仍只读原已下载文字，发送与编辑不可用。重联只见新代。冷启动无正文。原 APK 同进程恢复前台时未恢复离线阅读 | `09-offline-disconnected`、`10-offline-rotation`、`12-offline-cold-start` | 修复 APK 的同进程离线实机待验 |
| 原 APK 手机 A→B | 1 条链，1 台实体手机及主机 B | PASS。手机确认拉黑，原 CN 关闭、MC 撤销，双方旧历史均 404。新代手机只见两条新消息，旧行逐条比对保留 | `28-device-block.log` 及该次 JSON/UI 证据 | 双物理设备同时运行待验，前次 B→A 回执仍有效 |
| 专用 MariaDB／HTTPS 合成媒体 | 8 组、56 次 HTTP 响应 | 8/8，500 为 0。覆盖损坏 PNG 拒绝、SELF、FRIENDS 原好友、新好友、退出好友、双向 Block、独立对象与原图保留 | `08b-private-cover-matrix.log` | 手机头像 PNG/JPEG 实际选图已在首回执通过。作品、封面和私信附件的端侧原图、缩略图及撤权缓存链待验 |
| HTTPS 头像故障 | 2 组、7 次辅助 HTTPS 回读 | 2/2。multipart 发到一半关闭连接，原状态不变。完整上传后测试客户端不读取响应，持久化一次，按旧修订重试为 409，原图标记读回 | `26-avatar-transport.log` | 手机端中断、丢响应和重试待验 |
| 修复源码定向 Flutter | 121 | 121/121，变更五文件的静态分析通过。扩围总计 144 项，141 PASS、3 FAIL | `24-reviewed-flutter.jsonl`、`25-reviewed-analyze.log` | 3 项 v10.1.5 历史用例在隔离原树比较为同三项 FAIL，修复候选在机复验待授权 |
| PHP 8.4、专用 MariaDB 并发和真实 Workerman | 沿用已通过的具名验证 | PHP 8.4.28／SQLite 56/57，历史 409/200 单列。专用 MariaDB 9/9＋9/9，独立库附件 8/8，真实 WebSocket 5/5 | [集中工程复验](V2_P0_4_2_R1_LOCAL_CLOSURE_20261122.md) | 顾问指出的其他批量锁交叉并发覆盖仍待 |
| WLAN 四故障窗口 | 0 | NOT_RUN。现装包和本候选均使用手机回环。当前仅识别一台 USB 设备，临时 reverse 已归还为空 | `29-final-environment.txt` 及候选端点回读 | 须有可证明实际经过 WLAN 的受控路径和相应 TLS 身份 |

Flutter 七套定向执行为 `conversation_revalidation_gate_test.dart` 13/13、`live_chat_history_test.dart` 16/16、`live_chat_page_test.dart` 43/43、`live_chat_retained_list_cache_test.dart` 11/11、`live_conversation_private_cache_test.dart` 5/5、`offline_chat_text_test.dart` 3/3、`private_cache_service_test.dart` 30/30。隔离原树扩围 23 项，20 PASS、3 FAIL。三项为旧可靠性套件的长窗口离线投影、长文字缓存和大图离线显示断言。源码没有修改这些旧用例。原轮的首个前台用例 RED 和换代重试 RED、早期探针排查及截断日志也保留。第一次仅移除 ADB reverse 的探针中，已有持久连接仍有 25 次消息请求经过诊断中继。随后关闭该中继和连接，并以设备端 TCP 探针及零中继交换确认断链。

独立非作者 GPT L3 初审要求修订，再复核通过。审查覆盖列表与聊天完成次序、迟到的成功响应、关闭聊天后的已知换代、草稿绑定与加密读取故障。原固定交付的顾问范围接受仍以原会话为准，新候选和这份运行证据需集中复验。顾问另有离线本人消息中性状态建议，留在后续账中。

## 新候选与 Owner 实机门

| 项目 | 实际回读 |
| --- | --- |
| AAR | `D:/EliteSync/development/v2-cloud-r0-local-runtime-20261121/p042-r1-android-1011807-resume-20261122/aar/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`，4,912,161 字节，SHA-256 `0a32d647eac6ac18276e18c21307ad2014f76ebed0c197c2c51db25ffce87907` |
| APK | `D:/EliteSync/development/v2-cloud-r0-local-runtime-20261121/p042-r1-android-1011807-resume-20261122/EliteSync-V2-P0.4.2-R1-1011807.apk`，209,094,080 字节，SHA-256 `c7342860bba35cd7d883cc4e60433ace9728f75b3b37d72d037ad19ef5a2388b` |
| APK 身份 | `com.elitesync.v2functionp042r1`，版本码 `1011807`，版本名 `10.1.18-v2-function-p042-r1`，`arm64-v8a` |
| v2 签名 | 证书 SHA-256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09` |
| AAR 与 APK | AArch64 `libapp.so` 字节相同，SHA-256 `d926894503fbada10df28b50f0e3ccfb715b56cf93a9717548afb20a5d9b85b7` |
| 原生与 Dart | `https://127.0.0.1:18444/`，原生 `WS_BASE_URL` 为空，Flutter 平台深链转发关闭 |
| TLS | 内嵌、构建与实时叶证书一致，SHA-256 `41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`，TLS 1.3，校验证书和 IP，`GET /up` HTTP 200 |

首个宿主 APK 命令缺少项目离线候选入口依赖的 `CI=true`，在 `app/build.gradle.kts:142` 退出 1。第二次按源码门配置在独立目录构建成功，AAR 沿用已通过产物，两次命令和原始日志均保留。

本次没有安装修复版。手机 `25060RK16C` 当前 `1011807` 的实际包 SHA-256 仍为 `6ab17ca59e3f788b2f37ea7e3bea37d664a836e11e46e32c3c56aa1ccc786983`。Owner 需对新 SHA-256 `c7342860bba35cd7d883cc4e60433ace9728f75b3b37d72d037ad19ef5a2388b` 与该手机授权一次原地更新，再复验合格授权持续离线、切前台、冷启动和联网换代。1011805、1011806 包、数据及其旧产物保留。历史 1011806 A09、PHP 409/200 和本次原 APK 前台失败保留各自结果。初次选图的来源仍 UNKNOWN。过期 URI 和跨账号对象的手机冷／热入口待验，HTTPS 独立对象矩阵已通过。

封闭内测及生产均为 **NO_GO**。仍有修复候选实机、双物理设备、剩余媒体和真实 WLAN，以及真实旧管理员本人验证、共享受限 HTTPS、顾问集中复验和 Owner 准入。

[脱敏证据索引](V2_P0_4_2_R1_FOREGROUND_AND_MEDIA_EVIDENCE_20261122.md) · [原任务单补充清单](V2_P0_4_2_R1_VERIFICATION_CHECKLIST_20261122.md)
