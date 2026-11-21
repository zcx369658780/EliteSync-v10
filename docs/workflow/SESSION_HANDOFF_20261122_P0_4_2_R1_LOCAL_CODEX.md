# EliteSync V2 P0.4.2 R1｜本机 Codex 接续

2026-11-22（北京时间）。R1 仍为 PARTIAL，封闭内测和生产继续 NO_GO。

## 工作身份与证据

- 使用主机标记为 local 的 EliteSync Codex 会话。工程位于 D:/EliteSync-v10/build/p042-v2-worktree，分支 codex/v2-function-completion-20261121。交接前本地提交 7d320ebf656694edba39905c36d2e4fe27f917e1 与远端 7cad0a03cf257751174ed62942d87231f3053174 的 tree 同为 afdd8178e56ffaf62676f4e5a27199e2a9e22c27。接手先核对工作树、暂存区和远端最新提交。按 tree 识别同一内容，保护既有工作，避免因提交号差异重置。
- Owner 提供普通 Windows PowerShell 回执，ADB 状态为 device，成功读取型号 25060RK16C。另据 Owner 转述 PC 配置项目的验证，local Codex 在允许联网的工作区沙箱内可连接 127.0.0.1:5037 并读出同一型号。此前 durable Work 会话无法连接本机 ADB，独立回环探针返回 10013 AccessDenied，具体拦截策略未确认。设备序列号省略。
- Owner 已确认方案 B 首版。可信设备登录后，仅本代已下载文字及同代文字引用可以离线读取，授权自签发起最多 24 小时。冷启动需联网核验。媒体及列表、通知正文预览需联网复核。密文保留期独立。详见 [Owner 决策](../decisions/OWNER_V2_P0_4_2_OFFLINE_HISTORY_OPTION_B_20261122.md)。
- 方案 B 源码本地 e487691c30938af3f7ed4d308ac92e1cb3249aae，远端 af5948fcb68b8711876146b1ea2960592602d354，tree 同为 123ff21aecc6ad68bb5aacc0ac4dab5135e9a3d8。[方案 B 实施回执](../versions/v2/cloud-r0-20261121/V2_P0_4_2_R1_OFFLINE_HISTORY_OPTION_B_IMPLEMENTATION_20261122.md) · [上轮环境和媒体验证](../versions/v2/cloud-r0-20261121/V2_P0_4_2_R1_DEVICE_PREFLIGHT_FOLLOWTHROUGH_20261122.md)

## 下一步

1. 在 local 会话重验 ADB，同一设备和 1011805、1011806 共存。保留两版及设备数据、原专用 MariaDB 卷和原始证据，只用合成账号与媒体。分别确认 Flutter runner、PHP 8.4、专用 MariaDB 与真实 Workerman WebSocket 可用性。
2. 从最新 R1 源码构建可并行安装的候选，固定包名、versionCode、签名、SHA-256、原生和 Dart 端点及 TLS 身份，再向 Owner 单独申请实体安装授权。手机接入是连接证据，安装授权仍待。当前没有新 AAR 或 APK。
3. 完成具名运行验证与设备复验，重点覆盖 A09 双向 Block 后换代、24 小时离线文字与联网撤权、Photo Picker/PNG/JPEG、受众与缓存、旧链接与无线窗口。只有能证明目标请求经 WLAN 的测试才记为真实无线验证。
4. 将增量证据归档并同步原非 main 分支，交集中顾问复验。保留 1011806 的 A09 原始 FAIL、PHP 409/200 FAIL 和未运行项。范围维持 P0.4.2 R1，本轮保持封闭内测与生产 NO_GO。

已完成的 PHP 8.5.3／SQLite 结果包括方案 B 和代际、通知具名回归 14 项、398 断言，以及媒体补测 22 项、212 断言。Dart 静态分析和纯策略探针已通过。Widget、目标后端、真实 WebSocket 和修复后设备结果仍待。详见 [R1 报告](../versions/v2/cloud-r0-20261121/V2_P0_4_2_R1_ENGINEERING_REPORT_20261122.md)。
