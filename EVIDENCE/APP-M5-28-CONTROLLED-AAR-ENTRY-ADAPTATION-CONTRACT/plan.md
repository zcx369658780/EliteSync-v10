# APP-M5-28｜受控module AAR入口适配合同候选

2026-09-30；LEVEL2 DOCS-ONLY / PROPOSED SOURCE ADAPTATION CONTRACT。本文给出可实现的纯内存片段转换与调用材料，不改SDK、不产生可启动工程。新模式为 `elitesync.aar-entry=module-debug-v1`，与 `is-plugin=false` 分开；专用library入口不查host，保留Flutter任务、插件及SDK/NDK检查，项目仓库注入只在该模式下省略。AGP/Kotlin/Groovy编译、回调实际时序与完整隔离仍UNKNOWN；M5/隔离构建NOT_READY。

入口 `D:\EliteSync-v10`，main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，会话 `01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad`。CURRENT/TASK_CURRENT与明确派发一致，178条入口dirty/untracked保留。仅新增本plan；沿用local-workflow。M5-27已独立ACCEPT/CLOSED，最终hash 7B83055FD677DB5A53F18079696EBA59F7D6C5E0E19337146C15FE00709D21C9，旧2/2及全部旧预算关闭。

## 第一轮已保存证据

一次批量读取七个准确普通非reparse文件，每个≤256KiB，总121468 bytes≤1MiB；前三回执解析唯一JSON的output，exit均0，不执行保存命令。同次chunk `fe1687`，exit0，墙钟0.2933753秒；打印前主动累计UTF8，末状态前25980 bytes，包含末状态低于32KiB，无缺行/解析/hash/链接/大小/输出门失败，无重读。第一轮1/1关闭；无真实SDK读取。

| 本地证据（路径均在EVIDENCE/） | bytes | SHA256 |
| --- | ---: | --- |
| APP-M5-27-AAR-CONFIGURATION-ENTRY-CLOSURE/round-1-original-receipt.txt | 17581 | 9FD10B2C9B46D2578F7BFD32E266248A4C45CEC74140A39A1ED734E5DC1EA8E6 |
| 同目录round-2-original-receipt.txt | 31659 | 8B4657648F3BE8CA1A36E4DFCCED2CFAEA0FAFE18C6BB2B4DCEBD5EFB6B1FE44 |
| 同目录m526-original-receipt.txt | 24935 | FE1A9CF5D3DDAF259A5412346B77DF43CFB05295B31BBF8FB3767C2423F2E062 |
| 同目录plan.md | 16605 | 7B83055FD677DB5A53F18079696EBA59F7D6C5E0E19337146C15FE00709D21C9 |
| APP-M5-23-CONTROLLED-MODULE-RENDERER-CONTRACT/plan.md | 15630 | 82D150AB94166034660832017B722575B7F0D97AD113165D77D905AB49A1A60B |
| APP-M5-24-PURE-MODULE-BUNDLE-RENDERER/summary.md | 5582 | 520887DC1F0D3673D880EB682AB348CF2B2963BE4EE8FACF944543334446B5E9 |
| APP-M5-26-NDK-LIBRARY-AND-METADATA-CLOSURE/plan.md | 9476 | A0315719C54142EF462E12F4F1FEC7D5CA1705508A82E12A6B908097059C702A |

材料规则：JSON output按LF拆行（接受回执CRLF分隔并归一LF）；SECTION字符串必须唯一。语义行严格为十进制源行号、冒号、一个空格、正文；只剥该前缀，不strip正文缩进/尾空格。重复源行必须一致；要求每个目标源行存在且按升序输出。join LF后再添加一个LF，包括源末尾空行的原样贡献；不自动删空行。apply原回执已省独占注释/空行，其材料域只代表所回显非注释行；不插造缺失行，不伪装整文件补丁。

