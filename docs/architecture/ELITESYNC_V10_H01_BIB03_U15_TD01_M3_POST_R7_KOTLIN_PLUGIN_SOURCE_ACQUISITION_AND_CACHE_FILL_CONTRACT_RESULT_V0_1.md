# EliteSync v10｜Post-R7 Kotlin Gradle Plugin 2.1.0 Source Acquisition + Cache-Fill Contract Result v0.1

Status: `EXECUTED RESULT CANDIDATE — READ-ONLY SOURCE-CONTRACT REVIEW — NO ARTIFACT DOWNLOAD — NO CACHE FILL — NO GRADLE — NO M3 — NO M2`

## 1. Final classification

`KOTLIN-GRADLE-PLUGIN 2.1.0 SOURCE-ACQUISITION CONTRACT ESTABLISHED — READY FOR OWNER-AUTHORIZED B12 ACQUISITION`

该结论只建立一个后续可由 Owner 明确授权的、非伪造 Gradle cache 的 B12 acquisition contract：从 Maven Central 获取本结果逐项列出的同一 coordinate 元数据、校验材料和 classpath JAR，写入 task-owned external staging/local Maven repository，并立即核验 Length 与 SHA-256。

该结论不授权 B12，不证明任何 direct dependency 已在本地，不授权取得 direct dependency，不建立完整 offline classpath，不授权把文件手工写入 Gradle native cache，也不授权 Gradle、M3、AAR probe 或 M2。

## 2. Authority and bounded reads

- fresh-fetched GitHub `main`=`c66d4dabb44f512cf6d8d9dfb8c03b3d317c5e9e`；与 B11 authority 精确一致。
- FIRST blob=`18485c95262051e43892436fb52413132c5ee626`；已首先完整读取并匹配。
- B11 task branch=`task/h01-bib03-u15-td01-m3-post-r7-kotlin-plugin-source-acquisition-b11-v0-1`。
- B11 task commit=`ab01e6749171b4a2b3620b1fec8ab91c498104cb`；sole parent=`c66d4dabb44f512cf6d8d9dfb8c03b3d317c5e9e`。
- B11 task path=`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_KOTLIN_PLUGIN_SOURCE_ACQUISITION_AND_CACHE_FILL_CONTRACT_TASK_V0_1.md`。
- B11 task blob=`0da80ae8f7b83ac8d84478a7c9a112884fb3ff9d`。
- accepted B10 result blob=`cb31b77d3cdb64c4d0d47446aab81808e6418876`；已完整读取。
- accepted B9 result blob=`8b49fec7c642dec47ef7f8c844162cbe9aa60218`；只读取 exact remote-resource failure 与当前 Gradle/M3 上下文。
- B9 exact observed failure：Gradle 无法解析 `org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0`；对 Google Maven 与 Maven Central 的两个 exact POM resource 请求均因主机名不可解析失败；该唯一 M3 退出 `1`，后续 network/package fill、Gradle resolution retry、M3 retry、M2 均为 `NOT_RUN`。
- external source reads 仅限该 coordinate 的 POM、Gradle module metadata、checksum/signature resources及 classpath JAR `HEAD`；JAR body=`NOT_READ`，remote object=`NOT_SAVED`。
- research date=`2026-09-10`。

## 3. Exact coordinate and repository authority

唯一 primary coordinate：

`org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0`

### 3.1 Google Maven

下列 exact resource 在本轮 fresh read 中均返回 HTTP `404`：

- `https://dl.google.com/dl/android/maven2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.1.0/kotlin-gradle-plugin-2.1.0.pom`
- `https://dl.google.com/dl/android/maven2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.1.0/kotlin-gradle-plugin-2.1.0.jar`
- `https://dl.google.com/dl/android/maven2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.1.0/kotlin-gradle-plugin-2.1.0.module`
- 上述三者对应的 `.sha256` 与 `.sha1` resources。

因此：Google Maven 未建立该 coordinate 的可取得副本；不能声称 Google Maven 与 Maven Central copies byte-identical。B9 中出现 Google URL 只证明 Gradle 按 repository order 尝试该 URL，不证明该 resource 存在。

