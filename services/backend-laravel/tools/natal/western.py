"""Offline natal geometry and Skyfield adapter; calculation is not oracle approval.

Coordinates: geocentric apparent, true ecliptic/equinox of date. Outer-planet
targets in DE440s are explicitly barycentres. No Swiss/Kerykeion dependency.
Skyfield frame API: https://rhodesmill.org/skyfield/api-framelib.html
House definitions: diurnal/nocturnal semi-arcs; independently authored here.
"""
import datetime as dt
from contextlib import closing
import hashlib
import json
import math
import pathlib
import sys


def angle(value):
    return float(value) % 360.0


def signed(value):
    return (value + 180.0) % 360.0 - 180.0


def _coordinates(longitude, obliquity):
    longitude, obliquity = map(math.radians, (longitude, obliquity))
    return (angle(math.degrees(math.atan2(math.sin(longitude) * math.cos(obliquity), math.cos(longitude)))),
            math.asin(math.sin(longitude) * math.sin(obliquity)))


def _longitude(ra, obliquity):
    ra, obliquity = map(math.radians, (ra, obliquity))
    return angle(math.degrees(math.atan2(math.sin(ra), math.cos(ra) * math.cos(obliquity))))


def houses(latitude, sidereal_degrees, obliquity, mode):
    if mode not in ('whole', 'placidus', 'alcabitius'):
        raise ValueError('unsupported_house_system')
    if not all(math.isfinite(x) for x in (latitude, sidereal_degrees, obliquity)) or abs(latitude) > 90:
        raise ValueError('invalid_geometry_input')
    phi, theta, eps = map(math.radians, (latitude, sidereal_degrees, obliquity))
    a = math.cos(phi) * math.cos(theta)
    b = math.cos(phi) * math.sin(theta) * math.cos(eps) + math.sin(phi) * math.sin(eps)
    lam = math.atan2(-a, b)
    east = -math.sin(theta) * math.cos(lam) + math.cos(theta) * math.sin(lam) * math.cos(eps)
    asc = angle(math.degrees(lam) + (180.0 if east < 0 else 0.0))
    mc = _longitude(sidereal_degrees, obliquity)
    result = dict(requested_house_system=mode, effective_house_system=mode,
                  status='CALCULATED', ascendant=asc, descendant=angle(asc + 180),
                  midheaven=mc, imum_coeli=angle(mc + 180))
    if mode == 'whole':
        result['cusps'] = [angle(math.floor(asc / 30) * 30 + 30 * i) for i in range(12)]
        return result

    def semi_arc(declination):
        value = -math.tan(phi) * math.tan(declination)
        if abs(value) >= 1.0:
            raise ArithmeticError('circumpolar_semiarc')
        return math.degrees(math.acos(value))

    try:
        asc_ra, asc_dec = _coordinates(asc, obliquity)
        arc = semi_arc(asc_dec)
        cusps = {1: asc, 4: angle(mc + 180), 7: angle(asc + 180), 10: mc}
        if mode == 'alcabitius':
            for house, ra in ((11, sidereal_degrees + arc / 3), (12, sidereal_degrees + 2 * arc / 3),
                              (9, sidereal_degrees - (180 - arc) / 3), (8, sidereal_degrees - 2 * (180 - arc) / 3)):
                cusps[house] = _longitude(ra, obliquity)
        else:
            # A cusp divides its own declination's semi-diurnal arc, not the ASC's.
            def root(fraction, direction):
                span = angle(asc - mc) if direction == 1 else angle(mc - cusps[7])
                if not 0 < span < 180:
                    raise ArithmeticError('no_upper_quadrant')
                def value(distance):
                    ra, dec = _coordinates(angle(mc + direction * distance), obliquity)
                    return direction * signed(ra - sidereal_degrees) - fraction * semi_arc(dec)
                lo, hi = 0.0, span
                fl, fh = value(lo), value(hi)
                if fl * fh > 0:
                    raise ArithmeticError('cusp_not_bracketed')
                for _ in range(70):
                    mid = (lo + hi) / 2
                    fm = value(mid)
                    if fl * fm <= 0:
                        hi = mid
                    else:
                        lo, fl = mid, fm
                return angle(mc + direction * ((lo + hi) / 2))
            cusps.update({11: root(1/3, 1), 12: root(2/3, 1), 9: root(1/3, -1), 8: root(2/3, -1)})
        for upper, lower in ((11, 5), (12, 6), (9, 3), (8, 2)):
            cusps[lower] = angle(cusps[upper] + 180)
        result['cusps'] = [cusps[i] for i in range(1, 13)]
        if any(not 0 < angle(result['cusps'][(i+1) % 12] - result['cusps'][i]) < 180 for i in range(12)):
            raise ArithmeticError('non_monotonic_cusps')
        return result
    except ArithmeticError:
        return dict(status='NOT_APPLICABLE', reason='house_geometry_not_applicable',
                    requested_house_system=mode, effective_house_system=None)


