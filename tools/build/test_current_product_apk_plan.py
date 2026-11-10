import copy
import unittest

import current_product_apk_plan as p


class ApkPlanTests(unittest.TestCase):
    def setUp(self):
        self.args = dict(identity={'source_commit': p.SOURCE, 'apps_tree': p.APPS, 'services_tree': p.SERVICES},
            configuration={'status': 'CONFIG_GRAPH_BOUNDED_SUPPORTED', 'receipt_sha256': 'a' * 64,
                'proof': {'root_exit': 0, 'stop_reason': None, 'job_final_empty': True, 'all_bound_handles_exited': True}},
            device={'status': 'READONLY_DEVICE_IDENTITY_BOUNDED_SUPPORTED', 'matches_previous_owner_device': True,
                'api': 36, 'abi': 'arm64-v8a', 'target_package': p.PACKAGE, 'target_installed': False,
                'install': 0, 'launch': 0, 'reverse': 0, 'data_clear': 0, 'media': 0, 'actual_builds': 0},
            inventory_sha256='b' * 64)

    def test_plan_does_not_promote_configuration_or_device_evidence(self):
        before = copy.deepcopy(self.args)
        plan = p.make_plan(**self.args)
        self.assertEqual(self.args, before)
        for name in ['execution_allowed', 'install_allowed', 'real_media_allowed', 'G2', 'claim_created', 'old_claims_reused']:
            self.assertIs(plan[name], False)
        self.assertEqual(plan['stages'][1]['task'], ':app:assembleDebug')
        self.assertNotIn(':app:assembleRelease', str(plan))
        self.assertNotIn('serial', str(plan).lower())
        self.assertTrue(plan['stages'][1]['flutter_artifact'].endswith(plan['stages'][0]['publication_version']))
        self.assertEqual(plan['gates']['device_usb_transport'], 'NOT_PROVEN')
        self.args['device']['usb_adb_binding'] = True
        bound = p.make_plan(**self.args)
        self.assertEqual(bound['gates']['device_usb_transport'], 'READONLY_WINDOWS_BINDING_SUPPORTED')
        self.assertIs(bound['install_allowed'], False)
        self.args['inventory_sha256'] = 'c' * 64
        different = p.make_plan(**self.args)
        self.assertNotEqual(plan['stages'][0]['publication_version'], different['stages'][0]['publication_version'])
        self.assertIs(different['execution_allowed'], False)

    def test_configuration_safety_stop_or_unknown_exit_cannot_seed_a_plan(self):
        for key, value in [('root_exit', False), ('root_exit', 1), ('stop_reason', 'STOP'),
                           ('job_final_empty', False), ('all_bound_handles_exited', None)]:
            args = copy.deepcopy(self.args)
            args['configuration']['proof'][key] = value
            with self.assertRaises(ValueError):
                p.make_plan(**args)
        self.args['configuration']['status'] = 'CONFIG_GRAPH_SELECTS_DOCUMENTATION_TASK'
        with self.assertRaises(ValueError):
            p.make_plan(**self.args)

    def test_old_source_or_unbound_evidence_is_rejected(self):
        for field in ['source_commit', 'apps_tree', 'services_tree']:
            args = copy.deepcopy(self.args)
            args['identity'][field] = 'c' * 40
            with self.assertRaises(ValueError):
                p.make_plan(**args)
        self.args['inventory_sha256'] = 'unknown'
        with self.assertRaises(ValueError):
            p.make_plan(**self.args)

    def test_wrong_device_profile_and_device_writes_are_rejected(self):
        for key, value in [('matches_previous_owner_device', False), ('abi', 'x86_64'), ('api', True),
                           ('api', 25), ('target_package', 'com.elitesync'), ('target_installed', 0),
                           ('install', 1), ('media', True)]:
            args = copy.deepcopy(self.args)
            args['device'][key] = value
            with self.assertRaises(ValueError):
                p.make_plan(**args)


if __name__ == '__main__':
    unittest.main()
