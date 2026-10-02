# M5-77｜本仓 Kotlin Attachment 文字审计

结论：两 Attachment 的文字落点与三消费者调用已定位；早期 preflight 要求调用前已有属性和 LibraryExtension，但安装时序没有证明。材料保持隔离，Kotlin 编译、真实 Gradle 绑定和 SDK 兼容均 NOT_CHECKED；M5/隔离构建 NOT_READY。

来源仅 EVIDENCE/APP-M5-76-LOCAL-CRLF-CANDIDATE-MATERIAL/FlutterPlugin.kt，45907 bytes/SHA256 911647D43C25333D2BED7FCB4ECAE6172C8B4536D882501AAFDE1A07125A5C90。A chunk c9acff、exit 0、观察 wall 0.3340905s；原 cmd3210字符/plain pipes/login=false/tty=false。SourceRead1，完整原字面 FileInfo→Directory→DirectoryInfo.Parent 到根普通 non-reparse，hash/strictUTF8通过；同次全文只留宿主变量作物理行字面定位，没有全文回显或 AST/语义解析。本报告小摘录来自同次 A，完整定点证据见原 A。main/cf8bfaa4a03b8c9a682105617b185141904413be；234旧成员缺0，发布后status235。成员保留不证明无关 dirty 字节不变。

| Attachment/消费者 | 物理行 | 所属可见方法及变量来源 |
|---|---:|---|
| Attachment A：esControlledModule 成员 | 46–87 | class FlutterPlugin 声明34行内新增成员；参数 p: Project；own=p.extensions.extraProperties（48）；root=p.rootProject（49）；rootOwn=root.extensions.extraProperties（50） |
| apply 早期 preflight | 91 | apply(project: Project) 声明89；this.project=project 在90；传入同一方法参数 project |
| repository 消费者 | 132 | apply 同方法；if (!esControlledModule(project))；下一行起 hostedRepository 路径分支 |
| Attachment B：tasks 消费者 | 501 | addFlutterTasks(projectToAddTasksTo: Project) 声明395；传入该参数，受控分支内再次 findByType(LibraryExtension) 在502 |

原 A 的外围方法名来自此前最近可见 function 声明与物理行上下文；不是 Kotlin AST scope 证明。helper完整成员在原 A 的46–87行；三个非声明调用全部定位为91/132/501。

## helper 的输入门与早期顺序

关键原文小摘录：
- 51：val present = own.has(key) || p.hasProperty(key)
- 53：check(!rootOwn.has(key) && !root.hasProperty(key)) { "ES_ROOT_MODE" }
- 56：check(own.has(key)) { "ES_SCOPE" }
- 58：check(raw is String && raw == "module-debug-v1") { "ES_MODE" }
- 59–61：rootOwn 必须有同 key，且 rootRaw 为同一 String 值。
- 62–66：p.path == ":flutter"；!FlutterPluginUtils.isFlutterAppProject(p)；findByType(LibraryExtension::class.java)；android != null 且 productFlavors.isEmpty()；taskNames == listOf("assembleAarDebug")。
- 68–75：own 显式拥有 is-plugin=false、output-dir=File(root.projectDir,"../../publication").path、elitesync.sdk-identity=1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313、elitesync.aar-projects=:,:flutter,:sample_alpha,:sample_beta。
- 77–81：own/rootOwn 均有 buildNumber，own 值为64位小写hex String，root 值与其相等。
- 82–85：local-engine-repo/out/host-out/build-mode 与 skipDependencyChecks 均不得作为 p 属性存在。

无 own/project key 的分支在52–54行检查 root 也无 key后返回 false；受控分支才要求以上门。own.has 与 p.hasProperty 不相同，不能用继承或其它 scope 属性代 own 显式安装。

可见顺序为：apply89 → this.project赋值90 → 无条件 helper调用91 → val rootProject=project.rootProject93 → isFlutterAppProject 分支94 → repository条件调用132。helper对 LibraryExtension 的查询位于64行，发生在91行早期调用内部。第二处 LibraryExtension 可见查询在 tasks分支502，另外原有 host afterEvaluate 查询在537–540。后面的查询存在不证明91时扩展已存在，也不证明早期失败必然发生。

