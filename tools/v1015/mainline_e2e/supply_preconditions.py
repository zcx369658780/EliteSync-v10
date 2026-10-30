"""Source-only SUPPLY_ONLY_COMPOSER fact contract, separate from business gates.

No Popen, networking, native loading or vendor/lock writes. Trusted-operator facts
must be independently qualified; this module neither signs grants nor proves
legal rights from booleans. A matching input result is not a runtime grant.
"""
import json
import re
from pathlib import Path
from contracts import need

TASK = '5f1c709e31af0d4f2c1c93363c147942db7116c5'
PARENT = 'e93ef51401f4e25916149cca104f09debc32bc78'
APPS = '8cd9b6df8e744c8fc9d4217412edce31795a318d'
NATIVE_PROOFS = ('app_local_license_evidence_sha256', 'compiler_minimum_evidence_sha256',
                 'vc_payload_inventory_sha256', 'native_process_boundary_sha256')


def sha256(value):
    return isinstance(value, str) and re.fullmatch('[a-f0-9]{64}', value) is not None


def check_supply_only_facts(config, grant, proof, policy):
    need(grant.get('owner_authorized') is True and grant.get('task_blob') == TASK
         and grant.get('action') == 'SUPPLY_ONLY_COMPOSER', 'SUPPLY_OWNER_SCOPE_REQUIRED')
    need(grant.get('parent') == PARENT == policy.get('candidate_parent')
         and grant.get('apps_tree') == APPS == policy.get('apps_tree'), 'SUPPLY_SOURCE_BINDING')
    need(config.get('scripts') is False and config.get('plugins') is False
         and config.get('business_bootstrap') is False, 'SUPPLY_SCRIPTS_PLUGINS_BUSINESS_FORBIDDEN')
    need(not set(config) & {'database', 'db_port', 'db_password', 'api', 'fixture_password', 'app_key'},
         'SUPPLY_DB_API_CONFIGURATION_FORBIDDEN')
    need(config.get('metadata_origin') == 'https://repo.packagist.org'
         and config.get('registered_distribution_sources_only') is True
         and config.get('automatic_redirects') is False, 'SUPPLY_SOURCE_HOST_POLICY')
    for name, cap in [('http_requests', 240), ('download_bytes', 268435456),
                      ('resolution_attempts', 2), ('vendor_installs', 1)]:
        value = grant.get(name)
        need(type(value) is int and 0 < value <= cap, 'SUPPLY_BUDGET_REQUIRED')
    need(proof.get('php_archive_verified') is True
         and sha256(policy.get('reference_executable_sha256'))
         and proof.get('php_executable_sha256') == policy['reference_executable_sha256'],
         'SUPPLY_PHP_BYTES_NOT_QUALIFIED')
    need(all(sha256(proof.get(k)) for k in NATIVE_PROOFS)
         and proof.get('native_closure_qualified') is True,
         'SUPPLY_NATIVE_LICENSE_COMPILER_CLOSURE_NOT_QUALIFIED')
    need(proof.get('composer_phar_source_qualified') is True
         and sha256(proof.get('composer_phar_sha256')), 'SUPPLY_COMPOSER_SOURCE_NOT_QUALIFIED')
    # Deliberately no composer.lock readiness condition: only the supplier may
    # resolve that lock, after all independent native/source checks pass.
    return dict(state='STATIC_SUPPLY_INPUT_FACTS_MATCHED_ONLY', resolved_lock_required=False,
                process_started=False, runtime_authorized_by_this_check=False,
                business_runtime_allowed=False)


def inspect_policy(policy):
    return dict(state='SOURCE_ONLY_SUPPLY_PRECONDITIONS', execute='NOT_IMPLEMENTED_OR_AUTHORIZED_BY_THIS_ENTRY',
                php_member_hash_known=sha256(policy.get('reference_executable_sha256')),
                native_state=policy.get('vc_runtime', {}).get('state'),
                composer_lock_state=policy.get('composer_lock_state'),
                runtime='NOT_RUN_GATE_CLOSED')


def main():
    print(json.dumps(inspect_policy(json.loads(Path(__file__).with_name('php_requirements.json').read_bytes()))))


if __name__ == '__main__':
    main()
