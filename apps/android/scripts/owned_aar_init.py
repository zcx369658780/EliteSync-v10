"""Byte-only validation of the project-owned Flutter AAR init (no execution).

The tracked copy is option A. derive_bytes is its deterministic provenance check,
not a runtime generator; verification never edits the SDK or creates a copy.
"""
import hashlib
import json
import base64
import re
from pathlib import Path

UPSTREAM_SHA256 = 'b6b870954405c5d52afea183bb51b3220100c234401142d8c1bf3e2410cee2c2'
LICENSE_SHA256 = 'a3a9fd82f800a47377f7d3f60c60a5c91cae0495be8f329031e1448ce0f5dab9'
OWNED_SHA256 = '28c407c4fb95a7de690ff9a1455faf33bb62c28b365281dc6c2dfd20a61bb1a9'
PROVENANCE_SHA256 = 'ff4d82097e80239fb9d9861a68731573079d4120a2026aeddc5d4615c456942f'
SCOPE = 'v10.1.5-ordinary-r1-runtime'
DIRECTORY = 'apps/android/scripts/owned_flutter_aar_init'
REQUIRED_PROJECT_INPUTS = (
    'apps/android/app/build.gradle.kts', 'apps/android/scripts/owned_aar_init.py',
    DIRECTORY + '/aar_runtime.init.gradle', DIRECTORY + '/FLUTTER_LICENSE', DIRECTORY + '/SOURCE.json',
    DIRECTORY + '/UPSTREAM.patch',
)
TOOLING_PINS = {
    'build.gradle.kts': '8d83640366f1f78c9db70f771d0c6e4a9c0d9e4858aa6eee30891e86fed323b1',
    'settings.gradle.kts': '106ea06cbc2bf28234443b8a74e7ec4e32a817b4d279d122a650c073daad4d37',
    'src/main/kotlin/FlutterAppPluginLoaderPlugin.kt': '8f0cff54afa2bc47a463f8bdec32ee2163c365d980e8f461a8941f02ace96be1',
}
CONTEXT_GUARD_SHA256 = '159a20ea2d7233b6e11d114cfa744a5edbdb9c230ffbf938d26fc231af380604'
REQUIRED_PROJECT_INPUTS += (DIRECTORY + '/context_guard.gradle',)
HEADER = (
    b'// Copyright 2014 The Flutter Authors. All rights reserved.\n'
    b'// SPDX-License-Identifier: BSD-3-Clause; see FLUTTER_LICENSE and SOURCE.json.\n'
    b'// EliteSync owned derivative: two Javadoc requests removed; sources/runtime publication retained.\n'
)
PREAMBLE = HEADER + (Path(__file__).parent / 'owned_flutter_aar_init/context_guard.gradle').read_bytes() + b'\n'
PATCHES = tuple((
    b' ' * spaces + b'withSourcesJar()\r\n' + b' ' * spaces + b'withJavadocJar()\r\n',
    b' ' * spaces + b'withSourcesJar()\r\n',
) for spaces in (20, 16))


class OwnedInitError(ValueError):
    pass


def require(ok, reason):
    if not ok:
        raise OwnedInitError(reason)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def _patch_exact(source):
    require(source.count(b'withJavadocJar()') == 2, 'PATCH_CONTEXT_COUNT')
    for old, new in PATCHES:
        require(source.count(old) == 1, 'PATCH_CONTEXT_NOT_UNIQUE')
        source = source.replace(old, new, 1)
    return PREAMBLE + source


def derive_bytes(source):
    require(digest(source) == UPSTREAM_SHA256, 'SOURCE_IDENTITY_MISMATCH')
    return _patch_exact(source)


def checked_file(root, relative):
    root = Path(root)
    rel = Path(relative)
    require(root.is_absolute() and '..' not in root.parts and not rel.is_absolute()
            and '..' not in rel.parts, 'UNSAFE_OWNED_PATH')
    target = root / rel
    require(target.is_file(), 'OWNED_INPUT_MISSING:' + relative)
    for path in [target, *target.parents]:
        require(not path.is_symlink() and not getattr(path.lstat(), 'st_file_attributes', 0) & 1024,
                'OWNED_REDIRECTED_PATH')
    require(target.resolve().is_relative_to(root.resolve()), 'OWNED_PATH_ESCAPE')
    return target


def verify_files(project_root, flutter_root):
    original = checked_file(flutter_root, 'packages/flutter_tools/gradle/aar_init_script.gradle')
    upstream_license = checked_file(flutter_root, 'LICENSE')
    require(digest(upstream_license.read_bytes()) == LICENSE_SHA256, 'SOURCE_LICENSE_MISMATCH')
    expected = derive_bytes(original.read_bytes())
    guard = checked_file(project_root, DIRECTORY + '/context_guard.gradle')
    require(digest(guard.read_bytes()) == CONTEXT_GUARD_SHA256, 'CONTEXT_GUARD_HASH')
    for relative, pin in TOOLING_PINS.items():
        require(digest(checked_file(flutter_root, 'packages/flutter_tools/gradle/' + relative).read_bytes()) == pin,
                'TOOLING_SOURCE_HASH:' + relative)
    owned = checked_file(project_root, DIRECTORY + '/aar_runtime.init.gradle')
    license_file = checked_file(project_root, DIRECTORY + '/FLUTTER_LICENSE')
    provenance = checked_file(project_root, DIRECTORY + '/SOURCE.json')
    require(digest(license_file.read_bytes()) == LICENSE_SHA256, 'OWNED_LICENSE_MISMATCH')
    require(digest(provenance.read_bytes()) == PROVENANCE_SHA256, 'PROVENANCE_HASH')
    info = json.loads(provenance.read_bytes())
    require(info['scope'] == SCOPE and info['option'] == 'A_TRACKED_DERIVATIVE', 'OWNED_SCOPE')
    patch = checked_file(project_root, DIRECTORY + '/UPSTREAM.patch')
    require(digest(patch.read_bytes()) == info['patchSha256'], 'OWNED_PATCH_HASH')
    require(digest(owned.read_bytes()) == OWNED_SHA256 and owned.read_bytes() == expected, 'OWNED_OUTPUT_HASH')
    return owned


