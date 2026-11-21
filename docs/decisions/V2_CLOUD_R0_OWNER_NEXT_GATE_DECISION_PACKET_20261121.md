# EliteSync V2-CLOUD-R0｜下一步Owner集中决策包（顾问建议，尚非Owner决议）

日期：2026-11-21。工程[固定交付](https://github.com/zcx369658780/EliteSync-v10/blob/e431e0c9fca2be95fd1481d6afdcbaefac9cb6c0/docs/versions/v2/cloud-r0-20261121/V2_CLOUD_R0_ENGINEERING_REPORT_20261121.md)、顾问[独立限定验收](../workflow/V2_CLOUD_R0_ADVISOR_INDEPENDENT_SCOPED_ACCEPTANCE_20261121.md)。

## 四项门禁，按顺序决策

**1｜G0现时阿里云实例身份。顾问建议批准用户本人受控控制台登录后的有限只读核查。**  
当前`BLOCKED_LOGIN_REQUIRED`。Owner应自行在阿里云轻量应用服务器控制台登录，不向Codex/GPT输入密码/验证码/私钥；再由获准操作者核实实例归属、地域、实例ID、当前业务、CPU/RAM/盘、费用及有效网络身份。只产生脱敏证据；SSH需要另有独立可信host-key、账号、端口及最小只读权限。**未得G0确认不得执行云容器写入或管理员数据迁移。**

**2｜G1隔离云端Staging。顾问建议采用“实例及旧业务核查完成后，完全独立的新V2 Staging”而非覆盖旧后端。**  
本地PHP8.4.28+MariaDB10.11.19+三盘HTTPS已具名通过。现行Nginx`127.0.0.1`/localhost证书仅是本地链，不能直接用于外网实机。未来要有具名域名与TLS、受限入口、服务/DB/卷与旧站点隔离、镜像digest、有效容量、成本上限、回滚备份及监控。云实例、带宽/计费或生产端口变动须经Owner具名核验/批准；如果现有机器不足，先提供是否新增资源的预算而非自行下单。

**3｜G2真实管理员最小恢复。顾问建议批准继续备份元数据核验及合成演练，不提前批准真实解密与写入。**  
五月三份gzip+sidecar配对、一组两份GPG不透明hash都无法证明管理员来源或可恢复性。真实数据读取/解密前必须确定具名备份版本、来源服务器/数据持有人、逐个合法现时管理员主体和最少联系方式、合规目的、独立数据库、操作者和回滚。V2重新分配ID/密码及MFA/设备，原密码hash/Token/会话/其他用户资料不导入。真实管理员缺来源证明则先仅使用虚构管理员，不把“云端后端可用”卡在真实管理员恢复。

**4｜Connection门禁和Android单设备。顾问建议只讨论/批准一个`ISOLATED_SYNTHETIC_STAGING_ONLY`资格设计，不准全局解除`LiveConsentService::enabled()`。**  
实际源码先要求`restoration.enabled`和`APP_ENV∈{local,testing}`，当前`staging`返回404是正确fail-closed；不能靠`APP_ENV=local`或Header/自报`test=true`绕过。待Owner批准后可以编写实例绑定、服务器专用审计、仅虚构主体、过期撤销的受控新资格，保留Block/当前权限/MC/CN正反例。云Staging受限HTTPS可用、原生与Dart同时绑定独立API、不回退旧站、APK签名固定后，再由Owner确认唯一手机、网络和合成账号，实际验证Connection→双向同意→消息及撤权。真KYC/RTC/Push和真实用户依旧禁用。

## 优先权和当前要求

本轮**顾问建议**，非Owner已选择1～4项。当前立刻可做的非敏感工作：汇总当前控制台需要Owner登录的最短操作路径；本地复核镜像、测试脚本及证明新Staging不会访问旧网络；编写有界Connection资格方案但不启用。实际云写入、旧账号解密/导入、手机安装/设备操作须分别满足上述门禁。PC清理已完全结束。

**Owner本轮最小动作：在本人受控浏览器登录阿里云轻量应用服务器控制台，确认目标实例并提供去敏实例详情，之后再做G0只读复核。** 密码/验证码/SSH key永远不要粘贴到聊天或GitHub。
