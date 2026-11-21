# P0.4.2 R1｜手机接入后的构建、ADB 与媒体验证续办

2026-11-22（北京时间）。Owner 报告手机已接入。本轮继续原 P0.4.2 R1 任务，不新增版本。方案 B 候选源码 e487691c30938af3f7ed4d308ac92e1cb3249aae，GitHub 同树源码 af5948fcb68b8711876146b1ea2960592602d354，前次远端交付 c5a90246ab1310f5ba0b03c2e76adffd842593ed。

| 验证 | 实际结果 |
|---|---|
| 手机预检 | Platform Tools 37.0.0。adb devices 启动本机 5037 daemon 后未读到 server greeting，退出 1，无设备枚举。设备身份和当前 USB 授权状态 UNKNOWN。本轮未发设备命令、未新增 USB reverse，未安装或覆盖 1011805、1011806。 |
| Windows IPv4 回环 | 绑定 127.0.0.1 随机端口成功。同一进程的 TCP connect 被拒，Winsock 10013 AccessDenied。来源为独立探针，未归因于手机。 |
| Android 构建 | 缓存的 Gradle 8.14 最小离线 smoke 未能连接本机 daemon。首次 Flutter AAR 预检缺 Android 产物且 Google 下载域名解析失败，随后补齐现有本地 Android 构建缓存，进入 assembleAarRelease，Gradle daemon 在 127.0.0.1 监听后客户端仍无法连接，任务退出 1。新 AAR 和 APK 均为 0。包名、versionCode、签名、哈希、APK 内实际端点和 TLS 身份暂无新候选可核对。 |
| 目标后端 | Docker Desktop Linux engine pipe 无法连接，WSL 返回 E_ACCESSDENIED，当前 PHP CLI 为 8.5.3。PHP 8.4、专用 MariaDB 和真实 Workerman socket 仍 NOT_RUN，原专用卷未操作。 |
| 后端媒体补证 | CODEX_REPORTED PASS。PHP 8.5.3 / SQLite，V1011R1AuthorizationTest、V10114StatusVideoTest、V1011RevocationTest、StatusPostApiTest 共 22 项、212 断言。覆盖动态封面、受众变化、离开或撤权时的旧媒体下载、视频权限和凭据边界。测试使用本机合成记录与媒体，无真实用户数据。 |

后端媒体测试不替代实机上传或设备缩略图缓存验证。Photo Picker 返回、手机 PNG/JPEG、上传故障窗口、端上受众与缓存、旧 URI、通知旧链接、修复后双端代际及真实无线四窗口仍为 NOT_RUN。没有固定新 APK，因此没有进入实体安装授权步骤。

后续需要可连接本机回环及 ADB、可访问既有专用 WSL/Docker 的授权本地运行环境。恢复后先核实同一设备与原包共存，再构建并固化可独立共存的候选。固定哈希和 APK 身份后单独申请安装授权。真实无线用例须有经过 WLAN 的证据。

历史 1011806 A09 实机 FAIL 与原 PHP 409/200 FAIL 保留。Flutter Widget 与其他目标环境仍未复验，P0.4.2 R1 PARTIAL，封闭内测与生产继续 NO_GO。
