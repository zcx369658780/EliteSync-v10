# EliteSync V2｜P0.3 Android 1011805单台实体设备完整旅程验收任务

日期：2026-11-21。状态：`OWNER_DEVICE_AUTHORIZED / ANDROID_REVERSE_INSTALL_EXECUTION_AUTHORIZED / DEVICE_E2E_PENDING / CORE_FUNCTIONS_PARTIAL / CLOSED_BETA_NO_GO`。

依据：
- [P0.2顾问限定验收](../../workflow/V2_FUNCTION_P0_2_ADVISOR_SCOPED_ACCEPTANCE_20261121.md)
- [Owner单设备明确授权](../../decisions/OWNER_V2_ANDROID_1011805_SINGLE_DEVICE_TEST_AUTHORIZATION_20261121.md)
- [P0.2固定报告](https://github.com/zcx369658780/EliteSync-v10/blob/daa96756f96fb6fd62845323ebd3c53d2b2438d2/docs/versions/v2/cloud-r0-20261121/V2_FUNCTION_P0_2_MARIADB_RELATIONSHIP_AND_DEVICE_REPORT_20261121.md)
- [1011805主机设备脚本](../../../../tools/android/v2-function-1011805-device.ps1)
- [操作手册初稿](https://github.com/zcx369658780/EliteSync-v10/blob/daa96756f96fb6fd62845323ebd3c53d2b2438d2/docs/versions/v2/cloud-r0-20261121/ELITESYNC_V2_OPERATION_MANUAL_DRAFT_20261121.md)

## 0. Owner授权已经具备，不得重复索要

Owner已在2026-11-21当前对话明确表示：“好的我确认授权，下一轮可以实机检验，设备就绪。”对应记录：[Owner授权决定](../../decisions/OWNER_V2_ANDROID_1011805_SINGLE_DEVICE_TEST_AUTHORIZATION_20261121.md)。

因此：
- Codex不得再问Owner是否允许安装/实机测试，不得把旧报告中的`DEVICE_OWNER_GATE`继续作为阻断。
- `tools/android/v2-function-1011805-device.ps1`的`OwnerAuthorizationReference`填写上述治理决定路径/Owner对话授权引用即可。
- 仅当本机发现多台实体设备、无法识别Owner指定设备、或当前设备没有USB授权时，才暂停相应设备步骤并提出最小澄清；不是重新申请授权。

## 1. 固定APK身份（禁止重建或替换）

- Package：`com.elitesync.v2functionp0`
- Version：`10.1.18-v2-function-p0 / 1011805`
- ABI：arm64-v8a
- APK bytes：209,094,024
- APK SHA256：`d6064498bac327f40f2b2df9c5ed9664c819b29dfaffa916eaf6f6df7b649c05`
- Android Debug v2 signing cert SHA256：`9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`
- Native+Dart endpoint：`https://127.0.0.1:18444/`
- TLS cert SHA256：`41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96`

测试包与正式APP不同applicationId，不得将其改成生产包。APK hash/签名任一不一致，停止，不安装。

## 2. 启动本机隔离服务（不得触碰云端）

P0.2测试后三个容器已正常停止、两个专属卷保留。执行前：
1. 核当前工作树、Compose文件、项目名`elitesync-v2-function`、volume label、secret目录、DB/schema/server_id和回环TLS证书。只认`elitesync-v2-function`的本地服务，不复用旧项目/旧9.1C/阿里云。
2. 用`docker compose -f services/backend-laravel/docker/cloud-r0/compose.function.yaml ps -a`、`docker compose ls`和volume inspect确认目标容器/卷。不得执行`docker compose down -v`、volume prune、删除数据卷或全局Docker清理。
3. 仅启动该专属Compose的MariaDB/FPM/入口/worker。确认数据库server_id=2621121、schema`elitesync_v2_function`、app账号和MariaDB10.11；HTTPS访客请求固定证书返回401。任何identity不符就停，不做迁移/重建/换卷。
4. 服务健康后再运行Android Host预检。确保无任何请求发往`slowdate.top`、阿里云旧站或公网。

## 3. 识别唯一实体手机并执行ADB Reverse/Install

- 使用Android SDK platform-tools执行`adb devices -l`，确认授权USB实体设备。若恰有一台physical device，直接使用；若多台实体设备，向Owner确认哪台，不再询问授权；若只有emulator，拒绝使用并等待实体机接入。
- 序列号仅本机日志保留，GitHub报告只写脱敏设备标识（如hash短码/型号与Android版本，不写完整序列号）。
- 运行脚本`Stage=Host`，随后`Stage=Reverse`，再`Stage=Install`，每次传入实际serial和OwnerAuthorizationReference引用。保留命令、exit、APK identity和映射证据。
- Reverse用`adb reverse --no-rebind tcp:18444 tcp:18444`，不得覆盖现有映射。若发现已存在映射，先只读确认归属；不是本轮建立的就不删除、不覆盖。安装前脚本发现相同package已安装必须停止并报告，禁止卸载/清数据/覆盖。
- 安装后核对`pm path`、package/versionCode、签名。通过实际launcher解析启动应用，不猜MainActivity。
- 设备操作只针对EliteSync测试包。允许采集本应用截图和相关logcat；不读取其它App、私人照片、联系人、短信、无关通知、账号或设备文件。媒体测试使用专门生成/提供的合成图片，不打开私人相册。未经额外授权不请求相机/麦克风录制。

## 4. 当前版实机旅程（两名合成账号）

先使用MariaDB P0.2已准备的合成账号/CLI身份资格，避免通过UI新注册普通账号后错误假设其具备TEST_ONLY匹配资格。账号密码与签名secret仅本机私存，禁止写GitHub。

按实际UI入口完成：
1. **安装/冷启动**：启动、健康端点、证书、访客态401/未登录空态；强杀后重启；断网及恢复。不得绕过证书。
2. **账户**：A登录、刷新、退出、B登录、再次切A；确认页面资料、头像、三盘、会话和旧凭据隔离。退出后旧访问/刷新凭据拒绝。
3. **资料/本命三盘**：编辑昵称/城市等、保存并重读；已知出生时刻与未知时刻两种输入，保存、历史读回、版本冲突与失败恢复；清楚显示`COMPUTED_UNVERIFIED`，不得称算法独立验证PASS。
4. **慢约**：读取准备状态、参与资格、候选/历史。测试账号已在MariaDB具备TEST_ONLY资格时验证本轮可见结果；无资格时应清楚展示403/待实名等降级，不显示虚假候选。不得通过UI或HTTP自报verified/test_only。
5. **Connection/消息**：双方建立Connection；验证Connection不自动允许消息；双方单独同意后发送和读取同一文本消息；撤销或Block后重进消息页、旧深链/通知不可读，旧缓存清除或转成最小历史投影。
6. **社区与媒体**：发布合成好友作品/评论，检查SELF/FRIENDS受众；用合成PNG上传封面/头像，原好友可读字节，新好友不能读取旧受众封面，Block后旧封面/头像/作品链接404。记录图片选择器在真实设备的可用性；不访问私人照片。
7. **Buddy**：草稿、发布/发现、申请、确认、退出；重登和刷新后核对状态。
8. **通知**：当前通知、待办与历史；点击时服务端重验，Block/失权后旧路由隐藏内容，只保留最小历史。
9. **关系**：如页面提供，测试正式关系请求、双方确认和失权；凭据撤销/资格缺失时应明确拒绝，不把TEST_ONLY标为真实KYC。双方重新确认行为与MariaDB API一致。
10. **设备级失权**：Block、账号退出/停用后返回首页、冷启动、重新登录；验证私有页面、图片、消息和旧深链没有残留可见信息。

每步至少记录：页面入口/实际UI、请求API和HTTP状态、MariaDB对象/版本/状态、失权后旧入口结果、截图/日志证据ID。只对当前实际操作执行；未触发项标`NOT_RUN`，不得以API测试代替UI测试。

## 5. 收尾与手册同步

- 只移除本轮新建的`tcp:18444` reverse映射：`adb -s <serial> reverse --remove tcp:18444`；禁止`reverse --remove-all`。
- 保留APK、测试账号、DB卷及日志。容器是否停止由当前服务状态与下一阶段需要决定；不得down -v。
- 只把脱敏设备型号/Android版本、测试旅程、截图编号和日志SHA同步GitHub；serial、账号、密码、secret、个人信息仅保存在本机受控目录。
- 用同一APK SHA、源码commit和服务端commit采集A01–A12实际截图；Web W01–W04若已具名验证则独立采集。截图不能用不同版本拼接。
- 根据实际页面修订`ELITESYNC_V2_OPERATION_MANUAL_DRAFT_20261121.md`，不把尚未运行的功能写成已实测。
- 生成一份P0.3中文实机集中报告，状态区分`HOST_PREFLIGHT_PASS`、`DEVICE_INSTALL_PASS`、逐项`DEVICE_E2E_PASS/PARTIAL/FAIL/NOT_RUN`。封闭内测仍需Owner后续另行批准。

## 6. 绝对禁止

不访问阿里云，不恢复真实管理员，不使用真实KYC/Push/RTC，不运行全量PC清理，不读取私人相册/通讯录/短信，不清空/卸载/覆盖现有APP数据，不移除全部ADB reverse，不更换APK/签名/服务端地址，不合main、不申请软著、不公开招募或启动封闭内测。
