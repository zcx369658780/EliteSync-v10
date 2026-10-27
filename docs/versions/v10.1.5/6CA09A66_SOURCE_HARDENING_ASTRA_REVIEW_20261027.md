# EliteSync v10.1.5｜6ca09a66 Owned Init + Observer 源码加固｜Astra独立验收

日期：2026-10-27（Asia/Singapore）

**正式裁决：`SOURCE_HARDENING_ACCEPTED_WITH_OBSERVATIONS`，范围严格为 `SOURCE_LEVEL_ONLY`。不接受Gradle发布图、Groovy运行、Windows实际API、AAR/POM、APP APK或整版v10.1.5成功。**

持续：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / GRAPH_NOT_PROVEN / DOKKA_TASK_SELECTED_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN / GATE2_NOT_AUTHORIZED / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。

## 1. 实时权威与GitHub直接核验

- 任务合同：`docs/versions/v10.1.5/V10_1_5_OWNED_INIT_SCOPE_AND_OBSERVER_FAIL_CLOSED_SOURCE_HARDENING_TASK_20261027.md`，Blob `ddcc4e7e74b4e2aeaf1651aa20f51a0749c7f28a`，已读取。前置Astra ba77有界只读验收Blob `7f864c7e17b81acccb24cf0655de6b3a911a66f9`，没有证明旧G唯一根因。
- 本轮 fresh GitHub main `b420db62bd6c86394333fad863bd15f2865f6fd7`、Root `5b50be9c0a17ce77f8759c1fd261bca08b4cb1cc`，已接受v10.1.4完整apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 实际源码Commit `71ab58533270dd8b3a1270a3452a82b4f426e361`，唯一Parent `ba77a3c840c36550a7ec3aa5a6475b69d874004f`，Root `275cd2664444532c759d688ba4b262576ad065a4`，apps `5af7a9d0042be19437616e969e260658b67e9353`、services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。
- 交付候选Commit `6ca09a66c0ef9619df7a3d7d4b089516f409954f`，唯一Parent为上述源码Commit，Root `3bf735ab1c8e394844db80be35d86d2250390c82`；完整递归Root 6650条、`truncated=false`。apps/services与源码Commit逐Tree身份一致。
- 直接GitHub compare：ba77→71ab恰好17个源码新增/修改路径，索引逐项path/mode/Blob核对17/17一致；71ab→6ca只追加安全报告和脱敏索引两文档，ahead=1/behind=0。报告Blob `ed802bb3a72d6e52e3fd926d4905b456e16bfd65`；证据索引Blob `8d5a379a351960b3cb391fd2fd074908872719ab`，均已读取。未发现候选服务Tree或产品main发生改动。

## 2. Astra直接读源码的修复结论

### A. owned Flutter init context

直接读 `context_guard.gradle` Blob `65835140b9b6fb1f824ab47537848bf6bec64b01`、嵌入后的 `aar_runtime.init.gradle` Blob `42e7d45840559fa0444f305d23203b78e7658787`、`owned_aar_init.py` Blob `c2b59d849a1388f88d889973c66e03c2a6e07c00`、Kotlin消费者 `build.gradle.kts` Blob `ec58832c88aa41d8ce005c9fe8b036ccf5bf3c3c`，并核对SOURCE.json与UPSTREAM.patch。

- 根构建检查显式scope `v10.1.5-ordinary-r1-runtime`、projectRoot/Flutter根、规范路径及无symlink/reparse、精确Gradle8.14+offline、`assembleAarRelease`、target/is-plugin/dart-defines/ABI/version、脚本来源和init顺序。tooling子构建必须有已校验root parent、相同init来源/顺序、精确canonical Flutter tooling路径、固定SDK文件SHA与无冲突的child属性。未知included/buildSrc/深层parent不因此放行。
- 对唯一可信tooling child发生早退，避免修改tooling工程本身的maven-publish；合法根继续原AAR发布body，保留两分支withSourcesJar以及已有出版、Flutter/plugin AAR路径；两处withJavadocJar仍移除。
- SOURCE schema2、上游及许可、patch、guard单独pin及Kotlin消费者引用得到更新；`ownedAarInitContract` schema2和7项REQUIRED_PROJECT_INPUTS拒绝旧输入库存。本次**没有验证真实Gradle脚本编译、Groovy initScriptHandle中的`initscript.sourceFile`属性是否运行可见、parent/currentDir在实际included-build中的取值、或完整Gradle发布图**。纯Python`authorize_context`只是声明了Gradle对象身份的政策镜像，不是Gradle测试。
- 直接源码范围未发现应否定这一**源级有界修复**的安全放宽；但真实根/child匹配与Groovy配置结果一律`RUNTIME_NOT_PROVEN`，历史scope失败单一归因仍`NOT_PROVEN`。