| source id / SECTION / 范围 | 归一片段SHA256 |
| --- | --- |
| tasks-full：m526 / SECTION FlutterPlugin.kt METHOD addFlutterTasks 349-533 / 349–533全行 | B89C513B5803A734D6DC8F1574EED66F9BC173787D13A6D88F5604833F9CBEEE |
| repo-block：round2 / SECTION FlutterPlugin apply 46-307 ALL_NONCOMMENT_NONBLANK_LINES / 88–101全行 | 4CC5BDE39C726B5C6D8034E52929E1B3372D99B6F1B10FDAAF2D59FA567B6534 |
| init-full：round2 / SECTION aar_init_script FULL / 1–191全行 | 5252CD23EDFD3F02AB1E43875F2F0BAE286589A035475D092A87723E02524FCC |
| plugin-deps：round1 / SECTION PluginHandler FULL 1-261 / 226–258全行 | 5B7712D84D82BDCE1BB071419E6BAEFE134754C80B62E3C8BAE1005058E4C33F |

历史整SDK版本锚：FlutterPlugin identity `1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313`；init identity `B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2`。它们不等于上述归一片段hash，不证明持有完整SDK字节；init回执末尾空行/归一换行亦与原文件字节不同。后继实现只转换声明材料，不提供可直接写SDK的整文件补丁。

## 纯内存接口与exact域

拟议接口 `adapt_module_debug_entry(*, materials: tuple[tuple[str, bytes], ...], config: dict) -> EntryMaterials`。EntryMaterials是frozen dataclass：`fragments: tuple[tuple[str,bytes],...]`、`invocation: InvocationContract`；后者所有字段也为frozen dataclass/tuple/str，无mutable dict回传。禁止读文件/env、启动进程、resolve、编译或SDK改写。输入仅exact tuple/exact str/exact bytes/exact dict，拒绝子类、bool伪int、自定义对象；TypeError固定 `TYPE`，语义错误ValueError固定 `CONTRACT`，不回显原输入。

materials仅且按固定顺序tasks-full、repo-block、init-full、plugin-deps；每份等于上述归一原材料hash和已存准确锚，单份≤256KiB、累计≤1MiB。config必须且仅有：`mode`、`flutter_identity`、`init_identity`、`input_id`、`projects`、`properties`、`tasks`、`sdk_root`、`maven_root`、`publication_root`、`repositories_mode`。mode固定module-debug-v1；两identity固定历史锚；input_id严格64个ASCII小写hex；projects固定 `(':', ':flutter', ':sample_alpha', ':sample_beta')`，本首合同仅支持该人工两插件域。tasks固定 `('assembleAarDebug',)`，无冒号前缀。三root固定materials/flutter_sdk、materials/maven、publication；repositories_mode固定FAIL_ON_PROJECT_REPOS。无extra、任意路径/executable/env/版本或自由脚本覆盖。

properties是按projects同序的exact tuple `(project_path, tuple[(key,value),...])`，每project必须显式完整拥有下表，键序固定、无重复/继承/extra。值全为词法材料，input_id插值到buildNumber。全域在生成前验证；没有返回“部分成功”。同一原材料与config重复调用结果等值（确定性）；把任何已生成/部分适配片段当materials再次输入拒绝，绝不自动二次适配。缺锚、重复锚、wrong identity/hash、不一致源行、混入已适配标记均拒绝。

片段hash是输入验证而非算法安全证明。后继转换严格有限字符串插入/替换，保留未受控原文；每锚exact一次，禁止按宽泛fun正则或语义猜patch。新片段末行一个LF、UTF8无BOM；正文中不得省略代码或用占位省略号。tasks-full只在下述boundary处插入，前后全部原bytes保留；init-full只在三个指定callback的首行后插入guard并在allprojects之前插入完整helpers，其它原行不变。repo-block完整替换；apply-helper/preflight分别是附加源材料，真实apply全文件patch不在输出。

## Kotlin完整before/after与作用域

before repo是round2:88–101。保留同模式未启用时的完整原计算/注入；受控模式不读取仓库host表达式，也不注册项目Maven，SDK/engine及版本/NDK原检查不删。

