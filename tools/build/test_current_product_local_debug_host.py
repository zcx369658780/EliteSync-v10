import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import zipfile

import current_product_local_debug_host as host
from current_product_tree_inventory import inventory_trees
from test_current_product_aar_handoff import GROUP, ARTIFACT, VERSION


class LocalDebugHostTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.case = self.base / 'aar-case'
        (self.case / 'control').mkdir(parents=True)
        (self.case / 'output').mkdir()
        self.work = self.case / 'work'
        (self.work / 'AndroidSdk/platforms/android-36').mkdir(parents=True)
        (self.work / 'AndroidSdk/platforms/android-36/sdk-file').write_bytes(b'sdk fixture')
        self.repo = self.work / 'AarOutput/outputs/repo'
        module = self.repo / GROUP.replace('.', '/') / ARTIFACT / VERSION
        module.mkdir(parents=True)
        (module / f'{ARTIFACT}-{VERSION}.pom').write_text(
            f'<project><groupId>{GROUP}</groupId><artifactId>{ARTIFACT}</artifactId>'
            f'<version>{VERSION}</version><packaging>aar</packaging></project>')
        elf = bytearray(64)
        elf[:6], elf[18:20] = b'\x7fELF\x02\x01', (183).to_bytes(2, 'little')
        with zipfile.ZipFile(module / f'{ARTIFACT}-{VERSION}.aar', 'w') as archive:
            for name, content in [('AndroidManifest.xml', b'manifest'), ('classes.jar', b'classes'),
                                  ('jni/arm64-v8a/libapp.so', elf)]:
                archive.writestr(name, content)
        self.inputs = self.base / 'external'
        self.inputs.mkdir()
        for name in ['jdk/bin/java.exe', 'gradle/lib/agents/agent.jar', 'gradle/lib/cli.jar', 'cache/cache-file']:
            (self.inputs / name).parent.mkdir(parents=True, exist_ok=True)
            (self.inputs / name).write_bytes(b'fixture')
        put = host.local.shared.put
        inv = self.inventory({'local_work': str(self.work)})
        put(self.case / 'control/prepared-work-inventory.json', inv)
        put(self.case / 'control/external-inputs.json', self.inventory({'external': str(self.inputs)})['files'])
        self.contract = dict(kind='current-product-local-aar-producer', host_root=str(self.case),
            work_root=str(self.work), repository=str(self.repo), nonce='a'*32, publication_version=VERSION,
            source_identity={'source_commit': 'fixture'},
            work_inventory_sha256=host.local.shared.sha(self.case / 'control/prepared-work-inventory.json'),
            external_inventory_sha256=host.local.shared.sha(self.case / 'control/external-inputs.json'),
            launch_request=dict(command_line=subprocess.list2cmdline([
                str(self.inputs/'jdk/bin/java.exe'), '-javaagent:'+str(self.inputs/'gradle/lib/agents/agent.jar'),
                '-jar', str(self.inputs/'gradle/lib/cli.jar'), 'assembleAarRelease']), environment={
                'JAVA_HOME': str(self.inputs/'jdk'), 'SystemRoot': 'C:/Windows', 'WINDIR': 'C:/Windows',
                'GRADLE_RO_DEP_CACHE': str(self.inputs/'cache'), 'FLUTTER_ROOT': str(self.work/'Flutter'),
                'PUB_CACHE': str(self.work/'PubCache')}))
        put(self.case / 'control/run-contract.json', self.contract)
        grant_path = self.case / 'control/owner-grant.json'
        put(grant_path, dict(authorized=True, max_attempts=1,
            contract_sha256=host.local.shared.sha(self.case/'control/run-contract.json')))
        claim = dict(attempt=1, contract_sha256=host.local.shared.sha(self.case/'control/run-contract.json'),
                     grant_sha256=host.local.shared.sha(grant_path))
        put(self.case/'launch.claim.json', claim)
        put(self.case/'control/launch.claim.json', claim)
        put(self.case / 'output/result.json', dict(nonce='a'*32,
            status='LOCAL_AAR_ROOT_EXIT0_REPOSITORY_UNVERIFIED', root_exit=0,
            repository=str(self.repo)))
        android = self.base / 'tracked-android'
        (android / 'app').mkdir(parents=True)
        source = host.local.HERE.parents[1] / 'apps/android'
        for name in ['app/build.gradle.kts', 'settings.gradle.kts', 'gradle.properties']:
            (android/name).write_bytes((source/name).read_bytes())
        self.android_inventory = self.base / 'android-inventory.json'
        put(self.android_inventory, self.inventory({'android': str(android)}))
        self.root = self.base / 'debug-host'

    def inventory(self, roots):
        return inventory_trees(roots=roots, file_limit=1000, entry_limit=2000,
                               byte_limit=1000000, depth_limit=32)

    def compile_fixture(self, argv, **kwargs):
        executable = next(value[5:] for value in argv if value.startswith('/out:'))
        Path(executable).write_bytes(b'fake controller, never executed')
        return subprocess.CompletedProcess(argv, 0, b'fixture compile only', b'')

    def prepare(self):
        with patch.object(host.local, 'current_user', return_value='fixture-user'), \
             patch.object(host.local.subprocess, 'run', side_effect=self.compile_fixture):
            return host.prepare(self.root, self.case, self.android_inventory)

    def test_prepare_binds_private_apk_kind_inputs_and_offline_command(self):
        contract = self.prepare()
        self.assertEqual(contract['kind'], 'current-product-local-debug-host')
        self.assertNotIn('repository', contract)
        self.assertEqual(contract['apk_output'], str(self.root/'work/ApkOutput'))
        self.assertEqual((contract['sdk_seconds'], contract['host_seconds'], contract['cleanup_seconds']),
                         (1800, 2100, 45))
        self.assertEqual(contract['job_memory_bytes'], 4*1024**3)
        self.assertEqual(contract['required_available_mib'], 5120)
        self.assertIs(contract['serial_build'], True)
        self.assertEqual(contract['output_bytes'], 2*1024**3)
        args = host.windows_arguments(contract['launch_request']['command_line'])
        self.assertIn('--offline', args)
        self.assertEqual(args[-1], ':app:assembleDebug')
        self.assertFalse(any('assembleAar' in value or 'flutter-root' in value for value in args))
        self.assertNotIn('FLUTTER_ROOT', contract['launch_request']['environment'])
        self.assertNotIn('PUB_CACHE', contract['launch_request']['environment'])
        self.assertFalse((self.root/'work/Flutter').exists())
        self.assertFalse((self.root/'launch.claim.json').exists())
        self.assertFalse((self.root/'control/owner-grant.json').exists())
        app = (self.root/'work/AndroidHost/app/build.gradle.kts').read_text(encoding='utf-8')
        self.assertNotIn('Exec::class', app)
        self.assertIn('ndkVersion = "28.2.13676358"', app)
        self.assertIn((self.root/'VerifiedAarRepository').as_posix(), app)
        self.assertTrue(any(Path(name).name == 'current_product_local_debug_host.py'
                            for name in contract['host_helpers']))
        host.local._check_rows(json.loads((self.root/'control/prepared-work-inventory.json').read_bytes())['files'])

    def test_controller_has_distinct_apk_authority_and_result_semantics(self):
        self.prepare()
        controller = (self.root/'control/local_debug_host_supervisor.cs').read_text()
        self.assertIn('"current-product-local-debug-host"', controller)
        self.assertIn('LOCAL_DEBUG_HOST_ROOT_EXIT0_APK_UNVERIFIED', controller)
        self.assertIn('apk_output=(string)contract["apk_output"]', controller)
        self.assertNotIn('LOCAL_AAR_ROOT_EXIT0', controller)
        boundary = (self.root/'control/local-boundary.cs').read_text()
        self.assertIn('ActiveProcessLimit=64', boundary)
        self.assertIn('4UL*1024*1024*1024', boundary)
        self.assertIn('AssignProcessToJobObject', boundary)

    def test_source_drift_rejects_and_preserves_partial_candidate(self):
        data = json.loads(self.android_inventory.read_bytes())
        Path(data['roots']['android'], 'app/build.gradle.kts').write_text('drift')
        with self.assertRaises(ValueError):
            self.prepare()
        self.assertTrue(self.root.exists())
        self.assertFalse((self.root/'prepared.json').exists())
        self.assertFalse((self.root/'launch.claim.json').exists())

    def test_wrong_aar_result_rejects_without_candidate_or_compile(self):
        result = self.case/'output/result.json'
        data = json.loads(result.read_bytes()); data['nonce'] = 'wrong'
        result.write_text(json.dumps(data))
        with self.assertRaises(ValueError):
            self.prepare()
        self.assertFalse(self.root.exists())

    def test_existing_candidate_is_preserved(self):
        self.root.mkdir(); (self.root/'keep').write_bytes(b'preserve')
        with self.assertRaises(FileExistsError):
            self.prepare()
        self.assertEqual((self.root/'keep').read_bytes(), b'preserve')

    def test_changed_source_grant_cannot_prepare_host(self):
        grant_path = self.case/'control/owner-grant.json'
        grant = json.loads(grant_path.read_bytes()); grant['max_attempts'] = 2
        grant_path.write_text(json.dumps(grant))
        with self.assertRaisesRegex(ValueError, 'grant and consumed claim'):
            self.prepare()
        self.assertFalse(self.root.exists())

    def test_launch_delegates_to_shared_local_controller(self):
        with patch.object(host.local, 'launch', return_value={'fixture': True}) as launch:
            self.assertEqual(host.launch(self.root), {'fixture': True})
            launch.assert_called_once_with(self.root)


if __name__ == '__main__':
    unittest.main()
