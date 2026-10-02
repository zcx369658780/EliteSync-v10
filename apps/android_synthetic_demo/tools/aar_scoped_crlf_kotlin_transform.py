"""M5-62 SOURCE-ONLY: exact CRLF materials; original line context only."""
import hashlib

_SOURCE_SIZE = 42405
_SOURCE_SHA256 = '1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'
_OUTPUT_SIZE = 45907

_PATCHES = (
    ('helper-member', b'    private var pluginHandler: PluginHandler? = null\r\n\r\n    override fun apply(project: Project) {\r\n', b'    private var pluginHandler: PluginHandler? = null\r\n\r\n    private fun esControlledModule(p: Project): Boolean {\r\n        val key = "elitesync.aar-entry"\r\n        val own = p.extensions.extraProperties\r\n        val root = p.rootProject\r\n        val rootOwn = root.extensions.extraProperties\r\n        val present = own.has(key) || p.hasProperty(key)\r\n        if (!present) {\r\n            check(!rootOwn.has(key) && !root.hasProperty(key)) { "ES_ROOT_MODE" }\r\n            return false\r\n        }\r\n        check(own.has(key)) { "ES_SCOPE" }\r\n        val raw = own.get(key)\r\n        check(raw is String && raw == "module-debug-v1") { "ES_MODE" }\r\n        check(rootOwn.has(key)) { "ES_ROOT_SCOPE" }\r\n        val rootRaw = rootOwn.get(key)\r\n        check(rootRaw is String && rootRaw == raw) { "ES_ROOT_MODE" }\r\n        check(p.path == ":flutter") { "ES_PROJECT" }\r\n        check(!FlutterPluginUtils.isFlutterAppProject(p)) { "ES_APP" }\r\n        val android = p.extensions.findByType(LibraryExtension::class.java)\r\n        check(android != null && android.productFlavors.isEmpty()) { "ES_LIBRARY" }\r\n        check(p.gradle.startParameter.taskNames == listOf("assembleAarDebug")) { "ES_TASKS" }\r\n        val values = linkedMapOf(\r\n            "is-plugin" to "false",\r\n            "output-dir" to File(root.projectDir, "../../publication").path,\r\n            "elitesync.sdk-identity" to "1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313",\r\n            "elitesync.aar-projects" to ":,:flutter,:sample_alpha,:sample_beta"\r\n        )\r\n        values.forEach { (name, value) ->\r\n            check(own.has(name)) { "ES_SCOPE" }\r\n            check(own.get(name) == value) { "ES_PROPERTY" }\r\n        }\r\n        check(own.has("buildNumber")) { "ES_SCOPE" }\r\n        val id = own.get("buildNumber")\r\n        check(id is String && Regex("[0-9a-f]{64}").matches(id)) { "ES_ID" }\r\n        check(rootOwn.has("buildNumber")) { "ES_ROOT_SCOPE" }\r\n        check(rootOwn.get("buildNumber") == id) { "ES_ID" }\r\n        listOf("local-engine-repo", "local-engine-out", "local-engine-host-out", "local-engine-build-mode").forEach {\r\n            check(!p.hasProperty(it)) { "ES_LOCAL_ENGINE" }\r\n        }\r\n        check(!p.hasProperty("skipDependencyChecks")) { "ES_SKIP" }\r\n        return true\r\n    }\r\n\r\n    override fun apply(project: Project) {\r\n', 44, 46, 1793, 1893),
    ('apply-preflight', b'        this.project = project\r\n', b'        this.project = project\r\n        esControlledModule(project)\r\n', 47, 47, 1893, 1925),
    ('repository-consumer', b'        val hostedRepository: String =\r\n            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)\r\n                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST\r\n        val repository: String? =\r\n            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {\r\n                project.property(PROP_LOCAL_ENGINE_REPO) as String?\r\n            } else {\r\n                "$hostedRepository/${engineRealm}download.flutter.io"\r\n            }\r\n        rootProject.allprojects {\r\n            repositories.maven {\r\n                url = uri(repository!!)\r\n            }\r\n        }\r\n', b'        if (!esControlledModule(project)) {\r\n        val hostedRepository: String =\r\n            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)\r\n                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST\r\n        val repository: String? =\r\n            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {\r\n                project.property(PROP_LOCAL_ENGINE_REPO) as String?\r\n            } else {\r\n                "$hostedRepository/${engineRealm}download.flutter.io"\r\n            }\r\n        rootProject.allprojects {\r\n            repositories.maven {\r\n                url = uri(repository!!)\r\n            }\r\n        }\r\n        }\r\n', 88, 101, 3530, 4132),
    ('tasks-consumer', b'            return\r\n        }\r\n        // Flutter host module project (Add-to-app).\r\n        val hostAppProjectName: String? =\r\n', b'            return\r\n        }\r\n        if (esControlledModule(projectToAddTasksTo)) {\r\n            val android = projectToAddTasksTo.extensions.findByType(LibraryExtension::class.java)\r\n            check(android != null) { "ES_LIBRARY" }\r\n            android.libraryVariants.all esLibraryVariant@{\r\n                val variant = this\r\n                if (variant.name != "debug") {\r\n                    return@esLibraryVariant\r\n                }\r\n                check(variant.flavorName.isEmpty()) { "ES_FLAVOR" }\r\n                check(FlutterPluginUtils.buildModeFor(variant.buildType) == "debug") { "ES_MODE" }\r\n                val assembleTask = variant.assembleProvider.get()\r\n                check(FlutterPluginUtils.shouldConfigureFlutterTask(projectToAddTasksTo, assembleTask)) { "ES_TASKS" }\r\n                addFlutterDeps(variant, flutterPlugin, targetPlatforms)\r\n            }\r\n            getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)\r\n            FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(\r\n                projectToAddTasksTo,\r\n                getPluginHandler(projectToAddTasksTo).getPluginList()\r\n            )\r\n            return\r\n        }\r\n        // Flutter host module project (Add-to-app).\r\n        val hostAppProjectName: String? =\r\n', 453, 456, 22417, 22545),
)

