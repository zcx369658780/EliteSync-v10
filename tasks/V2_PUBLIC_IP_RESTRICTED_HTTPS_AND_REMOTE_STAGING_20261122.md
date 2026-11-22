# EliteSync V2｜阿里云公网IP受限HTTPS与远程Staging接入任务（无域名路径）

日期：2026-11-22（中国标准时间）

## 1. Owner最新约束与授权

Owner说明：当前域名注册/备案流程暂不可用，功能开发成功前只能使用阿里云现有实例的公网IP访问。故本任务不依赖Staging域名，不注册域名、不改DNS、不采购域名/证书/VPN或新服务器。

继续沿用Owner此前对“受限公网HTTPS与远程Staging”的授权，但只允许：
- 复用现有阿里云实例和V2 Docker运行栈；
- 使用现有阿里云公网IP；
- 评估并在满足全部条件后使用公开可信的IP地址TLS证书；
- 443仅允许Owner精确来源；
- 不开放匿名公网业务访问；
- 共享私信/WSS继续关闭。

公网IP证书技术路径不得被描述为绕过中国大陆ICP备案、软件著作权或其他适用监管/平台要求的手段。当前只做Owner受限Staging，不开展公开运营或生产发布。

## 2. 固定基线

仓库：`zcx369658780/EliteSync-v10`

分支：`codex/v2-function-completion-20261121`

当前治理HEAD：本任务创建前分支最新HEAD `0418a13e66e2d8fe03024e371a38d51673b2de22`

云端业务源码：`7e0009df4fe69e48967c4fbc111717626c85ed80`

阿里云实例：`Ubuntu-zlxh`

V2 Compose：`elitesync-v2-shared-staging-beta`

数据库：`elitesync_v2_beta_staging` / `server_id=2621124`

当前V2回环入口：`https://127.0.0.1:18446/`

当前云端WSS/Workerman：关闭

历史1011805/1011806/1011807/1011808 APK与全部数据、备份和证据必须保留。

## 3. 技术依据：公开可信IP证书已可用

不得继续把“没有域名”当作技术上无法使用HTTPS的结论。

截至本任务日期，Let's Encrypt已一般可用地签发IPv4和IPv6地址证书，但IP地址证书必须使用 `shortlived` profile，证书有效期为160小时（约6.7天）。官方说明：
- https://letsencrypt.org/2026/01/15/6day-and-ip-general-availability
- https://letsencrypt.org/2026/03/11/shorter-certs-certbot

Certbot官方说明：Certbot 5.4+支持IP地址证书的webroot方式；使用 `--ip-address` 和 `--preferred-profile shortlived`。Certbot当前的Nginx/Apache安装插件尚未支持IP证书自动安装，需要手工配置证书路径及deploy hook。IP证书webroot示例先使用ACME staging测试。不得使用DNS challenge冒充IP验证。
官方材料：
https://letsencrypt.org/2026/03/11/shorter-certs-certbot

## 4. 阶段A：只读核实IP和运行环境

先只读核对：
1. 阿里云实例当前实际公网IPv4/IPv6及是否静态/长期绑定。
2. 公网IP是否全球可路由、未被保留/共享代理或NAT改变。
3. 当前安全组/轻量防火墙TCP 80、443、22规则和IPv6规则。
4. 主机Nginx当前有效server blocks、80监听、443无监听状态。
5. 旧站410、旧Nginx配置、LiveKit `/rtc`代理、DevPilot、V2回环18446健康。
6. Certbot当前版本、安装来源、systemd timer、renew配置、可用磁盘空间。
7. 是否已有其他ACME客户端或证书自动化任务，避免重复管理同一证书。
8. 当前主机时间同步与UTC时间正确性。

所有真实公网IP、证书路径和私有配置只放root私有目录，报告/GitHub仅写脱敏身份及指纹。

若公网IP不稳定、实例身份不一致、当前Nginx配置无法无损增加challenge location或存在无法保护的服务冲突，停止公网改动并报告。

## 5. 阶段B：Let's Encrypt IP证书验证

### 5.1 证书类型

优先只申请实际阿里云公网IPv4证书：
- SAN必须使用X.509 `iPAddress` 类型；
- 不得把IP写成DNS SAN；
- 证书链必须为系统/Chrome/Android可信链；
- IP必须与实际实例绑定一致；
- 不允许自签名证书或忽略证书错误。

若确有稳定公网IPv6并需要通过IPv6访问，再单独评估IPv6证书与访问策略；本轮默认不启用IPv6公网业务入口，除非IPv6目标和来源都完整核验。

### 5.2 ACME staging先行

核实Certbot版本至少5.4；如低于5.4，先评估已有包管理方式可否无采购升级，不能盲目替换系统包。

