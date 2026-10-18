# EliteSync-v10｜v10.0.11 唯一正式冻结计划：动态星盘与关系盘恢复

**2026-10-18 — V10.0.11 FROZEN_FUNCTIONAL_PLAN / OWNER_MANUAL_DISPATCH_PENDING / IMPLEMENTATION_NOT_STARTED**

本版在 v10.0.10 已接受并完成 K08 的产品基线上开展。本文冻结功能目标和 AC，不代表 Codex 已获本地执行派发、已开始实现或已通过验收。Owner手动将本版综合任务单转交Codex后，本版开发授权按第七节一次生效。

## 1. Authority 与固定起点

Owner决定方向、数据用途、重大不可逆操作和费用；Astra冻结计划、独立终验与状态；Codex在一次综合任务内自主实现、测试、修复、多agent协作与非作者复核。沿用本地优先工作流，不恢复Work/dot实时监督或微任务审批。

冻结起点：
- v10.0.10 accepted：`65b4991837e76d04762b85a9439851264766e192`
- 产品源码锚：`2be08468754c7b1ad453f9eb0b7085050b3aaf99`
- K08产品集成Commit：`d82f19b7a7a6c15f486734ce24a4090262cccf48`
- K08时点main：`acff76ad5e8e9a15c94abdf203641e2365cd8ccc`
- apps：`01b58edcfec2766a1e764231d4098c0d61ea6d95`
- services：`c72d392f37968e20d1b48d2252a9549c2b0d04dc`

执行前仍需Codex核实时态；以上不是允许覆盖后继变化的永久HEAD。既有0.10正式acceptance、integration、Owner决定、旧失败与科学/许可观察均保持不变。

## 2. 冻结功能范围

本版必须将以下四组功能贯通真实安装Flutter APP、Laravel API、本地合法计算和本版独立MariaDB，并可持久读回：

1. **Synastry / 双人盘与 comparison**：用户明确提供两组输入或选择本人已确认的私有本命快照；计算双方本命、A对B与B对A的交叉相位及有方向的落宫。comparison仍是双盘对照，不得改名为composite。双方输入须可追溯、明确用途，不能自动读取平台另一用户的生辰。
2. **Transits / 行运**：用户选择目标时间（“现在”也是一次明确时间快照）、时区及必要地点；计算实际行运点位、速度/逆行、与本命的交叉相位，以及UI实际提供的宫位结果。修改事件时间或计算参数须按真实依赖刷新缓存。
3. **Solar Return / 太阳回归**：按用户选定目标公历年与地点/时区对应的UTC窗口搜索太阳回到本命太阳黄经的真实事件。窗口可能零个、一个或多个事件；完整返回事件列表与明确状态，不能假定每年必有且仅有一次。
4. **Lunar Return / 月亮回归**：用户显式选择查询起点，返回该起点处或之后首次月亮回到本命月亮黄经的真实事件。必须处理起点前后边界，不能只凭年份暗选某一次，也不能以宽松epsilon吞入已过去事件。

旧源核实规则：
- 已有旧实现证据：复用具名实现/输入输出合同，在本版内恢复真实可操作链。
- 旧源的comparison是双盘对照，不是真正中点composite。
- 旧Flutter的firdariaLike只是法达预留，annualProfectionLike只是年龄循环展示；不能冒称完整传统时法。
- 若同版有限核查未能建立法达、完整annual profection或真正composite的真实旧实现证据，明确记录SOURCE_NOT_ESTABLISHED / NOT_IMPLEMENTED及已查范围；不得因此阻断四组确定功能，也不得编造实现。若确认有真实旧实现则本版按其实际合同恢复；若需要新增算法、流派或产品范围，集中提交Owner决策，其他本版工作继续。
- Buddy/Social、地图/系统Push、其它媒体、历史真实数据/附件、完整APP+Web最终联合验收及长篇付费报告不属于本版；继续保留在内测前恢复台账，不得静默删除或永久Later。

## 3. 输入、隐私与计算语义

