# EliteSync v10｜当前证据与契约索引｜v0.1

维护修订：2026-09-21 / delivery-refresh-2。`INDEX REVISION CANDIDATE — NO NEW DOMAIN CONTRACT`。
当前事实 ref：`608c6b04dc17022db7fcf72c34b494a0944ece03`。除另注均使用此 ref；A/=`docs/architecture/`，D/=`services/backend-laravel/app/Domain/`，T/=`services/backend-laravel/tests/Unit/`。

## 1. 使用方式与证据等级

先找当前实际消费者，再展开精确 path/ref/blob；索引不替代原文，不授予整表读取、扫描或运行权限。新 Product Connection 实现优先消费 R17-R3 自包含契约及其接受记录，不重复拼装历史拒绝链。

DIRECT-DOC：本轮重读的文档；PRIOR-LEDGER：既有接受／拒绝文档中的固定技术 ledger，本轮未重跑；HISTORICAL：先前上下文／交接报告，本轮未重审完整实现。main 归属、作者报告、独立接受、实际测试、执行授权分别记录。

## 2. 当前活动与直接控制来源

| ID | 精确路径 | Blob | 状态／用途 |
|---|---|---|---|
| AGENTS | `AGENTS.md` | `c9a8e192f7647a1613a195655fe9c22c56502ddb` | DIRECT-DOC；本轮不修改 |
| PLAN-ACCEPT | `A/ELITESYNC_V10_PLANNING_OPTIMIZATION_INDEPENDENT_REVIEW_V0_1.md` | `4d7164e157cd9c0e1274af51661bd0857de05f91` | DIRECT-DOC；上一六文件计划包已接受，原文 PROPOSED 不是未接受证据 |
| PC-MAPPING | `A/ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_RESULT_V0_1.md` | `813817fdfe4a67c2835021ca64d74d4ed41acc03` | 自包含消费契约，接受关系见下一项 |
| PC-MAPPING-A | `A/ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_ACCEPTANCE_V0_1.md` | `2b1f23520912517f0e3ae6735208253fbfa37b4f` | DIRECT-DOC；mapping、IP-13E sufficient、Package A 已接受 |
| PC-REPAIR-A | `A/ELITESYNC_V10_IP_13I_R17_R2_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_EVALUATOR_REPAIR_ACCEPTANCE_V0_1.md` | `acfedada11c3c6e76b83f9674142168245db9c0f` | DIRECT-DOC；修复后 evaluator 及测试接受 |
| PC-R18-REJECT | `A/ELITESYNC_V10_IP_13I_R18_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md` | `26bcbaf64953159c0ea53c5e9be78e817e2192c9` | DIRECT-DOC；绑定键序 defect 和 first-pass 偏离；未集成 |
| PC-R18R1-T | `A/ELITESYNC_V10_NEXT_IP_13I_R18_R1_PRODUCT_CONNECTION_APPLICATION_BINDING_ORDER_CORRECTION_TASK_V0_1.md` | `b28397028f8795149886b7c8ecb9ddb51a691b86` | DIRECT-DOC；当前代码任务，Owner 报告未执行 |

R18-R1 的六路径及首次 PASS 停止规则不因新计划变化。若本次文档集成使 main 前进，只按精确 dispatch 的首次基线重发启动；不是在途特例。

## 3. 被拒 R18 的可复用材料，不是已接受源码

下表所有对象只在 ref `64dd8f8dccbbb3582656f98a70b1e36c6449fe0b`；当前 main 不包含该候选。来源级别为 PC-R18-REJECT / PC-R18R1-T 的 PRIOR-LEDGER。

| 路径 | Blob | R18-R1 处置 |
|---|---|---|
| `D/InMemoryLogicalPersistenceRepositoryContract.php` | `6178bc7290a9e542a39155756c9dd9e43d9eb0b2` | 精确原样 materialize，未整体接受 |
| `D/SqliteInMemoryLogicalPersistenceAdapter.php` | `678881a6c5868170270f4a400351966dd2e69a95` | 同上 |
| `T/ProductConnectionPersistenceFamilyTest.php` | `e4e6b946e5bace72da0bf36db6fd49caa328d00f` | 同上；不得称为本轮新测 |
| `D/ProductConnectionPersistenceApplicationAdapter.php` | `824f6950a0358d13675fb6cc79ce6c9eeaf45434` | 修正逐键 binding 比较 |
| `T/ProductConnectionPersistenceApplicationAdapterTest.php` | `b1680ef749a7e30b7d696988809360c86ee51171` | 增补键序不变／真实字段差异回归 |
| `A/ELITESYNC_V10_IP_13I_R18_PRODUCT_CONNECTION_PERSISTENCE_APPLICATION_IMPLEMENTATION_RESULT_V0_1.md` | `31523004ffd8d7d8511bcd667bcdea8d78cc5cd5` | 历史执行回执；不得复制为接受结果 |

