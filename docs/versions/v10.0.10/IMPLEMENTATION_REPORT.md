# v10.0.10 三盘本命恢复：综合实施与阻塞报告

## 2026-10-17 Astra阶段复核后的同版继续实施

**CONTINUE_SAME_VERSION / RIGHTS_AND_ORACLE_BLOCKED_FOR_FINAL / NOT_FINAL_CANDIDATE / NOT_ACCEPTED**。已完整读取固定于 `1bdc76c1e51b29af0e54ceb17b9bdb82eaf04c67` 的 [Astra阶段审查](https://github.com/zcx369658780/EliteSync-v10/blob/1bdc76c1e51b29af0e54ceb17b9bdb82eaf04c67/docs/versions/v10.0.10/ASTRA_IMPLEMENTATION_CHECKPOINT_REVIEW_20261017.md)。唯一冻结plan、八项AC不变；不是重新规划或新R任务。

本轮源码 **`0384a8ee65294931d35602b2a486f70ae3baedb6`**，Tree `b14d2bc2130e4fe881744f18fc2301970066c00d`，父为上轮 `54aaeca7bf8863554f07c6412fa912107e17b4b9`；apps=`6625bce44380b800bcaa843eb8f0c090422d076e`，services=`d3dcd788ef6d0500090ec84c50f0dcb5b4c05942`。15个源码/说明/独立参考路径：明确现有交运Gregorian行为与西占定义、profile1.0.1、APP可见标签和独立参考/测试。**未改变现有数值算法、紫微表、引擎、依赖版本或资料权限。** 后续报告提交继承上述产品子Tree，开发分支仍为 `codex/v10.0.10-natal-restoration`。

本节运行结果仍为 **CODEX_REPORTED / LOCAL_ONLY**；公开机器汇总关联回执名与stdout/stderr hash，Astra未登录本机复算。日期算术含少量1900或远期世纪规则探针，不把这些纯算术测试提升为APP全历史域验真。

| 本轮实际核验 | 结果与不能外推的范围 |
|---|---|
| 交运Gregorian盲选日期 | 非作者未读生产，30样本×公历/UTC/用户TZ=90项一致；含闰日、世纪、月底、年月非结合、DST与日期变更线。证明具名兼容算术，不是古籍唯一现代规则。 |
| HKO/起运补对照 | 复用先前88个生产输出，新增83个精度足够样本×offset/calendar/UTC=249项无差异；5个跨桶区间保持REFERENCE_UNCERTAIN。sect2全88个仅有分钟精度区间，未伪造唯一值。 |
| 西占定义补盲 | 28个非作者TT输入，ayanamsha、mean-apogee真春分点黄经及速率共84项通过；最大误差分别约1.448e-8°、1.363e-8°、8.583e-8°/日。独立ERFA矩阵/基本角，共享IERS/ERFA模型族；不证明官方Lahiri或旧版逐位等价。 |
| 紫微余星合法输入 | 独立HKO72输入中40个非闰月且初三以后，17星共680位置无差异；其余32例逐星NOT_ASSERTED。最初结构样本不保证农历月存在，没有拿它们运行APP域算法；另从原合法集独立生成并冻结新expected后才比产品。 |
| 选定大限/流年 | 同72输入新目标年，216个大限字段、72个年干支、864个宫名、72组四化数组、288个四化目标，共1512项一致；是选定规则子集，未含全流曜、小限/童限或完整边界oracle。 |
| 截路/旬空 | 60干支循环＋24非作者年份：84个截路/空亡合并双支集合相等，84个旬空单支落在古典双支集合；不证明两名称分支分配或单支阴阳选择。 |
| 定点回归 | PHP八字15 tests/130 assertions exit0，保留2个既有PHPUnit deprecation；Flutter默认/本版define各20项exit0，定点analyze exit0。独立参考可移植重放/语法通过；拒绝覆盖已有输出预期exit2且原hash不变。不累计为不重叠测试数量。 |

交运现有兼容行为已登记：固定UTC+08，顺序加年截日→加月截日→日→小时，最终转UTC/用户TZ；23时起运桶保留末桶11特例；保留出生分秒不代表秒级准确性。自定义CRC1956和平均月球远地点在同一profile、API元数据及APP标签中明示。见 [CALCULATION_CONVENTIONS](../../../services/backend-laravel/tools/natal/CALCULATION_CONVENTIONS.md)和[新参考来源清单](../../../services/backend-laravel/tools/natal/oracle/continuation_reference_sources.json)。参考生成器不进入生产，不用生产输出制造expected。

内部非作者复核确认产品数值口径未变、hash已进入既有缓存签名及未误标标准/验证状态；发现参考CLI先exists后write的覆盖竞态，已改原子 `open('x')` 并回读关闭。保留原手工探针ID，但明确其UTC00实际为UTC+08的08，不冒称本地23→00。公开紫微参考移植只改路径、输入去旧expected及stdout，72条case与冻结原稿逐值相同；无生产导入、绝对私有路径或受限亮度整表。复核不代替Astra接受。

本轮失败/限制完整保留：标签两项先RED后GREEN；西占参考v1省略月球平近点角和真春分点修正在**任何生产对照前**被发现，原件不覆盖，v2独立重冻后才比产品；交运重放hash差异经结构对比仅为sect2说明文字，88数值记录相同；本地harness字段/导入错误与一次报告脚本语法错误不按生产失败或静默通过计。原v1封诰与历史失败继续保留。

本轮只读原JPL线程一次，仍只有原SENT一封，没有重发、下载Chiron或付费。替代来源调查及剩余紫微/完整扩展参考仍不足以关闭最终AC；免费/第三方/商业备用路线、当前官方价格/六年合同及可审阅限定询问信息集中于唯一 [Owner决策请求](OWNER_DECISION_REQUEST.md)。不要求Owner逐字段转发或批准普通技术工作，不提供删必达字段追绿的选项。

本轮APP/API/DB/服务重启、完整套件及APK/AAR重建安装均 **NOT_RUN**。既有build4/数据库链证据继续绑定下方首轮源码 `883a53c...`，不能当成本轮标签已安装或新HEAD已完整实装。新profile按既有hash合同使旧结果STALE，待权利/完整参考闭合后才统一重算、构建和最终验收。原dirty根HEAD/index/status/43项hash保护快照仍相同；未动volume、历史资产、UAC、防火墙、RTC、main/K08或后继版本。

以下首轮原记录保留其固定身份、失败与范围，不能覆盖本节新增事实。

2026-10-17。**IMPLEMENTATION_CHECKPOINT_SAVED / RIGHTS_AND_ORACLE_BLOCKED / NOT_FINAL_CANDIDATE / V10.0.10 NOT_YET_ACCEPTED**。

Owner 方案 A 已实际派发并实施。真实三盘计算、APP 输入/设置/详情、Laravel 私有接口和独立 MariaDB 已贯通；本版仍未满足全部冻结必达字段的许可和独立准确性证明，**不能报告 FINAL CANDIDATE DELIVERED**。没有修改 AC、切入 Swiss/Kerykeion、合 main、执行 K08 或启动下一版本。本文集中保存同一版本成果和真正阻塞，不另立微型版本或新的规划轮次。

## 1. 固定身份与交付范围

| 对象 | 身份 |
|---|---|
| 唯一冻结 main/plan 所在提交 | `257f3cb6412dec370e49d028103f1f7bde56adfd` |
| 产品起点 | `a1ce6473e85ee02786fc2fb4bb33ca1eac46ea8f`，v10.0.9 K08 |
| 本版源码检查点 | `883a53cb23830ec79b5811f71a2238b7d1aacd20` |
| 源码 Tree | `1e92c5382533fc31498edbe4abaebfd50e36bba3` |
| apps Tree | `8e69c77a7ab82f6104936e9986f23a66bda2b5a2` |
| services Tree | `768bde48ecd9a56def4d8b405c8f87f36d1d8ec9` |
| 开发分支 | `codex/v10.0.10-natal-restoration`；后续报告提交不改变上述产品对象 |

91 个产品/测试/依赖说明文件，集中于 Android 本地构建接线、Flutter 本命/设置/会话保护、Laravel 本人私有派生及其迁移/测试、`tools/natal` 算法与独立规则参考、固定 wheel 锁和 33 份上游许可证原文。没有加入原始 API/数据库回执、设备标识、凭据、kernel、APK、真实出生资料或临时审阅目录。生成的 Python cache 被局部忽略，没有删除原证。

源码清单以该提交为准；[脱敏验证汇总](validation-summary.json)关联具体测试退出码和本地原始 stdout/stderr 的 SHA256。[开发接续说明](../../../services/backend-laravel/tools/natal/README.md)给出配置、依赖、时间/规则定义及适用限制。原始回执仍为 LOCAL_ONLY，网页 Astra 尚未直接读取，本文运行结论是 **CODEX_REPORTED**。

## 2. 实际恢复结果与来源

具名旧资产仍以原固定 `0f06e895a89629a7f4f0cf0c62b784446ecf515a` 的源码/版前登记为范围依据，不接触旧数据库。旧 Laravel Bazi/Lunar 引擎提供兼容行为；旧 Ziwei canonical/shadow 接口及 Flutter 页面提供字段/交互范围；旧 `services/api/app/services/astro.py` 的本命、扩展和动态接口仅作行为范围证据。旧 Kerykeion 5.12.7 的代码存在与架构 Accepted 均不等于商用许可或数值准确性通过，未把其受限引擎接入新链。

| 模块 | 已实际实现 | 尚未证明的部分 |
|---|---|---|
| 统一输入 | 公历日期、当地时间/精度、地点、IANA TZ、DST offset/fold、WGS84 坐标、单独确认的算法性别、版本与来源；未知不补 noon | 历史/未来时标物理精度与完整历法边界不能由输入合同测试代替 |
| 八字 | lunar-php 1.4.0 真四柱、藏干、十神、纳音、地势、五行计数；顺逆、起运、大运/流年及胎元/胎息/命宫/身宫；民用或真太阳日时、固定 UTC+08 节令年月柱分别记账 | 精确 Gregorian 交运日期、扩展全字段和更广年代/精确秒节令仍缺独立证明；未把地势等同科学强弱测量 |
| 紫微 | iztro 2.5.8 真十二宫、命身/宫干支/局、主辅杂星和亮度、十干四化、48 条有向宫干飞化、自化/命宫飞星、大限及明确参考日期的选定年运限 | 亮度出现具体异文；余辅星别名、闰月细则和完整运限独立参考未关闭 |
| 西占 | Skyfield 1.55/DE440s 十主体、速度/逆行、四轴、Whole/Placidus/Alcabitius、落宫/相位；具名 sidereal 重建、真交点轴、平均 Lilith | Chiron 未准入，full 为 PARTIAL_FULL；未证明与旧版 Lilith/sidereal 定义逐位等价；完整扩展盲测未关闭 |
| APP/后端/DB | 实装 APP 真输入、三盘与详情、真实计算设置、展示偏好、解释可关、POST 后 GET 核 revision/signature；新私有表持久化、重登/冷启动/服务及 DB 重启重读 | 软件链成功不使未验算法字段自动成为 VERIFIED |

新资料是本人私有计算镜像。保留 canonical birthday 和旧镜像，不无声回填正式事实；不向匹配评分、硬筛选、CN/MC 或关系结论写入玄学信号。现有 summary/chart/三盘详情识别新记录；FAILED、COMPUTING、STALE 均不回退旧估计盘。新 natal 数据不进入本版排除的旧动态盘 POST。

合盘/synastry/composite、行运/transit、太阳/月亮回归、法达及其它已证旧动态/关系盘保持**内测前必须恢复**的具名欠账，本版 NOT_IMPLEMENTED，不删除、不默认为永久 Later。

## 3. 许可与数据实际状态

- 已逐包核 lunar-php 1.4.0 与 Node 六包的安装元数据和 MIT 实文；Node 由固定 npm lock 安装。未独立重下载 npm/PHP 原始归档逐字节复核，不能把这项写成已执行。
- 六项 Python wheel 已固定版本、原始 SHA256 与包内 LICENSE/NOTICE，含 PyERFA/ERFA。实际版本、关键代码、RECORD/METADATA、ERFA active leap、Skyfield DeltaT/闰秒数据及实际 kernel hash 进入缓存身份。版本不在准入列表或 kernel 不匹配时身份不可用；已知时间计算拒绝执行。
- NumPy 二进制包含 OpenBLAS/LAPACK、附 GCC Runtime Library Exception 的运行库等附加条款；完整文本保留。Certifi 未修改，MPL 通知/全文及源码取得地址保留。当前只核 CPython 3.11 Windows x86_64 的这些 wheel，不宣称其它部署平台已验。
- DE440s 实文件 32,726,016 字节，SHA256 `c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2`；与 NAIF 官方 MD5 表一致。官方规则原响应已保留，明确允许 NAIF kernel 下载/使用、未修改再分发及商用，附其余条件；本版不捆绑 Toolkit。
- **Chiron 是必达字段，DE440s 不含它。** SSD/Horizons 数据不能自动套用 NAIF kernel 条款。Owner 已授权向 JPL 官方地址发送一次不含生辰、附件及费用承诺的澄清邮件，已 SENT；本轮一次只读查该线程只有原发件，没有回信。SENT 不等于许可。Chiron 数据未下载、未运行，不购买许可、不用 Swiss 绕过。

## 4. 独立参考与真实差异

| 验证 | 真实结果 | 独立性和覆盖限制 |
|---|---|---|
| 八字 HKO/USNO/经典规则 | 64 新样本＋24 补盲标签，2,200 项离散比较，0 差异 | 非 lunar 生成 expected；主要 2024；HKO 分钟表 ±60 秒守卫不证明 ±1 秒节令；精确公历交运/扩展未覆盖 |
| 紫微独立规则 v1 | 72 样本、5,040 项，60 项封诰差异 | 原失败完整保留；Sanqing 逆行与《全书》/NCC 顺行为真实异文，不能称前者误读或笔误 |
| 紫微明确顺行 profile v2 | 同一 HKO 合法新输入 48＋24，5,040 项，0 差异 | 独立规则构造 expected；不包含亮度、余小星、选定年全字段或历史 TZ；v2.1 只校正互相矛盾的来源说明，未重造 expected 或改规则 |
| 紫微外部亮度表 | 1,008 次对照覆盖 154/168 主星×地支；18 次不一致，集中太阴酉和七杀酉两对 | iztro 分别为“不”“庙”，紫微家为“旺”“旺”。另一公开表与紫微家有 63 格字面异文；上游程序谱系 UNKNOWN，不混表追绿，文章/整表不进入产品或公开测试 |
| 西占十主体 Horizons 主集 | 120 样本、1,200 项，最大约 0.0000671°，0 超阈值 | Horizons 与 Skyfield 独立实现，共享 JPL 数据族和部分时间规范；不是独立天文观测 |
| 额外非作者西占补盲输入 | 无父历史助手选 24 个全新输入；先固定来源/expected，再运行生产；240 项，最大约 0.0000681°，0 超 0.001° | 包含旧 UTC、闰秒邻近、世纪/闰日/跨日、日期变更线及南北高纬。仅证明所比字段，不把输入选择自身当 oracle |
| 速度/逆行 | 主集 1,200 项分类无差异；最大速度差约 0.0001401°/日 | ±30 秒参考；不证明精确驻留瞬间边界 |
| 四轴/宫制独立几何 | 96 组、1,504 项，最大约 2e-11°；3,168 宫尖区间探针，0 差异 | ERFA 向量/全局时间相位反演，另核 18 个公开手算值。参考作者曾读生产，明确 NOT_BLIND；其中一份公开数值为镜像次级来源，不证明全时间/星历链 |
| 月交点/平均 Lilith | 120 样本、360 项，最大约 3.5e-8°，0 超 0.001° | Horizons 地月向量＋ERFA 参考；同一 JPL 族、部分底层共享；NOT_BLIND，不证明原版 Lilith 定义或 Chiron |
| 真太阳时均时差 | 120 样本对 NOAA/Meeus 独立公式，最大约 2.674 秒，0 超 60 秒 | NOT_BLIND，共享冻结 TT；NOAA 不再维护，日出精度说明不当作均时差保证，未据此宣称全部时标精度已证 |

精确公历起运来源另经未读生产实现的助手核查：经典支持三日一年、日/月/时辰换算及保留余欠，但其交运示例使用农历/闰月，不能直接证明现代 Gregorian 闰日/月末加法、TZ/DST 或秒级规范。保留 lunar-php 已接受兼容口径，不无据改成另一流派，也不把当前输出作为自己的 oracle。

## 5. 实际软件链、回归和构建

已安装同一个独立测试包。APP 真实修改生日、时间、TZ、坐标后保存/重读至第 2 代；再真实选择 sidereal/Whole/full/真太阳时，保存/重读至第 3 代：四柱、12 宫、13 个已准入西占主体/方向存在，Chiron 缺失明确报告。随后仅重启本版 API/新 MariaDB，独立 SQL 两用户结果 hash 及 API profile 前后相同；两用户 canonical birthday 未改。最终 build4 实际退出账号、重登、强制结束/冷启动 APP，从“本地设置→盘面设置→真实计算设置”读回同一输入及设置。

42 次真实 API 请求覆盖 15 次输入/计算设置变化、持久 GET、同输入缓存、HTTP409 过期编辑、本人身份/伪造 user_id 不选中他人、DST gap/fold、非法日期/TZ/坐标、未知时间与历史域降级、Chiron 正确 partial。其结果不是算法准确性证明。

| 检查 | 实际结果 |
|---|---|
| PHP 本版定点套件 | 43 tests / 275 assertions，exit0；2 类既有 deprecation 保留 |
| Node 适配器 | 8/8，exit0，无 skip |
| Python | 25 项发现：首次 23 通过、2 项因未给指定 kernel 被条件跳过；随后显式指定本版 kernel 运行这 2 项，全部通过，exit0；ResourceWarning 严格检查 |
| Flutter 非作者发现修复回归 | 默认和 v1010 define 各 65 项通过；冷进入修复另有默认32/v1010模式5项；最后源码两模式各23项通过，analyze exit0 |
| build4 | AAR＋APK 构建 exit0；实际安装/启动成功。既有 deprecated API/build 提示保留 |
| APP 包/显示版本 | 独立 `.v1010test` 包；显示版本实际仍为 `0.08.04`，不冒称显示号已更新 |
| APK SHA256 | `f330c9a24f539e250130028aade5cd835de7bafb30195da18624d3a235d01c50`，222,959,834 字节 |
| AAR SHA256 | `577a7acbe4e5081b435d7fe077d0e2c0ba76c10eb1b927d294bb2021f3bef6f7`，4,024,898 字节 |

build4 绑定的本地源文件清单和实际构建/安装回执保留；Git 源码对象单独固定。既有 CRLF 与仓库过滤可能造成文件系统原字节和 Git 文本字节差异，不声称二者盲目逐字节相同。上游许可证使用局部 `-text` 保留原字节，33 份 staged blob 的 SHA256 与交付清单逐一一致。默认空白检查原失败保留；明确 CRLF 且排除需原样保留的上游条款后，产品源码空白检查 exit0，不改全局 Git 设置或上游原文追绿。

## 6. 非作者复核和原始失败

独立 GPT-6.1 Sol/high 只读代码复核发现并关闭：新私有生辰流入旧动态 POST 的跨会话链、无条件异步登出、旧设置对新盘失效、端点测试只在 v1010 define 成立，以及冷进入设置页不读取资料。补入派发前后会话 guard、含 natal 的动态请求关闭、真实计算/展示设置、双模式及冷进入测试。复核最后确认这些问题关闭；这是内部代码复核，不是 Astra 版本终验。

缓存额外修复实际 Python/时间表/kernel 身份。测试用本版 kernel 的**自有副本**改变一个字节，实际探测改变身份，内存投影变 STALE/清结果，恢复配置后匹配，原 kernel hash 未改；也实际改/恢复进程内 ERFA active 表验证签名。不能将 AVAILABLE 身份状态写成算法 VERIFIED。

全部原始 RED、stdout/stderr/exit 保留，包括：CP936 oracle 接收失败；第一轮封诰60差异；过长 Horizons TLIST 截断；1960年前空 DUT1 触发 TypeError（已按显式 UT1 标签修复）；补盲 harness 错用旧缓存的 JD 拒绝；API 首次摘要取错字段；回归脚本两次注册因缺失/未接受旧 required 字段获422；Flutter 会话/设置/端点/冷进入及起运时区显示 RED；分析历史 warning/info。没有用无日志的补跑覆盖原件或重造 expected 追绿。

原全量 PHP 16 项既有失败、旧 Flutter 失败、v10.0.9 AEC/回声观察、call65 额外 DB/room 终态未独立读回、旧 `/up` 内因 UNKNOWN 全部保留；本版不重跑全量历史、真实视频/语音、20 分钟网络窗口，未声明这些旧问题已修。

## 7. 冻结八项 AC 的真实状态

| AC | 本次结论 |
|---|---|
| AC-10-01 | PARTIAL：来源/锁/NOTICE/数据身份已交付，Chiron 与完整旧扩展逐项等价未关闭 |
| AC-10-02 | PARTIAL：真实 APP/API/DB 输入、修改、DST/unknown 负例成立；全冻结历法/秒级敏感性证明不足 |
| AC-10-03 | PARTIAL / REFERENCE_BLOCKED：基础独立对照通过，精确公历交运、扩展及更多边界未获完整独立 oracle |
| AC-10-04 | BLOCKED：真实通用盘/四化/飞星已有规则对照；亮度具体异文、余星/完整运限参考缺口未关闭 |
| AC-10-05 | BLOCKED：十主体/宫制/部分方向通过所列对照；Chiron 许可及完整扩展/具名标准等价未关闭 |
| AC-10-06 | 真实软件持久链已证明；因三盘必达准确性尚未齐备，不提升为完整版本 PASS |
| AC-10-07 | 影响范围身份/缓存/会话/私有资料回归通过；Match/CN/MC 代码合同未改，历史全链 NOT_RUN，不扩大已验范围 |
| AC-10-08 | 源码/构建安装/DB重启/内部复核/原失败材料已保存；完整算法、参考和许可不齐，NOT_FINAL_CANDIDATE |

## 8. 保护、运行收口和需要集中解决的事项

仅本版全新虚构库/volume、loopback API 和受控测试包被使用。现在测试 APP/API/DB 已停止，新增 reverse 已撤销，volume/新包数据/原证保留；原有模拟器不 wipe、不卸载其它包。UAC、防火墙、RTC、生产、真实资料外传、付费许可、全局 SDK 变更均 NOT_RUN。

原 dirty 根的 HEAD/index/normal status/43 项记录的 dirty tracked hash，实施前、运行收口后及源码提交后均一致；不将其表述为重新遍历验证了全部历史未跟踪媒体。未手动 reset/rebase/stash/clean/prune/delete，未吸收原 dirty 成果。

源码提交意外触发 Git 自带自动打包，输出有旧证据长路径警告，原输出保留。提交后再次核原保护快照相同，7 个固定当前/历史提交仍可读，gc.pid 已不存在；后续命令仅使用命令级 `gc.auto=0`/`maintenance.auto=false`，不改全局设置。不声称已全面核查所有不可达历史 loose object。

真正阻塞应在**本版同一合同内集中处理**：

1. 等 JPL 对具体 Chiron 离线数据/闭源服务权利作书面澄清；已授权邮件不重发、不付费、不外传生辰。没有许可前保持关闭，不能用 NASA 标签代替准入。
2. 由 Astra/Owner 对紫微已出现的亮度异文和余星口径确认独立参考依据。建议保持冻结 iztro 兼容目标与 UNVERIFIED，补同口径参考；若改用另一明表，应明确冻结的规则例外并独立重验，不自行挑值拼表或以未知当 PASS。
3. 补足精确 Gregorian 交运、完整运限/扩展及具名 sidereal/Lilith 的独立依据。现有传统比例不能自动确定现代公历加法；保留已接受兼容行为，不能由 Codex 擅自宣布某个未证现代换算是唯一事实。

以上不是要求 Owner 逐项管理实现或转发代理消息；常规工程修复已经自主完成。需要的是许可、可独立验真的规则依据及确有冲突时的具名产品决定。**冻结 AC 不降级，当前 main/v10.0.9接受状态不变；v10.0.10未被接受，等待解决上述阻塞后继续同版。**
