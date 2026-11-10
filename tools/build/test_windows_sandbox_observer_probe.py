from pathlib import Path
import tempfile
import unittest
import xml.etree.ElementTree as ET
import windows_sandbox_observer_probe as observer


class ObserverReceiptTests(unittest.TestCase):
    def setUp(self):
        self.manifest = {'nonce': 'a' * 32, 'binary_sha256': 'b' * 64}

    def good(self):
        return {'schema': 1, 'kind': 'owned-tree-and-network-observer', 'nonce': 'a' * 32,
            'username': 'WDAGUtilityAccount', 'binary_sha256': 'b' * 64, 'failure': None,
            'gradle_starts': 0, 'apk_builds': 0, 'G2': False,
            'proof': {'bound_members': 2, 'positive_endpoint_kinds': 4, 'positive_samples': 3,
                'successful_samples': 7, 'descendants_bound_before_resume': True,
                'owned_job_stopped': True, 'all_bound_handles_exited': True, 'job_final_empty': True,
                'tcp_udp_v4_v6_api_observed': True, 'sampling_non_atomic': True,
                'negative_reason': 'NON_LOOPBACK_TCP', 'udp_destination': 'UNKNOWN', 'full_builder_qualified': False}}

    def test_complete_bounded_receipt(self):
        observer.validate_receipt(self.good(), self.manifest)

    def test_failed_or_wrong_guest_cannot_pass(self):
        for key, value in [('failure', 'API failed'), ('username', 'host'), ('nonce', 'c' * 32),
                           ('binary_sha256', 'd' * 64), ('schema', True)]:
            with self.assertRaises(ValueError):
                observer.validate_receipt({**self.good(), key: value}, self.manifest)

    def test_positive_native_coverage_cannot_be_missing_or_boolean(self):
        for key in ['bound_members', 'positive_endpoint_kinds', 'positive_samples', 'successful_samples']:
            for value in [None, True, 0]:
                receipt = self.good()
                receipt['proof'][key] = value
                with self.assertRaises(ValueError):
                    observer.validate_receipt(receipt, self.manifest)

    def test_unknown_stop_or_exit_or_identity_proof_cannot_pass(self):
        keys = ['descendants_bound_before_resume', 'owned_job_stopped', 'all_bound_handles_exited',
                'job_final_empty', 'tcp_udp_v4_v6_api_observed', 'sampling_non_atomic']
        for key in keys:
            for value in [None, False, 1, 'true']:
                receipt = self.good()
                receipt['proof'][key] = value
                with self.assertRaises(ValueError):
                    observer.validate_receipt(receipt, self.manifest)

    def test_evidence_boundaries_cannot_be_promoted(self):
        for key, value in [('negative_reason', 'API_FAILED'), ('udp_destination', 'NO_TRAFFIC'), ('full_builder_qualified', True)]:
            receipt = self.good()
            receipt['proof'][key] = value
            with self.assertRaises(ValueError):
                observer.validate_receipt(receipt, self.manifest)

    def test_build_counts_and_gate_remain_strict(self):
        for key in ['gradle_starts', 'apk_builds']:
            for value in [None, 1, False]:
                with self.assertRaises(ValueError):
                    observer.validate_receipt({**self.good(), key: value}, self.manifest)
        with self.assertRaises(ValueError):
            observer.validate_receipt({**self.good(), 'G2': 0}, self.manifest)

    def test_configuration_maps_only_probe_and_owned_output(self):
        with tempfile.TemporaryDirectory() as directory:
            parent = Path(directory)
            root = parent / 'task'
            root.mkdir()
            for name in ['probe', 'fixture', 'output']:
                (root / name).mkdir()
            config = ET.fromstring(observer.configuration(root, 'a' * 32, parent))
            mappings = config.findall('./MappedFolders/MappedFolder')
            self.assertEqual([m.findtext('ReadOnly') for m in mappings], ['true', 'false'])
            self.assertEqual([m.findtext('HostFolder') for m in mappings], [str(root / 'probe'), str(root / 'output')])
            for option in ['Networking', 'ClipboardRedirection', 'AudioInput', 'VideoInput', 'PrinterRedirection', 'vGPU']:
                self.assertEqual(config.findtext(option), 'Disable')


if __name__ == '__main__':
    unittest.main()
