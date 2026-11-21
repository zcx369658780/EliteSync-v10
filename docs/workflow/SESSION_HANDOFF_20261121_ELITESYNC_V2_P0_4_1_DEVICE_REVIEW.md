# EliteSync V2 P0.4.1 实机验收交接

2026-11-21（北京时间） · **`DEVICE_INSTALL_PASS_ON_AUTHORIZED_RETRY / DEVICE_E2E_PARTIAL / ADVISOR_REVIEW_PENDING / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`**

## 起点与固定证据

- 工程使用 `v2-cloud-r0-20261121` 隔离树，远端 `zcx369658780/EliteSync-v10`，开发分支 `codex/v2-function-completion-20261121`。归档前本地与远端均为 `e4d1588acee62d8f8f166042c328e26cc951c14a`，产品源码固定 `00ca46f6b020afa25ce472509c2fd3227f74c461`。保留原脏 main、历史审阅树和既有证据。下次先只读核对实际 Git 根、origin、分支、HEAD、工作树和暂存区。
- 治理分支 `governance/home-matching-product-freeze-20261117`，本次核得 `00f40fb598bc5d3d73b64d942ce2871e38d59d3d`。下次开场复核治理顶部及最新具名决定。开发分支顶部的工程回执记录实际进度，权限以 Owner 具名决定为准。 [固定治理状态](https://github.com/zcx369658780/EliteSync-v10/blob/00f40fb598bc5d3d73b64d942ce2871e38d59d3d/docs/workflow/ACTIVE_STATE.md) · [设备任务书](https://github.com/zcx369658780/EliteSync-v10/blob/00f40fb598bc5d3d73b64d942ce2871e38d59d3d/docs/versions/v2/V2_P0_4_1011806_DEVICE_ACCEPTANCE_AND_SHARED_BETA_ENVIRONMENT_DECISION_TASK_20261121.md)
- 固定实机报告含 A10/A12、145 项可复核哈希、候选与手机拉回 APK 的身份、原始失败和专用 MariaDB 证据。操作手册正文保持 1011805 底稿，1011806 证据使用独立附页。原件均留本机。 [1011806 实机报告](https://github.com/zcx369658780/EliteSync-v10/blob/e4d1588acee62d8f8f166042c328e26cc951c14a/docs/versions/v2/cloud-r0-20261121/V2_P0_4_1_ANDROID_1011806_DEVICE_AND_SHARED_HTTPS_REPORT_20261121.md) · [操作手册](https://github.com/zcx369658780/EliteSync-v10/blob/e4d1588acee62d8f8f166042c328e26cc951c14a/docs/versions/v2/cloud-r0-20261121/ELITESYNC_V2_OPERATION_MANUAL_DRAFT_20261121.md)

## Owner 决策与任务状态

| 决策或节点 | 延续口径 |
|---|---|
| 功能优先次序 | 核心功能 → APP/API/Web 集成与质验 → 软著准备 → Owner 批准的封闭内测 → 再评估换服或升级。G0b 本地报告仍待顾问见原文，保留 SSH、旧后端和备份证据。 [Owner 决定](https://github.com/zcx369658780/EliteSync-v10/blob/536dad49bbe6c7534ff2a3ecb313c8b6a29fc842/docs/decisions/OWNER_V2_FUNCTION_COMPLETENESS_BEFORE_SOFTWARE_COPYRIGHT_AND_CLOSED_BETA_20261121.md) |
| PC 清理 | Owner 已结束清理，13 项全部保留。 |
| 实机授权与重试 | Owner 已授权此前 1011805 的同一实体机并行安装并测试固定 1011806。首试 `INSTALL_FAILED_USER_RESTRICTED`，拒绝原因 UNKNOWN。Owner 在手机旁允许重试，第二次成功。PackageManager 两包并存、1011806 拉回文件与候选一致。本轮安装和测试会话已收尾。 [设备授权](https://github.com/zcx369658780/EliteSync-v10/blob/00f40fb598bc5d3d73b64d942ce2871e38d59d3d/docs/decisions/OWNER_V2_ANDROID_1011806_DEVICE_INSTALL_AND_P0_4_TEST_AUTHORIZATION_20261121.md) |
| 旧管理员与共享后端 | Owner 将具名旧管理员身份恢复列为封闭内测硬门，保留原手机号，V2 新 ID 与新激活凭据，Web 权限走实际管理员门禁。两名虚构管理员演练已获限定接受。真实资料读取、备份解密和目标写入仍须一次性具名数据授权。共享受限 HTTPS 还需独立云权限，历史上海同驻容量未证实，公开价格仅供参考。 [旧管理员决定](https://github.com/zcx369658780/EliteSync-v10/blob/a77ebe606048be884d4682f27f77527b8d6fe5c1/docs/decisions/OWNER_V2_LEGACY_ADMIN_ACCOUNT_RECOVERY_REQUIRED_FOR_CLOSED_BETA_20261121.md) |

## 工程结果与首要待决

- 1011806 为 `com.elitesync.v2functionp04`、arm64-v8a、209,094,076 字节，APK SHA-256 `3c855b8f796e7b79124d35ae2c605c3cf36574e89d569cb47d687d1f4ff4c130`。原手机 Android 16/API 36。APK 固定使用 `https://127.0.0.1:18444/`、原 Compose 和 `elitesync_v2_function` MariaDB 10.11、server ID 2621121。手机 WLAN 已恢复，USB reverse 恢复至本轮开始前的映射集合，本轮代理已停止，两版应用和原卷保留。
- 已验证冷启动、合成双账号切换、昵称和三盘持久读回、消息 UNKNOWN 独立 fresh GET、同键恢复与去重，以及双向 Block 生效时的撤权。A10 图显示主机置备且在手机真实渲染的合成封面，A12 图显示失权后的通知历史。Buddy 到仅本人草稿，慢约与正式关系到具名负例，Connection/消息同意的正向状态由本机 HTTP 置备后在手机读取。
- **A09 FAIL 待顾问复核。** 第一次 Block 生效时旧正文和控件失权。解除 Block 后经新好友、Connection 第 2 代与双方消息同意，实机再次看到第 1 代的 4 条正文。同一对账号再次 Block 后清除。请优先裁定跨生命周期历史的读取边界，再安排针对性修复与回归。
- 手机选图返回和 PNG/JPEG 端上上传、新好友及退出好友受众、设备缩略图、跨账号与过期真实链接、候选双方接受、正式关系双确认、Buddy 双方链仍有缺项。手机实际关开 WLAN 时 USB 请求仍为 200，真实断链四个窗口各为 NOT_RUN，本机传输注入单独计账。
- 原 P0.4 PHP 60/61，唯一失败 409 期待、实得 200。保留 P0.3/1011805、1011804 和更早历史 FAIL/UNKNOWN/NOT_RUN、F-01 READABILITY_PARTIAL 与 43 PNG PENDING_BINARY_UPLOAD。旧排盘 A/B/C、注册可信离线 T0 待 Owner 裁定，真实供应商能力按其各自证据记账。

## 本次工作流收尾

本次仅归档 P0.4.1 进度和授权记录。开发分支的状态和工作流顶部补充交接入口，历史正文保留。日常工程沿用 Local-first，Codex 负责实施、自验和非 main 同步，顾问做集中审阅，Owner 决定保留事项和正式准入。设备测试先比对固定 APK 与同一设备，原始私有证据留本机，GitHub 保存去敏报告与哈希。按环境区分手机 UI、手机 HTTPS、主机合成、数据库持久化和真实无线结果。启动时检查是否有更新裁决，收到后按新任务范围推进。本轮停止在顾问集中验收，封闭内测和发布状态维持 NO_GO。