### B. observer + hardened runner

直接读 `windows_build_observer.py` Blob `e3be0bc3ce7189faf0bc58ec12782a913c7efe06` 与新增 `controlled_runner_hardened.py` Blob `0d8da8a44268c12e7593b13aa8c5b41337a3f2df` 及两份测试源。

- native DLL import改为实例构造时延迟；失败分支将OpenProcess、QueryFullProcessImageNameW、GetProcessTimes、空路径、未知creation identity和PID变动分开，读取失败后立即尽力取得错误码，构建有界LOCAL_ONLY失败事件。诊断sink要求必要字段、Hash、写入长度、flush；无法落盘时继续强停。
- 非loopback TCP、下载信号、unknown tool、路径不可读/漂移、root身份、Job关闭异常均仍保持fail-closed设计。原G runner/claim没有被修改。新runner `main()`立即抛 `NO_RUNTIME_AUTHORIZATION`，不能使用它运行G/A；旧A余额不可转移为新授权。
- observer/runner测试仅完全mock Windows native API、句柄、诊断日志、Job清理、预算及网络分类；没有真实Windows身份/时序证明。特别是将来的真实调用路径仍须再审核（如`initscript`实际属性、child Gradle parent身份、native错误时序、runner运行前日志sink绑定），本裁决不放行。
- 本轮readback中候选新runner与三个新测试源的工作树SHA与Git规范Blob SHA不同，索引已**分别记录**两组身份；不应将workingSha误称Git文件字节。最终候选Git path/mode/Blob身份直接核验成立。

## 3. 测试、预算及保护的证据等级

- Codex报告最终`140`项测试（37 owned byte/source、23 root/child policy model、44旧offline mock、15 observer mock、21 runner mock）exit0、0失败/0错误/0 skip；stdout SHA256 `227e9539add9179041e4b533a2e0993491a9980228d3116cf55323eae7cd522c`，stderr SHA256 `28dc8821bccf703bcdeae22ede7baf7d6456ccbc6f17bc278f0de75a718dac9b`。Astra直接读取部分相关测试定义，并未亲自运行本地Python。最终禁止API审计0是**Codex报告**；初始RED和一次ctypes DLL尝试被审计拦截的事实不被后者抹去。
- 私有完整stdout/stderr、105条LOCAL_ONLY原证索引、本地工作树干净、54个关键原证/五根/525 refs、旧partial与claim未改，都来自Codex本地报告；Astra未亲自登录Windows或再次核对LOCAL_ONLY。不能从具名抽查扩大为全盘保护或100453项库存全量复算。
- 历史完整APK预算1/1耗尽，新G预算1/1耗尽；旧A=0/1但G gate=false，Gate2未获新许可。没有本轮真实Gradle/Groovy/JVM/Flutter、AAR/POM、APK、设备/RTC、真实socket/network或系统软件安装卸载的Astra运行证据。
- 本次接受不改变原`AEC`、最后可闻波形、native handle、真实15/30天经过/物理30天清理、RTC SDK警告与真实Push provider未闭合事项。

## 4. 最终裁决与STOP

**`SOURCE_HARDENING_ACCEPTED_WITH_OBSERVATIONS / SOURCE_LEVEL_ONLY`**。接受：17个具名源文件与脱敏交付身份、严格源级scope允许/拒绝合同、出处pin/来源更新、observer诊断路径及符合冻结任务约束的失败保守处理。**不接受：**`PUBLISH_GRAPH_PASS`、`DOKKA_NOT_SELECTED`、`AAR_POM_RUNTIME_PASS`、`TCP_ROOT_CAUSE_FIXED`、`AC05_CLOSED`或v10.1.5整版接受。

后续最小建议：只有Owner**再独立批准新的受控运行预算、可信新库存、强停止进程监测与新的claim**，才可以考虑验证真实Gradle plugin-loader/root/child上下文及发布图。旧G预算或旧A剩余额度不得复活/转移；本轮**不自动发布**Gradle/G任务或外层APK构建，也不因尚缺运行证据重写原历史失败。

本审查仅在独立Astra**文档分支**归档及更新该分支ACTIVE_STATE；不修改产品main、不发布下一个Codex开发任务、不清理历史原证、不启动v10.1.6。停止等待Owner决定。
