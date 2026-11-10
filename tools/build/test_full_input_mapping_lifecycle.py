from unittest.mock import patch
import copy
from pathlib import Path
import sys
import tempfile
import types
import unittest

import full_input_mapping_lifecycle as lifecycle


class LifecycleCandidateTests(unittest.TestCase):
    def source_fixture(self, root):
        py, cs = lifecycle.generate_sources((lifecycle.HERE / 'full_input_mapping_probe.py').read_bytes(),
            (lifecycle.HERE / 'full_input_mapping_probe.cs').read_bytes())
        files = {'full_input_mapping_probe.py': py, 'full_input_mapping_probe.cs': cs}
        files.update({name: (lifecycle.HERE / name).read_bytes() for name in lifecycle.HELPERS})
        for name, raw in files.items(): (root / name).write_bytes(raw)
        return files

    def test_source_generation_only_changes_the_fixed_scope_literal(self):
        py = (lifecycle.HERE / 'full_input_mapping_probe.py').read_bytes()
        cs = (lifecycle.HERE / 'full_input_mapping_probe.cs').read_bytes()
        generated_py, generated_cs = lifecycle.generate_sources(py, cs)
        for original, generated in [(py, generated_py), (cs, generated_cs)]:
            self.assertEqual(generated.count(lifecycle.SCOPE.encode()), 1)
            self.assertNotIn(lifecycle.OLD_SCOPE.encode(), generated)
            self.assertEqual(generated.replace(lifecycle.SCOPE.encode(), lifecycle.OLD_SCOPE.encode(), 1), original)
        with self.assertRaises(ValueError): lifecycle.generate_sources(py + b'\n', cs)

    def test_new_grant_is_required_before_any_frozen_or_process_operation(self):
        for authority, reference in [(False, 'owner'), (1, 'owner'), (None, 'owner'), (True, ''), (True, None)]:
            with self.subTest(authority=authority), patch.object(lifecycle, 'frozen') as frozen:
                with self.assertRaises(ValueError): lifecycle.launch(new_scope_authorized=authority, owner_reference=reference)
                frozen.assert_not_called()

    def test_any_generated_source_drift_rejects_before_code_execution(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            files = self.source_fixture(root)
            for name, raw in files.items():
                (root / name).write_bytes(raw + b'\n# drift')
                with self.subTest(name=name), patch.object(lifecycle, 'SOURCES', root), patch.object(lifecycle, '_execute_sources') as execute:
                    with self.assertRaises(ValueError): lifecycle._load_base()
                    execute.assert_not_called()
                (root / name).write_bytes(raw)

    def test_verified_helper_objects_do_not_come_from_sys_modules(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            self.source_fixture(root)
            fake = types.ModuleType('polluted')
            fake.inventory_files = lambda *args: 'unverified'
            fake._path = lambda *args: 'unverified'
            with patch.object(lifecycle, 'SOURCES', root), patch.dict(sys.modules, {
                'current_product_apk_inventory': fake, 'current_product_build_plan': fake}):
                module = lifecycle._load_base()
                self.assertIsNot(module.inventory_files, fake.inventory_files)
                self.assertEqual(module.inventory_files.__code__.co_filename, str(root / 'current_product_apk_inventory.py'))
                self.assertEqual(module._path.__code__.co_filename, str(root / 'current_product_build_plan.py'))

    def test_empty_or_missing_pin_sets_and_promoted_contract_rejected(self):
        contract = {'scope': lifecycle.SCOPE, 'status': 'PROPOSED_NOT_AUTHORIZED', 'max_launches': 1,
            'owner_scope_grant_pending': True, 'old_scope': lifecycle.OLD_SCOPE, 'old_remaining': 0,
            'readonly_roots': 273, 'read_anchors': 275, 'readonly_access_checks': 2457, 'owned_write_roots': 2,
            'host_lifecycle_change': 'EXACT_CONFIG_PARENT_BIRTH_AND_HELD_HANDLE_PAIR_CLEANUP',
            'SDK_allowed': False, 'producer_allowed': False, 'device_media_allowed': False, 'G2': False,
            'source_pins': {path: 'a' * 64 for path in lifecycle.required_pins()}}
        lifecycle.validate_contract(contract)
        for change in [('source_pins', {}), ('old_remaining', True), ('max_launches', 2), ('readonly_access_checks', 1365)]:
            bad = copy.deepcopy(contract); bad[change[0]] = change[1]
            with self.subTest(change=change), self.assertRaises(ValueError): lifecycle.validate_contract(bad)
        bad = copy.deepcopy(contract); bad['source_pins'].pop(next(iter(bad['source_pins'])))
        with self.assertRaises(ValueError): lifecycle.validate_contract(bad)

    def test_wait_cannot_load_generated_code_before_new_authorization(self):
        with tempfile.TemporaryDirectory() as temp, patch.object(lifecycle, 'ROOT', Path(temp)), patch.object(lifecycle, 'frozen') as frozen:
            with self.assertRaises(FileNotFoundError): lifecycle.wait_and_collect()
            frozen.assert_not_called()


if __name__ == '__main__':
    unittest.main()
