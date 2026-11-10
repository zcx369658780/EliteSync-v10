"""Offline inverse of the admitted time_context profile, never a new oracle.

TT terms arrive from lunar-php, whose labels are model UT1+08, not UTC.
Keep the raw roots separately. Leap-second labels cannot be hidden by clamping.
"""
import datetime as dt
import json
import math
import sys
import warnings

import erfa
from skyfield.api import load
from time_context import resolve_time, TIME_PROFILE_VERSION, _delta_t_identity


def calendar_from_tt(parts, ts):
    if len(parts) != 2 or not all(math.isfinite(x) for x in parts):
        raise ValueError('invalid_tt_parts')
    t = ts.tt_jd(*parts)
    # The UTC introduction instant, expressed by the same forward profile.
    epoch, _ = resolve_time(dt.datetime(1960, 1, 1, tzinfo=dt.timezone.utc), ts)
    recorded = []
    if float(t - epoch) < 0:
        y, m, d, h, minute, second = t.ut1_calendar()
        interpretation = 'PRE_1960_CIVIL_LABEL_AS_UT1'
    else:
        with warnings.catch_warnings(record=True) as caught:
            warnings.simplefilter('always', erfa.ErfaWarning)
            tai1, tai2 = erfa.tttai(*parts)
            utc1, utc2 = erfa.taiutc(tai1, tai2)
            # ERFA performs UTC-aware nearest-second rounding, including :60.
            y, m, d, hms = erfa.d2dtf('UTC', 0, utc1, utc2)
        recorded = [str(w.message) for w in caught]
        h, minute = int(hms['h']), int(hms['m'])
        second = int(hms['s'])
        interpretation = ('ERFA_UTC_WITH_PRE_1972_DRIFT' if int(y) < 1972
                          else 'ERFA_UTC_WITH_LEAP_SECONDS')
    if second >= 60:
        raise ValueError('leap_second_label_not_representable')
    label = dt.datetime(int(y), int(m), int(d), int(h), int(minute), tzinfo=dt.timezone.utc)
    # Compatibility qiyun uses whole-second labels. Do not truncate negative dates.
    label += dt.timedelta(seconds=math.floor(float(second) + 0.5))
    cst = label.astimezone(dt.timezone(dt.timedelta(hours=8)))
    return dict(solar_datetime=cst.strftime('%Y-%m-%d %H:%M:%S'),
                cst_datetime=cst.isoformat(),
                normalized_instant_label=label.strftime('%Y-%m-%dT%H:%M:%SZ'),
                utc=(None if interpretation == 'PRE_1960_CIVIL_LABEL_AS_UT1'
                     else label.strftime('%Y-%m-%dT%H:%M:%SZ')),
                timestamp_frame=('model_UT1+08:00' if interpretation == 'PRE_1960_CIVIL_LABEL_AS_UT1'
                                 else 'UTC+08:00'),
                utc_interpretation=interpretation, warnings=recorded,
                rounding='nearest_second_half_up_calendar_label_not_physical_accuracy')


def compute(payload):
    ts = load.timescale(builtin=True)
    when = dt.datetime.fromisoformat(payload['utc'].replace('Z', '+00:00'))
    _, metadata = resolve_time(when, ts)
    expected = payload.get('expected_time_context')
    if expected is not None:
        # Re-resolve using actual tables; reject missing, stale or forged metadata.
        for key in ('profile_version', 'input_utc_label', 'tt_jd', 'dependencies',
                    'delta_t_model', 'active_erfa_leap_table_sha256', 'utc_interpretation'):
            if expected.get(key) != metadata.get(key):
                raise ValueError('time_context_identity_mismatch')
    terms = payload['terms']
    if not isinstance(terms, list) or not 2 <= len(terms) <= 120:
        raise ValueError('invalid_term_count')
    return dict(status='CALCULATED', profile_version=TIME_PROFILE_VERSION,
                time_context=metadata, delta_t_model=_delta_t_identity(ts),
                terms=[dict(id=x['id'], **calendar_from_tt(x['tt_jd'], ts)) for x in terms])


if __name__ == '__main__':
    try:
        raw = sys.stdin.buffer.read(131073)
        if len(raw) > 131072:
            raise ValueError('input_limit')
        print(json.dumps(compute(json.loads(raw)), ensure_ascii=False, allow_nan=False))
    except Exception:
        print(json.dumps(dict(status='ERROR', code='bazi_time_conversion_failed')))
        sys.exit(1)
