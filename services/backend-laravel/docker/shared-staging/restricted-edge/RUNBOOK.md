# 受限 V2 Staging HTTPS 接入

外层 Nginx 只代理固定 V2 回环 `18446`。现有 80 和 LiveKit 路由由原配置处理。Laravel `APP_URL` 保持回环，保留管理员恢复目标绑定。外层转发固定公网站点 Host、HTTPS scheme 与端口，真实来源取 socket 对端。

## 接入前核对

1. 从 Owner 私有记录读取已批准的 Staging FQDN、实际 DNS A/AAAA、可信证书及 Chrome 和实体手机的精确出口。分别记录普通 APP、Web 管理、API 管理和激活来源。API 管理及激活可使用空列表；本轮已恢复的管理员验收仅需要 Web 管理。
2. 确认控制面实际绑定 Ubuntu-zlxh。保存 443、22 和其它已启用规则快照。确保 SSH 独立通道可用。保存 Nginx 当前有效配置、站点文件和链接清单的 SHA-256、证书元数据、V2 Compose 与私有环境文件 SHA-256，以及 V2、DevPilot、LiveKit 健康状态。
3. 在 root 专属的 0700 目录准备私有 JSON。字段分别是 `host`、`fullchain`、`key`、`upstream_leaf`、`app`、`web_admin`、`api_admin`、`activation`。证书与密钥使用绝对路径，来源列表只接收带前缀长度的 IPv4 /32 或 IPv6 /128。IPv6 无许可来源时保留拒绝，核对 AAAA 与实际 IPv6 入站规则。
4. 用 `render.py` 生成 0600 的独立配置，使用 `verify-tls.sh HOST FULLCHAIN KEY UPSTREAM_LEAF` 核验外层链、DNS SAN、密钥归属与匹配，以及当前回环叶证书和 IP SAN。核对选定站点名称与现有虚拟主机无冲突。证书应有具名续期方式和到期告警。

## 顺序与验收

先把当前过宽的 443 规则收窄至已批准来源并回读。旧 22、80 和 LiveKit 端口按快照保留。然后在 host Nginx 新增独立 include `/etc/nginx/conf.d/elitesync-v2-restricted.conf`，仅引用 root 私有目录中的渲染文件；确认该 include 原先不存在。先执行 `nginx -t`，通过后 reload。重新核对 443 的 IPv4/IPv6 监听、V2 回环证书、DevPilot、LiveKit 直连与原 `/rtc` 代理状态。

从获准来源核对 Chrome 管理登录和 APP 登录、资料、三盘、私有媒体、退出。从未批准的 IPv4/IPv6 来源核对拒绝；浏览器和实体手机的来源分别绑定证据。用虚构普通账号核对既有管理授权拒绝，Web 登录仅由 Owner 输入其凭据。确认注册、激活、未获准管理 API、共享私信及 Upgrade 的拒绝，日志不包含密码、Authorization、Cookie 和激活参数。测试来源、时间窗和回执原文存于私有目录。

## Android 候选

实际域名和公开证书通过核验后，沿现有离线 ARM64 AAR → APK 链构建。AAR 沿用 1011808 的四个整合 Dart 开关，将 `ELITESYNC_V2_FUNCTION_BUILD`、`ELITESYNC_V2_REMOTE_STAGING_BUILD` 设为 true，`ELITESYNC_V2_STAGING_LOGIN_BUILD` 设为 false，`ELITESYNC_REMOTE_STAGING_HOST` 和 `ELITESYNC_API_BASE_URL` 分别绑定同一私有批准域名及其 HTTPS origin。宿主用 `-PelitesyncFunctionR1Candidate=true`、`-PelitesyncRemoteStagingHost=<获准域名>`、具名 AAR repo 和独立输出目录；远程候选使用系统证书信任。

回读 APK 的 Manifest、DEX、Dart AOT、签名、包名、ABI 和 WS 配置，并逐字节核对 AAR 和 APK 的 `libapp.so`。固定 SHA-256 后单独申请指定手机安装授权。公网和 WLAN 测试使用真实网络链路，原回环凭据和转发无需参与本次测试。

