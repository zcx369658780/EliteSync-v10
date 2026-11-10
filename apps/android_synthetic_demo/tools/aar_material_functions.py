"""Pure lexical AAR materials; no runtime or publication binding evidence.

Sources: M5-14 plan; build_info.dart:1081,1095-1096;
aar_init_script.gradle:21-25,36,88-100. Publication and component names
are separate inputs. Project version proposals do not establish pub.version.
"""

import base64
from dataclasses import dataclass
import re


_SYNTHETIC = ("ELITESYNC_SYNTHETIC_DEMO=true",)
_SEGMENT = re.compile(r"[A-Za-z0-9][A-Za-z0-9_.-]*", re.ASCII)
_GROUP_SEGMENT = re.compile(r"[A-Za-z0-9][A-Za-z0-9_-]*", re.ASCII)
_VERSION = re.compile(r"[A-Za-z0-9][A-Za-z0-9_.+\-]*", re.ASCII)


def encode_dart_defines(values: tuple[str, ...]) -> str:
    """Encode each item separately, preserving order, repeats and padding."""
    if type(values) is not tuple:
        raise TypeError("values must be a tuple")
    encoded = []
    for value in values:
        if type(value) is not str:
            raise TypeError("each define must be a str")
        try:
            data = value.encode("utf-8")
        except UnicodeEncodeError as error:
            raise ValueError("isolated surrogates are unsupported") from error
        encoded.append(base64.b64encode(data).decode("ascii"))
    return ",".join(encoded)


def synthetic_define_argument(defines: tuple[str, ...] = _SYNTHETIC) -> str:
    """Produce only the explicitly frozen synthetic define argument."""
    if type(defines) is not tuple:
        raise TypeError("defines must be a tuple")
    if any(type(value) is not str for value in defines):
        raise TypeError("each define must be a str")
    if defines != _SYNTHETIC:
        raise ValueError("exactly one synthetic=true define is required")
    return "-Pdart-defines=" + encode_dart_defines(defines)


@dataclass(frozen=True, slots=True)
class PublicationRecipe:
    group_id: str
    artifact_id: str
    publication_name: str
    component_name: str
    task_name: str
    project_version_proposal: str
    repository_relative_path: str
    runtime_ready: bool = False
    publication_binding_verified: bool = False


def _text(name: str, value: str, pattern: re.Pattern[str]) -> str:
    if type(value) is not str:
        raise TypeError(name + " must be a str")
    if pattern.fullmatch(value) is None:
        raise ValueError(name + " has an unsupported character domain")
    return value


def _relative_path(name: str, value: str) -> str:
    if type(value) is not str:
        raise TypeError(name + " must be a str")
    for segment in value.split("/"):
        _text(name + " segment", segment, _SEGMENT)
    return value


def synthetic_build_info_arguments(
    *,
    track_widget_creation: bool,
    tree_shake_icons: bool,
    project_cache_relative_path: str,
) -> tuple[str, ...]:
    """M5-16/build_info.dart:365-385: a restricted BuildInfo fragment.

    Relative cache text is lexical material, not evidence of cwd or isolation.
    This is neither a complete AAR argv nor an execution interface.
    """
    if type(track_widget_creation) is not bool:
        raise TypeError("track_widget_creation must be a bool")
    if type(tree_shake_icons) is not bool:
        raise TypeError("tree_shake_icons must be a bool")
    cache = _relative_path("project_cache_relative_path", project_cache_relative_path)
    return (
        synthetic_define_argument(),
        "-Pdart-obfuscation=false",
        "-Ptrack-widget-creation=" + ("true" if track_widget_creation else "false"),
        "-Ptree-shake-icons=" + ("true" if tree_shake_icons else "false"),
        "--project-cache-dir=" + cache,
    )


@dataclass(frozen=True, slots=True)
class ModuleTopologyMaterials:
    root_name: str
    project_names: tuple[str, ...]
    flutter_project_relative_dir: str
    app_project_relative_dir: None
    publication_module_name: str
    excluded_plugin_candidate_names: tuple[str, ...]
    loader_binding_verified: bool = False
    runtime_ready: bool = False


def module_topology_materials(
    *, module_relative_root: str, include_app: bool
) -> ModuleTopologyMaterials:
    """Pure template-choice materials, not an actual Gradle project graph.

    Sources: M5-19 include:16-17/settings:3-5; M5-18 ephemeral:27-31;
    M5-16:169-171. :flutter is the publication module, excluded only from
    plugin candidates. App binding is unknown. Relative text proves no
    cwd or isolation; include_app is our choice, not an SDK boolean branch.
    """
    root = _relative_path("module_relative_root", module_relative_root)
    if type(include_app) is not bool:
        raise TypeError("include_app must be a bool")
    return ModuleTopologyMaterials(
        root_name="android_generated",
        project_names=(":app", ":flutter") if include_app else (":flutter",),
        flutter_project_relative_dir=root + "/.android/Flutter",
        app_project_relative_dir=None,
        publication_module_name=":flutter",
        excluded_plugin_candidate_names=(":app", ":flutter"),
    )


