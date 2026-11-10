"""Independent v10.0.11 geometry and complete-window event-search reference.

No production search or geometry is imported here. Position callbacks may share
DE440s/Skyfield/ERFA with production: agreement then proves numerical search and
geometry, NOT independent physical ephemeris accuracy. Sampling assumes continuous
longitude with less than 90 degrees travel per interval and no unresolved reversal;
Sun/Moon return searches use a conservative one-hour grid. Tangent contacts and
arbitrarily oscillatory callbacks are outside this reference contract.
"""
import argparse
import datetime as dt
import json
import math

UTC = dt.timezone.utc
DEFINITIONS = {'conjunction': 0, 'sextile': 60, 'square': 90,
               'trine': 120, 'opposition': 180}


def circle_distance(a, b):
    raw = abs(float(a) - float(b)) % 360
    return min(raw, 360 - raw)


def cross_aspects(first, second, mode='major', orb_preset='standard', inclusive=True):
    definitions = dict(DEFINITIONS)
    if mode not in ('major', 'standard', 'extended'):
        raise ValueError('invalid_aspect_mode')
    if mode != 'major':
        definitions['quincunx'] = 150
    if mode == 'extended':
        definitions.update(semisextile=30, semisquare=45, sesquiquadrate=135)
    limit = {'tight': 3., 'standard': 6., 'wide': 8.}[orb_preset]
    result = []
    for a in first:
        for b in second:
            separation = circle_distance(a['longitude'], b['longitude'])
            for kind, exact in definitions.items():
                orb = min(limit, 3.) if exact in (30, 45, 135, 150) else limit
                deviation = abs(separation - exact)
                if deviation < orb or (inclusive and deviation == orb):
                    result.append(dict(a=a['name'], b=b['name'], type=kind,
                                       angle=exact, separation=separation,
                                       deviation=deviation, orb=orb))
    return result


def overlay_houses(points, cusps):
    """Independent sorted unwrapped cusp intervals; exact cusp belongs ahead."""
    if len(cusps) != 12 or not all(math.isfinite(x) for x in cusps):
        raise ValueError('invalid_cusps')
    start = cusps[0] % 360
    offsets = [(c - start) % 360 for c in cusps]
    if offsets != sorted(set(offsets)) or offsets[0] != 0:
        raise ValueError('invalid_cusps')
    out = []
    for p in points:
        offset = (p['longitude'] - start) % 360
        house = sum(offset >= cusp for cusp in offsets)
        out.append(dict(name=p['name'], house=house))
    return out


def _utc(value):
    if not isinstance(value, dt.datetime) or value.tzinfo is None or value.utcoffset() != dt.timedelta(0):
        raise ValueError('aware_utc_required')
    return value


def _iso(value):
    return value.isoformat(timespec='microseconds').replace('+00:00', 'Z')


