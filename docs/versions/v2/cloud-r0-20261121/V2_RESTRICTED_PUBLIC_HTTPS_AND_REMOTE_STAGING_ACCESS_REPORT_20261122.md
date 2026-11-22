# EliteSync V2｜受限公网 HTTPS 与远程设备准备

2026-11-22（中国标准时间）。**云端只读核查和本地准备已完成。公网接入待批准域名、可信证书和实际设备来源。** 交付分支为 `codex/v2-function-completion-20261121`。云端业务继续使用 `7e0009df4fe69e48967c4fbc111717626c85ed80` 及镜像配置 ID `sha256:5a7ee83db71cdf799c0998233e3dc0b9e3ad0958fa77227f590bd15063ac99cf`。 [固定任务](../../../../tasks/V2_RESTRICTED_PUBLIC_HTTPS_AND_REMOTE_STAGING_ACCESS_20261122.md)

## 云端只读核查

| 检查 | 状态与结论 |
| --- | --- |
| 实例和资源 | PASS。核对到 Ubuntu-zlxh、上海、当前 2 vCPU，采样可用内存 540 MiB，系统盘可用约 22 GiB。云端容器无 OOM。 |
| 阿里云轻量服务器入站防火墙 | PASS。Owner 打开已登录控制台后，进入具名实例的防火墙页。TCP 443 与 TCP 22 均为已启用，来源均为 `0.0.0.0/0`。控制台页面未显示优先级和 IPv6 规则。443 现有规则需要收窄；本轮未保存控制台更改。 |
| 宿主监听和防火墙 | PASS。443 无监听。80 和 SSH 22 保持原监听，宿主 ufw inactive、现有 IPv4/IPv6 INPUT 策略为 ACCEPT，未见显式 443 或 22 规则。SSH 公钥认证启用，密码认证关闭。本轮未发现已运行的 VPN 服务或 WireGuard 接口。 |
| Nginx、DNS 和证书 | 宿主 Nginx active，当前三个配置文件，无 HTTPS 虚拟主机，已编译 realip 模块。控制台域名管理页未发现具名 Staging 记录。系统有一张归档证书，含一个 DNS SAN，对应 A 解析到该实例，未查到 AAAA；证书已于 2026-08-16 到期，当前信任链验证失败，私钥为 root 私有。Certbot timer 和一项续期配置存在，获准域名及实际签发或续期方式待定。 |
| 固定 V2 | PASS。Compose `elitesync-v2-shared-staging-beta`，专用库 `elitesync_v2_beta_staging`、server_id 2621124。APP 和 Worker 镜像源码一致，数据库 healthy。只有内层 Nginx 发布 `127.0.0.1:18446`；数据库、FPM 和 Worker 无发布端口，Workerman 未运行。实际应用 WSS 与本地恢复开关均为 false。 |
| TLS 和保护服务 | PASS。V2 回环证书指纹 `20cb9f36030b22f6b07a726f3070bb3af5edf78cbace658c0904359eeea23b46`，TLS 1.3、IP SAN 和 `/up=200`。DevPilot `8030/up=200`、LiveKit `7880/=200`。原 Nginx `/rtc` 路由在位，无 Upgrade 的探针返回 404，与退休旧栈时的探针一致。 |
| 既有管理员 | PASS。只读回验 ADMIN-TEST-01 为唯一 active 映射，其他旧来源映射 0，APP 和 Web 会话各 1，激活材料已消费。此前回环通道的登录证据沿用。 [原验收报告](V2_ADMIN_TEST_01_RESTORE_AND_ADMIN_ACCOUNT_INVENTORY_REPORT_20261122.md) |
| 当前浏览器出口 | UNKNOWN。临时新配置的 Chrome 只读探针未在目标访问日志中找到匹配事件。本轮未选取任何源地址。控制台只读证据来自当前已登录的 Edge；Chrome 公网登录、实体手机出口及是否同出口仍待确认。 |

## 代理和设备候选

| 交付项 | 证据与限制 |
| --- | --- |
| 代理源码 | `88ab0150e8790af9ef6376261502b0aba9bd07d4`。独立 Nginx include 采用四份精确来源表，默认拒绝。原生和应用路径只转发具名健康、登录、资料、三盘、媒体及退出范围。Web 管理保留既有应用组合鉴权，API 管理和激活可独立保持关闭。公网注册、RTC、消息及 Upgrade 均拒绝。入口丢弃客户端自报转发链和登录查询参数，使用固定 HTTPS 和可信来源，启用限速、连接与请求体限制。 [边缘运行手册](../../../../services/backend-laravel/docker/shared-staging/restricted-edge/RUNBOOK.md) |
| 本地验证 | PASS。Nginx 1.28 按本地证书完成 24 项代理和 TLS 检查，包括允许/拒绝 IPv4、IPv6，伪造转发头、错误 Host 与 TLS 名称，管理三类边界，错误上游信任指纹被拒。该 502 仅表示上游 TLS 拒绝。配置渲染、私有 0600 权限和防覆盖、云端与本地 Compose config、证书和回滚脚本 Bash 语法均通过。 |
| 公网接入和回滚 | NOT_RUN。现有 443 规则、DNS、旧 Nginx、容器和数据均未写入。上线前先保存私有配置和规则快照，确认独立 SSH 与三项健康，收窄 443 后再启用独立 vhost。实际公网正反来源和云端回滚未执行。 |
| Android 源码 | `3011f70bed04a8a59ff64df96953aa77ac3952a6`，tree `3b7a85375e5ae0104023f12738653b733677dd25`。计划包名 `com.elitesync.v2stagingremote`，versionCode `1011809`。Gradle 和 Flutter 都要求同一 HTTPS DNS 名称，使用系统可信链和主机名验证，禁止旧站回退并禁用 Socket。Flutter 定向测试 60 项通过；1011808 模式补验 7 项通过。仅用合成域名编译 Android Kotlin 和回读 BuildConfig，拒绝裸 IP；该测试未打包。 |
| APK 及远程验收 | NOT_RUN。实际域名待定，远程 AAR/APK、签名及 SHA-256 尚未生成。Chrome 远程管理登录和访客/普通账号/非批准来源拒绝、实体手机登录/资料/三盘/私有媒体/退出、WLAN 真实四窗口及双物理机均待执行。模拟器可另作第二测试端。原 1011805/1011806/两个 1011807/1011808 的五份 APK SHA-256 回验一致。 |

