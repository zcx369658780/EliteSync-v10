"""Task-private CMake + existing matched VC inputs. No SDK/VM/installer API.

App-local deployment is described in Microsoft's deployment-in-visual-cpp docs.
Content/signatures and a static import match never prove guest loader resolution,
complete DLL closure, redistribution rights, runtime qualification or G2.
"""
from contextlib import ExitStack
import base64
import json
from pathlib import Path, PurePosixPath
import re
import subprocess

from current_product_apk_inventory import _absolute_path, _checked_stat, inventory_files
from current_product_aar_handoff import _bound_file
from current_product_tree_inventory import inventory_trees
from native_import_inventory import parse_imports


RUNTIME_NAMES = ('msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll')
CAPS = {'file_limit': 5000, 'entry_limit': 15000, 'byte_limit': 512 * 1024**2, 'depth_limit': 64}


def validate_bundle(metadata, parsed):
    if type(metadata) is not list or len(metadata) != 3 or set(parsed) != set(RUNTIME_NAMES):
        raise ValueError('one complete three-file VC bundle required')
    names, versions, signers = set(), set(), set()
    for row in metadata:
        name = row['name']
        if name not in RUNTIME_NAMES or name in names:
            raise ValueError('unique fixed runtime name required')
        names.add(name)
        version = row['file_version']
        if (type(version) is not str or not re.fullmatch(r'14\.\d+\.\d+\.\d+', version)
                or row['product_version'] != version or row['original_filename'].casefold() != name
                or row['signature'] != 'Valid' or row['company'] != 'Microsoft Corporation'
                or not re.search(r'(?:^|,)\s*O=Microsoft Corporation(?:,|$)', row['signer'])
                or not re.fullmatch('[A-Fa-f0-9]{40}', row['thumbprint'])):
            raise ValueError('valid matching Microsoft VC metadata required')
        if parsed[name]['machine'] != '0x8664' or parsed[name]['bits'] != 64:
            raise ValueError('only the declared AMD64 runtime is covered')
        versions.add(version);signers.add(row['thumbprint'].upper())
    if len(versions) != 1 or len(signers) != 1:
        raise ValueError('do not mix runtime package versions or signer sets')
    return {'version': next(iter(versions)), 'machine': '0x8664',
            'signer_thumbprint': next(iter(signers)), 'runtime_resolution_proven': False,
            'redistribution_rights_attested': False, 'execution_allowed': False, 'G2': False}


def signature_metadata(rows):
    """Read fixed PE resources/AuthentiCode metadata, never run DLL entry points."""
    encoded_paths = base64.b64encode(json.dumps([r['path'] for r in rows]).encode()).decode()
    command = r'''$ErrorActionPreference='Stop'
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$paths=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('__PATHS__'))|ConvertFrom-Json
$rows=@(foreach($path in $paths){
 $v=[Diagnostics.FileVersionInfo]::GetVersionInfo($path);$s=Get-AuthenticodeSignature -LiteralPath $path
 [ordered]@{path=[string]$path;name=[IO.Path]::GetFileName($path).ToLowerInvariant();file_version=[string]$v.FileVersion;
 product_version=[string]$v.ProductVersion;company=[string]$v.CompanyName;original_filename=[string]$v.OriginalFilename;
 signature=[string]$s.Status;signer=[string]$s.SignerCertificate.Subject;thumbprint=[string]$s.SignerCertificate.Thumbprint}
})
[Console]::Write((ConvertTo-Json -InputObject $rows -Depth 3 -Compress -WarningAction Stop))
'''.replace('__PATHS__', encoded_paths)
    encoded = base64.b64encode(command.encode('utf-16-le')).decode()
    result = subprocess.run(['pwsh', '-NoProfile', '-NonInteractive', '-EncodedCommand', encoded],
                            capture_output=True, timeout=20)
    if result.returncode or result.stderr.strip() or len(result.stdout) > 64 * 1024:
        raise ValueError('bounded signature metadata query rejected')
    metadata = json.loads(result.stdout.decode('utf-8-sig'))
    if type(metadata) is not list or len(metadata) != len(rows):
        raise ValueError('complete metadata array required')
    if {m['path'] for m in metadata} != {r['path'] for r in rows}:
        raise ValueError('signature metadata paths differ from input handles')
    return metadata


def _records(inventory, role):
    root = _absolute_path(inventory['roots'][role]);_checked_stat(root)
    rows = [r for r in inventory['files'] if r['role'] == role]
    seen = set()
    for row in rows:
        relative = row['relative_path'];rel = PurePosixPath(relative)
        if (not relative or rel.is_absolute() or '..' in rel.parts or '\\' in relative
                or ':' in relative or str(rel) != relative or relative.casefold() in seen
                or _absolute_path(row['path']) != root.joinpath(*rel.parts)):
            raise ValueError('unique canonical source rows under their declared root required')
        seen.add(relative.casefold())
    if not rows:
        raise ValueError('declared source root must not be empty')
    return root, rows


