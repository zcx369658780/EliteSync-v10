"""Time-standard checks against published ERFA/SOFA offsets, not chart fixtures."""
import datetime as dt
import importlib.util
import pathlib
import unittest

from skyfield.api import load

SPEC = importlib.util.spec_from_file_location(
    'natal_time_context', pathlib.Path(__file__).parents[1] / 'time_context.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class TimeContextTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.ts = load.timescale(builtin=True)

    def resolve(self, year, month=1, day=1, hour=0, minute=0, second=0):
        return MODULE.resolve_time(dt.datetime(year, month, day, hour, minute, second,
                                               tzinfo=dt.timezone.utc), self.ts)

    def test_1901_uses_ut1_not_invented_atomic_utc(self):
        instant, meta = self.resolve(1901)
        self.assertAlmostEqual(instant.ut1, 2415385.5, places=8)
        self.assertEqual(meta['utc_interpretation'], 'PRE_1960_CIVIL_LABEL_AS_UT1')
        self.assertIsNone(meta['tai_minus_utc_seconds'])
        self.assertIsNone(meta['dut1_seconds'])
        self.assertAlmostEqual((instant.tt - instant.ut1) * 86400,
                               meta['delta_t_seconds'], delta=0.00005)

    def test_1961_rubber_seconds_include_fractional_day_drift(self):
        _, midnight = self.resolve(1961)
        instant, noon = self.resolve(1961, hour=12)
        self.assertAlmostEqual(midnight['tai_minus_utc_seconds'], 1.422818, places=9)
        self.assertAlmostEqual(noon['tai_minus_utc_seconds'], 1.423466, places=9)
        self.assertEqual(noon['utc_interpretation'], 'ERFA_UTC_WITH_PRE_1972_DRIFT')
        nominal_jd = dt.date(1961, 1, 1).toordinal() + 1721425.0
        self.assertAlmostEqual(((instant.whole - nominal_jd) + instant.tt_fraction) * 86400,
                               32.184 + 1.423466, places=7)

    def test_1965_rubber_seconds_and_dut1_use_historical_offset(self):
        instant, meta = self.resolve(1965, hour=12)
        self.assertAlmostEqual(meta['tai_minus_utc_seconds'], 3.540778, places=9)
        self.assertAlmostEqual(meta['dut1_seconds'],
                               32.184 + 3.540778 - meta['delta_t_seconds'], places=9)
        nominal_jd = dt.date(1965, 1, 1).toordinal() + 1721425.0
        self.assertAlmostEqual(((instant.whole - nominal_jd) + instant.tt_fraction) * 86400,
                               32.184 + 3.540778, places=7)

    def test_1972_first_positive_leap_second(self):
        before, _ = self.resolve(1972, 6, 30, 23, 59, 59)
        after, meta = self.resolve(1972, 7, 1)
        seconds = ((after.whole - before.whole) +
                   (after.tt_fraction - before.tt_fraction)) * 86400
        self.assertAlmostEqual(seconds, 2, places=8)
        self.assertEqual(meta['tai_minus_utc_seconds'], 11)

    def test_j2000_known_tai_offset_and_versions(self):
        _, meta = self.resolve(2000, hour=12)
        self.assertEqual(meta['tai_minus_utc_seconds'], 32)
        self.assertEqual(meta['dependencies']['pyerfa'], '2.0.1.5')
        self.assertEqual(meta['dependencies']['skyfield'], '1.55')
        self.assertEqual(meta['delta_t_model']['status'], 'MODEL_NOT_OBSERVED_DUT1')

    def test_future_dubious_year_is_retained_with_unknown_actual_leaps(self):
        instant, meta = self.resolve(2100)
        self.assertTrue(instant.tt > 2488000)
        self.assertTrue(meta['erfa_dubious_year'])
        self.assertEqual(meta['future_leap_seconds_actual'], 'UNKNOWN')
        self.assertEqual(meta['accuracy_status'], 'FUTURE_ASSUMPTION')
        self.assertIn('no additional', meta['future_utc_assumption'])
        self.assertTrue(meta['warnings'])

    def test_reject_naive_and_nonzero_offsets(self):
        for when in (dt.datetime(2000, 1, 1),
                     dt.datetime(2000, 1, 1, tzinfo=dt.timezone(dt.timedelta(hours=8)))):
            with self.assertRaisesRegex(ValueError, 'aware_utc_datetime_required'):
                MODULE.resolve_time(when, self.ts)


if __name__ == '__main__':
    unittest.main()