- 双人盘使用明确的 first/second 输入。second可由用户主动录入并确认用途，或从本人明确选定的已确认私有快照生成；不能依据peer_id、Match、Connection、Messaging Consent、公开生日或私有镜像自动读取另一账号出生资料。
- 不得自动合成第二人的生日、时间偏移或地点；不得以12:00、默认Asia/Shanghai、0坐标或假轴/假宫位补齐未知数据。缺时、DST gap/fold未定、地点缺失、极地宫制无解、数据超出有效域，按受影响字段给出UNKNOWN/NOT_APPLICABLE/拒绝。
- 区分出生资料与事件资料。行运目标时间不得写入birthday；回归地点不得默认设备位置或出生地，除非用户明确选择该选项。记录民用时间精度、IANA TZ、DST fold、UTC和WGS84坐标来源。
- 沿用已接受的Skyfield 1.55、固定DE440s、时标/ERFA、whole/Placidus/Alcabitius、CRC1956、真交点、mean Lilith和Lowell自产Chiron及现有锁、runtime identity、manifest、NOTICE和hash。不得启用Kerykeion、Swiss Ephemeris、pyswisseph、AGPL/未准入sidecar或云端fallback，不购买新许可、不重积分或更换Chiron数据。
- 数据覆盖与精度按真实已接受源声明。超出Chiron/其它数据有效域的点位须拒绝或UNVERIFIED，不可伪装full。数值求根收敛不等于物理星历误差认证。
- 派生盘只保存在本人私有记录，默认private/no-store；不进入canonical profile、Match权重、硬筛选、客观关系事实、通知或公开图像。解释关闭时数值盘仍可用。Match≠Connection≠Messaging Consent的既有语义不变。
- 计算签名应覆盖本命快照revision、第二输入revision、盘型、目标时间/时区/地点、黄道/宫制/点位定义、引擎/依赖/数据/tzdb及必要规则版本。输入或真实设置变化后旧结果标STALE；晚到请求不能覆盖新代际，切账号/logout不能串入旧响应。

## 4. 回归事件数值合同

- 对目标黄经差采用正确的圆周/连续角度处理，避免±180°函数跳变被误当根；求根有明确有效bracket，禁止固定天数周期、搬移生日或预设日期伪造事件。
- 太阳回归按用户选定目标年和地点/时区计算UTC半开窗口，允许零、一或多个事件；不悄悄切换年份。
- 月亮回归按显式起点选择起点处或之后首次事件；起点略前、恰好命中、略后均需测试，边界规则与容差登记在机器可读registry。
- 计算层每个事件的有效bracket不宽于1秒，最短角残差不大于0.00001度。此为同一模型下的数值求根标准，不是物理事件误差保证。
- 事件独立参考必须在相同冻结搜索窗口自行寻找事件，不能复用生产求根函数，也不能只在生产返回时刻附近复算残差。与被测实现共享的天文数据/位置计算层须明确披露；另对代表性新时刻使用合法外部参考，分别说明位置误差与事件搜索误差。
- 地点影响只改变实际依赖它的宫位/显示部分；不混用八字真太阳时和天文UTC，不适用宫制不得自动fallback。

## 5. 持久化、API、UI与回归

必须贯通同一个已安装APP→真实Laravel→本地计算→隔离MariaDB→退出重登/服务与DB重启后的读回。开发库只使用虚构测试账号/输入，不导入历史真实SQL或重seed v10.0.6–v10.0.10既有验收库/卷。

API必须验证当前调用者所有权与账号状态；按ID读取、重算、历史结果获取均不可越权。管理员不因本版获得读取私密星盘的新权限。对当前用户成功与非本人、禁用、旧ID/旧缓存拒绝进行正反测试；生产及未知环境继续fail-closed。

APP必须有可操作的盘型选择、输入/事件时间与地点、计算/加载状态、结果盘面、空结果/不适用/错误解释和重试；不是静态preview、仅API或mock。旧provider里的second-person合成、noon/TZ补值及旧natal guard须由新合同替换，不能只删除guard。

只对受影响的v10.0.10本命路径、私有资料、缓存、登录/切号、必要Web登录与账号安全做回归。不重开三盘算法完整验收，不重跑真实RTC窗口。

## 6. 冻结验收 AC-11-01～AC-11-08

