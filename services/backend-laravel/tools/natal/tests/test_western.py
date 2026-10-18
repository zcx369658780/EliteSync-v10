import importlib.util
import math
import os
import json
import sys
import pathlib
import unittest
import datetime as dt
import hashlib
import tempfile
from unittest import mock

MODULE = pathlib.Path(__file__).parents[1] / 'western.py'
sys.path.insert(0, str(MODULE.parent))
spec = importlib.util.spec_from_file_location('natal_western', MODULE)
western = importlib.util.module_from_spec(spec)
spec.loader.exec_module(western)


class GeometryTests(unittest.TestCase):
    def test_pre_utc_label_is_already_ut1_and_has_no_fabricated_dut1(self):
        when = dt.datetime(1901, 1, 1, 23, 59, 59, 500000, tzinfo=dt.timezone.utc)
        self.assertEqual(western._ut1_datetime(when, {
            'utc_interpretation': 'PRE_1960_CIVIL_LABEL_AS_UT1', 'dut1_seconds': None}),
            dt.datetime(1901, 1, 1, 23, 59, 59, 500000))

    def test_utc_to_ut1_conversion_retains_day_rollover_and_fraction(self):
        when = dt.datetime(2000, 1, 1, 23, 59, 59, 750000, tzinfo=dt.timezone.utc)
        self.assertEqual(western._ut1_datetime(when, {
            'utc_interpretation': 'ERFA_UTC_WITH_LEAP_SECONDS', 'dut1_seconds': 0.5}),
            dt.datetime(2000, 1, 2, 0, 0, 0, 250000))
        with self.assertRaisesRegex(ValueError, 'ut1_time_metadata_missing'):
            western._ut1_datetime(when, {'dut1_seconds': None})

    def test_loaded_kernel_closes_when_body_lookup_fails(self):
        kernel = mock.Mock()
        kernel.__getitem__ = mock.Mock(side_effect=RuntimeError('test_body_lookup_failure'))
        payload = {'context': {'utc': '2000-01-01T12:00:00Z', 'time_precision': 'second'},
                   'profile': {}}
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / 'kernel.bsp'
            path.write_bytes(b'')
            with mock.patch('skyfield.api.load_file', return_value=kernel):
                with self.assertRaisesRegex(RuntimeError, 'test_body_lookup_failure'):
                    western.compute(payload, path, hashlib.sha256(b'').hexdigest())
        kernel.close.assert_called_once_with()

    def test_equatorial_axes_and_all_house_modes(self):
        for mode in ('whole', 'placidus', 'alcabitius'):
            result = western.houses(0.0, 0.0, 23.4392911, mode)
            self.assertEqual(result['status'], 'CALCULATED')
            self.assertAlmostEqual(result['ascendant'], 90.0, places=8)
            self.assertAlmostEqual(result['midheaven'], 0.0, places=8)
            for i, cusp in enumerate(result['cusps']):
                ra = math.radians((90 + i * 30) % 360)
                # At the equator time-based houses divide right ascension;
                # only whole-sign houses divide ecliptic longitude equally.
                expected = ((90 + i * 30) % 360 if mode == 'whole' else
                            math.degrees(math.atan2(math.sin(ra), math.cos(ra) * math.cos(math.radians(23.4392911)))) % 360)
                self.assertAlmostEqual(cusp, expected, places=7)

    def test_zero_obliquity_equatorial_houses_are_equal(self):
        for mode in ('whole', 'placidus', 'alcabitius'):
            result = western.houses(0.0, 0.0, 0.0, mode)
            for i, cusp in enumerate(result['cusps']):
                self.assertAlmostEqual(cusp, (90 + i * 30) % 360, places=7)

    def test_opposite_cusps_and_eastern_ascendant(self):
        for lat in (-52.1, 31.2, 51.5):
            for lst in (14.0, 140.0, 280.0):
                for mode in ('placidus', 'alcabitius'):
                    result = western.houses(lat, lst, 23.436, mode)
                    self.assertEqual(result['status'], 'CALCULATED')
                    for i in range(6):
                        self.assertAlmostEqual(western.angle(result['cusps'][i + 6] - result['cusps'][i]), 180.0)

    def test_polar_placidus_is_not_silently_another_house_system(self):
        result = western.houses(89.0, 0, 23.436, 'placidus')
        self.assertEqual(result['status'], 'NOT_APPLICABLE')
        self.assertEqual(result['requested_house_system'], 'placidus')
        self.assertIsNone(result['effective_house_system'])
        self.assertNotIn('cusps', result)

    def test_modes_are_real_and_point_membership_wraps(self):
        p = western.houses(51.5, 100, 23.436, 'placidus')
        a = western.houses(51.5, 100, 23.436, 'alcabitius')
        self.assertGreater(abs(p['cusps'][1] - a['cusps'][1]), 0.1)
        self.assertEqual(western.house_for(359.0, [350.0] + [float((350+i*30)%360) for i in range(1,12)]), 1)

    def test_invalid_inputs_are_rejected(self):
        for bad in ('koch', 'porphyry', ''):
            with self.assertRaises(ValueError):
                western.houses(0, 0, 23.4, bad)
        with self.assertRaises(ValueError):
            western.houses(float('nan'), 0, 23.4, 'whole')

    def test_aspect_exact_and_orb_boundary(self):
        result = western.aspects({'sun': 359.0, 'moon': 1.0, 'mars': 91.0}, 'major', 'tight')
        conj = next(x for x in result if x['a'] == 'sun' and x['b'] == 'moon')
        self.assertEqual(conj['type'], 'conjunction')
        self.assertEqual(conj['deviation'], 2.0)
        self.assertTrue(any(x['type'] == 'square' for x in result))


