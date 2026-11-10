"""Named geometric/mean lunar points; no Swiss or Kerykeion code/data.

Mean-apogee longitude is the IERS 2010 TN36 (5.43) combination F+Omega-l+180.
It is a mean longitude, with zero latitude as a chart convention, not the
instantaneous physical lunar apogee. All definitions travel with the output.
https://iers-conventions.obspm.fr/content/chapter5/icc5.pdf
"""
import math


def ascending_node(position, velocity):
    """Intersection of instantaneous geocentric lunar orbit plane and ecliptic.

    h = r cross v; k cross h points to the northbound intersection. Axes must
    already be in the declared ecliptic frame; no light-time is applied.
    """
    hx = position[1]*velocity[2] - position[2]*velocity[1]
    hy = position[2]*velocity[0] - position[0]*velocity[2]
    if not all(math.isfinite(float(x)) for x in (*position, *velocity)) or math.hypot(hx, hy) < 1e-30:
        raise ValueError('lunar_orbit_plane_has_no_unique_node')
    return math.degrees(math.atan2(float(hx), float(-hy))) % 360


def mean_apogee_longitude(centuries):
    """Mean ecliptic/equinox-of-date degrees, TT centuries from J2000.

    Independent coefficients formed from IERS TN36's published Delaunay
    polynomial coefficients; no production ephemeris or fixture is expected.
    """
    value = (300071.675232 + centuries*(14648449.0869 + centuries*(-37.1582 +
             centuries*(-0.044970 + centuries*0.00018948)))) / 3600 + 180
    return value % 360


def lunar_longitudes(time, ephemeris):
    from skyfield.framelib import ecliptic_frame
    from skyfield.nutationlib import iau2000a_radians
    relative = (ephemeris[301] - ephemeris[399]).at(time)
    rotation = ecliptic_frame.rotation_at(time)
    node = ascending_node(rotation @ relative.position.au, rotation @ relative.velocity.au_per_d)
    # Move the mean-longitude definition into the true equinox of date used
    # for the chart; this is a rotation of an abstract direction, not apparent
    # aberration of a physical body.
    nutation_longitude = math.degrees(float(iau2000a_radians(time)[0]))
    apogee = (mean_apogee_longitude((float(time.tt) - 2451545.0)/36525.0) + nutation_longitude) % 360
    return {'true_north_lunar_node': node, 'true_south_lunar_node': (node + 180) % 360,
            'mean_lilith': apogee}


DEFINITIONS = {
    'true_north_lunar_node': 'DE440s-instantaneous-geocentric-orbital-plane-northbound-node',
    'true_south_lunar_node': 'antipode-of-the-same-north-node; same-longitude-rate',
    'mean_lilith': 'IERS2010-F+Omega-l+180-mean-apogee-longitude; latitude-zero-chart-convention; true-equinox-rotation',
}
