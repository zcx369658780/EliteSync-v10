# EliteSync v10.1.5｜Aggregate循环引用定点诊断→Writer完整suite→条件式SDK/Producer/30配置｜Codex唯一综合长任务

日期：2026-10-24（Asia/Singapore）

**ASTRA_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / LOCAL_EXECUTION_NOT_STARTED / AGGREGATE_CYCLE_SOURCE_PATH_NOT_YET_PROVEN / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_AUTHORIZED_UNTIL_WRITER_PASS / CONDITIONAL_SANDBOX_0_OF_1 / CONDITIONAL_PRODUCER_0_OF_1 / CONDITIONAL_RESOLVE_0_OF_1 / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN**

## 0. 目标与门禁

Astra已复审候选 d0c1a00218ca68b92c6acf3338e292f956b023cf。类型捕获在保存回放JSON中发现 $.seconds 为 System.Decimal；这是本轮输入的实测，不是历史迟到异常的根因证明。唯一完整Writer suite 1/1 exit1，约1.187秒，在 fixture.ps1:96 序列化aggregate $body 时报告 System.Management.Automation.PSParameterizedProperty 循环引用。具体字段路径/父对象链UNKNOWN；fixture-body.json未写出，aggregate expectedCount=37 / actualCount=0 / checks=[] 只表示控制器没有可读的逐例body，不代表实际0例执行。37案例目录与38份JSON（20份failure JSON）也不证明37/37 PASS。

本任务只有Owner手动派发后才执行。先定位aggregate对象图循环引用，不重做Decimal、Git trust、GPU缓存、DAG、HOST或历史SDK 600秒问题。仅在LOCAL_ONLY新副本诊断并修复aggregate序列化。定点aggregate测试通过后才允许一次完整37案例suite；完整suite全PASS并经非作者复核后，才允许最多一次新禁网SDK Sandbox；SDK READY后最多一次真实Flutter Debug Producer；当次libs.jar通过核验后最多一次正式30配置解析。任何门失败即STOP，不重跑已消费的同级预算。

## 1. 固定authority

- 仓库 zcx369658780/EliteSync-v10。开工fresh核live main、Root、完整apps/services Tree。任务发布前main 3614bb386b6f1e2237e8d884c7d469ce29f0e0c1，Root 02f250a7fb4587314ee71bd1daa773826ed68af9；main唯一接受产品为v10.1.4，apps Tree 3468a3dd97da7accfda2539a0f8d8f68931a6110、services Tree 0cb1f9d19659291a462488b3686fd0a07a6698ac。
- 唯一连续研发起点 d0c1a00218ca68b92c6acf3338e292f956b023cf，Root 7fa7fc58b6b6ef3e6939f6111f6f23607b195f59，sole Parent f3fbc2c58615095a9065afd11cc2369f7241343f；待验apps Tree 785822ca072943c5bfefa3ccc37ede01c2af5164、services Tree 1e1e20bb3500bedb1a521e5f2ddeece915d09424不变。
- 最新Astra独立复审 sandbox_receipt_aggregate_circular_reference_independent_review_20261024.md Blob 0bea4cea935de96c8471997142df3ce31eb0d999；上一报告Blob eeaa8f1a1b00241f9107742a3f6f2e089cbb3753，Manifest Blob f44b9d344ce99710aa8b87063329dc6800b19a7f；正确前置任务Blob a0918a566bd88e47a630010757f27d9fdc970996、正确前置复审Blob 5a7d78eb4daf94ad553c51bfe9aee424f343bb8d。错误复审引用75f63bb7...不得采用。
- 前轮失败候选pins：receipt_writer.ps1 8930af018f129f00ac27cc141df5e7f662a77c2d88f5a61dd7ed9a330e74ba1a；receipt-schema.json 1d0f85833a30bac04e1647b4ba66e560794932872bed7d6bf9e091bb3edba652；fixture.ps1 146d2e159dcac6bc773fffe4571d6ec5ec5729ad365e3e4118a2f4e4cea86c61；fixture-plan.json bc9f413fa6f612687762b6419217623e4b83818225080feebf6608b576f26b5e；run_fixture_once.py 1cdcef296e1dd56c6d8eee8eb20400fd3b4bcd9487b8503728a2fec02a976dd6；writer-correction.json c60fe26a6048c9825ec3e35e781ddd8a20f32c54b2de86c558df0a478f8e51df。均为LOCAL_ONLY失败候选；仅在本任务独立副本修改，保留原件。
- 固定工具：Flutter3.41.7/Dart3.11.5/engine 59aa584fdf100e6c78c785d8a5b565d1de4b48ab，Gradle8.14可信bin SHA256 af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab，JDK17.0.18.8/AGP8.11.1/KGP2.2.20。原50键环境Hash 78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52；添加3个精确Git子进程键后的53键Hash 6468110fb2cd275115774ae4813aa769415d2f3d14bcb297ab9d0867457a9723，不得混称。ANDROID_PREFS_ROOT任何大小写键必须缺失，ANDROID_USER_HOME批准归属不改。
- 已验证DAG :flutter:compileFlutterBuildDebug → :flutter:packJniLibsflutterBuildDebug，目标模块debug libs.jar。旧DAG targetPath=lib/main.dart、dartDefines=null，ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN保持。严格resolver init SHA256 2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f，artifact policy SHA256 bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58固定。
- 历史600秒截止和约269秒后迟到PSInvalidCastException独立保留；当前Decimal捕获和aggregate循环引用不证明历史根因。OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS保留。

