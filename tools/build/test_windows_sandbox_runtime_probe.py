from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET
import windows_sandbox_runtime_probe as runtime


class RuntimeProbeContractTests(unittest.TestCase):
    def setUp(self):
        self.manifest = {'nonce': 'a' * 32, 'binary_sha256': 'b' * 64}

    def receipt(self):
        return {'schema': 1, 'kind': 'existing-tools-and-owned-job', 'nonce': 'a' * 32,
            'username': 'WDAGUtilityAccount', 'binary_sha256': 'b' * 64,
            'failure': None, 'readonly_tool_anchors': True,
            'java': {'exit': 0, 'pid': 12, 'creation_utc': '2026-11-01T12:00:00Z', 'version': '17.0.18'},
            'python': {'exit': 0, 'pid': 13, 'creation_utc': '2026-11-01T12:00:00Z', 'version': '3.11.'},
            'job': {'pid': 14, 'birth': 100, 'image': r'C:\Probe\RuntimeProbe.exe', 'exit_code': 1,
                    'assigned_before_resume': True, 'startup_frame': True, 'kill_on_close_observed': True},
            'gradle_starts': 0, 'apk_builds': 0, 'G2': False}

    def test_positive_receipt_does_not_claim_full_build_qualification(self):
        runtime.validate_receipt(self.receipt(), self.manifest)

    def test_guest_identity_or_reported_failure_cannot_pass(self):
        for key, value in [('nonce', 'c' * 32), ('binary_sha256', 'd' * 64), ('username', 'owner'),
                           ('failure', 'native API failed'), ('readonly_tool_anchors', 1)]:
            with self.assertRaises(ValueError):
                runtime.validate_receipt({**self.receipt(), key: value}, self.manifest)

    def test_missing_or_unknown_job_proof_cannot_pass(self):
        for key in ['assigned_before_resume', 'startup_frame', 'kill_on_close_observed']:
            for value in [False, None, 'true', 1]:
                receipt = self.receipt()
                receipt['job'][key] = value
                with self.assertRaises(ValueError):
                    runtime.validate_receipt(receipt, self.manifest)

    def test_live_or_unbound_child_cannot_pass(self):
        for key, value in [('pid', 0), ('pid', True), ('birth', 0), ('exit_code', 259), ('image', r'C:\other.exe')]:
            receipt = self.receipt()
            receipt['job'][key] = value
            with self.assertRaises(ValueError):
                runtime.validate_receipt(receipt, self.manifest)

    def test_tool_failure_or_missing_identity_cannot_pass(self):
        for tool in ['java', 'python']:
            for key, value in [('exit', 1), ('exit', False), ('pid', None), ('creation_utc', ''), ('version', 'wrong')]:
                receipt = self.receipt()
                receipt[tool][key] = value
                with self.assertRaises(ValueError):
                    runtime.validate_receipt(receipt, self.manifest)

    def test_unexpected_build_or_gate_result_cannot_pass(self):
        for key, value in [('gradle_starts', 1), ('gradle_starts', False), ('apk_builds', 1),
                           ('apk_builds', None), ('apk_builds', False), ('G2', True), ('G2', 0)]:
            with self.assertRaises(ValueError):
                runtime.validate_receipt({**self.receipt(), key: value}, self.manifest)
        receipt = self.receipt()
        del receipt['apk_builds']
        with self.assertRaises(ValueError):
            runtime.validate_receipt(receipt, self.manifest)

    def test_tool_identity_rejects_hardlinks_and_directories(self):
        import os
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'source.txt'
            source.write_bytes(b'only this owned fixture')
            runtime.identity(source)
            os.link(source, root / 'second-link.txt')
            for path in [source, root]:
                with self.assertRaises(ValueError):
                    runtime.identity(path)

    def test_configuration_has_exact_readonly_tool_roots_and_owned_output(self):
        with tempfile.TemporaryDirectory() as directory:
            parent = Path(directory)
            root = parent / 'owned'
            root.mkdir()
            for name in ['probe', 'fixture', 'output']:
                (root / name).mkdir()
            jdk, python = parent / 'jdk', parent / 'python'
            jdk.mkdir()
            python.mkdir()
            (jdk / 'release').write_text('owned test metadata')
            (python / 'python.exe').write_bytes(b'not executed')
            with patch.object(runtime, 'JDK', jdk), patch.object(runtime, 'PYTHON', python):
                xml = ET.fromstring(runtime.configuration(root, 'a' * 32, parent))
            mappings = xml.findall('./MappedFolders/MappedFolder')
            self.assertEqual(len(mappings), 4)
            writable = [x for x in mappings if x.findtext('ReadOnly') == 'false']
            self.assertEqual([x.findtext('HostFolder') for x in writable], [str(root / 'output')])
            self.assertEqual([x.findtext('SandboxFolder') for x in mappings],
                [r'C:\Probe', r'C:\ProbeOutput', r'C:\Tools\Jdk', r'C:\Tools\Python'])
            for name in ['Networking', 'ClipboardRedirection', 'AudioInput', 'VideoInput', 'PrinterRedirection', 'vGPU']:
                self.assertEqual(xml.findtext(name), 'Disable')


if __name__ == '__main__':
    unittest.main()
