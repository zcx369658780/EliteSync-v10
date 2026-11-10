"""Frozen source-only Kotlin proposal transformation.

No SDK access or execution. Positive fixture and independent oracle are deferred.
Early preflight remains PROPOSED; property/LibraryExtension timing is NOT_PROVEN.
"""
import hashlib


_SCOPE_LINES = (
    (34, b"class FlutterPlugin : Plugin<Project> {"),
    (46, b"    override fun apply(project: Project) {"),
    (349, b"    private fun addFlutterTasks(projectToAddTasksTo: Project) {"),
)

# Fixed scopes and complete LF literals; no caller-supplied patch package.
_EDITS = (
    (44, 46,
     b"    private var pluginHandler: PluginHandler? = null\n\n    override fun apply(project: Project) {\n",
     b"    private var pluginHandler: PluginHandler? = null\n\n    private fun esControlledModule(p: Project): Boolean {\n        val key = \"elitesync.aar-entry\"\n        val own = p.extensions.extraProperties\n        val root = p.rootProject\n        val rootOwn = root.extensions.extraProperties\n        val present = own.has(key) || p.hasProperty(key)\n        if (!present) {\n            check(!rootOwn.has(key) && !root.hasProperty(key)) { \"ES_ROOT_MODE\" }\n            return false\n        }\n        check(own.has(key)) { \"ES_SCOPE\" }\n        val raw = own.get(key)\n        check(raw is String && raw == \"module-debug-v1\") { \"ES_MODE\" }\n        check(rootOwn.has(key)) { \"ES_ROOT_SCOPE\" }\n        val rootRaw = rootOwn.get(key)\n        check(rootRaw is String && rootRaw == raw) { \"ES_ROOT_MODE\" }\n        check(p.path == \":flutter\") { \"ES_PROJECT\" }\n        check(!FlutterPluginUtils.isFlutterAppProject(p)) { \"ES_APP\" }\n        val android = p.extensions.findByType(LibraryExtension::class.java)\n        check(android != null && android.productFlavors.isEmpty()) { \"ES_LIBRARY\" }\n        check(p.gradle.startParameter.taskNames == listOf(\"assembleAarDebug\")) { \"ES_TASKS\" }\n        val values = linkedMapOf(\n            \"is-plugin\" to \"false\",\n            \"output-dir\" to File(root.projectDir, \"../../publication\").path,\n            \"elitesync.sdk-identity\" to \"1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313\",\n            \"elitesync.aar-projects\" to \":,:flutter,:sample_alpha,:sample_beta\"\n        )\n        values.forEach { (name, value) ->\n            check(own.has(name)) { \"ES_SCOPE\" }\n            check(own.get(name) == value) { \"ES_PROPERTY\" }\n        }\n        check(own.has(\"buildNumber\")) { \"ES_SCOPE\" }\n        val id = own.get(\"buildNumber\")\n        check(id is String && Regex(\"[0-9a-f]{64}\").matches(id)) { \"ES_ID\" }\n        check(rootOwn.has(\"buildNumber\")) { \"ES_ROOT_SCOPE\" }\n        check(rootOwn.get(\"buildNumber\") == id) { \"ES_ID\" }\n        listOf(\"local-engine-repo\", \"local-engine-out\", \"local-engine-host-out\", \"local-engine-build-mode\").forEach {\n            check(!p.hasProperty(it)) { \"ES_LOCAL_ENGINE\" }\n        }\n        check(!p.hasProperty(\"skipDependencyChecks\")) { \"ES_SKIP\" }\n        return true\n    }\n\n    override fun apply(project: Project) {\n"),
    (47, 47,
     b"        this.project = project\n",
     b"        this.project = project\n        esControlledModule(project)\n"),
    (88, 101,
     b"        val hostedRepository: String =\n            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)\n                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST\n        val repository: String? =\n            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {\n                project.property(PROP_LOCAL_ENGINE_REPO) as String?\n            } else {\n                \"$hostedRepository/${engineRealm}download.flutter.io\"\n            }\n        rootProject.allprojects {\n            repositories.maven {\n                url = uri(repository!!)\n            }\n        }\n",
     b"        if (!esControlledModule(project)) {\n        val hostedRepository: String =\n            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)\n                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST\n        val repository: String? =\n            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {\n                project.property(PROP_LOCAL_ENGINE_REPO) as String?\n            } else {\n                \"$hostedRepository/${engineRealm}download.flutter.io\"\n            }\n        rootProject.allprojects {\n            repositories.maven {\n                url = uri(repository!!)\n            }\n        }\n        }\n"),
    (453, 456,
     b"            return\n        }\n        // Flutter host module project (Add-to-app).\n        val hostAppProjectName: String? =\n",
     b"            return\n        }\n        if (esControlledModule(projectToAddTasksTo)) {\n            val android = projectToAddTasksTo.extensions.findByType(LibraryExtension::class.java)\n            check(android != null) { \"ES_LIBRARY\" }\n            android.libraryVariants.all esLibraryVariant@{\n                val variant = this\n                if (variant.name != \"debug\") {\n                    return@esLibraryVariant\n                }\n                check(variant.flavorName.isEmpty()) { \"ES_FLAVOR\" }\n                check(FlutterPluginUtils.buildModeFor(variant.buildType) == \"debug\") { \"ES_MODE\" }\n                val assembleTask = variant.assembleProvider.get()\n                check(FlutterPluginUtils.shouldConfigureFlutterTask(projectToAddTasksTo, assembleTask)) { \"ES_TASKS\" }\n                addFlutterDeps(variant, flutterPlugin, targetPlatforms)\n            }\n            getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)\n            FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(\n                projectToAddTasksTo,\n                getPluginHandler(projectToAddTasksTo).getPluginList()\n            )\n            return\n        }\n        // Flutter host module project (Add-to-app).\n        val hostAppProjectName: String? =\n"),
)


