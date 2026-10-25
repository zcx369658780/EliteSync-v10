# v10.1.5 D0-C Aggregate Failure Fallback 静态接线交付

**D0_C_FALLBACK_WIRING_STATIC_PASS / AWAITING_ASTRA_INDEPENDENT_REVIEW / GATE2_NOT_RUN**。

只在任务自有LOCAL_ONLY副本修改Writer的Serializer错误处理。非作者GPT-6.1 Sol/high读取准确原/新源码、最小diff、schema/plan及脱敏包，七项静态复核均PASS。没有运行任何PowerShell源文件、加载或执行Writer、调用Serializer或进行fixture；静态结论不代表有效failure receipt已实际生成、异常传播/原子IO已运行验证或产品已接受。

## 权威与连续身份

专项任务Blob `99862cba631dbb5569049bb7f71c7632e195bfa0`；原综合任务Blob `009a12cae75ef3b714f0156d4edbca2db1660719`；Gate1 Astra复核Blob `d377b19756eebeaf4f01c3f69d6fd2326ed89780`；Gate2启动前阻断复核Blob `b4e640323bf73985872dcb95ff9cc6f00d691e0d`。开工live main `f4f1227be892292a10e6490b866d49f8501d18d9`、Root `5f68df5a1816a2a09a753a8a14601b4b38e97b2f`，ACTIVE_STATE Blob `4e7c4a76957ae21b2a652eccbb50f5198367a84c`。main接受产品仍v10.1.4，apps/services Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac`。

连续候选分支 `codex/v10.1.5-source-faithful-serializer-conditional-sdk` 开工远端与本地HEAD均 `5dabe5de0a3a7f37ae0aa4e9a0ccf3e250b64298`，工作树干净。本次后继唯一Parent为该Commit、Parent Root `260d7d0ef1586016105c7c9509089bd6c6956d94`。仅新增本报告和Manifest；最终Commit/Root/两Blob及原字节由提交后独立回执固定，避免自引用。候选apps Tree `785822ca072943c5bfefa3ccc37ede01c2af5164`（1133条）与services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`（791条）保持，不集成main。

## 最小diff与真实失败链

唯一源码变化是将Writer原Serialize语句包入try/catch，原两字段投影和类型拒绝部分逐字节保持。fixture、schema、37案例plan逐字节保持；原有正常Receipt、独立fallback及原子发布函数均未改。

调用链是 `revised/fixture.ps1:8` 同目录dot-source → 第95行原13字段body → 第96行真实 `Write-Aggregate` → `revised/receipt_writer.ps1:145` 原 `New-ReceiptParser().Serialize($body)` → 第146–151行实际catch及既有 `Write-IndependentFailure 'fixture-body.json'` → 第96–105行独立JSON失败构造 → 第82–95行既有 `Write-AtomicReceiptJson`。不是harness补造。

catch先保存原aggregate错误，将字段元数据设为根`$`、输入类型设为实际aggregate字典类型，异常类型取原错误。fallback沿用现有control.runId、status=RECEIPT_SERIALIZATION_FAILURE、ready=false和最小元数据Hash。fixture第7行将control.runId绑定RunId，第95行body也使用同一RunId。现有配置outputRoot不变。原子发布函数只对独立failure JSON执行DeserializeObject/schema及Run ID/元数据Hash校验、严格UTF-8、读回Hash、同目录Move、发布后Hash；不调用aggregate Serialize、Write-Aggregate或相同body的Write-Receipt。

fallback成功后第158行bare throw仍重抛原aggregate错误；fallback自身失败则第155行抛出AggregateException，InnerExceptions按原aggregate异常、fallback异常排序。两条失败路径均不吞掉异常、不返回空aggregate或成功、不设置READY/PASS。此为静态错误合同，不是双错或发布运行实测。

范围边界：既有两字段投影/类型拒绝在新增try之前，保持原语义；不宣称这些投影拒绝也已接入fallback。本任务仅闭合实际Serializer异常路径。其他11字段、cases、13字段构造及业务合同不变。历史C#草稿、Gate1接受及Gate2原阻断证据保留。

| 文件 | 接受基线SHA-256 | 本次SHA-256 |
| --- | --- | --- |
| receipt_writer.ps1 | `4c1c9da462e07533f2db1d79bfeaf3acc1d88f2c8afd2147f7b68e2726aca4e4` | `9b494ac7e45b4a27dfaaef73b48bb6c9b60d25dc6521c32a968b80f5e3297512` |
| fixture.ps1 | `27d8f702ef8aa22219f462ac328d77cade2c65fc5f5cb4d9950776a60d5675d2` | 同字节 |
| receipt-schema.json | `1d0f85833a30bac04e1647b4ba66e560794932872bed7d6bf9e091bb3edba652` | 同字节 |
| fixture-plan.json | `bc9f413fa6f612687762b6419217623e4b83818225080feebf6608b576f26b5e` | 同字节 |

最小diff SHA-256 `a5708b3990a53d16661841b499c1d0b3d4c5b4baa89005e2e13b9694ad6249d6`；非作者完整审查SHA-256 `4b0b0af547f7204a69494ce358dea1a5a4e2654f68c8ab29bda90341409b3099`。七项结论、源Hash与精确行号见Manifest和审阅包，Astra仍需独立复核。

## 脱敏证据与回读

独立短期分支 `review/temporary-evidence-v1015-d0-c-fallback-wiring-static-20261025` 已普通创建，Commit `5bd6963ef58cd91401cd980bcb2775412cf70b7e`、Root `3d8062fb8e33e5d886d0c11d611017e58232d890`、唯一Parent `5dabe5de0a3a7f37ae0aa4e9a0ccf3e250b64298`。[固定审阅目录](https://github.com/zcx369658780/EliteSync-v10/tree/5bd6963ef58cd91401cd980bcb2775412cf70b7e/docs/_temporary_review/v1015-d0-c-fallback-wiring-static-20261025)仅10份必要材料，共58283字节：原/新Writer、未改fixture/schema/plan、diff、静态证据、Hash清单、说明和非作者结论。10/10文件Git Blob及原字节远端回读一致；产品双Tree保持。逐文件Blob/Hash/字节数见Manifest。

未上传个人绝对路径、凭据、真实PID、环境快照、私密日志、控制文件、运行输出或整个LOCAL_ONLY目录。历史fixture中的C盘Unicode字面量为合成测试值。审阅分支不合main或产品分支，清理另行授权。

## 保护、预算与停止

发布前22369/22369份具名保护文件Hash、五历史根HEAD/branch/index/dirty及warning、516条现有refs和原38份JSON保持，候选完整产品maps不变。该核验仅覆盖具名资产和五历史根，不是全盘、系统配置或活DB审计。正式候选ref的普通后继和本任务新审阅ref为具名授权变化，其它旧refs不得改写。

D0-A仍只含既有一次诊断、15次Serialize、约0.688秒、exit0且退出确认，未重跑或重置预算。Gate2为0次、15秒预算未消费。新Writer编译/加载/执行、定点正负例、37suite、Sandbox、Flutter/Gradle/Producer、libs.jar生成/验收和30项Configuration.resolve全部0 / NOT_RUN。原37案例对象未恢复，历史PSInvalidCast根因UNKNOWN。

保持 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。普通发布及回读完成即停止等待Astra；即使本次静态PASS，也不恢复Gate2。Gate2必须先经Astra独立复核本修复，再由Owner另行明确放行。
