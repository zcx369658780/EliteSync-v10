"""Source-bound APK preparation data; never grants execution or a new budget."""
import re


SOURCE = '84a94c9177ce832040146cff9968569762300307'
APPS = 'ed24852975baebeadc66f007dfb75ff9e31a97d4'
SERVICES = '7634b4755a41f08641e00948f684c06efb12d8fe'
PACKAGE = 'com.elitesync.v1015dev'


def make_plan(*, identity, configuration, device, inventory_sha256):
    if identity != {'source_commit': SOURCE, 'apps_tree': APPS, 'services_tree': SERVICES}:
        raise ValueError('Only the current accepted product identity is covered')
    proof = configuration.get('proof', {})
    if (configuration.get('status') != 'CONFIG_GRAPH_BOUNDED_SUPPORTED'
            or type(proof.get('root_exit')) is not int or proof['root_exit'] != 0
            or proof.get('stop_reason') is not None
            or proof.get('job_final_empty') is not True
            or proof.get('all_bound_handles_exited') is not True):
        raise ValueError('A successful bounded configuration result is required')
    for digest in [configuration.get('receipt_sha256'), inventory_sha256]:
        if type(digest) is not str or re.fullmatch('[0-9a-f]{64}', digest) is None:
            raise ValueError('Exact evidence SHA256 identities are required')
    if (device.get('status') != 'READONLY_DEVICE_IDENTITY_BOUNDED_SUPPORTED'
            or device.get('matches_previous_owner_device') is not True
            or device.get('abi') != 'arm64-v8a'
            or type(device.get('api')) is not int or device['api'] < 26
            or device.get('target_package') != PACKAGE
            or type(device.get('target_installed')) is not bool):
        raise ValueError('The bound arm64 Owner test device is required')
    # A profile from a prior install/media run is not this read-only observation.
    for name in ['install', 'launch', 'reverse', 'data_clear', 'media', 'actual_builds']:
        if type(device.get(name)) is not int or device[name] != 0:
            raise ValueError('Read-only device evidence must retain zero write actions')
    version = '1.0-v1015-' + SOURCE[:12] + '-' + inventory_sha256[:12]
    return {
        'schema': 1, 'kind': 'current-product-apk-preparation-plan',
        'identity': dict(identity), 'configuration_receipt_sha256': configuration['receipt_sha256'],
        'selected_inventory_sha256': inventory_sha256,
        'publication_identity_scope': 'SOURCE_AND_SELECTED_INVENTORY_ONLY_NOT_FULL_BUILD_INPUTS',
        'stages': [
            {'name': 'owned_flutter_release_aar', 'task': 'assembleAarRelease',
             'target': 'lib/main.dart', 'abi': 'android-arm64', 'publication_version': version},
            {'name': 'android_host_debug_apk', 'task': ':app:assembleDebug',
             'project': 'apps/android', 'package': PACKAGE, 'version_code': 1010501,
             'version_name': '10.1.5-dev', 'abi': 'arm64-v8a',
             'flutter_artifact': 'com.elitesync.flutter_elitesync_module:flutter_release:' + version},
        ],
        'dart_defines': ['ELITESYNC_V1015_LOCAL_BUILD=true', 'ELITESYNC_V1014_LOCAL_BUILD=true'],
        'api': 'http://127.0.0.1:8021/', 'ws': 'ws://127.0.0.1:8022/',
        'sdk_source_write_allowed': False, 'download_allowed': False,
        'gates': {
            'complete_build_input_closure': 'NOT_PROVEN',
            'owned_flutter_cache_and_lock': 'NOT_PREPARED',
            'direct_dart_snapshot_entry': 'SOURCE_ONLY_NOT_QUALIFIED',
            'native_process_tree': 'NOT_QUALIFIED_JAVA_CONFIG_OBSERVER_ONLY',
            'host_verified_aar_handoff': 'NOT_IMPLEMENTED',
            'offline_action_dependencies': 'NOT_PROVEN',
            'build_budget_and_claim': 'UNKNOWN_NOT_CREATED',
            'artifact_package_signature_abi': 'NOT_BUILT',
            'device_usb_transport': 'READONLY_WINDOWS_BINDING_SUPPORTED' if device.get('usb_adb_binding') is True else 'NOT_PROVEN',
            'device_install': 'NOT_READY_EXISTING_PACKAGE' if device['target_installed'] else 'NOT_RUN',
        },
        'ordinary_batch_prebuild': 'NOT_ELIGIBLE',
        'attempt_cap_proposed': 1, 'claim_created': False, 'old_claims_reused': False,
        'execution_allowed': False, 'install_allowed': False, 'real_media_allowed': False,
        'G2': False,
    }