按Let's Encrypt官方方式先用ACME staging测试IP证书：
```bash
certbot certonly --staging \
  --preferred-profile shortlived \
  --webroot \
  --webroot-path <dedicated-acme-webroot> \
  --ip-address <verified-public-ipv4>
```

命令参数中的真实IP只在本机私有环境使用，不写GitHub、报告或普通聊天。

Certbot 5.4+的IP证书webroot方式可用；Nginx插件当前不支持IP证书自动安装。禁止把 `certbot --nginx` 当成已支持路径。

### 5.3 HTTP-01 challenge和端口80

IP证书验证需要CA能够验证IP地址控制权。优先采用webroot HTTP-01：
- 只为 `/.well-known/acme-challenge/` 建立专用静态challenge目录；
- 只返回当前ACME token文件；
- 80端口其他路径保持原有410/旧服务行为，不代理到V2、不返回任何管理/API/账号内容；
- 不改写或删除LiveKit `/rtc` 代理；
- 若安全组TCP80尚未放行，先评估是否可在受控短窗口内打开；由于CA验证源地址不公开，不得伪造固定CA IP allowlist。
- staging验证完成后，评估为自动续期保留“80端口仅challenge路径”的长期最小配置，或评估支持IP证书的TLS-ALPN-01客户端替代方案。
- 如果长期保留80 challenge路径不可接受，且无可靠自动化TLS-ALPN-01方案，停止正式证书签发并报告Owner，不得改用HTTP登录。

不得为获取证书临时关闭整站Nginx或中断LiveKit；除非独立维护窗口和回滚方案经过明确审查。

### 5.4 生产可信证书与自动续期

只有staging挑战、SAN类型、证书链和webroot行为均通过后，才签发一张正式公开可信IP证书。

正式证书有效期约160小时，必须在启用前完成：
- 自动续期timer核验；
- 定时频率满足短证书窗口；
- 自定义deploy hook；
- deploy hook先校验证书IP SAN、链、有效期和私钥匹配，再生成新Nginx引用；
- `nginx -t`通过后reload；
- 失败时保留旧配置并回滚；
- 证书续期失败告警及过期前告警；
- 使用ACME staging dry-run或等效测试验证续期与deploy hook，不高频请求生产CA。

证书文件、私钥及ACME账户资料保持root私有，私钥不进入GitHub或Docker镜像。

## 6. 阶段C：IP字面量边缘代理适配

当前DNS版本地准备不能原样用于IP：
- `render.py` 当前仅接受DNS hostname；
- `nginx.conf.in` 当前要求 `$ssl_server_name == host`；
- IP字面量TLS客户端可能不发送DNS形式SNI，不能继续把SNI等于IP当成必要条件；
- Android Gradle、原生ApiClient及Flutter `main_prod.dart` 当前均有拒绝数字IP/只接受DNS名的逻辑。

必须为IP模式增加显式且不可混淆的配置路径：
1. 输入只能是已核实的单个全球可路由IPv4字面量（IPv6若获准另行设计）。
2. `render.py` 用标准IP解析校验，拒绝私网、环回、链路本地、组播、未指定、保留和非法IP。
3. Nginx对IP模式严格校验HTTP Host为批准IP；不要求IP必须出现在DNS型SNI中。TLS安全性由浏览器对X.509 iPAddress SAN的校验保证。
4. 证书必须包含完全相同的iPAddress SAN。
5. 不为未批准IP设置默认V2站点；错误Host返回421/拒绝。
6. 若没有获批IPv6证书和来源，关闭或不创建IPv6 V2监听，防止IPv6绕过。
7. 代理上游继续使用固定 `https://127.0.0.1:18446`，保留 `proxy_ssl_verify on`、上游IP SAN和叶证书校验。
8. 保留四套独立来源表：APP、WEB_ADMIN、API_ADMIN、ACTIVATION。API_ADMIN和ACTIVATION默认空。
9. `realip_remote_addr` 必须对应直接TCP连接对端；确认不存在会改变来源的CDN/代理。客户端伪造X-Forwarded-For不得影响allowlist。
10. 80端口仅challenge路径；443仅批准来源；22保持原状，不在本任务修改SSH规则。

本地测试至少覆盖：
- IP证书SAN正确/错误；
- IPv4/IPv6 allowlist；
- 错误Host；
- SNI为空/客户端对IP访问；
- 伪造X-Forwarded-For；
- 非批准来源；
- 错误上游证书；
- 路由白名单；
- Web管理与普通APP来源隔离；
- 共享私信/Upgrade始终拒绝；
- Nginx reload和回滚。

## 7. 阶段D：Android远程IP Staging候选

新候选仍采用尚未构建的远程Staging版本身份 `1011809`；先确认该versionCode没有其他实际APK占用。

修改：
- `apps/android/app/build.gradle.kts`
- `apps/android/app/src/main/java/com/elitesync/network/ApiClient.kt`
- `apps/flutter_elitesync_module/lib/main_prod.dart`
- 对应原生/Flutter测试

