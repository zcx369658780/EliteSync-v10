# EliteSync V2｜P0.4.1 Android 1011806 实机回执

2026-11-21（中国标准时间） · **HOST_PREFLIGHT_PASS／DEVICE_INSTALL_FAIL_FIRST_ATTEMPT／DEVICE_CONFIRMATION_REQUIRED／DEVICE_E2E_NOT_RUN／CLOSED_BETA_NO_GO**

首次安装由手机系统返回 `INSTALL_FAILED_USER_RESTRICTED`，退出码 1。只读复核确认 1011806 仍未安装，原 1011805 仍在。已请 Owner 在原手机上处理系统 USB 安装确认。治理授权已经生效，状态只涉及手机侧确认。具体系统拒绝原因 UNKNOWN。 [Owner 设备授权](https://github.com/zcx369658780/EliteSync-v10/blob/00f40fb598bc5d3d73b64d942ce2871e38d59d3d/docs/decisions/OWNER_V2_ANDROID_1011806_DEVICE_INSTALL_AND_P0_4_TEST_AUTHORIZATION_20261121.md)

## 实际身份

- 工作区 `v2-cloud-r0-20261121` 为授权隔离树，origin 为 `zcx369658780/EliteSync-v10`，分支 `codex/v2-function-completion-20261121`，基线 `f41f25bb8c237f8479b998e82e843f528397e1fa`。四份指定治理文件从 `00f40fb598bc5d3d73b64d942ce2871e38d59d3d` 首读。 [P0.4.1 任务书](https://github.com/zcx369658780/EliteSync-v10/blob/00f40fb598bc5d3d73b64d942ce2871e38d59d3d/docs/versions/v2/V2_P0_4_1011806_DEVICE_ACCEPTANCE_AND_SHARED_BETA_ENVIRONMENT_DECISION_TASK_20261121.md)
- 本机 APK 209,094,076 字节，`com.elitesync.v2functionp04 / 10.1.18-v2-function-p04 / 1011806`，arm64-v8a。SHA-256 为 `3c855b8f796e7b79124d35ae2c605c3cf36574e89d569cb47d687d1f4ff4c130`。APK v2 验证通过，证书 SHA-256 为 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。AAR SHA-256 为 `b81774a1730c0835161ee443625493c93c006543192c7b4beffe83afb36466aa`，APK 与 AAR 的 Dart 库字节一致。DEX/Dart 两端点均为 `https://127.0.0.1:18444/`。 [固定候选报告](V2_P0_4_HARDENING_AND_BETA_AUTHORIZATION_REPORT_20261121.md)
- ADB 在线实体机为 25060RK16C，Android 16/API 36，序列号与原私有记录精确一致。Windows ADB 的可选 USB 元数据缺席，初始辅助断言停在只读检测。随后核对了已保存的物理序列号、ADB 状态、型号和系统版本。完整序列号留本机。
- 原三个专用容器已运行，原 MariaDB/媒体卷身份均吻合。运行库 MariaDB 10.11.19、`elitesync_v2_function`、server ID 2621121。固定指纹 `41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96` 的本机 HTTPS 返回访客 401。安装前确认 1011806 缺席并建立本轮 18444 映射，受阻后只移除本轮映射并回读原映射列表一致。两名新虚构账号已置备，凭据留在本机受控目录。

## 实机结果矩阵

| 范围 | 状态 | 实际证据 |
|---|---|---|
| 工件、原设备和本机后端预检 | PASS | 文件、签名、包名、AAR、端点、TLS、设备、原库与原卷核身通过。 |
| 1011806 安装 | FAIL | `INSTALL_FAILED_USER_RESTRICTED`。手机 PackageManager 查不到新包。 |
| 手机拉回 APK、启动、冷启动、前后台 | NOT_RUN | 安装受阻，手机侧 APK 原件和运行证据尚无。 |
| 登录、退出、切号、资料和三盘 | NOT_RUN | 仅置备两个虚构账户，手机侧 UI/HTTP/数据库联动待实测。 |
| A→B/B→A Block、重复、UNKNOWN、消息 GET/幂等和控件失权 | NOT_RUN | 1011806 无可用前台。已接受的本地 Widget 与 API 证据按原范围保留。 |
| Photo Picker、合成图上传、SELF/FRIENDS、历史受众和缓存、故障重试 | NOT_RUN | 手机无选择或上传记录，原相册未访问。合成 PNG 在本机置备。 |
| 外部 URI、地图回调、当前与旧通知、冷/热启动 | NOT_RUN | 无新包 UI、Intent 或 1011806 A12 图。 |
| 真实无线中断的四个窗口和恢复 | NOT_RUN | 本轮只建立和收回 USB 端口，计为线缆转发操作。无线网络关闭是否让 APP 断链须独立测量，当前固定地址经 USB 转发。 |
| 1011806 A10/A12、W01–W04、设备脱敏 logcat | NOT_RUN | 无新包运行截图或进程日志。旧 1011805 证据继续归属原版本。 |

原 P0.4 PHP 扩围 60/61，唯一失败为上批亦可复现的 409/200 差异。旧全量及设备 FAIL、UNKNOWN、NOT_RUN 不变。 [P0.4 底账](V2_P0_4_HARDENING_AND_BETA_AUTHORIZATION_REPORT_20261121.md)

## 共享 HTTPS 决策准备

| 方案 | 当前可核结果 |
|---|---|
| 现有上海旧机 | 沿用只读原证 2 vCPU/2 GiB、约 627–628 MiB 可用内存、swap 0、旧 Laravel/MariaDB/Redis/LiveKit 同驻。并行容量未核准。只有无需升配且原套餐网络足够时，新增实例本体费用才可按零估。现账单、续费、带宽与峰时负载待获准后核。 |
| 独立上海 Staging | 以 2 vCPU/4 GiB/50–60 GiB 为候选。阿里云开发者社区公开参考为 70 元/月刊例或 379 元/年活动档，活动、上海库存、账号资格、续费、税费及实际结算均 UNKNOWN。轻量旧固定流量内地溢出 0.8 元/GB，轻量内置快照免费且有数量上限。ECS 另核系统盘、EIP/带宽或流量、快照存储、VPN、备份保留和续费，价格计算器未给具名订单报价。 |

共享环境需要独立 V2 FPM、worker、数据库账号/schema、媒体和数据卷、应用密钥与会话。使用可信 TLS 和具名访问限制，Web 管理和激活入口额外限制来源或经 VPN，数据库、Redis、FPM 保持内部网络。先做合成账号外地 HTTPS、远程权限和回滚演练。后续共享 APK 另固定原生/Dart 端点和签名。当前云端支出 0 元。 [阿里云轻量公开参考](https://developer.aliyun.com/article/1784154) · [轻量计费](https://help.aliyun.com/zh/simple-application-server/product-overview/billable-items) · [ECS 计费](https://help.aliyun.com/zh/ecs/billing-overview) · [EIP 计费](https://help.aliyun.com/zh/eip/billing-overview)

真实管理员数据授权包沿用 [独立签名、持有人及最小字段模板](V2_P0_4_HARDENING_AND_BETA_AUTHORIZATION_REPORT_20261121.md#一次性真实管理员数据授权包待-owner-确认)。真实候选数 UNKNOWN，实际候选清单、签名配置、旧库读取、备份解密和迁移均待 Owner 另行具名批准。共享 HTTPS、全部指定旧账号恢复及本人外地登录均是内测准入硬门。

## 本机证据哈希

| 文件 | SHA-256 |
|---|---|
| `install-attempt-01.log` | `a13a10af956a3f2c31a79a58ff27e95a088c0f508be436f8f2151101e81018a0` |
| `install-stop-receipt.md` | `cbc5a15a3f194ffa7e13ecc3b849f327fb84f97b1f3893295e00fd9babb85cff` |
| `fixture-seed.log` | `7451c783ae2051f64b97ed4c745835fe81236e04b34b78fad3ed5c492a77d3d2` |
| `reverse-close-01.log` | `4420ce8326902775797673621c664e24a6439d95ba5a6db66540cb8e996ca39a` |
