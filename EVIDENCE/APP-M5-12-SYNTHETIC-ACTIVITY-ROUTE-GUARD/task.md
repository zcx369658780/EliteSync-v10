# APP-M5-12｜synthetic Activity深链开关位置修复

ISSUED；LEVEL2，SOURCE-ONLY。Codex 01a0ef77-af94-75e2-8726-87c04e082018 Sol/medium。唯一D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be，保留所有既有修改。先读根五authority/local-workflow及M5-11 task/summary/work-review；M5-11 REJECT/CLOSED，39/39合同PASS回执与全部耗尽预算保留，不重跑。

唯一可改apps/android_synthetic_demo/app/src/main/AndroidManifest.xml，输入SHA256 CAE490260B4CD9AE8740F810BD6EA0C553F9F5D2DEF5E7567C233035FEA9F69A。仅新增本目录summary.md，不改其它源/validator/contract或旧证据。可读MainActivity.kt核对路由接线，输入SHA256 7C84B23C554FAD528126151E00AB1B63B9E179A2DFCDDD5A13AA4AC9A203176F。哈希不符或摘要冲突则停。

新官方源码只读预算：一次批量读取/定点rg/哈希以下两个已明确存在文件，不扩搜或读缓存/config：
D:\flutter\engine\src\flutter\shell\platform\android\io\flutter\embedding\android\FlutterActivity.java
D:\flutter\engine\src\flutter\shell\platform\android\io\flutter\embedding\android\FlutterActivityAndFragmentDelegate.java
核对getMetaData、shouldHandleDeeplinking及新Intent处理调用链。只读官方源/hash/准确行，不能把该源当未来AAR已核定版本。如果文件缺失/方法无法说明Activity开关语义则停止，交付UNRESOLVED，不猜位置。

在官方源码明确ActivityInfo.metaData读取语义后，只把现有flutter_deeplinking_enabled=false meta-data从application直属移到.MainActivity直属；不得重复开关，不改值、其它manifest权限/组件/属性、Kotlin或主题。保留固定getInitialRoute=/home，新Intent基类路径须由正确开关静态关闭。编辑一次，最小文本移动；无其它格式整理。

新验证预算：一次Python -I -B标准库XML静态检查（固定已有Python C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe，工具缺失停不搜索），仅解析最终manifest，验证唯一MainActivity、开关只在该Activity、值false、application无同名开关、原其它XML语义保持。可在同一进程用输入/输出字节证明只移动准确块，输出hash；30秒硬时限、每路16KiB上限并行排空，失败/超时/截断停，不修复重跑。另一次仅该目标空白检查（tracked/untracked按情况检查，不把git diff空输出当新文件检查），新预算各1/1。没有Flutter/Gradle/Android/设备或旧validator测试预算。

summary记录SDK两源hash及真实读取链/行、manifest前后hash/最小移动、单次XML和空白回执/时限/预算、未改其它源码、仅source接线修复。实际merged manifest/生命周期/host编译仍NOT_CHECKED，M5 NOT_READY；修复不等于运行路由证明。无目录扫描/索引、SDK修改、真实properties/配置缓存/备份/密钥/DB/SSH/API/网络/UAC/旧D:\EliteSync或Git提交/pull/push。无自接受/后继派发/authority修改，交付后停独立Work审查。
