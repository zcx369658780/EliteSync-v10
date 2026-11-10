import hashlib
import json
import subprocess
import unittest
from unittest.mock import patch

import producer_boundary_binding as binding
from sandbox_owned_session_cleanup import windows_arguments
import current_product_local_entry as local


def fixture():
    return {
        'source_identity': {'source_commit': 'fixture'},
        'publication_version': 'fixture-version',
        'inherit_environment': False,
        'stage1': {
            'argv': ['C:/Inputs/Jdk/bin/java.exe',
                     '-Duser.home=C:/BuildWork/Home',
                     '-javaagent:C:/Inputs/Gradle/lib/agent.jar',
                     '-Ptarget=lib/main.dart', '-Ptarget-platform=android-arm64',
                     '-Pdart-defines=Zml4dHVyZT10cnVl',
                     '-Dquoted=a "quoted value" with trailing slash\\',
                     '--offline', '--no-daemon', '--max-workers=1',
                     'assembleAarRelease'],
            'working_directory': 'C:/BuildWork/Project/.android'},
        'environment': {'PATH': 'C:/Inputs/Jdk/bin;C:/Windows/System32',
                        'ANDROID_HOME': 'C:/Inputs/AndroidSdk',
                        'GRADLE_RO_DEP_CACHE': 'C:/Inputs/ReadOnlySeed'},
        'overlays': {'helper.kt': 'require(root == "C:/BuildWork/Flutter")'},
        'gradle_properties': 'org.gradle.java.home=C:/Inputs/Jdk\n',
    }


REPLACEMENTS = {
    'C:/BuildWork': 'D:/Private Work',
    'C:/Inputs/Jdk': 'E:/Tools/Java Home',
    'C:/Inputs/Gradle': 'E:/Tools/Gradle',
    'C:/Inputs/AndroidSdk': 'E:/Tools/Android SDK',
    'C:/Inputs/ReadOnlySeed': 'E:/Seed',
}


class LocalEntryTests(unittest.TestCase):
    def render(self, entry=None, replacements=None, init=None):
        raw = json.dumps(fixture() if entry is None else entry).encode()
        with patch.object(binding, 'ENTRY_SHA256', hashlib.sha256(raw).hexdigest()):
            return local.render_local_entry(
                raw, b'fixture-boundary',
                REPLACEMENTS if replacements is None else replacements,
                "new File('C:/BuildWork/output')" if init is None else init)

    def test_command_roundtrip_and_fixed_arguments(self):
        result = self.render()
        self.assertEqual(result['argv'], windows_arguments(result['launch_request']['command_line']))
        self.assertEqual(result['launch_request']['command_line'], subprocess.list2cmdline(result['argv']))
        self.assertEqual(result['argv'][0], 'E:/Tools/Java Home/bin/java.exe')
        self.assertIn('-javaagent:E:/Tools/Gradle/lib/agent.jar', result['argv'])
        self.assertEqual(result['launch_request']['cwd'], r'D:\Private Work\Project\.android')
        for arg in fixture()['stage1']['argv'][3:]:
            self.assertIn(arg, result['argv'])
        self.assertEqual(result['argv'][-1], 'assembleAarRelease')
        self.assertIn('D:/Private Work/Control/producer-output.init.gradle', result['argv'])
        self.assertFalse(result['inherit_environment'])
        self.assertEqual(set(result['launch_request']['environment']), set(fixture()['environment']))
        self.assertEqual(result['source_identity'], fixture()['source_identity'])
        self.assertEqual(result['publication_version'], fixture()['publication_version'])
        self.assertIn('D:/Private Work/Flutter', result['overlays']['helper.kt'])
        self.assertIn('E:/Tools/Java Home', result['gradle_properties'])
        self.assertIn('D:/Private Work/output', result['output_init'])

    def test_nested_json_uri_and_windows_paths(self):
        original = {'packages': [{'rootUri': 'file:///C:/Inputs/PubPackages/one%20pkg/lib/'},
                                 {'rootUri': r'C:\Inputs\PubPackages\one pkg\lib'}],
                    'url': 'https://host/C:/Inputs/PubPackages/one%20pkg',
                    'query_url': 'https://host/?path=C:/Inputs/PubPackages/one%20pkg',
                    'other_path': r'D:\Keep This\unchanged',
                    'relative': '../one pkg', 'count': 2, 'flag': True}
        mapped = json.loads(local.remap_json(json.dumps(original).encode(),
                            {'C:/Inputs/PubPackages/one pkg': 'E:/My Packages/one#pkg'}))
        self.assertEqual(mapped['packages'][0]['rootUri'], 'file:///E:/My%20Packages/one%23pkg/lib/')
        self.assertEqual(mapped['packages'][1]['rootUri'], 'E:/My Packages/one#pkg/lib')
        self.assertEqual(mapped['url'], original['url'])
        self.assertEqual(mapped['query_url'], original['query_url'])
        self.assertEqual(mapped['other_path'], original['other_path'])
        self.assertEqual(mapped['relative'], original['relative'])
        self.assertEqual(mapped['count'], 2)
        self.assertTrue(mapped['flag'])

    def test_longest_prefix_and_component_boundaries(self):
        paths = ['C:/Inputs/PubPackages/pub_package_10/a',
                 'C:/Inputs/PubPackages/pub_package_1/a',
                 'C:/Inputs/PubPackages/pub_package_100/a']
        replacements = {'C:/Inputs/PubPackages/pub_package_1': 'E:/One',
                        'C:/Inputs/PubPackages': 'E:/All',
                        'C:/Inputs/PubPackages/pub_package_10': 'E:/Ten'}
        self.assertEqual(json.loads(local.remap_json(json.dumps(paths).encode(), replacements)),
                         ['E:/Ten/a', 'E:/One/a', 'E:/All/pub_package_100/a'])

    def test_unmapped_guest_paths_are_rejected_everywhere(self):
        for name in ('stage1', 'environment', 'overlays', 'gradle_properties'):
            obj = fixture()
            if name == 'stage1':
                obj[name]['argv'].insert(1, '-Dmiss=C:/Inputs/Unknown')
            elif name == 'environment':
                obj[name]['MISSING'] = r'C:\Inputs\Unknown'
            elif name == 'overlays':
                obj[name]['bad.kt'] = '"C:/Inputs/Unknown"'
            else:
                obj[name] += 'missing=C:/Inputs/Unknown\n'
            with self.subTest(name=name), self.assertRaisesRegex(ValueError, 'guest'):
                self.render(obj)
        with self.assertRaisesRegex(ValueError, 'guest'):
            self.render(init="new File('C:/Inputs/Unknown')")
        with self.assertRaisesRegex(ValueError, 'guest'):
            local.remap_json(b'{"rootUri":"file:///C:/Inputs/Unknown/"}', REPLACEMENTS)

    def test_pinned_entry_validation_is_not_bypassed(self):
        with self.assertRaisesRegex(ValueError, 'exact source-only'):
            local.render_local_entry(b'{}', b'fixture', REPLACEMENTS, '')

    def test_invalid_or_ambiguous_mapping_is_rejected(self):
        for replacements in ({'C:/BuildWork': 'relative'},
                             {'C:/BuildWork': 'C:/Inputs/Other'},
                             {'C:/BuildWork': 'D:/A', 'c:\\buildwork': 'D:/B'}):
            with self.subTest(replacements=replacements), self.assertRaises(ValueError):
                self.render(replacements=replacements)


if __name__ == '__main__':
    unittest.main()