远程IP模式必须：
- 使用 `https://<verified-public-ip>/`；
- 只允许构建时精确绑定的批准公网IP；
- 要求原生与Dart端点完全相同；
- Android系统可信证书链验证；
- 正常主机/IP SAN验证；
- 禁止裸HTTP、证书绕过、任意IP Bootstrap、旧生产站回退；
- 不固定短期叶证书指纹，以免证书自动轮换后客户端失效；
- WebSocket地址为空，`disableChatSocket=true`；
- 不启用RTC、公开注册或生产开关。

构建后回读：
- APK/AAR、libapp.so逐字节一致；
- 包名、versionCode、签名证书；
- IPv4端点与证书SAN；
- ABI、Manifest、Dart AOT；
- WS/RTC开关；
- APK SHA-256。

只允许本地构建，不自动安装。固定APK SHA后另行申请Owner指定手机安装授权。

## 8. 阶段E：精确来源与实际部署

Chrome和实体手机出口必须分别通过实际网络探测获得，不能从估计位置、历史日志、服务器运营商IP或模型推断。

可采用Owner分别从Chrome和手机访问一次不含账号资料、不要求登录的一次性source-probe路径，由服务端读取真实socket peer并保存到root私有回执。该路径不得回显公网IP，不记录任何认证材料，探测完成即关闭。若使用该方式，先核对80端口现有安全组和路由，不得扩大应用访问。

如果Chrome与手机共用同一Wi-Fi，仍分别探测并记录；若手机使用移动网络，单独记录移动网络出口。动态IP必须明确其维护成本；若频繁变化，提交现有VPN或其他受控方式方案，不自动采购。

正式部署前：
- 备份现有Nginx配置、站点链接、证书元数据、云防火墙规则、V2 Compose及私有env SHA-256；
- 确认独立SSH通道可用；
- 确认V2、DevPilot、LiveKit健康；
- 先收窄443到Owner精确来源，再启用V2 443 vhost；
- 443不允许 `0.0.0.0/0` 或 `::/0`；
- API_ADMIN和ACTIVATION保持空；
- 不影响旧HTTP 410及LiveKit `/rtc`；
- 不暴露数据库、Redis、FPM、Worker、Workerman内部端口。

完成后分别从Owner Chrome、实体手机执行：
- TLS可信链和IP SAN；
- 未登录/普通账号/未批准来源拒绝；
- Owner Web管理员登录；
- APP登录、资料、三盘、私有媒体、退出；
- 错误IP/错误Host/HTTP降级拒绝；
- 共享消息/WSS仍关闭。

真实WLAN四窗口、双物理设备仍分别记录，不得用模拟器或ADB reverse冒充。

## 9. 回滚

若IP证书、边缘配置或远程客户端失败：
- 使用独立SSH通道；
- 只撤销本次新增V2 edge include和本次443规则；
- 恢复原Nginx配置与规则快照；
- 关闭V2公网443监听；
- 保留V2回环18446及Docker服务；
- 不停止/删除V2数据库、卷、旧站、DevPilot、LiveKit；
- 复验DevPilot、LiveKit `/rtc`、V2 loopback；
- 保留失败配置、证书元数据和回滚SHA。

## 10. Owner输入与停点

Codex先完成阶段A、Certbot版本/支持能力核查、IP证书staging测试方案、本地IP代理适配和Android测试准备。

若需Owner精确来源或实际设备配合，集中一次请求：
- Chrome实际访问探测；
- 实体手机实际访问探测；
- 是否共用同一Wi-Fi/出口；
- 是否允许为ACME HTTP-01长期保留“仅challenge路径”的80入口（如果无法用安全可靠的TLS-ALPN-01替代）。

不需要Owner提供域名或DNS记录。

如果实际公网IP不稳定、证书不能被Chrome/Android系统信任、160小时证书不能可靠自动续期、端口80 challenge与旧服务冲突，停止公网443启用并提交明确证据，不用自签名证书或HTTP替代。

## 11. 交付

提交中文报告：
`V2_PUBLIC_IP_RESTRICTED_HTTPS_AND_REMOTE_STAGING_REPORT_20261122.md`

包含：
- 实例/IP稳定性去敏核验；
- Let's Encrypt IP SAN staging/production证据；
- 证书160小时生命周期和自动续期/deploy-hook验证；
- 80 challenge最小入口；
- Nginx IP模式来源表与上游TLS；
- Android/Flutter IP端点测试；
- 云安全组变更前后；
- Chrome/手机真实来源和远程测试；
- WSS仍关闭；
- 回滚结果；
- 所有PASS/FAIL/UNKNOWN/NOT_RUN。

所有真实IP、私钥、证书私钥、ACME账户凭据、owner来源地址、token、密码和私有env不得提交GitHub。

R1保持PARTIAL；封闭内测和生产保持NO_GO。
