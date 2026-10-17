import importlib.util
import pathlib
import unittest
import math

path = pathlib.Path(__file__).parents[1] / 'lunar_points.py'
spec = importlib.util.spec_from_file_location('lunar_points', path)
points = importlib.util.module_from_spec(spec)
spec.loader.exec_module(points)


class LunarPointTests(unittest.TestCase):
    def test_ascending_node_is_the_northbound_ecliptic_crossing(self):
        self.assertAlmostEqual(points.ascending_node([1, 0, 0], [0, 1, 0.2]), 0)
        self.assertAlmostEqual(points.ascending_node([0, 1, 0], [-1, 0, 0.2]), 90)
        with self.assertRaises(ValueError):
            points.ascending_node([1, 0, 0], [0, 1, 0])

    def test_mean_apogee_matches_independent_erfa_delaunay_arguments(self):
        import erfa
        for century in (-0.99, -0.6, 0, 0.24, 0.99):
            reference = math.degrees(erfa.faf03(century) + erfa.faom03(century) - erfa.fal03(century)) + 180
            difference = (points.mean_apogee_longitude(century) - reference + 180) % 360 - 180
            self.assertAlmostEqual(difference, 0.0, places=8)


if __name__ == '__main__':
    unittest.main()
