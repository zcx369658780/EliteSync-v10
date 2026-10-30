"""Current task native-only qualification. Default import performs no observation/launch.
The business qualifier still requires the resolved Laravel12 lock/vendor.
"""
import json
from datetime import datetime, timezone
from pathlib import Path
from contracts import need, local, digest, canonical
TASK='960a738505054ac97a8cb85df660bf4f0b6decc9'
PARENT='28994ea486eccc5191985c57952a61f6f7ab3d38'
BINDING=dict(commit=PARENT,apps_tree='8cd9b6df8e744c8fc9d4217412edce31795a318d',services_tree='4c01326cbf44b4705548e97221e3336e0448406f')
ROOT_NAME='v1015-vc-chain-real-loader-20261030'


def probe_authority(config, grant, now=None):
    now=now or datetime.now(timezone.utc)
    need(grant.get('task_blob')==TASK and grant.get('owner_authorized') is True
         and grant.get('action')=='php_native_no_db_probe','CURRENT_NATIVE_SCOPE')
    need(datetime.fromisoformat(grant['not_before'])<=now<datetime.fromisoformat(grant['expires_at']), 'GRANT_EXPIRED')
    need(grant.get('probe_operations')==2 and 0<grant.get('probe_seconds',0)<=30,'CURRENT_PROBE_BUDGET')
    need(grant.get('db_operations')==0 and grant.get('network_operations')==0
         and grant.get('laravel_bootstrap_allowed') is False and grant.get('new_instance_qualified') is False,'CURRENT_NO_DB_SCOPE')
    need(not set(config)&{'api','database','db_port','db_username','db_password','datadir','server_id','fixture_password','app_key'},'CURRENT_PROBE_DB_CONFIG')
    root=local(config['task_root']);need(root.is_dir() and root.name==ROOT_NAME,'CURRENT_NATIVE_ROOT')
    need(config.get('source_binding')==grant.get('source_binding')==BINDING,'CURRENT_NATIVE_SOURCE_BINDING')
    need(digest(canonical(config))==grant.get('config_sha256'),'CONFIG_CHANGED')
    need(0<config.get('max_bytes',0)<=8589934592 and config['max_bytes']==grant.get('max_bytes'),'CURRENT_SPACE_BUDGET')
    source=local(config['source_root'],root);files=config.get('source_files',{})
    required={'tests/E2E/php_runtime_probe.php','tests/E2E/MainlineEnvironment.php','tests/E2E/PhpRuntimeQualification.php','composer.json','composer.lock'}
    need(required<=set(files),'PROBE_SOURCE_CLOSURE_REQUIRED')
    for rel,h in files.items():
        need(isinstance(rel,str) and not Path(rel).is_absolute() and '..' not in Path(rel).parts and ':' not in rel,'PROBE_SOURCE_PATH')
        p=local(source/rel,root);need(p.is_file() and digest(p.read_bytes())==h,'PROBE_SOURCE_BYTES_CHANGED')
    return root


