# EliteSync v10.1.5｜Aggregate循环路径未证明｜Astra独立复审

日期：2026-10-24（Asia/Singapore）

**BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / AGGREGATE_CYCLE_PATH_NOT_PROVEN / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN / SDK_NOT_READY / PRODUCER_NOT_RUN / FORMAL_RESOLVE_NOT_RUN / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

## 1. 固定Git身份

- Codex候选Commit：0ef15686104e0260c3abb34071b8c731f577094a
- 唯一Parent：d0c1a00218ca68b92c6acf3338e292f956b023cf
- Root Tree：89e21c47f10451b63883ea68ea9e11fc62578dee
- 报告Blob：f843b20b3483cd7ab77c8150bf5717309c800880
- Manifest Blob：1bf3d2ebd04fde5c61df15ac777b96a62dc1494b

Astra直接读取候选Commit、报告、Manifest、compare及候选/Parent完整Tree。Compare为ahead1/behind0，只新增报告与Manifest两份docs。候选和Parent apps Tree均785822ca072943c5bfefa3ccc37ede01c2af5164、services Tree均1e1e20bb3500bedb1a521e5f2ddeece915d09424。main在本次复审开始时为531ec9c22f471fecd030380120551e4bd3bc8f73，Root 94df5664928cb6b82dee9bc830dd3adfd9a32d2e；产品仍为v10.1.4已接受apps 3468a3dd97da7accfda2539a0f8d8f68931a6110及services 0cb1f9d19659291a462488b3686fd0a07a6698ac。

## 2. D0-A诊断的准确含义

- 原始fixture-body.json与fixture-body.tmp均不存在，原aggregate对象图未保存。报告明确标记 ORIGINAL_AGGREGATE_OBJECT_NOT_PERSISTED。
- 唯一受限诊断约0.641秒完成，子进程exit31且已确认退出。诊断观察到8个非primitive节点、0个循环、0条目标PSParameterizedProperty边、3处未知类型截断；两个wrapper路径为started/finished，其immediateBaseObject为System.String。
- 该诊断只覆盖同源构造逻辑生成的最小合成子图，并且在started的_typeTable、started/finished的lockObject等位置有截断。没有证明原始37案例aggregate对象图无循环，也没有证明PSParameterizedProperty目标链路。监督器exit0仅代表受限诊断按预算结束；子进程exit31代表范围内未观察到循环，不是目标门PASS。
- 非作者逐边复核支持停止并指出共享引用不能自动判成循环，且不应扩大未知getter访问。Astra同意这一限制。

## 3. D0-B/C与后续门禁

Primitive投影未实施；定点aggregate正负例与完整37案例suite均未运行。新Sandbox、断网/精确Git/冻结HEAD、Flutter CLI、SDK READY均NOT_RUN；Producer 0/1、libs.jar未生成；正式resolve 0/1、Configuration.resolve()调用0、30项全部NOT_RUN。无宿主APK、设备、RTC/SFU、DB/API或main集成。

## 4. 保护与裁决

Codex本地保护回执报告21,999份具名原件、513条引用及五历史根保持。该范围只涵盖具名对象与选定只读来源，不代表全盘或活DB审计。旧stderr、失败aggregate、37案例目录、38份JSON与历史SDK迟到异常应继续保留。旧600秒截止与迟到PSInvalidCastException、Decimal保存回放、当前合成对象图分别属于不同证据，不能倒填同因。旧guest状态继续OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS。

**独立裁决：BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / AGGREGATE_CYCLE_PATH_NOT_PROVEN / WRITER_FIXTURE_NOT_PASS。** 本轮如实停止是正确的，但不能签Writer可靠性、SDK READY、Producer、30配置或v10.1.5产品接受。

## 5. 下一步收敛建议

下一任务先沿原fixture源代码静态追踪第95行aggregate body的每个字段、值来源、运行时类型及对象引用身份，重点查明PSParameterizedProperty如何可能进入第96行Serialize($body)。原始对象不存在时，必须保持该事实；可以用同源构造逻辑创建最小复现，但应逐字段核对实际类型并明确它只是重建样本。

不得继续扩大通用对象图遍历器、执行未知getter、调用ToString、运行JSON序列化来诊断，或将0个观察到的循环写成不存在循环。只有源级来源追踪或同源重建明确证明目标字段/对象链，才可设计primitive-only projection；否则标记SOURCE_PROVENANCE_INSUFFICIENT并停止，等待Owner决定是否改变证据要求。此阶段不允许定点aggregate测试、完整suite或Sandbox。

最终状态继续为OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED。
