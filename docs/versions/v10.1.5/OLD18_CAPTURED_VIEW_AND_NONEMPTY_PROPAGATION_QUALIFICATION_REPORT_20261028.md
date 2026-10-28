# EliteSync v10.1.5｜旧18件捕获视图与非空目录传播／回滚资格

日期：2026-10-28（Asia/Shanghai）。

**CAPTURED_VIEW_RECOVERY_BOUNDARY_DEFINED / NONEMPTY_PROPAGATION_BOUNDED_SUPPORTED_ON_NEW_FIXTURE / OLD18_READONLY_NO_RESTORATION。**

旧18件只读匹配，历史control 0x8404、当前0x8004的残留保持；旧对象修改／恢复／删除／移动／重建均0。唯一新非空目录树的父目录一轮变更及恢复后，四对象新捕获flags7视图精确恢复。此为新树有界方法证据，不是旧18件恢复、完整历史SD证明或OS隔离通过。

## 1. 权威与Git范围

正式任务Blob **86adf8d774379b6a7b5a90d416a01f35ae7ce35c** 已从main全文、Git原字节核对；Owner本地手动派发。开工及发布前fresh main **7d5c60eb331dae145c025e89decd7705a7d605f9**，Root **f7d77a49afdac0266161b3c39bb1359dadfcbe9c**，ACTIVE_STATE Blob **c90b291316fc0b3f0490ec6f92f5d99c13aadd97**。其中“待派发”为发布时点，不覆盖本地派发事实。

已读交接Blob 6e4c96977cf7bd69fd270fe3d92f5291c901079d、协议0f62532a71fb9753811fafa9e03819a46422f4bf、cfca报告edc910819c6614cfdd8f0db02274ebfd8f9166f3、索引4c7121c33030d66908c2f1423c1fddee07098c79、Astra裁决7fe6528893fd711736d2cbd80f64f286709eda86；8186报告／索引e773c0139dc4c0d6c91abad7553508382975d4e0／0cfc46b50f092b5c1c10df7ea4e065af3141144a绑定LOCAL_ONLY原证。旧G2合同796c9ad2d5d91b3d375cea6c079e9e6121e0be4c仅保留历史，不授本轮运行权。

本候选唯一Parent **cfca26beb6e3710b46f9c3559cce706c332a61b9**；源sole Parent 8186cebc94661bcdc229ee5b62b31871dc784a4c，源Root 462e4e542ebb6dbc2f6e9ed721134129c5a190de，完整递归6669项、未截断。候选完整apps **5af7a9d0042be19437616e969e260658b67e9353**／services **21eebf69bbc6397b1562d40f8cd9ebd7b246720f**保持。main已接受v10.1.4 apps **3468a3dd97da7accfda2539a0f8d8f68931a6110**／services **0cb1f9d19659291a462488b3686fd0a07a6698ac**。

只新增本报告和脱敏索引，不改产品或历史、不建checkout或本地refs。最终候选Commit／唯一Parent／Root、两新Blob／原字节、完整产品Tree和fresh main在发布后保存LOCAL_ONLY final-readback并随交付提供，避免在不可变报告中编造自引用SHA。

## 2. 四层恢复边界

1. HISTORICAL_OGD_CONTROL_EVIDENCED：8186可信O/G/DACL SDDL及其control语义0x8404可追溯，捕获源码flags7可核。源文件mtime记录LOCAL_ONLY；它不是原生API采集时间，精确历史采集时刻未补造。
2. CURRENT_FLAGS7_VIEW_VERIFIED：本轮仅flags7=OWNER|GROUP|DACL，当前control0x8004，返回binary／SDDL及身份内容与cfca当前快照一致。本轮binary不回填为历史binary。
3. CAPTURED_VIEW_RESTORATION_CANDIDATE_NOT_EXECUTED：将来另授权后，最多提出恢复可信历史O/G/DACL＋control字段；仍需引用、完整影响面与回滚资格，不构成本轮旧对象写许可或历史失败改判。
4. HISTORICAL_FULL_SD_BINARY_OR_SACL_UNPROVABLE：旧完整self-relative binary、SACL从未捕获，无法由新读取或重序列化追溯证明。未请求SACL不等于SACL不存在。

0x0400是描述符SE_DACL_AUTO_INHERITED control位，不是ACE的OI／CI／INHERITED标志。ACE／owner／内容匹配不能替代control或完整SD恢复，旧严格恢复仍0/18未关闭。

## 3. 18件矩阵、旧非空目录和引用／回滚

