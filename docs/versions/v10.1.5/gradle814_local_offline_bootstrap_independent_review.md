# EliteSync v10.1.5｜Gradle 8.14本地离线引导专项 Astra 独立复审

日期：2026-10-23（Asia/Singapore）。评审者：Astra，EliteSync GPT顾问。

**INDEPENDENT_REVIEW_COMPLETE / GRADLE814_STANDALONE_BOOTSTRAP_SUPPORTED / RESOLUTION_VERIFICATION_TOOLING_BLOCKED / NO_GRADLE_PROJECT_DEPENDENCY_RESOLUTION / NO_DIAGNOSTIC_APK / SOURCE_UNCHANGED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / OWNER_DECISION_REQUIRED / NO_AUTO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

## 1. 独立核验范围与GitHub固定身份

本审查直接读取GitHub上的候选Git Commit、根树及父根树、两份交付文档、上位正式任务与已冻结Android Gradle源文件。Astra没有接入Owner Windows电脑，也未执行Gradle或独立对22425解压文件、Flutter embedding JAR、1483历史资产或私有Gradle缓存做现场哈希，因此这些本地结果为`CODEX_REPORTED/LOCAL_ONLY`，不是Astra实测。

- 正式任务：`docs/versions/v10.1.5/OWNER_APPROVED_GRADLE814_OFFLINE_BOOTSTRAP_AND_DIAG_APK_TASK_20261022.md`，Git Blob `677a1f7c1709fa3d7778e4edab28bf84b293c7f1`。上一轮Astra复审Blob `6f7f200da8595d52f9da21ee39cd56d7b1164c27`。
- 复审前live`main`：`ea551353ec73df01e20f88f1ca01c633590a1344`；保持v10.1.4已接受产品和顾问任务文档，不含待验v10.1.5代码。
- 本候选固定Commit **`76a7542d9c9121051b55251fda198e568a8d0aa5`**，Root Tree **`8f313834c39075d0f56d89639fac787c8e3aa034`**，唯一Parent `73b3b753225f99824081d312a25a7deb170c62d3`，父Root `6c45db667bb7a11234a72600c41f04b9432328b6`。GitHub Compare相对父 ahead1／behind0，只新增：`docs/versions/v10.1.5/GRADLE814_LOCAL_OFFLINE_BOOTSTRAP_REPORT.md` Blob **`cdbd97a2e66bfa03d5db8f001c7f862396266795`**及`gradle814_local_offline_bootstrap_manifest.json` Blob **`16fce32045039f336ee5d224f1d4714604b41d29`**。文件原文已读取，数字、阶段、停机边界一致。
- 直接读取两份提交Root：完整apps均是`72c617cf86d5c653dd722accde340b51d2e085eb`；services均是`1e1e20bb3500bedb1a521e5f2ddeece915d09424`；只docs子Tree不同。故本候选`SOURCE_UNCHANGED`已由Git证明。受控诊断源码仍是`24ddf05875d8d4abad7a6b473f882698c9885c2a`，没有合入main。
- 所有测试20诊断＋93普通、五项debug隔离负例都是上一候选固定回执`REUSED_VALIDATION`，这次没有重跑，更未取得真机RTC通过证据。

## 2. S0可信本地分发、S1启动的证据层级

**S0=CODEX_REPORTED_PASS_WITH_SCOPE**：本地受控完整Gradle8.14 ZIP 224,116,304 B、SHA256 `efe9a3d147d948d7528a9887fa35abcf24ca1a43ad06439996490f77569b02d1`与此前可信原件字节相符；报告称ZIP有27264个条目、其中22425个解压文件逐字节比对，路径穿越/碰撞/符号链接检查通过；独立launcher`bin/gradle.bat` SHA256 `af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`。同engine精确Flutter embedding POM/JAR仍是之前取得的2542 B / 1,541,793 B同SHA，不是此次下载。之前未经授权产生的`gradle-8.14-all.zip.part` 38,302,288 B保留、Hash不变、不复制或执行。上述全部是Codex LOCAL_ONLY回执，不冒称Astra逐文件再核。

**S1=CODEX_REPORTED_EXIT0，判定限定接受**：报告/manifest表明在S0四项复制/Hash/入口核定之后，由**分发内直接`bin/gradle.bat`**而非Wrapper启动`--version --offline --no-daemon --console=plain`，中性cwd、空隔离GRADLE_USER_HOME、JDK17，会话内环境设置；唯一启动exit0、约0.544秒，stdout为Gradle8.14，无`Downloading`输出。此证据支持`GRADLE814_STANDALONE_LOCAL_BOOTSTRAP_PASS`，但**不支持**`GRADLE_PROJECT_CONFIGURATION_PASS`、`DEPENDENCY_GRAPH_PASS`、`ALL_HOST_NETWORK_OFFLINE_VERIFIED`。报告中的Gradle内嵌Kotlin2.0.21不能和项目Kotlin插件2.2.20混淆。

## 3. S2/S3独立技术核查与根因分类

