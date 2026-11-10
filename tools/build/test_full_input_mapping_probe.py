from pathlib import Path
import re
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import full_input_mapping_probe as probe


def mappings():
    rows = []
    for i in range(273):
        rows.append({'role': 'input_' + str(i), 'host': 'D:\\Inputs\\' + str(i),
            'guest': 'C:\\Inputs\\' + str(i), 'readonly': True, 'relative': 'pubspec.yaml',
            'guest_file': 'C:\\Inputs\\' + str(i) + r'\pubspec.yaml', 'bytes': 3,
            'sha256': 'b' * 64, 'file_id': {'device': 1, 'inode': i + 1}})
    for role, guest in probe.WRITABLE.items():
        rows.append({'role': role, 'host': 'E:\\Private\\' + role, 'guest': guest,
            'readonly': False, 'relative': 'source.txt', 'guest_file': guest + r'\source.txt',
            'bytes': 3, 'sha256': 'c' * 64, 'file_id': {'device': 2, 'inode': len(rows) + 1}})
    return rows


class MappingProbeTests(unittest.TestCase):
    def setUp(self):
        self.manifest = {'schema': 1, 'scope': probe.SCOPE, 'nonce': 'a' * 32,
                         'binary_sha256': 'd' * 64, 'mappings': mappings()}

    def good_receipt(self):
        m = self.manifest
        reads = [dict(role=r['role'], path=r['guest_file'], bytes=r['bytes'], sha256=r['sha256'], identity_stable=True) for r in m['mappings']]
        checks = [dict(role=r['role'], path=r['guest_file'], access=a, directory=False, succeeded=False, native_error=5)
                  for r in m['mappings'] if r['readonly'] for a in probe.ACCESS]
        checks += [dict(role=r['role'], path=r['guest'], access=a, directory=True, succeeded=False, native_error=5)
                   for r in m['mappings'] if r['readonly'] for a in probe.DIRECTORY_ACCESS]
        writes = [dict(role=role, path=guest + '\\.elitesync-mapping-' + m['nonce'] + '.tmp', write_read_delete_ok=True)
                  for role, guest in probe.WRITABLE.items()]
        return {'schema': 1, 'scope': probe.SCOPE, 'nonce': m['nonce'], 'binary_sha256': m['binary_sha256'],
                'username': 'WDAGUtilityAccount', 'pid': 42, 'creation_utc': '2026-11-04T00:00:00Z',
                'kernel_file_version': '10.0', 'clr_version': '4.0', 'reads': reads, 'readonly_checks': checks,
                'private_writes': writes, 'failure': None, 'network_no_active_adapter': True,
                'sdk_starts': 0, 'gradle_starts': 0, 'apk_builds': 0, 'G2': False}

    def test_complete_matrix_can_support_only_mapping_evidence(self):
        probe.validate_mappings(self.manifest['mappings'])
        good = self.good_receipt()
        self.assertEqual(len(good['reads']), 275)
        self.assertEqual(len(good['readonly_checks']), 2457)
        probe.validate_receipt(good, self.manifest)

    def test_incomplete_duplicate_overlapping_or_writable_input_rejected(self):
        for mode in ['missing', 'duplicate', 'overlap', 'readonly', 'guest_overlap', 'host_root']:
            rows = mappings()
            if mode == 'missing': rows.pop(0)
            elif mode == 'duplicate': rows[0] = rows[1].copy()
            elif mode == 'overlap': rows[0]['host'] = rows[1]['host'] + r'\nested'
            elif mode == 'readonly': rows[0]['readonly'] = False
            elif mode == 'guest_overlap': rows[0]['guest'] = r'C:\Probe'
            else: rows[0]['host'] = 'D:\\'
            with self.subTest(mode=mode), self.assertRaises(ValueError):
                probe.validate_mappings(rows)

    def test_anchor_paths_identity_and_bounds(self):
        for key, value in [('relative', '../escape'), ('relative', r'folder\file'),
                           ('relative', 'file:stream'), ('guest_file', r'C:\other'),
                           ('bytes', True), ('bytes', 262145), ('sha256', 'unknown'),
                           ('file_id', {'device': True, 'inode': 1})]:
            rows = mappings(); rows[0][key] = value
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                probe.validate_mappings(rows)

    def test_wsb_has_every_mapping_with_network_and_media_disabled(self):
        xml = ET.fromstring(probe.configuration(Path(r'C:\Owned\scope'), self.manifest))
        folders = xml.findall('MappedFolders/MappedFolder')
        self.assertEqual(len(folders), 277)
        self.assertEqual(sum(f.findtext('ReadOnly') == 'true' for f in folders), 274)
        for name in ['Networking', 'AudioInput', 'VideoInput', 'ClipboardRedirection']:
            self.assertEqual(xml.findtext(name), 'Disable')
        self.assertEqual(xml.findtext('MemoryInMB'), '2048')
        self.manifest['nonce'] = 'bad & command'
        with self.assertRaises(ValueError):
            probe.configuration(Path(r'C:\Owned\scope'), self.manifest)

    def test_missing_unknown_or_promoted_result_rejected(self):
        for key, value in [('schema', True), ('failure', 'STOP'), ('network_no_active_adapter', 1),
                           ('sdk_starts', True), ('gradle_starts', 1), ('apk_builds', None), ('G2', True),
                           ('pid', False), ('username', 'host'), ('binary_sha256', 'e' * 64)]:
            receipt = self.good_receipt(); receipt[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                probe.validate_receipt(receipt, self.manifest)
        receipt = self.good_receipt(); del receipt['failure']
        with self.assertRaises(ValueError): probe.validate_receipt(receipt, self.manifest)

    def test_partial_duplicate_successful_or_ambiguous_denial_rejected(self):
        for mode in ['missing', 'duplicate', 'success', 'sharing', 'boolean_error', 'directory_type']:
            receipt = self.good_receipt()
            checks = receipt['readonly_checks']
            if mode == 'missing': checks.pop()
            elif mode == 'duplicate': checks[0] = checks[1].copy()
            elif mode == 'success': checks[0]['succeeded'] = True
            elif mode == 'sharing': checks[0]['native_error'] = 32
            elif mode == 'boolean_error': checks[0]['native_error'] = True
            else: checks[0]['directory'] = 0
            with self.subTest(mode=mode), self.assertRaises(ValueError): probe.validate_receipt(receipt, self.manifest)

    def test_each_read_and_private_canary_must_be_bound(self):
        for mode in ['missing_read', 'read_hash', 'unstable', 'private_missing', 'private_path', 'private_cleanup']:
            receipt = self.good_receipt()
            if mode == 'missing_read': receipt['reads'].pop()
            elif mode == 'read_hash': receipt['reads'][0]['sha256'] = 'e' * 64
            elif mode == 'unstable': receipt['reads'][0]['identity_stable'] = False
            elif mode == 'private_missing': receipt['private_writes'].pop()
            elif mode == 'private_path': receipt['private_writes'][0]['path'] = r'C:\Inputs\bad'
            else: receipt['private_writes'][0]['write_read_delete_ok'] = None
            with self.subTest(mode=mode), self.assertRaises(ValueError): probe.validate_receipt(receipt, self.manifest)

    def test_no_authority_or_alternate_directory_can_reach_launch(self):
        for authority in [False, 1, None, 'true']:
            with patch.object(probe, 'frozen') as frozen, patch.object(probe.subprocess, 'run') as process:
                with self.assertRaises(ValueError): probe.launch(probe.FIXED_ROOT, mapping_runtime_authorized=authority)
                frozen.assert_not_called(); process.assert_not_called()
        with self.assertRaises(ValueError): probe._fixed_root(probe.FIXED_ROOT / 'case02')

    def test_guest_cleanup_requests_shutdown_and_never_reboot(self):
        source = (probe.HERE / 'full_input_mapping_probe.cs').read_text(encoding='utf-8')
        shutdown = int(re.search(r'EWX_POWEROFF = (0x[0-9a-f]+)', source).group(1), 16)
        force = int(re.search(r'EWX_FORCEIFHUNG = (0x[0-9a-f]+)', source).group(1), 16)
        self.assertEqual(shutdown, 8)
        self.assertEqual((shutdown | force) & 2, 0)
        self.assertIn('ExitWindowsEx(EWX_POWEROFF | EWX_FORCEIFHUNG,', source)
        self.assertNotIn('Process.Start(', source)

    def test_root_creation_rights_cannot_be_omitted_or_granted(self):
        receipt = self.good_receipt()
        receipt['readonly_checks'] = [r for r in receipt['readonly_checks'] if not (r['directory'] and r['access'] in (2, 4))]
        with self.assertRaises(ValueError): probe.validate_receipt(receipt, self.manifest)
        receipt = self.good_receipt()
        root_create = next(r for r in receipt['readonly_checks'] if r['directory'] and r['access'] == 2)
        root_create['succeeded'], root_create['native_error'] = True, 0
        with self.assertRaises(ValueError): probe.validate_receipt(receipt, self.manifest)


if __name__ == '__main__':
    unittest.main()
