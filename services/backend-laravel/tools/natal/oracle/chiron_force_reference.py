"""Independent software implementation of the same finite physical model.

This is not an independent physical model or an observational oracle. It grants
no permission and supplies neither scientific truth nor an AC adjudication.
The caller supplies all body positions, gravitational parameters, and constants.
Units are AU, days, and gravitational parameters in AU**3/day**2.
No integrator, ephemeris, built-in body data, or external side effects are used.
"""

import numpy as np


def _array(value, name):
    """Convert a real numeric input to a finite float64 array."""
    try:
        raw = np.asarray(value)
        if raw.dtype.kind not in "iuf":
            raise ValueError(f"{name} must contain real numbers")
        result = np.asarray(raw, dtype=np.float64)
    except (TypeError, ValueError, OverflowError) as exc:
        raise ValueError(f"{name} must contain real float64-compatible numbers") from exc
    if not np.all(np.isfinite(result)):
        raise ValueError(f"{name} must contain only finite values")
    return result


def _positive_scalar(value, name):
    result = _array(value, name)
    if result.shape != () or result <= 0:
        raise ValueError(f"{name} must be a positive scalar")
    return result.item()


def accel(position, velocity, planet_positions, planet_mus, solar_mu, c_au_day):
    """Return heliocentric acceleration as a new float64 vector of shape (3,).

    ``position`` and ``velocity`` are single three-vectors. Perturber positions
    are heliocentric with shape (N, 3); their positive gravitational parameters
    have shape (N,). Empty perturbations use shapes (0, 3) and (0,).

    Implements solar Newtonian attraction, direct minus indirect Newtonian
    perturbations, and the solar first-order relativistic term specified by
    the Gaia FPR generic equations 1--4. All inputs must be finite and real;
    gravitational parameters and light speed must be strictly positive.
    Singular separations and unrepresentable arithmetic raise ValueError.
    """
    r = _array(position, "position")
    v = _array(velocity, "velocity")
    p = _array(planet_positions, "planet_positions")
    mus = _array(planet_mus, "planet_mus")
    mu = _positive_scalar(solar_mu, "solar_mu")
    c = _positive_scalar(c_au_day, "c_au_day")
    if r.shape != (3,) or v.shape != (3,):
        raise ValueError("position and velocity must each have shape (3,)")
    if p.ndim != 2 or p.shape[1] != 3:
        raise ValueError("planet_positions must have shape (N, 3)")
    if mus.shape != (p.shape[0],) or np.any(mus <= 0):
        raise ValueError("planet_mus must have shape (N,) with positive values")

    try:
        with np.errstate(over="raise", invalid="raise", divide="raise", under="ignore"):
            radius = np.hypot.reduce(r)
            if radius == 0:
                raise ValueError("position must not coincide with the Sun")
            delta = p - r
            body_radii = np.hypot.reduce(p, axis=1)
            separations = np.hypot.reduce(delta, axis=1)
            if np.any(body_radii == 0) or np.any(separations == 0):
                raise ValueError("perturbers must not coincide with the Sun or position")

            result = -mu * r / radius**3
            result = result + np.sum(
                mus[:, None]
                * (delta / separations[:, None]**3 - p / body_radii[:, None]**3),
                axis=0,
            )
            relativity = (mu / c / c / radius**3) * (
                (4 * mu / radius - np.dot(v, v)) * r
                + 4 * np.dot(r, v) * v
            )
            result = result + relativity
    except (FloatingPointError, OverflowError) as exc:
        raise ValueError("acceleration arithmetic exceeds float64 range") from exc
    if not np.all(np.isfinite(result)):
        raise ValueError("acceleration is not finite")
    return np.array(result, dtype=np.float64, copy=True)
