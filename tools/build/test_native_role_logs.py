import copy
import json
import unittest
from unittest.mock import patch

import native_role_logs as logs


class NativeRoleLogsTests(unittest.TestCase):
    def setUp(self):
        self.exe = r'C:\Inputs\CMake\cmake.exe'
        self.manifest = {'executable': self.exe, 'images': [{'path': self.exe, 'sha256': 'a' * 64}],
                         'inputs': [{}] * 42}
        self.receipt = {'proof': {'root_pid': 10, 'root_birth': 100, 'bound_members': 1, 'successful_samples': 2,
                        'disk_scan_retries': 0, 'disk_directory_name_retries': 0,
                        'disk_directory_open_retries': 0, 'disk_deleted_directory_ids': 0}}
        self.rows = [
            {'operation': 'root_create_attempt', 'utc': '2026-11-05T00:00:00Z'},
            {'operation': 'process_image_check', 'pid': 10, 'birth': 100, 'observed_image': self.exe},
            {'utc': '2026-11-05T00:00:01Z', 'members': [{'pid': 10, 'birth': 100, 'image': self.exe, 'exited': False}],
             'endpoints': [], 'udp_destination': 'UNKNOWN', 'sampling_non_atomic': True},
            {'utc': '2026-11-05T00:00:02Z', 'members': [{'pid': 10, 'birth': 100, 'image': self.exe, 'exited': True}],
             'endpoints': [], 'udp_destination': 'UNKNOWN', 'sampling_non_atomic': True}]

    def raw(self, rows=None):
        return ('\r\n'.join(json.dumps(row) for row in (self.rows if rows is None else rows)) + '\r\n').encode()

    def validate(self, rows=None):
        return logs.validate_samples(self.raw(rows), self.receipt, self.manifest)

    def test_valid_samples_preserve_non_atomic_and_unknown_UDP(self):
        result = self.validate()
        self.assertEqual(result['sample_count'], 2)
        self.assertEqual(result['bound_members'], 1)
        self.assertIs(result['full_process_or_DLL_closure_proven'], False)
        self.assertIs(result['G2'], False)

    def test_STOP_or_bootstrap_failure_rejected_even_with_good_receipt(self):
        for operation in ('safety_stop', 'bootstrap_failure'):
            with self.subTest(operation=operation), self.assertRaises(ValueError):
                self.validate(self.rows + [{'operation': operation}])

    def test_unknown_image_or_birth_drift_rejected(self):
        for field, value in [('observed_image', r'C:\Windows\cmd.exe'), ('birth', 101), ('pid', True)]:
            rows = copy.deepcopy(self.rows)
            if field == 'birth':
                rows.insert(2, {**rows[1], 'birth': value})
            else:
                rows[1][field] = value
            with self.subTest(field=field), self.assertRaises(ValueError):
                self.validate(rows)

    def test_root_birth_binds_receipt_to_the_entire_sampled_instance(self):
        rows = copy.deepcopy(self.rows)
        rows[1]['birth'] = 999
        for row in rows[2:]:
            row['members'][0]['birth'] = 999
        with self.assertRaisesRegex(ValueError, 'root identity mismatch'):
            self.validate(rows)
        for value in (None, True, 0):
            self.receipt['proof']['root_birth'] = value
            with self.subTest(value=value), self.assertRaises(ValueError):
                self.validate()
        del self.receipt['proof']['root_birth']
        with self.assertRaises(ValueError):
            self.validate()

    def test_missing_or_repeated_root_attempt_and_wrong_root_rejected(self):
        for rows in (self.rows[1:], [self.rows[0]] + self.rows):
            with self.assertRaises(ValueError):
                self.validate(rows)
        self.receipt['proof']['root_pid'] = 99
        with self.assertRaises(ValueError):
            self.validate()

    def test_snapshot_and_counter_mismatch_rejected(self):
        for key, value in [('successful_samples', 3), ('bound_members', 2), ('disk_scan_retries', 1)]:
            receipt = copy.deepcopy(self.receipt);receipt['proof'][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                logs.validate_samples(self.raw(), receipt, self.manifest)

    def test_duplicate_JSON_key_nonfinite_non_UTF8_empty_and_unknown_row_rejected(self):
        for raw in (b'{"operation":"x","operation":"y"}\n', b'{"x":NaN}\n', b'\xff\n',
                    b'\n', b'{}\n', self.raw() + b'\n'):
            with self.subTest(raw=raw[:30]), self.assertRaises(ValueError):
                logs.validate_samples(raw, self.receipt, self.manifest)

    def test_byte_line_row_bounds_and_incomplete_final_line_rejected(self):
        for raw in (b'x' * (logs.MAX_BYTES + 1), b'x' * (logs.MAX_LINE_BYTES + 1) + b'\n', self.raw().rstrip(b'\r\n')):
            with self.assertRaises(ValueError):
                logs.validate_samples(raw, self.receipt, self.manifest)
        with patch.object(logs, 'MAX_ROWS', 3), self.assertRaisesRegex(ValueError, 'row bound'):
            self.validate()

    def test_duplicate_member_unchecked_identity_and_exited_revival_rejected(self):
        variants = []
        rows = copy.deepcopy(self.rows);rows[2]['members'].append(copy.deepcopy(rows[2]['members'][0]));variants.append(rows)
        rows = copy.deepcopy(self.rows);rows[2]['members'][0]['birth'] = 101;variants.append(rows)
        rows = copy.deepcopy(self.rows);rows[2]['members'][0]['exited'] = True;rows[3]['members'][0]['exited'] = False;variants.append(rows)
        for rows in variants:
            with self.assertRaises(ValueError):
                self.validate(rows)

    def endpoint(self, protocol='TCP', family=2):
        return {'pid': 10, 'state': 5 if protocol == 'TCP' else 0, 'family': family,
                'local_port': 123, 'remote_port': 124 if protocol == 'TCP' else 0,
                'protocol': protocol, 'local': '127.0.0.1' if family == 2 else '::1',
                'remote': ('127.0.0.1' if family == 2 else '::1') if protocol == 'TCP' else None}

    def test_TCP_v4_v6_and_UDP_exited_member_sample_accepted(self):
        rows = copy.deepcopy(self.rows)
        rows[3]['endpoints'] = [self.endpoint(), self.endpoint(family=23), self.endpoint('UDP')]
        result = self.validate(rows)
        self.assertEqual(result['endpoint_rows'], 3)
        self.assertEqual(result['udp_endpoint_rows'], 1)

    def test_unsafe_TCP_unknown_PID_bad_family_port_or_UDP_destination_rejected(self):
        for field, value in [('remote', '8.8.8.8'), ('local', '0.0.0.0'), ('pid', 99),
                             ('family', True), ('local_port', 65536), ('state', False)]:
            rows = copy.deepcopy(self.rows);endpoint = self.endpoint();endpoint[field] = value
            rows[2]['endpoints'] = [endpoint]
            with self.subTest(field=field), self.assertRaises(ValueError):
                self.validate(rows)
        rows = copy.deepcopy(self.rows);endpoint = self.endpoint('UDP');endpoint['remote'] = '127.0.0.1'
        rows[2]['endpoints'] = [endpoint]
        with self.assertRaises(ValueError):
            self.validate(rows)

    def test_TCP_listener_remote_is_not_destination_evidence(self):
        rows = copy.deepcopy(self.rows);endpoint = self.endpoint();endpoint.update(state=2, remote='0.0.0.0', remote_port=0)
        rows[2]['endpoints'] = [endpoint]
        self.validate(rows)

    def test_known_disk_operations_are_counted_and_owned(self):
        extra = [
            {'operation': 'disk_directory_name_retry', 'file_id': 1, 'error': 2, 'attempt': 1},
            {'operation': 'disk_directory_open_retry', 'file_id': 1, 'error': 5, 'attempt': 2},
            {'operation': 'disk_directory_id_gone', 'root': r'C:\BuildWork', 'file_id': 1},
            {'operation': 'disk_scan_retry', 'root': r'C:\ProbeOutput', 'attempt': 1, 'hresult': -2147024894}]
        for key in ('disk_scan_retries', 'disk_directory_name_retries', 'disk_directory_open_retries', 'disk_deleted_directory_ids'):
            self.receipt['proof'][key] = 1
        self.validate(self.rows + extra)
        extra[-1]['root'] = r'C:\Windows'
        with self.assertRaises(ValueError):
            self.validate(self.rows + extra)
        extra[-1]['root'] = r'C:\ProbeOutput'
        with self.assertRaisesRegex(ValueError, 'before root'):
            self.validate(extra + self.rows)

    def test_progress_extra_fields_and_time_boundary_rejected(self):
        for extra in ({'operation': 'input_verified', 'count': 200},
                      {'operation': 'root_create_attempt', 'utc': '2026-11-05T00:00:00Z', 'extra': True}):
            with self.assertRaises(ValueError):
                self.validate([extra] + self.rows)
        rows = copy.deepcopy(self.rows);rows[2]['utc'] = '2026-11-05T00:00:00'
        with self.assertRaises(ValueError):
            self.validate(rows)


if __name__ == '__main__':
    unittest.main()
