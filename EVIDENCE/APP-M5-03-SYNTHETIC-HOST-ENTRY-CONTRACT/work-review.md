# APP-M5-03 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，仅接受 docs-only 的 `NOT_FIXED` 入口/端点合同。** Work 核对 `plan.md` SHA-256 `29FF5F4E2C8326E98D251EA0C11DC436DE0B12B38C99B84C633FAE85B60D2E95`，并定点核验当前 Flutter SDK `build_aar.dart` 将 AAR target 固定为 `lib/main.dart`；该入口当前转向 prod。仓内 Android host 的 AAR 命令可传 dart define，却没有从已审来源证明可选 `main_demo.dart`。host 默认和 debug 配置含非 loopback 端点及覆盖路径，不能直接宣称 synthetic 隔离。

作者两轮静态预算 2/2，仅新增文档；未改代码/配置，未运行 Flutter/Gradle/adb、构建或设备。后继建议是一份需要另行固定路径与新预算的源码候选，不是本审查对 Android APK、入口选择、端点隔离或运行权限的接受。设备仍 `UNKNOWN`，M5 运行 `NOT_READY`。

APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填不变。既有 dirty/untracked 保留，无提交、pull、push。