_DECLARATIONS = (
    ('class', b'class FlutterPlugin : Plugin<Project> {\r\n', 34, 1327, 1368),
    ('apply', b'    override fun apply(project: Project) {\r\n', 46, 1849, 1893),
    ('addFlutterTasks', b'    private fun addFlutterTasks(projectToAddTasksTo: Project) {\r\n', 349, 16485, 16550),
)


def _count_overlapping(blob: bytes, needle: bytes) -> int:
    count = 0
    position = 0
    while True:
        position = blob.find(needle, position)
        if position < 0:
            return count
        count += 1
        position += 1


def _line_span(blob: bytes, first: int, last: int) -> tuple:
    start = 0
    for _ in range(first - 1):
        position = blob.find(b'\n', start)
        if position < 0:
            raise ValueError('ES_SOURCE_SCOPE')
        start = position + 1
    end = start
    for _ in range(last - first + 1):
        position = blob.find(b'\n', end)
        if position < 0:
            raise ValueError('ES_SOURCE_SCOPE')
        end = position + 1
    return start, end, blob[start:end]


def render_scoped_flutter_plugin(source: bytes) -> bytes:
    """Return all four fixed edits only after every original/scratch gate passes."""
    if type(source) is not bytes:
        raise ValueError('ES_SOURCE_TYPE')
    if len(source) != _SOURCE_SIZE:
        raise ValueError('ES_SOURCE_SIZE')
    if hashlib.sha256(source).hexdigest().upper() != _SOURCE_SHA256:
        raise ValueError('ES_SOURCE_IDENTITY')

    for _, before, _, first, last, start, end in _PATCHES:
        if _count_overlapping(source, before) != 1:
            raise ValueError('ES_ANCHOR_COUNT')
        if _line_span(source, first, last) != (start, end, before):
            raise ValueError('ES_SOURCE_SCOPE')

    for _, raw, line, start, end in _DECLARATIONS:
        if _count_overlapping(source, raw) != 1:
            raise ValueError('ES_SOURCE_SCOPE')
        if _line_span(source, line, line) != (start, end, raw):
            raise ValueError('ES_SOURCE_SCOPE')

    previous_start = -1
    previous_end = -1
    for _, _, _, _, _, start, end in _PATCHES:
        if start <= previous_start or start < previous_end or end <= start:
            raise ValueError('ES_ANCHOR_OVERLAP')
        previous_start, previous_end = start, end

    helper, preflight, repository, tasks = _PATCHES
    class_decl, apply_decl, tasks_decl = _DECLARATIONS
    # class34/apply46 boundary: full apply declaration ends the helper anchor.
    # preflight/repository: after apply46 before addFlutterTasks349.
    # tasks: after addFlutterTasks349. These are exact line contexts, not AST.
    scope_ok = (
        helper[3] > class_decl[2] and helper[5] >= class_decl[4]
        and helper[5] <= apply_decl[3] and helper[6] == apply_decl[4]
        and helper[3] <= apply_decl[2] and helper[4] == apply_decl[2]
        and helper[1].endswith(apply_decl[1])
        and preflight[5] == apply_decl[4] and preflight[3] > apply_decl[2]
        and preflight[6] <= tasks_decl[3] and preflight[4] < tasks_decl[2]
        and repository[5] > apply_decl[4] and repository[3] > apply_decl[2]
        and repository[6] <= tasks_decl[3] and repository[4] < tasks_decl[2]
        and tasks[5] >= tasks_decl[4] and tasks[3] > tasks_decl[2]
    )
    if not scope_ok:
        raise ValueError('ES_SOURCE_SCOPE')

    scratch = source
    for _, before, after, _, _, _, _ in _PATCHES:
        if _count_overlapping(scratch, before) != 1:
            raise ValueError('ES_SCRATCH_ANCHOR')
        position = scratch.find(before)
        scratch = scratch[:position] + after + scratch[position + len(before):]
    if len(scratch) != _OUTPUT_SIZE:
        raise ValueError('ES_OUTPUT_SIZE')
    return scratch
