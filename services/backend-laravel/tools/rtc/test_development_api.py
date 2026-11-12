import unittest

from serve_development_api import commands


class DevelopmentApiTest(unittest.TestCase):
    def test_authority_uses_a_separate_accept_queue_and_existing_kernel_router(self):
        (public, public_workers), (authority, authority_workers) = commands()
        self.assertEqual(public[public.index('-S') + 1], '0.0.0.0:8080')
        self.assertEqual(authority[authority.index('-S') + 1], '0.0.0.0:8082')
        self.assertEqual(public_workers, 4)
        self.assertEqual(authority_workers, 2)
        self.assertEqual(authority[-1], '/app/tools/rtc/authority_router.php')
        self.assertIn('opcache.validate_timestamps=1', authority)


if __name__ == '__main__':
    unittest.main()