def qualify(config,grant):
    from php_runtime import POLICY, validate_manifest
    root=probe_authority(config,grant);policy=json.loads(POLICY.read_bytes())
    need(policy.get('candidate_parent')==PARENT and policy.get('native_probe_task_blob')==TASK,'CURRENT_NATIVE_POLICY')
    path=local(config['php_runtime_manifest'],root);raw=path.read_bytes();h=digest(raw)
    need(h==config.get('php_runtime_manifest_sha256')==grant.get('php_cli_manifest_sha256')==grant.get('php_api_manifest_sha256'),'PHP_CLI_API_CLOSURE_MISMATCH')
    manifest=json.loads(raw);need(manifest.get('source_binding')==BINDING and manifest.get('central_runtime') is not None,'CURRENT_NATIVE_MANIFEST_SOURCE')
    # This is native-only: no assertion that the historical lock has been resolved.
    need(not any(x.get('origin')!='TRUSTED_EXISTING_PHP_DISTRIBUTION' for x in manifest.get('files',[])),'CURRENT_PRIVATE_REDIST_FORBIDDEN')
    pins={x['path']:x['sha256'] for x in policy['verified_archive_members']}
    need({x['path']:x['sha256'] for x in manifest.get('files',[])}==pins,'CURRENT_DISTRIBUTION_MEMBER_PINS')
    result=validate_manifest(manifest,local(config['php_runtime_root'],root),policy)
    need(local(config['php'],root)==Path(result['executable']) and grant.get('php_sha256')==policy['reference_executable_sha256'],'CURRENT_EXE_SOURCE')
    need(local(config['php_extension_dir'],root)==Path(result['extension_directory']),'PHP_CONFIG_EXTENSION_DIR')
    for rel,expected in policy['source_documents'].items():
        need(digest(local(Path(config['source_root'])/rel,root).read_bytes())==expected,'PHP_COMPOSER_SOURCE_CHANGED')
    pp=local(config['php_requirements'],root);need(json.loads(pp.read_bytes())==policy and digest(pp.read_bytes())==grant.get('php_requirements_file_sha256'),'CURRENT_NATIVE_REQUIREMENTS')
    for name in ['home','tmp','appdata','localappdata','empty-ini']:
        need(local(root/name,root).is_dir(),'PHP_PRIVATE_WRITE_DIRECTORY_MISSING')
    need(not any((root/'empty-ini').iterdir()),'PHP_INI_SCAN_DIRECTORY_NOT_EMPTY')
    result.update(manifest_sha256=h,requirements_file=str(pp));return result


def execution_gate(root, profile, grant):
    """Fail closed before Popen, bound to the original cross-session ledger."""
    import ctypes, os
    root=local(root);need(root.name==ROOT_NAME,'CURRENT_NATIVE_ROOT')
    ledger=local(root/'execution_ledger.jsonl',root)
    rows=[json.loads(x) for x in ledger.read_bytes().splitlines()]
    need(rows and rows[0].get('task_id')=='V1015_CENTRAL_VC_TRUST_CHAIN_L12_E2E_20261030'
         and rows[0].get('task_blob')==TASK and rows[0].get('sole_parent')==PARENT,'CURRENT_LEDGER_TASK')
    need(not any('TERMINAL_STOP' in str(x.get('action',x.get('event',''))) for x in rows),'CURRENT_TASK_ALREADY_STOPPED')
    count=lambda name:sum(x.get('action',x.get('event'))==name for x in rows)
    need(count('PREPARE_PHP_DB_FREE_PROBE')<2,'PROBE_BUDGET_EXHAUSTED')
    need(count('PREPARE_PHP_CLI_START')<60,'PHP_CLI_BUDGET_EXHAUSTED')
    need(os.name=='nt','WINDOWS_NATIVE_RUNTIME_REQUIRED')
    clock=ctypes.WinDLL('kernel32');clock.GetTickCount64.restype=ctypes.c_uint64
    need(0<=clock.GetTickCount64()-rows[0]['tick_start']<7200000,'PROBE_WINDOW_EXHAUSTED')
    from central_vc_loader import verify_current
    verify_current(profile['manifest']['central_runtime'])
    policy=profile['manifest'].get('windows_os_image_policy')
    need(isinstance(policy,dict) and policy.get('purpose')=='READONLY_LOADED_WINDOWS_OS_IMAGES','OS_IMAGE_SOURCE_NOT_QUALIFIED')
    from pe_dependencies import pe_info
    from php_runtime import os_import
    # At minimum all direct, non-api-set OS imports must have an exact trusted pin.
    # Unknown actually loaded modules are STILL rejected by the post-Popen guard.
    from os_images import system_root_fact, readonly_fact, validate_os_source
    system=system_root_fact()
    for row in profile['manifest']['files']:
        for name in pe_info(local(Path(profile['root'])/row['path'],Path(profile['root'])).read_bytes())['imports']:
            if os_import(name) and not name.startswith(('api-ms-','ext-ms-')):
                need(name in policy.get('images',{}),'NATIVE_OS_IMPORT_NOT_QUALIFIED:'+name)
                validate_os_source(readonly_fact(Path(system['path'])/name),policy,system)
    return ledger