def search_crossings(position, target, start, end, step_seconds=3600):
    """Enumerate integer-cycle crossings throughout [start,end), independently.

    No epsilon extends either domain edge. A small positive residual at start
    cannot create a preceding root. Exceptions/nonfinite values fail explicitly.
    Event definition CANONICAL_MICROSECOND_MODEL_CROSSING: emit the earliest
    datetime grid point whose oriented model residual is nonnegative, with
    negative residual one microsecond earlier. Historic UT1 model quantization
    (about 40 microseconds) is retained; this is not physical microsecond accuracy.
    """
    _utc(start)
    _utc(end)
    if not start < end or not math.isfinite(target) or not 0 < step_seconds <= 86400:
        raise ValueError('invalid_search_domain')
    span = end - start
    duration = (span.days * 86400 + span.seconds) * 1000000 + span.microseconds
    step = int(step_seconds * 1000000)
    if step < 1:
        raise ValueError('invalid_search_step')

    def read(microseconds):
        value = float(position(start + dt.timedelta(microseconds=microseconds)))
        if not math.isfinite(value):
            raise ValueError('nonfinite_position')
        return value % 360

    def delta(a, b):
        jump = b - a
        return jump - 360 * math.floor((jump + 180) / 360)

    target %= 360
    raw = read(0)
    phase = raw
    t = 0
    roots = []

    def append(lo, hi, root):
        when = start + dt.timedelta(microseconds=root)
        if not start <= when < end:
            return
        if roots and _iso(when) == roots[-1]['utc']:
            return
        residual = circle_distance(read(root), target)
        if residual > 1e-5:
            raise ArithmeticError('reference_residual_not_met')
        roots.append(dict(utc=_iso(when), bracket_start=_iso(start + dt.timedelta(microseconds=lo)),
                          bracket_end=_iso(start + dt.timedelta(microseconds=hi)),
                          bracket_seconds=(hi-lo)/1000000, residual_degrees=residual,
                          event_definition='CANONICAL_MICROSECOND_MODEL_CROSSING'))

    initial = delta(target, raw)
    previous = delta(target, read(-1))
    if abs(initial-previous) < 90 and (previous < 0 <= initial or previous > 0 >= initial):
        append(-1, 0, 0)
    while t < duration:
        next_t = min(duration, t + step)
        next_raw = read(next_t)
        travel = delta(raw, next_raw)
        if abs(travel) >= 90:
            raise ValueError('reference_sampling_too_coarse')
        next_phase = phase + travel
        lower, upper = sorted((phase, next_phase))
        # Include adjacent cycle candidates, then validate using raw callback
        # residuals. Summed phase rounding must not lose an exact endpoint zero.
        for cycle in range(math.floor((lower-target)/360), math.ceil((upper-target)/360)+1):
            level = target + 360*cycle
            if phase == next_phase or abs(level-phase) >= 90:
                continue
            direction = 1 if travel > 0 else -1
            first_residual = direction * delta(target, raw)
            last_residual = direction * delta(target, next_raw)
            if not first_residual < 0 <= last_residual or abs(last_residual-first_residual) >= 90:
                continue
            lo, hi = t, next_t
            while hi-lo > 1:
                mid = (lo+hi)//2
                fm = direction * delta(target, read(mid))
                if fm < 0:
                    lo = mid
                else:
                    hi = mid
            if not direction * delta(target, read(lo)) < 0 <= direction * delta(target, read(hi)):
                raise ArithmeticError('reference_crossing_not_bracketed')
            append(lo, hi, hi)
        t, raw, phase = next_t, next_raw, next_phase
    return roots


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--start', required=True)
    parser.add_argument('--end', required=True)
    parser.add_argument('--target', type=float, required=True)
    parser.add_argument('--initial', type=float, default=0.)
    parser.add_argument('--degrees-per-day', type=float, default=1.)
    parser.add_argument('--kernel', help='Optional local approved kernel; shares production position layer only')
    parser.add_argument('--kernel-sha256')
    parser.add_argument('--body', choices=('sun', 'moon'), default='sun')
    args = parser.parse_args()
    start = dt.datetime.fromisoformat(args.start.replace('Z', '+00:00'))
    end = dt.datetime.fromisoformat(args.end.replace('Z', '+00:00'))
    model = None
    try:
        if args.kernel:
            import pathlib
            import sys
            if not args.kernel_sha256:
                parser.error('--kernel-sha256 required with --kernel')
            sys.path.insert(0, str(pathlib.Path(__file__).parents[1]))
            from dynamic import PositionModel
            model = PositionModel(args.kernel, args.kernel_sha256, {'zodiac_mode': 'tropical'})
            callback = lambda when: model.longitude(when, args.body)
        else:
            callback = lambda when: args.initial + (when-start).total_seconds()/86400*args.degrees_per_day
        events = search_crossings(callback, args.target, start, end)
    finally:
        if model is not None:
            model.close()
    print(json.dumps(dict(reference='independent-unwrapped-cycle-bisection-v1',
                         scope='shared_position_model_numerics_not_physical_truth' if args.kernel else
                               'synthetic_numerics_not_physical_truth', events=events)))


if __name__ == '__main__':
    main()
