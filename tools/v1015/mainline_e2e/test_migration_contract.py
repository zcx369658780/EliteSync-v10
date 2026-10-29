"""Synthetic/source-only migration regressions. No PHP, Composer or network."""
import copy
import json
import unittest
from pathlib import Path
from unittest.mock import patch
from contracts import Gate, digest
from migration_contract import inspect_inputs, require_runtime_policy, DEPLOYMENT_MODULES
from php_runtime import POLICY, ZERO_TASKS, validate_manifest


class MigrationContracts(unittest.TestCase):
    def setUp(self):
        self.root = Path(__file__).resolve().parents[3]
        self.backend = self.root / 'services/backend-laravel'
        self.composer = json.loads((self.backend / 'composer.json').read_bytes())
        self.lock = json.loads((self.backend / 'composer.lock').read_bytes())
        self.policy = json.loads(POLICY.read_bytes())

    def audit(self):
        return inspect_inputs(self.composer, self.lock, self.policy)

    def test_old_lock_is_explicit_pending_and_not_runtime_success(self):
        result = self.audit()
        self.assertEqual('LOCK_RESOLUTION_PENDING', result['lock_state'])
        self.assertEqual('v11.48.0', result['locked_framework'])
        self.assertEqual('NOT_RUN_GATE_CLOSED', result['runtime'])

    def test_laravel13_rejected(self):
        self.composer['require']['laravel/framework'] = '^13.0'
        with self.assertRaisesRegex(Gate, 'LARAVEL12'): self.audit()

    def test_php_legacy_or_unbounded_ranges_rejected(self):
        for value in ('^8.2', '^8.5', '>=8.5.12', '~8.5.3'):
            self.composer['require']['php'] = value
            with self.assertRaisesRegex(Gate, 'PHP85_MAINTENANCE'): self.audit()

    def test_each_deployment_extension_is_required_in_composer(self):
        for module in DEPLOYMENT_MODULES | {'pdo_mysql'}:
            with self.subTest(module=module):
                previous = self.composer['require'].pop('ext-' + module)
                with self.assertRaisesRegex(Gate, 'COMPOSER_DEPLOYMENT'): self.audit()
                self.composer['require']['ext-' + module] = previous

    def test_missing_curl_policy_rejected(self):
        self.policy['required_modules'].remove('curl')
        with self.assertRaisesRegex(Gate, 'PHP_DEPLOYMENT'): self.audit()

    def test_curl_cannot_be_claimed_as_builtin(self):
        self.policy['required_shared_modules'].remove('curl')
        with self.assertRaisesRegex(Gate, 'CURL_SHARED'): self.audit()

    def test_curl_function_missing_rejected(self):
        self.policy['functions'].remove('curl_init')
        with self.assertRaisesRegex(Gate, 'CURL_SHARED'): self.audit()

    def test_curl_optional_rejected(self):
        self.policy['optional_modules']['curl'] = 'optional'
        with self.assertRaisesRegex(Gate, 'CURL_CANNOT'): self.audit()

    def test_wrong_php_version_or_zts_rejected(self):
        self.policy['php_version'] = '8.5.3'
        with self.assertRaisesRegex(Gate, 'PHP85_NTS'): self.audit()
        self.policy['php_version'] = '8.5.12'; self.policy['thread_safe'] = True
        with self.assertRaisesRegex(Gate, 'PHP85_NTS'): self.audit()

    def test_current_task_has_no_runtime_grant(self):
        self.assertIn('1ade4e5a89116eeba329311ed274229823aafd17', ZERO_TASKS)
        self.assertIn('8b6bd9233a08a7f4d0986d6f592eb114dec63e04', ZERO_TASKS)

    def test_tracked_policy_fail_closed_before_runtime(self):
        with self.assertRaisesRegex(Gate, 'SUPPLY_PENDING'): require_runtime_policy(self.policy)

    def test_changing_state_without_executable_pin_is_not_enough(self):
        self.policy.update(runtime_qualification_state='QUALIFIED_FOR_NEW_OWNER_RUNTIME_TASK', composer_lock_state='RESOLVED')
        with self.assertRaisesRegex(Gate, 'EXECUTABLE_HASH_PENDING'): require_runtime_policy(self.policy)

    def test_unqualified_vc_license_or_version_still_rejected(self):
        self.policy.update(runtime_qualification_state='QUALIFIED_FOR_NEW_OWNER_RUNTIME_TASK', composer_lock_state='RESOLVED', reference_executable_sha256='a'*64)
        with self.assertRaisesRegex(Gate, 'VC_SOURCE_LICENSE_VERSION'): require_runtime_policy(self.policy)

    def test_null_executable_pin_rejected_even_if_manifest_matches_null(self):
        with self.assertRaisesRegex(Gate, 'EXECUTABLE_HASH_PENDING'):
            validate_manifest({}, self.root, self.policy)

    def test_distribution_hash_is_not_executable_hash(self):
        self.assertIsNone(self.policy['reference_executable_sha256'])
        self.assertEqual('2a36a2edcb7a5b9252f638fd5e4cf84d7f6e066092654220dc0b63e5cf4e9723', self.policy['target_distribution']['archive_sha256'])

    def test_composer_source_checksums_bound(self):
        for name, expected in self.policy['source_documents'].items():
            self.assertEqual(expected, digest((self.backend/name).read_bytes()))

    def test_carbon2_lock_is_not_ready(self):
        for item in self.lock['packages']:
            if item['name'] == 'nesbot/carbon': item['version'] = '2.99.0'
        self.assertIn('Carbon 3 lock required', self.audit()['reasons'])

    def test_synthetic_version_match_is_never_solver_or_runtime_proof(self):
        for item in self.lock['packages']:
            if item['name'] == 'laravel/framework': item['version'] = 'v12.0.0'
        self.lock['platform']['php'] = '~8.5.12'
        result = self.audit()
        self.assertEqual('LOCK_VERSION_INPUTS_MATCH_COMPOSER_SOLVER_NOT_PROVEN', result['lock_state'])
        self.assertFalse(result['composer_solver_executed'])
        self.assertFalse(result['target_binary_bytes_verified'])

    def test_inspection_does_not_write_or_launch(self):
        with patch('subprocess.Popen', side_effect=AssertionError('NO_PROCESS')), patch.object(Path, 'write_bytes', side_effect=AssertionError('NO_WRITE')):
            self.audit()

    def test_php_and_python_closed_task_sets_match(self):
        source = (self.backend/'tests/E2E/PhpRuntimeQualification.php').read_text()
        declaration = source.split('public const CLOSED_TASKS = [', 1)[1].split('];', 1)[0]
        import re
        self.assertEqual(ZERO_TASKS, set(re.findall('[a-f0-9]{40}', declaration)))

    def test_cli_and_no_db_qualification_stop_before_manifest_or_launch(self):
        import php_runtime
        with patch('php_runtime.validate_authority', return_value=self.root), patch('php_runtime.validate_probe_authority', return_value=self.root):
            for qualifier in (php_runtime.qualify_config, php_runtime.qualify_probe_config):
                with self.subTest(entry=qualifier.__name__):
                    with self.assertRaisesRegex(Gate, 'SUPPLY_PENDING'):
                        qualifier({}, {'task_blob': '4'*40})

    def test_curl_extension_removal_is_rejected_in_inert_pe_closure(self):
        import test_php_runtime
        fixture = test_php_runtime.PhpRuntimeContracts('test_valid_frozen_inert_manifest_is_static_only')
        fixture.setUp()
        try:
            fixture.manifest['shared_modules'].pop('curl')
            with self.assertRaisesRegex(Gate, 'REQUIRED_MODULE_MISSING'): fixture.validate()
        finally:
            fixture.doCleanups()

    def test_curl_native_dependency_removal_is_rejected(self):
        import test_php_runtime
        fixture = test_php_runtime.PhpRuntimeContracts('test_valid_frozen_inert_manifest_is_static_only')
        fixture.setUp()
        try:
            fixture.manifest['files'] = [x for x in fixture.manifest['files'] if x['path'] != 'bin/libprivate.dll']
            (fixture.runtime/'bin/libprivate.dll').unlink()
            with self.assertRaisesRegex(Gate, 'NATIVE_DEPENDENCY_MISSING'): fixture.validate()
        finally:
            fixture.doCleanups()


if __name__ == '__main__': unittest.main()
