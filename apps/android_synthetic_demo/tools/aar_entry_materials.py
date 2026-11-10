from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
import re

_CODE = {
    'repo-before': "        val hostedRepository: String =\n            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)\n                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST\n        val repository: String? =\n            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {\n                project.property(PROP_LOCAL_ENGINE_REPO) as String?\n            } else {\n                \"$hostedRepository/${engineRealm}download.flutter.io\"\n            }\n        rootProject.allprojects {\n            repositories.maven {\n                url = uri(repository!!)\n            }\n        }\n".encode('utf-8'),
    'repo-after': "        if (!esControlledModule(project)) {\n        val hostedRepository: String =\n            System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)\n                ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST\n        val repository: String? =\n            if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {\n                project.property(PROP_LOCAL_ENGINE_REPO) as String?\n            } else {\n                \"$hostedRepository/${engineRealm}download.flutter.io\"\n            }\n        rootProject.allprojects {\n            repositories.maven {\n                url = uri(repository!!)\n            }\n        }\n        }\n".encode('utf-8'),
    'tasks-before': "            return\n        }\n        // Flutter host module project (Add-to-app).\n        val hostAppProjectName: String? =\n".encode('utf-8'),
    'tasks-after': "            return\n        }\n        if (esControlledModule(projectToAddTasksTo)) {\n            val android = projectToAddTasksTo.extensions.findByType(LibraryExtension::class.java)\n            check(android != null) { \"ES_LIBRARY\" }\n            android.libraryVariants.all esLibraryVariant@{\n                val variant = this\n                if (variant.name != \"debug\") {\n                    return@esLibraryVariant\n                }\n                check(variant.flavorName.isEmpty()) { \"ES_FLAVOR\" }\n                check(FlutterPluginUtils.buildModeFor(variant.buildType) == \"debug\") { \"ES_MODE\" }\n                val assembleTask = variant.assembleProvider.get()\n                check(FlutterPluginUtils.shouldConfigureFlutterTask(projectToAddTasksTo, assembleTask)) { \"ES_TASKS\" }\n                addFlutterDeps(variant, flutterPlugin, targetPlatforms)\n            }\n            getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)\n            FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(\n                projectToAddTasksTo,\n                getPluginHandler(projectToAddTasksTo).getPluginList()\n            )\n            return\n        }\n        // Flutter host module project (Add-to-app).\n        val hostAppProjectName: String? =\n".encode('utf-8'),
    'init-all-before': "allprojects {\n".encode('utf-8'),
    'init-all-after': "allprojects {\n    if (esEnabled(project)) {\n        esCheckProject(project, false)\n    }\n".encode('utf-8'),
    'init-afterProject-before': "afterProject { project ->\n".encode('utf-8'),
    'init-afterProject-after': "afterProject { project ->\n    if (esEnabled(project)) {\n        esAfterProject(project)\n        return\n    }\n".encode('utf-8'),
    'init-projectsEvaluated-before': "projectsEvaluated {\n".encode('utf-8'),
    'init-projectsEvaluated-after': "projectsEvaluated {\n    if (esEnabled(rootProject)) {\n        esProjectsEvaluated(rootProject)\n        return\n    }\n".encode('utf-8'),
    'init-helpers': "boolean esEnabled(Project p) {\n    def key = 'elitesync.aar-entry'\n    def own = p.extensions.extraProperties\n    def root = p.rootProject\n    def rootOwn = root.extensions.extraProperties\n    boolean present = own.has(key) || p.hasProperty(key)\n    if (!present) {\n        if (rootOwn.has(key) || root.hasProperty(key)) {\n            throw new GradleException('ES_ROOT_MODE')\n        }\n        return false\n    }\n    if (!own.has(key)) {\n        throw new GradleException('ES_MODE_SCOPE')\n    }\n    def raw = own.get(key)\n    if (!(raw instanceof String) || raw != 'module-debug-v1') {\n        throw new GradleException('ES_MODE_SCOPE')\n    }\n    if (!rootOwn.has(key)) {\n        throw new GradleException('ES_ROOT_MODE')\n    }\n    def rootRaw = rootOwn.get(key)\n    if (!(rootRaw instanceof String) || rootRaw != raw) {\n        throw new GradleException('ES_ROOT_MODE')\n    }\n    return true\n}\n\nSet<String> esAllowed() {\n    return [':', ':flutter', ':sample_alpha', ':sample_beta'] as Set\n}\n\nvoid esCheckProject(Project p, boolean evaluated) {\n    if (!esAllowed().contains(p.path) || !esEnabled(p)) {\n        throw new GradleException('ES_PROJECT')\n    }\n    def own = p.extensions.extraProperties\n    def expected = [\n        'is-plugin': 'false',\n        'output-dir': new File(p.rootProject.projectDir, '../../publication').path,\n        'elitesync.sdk-identity': '1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313',\n        'elitesync.aar-projects': ':,:flutter,:sample_alpha,:sample_beta'\n    ]\n    expected.each { key, value ->\n        if (!own.has(key) || !(own.get(key) instanceof String) || own.get(key) != value) {\n            throw new GradleException('ES_PROPERTY_SCOPE')\n        }\n    }\n    if (!own.has('buildNumber') || !(own.get('buildNumber') instanceof String) || !(own.get('buildNumber') ==~ /[0-9a-f]{64}/)) {\n        throw new GradleException('ES_ID')\n    }\n    if (!p.rootProject.extensions.extraProperties.has('buildNumber') || p.rootProject.extensions.extraProperties.get('buildNumber') != own.get('buildNumber')) {\n        throw new GradleException('ES_ID')\n    }\n    if (p.gradle.startParameter.taskNames != ['assembleAarDebug']) {\n        throw new GradleException('ES_TASKS')\n    }\n    if (['local-engine-repo', 'local-engine-out', 'local-engine-host-out', 'local-engine-build-mode', 'skipDependencyChecks'].any { p.hasProperty(it) }) {\n        throw new GradleException('ES_BYPASS')\n    }\n    if (evaluated && p.path != ':') {\n        if (!p.hasProperty('android') || !p.android.hasProperty('libraryVariants') || !p.android.productFlavors.isEmpty()) {\n            throw new GradleException('ES_LIBRARY')\n        }\n    }\n}\n\nvoid esAfterProject(Project p) {\n    esCheckProject(p, true)\n    if (p.path == ':') {\n        return\n    }\n    def singles = p.android.publishing.singleVariants\n    if (singles.isEmpty()) {\n        p.android.publishing.singleVariant('debug')\n    } else if (singles.size() != 1 || singles.first().variantName != 'debug') {\n        throw new GradleException('ES_PUBLICATION_VARIANT')\n    }\n}\n\nvoid esPublishDebug(Project p) {\n    esCheckProject(p, true)\n    def debugVariants = p.android.libraryVariants.findAll { it.name == 'debug' && it.flavorName.isEmpty() }\n    def component = p.components.findByName('debug')\n    if (debugVariants.size() != 1 || component == null || !p.publishing.publications.isEmpty() || !p.publishing.repositories.isEmpty()) {\n        throw new GradleException('ES_DEBUG_COMPONENT')\n    }\n    if (p.tasks.findByName('assembleAarDebug') != null) {\n        throw new GradleException('ES_DUPLICATE_TASK')\n    }\n    p.version = p.extensions.extraProperties.get('buildNumber')\n    p.publishing.publications.create('debug', MavenPublication) { pub ->\n        groupId = \"${pub.groupId}\"\n        artifactId = \"${pub.artifactId}_${pub.name}\"\n        version = \"${pub.version}\"\n        from component\n    }\n    p.publishing.repositories.maven {\n        name = 'controlledDebug'\n        url = p.uri(new File(p.extensions.extraProperties.get('output-dir'), 'outputs/repo'))\n    }\n    def publishDebug = p.tasks.named('publishDebugPublicationToControlledDebugRepository')\n    p.tasks.create('assembleAarDebug') {\n        dependsOn(debugVariants.first().assembleProvider)\n        finalizedBy(publishDebug)\n    }\n}\n\nvoid esProjectsEvaluated(Project root) {\n    def actual = ([root.path] + root.subprojects.collect { it.path }) as Set\n    if (actual != esAllowed()) {\n        throw new GradleException('ES_TOPOLOGY')\n    }\n    ([root] + root.subprojects.toList()).each { esCheckProject(it, true) }\n    Project module = root.findProject(':flutter')\n    if (module == null) {\n        throw new GradleException('ES_MODULE')\n    }\n    def participants = [module, root.findProject(':sample_alpha'), root.findProject(':sample_beta')]\n    if (participants.any { it == null }) {\n        throw new GradleException('ES_PLUGIN')\n    }\n    participants.each { esPublishDebug(it) }\n    def moduleDebug = module.tasks.named('assembleAarDebug').get()\n    participants.findAll { it.path != ':flutter' }.each { plugin ->\n        moduleDebug.dependsOn(plugin.tasks.named('assembleAarDebug'))\n    }\n}\n".encode('utf-8'),
    'apply-helper': "    private fun esControlledModule(p: Project): Boolean {\n        val key = \"elitesync.aar-entry\"\n        val own = p.extensions.extraProperties\n        val root = p.rootProject\n        val rootOwn = root.extensions.extraProperties\n        val present = own.has(key) || p.hasProperty(key)\n        if (!present) {\n            check(!rootOwn.has(key) && !root.hasProperty(key)) { \"ES_ROOT_MODE\" }\n            return false\n        }\n        check(own.has(key)) { \"ES_SCOPE\" }\n        val raw = own.get(key)\n        check(raw is String && raw == \"module-debug-v1\") { \"ES_MODE\" }\n        check(rootOwn.has(key)) { \"ES_ROOT_SCOPE\" }\n        val rootRaw = rootOwn.get(key)\n        check(rootRaw is String && rootRaw == raw) { \"ES_ROOT_MODE\" }\n        check(p.path == \":flutter\") { \"ES_PROJECT\" }\n        check(!FlutterPluginUtils.isFlutterAppProject(p)) { \"ES_APP\" }\n        val android = p.extensions.findByType(LibraryExtension::class.java)\n        check(android != null && android.productFlavors.isEmpty()) { \"ES_LIBRARY\" }\n        check(p.gradle.startParameter.taskNames == listOf(\"assembleAarDebug\")) { \"ES_TASKS\" }\n        val values = linkedMapOf(\n            \"is-plugin\" to \"false\",\n            \"output-dir\" to File(root.projectDir, \"../../publication\").path,\n            \"elitesync.sdk-identity\" to \"1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313\",\n            \"elitesync.aar-projects\" to \":,:flutter,:sample_alpha,:sample_beta\"\n        )\n        values.forEach { (name, value) ->\n            check(own.has(name)) { \"ES_SCOPE\" }\n            check(own.get(name) == value) { \"ES_PROPERTY\" }\n        }\n        check(own.has(\"buildNumber\")) { \"ES_SCOPE\" }\n        val id = own.get(\"buildNumber\")\n        check(id is String && Regex(\"[0-9a-f]{64}\").matches(id)) { \"ES_ID\" }\n        check(rootOwn.has(\"buildNumber\")) { \"ES_ROOT_SCOPE\" }\n        check(rootOwn.get(\"buildNumber\") == id) { \"ES_ID\" }\n        listOf(\"local-engine-repo\", \"local-engine-out\", \"local-engine-host-out\", \"local-engine-build-mode\").forEach {\n            check(!p.hasProperty(it)) { \"ES_LOCAL_ENGINE\" }\n        }\n        check(!p.hasProperty(\"skipDependencyChecks\")) { \"ES_SKIP\" }\n        return true\n    }\n".encode('utf-8'),
    'preflight-before': "        this.project = project\n".encode('utf-8'),
    'preflight-after': "        this.project = project\n        esControlledModule(project)\n".encode('utf-8'),
}

