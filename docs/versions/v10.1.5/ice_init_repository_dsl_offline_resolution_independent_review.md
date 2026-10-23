# EliteSync v10.1.5｜Gradle Init仓库DSL修正与首项离线依赖缺口 Astra独立复审

日期：2026-10-23（Asia/Singapore）。复审Authority：EliteSync GPT/Astra。

**INIT_DSL_DIAGNOSTIC_DELIVERY_REVIEWED_WITH_OBSERVATIONS / FIXTURE_PASS_CODEX_REPORTED / REAL_TARGET_RESOLVE_REACHED_BUT_BLOCKED / TWO_PINNED_ARCH_DEBUG_DEPENDENCIES_MISSING_FROM_OFFLINE_CACHE / NO_DIAGNOSTIC_APK / SOURCE_UNCHANGED / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / OWNER_DECISION_REQUIRED / NO_AUTOMATIC_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

本裁决**限定接受本轮离线工具调查和诚实停机的交付证据**，不是接受Gradle全依赖图、可运行诊断APK、真实RTC或冻结媒体安全合同。

## 1. 独立GitHub对象核验与证据等级

- 复审时`main` = `b13bdf188e6f6e1b6af7d98289f4bf2bf1d11814`，仍为已接受v10.1.4产品＋顾问治理文档，未集成本轮v10.1.5源码。
- Owner批准的唯一任务`docs/versions/v10.1.5/OWNER_APPROVED_INIT_REPOSITORY_DSL_FIX_AND_SINGLE_OFFLINE_BUILD_TASK_20261023.md`固定Blob `21b547a3c846326019f5662db984d328f9a34153`；上一轮Astra审查 `gradle_diagnostic_build_chain_fix_independent_review.md` Blob `4283ac288b31fdbd2513cccf8f8d3223ad0a687a`。本轮严格承接，不自行更改原AC05/产品规划。
- 最终候选Commit **`294c19f296b4b872dd7da8800d1901c08d209e51`**，唯一Parent **`7f059385f5fc4f6d17a87ce421e0ed4b3d976cc4`**，Root Tree **`069b16e6e42c9a011804814ea31a62cc061561d4`**；对父Git Compare ahead1／behind0，**只新增**两份文档：
  - `docs/versions/v10.1.5/ICE_INIT_REPOSITORY_DSL_OFFLINE_RESOLUTION_REPORT.md`，Blob **`a6261459a7dcbff49411c496101392713e74a493`**；
  - `docs/versions/v10.1.5/ice_init_repository_dsl_offline_resolution_manifest.json`，Blob **`6956357f1ba8a6a8890dfb74ce07b5fd480d2132`**。
- Astra通过GitHub直接读取候选/父Commit和两份原文、JSON清单、Compare及两个Git Root Tree，验证完整apps Tree在父和本候选均为 **`8011c1909444c689c45a23d4c20e1bef85694966`**，services均为 **`1e1e20bb3500bedb1a521e5f2ddeece915d09424`**；仅docs子Tree不同。**`SOURCE_UNCHANGED`属ASTRA_GITHUB_DIRECT可证明**，固定Gradle诊断源码仍为`5354ba679e24dbf972cea74e8fd0f60c51a2eca0`。
- Astra未访问Owner Windows真实任务目录、LOCAL_ONLY Groovy脚本/fixture二进制、Gradle完整原始stdout/stderr、68303份文件、Android手机或SQL/SDK原件。凡有关本地实际8测试、S2 runtime、历史hash/停机的事实，证据等级均是**`SUPPORTED_BY_CODEX_LOCAL_RECEIPTS`**，不是Astra亲自执行或hash后宣称全部PASS。仅公开报告和manifest能独立核内部口径一致性。

## 2. G0–G1：临时仓库DSL修正的真实增量

前一候选LOCAL_ONLY临时init SHA256 `bca437d1a485a81981df14e97bea478f7615193789795377d2d0a8034031b1f9`，真实错误为`Could not find method maven() on ExclusiveContentRepositorySpec`，发生在仓库闭包配置阶段，本来没有目标Configuration.resolve调用。

本轮Codex报告仅在新的LOCAL_ONLY脚本把仓库创建调用改为`forRepository { repos.maven { ... } }`并重定位任务归属根；新脚本3362 bytes、SHA256 **`5dad6fe912efab85e20b8c1fe2d0b3b81c3984dc68a1ef6704496a94288fa43b`**。该文件不在Git仓库产品源码中，Astra没有直接读此原件，故不把“只两处改动”说成GitHub直接diff证据。

据本地回执，实际以可信Gradle8.14运行**一次**无Android/Flutter插件的最小离线fixture，exit0、8/8：真实注册MavenArtifactRepository，官方同engine`flutter_embedding_debug`原件POM/JAR都成功解析且本地SHA匹配；`fixture.denied`合成同库负例有无过滤对照，错误Receiver和空对象拒绝。fixture使用空隔离Gradle home、没有远端仓库、官方工件的`transitive=false`，不应被说成项目全部传递依赖验证；fixture helper在换行归一后与实际脚本对应，**不是整文件字节同一**。该受限G1工作范围可记`FIXTURE_SCOPE_PASS_CODEX_REPORTED`。

上轮已取得的精确`io.flutter:flutter_embedding_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab` POM(2542B，SHA256 `437cf27a8aa1829c07f81f43e0468a5fa05cef7dc21451cabd51b7a6914341ff`)与JAR(1541793B，SHA256 `f6cb78578df77875f18f4d6c3bd29066288109935007e59d83e53ec85a8ce745`)在本轮仅本地复用。没有新官方发布者SHA/签名证明，故不能把存量原件身份扩展为官方签名接受。

