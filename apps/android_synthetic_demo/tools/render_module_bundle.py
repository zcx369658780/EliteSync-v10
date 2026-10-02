"""M5-23 SOURCE-ONLY four-body renderer; no bundle writes or execution.

SDK includedBuild/Flutter plugin and actual plugin side effects remain unknown.
Text generation proves neither Gradle compatibility nor runtime isolation.
"""

import re
from aar_material_functions import synthetic_plugin_materials


_FIXED = {
    "module_id": "flutter",
    "group_id": "com.elitesync.syntheticdemo",
    "namespace": "com.elitesync.syntheticdemo",
    "module_root": "module",
    "sdk_root": "materials/flutter_sdk",
    "maven_root": "materials/maven",
    "agp_version": "8.11.1",
    "kotlin_version": "2.2.20",
    "compile_sdk": 36,
    "min_sdk": 26,
    "target_sdk": 35,
}
_APPROVED = {
    "sample_alpha": "materials/sample_alpha",
    "sample_beta": "materials/sample_beta",
    "sample_gamma": "materials/sample_gamma",
}
_TARGETS = (
    "module/.android/settings.gradle",
    "module/.android/build.gradle",
    "module/.android/Flutter/build.gradle",
    "module/.android/Flutter/src/main/AndroidManifest.xml",
)
_SETTINGS_PREFIX = """// SOURCE-ONLY synthetic module; NOT_READY.
pluginManagement {
    includeBuild(new File(settingsDir, '../../materials/flutter_sdk/packages/flutter_tools/gradle'))
    repositories {
        maven { url = uri(new File(settingsDir, '../../materials/maven')) }
    }
}
plugins {
    id 'com.android.library' version '8.11.1' apply false
    id 'org.jetbrains.kotlin.android' version '2.2.20' apply false
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        maven { url = uri(new File(settingsDir, '../../materials/maven')) }
    }
}
rootProject.name = 'android_generated'
include ':flutter'
project(':flutter').projectDir = new File(settingsDir, 'Flutter')
"""
_MANIFEST = """<!-- SOURCE-ONLY synthetic module; NOT_READY. -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <uses-permission android:name="android.permission.INTERNET" tools:node="remove" />
    <uses-permission android:name="android.permission.CAMERA" tools:node="remove" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" tools:node="remove" />
    <application android:allowBackup="false" tools:node="merge">
        <meta-data android:name="flutterProjectType" android:value="module" />
        <meta-data android:name="flutterEmbedding" android:value="2" />
    </application>
</manifest>
"""


def render_module_bundle(
    *, config: dict, metadata: dict,
    approved_plugin_paths: tuple[tuple[str, str], ...],
) -> tuple[tuple[str, bytes], ...]:
    """Return immutable UTF-8/LF texts under a logical bundle-root only."""
    if type(config) is not dict:
        raise TypeError("config must be an exact dict")
    if set(config) != set(_FIXED) | {"ndk_version", "input_id"}:
        raise ValueError("unexpected or missing config keys")
    for key, expected in _FIXED.items():
        value = config[key]
        if type(value) is not type(expected):
            raise TypeError("config field type mismatch")
        if value != expected:
            raise ValueError("config field outside fixed design")
    ndk = config["ndk_version"]
    identifier = config["input_id"]
    if type(ndk) is not str or type(identifier) is not str:
        raise TypeError("NDK and input ID must be exact strings")
    if re.fullmatch(r"[1-9][0-9]*\.[0-9]+\.[0-9]+", ndk, re.ASCII) is None:
        raise ValueError("invalid NDK material version")
    if re.fullmatch(r"[0-9a-f]{64}", identifier, re.ASCII) is None:
        raise ValueError("invalid input ID material")
    plugins = synthetic_plugin_materials(
        metadata=metadata, approved_plugin_paths=approved_plugin_paths,
        module_relative_root="module",
    )
    roots = ["module", "materials/flutter_sdk", "materials/maven", "outputs", "publication", "host"]
    for name, path in approved_plugin_paths:
        if _APPROVED.get(name) != path:
            raise ValueError("approved plugin outside artificial fixture domain")
        roots.append(path)
    for index, left in enumerate(roots):
        for right in roots[index + 1:]:
            if left == right or left.startswith(right + "/") or right.startswith(left + "/"):
                raise ValueError("bundle material roots overlap")

    settings = _SETTINGS_PREFIX
    root = (
        "// SOURCE-ONLY synthetic module; NOT_READY.\n"
        "layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/module-root'))\n"
        "ext.set('output-dir', new File(rootProject.projectDir, '../../publication').path)\n"
        "ext.set('is-plugin', 'false')\n"
        "ext.set('buildNumber', '" + identifier + "')\n"
        "subprojects {\n"
        "    if (name == 'flutter') {\n"
        "        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/flutter'))\n"
        "    }\n"
    )
    flutter = (
        "// SOURCE-ONLY synthetic module; NOT_READY.\n"
        "plugins {\n"
        "    id 'com.android.library'\n"
        "    id 'dev.flutter.flutter-gradle-plugin'\n"
        "}\n"
        "group = 'com.elitesync.syntheticdemo'\n"
        "version = '" + identifier + "'\n"
        "android {\n"
        "    namespace = 'com.elitesync.syntheticdemo'\n"
        "    compileSdk = 36\n"
        "    ndkVersion = '" + ndk + "'\n"
        "    compileOptions {\n"
        "        sourceCompatibility = JavaVersion.VERSION_17\n"
        "        targetCompatibility = JavaVersion.VERSION_17\n"
        "    }\n"
        "    defaultConfig {\n"
        "        minSdk = 26\n"
        "        targetSdk = 35\n"
        "        versionCode = 1\n"
        "        versionName = '1.0'\n"
        "    }\n"
        "    publishing {\n"
        "        singleVariant('debug')\n"
        "    }\n"
        "}\n"
        "androidComponents {\n"
        "    beforeVariants(selector().all()) { variantBuilder ->\n"
        "        variantBuilder.enable = variantBuilder.name == 'debug'\n"
        "    }\n"
        "}\n"
        "flutter {\n"
        "    source = '../..'\n"
        "}\n"
        "dependencies {\n"
    )
    for plugin in plugins:
        name = plugin.name
        # settingsDir/rootProjectDir = bundle/module/.android, not bundle-root.
        settings += "include ':" + name + "'\n"
        settings += "project(':" + name + "').projectDir = new File(settingsDir, '../../" + plugin.project_relative_dir + "')\n"
        root += "    if (name == '" + name + "') {\n"
        root += "        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/plugins/" + name + "'))\n"
        root += "    }\n"
        flutter += "    implementation project(':" + name + "')\n"
    root += "}\n"
    flutter += "}\n"
    return tuple((path, body.encode("utf-8")) for path, body in zip(
        _TARGETS, (settings, root, flutter, _MANIFEST)
    ))
