# EliteSync V2｜受限公网 HTTPS 接入、共享私信准备与远程设备验收任务

日期：2026-11-22（中国标准时间）

## 1. Owner最新授权

Owner已明确同意进入：

1. 现有阿里云V2后端的受限公网HTTPS接入。
2. 共享私信/WSS的下一阶段准备。
3. 绑定远程Staging端点的新Android候选准备及远程设备验收。

本轮复用现有阿里云实例和现有V2 Docker运行栈。不购买新服务器，暂不升配。

本授权不等于开放匿名公网访问，也不等于自动启用共享私信、生产RTC、公开注册、真实管理员批量导入或封闭内测。

## 2. 固定基线

仓库：`zcx369658780/EliteSync-v10`

开发分支：`codex/v2-function-completion-20261121`

当前固定交付：`cd8f1669a52edf417fe4f31398d41bc692c427e7`

业务源码：`7e0009df4fe69e48967c4fbc111717626c85ed80`

云端业务源码镜像身份沿用：
`sha256:5a7ee83db71cdf799c0998233e3dc0b9e3ad0958fa77227f590bd15063ac99cf`

现有阿里云V2实例：`Ubuntu-zlxh`

V2 Compose项目：`elitesync-v2-shared-staging-beta`

V2目标数据库：`elitesync_v2_beta_staging`

MariaDB：`10.11.19`

server_id：`2621124`

当前V2入口：回环HTTPS `127.0.0.1:18446`

当前已恢复管理员：`ADMIN-TEST-01` / 内部代号 `V2-ADMIN-01`

当前Staging登录APK：`1011808`，仅绑定回环端点，不能直接当作公网版。

## 3. 首读

读取：
- `AGENTS.md`
- `docs/workflow/ACTIVE_STATE.md` 顶部CURRENT ENTRY
- 管理员恢复固定报告 `V2_ADMIN_TEST_01_RESTORE_AND_ADMIN_ACCOUNT_INVENTORY_REPORT_20261122.md`
- 旧栈退役及Beta部署报告 `V2_LEGACY_STACK_RETIREMENT_AND_BETA_CUTOVER_20261122.md`
- `services/backend-laravel/docker/shared-staging/RUNBOOK.md`
- 当前Compose、Nginx、Staging环境示例
- Android原生和Dart API端点配置及TLS证书校验代码
- Web管理员路由、管理员激活路由、API认证和Workerman授权代码
- Owner已接受的D-03、APP-T07及P0.4.2 R1相关合同

不递归历史handoff，不重做已接受的P0.4.2测试。

## 4. 保护与禁止事项

所有旧数据库、旧媒体、旧配置、ADMIN_PHONES来源、旧栈归档、V2数据库和媒体备份、恢复Manifest、审计记录及1011805/1011806/1011807/1011808 APK与证据必须保留。

不删除或覆盖任何备份，不清理旧卷。

不购买服务器、不升配、不采购域名、证书、VPN或第三方访问服务；如发现必须付费，提交实际报价并等待Owner确认。

不开放全网匿名访问，不把管理后台、激活页、数据库、Redis、FPM、Worker或内部WebSocket端口暴露到公网。

不修改旧站、不影响DevPilot及LiveKit。

不修改真实管理员账号、不再执行管理员恢复。

不开放生产RTC、不公开注册、不启用生产配置。

## 5. 阶段A：云端现状与网络只读核查

在阿里云只读核查：

1. 实例身份、资源及当前健康状态。
2. 云安全组443规则的协议、来源CIDR、优先级及绑定实例。
3. 主机iptables/nftables/ufw状态。
4. 主机443监听、Nginx虚拟主机及证书。
5. 现有DNS域名、解析目标、证书SAN、有效期和私钥归属。
6. V2回环18446及证书身份。
7. 旧Nginx配置和LiveKit /rtc代理现状。
8. SSH管理来源限制。
9. Docker Compose容器、网络、卷、镜像和资源。
10. 最近一次ADMIN-TEST-01 APP/Web登录会话及服务健康只读确认。

不将历史“443已放行”当成当前安全组配置证据。先核对真实来源CIDR；如规则为0.0.0.0/0或::/0，报告明确指出，不能因其存在就认定受限。

