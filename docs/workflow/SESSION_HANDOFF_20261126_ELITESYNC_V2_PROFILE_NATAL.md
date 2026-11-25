# 2026-11-26｜EliteSync V2 资料恢复、排盘地点搜索与实机交接

当前结论为 **P0 基础资料已通过 Owner 验收，1011812 原位更新通过，排盘地点搜索的服务端和新版手机功能待验。R1 PARTIAL，封闭内测与生产 NO_GO。**

## 现场基线

- 开发工作树为 D:/EliteSync/development/v2-cloud-r0-20261121，分支 codex/v2-function-completion-20261121。交接前本地和远端开发 HEAD 均为 f5518f5b0dac89fb706b7f0005259a2a62b5427a。同期远端 main 已只读核对为 d047a4100de01c103fbe19a28e41f9685c819df7。D:/EliteSync-v10 的原 main 仍是脏工作树，保留其未提交内容和未跟踪资产。
- V2 专用 Staging Compose 为 elitesync-v2-shared-staging-beta。最近记录的云端业务源码为 7e0009df4fe69e48967c4fbc111717626c85ed80，上游严格 HTTPS 仅回环 18446。交接仅核对本机 Git、远端引用和已存回执。

## Owner 决策与完成情况

- **旧资料恢复只涉及 ADMIN-TEST-01。** 第一轮 8 个字段在隔离备份恢复、dry-run、apply、API 和应用容器重启后通过。昵称随后经 Owner 另授一次补写空的 users.name，API 和重启后均读回 9/9，密码、权限、既有会话和映射核对一致。Owner 在实体 APP 确认基础资料完全恢复。命盘最后记录未生成，需 Owner 本人在排盘页核对输入并主动提交。历史恢复、激活和一次性探测授权均已消费。 [P0 恢复报告和 Owner 回执](../versions/v2/cloud-r0-20261121/V2_ADMIN_TEST_01_LEGACY_PROFILE_DATA_RESTORE_REPORT_20261122.md)
- **Owner 恢复阿里云全 IPv4 TCP 443，明确停止公网 443 连通性测试，主任务转向旧资料恢复和排盘。** 保留全 IPv4 与精确 /32 同时启用及外层 Nginx 仍限制来源的历史回执。仅 /32 的桌面 TLS 失败和根因未知均保留。正式 IP SAN、ACME 专用 80 路径、严格上游 TLS、续期和告警已核验。Owner 在 Codex 内置浏览器本人登录管理后台并取得服务端回读，工单完结。独立 Chrome 登录及真实 WLAN、双实体设备专项验收暂无完成回执。手机本人资料页 PASS 按其验收范围记录。 [P1 HTTPS 固定交接](../versions/v2/cloud-r0-20261121/V2_P1_PUBLIC_HTTPS_OWNER_WEB_HANDOFF_20261123.md)
- **排盘复用已保存出生资料。** 1011810 经 Owner 确认「使用已保存的出生资料」可用，也能唤起百度地图。Owner 认可无独立排盘记录时「重新读取已保存资料」不可用的表现。表单只补空白字段，已有坐标仅在确认 WGS84 后带入。百度公开 Android 地点搜索 URI 供外部查看，暂无选点或坐标回传契约。Google Play 版和另一官方版本均已在各自隔离模拟器进入搜索前报 EGL 错误，单独打开也复现。历史失败保留。 [百度 Android 调起文档](https://lbsyun.baidu.com/docs/webapi?title=mapadjustment%2Furi%2Fandriod)
- **同意加排盘页内搜索。** 源码 a030c131309adfa43df15dd12416790724bf5f5b 增加「搜索并带入坐标」。用户确认后，服务端通过 HTTPS 单次调用多维检索，只发送地点关键词和搜索城市，请求 WGS84。选中结果只回填当前草稿。本地 Laravel 13/13、Flutter 47/47。1011811 实机反馈拼音输入后搜索提示不可用，地图内缺少返回提示。源码 16993214a5ad6785355fb60048e5740aed10bf81 修正地点和城市的输入候选配置，在打开外部地图前说明手机返回键、手势和最近任务，并区分接口未上线、输入校验及限额等失败。Dart 分析无问题，Flutter 定向 47/47。 [百度多维检索契约](https://lbsyun.baidu.com/docs/webapi?title=placev3%2Fguide%2Fwebservice-placeapiV3%2Fmultidimensional)
- **1011812 具名手机原位更新 PASS。** 包名 com.elitesync.v2stagingremote，arm64-v8a，APK SHA-256 为 b47502e1340287f3f36e4f862c81f18625a4feacb721370d9827d0f539898165。在 25060RK16C 从 1011811 通过 adb install -r 原位更新，版本、已装 APK 哈希、appId、dataDir、首次安装时间和 EliteSync 包清单已回读。已消费本次装机授权。私有安装回执 DEVICE_1011812_INSTALL_RECEIPT_20261126.json 的 SHA-256 为 ecfe3e9ad25429bce980f5a54f0b80ea1d7b4ed896b25b20d375ab15b76a274e。新版真机拼音候选、地图返回提示和真实坐标回填均待验。
- **旧装机分支清理已完成。** Owner 曾单独授权移除手机上的四个旧 EliteSync 测试包并保留当时的 1011810。该轮已 PASS 和结清，之后只对保留包做原位升级。本机历史 APK 保留。

## 接手续作与停止条件

1. 开场只读核对实际 Git 根、origin、分支、HEAD、工作树与暂存区，阅读 AGENTS.md、ACTIVE_STATE 顶部、CURRENT_WORKFLOW 顶部及本交接。先确认 Owner 在 1011812 的反馈。新版实机验收需分别记录拼音选字、打开百度地图、系统切回、草稿保留和坐标回填。
2. 在线搜索当前缺少已上线的 POST /api/v1/profile/natal/places。已记录的 Staging 源码不含该路由，本机未发现有效 Web AK/SK。获得 Owner 对 V2 专用 Staging 的授权和密钥私有配置位置后，先核对多维检索权限。使用公开测试地点做获准的单次验证，确认 WGS84 来源后才进行具名手机回填验收。密钥或权限不满足时保留阻塞和请求结果。
3. 未来 APK 采用同包同签名的原位升级。每个新候选以具体 SHA 和具名设备授权，安装前后核对版本、哈希、包和数据目录。旧装机、卸载、恢复、激活和公网探测授权及记录均保留。
4. 浏览器优先 Codex 内置，Owner 本人登录并手动转交网页 GPT 顾问材料。保留 Owner 要求保持开启的页面。共享 Connection、私信、WSS、公开注册和生产 RTC 保持关闭，封闭内测与生产维持 NO_GO，禁止合并 main。保留脏工作树、旧库、媒体、配置、备份、历史 APK 和失败证据。真实地址、资料、密钥、工单原件与私有证据留本机。

交接文件保存现状与下一步所需条件。此处记载的已消耗授权仍按原回执管理。 [现行工作流](CURRENT_WORKFLOW.md)