## 2. D0-A｜定点对象图诊断与最小投影（LOCAL_ONLY，不启动Sandbox）

1. 只读核 fixture.ps1:96 的实际aggregate body构造、Serialize($body)输入来源及PSParameterizedProperty如何进入对象图。先查真实保存对象；fixture-body.json缺失，若无真实对象，标 ORIGINAL_AGGREGATE_OBJECT_NOT_PERSISTED，只能从同源构造逻辑生成最小合成复现，不能声称复现原对象。
2. 用不调用JSON serializer、Write-Receipt或Copy-ReceiptValue的只读对象图遍历器，记录字段路径、GetType().FullName、父子链、引用身份和循环闭环。对PSParameterizedProperty、ScriptProperty、ErrorRecord、Job等只读类型；不得执行getter、调用ToString、递归读取未知property或写敏感值。使用对象引用身份visited-set，并限制深度/节点数。
3. 只允许一次aggregate定点fixture，整体硬时限15秒。若无法定位循环字段路径/闭环，终态 AGGREGATE_CYCLE_PATH_NOT_PROVEN / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN，立即STOP。
4. 只有循环链路确切定位后，才可将aggregate body投影为显式白名单primitive-only schema：string、finite number、boolean、null、受限数组/字典。禁止将PSParameterizedProperty、ScriptProperty、ErrorRecord、Job或任意PowerShell运行时对象直接交JSON serializer。未知类型走独立失败路径；不能用ToString把复杂对象硬转string、不能删字段伪造成功。投影必须拒绝循环并报告路径，限制深度和大小。
5. 在新任务副本做最小修正，记录diff和before/after SHA256，保留原stderr、失败aggregate与38 JSON不变。不得修改系统、全局Git、shared SDK或产品源码。

## 3. D0-B｜定点aggregate正负例一次（15秒）

只有D0-A定位和修正通过静态复核后，允许一次aggregate专用fixture，总硬时限15秒：
- 正例：构造37个预期case结果的primitive-only aggregate；UTF-8写临时文件，重新读回、校验schema、Hash、run ID、expected/actual count及逐项状态，再同目录原子Move发布。
- 负例：注入不允许的PowerShell运行时对象/循环引用，必须明确拒绝、不得标READY/PASS，并用不依赖同一writer的primitive fallback写有效failure receipt；校验UTF-8/schema/Hash和原子发布，不泄露对象值。
- 时限包含启动、正负例、读回、收口和落盘；不得用Wait-Job局部timeout冒充全套hard deadline，不得启动Sandbox或Git/Flutter/Gradle。
- 任一例失败、回执缺失、循环未拒绝、schema/hash错误、进程退出未确认或超时，立即STOP，不运行完整suite，也不启动Sandbox。

## 4. D0-C｜完整37案例suite一次（60秒）

