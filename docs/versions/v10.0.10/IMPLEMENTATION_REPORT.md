# v10.0.10 三盘本命恢复：综合实施与阻塞报告

## 2026-10-18 完整本命候选集中交付（当前唯一状态）

**V10.0.10 FINAL CANDIDATE DELIVERED / AWAITING ASTRA INDEPENDENT ACCEPTANCE / NOT_YET_ACCEPTED**。方案A及冻结plan Blob `2057aa81e5c36da3236861ff767aed1c4fceb141` 未改；这是一份综合候选，非接受、main集成或K08。以下旧章节按原时点保留，其 BLOCKED、NOT_RUN、旧build与旧HEAD不能覆盖本节，也不反向改写原失败。

产品源码 Commit **`2be08468754c7b1ad453f9eb0b7085050b3aaf99`**；Tree **`8c893d71984ff9cdece9b22718ade86ab9bb5f2f`**；apps=`01b58edcfec2766a1e764231d4098c0d61ea6d95`；services=`c72d392f37968e20d1b48d2252a9549c2b0d04dc`。本节及交付登记的后继纯文档提交不改变这两个产品子Tree。开发分支 `codex/v10.0.10-natal-restoration`；正式main本次只读为 `234b0cc1fc30b163a80bbbb9ebaa487720cf5234`，未合main。代码相对K08的范围为Flutter本命输入/盘面/真实设置及相应私有Laravel、迁移、独立PHP/Node/Python计算器/锁/NOTICE/测试；本轮相对24ac的精确路径见validation-summary的source.paths。没有RTC或匹配评分新增功能。