def house_for(longitude, cusps):
    for index, start in enumerate(cusps):
        if angle(longitude - start) < angle(cusps[(index+1) % 12] - start):
            return index + 1
    raise ValueError('invalid_house_cusps')


def aspects(points, mode, orb_preset):
    definitions = [('conjunction', 0), ('sextile', 60), ('square', 90), ('trine', 120), ('opposition', 180)]
    if mode not in ('major', 'standard', 'extended') or orb_preset not in ('tight', 'standard', 'wide'):
        raise ValueError('invalid_aspect_profile')
    if mode in ('standard', 'extended'):
        definitions += [('quincunx', 150)]
    if mode == 'extended':
        definitions += [('semisextile', 30), ('semisquare', 45), ('sesquiquadrate', 135)]
    orb = {'tight': 3.0, 'standard': 6.0, 'wide': 8.0}[orb_preset]
    names = list(points)
    out = []
    for i, a in enumerate(names):
        for b in names[i+1:]:
            separation = abs(signed(points[a] - points[b]))
            for kind, exact in definitions:
                deviation = abs(separation - exact)
                effective_orb = min(orb, 3.0) if exact in (30, 45, 135, 150) else orb
                if deviation <= effective_orb:
                    out.append(dict(a=a, b=b, type=kind, angle=exact, separation=separation,
                                    deviation=deviation, orb=effective_orb, boundary='inclusive'))
    return out


def ayanamsha(time, timescale):
    """A fixed inertial zodiac anchored at CRC's published 1956 23d15m.

    The explicit true-of-date frame convention is our named profile, not a
    claim of bitwise identity with every modern product called 'Lahiri'.
    Reference: IMD Positional Astronomy Centre, Panchang explanation.
    """
    import numpy as np
    from skyfield.framelib import ecliptic_frame
    anchor = timescale.tt(1956, 3, 21, 0)
    longitude = math.radians(23.25)
    fixed = ecliptic_frame.rotation_at(anchor).T @ np.array([math.cos(longitude), math.sin(longitude), 0.0])
    projected = ecliptic_frame.rotation_at(time) @ fixed
    return angle(math.degrees(math.atan2(float(projected[1]), float(projected[0]))))


def _ut1_datetime(when, time_metadata):
    """Use the declared UT1 label directly before UTC existed; preserve NULL DUT1."""
    label = when.replace(tzinfo=None)
    if time_metadata.get('utc_interpretation') == 'PRE_1960_CIVIL_LABEL_AS_UT1':
        return label
    dut1 = time_metadata.get('dut1_seconds')
    if dut1 is None:
        raise ValueError('ut1_time_metadata_missing')
    return label + dt.timedelta(seconds=dut1)


