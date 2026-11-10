# APP-M5-47｜AAR 缺口事实修订

DOCS-ONLY CANDIDATE — WORK LEVEL2 / INDEPENDENT SOL-HIGH REVIEW PENDING。
2026-10-01；D:\EliteSync-v10；main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。
唯一新增本plan.md/CreateNew；M5-46旧REJECT候选保留，两旧A/B各1/1关闭，不修改或补跑。

## 两Required的自包含修正

正确提案是 this.project = project，不是另造的thisProject符号。preflight-after中明确调用esControlledModule(project)，其已保存符号与内容不是UNKNOWN。esControlledModule三处提案消费者必须同时列出；真实SDK外围class/import/API兼容仍UNKNOWN。这两层不能互相替代。

来源：EVIDENCE/APP-M5-29-AAR-ADAPTATION-CONTRACT-CONSISTENCY-REPAIR/plan.md L218–272；apps/android_synthetic_demo/tools/aar_entry_materials.py L9、11、19–21、209–211。两来源本轮准确size/hash已核。下列字面均为已存材料文字转录，不运行、不应用到SDK。

apply-helper：Attachment id=apply-helper，placement=FLUTTER_PLUGIN_CLASS_MEMBER，before=空bytes，after为下面完整UTF8/LF block（含末尾LF），executable_patch=False。完整已知符号为 private fun esControlledModule(p: Project): Boolean。

```kotlin
    private fun esControlledModule(p: Project): Boolean {
        val key = "elitesync.aar-entry"
        val own = p.extensions.extraProperties
        val root = p.rootProject
        val rootOwn = root.extensions.extraProperties
        val present = own.has(key) || p.hasProperty(key)
        if (!present) {
            check(!rootOwn.has(key) && !root.hasProperty(key)) { "ES_ROOT_MODE" }
            return false
        }
        check(own.has(key)) { "ES_SCOPE" }
        val raw = own.get(key)
        check(raw is String && raw == "module-debug-v1") { "ES_MODE" }
        check(rootOwn.has(key)) { "ES_ROOT_SCOPE" }
        val rootRaw = rootOwn.get(key)
        check(rootRaw is String && rootRaw == raw) { "ES_ROOT_MODE" }
        check(p.path == ":flutter") { "ES_PROJECT" }
        check(!FlutterPluginUtils.isFlutterAppProject(p)) { "ES_APP" }
        val android = p.extensions.findByType(LibraryExtension::class.java)
        check(android != null && android.productFlavors.isEmpty()) { "ES_LIBRARY" }
        check(p.gradle.startParameter.taskNames == listOf("assembleAarDebug")) { "ES_TASKS" }
        val values = linkedMapOf(
            "is-plugin" to "false",
            "output-dir" to File(root.projectDir, "../../publication").path,
            "elitesync.sdk-identity" to "1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313",
            "elitesync.aar-projects" to ":,:flutter,:sample_alpha,:sample_beta"
        )
        values.forEach { (name, value) ->
            check(own.has(name)) { "ES_SCOPE" }
            check(own.get(name) == value) { "ES_PROPERTY" }
        }
        check(own.has("buildNumber")) { "ES_SCOPE" }
        val id = own.get("buildNumber")
        check(id is String && Regex("[0-9a-f]{64}").matches(id)) { "ES_ID" }
        check(rootOwn.has("buildNumber")) { "ES_ROOT_SCOPE" }
        check(rootOwn.get("buildNumber") == id) { "ES_ID" }
        listOf("local-engine-repo", "local-engine-out", "local-engine-host-out", "local-engine-build-mode").forEach {
            check(!p.hasProperty(it)) { "ES_LOCAL_ENGINE" }
        }
        check(!p.hasProperty("skipDependencyChecks")) { "ES_SKIP" }
        return true
    }
```

apply-preflight-proposal：Attachment id=apply-preflight-proposal，placement=APPLY_AFTER_THIS_PROJECT_ASSIGNMENT，executable_patch=False；历史apply:47锚仅为材料来源说明，不固定当前method/class或唯一锚。完整before和after（UTF8/LF、各含末尾LF）如下，保留8个前导空格：

```kotlin id=preflight-before
        this.project = project
```

```kotlin id=preflight-after
        this.project = project
        esControlledModule(project)
```

## 三消费者与真实上下文边界

