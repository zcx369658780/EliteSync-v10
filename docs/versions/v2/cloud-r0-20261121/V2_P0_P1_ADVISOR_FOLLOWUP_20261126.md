# EliteSync V2｜P0 资料恢复与 P1 远程 Staging 实机补证

2026-11-26。请依据本报告补审上一轮 P0「实体 APP 资料页待验」和 P1「公网 HTTPS 与远程实机待验」。上一轮基线为 `43080f9a2bbcce5dbb6ed3cb0086ce945b02b1e3`。本报告证据固定于开发分支 `codex/v2-function-completion-20261121` 的 `23d4ff5de54398a58320ec078e5f2e14fd610163`，已核对 GitHub 同一分支引用。 [开发分支固定证据](https://github.com/zcx369658780/EliteSync-v10/blob/23d4ff5de54398a58320ec078e5f2e14fd610163/docs/workflow/ACTIVE_STATE.md)

## P0｜资料恢复与 Owner 实体 APP 验收

- 唯一恢复账号为 `ADMIN-TEST-01`。原批次 8/8 结论沿用。核对旧主库 `users.name` 和旧 API 的字段语义后，Owner 另行授权在目标列仍为空时只补昵称一列。补写后资料 API 和应用容器重启读回均为 9/9，密码、权限、已有会话、其他账号及派生资料保护核对通过。Flutter 坐标兼容的 27 项定向测试通过，扩围 43 通过、6 失败，6 项原基线复现的结果保留。 [P0 报告、补写及脱敏回执](https://github.com/zcx369658780/EliteSync-v10/blob/23d4ff5de54398a58320ec078e5f2e14fd610163/docs/versions/v2/cloud-r0-20261121/V2_ADMIN_TEST_01_LEGACY_PROFILE_DATA_RESTORE_REPORT_20261122.md)
- 顾问上一轮审阅的 **1011809** 后续获 Owner 具名设备和 SHA 授权。初次安装受 Android 用户限制，Owner 在场后获准重试，安装及已装哈希读回通过。Owner 在 **25060RK16C** 本人登录并确认基础信息全部恢复。服务端 9/9 为字段级核验，手机结论为 Owner 本人页面验收。 [1011809 实体 APP 回执](https://github.com/zcx369658780/EliteSync-v10/blob/23d4ff5de54398a58320ec078e5f2e14fd610163/docs/versions/v2/cloud-r0-20261121/V2_ADMIN_TEST_01_LEGACY_PROFILE_DATA_RESTORE_REPORT_20261122.md#2026-11-231011809-实体-app-本人验收)

## P1｜正式证书与具名远程场景

| 上轮保留项 | 补证结果 |
| --- | --- |
| 公网 IPv4 绑定 | 阿里云轻量实例随实例分配固定公网 IPv4，实例到期后无法保留。桌面 Chrome 和手机 Wi-Fi 在各自一次性来源窗口测得同一公网出口，临时探测入口已撤销。 |
| 正式可信证书及续期 | Owner 授权长期保留 80 的 ACME challenge-only 路径。正式公开可信 IP SAN 证书已签发并部署，约 160 小时有效。独立续期与健康 timer、真实 deploy hook 的 staging dry-run、隔离回滚及网页收到 OnFailure 测试告警均有回执。自然续期结果本报告未核验。 |
| 云防火墙与应用入口 | 仅云防火墙 `/32` 的桌面 443 链路为 FAIL，根因 UNKNOWN。Owner 随后恢复全 IPv4 TCP 443，已记录全 IPv4 与 `/32` 同时启用。外层 Nginx 分别限制 APP 与 Web 管理来源，严格校验回环上游 TLS。Owner 已停止公网 443 连通性探测。 |
| 浏览器与手机 | 桌面严格 TLS 的 `/up` 与 `/admin/login` 200，Owner 在 Codex 内置浏览器登录后台并有脱敏 302/200 回执。1011809 本人手机资料页通过。1011814 真机远程地点 API 200。独立 Chrome 管理登录、手机移动网络出口及真实 WLAN、双物理设备专项仍待验。 |
| 脱敏运行日志 | 已有外层脱敏日志回执，含时间、路由类别、来源判定、状态及上游结果。顾问建议的路径、请求 ID 和完整拒绝统计尚未取得独立核验。 |

[P1 部署与证书、来源、回滚和日志回执](https://github.com/zcx369658780/EliteSync-v10/blob/23d4ff5de54398a58320ec078e5f2e14fd610163/docs/versions/v2/cloud-r0-20261121/V2_P1_PUBLIC_HTTPS_OWNER_WEB_HANDOFF_20261123.md) · [仅 /32 复验结果与 Owner 决策](https://github.com/zcx369658780/EliteSync-v10/blob/23d4ff5de54398a58320ec078e5f2e14fd610163/docs/workflow/SESSION_HANDOFF_20261126_ELITESYNC_V2_PROFILE_NATAL.md) · [阿里云轻量应用服务器产品限制](https://help.aliyun.com/zh/simple-application-server/product-overview/limits)

## 1011814｜空坐标草稿地点回填

- 在 25060RK16C 同包同签名一次原位升级至 1011814。包名 `com.elitesync.v2stagingremote`，APK SHA-256 为 `37b9d370dda05f737cdd5e367d12267e3572220120edd6a27ec7710d8aec18d4`。已装版本、哈希、安装身份及数据目录读回通过。1011813 的天安门城楼 OSM 离线样本回填先前已由真机验证。 [1011814 装机及部署回执](https://github.com/zcx369658780/EliteSync-v10/blob/23d4ff5de54398a58320ec078e5f2e14fd610163/docs/versions/v2/cloud-r0-20261121/V2_NATAL_MANUAL_BAIDU_20261126.md) · [1011813 OSM 真机回执](https://github.com/zcx369658780/EliteSync-v10/blob/23d4ff5de54398a58320ec078e5f2e14fd610163/docs/versions/v2/cloud-r0-20261121/V2_NATAL_OFFLINE_OSM_PILOT_20261126.md)
- 1011814 实体 APP 从空坐标草稿输入公开地点「广州市第一人民医院／广州市」，拼音输入阶段零请求。点击「搜索」后，离线未命中触发 **一次百度服务端查询，零自动重试**。选中并二次确认后回填 GeoNames **广州市越秀区代表点**，WGS84 纬度 `23.12528`、经度 `113.26528`，坐标精度为区县级。退出后原地点及坐标读回一致。该样本未保存或计算命盘，百度 AK/SK 留在服务端。正式排盘由 Owner 本人核对并提交。 [定向测试与真机回填回执](https://github.com/zcx369658780/EliteSync-v10/blob/23d4ff5de54398a58320ec078e5f2e14fd610163/docs/versions/v2/cloud-r0-20261121/V2_NATAL_MANUAL_BAIDU_20261126.md)
- 八字、紫微斗数、西洋占星均在服务端计算。1011814 地点检索改动未触及三盘计算代码，沿用既有算法校验。 [服务端计算入口](https://github.com/zcx369658780/EliteSync-v10/blob/23d4ff5de54398a58320ec078e5f2e14fd610163/services/backend-laravel/app/Services/NatalCalculationService.php#L10)

请分别裁决 **P0 实体 APP 资料页**、**P1 具名远程 Staging**以及 **1011814 空坐标草稿代表点回填**的接受范围。当前 **R1 PARTIAL，封闭内测及生产 NO_GO**。共享 Connection、私信、WSS、公开注册和生产 RTC 保持关闭。
