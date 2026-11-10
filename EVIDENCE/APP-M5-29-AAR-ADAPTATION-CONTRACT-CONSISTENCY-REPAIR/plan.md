# APP-M5-29｜AAR适配合同一致性修订候选

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL2 REVIEW PENDING。M5-28为REJECT AS IMPLEMENTABLE CONTRACT，旧hash及2/2预算保留。本合同替代其四项矛盾：返回typed操作包；Invocation及所有buildNumber绑定动态input_id；逻辑publication只通过File.path recipe安装；mode只有属性不存在才进入legacy，own null拒绝。本文不生成完整SDK文件、不执行转换或安装；编译与运行仍UNKNOWN，M5/隔离构建NOT_READY。

入口 `D:\EliteSync-v10`，main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，执行会话 `01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad`；CURRENT/TASK_CURRENT与明确派发一致。179条入口dirty/untracked保留；唯一新增本plan，不改M5-28、源码/SDK/renderer/authority/旧证据。沿用local-workflow，所有旧预算关闭。

## 证据与材料域

第一轮chunk `990808`：exit0、0.237411秒；四文件各普通非reparse、≤256KiB、总107911 bytes≤1MiB，各一次完整读取/hash，预期全部匹配。wrapper只解析唯一JSON output，不执行保存命令；目标SECTION唯一、重复源行一致且范围完整。主动打印前累计UTF8，末状态前14885 bytes，含末状态低于32KiB，无截断/失败/重试。第一轮1/1关闭；本次没有SDK读取。

| 本地EVIDENCE来源 | bytes | SHA256 |
| --- | ---: | --- |
| APP-M5-28-CONTROLLED-AAR-ENTRY-ADAPTATION-CONTRACT/plan.md | 33736 | 57A2A856780B687E4E582E1DFAC1C71FBE3069D80C51726BEDF66028F2D254FC |
| APP-M5-27-AAR-CONFIGURATION-ENTRY-CLOSURE/m526-original-receipt.txt | 24935 | FE1A9CF5D3DDAF259A5412346B77DF43CFB05295B31BBF8FB3767C2423F2E062 |
| 同M5-27目录round-2-original-receipt.txt | 31659 | 8B4657648F3BE8CA1A36E4DFCCED2CFAEA0FAFE18C6BB2B4DCEBD5EFB6B1FE44 |
| 同M5-27目录round-1-original-receipt.txt | 17581 | 9FD10B2C9B46D2578F7BFD32E266248A4C45CEC74140A39A1ED734E5DC1EA8E6 |

归一规则固定：output按LF拆行（只把行分隔CRLF归一LF）；指定SECTION exact唯一；编号行格式为decimal+`: `+正文，仅剥该前缀，不strip缩进或正文尾空格。重复源行须一致，按准确范围逐行升序join LF，最后加一个LF，包括原末尾空行贡献。缺行/多SECTION/不一致直接拒绝。apply摘录已省注释/空行，只是该材料域，不填造完整源码。

冻结输入bytes可直接引用以下唯一来源id/范围与hash；这不是查任意文件的授权。后继纯函数接收这些bytes，不读取来源文件。

| id / SECTION与源行 | 归一片段SHA256 |
| --- | --- |
| tasks-full / m526：SECTION FlutterPlugin.kt METHOD addFlutterTasks 349-533，349–533 | B89C513B5803A734D6DC8F1574EED66F9BC173787D13A6D88F5604833F9CBEEE |
| repo-block / round2：SECTION FlutterPlugin apply 46-307 ALL_NONCOMMENT_NONBLANK_LINES，88–101 | 4CC5BDE39C726B5C6D8034E52929E1B3372D99B6F1B10FDAAF2D59FA567B6534 |
| init-full / round2：SECTION aar_init_script FULL，1–191 | 5252CD23EDFD3F02AB1E43875F2F0BAE286589A035475D092A87723E02524FCC |
| plugin-deps / round1：SECTION PluginHandler FULL 1-261，226–258 | 5B7712D84D82BDCE1BB071419E6BAEFE134754C80B62E3C8BAE1005058E4C33F |

历史整SDK锚FlutterPlugin=`1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313`，init=`B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2`。整文件hash与归一片段hash分开，不能凭这些摘录获得整SDKpatch或版本认证。M5-28未接受，引用它只固定候选字节来源，不继承其错误输出域。