def publication_recipe(
    *,
    base_group: str,
    base_artifact: str,
    publication_name: str,
    component_name: str,
    base_version: str,
    build_number: str | None,
    output_root: str,
) -> PublicationRecipe:
    """Return immutable string materials, without filesystem interpretation."""
    if type(base_group) is not str:
        raise TypeError("base_group must be a str")
    for segment in base_group.split("."):
        _text("group segment", segment, _GROUP_SEGMENT)
    _text("base_artifact", base_artifact, _SEGMENT)
    _text("publication_name", publication_name, _SEGMENT)
    if type(component_name) is not str:
        raise TypeError("component_name must be a str")
    if component_name != "debug":
        raise ValueError("only the debug component is supported")
    _text("base_version", base_version, _VERSION)
    proposal = base_version.replace("-SNAPSHOT", "")
    if build_number is not None:
        proposal = _text("build_number", build_number, _VERSION)
    _text("project_version_proposal", proposal, _VERSION)
    _relative_path("output_root", output_root)
    return PublicationRecipe(
        group_id=base_group,
        artifact_id=base_artifact + "_" + publication_name,
        publication_name=publication_name,
        component_name=component_name,
        task_name="assembleAarDebug",
        project_version_proposal=proposal,
        repository_relative_path=output_root + "/outputs/repo",
    )


_PLUGIN_NAME = re.compile(r"[a-z][a-z0-9_]*", re.ASCII)
_RESERVED_PLUGIN_NAMES = {"app", "flutter", "android_generated"}


@dataclass(frozen=True, slots=True)
class PluginMaterial:
    name: str
    project_name: str
    project_relative_dir: str
    build_output_relative_dir: str
    dependencies: tuple[str, ...]
    dev_dependency: bool
    loader_binding_verified: bool = False
    runtime_ready: bool = False


def _plugin_name(value: str) -> str:
    _text("plugin name", value, _PLUGIN_NAME)
    if value in _RESERVED_PLUGIN_NAMES:
        raise ValueError("reserved plugin name")
    return value


def _paths_overlap(left: str, right: str) -> bool:
    return left == right or left.startswith(right + "/") or right.startswith(left + "/")


def _keys(value: dict, expected: set[str]) -> None:
    if type(value) is not dict:
        raise TypeError("exact dict required")
    if set(value) != expected:
        raise ValueError("unexpected or missing schema keys")


def synthetic_plugin_materials(
    *, metadata: dict, approved_plugin_paths: tuple[tuple[str, str], ...],
    module_relative_root: str,
) -> tuple[PluginMaterial, ...]:
    """Artificial memory fixtures only; no JSON or host access.

    M5-21 loader:16-33/native:33-68 supplies mapping/filtering rules.
    Exact schema, explicit native bool, safe approved paths, uniqueness and
    full acyclic dependency validation are OUR restrictions, not SDK rules.
    """
    root = _relative_path("module root", module_relative_root)
    if type(approved_plugin_paths) is not tuple:
        raise TypeError("approved paths must be an exact tuple")
    if len(approved_plugin_paths) > 128:
        raise ValueError("too many approved paths")
    approved = {}
    for pair in approved_plugin_paths:
        if type(pair) is not tuple or len(pair) != 2:
            if type(pair) is not tuple:
                raise TypeError("approved entry must be an exact tuple")
            raise ValueError("approved entry must have two items")
        name = _plugin_name(pair[0])
        path = _relative_path("approved path", pair[1])
        if name in approved:
            raise ValueError("duplicate approved name")
        if _paths_overlap(path, root) or any(_paths_overlap(path, old) for old in approved.values()):
            raise ValueError("approved paths overlap")
        approved[name] = path

    _keys(metadata, {"plugins"})
    _keys(metadata["plugins"], {"android"})
    entries = metadata["plugins"]["android"]
    if type(entries) is not list:
        raise TypeError("android must be an exact list")
    if len(entries) > 128:
        raise ValueError("too many plugins")
    declarations = {}
    for entry in entries:
        _keys(entry, {"name", "path", "dependencies", "dev_dependency", "native_build"})
        name = _plugin_name(entry["name"])
        path = _relative_path("plugin path", entry["path"])
        if name in declarations:
            raise ValueError("duplicate plugin name")
        if name not in approved or path != approved[name]:
            raise ValueError("plugin does not match approved material")
        if type(entry["dev_dependency"]) is not bool or type(entry["native_build"]) is not bool:
            raise TypeError("plugin flags must be exact bools")
        deps = entry["dependencies"]
        if type(deps) is not list:
            raise TypeError("dependencies must be an exact list")
        if len(deps) > 128:
            raise ValueError("too many dependencies")
        dependencies = tuple(_plugin_name(dep) for dep in deps)
        if len(set(dependencies)) != len(dependencies):
            raise ValueError("duplicate dependencies")
        if name in dependencies:
            raise ValueError("self dependency")
        declarations[name] = (path, dependencies, entry["dev_dependency"], entry["native_build"])

    for path, deps, dev, native in declarations.values():
        for dep in deps:
            if dep not in declarations:
                raise ValueError("undeclared dependency")
            if native and not declarations[dep][3]:
                raise ValueError("native plugin depends on nonnative plugin")

    colors = {}

    def visit(name: str) -> None:
        if colors.get(name) == 1:
            raise ValueError("dependency cycle")
        if colors.get(name) == 2:
            return
        colors[name] = 1
        for dep in declarations[name][1]:
            visit(dep)
        colors[name] = 2

    for name in declarations:
        visit(name)
    return tuple(
        PluginMaterial(
            name=name, project_name=":" + name, project_relative_dir=path + "/android",
            build_output_relative_dir=root + "/.android/plugins_build_output/" + name,
            dependencies=deps, dev_dependency=dev,
        )
        for name, (path, deps, dev, native) in declarations.items() if native
    )
