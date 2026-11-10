# BE-01｜Messaging Consent 持久化边界映射候选

**结论：`NOT_READY`（可映射语义，尚不能派发代码）。** 本结果为 `docs-only` 作者候选，停在 Work LEVEL 2 独立审查。当前本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；`TASK_CURRENT.md` 将 BE-01 明确派发给本会话。Owner 要求先推进本地软件/后端，账号回填范围留待逐对象结构核对；此优先顺序不放行真实账号、生产 DB、备份恢复或迁移。历史路线图的 M2→M3 顺序以 `CURRENT.md` 的现时接受状态覆盖：R18-R1 Product Connection 开发态持久化/应用层已接受，APP-INT-01～05 本地主循环已接受，真实 auth/session、writer 和生产后端仍未建立。

## 可确定的边界

BA-05 的独立接受只建立 Messaging Consent 六态语义与 Product Conversation 的双输入 live gate，没有建立存储、schema、endpoint 或实现权限。`MessagingConsentConversationLiveGateEvaluator` 是纯求值器：MC 状态证据、转移证据和 CN 状态证据从调用方输入；它不能签发、读取或持久化真实权威。现有 `InMemoryLogicalPersistenceRepositoryContract` 仅声明 RR03、Canonical Match、Product Connection 三个记录族；`SqliteInMemoryLogicalPersistenceAdapter` 也仅显式保留这三个族的派生 payload。`PersistenceBoundaryApplicationInterfaceIntegrationContract` 的 submit、readback、revalidate 是可参考的**非授权关联边界**；投影读取结果明确 `projection_is_permission=false`，持久化结果不能替代源 authority。R18-R1 的 Product Connection adapter 及测试只证明 synthetic/dev-test Product Connection 的精确读回与负向门，不把 `CN_ACTIVE`、其 record family 或其来源升格为 `MC_ACTIVE`。

因此最小下一片应是**独立 MC 记录族的开发态设计与接受**，再实施来源携带的 MC 证据相关性记录和读回；不能将 MC 塞进 Product Connection family，不能把派生记录当作 MC writer。名称 `MESSAGING_CONSENT_STATE_TRANSITION_DERIVED_PROJECTION` 仅是待审候选，不是已接受常量。若业务要求持久化真正的 MC 权威事件/状态，须先另立并接受真实来源、写入者、事务与撤销协议；本次固定来源无此授权。

## 最小记录/投影映射（待独立设计接受）

| 层 | 必须保留的输入与身份 | 输出及硬门 |
|---|---|---|
| MC 来源证据 | MC consent identity；当前 Product Connection aggregate/context；恰两名相同参与者；用途 `CONVERSATION_LIVE_READ` 或 `CONVERSATION_LIVE_SEND`；requester 与不同的 recipient；来源 owner/scope、actor/role、audience、purpose、aggregate/lifecycle binding；MC **source-local** lineage/revision、condition、currentness、freshness、证据 identity | 只接受来源携带并精确绑定的证据；缺失、跨 Connection/参与者/用途、旧上下文、不新鲜或 `UNKNOWN` 均不可授予。CN 和 MC revision 各自独立，不能合成全局 revision。真实 MC 来源目前 `UNKNOWN`。 |
| 转移意图与结果相关性 | 不可变 intent identity、目标 consent identity、from/to、actor、当前 MC `expected_state_revision`、对应 CN 当前上下文、source transition identity；相同 identity 的同语义重试须 exact duplicate，改输入复用须拒绝 | `MC_NONE→MC_PENDING` 仅当前 `CN_ACTIVE` 的任一参与者请求；`MC_PENDING→MC_ACTIVE/MC_DECLINED` 仅绑定 recipient；`MC_PENDING→MC_WITHDRAWN` 仅绑定 requester；`MC_ACTIVE→MC_REVOKED` 可由任一绑定参与者。其他直接转移拒绝；传输超时只读对账，不推断成功或重放写入。 |
| 终态、修正与投影 | `MC_DECLINED/MC_WITHDRAWN/MC_REVOKED` 终结旧 consent identity；新尝试必须是新 consent context/request identity，从 `MC_NONE→MC_PENDING` 重走。correction/supersession/revocation 需指向精确 dependency/record identity | 旧 `MC_ACTIVE` 因较新 `MC_REVOKED` 或来源 correction/supersession 失效；不能按到达顺序取最后一条，也不能在旧 identity 上重开。重复同 revision 不同内容、不可比 lineage、乱序、重放均 `UNKNOWN` 或拒绝，不能由投影顺序裁决。 |
| 开发态持久化记录 | 独立 MC family、稳定 canonical logical record identity、源修订、不可变 intent、来源 carried outcome、纠错关系、投影元数据、transport observation；只存最小脱敏关联字段 | `store` 的 `STORED_NEW/EXACT_DUPLICATE` 只证明记录相关性，不证明同意已生效；changed-input reuse、同 revision 冲突、不可比记录须 fail closed。读回必须精确验证 family、身份、bindings、修订、源证据与 typed payload，不能借 Product Connection 的 52-key 结果或其终态规则。 |
| live-read / live-send | 每一维分别取当前有效 `CN_ACTIVE` 与同一 Connection/参与者/用途的当前有效 `MC_ACTIVE`；求值器分别输出 read/send，不把一维许可当另一维许可 | 当前有效权限是**两份独立来源证据在使用时重新核验的结果**，不是存储记录、投影或 transport 的属性。send 提交点再次核验独立 CN 与 MC 两输入；任一缺失、过期、撤销、冲突、不新鲜、历史 aggregate 或不匹配均禁止。live read 同样 fail closed，不据此裁定历史 Conversation 读取。 |

