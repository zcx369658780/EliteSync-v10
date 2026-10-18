"""Private derived charts, using only the admitted offline natal position model.

Return search scans the entire requested window in continuous longitude, then
bisects actual 360-degree crossings. Numerical convergence is not ephemeris
accuracy. No network, inferred second person, or relationship score.
"""
import datetime as dt
import hashlib
import json
import math
import pathlib
import sys
from contextlib import closing

import western

UTC = dt.timezone.utc
SEARCH_STEP = {'sun': 86400, 'moon': 10800}
BRACKET_SECONDS = 0.000001
RESIDUAL_DEGREES = 1e-5


def instant(value):
    result = dt.datetime.fromisoformat(value.replace('Z', '+00:00'))
    if result.tzinfo is None or result.utcoffset() != dt.timedelta(0):
        raise ValueError('explicit_utc_required')
    return result


def label(value):
    return value.astimezone(UTC).isoformat(timespec='microseconds').replace('+00:00', 'Z')


def cross_aspects(first, second, mode, orb_preset):
    # Prefixing keys retains all cross pairs, including the same named point.
    points = {**{'A:' + p['name']: p['longitude'] for p in first},
              **{'B:' + p['name']: p['longitude'] for p in second}}
    result = []
    for row in western.aspects(points, mode, orb_preset):
        if row['a'].startswith('A:') and row['b'].startswith('B:'):
            result.append({**row, 'a': row['a'][2:], 'b': row['b'][2:],
                           'a_owner': 'first', 'b_owner': 'second',
                           'source': 'geocentric_ecliptic_longitude',
                           'verification_status': 'CALCULATED_UNVERIFIED'})
    return result


def overlays(first, second):
    def direction(planets, chart):
        axes = chart.get('axes', {})
        if axes.get('status') != 'CALCULATED':
            return {'status': 'UNKNOWN', 'reason': axes.get('reason', 'houses_unavailable'), 'points': []}
        cusps = axes['cusps']
        return {'status': 'CALCULATED', 'points': [
            {'name': p['name'], 'house': western.house_for(p['longitude'], cusps)} for p in planets]}
    return {'first_in_second': direction(first.get('planets', []), second),
            'second_in_first': direction(second.get('planets', []), first)}


def search_events(position, target, start, end, body):
    """Find every crossing in [start, end), without a wrapped-sign pseudo-root.

    Sun/Moon geocentric longitudes are prograde in this admitted profile.
    Each scan interval must advance less than 90 degrees. A numerical event is
    the earliest representable datetime microsecond at the model crossing:
    f(t-1us)<0<=f(t). This also defines exact start inclusion without admitting
    an event that already passed. Historical position models can be quantized
    more coarsely than datetime; this does not assert microsecond physical truth.
    """
    if end <= start or body not in SEARCH_STEP or not math.isfinite(target):
        raise ValueError('invalid_search_window')
    target %= 360
    events = []
    left = start
    left_raw = position(start) % 360
    unwrapped = left_raw

    def emit(time, lo, hi):
        residual = abs(western.signed(position(time) - target))
        if not start <= time < end or residual > RESIDUAL_DEGREES:
            raise ArithmeticError('event_convergence_failed')
        if not events or time > instant(events[-1]['utc']):
            events.append({'utc': label(time), 'bracket_start': label(lo), 'bracket_end': label(hi),
                           'bracket_seconds': (hi - lo).total_seconds(), 'residual_degrees': residual,
                           'numerical_status': 'CONVERGED_SAME_MODEL', 'physical_accuracy': 'NOT_CERTIFIED'})

    previous = start - dt.timedelta(microseconds=1)
    f_previous = western.signed(position(previous) - target)
    f_start = western.signed(left_raw - target)
    if f_previous < 0 <= f_start and f_start - f_previous < 1:
        emit(start, previous, start)
    while left < end:
        right = min(end, left + dt.timedelta(seconds=SEARCH_STEP[body]))
        right_raw = position(right) % 360
        advance = western.signed(right_raw - left_raw)
        if not 0 < advance < 90:
            raise ArithmeticError('non_monotonic_or_underresolved_search')
        upper = unwrapped + advance
        level = target + 360 * (math.floor((unwrapped - target) / 360) + 1)
        left_delta = western.signed(left_raw - target)
        right_delta = western.signed(right_raw - target)
        if left_delta < 0 <= right_delta and right_delta - left_delta < 90:
            lo, hi = left, right
            while (hi - lo).total_seconds() > BRACKET_SECONDS:
                middle = lo + (hi - lo) / 2
                # Test the raw target residual, avoiding cumulative floating
                # cancellation changing which microsecond owns the crossing.
                if western.signed(position(middle) - target) < 0:
                    lo = middle
                else:
                    hi = middle
            # Preserve the first representable crossing, so returning its UTC
            # label and searching from that label has stable inclusive semantics.
            candidate = hi
            if candidate < end:
                emit(candidate, lo, hi)
        left, left_raw, unwrapped = right, right_raw, upper
    return events


