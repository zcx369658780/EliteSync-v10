# EliteSync v10.1.5｜SDK receipt writer fixture类型拒绝未捕获｜Astra独立复审

日期：2026-10-24（Asia/Singapore）。
裁决：**BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / RECEIPT_TYPE_REJECTION_UNDIAGNOSED / WRITER_RELIABILITY_NOT_PROVEN / SANDBOX_NOT_AUTHORIZED_TO_START / SDK_NOT_RUN / PRODUCER_NOT_RUN / FORMAL_RESOLVE_NOT_RUN / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

## 1. 固定Git对象、文档和产品边界

- Codex候选Commit `f3fbc2c58615095a9065afd11cc2369f7241343f`；Root Tree `07f5e2fd381f16862bdf43eef306b23096290042`；唯一Parent `a219fbb45edd0c746dce92af2f6abf661091bab4`。GitHub compare ahead1/behind0，只有两个新增docs：
  - `docs/versions/v10.1.5/SANDBOX_SDK_RECEIPT_CORRECTION_AND_CONDITIONAL_PRODUCER_REPORT.md` Blob `a13a2e18b8628a7d63e9595184d68438fbfb0546`；
  - `docs/versions/v10.1.5/sandbox_sdk_receipt_correction_and_conditional_producer_manifest.json` Blob `e3f72ccd6141dcb3031b8a3fe3883e6af9ae8856`。
- Astra直接读取报告、Manifest、候选Commit/compare，并读取候选与Parent完整Tree。apps Tree两者均`785822ca072943c5bfefa3ccc37ede01c2af5164`，services Tree均`1e1e20bb3500bedb1a521e5f2ddeece915d09424`；main产品仍v10.1.4 accepted apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`／services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，无产品改动。
- 前置任务Blob `8ec8ad6c1d76de7bd295101ffebe5e3ea69e15aa`；上次Astra review Blob `706ae77e7292ce104fcafc8ef0af18c72d0fb1f6`；本轮开始main `e2d8b1fa18fb9524a9c92bcf87b59547a36c3a02`／Root `778ad830858a5dd1d2363cc09e5f68321228ccfa`。Review与state docs更新可推进main，但不能改变产品acceptance。
- GitHub Git对象/文档是ASTRA_GITHUB_DIRECT；实际PowerShell fixture、脚本、时间和保护Hash是CODEX_REPORTED_LOCAL_ONLY。Astra未在Owner Windows环境运行该fixture，也没有原始PowerShell进程/输出可自行复算。

## 2. 本轮D0实测及准确解释

- 本轮唯一fixture suite **1/1，exit1**，终态`RECEIPT_TYPE_REJECTED`，定位在本轮receipt_writer.ps1第27行。**具体被拒的输入值类型没有捕获**，故`SPECIFIC_REJECTED_TYPE_UNKNOWN`，不能臆测为DateTime、PSCustomObject、数组、null或其他具体类型；历史PSInvalidCastException的根因也仍未知。
- 报告/Manifest显示仅生成三份`runId=fixture`合成正例JSON：framework identity、phase seed-copy、Unicode identity；没有aggregate fixture-result、没有可用failure receipt、没有完成负例覆盖或最终reconstruction outcome。三份正例存在只证明对应部分可写读，不证明完整writer或错误fallback可靠。
- Manifest进一步说明回放参数在进入Write-Receipt之前调用Copy-ReceiptValue；所以“没有failure JSON”本身不能证明fallback已经运行并失败。必须将**被拒类型未捕获**与**failure receipt未生成**分开，不可将二者合并成已定位的同一原因。
- 具体旧历史异常对象/扩展成员没有保存，本轮重建的fixture输入不能冒充历史原始对象。原历史PSInvalidCastException时间、600秒截止与约269秒后的迟到异常仍保留，不能用本轮fixture的RECEIPT_TYPE_REJECTED回填旧根因。
- 非作者只读复核给出两个重要缺口：其一，6秒Wait-Job不构成全套suite的hard deadline，Stop-Job/Receive-Job/Remove-Job收口也未被证明有界；其二，fallback失败回执缺少与正常回执同等级的UTF-8 JSON/schema/hash读回后原子发布；此外实际Flutter identity字段与深层对象类型正例覆盖不足。此次fixture退出1后没有修复或重跑，符合已消费预算即停止。
- D0未通过，所以本轮新Sandbox **0次**、Flutter CLI **0次**、producer **0/1**、真实libs.jar未生成、正式resolve **0/1**、15模块×2配置全部NOT_RUN。历史单仓safe.directory与冻结HEAD实际成功、上一Sandbox断网探针和Flutter DAG PASS都属于继承证据，不代替本轮writer可靠性门。

## 3. 保护及当前产品状态

- Codex有界本地保护回执：21,704份去重具名原件Hash未变，511条引用和五历史根保持；没有启动新Sandbox、改全局Git、改ACL、下载、强制结束进程、宿主APK、设备/RTC或main集成。数量只覆盖具名清单和已准备只读来源，不等于全盘或活DB审计。
- 终态真实且适当：`SDK_RECEIPT_WRITER_NOT_PROVEN / SDK_NOT_RUN / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN`。非作者复核不替代Astra独立审查，也不允许由三份正例文件推断整套writer通过。
- **独立裁决：`BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / RECEIPT_TYPE_REJECTION_UNDIAGNOSED / WRITER_RELIABILITY_NOT_PROVEN`**。认可诚实阻断交付，不签writer可靠性、SDK READY、Flutter CLI、producer、30配置或v10.1.5产品接受。

## 4. 下一步收敛建议

下一份任务不启动Sandbox、不执行Git/Flutter/Gradle、不重跑完整套旧fixture。只针对已固定的本轮新writer与fixture源，建立**明确捕获实际被拒类型的本地诊断**：在拒绝发生前先以不调用同一序列化器的方式记录字段名、输入的`GetType().FullName`（null单独处理）、是否数组/字典/标量、预期schema类型与失败阶段；只保存安全的类型元数据，不泄露实际私密值。先静态确认捕获语句不会再次进入相同ConvertTo-Json/Copy-ReceiptValue路径，再以一个定点负例验证能获得具体类型。若仍无法捕获，STOP并把确切未知点交Owner，不重复全suite。
 
在确切类型有证据后，再同一份新长任务中最小纠正输入归一化/receipt schema、使用不依赖复杂PS对象的失败回执fallback、修正全套suite的hard deadline（不能只给Wait-Job设timeout），对所有预期正/负例执行一次有界fixture；只有aggregate result、全部正例和负例、失败回执schema/Hash/原子落盘、整个执行/收口上限都实际PASS，才允许考虑新的单次Sandbox。任何未通过仍停在LOCAL_ONLY。**不得因为下一次类型诊断通过就自动启动Sandbox，必须等完整writer fixture全PASS与非作者前置复核。**

最终继续保持`OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。