需要先接受的最小设计是：MC 新 family 的精确 typed payload/schema、来源权威与绑定字段、source-local revision 比较与同 revision 冲突规则、终态新 identity、intent/record 幂等身份、correction/supersession 与 invalidate 读回语义，以及 read/send 双用途证据如何分别映射到非权限投影。设计还须固定证据最小化和接口的真实授权来源缺口；不能用一个源缺失的 synthetic 记录伪装当前许可。现有代码只能作为这些规则的结构参照，不能自行推导为 BA-05 已接受的持久化合同。

## 后继最小代码任务：当前 `NOT_READY`，仅列可审范围

待上述 MC family 设计被 Work 独立接受后，才可另发一个**synthetic/dev-test only** 代码任务。拟允许源码精确路径：`services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`、`services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`、`services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`、拟新增 `services/backend-laravel/app/Domain/MessagingConsentPersistenceApplicationAdapter.php`；拟允许测试精确路径：`services/backend-laravel/tests/Unit/ProductConnectionPersistenceFamilyTest.php`、拟新增 `services/backend-laravel/tests/Unit/MessagingConsentPersistenceApplicationAdapterTest.php`。`MessagingConsentConversationLiveGateEvaluator.php` 及其既有 Unit test、Product Connection adapter/test 只作固定对照，设计未证明有改动必要时不列入写入范围。以上仅是下一张任务的路径建议，**不是本任务的写入授权**。

后继实现顺序应为：先在两个 repository 实现同一 MC family 的严格结构/幂等/修订/冲突/失效规则；再加一个只使用现有 evaluator 的 MC application adapter，把输入来源证据、派生结果、持久化 disposition 和精确读回分开；最后在现有 application boundary 核对来源携带结果与投影不授予权限。定向测试限新 MC adapter/repository family 及现有 Product Connection 回归；负向至少覆盖跨 Connection、参与者/用途不匹配、`CN_ACTIVE` 无 MC、`MC_ACTIVE` 无 CN、过期/不新鲜/缺失/`UNKNOWN`、同 revision 冲突、乱序、重放、changed-input identity、终态旧 identity 重开、较新撤销、correction/supersession、read 与 send 分离及 send 提交时复核。失败回退为保留前一已接受开发态边界、拒绝/标记 MC 为不可用，不生成许可或迁移旧记录；新 family 仅在独立测试和 Work LEVEL 2 差异审查接受后可被后继使用。不得顺手增加 endpoint、migration、生产 writer、真实账号读取或 Flutter 接线。

## 静态回执与停点

本任务本地静态核对 **2/2 轮**：第 1 轮读取根 `AGENTS.md`、`CURRENT.md` 当前入口、`TASK_CURRENT.md` 顶部、完整 `task.md` 与 branch/HEAD/工作区；第 2 轮仅读任务白名单中的 `PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地工作流技能、路线图、R18-R1 接受文档、BA-05 设计/接受文档、六个指定 Domain 源码、指定 Product Connection family test，以及两个“同名 Unit test”。第二轮对这些固定文件做了 SHA-256；未全仓搜索或扩展读取。源码/测试只作静态阅读，未执行。`plan.md` 写入前不存在；唯一新增交付为本文件，其他 staged、modified、untracked 内容保持原状。

关键来源 SHA-256：BE-01 `task.md` `BE0D01BFD818D5B7CFA3D53370A4F141FF2439F18F3E7C6D1BE40CED2F7E0240`；BA-05 设计 `F994508A671B3818F21B73436E3FC013A743B51CBA2148C636F5D005991BBACA`、接受文档 `1FC25267CFD9006FCF5FC005B960CE70F7FBFDE77A981CECB856F544EA34E859`；MC evaluator `BE2D2B4AC6B1100159368D7ACCAE89542E75466F74B2D254D4001204574168D3`、其 Unit test `19BC2F889AB75A4A5D4D55C2EACDB5CA59CE3A1A0A49B0EE5623502BCA7A553C`；逻辑 repository `0AC84101E0FEDBEDAE2ED537ED176A965AF778035B8DE14BEF139DD2848BC89B`、SQLite adapter `A4A8AEFCF594680BFAA5D1BB7BBC847C402EC3BE2FAE14692B92F325AD96C5F4`、application boundary `ABA6B0DE25403AF2B44D2E893233F55358519D1AA3D34A112761BB907C22659D`；Product Connection adapter `BA8AA1B49E5BD978383F1ABD89410FCBD8F784A833A1EFDF94404A39C8CE989E`、其 Unit test `830FC3690E2038975A03ADC71678456BFA6D6919790BA8DEA6C32DF5DC49A86D`、family test `7D83CBD4D726F91A4F176C1DBC80699E70AC58FC35D4F4683CD5B06C96B1D09E`。其余已读入口与历史排程的哈希可由 Work 在本地独立复核；本次不以哈希证明语义接受。

`NOT_RUN`：PHPUnit、Composer、Artisan、Docker、构建、SSH/云/生产 DB、UAC、真实备份/密文/私钥、解密、恢复、业务数据、Git 提交/pull/push。未访问旧 `D:\EliteSync`、GitHub、`.env` 或日志。旧 AUTH-152/153 预算没有重置。作者不自接受，也不派发代码实现；此候选停在 Work LEVEL 2 独立审查。
