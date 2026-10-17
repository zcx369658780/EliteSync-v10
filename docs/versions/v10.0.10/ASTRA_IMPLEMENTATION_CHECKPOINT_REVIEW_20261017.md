# EliteSync-v10｜v10.0.10 Astra 实施检查点独立复核（2026-10-17）

**Astra裁决：`CHECKPOINT_EVIDENCE_REVIEWED_WITH_OBSERVATIONS / CONTINUE_SAME_VERSION / RIGHTS_AND_ORACLE_BLOCKED_FOR_FINAL / NOT_FINAL_CANDIDATE / V10.0.10 NOT_ACCEPTED`**

## 一、GitHub固定事实与复核来源

GitHub固定实施检查点：开发分支 `codex/v10.0.10-natal-restoration`，Commit `54aaeca7bf8863554f07c6412fa912107e17b4b9`，Tree `877314cfa4180f79e733e0680a737fd1939c0571`，唯一父Commit `883a53cb23830ec79b5811f71a2238b7d1aacd20`（其唯一父提交为正式v10.0.10 plan所在main `257f3cb6412dec370e49d028103f1f7bde56adfd`）。GitHub对该main至检查点比较为2次提交、97个路径，其中91个产品/算法/测试/依赖说明路径，另6个报告与状态文档；`main`提交在本复核开始时仍为`257f3cb6412dec370e49d028103f1f7bde56adfd`。

