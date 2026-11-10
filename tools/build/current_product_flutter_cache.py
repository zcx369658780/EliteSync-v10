"""Read-only revision-bound SDK cache metadata checks; never grants execution."""
import re


def assess_warm_cache(data):
    """Check caller-bound metadata without repairing stamps or attesting a VM."""
    head = data['sdk_git_head']
    if type(head) is not str or len(head) != 40 or any(c not in '0123456789abcdef' for c in head):
        raise ValueError('Exact SDK revision required')
    for key in ['yaml_mtime_ns', 'lock_mtime_ns']:
        if type(data[key]) is not int or data[key] <= 0:
            raise ValueError('Exact positive source timestamps required')
    if type(data['tool_args']) is not str:
        raise ValueError('Exact bootstrap VM arguments required')
    version = data['version_json']
    engine = data['engine_info_json']
    required = ['frameworkVersion', 'channel', 'repositoryUrl', 'frameworkRevision',
                'frameworkCommitDate', 'engineRevision', 'dartSdkVersion', 'devToolsVersion', 'flutterVersion']
    version_schema = isinstance(version, dict) and all(
        type(version.get(k)) is str and bool(version[k].strip()) for k in required)
    optional = ['engineCommitDate', 'engineContentHash', 'engineBuildDate']
    version_schema = version_schema and all(version.get(k) is None or type(version[k]) is str for k in optional)
    version = version if isinstance(version, dict) else {}
    engine = engine if isinstance(engine, dict) else {}
    stamps = [data[k].strip() for k in ['engine_version', 'engine_stamp', 'engine_dart_stamp', 'engine_info_stamp']]
    # Match the observed stable engine.version branch of update_engine_version.ps1,
    # not an assumed relation to engine content_hash or a prebuilt override.
    checks = {
        'revision_bound_compile_key': data['tool_stamp'].strip() == '"' + head + ':' + data['tool_args'] + '"',
        'version_json_schema': version_schema,
        'engine_version_tracked': data.get('engine_version_tracked') is True,
        'no_engine_override': data.get('prebuilt_engine_override') is None,
        'engine_stamps': len(set(stamps)) == 1 and re.fullmatch('[0-9a-f]{40}', stamps[0]) is not None,
        'version_revision': version.get('frameworkRevision') == head,
        'engine_git_revision': engine.get('git_revision') == version.get('engineRevision') == data['engine_stamp'].strip(),
        'dart_version': bool(data['dart_version'].strip()) and version.get('dartSdkVersion') == data['dart_version'].strip(),
        'lock_not_older_than_yaml': data['lock_mtime_ns'] >= data['yaml_mtime_ns'] or
            data['lock_mtime_ns'] // 60_000_000_000 == data['yaml_mtime_ns'] // 60_000_000_000,
    }
    return {'checks': checks, 'all_static_checks_supported': all(checks.values()),
            'scope': 'CALLER_BOUND_STATIC_WARM_CACHE_METADATA_ONLY',
            'stock_bat_branch': 'UNKNOWN_NOT_EXECUTED',
            'stamp_repaired': False, 'producer_entry_allowed': False, 'execution_allowed': False, 'G2': False}