def describe_bundle(inventory):
    root, all_rows = _records(inventory, 'jdk_17_0_18')
    rows = [r for r in all_rows if r['relative_path'] in ('bin/' + name for name in RUNTIME_NAMES)]
    if len(rows) != 3:
        raise ValueError('exact JDK-provided runtime triple required')
    parsed = {}
    # Hold all three inventoried instances while reading resources/signatures.
    with ExitStack() as stack:
        for row in rows:
            stream = stack.enter_context(_bound_file(root, row))
            if not 64 <= row['bytes'] <= 16 * 1024**2:
                raise ValueError('runtime PE size cap')
            raw = stream.read(row['bytes'] + 1)
            if len(raw) != row['bytes']:
                raise ValueError('runtime byte count drift')
            parsed[PurePosixPath(row['relative_path']).name] = parse_imports(raw)
        metadata = signature_metadata(rows)
        properties = validate_bundle(metadata, parsed)
    return {'status': 'PRIVATE_RUNTIME_CANDIDATE_ONLY', 'source_root': str(root),
            'dlls': rows, 'properties': properties, 'metadata': metadata, 'PE': parsed,
            'loaded_or_missing_guest_DLL_identity': 'UNKNOWN', 'execution_allowed': False, 'G2': False}


def _content(rows):
    return {r['relative_path']: (r['bytes'], r['sha256']) for r in rows}


def _source_tree(root, rows):
    actual = inventory_trees(roots={'cmake': str(root)}, **CAPS)
    if _content(actual['files']) != _content(rows):
        raise ValueError('current CMake file membership/content differs from declared inventory')
    by_relative = {r['relative_path']: r for r in actual['files']}
    if any(row['file_id'] != by_relative[row['relative_path']]['file_id'] for row in rows):
        raise ValueError('original CMake file identity differs')
    return actual


def stage_cmake(inventory, destination, task_root):
    """Copy every declared CMake file, adding the matched DLLs only in private bin.

    Refuse overwrites, links, source drift and collisions. Preserve partial output
    on failure. All source files are copied; empty directory metadata is not.
    """
    target, private = map(_absolute_path, (destination, task_root))
    if target.parent != private or private.parent == private or not private.is_dir():
        raise ValueError('fresh direct child of explicit private task root required')
    _checked_stat(private)
    if target.exists():
        raise FileExistsError('private candidate exists; no replacement or successor')
    source, cmake_rows = _records(inventory, 'android_cmake_3_22_1')
    jdk, _ = _records(inventory, 'jdk_17_0_18')
    if any(private.is_relative_to(root) or root.is_relative_to(private) for root in (source, jdk)):
        raise ValueError('private target must be disjoint from protected sources')
    additions = {'bin/' + name for name in RUNTIME_NAMES}
    if additions & {r['relative_path'].casefold() for r in cmake_rows}:
        raise ValueError('never overwrite an existing source runtime')
    if len(cmake_rows) + 3 > CAPS['file_limit'] or sum(r['bytes'] for r in cmake_rows) > CAPS['byte_limit']:
        raise ValueError('CMake input cap')
    bundle = describe_bundle(inventory)
    if sum(r['bytes'] for r in cmake_rows + bundle['dlls']) > CAPS['byte_limit']:
        raise ValueError('combined CMake/runtime copy byte cap')
    before = _source_tree(source, cmake_rows)
    target.mkdir()
    for parent, row in [(source, r) for r in cmake_rows] + [(jdk, r) for r in bundle['dlls']]:
        output = target / PurePosixPath(row['relative_path'])
        output.parent.mkdir(parents=True, exist_ok=True);_checked_stat(output.parent)
        with _bound_file(parent, row) as stream, output.open('xb') as copied:
            count = 0
            while chunk := stream.read(min(1024**2, row['bytes'] - count + 1)):
                count += len(chunk)
                if count > row['bytes']:
                    raise ValueError('source grew while copying')
                copied.write(chunk)
    final = inventory_trees(roots={'private_cmake': str(target)}, **CAPS)
    if _content(final['files']) != {**_content(cmake_rows), **_content(bundle['dlls'])}:
        raise ValueError('private candidate content/membership differs')
    after = _source_tree(source, cmake_rows)
    if before['files'] != after['files']:
        raise ValueError('CMake source changed during materialization')
    runtime_after = inventory_files([(r['role'], r['path']) for r in bundle['dlls']],
                                    [str(jdk)], 3, 48 * 1024**2)
    for expected, actual in zip(bundle['dlls'], runtime_after['files']):
        if any(expected[key] != actual[key] for key in ('role', 'path', 'bytes', 'sha256', 'file_id')):
            raise ValueError('VC source changed after its copy')
    return {'status': 'PRIVATE_CMAKE_AND_MATCHED_VC_INPUTS_PREPARED', 'source_cmake_root': str(source),
            'private_cmake_root': str(target), 'source_cmake_files': len(cmake_rows),
            'private_files': len(final['files']), 'private_bytes': final['total_bytes'],
            'bundle': bundle, 'inventory': final, 'source_writes': 0,
            'runtime_resolution_proven': False, 'readonly_guest_mapping_proven': False,
            'redistribution_rights_attested': False, 'SDK_executions': 0,
            'execution_allowed': False, 'G2': False}
