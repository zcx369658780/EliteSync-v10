# APP-M5-07｜synthetic bootstrap端点策略候选回执

状态：CANDIDATE / WORK LEVEL 2 REVIEW PENDING。纯Kotlin编译与测试PASS；Android/host/Gradle/设备均NOT_CHECKED，M5运行NOT_READY。

仓库 D:\EliteSync-v10，main，HEAD cf8bfaa4a03b8c9a682105617b185141904413be。两现有输入哈希逐一匹配；两新增源码、本摘要、输出jar均无路径冲突后才开始。仅修改两现有文件，新增两Kotlin源码、本摘要及指定jar，全部既有dirty/untracked保留。

## 最小差异与接线

- app/build.gradle.kts只在defaultConfig增加boolean ELITESYNC_SYNTHETIC_DEMO=false，无启用属性、Dart define、AAR同步/依赖/变体/端点/签名改动。
- 新BootstrapEndpointPolicy无Android/Flutter依赖或I/O。synthetic=true先require debug，返回固定 http://127.0.0.1:8080/ 与 ws://127.0.0.1:8080/；所有外部端点参数忽略，不解析/连接。非debug synthetic抛IllegalArgumentException，不回退普通模式。普通模式复制原firstNonBlank的Intent trim优先、文件trim回退、全缺省空串。
- MainActivity实际调用policy。getBootstrap在readBootstrapFile之前检查synthetic/debug并得到安全端点；synthetic不读取Intent端点参数或文件API/WS键。为保留initialRoute的文件回退，仍读取JSON文件及非端点字段，readBootstrapFile(includeEndpoints=false)在optString前排除两个端点键；不把该策略宣称为完全禁止bootstrap文件I/O。普通模式includeEndpoints=true与原读取语义一致。
- ensureBootstrapDefaults在synthetic下强制覆写两个Intent端点；onCreate、onNewIntent均保留原调用。debug门在intent为空返回前也执行。普通缺省BuildConfig端点逻辑保留。
- initialRoute/版本/debug返回、clearBootstrap及原firstNonBlank函数保留。本轮没有实际synthetic Android产物或Dart/AAR启用，AAR身份/host标记同源及应用数据隔离门未闭合。

静态接线审查PASS：policy真实接入、分支顺序、文件端点键过滤、首Intent/新Intent共用覆盖、默认false均核对。仅针对兩现有目标git diff --check一次退出0、无输出；两新增源码空白检查一次PASS。未格式整理其它内容。

## 工具身份（固定路径只读，无工具链搜索）

- Java C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot/bin/java.exe：5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B。
- Compiler lib C:/Users/zcxve/.gradle/wrapper/dists/gradle-8.14-all/5vwl8burbouivoo2kromnbp2p/gradle-8.14/lib，kotlin-compiler-embeddable-2.0.21.jar：9FA8CDD1DE0DCCFFE154C997D423EC6B5F53CD6D9177E3A77A9B0DE03FB1BC81。
- 同lib kotlin-stdlib-2.0.21.jar：F31CC53F105A7E48C093683BBD5437561D1233920513774B470805641BEDBC09。

## 实际验证

### 编译

命令参数：`["C:\\Program Files\\Eclipse Adoptium\\jdk-17.0.18.8-hotspot\\bin\\java.exe","-cp","C:\\Users\\zcxve\\.gradle\\wrapper\\dists\\gradle-8.14-all\\5vwl8burbouivoo2kromnbp2p\\gradle-8.14\\lib\\*","org.jetbrains.kotlin.cli.jvm.K2JVMCompiler","-no-stdlib","-no-reflect","-classpath","C:\\Users\\zcxve\\.gradle\\wrapper\\dists\\gradle-8.14-all\\5vwl8burbouivoo2kromnbp2p\\gradle-8.14\\lib\\kotlin-stdlib-2.0.21.jar","-jvm-target","17","apps/android/app/src/main/java/com/elitesync/BootstrapEndpointPolicy.kt","apps/android/app/src/test/java/com/elitesync/BootstrapEndpointPolicyJvmTest.kt","-d","EVIDENCE/APP-M5-07-SYNTHETIC-BOOTSTRAP-ENDPOINT-POLICY/out/policy-tests.jar"]`。
UTC 2026-09-30T00:28:21.282339+00:00 → 2026-09-30T00:28:24.847257+00:00，耗时 3.563 秒，退出 0，超时 false。stdout 0 字节，stderr 0 字节，两路截断均为false；硬时限120秒，每路捕获上限65536字节，双流并行排空。

### 测试

