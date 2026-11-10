# M5-49｜有限 Kotlin 修订材料

SOURCE-ONLY KOTLIN MATERIALS/DOCS CANDIDATE — WORK LEVEL2 / INDEPENDENT SOL-HIGH REVIEW PENDING。
2026-10-01；D:\EliteSync-v10；main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。
仅本patch-materials.md CreateNew；不执行替换，不改/复制SDK。
引用源身份：D:/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt，42405 bytes / SHA256 1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313。当前身份沿用已接受M5-48，本轮仅核其保存文档，不新读取SDK或刷新该源身份。

## 适用域与字面约定

四项只适用于上述精确版本及com.flutter.gradle.FlutterPlugin。LibraryExtension/Project/File imports在已存原10/19/29；不改package/imports、字段原文字节或原method声明。FlutterPluginUtils/AGP/Gradle实现和运行兼容未新核。
下面每个fence的正文就是完整UTF8/LF字面：空行和前导空格均有意义，每块最后一行包含一个LF，closing fence不属于字面。没有省略号、自由patch参数或运行命令。helper是旧M5-29完整block；其逻辑、常量、属性/任务/API gate全部不变。repo/tasks/preflight完整字面与adapter已保存_CODE项目经A纯文字转义比对一致，没有字面求值。
来源引用根：
- EVIDENCE/APP-M5-48-FLUTTER-PLUGIN-SOURCE-CONTEXT/source-context.md：已保存编号44–47、88–101、453–456；完整外围apply46–306和addFlutterTasks349–532仅作已接受上下文。
- EVIDENCE/APP-M5-29-AAR-ADAPTATION-CONTRACT-CONSISTENCY-REPAIR/plan.md：repo fences108/125，tasks144/151，helper220，preflight265/269。
- apps/android_synthetic_demo/tools/aar_entry_materials.py：_CODE同名项目、Attachment209–211。原两Attachment的executable_patch=False保持；本材料并未把它改成True。

## 有限顺序与锚的证明边界

固定顺序1 helper-member，2 apply-preflight，3 repository-consumer，4 tasks-consumer。helper成员插入留在字段与apply声明之间，不侵入任何既有method；preflight只改apply起始赋值行；repo只改仓库正文；tasks只改app返回与host分支边界。
已存范围显示这些before属于不同作用域：preflight赋值不在helper正文，repo正文与tasks边界不在helper或彼此的after中。未来仍须对完整原source先核size/hash并核四个before全文件唯一、scope及非重叠，不能把本轮摘录中的匹配提升为全文件新检索已证；应用每项前再次核局部scratch中该before唯一，首失败不产生部分结果。
未来仅在局部scratch完成四项后才返回完整字节；不得允许任意传入operations/anchor/replacement替代冻结四项。失败返回无候选字节，不能把前三项结果保存。整个输入包括未回显308–348及534以后必须逐byte保留；本轮没有这些正文的写入/复原权限。精确完整原hash前门不允许用只保存的两段上下文拼成假完整源。
以下before/after是材料，不是本轮已变换结果。原imports、其它class成员、apply其余语句、addFlutterTasks其余语句和未知范围不改。任务图/发布/插件加载/缓存/属性安装等并不因片段替换而被证明。

## 1 helper-member

Scope：com.flutter.gradle.FlutterPlugin；原44–46，class成员边界。下列锚在原源行号域内解释；插入后的绝对行号会移动，不能再按旧行号驱动替换。

```kotlin id=helper-member-before
    private var pluginHandler: PluginHandler? = null

    override fun apply(project: Project) {
```

```kotlin id=helper-member-after
    private var pluginHandler: PluginHandler? = null

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

    override fun apply(project: Project) {
```

## 2 apply-preflight

Scope：FlutterPlugin.apply(project: Project)；原47，方法开头赋值。下列锚在原源行号域内解释；插入后的绝对行号会移动，不能再按旧行号驱动替换。

```kotlin id=apply-preflight-before
        this.project = project
```

```kotlin id=apply-preflight-after
        this.project = project
        esControlledModule(project)
```

## 3 repository-consumer

Scope：FlutterPlugin.apply(project: Project)；原88–101，Maven正文。下列锚在原源行号域内解释；插入后的绝对行号会移动，不能再按旧行号驱动替换。

```kotlin id=repository-consumer-before
        val hostedRepository: String =
            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)
                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST
        val repository: String? =
            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {
                project.property(PROP_LOCAL_ENGINE_REPO) as String?
            } else {
                "$hostedRepository/${engineRealm}download.flutter.io"
            }
        rootProject.allprojects {
            repositories.maven {
                url = uri(repository!!)
            }
        }
```

```kotlin id=repository-consumer-after
        if (!esControlledModule(project)) {
        val hostedRepository: String =
            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)
                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST
        val repository: String? =
            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {
                project.property(PROP_LOCAL_ENGINE_REPO) as String?
            } else {
                "$hostedRepository/${engineRealm}download.flutter.io"
            }
        rootProject.allprojects {
            repositories.maven {
                url = uri(repository!!)
            }
        }
        }
```

## 4 tasks-consumer

Scope：FlutterPlugin.addFlutterTasks(projectToAddTasksTo: Project)；原453–456，app分支与host分支边界。下列锚在原源行号域内解释；插入后的绝对行号会移动，不能再按旧行号驱动替换。

```kotlin id=tasks-consumer-before
            return
        }
        // Flutter host module project (Add-to-app).
        val hostAppProjectName: String? =
```

