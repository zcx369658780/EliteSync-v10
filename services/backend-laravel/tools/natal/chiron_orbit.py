"""Numerical interpolation of an independently derived Chiron orbit.

This reader neither proves physical accuracy nor grants a data licence. Its
metadata gates check declarations already admitted by the caller's governance
process; they do not constitute an independent legal assessment. No data is
downloaded, generated, or connected to a production calculation here.
"""

from __future__ import annotations

import hashlib
import io
import json
from pathlib import Path
import re

import numpy as np
from skyfield.vectorlib import VectorFunction


_KEYS = {"offset_days", "states", "origin_tdb_jd", "metadata_utf8"}
_PROFILE = "lowell-astorb2060-dop54-hermite8d-v1"
_RIGHTS_STATUS = "ADMITTED_FOR_CLOSED_SOURCE_COMPUTATION_WITH_ATTRIBUTION"


def _real_array(value, name):
    """Accept only finite, real numeric arrays, without object coercion."""
    array = np.asarray(value)
    if array.dtype.kind not in "iuf":
        raise ValueError(f"{name} must contain real numeric values")
    with np.errstate(over="ignore", invalid="ignore"):
        array = np.asarray(array, dtype=np.float64)
    if not np.all(np.isfinite(array)):
        raise ValueError(f"{name} must contain only finite values")
    return array


def _immutable(array):
    # Immutable bytes also prevent callers from re-enabling the write flag.
    return np.frombuffer(array.tobytes(), dtype=np.float64).reshape(array.shape)


def _json_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("metadata contains duplicate JSON keys")
        result[key] = value
    return result


def _invalid_json_constant(value):
    raise ValueError(f"metadata contains a non-finite JSON constant: {value}")


def _finite_json_float(value):
    parsed = float(value)
    if not np.isfinite(parsed):
        raise ValueError("metadata contains a non-finite JSON number")
    return parsed


def _hermite(p0, v0, p1, v1, h, u):
    """Return position and its analytic velocity for one Hermite polynomial.

    Inputs follow NumPy broadcasting; callers provide a final coordinate axis
    for position/velocity and matching singleton axes for ``h`` and ``u``.
    Units are AU, AU/day, and days.
    """
    u2 = u * u
    u3 = u2 * u
    position = (
        (2 * u3 - 3 * u2 + 1) * p0
        + (u3 - 2 * u2 + u) * h * v0
        + (-2 * u3 + 3 * u2) * p1
        + (u3 - u2) * h * v1
    )
    velocity = (
        (6 * u2 - 6 * u) * p0 / h
        + (3 * u2 - 4 * u + 1) * v0
        + (-6 * u2 + 6 * u) * p1 / h
        + (3 * u2 - 2 * u) * v1
    )
    return position, velocity


