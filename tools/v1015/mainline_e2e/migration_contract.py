"""Nonproduction Laravel 12/PHP 8.5 input audit; import/inspect never launches tools.

This is a bounded source contract, not Composer schema validation or a SAT solver.
An audit result never grants runtime authority or verifies downloaded bytes.
"""
import json
import re
from pathlib import Path
from contracts import need

DEPLOYMENT_MODULES = frozenset('ctype curl dom fileinfo filter hash mbstring openssl pcre pdo session tokenizer xml'.split())
PHP_CONSTRAINT = '~8.5.12'


def require_runtime_policy(policy):
    """Called by both CLI and API qualification, before any process may start."""
    need(policy.get('runtime_qualification_state') == 'QUALIFIED_FOR_NEW_OWNER_RUNTIME_TASK'
         and policy.get('composer_lock_state') == 'RESOLVED', 'PHP_DEPENDENCY_SUPPLY_PENDING')
    need(isinstance(policy.get('reference_executable_sha256'), str)
         and re.fullmatch('[a-f0-9]{64}', policy['reference_executable_sha256']) is not None,
         'PHP_TARGET_EXECUTABLE_HASH_PENDING')
    vc = policy.get('vc_runtime', {})
    need(vc.get('state') == 'QUALIFIED'
         and isinstance(vc.get('minimum_version'), str)
         and all(re.fullmatch('[a-f0-9]{64}', vc.get(k) or '') for k in
                 ('source_receipt_sha256', 'license_receipt_sha256')),
         'PHP_VC_SOURCE_LICENSE_VERSION_PENDING')


def inspect_inputs(composer, lock, policy):
    req = composer.get('require', {})
    need(req.get('laravel/framework') == '^12.0', 'LARAVEL12_TARGET_REQUIRED')
    need(req.get('php') == PHP_CONSTRAINT, 'PHP85_MAINTENANCE_RANGE_REQUIRED')
    need(all(req.get('ext-' + module) == '*' for module in DEPLOYMENT_MODULES | {'pdo_mysql'}),
         'COMPOSER_DEPLOYMENT_EXTENSION_REQUIRED')
    need(policy.get('php_version') == '8.5.12' and policy.get('thread_safe') is False,
         'PHP85_NTS_TARGET_REQUIRED')
    need(DEPLOYMENT_MODULES | {'pdo_mysql'} <= set(policy.get('required_modules', [])),
         'PHP_DEPLOYMENT_MODULE_REQUIRED')
    need('curl' in policy.get('required_shared_modules', [])
         and {'curl_init', 'curl_exec', 'curl_version'} <= set(policy.get('functions', [])),
         'CURL_SHARED_CAPABILITY_REQUIRED')
    need('curl' not in policy.get('optional_modules', {}), 'CURL_CANNOT_BE_OPTIONAL')
    need(policy.get('framework', {}).get('target_major') == 12
         and policy['framework'].get('future_mode') == 'EVALUATION_ONLY', 'NO_LARAVEL13_AUTHORITY')
    packages = {p['name']: p for p in lock.get('packages', []) + lock.get('packages-dev', [])}
    framework = packages.get('laravel/framework', {}).get('version', 'MISSING')
    carbon = packages.get('nesbot/carbon', {}).get('version', 'MISSING')
    reasons = []
    if re.fullmatch(r'v?12[.]\d+[.]\d+', framework) is None:
        reasons.append('framework lock is not Laravel 12')
    if not carbon.lstrip('v').startswith('3.'):
        reasons.append('Carbon 3 lock required')
    if lock.get('platform', {}).get('php') != PHP_CONSTRAINT:
        reasons.append('lock PHP platform does not match composer.json')
    return dict(classification='STATIC_INPUT_AUDIT_ONLY', locked_framework=framework,
                locked_carbon=carbon, lock_state='LOCK_RESOLUTION_PENDING' if reasons else
                'LOCK_VERSION_INPUTS_MATCH_COMPOSER_SOLVER_NOT_PROVEN', reasons=reasons,
                runtime='NOT_RUN_GATE_CLOSED', composer_solver_executed=False,
                target_binary_bytes_verified=False)


def inspect(source_root):
    root = Path(source_root)
    return inspect_inputs(json.loads((root / 'services/backend-laravel/composer.json').read_bytes()),
                          json.loads((root / 'services/backend-laravel/composer.lock').read_bytes()),
                          json.loads(Path(__file__).with_name('php_requirements.json').read_bytes()))


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source_root', type=Path)
    args = parser.parse_args()
    print(json.dumps(inspect(args.source_root), sort_keys=True))