def compute(payload, kernel_path, expected_sha256):
    from skyfield.api import load, load_file
    from skyfield.framelib import ecliptic_frame
    from time_context import resolve_time
    from lunar_points import lunar_longitudes, DEFINITIONS

    path = pathlib.Path(kernel_path)
    actual_hash = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual_hash != expected_sha256:
        raise ValueError('kernel_identity_mismatch')
    context = payload['context']
    profile = payload['profile']
    if context.get('utc') is None or context.get('time_precision') == 'unknown':
        return dict(calculation_status='UNKNOWN', reason='birth_time_unknown', oracle_status='UNVERIFIED',
                    planets=[], houses=[], aspects=[], requested_profile=profile)
    when = dt.datetime.fromisoformat(context['utc'].replace('Z', '+00:00'))
    if when.tzinfo is None or when.utcoffset() != dt.timedelta(0):
        raise ValueError('explicit_utc_required')
    latitude, longitude = context.get('latitude'), context.get('longitude')
    if latitude is not None and (not math.isfinite(latitude) or abs(latitude) > 90):
        raise ValueError('invalid_latitude')
    if longitude is not None and (not math.isfinite(longitude) or abs(longitude) > 180):
        raise ValueError('invalid_longitude')
    zodiac = profile.get('zodiac_mode', 'tropical')
    if zodiac not in ('tropical', 'sidereal'):
        raise ValueError('unsupported_zodiac_mode')
    ts = load.timescale(builtin=True)
    t, time_metadata = resolve_time(when, ts)
    before_time = ts.tt_jd(t.whole, t.tt_fraction - 30/86400)
    after_time = ts.tt_jd(t.whole, t.tt_fraction + 30/86400)
    offset = ayanamsha(t, ts) if zodiac == 'sidereal' else 0.0
    with closing(load_file(str(path))) as eph:
        earth = eph[399]
        # Target IDs are part of the calculation contract; never call a barycentre a centre.
        bodies = {'sun': 10, 'moon': 301, 'mercury': 199, 'venus': 299,
                  'mars': 4, 'jupiter': 5, 'saturn': 6, 'uranus': 7, 'neptune': 8, 'pluto': 9}
        planets = []
        for name, target in bodies.items():
            def at(time):
                position = earth.at(time).observe(eph[target]).apparent()
                lat, lon, distance = position.frame_latlon(ecliptic_frame)
                value = float(lon.degrees)
                if zodiac == 'sidereal':
                    value = angle(value - ayanamsha(time, ts))
                return value, float(lat.degrees), float(distance.au)
            lon, lat, distance = at(t)
            before = at(before_time)[0]
            after = at(after_time)[0]
            speed = signed(after - before) * 1440.0
            planets.append(dict(name=name, longitude=lon, latitude=lat, distance_au=distance,
                                sign_index=int(lon // 30), degree=lon % 30, speed_degrees_per_day=speed,
                                retrograde=speed < 0, target_id=target,
                                target_kind='barycentre' if 4 <= target <= 9 else 'body_centre'))
        point_set = profile.get('point_set', 'core')
        if point_set not in ('core', 'extended', 'full'):
            raise ValueError('unsupported_point_set')
        missing = []
        if point_set != 'core':
            now = lunar_longitudes(t, eph)
            previous = lunar_longitudes(before_time, eph)
            following = lunar_longitudes(after_time, eph)
            for name in (['true_north_lunar_node', 'true_south_lunar_node'] +
                         (['mean_lilith'] if point_set == 'full' else [])):
                value = angle(now[name] - offset)
                before_offset = ayanamsha(before_time, ts) if zodiac == 'sidereal' else 0
                after_offset = ayanamsha(after_time, ts) if zodiac == 'sidereal' else 0
                speed = signed((following[name] - after_offset) - (previous[name] - before_offset)) * 1440
                planets.append(dict(name=name, longitude=value, latitude=0.0, distance_au=None,
                    sign_index=int(value//30), degree=value % 30, speed_degrees_per_day=speed,
                    retrograde=speed < 0, target_kind='defined_lunar_direction',
                    definition=DEFINITIONS[name], oracle_status='UNVERIFIED'))
        if point_set == 'full':
            from chiron_orbit import ChironOrbit, ChironVector
            resources = pathlib.Path(__file__).resolve().parents[2] / 'resources/natal'
            manifest_bytes = (resources / 'chiron-data-manifest.json').read_bytes()
            manifest = json.loads(manifest_bytes)
            if (manifest.get('schema') != 'elitesync.chiron.data.v1'
                    or manifest.get('rights_status') != 'ADMITTED_FOR_CLOSED_SOURCE_COMPUTATION_WITH_ATTRIBUTION'
                    or manifest.get('profile') != 'lowell-astorb2060-dop54-hermite8d-v1'
                    or manifest.get('artifact') != 'resources/natal/data/chiron-lowell-hermite8d-v1.npz'):
                raise ValueError('chiron_data_admission_missing')
            # The file is local, fixed, and separately permission-admitted.
            # No remote or restricted-engine fallback is attempted on failure.
            orbit = ChironOrbit(resources / 'data/chiron-lowell-hermite8d-v1.npz', manifest['artifact_sha256'])
            target = eph[10] + ChironVector(orbit)
            def chiron_at(time):
                position = earth.at(time).observe(target).apparent()
                latitude, longitude, distance = position.frame_latlon(ecliptic_frame)
                value = float(longitude.degrees)
                if zodiac == 'sidereal':
                    value = angle(value - ayanamsha(time, ts))
                return value, float(latitude.degrees), float(distance.au)
            value, chiron_latitude, distance = chiron_at(t)
            speed = signed(chiron_at(after_time)[0] - chiron_at(before_time)[0]) * 1440
            planets.append(dict(name='chiron', longitude=value, latitude=chiron_latitude, distance_au=distance,
                sign_index=int(value // 30), degree=value % 30, speed_degrees_per_day=speed,
                retrograde=speed < 0, target_id=2002060, target_kind='derived_small_body_centre',
                definition='Lowell astorb2060 finite-force trajectory; geocentric apparent true ecliptic of date',
                data_profile=manifest['profile'], data_sha256=manifest['artifact_sha256'],
                data_manifest_sha256=hashlib.sha256(manifest_bytes).hexdigest(),
                reference_status='INDEPENDENT_SAMPLED_REFERENCE_MATCH',
                oracle_status='UNVERIFIED',
                source_attribution='Lowell Observatory; L.H. Wasserman; NASA NAG5-4741, NNX16AG52G; Lowell endowment',
                source_notice='resources/natal/notices/Lowell-astorb-Chiron-ATTRIBUTION.txt'))
        # True obliquity used by the same true-of-date coordinate frame.
        eps = float(t._mean_obliquity_radians + t._nutation_angles_radians[1])
        house = (houses(latitude, float(t.gast) * 15.0 + longitude, math.degrees(eps), profile.get('house_system', 'placidus'))
                 if latitude is not None and longitude is not None else
                 dict(status='UNKNOWN', reason='coordinates_unknown', requested_house_system=profile.get('house_system', 'placidus'), effective_house_system=None))
        rows = []
        if house.get('status') == 'CALCULATED':
            if zodiac == 'sidereal':
                for key in ('ascendant', 'descendant', 'midheaven', 'imum_coeli'):
                    house[key] = angle(house[key] - offset)
                house['cusps'] = ([angle(math.floor(house['ascendant']/30)*30+30*i) for i in range(12)]
                                  if profile.get('house_system', 'placidus') == 'whole' else
                                  [angle(x - offset) for x in house['cusps']])
            rows = [dict(number=i+1, cusp=x, sign_index=int(x // 30)) for i, x in enumerate(house['cusps'])]
            for planet in planets:
                planet['house'] = house_for(planet['longitude'], house['cusps'])
        solar = None
        if longitude is not None:
            ra = earth.at(t).observe(eph[10]).apparent().radec(epoch='date')[0].hours
            apparent_hours = ((float(t.gast) + longitude / 15 - ra) + 12) % 24
            ut1 = _ut1_datetime(when, time_metadata)
            ut1_hours = ut1.hour + ut1.minute / 60 + (ut1.second + ut1.microsecond / 1e6) / 3600
            mean_hours = (ut1_hours + longitude / 15) % 24
            eot_hours = ((apparent_hours - mean_hours + 12) % 24) - 12
            effective = ut1 + dt.timedelta(hours=longitude / 15 + eot_hours)
            solar = dict(effective_solar_date=effective.date().isoformat(), effective_solar_time=effective.time().isoformat(timespec='seconds'),
                         equation_of_time_seconds=float(eot_hours * 3600), source='geocentric_apparent_sun_hour_angle',
                         ut1_utc_seconds=time_metadata['dut1_seconds'], status='CALCULATED')
        result = dict(calculation_status='PARTIAL_UNVERIFIED' if missing else 'CALCULATED',
                    oracle_status='UNVERIFIED', engine='skyfield', engine_version='1.55',
                    data_sha256=actual_hash, coordinate_frame='geocentric_apparent_true_ecliptic_of_date',
                    time_context=time_metadata, requested_profile=profile,
                    effective_profile={**profile, 'point_set': 'PARTIAL_FULL' if missing else point_set},
                    sidereal_reference=(dict(id='CRC1956-23.25-true-frame-anchor-IAU2000A-v1',
                                             display_name_zh='CRC1956 自定义恒星黄道（非官方 Lahiri）',
                                             standard_status='CUSTOM_NAMED_RECONSTRUCTION_NOT_OFFICIAL_LAHIRI',
                                             anchor_tt='1956-03-21T00:00:00', anchor_degrees=23.25,
                                             ayanamsha_degrees=offset, oracle_status='UNVERIFIED')
                                        if zodiac == 'sidereal' else None), planets=planets, houses=rows,
                    axes=house, aspects=aspects({x['name']: x['longitude'] for x in planets}, profile.get('aspect_mode', 'major'), profile.get('orb_preset', 'standard')),
                    solar_context=solar, unavailable_points=missing,
                    extensions_status='PARTIAL_FULL' if missing else ('NOT_REQUESTED' if point_set == 'core' else 'CALCULATED_UNVERIFIED'),
                    note='Calculation only; independent reference coverage and original extended points remain pending; not AC-10-05 PASS')
    return result


def main():
    try:
        if len(sys.argv) != 3:
            raise ValueError('kernel_path_and_hash_required')
        raw = sys.stdin.buffer.read(65537)
        if len(raw) > 65536:
            raise ValueError('input_too_large')
        result = compute(json.loads(raw), sys.argv[1], sys.argv[2])
        # JSON crosses a PHP subprocess boundary. ASCII escapes preserve Unicode
        # values without inheriting Windows' legacy stdout code page.
        print(json.dumps(result, ensure_ascii=True, allow_nan=False))
    except Exception:
        print(json.dumps(dict(calculation_status='ERROR', code='natal_calculation_failed')))
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
