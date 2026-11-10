# APP-T12-G12｜当前本地 Flutter 工具与定向证据状态（候选）

状态：Codex docs-only 候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。唯一仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 保留。仅新增本文件，未修改 APP-T12 历史结论、源码、测试或 authority；未运行新测试、分析、构建、adb、设备、网络或真实数据。

## 两轮准确来源（2/2）

1. **第一轮：只读已接受回执及历史层级。** `docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md:110,123-139` 的 G-12 是该次工作树上的历史判断：`.dart_tool/package_config.json` 当时 `ABSENT`，Flutter tests/analyze 未运行，工具执行证据未建立；该结果固定的是当时证据层级，不可追改。随后只在 `EVIDENCE/APP-G11-01～18/`、`APP-HM-01～10/` 的 Work `work-review.md` 与作者 `summary.md` 提取 Flutter 定向命令、退出码、目标和限制，并核对 `APP-M5-01～05/work-review.md`。G11-01、HM-01、HM-04 的 REJECT 和旧预算仍原样保留；G11-11 的 backend 测试失败不是 Flutter 工具状态证据。
2. **第二轮：当前精确状态。** 对模块固定 `.dart_tool/package_config.json` 作存在性与 SHA-256 检查；PowerShell `Get-Command` 只解析 `flutter`、`dart`；对下表准确目标文件取当前 SHA-256，并以已接受 Work 回执中的固定哈希比较。定点确认仓内 `apps/android/app/build.gradle.kts`、模块 `.android` 存在，模块普通 `android` 目录不存在；设备状态仅沿用 M5 已接受的 `UNKNOWN`，没有运行 adb。