_DIGESTS = (
    ('tasks-full', 'B89C513B5803A734D6DC8F1574EED66F9BC173787D13A6D88F5604833F9CBEEE'),
    ('repo-block', '4CC5BDE39C726B5C6D8034E52929E1B3372D99B6F1B10FDAAF2D59FA567B6534'),
    ('init-full', '5252CD23EDFD3F02AB1E43875F2F0BAE286589A035475D092A87723E02524FCC'),
    ('plugin-deps', '5B7712D84D82BDCE1BB071419E6BAEFE134754C80B62E3C8BAE1005058E4C33F'),
)

F = '1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'
I = 'B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2'
_PROJECTS = (':', ':flutter', ':sample_alpha', ':sample_beta')
_KEYS = ('elitesync.aar-entry', 'is-plugin', 'output-dir', 'buildNumber', 'elitesync.sdk-identity', 'elitesync.aar-projects')
_PHASE = 'BEFORE_EACH_PROJECT_APPLY_AND_BEFORE_ADAPTED_INIT_GUARDS'
_CONFIG_KEYS = ('mode', 'flutter_identity', 'init_identity', 'input_id', 'projects', 'properties', 'tasks', 'sdk_root', 'maven_root', 'publication_root', 'repositories_mode')


@dataclass(frozen=True, slots=True)
class PatchOperation:
    order: int
    target: str
    kind: str
    input_fragment_sha256: str
    anchor_id: str
    before: bytes
    after: bytes