def _unique_offset(haystack: bytes, needle: bytes, error: str) -> int:
    """Count all occurrences, including overlapping ones, without source evaluation."""
    first = haystack.find(needle)
    if first < 0 or haystack.find(needle, first + 1) >= 0:
        raise ValueError(error)
    return first


def render_scoped_flutter_plugin(source: bytes) -> bytes:
    """Return the complete proposed source only after every fixed gate succeeds."""
    if type(source) is not bytes:
        raise ValueError("ES_SOURCE_TYPE")
    if len(source) != 42405:
        raise ValueError("ES_SOURCE_SIZE")
    if hashlib.sha256(source).hexdigest().upper() != (
        "1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313"
    ):
        raise ValueError("ES_SOURCE_IDENTITY")

    # Precheck every original anchor before performing any scratch replacement.
    intervals = []
    for first_line, last_line, before, after in _EDITS:
        offset = _unique_offset(source, before, "ES_ANCHOR_COUNT")
        intervals.append((offset, offset + len(before)))

    # LF byte lines only: no newline normalization or decode/re-encode.
    lines = source.split(b"\n")
    if len(lines) < 456:
        raise ValueError("ES_SOURCE_SCOPE")
    for line_number, declaration in _SCOPE_LINES:
        if lines[line_number - 1] != declaration:
            raise ValueError("ES_SOURCE_SCOPE")
    for first_line, last_line, before, after in _EDITS:
        if b"\n".join(lines[first_line - 1:last_line]) + b"\n" != before:
            raise ValueError("ES_SOURCE_SCOPE")

    for previous, current in zip(intervals, intervals[1:]):
        if current[0] <= previous[0] or current[0] < previous[1]:
            raise ValueError("ES_ANCHOR_OVERLAP")

    # Only local immutable bytes are changed; original offsets are never reused.
    scratch = source
    for first_line, last_line, before, after in _EDITS:
        offset = _unique_offset(scratch, before, "ES_SCRATCH_ANCHOR")
        scratch = scratch[:offset] + after + scratch[offset + len(before):]
    if len(scratch) != 45840:
        raise ValueError("ES_OUTPUT_SIZE")
    return scratch