只有D0-A/B全PASS且一次非作者前置复核支持，才允许一次完整suite。总硬时限60秒，涵盖启动、37项、aggregate、所有回执读回和进程收口。每例必须有BEGIN与真实终态；aggregate须有37项可读结果、expected=actual=37、每例状态/耗时/receipt Hash/退出状态。不能把controller actualCount=0冒充案例数量。正负例、独立failure fallback、UTF-8/schema/hash、原子发布、run绑定、硬时限和进程收口全部PASS才可标WRITER_FIXTURE_PASS。任何案例FAIL/NOT_RUN、body/aggregate缺失、循环、退出不明或超时均立即STOP，Sandbox预算仍0。禁止重跑前轮suite或覆盖旧产物。

## 5. D1｜条件式新Sandbox SDK（最多一次）

仅D0-A/B/C全PASS、非作者复核通过后才可最多一次启动新独立Windows Sandbox SDK实例。启动前记录本轮进程快照与资源冲突；旧guest仍UNKNOWN，不循环调用失败HCS接口、不结束未知进程。新实例自身重新验证Networking Disable、父子IPv4/v6拒绝、无外联网卡/默认路由、映射只读源与guest私有写入边界；精确Git信任只适用于Flutter framework root，冻结HEAD必须为 cc0734ac716fbb8b90f3f9db8020958b1553afa7。使用新writer分阶段原子回执核Flutter/Dart/JDK/Gradle/SDK/cache真实可用；Flutter CLI必须真实启动，所有检查通过才可签SDK_RUNTIME_READY_FOR_STANDARD_DEBUG。600秒预算不自动延长；截止未收到有效READY立即STOP，迟到回执另记，不倒填截止PASS。不得下载、升级工具、改共享SDK或系统网络。

## 6. D2｜真实Producer最多一次

只有SDK READY且本实例安全门全PASS，才可最多一次运行 :flutter:packJniLibsflutterBuildDebug 与compile依赖，Gradle8.14离线、双ABI、同一guest同一工程root。首阻断立即STOP。必须核当次真实目标 .android/Flutter/build/intermediates/flutter/debug/libs.jar 的生成任务、before/after、Hash、合法ZIP/CRC/entry、真实JNI/native来源与x86_64、arm64-v8a ABI。空Jar、历史复制、来源不明不能PASS。

## 7. D3｜正式30配置解析最多一次

仅本次libs.jar全PASS后，才可最多一次运行 resolvePinnedDebugInputs，实际调用15模块×debugCompile/debugRuntime共30项Configuration.resolve()。保留严格init、artifact policy、固定工具与离线环境；逐项记录BEGIN/OK/首FAIL/NOT_RUN，首个新阻断即停止，不重试、不下载、不自动修复。30/30通过也不等于宿主APK、ICE诊断或RTC安全通过。

## 8. D4｜保护、交付与终态

- 一次非作者有界复核覆盖循环路径、primitive投影、aggregate正负例、完整suite硬时限及后续条件门。不要重做历史SDK600秒、Git trust、GPU、DAG、HOST或旧fixture审计。
- 保留21,820份具名保护原件、512条引用、五历史根、dirty/SQL/APK/备份/私密日志/SDK与全部旧失败；按开工实际核对，范围仅限具名对象，不宣称全盘或活DB审计。禁止系统网络/全局Git/ACL/owner修改、下载或未知进程清理。
- 从连续候选 d0c1a00218ca68b92c6acf3338e292f956b023cf 作为唯一Parent创建安全后继，Git只新增：
  1. docs/versions/v10.1.5/AGGREGATE_PRIMITIVE_PROJECTION_AND_CONDITIONAL_SDK_PRODUCER_REPORT.md
  2. docs/versions/v10.1.5/aggregate_primitive_projection_and_conditional_sdk_producer_manifest.json
- 不修改apps/services、旧报告、ACTIVE_STATE、AGENTS或main产品。普通non-force发布，回读Commit/sole Parent/Root、两份Blob、原UTF-8字节与完整产品双Tree。私密脚本、日志、路径、PID、环境、SDK/JAR/APK仅LOCAL_ONLY。
- 终态按事实选：AGGREGATE_CYCLE_PATH_NOT_PROVEN / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN；AGGREGATE_TARGETED_FIXTURE_FAILED / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN；WRITER_FIXTURE_FAILED / SANDBOX_NOT_RUN；SDK_RUNTIME_PRECONDITION_BLOCKED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN；SDK_READY / PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN；REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_RESOLUTION_FIRST_BLOCKER；REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_30_CONFIGS_PASS。

所有终态继续保留 OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW。发布后立即停止，等待Astra验收，不自动启动后继任务。