**S2明确NOT_RUN**：原正式任务S2.4明文要求当依赖解析任务仅由动态脚本定义、而没有已批准的可核验正式入口时，停止并记录`RESOLUTION_VERIFICATION_TOOLING_BLOCKED`。本轮报告说明`resolvePinnedDebugInputs`仅在上一轮临时init脚本`projectsEvaluated`中注册，项目跟踪源码没有固定该任务；Codex依其任务界限未将临时init脚本注入新隔离home、未运行项目依赖解析。**不能**由此断言“Gradle不支持动态任务”：动态任务完全可能有效，这是当前Owner授权／验证入口受限而非Gradle底层缺陷。真实解析次数0，既不能证明POM/JAR已经能被Gradle解析，也不能新造missing dependency坐标。

**S3明确NOT_RUN，且存在需要下一批准的内层Wrapper链**：Astra直接核固定产品源码`apps/android/app/build.gradle.kts` Blob `5a08d63f5f95155ca1f346f9809683f6f35ac7e0`：`tasks.named("preBuild") { dependsOn(syncFlutterAar) }`，`syncFlutterAar`对R1诊断分支通过`Exec`构造`apps/flutter_elitesync_module/.android/gradlew.bat`，传入原有Flutter SDK `aar_init_script.gradle`、专用测试target以及`assembleAarDebug --offline`。因此即使外层`<trusted>/bin/gradle.bat :app:assembleDebug`绕过Wrapper，仍会经`preBuild→syncFlutterAar→内层Wrapper`进入原先被禁止的引导；不修改已冻结源码/调用策略便无法证明整链符合“零Wrapper”。上一轮本次要求禁止Wrapper且不授权改源码，Codex停在S2前、没有冒险进入S3符合授权。实际`assembleDebug=0/1`，不是“build失败exit1”，没有APK及包名/签名/Flutter debug入口正向实物。
  
**判断限度**：本轮是**受限构建工作流仍有工具衔接缺口**，不是Flutter Maven同engine官方工件不可取得、也不是RTC的ICE端口/候选已经定位根因。未批准从`services.gradle.org`或其它域下载，不能以替换链接／临时取消offline／使用不可信`.zip.part`来制造假PASS。

## 4. 保护、审阅和遗留门

- Codex报告上一任务后注册的**1483份具名历史资产**及本次受保护输入bytes/SHA256不变，3193条SDK/env/lock/cache记录一致（包含3184原全局Maven文件）；5个历史根HEAD/branch/index/status、495 refs未变；第一根原153条Windows长路径warning不等于它们覆盖了未登记文件。Astra未逐文件本地验证，只能写`CODEX_REPORTED_LOCAL_PROTECTION_PASS_WITH_LIMITS`。
- 一次非作者GPT-6.1 Sol/high有界静态复核，未操作Gradle、网络、手机或重哈全部22425份文件；报告无新的高置信审阅阻断，但不等于设备/产物验收。
- 源码未变、无本轮依赖下载/Wrapper调用、无设备/模拟器/ADB、无数据库或SFU/API/媒体连接，不能写“本轮已验证RTC fail-closed在真机生效”。所有已证功能结果和旧安全/SQL/APP原证历史身份不变。

冻结AC-10.1.5-05仍全部开放：双独立真实APP双向流动音频未证；same-call实际媒体重连、旧RTC JWT首入及重入拒绝、撤权COMMIT后真实媒体停止≤5秒未执行。v10.1.5仍`PARTIAL/NOT_ACCEPTED`；main接受v10.1.4；方案A保留。

## 5. 裁决与最小下阶段权限建议（不自动下发）

**本次唯一任务在其实际范围内的独立裁决：`GRADLE814_OFFLINE_BOOTSTRAP_VERIFIED_FROM_CODEX_RECEIPT / RESOLUTION_TOOLING_GATE_STOP_COMPLIANT / DIAGNOSTIC_APK_NO_ARTIFACT / PARTIAL / OWNER_DECISION_REQUIRED`。** 不需要再重复`gradle --version`来证明同一件事，不自动重试空解析或构建。

如Owner以后决定继续，建议将下一个**唯一综合任务**直接收敛为两个**已知**构建编排障碍的定点修正，而不是再拆成反复独立审批：
1. **验证并具名批准**现有临时`resolvePinnedDebugInputs`的动态init脚本作为一次受控的离线解析验证器，或者审查后采用另一个同样无需修改正式源码的最小只读依赖解析入口。必须使用已固定Gradle8.14分发、隔离依赖、隔离home、没有任何外部下载，且不得把配置通过当依赖图通过。
2. **明确授权定点改变内层Wrapper调用策略**（仅诊断构建路线），令原`syncFlutterAar`这一个`Exec`在test-only条件下使用已核可信本地Gradle8.14二进制/或者完全隔离且验证完备的构建流程，保留原Flutter AAR target、Dart defines、cache coords、output及安全门。任何更改必须有专门source候选、定向负例与普通R1构建回归、非作者审查，不能偷偷改变普通release/旧R1构建链。
   
完成两步后若已知离线依赖确实齐备，才允许一次正向诊断APK构建和包名/签名/debug/test-only身份核验；若真正出现新缺失坐标，STOP并提交具体来源需求，**不得新下载或绕过依赖验证**。这些是未来Owner**需明确授权**的构建脚本／临时工具变更，**本轮没有授予**。仍不授权安装Android真机、SFU、ICE媒体、改变网络、main代码集成、自动R2或v10.1.6。

本轮Astra只在GitHub归档正式独立裁决，不执行本地构建或其他外部动作。