@unittest.skipUnless(os.environ.get('NATAL_TEST_KERNEL'), 'explicit locally audited kernel required')
class OfflineRuntimeTests(unittest.TestCase):
    def test_sidereal_full_cli_json_is_portable_under_windows_legacy_encoding(self):
        import subprocess
        import sys
        payload = {'context': {'utc': '2000-01-02T05:30:00Z', 'time_precision': 'second',
                               'latitude': 31.2, 'longitude': 121.5},
                   'profile': {'zodiac_mode': 'sidereal', 'house_system': 'placidus', 'point_set': 'full'}}
        process = subprocess.run([sys.executable, str(MODULE), os.environ['NATAL_TEST_KERNEL'],
            'c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2'],
            input=json.dumps(payload).encode('utf-8'), stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            env={**os.environ, 'PYTHONIOENCODING': 'cp936'}, timeout=30)
        self.assertEqual(process.returncode, 0, process.stderr)
        result = json.loads(process.stdout.decode('utf-8'))
        self.assertEqual(len(result['planets']), 14)
        self.assertEqual(result['effective_profile']['point_set'], 'full')
        self.assertIn('自定义', result['sidereal_reference']['display_name_zh'])

    def test_full_refuses_missing_or_corrupt_manifest_and_orbit(self):
        payload = {'context': {'utc': '2000-01-01T12:00:00Z', 'time_precision': 'second'},
                   'profile': {'point_set': 'full'}}
        args = (os.environ['NATAL_TEST_KERNEL'], 'c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2')
        resources = MODULE.parents[2] / 'resources/natal'
        manifest_path = resources / 'chiron-data-manifest.json'
        orbit_path = resources / 'data/chiron-lowell-hermite8d-v1.npz'
        original_read = pathlib.Path.read_bytes
        manifest = json.loads(original_read(manifest_path))
        for case in ('missing_manifest', 'unadmitted_manifest', 'missing_orbit', 'corrupt_orbit'):
            def read(path):
                if path == manifest_path:
                    if case == 'missing_manifest':
                        raise FileNotFoundError('synthetic missing manifest')
                    if case == 'unadmitted_manifest':
                        return json.dumps({**manifest, 'rights_status': 'PENDING'}).encode()
                if path == orbit_path:
                    if case == 'missing_orbit':
                        raise FileNotFoundError('synthetic missing orbit')
                    if case == 'corrupt_orbit':
                        return original_read(path) + b'changed-by-test-in-memory-only'
                return original_read(path)
            with self.subTest(case=case), mock.patch.object(pathlib.Path, 'read_bytes', read):
                with self.assertRaises((ValueError, FileNotFoundError)):
                    western.compute(payload, *args)

    def test_full_points_include_real_chiron_and_modes_recompute_it(self):
        payload = {'context': {'utc': '2000-01-01T12:00:00Z', 'time_precision': 'second',
                               'latitude': 51.5, 'longitude': 0.0},
                   'profile': {'zodiac_mode': 'tropical', 'house_system': 'whole', 'point_set': 'full'}}
        args = (os.environ['NATAL_TEST_KERNEL'], 'c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2')
        tropical = western.compute(payload, *args)
        chiron = next(p for p in tropical['planets'] if p['name'] == 'chiron')
        self.assertEqual(len(tropical['planets']), 14)
        self.assertEqual(tropical['effective_profile']['point_set'], 'full')
        self.assertEqual(tropical['unavailable_points'], [])
        self.assertEqual(chiron['reference_status'], 'INDEPENDENT_SAMPLED_REFERENCE_MATCH')
        self.assertGreater(chiron['distance_au'], 1)
        self.assertNotEqual(chiron['longitude'], 0)
        self.assertIn('house', chiron)
        payload['profile']['zodiac_mode'] = 'sidereal'
        sidereal = western.compute(payload, *args)
        shifted = next(p for p in sidereal['planets'] if p['name'] == 'chiron')
        self.assertAlmostEqual(western.angle(chiron['longitude'] - shifted['longitude']),
                               sidereal['sidereal_reference']['ayanamsha_degrees'], places=8)
        self.assertEqual(chiron['data_sha256'], shifted['data_sha256'])
        json.dumps(sidereal, allow_nan=False)

    def test_pre_utc_solar_context_keeps_ut1_interpretation(self):
        payload = {'context': {'utc': '1901-01-01T23:59:59Z', 'time_precision': 'second',
                               'latitude': 31.2, 'longitude': 179.0},
                   'profile': {'zodiac_mode': 'tropical', 'house_system': 'whole'}}
        result = western.compute(payload, os.environ['NATAL_TEST_KERNEL'],
            'c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2')
        self.assertEqual(result['calculation_status'], 'CALCULATED')
        self.assertEqual(result['time_context']['utc_interpretation'], 'PRE_1960_CIVIL_LABEL_AS_UT1')
        self.assertIsNone(result['time_context']['dut1_seconds'])
        self.assertIsNone(result['solar_context']['ut1_utc_seconds'])
        self.assertEqual(result['solar_context']['status'], 'CALCULATED')
        self.assertEqual(result['solar_context']['effective_solar_date'], '1901-01-02')
        json.dumps(result, allow_nan=False)

    def test_ten_bodies_are_json_serializable_and_sidereal_is_a_real_mode(self):
        payload = {'context': {'utc': '2000-01-01T12:00:00Z', 'time_precision': 'second',
                               'latitude': 51.5, 'longitude': 0.0},
                   'profile': {'zodiac_mode': 'tropical', 'house_system': 'whole'}}
        args = (os.environ['NATAL_TEST_KERNEL'], 'c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2')
        tropical = western.compute(payload, *args)
        self.assertEqual(len(tropical['planets']), 10)
        self.assertEqual(len(tropical['houses']), 12)
        json.dumps(tropical, allow_nan=False)
        payload['profile']['zodiac_mode'] = 'sidereal'
        sidereal = western.compute(payload, *args)
        json.dumps(sidereal, allow_nan=False)
        offset = sidereal['sidereal_reference']['ayanamsha_degrees']
        self.assertGreater(offset, 23)
        self.assertLess(offset, 25)
        for a, b in zip(tropical['planets'], sidereal['planets']):
            self.assertAlmostEqual(western.angle(a['longitude'] - b['longitude']), offset, places=8)
        self.assertEqual(sidereal['axes']['cusps'][0] % 30, 0)
        self.assertEqual(sidereal['solar_context'], tropical['solar_context'])


if __name__ == '__main__':
    unittest.main()