@dataclass(frozen=True, slots=True)
class Attachment:
    id: str
    placement: str
    historical_sdk_identity: str
    before: bytes
    after: bytes
    executable_patch: bool


@dataclass(frozen=True, slots=True)
class LiteralString:
    key: str
    value: str


@dataclass(frozen=True, slots=True)
class RootProjectDirFilePath:
    key: str
    base: str
    child_components: tuple[str, str, str]
    result: str
    install_phase: str


@dataclass(frozen=True, slots=True)
class InstallationGroup:
    project: str
    scope: str
    recipes: tuple[LiteralString | RootProjectDirFilePath, ...]


@dataclass(frozen=True, slots=True)
class InvocationContract:
    mode: str
    requested_tasks: tuple[str, ...]
    projects: tuple[str, ...]
    logical_properties: tuple[tuple[str, tuple[tuple[str, str], ...]], ...]
    property_installation: tuple[InstallationGroup, ...]
    property_install_phase: str
    sdk_root: str
    maven_root: str
    publication_root: str
    publication_repository: str
    repositories_mode: str
    module_project: str
    module_variant: str
    plugin_projects: tuple[str, ...]
    plugin_variants: tuple[str, ...]
    aar_task_edges: tuple[tuple[str, str], ...]
    publish_finalizers: tuple[str, ...]
    sdk_identity: str
    init_identity: str
    input_id: str
    runtime_ready: bool