## 共享私信准备

本地候选 `f50e3749fbb38e3af2316c056e5805e033f8e87f`，仅接受独立合成实验身份。MariaDB 10.11 本地隔离栈完成 25 项检查。真实 Laravel HTTP 路由在无登录时返回 401，在无授权、无 Connection、无双方 MC 或已撤销时返回 404，具名配对且 Connection 与 MC 均有效时返回 200。错目标、管理员、错批次、错实例标记、到期和重放均被拒，候选 WSS 始终关闭。两个本地合成 DB 均退出 0，无端口发布，实验卷保留。云端共享 Connection、MC、Workerman 及正向 WSS 仍待独立 Owner 决定。 [合成授权决策包](V2_STAGING_SYNTHETIC_CONNECTION_SCOPE_OWNER_DECISION_20261122.md)

## 保留的首错和下一步条件

首次边缘演练在本地宿主网络发生 TLS 连接 reset，进入隔离网络后曾因测试客户端无权读取私有证书目录而退出。使用具名隔离网络和正确权限后通过。首轮 MariaDB 探针有 19 条 PASS，计数脚本因 CRLF 与计数预期错误退出；扩展真实 HTTP 后 25/25、退出 0。首次 Flutter 测试按预期因缺少远程参数失败，补齐后通过。

实际变更依赖批准的 Staging 域名、可信证书与所需 DNS A/AAAA 授权，以及 Chrome 和实体手机的精确批准出口或具名 VPN 来源。若两端共用出口，需要在实际网络会话中核对。控制面 IPv6 规则仍待核实。批准来源核实后才改现有 443 规则、部署独立入口并制作固定候选，再按 APK SHA 和指定手机申请安装。

**R1 PARTIAL，封闭内测 NO_GO，生产 NO_GO。** 真实短信挑战仍为 NOT_RUN。历史失败、旧数据库和媒体、私有备份及恢复审计保留。网页顾问集中复验待回执。

## 脱敏证据索引

| 私有证据文件名 | SHA-256 |
| --- | --- |
| `01-cloud-sanitized.json` | `74b8c4a69dcc9f7d70d850fc16c5778ca4cb4a06693369b5fe62ce069f992d83` |
| `01b-cloud-sanitized.json` | `8b578ea766333d8c2b4c5b4b1163f04c3d4c47bab2a721bcb8a4b04599007b53` |
| `01c-archived-cert-dns.json` | `abec1189978959af2845507f5cb25f5a721155f9e0125f1a1ba2ae1ad5931cf2` |
| `01d-console-firewall-verified.json` | `e7768b1f6bc42bec6c70b944221e18cdebac57273bf7e41cff70cbdc71e8971e` |
| `01e-chrome-egress-sanitized.json` | `77b61b98ac4822b5795392c9838b63ed86ae4ff563b242fc9650c0ff461d1fb9` |
| `01f-console-domains-sanitized.json` | `9ebdbad06f6998e3fa56cdfbeeb904c40a54f656baf4e30571654309ae8f0335` |
| `02b-edge-matrix-final.log` | `fd9cfe026f3050794aaff046ff6bc3ef5673cb4d359e7f3f712b79632bedcab6` |
| `02c-renderer-compose.log` | `715c9d4bc295363f9c41499baf149ffd6b533ca594bca523af3ba39213bbd507` |
| `03b-scope-http.log` | `e4606123b43a0a3aa1497ff60742ab613a45ff5b8a697f007a05a2fee0cf603b` |
| `04b-flutter-remote-green.log` | `cdbec8d6ff556b9c5c97170144b78ce8522057b67b79ff8d933505122865925c` |
| `04c-flutter-1011808-endpoint-regression.log` | `5a2ca70040fb5d21fadaab0a65a067508d2819c97941d03be2443e77e7276d5d` |
| `05c-native-compile-identity.txt` | `cb886ee4e96dcbc169aebfe928a3e559f28ec16fa8f01c2cb83ecd1cb0f3004c` |
| `16-after-staging-readback.json` | `2ff56b66e51d540c8d3eabbe67cbd87a73165ecf6c096db8a7d18a99288c8ec1` |