```kotlin id=tasks-consumer-after
            return
        }
        if (esControlledModule(projectToAddTasksTo)) {
            val android = projectToAddTasksTo.extensions.findByType(LibraryExtension::class.java)
            check(android != null) { "ES_LIBRARY" }
            android.libraryVariants.all esLibraryVariant@{
                val variant = this
                if (variant.name != "debug") {
                    return@esLibraryVariant
                }
                check(variant.flavorName.isEmpty()) { "ES_FLAVOR" }
                check(FlutterPluginUtils.buildModeFor(variant.buildType) == "debug") { "ES_MODE" }
                val assembleTask = variant.assembleProvider.get()
                check(FlutterPluginUtils.shouldConfigureFlutterTask(projectToAddTasksTo, assembleTask)) { "ES_TASKS" }
                addFlutterDeps(variant, flutterPlugin, targetPlatforms)
            }
            getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)
            FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(
                projectToAddTasksTo,
                getPluginHandler(projectToAddTasksTo).getPluginList()
            )
            return
        }
        // Flutter host module project (Add-to-app).
        val hostAppProjectName: String? =
```

## 三消费者、早期时序与保护门

helper的三处完整消费者为：repository-consumer的!esControlledModule(project)，tasks-consumer的esControlledModule(projectToAddTasksTo)，apply-preflight的esControlledModule(project)。repo-after只包原仓库注入正文，tasks-after在已有app分支返回后增加受控debug/library路径并保留host分支前缀，preflight-after在this.project = project后直接调用、不消费返回值。不能漏一处或把调用符号标为UNKNOWN。

早期preflight状态PROPOSED；root/own属性安装与LibraryExtension在原47之后的可用时序NOT_PROVEN。helper保持既有fail-closed检查，不删除ES_SCOPE/ES_ROOT_SCOPE/ES_LIBRARY等门、不给fallback、不移动调用以假装通过。源内文字锚可提出，不等于此调用阶段语义正确；缺时序前门时运行禁止。repo后续调用、tasks debug分支也未编译或执行。
M5-48显示apply在此后仍读环境/engine cache、native loader、本地properties并配置profile/release/NDK/dependencies；本材料不宣称这些副作用已隔离。源码引用API不证明真实SDK/AGP/Groovy/Kotlin兼容，人工13tests不转移执行权限。

## 唯一最小后继建议（DRAFT / NOT_ISSUED）

拟一个SOURCE-ONLY纯内存受控变换候选：仅接受与本材料精确完整size/hash一致的源bytes，固化这四项/scopes/order/完整before-after；先核完整身份及四锚唯一和非重叠，全部局部scratch成功才返回完整bytes与变更范围，失败无部分输出。不增加恒定record或重复false preflight，不给通用自由patch API。
该任务必须另定准确写路径、来源/静态/人工oracle预算及首失败停点，并先独立Sol/high与WorkLEVEL2；未保存的源外范围不能臆造为正例oracle，完整输入及独立人工预期来源必须先固定。SOURCE-ONLY作者不运行、不写/复制SDK；实际验证、API编译、时序前门与隔离构建分别另授预算。变换产物仍只PROPOSED，绝不把成功字节变换称ready。此为一个材料到完整字节适配的实质切片建议，当前不派发、不标ISSUED、不发GO或编写变换代码。

## A来源与新预算回执

A新1/1完成关闭；chunk_id=4c8fc9，exit_code=0，wall_time_seconds=0.2760808。三固定本仓来源各一次ReadAllBytes，准确size/hash、普通non-reparse含祖先、strictUTF8通过；七个旧block完整正文与对应_CODE字符串文字一致（只转义核对，不eval/Python/AST）。组织A正文8696 UTF8 bytes，计数行附加后仍<=16KiB；本轮SDK读取/写/复制、代码执行均0。

```text
A EVIDENCE/APP-M5-48-FLUTTER-PLUGIN-SOURCE-CONTEXT/source-context.md bytes=32531 SHA256=7D12B382EABBF43CF29BBC65E302771CA0BA3D5B1042A296005950D0E8AA37C8 ordinary_non_reparse/strict_UTF8=PASS
A EVIDENCE/APP-M5-29-AAR-ADAPTATION-CONTRACT-CONSISTENCY-REPAIR/plan.md bytes=40085 SHA256=B7477C177E1CB1860959BD4136E6B1A1B33A5D9F2B75E75BDB4F6FC442A95382 ordinary_non_reparse/strict_UTF8=PASS
A apps/android_synthetic_demo/tools/aar_entry_materials.py bytes=20338 SHA256=B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7 ordinary_non_reparse/strict_UTF8=PASS
```

保存时B新0/1尚未执行；B只核本文完整字面/引用/size/hash/预算/工作区成员一次，最终B工具原回执在回复提供，不为补B再修改已核文档；首失败不修改重跑。
旧M5-46/47 REJECT及旧预算关闭保持；M5-48接受与native后段跨证据核定/原transport未完整恢复限制、M5-43PTY全传输NOT_PROVEN、M5-44静态145PASS/M5-45人工13/13均不追认或重跑。
全部SDK读取/写/复制、Python/AST/import/compile/算法/tests/checker/launcher/monitor/Gradle/Flutter/JVM/ADB/依赖解析/工程生成下载/staging/构建安装启动0。无Git mutation、邻源/SDK目录搜索、cache/config/env/home/真实metadata/properties、旧D:\EliteSync、真实数据/备份/密钥/生产DB/API/SSH或UAC；保留dirty/untracked、五冻结源/harness、旧候选证据及全部关闭预算。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false、真实性/恢复/生产/UAC门保持。候选交付后停WorkLEVEL2及独立Sol/high，不自接受、不修正重跑、不派后继。
