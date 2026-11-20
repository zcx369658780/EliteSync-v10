# EliteSync V2｜阶段B B1–B4工程交付：网页顾问限定验收（2026-11-20）

治理分支：`governance/home-matching-product-freeze-20261117`  
Owner授权：[阶段A限定终验与阶段B启动](../decisions/OWNER_V2_PHASE_A_FINAL_SCOPED_ACCEPTANCE_AND_PHASE_B_ENGINEERING_AUTHORIZATION_20261120.md)  
阶段B任务：[首页与内容权限产品化B1–B4](../versions/v2/V2_PHASE_B_HOME_CONTENT_AUDIENCE_CONSOLIDATED_EXECUTION_BRIEF_20261120.md)  
工程分支：`codex/v2-phase-b-home-content-audience-20261120`，GitHub回读指向`1780f6add9a439c109f527eb7f58c2f96ab8bfa5`。  
阶段A固定交付：`07b51a6de9695f5358b6bea2a59acd5be24ab6c2`；阶段B主业务源码：`f20f25ac8d0b70d9806295c62c0c3dd3e722a946`；通知测试修正：`789764f9e586b3311984d868b248d24c545c84d4`；阶段B最终完整交付：`1780f6add9a439c109f527eb7f58c2f96ab8bfa5`。  
状态：`PHASE_B_SCOPED_ACCEPTED_WITH_RESERVATIONS / OWNER_FINAL_ACCEPTANCE_PENDING / PHASE_C_NOT_AUTHORIZED / A6_MEETING_DEFERRED / MAIN_MERGE_RELEASE_NOT_AUTHORIZED`

## 一、独立验收方法与证据身份

