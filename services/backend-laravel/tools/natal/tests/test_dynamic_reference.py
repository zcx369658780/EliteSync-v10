"""Non-author geometry/search reference; no physical-accuracy claim from shared model.

Set NATAL_JPL_KERNEL to run blind-date real numerical comparisons. The production
search is the subject under test, never the source of expected event counts/times.
"""
import datetime as dt
import hashlib
import importlib
import math
import os
import pathlib
import sys
import unittest

BASE = pathlib.Path(__file__).parents[1]
sys.path.insert(0, str(BASE))
sys.path.insert(0, str(BASE / 'oracle'))
from dynamic_reference import circle_distance, cross_aspects, overlay_houses, search_crossings

UTC = dt.timezone.utc
START = dt.datetime(2024, 1, 1, tzinfo=UTC)


def instant(text):
    return dt.datetime.fromisoformat(text.replace('Z', '+00:00'))


def affine(initial, rate):
    return lambda when: (initial + (when-START).total_seconds()*rate) % 360


class IndependentReferenceTests(unittest.TestCase):
    def test_circle_wrap_and_opposite(self):
        self.assertEqual(circle_distance(359, 1), 2)
        self.assertEqual(circle_distance(0, 180), 180)
        self.assertEqual(circle_distance(-721, 721), 2)

    def test_inclusive_and_exclusive_orb(self):
        a = [{'name': 'sun', 'longitude': 359}]
        b = [{'name': 'moon', 'longitude': 5}]
        self.assertEqual(len(cross_aspects(a, b)), 1)
        self.assertEqual(cross_aspects(a, b, inclusive=False), [])
        b[0]['longitude'] += 1e-8
        self.assertEqual(cross_aspects(a, b), [])
        b[0]['longitude'] -= 2e-8
        self.assertEqual(len(cross_aspects(a, b)), 1)

    def test_swap_separation_and_directional_houses(self):
        a = [{'name': 'sun', 'longitude': 359}]
        b = [{'name': 'moon', 'longitude': 1}]
        ab, ba = cross_aspects(a, b)[0], cross_aspects(b, a)[0]
        self.assertEqual(ab['separation'], ba['separation'])
        self.assertEqual((ab['a'], ab['b']), (ba['b'], ba['a']))
        cusps_a = list(range(0, 360, 30))
        cusps_b = [(15+30*i) % 360 for i in range(12)]
        self.assertEqual(overlay_houses(a, cusps_b), [{'name': 'sun', 'house': 12}])
        self.assertEqual(overlay_houses(b, cusps_a), [{'name': 'moon', 'house': 1}])
        self.assertEqual(overlay_houses([{'name': 'edge', 'longitude': 15}], cusps_b)[0]['house'], 1)
        with self.assertRaises(ValueError):
            overlay_houses(a, [0]*12)

    def test_zero_one_multiple_and_exact_half_open_boundaries(self):
        position = affine(0, 1)
        self.assertEqual(search_crossings(position, 30, START, START+dt.timedelta(seconds=30), 10), [])
        one = search_crossings(position, 30, START, START+dt.timedelta(seconds=31), 10)
        self.assertEqual([x['utc'] for x in one], ['2024-01-01T00:00:30.000000Z'])
        many = search_crossings(position, 0, START, START+dt.timedelta(seconds=721), 10)
        self.assertEqual([x['utc'] for x in many], ['2024-01-01T00:00:00.000000Z',
                                                  '2024-01-01T00:06:00.000000Z',
                                                  '2024-01-01T00:12:00.000000Z'])

    def test_wrap_does_not_create_opposition_pseudoroot(self):
        self.assertEqual(search_crossings(affine(179, .1), 0, START,
                                         START+dt.timedelta(seconds=20), 5), [])
        result = search_crossings(affine(359, .1), 0, START,
                                 START+dt.timedelta(seconds=20), 5)
        self.assertEqual(instant(result[0]['utc']), START+dt.timedelta(seconds=10))

    def test_start_just_before_at_after_event_without_past_epsilon(self):
        position = affine(0, 1)
        before = START-dt.timedelta(microseconds=100)
        after = START+dt.timedelta(microseconds=100)
        end = START+dt.timedelta(seconds=20)
        self.assertEqual(len(search_crossings(position, 0, before, end, 5)), 1)
        self.assertEqual(len(search_crossings(position, 0, START, end, 5)), 1)
        self.assertEqual(search_crossings(position, 0, after, end, 5), [])

    def test_reverse_crossing_and_residual_bracket(self):
        result = search_crossings(affine(1, -.13), 0, START,
                                  START+dt.timedelta(seconds=20), 5)
        self.assertEqual(len(result), 1)
        self.assertLess(abs((instant(result[0]['utc'])-START).total_seconds()-1/.13), 1e-5)
        self.assertLessEqual(result[0]['bracket_seconds'], 1)
        self.assertLessEqual(result[0]['residual_degrees'], 1e-5)

    def test_invalid_domain_and_callback_failure_are_not_empty_success(self):
        for a, b in [(START, START), (START, START-dt.timedelta(seconds=1))]:
            with self.assertRaises(ValueError):
                search_crossings(affine(0, 1), 0, a, b)
        with self.assertRaises(ValueError):
            search_crossings(lambda _: float('nan'), 0, START, START+dt.timedelta(seconds=10))
        with self.assertRaises(ValueError):
            search_crossings(affine(0, 1), 0, START.replace(tzinfo=None), START+dt.timedelta(seconds=10))
        def unavailable(_):
            raise RuntimeError('out_of_ephemeris_domain')
        with self.assertRaisesRegex(RuntimeError, 'out_of_ephemeris_domain'):
            search_crossings(unavailable, 0, START, START+dt.timedelta(seconds=10))

    def test_quantized_model_event_is_first_microsecond_not_plateau_midpoint(self):
        # A 40us staircase models historical time representation quantization.
        def staircase(when):
            micros = round((when-START).total_seconds()*1000000)
            return ((micros//40)*40 - 80)/1000000 % 360
        expected = START+dt.timedelta(microseconds=80)
        roots = search_crossings(staircase, 0, START, START+dt.timedelta(seconds=1), .1)
        self.assertEqual([instant(x['utc']) for x in roots], [expected])
        for shift, count in [(-1000, 1), (-1, 1), (0, 1), (1, 0), (1000, 0)]:
            self.assertEqual(len(search_crossings(staircase, 0,
                expected+dt.timedelta(microseconds=shift), START+dt.timedelta(seconds=1), .1)), count)


class ProductionSyntheticComparisonTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.production = importlib.import_module('dynamic')

    def test_cross_aspects_all_modes_and_orbs_against_independent_arithmetic(self):
        # Blind deterministic points include wrap, exact orb, opposition and minors.
        first = [{'name': 'a'+str(i), 'longitude': n} for i, n in enumerate([359, 0, 61, 179, 303.5])]
        second = [{'name': 'b'+str(i), 'longitude': n} for i, n in enumerate([1, 6, 181, 46, 121, 270])]
        keys = ('a', 'b', 'type', 'angle', 'separation', 'deviation', 'orb')
        for mode in ('major', 'standard', 'extended'):
            for orb in ('tight', 'standard', 'wide'):
                with self.subTest(mode=mode, orb=orb):
                    expected = cross_aspects(first, second, mode, orb)
                    actual = self.production.cross_aspects(first, second, mode, orb)
                    normalize = lambda rows: sorted(tuple(row[k] for k in keys) for row in rows)
                    self.assertEqual(normalize(actual), normalize(expected))

    def test_directional_overlay_against_independent_intervals(self):
        pa = [{'name': 'sun', 'longitude': 359}, {'name': 'moon', 'longitude': 15}]
        pb = [{'name': 'sun', 'longitude': 1}, {'name': 'moon', 'longitude': 345}]
        ca = list(range(0, 360, 30))
        cb = [(15+30*i) % 360 for i in range(12)]
        first = {'planets': pa, 'houses': [{'number': i+1, 'cusp': c} for i, c in enumerate(ca)], 'axes': {'status': 'CALCULATED', 'cusps': ca}}
        second = {'planets': pb, 'houses': [{'number': i+1, 'cusp': c} for i, c in enumerate(cb)], 'axes': {'status': 'CALCULATED', 'cusps': cb}}
        actual = self.production.overlays(first, second)
        self.assertEqual(actual['first_in_second']['points'], overlay_houses(pa, cb))
        self.assertEqual(actual['second_in_first']['points'], overlay_houses(pb, ca))

    def test_production_half_open_and_start_inclusion_without_past_epsilon(self):
        callback = affine(0, 13/86400)
        end = START+dt.timedelta(days=10)
        for offset, count in [(-.0001, 1), (0, 1), (.0001, 0)]:
            with self.subTest(start_offset_seconds=offset):
                start = START+dt.timedelta(seconds=offset)
                expected = search_crossings(callback, 0, start, end)
                actual = self.production.search_events(callback, 0, start, end, 'moon')
                self.assertEqual(len(expected), count)
                self.assertEqual(len(actual), count)
                for event in actual:
                    self.assertGreaterEqual(instant(event['utc']), start)
                    self.assertLess(instant(event['utc']), end)
        # Root exactly at end must not appear, even if numerical tolerance could
        # otherwise pull it inside. Beginning one day earlier contains no root.
        before = START-dt.timedelta(days=1)
        self.assertEqual(self.production.search_events(callback, 0, before, START, 'moon'), [])

    def test_production_search_matches_independent_full_window(self):
        # Natural sun/moon scale rates, including +/-180 signed residual jump.
        cases = [(179, 0, 1/86400, 20*86400), (359, 0, 1/86400, 3*86400),
                 (0, 0, 13/86400, 60*86400), (20, 30, 13/86400, 50*86400)]
        for initial, target, rate, duration in cases:
            with self.subTest(initial=initial, target=target, duration=duration):
                callback = affine(initial, rate)
                end = START+dt.timedelta(seconds=duration)
                expected = search_crossings(callback, target, START, end)
                actual = self.production.search_events(callback, target, START, end, 'moon')
                self.assertEqual(len(actual), len(expected))
                for got, want in zip(actual, expected):
                    self.assertLess(abs((instant(got['utc'])-instant(want['utc'])).total_seconds()), 1)
                    self.assertLessEqual(got['bracket_seconds'], 1)
                    self.assertLessEqual(circle_distance(callback(instant(got['utc'])), target), 1e-5)


@unittest.skipUnless(os.environ.get('NATAL_JPL_KERNEL'), 'NOT_RUN: NATAL_JPL_KERNEL not set')
class RealSharedModelBlindSearchTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.production = importlib.import_module('dynamic')
        kernel = pathlib.Path(os.environ['NATAL_JPL_KERNEL'])
        cls.model = cls.production.PositionModel(str(kernel), hashlib.sha256(kernel.read_bytes()).hexdigest(), {'zodiac_mode': 'tropical'})

    @classmethod
    def tearDownClass(cls):
        cls.model.close()

    def assert_canonical_boundaries(self, model, body, target, root):
        callback = lambda when: model.longitude(when, body)
        event = instant(root['utc'])
        before = math.remainder(callback(event-dt.timedelta(microseconds=1))-target, 360)
        at = math.remainder(callback(event)-target, 360)
        self.assertLess(before, 0)
        self.assertGreaterEqual(at, 0)
        for shift, count in [(-1000, 1), (-1, 1), (0, 1), (1, 0), (1000, 0)]:
            start = event+dt.timedelta(microseconds=shift)
            end = event+dt.timedelta(seconds=2)
            expected = search_crossings(callback, target, start, end)
            actual = self.production.search_events(callback, target, start, end, body)
            self.assertEqual(len(expected), count, (body, shift, 'reference'))
            self.assertEqual(len(actual), count, (body, shift, 'production'))
            if count:
                self.assertEqual(expected[0]['utc'], root['utc'])
                self.assertEqual(actual[0]['utc'], root['utc'])
        # A root is excluded when used as the upper half-open endpoint.
        self.assertEqual(search_crossings(callback, target, event-dt.timedelta(seconds=2), event), [])
        self.assertEqual(self.production.search_events(callback, target,
                         event-dt.timedelta(seconds=2), event, body), [])

    def test_blind_dates_full_window_count_time_residual_and_bracket(self):
        # UTC literals are blind inputs, not production-converted expected values.
        # IANA civil annotations follow the named tzdb source files:
        # https://data.iana.org/time-zones/tzdb/europe (London, Berlin)
        # https://data.iana.org/time-zones/tzdb/asia (Shanghai)
        # https://data.iana.org/time-zones/tzdb/australasia (Kiritimati)
        # https://data.iana.org/time-zones/tzdb/northamerica (New York)
        # Berlin's 2024-03-31 01:00Z DST transition lies inside its window.
        # Future New York offsets are conditional on the current US rules;
        # these tests verify UTC search, not future legislation or TZ conversion.
        # The API/PHP suite owns executable IANA conversion validation; this
        # reference intentionally requires no host tzdata/zoneinfo installation.
        cases = [
            ('1900-06-01T00:00:00Z', '1901-06-06T00:00:00Z',
             'Europe/London midnight GMT historical window', 'sun'),
            ('2000-02-28T16:00:00Z', '2001-03-05T16:00:00Z',
             'Asia/Shanghai 2000-02-29 midnight +08 leap-day window', 'sun'),
            ('2024-03-29T23:00:00Z', '2024-05-08T22:00:00Z',
             'Europe/Berlin Mar30 midnight CET to May09 midnight CEST', 'moon'),
            ('2024-12-19T10:00:00Z', '2025-01-28T10:00:00Z',
             'Pacific/Kiritimati Dec20 to Jan29 midnight +14', 'moon'),
            ('2100-07-01T04:00:00Z', '2100-12-18T05:00:00Z',
             'America/New_York Jul01 EDT to Dec18 EST conditional rules', 'sun'),
        ]
        for start_utc, end_utc, civil_annotation, body in cases:
            with self.subTest(start=start_utc, end=end_utc,
                              civil_annotation=civil_annotation, body=body):
                start, end = instant(start_utc), instant(end_utc)
                callback = lambda when: self.model.longitude(when, body)
                # Independent target epoch, not a known production event.
                target = callback(start-dt.timedelta(days=91, hours=7, minutes=13))
                expected = search_crossings(callback, target, start, end, 21600 if body == 'sun' else 3600)
                actual = self.production.search_events(callback, target, start, end, body)
                self.assertEqual(len(actual), len(expected))
                for got, want in zip(actual, expected):
                    self.assertEqual(got['utc'], want['utc'])
                    self.assertLessEqual(got['bracket_seconds'], .000001)
                    self.assertLessEqual(circle_distance(callback(instant(got['utc'])), target), 1e-5)
                if expected:
                    self.assert_canonical_boundaries(self.model, body, target, expected[0])

    def test_crc1956_sidereal_sun_and_moon_independent_complete_windows(self):
        kernel = pathlib.Path(os.environ['NATAL_JPL_KERNEL'])
        model = self.production.PositionModel(str(kernel), hashlib.sha256(kernel.read_bytes()).hexdigest(),
                                              {'zodiac_mode': 'sidereal'})
        try:
            # CRC1956 custom true-frame anchor, never claimed official Lahiri.
            for body, start_text, end_text in [
                    ('sun', '2000-02-28T16:00:00Z', '2001-03-05T16:00:00Z'),
                    ('moon', '2024-03-29T23:00:00Z', '2024-05-08T22:00:00Z')]:
                with self.subTest(profile='CRC1956', body=body):
                    start, end = instant(start_text), instant(end_text)
                    callback = lambda when: model.longitude(when, body)
                    target = callback(start-dt.timedelta(days=91, hours=7, minutes=13))
                    expected = search_crossings(callback, target, start, end,
                                                21600 if body == 'sun' else 3600)
                    actual = self.production.search_events(callback, target, start, end, body)
                    self.assertEqual(len(actual), len(expected))
                    for got, want in zip(actual, expected):
                        self.assertEqual(got['utc'], want['utc'])
                        self.assertLessEqual(got['bracket_seconds'], .000001)
                        self.assertLessEqual(circle_distance(callback(instant(got['utc'])), target), 1e-5)
                    self.assertTrue(expected)
                    self.assert_canonical_boundaries(model, body, target, expected[0])
        finally:
            model.close()


if __name__ == '__main__':
    unittest.main()