@dataclass(frozen=True, slots=True)
class EntryMaterials:
    operations: tuple[PatchOperation, ...]
    attachments: tuple[Attachment, ...]
    invocation: InvocationContract


def _type(value: object, expected: type) -> None:
    if type(value) is not expected:
        raise TypeError('TYPE')


def _require(condition: bool) -> None:
    if not condition:
        raise ValueError('CONTRACT')


def _strings(value: object) -> None:
    _type(value, tuple)
    for item in value:
        _type(item, str)


def _validate_config(config: object) -> str:
    _type(config, dict)
    for key in config:
        _type(key, str)
    _require(set(config) == set(_CONFIG_KEYS))
    for key in ('mode', 'flutter_identity', 'init_identity', 'input_id', 'sdk_root', 'maven_root', 'publication_root', 'repositories_mode'):
        _type(config[key], str)
    fixed = (
        ('mode', 'module-debug-v1'), ('flutter_identity', F), ('init_identity', I),
        ('sdk_root', 'materials/flutter_sdk'), ('maven_root', 'materials/maven'),
        ('publication_root', 'publication'), ('repositories_mode', 'FAIL_ON_PROJECT_REPOS'),
    )
    for key, value in fixed:
        _require(config[key] == value)
    input_id = config['input_id']
    _require(re.fullmatch('[0-9a-f]{64}', input_id, flags=re.ASCII) is not None)
    _strings(config['projects'])
    _strings(config['tasks'])
    _require(config['projects'] == _PROJECTS)
    _require(config['tasks'] == ('assembleAarDebug',))
    properties = config['properties']
    _type(properties, tuple)
    _require(len(properties) == 4)
    expected_values = ('module-debug-v1', 'false', 'publication', input_id, F, ':,:flutter,:sample_alpha,:sample_beta')
    for index, group in enumerate(properties):
        _type(group, tuple)
        _require(len(group) == 2)
        project, entries = group
        _type(project, str)
        _type(entries, tuple)
        _require(project == _PROJECTS[index] and len(entries) == 6)
        for position, entry in enumerate(entries):
            _type(entry, tuple)
            _require(len(entry) == 2)
            key, value = entry
            _type(key, str)
            _type(value, str)
            _require(key == _KEYS[position] and value == expected_values[position])
    return input_id


