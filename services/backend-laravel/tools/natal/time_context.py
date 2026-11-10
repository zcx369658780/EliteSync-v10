"""Explicit civil-UTC/UT1 -> TT conversion for offline natal calculations.

Before UTC existed, a timezone-normalized civil label is interpreted as UT1.
This is a declared historical approximation, not an assertion of atomic UTC.
Python datetime cannot represent the literal leap-second label 23:59:60.
"""
import datetime as dt
import hashlib
import warnings

import erfa
import skyfield

PYERFA_VERSION = '2.0.1.5'
SKYFIELD_VERSION = '1.55'
UTC_INTRODUCED = dt.date(1960, 1, 1)
TIME_PROFILE_VERSION = 'v1010-erfa-utc-ut1-1'
TIME_TABLE_AUDIT_DATE = dt.date(2026, 10, 17)
OFFICIAL_TIME_STANDARD_SOURCES = {
    'erfa_utc_tai': 'https://github.com/liberfa/erfa/blob/v2.0.1/src/utctai.c',
    'erfa_historical_utc': 'https://github.com/liberfa/erfa/blob/v2.0.1/src/dat.c',
    'erfa_calendar_utc': 'https://github.com/liberfa/erfa/blob/v2.0.1/src/dtf2d.c',
    'erfa_tai_tt': 'https://github.com/liberfa/erfa/blob/v2.0.1/src/taitt.c',
    'sofa_time_manual': 'https://www.iausofa.org/timetools',
    'skyfield_time': 'https://rhodesmill.org/skyfield/time.html',
    'skyfield_delta_t': 'https://github.com/skyfielders/python-skyfield/blob/1.55/skyfield/timelib.py',
}


def _parts(whole, fraction):
    return [float(whole), float(fraction)]


def _delta_t_identity(timescale):
    """Fingerprint the actual caller's table; do not silently call it builtin."""
    model = timescale.delta_t_function
    identity = {
        'implementation': type(model).__module__ + '.' + type(model).__name__,
        'skyfield_version': skyfield.__version__,
        'status': 'MODEL_NOT_OBSERVED_DUT1',
        'source': OFFICIAL_TIME_STANDARD_SOURCES['skyfield_delta_t'],
    }
    if hasattr(model, 'table_tt') and hasattr(model, 'table_delta_t'):
        digest = hashlib.sha256()
        for array in (model.table_tt, model.table_delta_t):
            digest.update(array.astype('<f8').tobytes())
        identity['recent_table_sha256'] = digest.hexdigest()
        identity['recent_table_tt_jd_range'] = [float(model.table_tt[0]),
                                               float(model.table_tt[-1])]
        identity['long_term_implementation'] = type(model.long_term_function).__name__
    else:
        identity['recent_table_sha256'] = None
        identity['caller_supplied_override'] = True
    return identity


def resolve_time(when, timescale):
    """Return (Skyfield Time, provenance) for an aware zero-offset datetime.

    UT1 comes from Skyfield's caller-supplied Delta-T model, not a live IERS
    measurement. Post-1960 TT uses ERFA UTC quasi-JD -> TAI -> TT, including
    the pre-1972 non-SI UTC seconds. Dubious future years remain computable
    under an explicit unchanged-leap-table assumption and are never verified.
    """
    if not isinstance(when, dt.datetime) or when.tzinfo is None or when.utcoffset() != dt.timedelta(0):
        raise ValueError('aware_utc_datetime_required')
    if erfa.__version__ != PYERFA_VERSION or skyfield.__version__ != SKYFIELD_VERSION:
        raise RuntimeError('time_dependency_version_mismatch')

    seconds = when.hour * 3600 + when.minute * 60 + when.second + when.microsecond / 1e6
    nominal_jd = when.toordinal() + 1721424.5 + seconds / 86400
    metadata = {
        'profile_version': TIME_PROFILE_VERSION,
        'input_utc_label': when.isoformat(),
        'dependencies': {'pyerfa': erfa.__version__, 'erfa': erfa.version.erfa_version,
                         'sofa': erfa.version.sofa_version, 'skyfield': skyfield.__version__},
        'sources': dict(OFFICIAL_TIME_STANDARD_SOURCES),
        'delta_t_model': _delta_t_identity(timescale),
        'future_leap_seconds_actual': 'UNKNOWN',
        'future_utc_assumption': 'Use active ERFA table; no additional unlisted leap seconds assumed.',
        'time_table_audit_date': TIME_TABLE_AUDIT_DATE.isoformat(),
        'erfa_dubious_year': False,
        'warnings': [],
    }

    if when.date() < UTC_INTRODUCED:
        instant = timescale.ut1_jd(nominal_jd)
        metadata.update(utc_interpretation='PRE_1960_CIVIL_LABEL_AS_UT1',
                        tai_minus_utc_seconds=None, dut1_seconds=None,
                        accuracy_status='HISTORICAL_UT1_INTERPRETATION',
                        utc_quasi_jd=None)
    else:
        with warnings.catch_warnings(record=True) as recorded:
            warnings.simplefilter('always', erfa.ErfaWarning)
            utc1, utc2 = erfa.dtf2d('UTC', when.year, when.month, when.day,
                                  when.hour, when.minute, when.second + when.microsecond / 1e6)
            tai1, tai2 = erfa.utctai(utc1, utc2)
            tt1, tt2 = erfa.taitt(tai1, tai2)
            delta_at = float(erfa.dat(when.year, when.month, when.day, seconds / 86400))
        # Keep TT as two JD parts; summing them first loses sub-millisecond precision.
        instant = timescale.tt_jd(tt1, tt2)
        metadata['warnings'] = [str(item.message) for item in recorded]
        metadata['erfa_dubious_year'] = any('dubious year' in item.lower()
                                            for item in metadata['warnings'])
        leap_table = erfa.leap_seconds.get()
        metadata['active_erfa_leap_table_sha256'] = hashlib.sha256(leap_table.tobytes()).hexdigest()
        metadata['active_erfa_last_entry'] = {
            'year': int(leap_table[-1]['year']), 'month': int(leap_table[-1]['month']),
            'tai_minus_utc_seconds': float(leap_table[-1]['tai_utc']),
        }
        metadata.update(
            utc_interpretation=('ERFA_UTC_WITH_PRE_1972_DRIFT' if when.year < 1972
                                else 'ERFA_UTC_WITH_LEAP_SECONDS'),
            utc_quasi_jd=_parts(utc1, utc2),
            tai_jd=_parts(tai1, tai2), tai_minus_utc_seconds=delta_at,
            # Skyfield Time.dut1 uses its leap table, which omits rubber seconds.
            dut1_seconds=delta_at + 32.184 - float(instant.delta_t),
            accuracy_status=('FUTURE_ASSUMPTION' if when.date() > TIME_TABLE_AUDIT_DATE
                             or metadata['erfa_dubious_year'] else 'HISTORICAL_UTC_MODEL_UT1'))

    metadata.update(tt_jd=_parts(instant.whole, instant.tt_fraction),
                    ut1_jd=_parts(instant.whole, instant.ut1_fraction),
                    delta_t_seconds=float(instant.delta_t),
                    dut1_source='TT_MINUS_SKYFIELD_DELTA_T_NOT_LIVE_EOP')
    return instant, metadata