所有IP、域名、证书私钥路径和真实账号只存于root私有目录，不写入GitHub。

## 6. 阶段B：受限公网HTTPS设计与接入

### 6.1 访问模式选择

优先评估以下方案，按安全性和Owner现有条件排序：

A. 已有VPN/受控私网入口（若当前已经存在且不需新增采购）；
B. 公网443 + 精确来源IP allowlist + HTTPS；
C. 如果Owner设备出口IP动态变化，提出低成本VPN或其他受控接入方案，但不自行采购或注册第三方服务。

必须能同时覆盖Owner Chrome和实体手机。若二者出口不同，必须分别登记并验证。

不得猜测Owner当前公网IP。不得把模型估计地理位置或服务器日志中的历史IP当作Owner授权来源。需要Owner提供精确来源CIDR时，先完成其余准备并一次性提出。

### 6.2 域名与TLS

优先使用Owner已经拥有且可控的Staging域名。不得臆造域名或自动更改DNS。

若无可用域名，提交所需域名信息及证书方案，等待Owner补充。

TLS必须：
- 使用匹配域名的可信证书。
- 证书SAN覆盖实际域名。
- 校验链、有效期、私钥权限及自动续期方案。
- 不关闭证书验证。
- 不沿用仅含127.0.0.1 SAN的本地证书作为公网证书。
- 外层Nginx/边缘到V2回环上游也须验证上游证书身份，不能使用`proxy_ssl_verify off`作为绕过。
- 正确传递Host、X-Forwarded-Proto及可信代理信息，防止伪造转发头。

### 6.3 外层边缘入口

优先复用主机现有Nginx，不覆盖旧配置；新增独立vhost或独立include文件。

上游只连接V2回环HTTPS `127.0.0.1:18446`，使用严格上游证书验证。

限制：
- 443只允许已批准来源访问。
- 80不开放，除非证书签发/续期确实需要且采用临时最小化方式并经审查。
- 数据库、Redis、FPM、Worker、Workerman端口不得发布。
- 入口仅转发已批准的API和Web路径。
- 管理后台`/admin`、`/api/v1/admin`、`/admin/legacy-activate`及其他敏感路径必须单独限制来源，优先VPN/具名来源allowlist。
- 不开放公开注册、公开管理入口和公开激活入口。
- 不启用WSS路径。
- 登录及激活请求不得记录密码、Authorization、Cookie、激活码、URL查询秘密或手机号。
- 增加合理的请求体限制、连接/速率限制、超时及安全响应头。
- 拒绝非批准来源并验证IPv4、IPv6两种路径，防止IPv6绕过。

### 6.4 变更执行

先在本地生成配置、Nginx语法检查、Compose配置检查、证书验证脚本和回滚脚本。

在云端变更前：
- 备份现有Nginx配置及证书元数据。
- 保存云安全组规则快照。
- 保存V2 Compose和私有env SHA-256。
- 确认SSH独立管理通道不会被新规则阻断。
- 确认LiveKit /rtc和DevPilot健康。

仅当域名、TLS和精确来源限制已确认后，才执行受限443接入。不得先开放0.0.0.0/0再补allowlist。

完成后从批准来源执行正向测试，并从未批准来源执行拒绝测试。

## 7. 阶段C：Chrome与实体手机远程Staging验证

### Chrome

- 使用Owner已恢复的ADMIN-TEST-01登录。
- Web管理员路由要求现有AdminAccess、account active、admin.phone组合授权。
- 验证未登录、普通账号、非批准来源均被拒绝。
- 不改变真实管理员角色或名单。

### Android

现有1011808固定127.0.0.1:18446，不能直接用于远程公网访问。

先完成候选源码端点切换：
- Android原生API端点。
- Dart/Flutter API端点。
- TLS证书信任与主机名校验。
- WebSocket端点保持空或禁用。
- 生产旧站回退禁止。
- 共享私信继续关闭。

构建独立的新Staging APK，记录源码commit/tree、versionCode、包名、签名证书、AAR/libapp.so、APK SHA-256及端点身份。

