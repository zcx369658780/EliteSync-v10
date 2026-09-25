"""Pure consumer-gate tests; no OpenSSL or server process."""

import hashlib
import sys
import unittest

sys.dont_write_bytecode = True
from run import FIXED, ciphertext_matches, receipt_case


class CiphertextIdentityGateTests(unittest.TestCase):
    def setUp(self):
        self.cipher = bytearray(b"synthetic-ciphertext-for-only-this-test")
        self.length = len(self.cipher)
        self.digest = hashlib.sha256(self.cipher).hexdigest().upper()

    def test_correct_ciphertext_and_plaintext_release_once(self):
        buffer = bytearray(FIXED)
        result = receipt_case(0, buffer, self.cipher, self.length,
                              self.digest, True, True)
        self.assertEqual("PASS", result["status"])
        self.assertTrue(result["identity_match"])
        self.assertEqual((1, 21), (result["consumer_calls"], result["consumer_bytes"]))
        self.assertEqual(bytearray(len(FIXED)), buffer)

    def test_tampered_ciphertext_fake_success_still_rejected_by_identity(self):
        tampered = bytearray(self.cipher)
        tampered[-1] ^= 1
        buffer = bytearray(FIXED)
        result = receipt_case(0, buffer, tampered, self.length,
                              self.digest, True, True)
        self.assertFalse(result["identity_match"])
        self.assertEqual((0, 0), (result["consumer_calls"], result["consumer_bytes"]))
        self.assertTrue(result["buffer_cleared"])
        self.assertEqual(bytearray(len(FIXED)), buffer)
        self.assertFalse(ciphertext_matches(tampered[:-1], self.length, self.digest))

    def test_wrong_key_nonzero_exception_and_wrong_plaintext_reject(self):
        for code, capture_ok, plaintext in ((4, True, FIXED),
                                            (None, False, FIXED),
                                            (0, True, b"X" + FIXED[1:])):
            buffer = bytearray(plaintext)
            with self.subTest(code=code, capture_ok=capture_ok):
                result = receipt_case(code, buffer, self.cipher, self.length,
                                      self.digest, True, capture_ok)
                self.assertTrue(result["identity_match"])
                self.assertEqual((0, 0), (result["consumer_calls"], result["consumer_bytes"]))
                self.assertTrue(result["buffer_cleared"])


if __name__ == "__main__":
    unittest.main()