## 最终输入与返回schema

拟议 `adapt_module_debug_entry(*, materials: tuple[tuple[str,bytes],...], config: dict) -> EntryMaterials`，纯内存。exact tuple/str/bytes/dict，类型子类/custom object/list/bytearray拒绝；TypeError固定TYPE，语义错误ValueError固定CONTRACT，不回显输入。materials准确顺序tasks-full、repo-block、init-full、plugin-deps，四hash如上，每份≤256KiB总≤1MiB。

config必须且仅有mode、flutter_identity、init_identity、input_id、projects、properties、tasks、sdk_root、maven_root、publication_root、repositories_mode；mode固定module-debug-v1，两identity固定历史锚；input_id任意64个ASCII小写hex。projects固定 `(':', ':flutter', ':sample_alpha', ':sample_beta')`；tasks固定 `('assembleAarDebug',)`；三root固定materials/flutter_sdk、materials/maven、publication；repositories_mode固定FAIL_ON_PROJECT_REPOS。properties为按projects同序的tuple `(path, tuple[(key, logical_value),...])`；六键与顺序见P1/P2。value是exact str，buildNumber必须与config.input_id相等；publication是logical token，不是runtime安装值。无extra/重复键/继承标记/路径覆盖/env/executable。

所有返回类型frozen dataclass，所有容器tuple、值str/bytes/enum/frozen对象。固定schema如下：

```text id=output-schema
EntryMaterials(
  operations: tuple[PatchOperation, ...],
  attachments: tuple[Attachment, ...],
  invocation: InvocationContract
)
PatchOperation(
  order: exact int,
  target: Literal['repo-block','tasks-full','init-full'],
  kind: Literal['REPLACE_UNIQUE','INSERT_BEFORE_UNIQUE'],
  input_fragment_sha256: exact str,
  anchor_id: exact str,
  before: exact bytes,
  after: exact bytes
)
Attachment(
  id: Literal['apply-helper','apply-preflight-proposal'],
  placement: Literal['FLUTTER_PLUGIN_CLASS_MEMBER','APPLY_AFTER_THIS_PROJECT_ASSIGNMENT'],
  historical_sdk_identity: exact str,
  before: exact bytes,
  after: exact bytes,
  executable_patch: Literal[False]
)
InvocationContract(
  mode: exact str,
  requested_tasks: tuple[str,...],
  projects: tuple[str,...],
  logical_properties: tuple[tuple[str,tuple[tuple[str,str],...]],...],
  property_installation: tuple[InstallationGroup,...],
  property_install_phase: exact str,
  sdk_root: exact str,
  maven_root: exact str,
  publication_root: exact str,
  publication_repository: exact str,
  repositories_mode: exact str,
  module_project: exact str,
  module_variant: exact str,
  plugin_projects: tuple[str,...],
  plugin_variants: tuple[str,...],
  aar_task_edges: tuple[tuple[str,str],...],
  publish_finalizers: tuple[str,...],
  sdk_identity: exact str,
  init_identity: exact str,
  input_id: exact str,
  runtime_ready: Literal[False]
)
InstallationGroup(project: exact str, scope: Literal['LOCAL_EXTRA'], recipes: tuple[PropertyRecipe,...])
PropertyRecipe = LiteralString(key: exact str, value: exact str) | RootProjectDirFilePath(key: Literal['output-dir'], base: Literal['ROOT_PROJECT_DIR'], child_components: tuple[str,str,str], result: Literal['FILE_PATH'], install_phase: exact str)
```

返回不是已适配整片段，亦无fragment拼接结果/invocation固定文本字段。operations是完整typed修订描述，不立即应用。后继在新任务可将tasks-full/init-full局部scratch按该序产生完整适配片段，但本轮没有执行转换。完整apply未持有：helper和preflight只作为Attachment落地提案，class插入位置/import/API仍须独立来源门，executable_patch=false。

全输入/版本/hash/锚唯一性/无适配标记验证后，才能返回一个完整操作包；失败无部分返回、无宿主写入。后继执行时先在scratch完成所有操作与检查再发布一个结果，不提供事务已执行证明。相同原输入重复调用结果等值；将已适配/部分适配材料再次作为输入拒绝，不静默二次适配。输出顺序恒定，UTF8无BOM/LF；每个下方block含末尾LF，保留所有缩进，空before bytes明示，不引入省略正文。

## 完整operations与保留规则

