from pathlib import Path
import tempfile
import unittest
import zipfile

import current_product_private_host as host
from test_current_product_aar_handoff import GROUP, ARTIFACT, VERSION


class PrivateHostTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.repo = Path(self.temp.name) / 'repo'
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

    def render(self, app=None):
        return host.render_private_host(self.app if app is None else app, self.settings,
                                         str(self.repo), VERSION, file_limit=100, byte_limit=100000)

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

    def test_empty_repository_cannot_generate_host_override(self):
        empty = Path(self.temp.name) / 'empty'
        empty.mkdir()
        with self.assertRaises(ValueError):
            host.render_private_host(self.app, self.settings, str(empty), VERSION,
                                      file_limit=100, byte_limit=100000)


if __name__ == '__main__':
    unittest.main()
