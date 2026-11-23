# EliteSync V2｜P0 资料恢复与 P1 公网 HTTPS 会话交接

2026-11-23（北京时间）。开发分支 `codex/v2-function-completion-20261121`，本轮执行基线 `43080f9a2bbcce5dbb6ed3cb0086ce945b02b1e3`。云端业务源码 `7e0009df4fe69e48967c4fbc111717626c85ed80`，Git tree `80b7237fcd0c7d569a7026d4a73d1e0c34ef86b9`。实例 Ubuntu-zlxh，V2 Compose `elitesync-v2-shared-staging-beta`，库 `elitesync_v2_beta_staging`，`server_id=2621124`，上游 HTTPS 仅回环 18446。

**P0_PROFILE_API_AND_RESTART_PASS / OWNER_IAB_WEB_ADMIN_PASS / CLOUD_EXACT_ONLY_RETEST_PENDING / REMOTE_ANDROID_NOT_RUN / R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO**

## P0 与既有账号验收

- ADMIN-TEST-01 是唯一恢复账号。Owner 选择本人声明号码控制并独立签署 Ed25519，真实短信挑战 NOT_RUN。签名 dry-run、apply、激活及原回环 Web、1011808 实体 APP 本人登录均已完成。旧来源映射 active，其他旧账号恢复映射 0。原激活已消费，旧库独立恢复及旧/V2 归档核验沿用。 [管理员恢复报告](V2_ADMIN_TEST_01_RESTORE_AND_ADMIN_ACCOUNT_INVENTORY_REPORT_20261122.md)
- P0 使用现有 `legacy_admin_mappings` 唯一绑定。旧主库精确匹配 1、辅助旧库 0。备份隔离恢复、字段 dry-run、事务 apply、资料 API 返回 200 及 staging-app 重启后 8/8 读回通过。恢复生日、性别、城市、关系目标、出生时间、出生地点及成对经纬度。昵称语义 UNKNOWN，保留原值。密码、权限、有效会话、旧映射和历史审计核对通过。Owner APP 资料页仍待验。 [P0 资料报告](V2_ADMIN_TEST_01_LEGACY_PROFILE_DATA_RESTORE_REPORT_20261122.md)
- 1011809 候选 `com.elitesync.v2stagingremote` / arm64-v8a，源码 `b974d7e659da2cc622450f72ae338280d50faec0`，包含 P0 坐标解析修复 `1b37be22361f54ad0641843e1f803896578fbe96`。APK SHA-256 `8f1c47c843b44021d6f43063f8a1fcf51c7dd61e20336f86fe18ef6625fd7109`。已核原生与 Flutter 端点、签名及 AAR/APK/AOT 一致性。安装和实机运行 NOT_RUN。 [候选与 P1 准备报告](V2_PUBLIC_IP_RESTRICTED_HTTPS_AND_REMOTE_STAGING_REPORT_20261122.md)

## P1 部署与现场结果

- 复用阿里云轻量实例随实例分配的公网 IPv4。实体手机实际 Wi-Fi 与桌面 Chrome 在独立一次性窗口测得同一个公网 IPv4，Owner 批准唯一 /32。探测已结束，原临时路径已撤销。来源窗口和一次手机 HTTPS 浏览器检查的授权均已消费。
- Owner 授权长期 ACME challenge-only 80 路径、正式 IP 证书、受限 443 及网页告警。独立 Certbot 5.4.0 已签发约 160 小时的公开可信 IP SAN 证书。续期与健康 timer、真实 deploy hook 的 staging dry-run、隔离故障回滚及网页读取 OnFailure 测试事件均核验通过。主机旧站 410、旧 RTC 路由基线及 V2、DevPilot、LiveKit 健康检查通过。
- 外层 Nginx 的 APP 与 Web 管理分别匹配获批来源，API 管理、激活与 Upgrade 仍拒绝。固定回环上游 TLS 严格校验。云防火墙起初仅开精确 /32，桌面物理网卡对照的 22 和 80 抵达主机，443 超时且主机未观察到获批来源的 443 流量。阿里云自助网络诊断 8/8 通过，未提供逐连接结果。单次手机浏览器检查未获得 HTTP 200，导出编码失败后仅只读恢复，保留原回执。
- 阿里云工程师建议启用控制台所示的 443 规则。Owner 本人启用旧全 IPv4 TCP 443 规则，控制台回读全网规则和精确 /32 同时启用。随后桌面严格 TLS 的 `/up` 与 `/admin/login` 均返回 200，Nginx 记为获批来源。Owner 完成评价后，工单显示「已完结」。这次对照没有确立仅 /32 时的具体阻断机制。
- Owner 在 Codex 内置浏览器本人登录。HTTPS `/admin` 显示「用户管理」和退出入口，云端脱敏日志包含获批 Web 管理来源的 302 与 200。内置浏览器 Web 登录 PASS。独立 Chrome 登录、恢复后的手机远程 HTTPS、1011809 APP 登录和资料页、真实 WLAN 及双物理设备待验。现场全网 443 启用属 Owner 操作，当前远程 Web 通过不得作为仅 /32 的验收结论。

