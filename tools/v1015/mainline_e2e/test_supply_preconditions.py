"""Synthetic facts only; no acquisition, extraction, PHP, Composer or business run."""
import copy
import io
import json
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import patch
from contracts import Gate
from migration_contract import require_runtime_policy
from supply_preconditions import check_supply_only_facts, inspect_policy, NATIVE_PROOFS, TASK, PARENT, APPS


class SupplyFacts(unittest.TestCase):
    def setUp(self):
        self.policy = json.loads(Path(__file__).with_name('php_requirements.json').read_bytes())
        # This is the ended supplier contract's synthetic frozen input, not a new grant.
        self.policy['candidate_parent'] = PARENT
        self.config = dict(scripts=False, plugins=False, business_bootstrap=False,
                           metadata_origin='https://repo.packagist.org',
                           registered_distribution_sources_only=True, automatic_redirects=False)
        self.grant = dict(owner_authorized=True, task_blob=TASK, action='SUPPLY_ONLY_COMPOSER',
                          parent=PARENT, apps_tree=APPS, http_requests=240,
                          download_bytes=268435456, resolution_attempts=2, vendor_installs=1)
        self.proof = dict(php_archive_verified=True,
                          php_executable_sha256=self.policy['reference_executable_sha256'],
                          native_closure_qualified=True, composer_phar_source_qualified=True,
                          composer_phar_sha256='b'*64, **{k: 'a'*64 for k in NATIVE_PROOFS})

    def check(self):
        return check_supply_only_facts(self.config, self.grant, self.proof, self.policy)

    def test_synthetic_supplier_does_not_require_an_existing_laravel12_lock(self):
        self.assertEqual('LOCK_RESOLUTION_PENDING', self.policy['composer_lock_state'])
        result = self.check()
        self.assertFalse(result['resolved_lock_required'])
        self.assertFalse(result['process_started'])
        self.assertFalse(result['runtime_authorized_by_this_check'])

    def test_no_owner_or_wrong_action_rejected(self):
        self.grant['owner_authorized'] = False
        with self.assertRaisesRegex(Gate, 'OWNER_SCOPE'): self.check()
        self.grant['owner_authorized'] = True; self.grant['action'] = 'mainline_api_db_e2e'
        with self.assertRaisesRegex(Gate, 'OWNER_SCOPE'): self.check()

    def test_wrong_parent_rejected(self):
        self.grant['parent'] = '1'*40
        with self.assertRaisesRegex(Gate, 'SOURCE_BINDING'): self.check()

    def test_every_native_proof_is_required(self):
        for name in NATIVE_PROOFS:
            previous = self.proof.pop(name)
            with self.subTest(name=name):
                with self.assertRaisesRegex(Gate, 'NATIVE_LICENSE'): self.check()
            self.proof[name] = previous

    def test_known_executable_is_not_a_complete_native_closure(self):
        self.proof['native_closure_qualified'] = False
        with self.assertRaisesRegex(Gate, 'NATIVE_LICENSE'): self.check()

    def test_unsigned_unproven_composer_source_rejected(self):
        self.proof['composer_phar_source_qualified'] = False
        with self.assertRaisesRegex(Gate, 'COMPOSER_SOURCE'): self.check()

    def test_archive_hash_cannot_substitute_for_executable(self):
        self.proof['php_executable_sha256'] = self.policy['target_distribution']['archive_sha256']
        with self.assertRaisesRegex(Gate, 'PHP_BYTES'): self.check()

    def test_scripts_plugins_and_bootstrap_rejected(self):
        for name in ('scripts', 'plugins', 'business_bootstrap'):
            self.config[name] = True
            with self.subTest(name=name):
                with self.assertRaisesRegex(Gate, 'FORBIDDEN'): self.check()
            self.config[name] = False

    def test_database_config_is_not_a_supply_input(self):
        self.config['database'] = 'SYNTHETIC_DB_NAME'
        with self.assertRaisesRegex(Gate, 'DB_API_CONFIGURATION'): self.check()

    def test_unregistered_host_or_auto_redirect_rejected(self):
        self.config['metadata_origin'] = 'https://untrusted.invalid'
        with self.assertRaisesRegex(Gate, 'SOURCE_HOST'): self.check()
        self.config['metadata_origin'] = 'https://repo.packagist.org'; self.config['automatic_redirects'] = True
        with self.assertRaisesRegex(Gate, 'SOURCE_HOST'): self.check()

    def test_each_exceeded_or_boolean_budget_rejected(self):
        for name in ('http_requests', 'download_bytes', 'resolution_attempts', 'vendor_installs'):
            previous = self.grant[name];self.grant[name] = previous+1
            with self.subTest(name=name):
                with self.assertRaisesRegex(Gate, 'BUDGET'): self.check()
            self.grant[name] = previous
        self.grant['http_requests'] = True
        with self.assertRaisesRegex(Gate, 'BUDGET'): self.check()

    def test_current_policy_still_blocks_business_runtime(self):
        with self.assertRaisesRegex(Gate, 'SUPPLY_PENDING'): require_runtime_policy(self.policy)

    def test_default_inspection_has_no_process_or_write(self):
        import supply_preconditions
        output=io.StringIO()
        with patch('subprocess.Popen', side_effect=AssertionError('NO_PROCESS')), patch.object(Path, 'write_bytes', side_effect=AssertionError('NO_WRITE')), redirect_stdout(output):
            supply_preconditions.main()
        self.assertEqual('NOT_RUN_GATE_CLOSED', json.loads(output.getvalue())['runtime'])


if __name__ == '__main__':
    unittest.main()