拒绝候选不能成为 correction 的 accepted ancestor。Phase-A 复用不要求重新设计，但最终组合回归及 correction 独立 review 仍必需。

## 4. 当前 accepted main 的技术 ledger

下列来自既有接受／任务记录，未来实际消费者须再次在其执行 base 验证；本轮不宣称重新审查源码或运行。

| 对象 | 路径 | 当前 main blob |
|---|---|---|
| repaired evaluator | `D/ProductConnectionStateTransitionEvaluator.php` | `a2a2fefe2178834aa5051200cf2d1ecc3d4ea885` |
| evaluator test | `T/ProductConnectionStateTransitionEvaluatorTest.php` | `c68f82adf44af65ca80e51d7fc73bf1522b81980` |
| Common Authority | `D/CommonAuthorityEvidenceContract.php` | `e98e7db731d41269a7b89e01db12e1a81364751d` |
| IP-13A，尚无 Connection family | `D/InMemoryLogicalPersistenceRepositoryContract.php` | `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f` |
| IP-13D，尚无 Connection payload retention | `D/SqliteInMemoryLogicalPersistenceAdapter.php` | `640fb4a6cd0269d8eb55f218a2fc8ce823014f7c` |
| IP-13E | `D/PersistenceBoundaryApplicationInterfaceIntegrationContract.php` | `aa9721dfa66fe17eb2314bc9466870d479c07644` |
| Canonical Match adapter | `D/CanonicalMatchPersistenceApplicationAdapter.php` | `789e8905b2c9ee54d902d8b600100896af4f6063` |
| Match adapter test | `T/CanonicalMatchPersistenceApplicationAdapterTest.php` | `c8298f5e786a47d118b56f47cef6baab7f543b60` |

IP-13F 历史 blob `e70f260de92a0047e70b54827f4795edb3b74e00`，unchanged/non-participating；本索引未定位其 exact path，不虚构读取授权。

## 5. 产品、客户端与既有切片

| 来源 | 路径／固定身份 | 证据限制 |
|---|---|---|
| 产品设计 | `A/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_SUPPLEMENT_V0_1.md`；`b72ed9ec851d44aba7be65883186cb275fab22d1` | HISTORICAL；15-domain 产品目标，不是 evaluator exact schema |
| Owner acceptance | `A/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md`；`063dc18309afdc8f477cc9b22a29da1842776556` | HISTORICAL；产品边界保留 |
| 原 APP 路线 | `A/ELITESYNC_V10_NEW_VERSION_APP_IMPLEMENTATION_ROADMAP_BASELINE_V0_1.md`；`20863c434c7f6a06d76ba2ebdfee7ea1068fd711` | 历史范围，不再命令 APP-T01 下一步 |
| APP-T12 | `A/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md`；`4c00def5a94a117c8d9812996baf193de4a4aeb1` | DIRECT-DOC §§1–3、gaps/§8；静态矩阵、Flutter test/analyze/runtime 未建立；完整接受链未重审 |
| 9/21 handoff | `A/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_2026_09_21_V0_1.md`；`ed36cab735c57f57d516400cf549dec2a1bae8db` | HISTORICAL；不作实时执行入口 |

Runtime Readiness：历史 acceptance commit `be27354ec6d8de894b37fba31c4586efa298f94a`、acceptance blob `efa900a6351d98adbe5fe9fce2d846004296b4a9`、result `b388d349c9fe77714b2f1fb1e6fd69d9f6b4ebad`，报告 synthetic 至 HTTP。
Canonical Match：历史 acceptance commit `d09edcea6730d5d4cea87e90b38e9938f05bbeea`、acceptance blob `1b40415cb7e7362cc0696e43a4d5e7868f2683b3`、result `d081cdfc1218aa225639fb9495d19b419b4d0446`，报告 synthetic 至 HTTP。
这两条是旧 handoff/index 转述，未在本轮重新定位全部 source path；未来消费时定点展开，不为补图表遍历仓库，不将通过数当本轮新测试。