## 3. G2：真实解析确已抵达第一个配置，但没有整体PASS

本地回执明确：**一次**正式`resolvePinnedDebugInputs --offline`，历时约96.498秒，exit1。首次出现`PINNED_RESOLVE_BEGIN :flutter:debugCompileClasspath`，之后因该配置两项同engine工件**离线缓存不可解析**失败；`PINNED_RESOLVE_OK`为0、`PASS`为0；30个计划配置中仅第一个开始，剩余29项`NOT_RUN`。这证明前次`exclusiveContent`闭包错误在本次这条执行路径上**未再阻断**，且`Configuration.resolve()`已真正触发；不等于目标配置成功，更不等于其他14模块依赖图已经检查完。

新缺失坐标（**来自本轮明确Gradle离线错误，而非Astra猜测**）：
1. **`io.flutter:x86_64_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`**
2. **`io.flutter:arm64_v8a_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`**

严守结论边界：
- 错误性质是`MISSING_DEPENDENCY_COORDINATE_FROM_OFFLINE_CACHE`，并非官方仓库未发布或二进制已验证可下载。此轮**没有请求这两个远端工件**，其真实packaging/大小/Hash/官方可获得性均**UNKNOWN**。
- `Initialization script line37`这次是目标`config.resolve()`的调用位置，不能误说成上次line9仓库DSL异常重现。
- 此次不能断言“只缺这两个工件”。其它29个配置尚未运行、同一配置如有进一步解析问题也未暴露；不能称传递依赖图完整。
- 由于G2未通过，G3`assembleDebug`真实执行**0次**，不存在`build exit1`。APK packageId/版本/debuggable/签名/ABI/Flutter调试AAR与真实媒体统计功能全部`NOT_VERIFIED`。

## 4. 独立构建前置阻断、安全保护及后续门禁

候选报告/manifest还确认两个**独立于下载缺项**的G3前置问题：
- **`BUILD_PATH_IDENTITY_BLOCKED`**：已跟踪的固定Gradle诊断源码`apps/android/app/build.gradle.kts`绑定上一构建链特定的project/GRADLE_USER_HOME/taskRoot；当前新任务根在不改源码/覆盖原归属目录的前提下无法满足。不能软链/伪造Hash/挪动保护根使路径看似相符，也不能在尚未经Owner授权时修改产品/构建源码。
- **`SDK_STAGE_INCOMPLETE`**：现有隔离Flutter副本仅被证明满足Gradle配置阶段，未证明完整Dart/AAR/APK正向构建需要的本地组件齐备；不能为了拿APK任意复制全局SDK或新下载。

关于本地保护，Codex报告G0/G4对**68303件具名文件**及前轮35685件集合做hash/bytes比对、497旧refs和五历史根HEAD/branch/index/status相符，Windows既有153条长路径警告仍在，未受权Gradle`.zip.part` 38302288B同SHA原位未用。原global Maven统计3184与本次包含锁文件的3185条`global Gradle module records`口径不同，不能简单解释成新增下载。以上是**本地Codex回执**，Astra没有全盘亲自hash；未操作手机/ADB/数据库/服务/Room.connect及没有新网络下载属于Codex有界执行报告。

一次非作者GPT-6.1 Sol/high静态复核检查fixture证据、失败坐标、边界；该复核不代替实体APK或媒体安全验收。当前单手机加HTTP-only peer也未达到冻结双APP媒体合同。本轮未改变已接受main产品、RTC系统安全阈值或Owner方案A。

## 5. Astra正式裁决与后续Owner权限建议

**本轮交付在其受限范围内裁定：`GRADLE_INIT_DSL_FIXTURE_SCOPE_ACCEPTED_WITH_OBSERVATIONS / TARGET_OFFLINE_RESOLVE_REACHED_AND_BLOCKED_AT_PINNED_ARCH_ARTIFACTS / NO_APK / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`。** 不再就同一Groovy仓库闭包重复诊断；不要再用`gradle --version`或fixture成绩代替已经找到的真实坐标。

未来建议Owner**一次性有界批准**两条相互独立的工作线在同一长任务里协调，而不再次分裂成无信息的预检轮：
1. 先核实**精确同engine**`io.flutter:x86_64_debug`与`io.flutter:arm64_v8a_debug`的官方发布元数据和可信实际二进制，并在明确许可后只获取**确认缺失的官方依赖**至本任务隔离缓存，带URL、版本、大小、hash/CRC和发行者签名是否可得分级；不得扩展整个Flutter SDK/升级engine或任意其它包，若出现其它真正缺项须STOP请求Owner。
2. **单独具名修复**诊断test-only的`BUILD_PATH_IDENTITY`环境耦合及验证`SDK_STAGE_INCOMPLETE`对应的已拥有本地组件。只有在不改变正常R1/release产品构建行为、不清理历史缓存与old data且保证无Wrapper下载的情况下，才允许下一次真实离线解析／有限APK构建。工具链和路径修订需可审核代码diff/负例，不应为了构建成功弱化安全门。

**上述仅为建议，不视作已经授予下载权限、源码修订或再次消耗真实Gradle执行预算。** 本次不自动派发下一任务、不合产品源码main、不启动R2/P2/v10.1.6、不操作真机。冻结AC-10.1.5-05双APP媒体、same-call重连、旧RTC JWT首入重入、COMMIT后流动媒体≤5s仍全部OPEN/NOT_RUN；v10.1.4仍是main接受产品。

**最终：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / OWNER_DECISION_REQUIRED / PLAN_A_RETAINED`**。
