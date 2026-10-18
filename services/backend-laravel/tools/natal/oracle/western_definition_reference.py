"""Standalone, non-production reference for CRC1956 custom ayanamsha and mean lunar apogee.

No production modules, private paths, network calls, or external date files are used.
"""
from __future__ import annotations
import argparse
import json
import math
from pathlib import Path
import sys
import numpy as np
import erfa

D2R = math.pi / 180.0
R2D = 180.0 / math.pi
SECONDS_PER_DAY = 86400.0
TT_LABELS = [
    '1901-01-01T00:00:00', '1904-02-29T23:59:30', '1912-06-30T00:00:30',
    '1920-12-31T23:59:59', '1933-03-20T23:59:30', '1948-02-29T00:00:30',
    '1956-03-21T00:00:00', '1969-07-20T12:34:56', '1972-06-30T23:59:30',
    '1984-02-29T12:00:00', '1999-12-31T23:59:30', '2000-01-01T00:00:30',
    '2000-02-29T23:59:59', '2001-01-01T00:00:00', '2012-12-21T00:00:30',
    '2024-02-29T23:59:30', '2038-01-19T03:14:07', '2048-06-30T23:59:59',
    '2050-01-01T00:00:30', '2064-02-29T12:00:00', '2077-11-05T23:59:30',
    '2088-02-29T00:00:30', '2099-12-31T23:59:59', '2100-01-01T00:00:00',
    '2100-03-01T00:00:30', '1956-03-20T23:59:30', '1956-03-21T00:00:30',
    '2000-03-01T00:00:00'
]

def wrap_deg(value: float) -> float:
    return value % 360.0

def tt_jd(label: str) -> tuple[float, float]:
    date, clock = label.split('T')
    year, month, day = map(int, date.split('-'))
    hour, minute, second = map(int, clock.split(':'))
    return tuple(map(float, erfa.dtf2d('TT', year, month, day, hour, minute, second)))

def true_ecliptic_to_icrs(lon_deg: float, lat_deg: float, jd1: float, jd2: float) -> np.ndarray:
    # IAU 2006 mean obliquity with IAU 2000A nutation; rotate true ecliptic
    # coordinates to true equator, then invert pnm06a to ICRS.
    eps = float(erfa.obl06(jd1, jd2)) + float(erfa.nut06a(jd1, jd2)[1])
    lam, beta = lon_deg * D2R, lat_deg * D2R
    ecl = np.array([math.cos(beta)*math.cos(lam), math.cos(beta)*math.sin(lam), math.sin(beta)])
    ce, se = math.cos(eps), math.sin(eps)
    eq_true = np.array([ecl[0], ce*ecl[1]-se*ecl[2], se*ecl[1]+ce*ecl[2]])
    return erfa.pnm06a(jd1, jd2).T @ eq_true

def icrs_to_true_ecliptic(vec: np.ndarray, jd1: float, jd2: float) -> np.ndarray:
    eps = float(erfa.obl06(jd1, jd2)) + float(erfa.nut06a(jd1, jd2)[1])
    eq = erfa.pnm06a(jd1, jd2) @ vec
    ce, se = math.cos(eps), math.sin(eps)
    return np.array([eq[0], ce*eq[1]+se*eq[2], -se*eq[1]+ce*eq[2]])

ANCHOR_JD = erfa.dtf2d('TT', 1956, 3, 21, 0, 0, 0)
ANCHOR_ICRS = true_ecliptic_to_icrs(23.25, 0.0, float(ANCHOR_JD[0]), float(ANCHOR_JD[1]))

def crc1956_custom_ayanamsha(jd1: float, jd2: float) -> float:
    vec = icrs_to_true_ecliptic(ANCHOR_ICRS, jd1, jd2)
    return wrap_deg(math.atan2(float(vec[1]), float(vec[0])) * R2D)

def mean_lunar_apogee_mean_equinox(jd1: float, jd2: float) -> float:
    # IERS/SOFA fundamental arguments: F + Omega - l + 180 deg.
    t = ((jd1 - 2451545.0) + jd2) / 36525.0
    F = float(erfa.faf03(t))
    omega = float(erfa.faom03(t))
    l = float(erfa.fal03(t))
    return wrap_deg((F + omega - l) * R2D + 180.0)

def mean_lunar_apogee_true_equinox(jd1: float, jd2: float) -> float:
    dpsi = float(erfa.nut06a(jd1, jd2)[0])
    return wrap_deg(mean_lunar_apogee_mean_equinox(jd1, jd2) + dpsi * R2D)

def central_rate(function, jd1: float, jd2: float) -> float:
    offset = 30.0 / SECONDS_PER_DAY
    before = function(jd1, jd2 - offset)
    after = function(jd1, jd2 + offset)
    delta = (after - before + 180.0) % 360.0 - 180.0
    return delta / (60.0 / SECONDS_PER_DAY)

def build_document() -> dict:
    rows = []
    for label in TT_LABELS:
        jd1, jd2 = tt_jd(label)
        rows.append({
            'tt_label': label + ' TT',
            'jd1': jd1,
            'jd2': jd2,
            'jd_tt': jd1 + jd2,
            'crc1956_custom_ayanamsha_deg': crc1956_custom_ayanamsha(jd1, jd2),
            'mean_lunar_apogee_mean_equinox_deg': mean_lunar_apogee_mean_equinox(jd1, jd2),
            'mean_lunar_apogee_true_equinox_deg': mean_lunar_apogee_true_equinox(jd1, jd2),
            'mean_equinox_rate_deg_per_tt_day': central_rate(mean_lunar_apogee_mean_equinox, jd1, jd2),
            'true_equinox_rate_deg_per_tt_day': central_rate(mean_lunar_apogee_true_equinox, jd1, jd2),
            'rate_method': 'wrapped central difference at TT +/- 30 seconds'
        })
    return {
        'schema': 'combined-western-definition-reference-v1',
        'profile': 'CRC1956 custom only; no claim of official Lahiri or equivalence to a previous application version.',
        'definitions': {
            'ayanamsha': 'ICRS-fixed direction initialized at 1956-03-21 00:00 TT, true ecliptic/equinox longitude 23.25 deg, latitude 0 deg; target true-ecliptic longitude.',
            'mean_lunar_apogee': 'wrap(F + Omega - l + 180 deg); l is lunar mean anomaly, not a subscript on Omega.',
            'true_equinox_longitude': 'mean-equinox mean apogee longitude plus target-date nutation in longitude dpsi (ERFA nut06a).',
            'mean_point_limit': 'Formal mean lunar apogee point; not physical/osculating apogee and no true node is computed.',
            'time_scale': 'TT',
            'rate': 'Wrapped central difference at TT +/- 30 seconds, degrees per TT day.'
        },
        'engine': f'PyERFA {erfa.__version__}; NumPy {np.__version__}',
        'rows': rows
    }

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, help='create a new JSON file; existing targets are never overwritten')
    args = parser.parse_args()
    payload = json.dumps(build_document(), ensure_ascii=False, indent=2, sort_keys=True) + '\n'
    if args.output is None:
        sys.stdout.write(payload)
    else:
        # Exclusive creation ensures this command cannot replace any existing file.
        with args.output.open('x', encoding='utf-8', newline='\n') as stream:
            stream.write(payload)
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