以下六项是唯一operations；所有before/after全文在本文block，输入digest取上表对应target。before bytes是锚/替换范围，不是假称完整target。INsert语义after为插入bytes（不包含锚），REPLACE语义after替换before。每操作在当时scratch exact count=1才允许；共享init-all锚先插helpers后替换guard，helpers没有同样独立首锚。原target中不在精确替换范围的每个byte保留，不根据fun正则重建函数。

| order | target | kind | anchor_id / before | after |
| ---: | --- | --- | --- | --- |
| 0 | repo-block | REPLACE_UNIQUE | repo-before（覆盖整个该输入片段） | repo-after |
| 1 | tasks-full | REPLACE_UNIQUE | tasks-before（原453–456边界） | tasks-after |
| 2 | init-full | INSERT_BEFORE_UNIQUE | init-all-before（原113） | init-helpers（全文，含一个最终LF） |
| 3 | init-full | REPLACE_UNIQUE | init-all-before | init-all-after |
| 4 | init-full | REPLACE_UNIQUE | init-afterProject-before（原117） | init-afterProject-after |
| 5 | init-full | REPLACE_UNIQUE | init-projectsEvaluated-before（原150） | init-projectsEvaluated-after |

tasks原349–454的targetPlatforms361–362、flutterPlugin=this364及app分支保留，原456–533 host分支保留；新增分支在app返回之后/host之前，不复制app host assets代码。init原三个callback全部body及原其它函数保持，仅插guard；受控路径不调用原遍历全组件/publish，未启用时继续原路径。repo-after内原repo-before逐字保留（包括原缩进），不是只说语义等价。plugin-deps仅输入校验/来源，不产生修改。

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

## 完整修正helpers与attachments

Kotlin先判own存在或project.hasProperty存在；不存在还检查root是否单独存在，拒绝不一致。只在两者均无mode时legacy=false。存在则必须own，own值必须非null String且准确值；root同样必须own非null正确String。不用findProperty(null)判断不存在。

Attachment apply-helper：placement=FLUTTER_PLUGIN_CLASS_MEMBER，before=空bytes，after为完整block；Attachment apply-preflight-proposal：placement=APPLY_AFTER_THIS_PROJECT_ASSIGNMENT，before/after为下列完整block（历史apply:47锚），仅待审落地提案，不声称可对完整SDK应用。SDK identity均为历史Flutter锚。

```kotlin id=apply-helper
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

```kotlin id=preflight-before
        this.project = project
```

```kotlin id=preflight-after
        this.project = project
        esControlledModule(project)
