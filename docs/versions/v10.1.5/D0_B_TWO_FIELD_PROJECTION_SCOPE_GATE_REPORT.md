# v10.1.5 D0-B 两字段范围与调用点 Gate 1 交付

**D0_B_GATE1_PASS / AWAITING_ASTRA_INDEPENDENT_REVIEW / TARGETED_FIXTURE_NOT_RUN**。

本任务仅完成静态Gate 1。非作者GPT-6.1 Sol/high实际读取原/新源码、最小diff并独立计算Hash，七项必需审查均PASS、无修改意见。新投影未编译、未加载或执行，未运行任何fixture；该结论不等于Writer运行PASS、SDK READY或产品接受。

## 权威与固定身份

- 专项任务Blob `38667356cb487acc4d8fc0994f894eabf3fb82e0`；原正式任务Blob `009a12cae75ef3b714f0156d4edbca2db1660719`；前置Astra复审 `7eae0044f8c1621a5e6fdf8a8f637462b1596385`；前次阻断交付Astra复核 `8f627cf0d442f935f756435d4d7d97890bcfdb71`。
- 开工实时main `b101bf9680b5b46eda3c66ed93780af1ee5bc9d5`、Root `3fd90baf39bddd4e87d1213af565bc0994be0ece`；ACTIVE_STATE Blob `02f973f674b0461a361332880a5aee09dda737a8`。main接受产品仍v10.1.4，完整apps/services Tree为 `3468a3dd97da7accfda2539a0f8d8f68931a6110` / `0cb1f9d19659291a462488b3686fd0a07a6698ac`。交付前后仍须fresh核验，不把开工SHA冒充永恒HEAD。
- 连续分支 `codex/v10.1.5-source-faithful-serializer-conditional-sdk` 的开工远端/本地HEAD均为 `a9bb54d78e357ce15bf673a654baa849e264a32f`，工作树干净。后继唯一Parent固定为该候选，Parent Root `fd3c38b1d5e8a11b2ae5f31f33a2d52437a8d7b0`。候选只新增本报告和Manifest，最终Commit/Root/两Blob/原字节另存提交后回执，避免文档自引用。
- 候选完整apps Tree `785822ca072943c5bfefa3ccc37ede01c2af5164`（1133条）、services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`（791条）保持；不集成main。

## 修订与真实调用链

历史C#草稿保持12489字节、SHA-256 `c6469958b98b50c9f6d4e07b2cbce3ac5987ced635306e3d6d612b6047353c83`，另存原字节快照；它没有既有加载入口，未被新链引用。按正式任务允许的原生路径，仅修订任务自有LOCAL_ONLY PowerShell副本。

审阅包中的 `revised/fixture.ps1:8` 沿用同目录dot-source加载 `receipt_writer.ps1`；第95行建立原有13字段body；第96行的唯一变更为 `Write-Aggregate $body`。原生Writer第127行定义该函数，第130行仅枚举完整路径 `$.started` 与 `$.finished`，对两者先验证存在、非null、String及String BaseObject，再复制字符构造String并放入强类型字典；第142–143行是唯一两个body setter，第144行将该body直接作为原 `New-ReceiptParser().Serialize($body)` 输入。无需C#编译链或新加载器。

其他11个字段及cases不被该投影遍历、转换或重新赋值。缺失/null/非String/意外基础类型在Serialize和文件发布之前抛出明确错误；没有随意ToString或READY/PASS伪造。这里证明的是源码调用链与类型合同，投影后的实际运行类型仍NOT_OBSERVED。

13字段构造整行原字节保持：runId、passed、expectedCount、actualCount、cases、started、finished、childElapsedSeconds、currentCase、failureType、failureCode、runtimeProcessesStarted、jobsStarted。fixture除了第96行调用外逐字节不变；原Writer前9326字节完整保持。schema、37案例计划、runID、expected/actual count、cases、已有receipt fallback、UTF-8、Hash读回与原子发布合同没有删减或放宽。新函数仅返回JSON给既有aggregate发布尾部，不宣称新增或验证了aggregate独立fallback。

| 文件 | 原SHA-256 | 新SHA-256 |
| --- | --- | --- |
| fixture.ps1 | `146d2e159dcac6bc773fffe4571d6ec5ec5729ad365e3e4118a2f4e4cea86c61` | `27d8f702ef8aa22219f462ac328d77cade2c65fc5f5cb4d9950776a60d5675d2` |
| receipt_writer.ps1 | `8930af018f129f00ac27cc141df5e7f662a77c2d88f5a61dd7ed9a330e74ba1a` | `4c1c9da462e07533f2db1d79bfeaf3acc1d88f2c8afd2147f7b68e2726aca4e4` |
| receipt-schema.json | `1d0f85833a30bac04e1647b4ba66e560794932872bed7d6bf9e091bb3edba652` | 同字节 |
| fixture-plan.json | `bc9f413fa6f612687762b6419217623e4b83818225080feebf6608b576f26b5e` | 同字节 |

## 非作者与公开审阅证据

非作者逐项PASS：两字段范围、其他字段不变、schema/必需字段/业务合同、Writer真实调用链、原生加载与类型边界、最小diff/无产品变更、最小公开包安全性。完整审阅见包内 `NON_AUTHOR_STATIC_REVIEW.json`，SHA-256 `7cdd870d1d8abeebfc5289cb1e58f0b1179854c27459b172c8e9120990128da0`；源码Hash逐项绑定。它是非作者静态复核，Astra仍需独立复审。

已普通创建短期分支 `review/temporary-evidence-v1015-d0-b-projection-scope-gate-20261024`，Commit `841555d5e9f3314098190198d89ab2044c9b2cd9`、Root `401bb07a553931dbeb5b19ac29b04039cf3af3dc`，唯一Parent `a9bb54d78e357ce15bf673a654baa849e264a32f`。公开仅11份必要源文件/原新diff/schema/plan/清单/说明/审阅结果，共68949字节；[固定审阅目录](https://github.com/zcx369658780/EliteSync-v10/tree/841555d5e9f3314098190198d89ab2044c9b2cd9/docs/_temporary_review/v1015-d0-b-projection-scope-gate-20261024)。11/11远端Git Blob及原字节与本地包相同；产品双Tree保持。逐文件路径、Blob、SHA-256与字节数见Manifest，不上传完整LOCAL_ONLY目录、C#旧稿、个人路径、PID、环境快照、控制文件或私密日志。fixture中的C盘Unicode字面量为原合成测试值。此分支不合main或产品分支；后续清理另行处理。

首次字节回读控制器误将连接器已解码内容当作原始Git Blob JSON解析，产生管理脚本提取错误，已原样留存说明；使用显式base64文件读取后11/11字节核对通过。该错误不是投影/Writer运行失败，没有重跑诊断或fixture。

## 预算、保护与停止

D0-A仍只有已消费的一次诊断：15次Serialize、约0.688秒、exit0且退出确认；本次重跑0、未重置预算。结论只涉及源同构最小重建，原37案例对象未恢复，历史PSInvalidCast根因仍UNKNOWN。

本次投影编译/执行、15秒定点fixture、完整37案例suite、Sandbox操作、Flutter/Gradle/Producer、libs.jar生成/验收、30项Configuration.resolve均为0 / NOT_RUN。后续门未授权，不因Gate1静态PASS或剩余预算而自动开放。

发布前具名保护22294/22294文件Hash保持（包含此前22227份及后续落盘证据），五历史根HEAD/branch/index/dirty及warning状态保持，516条现有refs发布前保持，原38份JSON保留。产品完整maps保持。正式候选ref的本次普通后继与新审阅ref是具名授权变化；其它旧refs不得改写。该检查仅覆盖具名资产和五历史根，不是全盘、系统配置或活DB审计。

保持 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。完成普通发布与回读后停止，等待Astra独立验收；不得放行Gate2或启动后继。