## 公网 IPv4 模式

1. 控制面确认现有 IPv4 绑定及生命周期。分别核实 Chrome 与手机的真实出口并由 Owner 批准。仅使用已批准的 IPv4 /32，公网 IPv6 保持关闭，管理 API 和激活列表保持空。
2. 私有 JSON 使用 `public_ip` 字段绑定该 IPv4，替代 DNS 模式的 `host`。对 HTTP Host 校验批准 IPv4，支持省略 SNI 的 IP TLS 客户端。先核对宿主上 443 IPv4 默认虚拟主机及其他配置的归属。IP TLS 默认握手提供同一受信链，未知 HTTP Host 返回 421。
3. 使用独立 Certbot 5.4+ `certonly --staging --preferred-profile shortlived --webroot --webroot-path WEBROOT --ip-address APPROVED_IPV4`。临时 TCP 80 location 仅匹配批准 IP 与单层 base64url token 文件，缺失文件返回 404。通过新 worker 的 token 回读后才发起挑战。旧 410、`/rtc` 和其他服务按原路径验收。使用官方 staging 根核对精确 IP SAN、链、密钥和 160 小时有效期，并完成 `renew --dry-run --no-random-sleep-on-renew --run-deploy-hooks` 的专用测试 hook。staging 根只用于试验。
4. Owner 批准长期保留 challenge location 及实际来源、通过短证书告警配置核验后，才从正式目录签发并校验公开可信证书。隔离正式配置、work、logs、ACME 账户和 lineage；生产与 staging 目录分开。先备份并收窄 443 控制面，再按本文件部署顺序开通 vhost。
5. 证书路径固定指向 0700 的 root 私有 edge 目录下 `current/fullchain.pem` 与 `current/privkey.pem`。初始版本存入 `releases/INITIAL`，`current` 为相对符号链接。续期 deploy hook 在获准公网启用后调用 `bash deploy-ip-certificate.sh APPROVED_IPV4 EDGE_DIR UPSTREAM_LEAF`。它对新链、精确 IP SAN、期限、私钥和 V2 上游证书先行校验，串行原子切换链接，校验 Nginx、reload 并验证实际无 SNI 握手后的新叶证书。检查失败时切回旧链接，reload 并读回旧叶。旧证书版本和失败件保留。
6. 用独立 systemd timer 调用独立 Certbot，可设 `OnCalendar=*-*-* 00,06,12,18:15:00`、`RandomizedDelaySec=15m`、`Persistent=true`。服务使用显式正式 `--config-dir`、`--work-dir`、`--logs-dir` 和 `--cert-name`，由 timer 管理随机等待。核验下次执行时间及失败单元告警。独立核验 served 证书剩余 72 小时的告警、实际通知送达和旧证书超期的人工恢复路径。续期命令退出码和 live 叶 SHA 都需监控，Certbot lineage 的更新独立于 Nginx 服务切换；失败后可对已签发 lineage 手动运行同一 hook。系统 Certbot 及其现有 timer 由原证书维持。
7. Android 的原生参数为 `-PelitesyncRemoteStagingIp=APPROVED_IPV4`。Dart 定义 `ELITESYNC_REMOTE_STAGING_IP=APPROVED_IPV4`，`ELITESYNC_API_BASE_URL=https://APPROVED_IPV4/`，远程模式使用 Android/Flutter 的系统信任和 IP SAN 验证。构建产物与端点私下固定，装机授权绑定具体 APK SHA 和设备。

## 回滚

使用独立 SSH 通道。执行 `rollback.sh PRIVATE_SNAPSHOT_DIR INSTALLED_INCLUDE_SHA256`，仅把本次 include 移至私有取证目录，验证语法并 reload。若改过 443 控制面规则，先确认新增 V2 监听已移除，再按原快照恢复相应规则。保留回环 18446、旧 Nginx 配置、LiveKit 路径、V2 容器、卷和备份。最后复核三项健康状态和原站点配置哈希。失败原文与修复回执均留存。