### 3.2 Maven Central

Maven Central 是本任务唯一已证明发布该 coordinate 的 acquisition authority：

`https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.1.0/`

Preferred acquisition authority：`repo.maven.apache.org`。

Maven Central POM 内含 `published-with-gradle-metadata` marker，明确指示 Gradle metadata consumer 优先使用 `.module`；因此 `.module` 是后续 Gradle resolution 的 mandatory descriptor，不应只放置 POM/JAR 后假设等价。

## 4. Exact authoritative object inventory

### 4.1 Mandatory descriptors and base artifact

| object | canonical URL | HTTP / Length | SHA-256 authority | role |
| --- | --- | --- | --- | --- |
| `kotlin-gradle-plugin-2.1.0.pom` | `https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.1.0/kotlin-gradle-plugin-2.1.0.pom` | `200 / 10,992` | `.sha256` not published；`TO_BE_CAPTURED_DURING_AUTHORIZED_ACQUISITION` | mandatory Maven descriptor/fallback model |
| `kotlin-gradle-plugin-2.1.0.module` | `https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.1.0/kotlin-gradle-plugin-2.1.0.module` | `200 / 80,167` | `.sha256` not published；`TO_BE_CAPTURED_DURING_AUTHORIZED_ACQUISITION` | mandatory Gradle rich metadata and variant selector |
| `kotlin-gradle-plugin-2.1.0.jar` | `https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.1.0/kotlin-gradle-plugin-2.1.0.jar` | `200 HEAD / 28,880,724` | `.module` SHA-256=`f582c02aae45ce175c572f3d4414b8a701898d2e7b4cab99f8aa9dfb9bc86b8f` | mandatory base/fixed-attribute classpath variant |

B11 对已授权 POM/`.module` metadata response 做过内存内 SHA-256 复核，分别得到 `EBBD7CB6A5606A2EEF9F2B47B4C1D4C974B44900153A7C9DB37F838BCFB541CF` 与 `0A846B51225D2A0443F005316CBB1318591F5855AE6E955F7860C25BEE9D2B17`。它们是本轮 response identity cross-check，不替代 B12 对实际取得对象的即时 Length + SHA-256 捕获，也不冒充仓库单独发布的 `.sha256` resource。

### 4.2 Exact classpath variant JAR set

既有 B9/B10 evidence 未绑定实际 consumer Gradle plugin API version；B11 没有运行 Gradle，也没有扩大读取以猜测版本。为使 B12 contract 在该未知量下仍 exact、无 wildcard 且不触及相邻 coordinate，B12 proposed acquisition set 精确包含 `.module` 列出的全部五个 library classpath JAR；sources/javadoc JAR 不在集合内。

| filename / exact Central URL suffix | Length | authoritative SHA-256 from `.module` | applicability |
| --- | ---: | --- | --- |
| `kotlin-gradle-plugin-2.1.0.jar` | 28,880,724 | `f582c02aae45ce175c572f3d4414b8a701898d2e7b4cab99f8aa9dfb9bc86b8f` | no plugin-api attribute / fixed fallback |
| `kotlin-gradle-plugin-2.1.0-gradle80.jar` | 28,874,747 | `dececa5596e1f8607ff2237af0ad9375878eff29aae067d5507f9d37a96619f8` | plugin API `8.0` |
| `kotlin-gradle-plugin-2.1.0-gradle81.jar` | 28,874,753 | `77d37652463ef468c9e3e09035d26ceb0c6e9f3df7d193b0a0ef5f1a3f0f109c` | plugin API `8.1` |
| `kotlin-gradle-plugin-2.1.0-gradle82.jar` | 28,872,657 | `e63ba7311f908f7433173cd8a27c73d2e0f8479dfb9ad2e5940c7e270e160dc2` | plugin API `8.2` |
| `kotlin-gradle-plugin-2.1.0-gradle85.jar` | 28,864,735 | `caafc71157634bf7864f44026f5a63d256881c1cd9711456325266a53bafe728` | plugin API `8.5` |