## Owner 决策与续作边界

- 优先用 Codex 内置浏览器或可用浏览器插件，避免全局鼠标键盘控制。先确认可信 HTTPS 登录页可用，再显示给 Owner 手动登录。登录后以页面和脱敏日志回读验收，区分内置浏览器、独立 Chrome 和实体设备。Owner 手动转交网页 GPT 顾问的 prompt 和回复。
- 续作先读 AGENTS、ACTIVE_STATE 首项及本报告，核实际 Git 和只读现场状态。仅 /32 的公网链路需另行验证，涉及现有 443 规则调整时按 Owner 当期决定执行。装机需重新取得 Owner 对固定 APK SHA-256 与具名手机的授权。已消耗的探测和手机动作保留原预算。正式证书验收与顾问集中复验分别记录。
- 共享 Connection、共享私信和 WSS 关闭。公开注册、生产 RTC、封闭内测与生产不放行。不合 main。保留原脏 main、独立工作树、历史 APK、旧库、媒体、配置、备份及历史 FAIL。真实源和目标 IP、手机号、旧用户 ID、账号资料、工单号、私钥、激活码与原始回执留私有。原始证据由 Owner 从本机私有索引核查。

## 脱敏证据索引

下表 SHA-256 对应本机证据文件。P0 另有 [脱敏证据索引](V2_ADMIN_TEST_01_LEGACY_PROFILE_DATA_RESTORE_EVIDENCE_INDEX_20261122.md)。表中仅列文件名和哈希。

| 证据文件 | SHA-256 | 覆盖 |
| --- | --- | --- |
| `04-candidate-source-consistency.json` | `5c55e5803d324e00367e6498e683c761eeed846768e52689e3bfb953ddeca835` | 1011809 源码与 P0 修复及构建一致性 |
| `03-real-rollback.json` | `778bcd34760c6b09acd4eee6c0dfa6b597d8f2f79a29ec62541669d396986d24` | 隔离 Nginx 实际故障回滚 |
| `12-source-pair-readback.json` | `b5c660bbea03843fac2c8ca823c857ced17adaf23bcc5ea66654f58e810470fc` | Chrome 与实体 Wi-Fi 的两个来源窗口 |
| `02-production-certificate.json` | `da22d13e4b05a63052dee9381b7a548cf5e3796afb18ecc9be2751435564ec8a` | 正式证书、可信链与 IP SAN |
| `04-edge-activation.json` | `29fb9789b6313a03359fa91ff3f9f5cf104778760db43a9cfa41decc77ed7908` | 边缘代理、严格上游 TLS 与拒绝路径 |
| `06-renewal-rehearsal.json` | `a77ee5cf1c54fe070b38c950882bc5c59887fb45ee9bee11bb86211a50397b6d` | 正式 lineage staging dry-run 与真实 hook |
| `01d-web-alert-browser.json` | `8b778cc8cdc8700d1992c574598b9cfa01e0f20a405f4a87c5c817ada1c6b799` | 网页接收真实 systemd 测试告警 |
| `08b-phone-https-recovery.json` | `b751955c561fe127d40309002d88fdfdb6854bf402bb5f987a2696b5f7165ae6` | 一次获批实体手机观察的只读复核 |
| `09b-physical-port-comparison.json` | `f534841d23c8a8a114ace7713f32d348c6db99ece1fdf9f26602136509fdf8c3` | 限定来源的 22/80/443 对照 |
| `09c-ali-cloud-console-diagnosis.json` | `28fd02a0dabfe08c88c231e391111a51dd5b6be55c9551ea39a10f8565092e81` | 仅 /32 启用时的规则与实例诊断 |
| `09e-aliyun-ticket-submission.json` | `a19258a02a4435dac5b498501420e976d8bce690d1f74bd7a5ffd7df2cbaf2e9` | 阿里云官方支持工单受理 |
| `09f-desktop-443-retest-134132.json` | `a13dcf92a1c25d88eb334f18a4ed628010a103ddb26394e076e9cb97d848bdcc` | Owner 操作前严格 TLS 失败与主机健康 |
| `09g-post-owner-443-retest-134237.json` | `bf0f19239bb95ce8454f11be78694b1acc01e587b071f8a32153d4504ea90806` | Owner 操作后两个 HTTPS 路径返回 200 |
| `09h-owner-embedded-browser-admin-login.json` | `34c02f7020d7d7379d03bdf9fa5d7077c3875b526d23ab30fe96e9e086b48faf` | 本人公网 Web 登录、云端日志及工单完结 |
