"""Adapter regression and time-standard tests, not a solar-position oracle."""
import datetime as dt
import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).parents[1]))
from skyfield.api import load
from bazi_time import calendar_from_tt, compute
from time_context import resolve_time


class BaziTimeTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.ts = load.timescale(builtin=True)

    def test_time_roundtrip_including_rubber_seconds_future_and_civil_cross_day(self):
        for label in ('1900-01-01T00:00:00Z', '1959-12-31T23:59:59Z',
                      '1960-01-01T00:00:00Z', '1961-07-31T23:59:59Z',
                      '1965-06-01T12:34:56Z', '1971-12-31T23:59:59Z',
                      '1972-01-01T00:00:00Z', '1972-06-30T23:59:59Z',
                      '1972-07-01T00:00:00Z', '2000-02-29T16:00:00Z',
                      '2016-12-31T23:59:59Z', '2017-01-01T00:00:00Z',
                      '2060-12-31T23:59:59Z', '2100-03-01T00:00:00Z',
                      '2101-01-01T00:00:00Z'):
            with self.subTest(label=label):
                when = dt.datetime.fromisoformat(label.replace('Z', '+00:00'))
                t, meta = resolve_time(when, self.ts)
                converted = calendar_from_tt(meta['tt_jd'], self.ts)
                self.assertEqual(converted['normalized_instant_label'], label)
                self.assertEqual(converted['utc_interpretation'], meta['utc_interpretation'])
                if when.year < 1960:
                    self.assertIsNone(converted['utc'])
                else:
                    self.assertEqual(converted['utc'], label)

    def test_literal_or_rounded_leap_second_is_rejected_without_clamping(self):
        before, meta = resolve_time(dt.datetime(2016, 12, 31, 23, 59, 59,
                                                tzinfo=dt.timezone.utc), self.ts)
        for seconds in (0.8, 1.0, 1.2):
            parts = [float(before.whole), float(before.tt_fraction + seconds / 86400)]
            with self.assertRaisesRegex(ValueError, 'leap_second_label_not_representable'):
                calendar_from_tt(parts, self.ts)

    def test_forward_metadata_must_match_actual_identity(self):
        utc = '2100-01-01T00:00:00Z'
        _, meta = resolve_time(dt.datetime(2100, 1, 1, tzinfo=dt.timezone.utc), self.ts)
        payload = dict(utc=utc, terms=[dict(id=str(i), tt_jd=meta['tt_jd']) for i in range(2)],
                       expected_time_context=meta)
        self.assertEqual(compute(payload)['status'], 'CALCULATED')
        for key in ('tt_jd', 'delta_t_model', 'active_erfa_leap_table_sha256', 'dependencies', 'profile_version'):
            bad = {**meta, key: None}
            with self.assertRaisesRegex(ValueError, 'time_context_identity_mismatch'):
                compute({**payload, 'expected_time_context': bad})


if __name__ == '__main__':
    unittest.main()