```kotlin id=repo-before
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

```kotlin id=repo-after
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

新增同class helper为自有设计；只有完全未设置mode才返回false，错误值/继承作用域拒绝。project path必须:flutter且LibraryExtension存在/非app，无flavor。按本设计属性bootstrap已先执行；helper没有读取实际SDK数据。apply第一次检查拟放在this.project=project之后、root/SDK/env读取之前（原46–54间），不能从已存摘录制作整个apply文件patch。

```kotlin id=apply-helper
    private fun esControlledModule(p: Project): Boolean {
        val key = "elitesync.aar-entry"
        val raw = p.findProperty(key) ?: return false
        check(p.extensions.extraProperties.has(key)) { "ES_SCOPE" }
        check(raw is String && raw == "module-debug-v1") { "ES_MODE" }
        val root = p.rootProject
        check(root.extensions.extraProperties.has(key)) { "ES_ROOT_SCOPE" }
        check(root.extensions.extraProperties.get(key) == raw) { "ES_ROOT_MODE" }
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
            check(p.extensions.extraProperties.has(name)) { "ES_SCOPE" }
            check(p.extensions.extraProperties.get(name) == value) { "ES_PROPERTY" }
        }
        check(p.extensions.extraProperties.has("buildNumber")) { "ES_SCOPE" }
        val id = p.extensions.extraProperties.get("buildNumber")
        check(id is String && Regex("[0-9a-f]{64}").matches(id)) { "ES_ID" }
        check(root.extensions.extraProperties.has("buildNumber")) { "ES_ROOT_SCOPE" }
        check(root.extensions.extraProperties.get("buildNumber") == id) { "ES_ID" }
        listOf("local-engine-repo", "local-engine-out", "local-engine-host-out", "local-engine-build-mode").forEach {
            check(!p.hasProperty(it)) { "ES_LOCAL_ENGINE" }
        }
        check(!p.hasProperty("skipDependencyChecks")) { "ES_SKIP" }
        return true
    }
```

```kotlin id=apply-preflight
        esControlledModule(project)
```

原tasks-full:453–456为唯一完整插入boundary：after中的原4行逐字保留。原349–454包含targetPlatforms定义361–362、flutterPlugin=this364、app分支366–454；原456–533 host分支也原样保留。新branch在原app return之后/host查找之前，调用参数均在可见同一method作用域已定义。低SDK/NDK及configurePlugins仍在评估期调用，不只return丢失工作。

```kotlin id=tasks-before
            return
        }
        // Flutter host module project (Add-to-app).
        val hostAppProjectName: String? =
```