## 6. 历史纠正链：按具体疑点展开

R15-R1 result/acceptance：`A/ELITESYNC_V10_IP_13I_R15_R1_PRODUCT_CONNECTION_REASON_BOUNDARY_CORRECTION_REVIEW_RESULT_V0_1.md` / `fb064b7e290916ba7aa42d53990c9c54d289f5ba`；同名 `..._ACCEPTANCE_V0_1.md` / `7424e368a31edcd3e8ccc7d37133d6f4b321ebc3`。
R16-R1 result：`A/ELITESYNC_V10_IP_13I_R16_R1_PRODUCT_CONNECTION_DEPENDENCY_PRESENCE_CROSS_FIELD_VALIDATION_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md` / `f0da912cb3dcb1525fa36053168310f187cf58cb`；同名 `..._ACCEPTANCE_V0_1.md` / `96110d9484897012c7946b42a2256951ec8a60fc`。

原 R16 仅 ref `5494bf6835134ef1af69d5ebe32aa28ef62fc92e`、路径 `A/ELITESYNC_V10_IP_13I_R16_PRODUCT_CONNECTION_RECORD_PROJECTION_CONTRACT_REVIEW_RESULT_V0_1.md`、blob `aee15cf45c75c5a8f1733f5604803fc3ee766b4b`。仅 R16-R1 §16 / acceptance §7 保留的部分有效：原 §§4–7、11–15、17–22 限于不冲突内容；原 §§9–10 增加 binding boolean；原 §8、§16 及不完整 presence/context 组合服从纠正矩阵。原候选整体仍 rejected。

原 R17 task 仅 ref `b0196202c78f688723600ac9919cf96463908375`、路径 `A/ELITESYNC_V10_NEXT_IP_13I_R17_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_TASK_V0_1.md`、blob `68d18d4100ba24b493fd2b5ee9388f564aca9100`；旧 result 仅 ref `6af50b3cdf82ac8bc285bd160f773b48b29f1328`、路径 `A/ELITESYNC_V10_IP_13I_R17_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_RESULT_V0_1.md`、blob `14d92368dbb6a3e7ab2ed6c0cbcf4b149f831ac8`，保持 rejected。其拒绝记录 `A/ELITESYNC_V10_IP_13I_R17_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md` / `415ee64eb70894eed21eee97e58762307d6e408f` 不被新接受追改。

R17-R1 policy result/acceptance：`A/ELITESYNC_V10_IP_13I_R17_R1_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_CORRECTION_REVIEW_RESULT_V0_1.md` / `3918eac68121c6d3a7601ac703e5b1663fe9c054`；同名 `..._ACCEPTANCE_V0_1.md` / `cb44607f773705c168f15ca093935be1893259b7`。使用这些简写前，task author 必须展开全路径；简写不授权猜测或扫描。

## 7. 未关闭缺口及外部报告

G-02/G-03/G-05/G-06/G-08/G-13 = separate backend authority；G-07 = legal/data-rights；G-04/G-09 = retained UNKNOWN；G-10 = Phase 2；G-11 = compatibility debt；G-12 = tooling/evidence。synthetic HTTP／派生持久化不关闭真实 writer/auth/data gaps。

D02/U-12/U-14/TP/PUI、旧工具链及所有 no-processing 细节见当前入口；不解除 README/FD02/旧仓库限制。没有当前平台安装／启动完整证据，不能断言全局无 artifact，也不能宣布可运行 App 完成。

Owner 提供外部评估文件 `EliteSync_v10_Delivery_Process_Optimization_Report_20260921.md`，SHA-256 `387d875de016154cd40c8e4fecf33eb2c3c6f14781b6d883b1e1e690704027fb`。它是流程建议，不作为代码／产品接受；不全文复制入库，不围绕它建立额外审计链。其工时数据不足的限制保留；本路线新增的比例／日期均是明示假设而非该报告实测结论。