class ChironOrbit:
    """Read a hash-pinned, admitted NPZ and interpolate heliocentric ICRF states.

    ``state(tdb_jd)`` returns AU positions followed by AU/day velocities. The
    accepted interval is closed at both endpoints; extrapolation is forbidden.
    Missing files, hashes, format versions, and admission declarations fail
    closed by raising an exception.
    """

    def __init__(self, path, expected_sha256):
        if not isinstance(expected_sha256, str) or not re.fullmatch(
            r"[0-9a-fA-F]{64}", expected_sha256
        ):
            raise ValueError("expected_sha256 must be a 64-character SHA-256 hex digest")
        payload = Path(path).read_bytes()
        if hashlib.sha256(payload).hexdigest() != expected_sha256.lower():
            raise ValueError("Chiron orbit SHA-256 mismatch")

        # Load the very bytes whose hash was verified, never reopen the path.
        archive = np.load(io.BytesIO(payload), allow_pickle=False)
        if not isinstance(archive, np.lib.npyio.NpzFile):
            raise ValueError("Chiron orbit must be an NPZ archive")
        with archive:
            if len(archive.files) != len(_KEYS) or set(archive.files) != _KEYS:
                raise ValueError("Chiron orbit archive has unexpected keys")
            offsets = _real_array(archive["offset_days"], "offset_days")
            states = _real_array(archive["states"], "states")
            origin = archive["origin_tdb_jd"]
            metadata_bytes = archive["metadata_utf8"]

            if offsets.ndim != 1 or not 2 <= offsets.size <= 15000:
                raise ValueError("offset_days must have shape (N,), with 2 <= N <= 15000")
            if states.shape != (offsets.size, 6):
                raise ValueError("states must have shape (N, 6)")
            with np.errstate(over="ignore", invalid="ignore"):
                steps = np.diff(offsets)
            if not np.all(np.isfinite(steps) & (steps > 0) & (steps <= 8.000001)):
                raise ValueError("offset_days must strictly increase by at most 8.000001 days")
            if origin.shape != () or origin.dtype.kind != "f":
                raise ValueError("origin_tdb_jd must be a finite floating-point scalar")
            origin_value = float(origin)
            if not np.isfinite(origin_value):
                raise ValueError("origin_tdb_jd must be finite")
            if metadata_bytes.ndim != 1 or metadata_bytes.dtype != np.dtype("uint8"):
                raise ValueError("metadata_utf8 must be a one-dimensional uint8 array")
            metadata = json.loads(
                metadata_bytes.tobytes().decode("utf-8", errors="strict"),
                object_pairs_hook=_json_object,
                parse_constant=_invalid_json_constant,
                parse_float=_finite_json_float,
            )
            if not isinstance(metadata, dict):
                raise ValueError("metadata must be a JSON object")
            if metadata.get("profile") != _PROFILE:
                raise ValueError("Chiron orbit profile is missing or unsupported")
            if metadata.get("rights_status") != _RIGHTS_STATUS:
                raise ValueError("Chiron orbit admission declaration is missing or unsupported")

        self._offset_days = _immutable(offsets)
        self._states = _immutable(states)
        self._origin_tdb_jd = origin_value

    def state(self, tdb_jd):
        """Evaluate finite real scalar/array dates; return shape ``(..., 6)``."""
        dates = _real_array(tdb_jd, "tdb_jd")
        with np.errstate(over="ignore", invalid="ignore"):
            offsets = dates - self._origin_tdb_jd
        if not np.all(
            np.isfinite(offsets)
            & (offsets >= self._offset_days[0])
            & (offsets <= self._offset_days[-1])
        ):
            raise ValueError("tdb_jd lies outside the Chiron orbit data interval")

        indices = np.searchsorted(self._offset_days, offsets, side="right") - 1
        # Range validation above means only the exact final knot needs this.
        indices = np.where(indices == self._offset_days.size - 1, indices - 1, indices)
        h = self._offset_days[indices + 1] - self._offset_days[indices]
        u = (offsets - self._offset_days[indices]) / h
        start = self._states[indices]
        end = self._states[indices + 1]
        position, velocity = _hermite(
            start[..., :3], start[..., 3:], end[..., :3], end[..., 3:],
            h[..., np.newaxis], u[..., np.newaxis],
        )
        result = np.concatenate((position, velocity), axis=-1)
        if not np.all(np.isfinite(result)):
            raise ValueError("Chiron orbit interpolation produced non-finite values")
        return result


class ChironVector(VectorFunction):
    """Skyfield heliocentric vector; caller must explicitly add its Sun vector.

    This adapter changes neither the data admission nor its accuracy status.
    Retarded light-time evaluations are also subject to the orbit interval.
    """
    center = 10
    target = 2002060

    def __init__(self, orbit):
        if not isinstance(orbit, ChironOrbit):
            raise ValueError("a validated ChironOrbit is required")
        self.orbit = orbit

    def _at(self, time):
        state = self.orbit.state(time.tdb)
        return (np.moveaxis(state[..., :3], -1, 0),
                np.moveaxis(state[..., 3:], -1, 0), None, None)