仅枚举8186具名micro-fixture，深度≤8、可见对象≤65、单目录子项≤32；拒绝／未知链接即停止。实际18件与历史集合相同，10目录、8文件，4目录非空。“匹配”仅指ACE/O/G/内容与身份可比字段，明确保留control残留。

|ID|类别|直接子项／全部后代|历史→当前control|ACE/O/G/内容/身份|本轮旧恢复次数|
|---|---|---:|---|---|---|
|F001|directory|4/17|0x8404→0x8004|匹配|0／未执行|
|F002|file|0/0|0x8404→0x8004|匹配|0／未执行|
|F003|directory|1/1|0x8404→0x8004|匹配|0／未执行|
|F004|directory|7/7|0x8404→0x8004|匹配|0／未执行|
|F005|directory|5/5|0x8404→0x8004|匹配|0／未执行|
|F006|directory|0/0|0x8404→0x8004|匹配|0／未执行|
|F007|file|0/0|0x8404→0x8004|匹配|0／未执行|
|F008|file|0/0|0x8404→0x8004|匹配|0／未执行|
|F009|file|0/0|0x8404→0x8004|匹配|0／未执行|
|F010|file|0/0|0x8404→0x8004|匹配|0／未执行|
|F011|file|0/0|0x8404→0x8004|匹配|0／未执行|
|F012|file|0/0|0x8404→0x8004|匹配|0／未执行|
|F013|file|0/0|0x8404→0x8004|匹配|0／未执行|
|F014|directory|0/0|0x8404→0x8004|匹配|0／未执行|
|F015|directory|0/0|0x8404→0x8004|匹配|0／未执行|
|F016|directory|0/0|0x8404→0x8004|匹配|0／未执行|
|F017|directory|0/0|0x8404→0x8004|匹配|0／未执行|
|F018|directory|0/0|0x8404→0x8004|匹配|0／未执行|

F001有17后代，F003/F004/F005分别1/7/5。逐项源Hash、SDDL／当前binary Hash、ACE数量／继承、revision、祖先和匿名后代见索引；真实值只留LOCAL_ONLY。

目标单链接、无reparse、祖先FileId与cfca一致；可见集合完整不能排除外部引用。固定refs／worktree注册表没有精确目标路径字符串，只证明该有限登记检查；未扫描全盘、全进程、其它任务全部源码或全局打开句柄。**REFERENCES_NOT_EXCLUDED**。父链存在DELETE_CHILD候选ACE，但未执行token有效权限AccessCheck；ALLOW／DENY／组／继承组合不由ACE计数决定。父目录delete／rename探针均NOT_RUN。当前FileId保持不证明未来路径不可替换或持续OS隔离。

可证RESTORATION_SCOPE_PROVABLE_FOR_CAPTURED_FIELD_COMPARISON_ONLY；旧非空树继承写入效果、历史后代原态及完整回滚仍未证明：**CHILD_PROPAGATION_UNPROVEN / ROLLBACK_NOT_GUARANTEED / REFERENCES_NOT_EXCLUDED**。新树不是旧树影子原态备份。

## 4. 唯一新非空树实验

P父目录、D1直接文件、D2子目录、D3其下文件，合4对象／3后代，均唯一新任务拥有，不在保护／worktree／Seed／SDK子树。祖先无reparse，Volume/FileId独立且单链接，完整枚举匹配四项白名单。task-root与四对象句柄不共享写／删除，只有P句柄有WRITE_DAC。初始flags7 binary／SDDL／control／ACE／O/G、身份内容、祖先及固定源码／方案在调用前flush+fsync。

固定同一P句柄SetSecurityInfo，DACL_SECURITY_INFORMATION|UNPROTECTED_DACL_SECURITY_INFORMATION，mask **0x20000004**，owner/group/SACL参数None。保持原ACE顺序，在显式／继承边界插入本对象owner的OI|CI FILE_READ_ATTRIBUTES允许ACE，不加拒绝、不削减原权限。逐对象只允许这一预期marker：父flags3、子目录flags19、文件flags16，原ACE顺序／control／revision／身份内容保持；随后同句柄、同mask恢复原DACL一次。**测试允许ACE的继承与撤销，不测试写拒绝强度，也不重复N01/N02的0x8004恢复实验。**

|对象|before→mutation→restore control|精确单ACE传播|flags7全部捕获字段恢复|
|---|---|---|---|
|P|0x8404→0x8404→0x8404|是|是|
|D1|0x8404→0x8404→0x8404|是|是|
|D2|0x8404→0x8404→0x8404|是|是|
|D3|0x8404→0x8404→0x8404|是|是|