[最小公开安全审阅副本](https://github.com/zcx369658780/EliteSync-v10/blob/10bd9be1b7c6d14fa16003a266845d5f40fe32ab/docs/_temporary_review/v1010-natal-final-20261018/README.md)：分支 `review/temporary-evidence-v1010-natal-final-20261018`，Commit `10bd9be1b7c6d14fa16003a266845d5f40fe32ab`，Tree `a4f90066863936679cde69185147740ea56a59d4`，91文件／71个唯一blob，GitHub API逐路径及内容回读全等；原始LOCAL_ONLY未上传。MANIFEST逐项列原件SHA256、公开副本SHA256及脱敏方式；GitHub可读源码/副本不等于Astra已核验Windows执行。分支不得合产品/main；保留到Astra审阅及具名、精确HEAD清理授权。

| 冻结AC | 本候选真实结果、来源与适用限制（交Astra逐项裁决，非自授ACCEPT） |
|---|---|
| AC-10-01 来源/许可/完整性 | lunar-php1.4.0、iztro2.5.8＋三格官方数据勘误、Skyfield1.55及固定DE440s/时表；34个具名NOTICE文件再次核hash。Lowell元素及自产Chiron轨道以明确署名use/copy/transmit许可准入；不用Swiss/Kerykeion/pyswisseph/NIMA/Horizons Chiron或MPC原观测。旧具名能力、动态关系盘强制后续欠账、SBOM/来源/锁保留。 |
| AC-10-02 输入/历法/TZ | 实装APP生日/民用时精度/unknown、IANA TZ、坐标和独立算法性别→Laravel校验→私有表；原DST gap/fold、子时/岁首、节令及负例保留。最后新增合法原生日旁两日的太阳日期派生padding，1900/2101边缘不冒称独立历表已验；canonical保存合同不扩张。 |
| AC-10-03 八字 | 四柱/藏干/十神/纳音/地势/五行及大运/起运/流年/胎元胎息命身宫真实计算。原64＋24盲选2200比较、起运249/Gregorian90、扩展及纯规则5760等各自适用；跨年代24例600字段与日历标签补充一致。4848独立节气根、2424节最大2.626秒差；五寒露样本获独立秒网格下sect1/Gregorian条件化核对，原HKO分钟不确定性不删。现代Gregorian顺序截月末/时区/量化是具名兼容约定，不称传统唯一秒级物理真值。 |
| AC-10-04 紫微 | 单一冻结iztro-compatible profile的十二宫/命身/宫干五局/66星、四化/自化/有向命宫飞星、亮度与选定大限/小限/流年真实输出。232格有具名明表；原5040基本规则、102运限快照10464行、16岁首800行、24新selector边界2470行及原24盲选保留原范围；本轮17星72缓存1224项、命身主/来因/本命岁前将前2736项均一致。长生864＋1200、博士864、年系180、固定截空名称120等不叠加成覆盖率。童限附加四化/10流曜30例420仅现代profile组合一致性，古籍适用源仍未证；不借其它派别拼表。月星闰月为通则组合，刻本/异文及来源谱系限制保留。 |
| AC-10-05 西占 | 十主体/四轴/三宫制/落宫/相位/逆行、具名CRC1956自定义恒星黄道、真交点轴、平均Lilith及Chiron，full实算14点。保留96＋24主体参考、288几何、120月点/28定义补盲等各自证据。Chiron独立外部初值/force软件96＋24新时刻＋20停滞点邻侧比较最大黄经差0.000113555°、纬度0.000064144°，阈值0.001°，逆行一致。不是官方Lahiri/旧引擎逐位等价，不证明全世纪连续物理误差；极地/缺时/未准入数据正确拒绝或降级。 |
| AC-10-06 APP/API/持久DB/缓存 | 当前APK实际安装，UI修改01:05:06→01:06:07至A5；最后后端修复触发STALE隐藏，APP再保存至A6，B以最新源码重算至31。逐一核实际source_hashes、full14、同输入缓存、GET和旧编辑409。之后只重启本版API＋原虚构MariaDB/volume，两行SQL字节及API profile前后一致；APP进程冷启动重入可见A6/6。canonical生日未改，未重建/seed。日期/时/TZ/坐标/模式变化回归按此前适用范围复用。 |
| AC-10-07 权限/既有合同 | 最新50项PHP涵本人/非本人、禁用者、过期编辑/过期计算、异常及runtime/data cache使用点；原真实API鉴权401、越权query无效、422不覆盖结果保留。Flutter23项涵会话切换/设置/旧动态入口保护。CN/MC/匹配代码合同未改，不新增玄学评分/硬筛选；全历史/RTC NOT_RUN。 |
| AC-10-08 构建/安装/交付/复核 | 当前AAR/APK、本地stdout/stderr/exit、数据/源码/依赖hash、原失败及非作者只读累计复核已关联。内部复核无确定缺陷，不替代Astra精度、权利或版本独立裁决。498个客户端构建输入当前字节仍相同；后端末次修复后的真实重算/重启已单独完成。 |

实际最终检查：PHP **36 passed＋14 deprecated，9022 assertions，exit0**；Node主测试**10/10、0skip、exit0**；Western **15**、Chiron reader **7**均exit0；Flutter **23通过**，修改文件analyze无问题；19项portable构造/身份校验通过但未积分。原period-domain/clock、算法oracle、权限回归按影响复用，不与本轮数相加。最后新增参考只重放原30/420缓存，产品新运行0。语法/JSON、6项制品/构建pin、8项staged blob与原字节、34 NOTICE及无冲突阶段检查通过。字节pin故意保留CRLF；默认diff-check的CR尾误报原件保留，以命令局部 `cr-at-eol`重新识别后检查通过，未改全局Git或轨道字节。

APK **`d340e30b543a290c373c6405a66d6b6f8f27d65741dcfa14083f53ede0981cd2`**（222959834 bytes）；AAR **`dca5a7d4b24d7ce01fb53ffb4053f195dcf5266d172dcb48e942013f947a19e0`**（4030249 bytes）。是本版隔离开发测试包，显示版本仍0.08.04，不伪称已发布正式0.10包；旧build4仅代表旧源码。

Chiron自产轨道SHA256 `b8172992366c783e8cc65789e4837f432d3cb496c5f503b1a776275518a059e3`，438113 bytes、9182个8日节点、1900–2101含padding，builder逐字节重放一致。独立Gaia拟合初值只留内部参考，不分发原始状态/协方差；共享行星数据与有限力模型、遗漏小行星/fullEIH/J2/NG/协方差传播均在清单中。24例只有输入selector盲，主runner NOT_BLIND。这里的独立采样/规则证据不把所有盘面UNVERIFIED自动改成VERIFIED，也不宣称任何玄学预测效力。JPL/NIMA仍SENT/REPLY_PENDING/RIGHTS_NOT_GRANTED，本次无新邮件、查信、监测或费用请求。

最后安全收口：测试APP/API/本版DB已停，8010 reverse已撤，volume/数据/临时socket备份及全部旧原证保留；受控AVD与Docker Desktop留运行，没有停止其它项目。原dirty根HEAD/index/status及43项记录hash相同；不声称重哈全部untracked媒体。原PHP16既有失败、AEC/回声观察、call65额外DB/room终态缺证、旧/up根因UNKNOWN保留。原503/RED、默认diff-check、脚本字段KeyError、启动health首失败及所有科学差异记录保留；health次读通过。无生产、旧敏感DB、UAC/防火墙/全局SDK、RTC、main合并/K08或下一版。

**没有新增Owner费用/权限/流派决定请求。等待Astra按冻结8AC独立接受或集中指出真实缺陷；Codex没有宣布ACCEPTED。**

---

## 2026-10-18 当前事实增补（最终核验进行中）

**FINAL_VERIFICATION_IN_PROGRESS / NOT_FINAL_CANDIDATE / NOT_ACCEPTED**。主代理稍后填写最终源码identity；本节不预填或推定该identity。新增核验仍为 **CODEX_REPORTED / LOCAL_ONLY**，不是Astra终验。下一个章节及其后全部正文保留为历史记录，按当时源码和证据时点理解。

Lowell `astorb.dat` 作者条款明确允许署名后free use/copy/transmit；当前官网及CDS具名ReadMe已核，来源权利已登记于notice和manifest。许可仅覆盖所选轨道元素与自产轨道，不延伸到CDS其他catalog、MPC原观测、Gaia原数据、NIMA/Horizons或Swiss。JPL/NIMA仍待回复且未授予权利，不启动替代联系、邮箱查询或购买。

Chiron使用Lowell 2021-03-27 TT初值（3186条观测、45945天弧）；Gaia独立拟合初值仅作内部参考。自有太阳、主要行星、EarthMoon和solar 1PN有限模型，以DOPRI54及8日Hermite生成1900–2101含pad的9182节点。离线builder重建产物 SHA-256 `b8172992366c783e8cc65789e4837f432d3cb496c5f503b1a776275518a059e3`（438113 bytes）；八个源码/数据pin逐字节核对通过。constructor/身份验证19项仅检查构造、导入和method binding，**未积分**。原96日期Gaia独立force/DOP853/ERFA对照和新增24个selector时间、20个停滞点邻近参考时刻，最大黄经差 `0.00011355449294114806°`、纬度差 `6.414310619362595e-05°`，逆行一致；距离/速度只作诊断。selector只对输入选择盲，主runner **NOT_BLIND**，共用物理模型和行星数据，不能建立世纪连续误差界；小行星扰动、完整EIH、J2、非引力项、协方差传播仍未覆盖。120区间×3点插值误差只说明数学插值，不是轨道oracle。原closing失败、路径exit2和重复样本guard exit1保留；compare重放未重积分expected。完整限定与许可来源见本报告旧记录。

本轮选定源码PHP结果为36 passed、14 deprecated、9022 assertions（`20261018-final-source-all-v1010-php.stdout`）；时标CLI为15 tests，衍生太阳日期Node为10/10、PHP为1 test/14 assertions。JSON cp936中文编码已改为ASCII转义，原503及RED记录保留。派生太阳日期只在canonical出生域1900–2100旁最多扩展2天供计算，不扩大canonical范围；输入明确标为 **UNVERIFIED**。童限边界使用72例缓存×17项=1224项，产品新运行0；chart-marker对照为72×38=2736项，产品新运行0。年解/天德/月德180项及固定截路/空亡120项保留来源边界；66个本命星位有具名参考，但代码和数据查表推导不等于整派认证。紫微亮度余下8个表格空位不是缺格，来源谱系/刻本限制及阴干反例均保留。比较回执只证明已列案例，不升级整体AC或字段 `VERIFIED`。

当前APK本轮构建成功并安装，APK SHA-256 `d340e30b543a290c373c6405a66d6b6f8f27d65741dcfa14083f53ede0981cd2`；旧build4不能代表当前源码。A盘UI将 `01:05:06` 修改为 `01:06:07` 至revision 5，并有API/DB读回。较早A5/B30持久化与重启结果尚未绑定此后源码边界修复，需待主代理最终固定源码后再做最终存储核验；API请求总数以主代理实际summary为准，本节不推算。Docker两个临时socket目录仅改名并完整保留恢复；未reset、改volume、配置或密钥，数据库当前运行。最终复核及最终candidate identity仍由主代理收口；没有新增Owner决定。

## 2026-10-18 持续实施：独立规则与实际边界补齐（当前）

**CONTINUE_SAME_VERSION / NOT_FINAL_CANDIDATE / NOT_ACCEPTED**。沿用方案A和冻结AC。本地源码已保存 `24ac02cf21cc56a1d74c33e7587460e99d3a2af3` / Tree `8ce86fd0bb3086a1bae8321618bf076c3a5a13c5`，apps=`52e4a3ea6878e9c5fcc16fc352aef358e99d4602`、services=`9012fbcfda4a49d786f3e763a978b27e2451f360`。本轮8个精确路径含有限运限哨兵修复、APP不适用层、相应测试及永久独立参考/计算说明；前次232格亮度等成果保留。只读远端核验main仍 `234b0cc1fc30b163a80bbbb9ebaa487720cf5234`，开发分支仍 `4222645703821ab20896765a31df1cfa375034ca`。未推送微型检查点；结果为 **CODEX_REPORTED / LOCAL_ONLY**，不是Astra终验。

| 已完成工作 | 真实结果与适用范围 |
|---|---|
| 主星与辅煞完整亮度明表 | 非作者不读actual，按《紫微斗数全书》同一公开矩阵提取十四主星168格；75个既有输出1050次读取全部吻合。六辅煞另450次读取覆盖64格亦全部吻合；两者共232个具名来源格，不把重复读取当新增覆盖。同页太阴正文与矩阵存在异文，在线转录的具体刻本尚未证；不再把这部分笼统称为“只有未知程序表”，也不宣称整派认证。 |
| 可继续使用的规则参考 | 自有独立 `ziwei_brightness_reference.py`＋具名来源JSON已保留。72例独立位置＋亮度1440联合比较一致，覆盖218格；完整232格另见上述75缓存比较。非作者复核无确定缺陷，并补齐位置规则依赖hash。未改生产亮度数值/包版本或VERIFIED标签。 |
| 寒露五个敏感输入 | 公开、无生辰太阳网格取得Horizons DE441/Q31/IAU76-80独立模型括根。UTC18:59:58～59两端对应+08同一 `[01:00,03:00)` sect1桶；独立参考先固定，当前Bazi直接类5例35字段一致。五个源码文件另逐一核SHA256和722 Git blob相同。原HKO五例REFERENCE_UNCERTAIN不删；结论是模型条件下sect1/Gregorian交叉验证，非物理唯一秒、框架等价、盲测、全部88例或全部AC。 |
| 闰月四星 | 12例×4星48位置与来源结构推论一致；讲义通用上下半月规则及月星分类支持推论，但没有逐星无例外明文。保留原48个NOT_ASSERTED，不把推论吻合升级为全流派认证。 |
| 本命农历年界与早晚子 | 非作者先冻6个HKO日期×男女×00:00/23:00共24例；当前Node适配器实际运行。公农历、年干支、五行局、命身/宫干宫职、43具名星位、四化及有向飞化共3384比较行一致。部分比较行包含多个字段，不冒称3384独立样本。只证选定current-date子时与这三次本命岁首，不含运限年界。 |
| 已起大限切换 | 独立参考覆盖五行局2～6×男女10组，首限首年/末年/次限首年共30例；当前适配器实际运行，1080比较行一致，含名义年龄、宫干支/index/区间方向/12宫职/四化目标与七曜。不覆盖首限前童限、所有年龄或农历运限岁首。 |
| 七类剩余流曜 | 72例共504位置与具名规则一致，包含原144流年鸾喜，不能叠加。运马有层别明文；大限鸾喜限现代三合；流马原参考仍SOURCE_CONTEXT_INFERENCE；年解有深造讲义转载依据。额外作者说明补强流年马按当年支，但程序谱系/刻本未知，不倒改已冻结来源等级。 |
| APP运限与定义域修复 | 大限/小限有限表未匹配时，不再把引擎默认甲子和index=-1序列化为有效结果；明确NOT_APPLICABLE和中文原因，保留有效本命/流年，畸形或流年负索引仍报错。默认与v1010两模式各23项通过，analyze无问题；Node最终12项通过0skip。原RED和原22/9项保留，不叠加计数。 |
| 童限与小限 | 30个童限当前组件结果加72个旧小限缓存，2358行一致。童限古表仅佐证六龄角色，现代五行局截断是profile组合；童限四化/流曜仍SCOPE_NOT_ESTABLISHED，小限四化仍是明确登记的数学组合。 |
| 运限农历岁首 | 2个出生输入×8时刻共16真实引擎组件例，800行一致，含2023/24/25春节前后、元旦和立春次日。不是HTTP任意target_date能力或APP/DB实测。 |
| 永久选定运限参考 | 独立selected oracle与来源JSON已保留，102例复用缓存10464行一致（72×107＋30×92）；不运行旧产品集合，不扩增盲测。非作者发现stdin hash实际指输入文件的回执命名错误，原件保留并以独立补充区分文件hash和按原表达式重建的载荷hash；输入语义与比较值未变，无产品重跑。 |
| 新盲选运限边界 | 无父历史助手先冻结24新组合（男女各12，HKO1901首月），再以当前适配器运行，2470比较行一致。含局2～6童限→首限、小限120/121及12大限末段/越界。仅selector对actual及父结果盲，复用原独立规则，不冒称新文献/新实现或全域。 |
| 截空／旬空来源与反例 | 新永久pair/正旁参考获中州派转录明文支持；60周期的pair60与旬空正支60一致。将截路恒等正、空亡恒等旁的假设在30阴干例失败，原180行对照exit1保留；这是别名假设失败，不能据此交换产品星位。非作者复核确认旬空选择的源证可限定关闭，截路／空亡名称映射仍未证。 |

除另列24例无父历史盲选外，本轮复用参考生成与比较均按 **NOT_BLIND** 解释；来源提取未读actual不使整个补证成为新盲测。24例只新增具名边界的selector隔离，不把底层参考实现/来源重新认证，也不与旧24例或复用比较数合成覆盖率。各项有重叠，不能相加当完整AC通过数。

新增Node运行只针对尚未验证的24＋30边界例；亮度、闰月、流年鸾喜尽量复用已绑定的缓存，没有重复全量PHP/Node/Python/Flutter、RTC或旧APP/DB验收。所有指定验证回执包含stdout/stderr/exit；辅助脚本引号、缺脚本exit2及路径/字段检查错误保留，修正后缓存比较不冒称修复了业务算法。原全部RED、PHP16项旧失败、旧观察和原证不覆盖。

JPL/NIMA保持 **SENT / REPLY_PENDING / RIGHTS_NOT_GRANTED**，不查邮箱、不重发或付费。限定替代研究已排除以CDS观测记录冒充星历；Ketu的MIT软件标示不能解除其Swiss生成系数数据权利门，作者误差声明也不是独立oracle；ChironCalculator表来自Horizons、仅到2050且未确立再分发许可。Lowell/CDS ReadMe明确astorb署名后自由使用/复制/传输，但只声明多数对象epoch±50日二体精度，未核Chiron世纪精度。本轮均仅资料/元数据，未取轨道数值或集成数据。剩余真实缺口是Chiron适用权利/世纪参考、童限未证字段、截路/空亡独立别名、月星闰月逐项适用及完整单一profile来源限制；不再把已完成的102快照/16岁首子集笼统标为未做。寒露仍为模型条件下证据，冻结AC未降级。

最新源码对应APP/AAR/APK构建安装、HTTP→MariaDB重算/重启均 **NOT_RUN**，旧build4仍仅绑定其旧源码。独立内部复核不是Astra最终验收。原dirty根HEAD/index/status/43项记录hash在两次源码保存前后相同；没有遍历重哈全部untracked原件，也没有删除/改写卷、私有资料或历史资产。未启动服务、未碰生产/UAC/防火墙/RTC/全局SDK，未合main/K08/下版。当前没有新增Owner决定请求；本任务继续同版，保留其它可推进工作。

下节为此前源码时点的记录，所写未覆盖/无来源须与本节新增的具名证据合读，不能反向覆盖本节。

## 2026-10-18 同版实质修复与剩余证据边界（当前）

**CONTINUE_SAME_VERSION / RIGHTS_AND_ORACLE_BLOCKED_FOR_FINAL / NOT_FINAL_CANDIDATE / NOT_ACCEPTED**。Owner继续方案A，固定Astra审查为 `234b0cc1fc30b163a80bbbb9ebaa487720cf5234`；已实际回读其正文和NIMA邮件已发送附录。NIMA/JPL均为已发待回复，**SENT / REPLY_PENDING / RIGHTS_NOT_GRANTED**；本轮未发信、未查邮箱、未建立新监测。冻结plan Blob仍为 `2057aa81e5c36da3236861ff767aed1c4fceb141`，八项AC不变。

本轮已审查源码保存在本地同一开发分支 Commit **`e86db6e24907ed91c342f21a0dbe6c9f99dc38bd`**，Tree `9c067e755c1da545dc36bc4d6dbaa07be8ddc53e`，父 `4222645703821ab20896765a31df1cfa375034ca`；apps=`c4f659466ca9b9d1a195e901478808db594c4ca0`，services=`2cd1d3fbce25eee64fd84ea169784e7b67c18e5d`。18个明确路径，仅涉及本命适配器/时标/规则身份、相应Flutter提示、测试和开发说明。此提交是**同版源码保存，不是最终候选或新增验收轮**；尚未推送，远端开发分支仍为 `4222645`。后续本报告更新不改变其产品子Tree。

### 已修复的真实问题

1. **八字节令时标**：lunar-php输出标签来自模型UT1＋8，不可直接冒称UTC＋8。本轮恢复未舍入TT根，以TT半开区间选年月柱；1960起由ERFA含橡皮秒/闰秒转换，1960前明确模型UT1，未来闰秒未知。真实出生和正确邻节端点交给独立起运投影，未拿区间内部代表生日计算Yun。声明不符或转换失败则关闭本次计算，不默退旧框架。新源码、规则及同次西占time_context身份进入缓存签名，registry为1.0.2。
2. **酉宫三格亮度**：固定上游[Issue270](https://github.com/SylarLong/iztro/issues/270)及[2.6.1发布](https://github.com/SylarLong/iztro/releases/tag/v2.6.1)明确是数据错误修复，不再把三格笼统归为待Owner选流派。包和锁仍2.5.8，仅显式回移太阳酉陷→平、太阴酉不→旺、七杀酉庙→旺，保留engine原值/修正profile/source。2.6.1固定源码及MIT通知已核；没有改vendor、升级其它规则或拼表。完整独立亮度认证仍未关闭。
3. **身宫丑位天干**：同一年干五虎遁的offset12被旧公式取模成0，少两位天干。只修正丑位，保留精确legacy重放和修正标识；命宫、宫支、四柱、起运及大运/流年数值不变。明确现代节令月兼容口径，不冒称古籍中气法。

### 独立参考及定点验证

下列数量按各自字段解释，存在重叠，**不可相加当作覆盖率或AC通过数**。原RED/不确定样本全部保留；原始参考、外表及stdout/stderr/exit保持LOCAL_ONLY，公开汇总只列身份/数量/范围，结论为CODEX_REPORTED。

| 范围 | 实际结果与限制 |
|---|---|
| 1900–2101节气参考 | 独立Skyfield/DE440s共4848节气；新适配2424个“节”TT最大差2.625948秒，误差阈值仍60秒；根相对参考±61秒两侧的4848条不等式成立。这是根位置比较，不是另跑4848次适配器分支，也不把61秒当放宽后的精度阈值。参考根宽不等于物理精度，NOT_BLIND；与西占共享引擎/数据，不是独立观测。1960–1971参考日历标签未用ERFA橡皮秒，144个标签排除同口径日历比较，TT根仍可用；v1原件保留。 |
| 起运与Gregorian | 新路径88输入中83明确样本×3=249字段一致；原5例仍REFERENCE_UNCERTAIN，均接近2024寒露03:00量化桶。独立参考02:59:57.338861（+08）距桶约2.66秒，不能凭显示秒数追绿。Gregorian30×3=90一致；sect1/2库兼容投影8685断言通过，兼容算术不等于秒级物理交运。 |
| 八字扩展 | 胎元/胎息88×4=352字段一致；命/身88×4=352一致，后者含78旧＋10新结果，未冒称最新88全metadata重跑。1440纯规则5760字段一致；仅120个丑位新旧有差，legacy全部等于旧值，命宫0变化。10受影响完整结果递归比较只见指定宫修正及明确新增时间说明，其它数值不变。 |
| 紫微余星/系列 | 日系4星72例288位置；15余星1032位置（48个闰月月星仍NOT_ASSERTED）；博士十二星864；小限72＋543=615位置；长生十二神72×12=864支位，均一致。长生另100个纯规则单元未运行产品，不计入通过数。现代源和古籍方向异文保留，不能认证全派同等。 |
| 选定大限/流年 | 72例6048个具名字段检查一致，覆盖宫干支、区间/方向/宫职、四化目标、两层7曜、流年岁前/将前；与原1512等重叠。马/鸾/喜/年解288个原未断言项仍保留；未把规则局部一致当完整运限验真。 |
| 截空等杂曜 | 72合法输入四杂曜288、截空无序pair72、旬空正支72一致；60干支纯周期四曜240、截空pair60、旬空正支60一致。纯周期NOT_A_CIVIL_DATE；截路/空亡各自正副标签映射仍NOT_ASSERTED，旬空成员/正支重复约束不累计。 |
| 主星亮度外表 | 当前72＋3输出共1050次比较覆盖168/168格，差异/缺格/内部不一致均0；只沿用原先明示的得→得地、不→不得地别名。太阳酉新值平亦吻合。外部表上游UNKNOWN，不能排除共同来源，非完整独立oracle认证；外表无开放整表复用许可，未复制进产品/公开测试。旧18差异、另一表63格异文均保留。 |
| PHP定点套件 | 47 tests / 8996 assertions，exit0、无skip；2 Deprecations＋2 PHPUnit Deprecations保留。实际指定本版Python/kernel，含2项真实身份探测；不是全量PHP。 |
| Node/Python/Flutter | Node9通过；Python时标3通过；Flutter本命提示19通过、两文件analyze无问题；Pint最终exit0。后续仅测试import格式化，不再改生产源码。 |
| 服务类smoke | 实际Laravel bootstrap→本地Python/Node计算exit0，八字/西占TT一致、runtime AVAILABLE、Chiron关闭。没有启动HTTP或DB；不等于APP/API/MariaDB验收。 |

非作者Sol/high复核未发现新确定性问题，前次所需身宫窄回归已补足。已核fail-closed、TT半开区间、闰秒不夹值和新增源码/cache身份；独立参考作者先固定expected再比产品。纯规则单元、外表对照、代码单测和真实APP链仍分开报告。

### 尚未关闭的真实门与下一步

- **Chiron**：NIMA/JPL许可答复仍待自动提醒，本轮没有查邮箱或发信。新增[Lowell官方astorb说明](https://asteroid.lowell.edu/astorb/)及[原始官方条款](https://ftp.lowell.edu/pub/elgb/astorb.html)有署名后自由使用/复制/传输的明确许可线索，适用于其具名astorb.dat，不能扩张到MPC观测、NIMA或JPL文件。独立来源核查亦读到旧条款；官方只说明多数非近地对象当前epoch前后约50日二体精度，不是Chiron1900–2101保证。当前文档和带“先核条款再取数”守卫的本地读取均在条款TLS握手超时，**未发起轨道文件请求**；未获得数据或运行Chiron。Lowell是应继续核查的免费来源，不宣称其不可能合规，也不以公开下载充作最终准入。
- **紫微**：完整亮度及辅煞亮度的独立源流、48闰月月星、截路/空亡正副标签、剩余完整流曜及年界仍未齐。王亭之讲义的第三方转录只支持大限宫支起流马，未证明流年马/鸾/喜或层别年解，不拼其它派规则追绿。
- **八字**：5个量化敏感例及完整年代/节气边界的物理参考精度仍需收口；未删例或放宽guard。现代Gregorian兼容规则已明确，不再作为普通Owner审批问题。
- **西占**：十主体/宫制/相位及已有独立定义证据保留；CRC1956是自定义具名重建，非官方Lahiri；mean Lilith非瞬时远地点，真交点非平均交点。旧默认18点真实范围为十主体＋真南北交点＋Chiron＋Mean Lilith＋四轴；Earth/平均交点可选serializer键不被冒称旧已启用能力。Chiron仍为必达，full仍PARTIAL_FULL。

AC-10-01/03/04/05/08仍未全部关闭，02/06/07保留原真实链及适用范围，**无整版PASS**。旧build4属于旧源码身份；本轮最新源码的AAR/APK构建安装、APP→HTTP→MariaDB重算/重启实链均NOT_RUN，待剩余必达证据收口再统一执行，不能复标旧包。

收尾只读运行核查：本版8010/8011/43320端口无监听。Docker守护进程当前不可用，具名容器/volume的独立inspect均exit1；没有为补证启动Docker，不能将本次读取写成容器/卷存在或停止状态的重新确认。既有停止回执保留其历史身份，本轮未执行删除/修改卷操作。

原dirty根HEAD/index/status/43个记录hash在保存前后相同；未遍历重哈全部历史untracked媒体。无reset/stash/clean/prune、无历史卷/资料清理、无生产/付费/UAC/防火墙/RTC操作。main未改，未K08或下一版。当前没有重复请求方案A/NIMA发信或普通技术权限；集中权利与参考状态沿用[同一Owner决策文件](OWNER_DECISION_REQUEST.md)，不另造检查点/微型任务。

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