Astra实读：
- [综合实施报告](https://github.com/zcx369658780/EliteSync-v10/blob/54aaeca7bf8863554f07c6412fa912107e17b4b9/docs/versions/v10.0.10/IMPLEMENTATION_REPORT.md)，Blob `c2999d3261ca61516e36d5d27d5963cda1f1b77`
- [验证摘要](https://github.com/zcx369658780/EliteSync-v10/blob/54aaeca7bf8863554f07c6412fa912107e17b4b9/docs/versions/v10.0.10/validation-summary.json)，Blob `7eac45e834d8678e8bc70b5be9d0d27ab937449b`
- 本地版本源码读取：`NatalCalculationService.php`、`NatalCalculationProfile.php`、`NatalBaziCalculator.php`、`tools/natal/western.py`、`tools/natal/ziwei.mjs`、`tools/natal/oracle/ziwei_reference.py`及参考来源、`tools/natal/README.md`和计算profile JSON。上述代表性源码检查不代表整仓所有变更由Astra逐行静态审计。
- 固定[唯一冻结计划](plan.md)及Owner方案A仍保持。2026-10-17产品main `apps`/`services`已接受基线不因开发分支进度提升为新版已集成。

真实设备运行、DB/服务/APP重启及测试exit/hash来自Codex本地原证与公开脱敏摘要，属于`CODEX_REPORTED / LOCAL_ONLY`；Astra没有登录本机执行这些命令或亲自重复算法对照。本次不自行上调任何冻结AC为整版PASS。

## 二、已具有价值且不应返工的进度

已有同版统一出生资料、IANA TZ和DST/fold、显式算法参数、合法数据身份与缓存签名、真实Flutter/Laravel/隔离MariaDB的输入/版本并发/重读及冷启动闭环。产物为独立v10.0.10测试APK/AAR和开发环境，非正式商用分发；测试结果具有确定的源码/产物身份。

公开摘要给出：八字64新样本+24补盲、2200离散比较无差异（不含精确Gregorian交运等）；紫微48+24样本、5040项离散比较无差异**但明确不含亮度、余小星、完整选定年运限与历史TZ**；西占120+24个独立输入共1440项十主体黄经比较在候选误差阈值内；96组宫制几何比较及独立边界探针、42次真实API与相关定点PHP/Flutter/Node/Python测试有CODEX_REPORTED成功回执。独立比较的软件实现/盲测范围依报告口径保留，不把共享JPL历表称完全独立的观测来源。调试中失败与红测未被抹去。

**重要：Chiron缺失和扩展`PARTIAL_FULL`在代码中明确标注，紫微亮度`UNVERIFIED`、规则版本和西占自定义sidereal/Lilith口径也未被伪称全域oracle通过。这是负责任的失败透明度，不是可跨越AC的豁免。**

## 三、冻结门仍未闭合（不得降低）

**B1 Chiron合法数据**：DE440s不含Chiron；已获Owner一次性许可发出的JPL澄清邮件目前仅为`SENT/PENDING_REPLY`（邮件是否最新到达由Codex最后readback报告，Astra此轮未直接读取邮件）。**无回信不意味着被拒，也不意味着已获准**。必须区分NAIF从其服务器直接分发的kernel与Horizons生成的小天体SPK、SSD/SBDB数据、MPC/其他第三方轨道目录等各自权利条款。NAIF公开Rules允许其自身kernels在条件下未修改再分发/商用，不能推出Horizons生成Chiron SPK或其他来源同样受该规则覆盖；Horizons官方文档确认其技术上可为小天体生成SPK，不等于闭源交付的法律许可。参见 https://naif.jpl.nasa.gov/naif/rules.html 与 https://ssd.jpl.nasa.gov/horizons/manual.html 。可在本版调查具有**明确商用运行/服务端使用/再分发权限且覆盖冻结日期域**的另一数据源/实现，先核权利与历史精度再决定是否采用；不能因改名为MPC/PDS就假定可用，不能未经核准下载集成/外发/上架。既有邮件不重复群发、不承诺费用。若长期无合规可行来源，才集中向Owner提交许可/费用/功能合同的取舍；冻结Chiron字段不由Codex自动删除。

**B2 紫微现代流派独立验证**：原始封诰顺逆60项失败及校正为具名独立证据的v2来源差异保留。亮度1008次比较覆盖154/168星×支、其中18次不一致集中`七杀酉`和`太阴酉`；另14组合未有完整外部锚，余小星与选定年份运限的独立字段覆盖仍不足。不能因0差异的5040项不含这些字段就通过AC-10-04；也不能将其它流派异文简单称为bug。冻结`iztro-2.5.8-modern-default-v1`的同一profile及来源声明，寻找可明确复现该profile的非生产独立规则/表、逐格来源和完整运限案例，区别合理流派差异与实现错误。不同流派允许并列说明，但被选profile全部必达字段仍需独立可核，不得用引擎自身输出生成expected。真实不可消除的异文才以**具名两/三种值、各自来源/影响**集中请Owner裁定。

**B3 起运与西占扩展标准**：传统三日一岁等比例仅规定年龄/转换语义，不唯一决定现代Gregorian加月、闰日、月底取整、UTC与DST的具体算法。保留已经接受的lunar-php兼容语义，明确选择历法加法的可复现形式、年/月/日边界、时区与独立日期库/手算验证；不能将工程换算约定宣称古籍唯一认证。西占`CRC1956-23.25-true-frame-anchor-IAU2000A-v1`是自定义具名sidereal重建，**不是已经验证的Lahiri或原旧版逐位等价**；平均Lilith是具名mean lunar apogee模型，不可冒充任意其他黑月定义。必须在本版同一calculation-profile/APP标签中锁定所选定义、独立来源与oracle、边界敏感性；如果确证要改变Owner认可的旧功能语义，再报Owner一次明确选择，而不是将任何差异隐去。

## 四、版本级继续执行原则与当前Owner决定

- 裁决 **`CONTINUE_SAME_VERSION`**：既有已通过的真实APP、MariaDB、缓存、API、构建/定点测试、独立参考子集不因这三类欠账而被清零。不做新版本号、不重做路线图、不把每个亮度表/Chiron邮件/交运规则拆成微小任务或重复Astra评审。等JPL答复的同时，Codex应自主推进剩余全部**已获许可、已定义范围内**的reference acquisition、alternative rights checks、算法明确口径、缺项功能与盲测，优先一次交完整版候选。
- 在既定Owner v10.0.10手动派发范围内，Codex有普通本版源码/独立测试/虚构数据本地服务的自主实现权限；旧受控开发环境已停止应在未来重启前重新核归属，不能因此获全局系统权限。不得擅自购买许可、改变账号/隐私/数据合同、重启UAC/防火墙或真实RTC窗口、覆盖原备份/dirty root、扩大第三方商用授权、外发出生资料、合main/K08。
- **当前不需要Owner逐个裁决亮度值、日历算法和西占参数，也没有得到任何放宽原AC的批准**。只有反复独立验证后仍存在两个有证据且产品用户可见的互斥计算profile，或者许可路线确实需要付费/AGPL义务/删除必达项，才汇总成**一次真正Owner决策**。先返回严格字段、来源和具体选择及影响，而非空泛`UNKNOWN`。
- 本次`AC-10-01..08`的正式冻结合同保持不变，最终结论`V10.0.10 NOT_ACCEPTED`。报告中AC-10-06的真实软件链和AC-10-07局部回归是**局部证据成立**，不可自动覆盖依赖于三盘正确性的整版结论。直到全部许可/规则/独立oracle与实际功能闭合，不得产出`FINAL_CANDIDATE DELIVERED`标签。

下一版本综合一次性候选应回报完整Chiron来源准入或准确剩余权利阻断、全部亮度/小星/运限独立期望表、交运Gregorian与sidereal/Lilith具名规则及实际盲测、相应APP/API/DB与构建回归、原失败与运行终态。只向Astra提交一份最终综合候选或一次不可绕开的Owner决定请求。
