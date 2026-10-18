# v10.0.11 动态星盘与关系盘｜实施综合报告

**V10.0.11 CANDIDATE_READY_FOR_ASTRA / NOT_YET_ACCEPTED**。Synastry/Comparison、Transits、Solar Return、Lunar Return 已完成本版候选实现、独立数学参考、真实安装 APP→Laravel→隔离 MariaDB、重登及服务/数据库重启读回。以下运行结论为 `CODEX_REPORTED`；公开脱敏副本允许 Astra 核阅，未上传的 Windows 原证为 `LOCAL_ONLY`。内部复核不替代 Astra 独立验收。未合 main、执行 K08 或启动后继版本。

## 1. Authority、源码及制品

- 唯一冻结计划：main `f4b547f11ced66065a53ffae816db34c210f7009`，`docs/versions/v10.0.11/plan.md`，Blob `eb6de5a0ef6cdbd0cc8aa2fd35826a22b88b63d9`。实时发布前 main 仍核对同一身份。
- 最终产品源码锚：Commit `78ab7827b258cb649920e5121f24d506dae2a93c`，Tree `6f3edd909f37a3a0b8ecaf3fa8da1af02a47f186`。
- apps Tree `fc925bd85ed9c5ced157ae7dc3cad2b0aabe62c7`；services Tree `29cedff599411c7c246ba32e62d53b5d63e28f3f`。
- 产品分支 `codex/v10.0.11-dynamic-relationship-charts`。其交付提交还包括本报告和四份活动状态的最小更新，产品对象与上述源码锚一致。精确交付 Commit/Tree、临时审阅 Commit/Tree 由最终远端回读及审阅包固定，避免报告自引用 SHA。
- 独立短期审阅分支 `review/temporary-evidence-v1011-dynamic-final-20261018`，目录 `docs/_temporary_review/v1011-dynamic-final-20261018/`；只放公开安全副本，不合入产品分支/main。审阅后须具名授权及精确核头才能清理。
- 新增/修改21个产品及测试路径，2735行新增、7行删除；范围为 Android 独立本地构建门、Flutter页面/轮盘/路由/测试、Laravel服务/控制器/中间件/model/迁移/API/测试、动态profile、Python算法与独立参考。未新增依赖。

| 制品 | 身份 |
| --- | --- |
| 实际安装包 | `com.elitesync.v1011test`；debug APK 223025370 bytes；SHA256 `67aa8b7d33dbbbf8ce225612943583e8a898a0b23c3e1ebae593e5baadde7943` |
| AAR | 4027105 bytes；SHA256 `8126dd9fdc90bdb578b2c3c0d4e7522221b56dac4247fe496423f68d4b133ac0` |
| 构建绑定 | 实际构建于 `988e9d9b521d445141f70db06358bf7913d85fae`；其完整apps Tree与最终源码锚完全相同。随后只改后端Python、registry和测试；APK回拉字节一致，并由该已安装APP实际调用最终后端重算/重读。后端修复后重复构建 `NOT_RUN`，以完整apps对象相等复用有效构建。 |
| 环境 | 既有受控AVD、已有JDK17；显示版本0.08.04/code80400，不是正式运营版本。未升级全局SDK/JDK。 |

## 2. 实际恢复功能与合同

**双人盘**：双方由用户主动手填，或明确选择本人已确认私有本命快照；完整准入14点、A×B跨盘相位（含同名跨盘点）、类型/角差/orb/来源/状态、A入B与B入A宫位及双盘轮。Comparison是双盘对照，非中点Composite，不生成关系评分。

**行运**：目标日期、时间、IANA时区及地点真实参与计算并保存；十主体速度与逆行、跨盘相位和实际可计算宫位有来源状态。变更事件时间使其依赖更新；同签名本命可复用。目标时间不写回生日，不默认取设备位置。

