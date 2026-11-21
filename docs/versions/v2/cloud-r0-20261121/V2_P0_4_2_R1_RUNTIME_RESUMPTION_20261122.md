# P0.4.2 R1｜续验与并存候选准备

2026-11-22（北京时间）。工程状态 `R1_PARTIAL`，封闭内测与生产均为 `NO_GO`。

## 接手续验

工作树 `D:/EliteSync-v10/build/p042-v2-worktree`，分支 `codex/v2-function-completion-20261121`。接手时工作区和暂存区干净。本地 `285195840c1e4a3bf0d9df4269655a9f74abd70e` 与 GitHub 分支接手时指向的 `9f67caba930d244768c7535e92d81edeea960949` 均指向 tree `2b849690c3f30f71a5ee3238e5752c9c8a02d985`。远端 tree 由 GitHub Git Commit API 回读核对。

| 项目 | 本轮结果 |
| --- | --- |
| Flutter 标准测试 | `NOT_RUN`。缓存的标准 runner 进入测试加载阶段，五个套件均在 flutter_tester 回连调度端时返回 `10057`，runner 退出 1，业务测试执行数 0。 |
| PHP 8.4 与专用 MariaDB | `NOT_RUN`。当前 PHP CLI 为 8.5.3，WSL 枚举报 `E_ACCESSDENIED`，Docker Desktop Linux engine 管道不可用。专用库身份、迁移及 MariaDB 并发矩阵待本机运行时复验。本轮未操作数据库或数据库卷。 |
| 真实 Workerman WebSocket | `NOT_RUN`。独立 Windows IPv4 回环探针可监听，连接时报 `10013`。目标运行时不可用，握手、轮询回退、重连和代际切换矩阵待验。 |
| ADB 与具名设备复验 | ADB 退出 1，未读到本机 daemon 响应。此前 Owner 转述的本机 Codex 枚举证据继续有效。本轮未取得设备端回读，未发设备 shell、安装、应用数据或 USB reverse 命令。 |
| Android AAR 与 APK | 源码构建到达 `assembleAarRelease`，Gradle daemon 已监听回环但客户端无法连接，退出 1。单独的离线 Gradle 最小项目在 `--no-daemon` 下也未能连接单次 daemon。新 AAR 与 APK 产物均为 0。 |

本轮标准 Flutter 测试选择了 `live_chat_history_test.dart`、`live_chat_page_test.dart`、`live_chat_retained_list_cache_test.dart`、`live_conversation_private_cache_test.dart` 和 `offline_chat_text_test.dart`。前序 PHP 8.5.3／SQLite 正向结果仍按原范围计入。1011806 A09、PHP 预期 409 实际 200 两条原始 FAIL 原样留存。

## 备妥候选身份

[Android 宿主构建配置](../../../../apps/android/app/build.gradle.kts) 增加 `-PelitesyncFunctionR1Candidate=true`，由既有 V2 function 证书与集成 AAR 路径约束。源码配置指定 `com.elitesync.v2functionp042r1`、`10.1.18-v2-function-p042-r1`、`1011807`。该包名在源码层面与历史 `com.elitesync.v2functionp0`、`com.elitesync.v2functionp04` 区分。R1 使用既有 ARM64 debug 宿主和 release Flutter AAR。配置中的原生及 Dart API 端点为 `https://127.0.0.1:18444/`，沿用证书校验和候选平台 URI 入口策略。上述是源码配置，APK 实际包名、版本、签名、SHA-256、二进制端点与 TLS 身份仍待构建后核验。

## 续验入口

1. 在能访问 Windows 回环、同一手机及原 WSL Docker 运行时的 local Codex 会话复验。核对 1011805/1011806 并存、专用 MariaDB 服务身份和当前源码，再补跑 Flutter、PHP 8.4／MariaDB、Workerman 具名用例。只使用合成账号与媒体。
2. 以最新 R1 源码重新生成 ARM64 Flutter release AAR 和 opt-in debug 宿主 APK。在 APK 和 AAR 落盘后核对包名、版本、签名证书、文件 SHA-256、实际原生与 Dart 端点、TLS 指纹，并核对 APK 与 AAR 的 `libapp.so`。随后单独申请实体安装授权。
3. 获授权后验证 A09 双向 Block 后换代及 24 小时离线文字和联机撤权、系统 Photo Picker/PNG/JPEG、媒体受众和缓存、旧 URI/通知。只有证明请求实际经 WLAN 的四个窗口才能计入真实无线验证。保留两版已装应用、数据、专用卷和原证据。
