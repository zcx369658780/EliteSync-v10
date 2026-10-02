# APP-M5-04 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，限定接受固定 Dart 入口的源码分派。** Work 核对 `main.dart` 当前 SHA-256 `F0F4A6C112774AE0EE78D47B4FFAFD6CF20250B1CA5B6EE112AC4A4EB2BF2B54` 与作者摘要一致，差异仅增加 `ELITESYNC_SYNTHETIC_DEMO` 编译期布尔分支：true 调用现有 demo 入口，其余继续调用原 prod 入口。目标文件格式复核、`flutter analyze --no-pub lib/main.dart` 与差异空白检查均退出 0；Work 未复跑。

本结论不证明 AAR 产物带有标记、host 端点被隔离、APK 可构建/安装或设备行为。host 当前仍有非 loopback 默认与覆盖路径，且可能复用旧预制 AAR；这些门未被源码分派解除。设备 `UNKNOWN`、M5 运行 `NOT_READY`。

APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填不变。旧预算不重置，本地 main HEAD 未动，无提交、pull、push。
