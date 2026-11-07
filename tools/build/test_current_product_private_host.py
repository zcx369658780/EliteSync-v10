from pathlib import Path
import hashlib
import tempfile
import unittest
import zipfile
from unittest.mock import patch

import current_product_private_host as host
from test_current_product_aar_handoff import GROUP, ARTIFACT, VERSION


class PrivateHostTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / 'repo $local __FILES__'
        module = self.repo / GROUP.replace('.', '/') / ARTIFACT / VERSION
        module.mkdir(parents=True)
        (module / f'{ARTIFACT}-{VERSION}.pom').write_text(f'''<project><groupId>{GROUP}</groupId>
<artifactId>{ARTIFACT}</artifactId><version>{VERSION}</version><packaging>aar</packaging></project>''')
        elf = bytearray(64)
        elf[:6], elf[18:20] = b'\x7fELF\x02\x01', (183).to_bytes(2, 'little')
        with zipfile.ZipFile(module / f'{ARTIFACT}-{VERSION}.aar', 'w') as archive:
            archive.writestr('AndroidManifest.xml', b'manifest')
            archive.writestr('classes.jar', b'classes')
            archive.writestr('jni/arm64-v8a/libapp.so', bytes(elf))
        source = Path(__file__).resolve().parents[2] / 'apps' / 'android'
        self.app = (source / 'app' / 'build.gradle.kts').read_text(encoding='utf-8')
        self.settings = (source / 'settings.gradle.kts').read_text(encoding='utf-8')

    def render(self, app=None, **options):
        return host.render_private_host(self.app if app is None else app, self.settings,
                                         str(self.repo), VERSION, file_limit=100, byte_limit=100000,
                                         **options)

    def test_local_repository_uses_verified_absolute_path_in_both_files(self):
        result = self.render(local_repository=True)
        expected = self.repo.resolve().as_posix()
        literal = '"' + expected.replace('$', '\\$') + '"'
        self.assertIn('rootProject.file(' + literal + ').toPath()', result['app_gradle'])
        self.assertIn('url = uri(' + literal + ')', result['settings_gradle'])
        self.assertNotIn(host.GUEST_REPOSITORY, result['app_gradle'])
        self.assertNotIn(host.GUEST_REPOSITORY, result['settings_gradle'])
        self.assertEqual(result['repository_mode'], 'LOCAL')
        self.assertEqual(result['rendered_repository'], expected)
        self.assertIsNone(result['guest_repository'])
        self.assertEqual(result['runtime_consumption'], 'NOT_RUN')
        self.assertIs(result['execution_allowed'], False)
        self.assertIs(result['readonly_guest_mapping_proven'], False)
        self.assertIs(result['G2'], False)

    def test_guest_default_and_explicit_false_preserve_guest_output(self):
        result = self.render()
        self.assertEqual(result, self.render(local_repository=False))
        self.assertIn('rootProject.file("' + host.GUEST_REPOSITORY + '")', result['app_gradle'])
        self.assertIn('url = uri("' + host.GUEST_REPOSITORY + '")', result['settings_gradle'])
        self.assertEqual(result['guest_repository'], host.GUEST_REPOSITORY)
        self.assertEqual(result['repository_mode'], 'GUEST')
        self.assertEqual(result['rendered_repository'], host.GUEST_REPOSITORY)

    def test_private_copy_binds_real_manifest_coordinate_and_rechecks_bytes(self):
        result = self.render()
        app, settings = result['app_gradle'], result['settings_gradle']
        self.assertIn('debugImplementation("' + result['coordinate'] + '")', app)
        self.assertIn('verifyPrivateFlutterRepository()', app)
        self.assertIn('actual == verifiedFlutterFiles.keys', app)
        self.assertIn('MessageDigest.getInstance("SHA-256")', app)
        self.assertNotIn('flutterExecutable', app)
        self.assertNotIn('Exec::class', app)
        self.assertNotIn('isCiBuild', app)
        self.assertIn('gradle.startParameter.isOffline', settings)
        self.assertIn('taskNames == listOf(":app:assembleDebug")', settings)
        self.assertIn('exclusiveContent', settings)
        self.assertIn('ignoreGradleMetadataRedirection()', settings)
        self.assertNotIn('../flutter_elitesync_module/build/host/outputs/repo', settings)
        self.assertEqual(result['runtime_consumption'], 'NOT_RUN')
        self.assertIs(result['execution_allowed'], False)
        self.assertIs(result['producer_provenance_proven'], False)

    def test_source_drift_is_rejected(self):
        with self.assertRaises(ValueError):
            self.render(self.app + '\n// drift\n')

    def test_source_debug_opt_in_is_removed_from_verified_aar_host(self):
        result = self.render(local_repository=True)
        self.assertNotIn('flutterSourceDebug', result['app_gradle'])
        self.assertNotIn('project(":flutter")', result['app_gradle'])
        self.assertNotIn('flutter-source-debug.gradle', result['settings_gradle'])
        self.assertEqual(result['source_sha256'], {
            'app': hashlib.sha256(self.app.encode()).hexdigest(),
            'settings': hashlib.sha256(self.settings.encode()).hexdigest(),
        })

    def test_settings_drift_is_rejected_before_repository_read(self):
        with self.assertRaises(ValueError):
            host.render_private_host(self.app, self.settings + '\n// drift\n',
                str(self.repo), VERSION, file_limit=100, byte_limit=100000)

    def test_source_opt_in_preserves_original_aar_host_output_bytes(self):
        receipt = dict(repository='C:/fixture/repo',
            coordinate='com.elitesync.flutter_elitesync_module:flutter_release:1.0-fixed',
            content_manifest_sha256='1'*64,
            content_manifest=[dict(relative_path='fixture.aar', bytes=7, sha256='2'*64)],
            publications=['com.elitesync.flutter_elitesync_module:flutter_release:1.0-fixed'])
        # Golden outputs captured from the exact pre-source-debug pinned files.
        with patch.object(host, 'verify_repository', return_value=receipt):
            result = self.render()
        self.assertEqual(hashlib.sha256(result['app_gradle'].encode()).hexdigest(),
            '958a2b35600dd6b63bf8c260716e01a4b5d55ce5a2bf7db2b579856f5cf23a5b')
        self.assertEqual(hashlib.sha256(result['settings_gradle'].encode()).hexdigest(),
            'baf38ea8545d4c144ebef42ba9a18147eb6dd2bf982848f41744c70590b6f78d')

    def test_repository_checks_do_not_resolve_java_through_gradle_extension(self):
        app = self.render(local_repository=True)['app_gradle']
        imports, body = app.split('plugins {', 1)
        self.assertIn('import java.nio.file.Files as VerifiedRepositoryFiles', imports)
        self.assertIn('import java.nio.file.LinkOption as VerifiedRepositoryLinkOption', imports)
        self.assertIn('import java.security.MessageDigest as VerifiedRepositoryMessageDigest', imports)
        self.assertNotIn('java.nio.', body)
        self.assertNotIn('java.security.', body)
        self.assertIn('VerifiedRepositoryFiles.newInputStream', body)

    def test_java_type_names_in_repository_path_are_not_rewritten(self):
        target = self.repo.with_name('repo java.nio.file.Files java.nio.file.LinkOption java.security.MessageDigest')
        self.repo.rename(target)
        self.repo = target
        result = self.render(local_repository=True)
        literal = '"' + target.resolve().as_posix() + '"'
        self.assertIn('rootProject.file(' + literal + ').toPath()', result['app_gradle'])
        self.assertIn('url = uri(' + literal + ')', result['settings_gradle'])

    def test_empty_repository_cannot_generate_host_override(self):
        empty = Path(self.temp.name) / 'empty'
        empty.mkdir()
        with self.assertRaises(ValueError):
            host.render_private_host(self.app, self.settings, str(empty), VERSION,
                                      file_limit=100, byte_limit=100000)


if __name__ == '__main__':
    unittest.main()
