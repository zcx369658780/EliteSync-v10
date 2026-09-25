"""Pure consumer-gate tests; no OpenSSL or server processes."""

import sys
import unittest

sys.dont_write_bytecode = True
from run import FIXED, consume_only_verified, receipt_case


class ConsumerGateTests(unittest.TestCase):
    def test_exact_success_releases_once_and_clears(self):
        buffer = bytearray(FIXED)
        result = receipt_case(0, buffer, True, True, True)
        self.assertEqual("PASS", result["status"])
        self.assertEqual((1, 21), (result["consumer_calls"], result["consumer_bytes"]))
        self.assertTrue(result["buffer_cleared"])
        self.assertEqual(bytearray(len(FIXED)), buffer)

    def test_failure_paths_never_release_even_with_plaintext(self):
        for code, identity, normal, capture_ok in ((4, True, True, True),
                                                   (0, False, True, True),
                                                   (0, True, False, True),
                                                   (None, False, False, False)):
            buffer = bytearray(FIXED)
            with self.subTest(code=code, normal=normal):
                result = consume_only_verified(buffer, code, identity, normal, capture_ok)
                self.assertEqual((0, 0), (result["consumer_calls"], result["consumer_bytes"]))
                self.assertEqual(bytearray(len(FIXED)), buffer)

    def test_wrong_content_and_length_reject(self):
        for value in (bytearray(FIXED[:-1]), bytearray(b"X" + FIXED[1:])):
            result = consume_only_verified(value, 0, True, True, True)
            self.assertEqual((0, 0), (result["consumer_calls"], result["consumer_bytes"]))
            self.assertTrue(all(x == 0 for x in value))


if __name__ == "__main__":
    unittest.main()