明确风险：如果受控 key 已出现而 own/rootOwn配套属性或 Android LibraryExtension 尚未建立，91行会在执行后续 apply 文字前触发相应门失败。是否真实命中该条件、Android插件先后应用、外部属性安装者以及 taskNames真实值均 NOT_PROVEN。此次定点回显没有建立 Android插件应用语句或外部调用者的精确来源；不能据摘录未出现而断言完整文件不存在插件应用。没有移动调用、删除门或修源码。this.project字段赋值可见；字段声明未由此次定点回显独立定位。

## 可见名称绑定的证据边界

| 名称 | 可见文字 | 未证明 |
|---|---|---|
| Project | import org.gradle.api.Project（19）；Plugin<Project>（34）；方法参数46/89/395 | 实际 Gradle 类路径、版本与 API兼容 |
| LibraryExtension | import com.android.build.gradle.LibraryExtension（10）；helper64/tasks502/原host539 | 实际 AGP API与扩展安装时序 |
| File | import java.io.File（29）；output-dir 构造69 | 路径实际存在、输出可用或 publication 构建 |
| FlutterPluginUtils | 调用63/94；import readPropertiesIfExist 位于14；package com.flutter.gradle 位于5 | 类实现/来源/其它方法绑定；未读邻文件或 SDK |

project相关字段42–44的engineVersion/engineRealm/pluginHandler只作为回显上下文，不建立新运行 authority。repository回显132–137已显示受控条件与原 hostedRepository 分支开始；没有借未完整展开的后续分支推导真实依赖闭包。tasks回显501–507已显示受控条件、LibraryExtension与debug过滤开始；不据文字过滤宣称任务图正确。

## 各证据层分别保留

- M5-76：原bytes物化身份接受，性质 MATERIALIZED_FROM_FROZEN_INDEPENDENT_EXPECTED。本仓隔离材料并未接入apps活动源码/SDK；本次没有SDK读取或修改动作，未额外核当前SDK全字节状态。
- M5-75：准确独立expected正例完整相等及六负例七调用接受，是固定输入的算法证据。本轮不重复Test、不重建oracle，也不追认M5-50旧输入阻塞。
- 本轮：仅本仓物理行落点/名称/顺序文字事实；不证明Kotlin编译或语义绑定。
- 真实Project属性安装与LibraryExtension时序：NOT_PROVEN；early preflight PROPOSED保持。
- module/plugin输入闭包、依赖解析、Gradle任务图与产物：NOT_CHECKED；loader-runtime false、settings-v1拒绝、M5/隔离构建NOT_READY保持。
- 内部scope-anchor-scratch未覆盖路径、SDK/Kotlin兼容、真实性/恢复/生产/UAC门：未放行。

## 唯一后继草案：DRAFT / NOT_ISSUED

具体缺口：找出真实受控Project在FlutterPlugin.apply前安装 own/rootOwn属性及Android LibraryExtension的准确来源与调用顺序。单一结果拟为新 timing-source-evidence.md，文字核来源和相对调用，不生成常量record或重复已接受Test。

已有字面定位仅为本仓材料 apply89/91、helper48–66；实际安装者/调用者源 locator=NOT_FIXED。不得由imports猜邻源或SDK路径。草案允许写路径拟为 EVIDENCE/APP-M5-78-EXACT-EARLY-BINDING-SOURCE/timing-source-evidence.md；允许读路径必须由Work另单固定准确已存安装者/调用者locator后才成立，目前不授任何新增源读取。若locator位于SDK，须明确一次准确SDK只读授权；无locator首停，禁止搜索枚举或试跑构建来补它。

拟新预算：一份准确来源身份+全文读取A至多1；新报告身份B至多1；目标已存在/身份或完整祖先失败/输出超限首停，不补查重跑。独立Sol/high原来源文字审查与Work LEVEL2；所有运行/SDK构建/UAC预算0。该草案未发布、未派发，本会话不自行追读或创建后继目录。

本报告保存时A1/1成功关闭/B0/1。所有PowerShellParser/候选脚本/helper/Python/AST/compile/import/exec/变换/Static-Test/Kotlin/Gradle/SDK/Flutter/JVM/ADB/依赖解析/生成复制/构建安装启动0；普通治理与源码raw身份/文字读取实际发生。父tool独立stderr UNKNOWN/硬截止NOT_PROVEN。保留全部dirty/十五冻结/旧闭budget与保护门；无Git mutation、自接受或新会话。B后不改报告，交付停独立Sol/high与WorkLEVEL2。