| 材料项 | 已存准确调用及用途 | 真实上下文尚未证明 |
|---|---|---|
| repo-after（adapter L9） | if (!esControlledModule(project)) { ... }，包住原仓库注入正文；受控module时不进入该正文。原材料含System.getenv/FlutterPluginConstants、local-engine判断、rootProject.allprojects/repositories.maven。 | 该正文在真实class/method中的位置、project/rootProject/engineRealm等作用域、导入/常量和配置阶段、副作用闭包。材料字面用途不是真实执行结果。 |
| tasks-after（adapter L11） | if (esControlledModule(projectToAddTasksTo)) { ... }，进入材料中的LibraryExtension/debug/libraryVariants路径。 | projectToAddTasksTo的声明及传入范围、同一helper可见性、准确AGP/Kotlin API/variant类型、真实任务图与publish/finalizer配置。 |
| preflight-after（adapter L21） | this.project = project之后esControlledModule(project)，先调用检查；返回值在这两行中未消费。 | 完整外围method签名/class、this.project字段声明/import、调用时LibraryExtension/属性/任务已可用的阶段，以及唯一且语义正确的插入锚。 |

helper完整字面已知的类型/API引用包括Project、LibraryExtension、File、Regex、FlutterPluginUtils.isFlutterAppProject及Gradle属性/任务/extension接口；其真实imports、class作用域、API解析和版本兼容均UNKNOWN。before为空不能给helper建立唯一SDK插入位置；preflight已知短before也不能证明当前SDK仅有一个有效语义锚。不得把完整提案再标为“符号未知”，亦不得把提案符号当真实SDK上下文已核。

## 准确可执行缺口表

| 层 | 本地证据已证明 | 还不能直接构建的原因 |
|---|---|---|
| 四片段纯内存应用 | M5-45已接受冻结纯内存13/13；四片段与人工预期比较的接受不变。 | 局部字节结果不是完整真实SDK/工程文件；两Attachment未落地。没有本任务新增工具或Gradle运行。 |
| 两Attachment | adapter L210–211分别引用_CODE['apply-helper']及_CODE['preflight-before'/'preflight-after']，均False；上述完整字面与三消费者准确。 | 真实class/import/method/唯一插入锚/调用阶段未核；未允许修改或复制SDK。 |
| Invocation与人工属性 | M5-46旧材料域只作状态背景：runtime_ready=False，四project人工recipe/词法模型；不是SDK真实性证据。当前task保持loader/runtime false。helper本身检查: flutter项目、root/own属性、精确任务和四project字符串等。 | 实际Gradle Project属性安装、完整root/child project输入闭包、真实路径及插件读属性行为未运行证明。 |
| module/plugin输入闭包 | 冻结纯材料合同不改变真实metadata/properties未读取的边界。 | 完整工程/settings/include/plugin/模板/classpath与隐式配置副作用及隔离生成边界未在本轮核定。 |
| 隔离工具/依赖/任务图/产物 | M5-44接受静态145检查、M5-45接受13纯内存tests；旧预算关闭。 | 真实工具当前身份、HOME/cache/自动配置隔离、依赖解析、真实debug任务及发布产物、设备安装/启动全无本轮新证据。M5/隔离构建NOT_READY；settings/v1全拒绝保持。 |

旧M5-43 PTY全传输NOT_PROVEN、M5-44原工具检索后段限制仍保留；不追认13tests等于SDK/AGP/Groovy/Kotlin安装兼容、恢复、真实账号/Conversation或production ready。

## 历史locator恢复结果及检查范围

唯一允许的记录：EVIDENCE/APP-M5-27-AAR-CONFIGURATION-ENTRY-CLOSURE/m526-original-receipt.txt；24935 bytes，SHA256 FE1A9CF5D3DDAF259A5412346B77DF43CFB05295B31BBF8FB3767C2423F2E062。本轮一次ReadAllBytes、strictUTF8、普通non-reparse含祖先、准确size/hash通过。M5-29 plan L14明确引用这一本仓receipt；L18给材料按SECTION/编号行拆分及不填补缺行的归一约束。

本轮未恢复准确FlutterPlugin绝对路径，结果NOT_FIXED。检查方法为对全部原样UTF8文本按CRLF/LF物理行分割，定点匹配FlutterPlugin、SECTION、SHA256、bytes=/size=及PATH/SOURCE/FILE/path=行；同次回显该部分没有命中。没有补做封装格式识别或对整个receipt再进行JSON/Base64解封装；本轮不因此宣称receipt缺路径/缺SECTION、记录不存在或SDK文件不存在。可见检查结果不足转录历史准确路径及已保存SECTION范围，二者均未恢复，不臆造邻文件或目录。此为恢复限制，未转化为SDK搜索权限，未修正或重试A。

