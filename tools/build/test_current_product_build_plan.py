import unittest

from current_product_build_plan import LEGACY_G2_SOURCE, make_plan, validate_plan


class CurrentProductBuildPlanTests(unittest.TestCase):
    def plan(self):
        return make_plan(source_commit='a' * 40, apps_tree='b' * 40, services_tree='c' * 40,
                         stock_flutter=r'D:\flutter', source_pub=r'C:\InputsHost\pub',
                         tooling_snapshot=r'C:\InputsHost\tooling', old_seed=r'C:\InputsHost\seed')

    def test_valid_plan_describes_layout_without_execution_authority(self):
        plan = self.plan()
        validate_plan(plan)
        self.assertIs(plan['execution_allowed'], False)
        self.assertEqual(plan['new_runtime_budget'], 'UNKNOWN')
        self.assertNotEqual(plan['guard_conflict']['stock_tooling'], plan['guard_conflict']['private_tooling'])

    def test_code_identity_must_be_exact_and_distinct_from_legacy_source(self):
        for value in ['a' * 39, 'A' * 40, 'z' * 40, None, LEGACY_G2_SOURCE]:
            plan = self.plan()
            plan['source_identity']['source_commit'] = value
            with self.assertRaises(ValueError):
                validate_plan(plan)

    def test_ambiguous_or_redirect_style_paths_are_rejected(self):
        for value in [r'\\server\share\sdk', r'\\?\C:\sdk', r'C:sdk', 'C:\\',
                      r'C:\safe\..\sdk', r'C:\safe\.\sdk', r'C:\safe\sdk:stream',
                      r'C:\safe\sdk.', r'C:\safe\%SDK%', r'C:\safe\PROGRA~1', r'C:\safe\NUL']:
            plan = self.plan()
            plan['readonly_inputs']['stock_flutter']['host'] = value
            with self.assertRaises(ValueError, msg=value):
                validate_plan(plan)

    def test_readonly_inputs_cannot_be_writable_or_pseudo_boolean(self):
        for role in ['stock_flutter', 'source_pub', 'tooling_snapshot', 'old_seed']:
            for value in [False, 1, 'true', None]:
                plan = self.plan()
                plan['readonly_inputs'][role]['readonly'] = value
                with self.assertRaises(ValueError):
                    validate_plan(plan)

    def test_runtime_or_old_claim_authority_cannot_be_inferred(self):
        for key in ['execution_allowed', 'G2', 'old_claims_reused']:
            for value in [True, 0, 'false', None]:
                plan = self.plan()
                plan[key] = value
                with self.assertRaises(ValueError):
                    validate_plan(plan)
        plan = self.plan()
        plan['new_runtime_budget'] = 'AVAILABLE'
        with self.assertRaises(ValueError):
            validate_plan(plan)

    def test_cmake_staging_cannot_use_a_build_directory(self):
        plan = self.plan()
        plan['private_paths']['jni_staging'] = r'C:\BuildWork\Project\build\.cxx'
        with self.assertRaisesRegex(ValueError, 'CMake staging'):
            validate_plan(plan)

    def test_writable_home_cannot_share_input_or_output_roots(self):
        for value in [r'C:\Inputs\Flutter\state', r'C:\BuildWork\Tooling',
                      r'C:\BuildWork\Project\apps\flutter_elitesync_module\.android\cache',
                      r'C:\InputsHost\seed\writable']:
            plan = self.plan()
            plan['private_paths']['gradle_home'] = value
            with self.assertRaises(ValueError):
                validate_plan(plan)

    def test_seed_base_and_old_source_cannot_be_silently_rewritten(self):
        for key, value in [('seed_modules_root', r'C:\Inputs\DependencyCache\caches\modules-2')]:
            plan = self.plan()
            plan[key] = value
            with self.assertRaises(ValueError):
                validate_plan(plan)
        plan = self.plan()
        plan['legacy_g2']['source_commit'] = 'd' * 40
        with self.assertRaises(ValueError):
            validate_plan(plan)

    def test_guard_path_conflict_cannot_be_waived(self):
        for key, value in [('private_tooling', r'C:\Inputs\Flutter\packages\flutter_tools\gradle'),
                           ('path_identity_differs', False), ('original_guard_conflict_preserved', 1)]:
            plan = self.plan()
            plan['guard_conflict'][key] = value
            with self.assertRaises(ValueError):
                validate_plan(plan)

    def test_overlapping_host_inputs_are_rejected(self):
        plan = self.plan()
        plan['readonly_inputs']['tooling_snapshot']['host'] = r'D:\flutter\packages\flutter_tools'
        with self.assertRaisesRegex(ValueError, 'overlap'):
            validate_plan(plan)

    def test_extra_command_or_execution_fields_are_rejected(self):
        plan = self.plan()
        plan['command'] = ['gradle', 'assembleAarRelease']
        with self.assertRaises(ValueError):
            validate_plan(plan)
        plan = self.plan()
        plan['readonly_inputs']['stock_flutter']['command'] = ['gradle']
        with self.assertRaises(ValueError):
            validate_plan(plan)

    def test_malformed_nested_sections_are_rejected_as_data_errors(self):
        for key in ['source_identity', 'readonly_inputs', 'private_paths', 'legacy_g2', 'guard_conflict']:
            plan = self.plan()
            plan[key] = None
            with self.assertRaises(ValueError):
                validate_plan(plan)


if __name__ == '__main__':
    unittest.main()