每个 URL 均为上述 Central base URL加 exact filename；五个 HEAD response 均为 `200`，且 Content-Length 与 `.module` size 全部精确一致。

四个 plugin-API variant JAR 的 published verification resources 也已逐项证明：

| variant JAR | SHA-1 | MD5 | `.asc` |
| --- | --- | --- | --- |
| `kotlin-gradle-plugin-2.1.0-gradle80.jar` | `ff082c57d7d0333113a39bcaf0e4d09ef75c257a` | `7c43a03668a9e5bbcf12ed9279771ac3` | `200 / 689 bytes` |
| `kotlin-gradle-plugin-2.1.0-gradle81.jar` | `a83e1341b4718bd6e6ae76bce5a020a78984fd05` | `e33786eb0d8d1b7e29c8088612be8984` | `200 / 689 bytes` |
| `kotlin-gradle-plugin-2.1.0-gradle82.jar` | `6d02e21b63126e43a520af3ea2cd4c2cde14a2af` | `5fef0bc904388cb427c6c006564f70be` | `200 / 689 bytes` |
| `kotlin-gradle-plugin-2.1.0-gradle85.jar` | `43b225a353673533d9b523667983ee0276baf947` | `ed15e88534f3d46ed6e48e45bdbc50fb` | `200 / 689 bytes` |

### 4.3 Published checksum/signature resources

Maven Central 对 POM、base JAR、`.module` 均发布：

- `<object-url>.sha1`
- `<object-url>.md5`
- `<object-url>.asc`

Observed values：

| object | SHA-1 | MD5 | PGP signature |
| --- | --- | --- | --- |
| POM | `b6135bd4d7628804aaa9ccba4f0ab013a5993310` | `e5d6c35be0b58c1db4acf253bef356f3` | published, 689 bytes |
| base JAR | `6754c160c792aeaad521a1f1b80e3b96f2dae9b9` | `45f9643478b193272d0b3852ebb1a803` | published, 689 bytes |
| `.module` | `598e489c64473f2e6caca3f1c1e2e629b0ca343e` | `8459c9c1e295ae97654c348c944931df` | published, 689 bytes |

对应 `.sha256` resources 均返回 `404`。PGP signature resource 的存在不等于 signer trust 已建立；B11 未取得 signer key、未验证 trust chain，故不得把 `.asc` existence 写成 signature verification PASS。

## 5. Direct dependency inventory

POM direct dependencies 与 `.module` runtime variants 一致；`.module` 另外把 BOM作为 direct platform dependency。以下九项均是该 coordinate 的 direct resolution edge；它们不是本 B11/B12 自动 acquisition authority。

| group | artifact | version | scope / role | mandatory for runtime classpath resolution | fixed guest cache state |
| --- | --- | --- | --- | --- | --- |
| `org.jetbrains.kotlin` | `kotlin-gradle-plugins-bom` | `2.1.0` | POM import / Gradle platform, strict-version alignment | YES for `.module` runtime variant metadata resolution | `UNKNOWN — NOT_CHECKED` |
| `org.jetbrains.kotlin` | `kotlin-gradle-plugin-api` | `2.1.0` | POM compile / module runtime | YES | `UNKNOWN — NOT_CHECKED` |
| `org.jetbrains.kotlin` | `kotlin-gradle-plugin-model` | `2.1.0` | POM compile / module runtime | YES | `UNKNOWN — NOT_CHECKED` |
| `org.jetbrains.kotlin` | `kotlin-gradle-plugin-idea` | `2.1.0` | runtime | YES | `UNKNOWN — NOT_CHECKED` |
| `org.jetbrains.kotlin` | `kotlin-gradle-plugin-idea-proto` | `2.1.0` | runtime | YES | `UNKNOWN — NOT_CHECKED` |
| `org.jetbrains.kotlin` | `kotlin-klib-commonizer-api` | `2.1.0` | runtime | YES | `UNKNOWN — NOT_CHECKED` |
| `org.jetbrains.kotlin` | `kotlin-build-statistics` | `2.1.0` | runtime | YES | `UNKNOWN — NOT_CHECKED` |
| `org.jetbrains.kotlin` | `kotlin-util-klib-metadata` | `2.1.0` | runtime | YES | `UNKNOWN — NOT_CHECKED` |
| `org.jetbrains.kotlin` | `kotlin-compiler-runner` | `2.1.0` | runtime | YES | `UNKNOWN — NOT_CHECKED` |

