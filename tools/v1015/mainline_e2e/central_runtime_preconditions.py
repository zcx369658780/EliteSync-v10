"""Static central-v14 fact contracts. No native reads, observer, Popen or grant.

Inputs are independently captured trusted-operator evidence, not self-authenticating
assertions. A synthetic match neither proves Microsoft trust nor observes PHP ABI.
"""
import json
import ntpath
import re
from pathlib import Path
from contracts import need
from os_images import norm

CENTRAL_CLASS = 'MICROSOFT_CENTRAL_V14_RUNTIME'
NAMES = frozenset({'vcruntime140.dll'})


def hash64(value):
    return isinstance(value, str) and re.fullmatch('[a-f0-9]{64}', value) is not None


def version4(value):
    need(isinstance(value, str) and re.fullmatch(r'\d+[.]\d+[.]\d+[.]\d+', value) is not None,
         'CENTRAL_VERSION_FORMAT')
    return tuple(int(x) for x in value.split('.'))


def check_central_file_facts(fact, system, pin):
    need(pin.get('source_class') == CENTRAL_CLASS, 'CENTRAL_SOURCE_CLASS_REQUIRED')
    name = ntpath.basename(fact['path']).lower()
    need(name in NAMES and pin.get('module') == name, 'CENTRAL_NAMED_MODULE_ONLY')
    need(system.get('from_system_directory_api') is True and system.get('reparse') is False,
         'CENTRAL_SYSTEM_DIRECTORY_API_REQUIRED')
    need(norm(ntpath.dirname(fact['path'])) == norm(system['path'])
         and norm(fact['canonical_path']) == norm(fact['path'])
         and norm(pin['path']) == norm(fact['path']), 'CENTRAL_DIRECT_CANONICAL_SYSTEM_PATH')
    need(fact.get('readonly_handle') is True and fact.get('reparse') is False
         and type(fact.get('links')) is int and fact['links'] == 1, 'CENTRAL_LINK_OR_WRITE_REJECTED')
    need(fact.get('architecture') == 'x64' and fact.get('volume') == system.get('volume'),
         'CENTRAL_ARCH_OR_VOLUME')
    need(all(type(fact.get(k)) is int and fact[k] > 0 for k in ('file_id', 'volume', 'bytes'))
         and hash64(fact.get('sha256')),
         'CENTRAL_IDENTITY_REQUIRED')
    for key in ('sha256', 'file_id', 'volume', 'links', 'bytes', 'file_version'):
        need(fact.get(key) == pin.get(key), 'CENTRAL_PIN_CHANGED')
    signature = pin.get('signature', {})
    need(signature.get('valid_offline_trust') is True
         and signature.get('microsoft_publisher_verified') is True
         and hash64(signature.get('certificate_sha256'))
         and hash64(signature.get('publisher_chain_evidence_sha256')),
         'CENTRAL_SIGNATURE_CHAIN_EVIDENCE_REQUIRED')
    need(hash64(pin.get('minimum_compatibility_evidence_sha256')),
         'CENTRAL_COMPILER_COMPATIBILITY_EVIDENCE_REQUIRED')
    need(version4(fact['file_version']) >= version4(pin['minimum_runtime_version']),
         'CENTRAL_VERSION_BELOW_PINNED_MINIMUM')
    return dict(state='STATIC_CENTRAL_FILE_FACTS_MATCHED_ONLY',
                source_class=CENTRAL_CLASS, runtime_authorized=False, php_abi_observed=False)


def check_central_loaded_facts(loaded, pin, expected_process):
    need(pin.get('source_class') == CENTRAL_CLASS and pin.get('module') in NAMES,
         'CENTRAL_LOADED_SOURCE_CLASS')
    need(loaded.get('from_loaded_module_api') is True
         and loaded.get('process') == expected_process
         and type(expected_process.get('pid')) is int and expected_process['pid'] > 0
         and type(expected_process.get('creation')) is int and expected_process['creation'] > 0
         and re.fullmatch('[a-f0-9]{32}', expected_process.get('nonce', '')) is not None,
         'CENTRAL_LOADED_PROCESS_GENERATION')
    need(norm(loaded['path']) == norm(pin['path']) and loaded.get('sha256') == pin.get('sha256')
         and loaded.get('file_id') == pin.get('file_id') and loaded.get('volume') == pin.get('volume'),
         'CENTRAL_LOADED_IMAGE_CHANGED')
    return dict(state='CENTRAL_LOADED_INPUT_FACTS_MATCHED_ONLY', runtime_authorized=False,
                actual_php_load_observed_by_this_function=False)


def inspect_policy(policy):
    central = policy.get('central_runtime', {})
    return dict(state=central.get('state', 'CENTRAL_VC_NOT_QUALIFIED'),
                installed_file_present=central.get('installed_file_present'),
                observations_used=central.get('observations_used'),
                php='NOT_RUN_GATE_CLOSED', execute='NOT_AVAILABLE_IN_THIS_SOURCE_ONLY_ENTRY',
                installation_necessity='NOT_PROVEN')


def main():
    print(json.dumps(inspect_policy(json.loads(Path(__file__).with_name('php_requirements.json').read_bytes()))))


if __name__ == '__main__':
    main()
