"""Synthetic polynomial/negative tests; no astronomical data or physical oracle."""
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

import numpy as np

SPEC = importlib.util.spec_from_file_location(
    'natal_chiron_orbit', Path(__file__).parents[1] / 'chiron_orbit.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class ChironOrbitTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.path = Path(self.tmp.name) / 'synthetic.npz'
        self.origin = 2451545.0
        self.knots = np.array([-8., 0., 8., 16.])
        self.metadata = dict(
            profile='lowell-astorb2060-dop54-hermite8d-v1',
            rights_status='ADMITTED_FOR_CLOSED_SOURCE_COMPUTATION_WITH_ATTRIBUTION')

    @staticmethod
    def polynomial(t):
        t = np.asarray(t)
        return np.stack((1 + 2*t + 3*t*t + 4*t**3,
                         -3 + t*t, 7 - t,
                         2 + 6*t + 12*t*t, 2*t, -np.ones_like(t)), axis=-1)

    def archive(self, **changes):
        arrays = dict(offset_days=self.knots, states=self.polynomial(self.knots),
                      origin_tdb_jd=np.array(self.origin),
                      metadata_utf8=np.frombuffer(json.dumps(self.metadata).encode(), dtype=np.uint8))
        arrays.update(changes)
        with self.path.open('wb') as stream:
            np.savez(stream, **arrays)
        digest = hashlib.sha256(self.path.read_bytes()).hexdigest()
        return MODULE.ChironOrbit(self.path, digest)

    def test_cubic_value_and_derivative_arbitrary_shape(self):
        orbit = self.archive()
        offsets = np.array([[-8., -3., 0.], [2., 8., 16.]])
        np.testing.assert_allclose(orbit.state(self.origin + offsets),
                                   self.polynomial(offsets), rtol=2e-15, atol=2e-11)
        self.assertEqual(orbit.state(self.origin).shape, (6,))
        self.assertEqual(orbit.state(np.empty((2, 0))).shape, (2, 0, 6))

    def test_knots_including_final_endpoint_and_readonly_storage(self):
        orbit = self.archive()
        np.testing.assert_array_equal(orbit.state(self.origin + self.knots),
                                      self.polynomial(self.knots))
        for array in (orbit._states, orbit._offset_days):
            with self.assertRaises(ValueError):
                array.setflags(write=True)

    def test_invalid_dates_and_outside_interval_are_rejected(self):
        orbit = self.archive()
        for bad in (self.origin-8.00001, self.origin+16.00001, np.nan, np.inf,
                    '2451545', True, 1j, np.array([self.origin, np.nan]),
                    np.array([self.origin], dtype=object)):
            with self.subTest(value=str(bad)), self.assertRaises(ValueError):
                orbit.state(bad)

    def test_hash_pin_rejects_changed_bytes_and_invalid_digest(self):
        self.archive()
        for digest in ('0'*64, '', None, 'g'*64):
            with self.subTest(digest=digest), self.assertRaises(ValueError):
                MODULE.ChironOrbit(self.path, digest)

    def test_shape_dtype_spacing_and_finite_guards(self):
        cases = [dict(offset_days=[0., 0.]), dict(offset_days=[0., 9.]),
                 dict(offset_days=[0.]), dict(offset_days=np.array([[0., 1.]])),
                 dict(offset_days=[0., np.inf]), dict(states=np.zeros((4, 5))),
                 dict(states=np.full((4, 6), np.nan)), dict(states=np.zeros((4, 6), dtype=complex)),
                 dict(states=np.zeros((4, 6), dtype=object)),
                 dict(origin_tdb_jd=np.array([self.origin])), dict(origin_tdb_jd=np.array(1)),
                 dict(origin_tdb_jd=np.array(np.inf)), dict(extra=np.array(0)),
                 dict(metadata_utf8=np.array([1., 2.])),
                 dict(metadata_utf8=np.array([[1, 2]], dtype=np.uint8))]
        for changes in cases:
            with self.subTest(changes=str(changes)), self.assertRaises(ValueError):
                self.archive(**changes)

    def test_metadata_fail_closed(self):
        valid = json.dumps(self.metadata)
        cases = ['[]', '{}', valid.replace('ADMITTED_FOR_CLOSED_SOURCE', 'PENDING_FOR_CLOSED_SOURCE'),
                 valid.replace('hermite8d-v1', 'unknown-v0'),
                 valid[:-1] + ', "x": NaN}', valid[:-1] + ', "x": 1e999}',
                 valid[:-1] + ', "profile": "duplicate"}', '\ud800']
        for raw in cases:
            with self.subTest(raw=repr(raw)), self.assertRaises((ValueError, UnicodeError)):
                self.archive(metadata_utf8=np.frombuffer(raw.encode('utf-8', errors='surrogatepass'), dtype=np.uint8))

    def test_skyfield_vector_preserves_axes_and_rejects_unvalidated_orbit(self):
        from skyfield.api import load
        orbit = self.archive()
        vector = MODULE.ChironVector(orbit)
        ts = load.timescale(builtin=True)
        time = ts.tdb_jd(self.origin + np.array([-3., 2., 16.]))
        position, velocity, center, message = vector._at(time)
        expected = self.polynomial(np.array([-3., 2., 16.]))
        np.testing.assert_allclose(position, expected[:, :3].T, atol=2e-11)
        np.testing.assert_allclose(velocity, expected[:, 3:].T, atol=2e-11)
        self.assertIsNone(center)
        self.assertIsNone(message)
        self.assertEqual(vector.center, 10)
        self.assertEqual(vector.target, 2002060)
        with self.assertRaises(ValueError):
            MODULE.ChironVector(object())


if __name__ == '__main__':
    unittest.main()
