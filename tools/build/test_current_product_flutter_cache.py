import copy
import unittest

import current_product_flutter_cache as c


class FlutterCacheTests(unittest.TestCase):
    def data(self):
        return dict(sdk_git_head='a' * 40, tool_args='', tool_stamp='"' + 'a' * 40 + ':"',
            yaml_mtime_ns=120_000_000_001, lock_mtime_ns=120_000_000_002,
            engine_version='b' * 40, engine_stamp='b' * 40, engine_dart_stamp='b' * 40,
            engine_info_stamp='b' * 40, engine_version_tracked=True, prebuilt_engine_override=None,
            dart_version='3.11.5', version_json={'frameworkRevision': 'a' * 40,
                'engineRevision': 'b' * 40, 'dartSdkVersion': '3.11.5',
                'frameworkVersion': '3.41.7', 'channel': 'stable',
                'repositoryUrl': 'https://github.com/flutter/flutter.git',
                'frameworkCommitDate': '2026-04-15 21:21:08 -0700',
                'devToolsVersion': '2.54.2', 'flutterVersion': '3.41.7'},
            engine_info_json={'git_revision': 'b' * 40, 'content_hash': 'c' * 40})

    def test_static_checks_never_grant_execution(self):
        data = self.data()
        before = copy.deepcopy(data)
        result = c.assess_warm_cache(data)
        self.assertEqual(data, before)
        self.assertIs(result['all_static_checks_supported'], True)
        for name in ['producer_entry_allowed', 'execution_allowed', 'stamp_repaired', 'G2']:
            self.assertIs(result[name], False)

    def test_observed_empty_revision_stamp_remains_rejected(self):
        data = self.data()
        data['tool_stamp'] = '":"'
        self.assertIs(c.assess_warm_cache(data)['checks']['revision_bound_compile_key'], False)
        self.assertEqual(data['tool_stamp'], '":"')

    def test_incomplete_invalid_or_empty_metadata_never_supported(self):
        for key in self.data()['version_json']:
            for value in [None, '', 1]:
                data = self.data()
                data['version_json'][key] = value
                with self.subTest(key=key, value=value):
                    self.assertFalse(c.assess_warm_cache(data)['all_static_checks_supported'])
        for version in [None, [], {}]:
            data = self.data()
            data['version_json'] = version
            self.assertFalse(c.assess_warm_cache(data)['all_static_checks_supported'])
        data = self.data()
        for key in ['engine_version', 'engine_stamp', 'engine_dart_stamp', 'engine_info_stamp']:
            data[key] = ''
        data['version_json']['engineRevision'] = data['engine_info_json']['git_revision'] = ''
        self.assertFalse(c.assess_warm_cache(data)['all_static_checks_supported'])

    def test_engine_override_stamp_and_version_mismatches_remain_visible(self):
        for key, value in [('engine_version_tracked', False), ('prebuilt_engine_override', 'override'),
                           ('engine_dart_stamp', 'wrong'), ('dart_version', 'other')]:
            data = self.data()
            data[key] = value
            self.assertIs(c.assess_warm_cache(data)['all_static_checks_supported'], False)

    def test_bootstrap_minute_timestamp_rule_and_bool_rejection(self):
        data = self.data()
        data['yaml_mtime_ns'], data['lock_mtime_ns'] = 125_000_000_000, 121_000_000_000
        self.assertIs(c.assess_warm_cache(data)['checks']['lock_not_older_than_yaml'], True)
        data['yaml_mtime_ns'] = 180_000_000_000
        self.assertIs(c.assess_warm_cache(data)['checks']['lock_not_older_than_yaml'], False)
        data['lock_mtime_ns'] = True
        with self.assertRaises(ValueError):
            c.assess_warm_cache(data)


if __name__ == '__main__':
    unittest.main()