父变更1、恢复1；后代显式ACL写0、旧18写0。变更及恢复后四对象各自快照持久化，binary／SDDL逐字节及control、DACL/ACE、O/G、Volume/FileId/link/属性／内容全部比较。两API成功，无Win32异常；不以stale LastError声称0。句柄全关闭，新树原地保留。SACL未请求，状态字符串相同不算SACL验证。

仅支持本次新树、当前用户和ACL的一轮传播／回滚；不支持拒绝ACE、受限token、任意深度、受保护DACL、链接／reparse或旧历史树。旧18、历史完整SD及OS运行资格不因本实验关闭。

## 5. 静态/mock、原始失败和预算

六项新增纯合成分类检查通过，拒绝重复marker／其它ACE变化／control漂移／owner漂移／错误继承flag；不是OS矩阵。内部非作者只读静态审查发现判定、异常恢复、API兼容和Hash绑定问题，均在唯一新树创建前修订；最终审查绑定源码Hash，不是Astra独立接受。前轮10 mock、N01/N02、事件查询、旧child未重跑。

原始失败保留：补丁请求格式错误被工具拒绝（未写入）；首次只读登记因重复祖先快照超过自设单文件4MiB序列化guard而exit1，尚无ACL调用、未写出过大文件。改为唯一祖先快照＋引用后完成登记，比较标准不变、未重复保护首验；原stdout/stderr/exit1及失败JSON保留。辅助派发名冲突和报告准备JavaScript文本语法错误均为工具回执，不伪造进程stdout／退出码。安装ACL对象无AddAce在运行前以只读确认，真实执行源使用已存在的ACE构造方法；不是ACL失败后换API重试。

新任务logical和allocated各≤**33,554,432 bytes**。登记前后、ACL前后、终核前后与交付节点逐文件／目录FILE_STANDARD_INFO测量；无SDK／Seed副本或checkout。报告前logical **6563591**、allocated **6674312** bytes。报告／索引／远端回读／末尾回执另计最终快照与量化余量；快照不证明全卷瞬时峰值，后写回执及共享MFT/journal限制明确列出。旧2GiB／64MiB不继承。

首尾122原证Hash/size/FileId、五根HEAD/branch/index/status、527refs、worktree注册表、3183旧Seed Hash/FileId均匹配；旧18当前视图／内容／身份首尾一致。清单覆盖旧claims／partial／SQL/APK及失败日志保持，未全量重算旧26784/108/100453集合，未声称整盘保护。

新树1/1、后代3/3、父变更1/1、父恢复1/1已用尽，无重试；旧18全部写操作0。旧APK/G各1/1耗尽，旧A关闭；G2 max1/reserved0/Popen0、具名claim不存在，预算账本／claim写0，**无本轮G2许可**。受限／普通对照child、历史14矩阵、Gradle/JVM/Flutter/Dart、AAR/POM/APK、ADB/RTC、Gate2、工程网络/Job/observer、真实DB／生产／第三方业务均NOT_RUN。GitHub文档交付不是工程网络实验。

## 6. 证据分层、下一门与STOP

DIRECT_GITHUB_READBACK：权威任务／Git对象与最终候选回读。ASTRA_DIRECT_GITHUB_STATIC：既有cfca裁决，非本轮新接受。CODEX_REPORTED_LOCAL_EXECUTION：本轮只读登记、保护、新fixture真实调用与mock。LOCAL_ONLY_RAW：真实SDDL/SID/binary、本机路径与完整日志。NOT_RUN/NOT_PROVEN：旧恢复／完整历史SD／旧树引用回滚、受限矩阵、工程运行和整版接受。

下一阶段仅建议Owner/Astra明确未来捕获视图恢复可承诺哪些历史字段，并单独闭合旧非空目录逐后代原态、外部引用、传播影响及限次回滚。历史完整binary/SACL不能承诺追补；未来若授权已捕获字段语义恢复须另记定义，不能改旧严格失败为PASS。本轮未下达后继任务。

持续 **OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTORATION_BLOCKED_WITH_ORIGINAL_EVIDENCE / CHILD_INIT_ROOT_CAUSE_NOT_PROVEN / CHILD_ACCESS_MATRIX_NOT_RUN_14_OF_14 / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / INPUT_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / AAR_POM_RUNTIME_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED**。AEC/native handle、真实15/30日、物理清理、Push、SDK/Dokka/TCP历史未决保留。

**普通non-force单一候选发布及GitHub最终回读后STOP，等待Astra独立验收。不修旧18、不启动G2、不清理历史、不合main、不进入v10.1.6。**