```kotlin id=tasks-after
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

不复制host app mergeAssets接线；既有addFlutterDeps内部merge/processResources/bundleAar依赖仍使用。实际AGP callback何时提供variant、plugin配置在afterEvaluate前后的可用性和LibraryExtension API均未编译或运行核定。其它variant只是该入口不接线；不声称它们存在或其它代码不会注册其工作。

## init专用debug完整新增方法与插入规则

before三个callback首锚为以下完整字面材料（分别原113、117、150行）；after仅增加guard，其原全部body由init-full逐字接在guard之后，保证mode未启用时继续原行为。不是重建原SDK文件。

```groovy id=init-all-before
allprojects {
```

```groovy id=init-all-after
allprojects {
    if (esEnabled(project)) {
        esCheckProject(project, false)
    }
```

```groovy id=init-afterProject-before
afterProject { project ->
```

```groovy id=init-afterProject-after
afterProject { project ->
    if (esEnabled(project)) {
        esAfterProject(project)
        return
    }
```

```groovy id=init-projectsEvaluated-before
projectsEvaluated {
```

```groovy id=init-projectsEvaluated-after
projectsEvaluated {
    if (esEnabled(rootProject)) {
        esProjectsEvaluated(rootProject)
        return
    }
```

完整helpers插在init-full原113 allprojects之前。`esAllowed`包括rootProject.subprojects真实全部后代范围；任何意外子孙项目/新增app拒绝，不把该集合缩成仅一级。无插件源码执行安全承诺。root不是library；所有参与module/plugin必须library且无flavor，debug publication/component/task必须存在，否则拒绝。

```groovy id=init-helpers
boolean esEnabled(Project p) {
    def key = 'elitesync.aar-entry'
    def raw = p.findProperty(key)
    if (raw == null) {
        return false
    }
    if (!p.extensions.extraProperties.has(key) || !(raw instanceof String) || raw != 'module-debug-v1') {
        throw new GradleException('ES_MODE_SCOPE')
    }
    if (!p.rootProject.extensions.extraProperties.has(key) || p.rootProject.extensions.extraProperties.get(key) != raw) {
        throw new GradleException('ES_ROOT_MODE')
    }
    return true
}

Set<String> esAllowed() {
    return [':', ':flutter', ':sample_alpha', ':sample_beta'] as Set
}

void esCheckProject(Project p, boolean evaluated) {
    if (!esAllowed().contains(p.path) || !esEnabled(p)) {
        throw new GradleException('ES_PROJECT')
    }
    def own = p.extensions.extraProperties
    def expected = [
        'is-plugin': 'false',
        'output-dir': new File(p.rootProject.projectDir, '../../publication').path,
        'elitesync.sdk-identity': '1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313',
        'elitesync.aar-projects': ':,:flutter,:sample_alpha,:sample_beta'
    ]
    expected.each { key, value ->
        if (!own.has(key) || !(own.get(key) instanceof String) || own.get(key) != value) {
            throw new GradleException('ES_PROPERTY_SCOPE')
        }
    }
    if (!own.has('buildNumber') || !(own.get('buildNumber') instanceof String) || !(own.get('buildNumber') ==~ /[0-9a-f]{64}/)) {
        throw new GradleException('ES_ID')
    }
    if (!p.rootProject.extensions.extraProperties.has('buildNumber') || p.rootProject.extensions.extraProperties.get('buildNumber') != own.get('buildNumber')) {
        throw new GradleException('ES_ID')
    }
    if (p.gradle.startParameter.taskNames != ['assembleAarDebug']) {
        throw new GradleException('ES_TASKS')
    }
    if (['local-engine-repo', 'local-engine-out', 'local-engine-host-out', 'local-engine-build-mode', 'skipDependencyChecks'].any { p.hasProperty(it) }) {
        throw new GradleException('ES_BYPASS')
    }
    if (evaluated && p.path != ':') {
        if (!p.hasProperty('android') || !p.android.hasProperty('libraryVariants') || !p.android.productFlavors.isEmpty()) {
            throw new GradleException('ES_LIBRARY')
        }
    }
}

void esAfterProject(Project p) {
    esCheckProject(p, true)
    if (p.path == ':') {
        return
    }
    def singles = p.android.publishing.singleVariants
    if (singles.isEmpty()) {
        p.android.publishing.singleVariant('debug')
    } else if (singles.size() != 1 || singles.first().variantName != 'debug') {
        throw new GradleException('ES_PUBLICATION_VARIANT')
    }
}

void esPublishDebug(Project p) {
    esCheckProject(p, true)
    def debugVariants = p.android.libraryVariants.findAll { it.name == 'debug' && it.flavorName.isEmpty() }
    def component = p.components.findByName('debug')
    if (debugVariants.size() != 1 || component == null || !p.publishing.publications.isEmpty() || !p.publishing.repositories.isEmpty()) {
        throw new GradleException('ES_DEBUG_COMPONENT')
    }
    if (p.tasks.findByName('assembleAarDebug') != null) {
        throw new GradleException('ES_DUPLICATE_TASK')
    }
    p.version = p.extensions.extraProperties.get('buildNumber')
    p.publishing.publications.create('debug', MavenPublication) { pub ->
        groupId = "${pub.groupId}"
        artifactId = "${pub.artifactId}_${pub.name}"
        version = "${pub.version}"
        from component
    }
    p.publishing.repositories.maven {
        name = 'controlledDebug'
        url = p.uri(new File(p.extensions.extraProperties.get('output-dir'), 'outputs/repo'))
    }
    def publishDebug = p.tasks.named('publishDebugPublicationToControlledDebugRepository')
    p.tasks.create('assembleAarDebug') {
        dependsOn(debugVariants.first().assembleProvider)
        finalizedBy(publishDebug)
    }
}

void esProjectsEvaluated(Project root) {
    def actual = ([root.path] + root.subprojects.collect { it.path }) as Set
    if (actual != esAllowed()) {
        throw new GradleException('ES_TOPOLOGY')
    }
    ([root] + root.subprojects.toList()).each { esCheckProject(it, true) }
    Project module = root.findProject(':flutter')
    if (module == null) {
        throw new GradleException('ES_MODULE')
    }
    def participants = [module, root.findProject(':sample_alpha'), root.findProject(':sample_beta')]
    if (participants.any { it == null }) {
        throw new GradleException('ES_PLUGIN')
    }
    participants.each { esPublishDebug(it) }
    def moduleDebug = module.tasks.named('assembleAarDebug').get()
    participants.findAll { it.path != ':flutter' }.each { plugin ->
        moduleDebug.dependsOn(plugin.tasks.named('assembleAarDebug'))
    }
}
```

专用路径不调用原configureProject的所有组件循环、远端embedding分支或finalizedBy publish；只新增debug publication/本地发布目的地及命名debug发布finalizer，不用单一CLI任务名声称全图隔离。`SingleVariant.variantName`、Groovy Script方法访问、publish任务注册可见时点等均自有拟议API用法，未获得编译/配置证明；出现任务尚未注册会失败，不fallback到publish。原模式调用原allprojects、afterProject、projectsEvaluated及所有原函数，原函数文本保留。

## 显式逐project property与调用合同

四个project分别有自己extraProperties；不能只设root ext并假设继承。受审bootstrap须注册早于适配init的allprojects guard，在各project首次评估/apply前安装本表；root须在需要mode判断之前可见。不提供可执行launcher/真实argv；以下仅为调用材料，对实际Gradle init时序的满足仍UNKNOWN。

| local键（固定顺序） | root : | :flutter | :sample_alpha | :sample_beta |
| --- | --- | --- | --- | --- |
| elitesync.aar-entry | module-debug-v1 | module-debug-v1 | module-debug-v1 | module-debug-v1 |
| is-plugin | 字符串false | 字符串false | 字符串false | 字符串false |
| output-dir | publication逻辑根 | 同一显式值 | 同一显式值 | 同一显式值 |
| buildNumber | input_id | 相同input_id | 相同input_id | 相同input_id |
| elitesync.sdk-identity | Flutter历史整源hash | 同一显式值 | 同一显式值 | 同一显式值 |
| elitesync.aar-projects | :,:flutter,:sample_alpha,:sample_beta | 同一显式值 | 同一显式值 | 同一显式值 |

output-dir代码表达式固定 `new File(rootProject.projectDir, '../../publication').path`；它是从声明bundle/module/.android基准派生的publication逻辑根，不接受实际绝对值输入。未来调用时解析为本机路径是单独风险门，表达式不证明没有symlink或目录冲突。sdk-root逻辑materials/flutter_sdk与flutter.sdk/flutter-root的实际设置须由受审输入闭包/启动器提供，两者必须同一受审SDK；identity属性只是历史版本材料，不证明runtime SDK认证。

结构化InvocationContract固定如下，不带可执行命令、env或额外参数字段：

```text id=invocation-expectation
mode = module-debug-v1
requested_tasks = (assembleAarDebug,)
projects = (:, :flutter, :sample_alpha, :sample_beta)
property_install_phase = before_each_project_apply_and_before_adapted_init_guards
property_scopes = local_extra_properties_for_every_project
sdk_root = materials/flutter_sdk
maven_root = materials/maven
publication_root = publication
publication_repository = publication/outputs/repo
repositories_mode = FAIL_ON_PROJECT_REPOS
module_project = :flutter
module_variant = debug
plugin_projects = (:sample_alpha, :sample_beta)
plugin_variants = (debug, debug)
aar_task_edges = (:flutter:assembleAarDebug -> :sample_alpha:assembleAarDebug, :flutter:assembleAarDebug -> :sample_beta:assembleAarDebug)
publish_finalizers = (:flutter:publishDebugPublicationToControlledDebugRepository, :sample_alpha:publishDebugPublicationToControlledDebugRepository, :sample_beta:publishDebugPublicationToControlledDebugRepository)
sdk_identity = 1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313
init_identity = B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2
input_id = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
runtime_ready = false
```

最早可拒绝阶段：纯内存输入验证在返回任何片段前；Kotlin preflight在Flutter apply的SDK/env/engine/repo动作之前（实际落地须补完整原文件字节）；init own property guard在其maven-publish应用前，library/flavor检查在afterProject，debug component/topology在projectsEvaluated。AGP和included-build可能早于preflight，插件自己的评估可能早于最终topology检查；非法状态不能保证全部外部动作前被拒绝。真实执行需启动前完整图/材料/OS隔离门，不把静态guard当沙箱。

## 独立人工正例完整预期

正例P1的materials按四id顺序，准确bytes由上表独立保存回执行规则取得；不调用适配器回算期望。config全部字段为：mode=module-debug-v1，两identity为上表固定值，input_id=64个a，projects及tasks准确为接口固定tuple，sdk_root=materials/flutter_sdk、maven_root=materials/maven、publication_root=publication、repositories_mode=FAIL_ON_PROJECT_REPOS；properties是下列完整tuple，SDK_HASH是上文唯一字面hash的引用，没有另一可选值。

```text id=positive-properties
(
  (':', (('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
  (':flutter', (('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
  (':sample_alpha', (('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
  (':sample_beta', (('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')))
)
```

P1输出EntryMaterials.fragments准确七项，按顺序：apply-helper、apply-preflight、repo-after、tasks-after、init-helpers、init-guards、invocation-expectation。其中每项bytes等于本文对应完整codeblock UTF8/LF；init-guards准确为init-all-after、init-afterProject-after、init-projectsEvaluated-after三个block按该序直接拼接，无额外分隔LF；invocation-expectation为上面完整text block。input_id仅用于InvocationContract及properties，不替换这些不含ID的Kotlin/Groovy源片段。InvocationContract准确等于完整预期字段加properties tuple；输出不包含SDK整文件。before锚和tasks-full/init-full是输入和保留边界，完整后继拼接操作按前述规则，不返回“已写入”状态。

固定正例场景另附阶段预期（人工断言而非已执行结果）：三个参与library均无flavor、local属性齐全、每个有debug variant/component且无既有publication/repo/task。预期创建三份debug publication、三份本地repo/assembleAarDebug、三份命名发布finalizer；module task依赖两plugin任务，原host查找不执行；原configurePlugins与低SDK/NDK检查各在module专用路径保留。输入project scenario不是算法额外字段；是未来编译/运行审查的fixture状态，当前纯接口不能判断真实AGP component是否存在。

## 人工负例完整预期（未运行）

每例独立从P1只改所列项；纯输入失败必须抛固定异常且不返回片段，不写任何宿主内容。runtime fixture类失败是拟议guard结果，不虚称纯转换能检查真实对象。

| 独立改变 | 完整预期 |
| --- | --- |
| config/materials用子类、bytearray、list或properties value非exact str | TypeError TYPE，无EntryMaterials |
| identity错一个hex，材料hash错一个byte、材料id错序/extra/缺失 | ValueError CONTRACT，无EntryMaterials |
| tasks-full缺boundary、重复boundary、不一致源行，repo多锚、init callback重复 | ValueError CONTRACT，无EntryMaterials |
| materials用P1输出任一已适配片段，或原材料混入esControlledModule | ValueError CONTRACT，无二次适配 |
| mode错误/空值，任一project缺mode/local is-plugin，is-plugin改true或bool false | ValueError CONTRACT，无EntryMaterials |
| properties只给root、缺plugin表、继承标记/冲突值/重排或重复key | ValueError CONTRACT，无EntryMaterials |
| projects有:app、:sample_alpha:child、未知plugin、module名不是:flutter | ValueError CONTRACT，无EntryMaterials |
| tasks为assembleAarRelease、assembleAarProfile、:flutter:assembleAarDebug或两个任务 | ValueError CONTRACT，无EntryMaterials |
| root路径../publication、drive/UNC、额外env/executable/override字段、maven_root为https URL | ValueError CONTRACT，无EntryMaterials |
| repositories_mode=PREFER_SETTINGS/空值，拟删gate字段或任意远端repo字段 | ValueError CONTRACT，无EntryMaterials |
| runtime module为app/非library、任何plugin非library或任意flavor | ES_APP/ES_LIBRARY/ES_FLAVOR或ES_PUBLICATION_VARIANT，停止该阶段，不回落host或原发布路径 |
| runtime仅继承mode/false，root或plugin缺own属性、ID不一致 | ES_MODE_SCOPE/ES_PROPERTY_SCOPE/ES_ID，停止该阶段 |
| runtime增加app/意外后代或缺参与plugin | ES_PROJECT或ES_TOPOLOGY/ES_PLUGIN，停止该阶段 |
| runtime module/plugin缺debug component/variant、重复debug或预先有publication/repo/task | ES_DEBUG_COMPONENT/ES_DUPLICATE_TASK，停止，不创建替代release或调用publish |
| runtime任务带前缀/多任务，local-engine或skipDependencyChecks | ES_TASKS/ES_LOCAL_ENGINE/ES_SKIP/ES_BYPASS，停止，不降级 |

某runtime项目先完成注册后另一项目才失败可能留下配置对象，guard不提供事务回滚；不得因此运行任何任务。全部失败效果在真实Gradle执行前必须另审，本轮不跑正负例。

## 四正文与其余闭包

后继可实现SOURCE-ONLY纯材料转换，仅新增拟议tools/aar_entry_materials.py及test_aar_entry_materials.py（需Work另立路径与一次预算），不改变真实SDK；不把本plan当授权。renderer四正文后续修订应显式per-project作用域、保持FAIL_ON_PROJECT_REPOS和Maven-only材料路径、module debug选择、独立publication/output目录；专用init已处理debug publication，插件自己的singleVariant与variants仍须合同，不能靠module beforeVariants覆盖插件。

Api/implementation：保留Handler动态module buildTypeApi、插件间implementation和embedding调用；renderer显式implementation与动态Api重复语义尚未核最终配置/POM，本文不删Handler也不自动删除renderer行。人工依赖图有alpha→beta，debug包含dev alpha，不能套release过滤。真实metadata/native loader、helper最终configuration、GAV/POM字节绑定未证。

NDK不绕过forceNdkDownload；.cxx邻接输出、source/build/native_assets、mergeAssets/intermediate/libs.jar、included-build缓存/输出/仓库、engine/config/env访问都必须进入未来闭包。省略项目repo注入不等于本地材料齐备，也不约束真实插件额外repo；发布repo和依赖repo不是同一个作用域。SDK/NDK、FlutterTask TaskAction/registrant、AGP回调和命名发布任务时序、Kotlin/Groovy编译、完整输入/OS网络路径隔离、manifest权限/POM/真实材料均UNKNOWN。

## 第二轮静态与停点

第二轮将只读本plan一次、核≤256KiB、固定片段/接口/property/来源范围/人工预期与剩余门，并计算片段hash；不执行适配算法、正负例或任何编译。可在同次检查后附回执及最终hash，不能把自检当独立接受。候选唯一plan停Work独立LEVEL2审查，不自接受/后继。

无实际SDK/配置/cache/env/home/real properties/metadata/json/engine/plugin材料读取，无目录搜索/日志再回收、算法测试、下载复制、源码/SDK/renderer/authority/旧证据写、bundle/Gradle/Flutter/JVM/ADB/构建安装启动/UAC、旧D:\EliteSync/真实数据/备份密钥/生产DB/API/SSH或Git commit/pull/push。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false及真实账号/Conversation/恢复保护门保持。

## 第二轮同次静态回执（作者自检）

本plan一次完整读取，普通非reparse且≤256KiB；固定文本、片段唯一性/格式、repo原材料hash、原repo逐字保留、tasks boundary、init原首锚保留、可见变量作用域/调用、property表、人工正负例/来源与剩余门检查PASS。仅文本/hash检查，无适配算法/测试/编译执行；不能证明代码正确或运行安全。第二轮1/1关闭，总2/2；旧预算不重置。检查对象（附回执前）SHA256：E887EFB5684B428D3BD127004EC784317864CD5436187C80E0DE4E5B17AF197B；字节31318。输出主动UTF8≤16KiB。

| 片段id | SHA256（本文codeblock UTF8/LF；init-guards为三block拼接） |
| --- | --- |
| repo-before | 4CC5BDE39C726B5C6D8034E52929E1B3372D99B6F1B10FDAAF2D59FA567B6534 |
| repo-after | 6CD532EDDD8D104E299B6384AD3B81B2738CE700330FF00B2221A824162CEC17 |
| apply-helper | 9028E65E28A50FE8B2DCB042B1753652C18CF3509D24532807C2547F0157C3D8 |
| apply-preflight | 4D17B466317639230DC5505F16CB7B8DED1B1620C5989C6CE2DC63EFB6DD721B |
| tasks-before | B9AC68E2DC9DCCE8C2F2EB1F642FF674ED0AC23501D33499C1145A04E793D236 |
| tasks-after | 1CB68D8BB90ABD8A67CD6ACCB8CDB728DEDB5D8D7E1B7D8F124B592C6DF33BAE |
| init-all-before | 027A4434FFF6F23894D41BDFF3F3483268F9DFF7DF08F7D071E7D1EECDC60D56 |
| init-all-after | 2AABBDC10A6B4E1A7ED84A49BAAD75AB2CFE50346178A43DA63E6F3265E8ACC4 |
| init-afterProject-before | 4B80E184109EF9F5CDAA0858FBB90F65A199B99A912C11C769613200AE2778E7 |
| init-afterProject-after | BA75137EFFEE607DA26DD746BD10B337FD6A844009768599DEAA370811BB20EF |
| init-projectsEvaluated-before | 6C44D5256325F80C7A45180733525AB18DA7C3965AC60D7B8596781AD9806851 |
| init-projectsEvaluated-after | 0B01A220A0980091ED7D4B6E94969306EFE2C53FA215E2DBD149FCEC869CC05E |
| init-helpers | C4FB5C7FABE403AD8ECAD32CCCF9D4A3F12CAFE1D94B5BCF4895664D97A39BC6 |
| invocation-expectation | 2DD764C98FA957EC1A588802BF0A8B56A5B4B535E1BCDAD6F5F89060D27E27AB |
| positive-properties | BDD1120E0B9DA97E1547CC4D120E62CF813F23AC625C5F594FAB07576A2F50B6 |
| init-guards | 4AB9580802F2C3AF8B121F580047C543C2615CF84A6BF86FE5B8EFE4F10EDD88 |

全部片段均为提出的材料域；整SDK版本hash与片段hash区别保持。检查后只附此回执/停点，不改被检查的合同或代码。作者交付停Work独立LEVEL2 ACCEPT/REJECT，不自接受/后继；M5/隔离构建NOT_READY及全部保护门保持。