已知helper字面的历史Flutter锚是1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313（M5-29 L245）；锚不等于准确源路径或当前文件hash。本轮没有可转录的HISTORICAL_RECORDED_LOCATOR；外部当前身份标CURRENT_IDENTITY_NOT_CHECKED。没有访问任何SDK路径或证明其当前存在/版本/内容。

## 唯一最小后继建议（DRAFT / NOT_ISSUED）

优先缺口仍是三消费者共同依赖的真实Flutter插件class/import/apply上下文。最小来源上下文任务先固定来源，而非增加常量record或重复false preflight。

单一交付：source-context.md（准确写路径由Work在新task固定，当前不创建）。内容是历史locator/记录SECTION范围、当前源身份、必要class/import/方法与三消费者/唯一锚映射；不实现patch或生成工程。

进入当前SDK读取前的硬前置：Work先从上述唯一固定本仓receipt恢复准确路径与已存上下文范围，并审查其封装/解码方式；无法恢复即NOT_FIXED首停，不搜索猜FlutterPlugin.kt或邻目录。若另立该来源任务，可给一次0/1固定receipt证据解析预算，完整识别记录封装后按准确SECTION提取定位；只有定位已固定并由Work明确允许的准确路径才进入当前身份核定。历史locator标HISTORICAL_RECORDED_LOCATOR/CURRENT_IDENTITY_NOT_CHECKED，不能直接当当前hash。

随后拟议一次0/1 current-source只读预算：仅该准确SDK源，先普通non-reparse/路径无歧义/size/hash核定；与Work固定参考身份冲突即停、不续内容读取。身份通过后一次受限内容读取，准确片段需包含imports/class/字段与相关完整外围方法、repo-after/tasks-after/preflight-after三消费者及helper拟插入锚的完整上下文。片段具体行范围必须由已存SECTION和Work任务预先固定，未固定不自动扩展文件或窗口；输出总<=16KiB，严格UTF8。全部运行0，不修改SDK。

允许路径仅上述固定receipt、Work明确核定的一个SDK源和一个source-context.md；不顺import读邻文件、不目录搜索、不读metadata/properties/环境。建议交付文字核定一次0/1；任何来源缺失、格式/身份/定位/输出/编排/上下文问题首停，不修正重试，UNKNOWN保留。先独立Sol/high只读与WorkLEVEL2接受来源上下文，再另议可执行适配；本草案NOT_ISSUED，当前不派发、不发GO、不授SDK读取或运行。

## 本轮来源身份、预算与停点

A新1/1已完成并关闭；tool chunk_id=48a1ec，exit_code=0，wall_time_seconds=0.2162206；四固定来源各一次ReadAllBytes，准确size/hash/non-reparse/strictUTF8均通过，组织回显提前<=16KiB。两Required完整字面核定成功；locator未恢复及检查限制如上，不补读、不扩大。本task不是历史SDK identity刷新。

```text
A EVIDENCE/APP-M5-46-AAR-EXECUTABLE-GAP-CONVERGENCE/plan.md bytes=11329 SHA256=23551A9715427E6684156E73A96BDFC6AA2C78C90E43C0D0FF224731BC97F941 ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-29-AAR-ADAPTATION-CONTRACT-CONSISTENCY-REPAIR/plan.md bytes=40085 SHA256=B7477C177E1CB1860959BD4136E6B1A1B33A5D9F2B75E75BDB4F6FC442A95382 ordinary_non_reparse/strict_UTF8=PASS
A apps/android_synthetic_demo/tools/aar_entry_materials.py bytes=20338 SHA256=B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7 ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-27-AAR-CONFIGURATION-ENTRY-CLOSURE/m526-original-receipt.txt bytes=24935 SHA256=FE1A9CF5D3DDAF259A5412346B77DF43CFB05295B31BBF8FB3767C2423F2E062 ordinary_non_reparse/strict_UTF8=PASS
```

保存时B新0/1尚未执行；保存后仅本plan文字/引用/size/hash/预算/工作区成员核定一次。B工具原回执在最终回复提供，不为补B回执再改已核plan；失败首停不改/重跑。
所有Python/AST/import/compile/算法/tests/checker/launcher/monitor/SDK/Gradle/Flutter/JVM/ADB/依赖解析/构建/staging拷贝/安装启动0。只CreateNew本plan，不改authority/冻结源/harness/旧候选/证据；不commit/pull/push/reset/clean/stash、不旧D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH、SDK/cache/config/env/home/真实metadata/properties/搜索索引下载或UAC。保留dirty/untracked及所有旧关闭预算。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false、真实性/恢复/生产/UAC门保持。
交付终点：DOCS-ONLY候选停WorkLEVEL2与独立Sol/high只读审查，不自接受、不修正重跑、不派后继。