def _validate_materials(materials: object) -> None:
    _type(materials, tuple)
    _require(len(materials) == 4)
    total = 0
    for index, pair in enumerate(materials):
        _type(pair, tuple)
        _require(len(pair) == 2)
        source_id, content = pair
        _type(source_id, str)
        _type(content, bytes)
        expected_id, digest = _DIGESTS[index]
        _require(source_id == expected_id)
        _require(len(content) <= 262144)
        total += len(content)
        _require(total <= 1048576)
        _require(sha256(content).hexdigest().upper() == digest)
    originals = dict(materials)
    for target, anchor in (('repo-block', 'repo-before'), ('tasks-full', 'tasks-before'), ('init-full', 'init-all-before'), ('init-full', 'init-afterProject-before'), ('init-full', 'init-projectsEvaluated-before')):
        _require(originals[target].count(_CODE[anchor]) == 1)
    _require(_CODE['init-helpers'].count(_CODE['init-all-before']) == 0)


def adapt_module_debug_entry(*, materials: tuple, config: dict) -> EntryMaterials:
    """Return SOURCE-ONLY operations and installation recipes, never apply them."""
    _type(materials, tuple)
    _type(config, dict)
    input_id = _validate_config(config)
    _validate_materials(materials)
    digests = dict(_DIGESTS)
    definitions = (
        ('repo-block', 'REPLACE_UNIQUE', 'repo-before', 'repo-after'),
        ('tasks-full', 'REPLACE_UNIQUE', 'tasks-before', 'tasks-after'),
        ('init-full', 'INSERT_BEFORE_UNIQUE', 'init-all-before', 'init-helpers'),
        ('init-full', 'REPLACE_UNIQUE', 'init-all-before', 'init-all-after'),
        ('init-full', 'REPLACE_UNIQUE', 'init-afterProject-before', 'init-afterProject-after'),
        ('init-full', 'REPLACE_UNIQUE', 'init-projectsEvaluated-before', 'init-projectsEvaluated-after'),
    )
    operations = tuple(PatchOperation(n, target, kind, digests[target], anchor, _CODE[anchor], _CODE[after]) for n, (target, kind, anchor, after) in enumerate(definitions))
    attachments = (
        Attachment('apply-helper', 'FLUTTER_PLUGIN_CLASS_MEMBER', F, b'', _CODE['apply-helper'], False),
        Attachment('apply-preflight-proposal', 'APPLY_AFTER_THIS_PROJECT_ASSIGNMENT', F, _CODE['preflight-before'], _CODE['preflight-after'], False),
    )
    recipes = (
        LiteralString('elitesync.aar-entry', 'module-debug-v1'),
        LiteralString('is-plugin', 'false'),
        RootProjectDirFilePath('output-dir', 'ROOT_PROJECT_DIR', ('..', '..', 'publication'), 'FILE_PATH', _PHASE),
        LiteralString('buildNumber', input_id),
        LiteralString('elitesync.sdk-identity', F),
        LiteralString('elitesync.aar-projects', ':,:flutter,:sample_alpha,:sample_beta'),
    )
    logical = tuple((project, tuple((key, value) for key, value in entries)) for project, entries in config['properties'])
    invocation = InvocationContract(
        mode='module-debug-v1', requested_tasks=('assembleAarDebug',), projects=_PROJECTS,
        logical_properties=logical,
        property_installation=tuple(InstallationGroup(project, 'LOCAL_EXTRA', recipes) for project in _PROJECTS),
        property_install_phase=_PHASE, sdk_root='materials/flutter_sdk', maven_root='materials/maven',
        publication_root='publication', publication_repository='publication/outputs/repo',
        repositories_mode='FAIL_ON_PROJECT_REPOS', module_project=':flutter', module_variant='debug',
        plugin_projects=(':sample_alpha', ':sample_beta'), plugin_variants=('debug', 'debug'),
        aar_task_edges=((':flutter:assembleAarDebug', ':sample_alpha:assembleAarDebug'), (':flutter:assembleAarDebug', ':sample_beta:assembleAarDebug')),
        publish_finalizers=(':flutter:publishDebugPublicationToControlledDebugRepository', ':sample_alpha:publishDebugPublicationToControlledDebugRepository', ':sample_beta:publishDebugPublicationToControlledDebugRepository'),
        sdk_identity=F, init_identity=I, input_id=input_id, runtime_ready=False,
    )
    return EntryMaterials(operations, attachments, invocation)
