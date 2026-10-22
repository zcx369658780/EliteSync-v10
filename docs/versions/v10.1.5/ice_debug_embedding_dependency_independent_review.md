# EliteSync v10.1.5｜官方Debug Embedding依赖补齐任务 Astra 独立复审

日期：2026-10-22（Asia/Singapore）；Authority：EliteSync GPT/Astra独立Reviewer。

**INDEPENDENT_REVIEW_COMPLETE / PARTIAL / OFFICIAL_EMBEDDING_EVIDENCE_SUPPORTED_CODEX_LOCAL / UNAUTHORIZED_WRAPPER_DOWNLOAD_ATTEMPT_RECORDED / DEPENDENCY_GRAPH_NOT_PARSED / DIAGNOSTIC_APK_NOT_BUILT / PHONE_RUNTIME_NOT_RUN / PRODUCT_V10.1.5_NOT_ACCEPTED / AC05_OPEN / OWNER_DECISION_REQUIRED / NO_AUTO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

## 1. 范围、直接证据与权威身份

本独立复审实际通过GitHub读取固定commit、报告、JSON清单、两个完整Root的Git Tree，并独立比较apps/services SHA与changed paths。Astra**没有**访问Owner Windows文件系统、官方POM/JAR原始二进制、Gradle实际执行环境、原始缓存、1441份LOCAL_ONLY原证或真机，因此必须分离`GITHUB_DIRECT`与`CODEX_REPORTED_LOCAL_ONLY`两种证据等级。对外部Gradle官方文档只用来解释Wrapper引导顺序，不把文档当作该机器的现场回执。

- 原Owner有界任务`docs/versions/v10.1.5/OWNER_APPROVED_ICE_DEBUG_EMBEDDING_DEPENDENCY_TASK_20261022.md` Git Blob `38d83feca11946685d42c9f75b15ad8d207692c5`；授权官方Flutter Maven精确坐标及同engine必要依赖，**不授权**其它域或Gradle分发下载。
- 复审前live `main` SHA `0cb38cce0625319a113f043c63b8462dda699e90`，为已接受v10.1.4产品加文档，**不是v10.1.5产品源码**。
- 本轮交付Commit `73b3b753225f99824081d312a25a7deb170c62d3`，Root Tree `6c45db667bb7a11234a72600c41f04b9432328b6`；唯一Parent `8bee827c20c26c4ec954b774c011f09238ec59b3`，Parent Root `81aad417e50f6d7a180135248ccdd73da9b69c6f`。compare显示ahead1/behind0，**仅新增**`ICE_DEBUG_EMBEDDING_DEPENDENCY_UNBLOCK_REPORT.md`与`ice_debug_embedding_dependency_unblock_manifest.json`。
- 两份文档Git Blob各为`ba2212be8342dc0e6354a70bab4a64c456e2a716`和`646840354b93dab3ed617e43aac89af469fa9fa5`，Astra直接读取。完整apps Tree在父与本次候选均为`72c617cf86d5c653dd722accde340b51d2e085eb`，services Tree均为`1e1e20bb3500bedb1a521e5f2ddeece915d09424`，故`SOURCE_UNCHANGED`已由Git对象直接证明。
- 待构建诊断源码`24ddf05875d8d4abad7a6b473f882698c9885c2a`不变；Astra上一诊断源码复审Blob`6c736933e96e32b25e57a4318aa760049e5ed758`仍有效。

## 2. 官方精确工件的分层证据

Codex的本地回执称已读取Flutter SDK engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、Flutter `3.41.7`、Dart `3.11.5`及既有锁文件；任务目标为`io.flutter:flutter_embedding_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`。本轮没有SDK/lock源码修改。

报告与manifest交叉吻合的官方请求回执：

| 固定坐标工件 | Codex所报响应和本地校验 | 复审分类 |
|---|---|---|
| `.pom` | `storage.googleapis.com/download.flutter.io`同版本路径，HTTP 200、2542 B、SHA256 `437cf27a8aa1829c07f81f43e0468a5fa05cef7dc21451cabd51b7a6914341ff` | `SUPPORTED_CODEX_REPORTED` |
| `.jar` | 同源同版本，HTTP 200、1,541,793 B、SHA256 `f6cb78578df77875f18f4d6c3bd29066288109935007e59d83e53ec85a8ce745`；ZIP CRC、436条目及FlutterEngine.class的本机验证回执 | `SUPPORTED_CODEX_REPORTED` |
| `.pom.sha256`、`.jar.sha256` | 两项HTTP404 | `PUBLISHER_SHA256_SIDECAR_NOT_AVAILABLE` |

报告和清单一致标记POM`packaging=jar`，因此**本精确工件不是AAR**，不能以“未取AAR”当作缺失，也不能伪造AAR。Codex报告下载均无重定向、CRC32C自算匹配且ETag与本地MD5计算值一致；这仅证明所见对象及下载字节一致性，**不等于发行者数字签名或外部独立来源审计**。Astra没有从官方仓库下载原始POM/JAR核对其SHA，因此本轮“官方文件取得”是有具体URL/hash/字节证据的**Codex本地结果**，不是Astra亲手验证的供应链PASS。其他POM第三方传递依赖尚未由Gradle解析，不能宣告依赖图已完备。