没有读取或列举这些 direct dependencies 的 POM、module metadata、artifact、transitive dependencies、相邻版本或本地 cache entries。它们的本地存在性与完整性需要 separate bounded follow-on decision；B12 不能据本表自动下载它们。

## 6. Cache-fill/exposure mechanism decision

### A. Task-owned external staging + narrow local Maven repository — SELECTED

Gradle 官方支持以 exact URL 声明 Maven-compatible repository，并只使用构建已声明的 repositories。后续 task 可把经过验证的 exact Central objects 保持为标准 Maven layout，然后通过一个仅 include 此 module 的 repository declaration 暴露给 isolated test。

这是唯一 selected approach，因为它：

- 保留原始 POM与 Gradle module metadata；
- 由 Gradle 自己解析并生成 native cache metadata；
- 不伪造 `files-2.1` checksum path、repository identity或 `metadata-2.*` binary records；
- 可按 exact module content filter 收窄；
- 可独立保留 acquisition evidence 与 rollback boundary。

### B. Direct Gradle native cache population — REJECTED

`C:/M3A/cache/gradle/caches/modules-2/**` direct manual mutation=`UNSAFE / UNSUPPORTED FOR THIS CONTRACT`。

Gradle 官方说明 dependency cache 同时包含 checksum-addressed artifact store与 repository-specific resolved module metadata binary store；`metadata-2.*` 还随 Gradle version变化。仅把 POM/JAR放入 `files-2.1` 不能建立合法 descriptor/repository resolution state，手工构造 binary metadata也没有本任务可引用的支持契约。

### C. Other Gradle-supported local repository mechanism — NOT SUPERIOR

- `flatDir` 缺少 Maven/Gradle dependency metadata与 variant model，不能正确表达本 coordinate 的九个 direct edges和 plugin API variants。
- 自建 Ivy layout需要重新表达/转换现有 Maven/Gradle metadata，增加伪造风险，没有优于原样 local Maven repository 的证据。

## 7. Exact proposed B12 acquisition contract — NOT EXECUTED

### 7.1 Allowed network and source set

- only allowed scheme/host=`https://repo.maven.apache.org`
- only allowed base path=`/maven2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.1.0/`
- exact allowed primary objects：POM、`.module`、本结果 4.2 的五个 classpath JAR。
- exact allowed verification objects：上述 primary objects对应且实际 published 的 `.sha1`、`.md5`、`.asc`；不得 wildcard列举或同步目录。
- `dl.google.com` acquisition=`NOT_ALLOWED / NO COPY ESTABLISHED`。
- neighboring group/module/version、sources、javadoc、direct dependency acquisition=`NOT_ALLOWED`。

### 7.2 Exact task-owned staging/local repository root

Proposed root：

`C:\M3A\tasks\B12-kotlin-gradle-plugin-2.1.0\staging\maven-repository`

Exact coordinate directory：

`C:\M3A\tasks\B12-kotlin-gradle-plugin-2.1.0\staging\maven-repository\org\jetbrains\kotlin\kotlin-gradle-plugin\2.1.0`

该 root 在 repository、module、Flutter SDK 与 `C:\M3A\cache\gradle`之外。B11 没有创建它。

### 7.3 Required acquisition evidence

对每个 exact object，B12必须逐项记录：URL、HTTP status、response Content-Length、落地 filename、actual Length、immediate SHA-256、published SHA-1/MD5对比结果、时间与唯一 attempt identity。