Owner提交[阶段B固定工程报告](https://github.com/zcx369658780/EliteSync-v10/blob/1780f6add9a439c109f527eb7f58c2f96ab8bfa5/docs/versions/v2/phase-b-20261120/PHASE_B_ENGINEERING_REPORT.md)，内载B1–B4业务实现、隔离运行结果、全量测试失败对照、日志SHA及环境风险。网页顾问通过**GitHub连接器**独立核对交付commit/工程分支，并比较A交付与B源码和B最终交付差异、打开关键PHP/Dart/迁移及测试源码。**没有直接访问本地Windows工程、真实运行测试、读取私有原始日志或真实数据库/设备**。

- A交付`07b51a6d...`→B产品源码`f20f25ac...`：前进5次提交，修改APP、Laravel、三份迁移、测试及部分治理配置/文档。
- B产品源码`f20f25ac...`→完整交付`1780f6ad...`：前进2次提交，除阶段B工程报告外还有**`NotificationApiTest.php`测试夹具调整**。其过渡提交`789764f9...`把手工伪造的已读点赞通知改为通过真实点赞API产生并保留原通知读取断言；从可见补丁看并未弱化该测试，且能更真实覆盖新权限路径。故“业务产品源码f20f”与“最终已验交付1780”应分别使用，不得称其间完全只有文档。
- GitHub未见一份公开可逐测试审计的本次PHP/Flutter原始执行日志，仅有Codex报告的命令、计数、SHA256；报告指向本地`D:\EliteSync\development\v2-phase-b-evidence-20261120`保存原证。测试运行与“旧失败均在A复现”皆按`CODEX_REPORTED`记账，非顾问独立复现结果。

## 二、B1–B4合同/源码抽样

| 阶段AC | 固定源码可复核观察 | 当前顾问结论 |
|---|---|---|
| **B1 首页双域、编辑推荐与访客保守公开** | `HomeController::publicEditorial`仅输出配置中同时具`guest_read_approved=true`、`audience=PUBLIC_EDITORIAL`和非空`source_ref/title/body`的标题正文；`config/home_content.php`当前`public_editorial=[]`，因此访客没有实际发布的具名专题正文。`routes/api.php`将该API放在认证组外，用户作品路由仍需认证。登录作品`StatusPostController`有`featured/friends`频道、当前权限/Block重新核读；推荐仅指向现有原作品。 | `PASS_SCOPED_IMPLEMENTATION`，但**正式访客内容运营与具名真实素材发布`OPEN/EMPTY`**，不因合成测试允许真实转载或公开用户素材。 |
| **B2 新作品受众/评论策略与作者确认** | `StatusPostController::store`有`FRIENDS`及`FRIENDS_ONLY`默认，SELF强制OFF，PUBLIC_AUTHENTICATED需额外确认；`PostAudience`同时核作品读权、好友、Block及评论策略。受众变更`GET/PUT`提供版本/影响预览、显式OFF/隐式DEFAULT/来源未知的保守规则；Dart`status_square_page`默认FRIENDS并显示确认。 | `PASS_SCOPED_IMPLEMENTATION`，旧客户端、完整UI体验与设备/并发行为非本次独立验证。 |
| **B3 评论分主体展示权限与独立回复** | `StatusCommentController::changeDisplay`独立处理作者`WITHDRAW`和作品作者`HIDE`，回执不宣称物理删除；本人在失去作品读权时仍能仅凭本人已知评论ID撤回，不恢复作品读权。`StatusCommentAudience`检查评论、父评论各自原受众、当前账号/Block/作品资格；仅经固定安全回复文案验证的独立回复可在父隐藏时以最小中性上下文出现，其他保守隐藏；报告的API测试含非法主体、原受众及回复分支。 | `PASS_SCOPED_IMPLEMENTATION`；严格保守的固定回复是本阶段的有限功能，不代表任意第三方引用/附件或真实申诉系统全实现。 |
| **B4 全通道敏感内容权限与阶段A回归** | `StatusPostController`列表/详情、搜索/推荐、点赞/收藏和媒体封面在当前授权下重验；`MediaController::privateContent`读取真实媒体字节前重核可用独立授权并设置`private,no-store`；新评论原读者快照继续保守交集，未知旧评论/封面默认隐藏。通知点击重核原业务，Flutter已有前台/回流/切号防旧缓存机制与Widget测试。 | `PASS_SCOPED_IMPLEMENTATION`；旧缓存跨设备传播时效、JSON受众规模及MariaDB并发/锁行为仍缺真实环境证据，不能据此报全面G02/G03/G08 PASS。 |

证据示例（固定交付ref=`1780f6ad...`）：
- [官方访客正文API](https://github.com/zcx369658780/EliteSync-v10/blob/1780f6add9a439c109f527eb7f58c2f96ab8bfa5/services/backend-laravel/app/Http/Controllers/Api/V1/HomeController.php)、[内容源配置](https://github.com/zcx369658780/EliteSync-v10/blob/1780f6add9a439c109f527eb7f58c2f96ab8bfa5/services/backend-laravel/config/home_content.php)；
- [作品服务](https://github.com/zcx369658780/EliteSync-v10/blob/1780f6add9a439c109f527eb7f58c2f96ab8bfa5/services/backend-laravel/app/Http/Controllers/Api/V1/StatusPostController.php)、[权限服务](https://github.com/zcx369658780/EliteSync-v10/blob/1780f6add9a439c109f527eb7f58c2f96ab8bfa5/services/backend-laravel/app/Services/PostAudience.php)；
- [评论权限API](https://github.com/zcx369658780/EliteSync-v10/blob/1780f6add9a439c109f527eb7f58c2f96ab8bfa5/services/backend-laravel/app/Http/Controllers/Api/V1/StatusCommentController.php)、[回复上下文](https://github.com/zcx369658780/EliteSync-v10/blob/1780f6add9a439c109f527eb7f58c2f96ab8bfa5/services/backend-laravel/app/Services/StatusCommentAudience.php)；
- [私有媒体实际字节权限](https://github.com/zcx369658780/EliteSync-v10/blob/1780f6add9a439c109f527eb7f58c2f96ab8bfa5/services/backend-laravel/app/Http/Controllers/Api/V1/MediaController.php)、[阶段B定向PHP测试](https://github.com/zcx369658780/EliteSync-v10/blob/1780f6add9a439c109f527eb7f58c2f96ab8bfa5/services/backend-laravel/tests/Feature/V2PhaseBContentTest.php)。

## 三、测试口径：限定成功与全量红测不可混淆

| 验证类别 | 报告事实 | 当前可采证等级 |
|---|---|---|
| 具名A+B PHP | **149项、1,936断言、exit 0** | `CODEX_REPORTED_PASS / REVIEWED_TEST_SOURCE`，运行未独立复验 |
| 具名A+B Flutter | **226项、exit 0** | `CODEX_REPORTED_PASS / REVIEWED_TEST_SOURCE`，运行未独立复验 |
| 17个Dart文件分析 | **0问题、exit 0** | `CODEX_REPORTED_PASS`，仅指定文件范围 |
| PHP全量Unit+Feature | A固定基线`1,477 tests/81 errors/109 failures`，B交付`1,487 tests/81 errors/108 failures`；报告称逐案例对照**0新增失败，恢复1旧评论状态用例** | **`FULL_SUITE_FAIL / ZERO_NEW_FAILURES_CODEX_REPORTED`**，原始两份JUnit只在本地未复验 |
| Flutter Status+Buddy扩围 | **65项通过/3项失败**；报告称1个旧入口测试编译错误、2个旧Buddy Widget失败均在A基线复现 | **`EXPANDED_SUITE_FAIL / BASELINE_REPRODUCED_CODEX_REPORTED`**；未逐项查本地原日志，不能独立宣称无新回归 |

**关键澄清**：PHP全量仍有大量历史错误/失败，Flutter扩围仍FAIL；不能在任何总结中将阶段B称为“全量绿测PASS”。`BASELINE_REPRODUCED`目前仅是Codex出具的同源对照证据，不等于本顾问在Windows重跑确认。

## 四、运行环境/运营/法域/回滚风险保留

- **PHP环境**：交付报告实测PHP8.5.3、Laravel13.39.0、SQLite内存；项目声明PHP`~8.4.0`，**PHP8.4真实运行`NOT_RUN`**。
- **MariaDB真实能力**：三份阶段B新增迁移up/down的SQLite内存测试及在存量行的安全收紧已经报告；但MariaDB迁移、回滚、JSON索引/权限查询、请求竞争/读写锁与大规模原读者ID清单尚`NOT_RUN`。迁移回滚会丢B新权限与命令回执，并把不确定受众收紧，**不得未经另行授权在真实生产/共享数据上运行或回滚**。
- **真实正文与素材**：当前访客官方`public_editorial=[]`，无可发表的具名官方正文；没有单独授权的正式用户作品转载、第三方评论媒体或对访客开放素材，不得凭合成测试开放。
- **其他真实边界**：没有真机/模拟器、跨设备失权时效、真实KYC/Push/RTC供应商、正式后台运营/申诉及真实数据保留法律证据。完整G02/G03/G08只能按阶段B相关子项`PARTIAL`；G01/G06仍沿用A局部结果，G04/G05/G07/G09/G10未完成完整专项；43份原PNG`PENDING_BINARY_UPLOAD`、F-01`READABILITY_PARTIAL`、旧1011804 UI-AUDIT-01`UNKNOWN/NOT_RUN`不倒改。

## 五、最终顾问裁定与后续Owner决策

`PHASE_B_SCOPED_ACCEPTED_WITH_RESERVATIONS / OWNER_FINAL_ACCEPTANCE_PENDING`：B1–B4在固定可审代码、合同对应及报告中的具名隔离自动化范围达到可采纳的工程交付。此判断**不表示PHP/Flutter全量通过、真实设备/DB/供应商验证通过、官方访客真实内容上线或V2发布准入通过**。

- 不因3条已报告旧Flutter失败或PHP历史失败而直接推翻有独立代码证据的B阶段可用成果，也不自行把这些历史失败判成已经彻底关闭；在下一阶段统一质量包内追踪，而不是B1–B4按10个G逐项再派补单。
- 顾问仅建议Owner**正式接受B的限定自动化成果，并另行决定是否启动C**；Owner若未来授权，应将PHP8.4/MariaDB真实隔离验证、历史红测归因与内容法律许可作为持续明确OPEN项，勿用生产/个人数据补证。
- 不自动授权阶段C/D、正式A6 UI会议、主分支合并、Release、真实供应商联络采购或生产发布。

状态：`PHASE_B_SCOPED_ACCEPTED_WITH_RESERVATIONS / OWNER_FINAL_ACCEPTANCE_PENDING / PHASE_C_NOT_AUTHORIZED / A6_MEETING_DEFERRED / MAIN_MERGE_RELEASE_NOT_AUTHORIZED`。本轮网页GPT未直接访问Windows本地树、运行测试、启动下一阶段工程或改变既有工程分支。
