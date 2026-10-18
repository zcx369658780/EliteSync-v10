"""Real installed-package/table and isolated kernel fingerprint checks."""
import hashlib
import importlib.util
import os
import pathlib
import shutil
import tempfile
import unittest
from unittest import mock

SPEC = importlib.util.spec_from_file_location(
    'runtime_identity', pathlib.Path(__file__).parents[1] / 'runtime_identity.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class RuntimeIdentityTest(unittest.TestCase):
    def test_an_unadmitted_dependency_version_cannot_be_available(self):
        original_distribution = MODULE.importlib.metadata.distribution
        numpy_distribution = original_distribution('numpy')
        class ChangedDistribution:
            version = '0.0.0-unadmitted'
            read_text = numpy_distribution.read_text
        def installed(name):
            return ChangedDistribution() if name == 'numpy' else original_distribution(name)
        with tempfile.TemporaryDirectory() as directory:
            kernel = pathlib.Path(directory) / 'synthetic-kernel'
            kernel.write_bytes(b'identity only')
            with mock.patch.object(MODULE.importlib.metadata, 'distribution', side_effect=installed):
                result = MODULE.fingerprint(kernel, MODULE.sha256_file(kernel))
            self.assertEqual(result['status'], 'IDENTITY_UNAVAILABLE')
            self.assertEqual(result['reason'], 'dependency_version_not_admitted')

    def test_active_erfa_table_change_changes_fingerprint(self):
        import erfa
        import numpy as np
        original = erfa.leap_seconds.get().copy()
        with tempfile.TemporaryDirectory() as directory:
            kernel = pathlib.Path(directory) / 'synthetic-kernel'
            kernel.write_bytes(b'identity only')
            expected = MODULE.sha256_file(kernel)
            before = MODULE.fingerprint(kernel, expected)
            extra = np.array([(2099, 1, float(original[-1]['tai_utc']) + 1)], dtype=original.dtype)
            try:
                erfa.leap_seconds.set(np.concatenate([original, extra]))
                after = MODULE.fingerprint(kernel, expected)
                self.assertNotEqual(before['time_tables']['erfa_active_leap_sha256'],
                                    after['time_tables']['erfa_active_leap_sha256'])
            finally:
                erfa.leap_seconds.set(original)
            self.assertEqual(before, MODULE.fingerprint(kernel, expected))

    def test_actual_packages_and_active_time_tables_are_stable_and_observed(self):
        with tempfile.TemporaryDirectory() as directory:
            kernel = pathlib.Path(directory) / 'synthetic-kernel'
            kernel.write_bytes(b'identity test only; never used for ephemeris')
            expected = hashlib.sha256(kernel.read_bytes()).hexdigest()
            first = MODULE.fingerprint(kernel, expected)
            self.assertEqual(first, MODULE.fingerprint(kernel, expected))
            self.assertEqual(first['status'], 'AVAILABLE')
            self.assertEqual(first['packages']['skyfield']['version'], '1.55')
            self.assertEqual(first['packages']['pyerfa']['version'], '2.0.1.5')
            for field in ('skyfield_delta_t_sha256', 'erfa_active_leap_sha256'):
                self.assertEqual(len(first['time_tables'][field]), 64)
            self.assertEqual(len(first['implementation_sha256']['erfa.ufunc']), 64)

    @unittest.skipUnless(os.environ.get('NATAL_IDENTITY_TEST_KERNEL'), 'real kernel path not supplied')
    def test_real_kernel_copy_mutation_changes_identity_and_fails_admission(self):
        original = pathlib.Path(os.environ['NATAL_IDENTITY_TEST_KERNEL'])
        expected = MODULE.sha256_file(original)
        with tempfile.TemporaryDirectory() as directory:
            copy = pathlib.Path(directory) / 'owned-copy.bsp'
            shutil.copyfile(original, copy)
            accepted = MODULE.fingerprint(copy, expected)
            self.assertEqual(accepted['status'], 'AVAILABLE')
            with copy.open('r+b') as stream:
                stream.seek(-1, 2)
                last = stream.read(1)
                stream.seek(-1, 2)
                stream.write(bytes([last[0] ^ 1]))
            changed = MODULE.fingerprint(copy, expected)
            self.assertEqual(changed['status'], 'IDENTITY_UNAVAILABLE')
            self.assertNotEqual(changed['kernel']['actual_sha256'], accepted['kernel']['actual_sha256'])
            self.assertEqual(MODULE.sha256_file(original), expected)


if __name__ == '__main__':
    unittest.main()
