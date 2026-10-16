# v10.0.9 同版 R1 集中交付

**V10.0.9 R1 CANDIDATE DELIVERED — AWAITING ASTRA FINAL RE-ACCEPTANCE / NOT_ACCEPTED**。

本次只处理Astra固定审查提交27df047ea348de226b2f6a24e754cb9ae4633617中的三项；已实际完整读取正文。初始候选66a8638581d1017823ac3caa2536568e0de3b939 / Tree5d12910949af8bf8f29f87106f45594887a962b7。开始时live GitHub main=27df047ea348de226b2f6a24e754cb9ae4633617，原开发分支HEAD=66a8638；只fetch审查对象，没有合入main。最终R1 Commit/Tree由交付后外置receipt和Owner消息固定，本文不自含自身commit。

## 三项结果

| 项 | 结果 | 证据与限制 |
|---|---|---|
| R1-1 PHP16项归因 | 已完成定点归因；无R1产品修复 | [具名16项表](R1_PHP_FAILURE_ATTRIBUTION.md)。0.8与候选相同运行时/配置/fixture定点各16项62断言、4errors12failures、exit2；全部在固定0.8复现。共享路由摘要失败两侧实际hash不同，单独解释RTC新增与v2边界检查。不宣称全量绿或重现原全量执行顺序。 |
| R1-2 四条临时规则 | 已精确删除并读回0 | Owner当前“我在”批准四条精确删除及一次UAC，辅助脚本记录exit0（父进程OS退出码未捕获）；四项cmdlet成功，现场回读0。WLAN UDP7882/TCP7881，各allow-test和block-others。原创建脚本/精确来源回读归属一致；其它828条规则名称/启用/方向/动作/Profile不变，未比较其它无关filter字段。地址只LOCAL_ONLY。 |
| R1-3 双向语音关联 | 已整理，但关键字段NOT_PROVEN，未闭合人工证据缺口 | [语音关联](R1_AUDIO_EVIDENCE_LINKAGE.md)。原手机→电脑听辨、静音恢复、第三版两端hash、四个音频相关源码hash连续、最终包安装hash和call59双向RTP均有关联；同call同时双向人工可辨及试听call/room仍NOT_PROVEN。未创造Owner确认或拼接不同call。 |

## 源码、测试与构建

R1产品/测试源码变化为空；只文档及脱敏证据。产品/测试锚仍e0eb86ada8f8dff95a7b384969ace058385e2c37，最终包沿用原77d4b021…APK和dd1e869f…AAR。没有因文档重建/安装/双端复测。最终PDO必要选集在固定候选副本37项/325断言/exit0，保留2项vendor与2项PHPUnit弃用。原全量1063/14037、4errors12failures/exit2原样保留；全量PHP/Flutter本次NOT_RUN，原RTC32项exit0属于此前原证，不冒充R1新跑。

首次对照副本遗漏题库、常量警告，以及分析编码/换行检查失败均保留；修正的是本地对照/分析工具，没有修改产品或断言。详见归因报告及harness-observations.json。

## 精确防火墙最终状态

- EliteSync-v1009-manual-rtc-7882-20261016-block-others：REMOVED。
- EliteSync-v1009-manual-rtc-7882-20261016-allow-test：REMOVED。
- EliteSync-v1009-manual-rtc-7881-20261016-block-others：REMOVED。
- EliteSync-v1009-manual-rtc-7881-20261016-allow-test：REMOVED。

删除前均本版临时入站/WLAN/指定宿主地址；allow来源3项、block为排除允许来源的63段IPv4范围。原精确地址和完整前态只LOCAL_ONLY；安全前后态及归属文件hash见evidence/r1/firewall-safe-evidence.json。仅这四条规则由一个已授权UAC辅助进程删除；不开放新端口、不改变全局策略、不操作其它项目服务。

## 原证与资源

[脱敏证据索引](evidence/r1/raw-evidence-index.json)记录42份原件的相对locator、bytes、SHA256及可访问性，R1 stdout/stderr/JUnit/exit单独保留；原全量stderr已合并不可恢复为独立流。E=来源会话version-regression，A=同来源audio-echo-software，R=当前会话v1009-r1。LOCAL_ONLY原件不能冒充Astra已在GitHub实读；公开摘要统一CODEX_REPORTED。

当前本0.9所有具名DB/SFU/旧relay容器均exited；匹配候选路径的PHP/Python/Node服务0；DB卷elitesync-v1009-db-data仍存在，媒体/私配/原证保留。Owner现有AVD进程保留；本次无ADB/设备访问，双APP停止仅沿用原stop receipt，不声称已新读设备状态或全部资源关闭。原Windows麦克风状态未改。四条临时规则现已删除。

prepare-sfu.py及原五项dirty/untracked集合完整保留，未清理/reset/stash；D:/EliteSync-v10原dirty根、0.6～0.8卷、真实数据/生产/备份及无关LOCAL_ONLY未操作。测试只在私有隔离副本sqlite内存库执行，不seed持久DB。历史失败不重写。

## 未解决与保留观察

R1-3的同call人工双向同时可辨及试听身份关联保持NOT_PROVEN，需Astra/Owner裁决或新的具名补证授权。未申请或启动语音/视频/网络窗口。原生音频模式UNVERIFIED、本地front队头等待/短body风险、死锁有限重试不保证1.5秒、框架SQL日志LOCAL_ONLY、Android显示0.08.04及全量Flutter旧观察均不扩成R1优化。

唯一冻结plan Commit68d57f755d0091bc15cb867b96d3a21caee83690 / Blob042cf7298b75169a89b1dcd7c9fb113f6ddd72e3及AC09-01～08、D1～D6不变。此交付不构成ACCEPT；不编写最终acceptance.md、不合main、不K08、不后继版本。普通non-force推送原独立候选分支、读回固定Commit/Tree后停止，等待Owner转交Astra。
