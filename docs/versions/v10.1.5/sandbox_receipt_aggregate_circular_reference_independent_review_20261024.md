# EliteSync v10.1.5｜Writer类型捕获成功、完整fixture因aggregate循环引用失败｜Astra独立复审

日期：2026-10-24（Asia/Singapore）

**BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / AGGREGATE_SERIALIZATION_CIRCULAR_REFERENCE_OBSERVED / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN / SDK_NOT_READY / PRODUCER_NOT_RUN / FORMAL_RESOLVE_NOT_RUN / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

## 1. 固定Git对象与产品树

- Codex候选Commit `d0c1a00218ca68b92c6acf3338e292f956b023cf`，Root Tree `7fa7fc58b6b6ef3e6939f6111f6f23607b195f59`，唯一Parent `f3fbc2c58615095a9065afd11cc2369f7241343f`。GitHub compare ahead1/behind0，仅新增：
  - `docs/versions/v10.1.5/SANDBOX_SDK_RECEIPT_TYPE_CAPTURE_AND_CONDITIONAL_PRODUCER_REPORT.md` Blob `eeaa8f1a1b00241f9107742a3f6f2e089cbb3753`；
  - `docs/versions/v10.1.5/sandbox_sdk_receipt_type_capture_and_conditional_producer_manifest.json` Blob `f44b9d344ce99710aa8b87063329dc6800b19a7f`。