- AC-11-01 来源与完整性：四组确定功能与源/依赖/数据/字段映射完整；条件项按证据规则分类；comparison、composite、法达不混同；保留v10.0.10观察。
- AC-11-02 输入与私有工作区：真实APP录入/选择两人输入、目标时间/年份/起点和地点；服务端校验并持久化；无伪造second、noon、默认TZ。
- AC-11-03 双人盘：非fixture双输入产生真实双方点位、交叉相位、有方向落宫与可读盘面；交换A/B时对称/方向行为符合定义；环绕、orb、缺时及边界有独立参考。
- AC-11-04 行运：目标瞬间真实参与计算并持久化；点位、速度/逆行、交叉相位及实际展示宫位正确；改变参数触发正确缓存失效；新时刻独立参考成立。
- AC-11-05 回归：Solar/Lunar由真实事件搜索产生，事件选择语义、bracket/residual及独立搜索通过；零/多事件、环绕、起点边界及无解状态正确。
- AC-11-06 持久化/权限/并发：同一已安装APP贯通Laravel/本地计算/MariaDB，重登及服务/DB重启后读回一致；旧结果失效、迟到响应和切号不串号；本人允许与非本人/禁用/旧缓存拒绝真实测试。
- AC-11-07 独立验证与回归：非作者expected/独立数学实现覆盖新跨盘和事件搜索；披露共享数据层级；旧失败具名保留；不删断言或绕许可追绿。
- AC-11-08 完整交付：同一最终候选绑定源码Commit/Tree、实际AAR/APK/hash与安装、真实DB重启、参考资料、原始退出证据、非作者复核；未运行NOT_RUN；Codex不得自行宣称ACCEPTED、合main或启动下一版。

## 7. Owner手动派发后一次性本地授权

Owner手动将本冻结计划和综合任务单转交Codex后：
- 优先复用并先核验既有连续目录 `C:/Users/zcxve/.codex/worktrees/elitesync-main-64a098f/EliteSync-v10`，在安全干净基线上建立 `codex/v10.0.11-dynamic-relationship-charts`；原 `D:/EliteSync-v10` dirty根、其它worktree、未提交资产不触碰。
- 新建隔离开发数据库 `elitesync_v1011_dev`，默认仅 `127.0.0.1:43321`；本版Laravel默认 `127.0.0.1:8011`。复用已核验MariaDB镜像/运行身份，首次副作用前核名和资源归属；端口冲突可在同一loopback范围自主选空闲端口并记录。
- 只使用虚构账号和数据。允许本版迁移/seed、API读写、真实APP操作、退出重登及服务/DB持久重启。
- 复用Owner既有受控AVD，核验设备身份后允许启动、构建AAR/debug APK、安装、输入操作、切换虚构账号、退出/冷启动和精确ADB reverse。建议独立测试包 `com.elitesync.v1011test`，与旧验收包并存；不覆盖未知同名资产，不升级全局Android/Gradle/JDK，不操作真实手机，不启动RTC。
- 只启动/停止本任务确认归属的资源；持久volume、测试数据与原证据保留。不得清理未知容器/卷或旧验收环境。
- 不授权生产/商用发布、真实用户数据外发或用途扩大、历史SQL导入、备份/卷/媒体删除、付费许可/账户、新公网、UAC/防火墙或其它不可逆系统操作。越界时只暂停受影响部分，其他同版工作继续。
- JPL/NIMA邮件与既有提醒保持原状；不查信、重发、新建监控或自动更换数据源。

## 8. 一次性执行与交付合同

Codex在同一长任务内连续完成：有限旧源证据核查→算法/API/持久化/Flutter并行实现→独立事件搜索/跨盘参考→真实APP与隔离DB重启→必要回归→多agent协作与非作者复核→集中候选交付。旧源核查不变成单独preflight版本，不扫描无关项目或全历史。

保留真实stdout/stderr/exit、run id、原始hash与LOCAL_ONLY原证；对Astra需要直接审阅的材料按TEMP_REVIEW_EVIDENCE_PROTOCOL一次集中提交最小脱敏副本到本版专属临时分支，不合main/产品分支，不上传密钥、真实生辰、设备/私网敏感信息。公开Git对象的分支删除不保证历史对象永久消失。

只新增一份 `docs/versions/v10.0.11/IMPLEMENTATION_REPORT.md`，包含候选身份、四组功能、条件项结论、依赖与registry、测试/独立参考、资源状态、失败与观察、NOT_RUN及非作者复核。必要的manifest/运行说明作为复现附件；活动状态只做最小更新。普通non-force发布候选开发分支，回读Commit/Tree与制品身份；Astra独立接受前不得合main/K08。

完成出口只能是 `V10.0.11 CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE`；不完整时如实报告PARTIAL/BLOCKED及已有成果，不伪造ACCEPTED。v10.0.10的ACCEPTED_WITH_OBSERVATIONS与K08_INTEGRATION_COMPLETE持续有效。下一版本不自动启动。