命令参数：`["C:\\Program Files\\Eclipse Adoptium\\jdk-17.0.18.8-hotspot\\bin\\java.exe","-cp","D:\\EliteSync-v10\\EVIDENCE\\APP-M5-07-SYNTHETIC-BOOTSTRAP-ENDPOINT-POLICY\\out\\policy-tests.jar;C:\\Users\\zcxve\\.gradle\\wrapper\\dists\\gradle-8.14-all\\5vwl8burbouivoo2kromnbp2p\\gradle-8.14\\lib\\kotlin-stdlib-2.0.21.jar","com.elitesync.BootstrapEndpointPolicyJvmTest"]`。
UTC 2026-09-30T00:28:37.879152+00:00 → 2026-09-30T00:28:37.997835+00:00，耗时 0.125 秒，退出 0，超时 false。stdout 713 字节，stderr 0 字节，两路截断均为false；硬时限120秒，每路捕获上限65536字节，双流并行排空。14/14不同意义case PASS。

测试14类：external Intent/file；null；blank；malformed；首次与新参数等价；nondebug无参数拒绝；nondebug外部参数拒绝；普通Intent优先/trim；blank Intent文件回退/trim；null Intent文件回退；API/WS独立选择；全缺省空串；全blank空串；普通malformed非空值保持。测试直接调用production policy，无JUnit/下载依赖。纯策略用例不证明Android生命周期或整host编译。

原始测试stdout：
```
PASS synthetic rejects external Intent and file endpoints
PASS synthetic ignores null endpoints
PASS synthetic ignores blank endpoints
PASS synthetic ignores malformed endpoints
PASS synthetic initial and new input resolve identically
PASS synthetic nondebug fails with no inputs
PASS synthetic nondebug fails with external inputs
PASS ordinary Intent wins and trims
PASS ordinary blank Intent falls back to trimmed file
PASS ordinary null Intent falls back to file
PASS ordinary API and WS resolve independently
PASS ordinary absent inputs return empty strings
PASS ordinary blank file inputs return empty strings
PASS ordinary malformed nonblank values retain original semantics
TOTAL 14/14 PASS
```

预算：有界编辑完成；纯policy编译1/1、测试1/1耗尽；现有两文件空白检查1/1、新增源码空白检查1/1完成；无失败/超时/重跑。Gradle/wrapper/Android/设备预算0，未执行。

## 文件 SHA-256

输入：
- apps/android/app/build.gradle.kts：4D3A83B8940BBE5F14223350FC444C3F2A854E52A2416E525CD2D25ECD686ED3。
- apps/android/app/src/main/java/com/elitesync/MainActivity.kt：4432C60E723FF2C0E5955A50A94E9A8A050DA5472BEB9CDF714E68AE24440FF9。

输出：
- apps/android/app/build.gradle.kts：0B667C458BC45E213F36F9C0C7D25960EA9A900FD309B983890AE2A7668FBA5B。
- apps/android/app/src/main/java/com/elitesync/MainActivity.kt：96500063E7728CFB50AD196744AFFA0B6FDE0080045AA69BA0DF8EBD340CAD27。
- apps/android/app/src/main/java/com/elitesync/BootstrapEndpointPolicy.kt：E25174137CC6ECEA990B3EFF09752C545A8E724AF052582C7CE0665A881E9FBB。
- apps/android/app/src/test/java/com/elitesync/BootstrapEndpointPolicyJvmTest.kt：79DC1427072E9B6A9D28C3806EE9AF5346807E8373525B6C42EC1C0FADDA6453。
- EVIDENCE/APP-M5-07-SYNTHETIC-BOOTSTRAP-ENDPOINT-POLICY/out/policy-tests.jar：9040CDEB616A7A33D19042CBAE389CA86C1DCE3968FE266D9F3A83F9BE29A7FC。

## 状态及未证项

摘要写入前非忽略状态151→155，新增条目：
- ` M apps/android/app/build.gradle.kts`
- ` M apps/android/app/src/main/java/com/elitesync/MainActivity.kt`
- `?? apps/android/app/src/main/java/com/elitesync/BootstrapEndpointPolicy.kt`
- `?? apps/android/app/src/test/`
无移除条目，只有本任务授权路径状态变化；Git把新test目录聚合为src/test/，本轮只新增其下指定测试源码。out jar可能为忽略路径，以上哈希明确固定它，不以Git状态证明忽略缓存不变。

未读properties/凭据、真实数据/备份/密钥，未访问旧D:\EliteSync/SSH/网络/UAC；无commit/pull/push、authority更新、自接受或后继派发。Owner模拟器授权不扩大本任务0设备预算，没有adb/安装/运行。

M5仍NOT_READY，设备未核、端点整host/应用数据隔离及标记/AAR身份仍须后继任务；G08/G11、真实Conversation/账号、恢复回填门及所有旧预算不变。候选停Work独立LEVEL 2 ACCEPT/REJECT。
