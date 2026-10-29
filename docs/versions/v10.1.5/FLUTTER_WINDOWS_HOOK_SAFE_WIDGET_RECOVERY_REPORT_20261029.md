# v10.1.5 Windows私有Hook启动恢复及Widget/unit定向验证（2026-10-29）

**结果：`TEST_PASSED_UNDER_TASK_PRIVATE_PATCHED_RUNNER`。最终11文件77个实际用例全部通过，0失败、0跳过；修改测试文件analyze exit0。** 私有运行器补丁不能被称为原版未修改Flutter PASS，亦非整版产品接受。唯一候选完成后STOP等Astra。

## 固定权威和来源

开工fresh main `519672942e3697d8b3c7918d95619600feed658a` / Root `3b06491b8c1d95ba1be9dd5e2151a16d51fb816f`；ACTIVE_STATE `b9d0c40b34e1895789e445d91fa7ea2bad6ace9f` 已链接正式合同Blob `02018a930428bb6417c9fcdd811a6c1350b03988`。协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`，Astra上一轮完整裁决 `dc5a6d21e9c22f8e28b81cec7317aa740c9bd8db`，原报告 `5ec34d508f0e28c887b7527edc166aaf085d530b` 与索引 `cc534ec2d621e7e6e40ca957b65dab6b1d255fec` 均fresh读取。先前TASK_NOT_PUBLISHED阶段未运行，本次没有采用DRAFT合同。

sole Parent **`15b23d8cacfa1429f6f77b8d57a86fff6b827673`** / Root `025af603a46550721d863d354246e76d9bd072b0`；固定5322叶文件由上轮已GitHub原字节核验的本地来源逐Blob重建，无新下载。来源产品apps `29c3274654a03db7dbe2a53eb02a07686281266b`、services `9bba2938aa41ad3eaee501ef88bfeecdee797591`。main已接受产品仍v10.1.4，apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。

Git authority/对象属**DIRECT_GITHUB_OBJECT**；本机运行属**CODEX_REPORTED_LOCAL_TEST**；原始路径、stdout/stderr、进程参数、完整ledger、工具副本和patch为**LOCAL_ONLY_RAW**。Astra未亲自观察本机，本报告不将执行回执升级为独立OS验收。

## 私有运行面和适配

同一新task根、attempt-0001：从上轮固定只读私有来源复制一套完整SDK（18,000文件、3,277,485,220 bytes）及必要Pub副本（23,816文件、379,467,885 bytes），来源/目标逐文件byte Hash、FileId/Volume、无hardlink/reparse核验。app resolver170、tools102条均绑定新根；pubspec.lock原Blob未改。HOME/TEMP/APPDATA/PUB_CACHE/FLUTTER_ROOT、实际程序、cwd、缓存与生成输出指向本轮私有面；无SDK、Pub、MariaDB下载。原目录未补丁写入。

Flutter **3.41.7 / framework `cc0734ac716fbb8b90f3f9db8020958b1553afa7`**，Dart **3.11.5** 真正运行读回。旧`flutter_tools.snapshot`已经编入旧的hooks_runner调用；本轮从私有`packages/flutter_tools/bin/flutter_tools.dart`源码入口运行，使私有Pub补丁真正进入执行链，未修改共享SDK或旧snapshot求PASS。

原`hooks_runner1.0.1`两个调用是`compile kernel --packages --output --depfile script`和`--packages kernel --config [resources]`。供应方代码将Windows的这些调用设为runInShell；当前版本没有可切换的配置。固定Dart官方`lib/io/process.dart`明确支持绝对exe＋`runInShell:false`，并警告bat/cmd即便false也可启动系统shell。本轮仅在私有Pub的`run_process.dart`最小调用层适配：

- 固定程序只允许canonical私有dart.exe。真实caller的完整绝对`bin/dart`别名只映射到同一个已校验dart.exe，不做PATH/PATHEXT搜索。
- 使用验证后的canonical exe/cwd/参数实际启动；仅接受两个具名编译/Hook参数形态及无害资格探针，检查脚本、packages/config/resources、输出/depfile和JSON中绝对路径。
- Windows环境键统一大写、拒绝同一map重复键，核对所有私有写目录和PATH；false继承模式仍补入私有TEMP等必要项。保留原stdout/stderr的systemEncoding解码、exit返回和ProcessException传播。
- `Process.start(...runInShell:false)`；前后flush本地审计。外层Windows Job在主程序恢复前绑定，10ms辅助观察真实映像，禁止任何cmd/PowerShell/JVM/DB/API子进程；只有已核Windows conhost作为OS控制台宿主例外，不能把它称为shell或任务内exe。

原source SHA256 **`f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d4d08c393dad9`**；最终 **`7d04fa44ccd94549ea2011997d3b1053ae6e72716e9b9fc0cc4d7c7e202244bc`**；完整本地diff SHA256 **`9d7f7883e34bbe451d364b89b03d4acab6c30d00d1f4d9081f562708b6e7f119`**。首次私有适配及精确Windows别名修订Hash链均保留。实际objective_c9.5.0 Hook的编译、kernel运行均有私有dart.exe/参数/cwd/输出审计和exit0；未禁用必要Hook。后续批次可正常复用其合格私有缓存。

资格探针最终19检查PASS：5次实际direct子启动，含Unicode/空格/shell元字符参数、stdout/stderr、非零exit与异常、真实compile kernel/depfile、kernel/config运行；10项越界执行/相对程序/cwd/TEMP/PATH/大小写键/脚本/packages/output反例在Popen前拒绝。探针属于合同要求的独立Runner行为资格，不是Flutter test/analyze批次；全部Dart/准备调用仍写入同一ledger，未将业务测试冒充免费探针。

限制：此适配面向已由外层逐条核验的固定配置和可信测试代码，JSON相对URI依赖外层闭合；**不是**对任意恶意Dart/配置的通用OS sandbox。10ms观察不能证明捕获每个瞬时进程，预调用白名单、具名输入、来源校验及实际Hook审计提供补充；历史三次系统shell中止批次的完整写闭包NOT_PROVEN不被倒改。

## 逐文件最终真实测试

| 文件（相对test） | found | executed | passed | failed | skipped |
|---|---:|---:|---:|---:|---:|
| `core/storage/private_cache_service_test.dart` | 5 | 5 | 5 | 0 | 0 |
| `features/auth/data/datasource/auth_local_data_source_test.dart` | 5 | 5 | 5 | 0 | 0 |
| `features/auth/data/datasource/auth_private_storage_test.dart` | 2 | 2 | 2 | 0 | 0 |
| `core/network/v1015_late_response_test.dart` | 3 | 3 | 3 | 0 | 0 |
| `features/chat/data/datasource/v1015_socket_contract_test.dart` | 2 | 2 | 2 | 0 | 0 |
| `features/chat/presentation/pages/v1015_live_chat_reliability_test.dart` | 8 | 8 | 8 | 0 | 0 |
| `features/chat/presentation/pages/conversation_private_cache_test.dart` | 2 | 2 | 2 | 0 | 0 |
| `features/chat/presentation/pages/live_conversation_private_cache_test.dart` | 5 | 5 | 5 | 0 | 0 |
| `features/notification/presentation/pages/notification_center_page_test.dart` | 20 | 20 | 20 | 0 | 0 |
| `features/notification/presentation/pages/platform_notification_navigation_test.dart` | 14 | 14 | 14 | 0 | 0 |
| `session_rejection_test.dart` | 11 | 11 | 11 | 0 | 0 |

最终批次operation **`2e75fac543dd4da397c18773873a0ef4`**，真实exit0、JSON done.success=true。stdout SHA256 **`e847bb301a53674b65a4e386bfa7561822d4fee05dbf8c5383b3b02aa9fe0d49`**；stderr SHA256 **`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`**。77是最终唯一用例数；hidden加载/基础设施事件单列，不混入业务通过数。索引保留逐个testName、文件、真实结果以及各批次错误原件Hash。

F1：同键重试/未知结果、晚响应、旧WebSocket/切号授权失效；F2：按账号设备的密文、可信T0、合成15/30日、异常时钟/损坏/退出凭据队列；F3：旧通知当前权限、最小披露、异步换号/撤权及导航。本轮是Flutter引擎上的真实unit/widget＋Mock业务边界，**不是**真实服务端/APP/API/DB/设备E2E；物理15/30日、Keystore、物理清理、真实Push/RTC/Android仍NOT_RUN/NOT_PROVEN。上轮MariaDB已接受的23 Feature/152断言仅引用，不重新运行或累计为本轮新证据。

## 批次预算、失败及唯一测试修复

| 批次 | 类型 | executed | passed | failed | exit |
|---|---|---:|---:|---:|---:|
| 1 | Widget/unit | 0 | 0 | 0 | 1 |
| 2 | Widget/unit | 77 | 57 | 20 | 1 |
| 3 | Widget/unit | 20 | 14 | 6 | 1 |
| 4 | Widget/unit | 77 | 77 | 0 | 0 |
| 5 | analyze | — | — | — | 0 |
| 6 | Widget/unit | 77 | 77 | 0 | 0 |

实际Flutter test/analyze **6/6用尽**，失败不退款。第1批因真实caller扩展名精确别名不匹配，在用例发现前失败：0执行，不能称11文件失败。第2批首次77执行，57通过/20失败；第3批通知文件20执行，14通过/6失败；第4批全77通过；第5批单一修改文件analyze exit0；第6批最终源码全77通过（补两处已有throw分支花括号后，绑定最终源码再回归）。此后不再启动Flutter。

唯一Git产品树改动：`apps/flutter_elitesync_module/test/features/notification/presentation/pages/notification_center_page_test.dart`。Parent Blob `293d84df69b1e699991a67eeb2dc18d4b76c8787` → 候选Blob **`6ec6e0fd50982c4123141bffc888ff3141c8b953`**。实际失败是测试装配：`_wrap`同时默认和显式覆盖同一sessionProvider；通知列表mock替换掉了真实Provider对session的watch，事件点击时会话尚未初始化。测试专用`_SessionHarness`watch并等待已有显式合成认证fixture，包裹_wrap和3个router入口；去掉重复默认override，没有改变生产业务鉴权。保留所有失败注入、重试、错误清理、旧身份与权限否定断言。Sol/high独立只读助手对照确认**97个expect表达式逐一相同、16个testWidgets声明（含参数化）保留**，无skip/负例删除；其结论不是Astra验收。

原Runner探针的Unicode decoder断言、raw/canonical路径断言、UTF8 reader准备失败，以及上述3个失败业务/加载批次均原样保留。Unicode参数用子进程ASCII codeUnits回执核对，保留vendor systemEncoding，不改解码求假PASS。一条准备ledger记录曾双重JSON编码，原行未改，reader显式解码且预算未重置。完整错误、审计及私有补丁只保留本地。

## 保护、空间、交付与STOP

task_id **`V1015_WINDOWS_HOOKS_WIDGET_RECOVERY_20261029`**，唯一新根和完整ledger为LOCAL_ONLY。SDK镜像1/1、Pub1/1、固定source1/1；下载0，DB启动/连接/API0，G2/Gradle/JVM/Android/APK/ADB/RTC/真机/真实Push0。上轮MariaDB2/2、API1/2及所有旧预算原字节留存，不能重新用剩余额度。

本轮上限logical/allocated各8,589,934,592 bytes，预留和可溯检查点记录于索引，发布前最大logical **3912048419**、allocated **3998870168**；未连续测量每瞬峰值。最终回执在同根budget-terminal/completion-receipt记录后续元数据增长，不冒称全程连续峰值已证。

复制时逐文件原字节已核；结束时旧私有SDK18,000/Pub23,816文件的FileId/Volume/size/mtime稳定，4个关键原件Hash稳定，原ledger/receipt/readback Hash稳定。本轮没有再次全量重Hash所有旧source字节，亦没有对旧18/122原证/五保护根/527refs/Seed3183再做完整OS身份或ACL矩阵。它们、两实验树、dirty根、claims及历史失败均no-touch，永久保留历史`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`。

本候选只上传**一份测试修复＋本报告＋脱敏索引**。SDK/Pub/运行器完整补丁/缓存/日志/私人路径/凭据不上传。候选apps Tree **`798049a15eb33fec16acdd37d83a07af0ed181b5`**（729 blobs），services仍 **`9bba2938aa41ad3eaee501ef88bfeecdee797591`**（716 blobs）。发布后GitHub回读Commit、sole Parent、Root、3个变更原字节/Blob/mode、完整双Tree与fresh main，保存final-readback和完成回执；精确最终Commit/Root在交付消息提供，不由发布前文档自签接受。

保持`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / V10.1.6_NOT_STARTED / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / RTC_AEC_NOT_CLOSED`。**完成一次集中候选后STOP，等待Astra独立验收；不合main、不改AC05、不放行G2、不发布后继或进入v10.1.6。**