- JAR SHA-256 必须与 `.module` 中本结果 4.2 的 value 精确相等。
- POM/`.module` 因没有 published `.sha256`，其最终 authoritative acquisition SHA-256在 B12 实际取得后记录；在此之前保持 `TO_BE_CAPTURED_DURING_AUTHORIZED_ACQUISITION`。
- POM/`.module` actual Length、SHA-1、MD5必须与本结果精确相等。
- `.asc`只在 B12另行建立 exact signer key/trust authority时才可报告 verification PASS；否则只记录 resource identity。
- 任一 mismatch立即 fail closed；不得用另一个 repository、mirror、neighboring version或transitive acquisition替代。

### 7.4 Exact later exposure mechanism

Local Maven URL：

`file:///C:/M3A/tasks/B12-kotlin-gradle-plugin-2.1.0/staging/maven-repository`

后续 separate Owner-authorized B13 可使用 Gradle-supported init script，在任何 project build script求解 buildscript classpath前，把上述 repository 添加到各 project 的 `buildscript.repositories` 首位，并以 content filter 精确限制为：

- group=`org.jetbrains.kotlin`
- module=`kotlin-gradle-plugin`

init script必须由 B13 给出 exact path、exact content、write/cleanup与 pre/post evidence authority。Gradle官方支持 command-line `-I/--init-script`、`GRADLE_USER_HOME/init.gradle(.kts)`及 `GRADLE_USER_HOME/init.d/*.init.gradle(.kts)`；对 Flutter驱动的 M3，哪一种入口能被实际子 Gradle进程可靠继承仍须由 B13在不运行 M3之前做精确治理选择。本结果不自行声称 Flutter会转发 Gradle `-I`。

该 repository 只能暴露 primary coordinate；九个 direct dependencies继续由既有 repository/cache resolution处理。若任何 mandatory direct dependency local completeness 未建立，B13/M3仍保持 blocked；不得把 primary artifact acquisition误写为完整 offline classpath。

## 8. Authoritative Gradle references

- Maven repository declaration与“Gradle只使用 build script声明 repositories”的官方说明：`https://docs.gradle.org/current/userguide/supported_repository_types.html#sec:maven_repo`
- init script discovery order、`-I/--init-script`、`GRADLE_USER_HOME/init.d`与 `beforeProject` callback：`https://docs.gradle.org/current/userguide/init_scripts.html`
- dependency cache 的 checksum artifact store、repository-specific binary metadata与 `metadata-2.*` version mapping：`https://docs.gradle.org/current/userguide/dependency_caching.html#sec:dependency-cache`

官方文档本轮显示 version=`9.7.1`；本结果只引用不依赖产品 Gradle版本的 repository/init/cache-structure规则，不据此推断固定 guest 的实际 Gradle version。

## 9. Explicit NOT_RUN / NOT_MODIFIED

- Maven JAR body download/read/save=`NOT_RUN`
- Maven artifact persistence=`NOT_RUN`
- task-owned staging/local Maven repository creation=`NOT_RUN`
- Gradle native cache fill/mutation=`NOT_RUN`
- direct dependency acquisition/cache inspection=`NOT_RUN`
- Flutter pub / Dart pub=`NOT_RUN`
- `flutter create`=`NOT_RUN`
- `.android` delete/recreate=`NOT_RUN`
- Gradle/gradlew=`NOT_RUN`
- Gradle dependency resolution=`NOT_RUN`
- M3 / M3 retry=`NOT_RUN`
- AAR probe=`NOT_RUN`
- M2=`NOT_RUN`
- product implementation=`NOT_RUN`
- Sandbox create/stop/close/reset/kill/share/materialize=`NOT_RUN`
- repository-wide、directory-wide、host-wide、whole-cache、whole-SDK search/enumeration=`NOT_RUN`
- default `git status` / protected index inspection=`NOT_RUN`
- `CURRENT_CONTEXT`=`NOT_MODIFIED`
- self-accept / acceptance commit / `main` update=`NOT_RUN`

本文件只是 B11 executed-result candidate。其作者不得接受自己的结果；发布后必须 STOP，等待 fresh independent ACCEPT/REJECT。