**太阳回归**：按所选IANA时区的公历年完整UTC半开窗搜索，保留零/单/多事件及显式选择。真实API及独立整窗搜索证明2001零根、2004两根；APP展示完整双事件并选择第二项。修复合法1900正时区/2100负时区被UTC年界误拒的问题：保留原完整窗，使用既定数据已覆盖的保守padding，不截窗、不换数据。1900上海窗为`1899-12-31T15:54:17Z`至`1900-12-31T16:00:00Z`（年内LMT转+08）；2100纽约窗为`2100-01-01T05:00:00Z`至`2101-01-01T05:00:00Z`（条件于当前tzdb未来规则）。两端真实API完整14点与独立搜索事件UTC一致。

**月亮回归**：显式起点的35天完整窗口，只取起点处或之后首事件；整个查询窗必须在已声明UTC域内，否则明确拒绝。事件数值定义为可表示微秒格最早`f(t-1us)<0<=f(t)`，不以宽epsilon纳入已经过去的根。覆盖起点±1us/±1ms、半开端点、跨日/年、环绕、±180伪根、无解/越界/失败。

运行默认关闭，仅本地准入环境及本版loopback隔离库或测试sqlite可启用。所有权、实时账号禁用、完整源码/依赖/数据运行身份、来源revision与CAS均在后端检查；结果私有且`private, no-store`。输入/设置/运行身份变化使旧结果STALE并隐藏results/result_revision，迟到写入和旧事件选择不能覆盖新revision。Flutter以会话identity/epoch/operation隔离迟到响应、切号及dispose。

## 3. 真实APP、API、数据库结果

最终源码下：

| 私有记录 | 结果 |
| --- | --- |
| row11 Synastry | 已安装APP本人手填双方时间09:42:19/14:23:42，最终真实重算revision3；服务/DB重启后APP再次从历史读取revision3与轮盘。 |
| row12 Comparison | 用户明确选本人私有本命revision1，最终动态revision2。API读取与数据库关联证据具备。 |
| row8 Transit | 最终revision5，目标08:40:28；仅变事件后`first_cache_reused=true`。此前APP真实改至08:40:26的旧有效链保留。 |
| row14 Solar | 2004两事件，用户APP选index1；最终源码重算revision3仍保留index1。 |
| row10 Lunar | 首事件index0；最终revision3仍保留选择。 |
| row13 Solar | 2001 `NO_EVENT`，APP真实显示零事件；最终revision2。 |
| row15/16 Solar | 1900上海/2100纽约完整边界年；真实API与独立搜索均成功，完整14点。 |

最终实际API及MariaDB再次重启前后，**16动态记录+1本人本命**的完整结果hash、输入/结果revision、签名及选择相同；8条最终源码对应记录另经API逐条读回。canonical虚构用户生日与先前快照相同，未写入匹配评分/权重/硬筛选。原14行重启证据保留为此前源码时点，不冒充16行新快照。

旧runtime记录返回`STALE_RECALCULATION_REQUIRED`且results/result_revision为null；最终源码变化也真实触发旧缓存隐藏，再按新签名重算。非本人读row11为404，禁用已有secondary token用户后为403，旧ID999999为404。primary退出→secondary登录→空私有历史/输入/盘面→secondary退出→primary重登与持久读回均实际执行。Match、Connection、Messaging Consent独立授权合同未改。

## 4. 独立参考、测试和非作者复核