本轮允许本地构建，不自动安装新APK。固定新SHA后，向Owner申请指定设备安装授权。

## 8. 阶段D：共享私信授权准备（不开放）

Owner同意进入共享私信准备，但当前StagingSyntheticConnectionScope仍未获准启用。

本轮允许：
- 复核现有Connection/MC授权合同。
- 完成StagingSyntheticConnectionScope方案和威胁模型。
- 设计CLI授权清单、唯一实例/DB/batch/A-B对绑定、有效期、撤销和审计。
- 在本地合成环境实现及测试候选代码。
- 检查未授权用户、无Connection用户、无双方MC用户的拒绝语义。
- 设计WSS正向101、事件、Block、撤权关闭、旧令牌拒绝和第二代重连测试。

本轮禁止：
- 在云端开启`STAGING_WS_ENABLED`。
- 设置`MATCHING_FOUNDATION_WEBSOCKET_ENABLED=true`。
- 生成云端共享Connection/MC。
- 对真实用户或真实管理员开启共享私信。
- 将未授权Workerman请求的502当成正确业务拒绝。应在开放前定义可区分的401/403/404语义并验证，但保持WS关闭。

完成后提交单独Owner决策包，确认是否授权云端合成Connection及WSS正向验证。

## 9. 阶段E：手机与网络测试准备

本轮先准备远程Staging设备验收清单：
- Owner实体手机25060RK16C。
- Android模拟器作为第二测试端，但不得冒充第二物理设备。
- API登录、资料、三盘、私有媒体、账号退出。
- 证书错误、来源不在allowlist、网络切换和TLS主机名负例。
- 双物理设备A/B仍NOT_RUN。
- 真实WLAN四窗口仍NOT_RUN，除非后续具备真实WLAN受控路径并取得有效证据。

不把ADB reverse/SSH tunnel结果冒充公网远程或WLAN测试。

## 10. 回滚要求

若公网HTTPS配置失败：
- 先从SSH管理通道恢复上一个已验证Nginx配置。
- 恢复前后保留配置及SHA-256。
- 只撤销本次新增vhost/规则，不覆盖旧Nginx和LiveKit配置。
- 关闭新V2公网入口，保留回环18446。
- 不停止V2 Docker后端，不删除数据库或卷。
- 复验DevPilot、LiveKit /rtc、V2 loopback健康。
- 不清理任何证据。

## 11. Owner需补充的最小信息

Codex先只读检查现有域名、证书及安全组。

若没有可直接复用的受限入口，一次性向Owner提交：
1. 现有Staging域名是否可用；若无，Owner提供已拥有域名。
2. 访问策略：现有VPN或精确IPv4/IPv6出口CIDR。
3. Chrome和实体手机是否共用同一出口；如不同，分别提供。
4. 是否允许为域名DNS添加一条指定A/AAAA记录（只在确认后执行）。

不要求Owner再次批准本地配置、测试和候选构建。DNS、云安全组、主机公网监听等实际变更在准确目标和allowlist确定后，按本任务已批准的受限HTTPS范围实施；若出现新增费用或扩大到全网访问，必须重新审批。

## 12. 最终交付

同步原非main开发分支，生成中文报告：

`V2_RESTRICTED_PUBLIC_HTTPS_AND_REMOTE_STAGING_ACCESS_REPORT_20261122.md`

至少包含：
- 当前域名、TLS、443安全组和主机监听的去敏身份。
- 最终访问策略及批准CIDR引用（不公开具体Owner IP）。
- Nginx配置及上游TLS验证。
- 公网正向/负向测试。
- Chrome登录结果。
- 新APK身份及SHA-256。
- Owner实体手机远程登录结果（如获授权安装）。
- Workerman/WSS仍关闭的证据。
- SyntheticConnectionScope设计和Owner决策。
- 双物理设备、媒体、WLAN剩余门槛。
- 所有PASS、FAIL、UNKNOWN、NOT_RUN。
- 回滚结果及DevPilot/LiveKit健康。

不上传私钥、证书私钥、真实IP、密码、Cookie、Token、激活码、数据库导出、私有env或管理员个人信息。

R1继续PARTIAL；封闭内测和生产保持NO_GO。