```

Groovy完整helpers如下，其余发布设计维持M5-28；mode函数修正，root.subprojects仍含全部后代，debug组件/参与项目缺失拒绝，未知AGP API不宣称已编译。

```groovy id=init-helpers
boolean esEnabled(Project p) {
    def key = 'elitesync.aar-entry'
    def own = p.extensions.extraProperties
    def root = p.rootProject
    def rootOwn = root.extensions.extraProperties
    boolean present = own.has(key) || p.hasProperty(key)
    if (!present) {
        if (rootOwn.has(key) || root.hasProperty(key)) {
            throw new GradleException('ES_ROOT_MODE')
        }
        return false
    }
    if (!own.has(key)) {
        throw new GradleException('ES_MODE_SCOPE')
    }
    def raw = own.get(key)
    if (!(raw instanceof String) || raw != 'module-debug-v1') {
        throw new GradleException('ES_MODE_SCOPE')
    }
    if (!rootOwn.has(key)) {
        throw new GradleException('ES_ROOT_MODE')
    }
    def rootRaw = rootOwn.get(key)
    if (!(rootRaw instanceof String) || rootRaw != raw) {
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

## logical properties到安装recipe

所有project显式LOCAL_EXTRA，phase固定 `BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS`。不依赖root ext继承；受审bootstrap是以后执行前置条件，本纯函数仅返回recipe，不执行bootstrap。

recipe字段无默认/override。唯一File.path recipe为：

```text id=output-dir-recipe
RootProjectDirFilePath(
  key='output-dir',
  base='ROOT_PROJECT_DIR',
  child_components=('..','..','publication'),
  result='FILE_PATH',
  install_phase='BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS'
)
```

child_components不是调用者自由路径：准确固定这三个组件，joins成`../../publication`。未来installer执行 `File(rootProject.projectDir, "../../publication").path`，结果string写到每project自己的extra；不把logical token publication直接写入。Kotlin helper比较同一File(root.projectDir,..).path；Groovy比较同一new File(p.rootProject.projectDir,..).path。无normalize/canonical/resolve/读取存在性/symlink检查，必须同一root基准。

其它recipe为LiteralString，key和值直接从validated logical_properties取用；buildNumber由config.input_id绑定后转LiteralString。整个recipe tuple键序为mode、is-plugin、output-dir、buildNumber、SDK identity、project集合。每project的logical表都是完整六键，不省缺值或只设root。安装组按projects四项顺序。

人工逻辑模型，未访问任何目录：令root projectDir token为`B/module/.android`、模型分隔符为`/`，同一File.path词法模型的结果为`B/module/.android/../../publication`，不是字符串`publication`。P1/P2都得到相同这个表达式值，并同时与两helper的比较表达式相等。实际Windows/JVM native separators/真实绝对位置必须由未来installer一致处理；此人工模型不证明真实路径解析、ACL、symlink或OS隔离。不得把模型结果当实际电脑路径。

## P1/P2全部输入与完整Invocation预期

以下定义共享常量F/I/P/T与各完整table，不执行生成器。引用这些已全文定义的不可变常量是完整对象描述，不是省略字段；不存在任意默认或需后继猜的槽。操作六项和attachment两项bytes完全同于本文固定blocks，两例均不含调用文本返回值。通用Invocation必须从config.input_id构造，不接受冻结64a字节作为输出。

F=`1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313`；I=`B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2`；P=`(':',':flutter',':sample_alpha',':sample_beta')`；T=`('assembleAarDebug',)`；ID_A=`aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`；ID_B=`bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb`。

```text id=P1-properties
(
(':',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
(':flutter',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
(':sample_alpha',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
(':sample_beta',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')))
)
```

```text id=P2-properties
(
(':',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
(':flutter',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
(':sample_alpha',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta'))),
(':sample_beta',(('elitesync.aar-entry','module-debug-v1'),('is-plugin','false'),('output-dir','publication'),('buildNumber','bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')))
)
```

R_A/R_B分别为以下完整recipes tuple，FILE_RECIPE准确等于output-dir-recipe block定义；它是typed字段值，不是代码运行结果。

```text id=P1-recipes
R_A = (
LiteralString('elitesync.aar-entry','module-debug-v1'),
LiteralString('is-plugin','false'),
FILE_RECIPE,
LiteralString('buildNumber','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
LiteralString('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),
LiteralString('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')
)
```

```text id=P2-recipes
R_B = (
LiteralString('elitesync.aar-entry','module-debug-v1'),
LiteralString('is-plugin','false'),
FILE_RECIPE,
LiteralString('buildNumber','bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),
LiteralString('elitesync.sdk-identity','1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'),
LiteralString('elitesync.aar-projects',':,:flutter,:sample_alpha,:sample_beta')
)
```

完整输入P1：materials为上表准确四原bytes，config为下列11字段；P2同样全文列出，不通过适配器回算任何预期。properties blocks的literal tuple分别记L_A/L_B。

```text id=P1-input
config = dict(
mode='module-debug-v1', flutter_identity=F, init_identity=I,
input_id='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
projects=P, properties=L_A, tasks=T,
sdk_root='materials/flutter_sdk', maven_root='materials/maven',
publication_root='publication', repositories_mode='FAIL_ON_PROJECT_REPOS'
)
materials = (('tasks-full',TASKS_ORIGINAL_BYTES),('repo-block',REPO_ORIGINAL_BYTES),('init-full',INIT_ORIGINAL_BYTES),('plugin-deps',DEPS_ORIGINAL_BYTES))
```

```text id=P2-input
config = dict(
mode='module-debug-v1', flutter_identity=F, init_identity=I,
input_id='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
projects=P, properties=L_B, tasks=T,
sdk_root='materials/flutter_sdk', maven_root='materials/maven',
publication_root='publication', repositories_mode='FAIL_ON_PROJECT_REPOS'
)
materials = (('tasks-full',TASKS_ORIGINAL_BYTES),('repo-block',REPO_ORIGINAL_BYTES),('init-full',INIT_ORIGINAL_BYTES),('plugin-deps',DEPS_ORIGINAL_BYTES))
```

四ORIGINAL_BYTES唯一由冻结id/范围/hash定义，不能换其它版本。P1/P2 operations准确六项表，before/after逐block字节，inputdigest准确上表；attachments准确两项描述。所有源操作/attachment bytes两例恒定，不包含64a/64b。动态变化只在Invocation.input_id、logical表四个buildNumber及installation四个LiteralString buildNumber；FILE_RECIPE同值，不生成调用文本。

```text id=P1-invocation
InvocationContract(
mode='module-debug-v1', requested_tasks=('assembleAarDebug',),
projects=(':',':flutter',':sample_alpha',':sample_beta'),
logical_properties=L_A,
property_installation=(InstallationGroup(':','LOCAL_EXTRA',R_A),InstallationGroup(':flutter','LOCAL_EXTRA',R_A),InstallationGroup(':sample_alpha','LOCAL_EXTRA',R_A),InstallationGroup(':sample_beta','LOCAL_EXTRA',R_A)),
property_install_phase='BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS',
sdk_root='materials/flutter_sdk', maven_root='materials/maven',
publication_root='publication', publication_repository='publication/outputs/repo',
repositories_mode='FAIL_ON_PROJECT_REPOS', module_project=':flutter', module_variant='debug',
plugin_projects=(':sample_alpha',':sample_beta'), plugin_variants=('debug','debug'),
aar_task_edges=((':flutter:assembleAarDebug',':sample_alpha:assembleAarDebug'),(':flutter:assembleAarDebug',':sample_beta:assembleAarDebug')),
publish_finalizers=(':flutter:publishDebugPublicationToControlledDebugRepository',':sample_alpha:publishDebugPublicationToControlledDebugRepository',':sample_beta:publishDebugPublicationToControlledDebugRepository'),
sdk_identity=F, init_identity=I,
input_id='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', runtime_ready=False
)
```

```text id=P2-invocation
InvocationContract(
mode='module-debug-v1', requested_tasks=('assembleAarDebug',),
projects=(':',':flutter',':sample_alpha',':sample_beta'),
logical_properties=L_B,
property_installation=(InstallationGroup(':','LOCAL_EXTRA',R_B),InstallationGroup(':flutter','LOCAL_EXTRA',R_B),InstallationGroup(':sample_alpha','LOCAL_EXTRA',R_B),InstallationGroup(':sample_beta','LOCAL_EXTRA',R_B)),
property_install_phase='BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS',
sdk_root='materials/flutter_sdk', maven_root='materials/maven',
publication_root='publication', publication_repository='publication/outputs/repo',
repositories_mode='FAIL_ON_PROJECT_REPOS', module_project=':flutter', module_variant='debug',
plugin_projects=(':sample_alpha',':sample_beta'), plugin_variants=('debug','debug'),
aar_task_edges=((':flutter:assembleAarDebug',':sample_alpha:assembleAarDebug'),(':flutter:assembleAarDebug',':sample_beta:assembleAarDebug')),
publish_finalizers=(':flutter:publishDebugPublicationToControlledDebugRepository',':sample_alpha:publishDebugPublicationToControlledDebugRepository',':sample_beta:publishDebugPublicationToControlledDebugRepository'),
sdk_identity=F, init_identity=I,
input_id='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb', runtime_ready=False
)
```

## mode矩阵与四问题负例（人工预期，未执行）

纯接口只接受受控mode，不提供legacy config；legacy分支保留的是运行源材料行为。runtime fixtures与pure输入失败分开，不拿pure转换假装检查真实AGP对象。

| runtime mode状态 | 完整预期 |
| --- | --- |
| project/root均不存在mode（own.has和hasProperty均false） | 两helper返回false，原legacy分支文本继续 |
| own存在且null，即使findProperty返回null | Kotlin ES_MODE；Groovy ES_MODE_SCOPE，拒绝，不legacy |
| own存在且Boolean false | ES_MODE / ES_MODE_SCOPE，拒绝 |
| own存在但错误string/空string/其它type | ES_MODE / ES_MODE_SCOPE，拒绝 |
| project有继承mode但own缺失 | ES_SCOPE / ES_MODE_SCOPE，拒绝 |
| project不存在mode而root存在（包括null） | ES_ROOT_MODE，拒绝 |
| project正确own mode，root own缺失/继承/root null或错误值 | ES_ROOT_SCOPE或ES_ROOT_MODE；Groovy ES_ROOT_MODE，拒绝 |
| project/root正确own String值一致，library/属性/task等其余条件正确 | true并进入受控路径 |
| project/root值冲突 | ES_ROOT_MODE，拒绝 |

纯负例每项独立从P1/P2改一处；失败固定TYPE或CONTRACT，无EntryMaterials/部分操作包，无宿主写入：

| 输入改变 | 完整预期 |
| --- | --- |
| materials/id顺序错、缺输入、版本/hash/bytes错、缺/重复锚、不一致源行、已适配输入 | CONTRACT，拒绝整个包 |
| 要求fragments/完整SDK输出或任意patch target/自由覆盖字段 | CONTRACT，拒绝；只有固定六operations和两attachments |
| P2.input_id=64b但properties任一buildNumber仍64a或少一个project | CONTRACT，拒绝；不输出固定64a调用文本 |
| input_id非64个ASCII小写hex、bool/bytes/object | CONTRACT或TYPE，拒绝 |
| publication token改绝对/UNC/drive/../，properties直接给模型runtime路径 | CONTRACT，拒绝；only publication逻辑token |
| config增加recipe override，FILE_RECIPE组件/基准/结果/phase/作用域自由字段 | CONTRACT，拒绝；recipes由固定schema生成，不接受任意override |
| properties仅root、继承、缺false、false为bool、项目值冲突/重复key | CONTRACT或TYPE，拒绝 |
| pure mode missing/null/false/wrong，root-child conflict encoded inlogical表 | CONTRACT或TYPE，拒绝 |
| 增app/未知project/意外后代，非:flutter，任务release/profile/带前缀/多任务 | CONTRACT，拒绝 |
| 远端repo/PREFER_SETTINGS/删gate/local-engine/skip检查字段 | CONTRACT，拒绝 |

runtime fixture仍需：非library/flavor→ES_APP/ES_LIBRARY/ES_FLAVOR；debug组件/variant缺失、重复或既有pub/repo→ES_DEBUG_COMPONENT；重复任务→ES_DUPLICATE_TASK；额外后代→ES_TOPOLOGY/ES_PROJECT；非法任务→ES_TASKS；local-engine/skip→ES_LOCAL_ENGINE/ES_SKIP/ES_BYPASS。缺失时停止，不回落host、release或publish。可能先注册某项目再失败另一项目；不能声称runtime事务回滚。

## 四Required替代与未解门

原M5-28“七fragments输出/拼callback首锚”等条款被本六typed operations和两Attachment替代，不返回完整转换结果；原固定invocation-expectation bytes不作为通用输出，P1/P2仅独立预期；原properties安装说法被logical表与typed recipe两层替代；原findProperty null早退被完整presence检查helpers替代。M5-28仍REJECT，不因本新合同追认。

剩余域保持：无host library debug接线、configurePlugins/低SDK/NDK检查、仅受控模式省项目Maven、debug publication/task与原路径保留；FAIL_ON_PROJECT_REPOS不删，不用PREFER_SETTINGS/远端/local-engine/跳检查。TaskAction/registrant、Api与renderer implementation最终配置/POM、NDK/.cxx/source/build/native_assets/mergeAssets、真实SDK/engine/config/metadata/plugin输入、AGP/Groovy/Kotlin编译及回调/命名发布task时序、绝对路径/symlink/ACL/OS隔离/manifest/真实材料均UNKNOWN。属性bootstrap前置时点、included-build和plugin额外repo不因recipe变安全；preflight前AGP/included-build可能已有外部动作，不能称sandbox或release ready。

后继仅可由Work另立SOURCE-ONLY纯材料实现路径/预算；本轮不实现、不执行转换，不对完整SDKapply补丁自授权。第二轮仅读本plan一次、≤256KiB/输出≤16KiB做固定文本/hash一致性，不跑任何正负例；结果只附同次回执/停点，不修改被检查合同。

唯一plan停Work独立LEVEL2 ACCEPT/REJECT，不自接受/派后继。无SDK/配置/cache/env/home/真实properties/metadata/engine/plugin材料读取、目录搜索索引/日志再回收、下载复制/算法测试/编译/Gradle/Flutter/JVM/ADB/构建安装启动/UAC/落地bundle、源码/renderer/authority/旧证据写、旧D:\EliteSync/真实数据/备份密钥/生产DB/API/SSH或Git提交/pull/push。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false与所有保护门保持。

## 第二轮同次作者静态回执

一次读本plan，普通非reparse、≤256KiB；检查前字节37018，SHA256 897CB695323E52EC82DFBC5A340DD779A453243A3B87276241C455A71B6760E6。六operations顺序/typed返回域与attachment提案、before hash/原repo保留、未变tasks-after、P1/P2完整fixture仅ID及L/R引用差异、恒定源bytes不含动态ID、安装recipe字段、presence先于取值及null无legacy、模式矩阵/原文保留/剩余门固定文本检查PASS。只做标准库文本/hash，不执行转换算法、正负例、Kotlin/Groovy/Gradle；不证明语义正确或运行安全。打印前主动累计UTF8≤16KiB；第二轮1/1关闭，总2/2，旧预算保持。

| block id | SHA256（UTF8/LF） |
| --- | --- |
| output-schema | 9BD69C6B9BB00F7049F4DAF3CF7C3DB15DFC3C9B45F9EA17F964E4413045C744 |
| repo-before | 4CC5BDE39C726B5C6D8034E52929E1B3372D99B6F1B10FDAAF2D59FA567B6534 |
| repo-after | 6CD532EDDD8D104E299B6384AD3B81B2738CE700330FF00B2221A824162CEC17 |
| tasks-before | B9AC68E2DC9DCCE8C2F2EB1F642FF674ED0AC23501D33499C1145A04E793D236 |
| tasks-after | 1CB68D8BB90ABD8A67CD6ACCB8CDB728DEDB5D8D7E1B7D8F124B592C6DF33BAE |
| init-all-before | 027A4434FFF6F23894D41BDFF3F3483268F9DFF7DF08F7D071E7D1EECDC60D56 |
| init-all-after | 2AABBDC10A6B4E1A7ED84A49BAAD75AB2CFE50346178A43DA63E6F3265E8ACC4 |
| init-afterProject-before | 4B80E184109EF9F5CDAA0858FBB90F65A199B99A912C11C769613200AE2778E7 |
| init-afterProject-after | BA75137EFFEE607DA26DD746BD10B337FD6A844009768599DEAA370811BB20EF |
| init-projectsEvaluated-before | 6C44D5256325F80C7A45180733525AB18DA7C3965AC60D7B8596781AD9806851 |
| init-projectsEvaluated-after | 0B01A220A0980091ED7D4B6E94969306EFE2C53FA215E2DBD149FCEC869CC05E |
| apply-helper | 44503DD02B3F0B12E4713670BFB799D08A15A59195D0EF5C9FC45172D98719DE |
| preflight-before | 7A69ABFDFACB460AFFC96ED2443A9F77E5D60C4FC280AA6FDEB44298032B3965 |
| preflight-after | 3C085E0AF7BA0EB36970E3D7122522EB621103311A919C922B4AF693EA99E111 |
| init-helpers | 0256AE1A42DDD3AA7D592D053A97103D6B5BCAF67A0F7854285F7FDCDF183112 |
| output-dir-recipe | 4B7205BCE2677F1AEA0D9971760987708EA893CBDD91608155E94D20C58B7E65 |
| P1-properties | 4C04F37EA7CDECE1E3800BD2363683734F34A075B5084A46C68E60537BBC26E4 |
| P2-properties | 372D30B7617042C5A2388BD8BEDB558B99BFF7B41DA521D481A2A16232E22A2B |
| P1-recipes | 885E35DDD4C01D1DCB3C7F41DF6C865CE2C0D21C7D6A402D795C63CF39432E67 |
| P2-recipes | 1269FAB7F59FEF823A04E63F00AEE8163030FD58B2AC6F0A32403EE523965235 |
| P1-input | 65FD6F7D83B7AAF462ABBA5BD455F44BA97AA3240C4556304E98761DE88A6024 |
| P2-input | 076F83722457138369F94EB5971BC0707A067E0C5A981DB882446A5E41AB1181 |
| P1-invocation | 939D41AF1D637B405104923ABADCC5148CA8B0DA07B3EDD79275D1F2B7A4068B |
| P2-invocation | BCA7A86BFD4854FB06078A746A28BA33D46137A4F5626C67BD893281CD7925D3 |

检查后仅附本同次回执与停点，被检查schema/代码/fixture未改。作者候选停Work独立LEVEL2复核，不自接受/后继；M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false及全部保护门保持。