- Astra直接读取候选Commit、报告、Manifest与compare，并直接比较完整apps/services Tree。候选与唯一Parent apps Tree均`785822ca072943c5bfefa3ccc37ede01c2af5164`、services Tree均`1e1e20bb3500bedb1a521e5f2ddeece915d09424`。main开始时Commit `3614bb386b6f1e2237e8d884c7d469ce29f0e0c1`、Root `02f250a7fb4587314ee71bd1daa773826ed68af9`，产品apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`仍为v10.1.4接受对象。本轮无产品源码变化。
- 本轮正确的更正任务Blob `a0918a566bd88e47a630010757f27d9fdc970996`，正确前置Astra复审Blob `5a7d78eb4daf94ad553c51bfe9aee424f343bb8d`；原任务错误Blob `75f63bb7...`未被采用。Astra读取GitHub固定文档属`ASTRA_GITHUB_DIRECT`；本地PowerShell/fixture与保护Hash属`CODEX_REPORTED_LOCAL_ONLY`，非作者只读复核独立记录。

## 2. D0-A：当前保存回放类型捕获成功

- 一次定点类型捕获：**1/1、0.5秒、子进程退出确认、未超过15秒**；保存的dart-version.result JSON中`$.seconds`实测为`System.Decimal` scalar，而schema预期有限JSON数值；原native来源是`Stopwatch.Elapsed.TotalSeconds`（Double）。拒绝发生在`Copy-ReceiptValue`，早于`Write-Receipt`，异常为`System.Management.Automation.RuntimeException`。
- 这是本轮用**已保存回放JSON**观察到的类型，不是重新运行Dart或历史现场对象快照。最小writer修正保留Decimal数值分支，避免任意对象转String；本轮没有证据证明历史15:18:08 PSInvalidCastException的具体输入类型/完整延迟根因。
- 任务副本补了显式schema、实际SDK identity字段、独立primitive failure encoding、UTF8/schema/hash读回后原子发布与有界runner。修改均LOCAL_ONLY，失败源和旧证未覆写。

## 3. D0-B：唯一完整Writer suite失败，终态不变

- 本轮完整suite**1/1、exit1、约1.187秒**，低于60秒预算，fixture案例子进程已确认退出；未使用Job链、未执行Git/Flutter/Gradle/native产品命令。
- 首个可见终止错误出现在`fixture.ps1:96`的`(New-ReceiptParser).Serialize($body)`：序列化`System.Management.Automation.PSParameterizedProperty`时检测到循环引用，异常`InvalidOperationException`。原始stderr保留；没有捕获完整InnerException对象，具体导致循环的字段/对象来源仍UNKNOWN。
- `fixture-body.json`没有写出。独立controller failure aggregate有效，`passed=false`、`expectedCount=37`、`actualCount=0`、`checks=[]`、`processExitConfirmed=true`。这里`actualCount=0`代表缺少body导致controller无法验证逐案例结果，**不代表实际执行0案例，也不代表37案例全失败或除aggregate外全部通过**。
- 可见37个案例目录、38份同一run JSON（其中20份failure JSON）仅证明这些文件存在；不能将artifact presence等同case PASS。因`fixture-body.json`未落盘，控制器无法确认所有逐例结果，且无法排除更早的案例断言失败。故本轮完整Writer suite仍为`WRITER_FIXTURE_FAILED`，不能宣告`WRITER_RELIABILITY_PASS`。
- 未修复、未重跑；没有新Sandbox、Flutter CLI、SDK READY、producer、libs.jar或正式解析。Producer 0/1、`Configuration.resolve()`0调用、30项全部NOT_RUN。旧Git trust/冻结HEAD、旧Sandbox断网和旧DAG属于继承证据，不能代替本轮Writer门。

## 4. 保护与审查证据层次

- Codex报告普通non-force发布、固定Commit/Parent/Root/两Blob与原文字节、完整产品双Tree回读通过。保护回执报告**21,820份具名原件**未漂移、512条引用与五历史根保持；这只覆盖具名原件和选定只读来源，不等于全盘或活数据库审计。
- 类型捕获发生在本轮完整环境快照之前；环境快照报告覆盖suite前与失败后，不能夸大成覆盖整个D0起始时刻。原网络解析结构相同，但回执stateHash和raw文件Hash不同，必须分别保留。无系统网络/全局Git/ACL/owner修改、下载、强制结束进程或历史清理。
- 非作者GPT-6.1 Sol/high只读复核支持如实交付停止，未执行fixture或SDK；Astra独立review只直接核GitHub公开文档/对象。两者不可冒称运行时复验。

## 5. Astra裁决与下一步约束

**`BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / AGGREGATE_SERIALIZATION_CIRCULAR_REFERENCE_OBSERVED / WRITER_FIXTURE_NOT_PASS`**。本轮D0-A的`$.seconds: System.Decimal`捕获有效，但D0-B没有整套成功，不能启动Sandbox。

下一份任务应收敛到**聚合器序列化对象图**，不要重新修Decimal、Git trust、GPU缓存、DAG或历史SDK600秒根因：
1. 在新任务独立副本只读解析`fixture.ps1:96`前的实际`$body`构造、`New-ReceiptParser().Serialize($body)`输入与聚合对象来源；保留现有原始stderr、38 JSON、37目录和failure aggregate。
2. 用不调用同一序列化器的有界只读对象图诊断，定位`PSParameterizedProperty`的确切字段路径/父对象链，检测循环引用；仅记录类型、字段路径、对象引用ID和循环闭环，不记录敏感值。若真实对象图未保存，使用与实际构造同源的合成最小重建并明确其证据等级，不声称历史对象原件被复现。
3. 最小纠正应在序列化前将聚合body投影为有界、无引用循环的primitive-only schema（有限string/number/boolean/null/arrays/dictionaries），禁止将`PSParameterizedProperty`、ScriptProperty、ErrorRecord、Job或任意PowerShell运行时对象直接交给JSON serializer；用对象身份集检测循环，遇未知对象走明确失败路径而不是递归无限。
4. 只允许一次定点aggregate正例/负例fixture（15秒），验证聚合body序列化、UTF8/schema/hash读回、原子落盘与独立failure fallback。成功后才允许一次全套37案例suite（60秒总硬限，必须有真实aggregate且37项实际结果可读）；若定点诊断或完整suite任一失败立即STOP，不启动Sandbox、不重跑失败suite。只有全suite PASS并经一次非作者前置审查才可进入后续一次Sandbox/SDK/Producer/30配置门。
5. 历史15:13:39截止与15:18:08迟到异常、本轮Decimal类型捕获与aggregate循环引用分别记录；不宣称同因。任何本轮Writer PASS也不自动等于SDK READY、ICE诊断或AC05接受。

最终状态继续`OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`。
