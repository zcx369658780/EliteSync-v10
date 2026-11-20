# EliteSync V2｜阶段C集中独立顾问验收（2026-11-20）

状态：**PHASE_C_ADVISOR_PARTIAL / OWNER_FINAL_PENDING / PHASE_D_NOT_AUTHORIZED / NO_MAIN_MERGE_OR_RELEASE**  
审阅主体：网页GPT战略产品与阶段工程顾问；不代替本地Codex工程自验或Owner最终接受。

## 固定身份及证据分级

- 仓库：`zcx369658780/EliteSync-v10`。
- B完整固定安全基线：`1780f6add9a439c109f527eb7f58c2f96ab8bfa5`。
- C最终固定交付：`15b45a0068c65615dd600b314037965e31244584`；远端分支 `codex/v2-phase-c-data-rights-purpose-20261120` 在审阅时指向该提交。
- GitHub比较 B→C：**ahead 5 / behind 0**，B即merge-base，源码与测试在已接受A+B基础上增加。PHP测试源码 `a028cf7eb46bcc4967a41df8b86052920058b1f5` → 最终交付只增加本阶段工程报告，无后置源码更动。
- [Codex固定工程报告](https://github.com/zcx369658780/EliteSync-v10/blob/15b45a0068c65615dd600b314037965e31244584/docs/versions/v2/phase-c-20261120/PHASE_C_ENGINEERING_REPORT.md)已直接回读。
- 原Windows开发树/保护树dirty/index、隔离配置和原始日志为 **CODEX_REPORTED**，顾问不能直接核验本机Windows状态；GitHub源码、迁移、测试方法和固定差异为 **ADVISOR_SOURCE_SPOTCHECK**，并非顾问复跑或完整逐行代码审计。

## C1–C4逐项结论

| 部分 | 顾问结论 | 独立抽样验证 |
|---|---|---|
| C1 SOURCE/PURPOSE/AUDIENCE/SNAPSHOT | **PARTIAL** | `DataPurposeService`、`DataRightsController`、`TrustedIdentityService`、Flutter `DataPurposePage`：具名城市/本人本命→动态盘两个用途的独立测试许可、版本/到期/撤销拒绝、账户数据和展示/发布的分离已形成源码合同；真实合法依据无证，一般账号不可跨用途自动复用。不是全资料类别普遍法定许可证明。 |
| C2纠错/真实依赖/新发布 | **SCOPED_PASS** | `ShowcaseWorkflow`、`DataPurposeService`、`DynamicChartController`、`ToolRevisionController`：城市摘要和草稿版依赖、纠错后新发布拒绝、旧合法快照及撤销后字段屏蔽、晚到计算重查许可和来源；限已实现的具名依赖和私有工具，不把Mock算法称为核实。 |
| C3本人作品/评论对象级请求 | **PARTIAL** | `ObjectDataRequestService`、`DataRightsController`、Flutter对象页和PHP/Widget断言：本人对象权限、版本、同键、第三方评论隔离，真实账号返回`REQUEST_CHANNEL_UNAVAILABLE`；`REQUESTED/ACCEPTED/PROCESSING_TEST_ONLY`均限隔离试验，`completion_available=false`，无真实受理和完成承诺。 |
| C4失权/历史/安全回归 | **SCOPED_PASS** | 动态盘当前和历史读重新核用途、C1/C2/C3账号锁、UNKNOWN读后同键重试、A+B具名回归断言已有证据；设备和MariaDB并发时序NOT_RUN。 |

迁移抽样：`2026_11_20_120000_create_phase_c_data_rights.php`定义`data_purpose_grants`、`showcase_city_sources`、`object_data_requests`和私有出生时刻列，具有主体/用途或请求键约束；降级前核曾使用本人本命的动态当前及历史，必要时拒绝，并清除城市依赖的旧发布资格。SQLite隔离断言可见；MariaDB真实验证未发生。

抽查测试：`V2PhaseCDataRightsTest.php`、`V1011DynamicChartApiTest.php`及Flutter `phase_c_data_rights_page_test.dart`，实际有无许可409、跨主体404、纠错NEEDS_REVIEW、撤销后字段屏蔽、原键重查、仅测试受理、不删第三方评论、晚到结果阻断等正反断言。

## 测试、回归和重大保留

| 验证 | Codex报告 | 顾问独立程度 |
|---|---|---|
| PHP具名 | PASS 167项/2,140断言 | 测试文件与部分断言抽查；**未复跑** |
| Flutter具名 | PASS 243项 | Widget源码/断言抽查；**未复跑** |
| Dart静态分析 | 12改动文件/0问题 | **仅Codex运行报告**，非全仓 |
| PHP全量 | **FAIL** 1,496项、83 errors/131 failures、1 deprecation/4 skipped/3 risky | 报告与变更范围核对；原始JUnit逐例差异**未独立复算** |
| Flutter扩围 | **FAIL** 65通过/3失败 | 旧三项复现仅CODEX_REPORTED |
| Flutter全仓 | NOT_RUN | 不提升等级 |

B全量81 errors+108 failures=189；C全量83 errors+131 failures=214，新增**25**（2 errors+23 failures），不属于B原189条。Codex归因：
- `AstroCanonicalApiTest` 14 failures；
- `ProfileBasicRecomputeTest` 5 failures；
- `V1007BaziProvenanceTest` 3 failures+2 errors；
- `AuthPasswordApiTest` 1 failure。

**顾问独立验证到的关键回归事实：** C最终`AstroProfileController::save()`对旧排盘POST无条件返回409 `LEGAL_BASIS_UNVERIFIED`，原旧排盘写入自动计算不再提供；`ProfileController::saveBasic()`不再自动调用选修排盘，`AuthController::userPayload()`不再由旧衍生盘回填账号私有出生地。这是有意避免未经授权跨用途复用的可理解安全收紧，**也是对仍有旧测试与客户端依赖的功能行为变更**。不能因安全意图就将25项新增失败算作历史FAIL，也不能不经Owner产品取舍擅自删除旧能力/修改断言令全套绿灯。当前应视为实际兼容回归及未裁定的旧API产品合同。

保留：真实用途依据、对象删除法域/真实受理方/第三方及备份留存OPEN；PHP8.4、MariaDB真实迁移/回滚/并发、设备/模拟器与跨设备权利传播、真实KYC/Push/RTC均NOT_RUN。访客正式正文`public_editorial=[]`；原43PNG、F-01、旧1011804/UI-AUDIT-01仍沿用旧状态，不倒改。

## 顾问集中判定与下一步建议

**结论：`PHASE_C_ADVISOR_PARTIAL`。** 认可C1/C3的隔离技术合同进展和C2/C4具名安全保护的源码证据，但**不签发阶段C整体限定接受**，更不签发真实法律受理、生产准入或阶段D启动。25条新增回归必须具名处置。

建议在当前C范围内形成**一次合并的兼容收尾R1**，不恢复网页顾问微任务派单：
1. Codex保留安全失败关闭，按上述四组将25条分成“必须修复的旧客户端功能”“Owner拟明确退役的跨用途自动计算”“真实法律依据未确认所以必须阻断”三类，给出每组实际客户端入口、返回/提示、手填替代路径和不会泄露旧数据的验证。
2. 禁止恢复无权限的旧自动排盘/资料回填。可保留独立手填和已获当前用途授权的数据路径；如涉及既有核心功能退役，提交Owner一次性产品取舍，不通过改测试或隐藏失败自行批准。
3. R1集中交补充源码、变更、具名与全量对照（尤其25条），保留所有旧FAIL与NOT_RUN；有已证明安全的PHP8.4/MariaDB隔离环境才做相应定向补证，不要求接入外部真实系统。Owner可在R1集中验收后决定C是否关闭或接受仍有明确保留事项。
4. 原有本地交接`LOCAL_SYNC_DONE`仅为Codex可核实本机文件和SHA256的回执；GitHub `c0665772...` 的固定原文已由顾问读取，未直接访问Windows目录，故不写`ADVISOR_LOCAL_BYTES_VERIFIED`。

本结论不改变Owner已接受的阶段A/B具名范围，不改写旧FAIL/UNKNOWN/NOT_RUN，不授权阶段D、正式A6会议、生产及供应商、main集成或发布。  
**Owner最终接受：PENDING。**