## 3. Wrapper越界事件与构建门裁决

**事件完整保留，不可消解**。本轮使用私有`GRADLE_USER_HOME`，拟将可信Gradle8.14分发复制进隔离目录；但缓存复制尚未完成/核毕，实施者先启动`gradlew.bat resolvePinnedDebugInputs --offline`。Wrapper在init脚本和依赖解析之前准备下载`https://services.gradle.org/distributions/gradle-8.14-all.zip`；该域名和分发不属于**本任务唯一批准的Flutter Maven工件范围**。因此`--offline`不能作为Wrapper网络限制保障：官方Gradle Wrapper手册明示在本地缺少所需分发时先下载到Gradle用户目录。本案符合该机制描述；这不独立证明未观测的最终重定向主机。

本地回执记录约**38,302,288 B** `gradle-8.14-all.zip.part`，SHA256 `f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`。此部分下载**未经授权，不能写“未发生下载”**，亦不得作为可信Gradle分发执行/解压/合并缓存。报告称及时识别并只停止本任务归属Wrapper进程，没有覆盖全局缓存或重试。另隔离目录`224,116,304 B`完整ZIP与原有可信分发原件hash一致，仅是本地继承复制，不能与新的不受权`.part`混为一谈。

分层裁决：

- `OFFICIAL_PINNED_POM_JAR_OBTAINED_REPORTED`：有限可保留；
- `AUTHORIZATION_BOUNDARY_BREACH_ATTEMPT_CONFIRMED_FROM_CODEX_RECEIPT`：实际发生**授权域外下载尝试/部分字节落盘**，不能当作全部安全门PASS；停止行为正确且没有继续扩大；
- `ISOLATED_GRADLE_BOOTSTRAP_NOT_READY`、`DEPENDENCY_RESOLVE_NOT_RUN`、`DIAGNOSTIC_POSITIVE_ASSEMBLE_DEBUG_ATTEMPTS=0`；
- `DIAGNOSTIC_APK_NOT_PRODUCED`、包名/签名/源码Dart调试入口的正向**APK**实物均`NOT_VERIFIED`；
- `PHONE/ADB/SFU/LARAVEL/DB/ROOM_CONNECT=NOT_RUN`，不能把前轮20诊断测试、93普通回归/五负向build门`REUSED_VALIDATION`冒称本轮新跑或真机验证；
- `PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`，双实际APP媒体、same-call重连、旧JWT拒绝、COMMIT后流动媒体≤5秒停止继续全部没有新证据。

报告所称1441具名历史原证、3184全局缓存文件、3190 SDK/env/lock/cache记录、5根/494 refs/private.env前后匹配及153条既有Windows长路径警告，均为Codex**LOCAL_ONLY保护结果**，Astra没有访问物理磁盘独立hash。GitHub可直接保证的是发布后的apps/services产品树未变及仅两份文档变动，不可扩张为全部磁盘无变化。

## 4. 正式结论及Owner下一门

**正式结论：`V10.1.5_DEBUG_EMBEDDING_DEPENDENCY_TASK_PARTIAL_WITH_BOUNDARY_INCIDENT / SUPPLY_ARTIFACTS_REPORTED / NO_GRADLE_RESOLUTION / NO_APK / RTC_NOT_ACCEPTED / AC05_OPEN / OWNER_DECISION_REQUIRED`。** 当前证据支持把失败归类为**构建工具引导先后顺序/隔离分发就绪问题**，不是官方精确Flutter Maven版本一定不存在，也不是RTC音频故障已被根因定位。不得据此更改SFU网络、开放UDP/LAN/TURN、防火墙或直接合并main。

最小的下一步（**建议而非自动授权**）：由Owner明确批准另一次只限既有可信本地Gradle8.14分发的完整性/可执行启动门修正：
1. 在完全复制并验证现有可信分发的ZIP、目录结构、wrapper元数据与正确`GRADLE_USER_HOME`之后，**先用不会意外联网的方法证明分发能够本地启动**；可考虑直接调用事先验证的本地Gradle8.14可执行文件，或先证Wrapper能完全离线复用已有目录；不得在分发就绪前再次执行gradlew以赌运气；
2. 隔离本次未受权`.zip.part`且不执行、不加入依赖路径；原件保留以便审计，处理/删除须按归属审批；不要借这次事故扩展到`services.gradle.org`新下载权限；
3. 仅在本地Gradle离线启动门已证实时，验证现有官方精确POM/JAR可供isolated Gradle解析；如遇新的**真实**第三方传递依赖缺失，停并向Owner报精确坐标/来源，不能无限抓依赖；
4. 依赖解析通过之后才能执行**至多一次**正向诊断debug APK构建及包名、签名/debug限定验证。仍不授权任何手机安装或ICE/媒体实测。

**本轮不自动发新任务、R2、P2、main产品集成、v10.1.6，不删/改任何旧候选及真实LOCAL_ONLY原证。** main继续已接受v10.1.4；原v10.1.5 AC保持冻结，方案A继续生效。