| 当前准确文件（仓库相对） | 当前 SHA-256 | 与所列已接受回执 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/.dart_tool/package_config.json` | `A0397A29C470252B6DBA62E8E8D3D341209A93944DEBF6B666FCF70917882CA1` | 存在；与 APP-M5-01 作者固定哈希一致，非依赖执行证明 |
| `apps/flutter_elitesync_module/lib/main.dart` | `F0F4A6C112774AE0EE78D47B4FFAFD6CF20250B1CA5B6EE112AC4A4EB2BF2B54` | APP-M5-04 Work 一致 |
| `apps/flutter_elitesync_module/lib/app/router/app_router.dart` | `37F80AE948753FB389EABB36F7F257C64B6662E1A299A1F14B5E1B70B387FF12` | APP-G11-18 Work 一致 |
| `apps/flutter_elitesync_module/test/app/router/chat_route_state_router_test.dart` | `5459B50D9DA5FBB86CA31C47BD84EF0BA0A6C655AFBE35352BF1D03CF4DE2A29` | APP-G11-18 Work 一致 |
| `apps/flutter_elitesync_module/test/app/router/stored_chat_direct_route_binding_test.dart` | `4A1C1CEFDB1BDAECFF31EBCBE9028BCC86107BAC788A4D5D213F8571D20A3474` | APP-G11-18 Work 一致 |
| `apps/flutter_elitesync_module/test/features/chat/presentation/pages/conversation_list_page_test.dart` | `2E90DAA7A8A667A0FE9CB37F56A1E087749ABC554E3021B70F0387850F573B37` | APP-G11-16 Work 一致 |
| `apps/flutter_elitesync_module/test/features/home/presentation/pages/home_page_test.dart` | `C2E63C6E5CFD0430FBCCE3BA4307A2845DB66E393FA532DF18D905652D398A4C` | APP-HM-09 Work 一致 |
| `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart` | `1CAAA927E3A7C369D2E37038AFB3398B7E0D0E11DD2D90F63EA99AAFD1F9034A` | APP-HM-06 Work 一致 |
| `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart` | `7D2ADCACF09866B6130EAB543DBC82611D2B752841BB1CB0BC0EA12D55D4042B` | APP-HM-06 Work 一致 |
| `apps/android/app/build.gradle.kts` | `4D3A83B8940BBE5F14223350FC444C3F2A854E52A2416E525CD2D25ECD686ED3` | APP-M5-03 来源一致；非构建证明 |

当前 `Get-Command` 将 `flutter` 解析为 `D:\flutter\bin\flutter.bat`、`dart` 解析为 `D:\flutter\bin\dart.bat`。命令可解析、package config 存在和文件哈希相等都不能替代当前版本/依赖、全套测试或运行验证。

## G-12 事实矩阵

| 层级 | 当前分类与精确证据 | 不能推出 |
| --- | --- | --- |
| APP-T12 重审当时 | `TOOLING / EVIDENCE GAP` 是历史 ACCEPT 的证据记录；该次 package graph 缺失，Flutter tests/analyze `NOT ESTABLISHED`。 | 不应将当时的 `ABSENT/NOT RUN` 改成当时的 PASS。 |
| 当前工具入口 | package config 现存在，Flutter/Dart 现可在 PATH 解析；APP-M5-04 曾用这些入口完成定向 analyze。故“本地工具不可用”已不适合作为**当前整体判断**。 | 不证明工具版本、依赖全集、模块范围静态检查或 Android 工具链。 |
| 当前 Chat/Match 定向 tests | 已接受且受限的作者回执：APP-G11-02 `flutter test --no-pub test/app/router/match_legacy_redirect_regression_test.dart` 退出 0、13/13；G11-03 通知目标文件 20/20；G11-05 直达路由修正后 8/8；G11-06 路由 Unit 12/12；G11-07 列表 widget 修正后 20/20；G11-08 DTO+路由双文件 28/28；G11-09 列表 23/23；G11-15 路由 21/21；G11-16 列表 26/26；G11-18 `flutter test --no-pub test/app/router/chat_route_state_router_test.dart test/app/router/stored_chat_direct_route_binding_test.dart` 退出 0、32/32。各数是不同时间、不同目标和预算的回执。 | 不把分散 PASS 相加为当前整个 Chat/Match 套件、真实 Conversation 权限或生产兼容 PASS。G11-01 失败及 REJECT 不被后继成功回写。 |
| 当前 synthetic Home 定向 tests | 已接受回执：APP-HM-02 `flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` 退出 0、4/4；HM-03 6/6；HM-05 8/8；HM-06 11/11；HM-07 Home 页面修正后 7/7；HM-08 9/9；HM-09 `flutter test --no-pub test/features/home/presentation/pages/home_page_test.dart` 退出 0、11/11。HM-01 的格式失败/REJECT、HM-04 的语义失败/REJECT 保留在历史，后继各用新预算修正。 | 只证人工 provider/widget 状态，不证明 G-08 真实 Home/Match 来源、设备、账号或 backend 权限。 |
| 当前 analyze | APP-M5-04 `flutter analyze --no-pub lib/main.dart` 退出 0、`No issues found`；当前 `main.dart` 哈希与 Work 固定值一致。 | 只覆盖单文件，不等于 `lib/`、`test/` 或模块范围 analyze。 |
| M5 平台链 | APP-M5-02 已定位受 Git 跟踪的 `apps/android` host；APP-M5-04 仅接受显式默认关闭 Dart 分派；APP-M5-05 审查仍判 host 标记、AAR 身份和端点守卫 `NOT_FIXED`。设备 `UNKNOWN`。 | Android 构建、安装、启动、稳定行为、真实账号与生产权限均 `NOT_CHECKED/NOT_ESTABLISHED`；M5 运行仍 `NOT_READY`。 |

当前部分 G11/HM 回执还保留最终格式工具未复核等明确限制；本表只复述其被 Work 限定接受的测试事实，不扩写格式或运行结论。旧一次性预算不重置。本任务没有产生新的 Flutter test/analyze 回执。

## 唯一建议后继与停点

建议 Work 另立一张**当前模块范围的只读静态分析**任务：固定当前 Flutter module、`--no-pub`、精确一次 `flutter analyze --no-pub` 调用、时间/输出上限和失败即停回执，仅用人工/本地源，不修改源码/配置、不获取依赖或访问网络。它会把现有单文件 analyze 覆盖扩到模块范围，是真正新增的 G-12 工具证据；失败须原样记录，不能动用 APP-M5-04 或其它旧预算。完整测试套件、Android build/install 与真实账号仍需分别授权；此建议不是派发或执行。

两轮只读预算 **2/2 已耗尽**。APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填门不变；停 Work 独立 LEVEL 2 审查。无提交、pull、push。