| 检查 | 实际结果与范围 |
| --- | --- |
| Python最终 | **16项通过、无skip、exit0**；独立角距/orb/方向/落宫、合成边界、5个热带真实盲窗、2个CRC1956盲窗、两端公历年完整compute14点与Lunar越域拒绝。独立搜索自行遍历完整窗，不调用生产求根器。 |
| 独立外部十主体 | 新epoch `2026-10-18T07:37:26Z`，Horizons DE441位置及±30秒速度；最大经差0.00001352126°、最大速度差0.00008454864°/day，均小于预设0.001；逆行一致。仅传虚构event时刻，不传birth、不查询Chiron。 |
| 真实零/多根 | API与独立整窗搜索：2001零根；2004两根，`2004-01-01T04:48:00.000000Z`和`2004-12-31T10:33:26.795399Z`。 |
| PHP组合 | 23项/179断言/exit0：dynamic API9、输入unit4、既有Web session10。另19项/100断言/exit0：dynamic API8、输入unit4、既有natal API6、runtime gate1。有重叠，不相加。PHP/Flutter在后续Python域修复中未改，按影响复用。 |
| Flutter/静态 | 18项通过：动态5、旧session7、router6；analyze5项无issue；PHP10文件lint、Python3文件AST通过。 |
| Mutation | 本地副本移除跨侧过滤，9个独立比较失败；未改变产品文件。 |
| 非作者数学复核 | GPT-6.1 Sol/high只读复核求根、canonical微秒、sidereal、年份域及上海历史端点；最终未发现剩余数学阻断。测试/APP执行证据由主代理提供，审稿助手未重跑。 |
| 非作者安全复核 | GPT-6.1 Sol/high只读检查所有权、禁用、私有缓存、runtime身份、并发、会话隔离、分页及显示；关闭selection CAS、窗口字段和历史无界probe三项发现，无剩余安全阻断。最终Python域增量由数学复核覆盖，安全助手未重复评估其数学行为。 |

独立搜索共享已接受`PositionModel`位置层；外部DE441与DE440s亦共享JPL谱系。求根bracket≤1秒、最短角残差≤0.00001°是**同一计算模型数值收敛标准**；实现使用微秒格，历史UT1约40us量化明确披露，不代表物理微秒精度或全世纪星历误差保证。字段仍标`CALCULATED_UNVERIFIED`，测试覆盖不能把未验证字段变成事实，更不认证玄学预测。

## 5. 来源、许可、条件项和复现

沿用v10.0.10接受的Skyfield1.55、固定DE440s、ERFA/时标、现有whole/Placidus/Alcabitius、CRC1956自定义恒星黄道、真交点、mean Lilith及Lowell自产Chiron轨道。已核requirements锁、dependency manifest、Chiron manifest/制品、西占和time_context对象均与接受基线相同。未启用Kerykeion/Swiss/pyswisseph/AGPL sidecar或云端fallback，未重积分/更换Chiron数据，未购买或扩大解释许可。

有限具名旧源：旧仓`13277df80c3b82f33887ffe110d807ad79b38d8c/services/api/app/services/astro.py`，Blob `0a10c0a1cfcf7d7a5bf52e13cd4e676277d75c1c`（24692 bytes，API原字节Git对象核对），确认四组调用入口。结合现有Flutter具名资产，Composite仅分类线索，firdariaLike为预留，annualProfectionLike为年龄循环展示；真实Composite、完整法达和完整annual profection为`SOURCE_NOT_ESTABLISHED / NOT_IMPLEMENTED`。只表示已查具名范围，不声称所有历史版本不存在；仍在恢复台账保留，不拿条件项代替必达四功能。

复现须隔离虚构库`elitesync_v1011_dev`、MariaDB10.11.18，仅127.0.0.1:43321；Laravel仅127.0.0.1:8011。配置`DYNAMIC_CHARTS_ENABLED`、`NATAL_PYTHON`、`NATAL_JPL_KERNEL`、`NATAL_NODE`、`DB_*`、`VIEW_COMPILED_PATH`；密钥与私密环境不提交。依已接受锁安装本地依赖；仅对本版库迁移/虚构seed；测试强制sqlite内存避免继承真实DB。用独立包及`ELITESYNC_V1011_LOCAL_BUILD=true`、初始路由`/profile/astro/advanced`构建，已有JDK17；仅对本版API精确reverse。完整输入与profile取自私有工作区，不将API/盘面日志公开。