class PositionModel:
    def __init__(self, kernel_path, expected_hash, profile):
        from skyfield.api import load, load_file
        if hashlib.sha256(pathlib.Path(kernel_path).read_bytes()).hexdigest() != expected_hash:
            raise ValueError('kernel_identity_mismatch')
        self.ts = load.timescale(builtin=True)
        self.eph = load_file(kernel_path)
        self.profile = profile

    def close(self):
        self.eph.close()

    def longitude(self, when, body):
        from skyfield.framelib import ecliptic_frame
        from time_context import resolve_time
        time, _ = resolve_time(when, self.ts)
        longitude = float(self.eph[399].at(time).observe(self.eph[10 if body == 'sun' else 301])
                          .apparent().frame_latlon(ecliptic_frame)[1].degrees)
        if self.profile['zodiac_mode'] == 'sidereal':
            longitude -= western.ayanamsha(time, self.ts)
        return longitude % 360


def compute(payload, kernel_path, expected_hash):
    kind = payload['chart_type']
    if kind not in ('synastry', 'comparison', 'transit', 'solar_return', 'lunar_return'):
        raise ValueError('unsupported_dynamic_chart_type')
    profile = payload['profile']
    # This field is supplied only by the server after matching the complete
    # first-context/runtime signature; it is never accepted from an API client.
    first = payload.get('first_calculated')
    reused = first is not None
    if first is None:
        first = western.compute({'context': payload['first'], 'profile': profile}, kernel_path, expected_hash)
    result = {'schema': 'elitesync.dynamic.v1', 'chart_type': kind, 'first': first,
              'verification_status': 'CALCULATED_UNVERIFIED', 'relationship_score': None,
              'source_model': 'v1010-admitted-offline-natal', 'events': [], 'first_cache_reused': reused}
    if kind in ('synastry', 'comparison'):
        second = western.compute({'context': payload['second'], 'profile': profile}, kernel_path, expected_hash)
    elif kind == 'transit':
        second = western.compute({'context': payload['event'], 'profile': profile}, kernel_path, expected_hash)
    else:
        body = 'sun' if kind == 'solar_return' else 'moon'
        natal_point = next((p for p in first.get('planets', []) if p['name'] == body), None)
        if natal_point is None:
            return {**result, 'status': 'UNKNOWN', 'reason': 'natal_time_unknown', 'second': None,
                    'cross_aspects': [], 'house_overlays': None}
        event = payload['event']
        start = instant(event['window_start'] if kind == 'solar_return' else event['utc'])
        end = (instant(event['window_end']) if kind == 'solar_return'
               else start + dt.timedelta(days=35))
        # The fixed accepted scientific/input domain is retained for derived times.
        if start < dt.datetime(1900, 1, 1, tzinfo=UTC) or end > dt.datetime(2101, 1, 1, tzinfo=UTC):
            return {**result, 'status': 'OUTSIDE_DATA_DOMAIN', 'second': None,
                    'cross_aspects': [], 'house_overlays': None}
        with closing(PositionModel(kernel_path, expected_hash, profile)) as model:
            candidates = search_events(lambda time: model.longitude(time, body), natal_point['longitude'], start, end, body)
        if kind == 'lunar_return':
            candidates = candidates[:1]
        result.update(events=candidates, window={'start': label(start), 'end_exclusive': label(end)},
                      target_longitude=natal_point['longitude'], start_inclusion='CANONICAL_MICROSECOND_MODEL_CROSSING',
                      time_quantization='datetime microseconds; historical UT1/model resolution may be coarser; not physical accuracy')
        for candidate in candidates:
            context = {**event, 'utc': candidate['utc'], 'time_precision': 'second'}
            candidate['chart'] = western.compute({'context': context, 'profile': profile}, kernel_path, expected_hash)
            candidate['cross_aspects'] = cross_aspects(first.get('planets', []), candidate['chart'].get('planets', []),
                                                       profile['aspect_mode'], profile['orb_preset'])
            candidate['house_overlays'] = overlays(first, candidate['chart'])
        result.update(status=('NO_EVENT' if not candidates else 'MULTIPLE_EVENTS' if len(candidates) > 1 else 'CALCULATED'),
                      second=None, cross_aspects=[], house_overlays=None,
                      selection_required=bool(candidates))
        return result
    result.update(second=second, status=('CALCULATED' if first.get('calculation_status') == 'CALCULATED'
                                         and second.get('calculation_status') == 'CALCULATED' else 'PARTIAL_UNKNOWN'),
                  cross_aspects=cross_aspects(first.get('planets', []), second.get('planets', []),
                                              profile['aspect_mode'], profile['orb_preset']),
                  house_overlays=overlays(first, second))
    return result


def main():
    try:
        if len(sys.argv) != 3:
            raise ValueError('kernel_identity_required')
        raw = sys.stdin.buffer.read(131073)
        if len(raw) > 131072:
            raise ValueError('input_too_large')
        result = compute(json.loads(raw), sys.argv[1], sys.argv[2])
        print(json.dumps(result, ensure_ascii=True, allow_nan=False))
        return 0
    except Exception:
        print(json.dumps({'status': 'ERROR', 'code': 'dynamic_calculation_unavailable'}))
        return 1


if __name__ == '__main__':
    sys.exit(main())
