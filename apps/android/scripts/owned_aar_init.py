"""Byte-only validation of the project-owned Flutter AAR init (no execution).

The tracked copy is option A. derive_bytes is its deterministic provenance check,
not a runtime generator; verification never edits the SDK or creates a copy.
"""
import hashlib
import json
from pathlib import Path

UPSTREAM_SHA256 = 'b6b870954405c5d52afea183bb51b3220100c234401142d8c1bf3e2410cee2c2'
LICENSE_SHA256 = 'a3a9fd82f800a47377f7d3f60c60a5c91cae0495be8f329031e1448ce0f5dab9'
OWNED_SHA256 = '364295d4d861d81ca3113d25acf6e45dd422ebce64b412ef9baf20e02d32c48d'
PROVENANCE_SHA256 = '0f14efe7ed1a2d84be53f2a76a70a343a8bece8dc42f34b368c637c9b17a5f51'
SCOPE = 'v10.1.5-ordinary-r1-runtime'
DIRECTORY = 'apps/android/scripts/owned_flutter_aar_init'
REQUIRED_PROJECT_INPUTS = (
    'apps/android/app/build.gradle.kts', 'apps/android/scripts/owned_aar_init.py',
    DIRECTORY + '/aar_runtime.init.gradle', DIRECTORY + '/FLUTTER_LICENSE', DIRECTORY + '/SOURCE.json',
    DIRECTORY + '/UPSTREAM.patch',
)
PREAMBLE = (
    b'// Copyright 2014 The Flutter Authors. All rights reserved.\n'
    b'// SPDX-License-Identifier: BSD-3-Clause; see FLUTTER_LICENSE and SOURCE.json.\n'
    b'// EliteSync owned derivative: two Javadoc requests removed; sources/runtime publication retained.\n'
    b"if (gradle.startParameter.projectProperties['elitesyncOwnedAarInit'] != 'v10.1.5-ordinary-r1-runtime') {\n"
    b"    throw new GradleException('OWNED_AAR_INIT_REJECTED: explicit ordinary R1 scope required')\n"
    b'}\n\n'
)
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
    return {'schema': 1, 'scope': SCOPE, 'sourceSha256': UPSTREAM_SHA256,
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
