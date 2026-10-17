# v10.0.10 三盘算法与APP排盘恢复｜综合版前报告

2026-10-17。**V10.0.10 PREPLAN_READY / AWAITING ASTRA PLAN REVIEW / IMPLEMENTATION_NOT_STARTED**。

结论：已有可复用的APP页面、八字基础计算、canonical持久层和部分测试；**没有完整三盘准确性已经恢复的证据**。建议在一个v10.0.10功能版本内完成统一出生输入、三盘规则/合法引擎、独立验真、真实APP与数据库贯通。完整性按下文具名字段和原版能力对照验收，不按接口数量或样例数量计算。正式冻结前仍需解决规则口径、完整字段边界和许可路线的集中决定。

## 1. 调查身份、方法和证据等级

- 正式main及干净K08工作树实读HEAD均为`a1ce6473e85ee02786fc2fb4bb33ca1eac46ea8f`，Tree`11a3bef059aa7a1bc1093bdcd196e32f6ad80459`。产品apps=`cb244162165c572c95bf428c11945d37d0e56d52`，services=`f383a84689a0039077b030988ba55ad720b425dd`。所有当前源码路径均指该固定快照。
- 复用`C:/Users/zcxve/.codex/worktrees/elitesync-main-64a098f/EliteSync-v10`；原`D:/EliteSync-v10` dirty根及LOCAL_ONLY不吸收、不清理。只读代码图谱用于定位，图谱指向旧dirty根，**事实全部以干净K08文件及具名旧Git对象核对**；未重建索引。
- 两位只读助手分别核Laravel、Flutter/旧资产；独立Astra/high内部规划助手挑战完整性、精度和oracle独立性。它们的意见为内部建议，不是网页Astra冻结或版本验收。
- 已读取当前路线、Owner D1～D6、v10.0.7接受及v10.0.9 K08。v10.0.7的AC-07-06只接受本地八字基础链、缺时降级和重登读回；不包含完整紫微/西占。参见[固定0.7接受](https://github.com/zcx369658780/EliteSync-v10/blob/a1ce6473e85ee02786fc2fb4bb33ca1eac46ea8f/docs/versions/v10.0.7/acceptance.md)。
- 本次未运行排盘、测试、构建、服务、DB、APP或设备，未安装依赖、开启研究开关或购买许可。上游仅读取公开文档、许可证和包元数据。静态源码事实、历史接受、依赖许可候选与新版本运行通过分开记录。

等级：**已接受**只指既有冻结范围；**实现未验**指具名算法/消费代码；**fixture/演示**不可升级为任意输入准确性；**缺失/未实现**须补齐；**默认许可阻断**不能因研究模式解除。本报告不推断实际用户数据库内容。

## 2. 实际恢复清单

下列Laravel路径前缀为`services/backend-laravel/`；Flutter为`apps/flutter_elitesync_module/lib/`。

| 模块 | 固定代码证据 | 实际状态与0.10缺口 |
|---|---|---|
| 八字引擎 | `app/Services/LunarPhpBaziEngine.php:12–104`、`config/astro_canonical.php:5–14` | 默认lunar_php，真实调用Solar/Lunar/EightChar；四柱、藏干、五行、大运和流年已有输出。0.7基础链已接受，**不等于完整准确性已验** |
| 八字扩展 | 同引擎约202–225；Flutter `features/profile/presentation/widgets/professional_bazi_grid.dart` | 大运有干支/起止年与年龄，流年主要为年干支。网格可显示十神/地势，但当前引擎缺对应完整输出；纳音、旺衰体系、神煞、胎元、命/身宫、精确起运岁月日/交运时刻均不能据UI存在认定已恢复 |
| 节气/地点时 | `app/Services/BirthLocationSolarTimeService.php:20–93` | 当前按Asia/Shanghai/120°E，整数分钟经度差+近似方程时修正，支持跨日；不是全球历史时区/DST或高精节气验证。完整真太阳时/年/月/日界口径待定 |
| 紫微通用路径 | `app/Services/ZiweiCanonicalService.php:160–302` | seed/轮转估算，标`approximate_not_validated`；宫干/地支等缺口，非fixture四化空，飞星未实现。不能宣称通用十二宫正确 |
| 紫微有限oracle | `app/Support/Ziwei/ZiweiFixtureMatrix.php:13–75`、`tests/Fixtures/Ziwei/iztro_abc_comparison_fixture.json:2–56` | CECE/温墨A/B/C的具名有限子集；14主星/宫名地支比对，不覆盖辅小星、亮度、四化、飞星/命宫飞星。`external_oracle_status=not_validated`保留 |
| iztro适配器 | `tools/ziwei/iztro-runner/runner.mjs:29–33,166–234`、`app/Support/Ziwei/ZiweiIztroAdapterContract.php`、`config/ziwei.php` | 2.5.8隔离runner，off/shadow/local/app-visible候选门，生产默认未采用；时区/DST/真太阳时须外部预处理。现有fail-open到旧估算不能作为新正式排盘成功降级 |
| 西占Laravel | `app/Providers/AppServiceProvider.php:38–57`、`app/Services/LegacyInputWesternNatalEngine.php:17–68` | 依赖门之后仍回退legacy；太阳星座按日期，月亮/上升含CRC seed生成。**这些值不是行星位置/上升点计算**；western_lite及canonical rollout默认关闭 |
| 西占Python/绘图 | `app/Services/PythonAstroRenderService.php`、`config/python_astro.php` | HTTP消费/渲染适配存在；不能据localhost URL认定当前树有完整Python算法服务，更不能认定已部署或许可已清 |
| canonical/API | `app/Http/Controllers/Api/V1/AstroProfileController.php:105–180`、`ProfileController.php:533–584` | 接生日/时间/地点/经纬度，astro接口tz只允许Asia/Shanghai；profile-basic缺时存在12:00占位并带unknown provenance。不能把占位当确定出生事实；禁止客户端伪造派生字段的既有合同保留 |
| 持久化/缓存 | `app/Models/UserAstroProfile.php:10–40`，`database/migrations/2026_03_21_200000_create_user_astro_profiles_table.php`、`2026_03_30_120000_add_ziwei_fields_to_astro_profiles_and_users_tables.php` | user_astro_profiles、users.private_bazi/private_natal_chart/private_ziwei等私有镜像已有结构；西占缓存有输入签名/重算逻辑。没有由此证明0.10新引擎结果及全参数签名正确持久 |
| APP真实输入 | `features/profile/presentation/pages/edit_profile_page.dart:219–283,361–410`，data层profile保存映射 | 日期、可缺时间、地点搜索/本地手填坐标与范围校验存在；**没有显式IANA时区和历史DST选择链**。手填/搜索/用户确认的来源顺序须明确 |
| APP三盘详情 | `astro_profile_provider.dart:96–122`及`astro_bazi_page.dart`、`astro_ziwei_page.dart`、`astro_natal_chart_page.dart`（均在features/profile/presentation下对应providers/pages） | summary/chart真实API消费、超时/认证失效/回退和三盘渲染存在；紫微飞星是candidate/human_review_required，西占会读oracle/house_truth状态。这些是显示合同，不是准确性通过 |
| APP设置 | `features/profile/presentation/providers/astro_chart_settings_provider.dart:13–21,402–613`、设置页 | tropical/sidereal、whole/placidus/alcabitius、core/extended/full、相位和orb偏好本地持久；**不改变服务端盘面**。0.10需区分纯显示偏好与真正计算参数，后者入服务端签名并实际重算 |
| 演示/预览 | `astro_chart_sample_fixture.dart`、`astro_chart_sample_comparison.dart`及advanced preview/time-lord providers | 固定样例、离线生成、部分法达占位/时间法预览，不能作真实盘或独立oracle；保留明确演示标记，不能混入用户canonical |
| 已有测试 | `AstroCanonicalApiTest.php`、`V1007BaziProvenanceTest.php`、`ProfileBasicRecomputeTest.php`及Ziwei Oracle/Iztro测试 | 覆盖藏干/真太阳时合同、输入改变、未知时间、客户端伪造、缓存/fixture等；不是全面非fixture验真。本次未运行。0.9原PHP4 errors/12 failures及0.7旧Flutter失败继续按旧记录保留，受本版影响的失败须真实处理/归因，不能删除断言追绿 |

输入、输出、UI及测试不能各自形成互不相连的“完成”。0.10必须将同一`input_revision + calculation_profile + result_revision`贯穿这些模块。

## 3. 具名旧资产与完整性边界

旧库仅只读`D:/EliteSync`固定Commit`0f06e895a89629a7f4f0cf0c62b784446ecf515a`、Tree`42a0a72b175f9fd8e0468cd3006573f8d4f78330`；不读数据库、历史生辰或真实媒介。

| 固定资产 | Git Blob | 可复用范围与限制 |
|---|---|---|
| `services/backend-laravel/app/Services/BaziCanonicalService.php` / `LunarPhpBaziEngine.php` | `ac37d9aabd483fb9eaad35866be828700c48381e` / `3931d10d1560c5198690d33a720813fe98b17400` | 已核旧版rollout选择lunar/legacy，以及真实Solar/EightChar、藏干/五行/大运路径；可作继承和差异参考，不把旧fallback/置信分数或性别缺省值当准确性证据 |
| `services/backend-laravel/app/Services/ZiweiCanonicalService.php` / `app/Support/Ziwei/ZiweiIztroShadowAdapter.php` / runner package.json | `47f2cbd1f914f8bbb7424b25b44b6b45cf6d4099` / `c19b8799e861aaf25b09733c55c7811c40051a1c` / `a5b0873b6aeaa8896a4645fc740b68a290f959f8` | 已核同类seed/轮转估算和候选适配架构；是可复用接口/范围资产，不能补成另有一套已验完整紫微。包和规则仍需独立许可/准确性检查 |
| `services/api/app/services/astro.py` | `0a10c0a1cfcf7d7a5bf52e13cd4e676277d75c1c` | Kerykeion natal/行星/12宫/相位/绘图结构；另有合盘、transit、return方法。natal固定tropical+Placidus、online=False、uses_true_solar_time=False、oracle未验证。仅候选行为/字段参考，不是当前运行或商用授权 |
| `services/api/requirements.txt` | `bbd43d98c799811014f3fa9d1b1f08257c6432bc` | 具名`kerykeion==5.12.7`，不是当前6.x；不自动升级或安装 |
| `docs/adr_western_canonical_route.md` / Kerykeion LICENSE | `c90b18b9d17be851a28e75b9caeb7a86b28fe3ae` / `3e5ba093dbca9c27acc0e3d1d312112065c1c140` | architecture Accepted、commercial authorization Pending；AGPL许可门未消失 |
| 旧Flutter八字/紫微/西占/资料页 | `befdf4c05811cbbde8d41676ee6a018c7d34e249` / `d25d2c694e9f9ba22cb552b854c5a722f14644a3` / `3e445b99a2646d601caef3e19d1bd67df0e02b75` / `da65d389a7ee6e000445f97f306531fb4424577b` | 恢复UI布局/字段/交互参考；逐文件版权与来源须登记，不机械覆盖新API/授权/unknown合同 |

旧库根LICENSE实读MIT；它不覆盖另附AGPL等第三方依赖，不能把整个旧实现的版权链一概称MIT。上表为本次已核实的具名资产，不是旧仓所有文件/未跟踪内容的穷尽清查。

**建议完整盘面清单**：八字四柱/藏干/十神/纳音/选定旺衰地势/五行及大运起运流年；紫微十二宫/命身宫/宫干地支/14主星及具名辅小星/四化/命宫飞星和已选运限；西占十个占星主体（日月、水金火木土天海冥）、ASC/DSC/MC/IC、12宫、逆行/速度、相位及已选扩展点。旧西占有Chiron、Lilith、交点等，须展开core/extended/full的**逐点清单及定义**；一个空数组或换个标签不算恢复。

神煞/胎元/命身宫等八字扩展目前缺实际引擎输出；在本版恢复清单中登记其真实旧实现/规则后落实，不能把页面“-”当完整能力。合盘/行运/回归/法达/推运与付费长报告属于额外时间/解释能力，是否纳入“完整排盘”须在冻结时明确；既有线索保留，未选入的不记为已恢复，不拆成多个宫位/接口版本。

## 4. 引擎与许可证核查、建议组合

截至2026-10-17的上游读取结果；版本建议不是本项目已安装或已准入。源码许可证、传递依赖、数据文件和部署方式分别核验；公开仓库不等于项目自动履行AGPL义务。

| 候选 | 来源/版本证据 | 许可与部署结论 |
|---|---|---|
| lunar-php | 当前composer.lock为1.4.0，source`1443e795c132d63333c358a330117cfe18b1b560`；[固定LICENSE](https://github.com/6tail/lunar-php/blob/1443e795c132d63333c358a330117cfe18b1b560/LICENSE)实读MIT | 推荐继续作历法/八字规则基础，保留NOTICE；不等于所有流派或节气精度已独立验证。LICENSE SHA256`d9210caf1844dcf410095cea464b79800aad30dbd49df092076b9f0ddc015404` |
| iztro | 当前package-lock锁2.5.8；[npm固定元数据](https://registry.npmjs.org/iztro/2.5.8)与仓库锁integrity一致，标MIT；[上游许可](https://github.com/SylarLong/iztro/blob/main/LICENSE) | 推荐紫微基础；同锁lunar-lite0.2.8/lunar-typescript1.8.6/dayjs1.11.21/i18next23.16.8等均标MIT。正式准入须实读包内LICENSE/NOTICE及完整传递链；本次未安装。v2.5.8 LICENSE标签URL返回404，不把主分支文本冒成已取到的固定包全文；当前网页2.6.2新接口不能直接推断2.5.8支持 |
| Kerykeion | 旧具名5.12.7；[PyPI当前元数据](https://pypi.org/pypi/kerykeion/json)为6.0.5，依赖libephemeris3.2.2；[固定6.0.5 LICENSE](https://github.com/g-battaglia/kerykeion/blob/v6.0.5/LICENSE)为AGPL-3.0 | 保持默认blocked。当前[官方后端说明](https://kerykeion.net/python-library/docs/v6/ephemeris_backend)显示默认libephemeris仍AGPL，Swiss后端另有Swiss链；切后端/sidecar/研究标志均不能自动取得闭源商业权利。商业授权须覆盖实际版本和各版权主体，不买则不运行准入 |
| Swiss Ephemeris / pyswisseph | [官方源](https://github.com/aloistr/swisseph)、可核发行2.10.03；[pyswisseph PyPI](https://pypi.org/project/pyswisseph/)2.10.3.2，实际[LICENSE](https://github.com/astrorigin/pyswisseph/blob/master/LICENSE.txt)为AGPL | [官方双许可](https://www.astro.com/swisseph/swephinfo_e.htm)：AGPL合规路线或专业合同。**AGPL并不禁止商业使用**，但当前Owner未批准其项目义务或购买。Swiss专业许可不自动覆盖Python binding/Kerykeion等。未核成新版锁，不宣称此版本是全网最新 |
| Flatlib | 当前gate将其描述为MIT，并注明Swiss传递链 | 不能借外层MIT绕过Swiss门；不是默认替代推荐 |
| Skyfield + JPL SPK | [Skyfield官方](https://rhodesmill.org/skyfield/)、[源码LICENSE](https://github.com/skyfielders/python-skyfield/blob/master/LICENSE)、PyPI当前1.55为MIT；[DE440文档](https://ssd.jpl.nasa.gov/doc/de440_de441.html)及[文件覆盖](https://rhodesmill.org/skyfield/planets.html) | **优先评估的无新增引擎许可费西占天文基础**：固定1.55与依赖锁、官方DE440s（1849–2150）覆盖现代生日；无现成完整占星宫制/规则层，须自有合法实现。jplephem/NumPy/sgp4等、时间尺度及每个SPK数据来源/再分发条件单列SBOM。未下载kernel，不凭“NASA”笼统认定所有数据公版；Chiron等需另选具名数据，不由DE440s自动覆盖 |
| Astronomy Engine | [2.1.19 npm](https://registry.npmjs.org/astronomy-engine/2.1.19)，源码`61dc07020aaa6885d2c7f688a4d82beaf6edb9ef`、[MIT LICENSE](https://github.com/cosinekitty/astronomy/blob/61dc07020aaa6885d2c7f688a4d82beaf6edb9ef/LICENSE) | 可作低依赖备选/独立低精度交叉检查；上游[约±1角分目标](https://github.com/cosinekitty/astronomy/blob/61dc07020aaa6885d2c7f688a4d82beaf6edb9ef/README.md)不是秒级节气或所有宫尖保证。太阳1角分约对应24分钟，不推荐单靠它承诺分钟级节气边界。无完整宫制/Chiron等现成覆盖，不能冒完整旧西占替代 |

**推荐A：lunar-php1.4.0 + iztro2.5.8 + Skyfield1.55/官方锁定JPL数据 + 自有规则/宫制层。** 先用独立参考证明精度和全部必恢复字段可行，再按同一版本接通APP。可控本地Python子进程/sidecar只负责运算，不引入外部生辰服务；采用哪种进程边界是实施细节，不能改变许可条件。需要NOTICE/SBOM、离线固定数据、限时/限输出、安全错误和版本化签名。

**备选B：具名合法商业授权的Swiss/适配层，或明确履行AGPL的路线。** 如A不能满足完整点位、Placidus/Alcabitius、精度或交付成本，集中交Owner选择；未经批准不自动切B、不降验收或暗中排除扩展点。费用、合同覆盖与报价当前UNKNOWN，未购买/联系第三方。零引擎许可费不等于零实现成本或法律审核已完成。

数据准入优先使用[NAIF官方规则](https://naif.jpl.nasa.gov/naif/rules.html)覆盖的原样kernel：规则允许商用及未修改kernel再分发，同时有来源/修改标注等条件；**整套Toolkit镜像再分发另有限制**。Skyfield读取SPK不要求捆绑Toolkit。此依据不自动覆盖从其它实体获取的Chiron等数据；实施前仍须核每个实际文件、hash及适用条款，不能把数据笼统改标MIT。

## 5. 统一输入、规则与数据合同建议

1. 保留原始canonical生日/当地民用时间/地点/坐标及现有私有镜像；新增的是版本化计算上下文，不擅自改正式资料来源。建议记录`input_revision`、时间精度/未知标记、IANA TZ及用户确认/解析来源、tzdb版本、DST fold/offset、UTC/TT/UT1策略、WGS84经纬度/来源、历法/流派、引擎/数据hash、requested/effective参数、result/oracle状态。旧记录缺时区标unknown，不能按当前手机时区或120E静默回填。
2. 全局时区先解民用时为真实时刻；DST重复时刻必须选择、跳过时刻拒绝或由用户明确修正，跨日保留。无联网/收费地理服务要求：沿用合法城市建议，**允许显式IANA选择和坐标确认**；名称不是时区权威，经纬度不是自动授予生辰外传的许可。
3. 真太阳时为八字/选定紫微口径的派生量，保留民用/平太阳/真太阳中间值和符号。不能把已校正的真太阳时再次当民用时转换UTC，更不能用它替换西占实际UTC。缺地点、经度、时区或时间时明确降级；旧12:00占位不生成确定时柱/命宫/ASC/宫位。
   顺逆、起运和安星涉及的非时间参数也须逐项声明语义及现有canonical来源，包含性别类排盘参数的unknown状态；不能把公开资料gender或缺省布尔值冒作用户已确认参数。其变化入签名；若需新增采集/改变资料语义，才交O4决定。
4. 建议默认候选：八字立春年界、节令月界，保留当前已接受日界后再按oracle确定23点/0点与起运规则；紫微显式锁定闰月、早晚子、四化/亮度表和命身宫/飞化规则；西占保留旧tropical+Placidus为主要参照，whole/Alcabitius及sidereal的具体ayanamsha须真实计算。**这些是待冻结建议，不是已批准新流派**；不能让包默认值隐式决定产品。
5. cache key必须覆盖全部输入、时间解析、流派/宫制/黄道/点位/orb、规则/引擎/数据版本；修改任一相关项使旧结果失效。revision/CAS防止旧慢请求覆盖新资料，失败不把旧盘伪装成新盘；只改颜色/布局可不重算。
6. 解释层只能引用带来源和状态的结构化结果，允许关闭；无新LLM外传、收费API或生辰分享默认许可。历法/天文数值一致不证明玄学关系预测有效；**本版即使验真，也不自动把三盘信号加入匹配分数/硬筛选/关系结论**。

## 6. 可执行的独立非fixture oracle方案

“非fixture”指预期值来自独立来源/独立计算和新输入，不能从被测引擎复制。独立采集后保存为回归fixture是允许的；同一6tail多语言实现、iztro衍生项目、APP与API相同输出、上游自带例子都不是独立性证明。

| 层 | 具名参考和执行方法 | 独立性/许可/覆盖限制 |
|---|---|---|
| 公农历、闰月、节气日期 | [HKO1901–2100公农历表](https://www.hko.gov.hk/en/gts/time/conversion.htm)、[24节气定义](https://www.hko.gov.hk/en/gts/time/24solarterms.htm)；记录年份/文件hash、官方时区和表格分辨率，独立转录对比 | 公农历转换表不含每日干支，也不能验证秒级节气；1900及范围外须另有参考，不擅改既有资料可存范围。表和文本再分发按其条款，不大包抓取 |
| 干支日/纪日锚 | 独立选用HKO年历的每日干支日格，例如已查看的[2026年2月官方月历](https://www.hko.gov.hk/en/gts/astron2026/files/2026cal02.pdf)，绑定具体日/页及双人转录；用[USNO儒略日服务](https://aa.usno.navy.mil/data/JulianDate)核日序，按冻结的本地日界推导60日循环 | 日格提取/hash封存和跨年代锚点对照尚待实施前完成，状态REFERENCE_PENDING；不得从仅有年干支的公农历表臆造日锚。USNO只核日序，不直接验证干支或23点换日规则 |
| 时区/DST/UTC | [IANA tzdb](https://www.iana.org/time-zones/tz-link)固定版及转换规则；非作者用另一标准时间库验证民用时→UTC、重复/缺失时刻 | 同tzdb是共同权威数据，独立的是消费实现；历史1970年前可能有资料不确定性，不能报秒级真值。运行版号待实施实读锁定 |
| 日月行星/节气/方程时 | [JPL Horizons API](https://ssd-api.jpl.nasa.gov/doc/horizons.html)与[手册](https://ssd.jpl.nasa.gov/horizons/manual.html)：用虚构坐标/UTC批量取外部结果，固定目标ID、中心、视/几何位置、参考面、时标/修正和版本；太阳黄经根求节气。HKO年历另核日期/分钟级太阳时 | Skyfield+JPL与Horizons可能共享JPL数据，称**独立软件实现/外部参考**，不称独立天文数据源；与实际参考模型差异明示，禁止把重心坐标冒行星中心 |
| ASC/MC/宫制/相位 | [USNO恒星时服务](https://aa.usno.navy.mil/data/siderealtime)验证恒星时；非作者从球面几何及公开宫制定义独立实现/手算ASC、MC与whole/Placidus/Alcabitius；[Swiss技术文档](https://www.astro.com/swisseph/swephprg.htm)核定义/适用域，不复制其受限源码 | 独立脚本不导入生产宫制函数。相位由独立高精经度+冻结orb规则重新判定。极地Placidus无解不得静默以Porphyry冒充；商业比较工具只有许可/条款明确才使用 |
| 八字派生 | 非作者根据独立历法/节气结果、冻结十神/藏干/纳音/旺衰及起运规则，逐步记录四柱/中间表/顺逆与起运；两人盲算抽查，不读被测输出生成expected | HKO/JPL不直接验证十神/旺衰；规则版本/书表出处必须明确。现代解释文案不因古籍内容而自动获版权 |
| 紫微 | 具名规则源候选：[《紫微斗数全书》卷二安身命/安星原文](https://zh.wikisource.org/wiki/紫微斗數全書/全覽)；将选定条目及版本定位，与冻结四化表逐项映射，由非作者独立手推十二宫/主辅星/飞化边；新样本不复用A/B/C。温墨外部排盘仅在版本/设置/条款/实现独立性已核时作辅助 | 古籍不同流派不天然等于iztro口径；闰月/四化差异必须先裁规则。电子转录/现代批注有自己的许可，不整段搬入产品。**完整现代四化/亮度/飞星oracle尚未取得，本次仅定位可核源；此缺口阻止宣称已验/直接冻结无条件完整通过**。若选定规则无法独立支持，回Astra/Owner决定，不能自己生成expected |

建议按[计划候选](PLAN_CANDIDATE.md)的数值和离散标准执行：新采样、分层边界矩阵、候选固定后非作者追加盲测；全部保存输入/设置/来源/hash/期望/实际/偏差/状态。外部查询只用虚构生辰；不上传真实资料。不调用受阻AGPL引擎来“偷做oracle”。oracle的原始可获取性和字段覆盖先验证，缺参考字段不得标verified。

## 7. 版本范围、风险与集中决定

一个版本内顺序为：完整能力/规则表与oracle准入 → 时间输入纵向链 → 三盘引擎与独立验真 → canonical/API/APP/缓存持久化 → 实装APP和真实隔离DB验证 → 内部非作者复核 → Astra综合终验。不是每个宫/接口另发版本。完整验收候选见[PLAN_CANDIDATE.md](PLAN_CANDIDATE.md)。

| 真正需决定的事项 | 推荐与明确备选 |
|---|---|
| O1：无现行唯一权威的流派/时间规则 | 推荐保存既有八字已接受行为并显式锁规则；紫微选一套有完整出处和oracle的安星/四化/闰月/子时规则，命宫飞星使用同表同方向；西占明确sidereal ayanamsha。备选为其它具名流派，须单独预期矩阵，不能混表。Astra可提出最终profile，Owner确认确有产品差异部分 |
| O2：“完整”扩展能力与输入适用域 | 推荐核心三盘+具名旧natal扩展点/原版实际排盘能力全部进同版，逐点展开full，不把演示/空值算恢复。需Owner裁定旧合盘/行运/回归/法达等是否也为本版必达；不能未经确认删去旧功能或宣称全APP完成。缺时/极地建议明确部分盘/不适用而非假值；若要求自动另选宫制或强制默认时间，属重大合同取舍 |
| O3：零新增引擎许可费路线不足时 | 推荐A先做能力/精度/许可可行性门。备选B须Owner明确AGPL合规发布还是具名商业合同/费用上限；Kery/Swiss/binding分别确认。当前不购、不联系、不自动fallback，不以微服务隔离当法律豁免 |
| O4：仅若突破现有私有资料合同 | 默认保留canonical来源、用户确认时区/坐标，解释本地且可关闭。若要自动地理外发、云端解释或扩大新敏感字段/共享范围，才需要Owner新增数据/隐私授权；本方案不依赖这些扩权 |

主要风险是：规则源与引擎非同一口径；新“full”仍漏旧点位；时区与真太阳时二次校正；不同参考系的假误差；极地宫制暗换；旧noon/seed/缓存污染正式事实；研究模式或外层MIT掩盖AGPL/数据条款；未验证输出回流评分。按字段状态、来源链、独立盲测和真实权限回归逐项防止，而不是用更多演示替代。

## 8. 交付终点

只交本报告与一份正式计划候选，不改产品源码、活动状态、Owner决定或旧AC。所有新算法/部署/DB/安装/测试结果为**NOT_RUN**；不授权实施、生产、历史数据、购买许可或新RTC窗口。

**V10.0.10 PREPLAN_READY / AWAITING ASTRA PLAN REVIEW / IMPLEMENTATION_NOT_STARTED**。Astra审阅并集中解决上述冻结事项后，才能形成正式plan；Owner另行派发才可实施。