## 6. AC候选判定

| 冻结AC | Codex证据结论（Astra尚未接受） |
| --- | --- |
| AC-11-01 来源与完整性 | 四组、来源/依赖/数据/profile与条件项分类完整。CANDIDATE_COMPLETE。 |
| AC-11-02 输入与私有工作区 | 真实APP手填/本人快照、明确事件时间地点、服务端校验与私有持久化。CANDIDATE_COMPLETE。 |
| AC-11-03 双人盘 | 真实双盘、跨相位/有向落宫、独立角距/orb/交换参考、APP轮盘。CANDIDATE_COMPLETE。 |
| AC-11-04 行运 | 实际目标、速度逆行外参、缓存真实依赖与持久化。CANDIDATE_COMPLETE_WITH_SHARED_DATA_LIMIT。 |
| AC-11-05 回归 | 完整独立搜索、Solar零/多根及选择、Lunar首事件/起点边界、域边界。CANDIDATE_COMPLETE。 |
| AC-11-06 持久/权限/并发 | 已安装APP→最终后端→隔离DB、重登/重启/读回、STALE隐藏、拒绝矩阵/CAS/切号。CANDIDATE_COMPLETE。 |
| AC-11-07 独立验证与回归 | 独立参考、受影响回归、非作者复核与共享模型限制公开。CANDIDATE_COMPLETE_WITH_SCOPE_LIMITS。 |
| AC-11-08 完整交付 | 固定源码、制品及apps绑定、测试退出、重启与复核、安全审阅副本、资源收口。CANDIDATE_READY_FOR_ASTRA。 |

## 7. 失败与限制保留

首轮测试继承mysql环境使8项失败，已明确测试隔离；设置归一化target_year导致错误STALE、Flutter nullable/滚动/按钮/lint、Web本地compiled-view目录、无效JDK路径、参考环境缺tzdata、求根累计舍入1us差异均保留首次输出并修复验证。最后新增边界测试曾错误沿用上海年初LMT到年末，真实API断言exit1；经非作者指出及PHP实核纠正为+08，最终16测试及两端API/独立搜索通过。UI辅助点击/滚动失败仅记自动化工具失败，不冒充产品成功。dirty根一次状态比较错误使用all-untracked与原normal目录摘要比较，不可比；按同命令只读回读后HEAD/index/status均相等，未改根。

保留PDO8.5常量deprecation、旧PHPUnit docblock warnings。原全量PHP16既有失败未重新修复/全量重跑；v10.0.10接受记录中的Lowell全世纪物理误差限制、CRC1956非官方Lahiri、mean Lilith定义、紫微童限适用范围，以及历史AEC/回声、call65额外终态读回缺口、旧/up根因UNKNOWN延续。无生产、RTC、UAC、防火墙、新邮件/查信、付费或真实用户数据外发；这些均NOT_RUN。

## 8. 保护与资源终态

专用连续开发树保留本版分支和全部成果。受保护原dirty根仅只读身份/status，**HEAD、index SHA256与同模式porcelain-v2状态均与实施前相等**；未pull/reset/rebase/stash/clean/覆盖checkout/prune。没有初始逐文件字节manifest，故不声称全部dirty文件已逐字节复验。旧证据、媒体、数据库和持久卷未清理。

本版APP已force-stop；精确8011 reverse移除并回读；API PID经实时命令行核归属后停止；本版MariaDB容器停止，8011/43321 loopback均已关闭。专用持久卷保留、AVD保留且未停止、Docker Desktop未停止；不存在生产部署。`pidof`空输出exit1是预期“APP不运行”，不计测试失败。临时审阅分支保留待Astra审阅和具名清理。

最终出口：**V10.0.11 CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE / NOT_YET_ACCEPTED**，以最终普通发布和独立GitHub回读为交付凭据。停止于此，不自接受、合main、K08或启动下一版。