def inventory_contract():
    return {'schema': 2, 'contextPolicy': 'strict-parent-root-and-exact-tooling-v2', 'scope': SCOPE,
            'contextGuardSha256': CONTEXT_GUARD_SHA256, 'toolingPins': dict(TOOLING_PINS), 'sourceSha256': UPSTREAM_SHA256,
            'ownedSha256': OWNED_SHA256, 'licenseSha256': LICENSE_SHA256,
            'provenanceSha256': PROVENANCE_SHA256}


def verify_inventory(config, roots):
    require(config.get('ownedAarInitContract') == inventory_contract(),
            'NEW_BUILD_INPUTS_REQUIRE_NEW_TRUSTED_INVENTORY')
    inventory = {(x['root'], x['path']): x['sha256'] for x in config.get('inventory', [])}
    definitions = {x['path']: x['sha256'] for x in config.get('definitions', [])}
    for relative in REQUIRED_PROJECT_INPUTS:
        actual = digest(checked_file(roots['project'], relative).read_bytes())
        require(inventory.get(('project', relative)) == actual and definitions.get(relative) == actual,
                'OWNED_INPUT_NOT_ATTESTED:' + relative)
    return verify_files(roots['project'], roots['flutter'])


def authorize_context(context):
    """Pure filesystem/policy model for isolated tests; does not execute Groovy.

    This mirrors the tracked guard but is not runtime validation of Gradle objects.
    All object relationships/flags supplied by the mock caller remain declarations.
    """
    parent = context.get('parent')
    root = context if parent is None else parent
    require(root.get('parent') is None, 'UNKNOWN_NESTED_CONTEXT')
    props = root['properties']
    require(props.get('elitesyncOwnedAarInit') == SCOPE, 'ROOT_SCOPE_REQUIRED')
    project = Path(props.get('elitesyncOwnedAarProjectRoot', ''))
    flutter = Path(props.get('flutter-root', ''))
    def directory(p):
        require(p.is_absolute() and '..' not in p.parts and p.is_dir(), 'UNSAFE_CONTEXT_PATH')
        for item in [p, *p.parents]:
            require(not item.is_symlink() and not getattr(item.lstat(), 'st_file_attributes', 0) & 1024,
                    'CONTEXT_REDIRECTED_PATH')
        require(p.resolve() == p, 'CONTEXT_NONCANONICAL_PATH')
        return p
    project, flutter = directory(project), directory(flutter)
    module = directory(project / 'apps/flutter_elitesync_module/.android')
    tooling = directory(flutter / 'packages/flutter_tools/gradle')
    require(directory(Path(root['current_dir'])) == module, 'ROOT_MODULE_IDENTITY')
    require(all(x.get('version') == '8.14' and x.get('offline') is True for x in [root, context]),
            'OFFLINE_GRADLE_CONTEXT')
    require(root.get('tasks') == ['assembleAarRelease'], 'ROOT_TASK_CONTRACT')
    defines = ','.join(base64.b64encode(x.encode()).decode() for x in
        ['ELITESYNC_V1015_LOCAL_BUILD=true', 'ELITESYNC_V1015_R1_LOCAL_BUILD=true'])
    require(props.get('target') == 'lib/main.dart' and props.get('is-plugin') == 'false' and
            props.get('dart-defines') == defines and props.get('target-platform') == 'android-x64,android-arm64' and
            re.fullmatch(r'1\.0-v1015r1-[0-9a-f]{12}', props.get('buildNumber', '')) is not None,
            'ORDINARY_RUNTIME_REQUIRED')
    expected = [project / DIRECTORY / 'aar_runtime.init.gradle', project / 'apps/android/scripts/offline_debug.init.gradle']
    require(root['init_scripts'] == expected and context['init_scripts'] == expected and
            Path(context['script']) == expected[0], 'INIT_IDENTITY_OR_ORDER')
    for p in expected:checked_file(project, p.relative_to(project).as_posix())
    verify_files(project, flutter)
    if parent is None:return 'OWNED_CONTEXT_ROOT'
    require(directory(Path(context['current_dir'])) == tooling, 'UNKNOWN_INCLUDED_CONTEXT')
    child = context['properties']
    if 'elitesyncOwnedAarProjectRoot' in child:
        require(directory(Path(child['elitesyncOwnedAarProjectRoot'])) == project, 'CONFLICTING_INCLUDED_INPUT')
    for key in ['elitesyncOwnedAarInit', 'flutter-root', 'target', 'dart-defines',
                'is-plugin', 'target-platform', 'buildNumber']:
        require(key not in child or child[key] == props[key], 'CONFLICTING_INCLUDED_INPUT')
    return 'OWNED_CONTEXT_TOOLING'
