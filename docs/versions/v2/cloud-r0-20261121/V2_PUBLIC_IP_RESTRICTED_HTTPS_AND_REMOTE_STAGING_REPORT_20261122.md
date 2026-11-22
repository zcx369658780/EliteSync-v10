# EliteSync V2｜公网 IP 受限 HTTPS 与远程 Staging 报告

2026-11-23（北京时间） · **ACME_STAGING_PASS / LOCAL_EDGE_PASS / APK_VERIFIED / PUBLIC_443_HELD / REMOTE_ACCEPTANCE_NOT_RUN**

`Ubuntu-zlxh` 的现有公网 IPv4 已完成 Let’s Encrypt staging 签发和续期演练。外层代理、证书切换及 1011809 客户端已完成本机验证。云端目前只服务回环 V2，公网 443 尚未启用。

## 云端与证书

- 治理基线 `3bf5769494feca893e2ea0369f836926d572c5e0`。云端 V2 业务源码 `7e0009df4fe69e48967c4fbc111717626c85ed80`、Git tree `80b7237fcd0c7d569a7026d4a73d1e0c34ef86b9`。宿主 Nginx 和现有 Compose 分开管理。
- 同一 SSH 主机身份、跨日相同目标及 CA 的 HTTP-01 验证确认当前公网 IPv4 与实例入口一致。实例网卡未直接列出该公网 IPv4，控制面长期绑定类型为 UNKNOWN。公网 IPv6 本轮未启用。
- 阿里云控制台上一轮回读显示 443 和 22 来源为全部 IPv4，优先级及 IPv6 规则未展示。本轮规则写入 0，443 实际监听 0。TCP 80 的可达性由 CA 的 HTTP-01 验证证实，控制面规则细目待正式部署前回读。
- 系统 Certbot 为 2.9.0，沿用原 timer 与既有证书配置。独立 Certbot 5.4.0 通过 webroot 与 `shortlived` 演练。证书含唯一且精确的 X.509 `iPAddress` SAN，官方 staging 链校验、密钥配对通过。有效期 159.9997 小时，约 160 小时。生产系统信任库拒绝该 staging 链。正式可信证书签发 NOT_RUN。
- 初次预检在 reload 后读到 410，恢复原配置后保留失败回执。加上新 worker 就绪回读后，同一路径观测到 410→200，随后签发通过。续期初次演练被 178.75 秒的 Certbot 随机延迟阻断。明确禁用该次试验的内置随机等待后，`renew --dry-run` 和 staging 测试 hook PASS。
- 临时 HTTP-01 location 仅允许绑定的 IP Host 和单层 token 文件，错误 Host、缺失 token 均返回 404。每次完成后恢复旧配置。最终回读原 80 配置 SHA 相同，挑战 location 已撤销，旧站 410、LiveKit 原 `/rtc` 响应及 DevPilot、LiveKit、V2 健康均保持基线。V2 只发布 `127.0.0.1:18446`，其他服务发布端口 0，V2 Workerman 未运行。带 IP Host 的 Web 登录页仅在 V2 回环读取到 200。

## 本地边缘代理与续期部署

IP 模式只接受一个规范公网 IPv4。Nginx 校验 HTTP Host 和请求目标 Host，支持无 SNI 的 IP TLS 客户端。APP、Web 管理、API 管理及激活使用独立来源表，IP 模式仅有 IPv4 精确来源，API 管理及激活保持空。上游仍经固定回环 TLS，启用证书校验并独立校验 IP SAN 与当前叶证书指纹。

隔离 Nginx 实际运行矩阵共 40 项，通过无 SNI、错 Host、错 SAN、无 IPv6 监听、非批准来源、伪造转发头、管理和 APP 来源隔离、路径拒绝、错上游证书等测试。旧 DNS 模式的 SNI、IPv6 与精确来源渲染也通过。使用隔离证书验证新 deploy hook 的链、IP SAN、密钥、切换后实际叶证书和故障回滚。模拟 reload 失败后，旧叶证书及链接读回通过。云端 staging dry-run 使用专用测试 hook，正式 hook 和 timer 尚未安装。

预案使用独立 timer 每六小时检查，最多 15 分钟随机等待，同时独立检查剩余 72 小时和失败告警。timer 表达式通过解析，告警目的地、送达、实际自动续期及正式链信任待部署核验。80 长期保留仅挑战路径需 Owner 确认。 [IP 模式与回滚手册](../../../../services/backend-laravel/docker/shared-staging/restricted-edge/RUNBOOK.md)

## Android 1011809 候选

- 客户端及本地配置源码提交 `b974d7e659da2cc622450f72ae338280d50faec0`，Git tree `5121fc1abb73cafea80735be701e0f6988a8f950`。旧准备轮仅生成 1011809 原生测试配置；本轮开始前在具名准备目录未找到该版本的 APK。
- 固定候选 `com.elitesync.v2stagingremote` / `1011809` / `arm64-v8a`，APK SHA-256 `8f1c47c843b44021d6f43063f8a1fcf51c7dd61e20336f86fe18ef6625fd7109`，签名证书 SHA-256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。AAR 与 APK 的 `libapp.so` 逐字节一致，Manifest 禁用备份和调试，原生 DEX 与 Flutter AOT 端点身份匹配。
- Dart 和原生严格使用同一构建时 HTTPS IP origin，原生采用系统信任，Flutter 未注入替代证书，禁止不匹配的 Bootstrap，原生证书覆盖及 WS 地址为空。功能模式禁用聊天 socket 与 RTC。两项 Gradle 无效输入按预期拒绝，定向 Dart 27 项通过。客户端最终包含 P0 坐标格式兼容。初次宿主构建在既有离线 CI 产物门停止，启用既有 CI 构建条件后通过。先前中间 APK 与五个历史 APK 均保留。
- APK、实际端点与构建原件只留私有工作区。安装 NOT_RUN，需绑定候选 SHA 与具名手机的 Owner 授权。

## 远程验收状态

| 项目 | 状态 |
| --- | --- |
| 平台公网 IP 长期绑定类型 | UNKNOWN |
| Chrome 与实体手机实际出口及获准白名单 | UNKNOWN，两端分别探测 |
| 443 控制面收窄与公网监听 | NOT_RUN，当前无监听 |
| 公开可信证书、实际自动续期、告警与正式 hook | NOT_RUN |
| Chrome 可信链、Owner 管理登录及普通账号拒绝 | NOT_RUN |
| 手机 APP 远程登录、资料、三盘、私有媒体及退出 | NOT_RUN |
| 真实 WLAN 四窗口 | NOT_RUN |
| 双物理设备 | NOT_RUN |
| 云上共享私信、WSS、公开注册、生产 RTC | 未启用 |

回滚保留旧站配置及其 SHA、现有服务及历史全部证据。未来上线仅新增具名 V2 include，回滚按快照恢复本次 include 和 443 规则。共享 Connection 合成授权沿用上一轮本地回执，云端开关未启用。

R1 PARTIAL。封闭内测与生产 NO_GO。网页 GPT 集中复验待 Owner 转交。 [P1 脱敏证据索引](V2_PUBLIC_IP_RESTRICTED_HTTPS_AND_REMOTE_STAGING_EVIDENCE_INDEX_20261122.md)
