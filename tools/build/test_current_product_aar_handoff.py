import hashlib
from pathlib import Path
import tempfile
import unittest
import zipfile
from unittest.mock import patch

import current_product_aar_handoff as handoff


VERSION = '1.0-v1015-' + 'a' * 12 + '-' + 'b' * 12
GROUP = 'com.elitesync.flutter_elitesync_module'
ARTIFACT = 'flutter_release'


class AarHandoffTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.repo = self.base / 'producer'
        self.module = self.repo / GROUP.replace('.', '/') / ARTIFACT / VERSION
        self.module.mkdir(parents=True)
        self.pom = self.module / f'{ARTIFACT}-{VERSION}.pom'
        self.aar = self.module / f'{ARTIFACT}-{VERSION}.aar'
        self.write_pom()
        self.write_aar()

    def write_pom(self, version=VERSION, dependencies=''):
        self.pom.write_text(f'''<project xmlns="http://maven.apache.org/POM/4.0.0">
<modelVersion>4.0.0</modelVersion><groupId>{GROUP}</groupId>
<artifactId>{ARTIFACT}</artifactId><version>{version}</version><packaging>aar</packaging>
<dependencies>{dependencies}</dependencies></project>''', encoding='utf-8')

    def write_aar(self, extra=None, arm64=True):
        elf = bytearray(64)
        elf[:6] = b'\x7fELF\x02\x01'
        elf[18:20] = (183 if arm64 else 62).to_bytes(2, 'little')
        with zipfile.ZipFile(self.aar, 'w') as archive:
            archive.writestr('AndroidManifest.xml', b'manifest fixture')
            archive.writestr('classes.jar', b'classes fixture')
            archive.writestr('jni/arm64-v8a/libapp.so', bytes(elf))
            if extra:
                archive.writestr(extra, b'bad')

    def verify(self):
        return handoff.verify_repository(str(self.repo), VERSION,
                                         file_limit=100, byte_limit=100000)

    def test_coordinate_hash_and_scope_are_bound_without_provenance_claim(self):
        result = self.verify()
        self.assertEqual(result['coordinate'], GROUP + ':' + ARTIFACT + ':' + VERSION)
        self.assertEqual(result['main_aar_sha256'], hashlib.sha256(self.aar.read_bytes()).hexdigest())
        self.assertEqual(result['files'], 2)
        self.assertIs(result['producer_provenance_proven'], False)
        self.assertIs(result['offline_dependencies_proven'], False)
        self.assertIs(result['execution_allowed'], False)

    def test_empty_or_incomplete_repository_is_rejected(self):
        self.aar.unlink()
        with self.assertRaises(ValueError):
            self.verify()
        self.pom.unlink()
        with self.assertRaises(ValueError):
            self.verify()

    def test_version_mismatch_or_unbound_version_is_rejected(self):
        self.write_pom(version='1.0')
        with self.assertRaises(ValueError):
            self.verify()
        for version in ['1.0', VERSION + '-SNAPSHOT', '../escape', True]:
            with self.subTest(version=version), self.assertRaises(ValueError):
                handoff.verify_repository(str(self.repo), version, file_limit=100, byte_limit=100000)

    def test_unpinned_external_dependency_is_rejected(self):
        for version in ['[1,)', 'LATEST', 'RELEASE', '1.0-SNAPSHOT',
                        '1.+', 'latest.release', 'latest.integration']:
            self.write_pom(dependencies=f'''<dependency><groupId>io.flutter</groupId>
<artifactId>flutter_embedding_release</artifactId><version>{version}</version></dependency>''')
            with self.subTest(version=version), self.assertRaises(ValueError):
                self.verify()

    def test_pinned_external_dependency_is_recorded_but_not_claimed_offline(self):
        self.write_pom(dependencies='''<dependency><groupId>io.flutter</groupId>
<artifactId>flutter_embedding_release</artifactId><version>1.0.0-engine</version></dependency>''')
        result = self.verify()
        self.assertEqual(result['external_dependencies'], ['io.flutter:flutter_embedding_release:1.0.0-engine'])
        self.assertIs(result['offline_dependencies_proven'], False)

    def test_xml_entities_and_misplaced_publications_are_rejected(self):
        self.pom.write_bytes(b'<!DOCTYPE project [<!ENTITY x "x">]><project/>')
        with self.assertRaises(ValueError):
            self.verify()
        self.write_pom()
        self.pom.rename(self.repo / 'wrong.pom')
        with self.assertRaises(ValueError):
            self.verify()

    def test_utf16_entity_and_duplicate_coordinates_are_rejected(self):
        self.pom.write_bytes('<!DOCTYPE project [<!ENTITY x "x">]><project/>'.encode('utf-16'))
        with self.assertRaises(ValueError):
            self.verify()
        self.write_pom()
        text = self.pom.read_text(encoding='utf-8')
        self.pom.write_text(text.replace('<version>', '<version>1.0</version><version>', 1), encoding='utf-8')
        with self.assertRaises(ValueError):
            self.verify()

    def test_extra_native_library_header_and_post_inspection_addition_rejected(self):
        self.write_aar(extra='jni/arm64-v8a/libextra.so')
        with self.assertRaises(ValueError):
            self.verify()
        self.write_aar()
        original = handoff._aar_header

        def added(*args):
            original(*args)
            (self.repo / 'late.txt').write_bytes(b'late')

        with patch.object(handoff, '_aar_header', side_effect=added):
            with self.assertRaises(ValueError):
                self.verify()

    def test_wrong_architecture_and_zip_traversal_are_rejected(self):
        self.write_aar(arm64=False)
        with self.assertRaises(ValueError):
            self.verify()
        for name in ['../escape', '/absolute', 'jni/x86_64/extra.so']:
            self.write_aar(extra=name)
            with self.subTest(name=name), self.assertRaises(ValueError):
                self.verify()

    def test_duplicate_zip_member_is_rejected(self):
        with zipfile.ZipFile(self.aar, 'a') as archive:
            archive.writestr('CLASSES.JAR', b'duplicate')
        with self.assertRaises(ValueError):
            self.verify()

    def test_copy_to_fresh_private_destination_preserves_exact_repository(self):
        task = self.base / 'task'
        task.mkdir()
        result = handoff.stage_repository(str(self.repo), str(task / 'verified-repo'),
                                          str(task), VERSION, file_limit=100, byte_limit=100000)
        copied = task / 'verified-repo' / self.aar.relative_to(self.repo)
        self.assertEqual(copied.read_bytes(), self.aar.read_bytes())
        self.assertEqual(result['status'], 'PRIVATE_REPOSITORY_BYTES_VERIFIED')
        self.assertIs(result['execution_allowed'], False)
        self.assertIs(result['readonly_guest_mapping_proven'], False)
        with self.assertRaises((ValueError, FileExistsError)):
            handoff.stage_repository(str(self.repo), str(task / 'verified-repo'),
                                      str(task), VERSION, file_limit=100, byte_limit=100000)

    def test_copy_rejects_overlap_and_destination_outside_task_root(self):
        for destination, task in [(self.repo / 'copy', self.repo),
                                  (self.base / 'other', self.base / 'task')]:
            with self.subTest(destination=destination), self.assertRaises((ValueError, OSError)):
                handoff.stage_repository(str(self.repo), str(destination), str(task), VERSION,
                                          file_limit=100, byte_limit=100000)


if __name__ == '__main__':
    unittest.main()
