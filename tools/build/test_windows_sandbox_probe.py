import tempfile
import unittest
from pathlib import Path
import xml.etree.ElementTree as ET

import windows_sandbox_probe as probe


class SandboxProbeContractTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.parent = Path(self.temp.name)
        self.root = self.parent / 'owned-probe'
        self.root.mkdir()
        for name in ['probe', 'fixture', 'output']:
            (self.root / name).mkdir()
        self.nonce = 'a' * 32

    def test_configuration_has_only_two_readonly_inputs_and_one_owned_output(self):
        xml = ET.fromstring(probe.configuration(self.root, self.nonce, self.parent))
        mappings = xml.findall('./MappedFolders/MappedFolder')
        self.assertEqual(len(mappings), 3)
        self.assertEqual([x.findtext('ReadOnly') for x in mappings], ['true', 'true', 'false'])
        self.assertEqual([Path(x.findtext('HostFolder')).parent for x in mappings], [self.root] * 3)

    def test_configuration_explicitly_disables_external_device_and_network_sharing(self):
        xml = ET.fromstring(probe.configuration(self.root, self.nonce, self.parent))
        for name in ['Networking', 'vGPU', 'AudioInput', 'VideoInput', 'PrinterRedirection', 'ClipboardRedirection']:
            self.assertEqual(xml.findtext(name), 'Disable', name)
        self.assertEqual(xml.findtext('ProtectedClient'), 'Enable')
        self.assertEqual(xml.findtext('MemoryInMB'), '2048')
        self.assertNotIn('ExecutionPolicy', xml.findtext('./LogonCommand/Command'))

    def test_scope_rejects_parent_root_and_outside_or_missing_paths(self):
        for root in [self.parent, self.parent.parent, self.parent / 'missing']:
            with self.assertRaises(ValueError):
                probe.configuration(root, self.nonce, self.parent)

    def test_nonce_is_not_a_shell_command_or_a_path(self):
        for nonce in ['', '../a', 'a' * 31, 'A' * 32, 'a;shutdown', 'a' * 33]:
            with self.assertRaises(ValueError):
                probe.configuration(self.root, nonce, self.parent)

    def test_receipt_must_bind_attempt_hash_and_guest_identity(self):
        receipt = self.good_receipt()
        probe.validate_receipt(receipt, self.nonce, 'b' * 64)
        for key, value in [('nonce', 'c' * 32), ('input_sha256', 'd' * 64), ('username', 'zcxve')]:
            bad = {**receipt, key: value}
            with self.assertRaises(ValueError):
                probe.validate_receipt(bad, self.nonce, 'b' * 64)

    def good_receipt(self):
        return {
            'schema': 1, 'nonce': self.nonce, 'username': 'WDAGUtilityAccount',
            'input_sha256': 'b' * 64,
            'checks': {name: True for name in probe.REQUIRED_CHECKS},
            'network': [{'family': 2, 'native_error': 10051}, {'family': 23, 'native_error': 10051}],
        }

    def test_missing_or_unknown_or_failed_check_never_means_success(self):
        for value in [False, None, 'true', 1]:
            receipt = self.good_receipt()
            receipt['checks']['open_write_denied'] = value
            with self.assertRaises(ValueError):
                probe.validate_receipt(receipt, self.nonce, 'b' * 64)
        receipt = self.good_receipt()
        del receipt['checks']['open_write_denied']
        with self.assertRaises(ValueError):
            probe.validate_receipt(receipt, self.nonce, 'b' * 64)

    def test_timeout_or_remote_refusal_is_not_network_isolation(self):
        for error in [0, 10060, 10061, None]:
            receipt = self.good_receipt()
            receipt['network'][0]['native_error'] = error
            with self.assertRaises(ValueError):
                probe.validate_receipt(receipt, self.nonce, 'b' * 64)

    def test_explicit_guest_failure_or_missing_binary_identity_is_rejected(self):
        receipt = self.good_receipt()
        receipt.update(binary_sha256='c' * 64, pid=123, creation_utc='2026-11-01T12:00:00Z')
        probe.validate_receipt(receipt, self.nonce, 'b' * 64, 'c' * 64)
        for key, value in [('failure', 'native check failed'), ('binary_sha256', 'd' * 64), ('pid', True), ('pid', 0), ('creation_utc', None)]:
            with self.assertRaises(ValueError):
                probe.validate_receipt({**receipt, key: value}, self.nonce, 'b' * 64, 'c' * 64)

    def test_leaf_mapping_reparse_is_rejected(self):
        fixture = self.root / 'fixture'
        fixture.rmdir()
        outside = self.parent / 'outside'
        outside.mkdir()
        import subprocess
        made = subprocess.run(['pwsh', '-NoProfile', '-Command',
            "New-Item -ItemType Junction -Path '" + str(fixture).replace("'", "''") + "' -Target '" + str(outside).replace("'", "''") + "' | Out-Null"], capture_output=True)
        self.assertEqual(made.returncode, 0, made.stderr)
        # Remove only this exact junction, never recurse through its target.
        self.addCleanup(lambda: fixture.rmdir())
        with self.assertRaises(ValueError):
            probe.configuration(self.root, self.nonce, self.parent)

    def test_a_second_launch_claim_cannot_replace_or_refund_the_first(self):
        probe.claim_once(self.root / 'launch.claim.json', {'attempt': self.nonce})
        original = (self.root / 'launch.claim.json').read_bytes()
        with self.assertRaises(FileExistsError):
            probe.claim_once(self.root / 'launch.claim.json', {'attempt': 'c' * 32})
        self.assertEqual((self.root / 'launch.claim.json').read_bytes(), original)

    def test_same_bytes_cannot_replace_the_owned_fixture_identity(self):
        source = self.root / 'fixture/source.txt'
        source.write_bytes(b'owned sample')
        info = source.stat()
        manifest = {'input_sha256': probe.digest(source), 'input_file_id': [info.st_dev, info.st_ino]}
        probe.validate_fixture(self.root, manifest)
        source.rename(self.root / 'preserved-original.txt')
        source.write_bytes(b'owned sample')
        with self.assertRaises(ValueError):
            probe.validate_fixture(self.root, manifest)

    def test_fixture_hardlink_to_another_owned_path_is_rejected_before_launch(self):
        source = self.root / 'fixture/source.txt'
        source.write_bytes(b'owned sample')
        info = source.stat()
        manifest = {'input_sha256': probe.digest(source), 'input_file_id': [info.st_dev, info.st_ino]}
        import os
        os.link(source, self.root / 'another-link.txt')
        with self.assertRaises(ValueError):
            probe.validate_fixture(self.root, manifest)


if __name__ == '__main__':
    unittest.main()
